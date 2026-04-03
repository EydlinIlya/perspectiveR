# Get Table Schema

Requests the schema (column names and types) of the Perspective table.
The result is delivered asynchronously to `input$<outputId>_schema`.

## Usage

``` r
psp_schema(proxy)
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
psp_schema(proxy)
}
```
