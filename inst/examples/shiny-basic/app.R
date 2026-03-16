library(shiny)
library(peRspective)

ui <- fluidPage(
  titlePanel("peRspective Demo"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("dataset", "Dataset:",
        choices = c("mtcars", "iris", "airquality"),
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
          "Solarized Light", "Solarized Dark",
          "Vaporwave"
        ),
        selected = "Pro Light"
      ),
      hr(),
      h4("Streaming Data Controls"),
      actionButton("add_rows", "Add 5 Random Rows", class = "btn-success"),
      actionButton("replace_data", "Replace With Fresh Data", class = "btn-warning"),
      actionButton("clear_data", "Clear All Data", class = "btn-danger"),
      actionButton("reset_view", "Reset View"),
      hr(),
      h4("Viewer Config (live)"),
      helpText("Interact with the viewer (change columns, filters, etc.)
               and the config will appear here:"),
      verbatimTextOutput("config_display")
    ),
    mainPanel(
      width = 9,
      perspectiveOutput("viewer", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  get_data <- function() {
    switch(input$dataset,
      "mtcars" = mtcars,
      "iris" = iris,
      "airquality" = airquality
    )
  }

  output$viewer <- renderPerspective({
    perspective(get_data(),
      plugin = input$plugin,
      theme = input$theme,
      settings = TRUE
    )
  })

  observeEvent(input$add_rows, {
    proxy <- perspectiveProxy(session, "viewer")
    data <- get_data()
    new_rows <- data[sample(nrow(data), 5, replace = TRUE), ]
    for (col in names(new_rows)) {
      if (is.numeric(new_rows[[col]])) {
        new_rows[[col]] <- round(new_rows[[col]] * runif(5, 0.8, 1.2), 2)
      }
    }
    psp_update(proxy, new_rows)
  })

  observeEvent(input$replace_data, {
    proxy <- perspectiveProxy(session, "viewer")
    data <- get_data()
    subset_data <- data[sample(nrow(data), min(15, nrow(data))), ]
    psp_replace(proxy, subset_data)
  })

  observeEvent(input$clear_data, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_clear(proxy)
  })

  observeEvent(input$reset_view, {
    proxy <- perspectiveProxy(session, "viewer")
    psp_reset(proxy)
  })

  output$config_display <- renderPrint({
    cfg <- input$viewer_config
    if (is.null(cfg)) {
      cat("(interact with the viewer to see config)")
    } else {
      str(cfg, max.level = 2)
    }
  })
}

shinyApp(ui, server)
