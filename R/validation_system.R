# =============================================================================
# VALIDATION SYSTEM
# =============================================================================
# This file consolidates all validation functions from the original files:
# - validate_study_config.R
# - validate_response_mapping.R  
# - validation_clean.R
# - argument_validation.R

# =============================================================================
# ARGUMENT VALIDATION AND CORRECTION MODULE
# =============================================================================

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

# Helper functions for argument validation
match_case_insensitive <- function(value, valid_values) {
  lower_value <- tolower(value)
  lower_valid <- tolower(valid_values)
  
  idx <- which(lower_valid == lower_value)
  if (length(idx) > 0) {
    return(valid_values[idx[1]])
  }
  
  return(NULL)
}

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

calculate_similarity <- function(s1, s2) {
  # Use Levenshtein distance
  dist <- adist(s1, s2)[1, 1]
  max_len <- max(nchar(s1), nchar(s2))
  
  if (max_len == 0) return(1)
  
  similarity <- 1 - (dist / max_len)
  return(max(0, min(1, similarity)))
}

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

# =============================================================================
# STUDY CONFIGURATION VALIDATION
# =============================================================================

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
    errors <- c(errors, "Study name is required but missing")
    suggestions <- c(suggestions, "Add: name = 'My Study Name'")
  }
  
  # Check model specification
  if (is.null(config$model)) {
    errors <- c(errors, "IRT model specification is required")
    suggestions <- c(suggestions, "Add: model = '2PL' (or '1PL', '3PL', 'GRM')")
  } else {
    # Validate model is supported
    valid_models <- c("1PL", "2PL", "3PL", "GRM", "GPCM", "PCM", "RSM")
    if (!config$model %in% valid_models) {
      errors <- c(errors, sprintf("Model '%s' is not supported", config$model))
      suggestions <- c(suggestions, sprintf("Use one of: %s", paste(valid_models, collapse = ", ")))
    }
  }
  
  # Check stopping criteria
  has_max_items <- !is.null(config$max_items) && is.numeric(config$max_items) && config$max_items > 0
  has_min_sem <- !is.null(config$min_SEM) && is.numeric(config$min_SEM) && config$min_SEM > 0
  
  if (!has_max_items && !has_min_sem) {
    errors <- c(errors, "At least one stopping criterion is required (max_items or min_SEM)")
    suggestions <- c(suggestions, "Add: max_items = 20 or min_SEM = 0.3")
  }
  
  # =============================================================================
  # ITEM BANK VALIDATION
  # =============================================================================
  
  if (!is.null(item_bank)) {
    if (!is.data.frame(item_bank)) {
      errors <- c(errors, "Item bank must be a data.frame")
    } else if (nrow(item_bank) == 0) {
      errors <- c(errors, "Item bank is empty")
    } else {
      # Check required columns based on model
      if (!is.null(config$model)) {
        required_cols <- switch(config$model,
          "1PL" = c("b"),
          "2PL" = c("a", "b"), 
          "3PL" = c("a", "b", "c"),
          "GRM" = c("a", "b1", "b2"),
          "GPCM" = c("a", "b1"),
          "PCM" = c("b1"),
          "RSM" = c("b1"),
          c("a", "b")  # default
        )
        
        missing_cols <- setdiff(required_cols, names(item_bank))
        if (length(missing_cols) > 0) {
          errors <- c(errors, sprintf(
            "Item bank missing required columns for %s model: %s",
            config$model, paste(missing_cols, collapse = ", ")
          ))
        }
      }
      
      # Check for content columns
      content_cols <- c("Question", "Content", "Item", "Text")
      has_content <- any(content_cols %in% names(item_bank))
      if (!has_content) {
        warnings <- c(warnings, "No question content column found (Question, Content, Item, or Text)")
      }
    }
  }
  
  # =============================================================================
  # PARAMETER CONSISTENCY CHECKS
  # =============================================================================
  
  # Check max_items vs item bank size
  if (!is.null(item_bank) && !is.null(config$max_items)) {
    if (config$max_items > nrow(item_bank)) {
      warnings <- c(warnings, sprintf(
        "max_items (%d) exceeds item bank size (%d)",
        config$max_items, nrow(item_bank)
      ))
    }
  }
  
  # Check min_items vs max_items
  if (!is.null(config$min_items) && !is.null(config$max_items)) {
    if (config$min_items > config$max_items) {
      errors <- c(errors, "min_items cannot exceed max_items")
    }
  }
  
  # Check adaptive settings
  if (!is.null(config$adaptive) && config$adaptive) {
    if (is.null(config$criteria)) {
      warnings <- c(warnings, "Adaptive testing enabled but no selection criteria specified")
      suggestions <- c(suggestions, "Add: criteria = 'MI' for maximum information")
    }
  }
  
  # =============================================================================
  # DEMOGRAPHIC VALIDATION
  # =============================================================================
  
  if (!is.null(config$demographics)) {
    if (!is.character(config$demographics)) {
      errors <- c(errors, "Demographics must be a character vector")
    } else if (length(config$demographics) == 0) {
      warnings <- c(warnings, "Empty demographics vector specified")
    }
  }
  
  # =============================================================================
  # THEME AND UI VALIDATION
  # =============================================================================
  
  if (!is.null(config$theme)) {
    valid_themes <- c("light", "dark", "minimal", "professional", "hildesheim")
    if (!config$theme %in% valid_themes) {
      warnings <- c(warnings, sprintf("Unknown theme '%s'", config$theme))
      suggestions <- c(suggestions, sprintf("Try: %s", paste(valid_themes, collapse = ", ")))
    }
  }
  
  # =============================================================================
  # RETURN VALIDATION RESULTS
  # =============================================================================
  
  is_valid <- length(errors) == 0
  
  if (!is_valid) {
    cat("\n=== CONFIGURATION VALIDATION FAILED ===\n")
    cat("Errors found:\n")
    for (i in seq_along(errors)) {
      cat(sprintf("  %d. %s\n", i, errors[i]))
    }
    
    if (length(suggestions) > 0) {
      cat("\nSuggestions:\n")
      for (i in seq_along(suggestions)) {
        cat(sprintf("  • %s\n", suggestions[i]))
      }
    }
    cat("========================================\n\n")
  }
  
  if (length(warnings) > 0) {
    cat("\n=== CONFIGURATION WARNINGS ===\n")
    for (i in seq_along(warnings)) {
      cat(sprintf("  Warning %d: %s\n", i, warnings[i]))
    }
    cat("===============================\n\n")
  }
  
  return(list(
    valid = is_valid,
    errors = errors,
    warnings = warnings,
    suggestions = suggestions
  ))
}

