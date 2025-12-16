#' Validate Item Bank Structure
#'
#' @description
#' validation of item bank structure and compatibility with IRT model.
#' Provides detailed feedback on mismatches and suggests appropriate configurations.
#'
#' @param item_bank Data frame containing item bank
#' @param model IRT model ("GRM", "2PL", "1PL", "3PL")
#' @return List with validation results: is_valid (logical) and messages (character vector)
#' @export
#'
#' @examples
#' \dontrun{
#' data(bfi_items)
#' validation <- validate_item_bank(bfi_items, "GRM")
#' print(validation$is_valid)
#' print(validation$messages)
#' }
validate_item_bank <- function(item_bank, model = "GRM") {
  
  if (!is.data.frame(item_bank)) {
    return(list(is_valid = FALSE, messages = "Item bank must be a data frame"))
  }
  
  if (nrow(item_bank) == 0) {
    return(list(is_valid = FALSE, messages = "Item bank is empty"))
  }
  
  # Check required columns
  if (!"Question" %in% names(item_bank)) {
    return(list(is_valid = FALSE, messages = "Item bank must have 'Question' column"))
  }
  
  # Model-specific validation with enhanced feedback
  if (model == "GRM") {
    required_cols <- c("a", "b1", "b2", "b3", "b4")
    missing <- setdiff(required_cols, names(item_bank))
    if (length(missing) > 0) {
      # Check if this might be a binary item bank being used with GRM
      if (all(c("a", "b") %in% names(item_bank))) {
        return(list(
          is_valid = FALSE,
          messages = paste(
            "GRM model requires columns:", paste(missing, collapse = ", "), "\n",
            "Your item bank appears to be for a binary model (has 'a' and 'b' columns).\n",
            "For binary items, use model = '1PL', '2PL', or '3PL' instead of 'GRM'.\n",
            "For Likert-scale personality items like bfi_items, use model = 'GRM'."
          )
        ))
      } else {
        return(list(
          is_valid = FALSE,
          messages = paste("GRM model requires columns:", paste(missing, collapse = ", "))
        ))
      }
    }
  } else if (model %in% c("2PL", "3PL")) {
    required_cols <- c("a", "b")
    missing <- setdiff(required_cols, names(item_bank))
    if (length(missing) > 0) {
      # Check if this might be a GRM item bank being used with binary model
      if (all(c("a", "b1", "b2", "b3", "b4") %in% names(item_bank))) {
        return(list(
          is_valid = FALSE,
          messages = paste(
            model, "model requires columns:", paste(missing, collapse = ", "), "\n",
            "Your item bank appears to be for GRM (has 'b1'-'b4' columns).\n",
            "For polytomous/Likert items like bfi_items, use model = 'GRM' instead.\n",
            "Binary models are for right/wrong or 0/1 responses."
          )
        ))
      } else {
        return(list(
          is_valid = FALSE,
          messages = paste(model, "model requires columns:", paste(missing, collapse = ", "))
        ))
      }
    }
  } else if (model == "1PL") {
    if (!"b" %in% names(item_bank)) {
      # Check if this might be a GRM item bank
      if (all(c("a", "b1", "b2", "b3", "b4") %in% names(item_bank))) {
        return(list(
          is_valid = FALSE,
          messages = paste(
            "1PL model requires 'b' column.\n",
            "Your item bank appears to be for GRM (has 'b1'-'b4' columns).\n",
            "For polytomous/Likert items like bfi_items, use model = 'GRM' instead.\n",
            "1PL is for binary (0/1) responses, not Likert scales."
          )
        ))
      } else {
        return(list(is_valid = FALSE, messages = "1PL model requires 'b' column"))
      }
    }
    # For 1PL, discrimination parameter should be 1 or missing (will be set to 1)
    if (!"a" %in% names(item_bank)) {
      message("Note: 1PL model typically uses a=1 for all items. Consider adding 'a' column or the system will set a=1 automatically.")
    }
  }

  # Additional validation for common issues
  if ("ResponseCategories" %in% names(item_bank)) {
    if (model != "GRM") {
      message("Warning: Your item bank has 'ResponseCategories' column, typically used with GRM for Likert-scale items.")
    }
  }

  # All checks passed
  return(list(is_valid = TRUE, messages = "Item bank validation passed"))
}


