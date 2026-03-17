library(shiny)
library(peRspective)

# European stock market closing prices (1991-1998)
stocks <- as.data.frame(EuStockMarkets)
stocks$Date <- seq(as.Date("1991-07-01"), length.out = nrow(stocks), by = "day")
stocks <- stocks[, c("Date", "DAX", "SMI", "CAC", "FTSE")]
stocks$Year <- as.integer(format(stocks$Date, "%Y"))
available_years <- sort(unique(stocks$Year))

WINDOW_SIZE <- 100

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
      helpText(
        "EU stock indices streamed row by row.",
        "Drag columns in the viewer to compare indices."
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

  year_data <- reactive({
    yr <- as.integer(input$year)
    stocks[stocks$Year == yr, c("Date", "DAX", "SMI", "CAC", "FTSE")]
  })

  # Render once with first year's data
  output$viewer <- renderPerspective({
    data <- isolate(year_data())
    perspective(
      data[1, ],
      plugin = "X/Y Line",
      columns = list("Date", "DAX"),
      settings = TRUE
    )
  })

  # Year change: reset stream, replace data (preserves user's column selections)
  observeEvent(input$year, {
    current_row(1)
    proxy <- perspectiveProxy(session, "viewer")
    psp_replace(proxy, year_data()[1, ])
  }, ignoreInit = TRUE)

  observeEvent(input$start_over, {
    current_row(1)
    proxy <- perspectiveProxy(session, "viewer")
    psp_replace(proxy, year_data()[1, ])
  })

  # Stream one row per second, sliding window after WINDOW_SIZE
  observe({
    invalidateLater(1000)

    data <- isolate(year_data())
    pos <- isolate(current_row())
    if (pos >= nrow(data)) return()

    new_pos <- pos + 1
    current_row(new_pos)

    start <- max(1, new_pos - WINDOW_SIZE + 1)
    proxy <- perspectiveProxy(session, "viewer")
    psp_replace(proxy, data[start:new_pos, ])
  })
}

shinyApp(ui, server)
