# Parallel processing helpers and the item information function used by item
# selection (compute_item_info_single).

#' Single Item Information Computation
#'
#' Computes Fisher information for a single item at a given ability level,
#' using the item parameters in \code{item_bank} as fixed. Used by
#' \code{\link{select_next_item}} and \code{\link{fast_select_next_item}}.
#'
#' Formulas (logistic metric without the constant 1.7):
#' 1PL/2PL \eqn{I(\theta) = a^2 P (1 - P)}; 3PL
#' \eqn{I(\theta) = a^2 (P - c)^2 (1 - P) / (P (1 - c)^2)}; GRM
#' \eqn{I(\theta) = \sum_k [P'_k(\theta)]^2 / P_k(\theta)}, where \eqn{P_k}
#' are category probabilities derived from the boundary curves
#' \eqn{P^*_j(\theta) = 1/(1+\exp(-a(\theta-b_j)))} (Samejima, 1969).
#' For 1PL a column \code{a} is used if present. Missing parameters are filled
#' with the same arbitrary defaults as in \code{\link{estimate_ability}}.
#'
#' @references
#' Samejima, F. (1969). Estimation of latent ability using a response pattern of
#'   graded scores. \emph{Psychometrika Monograph Supplement}, No. 17.
#'
#' @param theta Ability estimate
#' @param item_idx Item index (row number in item_bank)
#' @param item_bank Data frame containing item parameters (a, b for 2PL; a, b, c
#'   for 3PL; a, b1, b2, ... for GRM)
#' @param config Study configuration with \code{$model} element
#' @return Numeric information value (non-negative)
#' @export
compute_item_info_single <- function(theta, item_idx, item_bank, config) {
  # Same column aliases as select_next_item()
  nms <- names(item_bank)
  if (!"a" %in% nms && "discrimination" %in% nms) item_bank$a <- item_bank$discrimination
  if (!"b" %in% nms && "difficulty" %in% nms) item_bank$b <- item_bank$difficulty
  a <- if ("a" %in% names(item_bank)) item_bank$a[item_idx] else NA_real_
  if (is.na(a)) {
    a <- switch(config$model,
      "1PL" = 1.0,
      "2PL" = 1.2,
      "3PL" = 1.0,
      "GRM" = 1.5,
      1.0
    )
  }
  
  # Handle unknown difficulty/threshold parameters
  if (config$model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    if (length(b_cols) == 0) {
      return(0)
    }
    b_thresholds <- as.numeric(item_bank[item_idx, b_cols])
    
    # Replace any NA thresholds with defaults
    if (any(is.na(b_thresholds))) {
      na_indices <- which(is.na(b_thresholds))
      for (i in na_indices) {
        b_thresholds[i] <- (i - (length(b_thresholds) + 1) / 2) * 1.2
      }
      b_thresholds <- sort(b_thresholds)
      for (i in 2:length(b_thresholds)) {
        if (b_thresholds[i] <= b_thresholds[i-1]) {
          b_thresholds[i] <- b_thresholds[i-1] + 0.1
        }
      }
    }
  } else {
    b <- item_bank$b[item_idx] %||% 0
    if (is.na(b)) {
      b <- 0
    }
  }
  
  # Handle unknown guessing parameter
  c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) {
    c_val <- item_bank$c[item_idx]
    if (is.na(c_val)) 0.15 else c_val
  } else 0
  
  info <- if (config$model == "3PL") {
    p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b)))
    q <- 1 - p
    (a^2 * (p - c_param)^2 * q) / (p * (1 - c_param)^2)
  } else if (config$model == "GRM") {
    # Samejima Graded Response Model information
    # Reference: Samejima, F. (1969). Estimation of latent ability using a
    # response pattern of graded scores. Psychometrika Monograph Supplement, 17.
    n_cat <- length(b_thresholds) + 1
    if (n_cat < 2) {
      return(0)
    }
    # Boundary characteristic curves: P*_j(theta) = 1/(1+exp(-a*(theta-b_j)))
    # with P*_0 = 1 and P*_{K+1} = 0
    P_star <- c(1, vapply(b_thresholds, function(bk) {
      1 / (1 + exp(-a * (theta - bk)))
    }, numeric(1)), 0)
    # Category probabilities: P_k = P*_k - P*_{k+1}
    P_cat <- pmax(P_star[1:n_cat] - P_star[2:(n_cat + 1)], 1e-10)
    # Derivatives of boundary curves: dP*_j/dtheta = a * P*_j * (1 - P*_j)
    dP_star <- c(0, a * P_star[2:(n_cat)] * (1 - P_star[2:(n_cat)]), 0)
    # Category probability derivatives: dP_k = dP*_k - dP*_{k+1}
    dP_cat <- dP_star[1:n_cat] - dP_star[2:(n_cat + 1)]
    # Information: I(theta) = sum( [dP_k]^2 / P_k )
    sum(dP_cat^2 / P_cat)
  } else {
    p <- 1 / (1 + exp(-a * (theta - b)))
    a^2 * p * (1 - p)
  }
  
  if (is.finite(info) && info > 0) info else 0
}
