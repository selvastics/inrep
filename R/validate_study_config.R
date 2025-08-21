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
#'     cat("  ❌", error, "\n")
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
        "results_processor must be a function.\nExample:\nconfig$results_processor <- function(responses, item_bank) {\n  # Your code here\n  return(shiny::HTML('<p>Results</p>'))\n}"
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
      ifelse(valid, "PASSED ✓", "FAILED ✗"),
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
      cat("❌ ERRORS (must fix):\n")
      for (i in seq_along(errors)) {
        cat(sprintf("  %d. %s\n\n", i, errors[i]))
      }
    }
    
    if (length(warnings) > 0) {
      cat("⚠️  WARNINGS (should review):\n")
      for (i in seq_along(warnings)) {
        cat(sprintf("  %d. %s\n\n", i, warnings[i]))
      }
    }
    
    if (length(suggestions) > 0) {
      cat("💡 SUGGESTIONS (optional improvements):\n")
      for (i in seq_along(suggestions)) {
        cat(sprintf("  %d. %s\n\n", i, suggestions[i]))
      }
    }
    
    cat(report$summary, "\n")
    cat(strrep("=", 70), "\n\n")
  }
  
  return(report)
}

#' Validate Item Bank Structure
#'
#' @description
#' Validates item bank structure with detailed error messages
#'
#' @param item_bank Data frame containing items
#' @param model IRT model to use
#'
#' @return List with validation results
#' @export
validate_item_bank <- function(item_bank, model = "GRM") {
  
  errors <- character()
  warnings <- character()
  
  if (!is.data.frame(item_bank)) {
    return(list(
      valid = FALSE,
      errors = "Item bank must be a data frame",
      warnings = character()
    ))
  }
  
  # Model-specific validation
  if (model == "GRM") {
    if (!"ResponseCategories" %in% names(item_bank)) {
      errors <- c(errors,
        "GRM requires ResponseCategories column. Add: item_bank$ResponseCategories <- '1,2,3,4,5'"
      )
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    warnings = warnings
  ))
}