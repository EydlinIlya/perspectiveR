# Validate Expressions

Validates Perspective expression strings against the table without
applying them. The result is delivered asynchronously to
`input$<outputId>_validate_expressions`.

## Usage

``` r
psp_validate_expressions(proxy, expressions)
```

## Arguments

- proxy:

  A
  [`perspectiveProxy`](https://eydlinilya.github.io/perspectiveR/reference/perspectiveProxy.md)
  object.

- expressions:

  A non-empty character vector of expression strings.

## Value

The proxy object (invisibly), for chaining.

## Examples

``` r
if (interactive()) {
proxy <- perspectiveProxy(session, "viewer")
psp_validate_expressions(proxy, expressions = c("\"col1\" + \"col2\""))
}
```
