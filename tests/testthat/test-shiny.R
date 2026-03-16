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
