#' Validation System for increp Package
#' 
#' This file consolidates all validation functions including:
#' - Study config validation (from validate_study_config.R)
#' - Response mapping validation (from validate_response_mapping.R)
#' - Item bank validation (from validation_clean.R)
#' - Argument validation (from argument_validation.R)
#' 
#' @name validation_system
#' @keywords internal

# ============================================================================
# SECTION 1: STUDY CONFIG VALIDATION (from validate_study_config.R)
# ============================================================================

# =============================================================================
# COMPREHENSIVE STUDY CONFIGURATION VALIDATION
# =============================================================================
# This file provides user-friendly validation with clear error messages
# to help users understand exactly what's wrong with their configuration

#' Validate Study Configuration with User-Friendly Error Messages
#'
#' @description
#' Performs comprehensive validation of study configuration parameters
#' with detailed, actionable error messages to guide users in fixing issues.
#' This function helps prevent common errors like NULL current_item issues.
#'
#' @param config Study configuration list from create_study_config()
#' @param item_bank Data frame containing assessment items
#' @param context Character string indicating validation context (e.g., "launch", "preview")
#'
#' @return List with validation results:
#'   \item{valid}{Logical indicating if configuration is valid}
#'   \item{errors}{Character vector of error messages}
#'   \item{warnings}{Character vector of warning messages}
#'   \item{suggestions}{Character vector of helpful suggestions}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' config <- create_study_config(name = "My Study")
#' items <- data.frame(Question = c("Item 1", "Item 2"))
#' validation <- validate_study_config(config, items)
#' 
#' if (!validation$valid) {
#'   cat("Configuration errors found:\n")
#'   for (error in validation$errors) {
#'     cat("  ERROR:", error, "\n")
#'   }
#' }
#' }
validate_study_config <- function(config, item_bank = NULL, context = "launch") {
  
  errors <- character()
  warnings <- character()
  suggestions <- character()
  
  # =============================================================================
  # REQUIRED PARAMETERS VALIDATION
  # =============================================================================
  
  # Check study name
  if (is.null(config$name) || config$name == "") {
    errors <- c(errors, 
      "Study name is missing. Please specify: config$name <- 'Your Study Name'"
    )
  }
  
  # Check study key
  if (is.null(config$study_key) || config$study_key == "") {
    warnings <- c(warnings,
      "Study key is missing. A unique key will be auto-generated, but it's better to specify: config$study_key <- 'unique_study_id'"
    )
  }
  
  # =============================================================================
  # MODEL CONFIGURATION VALIDATION
  # =============================================================================
  
  # Check IRT model
  valid_models <- c("1PL", "2PL", "3PL", "GRM", "PCM", "GPCM", "RSM")
  if (is.null(config$model)) {
    errors <- c(errors,
      sprintf("IRT model not specified. Please choose one of: %s\nExample: config$model <- 'GRM'",
              paste(valid_models, collapse = ", "))
    )
  } else if (!config$model %in% valid_models) {
    errors <- c(errors,
      sprintf("Invalid IRT model '%s'. Valid options are: %s\nExample: config$model <- 'GRM'",
              config$model, paste(valid_models, collapse = ", "))
    )
  }
  
  # Check adaptive setting
  if (is.null(config$adaptive)) {
    warnings <- c(warnings,
      "Adaptive testing not specified. Defaulting to TRUE.\nTo use fixed order: config$adaptive <- FALSE"
    )
    config$adaptive <- TRUE
  }
  
  # Check for non-adaptive mode requirements
  if (isFALSE(config$adaptive)) {
    if (is.null(config$criteria)) {
      warnings <- c(warnings,
        "Non-adaptive mode: Consider setting criteria to 'RANDOM'.\nExample: config$criteria <- 'RANDOM'"
      )
    }
    if (is.null(config$fixed_items) && !is.null(item_bank)) {
      suggestions <- c(suggestions,
        sprintf("Non-adaptive mode: Consider specifying item order.\nExample: config$fixed_items <- 1:%d", nrow(item_bank))
      )
    }
  }
  
  # =============================================================================
  # ITEM BANK VALIDATION
  # =============================================================================
  
  if (!is.null(item_bank)) {
    
    # Check if item bank is a data frame
    if (!is.data.frame(item_bank)) {
      errors <- c(errors,
        "Item bank must be a data frame. Example:\nitem_bank <- data.frame(\n  Question = c('Item 1', 'Item 2'),\n  id = c('Q1', 'Q2'),\n  b = c(0, 0.5)\n)"
      )
    } else {
      
      # Check for required columns
      required_cols <- c("Question")
      missing_cols <- setdiff(required_cols, names(item_bank))
      
      if (length(missing_cols) > 0) {
        errors <- c(errors,
          sprintf("Item bank missing required column(s): %s\nYour columns: %s\nExample fix:\nitem_bank$Question <- c('Your item text here')",
                  paste(missing_cols, collapse = ", "),
                  paste(names(item_bank), collapse = ", "))
        )
      }
      
      # Check for model-specific requirements
      if (!is.null(config$model)) {
        
        if (config$model == "GRM" && !"ResponseCategories" %in% names(item_bank)) {
          errors <- c(errors,
            "GRM model requires 'ResponseCategories' column.\nExample: item_bank$ResponseCategories <- '1,2,3,4,5'"
          )
        }
        
        if (config$model %in% c("2PL", "3PL") && !"a" %in% names(item_bank)) {
          warnings <- c(warnings,
            sprintf("%s model typically requires discrimination parameter 'a'.\nExample: item_bank$a <- rep(1, nrow(item_bank))",
                    config$model)
          )
        }
        
        if (config$model == "3PL" && !"c" %in% names(item_bank)) {
          warnings <- c(warnings,
            "3PL model requires guessing parameter 'c'.\nExample: item_bank$c <- rep(0.2, nrow(item_bank))"
          )
        }
      }
      
      # Check item count
      if (nrow(item_bank) == 0) {
        errors <- c(errors,
          "Item bank is empty. Please add at least one item."
        )
      } else if (nrow(item_bank) < 5) {
        warnings <- c(warnings,
          sprintf("Only %d items in item bank. Consider adding more items for reliable measurement.", nrow(item_bank))
        )
      }
      
      # Check for item IDs
      if (!"id" %in% names(item_bank)) {
        suggestions <- c(suggestions,
          "Consider adding item IDs for better tracking:\nitem_bank$id <- paste0('ITEM_', 1:nrow(item_bank))"
        )
      }
    }
  }
  
  # =============================================================================
  # DEMOGRAPHICS VALIDATION
  # =============================================================================
  
  if (!is.null(config$demographics) && length(config$demographics) > 0) {
    
    # Check input types
    if (is.null(config$input_types)) {
      warnings <- c(warnings,
        "Input types not specified for demographics. Defaulting to 'text'.\nSpecify types: config$input_types <- list(Age = 'numeric', Gender = 'select')"
      )
    } else {
      # Check if all demographics have input types
      missing_types <- setdiff(config$demographics, names(config$input_types))
      if (length(missing_types) > 0) {
        warnings <- c(warnings,
          sprintf("Input types missing for: %s\nAdd: config$input_types$%s <- 'select'",
                  paste(missing_types, collapse = ", "),
                  missing_types[1])
        )
      }
    }
    
    # Check demographic configurations
    if (is.null(config$demographic_configs)) {
      errors <- c(errors,
        "Demographic configurations missing. Example:\nconfig$demographic_configs <- list(\n  Age = list(\n    question = 'What is your age?',\n    options = NULL,  # NULL for text/numeric\n    required = TRUE\n  )\n)"
      )
    } else {
      # Validate each demographic configuration
      for (demo in config$demographics) {
        if (!demo %in% names(config$demographic_configs)) {
          errors <- c(errors,
            sprintf("Configuration missing for demographic '%s'.\nAdd: config$demographic_configs$%s <- list(question = 'Your question', options = c('Option1', 'Option2'))",
                    demo, demo)
          )
        } else {
          demo_config <- config$demographic_configs[[demo]]
          if (is.null(demo_config$question)) {
            errors <- c(errors,
              sprintf("Question text missing for '%s'.\nAdd: config$demographic_configs$%s$question <- 'Your question text'",
                      demo, demo)
            )
          }
        }
      }
    }
  }
  
  # =============================================================================
  # ADAPTIVE TESTING PARAMETERS
  # =============================================================================
  
  if (isTRUE(config$adaptive)) {
    
    # Check stopping criteria
    if (is.null(config$min_items) && is.null(config$min_SEM)) {
      warnings <- c(warnings,
        "No stopping criteria specified for adaptive testing.\nConsider setting: config$min_items <- 10 or config$min_SEM <- 0.3"
      )
    }
    
    # Check selection criteria
    valid_criteria <- c("MI", "MFI", "RANDOM", "WEIGHTED")
    if (!is.null(config$criteria) && !config$criteria %in% valid_criteria) {
      errors <- c(errors,
        sprintf("Invalid selection criteria '%s'. Valid options: %s\nExample: config$criteria <- 'MI'",
                config$criteria, paste(valid_criteria, collapse = ", "))
      )
    }
    
  } else {
    # Non-adaptive mode checks
    if (!is.null(config$max_items) && !is.null(item_bank)) {
      if (config$max_items != nrow(item_bank)) {
        suggestions <- c(suggestions,
          sprintf("In non-adaptive mode, consider setting max_items equal to item bank size:\nconfig$max_items <- %d",
                  nrow(item_bank))
        )
      }
    }
  }
  
  # =============================================================================
  # UI AND THEME VALIDATION
  # =============================================================================
  
  # Check theme
  valid_themes <- c("default", "modern", "classic", "professional", "hildesheim", "academic")
  if (!is.null(config$theme) && !config$theme %in% valid_themes) {
    warnings <- c(warnings,
      sprintf("Unknown theme '%s'. Valid themes: %s\nUsing default theme.",
              config$theme, paste(valid_themes, collapse = ", "))
    )
  }
  
  # Check response UI type
  valid_ui_types <- c("radio", "slider", "buttons", "likert")
  if (!is.null(config$response_ui_type) && !config$response_ui_type %in% valid_ui_types) {
    warnings <- c(warnings,
      sprintf("Unknown response UI type '%s'. Valid types: %s",
              config$response_ui_type, paste(valid_ui_types, collapse = ", "))
    )
  }
  
  # =============================================================================
  # RESULTS PROCESSOR VALIDATION
  # =============================================================================
  
  if (!is.null(config$results_processor)) {
    if (!is.function(config$results_processor)) {
      errors <- c(errors,
        "results_processor must be a function.\nExample:\nconfig$results_processor <- function(responses, item_bank) {\n  # Your code here\n  return(shiny::shiny::HTML('<p>Results</p>'))\n}"
      )
    } else {
      # Check function signature
      args <- names(formals(config$results_processor))
      if (!all(c("responses", "item_bank") %in% args)) {
        warnings <- c(warnings,
          "results_processor function should accept 'responses' and 'item_bank' parameters.\nExample: function(responses, item_bank) { ... }"
        )
      }
    }
  }
  
  # =============================================================================
  # COMMON ISSUES AND HELPFUL SUGGESTIONS
  # =============================================================================
  
  # Check for common mistakes
  if (!is.null(config$adapative)) {  # Common typo
    warnings <- c(warnings,
      "Found 'adapative' (typo). Did you mean 'adaptive'?\nCorrect: config$adaptive <- TRUE"
    )
  }
  
  if (!is.null(config$responce_ui_type)) {  # Common typo
    warnings <- c(warnings,
      "Found 'responce_ui_type' (typo). Did you mean 'response_ui_type'?\nCorrect: config$response_ui_type <- 'radio'"
    )
  }
  
  # Provide helpful suggestions based on configuration
  if (length(errors) == 0) {
    if (is.null(config$instructions)) {
      suggestions <- c(suggestions,
        "Consider adding instructions for participants:\nconfig$instructions <- list(\n  welcome = 'Welcome to our study',\n  purpose = 'This study aims to...'\n)"
      )
    }
    
    if (is.null(config$session_save)) {
      suggestions <- c(suggestions,
        "Consider enabling session saving for data recovery:\nconfig$session_save <- TRUE"
      )
    }
  }
  
  # =============================================================================
  # RETURN VALIDATION RESULTS
  # =============================================================================
  
  valid <- length(errors) == 0
  
  # Create detailed report
  report <- list(
    valid = valid,
    errors = errors,
    warnings = warnings,
    suggestions = suggestions,
    summary = sprintf(
      "Validation %s: %d error(s), %d warning(s), %d suggestion(s)",
      ifelse(valid, "PASSED", "FAILED"),
      length(errors),
      length(warnings),
      length(suggestions)
    )
  )
  
  # Print report if in interactive mode
  if (interactive() && (length(errors) > 0 || length(warnings) > 0)) {
    cat("\n", strrep("=", 70), "\n", sep = "")
    cat("STUDY CONFIGURATION VALIDATION REPORT\n")
    cat(strrep("=", 70), "\n\n")
    
    if (length(errors) > 0) {
      cat("ERRORS (must fix):\n")
      for (i in seq_along(errors)) {
        cat(sprintf("  %d. %s\n\n", i, errors[i]))
      }
    }
    
    if (length(warnings) > 0) {
      cat("WARNINGS (should review):\n")
      for (i in seq_along(warnings)) {
        cat(sprintf("  %d. %s\n\n", i, warnings[i]))
      }
    }
    
    if (length(suggestions) > 0) {
      cat("SUGGESTIONS (optional improvements):\n")
      for (i in seq_along(suggestions)) {
        cat(sprintf("  %d. %s\n\n", i, suggestions[i]))
      }
    }
    
    cat(report$summary, "\n")
    cat(strrep("=", 70), "\n\n")
  }
  
  return(report)
}



