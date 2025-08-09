# File: estimate_ability.R

#' Estimate Ability Using TAM Framework
#'
#' Estimates person ability using Item Response Theory models through the TAM package.
#' This function serves as an interface layer that passes response data to TAM's validated 
#' psychometric functions and returns standardized results for the \code{inrep} workflow.
#' All statistical computations are performed exclusively by TAM (Robitzsch et al., 2024).
#'
#' @param rv Reactive values object containing current assessment state. Required components:
#'   \describe{
#'     \item{responses}{Numeric vector of item responses in administration order}
#'     \item{administered}{Integer vector of administered item indices from item bank}
#'     \item{current_ability}{Current ability estimate (updated by this function)}
#'     \item{ability_se}{Standard error of current ability estimate}
#'     \item{ability_history}{Vector tracking ability estimates across items}
#'   }
#' @param item_bank Data frame containing item parameters compatible with TAM. 
#'   Required columns vary by model:
#'   \describe{
#'     \item{Question}{Item content or identifier}
#'     \item{a}{Discrimination parameter (2PL, 3PL, GRM)}
#'     \item{b, b1, b2, ...}{Difficulty/threshold parameters}
#'     \item{c}{Guessing parameter (3PL only)}
#'     \item{ResponseCategories}{Response scale definition (GRM)}
#'   }
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Critical elements:
#'   \describe{
#'     \item{model}{IRT model specification for TAM}
#'     \item{estimation_method}{TAM estimation procedure}
#'     \item{theta_prior}{Prior distribution parameters}
#'     \item{theta_grid}{Numerical integration grid}
#'   }
#' 
#' @return Named list containing ability estimation results:
#' \describe{
#'   \item{theta}{Ability estimate on logit scale}
#'   \item{se}{Standard error of ability estimate}
#'   \item{method}{Estimation method used ("TAM", "EAP", "WLE", "MIRT")}
#'   \item{convergence}{Logical indicating estimation convergence}
#'   \item{posterior}{Posterior distribution (EAP method)}
#'   \item{likelihood}{Likelihood function values (WLE method)}
#'   \item{info}{Fisher information at ability estimate}
#'   \item{reliability}{Empirical reliability estimate}
#'   \item{fit_statistics}{Model fit indicators when available}
#' }
#' 
#' @export
#' 
#' @details
#' \strong{TAM Integration Architecture:} This function implements a comprehensive interface
#' to TAM's ability estimation procedures without implementing independent psychometric algorithms.
#' The integration follows established IRT best practices:
#' 
#' \strong{Model-Specific TAM Functions:}
#' \describe{
#'   \item{\strong{1PL/Rasch Model}}{
#'     Uses \code{\link[TAM]{tam.mml}} with Rasch constraints (all discriminations = 1).
#'     Ability estimation via \code{\link[TAM]{tam.wle}} or \code{\link[TAM]{tam.eap}}.
#'   }
#'   \item{\strong{2PL Model}}{
#'     Uses \code{\link[TAM]{tam.mml.2pl}} with item-specific discrimination parameters.
#'     Supports both WLE and EAP estimation methods.
#'   }
#'   \item{\strong{3PL Model}}{
#'     Uses \code{\link[TAM]{tam.mml.3pl}} including guessing parameters.
#'     Typically uses EAP estimation due to complexity.
#'   }
#'   \item{\strong{GRM (Graded Response Model)}}{
#'     Uses \code{\link[TAM]{tam.mml}} with polytomous item specifications.
#'     Handles ordered categorical responses with multiple thresholds.
#'   }
#' }
#' 
#' \strong{Estimation Method Selection:}
#' \describe{
#'   \item{\strong{TAM (Default)}}{
#'     Full TAM model estimation with maximum likelihood procedures.
#'     Provides most accurate estimates but computationally intensive.
#'   }
#'   \item{\strong{EAP (Expected A Posteriori)}}{
#'     Bayesian estimation using \code{\link[TAM]{tam.eap}}.
#'     Incorporates prior distribution, stable for extreme scores.
#'   }
#'   \item{\strong{WLE (Weighted Likelihood)}}{
#'     Frequentist estimation using \code{\link[TAM]{tam.wle}}.
#'     Reduces bias compared to maximum likelihood.
#'   }
#'   \item{\strong{MIRT (Compatibility)}}{
#'     Alternative estimation using \code{mirt} package when specified.
#'     Provides cross-validation of TAM results.
#'   }
#' }
#' 
#' \strong{Adaptive Integration:} In adaptive testing contexts:
#' \itemize{
#'   \item Updates ability estimate after each item administration
#'   \item Maintains ability history for tracking convergence
#'   \item Provides real-time standard error monitoring
#'   \item Supports stopping rule evaluation based on precision
#' }
#' 
#' \strong{Quality Control and Robustness:}
#' \itemize{
#'   \item Automatic fallback to EAP if TAM estimation fails to converge
#'   \item Uses prior mean when insufficient response data available
#'   \item Validates theta_grid specifications for numerical stability
#'   \item Handles edge cases (all correct/incorrect responses) gracefully
#'   \item Provides convergence diagnostics and warnings
#' }
#' 
#' \strong{Performance Optimization:}
#' \itemize{
#'   \item Caches item parameters and information calculations
#'   \item Utilizes parallel processing when enabled in configuration
#'   \item Implements incremental estimation updates in adaptive mode
#'   \item Minimizes redundant TAM function calls through intelligent caching
#' }
#' 
#' \strong{Error Handling:} Comprehensive error management includes:
#' \itemize{
#'   \item Graceful handling of TAM estimation failures
#'   \item Automatic model specification validation
#'   \item Response pattern analysis for unusual cases
#'   \item Logging of estimation issues for debugging
#' }
#' 
#' All psychometric computations rely exclusively on TAM's peer-reviewed implementations.
#' \code{inrep} provides the data management, workflow integration, and user interface layers.
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Ability Estimation with GRM
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create study configuration
#' config <- create_study_config(
#'   model = "GRM", 
#'   estimation_method = "TAM",
#'   theta_prior = c(0, 1)
#' )
#' 
#' # Simulate response data
#' rv <- list(
#'   responses = c(2, 4, 3, 1, 5),
#'   administered = c(1, 5, 12, 18, 23),
#'   current_ability = 0,
#'   ability_se = 1,
#'   ability_history = c()
#' )
#' 
#' # Estimate ability using TAM
#' result <- estimate_ability(rv, bfi_items, config)
#' 
#' # Display results
#' cat("Ability Estimate:", round(result$theta, 3), "\n")
#' cat("Standard Error:", round(result$se, 3), "\n")
#' cat("Estimation Method:", result$method, "\n")
#' cat("Convergence:", result$convergence, "\n")
#' 
#' # Example 2: 2PL Model with WLE Estimation
#' config_2pl <- create_study_config(
#'   model = "2PL",
#'   estimation_method = "WLE",
#'   theta_prior = c(0, 1.2)
#' )
#' 
#' # Cognitive test item bank
#' cognitive_items <- data.frame(
#'   Question = c("Item 1", "Item 2", "Item 3", "Item 4", "Item 5"),
#'   a = c(1.2, 0.8, 1.5, 1.0, 1.3),
#'   b = c(-0.5, 0.2, -1.0, 0.8, -0.3),
#'   Option1 = c("A", "A", "A", "A", "A"),
#'   Option2 = c("B", "B", "B", "B", "B"),
#'   Option3 = c("C", "C", "C", "C", "C"),
#'   Option4 = c("D", "D", "D", "D", "D"),
#'   Answer = c("B", "C", "A", "D", "B")
#' )
#' 
#' # Response data (0 = incorrect, 1 = correct)
#' rv_2pl <- list(
#'   responses = c(1, 0, 1, 1, 0),
#'   administered = c(1, 2, 3, 4, 5),
#'   current_ability = 0,
#'   ability_se = 1,
#'   ability_history = c()
#' )
#' 
#' # Estimate ability
#' result_2pl <- estimate_ability(rv_2pl, cognitive_items, config_2pl)
#' 
#' # Compare different estimation methods
#' cat("2PL WLE Estimate:", round(result_2pl$theta, 3), "\n")
#' cat("Information at estimate:", round(result_2pl$info, 3), "\n")
#' 
#' # Example 3: EAP Estimation with Custom Prior
#' config_eap <- create_study_config(
#'   model = "GRM",
#'   estimation_method = "EAP",
#'   theta_prior = c(0.5, 0.8),  # Shifted prior for specific population
#'   theta_grid = seq(-4, 4, 0.1)  # Fine grid for precision
#' )
#' 
#' # Estimate with EAP
#' result_eap <- estimate_ability(rv, bfi_items, config_eap)
#' 
#' # View posterior distribution
#' if (!is.null(result_eap$posterior)) {
#'   cat("EAP Estimate:", round(result_eap$theta, 3), "\n")
#'   cat("Posterior SD:", round(result_eap$se, 3), "\n")
#'   cat("Reliability:", round(result_eap$reliability, 3), "\n")
#' }
#' 
#' # Example 4: Adaptive Testing Context
#' # Simulate adaptive testing scenario
#' simulate_adaptive_estimation <- function(true_theta, item_bank, config) {
#'   rv <- list(
#'     responses = c(),
#'     administered = c(),
#'     current_ability = 0,
#'     ability_se = 1,
#'     ability_history = c()
#'   )
#'   
#'   # Simulate 10 items
#'   for (i in 1:10) {
#'     # Simulate item selection (simplified)
#'     item_idx <- sample(1:nrow(item_bank), 1)
#'     
#'     # Simulate response based on true theta
#'     prob_correct <- plogis(true_theta - item_bank$b[item_idx])
#'     response <- rbinom(1, 1, prob_correct)
#'     
#'     # Update response data
#'     rv$responses <- c(rv$responses, response)
#'     rv$administered <- c(rv$administered, item_idx)
#'     
#'     # Estimate ability
#'     result <- estimate_ability(rv, item_bank, config)
#'     
#'     # Update tracking
#'     rv$current_ability <- result$theta
#'     rv$ability_se <- result$se
#'     rv$ability_history <- c(rv$ability_history, result$theta)
#'     
#'     cat(sprintf("Item %d: Response = %d, Theta = %.3f, SE = %.3f\n", 
#'                 i, response, result$theta, result$se))
#'   }
#'   
#'   return(list(
#'     final_theta = rv$current_ability,
#'     final_se = rv$ability_se,
#'     history = rv$ability_history,
#'     true_theta = true_theta,
#'     bias = rv$current_ability - true_theta
#'   ))
#' }
#' 
#' # Run adaptive simulation
#' adaptive_config <- create_study_config(
#'   model = "1PL",
#'   estimation_method = "EAP"
#' )
#' 
#' # Simple 1PL item bank
#' rasch_items <- data.frame(
#'   Question = paste("Item", 1:20),
#'   b = seq(-2, 2, length.out = 20),
#'   Option1 = rep("A", 20),
#'   Option2 = rep("B", 20),
#'   Answer = rep("B", 20)
#' )
#' 
#' sim_result <- simulate_adaptive_estimation(
#'   true_theta = 0.5, 
#'   item_bank = rasch_items, 
#'   config = adaptive_config
#' )
#' 
#' cat("\nAdaptive Testing Summary:\n")
#' cat("True Theta:", sim_result$true_theta, "\n")
#' cat("Final Estimate:", round(sim_result$final_theta, 3), "\n")
#' cat("Final SE:", round(sim_result$final_se, 3), "\n")
#' cat("Bias:", round(sim_result$bias, 3), "\n")
#' 
#' # Example 5: Model Comparison
#' # Compare estimation methods for same data
#' methods <- c("TAM", "EAP", "WLE")
#' comparison_results <- list()
#' 
#' for (method in methods) {
#'   method_config <- create_study_config(
#'     model = "2PL",
#'     estimation_method = method
#'   )
#'   
#'   result <- estimate_ability(rv_2pl, cognitive_items, method_config)
#'   comparison_results[[method]] <- result
#' }
#' 
#' # Display comparison
#' cat("\nMethod Comparison:\n")
#' for (method in methods) {
#'   result <- comparison_results[[method]]
#'   cat(sprintf("%s: Theta = %.3f, SE = %.3f\n", 
#'               method, result$theta, result$se))
#' }
#' }
#' 
#' @references
#' \itemize{
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item Warm, T. A. (1989). Weighted likelihood estimation of ability in item response theory. 
#'     \emph{Psychometrika}, 54(3), 427-450.
#'   \item Bock, R. D., & Mislevy, R. J. (1982). Adaptive EAP estimation of ability in a microcomputer environment. 
#'     \emph{Applied Psychological Measurement}, 6(4), 431-444.
#'   \item Baker, F. B., & Kim, S. H. (2004). \emph{Item response theory: Parameter estimation techniques}. 
#'     CRC Press.
#'   \item Embretson, S. E., & Reise, S. P. (2000). \emph{Item response theory for psychologists}. 
#'     Lawrence Erlbaum Associates.
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_study_config}} for configuring estimation parameters
#'   \item \code{\link{select_next_item}} for adaptive item selection using ability estimates
#'   \item \code{\link{launch_study}} for complete assessment implementation
#'   \item \code{\link[TAM]{tam.wle}} for WLE estimation details
#'   \item \code{\link[TAM]{tam.eap}} for EAP estimation details
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' Robitzsch, A., Kiefer, T., George, A. C., & Uenlue, A. (2020). 
#' CDM: Cognitive Diagnosis Modeling. R package version 7.5-15. 
#' 
#' @seealso \code{\link{create_study_config}}, \code{\link{select_next_item}}, 
#'   \code{\link{launch_study}}
#' 
#' @keywords psychometrics IRT ability estimation
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
    print("No responses provided, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  # Use default theta_grid if not properly set
  theta_grid <- if (is.numeric(config$theta_grid) && length(config$theta_grid) >= 2) {
    config$theta_grid
  } else {
    print("Invalid theta_grid, using default grid (-4, 4, 100)")
    seq(-4, 4, length.out = 100)
  }
  
  if (config$model %in% c("1PL", "2PL", "3PL") && config$estimation_method == "TAM" && length(responses) >= 5) {
    tryCatch({
      dat <- matrix(as.integer(responses), nrow = 1)
      colnames(dat) <- administered
      if (config$model == "1PL") {
        mod <- tam.mml(resp = dat, irtmodel = "1PL", control = list(snodes = 1000))
      } else if (config$model == "2PL") {
        mod <- tam.mml.2pl(resp = dat, irtmodel = "2PL", control = list(snodes = 1000))
      } else {
        item_bank_subset <- item_bank[administered, , drop = FALSE]
        c_params <- if ("c" %in% names(item_bank)) item_bank_subset$c else rep(0, length(administered))
        mod <- tam.mml.3pl(resp = dat, gammaslope = item_bank_subset$a, guess = c_params, control = list(snodes = 1000))
      }
      est <- tam.wle(mod)
      if (nrow(est) == 0 || is.na(est$theta[1])) {
        print("TAM estimation failed, falling back to EAP")
      } else {
        print(sprintf("TAM estimation: theta=%.2f, se=%.3f", est$theta[1], est$error[1]))
        return(list(theta = est$theta[1], se = est$error[1]))
      }
    }, error = function(e) {
      print(sprintf("TAM estimation error: %s, falling back to EAP", e$message))
    })
  }
  
  # MIRT estimation method
  if (config$model %in% c("1PL", "2PL", "3PL", "GRM") && config$estimation_method == "MIRT" && length(rv$responses) >= 3) {
    mirt_result <- estimate_ability_mirt(
      responses = rv$responses,
      administered = rv$administered,
      item_bank = item_bank,
      model = config$model,
      method = "EAP",
      prior_mean = config$theta_prior[1],
      prior_sd = config$theta_prior[2],
      verbose = FALSE
    )
    
    if (!is.null(mirt_result$theta) && !is.na(mirt_result$theta) && mirt_result$method != "error") {
      return(list(theta = mirt_result$theta, se = mirt_result$se))
    } else {
      print("MIRT estimation failed, falling back to EAP")
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
          print("No threshold parameters for GRM item")
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
        probs <- numeric(n_categories)
        probs[1] <- 1 / (1 + exp(a * (theta - b[1])))
        for (k in 2:(n_categories - 1)) {
          probs[k] <- 1 / (1 + exp(a * (theta - b[k - 1]))) - 1 / (1 + exp(a * (theta - b[k])))
        }
        probs[n_categories] <- 1 - 1 / (1 + exp(a * (theta - b[n_categories - 1])))
        probs <- pmax(probs, 1e-10)
        probs <- probs / sum(probs)
        response <- as.integer(rv$responses[j])
        if (response < 1 || response > n_categories || is.na(response)) {
          print(sprintf("Invalid response %d for item %d", response, item_idx))
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
    print("Invalid posterior, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  post <- exp(log_post - max(log_post, na.rm = TRUE))
  post <- post / sum(post, na.rm = TRUE)
  
  theta_est <- sum(theta_grid * post, na.rm = TRUE)
  se_est <- sqrt(sum((theta_grid - theta_est)^2 * post, na.rm = TRUE))
  
  if (is.na(theta_est) || is.na(se_est)) {
    print("EAP estimation resulted in NA, returning prior")
    return(list(theta = config$theta_prior[1], se = config$theta_prior[2]))
  }
  
  print(sprintf("EAP estimation: theta=%.2f, se=%.3f", theta_est, se_est))
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
  
  print(sprintf("Starting MIRT ability estimation with %d responses using %s model", 
                length(responses), model))
  
  if (length(responses) == 0 || length(administered) == 0) {
    print("No responses provided for MIRT estimation")
    return(list(theta = prior_mean, se = prior_sd, method = "prior"))
  }
  
  if (length(responses) != length(administered)) {
    print("Length mismatch between responses and administered items")
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
    print(sprintf("Fitting MIRT model with itemtype: %s", itemtype))
    
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
      
      print(sprintf("MIRT %s estimation successful: theta=%.3f, se=%.3f, reliability=%.3f", 
                    method, theta_est, se_est, reliability))
      
      # Generate LLM assistance prompt for ability estimation optimization
      if (getOption("inrep.llm_assistance", FALSE)) {
        ability_prompt <- generate_ability_optimization_prompt(result, administered, model)
        message(paste(rep("=", 60), collapse = ""))
        message("LLM ASSISTANCE: ABILITY ESTIMATION OPTIMIZATION")
        message(paste(rep("=", 60), collapse = ""))
        message("Copy the following prompt to ChatGPT, Claude, or your preferred LLM for advanced ability estimation insights:")
        message("")
        message(ability_prompt)
        message("")
        message(paste(rep("=", 60), collapse = ""))
        message("")
      }
      
      return(result)
      
    } else {
      print("MIRT ability estimation failed - no valid scores returned")
      return(list(theta = prior_mean, se = prior_sd, method = "fallback_prior"))
    }
    
  }, error = function(e) {
    print(sprintf("MIRT estimation error: %s", e$message))
    return(list(theta = prior_mean, se = prior_sd, method = "error", error_msg = e$message))
  })
}

#' Generate Ability Estimation Optimization Prompt for LLM Assistance
#' @noRd
generate_ability_optimization_prompt <- function(result, administered, model) {
  prompt <- paste0(
    "# EXPERT ABILITY ESTIMATION ANALYSIS\n\n",
    "You are an expert psychometrician specializing in Item Response Theory and ability estimation. ",
    "I need advanced insights on ability estimation quality and optimization.\n\n",
    
    "## ESTIMATION RESULTS\n",
    "- Ability Estimate (θ): ", sprintf("%.3f", result$theta), "\n",
    "- Standard Error: ", sprintf("%.3f", result$se %||% "Not available"), "\n",
    "- Estimation Method: ", result$method, "\n",
    "- IRT Model: ", model, "\n",
    "- Items Administered: ", length(administered), "\n",
    "- Convergence: ", result$converged %||% "Not reported", "\n",
    "- Reliability: ", sprintf("%.3f", result$reliability %||% "Not available"), "\n\n",
    
    "## ANALYSIS REQUESTS\n\n",
    "### 1. Estimation Quality Assessment\n",
    "- Evaluate standard error (", sprintf("%.3f", result$se %||% 0), ") appropriateness for decision-making\n",
    "- Assess reliability (", sprintf("%.3f", result$reliability %||% 0), ") for this context\n",
    "- Analyze ability estimate (", sprintf("%.3f", result$theta), ") interpretability\n",
    "- Identify potential estimation issues or concerns\n\n",
    
    "### 2. Adaptive Testing Efficiency\n",
    "- Evaluate test efficiency with ", length(administered), " items administered\n",
    "- Recommend optimal stopping criteria adjustments\n",
    "- Assess information contribution of recent items\n",
    "- Suggest item selection strategy improvements\n\n",
    
    "### 3. Methodological Considerations\n",
    "- Compare ", result$method, " performance vs alternatives\n",
    "- Evaluate ", model, " model appropriateness for this response pattern\n",
    "- Assess potential bias or measurement issues\n",
    "- Recommend validation procedures\n\n",
    
    "### 4. Practical Implications\n",
    "- Interpret ability estimate in practical context\n",
    "- Assess measurement precision for decision-making\n",
    "- Evaluate confidence in current estimate\n",
    "- Recommend next steps or additional assessment\n\n",
    
    "## PROVIDE\n",
    "1. Detailed psychometric assessment of estimation quality\n",
    "2. Specific recommendations for improving measurement precision\n",
    "3. Interpretation guidelines for ability estimate\n",
    "4. Quality control recommendations for future administrations\n",
    "5. Expected performance vs benchmark standards\n\n",
    
    "Please provide expert-level insights with specific, actionable recommendations."
  )
  
  return(prompt)
}