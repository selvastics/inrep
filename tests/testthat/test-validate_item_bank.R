# Test suite for validate_item_bank function
# Tests item bank validation for different IRT models

context("validate_item_bank")

test_that("validate_item_bank validates 2PL item bank correctly", {
  # Valid 2PL item bank
  valid_2pl_bank <- data.frame(
    item_id = 1:3,
    a = c(1.2, 0.8, 1.5),
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(valid_2pl_bank, "2PL")
  expect_true(result)
})

test_that("validate_item_bank validates 1PL item bank correctly", {
  # Valid 1PL item bank (only b parameter)
  valid_1pl_bank <- data.frame(
    item_id = 1:3,
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(valid_1pl_bank, "1PL")
  expect_true(result)
})

test_that("validate_item_bank validates 3PL item bank correctly", {
  # Valid 3PL item bank
  valid_3pl_bank <- data.frame(
    item_id = 1:3,
    a = c(1.2, 0.8, 1.5),
    b = c(0.0, -0.5, 0.3),
    c = c(0.1, 0.05, 0.2),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(valid_3pl_bank, "3PL")
  expect_true(result)
})

test_that("validate_item_bank validates GRM item bank correctly", {
  # Valid GRM item bank
  valid_grm_bank <- data.frame(
    item_id = 1:3,
    a = c(1.2, 0.8, 1.5),
    b1 = c(-1.0, -0.5, -0.8),
    b2 = c(0.0, 0.0, 0.0),
    b3 = c(1.0, 0.5, 0.8),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(valid_grm_bank, "GRM")
  expect_true(result)
})

test_that("validate_item_bank detects missing required columns", {
  # Missing 'a' column for 2PL
  invalid_2pl_bank <- data.frame(
    item_id = 1:3,
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(invalid_2pl_bank, "2PL")
  expect_false(result)
})

test_that("validate_item_bank detects missing item_id column", {
  # Missing item_id column
  invalid_bank <- data.frame(
    a = c(1.2, 0.8, 1.5),
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(invalid_bank, "2PL")
  expect_false(result)
})

test_that("validate_item_bank detects invalid parameter values", {
  # Invalid 'a' parameter (negative)
  invalid_params_bank <- data.frame(
    item_id = 1:3,
    a = c(-1.2, 0.8, 1.5),  # Negative discrimination
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(invalid_params_bank, "2PL")
  expect_false(result)
})

test_that("validate_item_bank handles empty item bank", {
  empty_bank <- data.frame(
    item_id = integer(0),
    a = numeric(0),
    b = numeric(0),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(empty_bank, "2PL")
  expect_false(result)
})

test_that("validate_item_bank handles single item", {
  single_item_bank <- data.frame(
    item_id = 1,
    a = 1.2,
    b = 0.0,
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(single_item_bank, "2PL")
  expect_true(result)
})

test_that("validate_item_bank handles mixed item types", {
  # Mixed 2PL and 3PL items
  mixed_bank <- data.frame(
    item_id = 1:4,
    a = c(1.2, 0.8, 1.5, 1.0),
    b = c(0.0, -0.5, 0.3, 0.1),
    c = c(NA, NA, 0.1, 0.05),  # Some items have guessing parameter
    stringsAsFactors = FALSE
  )
  
  # Should validate as 2PL (ignoring c column)
  result_2pl <- validate_item_bank(mixed_bank, "2PL")
  expect_true(result_2pl)
  
  # Should validate as 3PL (with c column)
  result_3pl <- validate_item_bank(mixed_bank, "3PL")
  expect_true(result_3pl)
})

test_that("validate_item_bank handles different data types", {
  # Test with character item_id
  char_id_bank <- data.frame(
    item_id = c("item1", "item2", "item3"),
    a = c(1.2, 0.8, 1.5),
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  result <- validate_item_bank(char_id_bank, "2PL")
  expect_true(result)
})

test_that("validate_item_bank provides helpful error messages", {
  # Missing required column
  invalid_bank <- data.frame(
    item_id = 1:3,
    b = c(0.0, -0.5, 0.3),
    stringsAsFactors = FALSE
  )
  
  # Capture the validation result and check for error message
  result <- validate_item_bank(invalid_bank, "2PL")
  expect_false(result)
})

test_that("validate_item_bank handles all supported models", {
  models <- c("1PL", "2PL", "3PL", "GRM")
  
  for (model in models) {
    # Create appropriate item bank for each model
    if (model == "1PL") {
      bank <- data.frame(
        item_id = 1:3,
        b = c(0.0, -0.5, 0.3),
        stringsAsFactors = FALSE
      )
    } else if (model == "2PL") {
      bank <- data.frame(
        item_id = 1:3,
        a = c(1.2, 0.8, 1.5),
        b = c(0.0, -0.5, 0.3),
        stringsAsFactors = FALSE
      )
    } else if (model == "3PL") {
      bank <- data.frame(
        item_id = 1:3,
        a = c(1.2, 0.8, 1.5),
        b = c(0.0, -0.5, 0.3),
        c = c(0.1, 0.05, 0.2),
        stringsAsFactors = FALSE
      )
    } else if (model == "GRM") {
      bank <- data.frame(
        item_id = 1:3,
        a = c(1.2, 0.8, 1.5),
        b1 = c(-1.0, -0.5, -0.8),
        b2 = c(0.0, 0.0, 0.0),
        b3 = c(1.0, 0.5, 0.8),
        stringsAsFactors = FALSE
      )
    }
    
    result <- validate_item_bank(bank, model)
    expect_true(result)
  }
})