library(shiny)
library(peRspective)

ui <- fluidPage(
  titlePanel("peRspective Shiny Demo"),
  sidebarLayout(
    sidebarPanel(
      selectInput("dataset", "Dataset:",
        choices = c("mtcars", "iris", "diamonds"),
        selected = "mtcars"
      ),
      selectInput("plugin", "Chart Type:",
        choices = c(
          "Datagrid", "Y Bar", "X Bar", "Y Line",
          "Y Area", "Y Scatter", "XY Scatter",
          "Treemap", "Sunburst", "Heatmap"
        ),
        selected = "Datagrid"
      ),
      selectInput("theme", "Theme:",
        choices = c(
          "Pro Light", "Pro Dark", "Monokai",
          "Solarized Light", "Solarized Dark", "Vaporwave"
        ),
        selected = "Pro Light"
      ),
      actionButton("update_btn", "Add Random Rows"),
      actionButton("clear_btn", "Clear Data"),
      actionButton("reset_btn", "Reset View"),
      hr(),
      h4("Current Config (from viewer):"),
      verbatimTextOutput("config_output")
    ),
    mainPanel(
      perspectiveOutput("viewer", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  # Reactive dataset
  current_data <- reactiveVal(mtcars)

  observeEvent(input$dataset, {
    data <- switch(input$dataset,
      "mtcars" = mtcars,
      "iris" = iris,
      "diamonds" = {
        if (requireNamespace("ggplot2", quietly = TRUE)) {
          ggplot2::diamonds[1:1000, ]
        } else {
          mtcars
        }
      }
    )
    current_data(data)
  })

  # Render the perspective widget
  output$viewer <- renderPerspective({
    perspective(current_data(),
      plugin = input$plugin,
      theme = input$theme,
      settings = TRUE
    )
  })

  # Proxy operations
  observeEvent(input$update_btn, {
    proxy <- perspectiveProxy(session, "viewer")
    data <- current_data()
    # Add some random rows based on existing data
    n <- min(5, nrow(data))
    new_rows <- data[sample(nrow(data), n, replace = TRUE), ]
    # Add some noise to numeric columns
    for (col in names(new_rows)) {
      if (is.numeric(new_rows[[col]])) {
        new_rows[[col]] <- new_rows[[col]] * runif(n, 0.8, 1.2)
      }
    }
    psp_update(proxy, new_rows)
  })

  observeEvent(input$clear_btn, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_clear(proxy)
  })

  observeEvent(input$reset_btn, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_reset(proxy)
  })

  # Display config changes from viewer
  output$config_output <- renderPrint({
    cfg <- input$viewer_config
    if (is.null(cfg)) {
      cat("(interact with the viewer to see config)")
    } else {
      str(cfg, max.level = 2)
    }
  })
}

shinyApp(ui, server)
