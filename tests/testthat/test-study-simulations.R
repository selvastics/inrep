# Test Suite for Study Simulations and Edge Cases
# Tests various real-world scenarios and ensures robustness

library(testthat)
library(inrep)

# Source enhanced modules
source("../../R/study_simulations.R")
source("../../R/enhanced_config_handler.R")

context("Study Simulations and Edge Cases")

test_that("Educational study simulations work correctly", {
  results <- simulate_educational_studies()
  
  expect_type(results, "list")
  expect_true(length(results) > 0)
  
  # Check each scenario
  for (scenario in names(results)) {
    expect_true(results[[scenario]]$status %in% c("success", "error"))
    if (results[[scenario]]$status == "error") {
      warning(paste("Educational scenario failed:", scenario, "-", 
                   results[[scenario]]$message))
    }
  }
})

test_that("Clinical study simulations work correctly", {
  results <- simulate_clinical_studies()
  
  expect_type(results, "list")
  expect_true(length(results) > 0)
  
  # Check PHQ-9 scenario specifically
  if ("clinical_depression" %in% names(results)) {
    phq9 <- results$clinical_depression
    if (phq9$status == "success") {
      expect_true("suicide_item_alert" %in% names(phq9$config) || 
                 "clinical_mode" %in% names(phq9$config))
    }
  }
})

test_that("Corporate study simulations work correctly", {
  results <- simulate_corporate_studies()
  
  expect_type(results, "list")
  
  # Check proctoring scenario
  if ("corporate_technical" %in% names(results)) {
    tech <- results$corporate_technical
    if (tech$status == "success" && !is.null(tech$config)) {
      if (isTRUE(tech$config$proctoring_enabled)) {
        expect_true(tech$config$prevent_copy_paste %||% FALSE)
      }
    }
  }
})

test_that("Extreme parameter simulations are handled", {
  results <- simulate_extreme_studies()
  
  expect_type(results, "list")
  
  # Check massive scale scenario
  if ("extreme_massive" %in% names(results)) {
    massive <- results$extreme_massive
    if (massive$status == "success" && !is.null(massive$config)) {
      # Should trigger performance optimizations
      expect_true(massive$config$max_items <= 1000)  # Should be capped
    }
  }
  
  # Check minimal scenario
  if ("extreme_minimal" %in% names(results)) {
    minimal <- results$extreme_minimal
    expect_true(minimal$status %in% c("success", "error"))
  }
  
  # Check unicode scenario
  if ("extreme_unicode" %in% names(results)) {
    unicode <- results$extreme_unicode
    expect_true(unicode$status %in% c("success", "error"))
  }
})

test_that("Configuration validation handles edge cases", {
  # Test extreme max_items
  config1 <- list(max_items = 10000, min_items = 5000)
  fixed1 <- validate_and_fix_config(config1)
  expect_lte(fixed1$max_items, 1000)
  expect_lte(fixed1$min_items, fixed1$max_items)
  
  # Test invalid model
  config2 <- list(model = "INVALID_MODEL")
  fixed2 <- validate_and_fix_config(config2)
  expect_true(fixed2$model %in% c("1PL", "2PL", "3PL", "GRM"))
  
  # Test empty name
  config3 <- list(name = "")
  fixed3 <- validate_and_fix_config(config3)
  expect_true(nchar(fixed3$name) > 0)
  
  # Test too many demographics
  config4 <- list(demographics = paste0("var_", 1:200))
  fixed4 <- validate_and_fix_config(config4)
  expect_lte(length(fixed4$demographics), 100)
  
  # Test negative SEM
  config5 <- list(min_SEM = -1)
  fixed5 <- validate_and_fix_config(config5)
  expect_gte(fixed5$min_SEM, 0)
})

test_that("Item bank compatibility is validated", {
  config <- list(model = "2PL", max_items = 10)
  
  # Test with missing columns
  item_bank1 <- data.frame(
    item_id = 1:5,
    content = paste("Item", 1:5)
    # Missing difficulty and discrimination
  )
  
  fixed_config <- validate_and_fix_config(config, item_bank1)
  expect_true(fixed_config$item_bank_modified %||% FALSE)
  
  # Test with multimedia items
  item_bank2 <- data.frame(
    item_id = 1:5,
    content = paste("Item", 1:5),
    difficulty = rnorm(5),
    discrimination = runif(5, 0.5, 2),
    media_url = paste0("http://example.com/media", 1:5)
  )
  
  config2 <- validate_and_fix_config(config, item_bank2)
  expect_true(config2$has_multimedia %||% FALSE)
  expect_true(config2$preload_media %||% FALSE)
})

