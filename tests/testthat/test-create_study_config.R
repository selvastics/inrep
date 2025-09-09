# Test suite for create_study_config function
# Tests configuration creation, validation, and parameter handling

context("create_study_config")

test_that("create_study_config creates valid configuration with minimal parameters", {
  config <- create_study_config(
    name = "Test Study",
    model = "2PL"
  )
  
  expect_is(config, "list")
  expect_equal(config$name, "Test Study")
  expect_equal(config$model, "2PL")
  expect_true(config$adaptive)
  expect_equal(config$max_items, 20)
  expect_equal(config$min_items, 5)
})

test_that("create_study_config handles all IRT models correctly", {
  models <- c("1PL", "2PL", "3PL", "GRM")
  
  for (model in models) {
    config <- create_study_config(
      name = paste("Test", model),
      model = model
    )
    expect_equal(config$model, model)
  }
})

test_that("create_study_config validates parameter ranges", {
  # Test max_items validation
  expect_error(
    create_study_config(name = "Test", model = "2PL", max_items = 0),
    "max_items must be a positive integer"
  )
  
  # Test min_items validation
  expect_error(
    create_study_config(name = "Test", model = "2PL", min_items = -1),
    "min_items must be a non-negative integer"
  )
  
  # Test min_SEM validation
  expect_error(
    create_study_config(name = "Test", model = "2PL", min_SEM = 0),
    "min_SEM must be a positive number"
  )
})

test_that("create_study_config handles parallel processing parameters", {
  config <- create_study_config(
    name = "Parallel Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 4,
    parallel_batch_size = 25
  )
  
  expect_true(config$parallel_computation)
  expect_equal(config$parallel_workers, 4)
  expect_equal(config$parallel_batch_size, 25)
})

test_that("create_study_config handles demographics configuration", {
  config <- create_study_config(
    name = "Demo Test",
    model = "2PL",
    demographics = c("Age", "Gender"),
    input_types = list(
      Age = "numeric",
      Gender = "select"
    )
  )
  
  expect_equal(config$demographics, c("Age", "Gender"))
  expect_equal(config$input_types$Age, "numeric")
  expect_equal(config$input_types$Gender, "select")
})

test_that("create_study_config handles theme configuration", {
  themes <- c("light", "dark", "professional", "monochrome")
  
  for (theme in themes) {
    config <- create_study_config(
      name = paste("Theme", theme),
      model = "2PL",
      theme = theme
    )
    expect_equal(config$theme, theme)
  }
})

test_that("create_study_config handles adaptive vs non-adaptive modes", {
  # Adaptive mode
  config_adaptive <- create_study_config(
    name = "Adaptive Test",
    model = "2PL",
    adaptive = TRUE
  )
  expect_true(config_adaptive$adaptive)
  
  # Non-adaptive mode
  config_fixed <- create_study_config(
    name = "Fixed Test",
    model = "2PL",
    adaptive = FALSE
  )
  expect_false(config_fixed$adaptive)
})

test_that("create_study_config handles stopping criteria", {
  config <- create_study_config(
    name = "Stopping Test",
    model = "2PL",
    min_SEM = 0.3,
    max_items = 15,
    criteria = "MI"
  )
  
  expect_equal(config$min_SEM, 0.3)
  expect_equal(config$max_items, 15)
  expect_equal(config$criteria, "MI")
})

test_that("create_study_config handles session management", {
  config <- create_study_config(
    name = "Session Test",
    model = "2PL",
    session_save = TRUE,
    session_timeout = 3600
  )
  
  expect_true(config$session_save)
  expect_equal(config$session_timeout, 3600)
})

test_that("create_study_config provides sensible defaults", {
  config <- create_study_config(name = "Default Test")
  
  expect_equal(config$model, "2PL")
  expect_true(config$adaptive)
  expect_equal(config$max_items, 20)
  expect_equal(config$min_items, 5)
  expect_equal(config$min_SEM, 0.3)
  expect_equal(config$criteria, "MI")
  expect_false(config$parallel_computation)
  expect_equal(config$theme, "light")
})