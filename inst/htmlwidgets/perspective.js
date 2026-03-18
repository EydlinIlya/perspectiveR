// perspectiveR htmlwidgets binding
// Bridges htmlwidgets' synchronous pattern with Perspective's async ESM initialization

// ---- Perspective Ready Promise ----
// The ESM bundle (perspective-all.mjs) sets window.__perspectiveReady = true
// and dispatches a "perspective-ready" CustomEvent when WASM is initialized.
function waitForPerspective() {
  return new Promise(function (resolve) {
    if (window.__perspectiveReady) {
      resolve(window.__perspectiveWorker);
      return;
    }
    window.addEventListener(
      "perspective-ready",
      function () {
        resolve(window.__perspectiveWorker);
      },
      { once: true }
    );
  });
}

// ---- Base64 decode helper for Arrow IPC ----
function base64ToArrayBuffer(base64) {
  var binaryString = atob(base64);
  var len = binaryString.length;
  var bytes = new Uint8Array(len);
  for (var i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

// ---- Base64 encode helper for Arrow export ----
function arrayBufferToBase64(buffer) {
  var bytes = new Uint8Array(buffer);
  var binary = "";
  for (var i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

// ---- Proxy message processing ----
async function processProxyMessage(el, viewer, table, msg) {
  switch (msg.method) {
    case "update":
      var updateData;
      if (msg.format === "arrow") {
        updateData = base64ToArrayBuffer(msg.data);
      } else {
        updateData = JSON.parse(msg.data);
      }
      await table.update(updateData);
      break;

    case "replace":
      var replaceData;
      if (msg.format === "arrow") {
        replaceData = base64ToArrayBuffer(msg.data);
      } else {
        replaceData = JSON.parse(msg.data);
      }
      await table.replace(replaceData);
      break;

    case "clear":
      await table.clear();
      await viewer.load(table);
      break;

    case "restore":
      if (msg.config) {
        await viewer.restore(msg.config);
      }
      break;

    case "reset":
      await viewer.load(table);
      break;

    case "remove":
      if (msg.keys) {
        await table.remove(msg.keys);
      }
      break;

    case "export":
      var view = await viewer.getView();
      var exportData;
      var format = msg.format || "json";
      var windowOpts = {};
      if (msg.start_row != null) windowOpts.start_row = msg.start_row;
      if (msg.end_row != null) windowOpts.end_row = msg.end_row;
      if (msg.start_col != null) windowOpts.start_col = msg.start_col;
      if (msg.end_col != null) windowOpts.end_col = msg.end_col;
      if (format === "csv") {
        exportData = await view.to_csv(windowOpts);
      } else if (format === "columns") {
        exportData = await view.to_columns(windowOpts);
      } else if (format === "arrow") {
        var arrowBuf = await view.to_arrow(windowOpts);
        exportData = arrayBufferToBase64(arrowBuf);
      } else {
        exportData = await view.to_json(windowOpts);
      }
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_export", {
          format: format,
          data: exportData,
        }, { priority: "event" });
      }
      break;

    case "save":
      var state = await viewer.save();
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_state", state, {
          priority: "event",
        });
      }
      break;

    case "schema":
      var schema = await table.schema();
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_schema", schema, {
          priority: "event",
        });
      }
      break;

    case "size":
      var size = await table.size();
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_size", size, {
          priority: "event",
        });
      }
      break;

    case "columns":
      var columns = await table.columns();
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_columns", columns, {
          priority: "event",
        });
      }
      break;

    case "validate_expressions":
      var validationResult = await table.validate_expressions(msg.expressions);
      if (HTMLWidgets.shinyMode) {
        Shiny.setInputValue(el.id + "_validate_expressions", validationResult, {
          priority: "event",
        });
      }
      break;

    case "on_update":
      if (msg.enable) {
        // Remove existing subscription if any
        if (el.__pspUpdateId != null && el.__pspUpdateView) {
          el.__pspUpdateView.remove_update(el.__pspUpdateId);
          el.__pspUpdateId = null;
          el.__pspUpdateView = null;
        }
        var updateView = await viewer.getView();
        var callback = function (updated) {
          var payload = {
            timestamp: Date.now(),
            port_id: updated.port_id,
            source: updated.port_id > 0 ? "edit" : "api",
          };
          if (HTMLWidgets.shinyMode) {
            Shiny.setInputValue(el.id + "_update", payload, {
              priority: "event",
            });
          }
        };
        el.__pspUpdateView = updateView;
        el.__pspUpdateId = await updateView.on_update(callback);
      } else {
        if (el.__pspUpdateId != null && el.__pspUpdateView) {
          el.__pspUpdateView.remove_update(el.__pspUpdateId);
          el.__pspUpdateId = null;
          el.__pspUpdateView = null;
        }
      }
      break;
  }
}

