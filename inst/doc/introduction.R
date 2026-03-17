## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(peRspective)

## ----basic, eval=FALSE--------------------------------------------------------
# perspective(mtcars)

## ----config, eval=FALSE-------------------------------------------------------
# perspective(mtcars,
#   group_by = "cyl",
#   columns = c("mpg", "hp", "wt"),
#   plugin = "Y Bar",
#   theme = "Pro Dark"
# )

## ----filter-sort, eval=FALSE--------------------------------------------------
# perspective(iris,
#   filter = list(c("Species", "==", "setosa")),
#   sort = list(c("Sepal.Length", "desc"))
# )

## ----expressions, eval=FALSE--------------------------------------------------
# perspective(mtcars,
#   expressions = c('"hp" / "wt"'),
#   columns = c("mpg", "hp", "wt", '"hp" / "wt"')
# )

## ----arrow, eval=FALSE--------------------------------------------------------
# # Requires the arrow package
# big_data <- data.frame(
#   x = rnorm(100000),
#   y = rnorm(100000),
#   group = sample(letters, 100000, replace = TRUE)
# )
# perspective(big_data, use_arrow = TRUE)

## ----shiny, eval=FALSE--------------------------------------------------------
# library(shiny)
# 
# ui <- fluidPage(
#   perspectiveOutput("viewer", height = "600px"),
#   actionButton("add", "Add Data")
# )
# 
# server <- function(input, output, session) {
#   output$viewer <- renderPerspective({
#     perspective(mtcars, plugin = "Y Bar", group_by = "cyl")
#   })
# 
#   observeEvent(input$add, {
#     proxy <- perspectiveProxy(session, "viewer")
#     new_data <- mtcars[sample(nrow(mtcars), 5), ]
#     psp_update(proxy, new_data)
#   })
# 
#   # Capture user's interactive config changes
#   observeEvent(input$viewer_config, {
#     message("User changed config: ", str(input$viewer_config))
#   })
# }
# 
# shinyApp(ui, server)

## ----filter-op, eval=FALSE----------------------------------------------------
# # Match rows where Species is "setosa" OR Sepal.Length > 6
# perspective(iris,
#   filter = list(
#     c("Species", "==", "setosa"),
#     c("Sepal.Length", ">", "6")
#   ),
#   filter_op = "or"
# )

## ----limit, eval=FALSE--------------------------------------------------------
# # Keep only the last 100 rows
# perspective(streaming_data, limit = 100)

## ----indexed, eval=FALSE------------------------------------------------------
# # Create an indexed table keyed on "cyl"
# perspective(mtcars, index = "cyl", plugin = "Datagrid")
# 
# # In a Shiny server:
# proxy <- perspectiveProxy(session, "viewer")
# psp_update(proxy, updated_rows)   # upserts by "cyl"
# psp_remove(proxy, keys = c(4, 8)) # remove rows where cyl == 4 or 8

## ----export, eval=FALSE-------------------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# psp_export(proxy, format = "csv")
# 
# # Result arrives asynchronously:
# observeEvent(input$viewer_export, {
#   cat("Format:", input$viewer_export$format, "\n")
#   cat("Data:", input$viewer_export$data, "\n")
# })

## ----save-restore, eval=FALSE-------------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# 
# # Save current state
# psp_save(proxy)
# observeEvent(input$viewer_state, {
#   saved <- input$viewer_state
#   # Later, restore it:
#   psp_restore(proxy, saved)
# })

## ----on-update, eval=FALSE----------------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# psp_on_update(proxy, enable = TRUE)
# 
# observeEvent(input$viewer_update, {
#   info <- input$viewer_update
#   message("Update at ", info$timestamp, " from ", info$source)
# })
# 
# # To unsubscribe:
# psp_on_update(proxy, enable = FALSE)

## ----metadata, eval=FALSE-----------------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# 
# # Get column types
# psp_schema(proxy)
# observeEvent(input$viewer_schema, {
#   str(input$viewer_schema)  # list(col1 = "float", col2 = "string", ...)
# })
# 
# # Get row count
# psp_size(proxy)
# observeEvent(input$viewer_size, {
#   message("Table has ", input$viewer_size, " rows")
# })
# 
# # Get column names
# psp_columns(proxy)
# observeEvent(input$viewer_columns, {
#   message("Columns: ", paste(input$viewer_columns, collapse = ", "))
# })

## ----windowed-export, eval=FALSE----------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# 
# # Export only the first 50 rows
# psp_export(proxy, format = "json", start_row = 0, end_row = 50)
# 
# # Export rows 100-200, columns 0-3
# psp_export(proxy, format = "csv",
#   start_row = 100, end_row = 200,
#   start_col = 0, end_col = 3
# )

## ----validate-expr, eval=FALSE------------------------------------------------
# proxy <- perspectiveProxy(session, "viewer")
# psp_validate_expressions(proxy, c('"hp" / "wt"', '"invalid_col" + 1'))
# 
# observeEvent(input$viewer_validate_expressions, {
#   result <- input$viewer_validate_expressions
#   # Contains validation info for each expression
#   str(result)
# })

## ----themes, eval=FALSE-------------------------------------------------------
# perspective(mtcars, theme = "Pro Dark")
# perspective(mtcars, theme = "Dracula")
# perspective(mtcars, theme = "Gruvbox Dark")

