// Entry point for esbuild bundling of Perspective ESM modules
// Uses the .inline.js builds which have WASM embedded as base64.

import perspective from "@finos/perspective/dist/esm/perspective.inline.js";
import "@finos/perspective-viewer/dist/esm/perspective-viewer.inline.js";
import "@finos/perspective-viewer-datagrid/dist/esm/perspective-viewer-datagrid.js";
import "@finos/perspective-viewer-d3fc/dist/esm/perspective-viewer-d3fc.js";

// Create a shared worker instance and expose it globally
const worker = await perspective.worker();
window.__perspectiveWorker = worker;
window.__perspectiveReady = true;
window.dispatchEvent(new CustomEvent("perspective-ready"));
