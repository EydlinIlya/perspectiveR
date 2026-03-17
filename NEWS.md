# peRspective 0.3.0

* Added `psp_schema()`, `psp_size()`, `psp_columns()`, and
  `psp_validate_expressions()` proxy functions for table introspection.
* Added `filter_op` parameter for programmatic filter operators.
* Added `limit` parameter to cap the number of rows loaded into the table.
* Added `expressions` parameter for computed/virtual columns.
* Added windowed export support to `psp_export()` via `start_row`, `end_row`,
  `start_col`, and `end_col` parameters.
* Added three new demo apps: streaming stock market, editable table, and
  expression builder.

# peRspective 0.2.0

* Added `index` parameter for keyed/indexed tables.
* Added `psp_remove()` to delete rows by primary key.
* Added `psp_export()` to export view data as JSON, CSV, columns, or Arrow.
* Added `psp_save()` to retrieve the current viewer configuration.
* Added `psp_on_update()` to subscribe to table update events.
* Added `input$<outputId>_select` event for row/data-point selection.
* Added theme support for dark mode and custom styling.

# peRspective 0.1.0

* Initial release.
* `perspective()` widget with support for 14 chart types.
* Shiny integration via `perspectiveOutput()`, `renderPerspective()`, and
  `perspectiveProxy()`.
* Proxy functions: `psp_update()`, `psp_replace()`, `psp_clear()`,
  `psp_restore()`, and `psp_reset()`.
* Arrow IPC serialization for high-performance data transfer.
* Bundled Shiny demo app with `run_example()`.
