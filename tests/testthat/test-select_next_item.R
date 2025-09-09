# Test suite for select_next_item function
# Tests item selection algorithms and adaptive testing logic

context("select_next_item")

# Create test data
test_item_bank <- data.frame(
  item_id = 1:10,
  a = c(1.2, 0.8, 1.5, 1.0, 1.3, 0.9, 1.1, 1.4, 0.7, 1.6),
  b = c(0.0, -0.5, 0.3, -0.2, 0.1, 0.4, -0.3, 0.6, -0.1, 0.2),
  stringsAsFactors = FALSE
)

test_that("select_next_item works with MI criterion", {
  config <- create_study_config(
    name = "MI Test",
    model = "2PL",
    criteria = "MI"
  )
  
  result <- select_next_item(
    config = config,
    administered_items = c(1, 2, 3),
    responses = c(1, 0, 1),
    current_ability = 0.5,
    item_bank = test_item_bank
  )
  
  expect_is(result, "list")
  expect_true("item_id" %in% names(result))
  expect_true("item_info" %in% names(result))
  expect_is(result$item_id, "numeric")
  expect_is(result$item_info, "data.frame")
  expect_false(result$item_id %in% c(1, 2, 3))
})

test_that("select_next_item works with different criteria", {
  criteria <- c("MI", "MFI", "KL")
  
  for (criterion in criteria) {
    config <- create_study_config(
      name = paste("Criterion", criterion),
      model = "2PL",
      criteria = criterion
    )
    
    result <- select_next_item(
      config = config,
      administered_items = c(1, 2),
      responses = c(1, 0),
      current_ability = 0.0,
      item_bank = test_item_bank
    )
    
    expect_is(result, "list")
    expect_true("item_id" %in% names(result))
    expect_true("item_info" %in% names(result))
    expect_false(result$item_id %in% c(1, 2))
  }
})

test_that("select_next_item handles different IRT models", {
  models <- c("1PL", "2PL", "3PL")
  
  for (model in models) {
    config <- create_study_config(
      name = paste("Model", model),
      model = model
    )
    
    result <- select_next_item(
      config = config,
      administered_items = c(1),
      responses = c(1),
      current_ability = 0.0,
      item_bank = test_item_bank
    )
    
    expect_is(result, "list")
    expect_true("item_id" %in% names(result))
    expect_true("item_info" %in% names(result))
    expect_false(result$item_id == 1)
  }
})

test_that("select_next_item handles GRM model", {
  # Create GRM item bank
  grm_item_bank <- data.frame(
    item_id = 1:5,
    a = c(1.2, 0.8, 1.5, 1.0, 1.3),
    b1 = c(-1.0, -0.5, -0.8, -0.3, -0.6),
    b2 = c(0.0, 0.0, 0.0, 0.0, 0.0),
    b3 = c(1.0, 0.5, 0.8, 0.3, 0.6),
    stringsAsFactors = FALSE
  )
  
  config <- create_study_config(
    name = "GRM Test",
    model = "GRM"
  )
  
  result <- select_next_item(
    config = config,
    administered_items = c(1, 2),
    responses = c(2, 1),
    current_ability = 0.0,
    item_bank = grm_item_bank
  )
  
  expect_is(result, "list")
  expect_true("item_id" %in% names(result))
  expect_true("item_info" %in% names(result))
  expect_false(result$item_id %in% c(1, 2))
})

test_that("select_next_item handles parallel processing", {
  config <- create_study_config(
    name = "Parallel Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  result <- select_next_item(
    config = config,
    administered_items = c(1, 2, 3),
    responses = c(1, 0, 1),
    current_ability = 0.5,
    item_bank = test_item_bank
  )
  
  expect_is(result, "list")
  expect_true("item_id" %in% names(result))
  expect_true("item_info" %in% names(result))
  expect_false(result$item_id %in% c(1, 2, 3))
})

test_that("select_next_item returns NULL when all items administered", {
  config <- create_study_config(
    name = "Complete Test",
    model = "2PL"
  )
  
  # Administer all items
  all_administered <- 1:10
  all_responses <- rep(1, 10)
  
  result <- select_next_item(
    config = config,
    administered_items = all_administered,
    responses = all_responses,
    current_ability = 0.5,
    item_bank = test_item_bank
  )
  
  expect_null(result)
})

test_that("select_next_item handles empty administered items", {
  config <- create_study_config(
    name = "First Item Test",
    model = "2PL"
  )
  
  result <- select_next_item(
    config = config,
    administered_items = c(),
    responses = c(),
    current_ability = 0.0,
    item_bank = test_item_bank
  )
  
  expect_is(result, "list")
  expect_true("item_id" %in% names(result))
  expect_true("item_info" %in% names(result))
  expect_true(result$item_id %in% 1:10)
})

test_that("select_next_item provides item information", {
  config <- create_study_config(
    name = "Info Test",
    model = "2PL"
  )
  
  result <- select_next_item(
    config = config,
    administered_items = c(1, 2),
    responses = c(1, 0),
    current_ability = 0.0,
    item_bank = test_item_bank
  )
  
  expect_is(result$item_info, "data.frame")
  expect_equal(nrow(result$item_info), 1)
  expect_equal(result$item_info$item_id, result$item_id)
  expect_true("a" %in% names(result$item_info))
  expect_true("b" %in% names(result$item_info))
})

test_that("select_next_item handles different ability levels", {
  config <- create_study_config(
    name = "Ability Test",
    model = "2PL"
  )
  
  # Test with low ability
  result_low <- select_next_item(
    config = config,
    administered_items = c(1),
    responses = c(0),
    current_ability = -2.0,
    item_bank = test_item_bank
  )
  
  # Test with high ability
  result_high <- select_next_item(
    config = config,
    administered_items = c(1),
    responses = c(1),
    current_ability = 2.0,
    item_bank = test_item_bank
  )
  
  expect_is(result_low, "list")
  expect_is(result_high, "list")
  expect_true("item_id" %in% names(result_low))
  expect_true("item_id" %in% names(result_high))
  expect_false(result_low$item_id == 1)
  expect_false(result_high$item_id == 1)
})

test_that("select_next_item handles caching", {
  config <- create_study_config(
    name = "Cache Test",
    model = "2PL",
    cache_enabled = TRUE
  )
  
  result1 <- select_next_item(
    config = config,
    administered_items = c(1),
    responses = c(1),
    current_ability = 0.0,
    item_bank = test_item_bank
  )
  
  result2 <- select_next_item(
    config = config,
    administered_items = c(1),
    responses = c(1),
    current_ability = 0.0,
    item_bank = test_item_bank
  )
  
  expect_is(result1, "list")
  expect_is(result2, "list")
  expect_true("item_id" %in% names(result1))
  expect_true("item_id" %in% names(result2))
})