library(shiny)
library(peRspective)

# Prepare airquality with a proper Date column
aq <- airquality
aq$Date <- as.Date(paste("1973", aq$Month, aq$Day, sep = "-"))
aq <- aq[order(aq$Date), ]
rownames(aq) <- NULL

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
      actionButton("prepare_export", "Prepare Export", class = "btn-info"),
      conditionalPanel(
        condition = "output.export_available",
        downloadButton("download_export", "Download", class = "btn-success")
      )
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
  export_result <- reactiveVal(NULL)
  export_ready <- reactiveVal(FALSE)
  export_fmt <- reactiveVal("json")

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

  # Windowed export (two-step: prepare then download)
  observeEvent(input$prepare_export, {
    export_ready(FALSE)
    export_result(NULL)
    export_fmt(input$window_export_format)
    psp_export(proxy(),
      format = input$window_export_format,
      start_row = input$start_row,
      end_row = input$end_row,
      start_col = input$start_col,
      end_col = input$end_col
    )
  })

  observeEvent(input$viewer_export, {
    result <- input$viewer_export
    if (is.null(result)) return()
    export_result(result)
    export_ready(TRUE)
  })

  # Gate the download button visibility
  output$export_available <- reactive(export_ready())
  outputOptions(output, "export_available", suspendWhenHidden = FALSE)

  # Download handler
  output$download_export <- downloadHandler(
    filename = function() {
      fmt <- export_fmt()
      paste0("perspective_export.", fmt)
    },
    content = function(file) {
      result <- export_result()
      fmt <- export_fmt()
      if (fmt == "csv") {
        writeLines(result$data, file)
      } else {
        jsonlite::write_json(result$data, file, auto_unbox = TRUE, pretty = TRUE)
      }
    }
  )
}

shinyApp(ui, server)
