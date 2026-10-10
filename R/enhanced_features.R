#' Configuration Checks and Response Report Helpers
#'
#' Helpers called by \code{\link{launch_study}}: configuration checks
#' (\code{validate_and_fix_config}, \code{handle_extreme_parameters}) and
#' the response table \code{create_response_report}.
#'
#' @name enhanced_features
#' @keywords internal

# Configuration checks ----

#' Validate and Fix Study Configuration
#'
#' Clamps item counts (\code{max_items} to 1 to 1000, \code{min_items} to at
#' least 1 and at most \code{max_items}), replaces an unsupported \code{model}
#' by \code{"2PL"}, resets a negative \code{min_SEM} to 0.3, limits and
#' sanitises demographic names, sets a default study name, and, if an item
#' bank is given, caps \code{max_items} at the bank size and notes missing
#' parameter columns. Changes are recorded in \code{validation_warnings}.
#'
#' @param config Study configuration list
#' @param item_bank Item bank data frame (optional)
#' @return Validated and corrected configuration
#' @export
validate_and_fix_config <- function(config, item_bank = NULL) {
  if (is.null(config)) {
    stop("Configuration cannot be NULL")
  }
  
  # Initialize fixed config
  fixed_config <- config
  warnings <- list()
  
  # 1. Handle extreme item counts
  if (!is.null(fixed_config$max_items)) {
    if (fixed_config$max_items > 1000) {
      warnings$max_items <- "Maximum items exceeds 1000, capping at 1000 for performance"
      fixed_config$max_items <- 1000
    }
    if (fixed_config$max_items < 1) {
      warnings$min_items <- "Maximum items must be at least 1"
      fixed_config$max_items <- 1
    }
  }
  
  if (!is.null(fixed_config$min_items)) {
    if (fixed_config$min_items < 1) {
      fixed_config$min_items <- 1
    }
    if (!is.null(fixed_config$max_items) && fixed_config$min_items > fixed_config$max_items) {
      fixed_config$min_items <- fixed_config$max_items
      warnings$item_mismatch <- "min_items cannot exceed max_items, adjusted"
    }
  }
  
  # 2. Handle invalid model specifications (only these four are implemented
  # in estimate_ability() and compute_item_info_single())
  valid_models <- c("1PL", "2PL", "3PL", "GRM")
  if (!is.null(fixed_config$model)) {
    if (!(fixed_config$model %in% valid_models)) {
      warnings$model <- paste("Invalid model:", fixed_config$model, "- defaulting to 2PL")
      fixed_config$model <- "2PL"
    }
  } else {
    fixed_config$model <- "2PL"
  }
  
  # 3. Handle extreme SEM values
  if (!is.null(fixed_config$min_SEM)) {
    if (fixed_config$min_SEM < 0) {
      fixed_config$min_SEM <- 0.3
      warnings$sem <- "Invalid min_SEM, using default 0.3"
    }
    if (fixed_config$min_SEM > 10) {
      fixed_config$min_SEM <- 999
      fixed_config$adaptive_stopping <- FALSE
    }
  }
  
  # 4. Handle demographic variables
  if (!is.null(fixed_config$demographics)) {
    if (length(fixed_config$demographics) > 100) {
      warnings$demographics <- "Too many demographic variables, limiting to 100"
      fixed_config$demographics <- fixed_config$demographics[1:100]
    }
    fixed_config$demographics <- make.names(fixed_config$demographics, unique = TRUE)
  }
  
  # 5. Handle names
  if (!is.null(fixed_config$name)) {
    if (nchar(trimws(fixed_config$name)) == 0) {
      fixed_config$name <- "Unnamed Study"
    }
    if (nchar(fixed_config$name) > 500) {
      fixed_config$name <- substr(fixed_config$name, 1, 500)
    }
  } else {
    fixed_config$name <- "Unnamed Study"
  }
  
  # 6. Validate item bank compatibility
  if (!is.null(item_bank)) {
    fixed_config <- validate_item_bank_compatibility(fixed_config, item_bank)
  }
  
  # Add warnings to config
  if (length(warnings) > 0) {
    fixed_config$validation_warnings <- warnings
  }
  
  # Add validation timestamp
  fixed_config$validated_at <- Sys.time()
  fixed_config$validation_version <- "2.0.0"
  
  return(fixed_config)
}

#' Validate Item Bank Compatibility
#' 
#' Ensures item bank is compatible with configuration
#' 
#' @param config Study configuration
#' @param item_bank Item bank data frame
#' @return Updated configuration
validate_item_bank_compatibility <- function(config, item_bank) {
  
  if (!is.data.frame(item_bank)) {
    stop("Item bank must be a data frame")
  }
  
  n_items <- nrow(item_bank)
  
  # Check max_items doesn't exceed item bank
  if (!is.null(config$max_items) && config$max_items > n_items) {
    config$max_items <- n_items
    config$validation_warnings$max_items_adjusted <- 
      paste("max_items reduced to", n_items, "(item bank size)")
  }
  
  # Item parameters are only used in adaptive mode
  if (!isTRUE(config$adaptive)) return(config)

  # Check model compatibility
  if (config$model == "GRM") {
    required_cols <- c("Question", "a", "b1", "b2", "b3", "b4")
    if (!all(required_cols %in% names(item_bank))) {
      config$validation_warnings$grm_params <- 
        "GRM requires a, b1, b2, b3, b4 parameters"
    }
  } else if (config$model %in% c("2PL", "3PL")) {
    required_cols <- c("Question", "a", "b")
    if (!all(required_cols %in% names(item_bank))) {
      config$validation_warnings$binary_params <- 
        paste(config$model, "requires a and b parameters")
    }
  }
  
  return(config)
}

