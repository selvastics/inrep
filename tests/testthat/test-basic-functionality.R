# Test that package loads correctly
test_that("package loads without errors", {
  expect_no_error(library(inrep))
})

# Test that main functions exist
test_that("main functions are available", {
  library(inrep)
  expect_true(exists("create_study_config"))
  expect_true(exists("launch_study")) 
  expect_true(exists("estimate_ability"))
  expect_true(exists("validate_item_bank"))
})

# Test that data objects can be loaded
test_that("data objects can be loaded", {
  library(inrep)
  data(bfi_items, envir = environment())
  expect_true(exists("bfi_items", envir = environment()))
  data(math_items, envir = environment()) 
  expect_true(exists("math_items", envir = environment()))
})

# Test basic functionality
test_that("create_study_config works with defaults", {
  config <- create_study_config()
  expect_type(config, "list")
  expect_true("name" %in% names(config))
  expect_true("model" %in% names(config))
  expect_equal(config$model, "GRM")
})

# Test parameter validation
test_that("create_study_config validates parameters", {
  expect_error(
    create_study_config(min_SEM = -1),
    "min_SEM > 0"
  )
  
  expect_error(
    create_study_config(model = "invalid"),
    "model.*1PL.*2PL.*3PL.*GRM"
  )
  
  expect_error(
    create_study_config(min_items = 0),
    "min_items > 0"
  )
})
