// peRspective htmlwidgets binding
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

// ---- Theme management ----
function applyTheme(viewer, theme) {
  // Remove all existing theme classes
  var themeClasses = [
    "perspective-viewer-material",
    "perspective-viewer-material-dark",
    "perspective-viewer-material-dense",
  ];
  themeClasses.forEach(function (cls) {
    viewer.classList.remove(cls);
  });

  // Perspective v3 uses a theme attribute
  if (theme) {
    viewer.setAttribute("theme", theme);
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
        // Wait for Perspective WASM to be ready
        worker = await waitForPerspective();

        // Clear previous content
        el.innerHTML = "";

        // Create viewer element
        viewer = document.createElement("perspective-viewer");
        viewer.style.width = "100%";
        viewer.style.height = "100%";
        el.appendChild(viewer);

        // Apply theme
        applyTheme(viewer, x.theme);

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
        if (x.data_format !== "arrow" && x.schema) {
          var pspSchema = {};
          var schemaKeys = Object.keys(x.schema);
          for (var si = 0; si < schemaKeys.length; si++) {
            pspSchema[schemaKeys[si]] = x.schema[schemaKeys[si]];
          }
          table = await worker.table(pspSchema);
          await table.update(tableData);
        } else {
          table = await worker.table(tableData);
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
        }

        // Store references on the element for proxy access
        el.__pspViewer = viewer;
        el.__pspTable = table;
        el.__pspWorker = worker;
      },

      resize: function (width, height) {
        if (viewer) {
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
  Shiny.addCustomMessageHandler("perspective-calls", async function (msg) {
    var el = document.getElementById(msg.id);
    if (!el) return;

    var viewer = el.__pspViewer;
    var table = el.__pspTable;

    if (!viewer || !table) return;

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
        break;

      case "restore":
        if (msg.config) {
          await viewer.restore(msg.config);
        }
        break;

      case "reset":
        await viewer.reset();
        break;
    }
  });
}
