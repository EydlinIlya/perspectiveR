# peRspective

R htmlwidgets binding for the [FINOS Perspective](https://perspective.finos.org/) library -- a high-performance WebAssembly-powered data visualization engine with interactive pivot tables and 12+ chart types.

## Installation

```r
# Install from source (requires the built JS bundle)
devtools::install_local(".")
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

## Shiny Usage

```r
library(shiny)
library(peRspective)

ui <- fluidPage(
  perspectiveOutput("viewer", height = "600px")
)

server <- function(input, output, session) {
  output$viewer <- renderPerspective({
    perspective(mtcars, plugin = "Y Bar", group_by = "cyl")
  })

  # Stream new data
  observeEvent(input$add, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_update(proxy, new_data)
  })

  # Capture user's interactive config changes
  observeEvent(input$viewer_config, {
    saved_config <- input$viewer_config
  })
}
```

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