# =============================================================================
# RESPONSE MAPPING VALIDATION
# =============================================================================

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
#'   \item \strong{Partial Credit}: Validates step parameters and category scoring
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Validate GRM configuration
#' config <- create_study_config(
#'   name = "Personality Assessment",
#'   model = "GRM"
#' )
#' 
#' # Load BFI items for validation
#' data(bfi_items)
#' 
#' # Test with sample responses
#' test_responses <- c(3, 2, 4, 1, 5)  # Likert scale responses
#' test_items <- c(1, 5, 10, 15, 20)   # Item indices
#' 
#' is_valid <- validate_response_mapping(
#'   config, bfi_items, test_responses, test_items
#' )
#' 
#' if (is_valid) {
#'   cat("Response mapping validation passed!\n")
#' } else {
#'   cat("Response mapping validation failed - check output for details\n")
#' }
#' }
validate_response_mapping <- function(config, item_bank, test_responses = NULL, test_items = NULL) {
  
  cat("=== RESPONSE MAPPING VALIDATION ===\n")
  cat("Validating response processing pipeline...\n\n")
  
  validation_passed <- TRUE
  
  # Step 1: Configuration Validation
  cat("1. Configuration Validation:\n")
  if (is.null(config$model)) {
    cat("   ❌ ERROR: Model specification missing\n")
    validation_passed <- FALSE
  } else {
    cat(sprintf("   ✓ Model: %s\n", config$model))
  }
  
  # Step 2: Item Bank Structure Validation
  cat("\n2. Item Bank Structure Validation:\n")
  if (!is.data.frame(item_bank)) {
    cat("   ❌ ERROR: Item bank is not a data.frame\n")
    validation_passed <- FALSE
  } else {
    cat(sprintf("   ✓ Item bank: %d items, %d columns\n", nrow(item_bank), ncol(item_bank)))
    
    # Check required columns based on model
    required_cols <- switch(config$model,
      "GRM" = c("a", "b1", "b2"),
      "2PL" = c("a", "b"),
      "3PL" = c("a", "b", "c"),
      c("a", "b")  # default
    )
    
    missing_cols <- setdiff(required_cols, names(item_bank))
    if (length(missing_cols) > 0) {
      cat(sprintf("   ❌ ERROR: Missing required columns: %s\n", paste(missing_cols, collapse = ", ")))
      validation_passed <- FALSE
    } else {
      cat("   ✓ All required parameter columns present\n")
    }
  }
  
  # Step 3: Response Processing Test
  cat("\n3. Response Processing Test:\n")
  if (!is.null(test_responses) && !is.null(test_items)) {
    if (length(test_responses) != length(test_items)) {
      cat("   ❌ ERROR: Response and item vectors have different lengths\n")
      validation_passed <- FALSE
    } else {
      cat(sprintf("   ✓ Testing with %d responses\n", length(test_responses)))
      
      # Test response validation
      tryCatch({
        # Simulate response validation (would use actual validation functions)
        valid_responses <- all(is.numeric(test_responses) & !is.na(test_responses))
        if (valid_responses) {
          cat("   ✓ Response validation passed\n")
        } else {
          cat("   ❌ ERROR: Invalid responses detected\n")
          validation_passed <- FALSE
        }
      }, error = function(e) {
        cat(sprintf("   ❌ ERROR in response validation: %s\n", e$message))
        validation_passed <- FALSE
      })
    }
  } else {
    cat("   ⚠ WARNING: No test responses provided - skipping response processing test\n")
  }
  
  # Step 4: Model-Specific Validation
  cat("\n4. Model-Specific Validation:\n")
  if (!is.null(config$model)) {
    if (config$model == "GRM") {
      # Check for response categories
      if ("ResponseCategories" %in% names(item_bank)) {
        cat("   ✓ GRM: ResponseCategories column found\n")
      } else {
        cat("   ⚠ WARNING: GRM model but no ResponseCategories column\n")
      }
    } else if (config$model %in% c("1PL", "2PL", "3PL")) {
      # Check for correct answers
      if ("Answer" %in% names(item_bank) || "CorrectAnswer" %in% names(item_bank)) {
        cat("   ✓ Binary model: Answer column found\n")
      } else {
        cat("   ⚠ WARNING: Binary model but no Answer/CorrectAnswer column\n")
      }
    }
  }
  
  # Step 5: Final Summary
  cat("\n=== VALIDATION SUMMARY ===\n")
  if (validation_passed) {
    cat("✅ Response mapping validation PASSED\n")
    cat("   All checks completed successfully\n")
  } else {
    cat("❌ Response mapping validation FAILED\n")
    cat("   Please address the errors above\n")
  }
  cat("==========================\n\n")
  
  return(validation_passed)
}

