// Loader script for Perspective ESM module
// htmlwidgets loads scripts as regular <script> tags, but Perspective
// requires ESM (type="module"). This loader dynamically creates the
// module script element.
(function () {
  if (window.__perspectiveLoading) return;
  window.__perspectiveLoading = true;

  // Find the path to perspective-all.mjs relative to this loader script
  var scripts = document.querySelectorAll("script");
  var loaderScript = scripts[scripts.length - 1];
  var loaderSrc = loaderScript.src || "";
  var basePath = loaderSrc.substring(0, loaderSrc.lastIndexOf("/") + 1);

  var moduleScript = document.createElement("script");
  moduleScript.type = "module";
  moduleScript.src = basePath + "perspective-all.mjs";
  document.head.appendChild(moduleScript);
})();
