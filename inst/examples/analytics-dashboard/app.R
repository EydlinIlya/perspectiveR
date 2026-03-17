library(shiny)
library(peRspective)

chart_types <- c("Datagrid", "Y Bar", "X Bar", "Y Line", "Y Area",
                 "Y Scatter", "Heatmap", "Treemap", "Sunburst")

themes <- c("Pro Light", "Pro Dark", "Monokai", "Solarized Light",
            "Solarized Dark", "Vaporwave", "Dracula", "Gruvbox", "Gruvbox Dark")

presets <- c(
  "Avg Weight by Diet (Bar)" = "diet_bar",
  "Weight Over Time by Diet (Line)" = "time_line",
  "Diet x Time Heatmap" = "heatmap",
  "Diet Sunburst" = "sunburst"
)

preset_configs <- list(
  diet_bar = list(
    plugin = "Y Bar",
    group_by = list("Diet"),
    columns = list("weight"),
    aggregates = list(weight = "avg")
  ),
  time_line = list(
    plugin = "Y Line",
    group_by = list("Time"),
    split_by = list("Diet"),
    columns = list("weight"),
    aggregates = list(weight = "avg")
  ),
  heatmap = list(
    plugin = "Heatmap",
    group_by = list("Diet"),
    split_by = list("Time"),
    columns = list("weight"),
    aggregates = list(weight = "avg")
  ),
  sunburst = list(
    plugin = "Sunburst",
    group_by = list("Diet", "Chick"),
    columns = list("weight"),
    aggregates = list(weight = "sum")
  )
)

ui <- fluidPage(
  titlePanel("Analytics Dashboard Demo"),
  sidebarLayout(
    sidebarPanel(
      width = 3,

      h4("Chart Config"),
      selectInput("chart_type", "Chart Type:", choices = chart_types, selected = "Y Bar"),
      selectInput("theme", "Theme:", choices = themes, selected = "Pro Light"),

      hr(),
      h4("Pivot Config"),
      checkboxGroupInput("group_by", "Group By:",
        choices = c("Diet", "Chick", "Time"), selected = "Diet"
      ),
      checkboxGroupInput("split_by", "Split By:",
        choices = c("Diet", "Chick", "Time")
      ),
      selectInput("agg_func", "Weight Aggregation:",
        choices = c("sum", "avg", "count", "max", "min"), selected = "avg"
      ),
      actionButton("apply_config", "Apply", class = "btn-primary"),

      hr(),
      h4("Presets"),
      selectInput("preset", "Load a Preset:", choices = presets),
      actionButton("load_preset", "Load Preset", class = "btn-info"),

      hr(),
      h4("State Management"),
      actionButton("save_state", "Save State"),
      actionButton("restore_state", "Restore State"),
      textOutput("state_status"),

      hr(),
      h4("Selection Details"),
      verbatimTextOutput("selection_info")
    ),
    mainPanel(
      width = 9,
      perspectiveOutput("viewer", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  saved_state <- reactiveVal(NULL)
  state_msg <- reactiveVal("")
  current_theme <- reactiveVal("Pro Light")

  # Initial render: bar chart grouped by Diet
  output$viewer <- renderPerspective({
    theme <- current_theme()
    perspective(
      ChickWeight,
      plugin = "Y Bar",
      group_by = "Diet",
      columns = c("weight"),
      aggregates = list(weight = "avg"),
      theme = theme
    )
  })

  proxy <- reactive(perspectiveProxy(session, "viewer"))

  # Apply pivot/chart config via proxy
  observeEvent(input$apply_config, {
    config <- list(plugin = input$chart_type)
    if (length(input$group_by) > 0) config$group_by <- as.list(input$group_by)
    if (length(input$split_by) > 0) config$split_by <- as.list(input$split_by)
    config$columns <- list("weight")
    config$aggregates <- list(weight = input$agg_func)
    psp_restore(proxy(), config)
  })

  # Theme switch: re-render widget
  observeEvent(input$theme, {
    current_theme(input$theme)
  }, ignoreInit = TRUE)

  # Load preset
  observeEvent(input$load_preset, {
    config <- preset_configs[[input$preset]]
    if (!is.null(config)) {
      psp_restore(proxy(), config)
    }
  })

  # Save state
  observeEvent(input$save_state, {
    psp_save(proxy())
    state_msg("Saving...")
  })

  observeEvent(input$viewer_state, {
    saved_state(input$viewer_state)
    state_msg("State saved!")
  })

  # Restore state
  observeEvent(input$restore_state, {
    st <- saved_state()
    if (is.null(st)) {
      state_msg("No saved state to restore")
    } else {
      psp_restore(proxy(), st)
      state_msg("State restored!")
    }
  })

  output$state_status <- renderText(state_msg())

  # Selection details
  output$selection_info <- renderText({
    sel <- input$viewer_select
    if (is.null(sel)) {
      "Select data points to see details"
    } else {
      paste(utils::capture.output(utils::str(sel, max.level = 3)), collapse = "\n")
    }
  })
}

shinyApp(ui, server)
