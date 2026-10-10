#' Estimate Ability (EAP with Fixed Item Parameters)
#'
#' Computes the expected a posteriori (EAP) estimate of a person's ability and
#' its posterior standard deviation from the responses given so far. The item
#' parameters in \code{item_bank} are treated as fixed and known; nothing is
#' calibrated here.
#'
#' @param rv A list (or Shiny \code{reactiveValues}) with \code{$responses},
#'   \code{$administered} (row indices into \code{item_bank}) and
#'   \code{$current_ability}, or a plain numeric response vector, in which case
#'   the responses are taken to belong to items \code{1, 2, ...} of the bank.
#' @param item_bank Data frame with item parameters. Required columns depend
#'   on the model: \code{b} (and optionally \code{a}) for 1PL; \code{a}, \code{b}
#'   for 2PL; \code{a}, \code{b}, \code{c} for 3PL; \code{a}, \code{b1},
#'   \code{b2}, ... for GRM. Columns \code{discrimination} and \code{difficulty}
#'   are accepted as aliases of \code{a} and \code{b}.
#' @param config Study configuration (from \code{\link{create_study_config}})
#'   or a model name string (e.g., \code{"2PL"}).
#'
#' @return List with \code{theta} (EAP estimate) and \code{se} (posterior
#'   standard deviation).
#'
#' @details
#' The posterior is evaluated on \code{config$theta_grid} with a normal prior
#' \eqn{N(\mu, \sigma^2)}, \code{c(mu, sigma) = config$theta_prior}. The
#' estimate is the posterior mean and \code{se} is the posterior standard
#' deviation (Bock & Mislevy, 1982). The same computation is used whatever
#' \code{config$estimation_method} says; \code{"WLE"} has no effect here.
#'
#' Response coding: dichotomous models expect 0/1. The GRM expects categories
#' \code{1, ..., K + 1} for \code{K} thresholds \code{b1 < ... < bK}
#' (Samejima, 1969). Responses that are \code{NA} or outside this range are
#' skipped. The logistic metric is used without the scaling constant 1.7.
#'
#' Missing parameters are filled with fixed defaults (for example \code{a = 1.2}
#' for 2PL, \code{a = 1.5} for GRM, \code{c = 0.15} for 3PL, \code{b = 0},
#' evenly spaced GRM thresholds). These values are arbitrary and only keep the
#' computation running; a bank with missing parameters should be completed
#' before use. For 1PL, a column \code{a} is used if present, so it should be
#' constant across items.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' config <- create_study_config(model = "GRM")
#' rv <- list(
#'   responses = c(2, 4, 3, 1, 5),
#'   administered = c(1, 5, 12, 18, 23),
#'   current_ability = 0
#' )
#' result <- estimate_ability(rv, bfi_items, config)
#' cat("Theta:", round(result$theta, 3), "SE:", round(result$se, 3), "\n")
#' }
#'
#' @references
#' Bock, R. D., & Mislevy, R. J. (1982). Adaptive EAP estimation of ability in a
#'   microcomputer environment. \emph{Applied Psychological Measurement}, 6(4),
#'   431--444.
#'
#' Samejima, F. (1969). Estimation of latent ability using a response pattern of
#'   graded scores. \emph{Psychometrika Monograph Supplement}, No. 17.
#'
#' @seealso \code{\link{create_study_config}}, \code{\link{select_next_item}},
#'   \code{\link{launch_study}}
#'
#' @keywords psychometrics IRT
estimate_ability <- function(rv, item_bank, config) {
  if (is.list(rv) && !is.null(rv$responses)) {
    responses <- rv$responses
    administered <- rv$administered
    current_ability <- rv$current_ability
  } else if (is.atomic(rv) && !is.null(rv)) {
    responses <- rv
    administered <- seq_along(responses)
    current_ability <- 0
  } else {
    stop("rv must be either a reactive values object with $responses component or a simple vector")
  }
  
  if (is.character(config)) {
    model <- config
    config <- list(
      model = model,
      estimation_method = "EAP",
      theta_prior = c(0, 1),
      theta_grid = seq(-4, 4, length.out = 100)
    )
  }
  # A config list without a prior gets the standard normal prior
  if (length(config$theta_prior) != 2) config$theta_prior <- c(0, 1)
  
  if (length(responses) == 0) {
    message("No responses provided, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  theta_grid <- if (is.numeric(config$theta_grid) && length(config$theta_grid) >= 2) {
    config$theta_grid
  } else {
    message("Invalid theta_grid, using default grid (-4, 4, 100)")
    seq(-4, 4, length.out = 100)
  }
  
  # Same column aliases as select_next_item() and launch_study()
  nms <- names(item_bank)
  if (!"a" %in% nms && "discrimination" %in% nms) item_bank$a <- item_bank$discrimination
  if (!"b" %in% nms && "difficulty" %in% nms) item_bank$b <- item_bank$difficulty
  if (!"a" %in% names(item_bank)) item_bank$a <- NA_real_
  
  n_theta <- length(theta_grid)
  prior <- dnorm(theta_grid, config$theta_prior[1], config$theta_prior[2])
  prior <- prior / sum(prior)
  
  default_a <- switch(config$model, "1PL" = 1.0, "2PL" = 1.2, "3PL" = 1.0, "GRM" = 1.5, 1.0)
  b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
  is_grm <- config$model == "GRM"
  has_c <- config$model == "3PL" && "c" %in% names(item_bank)
  
  log_likelihood <- numeric(n_theta)
  
  for (j in seq_along(responses)) {
    item_idx <- administered[j]
    a <- item_bank$a[item_idx]
    if (is.na(a)) a <- default_a
    resp <- as.integer(responses[j])
    
    if (is_grm) {
      b <- as.numeric(item_bank[item_idx, b_cols])
      if (length(b) == 0) return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
      if (any(is.na(b))) {
        na_idx <- which(is.na(b))
        for (k in na_idx) b[k] <- (k - (length(b) + 1) / 2) * 1.2
        b <- sort(b)
        for (k in 2:length(b)) if (b[k] <= b[k-1]) b[k] <- b[k-1] + 0.1
      }
      n_cat <- length(b) + 1
      if (is.na(resp) || resp < 1 || resp > n_cat) next
      P_star_mid <- vapply(b, function(bk) 1 / (1 + exp(-a * (theta_grid - bk))), numeric(n_theta))
      if (length(b) == 1) P_star_mid <- matrix(P_star_mid, ncol = 1)
      P_star <- cbind(1, P_star_mid, 0)
      P_cat <- pmax(P_star[, resp] - P_star[, resp + 1L], 1e-10)
      log_likelihood <- log_likelihood + log(P_cat)
    } else {
      if (is.na(resp) || !resp %in% c(0L, 1L)) next
      b_val <- item_bank$b[item_idx] %||% 0
      if (is.na(b_val)) b_val <- 0
      c_param <- if (has_c) { cv <- item_bank$c[item_idx]; if (is.na(cv)) 0.15 else cv } else 0
      p <- c_param + (1 - c_param) / (1 + exp(-a * (theta_grid - b_val)))
      # Bound away from 0 and 1: p rounds to exactly 1 for large a * (theta - b),
      # and 0 * log(0) would then give NaN at those grid points.
      p <- pmin(pmax(p, 1e-10), 1 - 1e-10)
      log_likelihood <- log_likelihood + resp * log(p) + (1 - resp) * log(1 - p)
    }
  }
  
  log_post <- log_likelihood + log(prior)
  if (all(is.na(log_post) | is.infinite(log_post))) {
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  post <- exp(log_post - max(log_post, na.rm = TRUE))
  post <- post / sum(post, na.rm = TRUE)
  
  theta_est <- sum(theta_grid * post, na.rm = TRUE)
  se_est <- sqrt(sum((theta_grid - theta_est)^2 * post, na.rm = TRUE))
  
  if (is.na(theta_est) || is.na(se_est)) {
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  return(list(theta = theta_est, se = se_est))
}
