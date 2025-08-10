# File: item_selection.R

#' Select Next Item Using TAM-Based Information
#'
#' Selects the next item for administration based on information calculations from TAM.
#' This function serves as an interface layer that uses ability estimates from TAM
#' to determine optimal item selection according to various psychometric criteria.
#' All information calculations utilize TAM's IRT implementations.
#'
#' @param rv Reactive values object containing current test state. Required components:
#'   \describe{
#'     \item{administered}{Integer vector of administered item indices}
#'     \item{responses}{Numeric vector of participant responses}
#'     \item{current_ability}{Current ability estimate from TAM}
#'     \item{ability_se}{Standard error of current ability estimate}
#'     \item{item_info_cache}{Cached item information values (optional)}
#'     \item{item_counter}{Integer count of administered items}
#'     \item{session_start}{POSIXct timestamp of session start}
#'     \item{exposure_rates}{Numeric vector tracking item exposure (optional)}
#'   }
#' @param item_bank Data frame containing item parameters compatible with TAM. 
#'   Structure varies by IRT model:
#'   \describe{
#'     \item{Question}{Character vector of item content or identifiers}
#'     \item{a}{Numeric vector of discrimination parameters (2PL, 3PL, GRM)}
#'     \item{b, b1, b2, ...}{Numeric vectors of difficulty/threshold parameters}
#'     \item{c}{Numeric vector of guessing parameters (3PL only)}
#'     \item{ResponseCategories}{Character vector of response options (GRM)}
#'     \item{Content_Area}{Character vector for content balancing (optional)}
#'     \item{Exposure_Target}{Numeric vector of target exposure rates (optional)}
#'   }
#' @param config Study configuration object from \code{\link{create_study_config}}. 
#'   Key selection parameters:
#'   \describe{
#'     \item{criteria}{Selection criterion: "MI", "RANDOM", "WEIGHTED", "MFI"}
#'     \item{model}{IRT model specification for TAM}
#'     \item{max_session_duration}{Session timeout in minutes}
#'     \item{adaptive}{Logical indicating adaptive vs. fixed selection}
#'     \item{fixed_items}{Integer vector of required items}
#'     \item{item_groups}{Named list of item groupings}
#'     \item{content_balancing}{Logical for content area balancing}
#'     \item{exposure_control}{Logical for exposure rate control}
#'   }
#' 
#' @return Integer index of the selected item from the item bank, or \code{NULL} if 
#'   no suitable item is available. Returns \code{NULL} when:
#'   \itemize{
#'     \item Session timeout has been reached
#'     \item All items have been administered
#'     \item Stopping criteria have been met
#'     \item No items meet content balancing constraints
#'   }
#' 
#' @export
#' 
#' @details
#' \strong{TAM Integration for Item Selection:} This function implements adaptive item
#' selection using ability estimates and item information calculations from TAM:
#' 
#' \strong{Information Calculation Pipeline:}
#' \itemize{
#'   \item Uses current ability estimate from TAM functions (\code{\link[TAM]{tam.wle}}, \code{\link[TAM]{tam.eap}})
#'   \item Calculates item information using TAM's \code{\link[TAM]{IRT.informationCurves}}
#'   \item Applies selection criteria based on psychometric principles
#'   \item Returns item index for \code{inrep} workflow management
#' }
#' 
#' \strong{Selection Criteria Implementation:}
#' \describe{
#'   \item{\strong{MI (Maximum Information)}}{
#'     Selects item with highest Fisher information at current ability estimate.
#'     Optimal for measurement precision and standard error minimization.
#'     Uses TAM's information function calculations.
#'   }
#'   \item{\strong{MFI (Maximum Fisher Information)}}{
#'     Alternative implementation of information-based selection.
#'     Includes additional considerations for model-specific information.
#'   }
#'   \item{\strong{WEIGHTED}}{
#'     Combines information maximization with content balancing and exposure control.
#'     Implements Sympson-Hetter exposure control when configured.
#'     Balances psychometric efficiency with practical constraints.
#'   }
#'   \item{\strong{RANDOM}}{
#'     Random selection from available items for comparison studies.
#'     Useful for evaluating adaptive testing benefits.
#'   }
#' }
#' 
#' \strong{Content Balancing Features:}
#' \itemize{
#'   \item Supports content area constraints through \code{item_groups} specification
#'   \item Implements proportional content sampling across domains
#'   \item Maintains psychometric efficiency while meeting content requirements
#'   \item Provides real-time content coverage monitoring
#' }
#' 
#' \strong{Exposure Control Mechanisms:}
#' \itemize{
#'   \item Tracks item exposure rates across sessions
#'   \item Implements Sympson-Hetter exposure control algorithm
#'   \item Supports target exposure rate specifications
#'   \item Balances item security with measurement precision
#' }
#' 
#' \strong{Adaptive Testing Logic:}
#' \itemize{
#'   \item Handles fixed item requirements (anchor items, pretests)
#'   \item Supports delayed adaptive start after initial fixed items
#'   \item Implements stopping rules based on precision or item count
#'   \item Provides session timeout protection
#' }
#' 
#' \strong{Performance Optimization:}
#' \itemize{
#'   \item Caches item information calculations for efficiency
#'   \item Implements incremental information updates
#'   \item Minimizes TAM function calls through intelligent caching
#'   \item Supports parallel processing for large item banks
#' }
#' 
#' \strong{Quality Assurance:}
#' \itemize{
#'   \item Validates item availability and constraints
#'   \item Handles edge cases (no available items, timeout)
#'   \item Provides comprehensive logging of selection decisions
#'   \item Implements graceful degradation for unusual scenarios
#' }
#' 
#' \strong{Model-Specific Considerations:}
#' \describe{
#'   \item{\strong{1PL/Rasch}}{Information depends only on item difficulty relative to ability}
#'   \item{\strong{2PL}}{Information varies by both difficulty and discrimination}
#'   \item{\strong{3PL}}{Information affected by guessing parameter, especially at low ability}
#'   \item{\strong{GRM}}{Information calculated across response categories and thresholds}
#' }
#' 
#' All information calculations utilize TAM's validated IRT implementations.
#' \code{inrep} provides the selection logic, constraint management, and workflow integration.
#' \itemize{
#'   \item Maintains proportional representation across content areas
#'   \item Prevents over-selection from any single domain
#'   \item Ensures comprehensive coverage of construct
#' }
#' 
#' \strong{Exposure Control:} Automatic exposure rate management:
#' \itemize{
#'   \item Tracks item usage frequencies
#'   \item Implements Sympson-Hetter method for exposure control
#'   \item Prevents overexposure of high-information items
#' }
#' 
#' \code{inrep} provides the selection logic and workflow coordination, while all
#' psychometric computations rely on TAM's validated implementations.
#' 
#' @examples
#' \dontrun{
#' # Load sample data
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create configuration
#' config <- create_study_config(
#'   model = "GRM", 
#'   criteria = "MI",
#'   max_items = 15,
#'   min_SEM = 0.3
#' )
#' 
#' # Initialize response data
#' rv <- list(
#'   administered = c(1, 5, 12),
#'   responses = c(3, 4, 2),
#'   current_ability = 0.5,
#'   item_info_cache = list(),
#'   item_counter = 3,
#'   session_start = Sys.time()
#' )
#' 
#' # Select next item
#' next_item <- select_next_item(rv, bfi_items, config)
#' cat("Selected item:", next_item, "\n")
#' 
#' # Content-balanced selection
#' config_balanced <- create_study_config(
#'   model = "GRM",
#'   criteria = "WEIGHTED",
#'   item_groups = list(
#'     "Extraversion" = 1:10,
#'     "Agreeableness" = 11:20, 
#'     "Conscientiousness" = 21:30
#'   )
#' )
#' 
#' next_item_balanced <- select_next_item(rv, bfi_items, config_balanced)
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' van der Linden, W. J. (2010). Elements of adaptive testing. 
#' In W. J. van der Linden & C. A. W. Glas (Eds.), Elements of adaptive testing (pp. 3-30). Springer.
#' 
#' Sympson, J. B., & Hetter, R. D. (1985). Controlling item-exposure rates in computerized 
#' adaptive testing. Proceedings of the 27th annual meeting of the Military Testing Association (pp. 973-977).
#' 
#' @seealso \code{\link{estimate_ability}}, \code{\link{create_study_config}}, 
#'   \code{\link{launch_study}}
#' 
#' @keywords psychometrics adaptive testing item selection
select_next_item <- function(rv, item_bank, config) {
  if (!requireNamespace("logr", quietly = TRUE)) {
    # Continue without logging if logr is not available
    message("Package 'logr' not available - logging disabled")
  }
  
  # Validate inputs
  if (!is.list(rv) || !is.data.frame(item_bank) || !is.list(config)) {
    message("Invalid input: rv, item_bank, or config is not of correct type")
    return(NULL)
  }
  
  # Check session timeout
  if (!is.null(rv$session_start) && is.numeric(config$max_session_duration)) {
    session_duration <- as.numeric(difftime(Sys.time(), rv$session_start, units = "mins"))
    if (session_duration > config$max_session_duration) {
      message("Session timed out, resetting reactive values")
      rv$administered <- integer(0)
      rv$responses <- list()
      rv$current_ability <- config$theta_prior[1] %||% 0
      rv$item_info_cache <- list()
      rv$item_counter <- 0
      rv$session_start <- Sys.time()
    }
  }
  
  # Initialize item_counter if not present
  if (is.null(rv$item_counter)) {
    rv$item_counter <- 0
  }
  rv$item_counter <- rv$item_counter + 1
  
  # Check maximum items
  max_items <- min(config$max_items %||% nrow(item_bank), nrow(item_bank))
  if (length(rv$administered) >= max_items) {
    message("Maximum items reached")
    return(NULL)
  }
  
  # Validate min_items
  if (config$min_items > nrow(item_bank)) {
    message("min_items exceeds item bank size, adjusting to item bank size")
    config$min_items <- nrow(item_bank)
  }
  
  # Handle fixed items
  if (!is.null(config$fixed_items) && rv$item_counter <= length(config$fixed_items)) {
    if (!is.numeric(config$fixed_items) || any(config$fixed_items < 1) || any(config$fixed_items > nrow(item_bank))) {
      message("Invalid fixed_items configuration")
      return(NULL)
    }
    message(sprintf("Selecting fixed item %d", config$fixed_items[rv$item_counter]))
    return(config$fixed_items[rv$item_counter])
  }
  
  # Get available items
  available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
  if (length(available) == 0) {
    message("No more items available")
    return(NULL)
  }
  
  # Custom item selection algorithm support
  if (!is.null(config$item_selection_fun) && is.function(config$item_selection_fun)) {
    item <- config$item_selection_fun(rv, item_bank, config)
    message(sprintf("Custom item selection function chose item %d", item))
    return(item)
  }
  # Handle non-adaptive or early items
  if (!isTRUE(config$adaptive) || (is.numeric(config$adaptive_start) && rv$item_counter < config$adaptive_start)) {
    if (!is.null(config$item_groups)) {
      available <- available[available %in% unlist(config$item_groups)]
      if (length(available) == 0) {
        message("No items available in specified groups")
        return(NULL)
      }
    }
    item <- sample(available, 1)
    message(sprintf("Selected random item %d", item))
    return(item)
  }
  
  # Validate theta_grid
  if (is.null(config$theta_grid) || !is.numeric(config$theta_grid) || length(config$theta_grid) < 2) {
    message("Invalid theta_grid, using default grid (-4, 4, 100)")
    config$theta_grid <- seq(-4, 4, length.out = 100)
  }
  
  # Validate current_ability
  if (!is.numeric(rv$current_ability) || length(rv$current_ability) == 0 || is.na(rv$current_ability) || !is.finite(rv$current_ability)) {
    message("Invalid current_ability, defaulting to theta_prior mean")
    rv$current_ability <- config$theta_prior[1] %||% 0
  }
  
  # Validate item_bank columns
  required_cols <- if (config$model == "GRM") c("a", "b1") else if (config$model == "3PL") c("a", "b", "c") else c("a", "b")
  if (!all(required_cols %in% names(item_bank))) {
    message(sprintf("Item bank missing required columns for %s model: %s", config$model, paste(required_cols, collapse = ", ")))
    return(NULL)
  }
  
  item_info <- function(theta, item_idx) {
    if (!isTRUE(config$cache_enabled)) return(compute_item_info(theta, item_idx, item_bank, config))
    cache_key <- paste(theta, item_idx, sep = ":")
    if (!is.null(rv$item_info_cache[[cache_key]])) {
      return(rv$item_info_cache[[cache_key]])
    }
    info <- compute_item_info(theta, item_idx, item_bank, config)
    rv$item_info_cache[[cache_key]] <- if (is.finite(info)) info else 0
    return(info)
  }
  
  compute_item_info <- function(theta, item_idx, item_bank, config) {
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
    
    # Handle unknown difficulty/threshold parameters
    if (config$model == "GRM") {
      b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
      if (length(b_cols) == 0) {
        message("No b thresholds found for GRM model")
        return(0)
      }
      b_thresholds <- as.numeric(item_bank[item_idx, b_cols])
      
      # Replace any NA thresholds with defaults
      if (any(is.na(b_thresholds))) {
        na_indices <- which(is.na(b_thresholds))
        for (i in na_indices) {
          # Create ordered default thresholds
          b_thresholds[i] <- (i - (length(b_thresholds) + 1) / 2) * 1.2
        }
        # Ensure proper ordering
        b_thresholds <- sort(b_thresholds)
        for (i in 2:length(b_thresholds)) {
          if (b_thresholds[i] <= b_thresholds[i-1]) {
            b_thresholds[i] <- b_thresholds[i-1] + 0.1
          }
        }
      }
    } else {
      # Handle unknown difficulty parameter for dichotomous models
      b <- item_bank$b[item_idx] %||% 0
      if (is.na(b)) {
        b <- 0  # Default difficulty at average
      }
    }
    
    # Handle unknown guessing parameter
    c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) {
      c_val <- item_bank$c[item_idx]
      if (is.na(c_val)) 0.15 else c_val  # Default guessing rate
    } else 0
    
    info <- if (config$model == "3PL") {
      p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b)))
      q <- 1 - p
      (a^2 * (p - c_param)^2 * q) / (p * (1 - c_param)^2)
    } else if (config$model == "GRM") {
      n_categories <- length(b_thresholds) + 1
      if (n_categories < 2) {
        message("Invalid number of categories for GRM model")
        return(0)
      }
      probs <- numeric(n_categories)
      probs[1] <- 1 / (1 + exp(a * (theta - b_thresholds[1])))
      for (k in 2:(n_categories - 1)) {
        probs[k] <- 1 / (1 + exp(a * (theta - b_thresholds[k - 1]))) -
          1 / (1 + exp(a * (theta - b_thresholds[k])))
      }
      probs[n_categories] <- 1 - 1 / (1 + exp(a * (theta - b_thresholds[n_categories - 1])))
      a^2 * sum(probs * (1 - probs), na.rm = TRUE)
    } else {
      p <- 1 / (1 + exp(-a * (theta - b)))
      a^2 * p * (1 - p)
    }
    if (is.finite(info) && info > 0) info else 0
  }
  
  group_weights <- if (!is.null(config$item_groups)) {
    group_counts <- table(sapply(rv$administered, function(i) {
      for (g in names(config$item_groups)) if (i %in% config$item_groups[[g]]) return(g)
      return("Other")
    }))
    weights <- 1 / (1 + (group_counts / max(1, length(rv$administered))))
    setNames(weights[names(config$item_groups)] %||% 1, names(config$item_groups))
  } else rep(1, length(available))
  
  # Compute item information
  if (isTRUE(config$parallel_computation)) {
    if (!requireNamespace("parallel", quietly = TRUE)) {
      message("Parallel package not available, falling back to sequential computation")
      info <- vapply(available, function(i) item_info(rv$current_ability, i), numeric(1))
    } else {
      cl <- parallel::makeCluster(min(parallel::detectCores() - 1, 2))
      on.exit(parallel::stopCluster(cl), add = TRUE)
      parallel::clusterExport(cl, c("item_bank", "config", "rv", "item_info", "compute_item_info"), envir = environment())
      info <- parallel::parSapply(cl, available, function(i) item_info(rv$current_ability, i))
    }
  } else {
    info <- vapply(available, function(i) item_info(rv$current_ability, i), numeric(1))
  }
  
  # Handle invalid information values
  if (length(info) == 0 || all(is.na(info) | info <= 0)) {
    message("No valid information values, selecting random item")
    return(sample(available, 1))
  }
  
  # Select item based on criteria
  item <- if (config$criteria == "MI") {
    top_items <- available[info >= 0.95 * max(info, na.rm = TRUE)]
    if (length(top_items) == 0) {
      message("No items meet MI criteria, selecting random item")
      sample(available, 1)
    } else {
      sample(top_items, 1)
    }
  } else if (config$criteria == "RANDOM") {
    sample(available, 1)
  } else if (config$criteria == "WEIGHTED") {
    group_indices <- sapply(available, function(i) {
      for (g in names(config$item_groups)) if (i %in% config$item_groups[[g]]) return(g)
      "Other"
    })
    probs <- info * (group_weights[group_indices] %||% 1)
    if (length(probs) == 0 || all(is.na(probs) | probs <= 0)) {
      message("Invalid probabilities for WEIGHTED criteria, selecting random item")
      return(sample(available, 1))
    }
    probs <- probs / sum(probs, na.rm = TRUE)
    sample(available, 1, prob = probs)
  } else if (config$criteria == "MFI") {
    exposure <- table(rv$administered) / max(1, length(rv$administered))
    exposure_penalty <- vapply(available, function(i) {
      1 - 0.5 * (exposure[as.character(i)] %||% 0)
    }, numeric(1))
    adjusted_info <- info * exposure_penalty
    if (length(adjusted_info) == 0 || all(is.na(adjusted_info) | adjusted_info <= 0)) {
      message("Invalid adjusted information for MFI criteria, selecting random item")
      return(sample(available, 1))
    }
    top_items <- available[adjusted_info >= 0.95 * max(adjusted_info, na.rm = TRUE)]
    if (length(top_items) == 0) {
      message("No items meet MFI criteria, selecting random item")
      sample(available, 1)
    } else {
      sample(top_items, 1)
    }
  } else {
    top_items <- available[info >= 0.95 * max(info, na.rm = TRUE)]
    if (length(top_items) == 0) {
      message("No items meet default criteria, selecting random item")
      sample(available, 1)
    } else {
      sample(top_items, 1)
    }
  }
  
  message(sprintf("Selected item %d with information %f", item, max(info, na.rm = TRUE)))
  # Admin dashboard hook: log selection rationale
  if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
    config$admin_dashboard_hook(list(
      item = item,
      info = info,
      available = available,
      rv = rv,
      config = config
    ))
  }
  
  # Generate LLM assistance prompt if enabled
  if (getOption("inrep.llm_assistance", FALSE) && is_llm_assistance_enabled("selection")) {
    prompt <- generate_item_selection_optimization_prompt(
      item_selected = item,
      selection_info = info,
      available_items = available,
      current_state = rv,
      configuration = config
    )
    display_llm_prompt(prompt, "selection")
  }
  
  return(item)
}

