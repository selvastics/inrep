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
#'   \item \code{\link{create_enhanced_response_report}} for response reporting
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
  
  cat("VALIDATING RESPONSE MAPPING SYSTEM\n")
  cat(paste(rep("=", 50), collapse=""), "\n")
  
  # Step 1: Validate configuration
  cat("1. Configuration validation...\n")
  
  required_fields <- c("model", "response_validation_fun", "scoring_fun")
  missing_fields <- required_fields[!required_fields %in% names(config)]
  
  if (length(missing_fields) > 0) {
    cat("✗ Missing required config fields:", paste(missing_fields, collapse=", "), "\n")
    return(FALSE)
  }
  cat("✓ Configuration valid\n")
  
  # Step 2: Validate item bank structure
  cat("2. Item bank validation...\n")
  
  required_cols <- c("Question")
  if (config$model == "GRM") {
    required_cols <- c(required_cols, "ResponseCategories")
  } else {
    required_cols <- c(required_cols, "Answer")
  }
  
  missing_cols <- required_cols[!required_cols %in% colnames(item_bank)]
  if (length(missing_cols) > 0) {
    cat("✗ Missing required item bank columns:", paste(missing_cols, collapse=", "), "\n")
    return(FALSE)
  }
  cat("✓ Item bank structure valid\n")
  
  # Step 3: Validate response processing
  cat("3. Response processing validation...\n")
  
  validation_results <- sapply(test_responses, function(r) {
    tryCatch({
      config$response_validation_fun(r)
    }, error = function(e) FALSE)
  })
  
  if (!all(validation_results)) {
    cat("✗ Some responses failed validation:", 
        paste(test_responses[!validation_results], collapse=", "), "\n")
    return(FALSE)
  }
  cat("✓ All responses pass validation\n")
  
  # Step 4: Validate scoring
  cat("4. Scoring validation...\n")
  
  scored_responses <- sapply(seq_along(test_responses), function(i) {
    response <- test_responses[i]
    item_idx <- test_items[i]
    correct_answer <- if (config$model == "GRM") NULL else item_bank$Answer[item_idx]
    
    tryCatch({
      config$scoring_fun(response, correct_answer)
    }, error = function(e) {
      cat("Error scoring response", i, ":", e$message, "\n")
      NA
    })
  })
  
  if (any(is.na(scored_responses))) {
    cat("✗ Some responses could not be scored\n")
    return(FALSE)
  }
  cat("✓ All responses scored successfully\n")
  
  # Step 5: Validate reporting table generation
  cat("5. Reporting table validation...\n")
  
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
    
    cat("✓ Reporting table generated successfully\n")
    
    # Step 6: Validate response consistency
    cat("6. Response consistency validation...\n")
    
    # Check that input responses match reported responses
    if (config$model == "GRM") {
      # For GRM, scored responses should match original responses
      consistency_check <- all(scored_responses == test_responses)
    } else {
      # For binary models, check that scoring is consistent
      consistency_check <- all(scored_responses %in% c(0, 1))
    }
    
    if (!consistency_check) {
      cat("✗ Response consistency check failed\n")
      cat("   Input responses:", paste(test_responses, collapse=", "), "\n")
      cat("   Scored responses:", paste(scored_responses, collapse=", "), "\n")
      return(FALSE)
    }
    
    cat("✓ Response consistency validated\n")
    
    # Step 7: Summary report
    cat("\n", paste(rep("=", 50), collapse=""), "\n")
    cat("VALIDATION SUMMARY\n")
    cat(paste(rep("=", 50), collapse=""), "\n")
    
    cat("Input responses:     ", paste(test_responses, collapse=", "), "\n")
    cat("Scored responses:    ", paste(scored_responses, collapse=", "), "\n")
    cat("Items administered:  ", paste(test_items, collapse=", "), "\n")
    cat("Model:               ", config$model, "\n")
    cat("Validation:          ✓ PASSED\n")
    
    cat("\nReporting table preview:\n")
    print(head(dat, 3))
    
    return(TRUE)
    
  }, error = function(e) {
    cat("✗ Error generating reporting table:", e$message, "\n")
    return(FALSE)
  })
}
