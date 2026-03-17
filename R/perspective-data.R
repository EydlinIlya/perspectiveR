#' Serialize data frame as column-oriented JSON
#'
#' Coerces all column types into Perspective-compatible JSON. Returns
#' both the JSON string and a schema object mapping column names to
#' Perspective type hints so the JS side can create a typed table.
#'
#' @param data A data.frame.
#' @return A list with `data` (JSON string), `format` ("json"), and
#'   `schema` (named list of Perspective type strings).
#' @noRd
.serialize_json <- function(data) {
  schema <- list()

  for (col in names(data)) {
    vec <- data[[col]]

    if (inherits(vec, "POSIXlt")) {
      # POSIXlt -> POSIXct
      vec <- as.POSIXct(vec)
    }

    if (inherits(vec, "POSIXct")) {
      # Datetimes -> ISO 8601 strings with "T" separator
      schema[[col]] <- "datetime"
      data[[col]] <- format(vec, format = "%Y-%m-%dT%H:%M:%S", usetz = FALSE)
      # Restore NAs (format() turns NA into "NA" string)
      data[[col]][is.na(vec)] <- NA_character_

    } else if (inherits(vec, "Date")) {
      # Dates -> ISO 8601 strings
      schema[[col]] <- "date"
      data[[col]] <- format(vec, format = "%Y-%m-%d")
      data[[col]][is.na(vec)] <- NA_character_

    } else if (inherits(vec, "difftime")) {
      # difftime -> numeric seconds
      schema[[col]] <- "float"
      data[[col]] <- as.numeric(vec, units = "secs")

    } else if (is.factor(vec) || inherits(vec, "ordered")) {
      # Factors (including ordered) -> character
      schema[[col]] <- "string"
      data[[col]] <- as.character(vec)

    } else if (is.logical(vec)) {
      schema[[col]] <- "boolean"
      # logical is fine as-is for jsonlite

    } else if (is.integer(vec)) {
      schema[[col]] <- "integer"
      # integer is fine as-is

    } else if (is.numeric(vec)) {
      schema[[col]] <- "float"
      # Handle NaN, Inf, -Inf: replace with NA so they become JSON null.
      # Perspective has no representation for NaN/Inf in float columns.
      bad <- is.nan(vec) | is.infinite(vec)
      if (any(bad)) {
        data[[col]][bad] <- NA_real_
      }

    } else if (is.character(vec)) {
      schema[[col]] <- "string"
      # character is fine as-is

    } else if (is.list(vec)) {
      # List columns -> convert to string representation
      schema[[col]] <- "string"
      data[[col]] <- vapply(vec, function(x) {
        if (is.null(x) || (length(x) == 1 && is.na(x))) NA_character_
        else jsonlite::toJSON(x, auto_unbox = TRUE)
      }, character(1))

    } else {
      # Fallback: coerce to character
      schema[[col]] <- "string"
      data[[col]] <- as.character(vec)
    }
  }

  json <- jsonlite::toJSON(data, dataframe = "columns", auto_unbox = TRUE,
                           na = "null", digits = NA)
  list(data = as.character(json), format = "json", schema = schema)
}

#' Serialize data frame as Arrow IPC (base64-encoded)
#'
#' Requires the \code{arrow} package to be installed.
#'
#' @param data A data.frame.
#' @return A list with `data` (base64 string) and `format` ("arrow").
#' @noRd
.serialize_arrow <- function(data) {
  if (!requireNamespace("arrow", quietly = TRUE)) {
    stop(
      "The `arrow` package is required for Arrow IPC serialization.\n",
      "Install it with: install.packages('arrow')",
      call. = FALSE
    )
  }

  # Pre-process columns that Arrow might struggle with
  for (col in names(data)) {
    vec <- data[[col]]
    if (inherits(vec, "POSIXlt")) {
      data[[col]] <- as.POSIXct(vec)
    } else if (inherits(vec, "difftime")) {
      data[[col]] <- as.numeric(vec, units = "secs")
    } else if (is.factor(vec)) {
      data[[col]] <- as.character(vec)
    } else if (is.list(vec)) {
      data[[col]] <- vapply(vec, function(x) {
        if (is.null(x) || (length(x) == 1 && is.na(x))) NA_character_
        else as.character(jsonlite::toJSON(x, auto_unbox = TRUE))
      }, character(1))
    }
  }

  # Write to raw bytes using Arrow IPC stream format
  buf <- arrow::BufferOutputStream$create()
  arrow::write_ipc_stream(data, buf)
  raw_bytes <- as.raw(buf$finish())

  # Base64 encode
  b64 <- base64enc_raw(raw_bytes)

  list(data = b64, format = "arrow")
}

#' Base64 encode raw bytes
#'
#' @param raw_vec A raw vector.
#' @return A character string of base64-encoded data.
#' @noRd
base64enc_raw <- function(raw_vec) {
  jsonlite::base64_enc(raw_vec)
}
