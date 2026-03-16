# ---- Numeric types ----

test_that("integer columns serialize correctly", {
  df <- data.frame(x = c(1L, 2L, NA_integer_, .Machine$integer.max))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "integer")
  expect_true(grepl("2147483647", res$data))
  expect_true(grepl("null", res$data))
})

test_that("NaN becomes null in JSON", {
  df <- data.frame(x = c(1.5, NaN, 3.0))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "float")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], 1.5)
  expect_true(is.na(parsed$x[2]))
  expect_equal(parsed$x[3], 3.0)
})

test_that("Inf and -Inf become null in JSON", {
  df <- data.frame(x = c(Inf, -Inf, 42))
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_true(is.na(parsed$x[1]))
  expect_true(is.na(parsed$x[2]))
  expect_equal(parsed$x[3], 42)
})

test_that("NA_real_ becomes null in JSON", {
  df <- data.frame(x = c(1.0, NA_real_, 3.0))
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_true(is.na(parsed$x[2]))
})

test_that("all-NaN column serializes without error", {
  df <- data.frame(x = c(NaN, NaN, NaN))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$data, '{"x":[null,null,null]}')
})

test_that("all-Inf column serializes without error", {
  df <- data.frame(x = c(Inf, -Inf, Inf))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$data, '{"x":[null,null,null]}')
})

test_that("extreme doubles are preserved", {
  df <- data.frame(x = c(1e308, -1e308, 1e-308))
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], 1e308)
  expect_equal(parsed$x[2], -1e308)
})

# ---- Character types ----

test_that("NA_character_ becomes null", {
  df <- data.frame(x = c("a", NA_character_, "b"), stringsAsFactors = FALSE)
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "string")
  expect_true(grepl("null", res$data))
})

test_that("empty strings are preserved (not turned into null)", {
  df <- data.frame(x = c("a", "", "b"), stringsAsFactors = FALSE)
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[2], "")
})

test_that("unicode characters are preserved", {
  df <- data.frame(x = c("caf\u00e9", "\u4e16\u754c"), stringsAsFactors = FALSE)
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], "caf\u00e9")
  expect_equal(parsed$x[2], "\u4e16\u754c")
})

test_that("special characters in strings are properly escaped", {
  df <- data.frame(x = c("line\nbreak", "tab\there", 'quote"inside'),
                   stringsAsFactors = FALSE)
  res <- peRspective:::.serialize_json(df)
  # Should be valid JSON
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], "line\nbreak")
  expect_equal(parsed$x[3], 'quote"inside')
})

# ---- Logical ----

test_that("logical with NA serializes correctly", {
  df <- data.frame(x = c(TRUE, FALSE, NA))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "boolean")
  expect_true(grepl("true", res$data))
  expect_true(grepl("false", res$data))
  expect_true(grepl("null", res$data))
})

# ---- Factors ----

test_that("factors are converted to strings", {
  df <- data.frame(x = factor(c("a", "b", NA, "a")))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "string")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], "a")
  expect_true(is.na(parsed$x[3]))
})

test_that("ordered factors are converted to strings", {
  df <- data.frame(x = ordered(c("low", "med", "high"), levels = c("low", "med", "high")))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "string")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x, c("low", "med", "high"))
})

# ---- Dates ----

test_that("Date columns get 'date' schema type and ISO 8601 format", {
  df <- data.frame(x = as.Date(c("2024-01-15", NA, "2024-12-25")))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "date")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], "2024-01-15")
  expect_true(is.na(parsed$x[2]))
  expect_equal(parsed$x[3], "2024-12-25")
})

test_that("epoch date (1970-01-01) is handled", {
  df <- data.frame(x = as.Date("1970-01-01"))
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x, "1970-01-01")
})

# ---- Datetimes ----

test_that("POSIXct columns get 'datetime' schema type and ISO 8601 with T", {
  df <- data.frame(x = as.POSIXct(c("2024-01-15 10:30:00", NA), tz = "UTC"))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "datetime")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], "2024-01-15T10:30:00")
  expect_true(is.na(parsed$x[2]))
})

test_that("POSIXlt columns are auto-converted to POSIXct", {
  df <- data.frame(x = 1:2)
  df$dt <- as.POSIXlt(c("2024-01-01 00:00:00", "2024-06-15 12:00:00"), tz = "UTC")
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$dt, "datetime")
  parsed <- jsonlite::fromJSON(res$data)
  expect_true(grepl("T", parsed$dt[1]))
})

test_that("POSIXct NA does not produce string 'NA'", {
  df <- data.frame(x = as.POSIXct(c(NA, "2024-01-01 00:00:00"), tz = "UTC"))
  res <- peRspective:::.serialize_json(df)
  # Should contain null, not the string "NA"
  expect_false(grepl('"NA"', res$data))
  expect_true(grepl("null", res$data))
})

# ---- difftime ----

test_that("difftime is converted to numeric seconds", {
  df <- data.frame(x = as.difftime(c(60, 120, NA), units = "secs"))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$x, "float")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], 60)
  expect_equal(parsed$x[2], 120)
  expect_true(is.na(parsed$x[3]))
})

test_that("difftime in minutes is converted to seconds", {
  df <- data.frame(x = as.difftime(c(1, 2), units = "mins"))
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x[1], 60)
  expect_equal(parsed$x[2], 120)
})

# ---- List columns ----

test_that("list columns are serialized as JSON strings", {
  df <- data.frame(x = 1:3)
  df$nested <- list(c(1, 2), c(3, 4, 5), NULL)
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$schema$nested, "string")
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$nested[1], "[1,2]")
  expect_true(is.na(parsed$nested[3]))
})

# ---- Edge cases ----

test_that("empty data.frame serializes", {
  df <- data.frame(x = integer(0), y = character(0))
  res <- peRspective:::.serialize_json(df)
  expect_equal(res$data, '{"x":[],"y":[]}')
})

test_that("single row data.frame serializes", {
  df <- data.frame(x = 1, y = "a")
  res <- peRspective:::.serialize_json(df)
  parsed <- jsonlite::fromJSON(res$data)
  expect_equal(parsed$x, 1)
})

test_that("all-NA logical column gets boolean schema", {
  df <- data.frame(x = c(NA, NA, NA))
  res <- peRspective:::.serialize_json(df)
  # R defaults all-NA to logical, which should map to boolean
  expect_equal(res$schema$x, "boolean")
})

# ---- Widget creation with mixed types ----

test_that("perspective() handles mixed-type data frame", {
  df <- data.frame(
    id = 1:3,
    name = c("Alice", NA, "Eve"),
    score = c(95.5, NaN, Inf),
    passed = c(TRUE, FALSE, NA),
    grade = factor(c("A", "B", NA)),
    exam_date = as.Date(c("2024-01-15", NA, "2024-05-25")),
    submitted = as.POSIXct(c("2024-01-15 09:00:00", NA, "2024-05-25 16:45:00"), tz = "UTC"),
    duration = as.difftime(c(60, NA, 120), units = "mins"),
    stringsAsFactors = FALSE
  )
  w <- perspective(df)
  expect_s3_class(w, "perspective")
  expect_equal(w$x$data_format, "json")
  expect_equal(w$x$schema$id, "integer")
  expect_equal(w$x$schema$name, "string")
  expect_equal(w$x$schema$score, "float")
  expect_equal(w$x$schema$passed, "boolean")
  expect_equal(w$x$schema$grade, "string")
  expect_equal(w$x$schema$exam_date, "date")
  expect_equal(w$x$schema$submitted, "datetime")
  expect_equal(w$x$schema$duration, "float")
})
