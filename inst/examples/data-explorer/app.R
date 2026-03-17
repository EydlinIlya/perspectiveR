library(shiny)
library(peRspective)

# Prepare airquality with a proper Date column
aq <- airquality
aq$Date <- as.Date(paste("1973", aq$Month, aq$Day, sep = "-"))
aq <- aq[order(aq$Date), ]
rownames(aq) <- NULL

# Helper to build expression object (mirrors internal .build_expressions)
build_expr <- function(expr_str) {
  result <- as.list(expr_str)
  names(result) <- expr_str
  result
}

ui <- fluidPage(
  titlePanel("Data Explorer Demo"),
  sidebarLayout(
    sidebarPanel(
      width = 4,

      h4("Data Mode"),
      radioButtons("data_mode", NULL,
        choices = c("Full Dataset" = "full", "Rolling Window" = "rolling"),
        selected = "full", inline = TRUE
      ),
      conditionalPanel(
        condition = "input.data_mode == 'rolling'",
        sliderInput("window_size", "Window Size:", min = 10, max = 100, value = 30),
        actionButton("start_stream", "Start Stream", class = "btn-success"),
        actionButton("stop_stream", "Stop Stream", class = "btn-warning")
      ),

      hr(),
      h4("Filter Demo"),
      checkboxInput("filter_ozone", "Ozone > 60", value = FALSE),
      checkboxInput("filter_temp", "Temp > 85", value = FALSE),
      checkboxInput("filter_wind", "Wind < 8", value = FALSE),
      radioButtons("filter_op", "Combine filters with:",
        choices = c("and", "or"), selected = "and", inline = TRUE
      ),
      actionButton("apply_filters", "Apply Filters", class = "btn-primary"),

      hr(),
      h4("Expressions"),
      textInput("expr_input", "Expression:",
        placeholder = '// Temp in Celsius\n("Temp" - 32) * 5 / 9'
      ),
      helpText(
        'Examples: "Ozone" * 2, ("Temp" - 32) * 5 / 9,',
        'if("Ozone" > 60) "High" else "Low"'
      ),
      actionButton("validate_expr", "Validate"),
      actionButton("add_expr", "Add to View", class = "btn-primary"),
      verbatimTextOutput("validation_result"),

      hr(),
      h4("Table Metadata"),
      actionButton("get_schema", "Schema"),
      actionButton("get_size", "Size"),
      actionButton("get_columns", "Columns"),
      verbatimTextOutput("metadata_display"),

      hr(),
      h4("Windowed Export"),
      fluidRow(
        column(6, numericInput("start_row", "Start Row:", value = 0, min = 0)),
        column(6, numericInput("end_row", "End Row:", value = 10, min = 1))
      ),
      fluidRow(
        column(6, numericInput("start_col", "Start Col:", value = 0, min = 0)),
        column(6, numericInput("end_col", "End Col:", value = 3, min = 1))
      ),
      radioButtons("window_export_format", "Format:",
        choices = c("json", "csv"), inline = TRUE
      ),
      actionButton("windowed_export", "Export Window", class = "btn-info"),
      verbatimTextOutput("export_preview")
    ),
    mainPanel(
      width = 8,
      perspectiveOutput("viewer", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  streaming <- reactiveVal(FALSE)
  stream_row <- reactiveVal(1)
  metadata_text <- reactiveVal(NULL)
  validation_text <- reactiveVal(NULL)
  export_text <- reactiveVal(NULL)

  # Initial render
  output$viewer <- renderPerspective({
    perspective(aq, sort = list(c("Date", "asc")))
  })

  proxy <- reactive(perspectiveProxy(session, "viewer"))

  # Data mode switch
  observeEvent(input$data_mode, {
    streaming(FALSE)
    stream_row(1)
    if (input$data_mode == "full") {
      output$viewer <- renderPerspective({
        perspective(aq, sort = list(c("Date", "asc")))
      })
    } else {
      ws <- input$window_size
      output$viewer <- renderPerspective({
        perspective(aq[1, ], limit = ws, sort = list(c("Date", "asc")))
      })
    }
  }, ignoreInit = TRUE)

  # Start/stop streaming
  observeEvent(input$start_stream, {
    stream_row(1)
    streaming(TRUE)
  })

  observeEvent(input$stop_stream, {
    streaming(FALSE)
  })

  # Stream rows when in rolling mode
  observe({
    req(streaming())
    invalidateLater(500)

    pos <- isolate(stream_row())
    if (pos > nrow(aq)) {
      streaming(FALSE)
      return()
    }

    psp_update(proxy(), aq[pos, ])
    stream_row(pos + 1)
  })

  # Apply filters
  observeEvent(input$apply_filters, {
    filters <- list()
    if (input$filter_ozone) filters[[length(filters) + 1]] <- c("Ozone", ">", "60")
    if (input$filter_temp) filters[[length(filters) + 1]] <- c("Temp", ">", "85")
    if (input$filter_wind) filters[[length(filters) + 1]] <- c("Wind", "<", "8")

    config <- list()
    if (length(filters) > 0) {
      config$filter <- filters
      config$filter_op <- input$filter_op
    } else {
      config$filter <- list()
    }
    psp_restore(proxy(), config)
  })

  # Validate expression
  observeEvent(input$validate_expr, {
    req(nzchar(input$expr_input))
    psp_validate_expressions(proxy(), input$expr_input)
    validation_text("Validating...")
  })

  observeEvent(input$viewer_validate_expressions, {
    result <- input$viewer_validate_expressions
    if (is.null(result)) return()
    validation_text(
      paste(utils::capture.output(utils::str(result, max.level = 3)), collapse = "\n")
    )
  })

  output$validation_result <- renderText(validation_text())

  # Add expression to view
  observeEvent(input$add_expr, {
    req(nzchar(input$expr_input))
    psp_restore(proxy(), list(expressions = build_expr(input$expr_input)))
  })

  # Table metadata
  observeEvent(input$get_schema, {
    psp_schema(proxy())
    metadata_text("Fetching schema...")
  })

  observeEvent(input$get_size, {
    psp_size(proxy())
    metadata_text("Fetching size...")
  })

  observeEvent(input$get_columns, {
    psp_columns(proxy())
    metadata_text("Fetching columns...")
  })

  observeEvent(input$viewer_schema, {
    result <- input$viewer_schema
    if (is.null(result)) return()
    metadata_text(paste("Schema:\n",
      paste(utils::capture.output(utils::str(result)), collapse = "\n")))
  })

  observeEvent(input$viewer_size, {
    result <- input$viewer_size
    if (is.null(result)) return()
    metadata_text(paste("Row count:", result))
  })

  observeEvent(input$viewer_columns, {
    result <- input$viewer_columns
    if (is.null(result)) return()
    metadata_text(paste("Columns:\n", paste(unlist(result), collapse = ", ")))
  })

  output$metadata_display <- renderText(metadata_text())

  # Windowed export
  observeEvent(input$windowed_export, {
    psp_export(proxy(),
      format = input$window_export_format,
      start_row = input$start_row,
      end_row = input$end_row,
      start_col = input$start_col,
      end_col = input$end_col
    )
    export_text("Exporting...")
  })

  observeEvent(input$viewer_export, {
    result <- input$viewer_export
    if (is.null(result)) return()
    preview <- if (is.character(result)) {
      substr(result, 1, 2000)
    } else {
      paste(utils::capture.output(utils::str(result, max.level = 2)), collapse = "\n")
    }
    export_text(preview)
  })

  output$export_preview <- renderText(export_text())
}

shinyApp(ui, server)