#' Clamp Configuration Values to Fixed Bounds
#'
#' Clamps selected numeric configuration values to fixed ranges (for example
#' \code{theta_prior} elementwise to -5 to 5), truncates some strings, and
#' shortens some vectors.
#'
#' @param params List of parameters
#' @return Sanitized parameters
#' @export
handle_extreme_parameters <- function(params) {
  sanitized <- params
  
  # Numeric bounds
  numeric_bounds <- list(
    max_items = c(1, 1000),
    min_items = c(1, 1000),
    min_SEM = c(0.01, 10),
    time_limit = c(0, 86400),
    time_per_item = c(1, 3600),
    max_session_duration = c(1, 1440),
    theta_prior = c(-5, 5),
    passing_score = c(-4, 4),
    extended_time_factor = c(1, 5)
  )
  
  for (param in names(numeric_bounds)) {
    if (!is.null(sanitized[[param]])) {
      bounds <- numeric_bounds[[param]]
      if (is.numeric(sanitized[[param]])) {
        sanitized[[param]] <- pmax(bounds[1], pmin(bounds[2], sanitized[[param]]))
      }
    }
  }
  
  # String lengths
  string_maxlen <- list(
    name = 500,
    study_key = 100,
    language = 10,
    theme = 50
  )
  
  for (param in names(string_maxlen)) {
    if (!is.null(sanitized[[param]]) && is.character(sanitized[[param]])) {
      if (nchar(sanitized[[param]]) > string_maxlen[[param]]) {
        sanitized[[param]] <- substr(sanitized[[param]], 1, string_maxlen[[param]])
      }
    }
  }
  
  # Array limits
  array_limits <- list(
    demographics = 100,
    fixed_items = 500,
    report_formats = 10,
    study_phases = 20,
    modules = 50
  )
  
  for (param in names(array_limits)) {
    if (!is.null(sanitized[[param]]) && length(sanitized[[param]]) > array_limits[[param]]) {
      sanitized[[param]] <- sanitized[[param]][1:array_limits[[param]]]
    }
  }
  
  return(sanitized)
}

# Response report ----

#' Create Response Report
#'
#' Builds a table of the administered items with the responses and response
#' times. For GRM, optional labels are taken from a fixed five-point agreement
#' scale in the study language; they are only correct for items with that
#' scale. For other models, responses coded 1 are shown as "Correct" when the
#' bank has an \code{Answer} column.
#'
#' @param config Study configuration object
#' @param cat_result List with \code{administered}, \code{responses} and
#'   \code{response_times}
#' @param item_bank Item bank dataset
#' @param include_labels Include response labels (GRM only)
#'
#' @return Data frame with response report
#' @export
create_response_report <- function(config, cat_result, item_bank, include_labels = TRUE) {
  
  if (is.null(cat_result) || is.null(cat_result$responses)) {
    stop("Invalid cat_result: missing responses")
  }
  
  items <- cat_result$administered
  responses <- cat_result$responses
  
  # Basic table structure
  if (config$model == "GRM") {
    # For GRM, show actual response values with optional labels
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = responses,
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
    
    # Add response labels if requested
    if (include_labels && isTRUE(config$language %in% c("en", "de", "es", "fr"))) {
      response_labels <- switch(config$language,
        "en" = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
        "de" = c("Stark ablehnen", "Ablehnen", "Neutral", "Zustimmen", "Stark zustimmen"),
        "es" = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo"),
        "fr" = c("Fortement en d\u00E9saccord", "En d\u00E9saccord", "Neutre", "D'accord", "Fortement d'accord")
      )
      
      # Add response labels column
      dat$Response_Label <- response_labels[responses]
      
      # Reorder columns
      dat <- dat[, c("Item", "Response", "Response_Label", "Time")]
    }
    
  } else {
    # For binary models, show correct/incorrect with answers
    # Check if Answer column exists (for compatibility with different item banks)
    if ("Answer" %in% names(item_bank)) {
      dat <- data.frame(
        Item = item_bank$Question[items],
        Response = ifelse(responses == 1, "Correct", "Incorrect"),
        Correct = item_bank$Answer[items],
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    } else {
      # For item banks without Answer column (e.g., personality items)
      dat <- data.frame(
        Item = item_bank$Question[items],
        Response = responses,
        Score = responses,  # For personality items, response is the score
        Time = round(cat_result$response_times, 1),
        check.names = FALSE
      )
    }
  }
  
  # Add validation metadata
  attr(dat, "validation_info") <- list(
    total_items = length(items),
    total_responses = length(responses),
    response_consistency = all(!is.na(responses)),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(dat)
}
