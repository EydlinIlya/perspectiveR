library(shiny)
library(peRspective)

# European stock market closing prices (1991-1998)
stocks <- as.data.frame(EuStockMarkets)
stocks$Date <- seq(as.Date("1991-07-01"), length.out = nrow(stocks), by = "day")
stocks <- stocks[, c("Date", "DAX", "SMI", "CAC", "FTSE")]
stocks$Year <- as.integer(format(stocks$Date, "%Y"))
available_years <- sort(unique(stocks$Year))

WINDOW_SIZE <- 100

# Helper to build expression object (mirrors internal .build_expressions)
build_expr <- function(expr_str) {
  result <- as.list(expr_str)
  names(result) <- expr_str
  result
}

ui <- fluidPage(
  titlePanel("peRspective Demo"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput("year", "Year:",
        choices = available_years,
        selected = available_years[1]
      ),
      actionButton("start_over", "Start Over", class = "btn-primary"),
      hr(),
      checkboxInput("use_arrow", "Use Arrow IPC serialization",
        value = requireNamespace("arrow", quietly = TRUE)
      ),

      hr(),
      h4("Expressions"),
      textInput("expr_input", "Expression:",
        placeholder = '// DAX in USD\n"DAX" * 0.6'
      ),
      helpText(
        'Examples: "DAX" * 0.6, "SMI" - "DAX",',
        'if("DAX" > 3000) "High" else "Low"'
      ),
      actionButton("validate_expr", "Validate"),
      actionButton("add_expr", "Add to View", class = "btn-primary"),
      verbatimTextOutput("validation_result"),

      hr(),
      h4("Named States"),
      textInput("state_name", "State name:", placeholder = "e.g. My Layout"),
      actionButton("save_state", "Save State", class = "btn-info"),
      selectInput("saved_states_list", "Saved states:", choices = NULL),
      actionButton("restore_state", "Restore", class = "btn-success"),
      textOutput("state_status"),

      hr(),
      helpText(
        "EU stock indices streamed row by row.",
        "Drag columns in the viewer to compare indices.",
        "Toggle Arrow IPC for faster serialization (requires arrow package)."
      )
    ),
    mainPanel(
      width = 9,
      perspectiveOutput("viewer", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  current_row <- reactiveVal(1)
  validation_text <- reactiveVal(NULL)
  saved_states <- reactiveVal(list())
  pending_name <- reactiveVal(NULL)
  state_msg <- reactiveVal("")

  year_data <- reactive({
    yr <- as.integer(input$year)
    stocks[stocks$Year == yr, c("Date", "DAX", "SMI", "CAC", "FTSE")]
  })

  # Render once with first year's data (limit enables rolling window)
  output$viewer <- renderPerspective({
    data <- isolate(year_data())
    perspective(
      data[1, ],
      limit = WINDOW_SIZE,
      plugin = "X/Y Line",
      columns = list("Date", "DAX"),
      settings = TRUE
    )
  })

  proxy <- reactive(perspectiveProxy(session, "viewer"))

  # Year change: reset stream, replace data (preserves user's column selections)
  observeEvent(input$year, {
    current_row(1)
    psp_replace(proxy(), year_data()[1, ], use_arrow = input$use_arrow)
  }, ignoreInit = TRUE)

  observeEvent(input$start_over, {
    current_row(1)
    psp_replace(proxy(), year_data()[1, ], use_arrow = input$use_arrow)
  })

  # Stream one row per second (limit handles the rolling window automatically)
  observe({
    invalidateLater(1000)

    data <- isolate(year_data())
    pos <- isolate(current_row())
    if (pos >= nrow(data)) return()

    new_pos <- pos + 1
    current_row(new_pos)

    psp_update(proxy(), data[new_pos, ], use_arrow = isolate(input$use_arrow))
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

  # Save named state
  observeEvent(input$save_state, {
    name <- trimws(input$state_name)
    req(nzchar(name))
    pending_name(name)
    psp_save(proxy())
    state_msg("Saving...")
  })

  observeEvent(input$viewer_state, {
    name <- pending_name()
    if (is.null(name)) return()
    states <- saved_states()
    states[[name]] <- input$viewer_state
    saved_states(states)
    pending_name(NULL)
    updateSelectInput(session, "saved_states_list", choices = names(states),
      selected = name)
    state_msg(paste0("Saved: ", name))
  })

  # Restore named state
  observeEvent(input$restore_state, {
    name <- input$saved_states_list
    req(name)
    states <- saved_states()
    st <- states[[name]]
    if (is.null(st)) {
      state_msg("State not found")
    } else {
      psp_restore(proxy(), st)
      state_msg(paste0("Restored: ", name))
    }
  })

  output$state_status <- renderText(state_msg())
}

shinyApp(ui, server)
