# ---- Arrow serialization tests ----

test_that("Arrow serialization produces base64 output", {
  skip_if_not_installed("arrow")
  result <- peRspective:::.serialize_arrow(mtcars[1:5, ])
  expect_equal(result$format, "arrow")
  expect_type(result$data, "character")
  expect_true(nchar(result$data) > 0)
})

test_that("Arrow serialization handles factors", {
  skip_if_not_installed("arrow")
  df <- data.frame(x = 1:3, y = factor(c("a", "b", "c")))
  result <- peRspective:::.serialize_arrow(df)
  expect_equal(result$format, "arrow")
})

test_that("Arrow serialization handles difftime", {
  skip_if_not_installed("arrow")
  df <- data.frame(x = 1:2, d = as.difftime(c(60, 120), units = "secs"))
  result <- peRspective:::.serialize_arrow(df)
  expect_equal(result$format, "arrow")
})

test_that("Arrow serialization handles POSIXlt", {
  skip_if_not_installed("arrow")
  df <- data.frame(x = 1:2)
  df$dt <- as.POSIXlt(c("2024-01-01 00:00:00", "2024-06-15 12:00:00"), tz = "UTC")
  result <- peRspective:::.serialize_arrow(df)
  expect_equal(result$format, "arrow")
})

test_that("Arrow serialization handles list columns", {
  skip_if_not_installed("arrow")
  df <- data.frame(x = 1:2)
  df$nested <- list(c(1, 2), NULL)
  result <- peRspective:::.serialize_arrow(df)
  expect_equal(result$format, "arrow")
})

test_that("perspective with use_arrow=TRUE works", {
  skip_if_not_installed("arrow")
  w <- perspective(mtcars[1:5, ], use_arrow = TRUE)
  expect_s3_class(w, "perspective")
  expect_equal(w$x$data_format, "arrow")
})

test_that("base64enc_raw roundtrips correctly", {
  raw_input <- charToRaw("hello world")
  b64 <- peRspective:::base64enc_raw(raw_input)
  expect_type(b64, "character")
  expect_true(nchar(b64) > 0)
  decoded <- jsonlite::base64_dec(b64)
  expect_equal(decoded, raw_input)
})
