# Save Viewer State

Requests the current viewer configuration (columns, pivots, filters,
sort, plugin, etc.). The result is delivered asynchronously to
`input$<outputId>_state`.

## Usage

``` r
psp_save(proxy)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_save(proxy)
}
```
