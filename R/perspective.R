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
#' @param filter_op Character string controlling how multiple filters are
#'   combined: \code{"and"} (default) or \code{"or"}. If \code{NULL}, the
#'   Perspective default (\code{"and"}) is used.
#' @param expressions Character vector of Perspective expression strings for
#'   computed columns. For example: \code{c('"Profit" / "Sales"')}.
#' @param aggregates A named list mapping column names to aggregate functions.
#'   For example: \code{list(mpg = "avg", hp = "sum")}.
#' @param plugin Character string specifying the visualization plugin.
#'   Options include: \code{"Datagrid"}, \code{"Y Bar"}, \code{"X Bar"},
#'   \code{"Y Line"}, \code{"X/Y Line"}, \code{"Y Area"}, \code{"Y Scatter"},
#'   \code{"XY Scatter"}, \code{"Treemap"}, \code{"Sunburst"}, \code{"Heatmap"}.
#' @param plugin_config A list of plugin-specific configuration options.
#' @param theme Character string specifying the CSS theme. Options:
#'   \code{"Pro Light"}, \code{"Pro Dark"}, \code{"Monokai"},
#'   \code{"Solarized Light"}, \code{"Solarized Dark"},
#'   \code{"Vaporwave"}, \code{"Dracula"}, \code{"Gruvbox"},
#'   \code{"Gruvbox Dark"}. Default is \code{"Pro Light"}.
#' @param settings Logical; whether to show the settings/configuration panel
#'   sidebar. Default \code{TRUE}. This is the interactive UI where users
#'   drag-and-drop columns, change chart types, add filters, etc.
#' @param title Character string for the viewer title. If \code{NULL}, no title
#'   is shown.
#' @param editable Logical; whether the data in the grid is user-editable.
#'   Default \code{FALSE}.
#' @param index Character string naming a column to use as the table's primary
#'   key. When set, \code{psp_update()} performs upserts (matching rows are
#'   updated instead of appended) and \code{psp_remove()} can delete rows by
#'   key. Must be the name of a column present in \code{data}. Default
#'   \code{NULL} (no index).
#' @param limit Single positive integer specifying the maximum number of rows
#'   the table will hold. When new rows are added beyond this limit, the oldest
#'   rows are removed (rolling window). Mutually exclusive with \code{index}.
#'   Default \code{NULL} (no limit).
#' @param use_arrow Logical; if \code{TRUE}, serialize data using Arrow IPC
#'   format (base64-encoded) for better performance with large datasets.
#'   Requires the \code{arrow} package. Default \code{FALSE}.
#' @param width Widget width (CSS string or numeric pixels).
#' @param height Widget height (CSS string or numeric pixels).
#' @param elementId Optional explicit element ID for the widget.
#'
#' @details
#' When used in a Shiny app, the following reactive inputs are available
#' (where \code{outputId} is the ID passed to \code{\link{perspectiveOutput}}):
#' \describe{
#'   \item{\code{input$<outputId>_config}}{Fires when the user changes the
#'     viewer configuration (columns, pivots, filters, etc.).}
#'   \item{\code{input$<outputId>_click}}{Fires when the user clicks a cell
#'     or data point.}
#'   \item{\code{input$<outputId>_select}}{Fires when the user selects rows
#'     or data points.}
#'   \item{\code{input$<outputId>_update}}{Fires on each table data change
#'     when subscribed via \code{\link{psp_on_update}}.}
#'   \item{\code{input$<outputId>_export}}{Contains exported data after
#'     calling \code{\link{psp_export}}.}
#'   \item{\code{input$<outputId>_state}}{Contains saved viewer state after
#'     calling \code{\link{psp_save}}.}
#'   \item{\code{input$<outputId>_schema}}{Contains the table schema after
#'     calling \code{\link{psp_schema}}.}
#'   \item{\code{input$<outputId>_size}}{Contains the table row count after
#'     calling \code{\link{psp_size}}.}
#'   \item{\code{input$<outputId>_columns}}{Contains the table column names
#'     after calling \code{\link{psp_columns}}.}
#'   \item{\code{input$<outputId>_validate_expressions}}{Contains expression
#'     validation results after calling \code{\link{psp_validate_expressions}}.}
#' }
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
                        filter_op = NULL,
                        expressions = NULL,
                        aggregates = NULL,
                        plugin = NULL,
                        plugin_config = NULL,
                        theme = "Pro Light",
                        settings = TRUE,
                        title = NULL,
                        editable = FALSE,
                        index = NULL,
                        limit = NULL,
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

  # Validate filter_op
  if (!is.null(filter_op)) {
    if (!is.character(filter_op) || length(filter_op) != 1L ||
        !filter_op %in% c("and", "or")) {
      stop('`filter_op` must be "and" or "or".', call. = FALSE)
    }
  }

  # Validate index
  if (!is.null(index)) {
    if (!is.character(index) || length(index) != 1L) {
      stop("`index` must be a single character string.", call. = FALSE)
    }
    if (!index %in% names(data)) {
      stop(sprintf("`index` column '%s' not found in `data`.", index), call. = FALSE)
    }
  }

  # Validate limit
  if (!is.null(limit)) {
    if (length(limit) != 1L || is.na(limit) || !is.numeric(limit) ||
        limit != as.integer(limit) || limit <= 0L) {
      stop("`limit` must be a single positive integer.", call. = FALSE)
    }
    limit <- as.integer(limit)
  }

  # index and limit are mutually exclusive
  if (!is.null(index) && !is.null(limit)) {
    stop("`index` and `limit` cannot both be set.", call. = FALSE)
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
  if (!is.null(filter_op)) config$filter_op <- filter_op
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
  if (!is.null(index)) x$index <- index
  if (!is.null(limit)) x$limit <- limit

  # Create widget
  htmlwidgets::createWidget(
    name = "perspective",
    x = x,
    width = width,
    height = height,
    package = "perspectiveR",
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
