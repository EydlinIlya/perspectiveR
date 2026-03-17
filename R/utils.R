#' @keywords internal
"_PACKAGE"

#' @importFrom htmltools tags
NULL

#' Run a peRspective Example App
#'
#' Launches a bundled Shiny example app demonstrating the peRspective widget.
#'
#' @param example Name of the example to run. Use \code{NULL} (default) to list
#'   available examples.
#' @param ... Additional arguments passed to \code{\link[shiny]{runApp}}.
#'
#' @examples
#' # List available examples
#' run_example()
#'
#' # Launch the demo app
#' \dontrun{
#' run_example("shiny-basic")
#' }
#'
#' @export
run_example <- function(example = NULL, ...) {
  examples_dir <- system.file("examples", package = "peRspective")
  all_dirs <- list.dirs(examples_dir, full.names = FALSE, recursive = FALSE)
  available <- all_dirs[file.exists(file.path(examples_dir, all_dirs, "app.R"))]

  if (is.null(example)) {
    message("Available peRspective examples:\n",
            paste(" ", available, collapse = "\n"),
            "\n\nRun one with: run_example(\"", available[1], "\")")
    return(invisible(available))
  }

  app_dir <- system.file("examples", example, package = "peRspective")
  if (app_dir == "") {
    stop("Example '", example, "' not found. Available: ",
         paste(available, collapse = ", "), call. = FALSE)
  }

  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("The `shiny` package is required to run examples.\n",
         "Install it with: install.packages('shiny')", call. = FALSE)
  }

  shiny::runApp(app_dir, ...)
}
