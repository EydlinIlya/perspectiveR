#' Shiny Output for Perspective Viewer
#'
#' Creates a Perspective viewer output element for use in a Shiny UI.
#'
#' @param outputId Output variable name.
#' @param width CSS width (default \code{"100\%"}).
#' @param height CSS height (default \code{"400px"}).
#'
#' @return A Shiny output element.
#'
#' @examples
#' \dontrun{
#' library(shiny)
#' ui <- fluidPage(
#'   perspectiveOutput("viewer", height = "600px")
#' )
#' }
#'
#' @importFrom htmlwidgets shinyWidgetOutput
#' @export
perspectiveOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(outputId, "perspective",
                                  width = width, height = height,
                                  package = "peRspective")
}

#' Render a Perspective Viewer in Shiny
#'
#' Server-side rendering function for the Perspective widget.
#'
#' @param expr An expression that returns a \code{\link{perspective}} widget.
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Logical; is \code{expr} a quoted expression?
#'
#' @return A Shiny render function.
#'
#' @examples
#' \dontrun{
#' server <- function(input, output) {
#'   output$viewer <- renderPerspective({
#'     perspective(mtcars, group_by = "cyl", plugin = "Y Bar")
#'   })
#' }
#' }
#'
#' @importFrom htmlwidgets shinyRenderWidget
#' @export
renderPerspective <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, perspectiveOutput, env, quoted = TRUE)
}

#' Create a Perspective Proxy Object for Shiny
#'
#' Creates a proxy object that can be used to update an existing Perspective
#' viewer in a Shiny app without re-rendering the entire widget. Use this with
#' \code{psp_update}, \code{psp_replace}, \code{psp_clear}, \code{psp_restore},
#' and \code{psp_reset} to modify the viewer.
#'
#' @param session The Shiny session object (usually \code{session}).
#' @param outputId The output ID of the Perspective widget to control.
#'
#' @return A proxy object of class \code{"perspective_proxy"}.
#'
#' @examples
#' \dontrun{
#' server <- function(input, output, session) {
#'   output$viewer <- renderPerspective({
#'     perspective(mtcars)
#'   })
#'
#'   observeEvent(input$add_data, {
#'     proxy <- perspectiveProxy(session, "viewer")
#'     psp_update(proxy, new_data)
#'   })
#' }
#' }
#'
#' @export
perspectiveProxy <- function(session, outputId) {
  structure(
    list(session = session, id = outputId),
    class = "perspective_proxy"
  )
}

#' Update (Append) Data in a Perspective Viewer
#'
#' Sends new rows to be appended to the existing Perspective table.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param data A data.frame of new rows to append.
#' @param use_arrow Logical; use Arrow IPC serialization. Default \code{FALSE}.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_update <- function(proxy, data, use_arrow = FALSE) {
  .validate_proxy(proxy)
  serialized <- if (use_arrow) .serialize_arrow(data) else .serialize_json(data)
  .send_proxy_message(proxy, "update", serialized)
}

#' Replace All Data in a Perspective Viewer
#'
#' Replaces the entire dataset in the Perspective table.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param data A data.frame containing the replacement data.
#' @param use_arrow Logical; use Arrow IPC serialization. Default \code{FALSE}.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_replace <- function(proxy, data, use_arrow = FALSE) {
  .validate_proxy(proxy)
  serialized <- if (use_arrow) .serialize_arrow(data) else .serialize_json(data)
  .send_proxy_message(proxy, "replace", serialized)
}

#' Clear All Data from a Perspective Viewer
#'
#' Removes all rows from the Perspective table (schema is preserved).
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_clear <- function(proxy) {
  .validate_proxy(proxy)
  .send_proxy_message(proxy, "clear", list())
}

#' Restore Viewer Configuration
#'
#' Applies a configuration object to the Perspective viewer, changing columns,
#' group_by, split_by, filters, sort, aggregates, plugin, etc.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param config A list of Perspective viewer configuration options.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_restore <- function(proxy, config) {
  .validate_proxy(proxy)
  .send_proxy_message(proxy, "restore", list(config = config))
}

#' Reset Viewer to Default State
#'
#' Resets the Perspective viewer to its default configuration.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_reset <- function(proxy) {
  .validate_proxy(proxy)
  .send_proxy_message(proxy, "reset", list())
}

#' Validate a perspective proxy object
#' @param proxy The object to validate.
#' @noRd
.validate_proxy <- function(proxy) {
  if (!inherits(proxy, "perspective_proxy")) {
    stop("`proxy` must be a perspectiveProxy object.", call. = FALSE)
  }
}

#' Send a custom message to a Perspective widget via Shiny session
#' @param proxy The proxy object.
#' @param method The method name (update, replace, clear, restore, reset).
#' @param payload A list of data to send.
#' @noRd
.send_proxy_message <- function(proxy, method, payload) {
  msg <- c(list(id = proxy$id, method = method), payload)
  proxy$session$sendCustomMessage("perspective-calls", msg)
  invisible(proxy)
}