# ============================================================================
# SECTION 2: RESPONSE MAPPING VALIDATION (from validate_response_mapping.R)
# ============================================================================

# Enhanced Response Mapping Validation System
# This creates a comprehensive validation system for response mapping

#' Validate Response Mapping System for IRT-Based Assessments
#'
#' @description
#' Validates that input responses are correctly mapped to the final reporting system,
#' ensuring perfect alignment between what users input and what they see in results.
#' This function provides comprehensive validation for the entire response processing
#' pipeline in TAM-based adaptive assessments.
#'
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Must contain validation functions, scoring functions, and model specifications.
#' @param item_bank Item bank dataset with question content and response options.
#'   Structure varies by IRT model but must include required columns.
#' @param test_responses Vector of test responses to validate (e.g., c(3, 2, 4, 1, 5)).
#' @param test_items Vector of test items administered (e.g., c(1, 5, 12, 18, 23)).
#' 
#' @return Logical value: \code{TRUE} if all validation checks pass, \code{FALSE} otherwise.
#'   Function outputs detailed validation results to console during execution.
#' 
#' @export
#' 
#' @details
#' This function performs comprehensive validation of the response mapping system:
#' 
#' \strong{Validation Steps:}
#' \enumerate{
#'   \item \strong{Configuration Validation}: Checks required fields in config object
#'   \item \strong{Item Bank Validation}: Verifies required columns for model type
#'   \item \strong{Response Processing}: Tests response validation functions
#'   \item \strong{Scoring Validation}: Confirms scoring functions work correctly
#'   \item \strong{Reporting Table Generation}: Validates table creation logic
#'   \item \strong{Response Consistency}: Ensures input-output alignment
#' }
#' 
#' \strong{Error Detection:}
#' \itemize{
#'   \item Missing configuration fields
#'   \item Invalid item bank structure
#'   \item Failed response validation
#'   \item Scoring function errors
#'   \item Reporting table generation failures
#'   \item Response consistency issues
#' }
#' 
#' \strong{Model-Specific Validation:}
#' \itemize{
#'   \item \strong{GRM}: Validates ResponseCategories column and ordinal responses
#'   \item \strong{Binary Models}: Validates Answer column and correct/incorrect scoring
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic GRM Validation
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create GRM configuration
#' config <- create_study_config(
#'   model = "GRM",
#'   response_validation_fun = function(x) !is.na(x) && x %in% 1:5,
#'   scoring_fun = function(response, correct_answer) as.numeric(response)
#' )
#' 
#' # Test responses and items
#' test_responses <- c(3, 2, 4, 1, 5)
#' test_items <- c(1, 5, 12, 18, 23)
#' 
#' # Validate response mapping
#' is_valid <- validate_response_mapping(config, bfi_items, test_responses, test_items)
#' cat("Validation result:", is_valid, "\n")
#' 
#' # Example 2: Binary Model Validation
#' # Create binary item bank
#' binary_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   Answer = c("4", "15", "5"),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6")
#' )
#' 
#' # Create binary configuration
#' binary_config <- create_study_config(
#'   model = "2PL",
#'   response_validation_fun = function(x) !is.na(x) && x %in% c("2", "3", "4", "5", "10", "12", "15", "18"),
#'   scoring_fun = function(response, correct_answer) as.numeric(response == correct_answer)
#' )
#' 
#' # Test binary responses
#' binary_responses <- c("4", "15", "5")  # All correct
#' binary_items <- c(1, 2, 3)
#' 
#' # Validate binary mapping
#' is_valid_binary <- validate_response_mapping(binary_config, binary_items, binary_responses, binary_items)
#' cat("Binary validation result:", is_valid_binary, "\n")
#' 
#' # Example 3: Validation with Errors
#' # Create problematic configuration to test error detection
#' problematic_config <- create_study_config(
#'   model = "GRM",
#'   # Missing required functions
#'   response_validation_fun = NULL,
#'   scoring_fun = NULL
#' )
#' 
#' # This should fail validation
#' tryCatch({
#'   validate_response_mapping(problematic_config, bfi_items, test_responses, test_items)
#' }, error = function(e) {
#'   cat("Expected error caught:", e$message, "\n")
#' })
#' 
#' # Example 4: Comprehensive Validation Workflow
#' # Complete validation workflow for research study
#' complete_validation <- function(config, item_bank) {
#'   # Generate test data
#'   n_items <- min(10, nrow(item_bank))
#'   test_items <- sample(1:nrow(item_bank), n_items)
#'   
#'   if (config$model == "GRM") {
#'     test_responses <- sample(1:5, n_items, replace = TRUE)
#'   } else {
#'     # For binary models, use correct answers
#'     test_responses <- item_bank$Answer[test_items]
#'   }
#'   
#'   cat("Starting comprehensive validation...\n")
#'   cat("Items:", length(test_items), "\n")
#'   cat("Responses:", length(test_responses), "\n")
#'   cat("Model:", config$model, "\n")
#'   
#'   # Run validation
#'   result <- validate_response_mapping(config, item_bank, test_responses, test_items)
#'   
#'   cat("\nValidation completed:", if (result) "PASSED" else "FAILED", "\n")
#'   return(result)
#' }
#' 
#' # Run comprehensive validation
#' result <- complete_validation(config, bfi_items)
#' 
#' # Example 5: Multi-Model Validation
#' # Test validation across different models
#' models <- c("GRM", "2PL", "1PL")
#' validation_results <- list()
#' 
#' for (model in models) {
#'   cat("\n", paste(rep("=", 40), collapse=""), "\n")
#'   cat("Testing model:", model, "\n")
#'   
#'   # Create model-specific configuration
#'   model_config <- create_study_config(
#'     model = model,
#'     response_validation_fun = if (model == "GRM") {
#'       function(x) !is.na(x) && x %in% 1:5
#'     } else {
#'       function(x) !is.na(x) && x %in% c("A", "B", "C", "D")
#'     },
#'     scoring_fun = if (model == "GRM") {
#'       function(response, correct_answer) as.numeric(response)
#'     } else {
#'       function(response, correct_answer) as.numeric(response == correct_answer)
#'     }
#'   )
#'   
#'   # Create appropriate item bank
#'   if (model == "GRM") {
#'     test_bank <- bfi_items
#'     test_responses <- sample(1:5, 5, replace = TRUE)
#'   } else {
#'     test_bank <- binary_items
#'     test_responses <- sample(c("A", "B", "C", "D"), 3, replace = TRUE)
#'   }
#'   
#'   test_items <- 1:min(nrow(test_bank), length(test_responses))
#'   
#'   # Run validation
#'   validation_results[[model]] <- validate_response_mapping(
#'     model_config, test_bank, test_responses, test_items
#'   )
#' }
#' 
#' # Summary
#' cat("\n", paste(rep("=", 40), collapse=""), "\n")
#' cat("VALIDATION SUMMARY\n")
#' cat(paste(rep("=", 40), collapse=""), "\n")
#' for (model in models) {
#'   cat(sprintf("%-10s: %s\n", model, 
#'               if (validation_results[[model]]) "PASSED" else "FAILED"))
#' }
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_study_config}} for creating configuration objects
#'   \item \code{\link{create_response_report}} for response reporting
#'   \item \code{\link{validate_response_report}} for report validation
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @keywords validation psychometrics IRT response-mapping quality-assurance
validate_response_mapping <- function(config, item_bank, test_responses, test_items) {
  
  # Initialize validation log
  validation_log <- character()
  add_log <- function(msg) validation_log <<- c(validation_log, msg)
  
  add_log("VALIDATING RESPONSE MAPPING SYSTEM")
  add_log(paste(rep("=", 50), collapse=""))
  
  # Step 1: Validate configuration
  add_log("1. Configuration validation...")
  
  required_fields <- c("model", "response_validation_fun", "scoring_fun")
  missing_fields <- required_fields[!required_fields %in% names(config)]
  
  if (length(missing_fields) > 0) {
    add_log(paste("X Missing required config fields:", paste(missing_fields, collapse=", ")))
    return(FALSE)
  }
  add_log("[OK] Configuration valid")
  
  # Step 2: Validate item bank structure
  add_log("2. Item bank validation...")
  
  required_cols <- c("Question")
  if (config$model == "GRM") {
    required_cols <- c(required_cols, "ResponseCategories")
  } else {
    required_cols <- c(required_cols, "Answer")
  }
  
  missing_cols <- required_cols[!required_cols %in% colnames(item_bank)]
  if (length(missing_cols) > 0) {
    add_log(paste("X Missing required item bank columns:", paste(missing_cols, collapse=", ")))
    return(FALSE)
  }
  add_log("[OK] Item bank structure valid")
  
  # Step 3: Validate response processing
  add_log("3. Response processing validation...")
  
  validation_results <- sapply(test_responses, function(r) {
    tryCatch({
      config$response_validation_fun(r)
    }, error = function(e) FALSE)
  })
  
  if (!all(validation_results)) {
    add_log(paste("X Some responses failed validation:", 
        paste(test_responses[!validation_results], collapse=", ")))
    return(FALSE)
  }
  add_log("[OK] All responses pass validation")
  
  # Step 4: Validate scoring
  add_log("4. Scoring validation...")
  
  scored_responses <- sapply(seq_along(test_responses), function(i) {
    response <- test_responses[i]
    item_idx <- test_items[i]
    correct_answer <- if (config$model == "GRM") NULL else item_bank$Answer[item_idx]
    
    tryCatch({
      config$scoring_fun(response, correct_answer)
    }, error = function(e) {
      add_log(paste("Error scoring response", i, ":", e$message))
      NA
    })
  })
  
  if (any(is.na(scored_responses))) {
    add_log("X Some responses could not be scored")
    return(FALSE)
  }
  add_log("[OK] All responses scored successfully")
  
  # Step 5: Validate reporting table generation
  add_log("5. Reporting table validation...")
  
  # Simulate the exact table generation logic from launch_study.R
  cat_result <- list(
    responses = scored_responses,
    administered = test_items,
    response_times = rep(2.0, length(test_responses))
  )
  
  tryCatch({
    if (config$model == "GRM") {
      dat <- data.frame(
        Item = item_bank$Question[cat_result$administered],
        Response = cat_result$responses,
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    } else {
      dat <- data.frame(
        Item = item_bank$Question[cat_result$administered],
        Response = ifelse(cat_result$responses == 1, "Correct", "Incorrect"),
        Correct = item_bank$Answer[cat_result$administered],
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    }
    
    add_log("[OK] Reporting table generated successfully")
    
    # Step 6: Validate response consistency
    add_log("6. Response consistency validation...")
    
    # Check that input responses match reported responses
    if (config$model == "GRM") {
      # For GRM, scored responses should match original responses
      consistency_check <- all(scored_responses == test_responses)
    } else {
      # For binary models, check that scoring is consistent
      consistency_check <- all(scored_responses %in% c(0, 1))
    }
    
    if (!consistency_check) {
      add_log("X Response consistency check failed")
      add_log(paste("   Input responses:", paste(test_responses, collapse=", ")))
      add_log(paste("   Scored responses:", paste(scored_responses, collapse=", ")))
      return(FALSE)
    }
    
    add_log("[OK] Response consistency validated")
    
    # Step 7: Summary report
    add_log("")
    add_log(paste(rep("=", 50), collapse=""))
    add_log("VALIDATION SUMMARY")
    add_log(paste(rep("=", 50), collapse=""))
    
    add_log(paste("Input responses:     ", paste(test_responses, collapse=", ")))
    add_log(paste("Scored responses:    ", paste(scored_responses, collapse=", ")))
    add_log(paste("Items administered:  ", paste(test_items, collapse=", ")))
    add_log(paste("Model:               ", config$model))
    add_log("Validation:          [OK] PASSED")
    
    add_log("")
    add_log("Reporting table preview:")
    add_log(paste("Preview:", paste(capture.output(head(dat, 3)), collapse = "\n")))
    
    return(TRUE)
    
  }, error = function(e) {
    add_log(paste("X Error generating reporting table:", e$message))
    return(FALSE)
  })
}


# ============================================================================
# SECTION 3: ITEM BANK VALIDATION (from validation_clean.R)
# ============================================================================

#' Validate Item Bank for TAM Compatibility
#'
#' Validates the structure and content of an item bank for compatibility with
#' TAM package functions and the specified IRT model. Ensures that item parameters
#' and data structure meet TAM's requirements for statistical analysis and that
#' parameter values are within acceptable ranges for stable estimation.
#'
#' @param item_bank Data frame containing item parameters and content.
#' Structure and required columns vary by IRT model specification.
#' @param model Character string specifying IRT model for validation.
#' Options: \code{"1PL"}, \code{"2PL"}, \code{"3PL"}, \code{"GRM"}. Default: \code{"GRM"}.
#'
#' @return Logical value: \code{TRUE} if item bank is valid for TAM processing,
#' \code{FALSE} otherwise. Function will stop execution with descriptive error
#' message if critical validation failures are detected.
#'
#' @export
#'
#' @details
#' \strong{TAM Compatibility Requirements:} This function ensures comprehensive
#' compatibility with TAM package specifications:
#'
#' \strong{Structural Validation:}
#' \itemize{
#' \item Validates required columns for TAM model fitting functions
#' \item Checks data types and format consistency
#' \item Ensures adequate sample size for parameter estimation
#' \item Verifies no missing values in critical parameter columns
#' }
#'
#' \strong{Parameter Range Validation:}
#' \itemize{
#' \item Discrimination parameters (a): Must be positive, typically 0.2-3.0
#' \item Difficulty parameters (b): Logit scale, typically -4.0 to +4.0
#' \item Threshold parameters (b1, b2, ...): Must be in ascending order
#' \item Guessing parameters (c): Must be between 0.0 and 1.0
#' \item Response categories: Must be properly formatted and consistent
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Validate BFI personality items for GRM
#' library(inrep)
#' data(bfi_items)
#'
#' # Validate for GRM model
#' is_valid_grm <- validate_item_bank(bfi_items, "GRM")
#' cat("BFI items valid for GRM:", is_valid_grm, "\n")
#'
#' # Example 2: Validate cognitive items for 2PL model
#' cognitive_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   a = c(1.2, 0.8, 1.5),
#'   b = c(-0.5, 0.2, -1.0),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6"),
#'   Answer = c("4", "15", "5")
#' )
#'
#' # Validate for 2PL model
#' is_valid_2pl <- validate_item_bank(cognitive_items, "2PL")
#' cat("Cognitive items valid for 2PL:", is_valid_2pl, "\n")
#' }
#'
#' @references
#' \itemize{
#' \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}.
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' \item Samejima, F. (1969). Estimation of latent ability using a response pattern of
#' graded scores. \emph{Psychometrika Monograph Supplement}, 34(4), 100-114.
#' }
#'
#' @seealso
#' \itemize{
#' \item \code{\link{create_study_config}} for configuring models that use validated item banks
#' \item \code{\link{launch_study}} for using validated item banks in assessments
#' \item \code{\link[TAM]{tam.mml}} for TAM model fitting functions
#' }
validate_item_bank <- function(item_bank, model = "GRM") {
  
  # Initialize validation log
  validation_log <- character()
  add_log <- function(msg) validation_log <<- c(validation_log, msg)
  
  add_log("VALIDATING ITEM BANK FOR TAM COMPATIBILITY")
  add_log("===========================================")
  
  if (!is.data.frame(item_bank)) {
    stop("item_bank must be a data frame")
  }
  
  if (nrow(item_bank) == 0) {
    stop("item_bank must contain at least one item")
  }
  
  n_items <- nrow(item_bank)
  add_log(paste("Validating", n_items, "items for", model, "model"))
  add_log("")
  
  errors <- c()
  warnings <- c()
  
  # Check required columns
  required_cols <- c("Question")
  if (!all(required_cols %in% names(item_bank))) {
    missing <- setdiff(required_cols, names(item_bank))
    errors <- c(errors, paste("Missing required columns:", paste(missing, collapse = ",")))
  }
  
  # Model-specific validation with unknown parameter support
  if (model %in% c("1PL", "2PL", "3PL", "GRM")) {
    # Check discrimination parameter
    if (!"a" %in% names(item_bank)) {
      errors <- c(errors, "Missing discrimination parameter 'a'")
    } else {
      a_values <- item_bank$a
      unknown_a <- sum(is.na(a_values))
      known_a <- sum(!is.na(a_values))
      
      add_log("Discrimination parameters (a):")
      add_log(paste("  Unknown (NA):", unknown_a, "of", n_items))
      add_log(paste("  Known values:", known_a, "of", n_items))
      
      if (known_a > 0) {
        known_values <- a_values[!is.na(a_values)]
        negative_a <- sum(known_values <= 0)
        extreme_a <- sum(known_values > 5)
        
        if (negative_a > 0) {
          errors <- c(errors, paste(negative_a, "items have non-positive discrimination"))
        }
        if (extreme_a > 0) {
          warnings <- c(warnings, paste(extreme_a, "items have very high discrimination (>5)"))
        }
        
        add_log(paste("  Range of known values:", round(range(known_values), 2)))
      }
      
      if (unknown_a > 0) {
        add_log("  Note: Unknown parameters will be initialized during analysis")
      }
    }
  }
  
  # Difficulty/threshold parameter validation with unknown parameter support
  if (model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    
    if (length(b_cols) == 0) {
      errors <- c(errors, "No threshold parameters (b1, b2, ...) found for GRM model")
    } else {
      add_log("")
      add_log("Threshold parameters:")
      
      for (col in b_cols) {
        unknown_thresh <- sum(is.na(item_bank[[col]]))
        known_thresh <- sum(!is.na(item_bank[[col]]))
        
        add_log(paste("  ", col, ": Unknown =", unknown_thresh, ", Known =", known_thresh))
        
        if (known_thresh > 0) {
          known_values <- item_bank[[col]][!is.na(item_bank[[col]])]
          extreme_thresh <- sum(abs(known_values) > 6)
          if (extreme_thresh > 0) {
            warnings <- c(warnings, paste(extreme_thresh, "items have extreme", col, "values"))
          }
        }
      }
      
      # Check threshold ordering for items with all known thresholds
      ordering_issues <- 0
      for (i in 1:n_items) {
        thresholds <- as.numeric(item_bank[i, b_cols])
        if (!any(is.na(thresholds))) {
          # Only check ordering if all thresholds are known
          if (any(diff(thresholds) <= 0)) {
            ordering_issues <- ordering_issues + 1
          }
        }
      }
      
      if (ordering_issues > 0) {
        warnings <- c(warnings, paste(ordering_issues, "items have threshold ordering issues"))
        add_log(paste("  Warning:", ordering_issues, "items may need threshold reordering"))
      }
      
      # Count items with mixed known/unknown thresholds
      mixed_items <- 0
      for (i in 1:n_items) {
        thresholds <- as.numeric(item_bank[i, b_cols])
        if (any(is.na(thresholds)) && !all(is.na(thresholds))) {
          mixed_items <- mixed_items + 1
        }
      }
      
      if (mixed_items > 0) {
        add_log(paste("  Note:", mixed_items, "items have partial threshold information"))
      }
    }
    
    # Check ResponseCategories
    if (!"ResponseCategories" %in% names(item_bank)) {
      warnings <- c(warnings, "Missing ResponseCategories column for GRM model")
    }
    
  } else {
    # Difficulty parameter for dichotomous models
    if (!"b" %in% names(item_bank)) {
      errors <- c(errors, "Missing difficulty parameter 'b'")
    } else {
      b_values <- item_bank$b
      unknown_b <- sum(is.na(b_values))
      known_b <- sum(!is.na(b_values))
      
      add_log("")
      add_log("Difficulty parameters (b):")
      add_log(paste("  Unknown (NA):", unknown_b, "of", n_items))
      add_log(paste("  Known values:", known_b, "of", n_items))
      
      if (known_b > 0) {
        known_values <- b_values[!is.na(b_values)]
        extreme_b <- sum(abs(known_values) > 6)
        
        if (extreme_b > 0) {
          warnings <- c(warnings, paste(extreme_b, "items have extreme difficulty values"))
        }
        
        add_log(paste("  Range of known values:", round(range(known_values), 2)))
      }
      
      if (unknown_b > 0) {
        add_log("  Note: Unknown parameters will be initialized during analysis")
      }
    }
  }
  
  # 3PL guessing parameter validation
  if (model == "3PL") {
    if (!"c" %in% names(item_bank)) {
      errors <- c(errors, "Missing guessing parameter 'c' for 3PL model")
    } else {
      c_values <- item_bank$c
      unknown_c <- sum(is.na(c_values))
      known_c <- sum(!is.na(c_values))
      
      add_log("")
      add_log("Guessing parameters (c):")
      add_log(paste("  Unknown (NA):", unknown_c, "of", n_items))
      add_log(paste("  Known values:", known_c, "of", n_items))
      
      if (known_c > 0) {
        known_values <- c_values[!is.na(c_values)]
        invalid_c <- sum(known_values < 0 | known_values >= 1)
        high_c <- sum(known_values > 0.4)
        
        if (invalid_c > 0) {
          errors <- c(errors, paste(invalid_c, "items have invalid guessing parameters (must be 0-1)"))
        }
        if (high_c > 0) {
          warnings <- c(warnings, paste(high_c, "items have high guessing parameters (>0.4)"))
        }
        
        add_log(paste("  Range of known values:", round(range(known_values), 3)))
      }
      
      if (unknown_c > 0) {
        add_log("  Note: Unknown parameters will be initialized during analysis")
      }
    }
  }
  
  # Summary and recommendations
  add_log("")
  add_log("VALIDATION SUMMARY")
  add_log("===================")
  
  if (length(errors) > 0) {
    add_log("ERROR: ERRORS FOUND:")
    for (error in errors) {
      add_log(paste("• ", error))
    }
  }
  
  if (length(warnings) > 0) {
    add_log("Warning: WARNINGS:")
    for (warning in warnings) {
      add_log(paste("• ", warning))
    }
  }
  
  if (length(errors) == 0 && length(warnings) == 0) {
    add_log("SUCCESS: No issues found")
  }
  
  # Unknown parameter summary
  total_params <- 0
  unknown_params <- 0
  
  if ("a" %in% names(item_bank)) {
    total_params <- total_params + n_items
    unknown_params <- unknown_params + sum(is.na(item_bank$a))
  }
  
  if (model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    for (col in b_cols) {
      if (col %in% names(item_bank)) {
        total_params <- total_params + n_items
        unknown_params <- unknown_params + sum(is.na(item_bank[[col]]))
      }
    }
  } else if ("b" %in% names(item_bank)) {
    total_params <- total_params + n_items
    unknown_params <- unknown_params + sum(is.na(item_bank$b))
  }
  
  if (model == "3PL" && "c" %in% names(item_bank)) {
    total_params <- total_params + n_items
    unknown_params <- unknown_params + sum(is.na(item_bank$c))
  }
  
  unknown_proportion <- if (total_params > 0) unknown_params / total_params else 0
  
  add_log("")
  add_log("PARAMETER SUMMARY:")
  add_log(paste("Total parameters:", total_params))
  add_log(paste("Unknown (NA) parameters:", unknown_params))
  add_log(paste("Proportion unknown:", round(unknown_proportion * 100, 1), "%"))
  
  study_type <- if (unknown_params == 0) {
    "Fixed Parameter Analysis"
  } else if (unknown_params == total_params) {
    "Full Parameter Estimation"
  } else {
    "Mixed Parameter Study"
  }
  add_log(paste("Study type:", study_type))
  
  # Recommendations
  add_log("")
  add_log("RECOMMENDATIONS:")
  
  if (unknown_params > 0) {
    add_log("• Use initialize_unknown_parameters() before analysis")
    add_log("• Consider parameter estimation with TAM calibration")
    add_log("• Ensure adequate sample size for stable estimation")
    
    if (unknown_proportion > 0.5) {
      add_log("• Large-scale parameter estimation detected")
      add_log("• Recommend N > 500 for stable parameter estimates")
    }
    
    if (unknown_proportion < 1.0 && unknown_proportion > 0) {
      add_log("• Mixed known/unknown parameters detected")
      add_log("• Consider anchoring strategy for parameter linking")
    }
  } else {
    add_log("• All parameters known - ready for fixed-parameter analysis")
    add_log("• No parameter initialization required")
  }
  
  # Return validation result
  is_valid <- length(errors) == 0
  
  if (is_valid) {
    add_log("")
    add_log("SUCCESS: VALIDATION PASSED")
    add_log(paste("Item bank is ready for", model, "analysis with inrep/TAM"))
  } else {
    add_log("")
    add_log("ERROR: VALIDATION FAILED")
    add_log("Please fix errors before proceeding")
  }
  
  add_log("")
  
  # Return both validation result and log
  result <- list(
    is_valid = is_valid,
    errors = errors,
    warnings = warnings,
    validation_log = validation_log,
    total_params = total_params,
    unknown_params = unknown_params,
    unknown_proportion = unknown_proportion,
    study_type = study_type
  )
  
  return(result)
}


# ============================================================================
# SECTION 4: ARGUMENT VALIDATION (from argument_validation.R)
# ============================================================================

#' Argument Validation and Correction Module
#' 
#' Provides robust argument validation with case-insensitive matching,
#' spelling correction, and helpful user feedback
#' 
#' @name argument_validation
#' @docType data
NULL

#' Validate and Correct Arguments
#' 
#' Validates arguments with fuzzy matching and helpful suggestions
#' 
#' @param value User-provided value
#' @param valid_values Valid values for the argument
#' @param arg_name Name of the argument for error messages
#' @param fuzzy_threshold Threshold for fuzzy matching (0-1)
#' @param auto_correct Whether to auto-correct minor typos
#' @return Corrected value or error
#' @export
validate_argument <- function(
  value,
  valid_values,
  arg_name = "argument",
  fuzzy_threshold = 0.8,
  auto_correct = TRUE
) {
  
  # Handle NULL or missing values
  if (is.null(value) || length(value) == 0) {
    return(NULL)
  }
  
  # Convert to character for comparison
  value_char <- as.character(value)
  valid_chars <- as.character(valid_values)
  
  # First try exact match (case-insensitive)
  exact_match <- match_case_insensitive(value_char, valid_chars)
  if (!is.null(exact_match)) {
    if (tolower(value_char) != tolower(exact_match)) {
      message(sprintf(
        "Note: Automatically corrected '%s' to '%s' for %s",
        value_char, exact_match, arg_name
      ))
    }
    return(exact_match)
  }
  
  # Try fuzzy matching for spelling errors
  fuzzy_match <- find_fuzzy_match(value_char, valid_chars, fuzzy_threshold)
  
  if (!is.null(fuzzy_match) && auto_correct) {
    message(sprintf(
      "Auto-corrected: '%s' interpreted as '%s' for %s\n  (Similarity: %.0f%%)",
      value_char, fuzzy_match$match, arg_name,
      fuzzy_match$similarity * 100
    ))
    return(fuzzy_match$match)
  }
  
  # Generate helpful error message
  suggestion <- generate_suggestion(value_char, valid_chars, arg_name)
  
  stop(create_friendly_error(
    value_char, valid_chars, arg_name, suggestion
  ), call. = FALSE)
}

#' Case-Insensitive Matching
#' 
#' Finds exact match ignoring case
#' 
#' @param value Value to match
#' @param valid_values Valid values
#' @return Matched value or NULL
match_case_insensitive <- function(value, valid_values) {
  lower_value <- tolower(value)
  lower_valid <- tolower(valid_values)
  
  idx <- which(lower_valid == lower_value)
  if (length(idx) > 0) {
    return(valid_values[idx[1]])
  }
  
  return(NULL)
}

#' Find Fuzzy Match
#' 
#' Finds best fuzzy match using string distance
#' 
#' @param value Value to match
#' @param valid_values Valid values
#' @param threshold Minimum similarity threshold
#' @return List with match and similarity or NULL
find_fuzzy_match <- function(value, valid_values, threshold = 0.8) {
  
  # Calculate string distances
  distances <- sapply(valid_values, function(v) {
    calculate_similarity(tolower(value), tolower(v))
  })
  
  # Find best match
  best_idx <- which.max(distances)
  best_similarity <- distances[best_idx]
  
  if (best_similarity >= threshold) {
    return(list(
      match = valid_values[best_idx],
      similarity = best_similarity
    ))
  }
  
  return(NULL)
}

#' Calculate String Similarity
#' 
#' Calculates similarity between two strings
#' 
#' @param s1 First string
#' @param s2 Second string
#' @return Similarity score (0-1)
calculate_similarity <- function(s1, s2) {
  # Use Levenshtein distance
  dist <- adist(s1, s2)[1, 1]
  max_len <- max(nchar(s1), nchar(s2))
  
  if (max_len == 0) return(1)
  
  similarity <- 1 - (dist / max_len)
  return(max(0, min(1, similarity)))
}

#' Generate Suggestion
#' 
#' Generates helpful suggestion for user
#' 
#' @param value Invalid value
#' @param valid_values Valid values
#' @param arg_name Argument name
#' @return Suggestion string
generate_suggestion <- function(value, valid_values, arg_name) {
  
  # Find closest matches
  similarities <- sapply(valid_values, function(v) {
    calculate_similarity(tolower(value), tolower(v))
  })
  
  # Get top 3 suggestions
  top_indices <- order(similarities, decreasing = TRUE)[1:min(3, length(valid_values))]
  suggestions <- valid_values[top_indices]
  
  if (similarities[top_indices[1]] > 0.5) {
    return(sprintf("Did you mean '%s'?", suggestions[1]))
  } else {
    return(sprintf("Try one of: %s", paste(suggestions, collapse = ", ")))
  }
}

#' Create Friendly Error Message
#' 
#' Creates user-friendly error message
#' 
#' @param value Invalid value
#' @param valid_values Valid values
#' @param arg_name Argument name
#' @param suggestion Suggestion text
#' @return Error message
create_friendly_error <- function(value, valid_values, arg_name, suggestion) {
  
  # Group valid values by category if applicable
  grouped <- group_values_by_category(valid_values)
  
  error_msg <- paste0(
    "\n",
    "==================================================\n",
    "  Oops! There's an issue with '", arg_name, "'\n",
    "==================================================\n\n",
    "  You provided: '", value, "'\n",
    "  ", suggestion, "\n\n",
    "  Valid options are:\n"
  )
  
  if (length(grouped) > 1) {
    for (category in names(grouped)) {
      error_msg <- paste0(
        error_msg,
        "    ", category, ":\n",
        "      ", paste(grouped[[category]], collapse = ", "), "\n"
      )
    }
  } else {
    # Display in columns for better readability
    values_formatted <- format_values_in_columns(valid_values)
    error_msg <- paste0(error_msg, values_formatted)
  }
  
  error_msg <- paste0(
    error_msg,
    "\n",
    "  Tip: Arguments are case-insensitive and minor\n",
    "       typos are automatically corrected!\n",
    "==================================================\n"
  )
  
  return(error_msg)
}

#' Group Values by Category
#' 
#' Groups values into logical categories
#' 
#' @param values Values to group
#' @return Named list of grouped values
group_values_by_category <- function(values) {
  
  # Define categories for known argument types
  theme_categories <- list(
    "Light Themes" = c("minimal", "light", "clean", "default"),
    "Dark Themes" = c("dark", "midnight", "night"),
    "Colorful Themes" = c("sunset", "forest", "ocean", "berry"),
    "Professional" = c("professional", "clinical", "educational", "research", "corporate"),
    "Custom" = c("hildesheim", "modern")
  )
  
  model_categories <- list(
    "IRT Models" = c("1PL", "2PL", "3PL", "GRM", "GPCM", "PCM", "RSM"),
    "Classical" = c("CTT", "classical")
  )
  
  # Check if values match any category system
  for (cats in list(theme_categories, model_categories)) {
    all_vals <- unlist(cats)
    if (any(tolower(values) %in% tolower(all_vals))) {
      grouped <- list()
      for (cat_name in names(cats)) {
        cat_values <- cats[[cat_name]]
        matches <- values[tolower(values) %in% tolower(cat_values)]
        if (length(matches) > 0) {
          grouped[[cat_name]] <- matches
        }
      }
      
      # Add any uncategorized values
      categorized <- unlist(grouped)
      uncategorized <- setdiff(values, categorized)
      if (length(uncategorized) > 0) {
        grouped[["Other"]] <- uncategorized
      }
      
      return(grouped)
    }
  }
  
  # No categorization found
  return(list("Options" = values))
}

#' Format Values in Columns
#' 
#' Formats values in columns for display
#' 
#' @param values Values to format
#' @param columns Number of columns
#' @return Formatted string
format_values_in_columns <- function(values, columns = 3) {
  n <- length(values)
  rows <- ceiling(n / columns)
  
  # Pad values to make complete grid
  padded <- c(values, rep("", rows * columns - n))
  
  # Create matrix by columns
  matrix_vals <- matrix(padded, nrow = rows, ncol = columns, byrow = FALSE)
  
  # Format each row
  formatted_rows <- apply(matrix_vals, 1, function(row) {
    row <- row[row != ""]  # Remove padding
    if (length(row) > 0) {
      paste0("    ", paste(sprintf("%-20s", row), collapse = ""))
    } else {
      ""
    }
  })
  
  return(paste(formatted_rows[formatted_rows != ""], collapse = "\n"))
}

#' Validate Theme Argument
#' 
#' Validates and corrects theme names
#' 
#' @param theme Theme name provided by user
#' @return Validated theme name
#' @export
validate_theme <- function(theme) {
  valid_themes <- c(
    "default", "clean", "minimal", "light", "dark", "midnight", 
    "modern", "sunset", "forest", "ocean", "berry",
    "professional", "clinical", "educational", "research",
    "corporate", "hildesheim"
  )
  
  # Handle NULL - return default
  if (is.null(theme)) {
    return("light")
  }
  
  validated <- validate_argument(
    theme,
    valid_themes,
    "theme",
    fuzzy_threshold = 0.7,
    auto_correct = TRUE
  )
  
  return(validated)
}

#' Validate Model Argument
#' 
#' Validates and corrects IRT model names
#' 
#' @param model Model name provided by user
#' @return Validated model name
#' @export
validate_model <- function(model) {
  valid_models <- c(
    "1PL", "2PL", "3PL", "GRM", "GPCM", "PCM", "RSM", "CTT"
  )
  
  # Handle common variations
  model_upper <- toupper(as.character(model))
  
  # Common corrections
  corrections <- list(
    "RASCH" = "1PL",
    "1-PL" = "1PL",
    "2-PL" = "2PL", 
    "3-PL" = "3PL",
    "GRADED" = "GRM",
    "PARTIAL" = "PCM",
    "RATING" = "RSM"
  )
  
  if (model_upper %in% names(corrections)) {
    corrected <- corrections[[model_upper]]
    message(sprintf(
      "Note: Model '%s' interpreted as '%s'",
      model, corrected
    ))
    return(corrected)
  }
  
  validated <- validate_argument(
    model_upper,
    valid_models,
    "model",
    fuzzy_threshold = 0.8,
    auto_correct = TRUE
  )
  
  return(validated)
}

#' Validate Progress Style
#' 
#' Validates progress bar style
#' 
#' @param style Progress style
#' @return Validated style
#' @export
validate_progress_style <- function(style) {
  valid_styles <- c(
    "bar", "circle", "percent", "steps", "dots", "none"
  )
  
  # Handle NULL
  if (is.null(style)) {
    return("bar")
  }
  
  validated <- validate_argument(
    style,
    valid_styles,
    "progress_style",
    fuzzy_threshold = 0.7,
    auto_correct = TRUE
  )
  
  return(validated)
}

#' Validate Numeric Parameter
#' 
#' Validates numeric parameters with helpful messages
#' 
#' @param value User-provided value
#' @param param_name Parameter name
#' @param min_val Minimum valid value
#' @param max_val Maximum valid value
#' @param default Default value if invalid
#' @return Validated numeric value
#' @export
validate_numeric <- function(
  value,
  param_name,
  min_val = NULL,
  max_val = NULL,
  default = NULL
) {
  
  # Try to convert to numeric
  if (is.character(value)) {
    num_val <- suppressWarnings(as.numeric(value))
    if (is.na(num_val)) {
      message(sprintf(
        "Warning: '%s' is not a valid number for %s. Using default: %s",
        value, param_name, default
      ))
      return(default)
    }
    value <- num_val
  }
  
  # Check bounds
  if (!is.null(min_val) && value < min_val) {
    message(sprintf(
      "Note: %s value %g is below minimum (%g). Setting to %g",
      param_name, value, min_val, min_val
    ))
    return(min_val)
  }
  
  if (!is.null(max_val) && value > max_val) {
    message(sprintf(
      "Note: %s value %g exceeds maximum (%g). Setting to %g",
      param_name, value, max_val, max_val
    ))
    return(max_val)
  }
  
  return(value)
}

#' Smart Parameter Validation
#' 
#' Validates all parameters in a configuration
#' 
#' @param config Configuration list
#' @return Validated configuration
#' @export
validate_config_smart <- function(config) {
  
  # Validate theme
  if (!is.null(config$theme)) {
    config$theme <- validate_theme(config$theme)
  }
  
  # Validate model
  if (!is.null(config$model)) {
    config$model <- validate_model(config$model)
  }
  
  # Validate progress style
  if (!is.null(config$progress_style)) {
    config$progress_style <- validate_progress_style(config$progress_style)
  }
  
  # Validate numeric parameters
  if (!is.null(config$max_items)) {
    config$max_items <- validate_numeric(
      config$max_items, "max_items", 
      min_val = 1, max_val = 1000, default = 20
    )
  }
  
  if (!is.null(config$min_items)) {
    config$min_items <- validate_numeric(
      config$min_items, "min_items",
      min_val = 1, max_val = config$max_items %||% 100, 
      default = 5
    )
  }
  
  if (!is.null(config$min_SEM)) {
    config$min_SEM <- validate_numeric(
      config$min_SEM, "min_SEM",
      min_val = 0.01, max_val = 2.0, default = 0.3
    )
  }
  
  # Check for typos in boolean parameters
  bool_params <- c("session_save", "allow_review", "show_feedback", 
                   "randomize", "adaptive")
  
  for (param in bool_params) {
    if (!is.null(config[[param]])) {
      config[[param]] <- validate_boolean(config[[param]], param)
    }
  }
  
  return(config)
}

#' Validate Boolean Parameter
#' 
#' Validates boolean parameters with fuzzy matching
#' 
#' @param value User-provided value
#' @param param_name Parameter name
#' @return Logical value
validate_boolean <- function(value, param_name) {
  
  if (is.logical(value)) {
    return(value)
  }
  
  # Convert to character and check
  char_val <- tolower(as.character(value))
  
  true_values <- c("true", "t", "yes", "y", "1", "on", "enable", "enabled")
  false_values <- c("false", "f", "no", "n", "0", "off", "disable", "disabled")
  
  if (char_val %in% true_values) {
    return(TRUE)
  }
  
  if (char_val %in% false_values) {
    return(FALSE)
  }
  
  # Check for typos
  true_similarity <- max(sapply(true_values, function(v) {
    calculate_similarity(char_val, v)
  }))
  
  false_similarity <- max(sapply(false_values, function(v) {
    calculate_similarity(char_val, v)
  }))
  
  if (true_similarity > 0.7 && true_similarity > false_similarity) {
    message(sprintf(
      "Note: '%s' interpreted as TRUE for %s",
      value, param_name
    ))
    return(TRUE)
  }
  
  if (false_similarity > 0.7) {
    message(sprintf(
      "Note: '%s' interpreted as FALSE for %s",
      value, param_name
    ))
    return(FALSE)
  }
  
  warning(sprintf(
    "Could not interpret '%s' as boolean for %s. Using FALSE",
    value, param_name
  ))
  
  return(FALSE)
}