// ---- htmlwidgets binding ----
HTMLWidgets.widget({
  name: "perspective",
  type: "output",

  factory: function (el, width, height) {
    // State for this widget instance
    var viewer = null;
    var table = null;
    var worker = null;

    return {
      renderValue: async function (x) {
        // Mark not ready while initializing (clears refs from previous render)
        el.__pspViewer = null;
        el.__pspTable = null;

        // Wait for Perspective WASM to be ready
        worker = await waitForPerspective();

        // Clear previous content
        el.innerHTML = "";

        // Create viewer element
        viewer = document.createElement("perspective-viewer");
        viewer.style.width = "100%";
        viewer.style.height = "100%";
        el.appendChild(viewer);

        // Parse data based on format
        var tableData;
        if (x.data_format === "arrow") {
          tableData = base64ToArrayBuffer(x.data);
        } else {
          // JSON column-oriented format
          tableData = JSON.parse(x.data);
        }

        // Create Perspective table.
        // If a schema is provided (from R type detection), create a typed
        // table first so Perspective knows date/datetime column types
        // rather than inferring them as strings.
        var tableOpts = {};
        if (x.index) tableOpts.index = x.index;
        if (x.limit) tableOpts.limit = x.limit;

        if (x.data_format !== "arrow" && x.schema) {
          var pspSchema = {};
          var schemaKeys = Object.keys(x.schema);
          for (var si = 0; si < schemaKeys.length; si++) {
            pspSchema[schemaKeys[si]] = x.schema[schemaKeys[si]];
          }
          table = await worker.table(pspSchema, tableOpts);
          await table.update(tableData);
        } else {
          table = await worker.table(tableData, tableOpts);
        }

        // Load table into viewer
        await viewer.load(table);

        // Apply configuration via restore
        if (x.config && Object.keys(x.config).length > 0) {
          var config = {};

          if (x.config.columns) config.columns = x.config.columns;
          if (x.config.group_by) config.group_by = x.config.group_by;
          if (x.config.split_by) config.split_by = x.config.split_by;
          if (x.config.sort) config.sort = x.config.sort;
          if (x.config.filter) config.filter = x.config.filter;
          if (x.config.filter_op) config.filter_op = x.config.filter_op;
          if (x.config.expressions) config.expressions = x.config.expressions;
          if (x.config.aggregates) config.aggregates = x.config.aggregates;
          if (x.config.plugin) config.plugin = x.config.plugin;
          if (x.config.plugin_config)
            config.plugin_config = x.config.plugin_config;
          if (x.config.title !== undefined && x.config.title !== null)
            config.title = x.config.title;

          if (Object.keys(config).length > 0) {
            await viewer.restore(config);
          }
        }

        // Settings panel visibility
        if (x.config && x.config.settings === false) {
          viewer.toggleConfig(false);
        } else {
          // Default: open the settings panel
          viewer.toggleConfig(true);
        }

        // Editable mode
        if (x.config && x.config.editable) {
          viewer.setAttribute("editable", "");
        }

        // Apply theme via attribute
        if (x.theme) {
          viewer.setAttribute("theme", x.theme);
        }

        // ---- Shiny event forwarding ----
        if (HTMLWidgets.shinyMode) {
          // Forward config changes to R
          viewer.addEventListener("perspective-config-update", function () {
            viewer.save().then(function (cfg) {
              Shiny.setInputValue(el.id + "_config", cfg, {
                priority: "event",
              });
            });
          });

          // Forward click events to R
          viewer.addEventListener("perspective-click", function (event) {
            Shiny.setInputValue(el.id + "_click", event.detail, {
              priority: "event",
            });
          });

          // Forward select events to R
          viewer.addEventListener("perspective-select", function (event) {
            Shiny.setInputValue(el.id + "_select", event.detail, {
              priority: "event",
            });
          });
        }

        // Store references on the element for proxy access
        el.__pspViewer = viewer;
        el.__pspTable = table;
        el.__pspWorker = worker;

        // Flush any proxy messages that arrived during async initialization
        if (el.__pspPendingMsgs) {
          var pending = el.__pspPendingMsgs;
          el.__pspPendingMsgs = [];
          for (var pi = 0; pi < pending.length; pi++) {
            await processProxyMessage(el, viewer, table, pending[pi]);
          }
        }
      },

      resize: function (width, height) {
        if (viewer && viewer.notifyResize) {
          viewer.notifyResize();
        }
      },

      // Expose for proxy access
      getViewer: function () {
        return viewer;
      },
      getTable: function () {
        return table;
      },
    };
  },
});

// ---- Shiny proxy message handler ----
if (HTMLWidgets.shinyMode) {
  Shiny.addCustomMessageHandler("perspective-calls", function (msg) {
    var el = document.getElementById(msg.id);
    if (!el) return;

    // Queue messages that arrive before the viewer is ready
    if (!el.__pspViewer || !el.__pspTable) {
      if (!el.__pspPendingMsgs) el.__pspPendingMsgs = [];
      el.__pspPendingMsgs.push(msg);
      return;
    }

    processProxyMessage(el, el.__pspViewer, el.__pspTable, msg);
  });
}
