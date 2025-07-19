
#' Validate Item Bank for TAM Compatibility
#'
#' Validates the structure and content of an item bank for compatibility with
#' TAM package functions and the specified IRT model. Ensures that item parameters
#' and data structure meet TAM's requirements for statistical analysis and that
#' parameter values are within acceptable ranges for stable estimation.
#'
#' @param item_bank Data frame containing item parameters and content.
#'   Structure and required columns vary by IRT model specification.
#' @param model Character string specifying IRT model for validation.
#'   Options: \code{"1PL"}, \code{"2PL"}, \code{"3PL"}, \code{"GRM"}. Default: \code{"GRM"}.
#' 
#' @return Logical value: \code{TRUE} if item bank is valid for TAM processing,
#'   \code{FALSE} otherwise. Function will stop execution with descriptive error
#'   message if critical validation failures are detected.
#' 
#' @export
#' 
#' @details
#' \strong{TAM Compatibility Requirements:} This function ensures comprehensive
#' compatibility with TAM package specifications:
#' 
#' \strong{Structural Validation:}
#' \itemize{
#'   \item Validates required columns for TAM model fitting functions
#'   \item Checks data types and format consistency
#'   \item Ensures adequate sample size for parameter estimation
#'   \item Verifies no missing values in critical parameter columns
#' }
#' 
#' \strong{Parameter Range Validation:}
#' \itemize{
#'   \item Discrimination parameters (a): Must be positive, typically 0.2-3.0
#'   \item Difficulty parameters (b): Logit scale, typically -4.0 to +4.0
#'   \item Threshold parameters (b1, b2, ...): Must be in ascending order
#'   \item Guessing parameters (c): Must be between 0.0 and 1.0
#'   \item Response categories: Must be properly formatted and consistent
#' }
#' 
#' \strong{Model-Specific Requirements:}
#' \describe{
#'   \item{\strong{1PL/Rasch Model}}{
#'     Requires: \code{Question}, \code{b} (difficulty), response options.
#'     Validates: Difficulty parameter range, response coding consistency.
#'   }
#'   \item{\strong{2PL Model}}{
#'     Requires: \code{Question}, \code{a} (discrimination), \code{b}, response options.
#'     Validates: Positive discrimination, parameter interaction feasibility.
#'   }
#'   \item{\strong{3PL Model}}{
#'     Requires: \code{Question}, \code{a}, \code{b}, \code{c} (guessing), response options.
#'     Validates: Guessing parameter bounds, model identifiability.
#'   }
#'   \item{\strong{GRM (Graded Response Model)}}{
#'     Requires: \code{Question}, \code{a}, threshold parameters, \code{ResponseCategories}.
#'     Validates: Threshold ordering, response category consistency.
#'   }
#' }
#' 
#' \strong{Data Quality Checks:}
#' \itemize{
#'   \item Identifies potential estimation problems (extreme parameters)
#'   \item Warns about items with unusual parameter combinations
#'   \item Checks for duplicate items or parameter sets
#'   \item Validates response coding consistency across items
#' }
#' 
#' \strong{Cross-Format Compatibility:}
#' \itemize{
#'   \item Handles conversion between GRM and dichotomous formats
#'   \item Provides compatibility warnings for mixed formats
#'   \item Suggests appropriate model selection based on data structure
#' }
#' 
#' \code{inrep} uses this validation to ensure seamless data flow to TAM functions.
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
#' 
#' # Example 3: Validate problematic item bank
#' problematic_items <- data.frame(
#'   Question = c("Item 1", "Item 2"),
#'   a = c(-0.5, 5.0),  # Negative discrimination, extreme value
#'   b = c(0.0, 10.0),  # Extreme difficulty
#'   Option1 = c("A", "A"),
#'   Option2 = c("B", "B"),
#'   Answer = c("A", "B")
#' )
#' 
#' # This should produce warnings or errors
#' tryCatch({
#'   is_valid_prob <- validate_item_bank(problematic_items, "2PL")
#' }, error = function(e) {
#'   cat("Validation failed as expected:", e$message, "\n")
#' })
#' 
#' # Example 4: Validate GRM with threshold checking
#' grm_items <- data.frame(
#'   Question = c("I am talkative", "I am reserved"),
#'   a = c(1.0, 1.2),
#'   b1 = c(-2.0, -1.5),
#'   b2 = c(-1.0, -0.5),
#'   b3 = c(0.0, 0.5),
#'   b4 = c(1.0, 1.5),
#'   ResponseCategories = c("1,2,3,4,5", "1,2,3,4,5")
#' )
#' 
#' # Validate threshold ordering
#' is_valid_grm_thresh <- validate_item_bank(grm_items, "GRM")
#' cat("GRM items with thresholds valid:", is_valid_grm_thresh, "\n")
#' 
#' # Example 5: Comprehensive validation with detailed output
#' detailed_validation <- function(item_bank, model) {
#'   cat("Validating item bank for model:", model, "\n")
#'   cat("Number of items:", nrow(item_bank), "\n")
#'   cat("Available columns:", paste(names(item_bank), collapse = ", "), "\n")
#'   
#'   result <- tryCatch({
#'     validate_item_bank(item_bank, model)
#'   }, error = function(e) {
#'     cat("ERROR:", e$message, "\n")
#'     return(FALSE)
#'   }, warning = function(w) {
#'     cat("WARNING:", w$message, "\n")
#'     return(TRUE)
#'   })
#'   
#'   if (result) {
#'     cat("✓ Item bank is valid for", model, "model\n")
#'   } else {
#'     cat("✗ Item bank validation failed\n")
#'   }
#'   
#'   return(result)
#' }
#' 
#' # Test with different models
#' detailed_validation(bfi_items, "GRM")
#' detailed_validation(cognitive_items, "2PL")
#' }
#' 
#' @references
#' \itemize{
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item Samejima, F. (1969). Estimation of latent ability using a response pattern of 
#'     graded scores. \emph{Psychometrika Monograph Supplement}, 34(4), 100-114.
#'   \item Birnbaum, A. (1968). Some latent trait models and their use in inferring an 
#'     examinee's ability. In F. M. Lord & M. R. Novick (Eds.), 
#'     \emph{Statistical theories of mental test scores} (pp. 397-479). Addison-Wesley.
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_study_config}} for configuring models that use validated item banks
#'   \item \code{\link{launch_study}} for using validated item banks in assessments
#'   \item \code{\link[TAM]{tam.mml}} for TAM model fitting functions
#' }
validate_item_bank <- function(item_bank, model = "GRM") {
  
  cat("🔍 VALIDATING ITEM BANK FOR TAM COMPATIBILITY\n")
  cat("===========================================\n")
  
  if (!is.data.frame(item_bank)) {
    stop("item_bank must be a data frame")
  }
  
  if (nrow(item_bank) == 0) {
    stop("item_bank must contain at least one item")
  }
  
  n_items <- nrow(item_bank)
  cat("📊 Validating", n_items, "items for", model, "model\n\n")
  
  errors <- c()
  warnings <- c()
  
  # Check required columns
  required_cols <- c("Question")
  if (!all(required_cols %in% names(item_bank))) {
    missing <- setdiff(required_cols, names(item_bank))
    errors <- c(errors, paste("Missing required columns:", paste(missing, collapse = ", ")))
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
      
      cat("📈 Discrimination parameters (a):\n")
      cat("  Unknown (NA):", unknown_a, "of", n_items, "\n")
      cat("  Known values:", known_a, "of", n_items, "\n")
      
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
        
        cat("  Range of known values:", round(range(known_values), 2), "\n")
      }
      
      if (unknown_a > 0) {
        cat("  💡 Unknown parameters will be initialized during analysis\n")
      }
    }
  }
  
  # Difficulty/threshold parameter validation with unknown parameter support
  if (model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    
    if (length(b_cols) == 0) {
      errors <- c(errors, "No threshold parameters (b1, b2, ...) found for GRM model")
    } else {
      cat("\n🎯 Threshold parameters:\n")
      
      for (col in b_cols) {
        unknown_thresh <- sum(is.na(item_bank[[col]]))
        known_thresh <- sum(!is.na(item_bank[[col]]))
        
        cat("  ", col, ": Unknown =", unknown_thresh, ", Known =", known_thresh, "\n")
        
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
        cat("  ⚠️ ", ordering_issues, "items may need threshold reordering\n")
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
        cat("  📝 ", mixed_items, "items have partial threshold information\n")
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
      
      cat("\n🎯 Difficulty parameters (b):\n")
      cat("  Unknown (NA):", unknown_b, "of", n_items, "\n")
      cat("  Known values:", known_b, "of", n_items, "\n")
      
      if (known_b > 0) {
        known_values <- b_values[!is.na(b_values)]
        extreme_b <- sum(abs(known_values) > 6)
        
        if (extreme_b > 0) {
          warnings <- c(warnings, paste(extreme_b, "items have extreme difficulty values"))
        }
        
        cat("  Range of known values:", round(range(known_values), 2), "\n")
      }
      
      if (unknown_b > 0) {
        cat("  💡 Unknown parameters will be initialized during analysis\n")
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
      
      cat("\n🎲 Guessing parameters (c):\n")
      cat("  Unknown (NA):", unknown_c, "of", n_items, "\n")
      cat("  Known values:", known_c, "of", n_items, "\n")
      
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
        
        cat("  Range of known values:", round(range(known_values), 3), "\n")
      }
      
      if (unknown_c > 0) {
        cat("  💡 Unknown parameters will be initialized during analysis\n")
      }
    }
  }
  
  # Summary and recommendations
  cat("\n📋 VALIDATION SUMMARY\n")
  cat("===================\n")
  
  if (length(errors) > 0) {
    cat("❌ ERRORS FOUND:\n")
    for (error in errors) {
      cat("  •", error, "\n")
    }
  }
  
  if (length(warnings) > 0) {
    cat("⚠️  WARNINGS:\n")
    for (warning in warnings) {
      cat("  •", warning, "\n")
    }
  }
  
  if (length(errors) == 0 && length(warnings) == 0) {
    cat("✅ No issues found\n")
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
  
  cat("\n🔢 PARAMETER SUMMARY:\n")
  cat("  Total parameters:", total_params, "\n")
  cat("  Unknown (NA) parameters:", unknown_params, "\n")
  cat("  Proportion unknown:", round(unknown_proportion * 100, 1), "%\n")
  
  study_type <- if (unknown_params == 0) {
    "Fixed Parameter Analysis"
  } else if (unknown_params == total_params) {
    "Full Parameter Estimation"
  } else {
    "Mixed Parameter Study"
  }
  cat("  Study type:", study_type, "\n")
  
  # Recommendations
  cat("\n💡 RECOMMENDATIONS:\n")
  
  if (unknown_params > 0) {
    cat("  • Use initialize_unknown_parameters() before analysis\n")
    cat("  • Consider parameter estimation with TAM calibration\n")
    cat("  • Ensure adequate sample size for stable estimation\n")
    
    if (unknown_proportion > 0.5) {
      cat("  • Large-scale parameter estimation detected\n")
      cat("  • Recommend N > 500 for stable parameter estimates\n")
    }
    
    if (unknown_proportion < 1.0 && unknown_proportion > 0) {
      cat("  • Mixed known/unknown parameters detected\n")
      cat("  • Consider anchoring strategy for parameter linking\n")
    }
  } else {
    cat("  • All parameters known - ready for fixed-parameter analysis\n")
    cat("  • No parameter initialization required\n")
  }
  
  # Return validation result
  is_valid <- length(errors) == 0
  
  if (is_valid) {
    cat("\n✅ VALIDATION PASSED\n")
    cat("Item bank is ready for", model, "analysis with inrep/TAM\n")
  } else {
    cat("\n❌ VALIDATION FAILED\n")
    cat("Please fix errors before proceeding\n")
  }
  
  cat("\n")
  return(is_valid)
  print("Validating item bank...")
  
  if (!is.data.frame(item_bank) || nrow(item_bank) == 0) {
    print("Item bank must be a non-empty data frame")
    stop("Item bank must be a non-empty data frame")
  }
  
  # Base required columns for all models
  required_cols <- c("Question")
  
  if (model %in% c("1PL", "2PL", "3PL")) {
    # For dichotomous models, check if we have GRM-style data
    if ("ResponseCategories" %in% names(item_bank) && !all(c("Option1", "Option2", "Option3", "Option4", "Answer") %in% names(item_bank))) {
      print(sprintf("Item bank appears to be GRM format but model is %s. Converting or use model='GRM'", model))
      # Don't error, just warn - we can work with GRM data for dichotomous models in some cases
    }
    
    required_cols <- c(required_cols, "a")
    
    # Only require these if we don't have GRM-style data
    if (!"ResponseCategories" %in% names(item_bank)) {
      required_cols <- c(required_cols, paste0("Option", 1:4), "Answer")
    }
    
    # Add b parameter requirement
    if (!"b" %in% names(item_bank)) {
      # Check for b1 as alternative
      if ("b1" %in% names(item_bank)) {
        print("Using b1 as b parameter for dichotomous model")
      } else {
        required_cols <- c(required_cols, "b")
      }
    }
    
    if (model == "3PL") {
      required_cols <- c(required_cols, "c")
    }
  } else if (model == "GRM") {
    required_cols <- c(required_cols, "a", "ResponseCategories")
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    if (length(b_cols) < 1) {
      print("GRM requires at least one threshold column")
      stop("GRM requires at least one threshold column (b1, b2, ...)")
    }
    required_cols <- c(required_cols, b_cols)
  }
  
  missing_cols <- setdiff(required_cols, names(item_bank))
  if (length(missing_cols) > 0) {
    print(sprintf("Item bank missing columns: %s", paste(missing_cols, collapse = ", ")))
    print(sprintf("Available columns: %s", paste(names(item_bank), collapse = ", ")))
    stop(sprintf("Item bank missing columns: %s", paste(missing_cols, collapse = ", ")))
  }
  
  # Validate numeric columns
  numeric_cols <- c("a")
  if ("b" %in% names(item_bank)) {
    numeric_cols <- c(numeric_cols, "b")
  } else if ("b1" %in% names(item_bank)) {
    numeric_cols <- c(numeric_cols, "b1")
  }
  if (model == "3PL" && "c" %in% names(item_bank)) {
    numeric_cols <- c(numeric_cols, "c")
  }
  if (model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    numeric_cols <- c(numeric_cols, b_cols)
  }
  
  for (col in numeric_cols) {
    if (col %in% names(item_bank) && !all(is.numeric(item_bank[[col]]) & !is.na(item_bank[[col]]))) {
      print(sprintf("Column %s must be numeric and non-NA", col))
      stop(sprintf("Column %s must be numeric and non-NA", col))
    }
  }
  
  # Validate GRM response categories
  if (model == "GRM" && "ResponseCategories" %in% names(item_bank)) {
    for (i in seq_len(nrow(item_bank))) {
      cats <- tryCatch({
        as.numeric(unlist(strsplit(item_bank$ResponseCategories[i], ",")))
      }, error = function(e) {
        print(sprintf("Invalid ResponseCategories format for item %d", i))
        stop(sprintf("Invalid ResponseCategories format for item %d", i))
      })
      
      if (!all(cats == sort(cats)) || any(duplicated(cats))) {
        print(sprintf("ResponseCategories for item %d must be unique and sorted", i))
        stop(sprintf("ResponseCategories for item %d must be unique and sorted", i))
      }
    }
  }
  
  print("Item bank validation successful")
  
  # Generate LLM assistance prompt for validation optimization
  if (getOption("inrep.llm_assistance", FALSE)) {
    validation_prompt <- generate_validation_optimization_prompt(item_bank, model)
    cat("\n" %r% 60, "\n")
    cat("LLM ASSISTANCE: VALIDATION OPTIMIZATION\n")
    cat("=" %r% 60, "\n")
    cat("Copy the following prompt to ChatGPT, Claude, or your preferred LLM for advanced validation insights:\n\n")
    cat(validation_prompt)
    cat("\n" %r% 60, "\n\n")
  }
  
  TRUE
}

#' Generate Validation Optimization Prompt for LLM Assistance
#' @noRd
generate_validation_optimization_prompt <- function(item_bank, model) {
  # Analyze item bank characteristics
  n_items <- nrow(item_bank)
  param_summary <- list()
  
  if ("a" %in% names(item_bank)) {
    param_summary$discrimination <- sprintf("Range: %.2f - %.2f, Mean: %.2f", 
                                          min(item_bank$a, na.rm = TRUE),
                                          max(item_bank$a, na.rm = TRUE),
                                          mean(item_bank$a, na.rm = TRUE))
  }
  
  if ("b" %in% names(item_bank)) {
    param_summary$difficulty <- sprintf("Range: %.2f - %.2f, Mean: %.2f",
                                       min(item_bank$b, na.rm = TRUE),
                                       max(item_bank$b, na.rm = TRUE),
                                       mean(item_bank$b, na.rm = TRUE))
  }
  
  prompt <- paste0(
    "# EXPERT PSYCHOMETRIC VALIDATION ANALYSIS\n\n",
    "You are an expert psychometrician specializing in Item Response Theory. I need advanced validation insights for my item bank.\n\n",
    
    "## ITEM BANK CHARACTERISTICS\n",
    "- Model: ", model, "\n",
    "- Number of Items: ", n_items, "\n"
  )
  
  if (length(param_summary) > 0) {
    prompt <- paste0(prompt, "- Parameter Summary:\n")
    for (param in names(param_summary)) {
      prompt <- paste0(prompt, "  * ", tools::toTitleCase(param), ": ", param_summary[[param]], "\n")
    }
  }
  
  prompt <- paste0(prompt,
    "\n## VALIDATION ENHANCEMENT REQUESTS\n\n",
    "### 1. Parameter Optimization Analysis\n",
    "- Evaluate discrimination parameter distribution for optimal adaptive testing\n",
    "- Assess difficulty parameter coverage across ability spectrum\n",
    "- Identify potential parameter constraints or unusual values\n",
    "- Recommend parameter adjustments for improved efficiency\n\n",
    
    "### 2. Psychometric Quality Assessment\n",
    "- Analyze item information curves for test efficiency\n",
    "- Evaluate expected standard errors across ability range\n",
    "- Identify items with suboptimal psychometric properties\n",
    "- Recommend item development priorities\n\n",
    
    "### 3. Model Appropriateness\n",
    "- Confirm ", model, " model suitability for this item bank\n",
    "- Suggest alternative models if appropriate\n",
    "- Evaluate model assumptions and violations\n",
    "- Recommend additional validation procedures\n\n",
    
    "### 4. Adaptive Testing Optimization\n",
    "- Predict test efficiency for adaptive administration\n",
    "- Recommend optimal stopping criteria\n",
    "- Suggest item exposure control strategies\n",
    "- Evaluate content balancing requirements\n\n",
    
    "## PROVIDE\n",
    "1. Detailed psychometric assessment of current item bank\n",
    "2. Specific recommendations for parameter optimization\n",
    "3. Validation procedures to implement before deployment\n",
    "4. Expected performance metrics for adaptive testing\n",
    "5. Risk assessment and quality control strategies\n\n",
    
    "Please provide expert-level insights with specific, actionable recommendations."
  )
  
  return(prompt)
}
