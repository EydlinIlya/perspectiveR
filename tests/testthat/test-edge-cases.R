# ---- Fallback branch in .serialize_json ----

test_that("unknown column type falls back to character", {
  df <- data.frame(x = 1:3)
  # Create a column with an uncommon class
  df$raw_col <- as.raw(c(0x01, 0x02, 0x03))
  result <- perspectiveR:::.serialize_json(df)
  expect_equal(result$schema$raw_col, "string")
})

# ---- perspective() with plugin_config ----

test_that("plugin_config is passed through", {
  w <- perspective(mtcars,
    plugin = "Datagrid",
    plugin_config = list(columns = list(mpg = list(number_color_mode = "bar")))
  )
  expect_equal(w$x$config$plugin_config$columns$mpg$number_color_mode, "bar")
})

# ---- perspective() with elementId ----

test_that("elementId is passed to widget", {
  w <- perspective(mtcars, elementId = "my-widget")
  expect_equal(w$elementId, "my-widget")
})

# ---- .build_expressions ----

test_that(".build_expressions creates named list", {
  result <- perspectiveR:::.build_expressions(c("a + b", "c * 2"))
  expect_type(result, "list")
  expect_equal(names(result), c("a + b", "c * 2"))
  expect_equal(result[["a + b"]], "a + b")
})
