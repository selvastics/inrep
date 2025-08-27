test_that("launch_study works with valid input", {
  # Create a minimal config and item_bank for testing
  config <- list(name = "Test Study", model = "1PL", max_items = 5)
  item_bank <- data.frame(Question = c("1 + 1 ="), b = c(0.0), Option1 = c("1"), Option2 = c("2"), Option3 = c("3"), Option4 = c("4"), Answer = c("2"))

  # Expect that launch_study runs without errors
  expect_no_error(launch_study(config, item_bank))
})

test_that("launch_study throws error with NULL config", {
  item_bank <- data.frame(Question = c("1 + 1 ="), b = c(0.0), Option1 = c("1"), Option2 = c("2"), Option3 = c("3"), Option4 = c("4"), Answer = c("2"))
  expect_error(launch_study(NULL, item_bank), "Configuration is NULL")
})

test_that("launch_study throws error with NULL item_bank", {
  config <- list(name = "Test Study", model = "1PL", max_items = 5)
  expect_error(launch_study(config, NULL), "Item bank is NULL")
})
