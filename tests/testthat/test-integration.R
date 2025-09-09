# Integration tests for complete workflows
# Tests end-to-end functionality and component integration

context("integration_tests")

test_that("complete adaptive testing workflow works", {
  # Create test item bank
  item_bank <- data.frame(
    item_id = 1:10,
    a = c(1.2, 0.8, 1.5, 1.0, 1.3, 0.9, 1.1, 1.4, 0.7, 1.6),
    b = c(0.0, -0.5, 0.3, -0.2, 0.1, 0.4, -0.3, 0.6, -0.1, 0.2),
    stringsAsFactors = FALSE
  )
  
  # Create configuration
  config <- create_study_config(
    name = "Integration Test",
    model = "2PL",
    max_items = 5,
    min_items = 3,
    min_SEM = 0.5,
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  # Simulate adaptive testing process
  administered_items <- c()
  responses <- c()
  current_ability <- 0.0
  
  # Run adaptive testing loop
  for (i in 1:config$max_items) {
    # Select next item
    next_item <- select_next_item(
      config = config,
      administered_items = administered_items,
      responses = responses,
      current_ability = current_ability,
      item_bank = item_bank
    )
    
    if (is.null(next_item)) break
    
    # Simulate response (random for testing)
    response <- sample(c(0, 1), 1)
    
    # Update administered items and responses
    administered_items <- c(administered_items, next_item$item_id)
    responses <- c(responses, response)
    
    # Estimate ability
    ability_result <- estimate_ability(
      rv = list(responses = responses, administered = administered_items),
      item_bank = item_bank,
      config = config
    )
    
    current_ability <- ability_result$theta
    
    # Check stopping criteria
    if (length(administered_items) >= config$min_items && 
        ability_result$se <= config$min_SEM) {
      break
    }
  }
  
  # Verify results
  expect_true(length(administered_items) >= config$min_items)
  expect_true(length(administered_items) <= config$max_items)
  expect_equal(length(responses), length(administered_items))
  expect_is(current_ability, "numeric")
  expect_true(!is.na(current_ability))
})

test_that("complete non-adaptive testing workflow works", {
  # Create test item bank
  item_bank <- data.frame(
    item_id = 1:5,
    a = c(1.2, 0.8, 1.5, 1.0, 1.3),
    b = c(0.0, -0.5, 0.3, -0.2, 0.1),
    stringsAsFactors = FALSE
  )
  
  # Create non-adaptive configuration
  config <- create_study_config(
    name = "Non-Adaptive Test",
    model = "2PL",
    adaptive = FALSE,
    max_items = 5,
    min_items = 5
  )
  
  # Simulate fixed-order testing
  administered_items <- 1:5
  responses <- sample(c(0, 1), 5, replace = TRUE)
  
  # Estimate final ability
  ability_result <- estimate_ability(
    rv = list(responses = responses, administered = administered_items),
    item_bank = item_bank,
    config = config
  )
  
  # Verify results
  expect_equal(length(administered_items), 5)
  expect_equal(length(responses), 5)
  expect_is(ability_result$theta, "numeric")
  expect_is(ability_result$se, "numeric")
  expect_true(!is.na(ability_result$theta))
  expect_true(!is.na(ability_result$se))
})

test_that("GRM model workflow works", {
  # Create GRM item bank
  grm_item_bank <- data.frame(
    item_id = 1:5,
    a = c(1.2, 0.8, 1.5, 1.0, 1.3),
    b1 = c(-1.0, -0.5, -0.8, -0.3, -0.6),
    b2 = c(0.0, 0.0, 0.0, 0.0, 0.0),
    b3 = c(1.0, 0.5, 0.8, 0.3, 0.6),
    stringsAsFactors = FALSE
  )
  
  # Create GRM configuration
  config <- create_study_config(
    name = "GRM Test",
    model = "GRM",
    max_items = 5,
    min_items = 3
  )
  
  # Simulate GRM testing
  administered_items <- c()
  responses <- c()
  
  for (i in 1:config$max_items) {
    next_item <- select_next_item(
      config = config,
      administered_items = administered_items,
      responses = responses,
      current_ability = 0.0,
      item_bank = grm_item_bank
    )
    
    if (is.null(next_item)) break
    
    # Simulate polytomous response (1-4 scale)
    response <- sample(1:4, 1)
    
    administered_items <- c(administered_items, next_item$item_id)
    responses <- c(responses, response)
  }
  
  # Estimate ability
  ability_result <- estimate_ability(
    rv = list(responses = responses, administered = administered_items),
    item_bank = grm_item_bank,
    config = config
  )
  
  # Verify results
  expect_true(length(administered_items) >= config$min_items)
  expect_true(length(administered_items) <= config$max_items)
  expect_equal(length(responses), length(administered_items))
  expect_true(all(responses >= 1 & responses <= 4))
  expect_is(ability_result$theta, "numeric")
  expect_true(!is.na(ability_result$theta))
})

test_that("parallel processing integration works", {
  # Create test item bank
  item_bank <- data.frame(
    item_id = 1:20,
    a = runif(20, 0.5, 2.0),
    b = runif(20, -2, 2),
    stringsAsFactors = FALSE
  )
  
  # Create parallel configuration
  config <- create_study_config(
    name = "Parallel Integration Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2,
    parallel_batch_size = 5,
    max_items = 10,
    min_items = 5
  )
  
  # Simulate parallel processing
  administered_items <- c()
  responses <- c()
  current_ability <- 0.0
  
  for (i in 1:config$max_items) {
    # Use parallel item selection
    next_item <- select_next_item(
      config = config,
      administered_items = administered_items,
      responses = responses,
      current_ability = current_ability,
      item_bank = item_bank
    )
    
    if (is.null(next_item)) break
    
    response <- sample(c(0, 1), 1)
    administered_items <- c(administered_items, next_item$item_id)
    responses <- c(responses, response)
    
    # Use parallel ability estimation
    ability_result <- estimate_ability(
      rv = list(responses = responses, administered = administered_items),
      item_bank = item_bank,
      config = config
    )
    
    current_ability <- ability_result$theta
  }
  
  # Verify results
  expect_true(length(administered_items) >= config$min_items)
  expect_true(length(administered_items) <= config$max_items)
  expect_is(current_ability, "numeric")
  expect_true(!is.na(current_ability))
})

test_that("error handling integration works", {
  # Create configuration with invalid parameters
  config <- create_study_config(
    name = "Error Test",
    model = "2PL",
    max_items = 0  # Invalid parameter
  )
  
  # Should handle error gracefully
  expect_error(
    create_study_config(
      name = "Error Test",
      model = "2PL",
      max_items = 0
    ),
    "max_items must be a positive integer"
  )
})

test_that("validation integration works", {
  # Create invalid item bank
  invalid_item_bank <- data.frame(
    item_id = 1:3,
    b = c(0.0, -0.5, 0.3),
    # Missing 'a' column for 2PL
    stringsAsFactors = FALSE
  )
  
  # Should detect validation error
  result <- validate_item_bank(invalid_item_bank, "2PL")
  expect_false(result)
})

test_that("performance monitoring integration works", {
  # Create configuration with performance monitoring
  config <- create_study_config(
    name = "Performance Test",
    model = "2PL",
    parallel_computation = TRUE,
    parallel_workers = 2
  )
  
  # Create performance monitor
  monitor <- create_performance_monitor()
  
  # Simulate monitored operations
  monitor <- start_operation_timing(monitor, "item_selection")
  Sys.sleep(0.01)
  monitor <- end_operation_timing(monitor, "item_selection")
  
  monitor <- start_operation_timing(monitor, "ability_estimation")
  Sys.sleep(0.01)
  monitor <- end_operation_timing(monitor, "ability_estimation")
  
  # Get performance summary
  summary <- get_performance_summary(monitor)
  
  expect_is(summary, "list")
  expect_true("total_operations" %in% names(summary))
  expect_true(summary$total_operations >= 2)
})

test_that("complete study configuration validation works", {
  # Test valid configuration
  valid_config <- create_study_config(
    name = "Valid Test",
    model = "2PL",
    max_items = 10,
    min_items = 5,
    min_SEM = 0.3,
    demographics = c("Age", "Gender"),
    theme = "professional"
  )
  
  # Should create valid configuration
  expect_is(valid_config, "list")
  expect_equal(valid_config$name, "Valid Test")
  expect_equal(valid_config$model, "2PL")
  expect_equal(valid_config$max_items, 10)
  expect_equal(valid_config$min_items, 5)
  expect_equal(valid_config$min_SEM, 0.3)
  expect_equal(valid_config$demographics, c("Age", "Gender"))
  expect_equal(valid_config$theme, "professional")
})

test_that("data export integration works", {
  # Create test data
  test_data <- list(
    participant1 = data.frame(
      item_id = 1:3,
      response = c(1, 0, 1),
      ability = 0.5
    ),
    participant2 = data.frame(
      item_id = 1:3,
      response = c(0, 1, 0),
      ability = -0.3
    )
  )
  
  config <- create_study_config(
    name = "Export Test",
    model = "2PL",
    parallel_computation = TRUE
  )
  
  # Test different export formats
  formats <- c("csv", "json", "rds")
  
  for (format in formats) {
    result <- parallel_data_export(
      data_list = test_data,
      format = format,
      config = config
    )
    
    expect_is(result, "character")
    expect_true(length(result) > 0)
  }
})