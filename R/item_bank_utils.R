#' Validate Item Bank Structure
#'
#' @description
#' Checks that the item bank is a non-empty data frame with a \code{Question}
#' column and, for adaptive studies, the parameter columns the model needs:
#' \code{a}, \code{b1}--\code{b4} for GRM; \code{a}, \code{b} for 2PL and 3PL;
#' \code{b} for 1PL. Parameter values are not checked, and for 3PL the
#' \code{c} column is not required. For GRM a message is printed when the
#' number of thresholds \code{b1, b2, ...} differs from the number of
#' categories in \code{ResponseCategories} minus one; the bank is still
#' reported as valid in that case.
#'
#' @param item_bank Data frame containing item bank
#' @param model IRT model ("GRM", "2PL", "1PL", "3PL")
#' @param adaptive Logical. When \code{FALSE} (non-adaptive / fixed-form study),
#'   IRT parameter columns (\code{a}, \code{b}, \code{b1} to \code{b4}) are not
#'   required and the column checks are skipped. Only \code{Question} and
#'   \code{ResponseCategories} are checked. Default \code{TRUE} preserves the
#'   existing behaviour for adaptive studies.
#' @return List with validation results: is_valid (logical) and messages (character vector)
#' @export
#'
#' @examples
#' \dontrun{
#' data(bfi_items)
#' # Adaptive study: IRT columns required
#' validation <- validate_item_bank(bfi_items, "GRM", adaptive = TRUE)
#' # Fixed-form study: IRT columns optional
#' validation <- validate_item_bank(bfi_items, "GRM", adaptive = FALSE)
#' print(validation$is_valid)
#' print(validation$messages)
#' }
validate_item_bank <- function(item_bank, model = "GRM", adaptive = TRUE) {
  
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
  
  # IRT parameter columns are only required for adaptive studies.
  # In a fixed-form (non-adaptive) study the item parameters are never read,
  # so we skip these checks entirely.
  if (!isTRUE(adaptive)) {
    return(list(is_valid = TRUE, messages = "Item bank validation passed (non-adaptive: IRT columns not checked)"))
  }
  
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

  if ("ResponseCategories" %in% names(item_bank)) {
    if (model != "GRM") {
      message("Warning: Your item bank has 'ResponseCategories' column, typically used with GRM for Likert-scale items.")
    } else {
      # inrep's GRM uses one category more than there are thresholds; responses
      # above that are skipped in estimate_ability().
      n_thresholds <- length(grep("^b[0-9]+$", names(item_bank)))
      n_categories <- vapply(strsplit(as.character(item_bank$ResponseCategories), ","),
                             length, integer(1))
      mismatch <- which(n_categories != n_thresholds + 1L)
      if (length(mismatch) > 0) {
        message(sprintf(
          "Warning: %d item(s) have a number of response categories that does not match the %d threshold columns (expected %d categories), e.g. item %d.",
          length(mismatch), n_thresholds, n_thresholds + 1L, mismatch[1]))
      }
    }
  }

  # All checks passed
  return(list(is_valid = TRUE, messages = "Item bank validation passed"))
}


#' Flag Items with Low Discrimination
#'
#' @description
#' Returns the rows of \code{item_bank} whose discrimination \code{a} is below
#' \code{discrimination_threshold}. Nothing else is checked (threshold order,
#' parameter ranges and missing values are not examined; items with missing
#' \code{a} are not flagged).
#'
#' @param item_bank Data frame with a discrimination column \code{a}.
#' @param discrimination_threshold Numeric cut-off. Default is 0.2.
#'
#' @return Data frame with the flagged rows (zero rows if none).
#'
#' @export
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
#' # Example 2: Higher cut-off
#' strict_outliers <- detect_outlier_items(bfi_items, discrimination_threshold = 0.7)
#' 
#' cat("Items below strict threshold (0.7):\n")
#' print(strict_outliers[, c("Question", "a")])
#' 
#' # Example 3: Drop flagged items
#' clean_items <- bfi_items[!rownames(bfi_items) %in% rownames(outliers), ]
#' cat("Original items:", nrow(bfi_items), "\n")
#' cat("Clean items:", nrow(clean_items), "\n")
#' cat("Removed:", nrow(bfi_items) - nrow(clean_items), "items\n")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_item_bank}} for structural validation
#'   \item \code{bfi_items} for example item bank (use \code{data(bfi_items)})
#' }
#'
#' @keywords psychometrics item-analysis
detect_outlier_items <- function(item_bank, discrimination_threshold = 0.2) {
  # which() drops NA, which would otherwise add all-NA rows
  flagged <- item_bank[which(item_bank$a < discrimination_threshold), , drop = FALSE]
  if (nrow(flagged) > 0) {
    message(sprintf("%d items flagged for low discrimination.", nrow(flagged)))
  }
  flagged
}
