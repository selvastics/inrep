# Test suite for estimate_ability function
# Tests ability estimation with different IRT models and methods

context("estimate_ability")

# Create test data
test_item_bank <- data.frame(
  item_id = 1:5,
  a = c(1.2, 0.8, 1.5, 1.0, 1.3),
  b = c(0.0, -0.5, 0.3, -0.2, 0.1),
  stringsAsFactors = FALSE
)

test_responses <- c(1, 0, 1, 1, 0)
test_administered <- 1:5

test_that("estimate_ability works with TAM method", {
  config <- create_study_config(
    name = "TAM Test",
    model = "2PL",
    estimation_method = "TAM"
  )
  
  result <- estimate_ability(
    rv = list(responses = test_responses, administered = test_administered),
    item_bank = test_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_is(result$theta, "numeric")
  expect_is(result$se, "numeric")
  expect_true(result$se > 0)
})

test_that("estimate_ability works with MIRT method", {
  config <- create_study_config(
    name = "MIRT Test",
    model = "2PL",
    estimation_method = "MIRT"
  )
  
  result <- estimate_ability(
    rv = list(responses = test_responses, administered = test_administered),
    item_bank = test_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_is(result$theta, "numeric")
  expect_is(result$se, "numeric")
  expect_true(result$se > 0)
})

test_that("estimate_ability handles empty responses", {
  config <- create_study_config(
    name = "Empty Test",
    model = "2PL"
  )
  
  result <- estimate_ability(
    rv = list(responses = c(), administered = c()),
    item_bank = test_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_equal(result$theta, 0)
  expect_true(result$se > 0)
})

test_that("estimate_ability handles different IRT models", {
  models <- c("1PL", "2PL", "3PL")
  
  for (model in models) {
    config <- create_study_config(
      name = paste("Model", model),
      model = model
    )
    
    result <- estimate_ability(
      rv = list(responses = test_responses, administered = test_administered),
      item_bank = test_item_bank,
      config = config
    )
    
    expect_is(result, "list")
    expect_true("theta" %in% names(result))
    expect_true("se" %in% names(result))
  }
})

test_that("estimate_ability handles GRM model", {
  # Create GRM item bank
  grm_item_bank <- data.frame(
    item_id = 1:3,
    a = c(1.2, 0.8, 1.5),
    b1 = c(-1.0, -0.5, -0.8),
    b2 = c(0.0, 0.0, 0.0),
    b3 = c(1.0, 0.5, 0.8),
    stringsAsFactors = FALSE
  )
  
  config <- create_study_config(
    name = "GRM Test",
    model = "GRM"
  )
  
  grm_responses <- c(2, 1, 3)
  grm_administered <- 1:3
  
  result <- estimate_ability(
    rv = list(responses = grm_responses, administered = grm_administered),
    item_bank = grm_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
})

test_that("estimate_ability handles parallel processing", {
  config <- create_study_config(
    name = "Parallel Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  result <- estimate_ability(
    rv = list(responses = test_responses, administered = test_administered),
    item_bank = test_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
})

test_that("estimate_ability provides reasonable estimates", {
  config <- create_study_config(
    name = "Reasonable Test",
    model = "2PL"
  )
  
  # Test with all correct responses
  all_correct <- rep(1, 5)
  result_correct <- estimate_ability(
    rv = list(responses = all_correct, administered = test_administered),
    item_bank = test_item_bank,
    config = config
  )
  
  # Test with all incorrect responses
  all_incorrect <- rep(0, 5)
  result_incorrect <- estimate_ability(
    rv = list(responses = all_incorrect, administered = test_administered),
    item_bank = test_item_bank,
    config = config
  )
  
  # Correct responses should give higher theta
  expect_gt(result_correct$theta, result_incorrect$theta)
  
  # Both should have reasonable standard errors
  expect_true(result_correct$se > 0)
  expect_true(result_incorrect$se > 0)
  expect_true(result_correct$se < 2)
  expect_true(result_incorrect$se < 2)
})

test_that("estimate_ability handles missing data gracefully", {
  config <- create_study_config(
    name = "Missing Test",
    model = "2PL"
  )
  
  # Test with some missing responses
  responses_with_na <- c(1, NA, 0, 1, NA)
  administered_with_na <- c(1, 2, 3, 4, 5)
  
  result <- estimate_ability(
    rv = list(responses = responses_with_na, administered = administered_with_na),
    item_bank = test_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_is(result$theta, "numeric")
  expect_is(result$se, "numeric")
})

test_that("estimate_ability handles single item", {
  config <- create_study_config(
    name = "Single Test",
    model = "2PL"
  )
  
  single_item_bank <- test_item_bank[1, ]
  single_response <- 1
  single_administered <- 1
  
  result <- estimate_ability(
    rv = list(responses = single_response, administered = single_administered),
    item_bank = single_item_bank,
    config = config
  )
  
  expect_is(result, "list")
  expect_true("theta" %in% names(result))
  expect_true("se" %in% names(result))
  expect_is(result$theta, "numeric")
  expect_is(result$se, "numeric")
})