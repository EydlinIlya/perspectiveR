library(shiny)
library(perspectiveR)

base_grid <- expand.grid(
  u = seq(0, 2 * pi, length.out = 80),
  v = seq(0, 2 * pi, length.out = 80)
)

ui <- fluidPage(
  titlePanel("Spinning Donut"),
  sidebarLayout(
    sidebarPanel(width = 3,
      sliderInput("speed", "Speed:", min = 0, max = 0.2, value = 0.05, step = 0.01),
      actionButton("pause", "Pause"),
      actionButton("reset", "Reset"),
      hr(),
      helpText("3D torus \u2014 all geometry computed in Perspective's expression engine.",
               "R streams only rotation angles; sin/cos/lighting run in WebAssembly.")
    ),
    mainPanel(width = 9,
      perspectiveOutput("donut", height = "700px")
    )
  )
)

server <- function(input, output, session) {
  angle <- reactiveVal(0)
  paused <- reactiveVal(FALSE)

  output$donut <- renderPerspective({
    perspective(base_grid,
      expressions = c(
        '"x" = (2 + cos("v")) * cos("u")',
        '"y" = (2 + cos("v")) * sin("u")',
        '"shade" = cos("v") * sin("u") + sin("v")'
      ),
      columns  = c("x", "y", "shade"),
      plugin   = "XY Scatter",
      theme    = "Pro Dark",
      settings = FALSE,
      title    = "Spinning Donut"
    )
  })

  proxy <- reactive(perspectiveProxy(session, "donut"))

  # Animation loop: shift u by rotation angle each frame
  observe({
    invalidateLater(50)
    if (isolate(paused())) return()
    a <- isolate(angle()) + isolate(input$speed)
    angle(a)
    psp_replace(proxy(), data.frame(u = base_grid$u + a, v = base_grid$v))
  })

  observeEvent(input$pause, {
    paused(!paused())
    updateActionButton(session, "pause", label = if (paused()) "Resume" else "Pause")
  })

  observeEvent(input$reset, {
    angle(0)
    psp_replace(proxy(), base_grid)
  })
}

shinyApp(ui, server)
