# File: estimate_ability.R

#' Estimate Ability Using IRT Models
#'
#' Estimates person ability from item responses. Uses TAM for model fitting
#' when enough responses are available (>= 3 with variability). Falls back to
#' a direct EAP computation using pre-calibrated item parameters otherwise.
#'
#' @param rv Reactive values object or a simple numeric response vector.
#'   When a list, requires \code{$responses}, \code{$administered},
#'   and \code{$current_ability}.
#' @param item_bank Data frame with item parameters. Required columns depend
#'   on model: \code{a}, \code{b} for 2PL; \code{a}, \code{b}, \code{c} for 3PL;
#'   \code{a}, \code{b1}, \code{b2}, ... for GRM.
#' @param config Study configuration (from \code{\link{create_study_config}})
#'   or a model name string (e.g., \code{"2PL"}).
#'
#' @return List with \code{theta} (ability estimate) and \code{se} (standard error).
#'
#' @details
#' \strong{TAM path}: When \code{estimation_method} is \code{"EAP"} or \code{"WLE"},
#' the model has >= 3 responses with variability, and TAM is available, the function
#' fits a TAM model and extracts person parameters.
#'
#' \strong{Fallback path}: Computes EAP directly from pre-calibrated item parameters
#' (the \code{item_bank} a/b values). This uses correct IRT probability functions:
#' 2PL/3PL logistic, Samejima GRM boundary curves.
#'
#' TAM model mapping: 1PL -> \code{tam.mml}, 2PL -> \code{tam.mml.2pl},
#' 3PL -> \code{tam.mml.3pl}. For GRM, TAM fits a GPCM (Generalized Partial
#' Credit Model) with step parameters, which differs from Samejima's GRM
#' parameterization used in the item bank. The fallback path uses the correct
#' Samejima formulation with the pre-calibrated threshold parameters.
#' GRM support is experimental; 1PL/2PL/3PL are fully supported.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' config <- create_study_config(model = "GRM", estimation_method = "EAP")
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
#' Robitzsch, A., Kiefer, T., & Wu, M. (2024). \emph{TAM: Test Analysis Modules}.
#'   R package. \url{https://CRAN.R-project.org/package=TAM}
#'
#' Warm, T. A. (1989). Weighted likelihood estimation of ability in item response theory.
#'   \emph{Psychometrika}, 54(3), 427--450.
#'
#' @seealso \code{\link{create_study_config}}, \code{\link{select_next_item}},
#'   \code{\link{launch_study}}
#'
#' @keywords psychometrics IRT
estimate_ability <- function(rv, item_bank, config) {
  # Handle both reactive values and simple vectors
  if (is.list(rv) && !is.null(rv$responses)) {
    # Standard reactive values object
    responses <- rv$responses
    administered <- rv$administered
    current_ability <- rv$current_ability
  } else if (is.atomic(rv) && !is.null(rv)) {
    # Simple vector input (for testing)
    responses <- rv
    administered <- seq_along(responses)
    current_ability <- 0
  } else {
    # Handle other cases
    stop("rv must be either a reactive values object with $responses component or a simple vector")
  }
  
  # Handle config parameter - if it's a simple string, create a basic config
  if (is.character(config)) {
    model <- config
    config <- list(
      model = model,
      estimation_method = "TAM",
      theta_prior = c(0, 1),
      theta_grid = seq(-4, 4, length.out = 100)
    )
  }
  
  # logger(sprintf("Estimating ability for %d responses", length(responses)), level = "INFO")
  
  if (length(responses) == 0) {
    message("No responses provided, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  # Use default theta_grid if not properly set
  theta_grid <- if (is.numeric(config$theta_grid) && length(config$theta_grid) >= 2) {
    config$theta_grid
  } else {
    message("Invalid theta_grid, using default grid (-4, 4, 100)")
    seq(-4, 4, length.out = 100)
  }
  
  # TAM package estimation for all models (EAP or WLE)
  use_tam <- config$estimation_method %in% c("EAP", "WLE") && 
             config$model %in% c("1PL", "2PL", "3PL", "GRM") && 
             length(responses) >= 3 && 
             requireNamespace("TAM", quietly = TRUE)
  
  if (use_tam) {
    # Require variability to avoid degenerate fits
    if (length(unique(na.omit(as.integer(responses)))) > 1) {
      tryCatch({
        dat <- matrix(as.integer(responses), nrow = 1)
        colnames(dat) <- administered
        ctrl <- list(snodes = 500, progress = FALSE, verbose = FALSE)
        
        # Fit appropriate TAM model
        if (config$model == "1PL") {
          mod <- suppressMessages(TAM::tam.mml(resp = dat, irtmodel = "1PL", control = ctrl))
        } else if (config$model == "2PL") {
          mod <- suppressMessages(TAM::tam.mml.2pl(resp = dat, irtmodel = "2PL", control = ctrl))
        } else if (config$model == "3PL") {
          item_bank_subset <- item_bank[administered, , drop = FALSE]
          c_params <- if ("c" %in% names(item_bank_subset)) item_bank_subset$c else rep(0, length(administered))
          slopes <- if ("a" %in% names(item_bank_subset)) item_bank_subset$a else rep(1, length(administered))
          mod <- suppressMessages(TAM::tam.mml.3pl(resp = dat, gammaslope = slopes, guess = c_params, control = ctrl))
        } else if (config$model == "GRM") {
          # TAM fits the Generalized Partial Credit Model (GPCM) with step
          # parameters—a different model from Samejima's GRM. The item bank
          # b1/b2/... columns are Samejima boundary thresholds, not GPCM step
          # parameters. Ability estimates from this path are approximate.
          # The EAP fallback below uses the correct Samejima GRM formulation
          # with the pre-calibrated threshold parameters.
          mod <- suppressMessages(TAM::tam.mml(resp = dat, irtmodel = "GPCM", control = ctrl))
        }
        
        # Apply requested estimation method
        if (config$estimation_method == "WLE") {
          # WLE: Weighted Likelihood Estimation (frequentist)
          est <- suppressMessages(TAM::tam.wle(mod))
          theta_est <- est$theta[1]
          se_est <- est$error[1]
          method_name <- "WLE"
        } else {
          # EAP: Expected A Posteriori (Bayesian) - extract from fitted model
          theta_est <- mod$person$EAP[1]
          se_est <- mod$person$SE.EAP[1]
          method_name <- "EAP"
        }
        
        if (is.finite(theta_est) && is.finite(se_est)) {
          message(sprintf("TAM %s estimation: theta=%.2f, se=%.3f", method_name, theta_est, se_est))
          return(list(theta = theta_est, se = se_est))
        } else {
          message(sprintf("TAM %s estimation produced invalid result, using fallback", method_name))
        }
      }, error = function(e) {
        message(sprintf("TAM estimation error: %s, using fallback", e$message))
      })
    } else {
      message("Insufficient response variability for TAM, using fallback")
    }
  }
  
  # EAP estimation as fallback
  prior <- dnorm(theta_grid, config$theta_prior[1], config$theta_prior[2])
  prior <- prior / sum(prior)
  
  log_likelihood <- numeric(length(theta_grid))
  for (i in seq_along(theta_grid)) {
    theta <- theta_grid[i]
    ll <- 0
    for (j in seq_along(rv$responses)) {
      item_idx <- rv$administered[j]
      
      # Handle unknown (NA) discrimination parameter
      a <- item_bank$a[item_idx]
      if (is.na(a)) {
        # Use default discrimination based on model
        a <- switch(config$model,
          "1PL" = 1.0,
          "2PL" = 1.2,
          "3PL" = 1.0,
          "GRM" = 1.5,
          1.0  # fallback
        )
      }
      
      b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
      b <- if (length(b_cols) > 0) as.numeric(item_bank[item_idx, b_cols]) else numeric(0)
      
      if (config$model == "GRM") {
        if (length(b) == 0) {
          message("No threshold parameters for GRM item")
          return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
        }
        
        # Handle unknown threshold parameters
        if (any(is.na(b))) {
          na_indices <- which(is.na(b))
          for (k in na_indices) {
            # Create ordered default thresholds
            b[k] <- (k - (length(b) + 1) / 2) * 1.2
          }
          # Ensure proper ordering
          b <- sort(b)
          for (k in 2:length(b)) {
            if (b[k] <= b[k-1]) {
              b[k] <- b[k-1] + 0.1
            }
          }
        }
        
        n_categories <- length(b) + 1
        # Samejima GRM: boundary characteristic curves P*_j = 1/(1+exp(-a*(theta-b_j)))
        P_star <- c(1, vapply(b, function(bk) {
          1 / (1 + exp(-a * (theta - bk)))
        }, numeric(1)), 0)
        # Category probabilities: P_k = P*_k - P*_{k+1}
        probs <- pmax(P_star[1:n_categories] - P_star[2:(n_categories + 1)], 1e-10)
        probs <- probs / sum(probs)
        response <- as.integer(rv$responses[j])
        if (response < 1 || response > n_categories || is.na(response)) {
          message(sprintf("Invalid response %d for item %d", response, item_idx))
          next
        }
        ll <- ll + log(probs[response])
      } else {
        # Handle unknown difficulty parameter for dichotomous models
        b_single <- item_bank$b[item_idx] %||% 0
        if (is.na(b_single)) {
          b_single <- 0  # Default difficulty at average
        }
        
        # Handle unknown guessing parameter
        c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) {
          c_val <- item_bank$c[item_idx]
          if (is.na(c_val)) 0.15 else c_val  # Default guessing rate
        } else 0
        
        p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b_single)))
        p <- pmax(p, 1e-10)
        response <- as.integer(rv$responses[j])
        ll <- ll + (response * log(p) + (1 - response) * log(1 - p))
      }
    }
    log_likelihood[i] <- ll
  }
  
  log_post <- log_likelihood + log(prior)
  if (all(is.na(log_post) | is.infinite(log_post))) {
    message("Invalid posterior, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  post <- exp(log_post - max(log_post, na.rm = TRUE))
  post <- post / sum(post, na.rm = TRUE)
  
  theta_est <- sum(theta_grid * post, na.rm = TRUE)
  se_est <- sqrt(sum((theta_grid - theta_est)^2 * post, na.rm = TRUE))
  
  if (is.na(theta_est) || is.na(se_est)) {
    message("EAP estimation resulted in NA, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  message(sprintf("EAP estimation: theta=%.2f, se=%.3f", theta_est, se_est))
  return(list(theta = theta_est, se = se_est))
}

#' Advanced MIRT Ability Estimation
#'
#' Estimates ability using the mirt package with advanced options.
#'
#' @param responses Vector of item responses.
#' @param administered Vector of administered item indices.
#' @param item_bank Data frame containing item parameters.
#' @param model IRT model ("1PL", "2PL", "3PL", "GRM").
#' @param method Estimation method ("EAP", "MAP", "ML", "WLE").
#' @param prior_mean Prior mean for ability (default: 0).
#' @param prior_sd Prior standard deviation for ability (default: 1).
#' @param n_synthetic Number of synthetic response patterns for model fitting (default: 500).
#' @param verbose Whether to print detailed output (default: FALSE).
#' @return List containing theta estimate, standard error, and additional mirt output.
#' @export
estimate_ability_mirt <- function(responses, administered, item_bank, model = "2PL", 
                                  method = "EAP", prior_mean = 0, prior_sd = 1, 
                                  n_synthetic = 500, verbose = FALSE) {
  
  message(sprintf("Starting MIRT ability estimation with %d responses using %s model", 
                length(responses), model))
  
  if (length(responses) == 0 || length(administered) == 0) {
    message("No responses provided for MIRT estimation")
    return(list(theta = prior_mean, se = prior_sd, method = "prior"))
  }
  
  if (length(responses) != length(administered)) {
    message("Length mismatch between responses and administered items")
    return(list(theta = prior_mean, se = prior_sd, method = "error"))
  }
  
  tryCatch({
    # Check if mirt package is available
    if (!requireNamespace("mirt", quietly = TRUE)) {
      warning("mirt package not available. Falling back to TAM estimation.")
      return(list(theta = prior_mean, se = prior_sd, method = "error"))
    }
    
    # Prepare response matrix
    dat <- matrix(as.integer(responses), nrow = 1)
    colnames(dat) <- paste0("Item", administered)
    
    # Get item parameters for administered items
    item_params <- item_bank[administered, , drop = FALSE]
    
    # Handle unknown parameters with initialization
    for (i in 1:nrow(item_params)) {
      # Handle unknown discrimination
      if (is.na(item_params$a[i])) {
        item_params$a[i] <- switch(model,
          "1PL" = 1.0,
          "2PL" = 1.2,
          "3PL" = 1.0,
          "GRM" = 1.5,
          1.0
        )
      }
      
      # Handle unknown difficulty/threshold parameters
      if (model == "GRM") {
        b_cols <- grep("^b[0-9]+$", names(item_params), value = TRUE)
        for (j in seq_along(b_cols)) {
          col <- b_cols[j]
          if (is.na(item_params[[col]][i])) {
            # Create ordered default threshold
            item_params[[col]][i] <- (j - (length(b_cols) + 1) / 2) * 1.2
          }
        }
        # Ensure threshold ordering for this item
        thresholds <- as.numeric(item_params[i, b_cols])
        if (any(diff(thresholds) <= 0)) {
          sorted_thresholds <- sort(thresholds)
          for (k in 2:length(sorted_thresholds)) {
            if (sorted_thresholds[k] <= sorted_thresholds[k-1]) {
              sorted_thresholds[k] <- sorted_thresholds[k-1] + 0.1
            }
          }
          item_params[i, b_cols] <- sorted_thresholds
        }
      } else {
        # Handle unknown difficulty for dichotomous models
        if ("b" %in% names(item_params) && is.na(item_params$b[i])) {
          item_params$b[i] <- 0
        }
      }
      
      # Handle unknown guessing parameter
      if (model == "3PL" && "c" %in% names(item_params) && is.na(item_params$c[i])) {
        item_params$c[i] <- 0.15
      }
    }
    
    # Generate synthetic data for model fitting (mirt requires multiple response patterns)
    theta_sim <- stats::rnorm(n_synthetic, prior_mean, prior_sd)
    synthetic_data <- matrix(NA, nrow = n_synthetic, ncol = length(administered))
    colnames(synthetic_data) <- paste0("Item", administered)
    
    # Generate synthetic responses based on true item parameters
    for (i in seq_along(administered)) {
      a_param <- item_params$a[i]
      b_param <- item_params$b[i]
      c_param <- if ("c" %in% names(item_params)) item_params$c[i] else 0
      
      if (model == "GRM") {
        # Graded Response Model
        max_score <- if ("max_score" %in% names(item_params)) item_params$max_score[i] else 4
        # Create threshold parameters
        if ("d1" %in% names(item_params)) {
          # Use explicit threshold parameters if available
          thresholds <- c()
          for (k in 1:max_score) {
            thresh_name <- paste0("d", k)
            if (thresh_name %in% names(item_params)) {
              thresholds <- c(thresholds, item_params[[thresh_name]][i])
            }
          }
          if (length(thresholds) == 0) {
            thresholds <- seq(b_param - 1.5, b_param + 1.5, length.out = max_score)
          }
        } else {
          # Generate thresholds around b parameter
          thresholds <- seq(b_param - 1.5, b_param + 1.5, length.out = max_score)
        }
        
        # Calculate category probabilities
        probs <- matrix(0, nrow = n_synthetic, ncol = max_score + 1)
        
        # P*(theta) for each threshold
        for (k in 1:max_score) {
          probs[, k + 1] <- 1 / (1 + exp(-a_param * (theta_sim - thresholds[k])))
        }
        
        # Convert to category probabilities
        probs[, 1] <- 1 - probs[, 2]  # P(X=0)
        for (k in 2:max_score) {
          probs[, k + 1] <- probs[, k + 1] - probs[, k]  # P(X=k)
        }
        
        # Ensure probabilities are non-negative
        probs[probs < 0] <- 0
        
        # Sample responses
        synthetic_data[, i] <- apply(probs, 1, function(p) {
          if (sum(p) == 0) return(0)
          sample(0:max_score, 1, prob = p / sum(p))
        })
        
      } else {
        # Dichotomous models (1PL, 2PL, 3PL)
        prob <- c_param + (1 - c_param) / (1 + exp(-a_param * (theta_sim - b_param)))
        synthetic_data[, i] <- stats::rbinom(n_synthetic, 1, prob)
      }
    }
    
    # Combine actual response with synthetic data
    full_data <- rbind(dat, synthetic_data)
    
    # Determine itemtype for mirt
    itemtype <- switch(model,
                      "1PL" = "Rasch",
                      "2PL" = "2PL", 
                      "3PL" = "3PL",
                      "GRM" = "graded")
    
    # Fit mirt model
    message(sprintf("Fitting MIRT model with itemtype: %s", itemtype))
    
    mirt_model <- mirt::mirt(data = full_data, 
                            model = 1, 
                            itemtype = itemtype, 
                            verbose = verbose,
                            SE = TRUE,
                            technical = list(NCYCLES = 500))
    
    # Set up prior for ability estimation
    if (method %in% c("EAP", "MAP")) {
      prior_params <- list(mean = prior_mean, cov = prior_sd^2)
    } else {
      prior_params <- NULL
    }
    
    # Estimate ability for actual response pattern
    ability_scores <- mirt::fscores(object = mirt_model, 
                                   response.pattern = dat,
                                   method = method,
                                   full.scores = FALSE,
                                   scores.only = FALSE,
                                   prior = prior_params)
    
    if (!is.null(ability_scores) && nrow(ability_scores) > 0 && !is.na(ability_scores[1, 1])) {
      theta_est <- ability_scores[1, 1]
      se_est <- if (ncol(ability_scores) > 1) ability_scores[1, 2] else NA
      
      # Extract additional information
      fit_stats <- mirt::M2(mirt_model, type = "C2")
      reliability <- mirt::empirical_rxx(ability_scores)
      
      result <- list(
        theta = theta_est,
        se = se_est,
        method = paste("MIRT", method),
        model = model,
        fit_stats = fit_stats,
        reliability = reliability,
        n_items = length(administered),
        converged = mirt::extract.mirt(mirt_model, "converged")
      )
      
      message(sprintf("MIRT %s estimation successful: theta=%.3f, se=%.3f, reliability=%.3f", 
                    method, theta_est, se_est, reliability))
      
      
      return(result)
      
    } else {
      message("MIRT ability estimation failed - no valid scores returned")
      return(list(theta = prior_mean, se = prior_sd, method = "fallback_prior"))
    }
    
  }, error = function(e) {
    message(sprintf("MIRT estimation error: %s", e$message))
    return(list(theta = prior_mean, se = prior_sd, method = "error", error_msg = e$message))
  })
}
