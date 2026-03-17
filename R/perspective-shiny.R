#' Shiny Output for Perspective Viewer
#'
#' Creates a Perspective viewer output element for use in a Shiny UI.
#'
#' @param outputId Output variable name.
#' @param width CSS width (default \code{"100\%"}).
#' @param height CSS height (default \code{"400px"}).
#'
#' @details
#' The following reactive inputs are available (where \code{outputId} is the
#' ID you supply):
#' \describe{
#'   \item{\code{input$<outputId>_config}}{Viewer configuration changes.}
#'   \item{\code{input$<outputId>_click}}{Cell/data-point click events.}
#'   \item{\code{input$<outputId>_select}}{Row/data-point selection events.}
#'   \item{\code{input$<outputId>_update}}{Table data changes (requires
#'     \code{\link{psp_on_update}}).}
#'   \item{\code{input$<outputId>_export}}{Exported data (after
#'     \code{\link{psp_export}}).}
#'   \item{\code{input$<outputId>_state}}{Saved viewer state (after
#'     \code{\link{psp_save}}).}
#' }
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

#' Remove Rows by Key from a Perspective Viewer
#'
#' Removes rows matching the given primary-key values from an indexed
#' Perspective table. The table must have been created with an \code{index}
#' column (see \code{\link{perspective}}).
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param keys A vector of key values identifying the rows to remove.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_remove <- function(proxy, keys) {
  .validate_proxy(proxy)
  if (missing(keys) || length(keys) == 0L) {
    stop("`keys` must be a non-empty vector.", call. = FALSE)
  }
  .send_proxy_message(proxy, "remove", list(keys = as.list(keys)))
}

#' Export Data from a Perspective Viewer
#'
#' Requests data export from the current Perspective view. The result is
#' delivered asynchronously to \code{input$<outputId>_export}.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param format Export format: \code{"json"} (default), \code{"csv"},
#'   \code{"columns"}, or \code{"arrow"} (base64-encoded Arrow IPC).
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_export <- function(proxy, format = c("json", "csv", "columns", "arrow")) {
  .validate_proxy(proxy)
  format <- match.arg(format)
  .send_proxy_message(proxy, "export", list(format = format))
}

#' Save Viewer State
#'
#' Requests the current viewer configuration (columns, pivots, filters, sort,
#' plugin, etc.). The result is delivered asynchronously to
#' \code{input$<outputId>_state}.
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_save <- function(proxy) {
  .validate_proxy(proxy)
  .send_proxy_message(proxy, "save", list())
}

#' Subscribe to Table Update Events
#'
#' Enables or disables a subscription to table data changes. When enabled,
#' every \code{table.update()} triggers \code{input$<outputId>_update}
#' with a list containing \code{timestamp}, \code{port_id}, and
#' \code{source} (\code{"edit"} for user edits, \code{"api"} for
#' programmatic updates).
#'
#' @param proxy A \code{\link{perspectiveProxy}} object.
#' @param enable Logical; \code{TRUE} to subscribe, \code{FALSE} to
#'   unsubscribe. Default \code{TRUE}.
#'
#' @return The proxy object (invisibly), for chaining.
#'
#' @export
psp_on_update <- function(proxy, enable = TRUE) {
  .validate_proxy(proxy)
  .send_proxy_message(proxy, "on_update", list(enable = enable))
}

#' Send a custom message to a Perspective widget via Shiny session
#' @param proxy The proxy object.
#' @param method The method name.
#' @param payload A list of data to send.
#' @noRd
.send_proxy_message <- function(proxy, method, payload) {
  msg <- c(list(id = proxy$id, method = method), payload)
  proxy$session$sendCustomMessage("perspective-calls", msg)
  invisible(proxy)
}
