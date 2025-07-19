test_that("UI is created without errors", {
  config <- list(name = "Test Study", model = "1PL", max_items = 5, language = "en")
  expect_no_error(create_ui(config))
})

test_that("UI elements have correct ARIA attributes", {
  config <- list(name = "Test Study", model = "1PL", max_items = 5, language = "en")
  ui <- create_ui(config)
  expect_true(grepl("role = \"main\"", as.character(ui)))
  expect_true(grepl("aria-level = \"1\"", as.character(ui)))
})
