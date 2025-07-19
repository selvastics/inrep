
library(testthat)
library(inrep)

test_that("estimate_ability returns prior when no items administered", {
  config <- create_study_config(model = "GRM", theta_prior = c(0, 1))
  rv <- reactiveValues(
    administered = c(),
    responses = c(),
    current_ability = 0,
    current_se = 1
  )
  item_bank <- data.frame(
    Question = "Q1",
    ResponseCategories = "1,2,3,4,5",
    a = 1.0,
    b1 = -2.0,
    b2 = -0.5,
    b3 = 0.5,
    b4 = 2.0
  )
  result <- estimate_ability(rv, item_bank, config)
  expect_equal(result$theta, 0)
  expect_equal(result$se, 1)
})

test_that("estimate_ability handles invalid responses", {
  config <- create_study_config(model = "GRM")
  rv <- reactiveValues(
    administered = c(1),
    responses = c(NA),
    current_ability = 0,
    current_se = 1
  )
  item_bank <- data.frame(
    Question = "Q1",
    ResponseCategories = "1,2,3,4,5",
    a = 1.0,
    b1 = -2.0,
    b2 = -0.5,
    b3 = 0.5,
    b4 = 2.0
  )
  result <- estimate_ability(rv, item_bank, config)
  expect_true(is.finite(result$theta))
})

test_that("estimate_ability computes theta for valid GRM responses", {
  config <- create_study_config(model = "GRM", theta_prior = c(0, 1))
  rv <- reactiveValues(
    administered = c(1, 2),
    responses = c(3, 4),
    current_ability = 0,
    current_se = 1
  )
  item_bank <- data.frame(
    Question = c("Q1", "Q2"),
    ResponseCategories = c("1,2,3,4,5", "1,2,3,4,5"),
    a = c(1.0, 1.2),
    b1 = c(-2.0, -1.8),
    b2 = c(-0.5, -0.3),
    b3 = c(0.5, 0.7),
    b4 = c(2.0, 2.2)
  )
  result <- estimate_ability(rv, item_bank, config)
  expect_true(is.finite(result$theta))
  expect_true(is.finite(result$se))
  expect_true(result$se <= rv$current_se)
})

test_that("estimate_ability handles 3PL model", {
  config <- create_study_config(model = "3PL")
  rv <- reactiveValues(
    administered = c(1),
    responses = c(1),
    current_ability = 0,
    current_se = 1
  )
  item_bank <- data.frame(
    Question = "Q1",
    a = 1.0,
    b = 0.0,
    c = 0.2,
    Answer = "Option1",
    Option1 = "A",
    Option2 = "B",
    Option3 = "C",
    Option4 = "D"
  )
  result <- estimate_ability(rv, item_bank, config)
  expect_true(is.finite(result$theta))
  expect_true(is.finite(result$se))
})
