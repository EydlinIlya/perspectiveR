# Run a perspectiveR Example App

Launches a bundled Shiny example app demonstrating the perspectiveR
widget.

## Usage

``` r
run_example(example = NULL, ...)
```

## Arguments

- example:

  Name of the example to run. Use `NULL` (default) to list available
  examples.

- ...:

  Additional arguments passed to
  [`runApp`](https://rdrr.io/pkg/shiny/man/runApp.html).

## Value

If `example` is `NULL`, a character vector of available example names
(invisibly). Otherwise, no return value; called for the side effect of
launching a Shiny app.

## Examples

``` r
# List available examples
run_example()
#> Available perspectiveR examples:
#>   crud-table
#>   shiny-basic
#>   spinning-donut
#> 
#> Run one with: run_example("crud-table")

# Launch the demo app
if (interactive()) {
run_example("shiny-basic")
}
```
