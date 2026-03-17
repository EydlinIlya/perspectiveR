library(shiny)
library(peRspective)

# Prepare mtcars with car names as a column (primary key)
cars_data <- mtcars
cars_data$car <- rownames(mtcars)
rownames(cars_data) <- NULL
cars_data <- cars_data[, c("car", "mpg", "cyl", "hp", "wt",
                           "disp", "drat", "qsec", "vs", "am", "gear", "carb")]

ui <- fluidPage(
  titlePanel("CRUD Table Demo"),
  sidebarLayout(
    sidebarPanel(
      width = 3,

      h4("Add / Update Car"),
      textInput("car_name", "Car Name:", placeholder = "e.g. Toyota Corolla"),
      numericInput("car_mpg", "MPG:", value = 25, min = 0, step = 0.1),
      numericInput("car_cyl", "Cylinders:", value = 4, min = 2, max = 16, step = 2),
      numericInput("car_hp", "Horsepower:", value = 100, min = 0, step = 1),
      numericInput("car_wt", "Weight (1000 lbs):", value = 3.0, min = 0, step = 0.1),
      actionButton("add_car", "Add / Update", class = "btn-primary"),

      hr(),
      h4("Delete Selected"),
      verbatimTextOutput("clicked_car_display"),
      actionButton("delete_car", "Delete Selected", class = "btn-danger"),

      hr(),
      h4("Export Data"),
      radioButtons("export_format", "Format:", choices = c("json", "csv"), inline = TRUE),
      actionButton("export_btn", "Export", class = "btn-info"),
      verbatimTextOutput("export_preview"),

      hr(),
      h4("Activity Log"),
      checkboxInput("subscribe_updates", "Subscribe to updates", value = TRUE),
      verbatimTextOutput("activity_log")
    ),
    mainPanel(
      width = 9,
      perspectiveOutput("viewer", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  clicked_car <- reactiveVal(NULL)
  log_entries <- reactiveVal(character(0))
  export_data <- reactiveVal(NULL)

  # Render the table with index = "car" for keyed upserts

  output$viewer <- renderPerspective({
    perspective(
      cars_data,
      index = "car",
      editable = TRUE,
      sort = list(c("car", "asc"))
    )
  })

  proxy <- reactive(perspectiveProxy(session, "viewer"))

  # Toggle update subscription
  observe({
    psp_on_update(proxy(), input$subscribe_updates)
  })

  # Click event: extract car name

  observeEvent(input$viewer_click, {
    click <- input$viewer_click
    if (!is.null(click) && !is.null(click$row)) {
      car_name <- click$row[["car"]]
      if (!is.null(car_name)) {
        clicked_car(car_name)
      }
    }
  })

  output$clicked_car_display <- renderText({
    car <- clicked_car()
    if (is.null(car)) "Click a row to select" else car
  })

  # Add / Update a car (upsert via index)
  observeEvent(input$add_car, {
    req(nzchar(input$car_name))
    new_row <- data.frame(
      car = input$car_name,
      mpg = input$car_mpg,
      cyl = input$car_cyl,
      hp = input$car_hp,
      wt = input$car_wt,
      stringsAsFactors = FALSE
    )
    psp_update(proxy(), new_row)
  })

  # Delete selected car by key
  observeEvent(input$delete_car, {
    car <- clicked_car()
    req(car)
    psp_remove(proxy(), keys = car)
    clicked_car(NULL)
  })

  # Export
  observeEvent(input$export_btn, {
    psp_export(proxy(), format = input$export_format)
  })

  observeEvent(input$viewer_export, {
    result <- input$viewer_export
    if (is.null(result)) return()
    preview <- if (is.character(result)) {
      substr(result, 1, 2000)
    } else {
      paste(utils::capture.output(utils::str(result, max.level = 2)), collapse = "\n")
    }
    export_data(preview)
  })

  output$export_preview <- renderText({
    export_data()
  })

  # Activity log from update events
  observeEvent(input$viewer_update, {
    evt <- input$viewer_update
    ts <- if (!is.null(evt$timestamp)) {
      format(as.POSIXct(evt$timestamp / 1000, origin = "1970-01-01"), "%H:%M:%S")
    } else {
      format(Sys.time(), "%H:%M:%S")
    }
    source <- if (!is.null(evt$source)) evt$source else "unknown"
    entry <- sprintf("[%s] Update from: %s", ts, source)
    current <- log_entries()
    log_entries(c(entry, utils::head(current, 19)))
  })

  output$activity_log <- renderText({
    entries <- log_entries()
    if (length(entries) == 0) "No activity yet" else paste(entries, collapse = "\n")
  })
}

shinyApp(ui, server)
