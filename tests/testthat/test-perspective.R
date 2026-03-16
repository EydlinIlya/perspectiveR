test_that("perspective creates an htmlwidget", {
  w <- perspective(mtcars)
  expect_s3_class(w, "htmlwidget")
  expect_s3_class(w, "perspective")
})

test_that("perspective accepts data.frame input", {
  w <- perspective(iris)
  expect_s3_class(w, "perspective")
  expect_equal(w$x$data_format, "json")
})

test_that("perspective accepts matrix input", {
  m <- matrix(1:12, nrow = 3, dimnames = list(NULL, c("a", "b", "c", "d")))
  w <- perspective(m)
  expect_s3_class(w, "perspective")
})

test_that("perspective rejects non-data inputs", {
  expect_error(perspective("not a dataframe"), "data.frame or matrix")
  expect_error(perspective(1:10), "data.frame or matrix")
  expect_error(perspective(list(a = 1)), "data.frame or matrix")
})

test_that("perspective config options are passed correctly", {
  w <- perspective(mtcars,
    columns = c("mpg", "cyl"),
    group_by = "cyl",
    split_by = "am",
    plugin = "Y Bar",
    theme = "Pro Dark",
    settings = FALSE,
    title = "Test Chart"
  )

  expect_equal(w$x$config$columns, list("mpg", "cyl"))
  expect_equal(w$x$config$group_by, list("cyl"))
  expect_equal(w$x$config$split_by, list("am"))
  expect_equal(w$x$config$plugin, "Y Bar")
  expect_equal(w$x$theme, "Pro Dark")
  expect_false(w$x$config$settings)
  expect_equal(w$x$config$title, "Test Chart")
})

test_that("perspective sort config is passed correctly", {
  w <- perspective(mtcars,
    sort = list(c("mpg", "desc"))
  )
  expect_equal(w$x$config$sort, list(c("mpg", "desc")))
})

test_that("perspective filter config is passed correctly", {
  w <- perspective(mtcars,
    filter = list(c("cyl", "==", "6"))
  )
  expect_equal(w$x$config$filter, list(c("cyl", "==", "6")))
})

test_that("perspective aggregates are passed correctly", {
  w <- perspective(mtcars,
    group_by = "cyl",
    aggregates = list(mpg = "avg", hp = "sum")
  )
  expect_equal(w$x$config$aggregates$mpg, "avg")
  expect_equal(w$x$config$aggregates$hp, "sum")
})

test_that("perspective expressions are passed correctly", {
  w <- perspective(mtcars,
    expressions = c('"mpg" * 2')
  )
  expect_type(w$x$config$expressions, "list")
})

test_that("perspective editable flag is passed correctly", {
  w <- perspective(mtcars, editable = TRUE)
  expect_true(w$x$config$editable)
})

test_that("JSON serialization handles factors", {
  df <- data.frame(
    x = 1:3,
    y = factor(c("a", "b", "c")),
    stringsAsFactors = FALSE
  )
  result <- peRspective:::.serialize_json(df)
  expect_equal(result$format, "json")
  # Factor should be converted to character in JSON
  parsed <- jsonlite::fromJSON(result$data)
  expect_type(parsed$y, "character")
})

test_that("JSON serialization handles NA values", {
  df <- data.frame(x = c(1, NA, 3), y = c("a", "b", NA))
  result <- peRspective:::.serialize_json(df)
  expect_equal(result$format, "json")
  expect_true(grepl("null", result$data))
})

test_that("Arrow serialization requires arrow package", {
  skip_if(requireNamespace("arrow", quietly = TRUE),
    message = "arrow is installed; cannot test missing-package error"
  )
  expect_error(.serialize_arrow(mtcars), "arrow")
})

test_that("perspective sizing policy is set", {
  w <- perspective(mtcars, width = "500px", height = "300px")
  expect_equal(w$width, "500px")
  expect_equal(w$height, "300px")
})

test_that("NULL config options are excluded", {
  w <- perspective(mtcars)
  expect_null(w$x$config$columns)
  expect_null(w$x$config$group_by)
  expect_null(w$x$config$split_by)
  expect_null(w$x$config$sort)
  expect_null(w$x$config$filter)
  expect_null(w$x$config$plugin)
})
