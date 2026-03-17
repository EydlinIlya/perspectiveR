test_that("perspectiveOutput creates shiny output", {
  skip_if_not_installed("shiny")
  out <- perspectiveOutput("test_id")
  expect_s3_class(out, "shiny.tag.list")
})

test_that("perspectiveProxy creates proxy object", {
  proxy <- perspectiveProxy(list(), "test_id")
  expect_s3_class(proxy, "perspective_proxy")
  expect_equal(proxy$id, "test_id")
})

test_that("proxy validation works", {
  expect_error(psp_clear("not_a_proxy"), "perspectiveProxy")
  expect_error(psp_reset(list()), "perspectiveProxy")
})

test_that("psp_remove validates proxy", {
  expect_error(psp_remove("not_a_proxy", keys = 1), "perspectiveProxy")
})

test_that("psp_remove rejects empty keys", {
  proxy <- perspectiveProxy(list(), "test_id")
  expect_error(psp_remove(proxy, keys = c()), "non-empty")
  expect_error(psp_remove(proxy), "non-empty")
})

test_that("psp_export validates proxy", {
  expect_error(psp_export("not_a_proxy"), "perspectiveProxy")
})

test_that("psp_export validates format", {
  proxy <- perspectiveProxy(list(), "test_id")
  expect_error(psp_export(proxy, format = "invalid"), "should be one of")
})

test_that("psp_save validates proxy", {
  expect_error(psp_save("not_a_proxy"), "perspectiveProxy")
})

test_that("psp_on_update validates proxy", {
  expect_error(psp_on_update("not_a_proxy"), "perspectiveProxy")
})

# ---- windowed export tests ----

test_that("psp_export validates window params", {
  proxy <- perspectiveProxy(list(), "test_id")
  expect_error(psp_export(proxy, start_row = "a"), "single numeric value")
  expect_error(psp_export(proxy, end_row = c(1, 2)), "single numeric value")
  expect_error(psp_export(proxy, start_col = NA), "single numeric value")
  expect_error(psp_export(proxy, end_col = TRUE), "single numeric value")
})

# ---- table metadata proxy tests ----

test_that("psp_schema validates proxy", {
  expect_error(psp_schema("not_a_proxy"), "perspectiveProxy")
})

test_that("psp_size validates proxy", {
  expect_error(psp_size("not_a_proxy"), "perspectiveProxy")
})

test_that("psp_columns validates proxy", {
  expect_error(psp_columns("not_a_proxy"), "perspectiveProxy")
})

# ---- expression validation tests ----

test_that("psp_validate_expressions validates proxy", {
  expect_error(psp_validate_expressions("not_a_proxy", "x"), "perspectiveProxy")
})

test_that("psp_validate_expressions requires non-empty character vector", {
  proxy <- perspectiveProxy(list(), "test_id")
  expect_error(psp_validate_expressions(proxy, c()), "non-empty character")
  expect_error(psp_validate_expressions(proxy, 123), "non-empty character")
  expect_error(psp_validate_expressions(proxy), "non-empty character")
})
