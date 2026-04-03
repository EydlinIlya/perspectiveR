# Render a Perspective Viewer in Shiny

Server-side rendering function for the Perspective widget.

## Usage

``` r
renderPerspective(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- expr:

  An expression that returns a
  [`perspective`](https://eydlinilya.github.io/perspectiveR/reference/perspective.md)
  widget.

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Logical; is `expr` a quoted expression?

## Value

A Shiny render function.

## Examples

``` r
if (interactive()) {
server <- function(input, output) {
  output$viewer <- renderPerspective({
    perspective(mtcars, group_by = "cyl", plugin = "Y Bar")
  })
}
}
```
