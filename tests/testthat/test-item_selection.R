
library(testthat)
library(inrep)

test_that("select_next_item returns NULL when max items reached", {
  config <- create_study_config(model = "GRM", max_items = 2)
  rv <- reactiveValues(
    administered = c(1, 2),
    responses = c(3, 4),
    current_ability = 0,
    item_info_cache = list(),
    item_counter = 2
  )
  item_bank <- data.frame(
    Question = c("Q1", "Q2"),
    ResponseCategories = c("1,2,3,4,5", "1,2,3,4,5"),
    a = c(1.0, 1.0),
    b1 = c(-2.0, -2.0),
    b2 = c(-0.5, -0.5),
    b3 = c(0.5, 0.5),
    b4 = c(2.0, 2.0)
  )
  expect_null(select_next_item(rv, item_bank, config))
})

test_that("select_next_item selects fixed items", {
  config <- create_study_config(model = "GRM", fixed_items = c(1, 2))
  rv <- reactiveValues(
    administered = c(),
    responses = c(),
    current_ability = 0,
    item_info_cache = list(),
    item_counter = 0
  )
  item_bank <- data.frame(
    Question = c("Q1", "Q2"),
    ResponseCategories = c("1,2,3,4,5", "1,2,3,4,5"),
    a = c(1.0, 1.0),
    b1 = c(-2.0, -2.0),
    b2 = c(-0.5, -0.5),
    b3 = c(0.5, 0.5),
    b4 = c(2.0, 2.0)
  )
  expect_equal(select_next_item(rv, item_bank, config), 1)
})
