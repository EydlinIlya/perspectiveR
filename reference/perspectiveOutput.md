# Shiny Output for Perspective Viewer

Creates a Perspective viewer output element for use in a Shiny UI.

## Usage

``` r
perspectiveOutput(outputId, width = "100%", height = "400px")
```

## Arguments

- outputId:

  Output variable name.

- width:

  CSS width (default `"100%"`).

- height:

  CSS height (default `"400px"`).

## Value

A Shiny output element.

## Details

The following reactive inputs are available (where `outputId` is the ID
you supply):

- `input$<outputId>_config`:

  Viewer configuration changes.

- `input$<outputId>_click`:

  Cell/data-point click events.

- `input$<outputId>_select`:

  Row/data-point selection events.

- `input$<outputId>_update`:

  Table data changes (requires
  [`psp_on_update`](https://eydlinilya.github.io/perspectiveR/reference/psp_on_update.md)).

- `input$<outputId>_export`:

  Exported data (after
  [`psp_export`](https://eydlinilya.github.io/perspectiveR/reference/psp_export.md)).

- `input$<outputId>_state`:

  Saved viewer state (after
  [`psp_save`](https://eydlinilya.github.io/perspectiveR/reference/psp_save.md)).

- `input$<outputId>_schema`:

  Table schema (after
  [`psp_schema`](https://eydlinilya.github.io/perspectiveR/reference/psp_schema.md)).

- `input$<outputId>_size`:

  Table row count (after
  [`psp_size`](https://eydlinilya.github.io/perspectiveR/reference/psp_size.md)).

- `input$<outputId>_columns`:

  Table column names (after
  [`psp_columns`](https://eydlinilya.github.io/perspectiveR/reference/psp_columns.md)).

- `input$<outputId>_validate_expressions`:

  Expression validation results (after
  [`psp_validate_expressions`](https://eydlinilya.github.io/perspectiveR/reference/psp_validate_expressions.md)).

## Examples

``` r
if (interactive()) {
library(shiny)
ui <- fluidPage(
  perspectiveOutput("viewer", height = "600px")
)
}
```
