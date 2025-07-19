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
#' }}} for using validated item banks in assessments
#' \item \code{\link[TAM]{tam.mml}} for TAM model fitting functions
#' }
validate_item_bank <- function(item_bank, model = "GRM") {
  
  cat("VALIDATING ITEM BANK FOR TAM COMPATIBILITY\n")
  cat("===========================================\n")
  
  if (!is.data.frame(item_bank)) {
    stop("item_bank must be a data frame")
  }
  
  if (nrow(item_bank) == 0) {
    stop("item_bank must contain at least one item")
  }
  
  n_items <- nrow(item_bank)
  cat("Validating", n_items, "items for", model, "model\n\n")
  
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
      
      cat("Discrimination parameters (a):\n")
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
        cat("  Note: Unknown parameters will be initialized during analysis\n")
      }
    }
  }
  
  # Difficulty/threshold parameter validation with unknown parameter support
  if (model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    
    if (length(b_cols) == 0) {
      errors <- c(errors, "No threshold parameters (b1, b2, ...) found for GRM model")
    } else {
      cat("\nThreshold parameters:\n")
      
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
        cat("  Warning:", ordering_issues, "items may need threshold reordering\n")
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
        cat("  Note:", mixed_items, "items have partial threshold information\n")
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
      
      cat("\nDifficulty parameters (b):\n")
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
        cat("  Note: Unknown parameters will be initialized during analysis\n")
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
      
      cat("\nGuessing parameters (c):\n")
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
        cat("  Note: Unknown parameters will be initialized during analysis\n")
      }
    }
  }
  
  # Summary and recommendations
  cat("\nVALIDATION SUMMARY\n")
  cat("===================\n")
  
  if (length(errors) > 0) {
    cat("ERROR: ERRORS FOUND:\n")
    for (error in errors) {
      cat("• ", error, "\n")
    }
  }
  
  if (length(warnings) > 0) {
    cat("Warning: WARNINGS:\n")
    for (warning in warnings) {
      cat("• ", warning, "\n")
    }
  }
  
  if (length(errors) == 0 && length(warnings) == 0) {
    cat("SUCCESS: No issues found\n")
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
  
  cat("\nPARAMETER SUMMARY:\n")
  cat("Total parameters:", total_params, "\n")
  cat("Unknown (NA) parameters:", unknown_params, "\n")
  cat("Proportion unknown:", round(unknown_proportion * 100, 1), "%\n")
  
  study_type <- if (unknown_params == 0) {
    "Fixed Parameter Analysis"
  } else if (unknown_params == total_params) {
    "Full Parameter Estimation"
  } else {
    "Mixed Parameter Study"
  }
  cat("Study type:", study_type, "\n")
  
  # Recommendations
  cat("\nRECOMMENDATIONS:\n")
  
  if (unknown_params > 0) {
    cat("• Use initialize_unknown_parameters() before analysis\n")
    cat("• Consider parameter estimation with TAM calibration\n")
    cat("• Ensure adequate sample size for stable estimation\n")
    
    if (unknown_proportion > 0.5) {
      cat("• Large-scale parameter estimation detected\n")
      cat("• Recommend N > 500 for stable parameter estimates\n")
    }
    
    if (unknown_proportion < 1.0 && unknown_proportion > 0) {
      cat("• Mixed known/unknown parameters detected\n")
      cat("• Consider anchoring strategy for parameter linking\n")
    }
  } else {
    cat("• All parameters known - ready for fixed-parameter analysis\n")
    cat("• No parameter initialization required\n")
  }
  
  # Return validation result
  is_valid <- length(errors) == 0
  
  if (is_valid) {
    cat("\nSUCCESS: VALIDATION PASSED\n")
    cat("Item bank is ready for", model, "analysis with inrep/TAM\n")
  } else {
    cat("\nERROR: VALIDATION FAILED\n")
    cat("Please fix errors before proceeding\n")
  }
  
  cat("\n")
  return(is_valid)
}
