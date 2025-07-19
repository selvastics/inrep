# Test item bank validation
test_that("validate_item_bank works correctly", {
  # Create a minimal valid item bank
  test_bank <- data.frame(
    item_id = paste0("item_", 1:5),
    content = paste("Test item", 1:5),
    a = c(1.2, 1.5, 0.8, 1.1, 1.3),
    b = c(-1.0, 0.0, 1.0, -0.5, 0.5),
    stringsAsFactors = FALSE
  )
  
  # Test validation passes
  expect_true(validate_item_bank(test_bank, model = "2PL"))
  
  # Test missing columns
  bad_bank <- test_bank[, -which(names(test_bank) == "a")]
  expect_error(
    validate_item_bank(bad_bank, model = "2PL"),
    "discrimination parameter"
  )
})

# Test ability estimation
test_that("estimate_ability basic functionality", {
  # Skip if TAM not available
  skip_if_not_installed("TAM")
  
  # Create simple test case
  responses <- c(1, 0, 1, 1, 0)
  item_params <- data.frame(
    a = c(1.2, 1.1, 1.3, 1.0, 1.4),
    b = c(-0.5, 0.0, 0.5, -1.0, 1.0)
  )
  
  result <- estimate_ability(
    responses = responses,
    item_bank = item_params,
    model = "2PL",
    method = "EAP"
  )
  
  expect_type(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_true(is.numeric(result$theta))
  expect_true(result$se > 0)
})

# Test unknown parameters support
test_that("unknown parameters functionality", {
  # Test initialization
  unknown_bank <- data.frame(
    item_id = paste0("item_", 1:3),
    content = paste("Test item", 1:3),
    a = c(NA, 1.2, NA),
    b = c(-0.5, NA, 0.5)
  )
  
  initialized <- initialize_unknown_parameters(unknown_bank, model = "2PL")
  
  expect_false(any(is.na(initialized$a)))
  expect_false(any(is.na(initialized$b)))
  expect_true(all(initialized$a > 0))
})

# Test multilingual support
test_that("language configuration works", {
  config <- create_study_config(language = "de")
  expect_equal(config$language, "de")
  
  expect_error(
    create_study_config(language = "invalid"),
    "language.*en.*de.*es.*fr"
  )
})
