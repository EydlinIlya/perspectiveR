## R CMD check results

0 errors | 0 warnings | 1 note

* This is a first submission.

## Notes for CRAN reviewers

* **Installed size / bundled assets**: The package bundles the FINOS Perspective
  v3.1.3 JavaScript and WebAssembly library (~5 MB) in `inst/htmlwidgets/`.
  This is the upstream build from <https://github.com/finos/perspective> and is
  required for the widget to function. Source attribution is documented in
  `inst/COPYRIGHTS`.

* **`:::` usage**: The triple-colon operator appears only in test files

  (`tests/testthat/`) to access the internal helper `.serialize_json` for
  serialization round-trip tests. It is not used in any package code.
