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