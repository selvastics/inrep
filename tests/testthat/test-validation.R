
library(testthat)
library(inrep)

test_that("validate_item_bank detects missing columns", {
  invalid_bank <- data.frame(Question = "Q1")
  expect_error(validate_item_bank(invalid_bank, "GRM"), "Item bank missing columns: a, ResponseCategories")
})

test_that("validate_item_bank checks numeric columns", {
  invalid_bank <- data.frame(
    Question = "Q1",
    ResponseCategories = "1,2,3,4,5",
    a = "invalid",
    b1 = 0,
    b2 = 0,
    b3 = 0,
    b4 = 0
  )
  expect_error(validate_item_bank(invalid_bank, "GRM"), "Column a must be numeric and non-NA")
})

test_that("validate_item_bank checks ResponseCategories for GRM", {
  invalid_bank <- data.frame(
    Question = "Q1",
    ResponseCategories = "5,4,3,2,1",
    a = 1.0,
    b1 = 0,
    b2 = 0,
    b3 = 0,
    b4 = 0
  )
  expect_error(validate_item_bank(invalid_bank, "GRM"), "ResponseCategories for item 1 must be unique and sorted")
})

test_that("validate_item_bank passes for valid GRM item bank", {
  valid_bank <- data.frame(
    Question = "Q1",
    ResponseCategories = "1,2,3,4,5",
    a = 1.0,
    b1 = -2.0,
    b2 = -0.5,
    b3 = 0.5,
    b4 = 2.0
  )
  expect_true(validate_item_bank(valid_bank, "GRM"))
})