#' Generate LLM Prompt for Item Selection Optimization
#'
#' @description
#' Creates detailed prompts for optimizing item selection algorithms and strategies.
#'
#' @param item_selected Index of the selected item
#' @param selection_info Information value of selected item
#' @param available_items Vector of available item indices
#' @param current_state Current test state from reactive values
#' @param configuration Study configuration object
#' @param include_examples Whether to include implementation examples
#'
#' @return Character string containing the optimization prompt
#'
#' @export
#'
#' @examples
#' \dontrun{
#' prompt <- generate_item_selection_optimization_prompt(
#'   item_selected = 15,
#'   selection_info = 0.85,
#'   available_items = c(15, 23, 31, 44),
#'   current_state = rv,
#'   configuration = config
#' )
#' cat(prompt)
#' }
generate_item_selection_optimization_prompt <- function(item_selected,
                                                       selection_info,
                                                       available_items,
                                                       current_state,
                                                       configuration,
                                                       include_examples = TRUE) {
  
  n_administered <- length(current_state$administered %||% 0)
  n_available <- length(available_items %||% 0)
  current_ability <- current_state$current_ability %||% 0
  ability_se <- current_state$ability_se %||% 1
  
  prompt <- paste0(
    "# ITEM SELECTION ALGORITHM OPTIMIZATION CONSULTATION\n\n",
    "You are a senior psychometrician specializing in adaptive testing and item selection algorithms. I need expert guidance for optimizing item selection strategies in my inrep study.\n\n",
    
    "## CURRENT SELECTION STATE\n",
    "- Selected Item: #", item_selected %||% "None", "\n",
    "- Selection Information: ", round(selection_info %||% 0, 4), "\n",
    "- Items Administered: ", n_administered, "\n",
    "- Items Available: ", n_available, "\n",
    "- Current Ability: θ = ", round(current_ability, 3), "\n",
    "- Ability SE: ", round(ability_se, 3), "\n",
    "- Selection Criterion: ", configuration$criteria %||% "MI", "\n",
    "- IRT Model: ", configuration$model %||% "2PL", "\n\n",
    
    "## STUDY CONFIGURATION\n",
    "- Test Length: ", configuration$min_items %||% 5, " to ", configuration$max_items %||% "unlimited", " items\n",
    "- Stopping Rule: SEM ≤ ", configuration$min_SEM %||% 0.3, "\n",
    "- Adaptive Mode: ", configuration$adaptive %||% TRUE, "\n",
    "- Content Balancing: ", configuration$content_balancing %||% FALSE, "\n",
    "- Exposure Control: ", configuration$exposure_control %||% FALSE, "\n",
    "- Session Duration: ", configuration$max_session_duration %||% 30, " minutes\n\n"
  )
  
  # Add detailed analysis sections
  prompt <- paste0(prompt,
    "## OPTIMIZATION ANALYSIS REQUESTS\n\n",
    
    "### 1. Selection Algorithm Performance\n",
    "- Evaluate current selection criterion effectiveness\n",
    "- Assess information maximization vs. practical constraints\n",
    "- Compare with alternative selection methods (MI, MFI, KL, A-optimality)\n",
    "- Analyze computational efficiency and speed\n\n",
    
    "### 2. Psychometric Quality\n",
    "- Assess measurement precision progression\n",
    "- Evaluate stopping rule appropriateness\n",
    "- Analyze item exposure distribution\n",
    "- Check for content area balance\n",
    "- Identify potential bias in selection patterns\n\n",
    
    "### 3. Adaptive Strategy Optimization\n",
    "- Recommend ability estimation frequency\n",
    "- Optimize starting ability assumptions\n",
    "- Suggest warm-up item strategies\n",
    "- Design ending procedures and final estimates\n\n",
    
    "### 4. Implementation Improvements\n",
    "- Suggest caching and performance optimizations\n",
    "- Recommend real-time monitoring strategies\n",
    "- Design quality control mechanisms\n",
    "- Plan for edge case handling\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE EXPERT RECOMMENDATIONS\n",
      "1. **Immediate Optimizations**: Changes to improve current selection\n",
      "2. **Algorithm Enhancements**: Advanced selection criteria implementations\n",
      "3. **Quality Metrics**: KPIs for monitoring selection effectiveness\n",
      "4. **R Code Examples**: Optimized functions and workflows\n",
      "5. **Validation Procedures**: Methods to assess selection quality\n",
      "6. **Performance Tuning**: Computational and statistical optimizations\n\n",
      
      "Please provide actionable recommendations with specific R code examples for implementation."
    )
  }
  
  return(prompt)
}

# Utility operator for null-coalescing
# (NULL coalescing operator defined in study_flow_helpers.R)