# Export Data from a Perspective Viewer

Requests data export from the current Perspective view. The result is
delivered asynchronously to `input$<outputId>_export`.

## Usage

``` r
psp_export(
  proxy,
  format = c("json", "csv", "columns", "arrow"),
  start_row = NULL,
  end_row = NULL,
  start_col = NULL,
  end_col = NULL
)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- format:

  Export format: `"json"` (default), `"csv"`, `"columns"`, or `"arrow"`
  (base64-encoded Arrow IPC).

- start_row:

  Optional single numeric value specifying the first row (0-based) to
  include in the export.

- end_row:

  Optional single numeric value specifying the row (0-based, exclusive)
  at which to stop.

- start_col:

  Optional single numeric value specifying the first column (0-based) to
  include.

- end_col:

  Optional single numeric value specifying the column (0-based,
  exclusive) at which to stop.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_export(proxy, format = "csv")
}
```
