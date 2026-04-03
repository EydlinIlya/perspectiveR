# Subscribe to Table Update Events

Enables or disables a subscription to table data changes. When enabled,
every `table.update()` triggers `input$<outputId>_update` with a list
containing `timestamp`, `port_id`, and `source` (`"edit"` for user
edits, `"api"` for programmatic updates).

## Usage

``` r
psp_on_update(proxy, enable = TRUE)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- enable:

  Logical; `TRUE` to subscribe, `FALSE` to unsubscribe. Default `TRUE`.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_on_update(proxy)
}
```
