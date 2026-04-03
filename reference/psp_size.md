# Get Table Row Count

Requests the number of rows in the Perspective table. The result is
delivered asynchronously to `input$<outputId>_size`.

## Usage

``` r
psp_size(proxy)
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
psp_size(proxy)
}
```
