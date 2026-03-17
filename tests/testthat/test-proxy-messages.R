# Test that proxy functions send correct messages through the session.
# We use a mock session that captures sendCustomMessage calls.

mock_session <- function() {
  env <- new.env(parent = emptyenv())
  env$messages <- list()
  env$sendCustomMessage <- function(type, message) {
    env$messages[[length(env$messages) + 1]] <- list(type = type, message = message)
  }
  env
}

make_proxy <- function() {
  session <- mock_session()
  proxy <- perspectiveProxy(session, "viewer1")
  list(proxy = proxy, session = session)
}

# ---- psp_update ----

test_that("psp_update sends update message with JSON", {
  p <- make_proxy()
  result <- psp_update(p$proxy, data.frame(x = 1:3))
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$type, "perspective-calls")
  expect_equal(msgs[[1]]$message$id, "viewer1")
  expect_equal(msgs[[1]]$message$method, "update")
  expect_equal(msgs[[1]]$message$format, "json")
  expect_invisible(psp_update(p$proxy, data.frame(x = 1)))
})

test_that("psp_update validates proxy", {
  expect_error(psp_update("not_a_proxy", data.frame(x = 1)), "perspectiveProxy")
})

# ---- psp_replace ----

test_that("psp_replace sends replace message", {
  p <- make_proxy()
  psp_replace(p$proxy, data.frame(y = c("a", "b")))
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "replace")
  expect_equal(msgs[[1]]$message$format, "json")
})

test_that("psp_replace validates proxy", {
  expect_error(psp_replace("not_a_proxy", data.frame(x = 1)), "perspectiveProxy")
})

# ---- psp_clear ----

test_that("psp_clear sends clear message", {
  p <- make_proxy()
  psp_clear(p$proxy)
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "clear")
})

# ---- psp_reset ----

test_that("psp_reset sends reset message", {
  p <- make_proxy()
  psp_reset(p$proxy)
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "reset")
})

# ---- psp_restore ----

test_that("psp_restore sends restore message with config", {
  p <- make_proxy()
  cfg <- list(plugin = "Y Bar", group_by = list("cyl"))
  psp_restore(p$proxy, cfg)
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "restore")
  expect_equal(msgs[[1]]$message$config, cfg)
})

test_that("psp_restore validates proxy", {
  expect_error(psp_restore("not_a_proxy", list()), "perspectiveProxy")
})

# ---- psp_remove ----

test_that("psp_remove sends remove message with keys", {
  p <- make_proxy()
  psp_remove(p$proxy, keys = c("a", "b"))
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "remove")
  expect_equal(msgs[[1]]$message$keys, list("a", "b"))
})

# ---- psp_export ----

test_that("psp_export sends export message with format", {
  p <- make_proxy()
  psp_export(p$proxy, format = "csv")
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "export")
  expect_equal(msgs[[1]]$message$format, "csv")
})

test_that("psp_export sends windowed params", {
  p <- make_proxy()
  psp_export(p$proxy, format = "json", start_row = 0, end_row = 10,
             start_col = 0, end_col = 3)
  msg <- p$session$messages[[1]]$message
  expect_equal(msg$start_row, 0)
  expect_equal(msg$end_row, 10)
  expect_equal(msg$start_col, 0)
  expect_equal(msg$end_col, 3)
})

test_that("psp_export default format is json", {
  p <- make_proxy()
  psp_export(p$proxy)
  expect_equal(p$session$messages[[1]]$message$format, "json")
})

# ---- psp_save ----

test_that("psp_save sends save message", {
  p <- make_proxy()
  psp_save(p$proxy)
  msgs <- p$session$messages
  expect_length(msgs, 1)
  expect_equal(msgs[[1]]$message$method, "save")
})

# ---- psp_on_update ----

test_that("psp_on_update sends on_update message with enable flag", {
  p <- make_proxy()
  psp_on_update(p$proxy, enable = TRUE)
  expect_equal(p$session$messages[[1]]$message$method, "on_update")
  expect_true(p$session$messages[[1]]$message$enable)

  psp_on_update(p$proxy, enable = FALSE)
  expect_false(p$session$messages[[2]]$message$enable)
})

# ---- psp_schema ----

test_that("psp_schema sends schema message", {
  p <- make_proxy()
  psp_schema(p$proxy)
  expect_equal(p$session$messages[[1]]$message$method, "schema")
})

# ---- psp_size ----

test_that("psp_size sends size message", {
  p <- make_proxy()
  psp_size(p$proxy)
  expect_equal(p$session$messages[[1]]$message$method, "size")
})

# ---- psp_columns ----

test_that("psp_columns sends columns message", {
  p <- make_proxy()
  psp_columns(p$proxy)
  expect_equal(p$session$messages[[1]]$message$method, "columns")
})

# ---- psp_validate_expressions ----

test_that("psp_validate_expressions sends validate message", {
  p <- make_proxy()
  psp_validate_expressions(p$proxy, expressions = c('"col1" + "col2"'))
  msg <- p$session$messages[[1]]$message
  expect_equal(msg$method, "validate_expressions")
  expect_type(msg$expressions, "list")
})

# ---- chaining ----

test_that("proxy functions return proxy invisibly for chaining", {
  p <- make_proxy()
  expect_invisible(psp_clear(p$proxy))
  expect_invisible(psp_reset(p$proxy))
  expect_invisible(psp_save(p$proxy))
  expect_invisible(psp_on_update(p$proxy))
  expect_invisible(psp_schema(p$proxy))
  expect_invisible(psp_size(p$proxy))
  expect_invisible(psp_columns(p$proxy))

  ret <- psp_clear(p$proxy)
  expect_s3_class(ret, "perspective_proxy")
})