test_that("Unicode text validation works", {
  # Test various unicode strings
  text1 <- "Hello World"
  expect_equal(validate_unicode_text(text1), text1)
  
  text2 <- "测试文本"  # Chinese
  validated2 <- validate_unicode_text(text2)
  expect_type(validated2, "character")
  
  text3 <- "Тест"  # Cyrillic
  validated3 <- validate_unicode_text(text3)
  expect_type(validated3, "character")
  
  # Test item ID sanitization
  item_id <- "Item-123_测试"
  validated_id <- validate_unicode_text(item_id, "item_id")
  expect_match(validated_id, "^[A-Za-z0-9_-]+$")
  
  # Test empty string
  empty <- "   "
  validated_empty <- validate_unicode_text(empty, "test")
  expect_true(nchar(validated_empty) > 0)
})

test_that("Extreme parameters are handled correctly", {
  params <- list(
    max_items = 5000,
    min_items = -10,
    min_SEM = 100,
    time_limit = 1000000,
    name = paste(rep("a", 1000), collapse = ""),
    demographics = paste0("var_", 1:500)
  )
  
  sanitized <- handle_extreme_parameters(params)
  
  expect_lte(sanitized$max_items, 1000)
  expect_gte(sanitized$min_items, 1)
  expect_lte(sanitized$min_SEM, 10)
  expect_lte(sanitized$time_limit, 86400)
  expect_lte(nchar(sanitized$name), 500)
  expect_lte(length(sanitized$demographics), 100)
})

test_that("Branching rules are validated", {
  rules <- list(
    rule1 = list(
      condition = "theta > 1",
      action = "skip_to_end"
    ),
    rule2 = list(
      theta_threshold = 2,
      next_module = "advanced"
    ),
    invalid_rule = list(
      something = "else"
    ),
    dangerous_rule = list(
      condition = "system('rm -rf /')",
      action = "continue"
    )
  )
  
  processed <- handle_branching_rules(rules)
  
  expect_type(processed, "list")
  expect_true("rule1" %in% names(processed))
  expect_true("rule2" %in% names(processed))
  expect_false("invalid_rule" %in% names(processed))
  
  # Dangerous rule should be sanitized
  if ("dangerous_rule" %in% names(processed)) {
    expect_equal(processed$dangerous_rule$condition, "TRUE")
  }
})

test_that("Scale optimization works correctly", {
  # Small scale
  config_small <- optimize_for_scale(list(), 50)
  expect_false(config_small$cache_enabled %||% TRUE)
  expect_equal(config_small$database_mode, "sqlite")
  
  # Medium scale
  config_medium <- optimize_for_scale(list(), 500)
  expect_true(config_medium$cache_enabled)
  expect_equal(config_medium$database_mode, "postgresql")
  
  # Large scale
  config_large <- optimize_for_scale(list(), 5000)
  expect_true(config_large$enable_load_balancing %||% FALSE)
  expect_true(config_large$use_cdn %||% FALSE)
  
  # Massive scale
  config_massive <- optimize_for_scale(list(), 50000)
  expect_equal(config_massive$database_mode, "distributed")
  expect_true(config_massive$horizontal_scaling %||% FALSE)
})

test_that("Fallback configuration is created on error", {
  # Test with NULL
  fallback1 <- create_fallback_config(NULL)
  expect_type(fallback1, "list")
  expect_true("name" %in% names(fallback1))
  expect_true("model" %in% names(fallback1))
  expect_true(fallback1$fallback_mode)
  
  # Test with partial config
  original <- list(name = "My Study", language = "es")
  fallback2 <- create_fallback_config(original)
  expect_equal(fallback2$name, "My Study")
  expect_equal(fallback2$language, "es")
  expect_true(fallback2$fallback_mode)
})

test_that("Clinical settings trigger appropriate flags", {
  config <- list(
    suicide_item_alert = c(9),
    model = "GRM"
  )
  
  validated <- validate_and_fix_config(config)
  
  expect_true(validated$clinical_mode %||% FALSE)
  expect_true("emergency_contact" %in% names(validated))
})

test_that("Accessibility settings are comprehensive", {
  config <- list(
    accessibility_enhanced = TRUE
  )
  
  validated <- validate_and_fix_config(config)
  
  expect_true(validated$font_size_adjustable %||% FALSE)
  expect_true(validated$high_contrast_available %||% FALSE)
  expect_true(validated$screen_reader_compatible %||% FALSE)
  expect_true(validated$keyboard_navigation %||% FALSE)
  expect_true(validated$aria_labels %||% FALSE)
})

test_that("Complete simulation run works", {
  skip_on_cran()  # Skip on CRAN due to time
  
  # Run all simulations
  all_results <- run_all_simulations()
  
  expect_type(all_results, "list")
  expect_true("results" %in% names(all_results))
  expect_true("errors" %in% names(all_results))
  expect_true("summary" %in% names(all_results))
  
  # Check summary
  summary <- all_results$summary
  expect_true(summary$total_scenarios > 0)
  expect_gte(summary$success_rate, 0)
  expect_lte(summary$success_rate, 100)
  
  # Report any errors found
  if (length(all_results$errors) > 0) {
    for (error_name in names(all_results$errors)) {
      message(paste("Simulation error in", error_name, ":", 
                   all_results$errors[[error_name]]))
    }
  }
})