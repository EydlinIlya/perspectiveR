# Changelog

## perspectiveR 0.3.1

- Fixed theme initialization: themes now apply atomically with the
  plugin via `restore()`, preventing a flash of default colors on first
  render.
- Added pkgdown site with interactive article.
- Resized logo.

## perspectiveR 0.3.0

CRAN release: 2026-03-30

- Added
  [`psp_schema()`](https://eydlinilya.github.io/perspectiveR/reference/psp_schema.md),
  [`psp_size()`](https://eydlinilya.github.io/perspectiveR/reference/psp_size.md),
  [`psp_columns()`](https://eydlinilya.github.io/perspectiveR/reference/psp_columns.md),
  and
  [`psp_validate_expressions()`](https://eydlinilya.github.io/perspectiveR/reference/psp_validate_expressions.md)
  proxy functions for table introspection.
- Added `filter_op` parameter for programmatic filter operators.
- Added `limit` parameter to cap the number of rows loaded into the
  table.
- Added `expressions` parameter for computed/virtual columns.
- Added windowed export support to
  [`psp_export()`](https://eydlinilya.github.io/perspectiveR/reference/psp_export.md)
  via `start_row`, `end_row`, `start_col`, and `end_col` parameters.
- Added three new demo apps: streaming stock market, editable table, and
  expression builder.

## perspectiveR 0.2.0

- Added `index` parameter for keyed/indexed tables.
- Added
  [`psp_remove()`](https://eydlinilya.github.io/perspectiveR/reference/psp_remove.md)
  to delete rows by primary key.
- Added
  [`psp_export()`](https://eydlinilya.github.io/perspectiveR/reference/psp_export.md)
  to export view data as JSON, CSV, columns, or Arrow.
- Added
  [`psp_save()`](https://eydlinilya.github.io/perspectiveR/reference/psp_save.md)
  to retrieve the current viewer configuration.
- Added
  [`psp_on_update()`](https://eydlinilya.github.io/perspectiveR/reference/psp_on_update.md)
  to subscribe to table update events.
- Added `input$<outputId>_select` event for row/data-point selection.
- Added theme support for dark mode and custom styling.

## perspectiveR 0.1.0

- Initial release.
- [`perspective()`](https://eydlinilya.github.io/perspectiveR/reference/perspective.md)
  widget with support for multiple chart types.
- Shiny integration via
  [`perspectiveOutput()`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveOutput.md),
  [`renderPerspective()`](https://eydlinilya.github.io/perspectiveR/reference/renderPerspective.md),
  and
  [`perspectiveProxy()`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md).
- Proxy functions:
  [`psp_update()`](https://eydlinilya.github.io/perspectiveR/reference/psp_update.md),
  [`psp_replace()`](https://eydlinilya.github.io/perspectiveR/reference/psp_replace.md)no,
  [`psp_clear()`](https://eydlinilya.github.io/perspectiveR/reference/psp_clear.md),
  [`psp_restore()`](https://eydlinilya.github.io/perspectiveR/reference/psp_restore.md),
  and
  [`psp_reset()`](https://eydlinilya.github.io/perspectiveR/reference/psp_reset.md).
- Arrow IPC serialization for high-performance data transfer.
- Bundled Shiny demo app with
  [`run_example()`](https://eydlinilya.github.io/perspectiveR/reference/run_example.md).
