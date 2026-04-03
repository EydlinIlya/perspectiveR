# Get Table Column Names

Requests the column names of the Perspective table. The result is
delivered asynchronously to `input$<outputId>_columns`.

## Usage

``` r
psp_columns(proxy)
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
psp_columns(proxy)
}
```