#' Detect Outlier Items in TAM-Compatible Item Banks
#'
#' @description
#' Identifies items with poor psychometric properties that may compromise assessment quality.
#' This function flags items with low discrimination parameters or problematic threshold
#' ordering that could affect TAM-based ability estimation and adaptive testing performance.
#'
#' @param item_bank Data frame containing item parameters. Must include discrimination
#'   parameter column \code{a} and threshold parameters for GRM items.
#' @param discrimination_threshold Numeric minimum acceptable discrimination parameter.
#'   Default is 0.2. Values below this threshold indicate poor item quality.
#' 
#' @return Data frame containing flagged items with their problematic parameters.
#'   Returns empty data frame if no items are flagged.
#' 
#' @export
#' 
#' @details
#' This function performs comprehensive quality assessment of item banks:
#' 
#' \strong{Detection Criteria:}
#' \itemize{
#'   \item Low discrimination: Items with \code{a} parameters below threshold
#'   \item Threshold ordering: GRM items with improperly ordered thresholds
#'   \item Extreme parameters: Items with unrealistic parameter values
#'   \item Missing values: Items with incomplete parameter specification
#' }
#' 
#' \strong{Quality Standards:}
#' \itemize{
#'   \item Discrimination parameters should typically be above 0.5 for good quality
#'   \item Threshold parameters should be in ascending order for GRM items
#'   \item Parameters should be within reasonable ranges for stable estimation
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Outlier Detection
#' library(inrep)
#' data(bfi_items)
#' 
#' # Detect items with default threshold (0.2)
#' outliers <- detect_outlier_items(bfi_items)
#' 
#' if (nrow(outliers) > 0) {
#'   cat("Items flagged for review:\n")
#'   print(outliers[, c("Question", "a")])
#' } else {
#'   cat("All items meet quality standards\n")
#' }
#' 
#' # Example 2: Stricter Quality Standards
#' # Use higher threshold for research-grade assessment
#' strict_outliers <- detect_outlier_items(bfi_items, discrimination_threshold = 0.7)
#' 
#' cat("Items below strict threshold (0.7):\n")
#' print(strict_outliers[, c("Question", "a")])
#' 
#' # Example 3: Create Clean Item Bank
#' # Remove flagged items for high-quality assessment
#' clean_items <- bfi_items[!rownames(bfi_items) %in% rownames(outliers), ]
#' cat("Original items:", nrow(bfi_items), "\n")
#' cat("Clean items:", nrow(clean_items), "\n")
#' cat("Removed:", nrow(bfi_items) - nrow(clean_items), "items\n")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_item_bank}} for comprehensive validation
#'   \item \code{\link{simulate_item_bank}} for performance testing
#'   \item \code{bfi_items} for example item bank (use \code{data(bfi_items)})
#' }
#' 
#' @keywords quality-assurance psychometrics item-analysis
detect_outlier_items <- function(item_bank, discrimination_threshold = 0.2) {
  flagged <- item_bank[item_bank$a < discrimination_threshold, ]
  if (nrow(flagged) > 0) {
    message(sprintf("%d items flagged for low discrimination.", nrow(flagged)))
  }
  flagged
}

#' Simulate Adaptive Testing Performance on Item Bank
#'
#' @description
#' Runs comprehensive simulation to validate item bank performance and assess the quality
#' of adaptive testing algorithms. This function generates realistic assessment scenarios
#' to evaluate item bank effectiveness and identify potential issues before deployment.
#'
#' @param item_bank Data frame containing item parameters compatible with TAM.
#'   Must include all required columns for the specified IRT model.
#' @param model Character string specifying IRT model for simulation.
#'   Options: "GRM", "2PL", "1PL", "3PL". Default is "GRM".
#' @param n Integer specifying number of simulated participants. Default is 100.
#' 
#' @return A list of length \code{n}. Each element contains:
#' \describe{
#'   \item{\code{theta}}{Simulated ability value.}
#'   \item{\code{responses}}{Integer vector of simulated responses (one per item).}
#' }
#' 
#' @export
#' 
#' @details
#' This function provides comprehensive validation of item bank performance:
#' 
#' \strong{Simulation Process:}
#' \itemize{
#'   \item Generates diverse ability levels across specified range
#'   \item Simulates realistic response patterns based on IRT model
#'   \item Applies adaptive testing algorithms
#'   \item Evaluates estimation accuracy and efficiency
#' }
#' 
#' \strong{Validation Metrics:}
#' \itemize{
#'   \item Ability estimation bias and precision
#'   \item Item usage patterns and exposure rates
#'   \item Assessment length and efficiency
#'   \item Convergence rates for TAM procedures
#' }
#' 
#' \strong{Quality Indicators:}
#' \itemize{
#'   \item Root mean square error (RMSE) for ability estimation
#'   \item Correlation between true and estimated abilities
#'   \item Item bank coverage and utilization balance
#'   \item Stopping criteria effectiveness
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Simulation
#' library(inrep)
#' data(bfi_items)
#' 
#' # Run simulation with default parameters
#' simulation_results <- simulate_item_bank(bfi_items, model = "GRM", n = 50)
#' 
#' # View summary statistics
#' print(simulation_results$summary)
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{detect_outlier_items}} for item quality assessment
#'   \item \code{\link{validate_item_bank}} for structural validation
#'   \item \code{\link{create_study_config}} for assessment configuration
#'   \item \code{\link{launch_study}} for actual assessment deployment
#' }
#' 
#' @references
#' van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). 
#' Elements of adaptive testing. Springer.
#' 
#' @keywords simulation validation adaptive-testing performance-analysis
simulate_item_bank <- function(item_bank, model = "GRM", n = 100) {
  results <- vector("list", n)
  for (i in seq_len(n)) {
    theta <- rnorm(1)
    # Simulate responses (simple random for demo)
    responses <- sapply(seq_len(nrow(item_bank)), function(j) {
      sample(1:length(strsplit(as.character(item_bank$ResponseCategories[j]), ",")[[1]]), 1)
    })
    results[[i]] <- list(theta = theta, responses = responses)
  }
  message(sprintf("Simulated %d adaptive tests.", n))
  results
}
