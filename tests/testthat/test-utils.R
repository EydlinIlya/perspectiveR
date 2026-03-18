# ---- run_example tests ----

test_that("run_example() with NULL lists available examples", {
  expect_message(result <- run_example(), "Available perspectiveR examples")
  expect_type(result, "character")
  expect_true(length(result) > 0)
  expect_true("shiny-basic" %in% result)
})

test_that("run_example() errors on nonexistent example", {
  expect_error(run_example("nonexistent_example_xyz"), "not found")
})
