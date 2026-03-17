# peRspective

R htmlwidgets binding for the [FINOS Perspective](https://perspective.finos.org/) library -- a high-performance WebAssembly-powered data visualization engine with interactive pivot tables and 12+ chart types.

## Installation

```r
# Install from GitHub
remotes::install_github("EydlinIlya/peRspective")

# Or using pak
pak::pak("EydlinIlya/peRspective")

# Or using devtools
devtools::install_github("EydlinIlya/peRspective")
```

## Quick Start

```r
library(peRspective)

# Interactive data grid with full self-service UI
perspective(mtcars)

# Bar chart grouped by cylinder count
perspective(mtcars, group_by = "cyl", plugin = "Y Bar")

# Filtered scatter plot
perspective(iris,
  columns = c("Sepal.Length", "Sepal.Width", "Species"),
  filter = list(c("Species", "==", "setosa")),
  plugin = "Y Scatter"
)
```

## Features

- **12+ visualization types**: Datagrid, bar, line, area, scatter, heatmap, treemap, sunburst, and more
- **Self-service interactive UI**: Drag-and-drop columns, switch chart types, add filters/sorts/pivots, create computed expressions
- **High performance**: WebAssembly-powered compute engine runs entirely in the browser
- **Shiny integration**: Output/render bindings plus proxy interface for streaming data updates
- **Arrow IPC support**: Optional `arrow` package integration for efficient serialization of large datasets
- **Works everywhere**: RStudio Viewer, R Markdown, Quarto, and Shiny

## Shiny Demo

A streaming stock market demo is bundled with the package:

```r
library(peRspective)
run_example("shiny-basic")
```

This launches a Shiny app that replays European stock market data (DAX, SMI,
CAC, FTSE 1991-1998) as an X/Y Line chart, streaming one row per second with
a 100-row sliding window. Select a year and drag additional indices from the
column list to compare.

### Shiny Usage

```r
library(shiny)
library(peRspective)

ui <- fluidPage(
  selectInput("dataset", "Dataset:",
    choices = c("mtcars", "iris", "airquality")
  ),
  perspectiveOutput("viewer", height = "600px")
)

server <- function(input, output, session) {
  output$viewer <- renderPerspective({
    data <- switch(input$dataset,
      "mtcars" = mtcars,
      "iris" = iris,
      "airquality" = airquality
    )
    perspective(data)
  })
}

shinyApp(ui, server)
```

### Proxy Functions

- `psp_update(proxy, data)` — append new rows
- `psp_replace(proxy, data)` — replace all data
- `psp_clear(proxy)` — clear all rows
- `psp_restore(proxy, config)` — apply a saved config
- `psp_reset(proxy)` — reset viewer to defaults

## Building the JS Bundle

The pre-built JS bundle is included. To rebuild from source:

```bash
cd tools
npm install
npm run build
npm run copy-themes
```

## License

Apache License 2.0
