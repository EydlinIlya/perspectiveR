#' Create a Perspective Interactive Viewer
#'
#' Creates an interactive pivot table and visualization widget powered by the
#' FINOS Perspective library. The viewer provides a self-service UI where users
#' can interactively change chart types, group/split/filter/sort data, create
#' computed columns, and configure aggregations.
#'
#' @param data A data.frame or matrix to display.
#' @param columns Character vector of column names to show. If \code{NULL},
#'   all columns are shown.
#' @param group_by Character vector of column names to group rows by (row pivots).
#' @param split_by Character vector of column names to split columns by (column pivots).
#' @param sort A list of two-element vectors, each containing a column name and
#'   a direction (\code{"asc"}, \code{"desc"}, \code{"col asc"}, \code{"col desc"},
#'   \code{"asc abs"}, \code{"desc abs"}, \code{"col asc abs"}, \code{"col desc abs"}).
#'   For example: \code{list(c("mpg", "desc"))}.
#' @param filter A list of three-element vectors, each containing a column name,
#'   an operator (\code{"=="}, \code{"!="}, \code{">"}, \code{"<"}, \code{">="}, \code{"<="},
#'   \code{"begins with"}, \code{"contains"}, \code{"ends with"}, \code{"in"}, \code{"not in"},
#'   \code{"is null"}, \code{"is not null"}), and a value.
#'   For example: \code{list(c("cyl", "==", "6"))}.
#' @param expressions Character vector of Perspective expression strings for
#'   computed columns. For example: \code{c('"Profit" / "Sales"')}.
#' @param aggregates A named list mapping column names to aggregate functions.
#'   For example: \code{list(mpg = "avg", hp = "sum")}.
#' @param plugin Character string specifying the visualization plugin.
#'   Options include: \code{"Datagrid"}, \code{"Y Bar"}, \code{"X Bar"},
#'   \code{"Y Line"}, \code{"Y Area"}, \code{"Y Scatter"}, \code{"XY Scatter"},
#'   \code{"Treemap"}, \code{"Sunburst"}, \code{"Heatmap"}.
#' @param plugin_config A list of plugin-specific configuration options.
#' @param theme Character string specifying the CSS theme. Options:
#'   \code{"Pro Light"}, \code{"Pro Dark"}, \code{"Monokai"},
#'   \code{"Solarized Light"}, \code{"Solarized Dark"},
#'   \code{"Vaporwave"}. Default is \code{"Pro Light"}.
#' @param settings Logical; whether to show the settings/configuration panel
#'   sidebar. Default \code{TRUE}. This is the interactive UI where users
#'   drag-and-drop columns, change chart types, add filters, etc.
#' @param title Character string for the viewer title. If \code{NULL}, no title
#'   is shown.
#' @param editable Logical; whether the data in the grid is user-editable.
#'   Default \code{FALSE}.
#' @param use_arrow Logical; if \code{TRUE}, serialize data using Arrow IPC
#'   format (base64-encoded) for better performance with large datasets.
#'   Requires the \code{arrow} package. Default \code{FALSE}.
#' @param width Widget width (CSS string or numeric pixels).
#' @param height Widget height (CSS string or numeric pixels).
#' @param elementId Optional explicit element ID for the widget.
#'
#' @return An htmlwidgets object that can be printed, included in R Markdown,
#'   Quarto documents, or Shiny apps.
#'
#' @examples
#' # Basic data grid
#' perspective(mtcars)
#'
#' # Bar chart grouped by cylinder count
#' perspective(mtcars, group_by = "cyl", plugin = "Y Bar")
#'
#' # Filtered and sorted view
#' perspective(iris,
#'   columns = c("Sepal.Length", "Sepal.Width", "Species"),
#'   filter = list(c("Species", "==", "setosa")),
#'   sort = list(c("Sepal.Length", "desc"))
#' )
#'
#' @importFrom htmlwidgets createWidget
#' @importFrom jsonlite toJSON
#' @export
perspective <- function(data,
                        columns = NULL,
                        group_by = NULL,
                        split_by = NULL,
                        sort = NULL,
                        filter = NULL,
                        expressions = NULL,
                        aggregates = NULL,
                        plugin = NULL,
                        plugin_config = NULL,
                        theme = "Pro Light",
                        settings = TRUE,
                        title = NULL,
                        editable = FALSE,
                        use_arrow = FALSE,
                        width = NULL,
                        height = NULL,
                        elementId = NULL) {

  # Validate data
  if (!is.data.frame(data) && !is.matrix(data)) {
    stop("`data` must be a data.frame or matrix.", call. = FALSE)
  }
  if (is.matrix(data)) {
    data <- as.data.frame(data)
  }

  # Serialize data
  if (use_arrow) {
    serialized <- .serialize_arrow(data)
  } else {
    serialized <- .serialize_json(data)
  }

  # Build viewer config (only include non-NULL values)
  config <- list()
  if (!is.null(columns)) config$columns <- as.list(columns)
  if (!is.null(group_by)) config$group_by <- as.list(group_by)
  if (!is.null(split_by)) config$split_by <- as.list(split_by)
  if (!is.null(sort)) config$sort <- sort
  if (!is.null(filter)) config$filter <- filter
  if (!is.null(expressions)) config$expressions <- .build_expressions(expressions)
  if (!is.null(aggregates)) config$aggregates <- aggregates
  if (!is.null(plugin)) config$plugin <- plugin
  if (!is.null(plugin_config)) config$plugin_config <- plugin_config
  if (!is.null(title)) config$title <- title
  config$settings <- settings
  config$editable <- editable

  # Widget payload
  x <- list(
    data = serialized$data,
    data_format = serialized$format,
    schema = serialized$schema,
    config = config,
    theme = theme
  )

  # Create widget
  htmlwidgets::createWidget(
    name = "perspective",
    x = x,
    width = width,
    height = height,
    package = "peRspective",
    elementId = elementId,
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = "100%",
      defaultHeight = "400px",
      viewer.defaultHeight = "100%",
      viewer.defaultWidth = "100%",
      knitr.defaultWidth = "100%",
      knitr.defaultHeight = "500px",
      knitr.figure = FALSE,
      browser.fill = TRUE,
      viewer.fill = TRUE
    )
  )
}

#' Build expressions object for Perspective
#'
#' Perspective expects expressions as an object mapping expression names
#' to expression strings.
#' @param exprs Character vector of expression strings.
#' @return A named list suitable for Perspective's expressions config.
#' @noRd
.build_expressions <- function(exprs) {
  # Perspective v2+ uses a named object: { "expr_name": "expr_string" }
  # Use the expression string as both key and value
  result <- as.list(exprs)
  names(result) <- exprs
  result
}