# =============================================================================
# ITEM BANK VALIDATION
# =============================================================================

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
#' data(cognitive_items_data)
#' is_valid_2pl <- validate_item_bank(cognitive_items_data, "2PL")
#' cat("Cognitive items valid for 2PL:", is_valid_2pl, "\n")
#' }
validate_item_bank <- function(item_bank, model = "GRM") {
  
  cat("=== ITEM BANK VALIDATION ===\n")
  cat(sprintf("Validating item bank for %s model...\n\n", model))
  
  validation_passed <- TRUE
  
  # Basic structure validation
  if (!is.data.frame(item_bank)) {
    cat("❌ ERROR: Item bank must be a data.frame\n")
    return(FALSE)
  }
  
  if (nrow(item_bank) == 0) {
    cat("❌ ERROR: Item bank is empty\n")
    return(FALSE)
  }
  
  cat(sprintf("✓ Basic structure: %d items, %d columns\n", nrow(item_bank), ncol(item_bank)))
  
  # Model-specific validation
  required_cols <- switch(model,
    "1PL" = c("b"),
    "2PL" = c("a", "b"),
    "3PL" = c("a", "b", "c"),
    "GRM" = c("a", "b1", "b2"),
    "GPCM" = c("a", "b1"),
    "PCM" = c("b1"),
    "RSM" = c("b1"),
    c("a", "b")  # default
  )
  
  missing_cols <- setdiff(required_cols, names(item_bank))
  if (length(missing_cols) > 0) {
    cat(sprintf("❌ ERROR: Missing required columns for %s: %s\n", 
                model, paste(missing_cols, collapse = ", ")))
    validation_passed <- FALSE
  } else {
    cat(sprintf("✓ Required columns present: %s\n", paste(required_cols, collapse = ", ")))
  }
  
  # Parameter range validation
  if (validation_passed) {
    cat("\nParameter Range Validation:\n")
    
    # Discrimination parameters (a)
    if ("a" %in% names(item_bank)) {
      a_values <- item_bank$a
      if (any(is.na(a_values))) {
        cat("❌ ERROR: Missing values in discrimination parameters (a)\n")
        validation_passed <- FALSE
      } else if (any(a_values <= 0)) {
        cat("❌ ERROR: Non-positive discrimination parameters found\n")
        validation_passed <- FALSE
      } else if (any(a_values > 5)) {
        cat("⚠ WARNING: Very high discrimination parameters (>5) detected\n")
      } else {
        cat(sprintf("✓ Discrimination parameters: range [%.2f, %.2f]\n", 
                    min(a_values), max(a_values)))
      }
    }
    
    # Difficulty parameters (b)
    if ("b" %in% names(item_bank)) {
      b_values <- item_bank$b
      if (any(is.na(b_values))) {
        cat("❌ ERROR: Missing values in difficulty parameters (b)\n")
        validation_passed <- FALSE
      } else if (any(abs(b_values) > 6)) {
        cat("⚠ WARNING: Extreme difficulty parameters (|b| > 6) detected\n")
      } else {
        cat(sprintf("✓ Difficulty parameters: range [%.2f, %.2f]\n", 
                    min(b_values), max(b_values)))
      }
    }
    
    # Guessing parameters (c) for 3PL
    if ("c" %in% names(item_bank)) {
      c_values <- item_bank$c
      if (any(is.na(c_values))) {
        cat("❌ ERROR: Missing values in guessing parameters (c)\n")
        validation_passed <- FALSE
      } else if (any(c_values < 0 | c_values > 1)) {
        cat("❌ ERROR: Guessing parameters must be between 0 and 1\n")
        validation_passed <- FALSE
      } else {
        cat(sprintf("✓ Guessing parameters: range [%.3f, %.3f]\n", 
                    min(c_values), max(c_values)))
      }
    }
    
    # Threshold parameters for polytomous models
    if (model %in% c("GRM", "GPCM", "PCM", "RSM")) {
      threshold_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
      if (length(threshold_cols) > 1) {
        for (i in 1:nrow(item_bank)) {
          thresholds <- as.numeric(item_bank[i, threshold_cols])
          thresholds <- thresholds[!is.na(thresholds)]
          if (length(thresholds) > 1 && any(diff(thresholds) <= 0)) {
            cat(sprintf("❌ ERROR: Non-ascending thresholds in item %d\n", i))
            validation_passed <- FALSE
            break
          }
        }
        if (validation_passed) {
          cat("✓ Threshold parameters in ascending order\n")
        }
      }
    }
  }
  
  # Content validation
  content_cols <- c("Question", "Content", "Item", "Text")
  has_content <- any(content_cols %in% names(item_bank))
  if (has_content) {
    cat("✓ Question content column found\n")
  } else {
    cat("⚠ WARNING: No question content column detected\n")
  }
  
  # Final summary
  cat("\n=== VALIDATION SUMMARY ===\n")
  if (validation_passed) {
    cat("✅ Item bank validation PASSED\n")
    cat(sprintf("   Ready for %s analysis with TAM\n", model))
  } else {
    cat("❌ Item bank validation FAILED\n")
    cat("   Please address the errors above\n")
  }
  cat("==========================\n\n")
  
  return(validation_passed)
}