#' Select Next Item
#'
#' Selects the next item to administer. In adaptive mode the choice is based on
#' the Fisher information of each available item, computed by
#' \code{\link{compute_item_info_single}} from the item parameters in
#' \code{item_bank} at the current ability estimate (see \code{criteria}).
#' This function is used when \code{config$fast_item_selection} is
#' \code{FALSE}; otherwise \code{\link{launch_study}} calls
#' \code{\link{fast_select_next_item}}.
#'
#' @param rv List (or Shiny \code{reactiveValues}) with the current test state:
#'   \describe{
#'     \item{administered}{Integer vector of administered item indices}
#'     \item{responses}{Vector of responses}
#'     \item{current_ability}{Current ability estimate (from \code{\link{estimate_ability}})}
#'     \item{current_se}{Posterior SD of the current estimate (used by \code{"MEI"})}
#'     \item{session_start}{POSIXct time of session start (optional)}
#'     \item{domain_theta_histories}{Named list of per-domain histories
#'       (optional; see Details)}
#'   }
#' @param item_bank Data frame with item parameters: \code{a}, \code{b} (1PL,
#'   2PL); \code{a}, \code{b}, \code{c} (3PL); \code{a}, \code{b1}, \code{b2},
#'   ... (GRM). Columns \code{discrimination}, \code{difficulty} and
#'   \code{content} are accepted as aliases of \code{a}, \code{b} and
#'   \code{Question}.
#' @param config Study configuration from \code{\link{create_study_config}}.
#'   Fields used: \code{criteria}, \code{model}, \code{adaptive},
#'   \code{adaptive_start}, \code{fixed_items}, \code{item_groups},
#'   \code{max_items}, \code{min_items}, \code{max_session_duration},
#'   \code{theta_prior}, \code{theta_grid}, and optionally
#'   \code{item_selection_fun} and \code{admin_dashboard_hook}.
#'
#' @return Integer index of the selected item, or \code{NULL} if the session
#'   time limit (\code{max_session_duration}, in minutes) is exceeded,
#'   \code{max_items} is reached, no item is left, or the configuration is
#'   invalid.
#'
#' @export
#'
#' @details
#' Order of rules for the item number \eqn{k} = number administered + 1:
#' \enumerate{
#'   \item If \code{fixed_items} is set and \eqn{k \le} \code{length(fixed_items)},
#'     the \eqn{k}-th fixed item is returned.
#'   \item If the bank has a \code{domain} column and \code{rv} carries
#'     \code{domain_theta_histories}, the available items are restricted to the
#'     domain with the fewest administered items.
#'   \item If \code{config$item_selection_fun} is a function, its result is returned.
#'   \item Non-adaptive mode: the lowest-numbered available item (restricted to
#'     \code{item_groups} if given). Adaptive mode with \eqn{k <}
#'     \code{adaptive_start}: a random available item.
#'   \item Otherwise the item is chosen by \code{config$criteria}.
#' }
#'
#' Criteria (information is evaluated at the current EAP estimate
#' \eqn{\hat\theta} unless stated otherwise):
#' \describe{
#'   \item{\code{"MI"}}{Maximum Fisher information; ties broken at random.}
#'   \item{\code{"MEI"}}{Fisher information averaged over a normal
#'     approximation \eqn{N(\hat\theta, SE^2)} of the posterior (21 points over
#'     \eqn{\pm 3} SE). This is a posterior-weighted information criterion in
#'     the sense of van der Linden (1998); it is not the maximum expected
#'     information criterion of that paper, which takes the expectation over
#'     the predictive distribution of the next response.}
#'   \item{\code{"MFI"}}{A random draw among the items whose information is at
#'     least 95\% of the maximum. No exposure rates are tracked across sessions.}
#'   \item{\code{"WEIGHTED"}}{A random draw with probability proportional to
#'     information times a weight \eqn{1 / (1 + p_g)}, where \eqn{p_g} is the
#'     share of administered items that belong to the item's group in
#'     \code{item_groups}. Without \code{item_groups} all weights are 1.}
#'   \item{\code{"RANDOM"}}{A random available item.}
#' }
#' Information formulas: 1PL/2PL \eqn{a^2 P (1 - P)}; 3PL
#' \eqn{a^2 (P - c)^2 (1 - P) / (P (1 - c)^2)}; GRM \eqn{\sum_k P_k'^2 / P_k}
#' with Samejima's boundary curves (Samejima, 1969). The logistic metric is
#' used without the constant 1.7.
#'
#' No content-balancing algorithm beyond the \code{"WEIGHTED"} weights, and no
#' exposure control method (such as Sympson-Hetter), is implemented.
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' config <- create_study_config(
#'   model = "GRM",
#'   criteria = "MI",
#'   max_items = 15,
#'   min_SEM = 0.3,
#'   fast_item_selection = FALSE
#' )
#'
#' rv <- list(
#'   administered = c(1, 5, 12),
#'   responses = c(3, 4, 2),
#'   current_ability = 0.5,
#'   current_se = 0.8,
#'   session_start = Sys.time()
#' )
#'
#' next_item <- select_next_item(rv, bfi_items, config)
#' cat("Selected item:", next_item, "\n")
#'
#' config_weighted <- create_study_config(
#'   model = "GRM",
#'   criteria = "WEIGHTED",
#'   item_groups = list(
#'     "Group1" = 1:10,
#'     "Group2" = 11:20,
#'     "Group3" = 21:30
#'   )
#' )
#'
#' next_item_weighted <- select_next_item(rv, bfi_items, config_weighted)
#' }
#'
#' @references
#' Samejima, F. (1969). Estimation of latent ability using a response pattern of
#'   graded scores. \emph{Psychometrika Monograph Supplement}, No. 17.
#'
#' van der Linden, W. J. (1998). Bayesian item selection criteria for adaptive
#'   testing. \emph{Psychometrika}, 63(2), 201--216.
#'
#' van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). \emph{Elements of
#'   adaptive testing}. Springer.
#'
#' @seealso \code{\link{fast_select_next_item}}, \code{\link{estimate_ability}},
#'   \code{\link{create_study_config}}, \code{\link{launch_study}}
#'
#' @keywords psychometrics adaptive testing item selection
select_next_item <- function(rv, item_bank, config) {
  if (!is.list(rv) || !is.data.frame(item_bank) || !is.list(config)) {
    message("Invalid input: rv, item_bank, or config is not of correct type")
    return(NULL)
  }

  # rv may be a Shiny reactiveValues object, so it is read here but never
  # modified: assignments would change the live session state.
  if (!is.null(rv$session_start) && is.numeric(config$max_session_duration)) {
    session_duration <- as.numeric(difftime(Sys.time(), rv$session_start, units = "mins"))
    if (session_duration > config$max_session_duration) {
      message("Session time limit reached, no further item selected")
      return(NULL)
    }
  }

  administered <- rv$administered
  item_number <- length(administered) + 1L

  max_items <- min(config$max_items %||% nrow(item_bank), nrow(item_bank))
  if (length(administered) >= max_items) {
    message("Maximum items reached")
    return(NULL)
  }

  if (config$min_items > nrow(item_bank)) {
    message("min_items exceeds item bank size, adjusting to item bank size")
    config$min_items <- nrow(item_bank)
  }

  if (!is.null(config$fixed_items) && item_number <= length(config$fixed_items)) {
    if (!is.numeric(config$fixed_items) || any(config$fixed_items < 1) || any(config$fixed_items > nrow(item_bank))) {
      message("Invalid fixed_items configuration")
      return(NULL)
    }
    message(sprintf("Selecting fixed item %d", config$fixed_items[item_number]))
    return(config$fixed_items[item_number])
  }

  available <- setdiff(seq_len(nrow(item_bank)), administered)
  if (length(available) == 0) {
    message("No more items available")
    return(NULL)
  }

  # Domain balancing, used when the caller keeps per-domain histories
  if ("domain" %in% names(item_bank) && length(unique(item_bank$domain)) > 1) {
    current_domain <- NULL

    if (!is.null(rv$domain_theta_histories)) {
      domains <- names(rv$domain_theta_histories)
      domain_items_administered <- integer(length(domains))
      names(domain_items_administered) <- domains

      if (length(administered) > 0) {
        for (domain in domains) {
          domain_item_indices <- which(item_bank$domain == domain)
          domain_items_administered[domain] <- sum(administered %in% domain_item_indices)
        }
      }

      current_domain <- names(domain_items_administered)[which.min(domain_items_administered)]

      logger(sprintf("Domain balancing: %s", paste(paste0(names(domain_items_administered), "=", domain_items_administered), collapse=", ")))
    }

    if (!is.null(current_domain)) {
      domain_item_indices <- which(item_bank$domain == current_domain)
      available <- intersect(available, domain_item_indices)

      if (length(available) == 0) {
        logger(sprintf("No more items in domain %s, switching domains", current_domain))
        available <- setdiff(seq_len(nrow(item_bank)), administered)
      }
    }
  }

  if (!is.null(config$item_selection_fun) && is.function(config$item_selection_fun)) {
    item <- config$item_selection_fun(rv, item_bank, config)
    message(sprintf("Custom item selection function chose item %d", item))
    return(item)
  }

  if (!isTRUE(config$adaptive) || (is.numeric(config$adaptive_start) && item_number < config$adaptive_start)) {
    if (!is.null(config$item_groups)) {
      available <- available[available %in% unlist(config$item_groups)]
      if (length(available) == 0) {
        message("No items available in specified groups")
        return(NULL)
      }
    }
    if (!isTRUE(config$adaptive)) {
      item <- min(available)
      message(sprintf("Selected item %d (non-adaptive, sequential order)", item))
    } else {
      item <- available[sample.int(length(available), 1L)]
      message(sprintf("Selected random item %d (pre-adaptive phase)", item))
    }
    return(item)
  }

  if (is.null(config$theta_grid) || !is.numeric(config$theta_grid) || length(config$theta_grid) < 2) {
    message("Invalid theta_grid, using default grid (-4, 4, 100)")
    config$theta_grid <- seq(-4, 4, length.out = 100)
  }

  if ("content" %in% names(item_bank) && !"Question" %in% names(item_bank)) item_bank$Question <- item_bank$content
  if ("discrimination" %in% names(item_bank) && !"a" %in% names(item_bank)) item_bank$a <- item_bank$discrimination
  if ("difficulty" %in% names(item_bank) && !"b" %in% names(item_bank)) item_bank$b <- item_bank$difficulty
  required_cols <- if (config$model == "GRM") c("a", "b1") else if (config$model == "3PL") c("a", "b", "c") else c("a", "b")
  if (!all(required_cols %in% names(item_bank))) {
    message(sprintf("Item bank missing required columns for %s model: %s", config$model, paste(required_cols, collapse = ", ")))
    return(NULL)
  }

  group_of <- function(i) {
    for (g in names(config$item_groups)) if (i %in% config$item_groups[[g]]) return(g)
    "Other"
  }
  group_weights <- if (!is.null(config$item_groups)) {
    group_counts <- table(factor(vapply(administered, group_of, character(1)),
                                 levels = c(names(config$item_groups), "Other")))
    weights <- 1 / (1 + (group_counts / max(1, length(administered))))
    setNames(as.numeric(weights[names(config$item_groups)]), names(config$item_groups))
  } else rep(1, length(available))

  current_theta <- rv$current_ability %||% config$theta_prior[1] %||% 0
  if (!is.numeric(current_theta) || length(current_theta) == 0 || !is.finite(current_theta)) {
    message("Invalid current_ability, defaulting to theta_prior mean")
    current_theta <- config$theta_prior[1] %||% 0
  }

  # Fisher information at the point estimate; "MEI" computes its own values below.
  info <- vapply(available, function(i) {
    compute_item_info_single(current_theta, i, item_bank, config)
  }, numeric(1))

  # sample(x, 1) draws from 1:x when x is a single number, so index explicitly.
  pick1 <- function(v) v[sample.int(length(v), 1L)]

  if (length(info) == 0 || all(is.na(info) | info <= 0)) {
    message("No valid information values, selecting random item")
    return(pick1(available))
  }

  item <- if (config$criteria == "RANDOM") {
    pick1(available)
  } else if (config$criteria == "MI") {
    max_info <- max(info, na.rm = TRUE)
    top_items <- available[info >= max_info]
    if (length(top_items) == 0) {
      message("No items meet MI criteria, selecting random item")
      pick1(available)
    } else {
      pick1(top_items)
    }
  } else if (config$criteria == "MEI") {
    # Posterior-weighted Fisher information. The posterior is approximated by
    # N(theta_hat, SE^2); with an IRT likelihood the true posterior is not
    # normal, so this is an approximation.
    se_now  <- rv$current_se
    se_post <- if (!is.null(se_now) && is.numeric(se_now) &&
                    is.finite(se_now) && se_now > 0) se_now else 1.0
    mei_grid    <- seq(current_theta - 3 * se_post,
                       current_theta + 3 * se_post,
                       length.out = 21)
    mei_weights <- dnorm(mei_grid, current_theta, se_post)
    mei_weights <- mei_weights / sum(mei_weights)
    info_mei <- vapply(available, function(i) {
      sum(mei_weights * vapply(mei_grid, function(t)
        compute_item_info_single(t, i, item_bank, config), numeric(1)))
    }, numeric(1))
    if (all(is.na(info_mei) | info_mei <= 0)) {
      message("No valid MEI values, falling back to random selection")
      pick1(available)
    } else {
      top_items <- available[info_mei >= max(info_mei, na.rm = TRUE)]
      if (length(top_items) == 0L) pick1(available) else pick1(top_items)
    }
  } else if (config$criteria == "WEIGHTED") {
    group_indices <- vapply(available, group_of, character(1))
    weight_values <- group_weights[group_indices]
    weight_values[is.na(weight_values)] <- 1
    probs <- info * weight_values
    if (length(probs) == 0 || all(is.na(probs) | probs <= 0)) {
      message("Invalid probabilities for WEIGHTED criteria, selecting random item")
      return(pick1(available))
    }
    probs <- probs / sum(probs, na.rm = TRUE)
    available[sample.int(length(available), 1L, prob = probs)]
  } else if (config$criteria == "MFI") {
    top_items <- available[info >= 0.95 * max(info, na.rm = TRUE)]
    if (length(top_items) == 0L) {
      message("No items meet MFI criteria, selecting random item")
      pick1(available)
    } else {
      pick1(top_items)
    }
  } else {
    # Unrecognised criteria: maximum information
    top_items <- available[info >= max(info, na.rm = TRUE)]
    if (length(top_items) == 0L) {
      message("No items meet default criteria, selecting random item")
      pick1(available)
    } else {
      pick1(top_items)
    }
  }

  # Guard against returning an administered item (only reachable if the
  # domain fallback or a criterion above misbehaves).
  if (!is.null(item) && (item %in% administered)) {
    orig_item <- item
    fallback_pool <- setdiff(seq_len(nrow(item_bank)), administered)
    if (length(fallback_pool) == 0L) {
      message("Duplicate guard: no items remaining after dedup")
      return(NULL)
    }
    fb_info <- vapply(fallback_pool,
      function(j) compute_item_info_single(current_theta, j, item_bank, config),
      numeric(1L))
    item <- fallback_pool[which.max(fb_info)]
    message(sprintf("Duplicate guard: item %d already administered; redirected to item %d",
                    orig_item, item))
  }

  message(sprintf("Selected item %d (maximum information among available items: %f)", item, max(info, na.rm = TRUE)))
  if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
    config$admin_dashboard_hook(list(
      item = item,
      info = info,
      available = available,
      rv = rv,
      config = config
    ))
  }

  return(item)
}

#' Fast Item Selection
#'
#' Default item selection in \code{\link{launch_study}}
#' (\code{config$fast_item_selection = TRUE}). In adaptive mode it computes
#' Fisher information at the current estimate for a random subset of at most
#' \code{max_compute} available items and draws at random among those whose
#' information is at least 90\% of the subset maximum. \code{config$criteria},
#' \code{item_groups}, domain balancing and \code{item_selection_fun} are not
#' used; use \code{\link{select_next_item}} for those.
#'
#' Order of rules for item number \eqn{k} = number administered + 1:
#' \code{fixed_items} first; then, in non-adaptive mode, the lowest-numbered
#' available item; in adaptive mode a random item while \eqn{k <}
#' \code{adaptive_start}; then the information rule above.
#'
#' @param rv List (or Shiny \code{reactiveValues}) with \code{administered} and
#'   \code{current_ability}.
#' @param item_bank Data frame containing item parameters
#' @param config Study configuration object
#' @param max_compute Maximum number of items for which information is
#'   computed (default: 15)
#' @return Integer index of the selected item, or \code{NULL} if no item is left
#'   or \code{max_items} is reached.
#' @export
fast_select_next_item <- function(rv, item_bank, config, max_compute = 15) {
  if (length(rv$administered) >= (config$max_items %||% nrow(item_bank))) {
    return(NULL)
  }

  available <- setdiff(seq_len(nrow(item_bank)), rv$administered)
  if (length(available) == 0) return(NULL)

  n_administered <- length(rv$administered)
  item_number <- n_administered + 1L

  fixed <- config$fixed_items
  if (is.numeric(fixed) && item_number <= length(fixed) &&
      all(fixed >= 1) && all(fixed <= nrow(item_bank))) {
    return(fixed[item_number])
  }

  if (!isTRUE(config$adaptive)) {
    if (!is.null(config$item_groups)) {
      available <- available[available %in% unlist(config$item_groups)]
      if (length(available) == 0) return(NULL)
    }
    return(min(available))
  }

  adaptive_start <- config$adaptive_start %||% config$min_items %||% 5
  if (item_number < adaptive_start) {
    # sample(x, 1) draws from 1:x when x is a single number; sample.int() avoids this
    item <- available[sample.int(length(available), 1L)]
    message(sprintf("Selected random item %d (pre-adaptive phase, item %d; adaptive from item %d)",
                    item, item_number, adaptive_start))
    return(item)
  }

  if (length(available) <= 5) max_compute <- length(available)

  if (length(available) > max_compute) {
    available <- available[sample.int(length(available), max_compute)]
  }

  current_theta <- rv$current_ability %||% config$theta_prior[1] %||% 0
  if (!is.finite(current_theta)) current_theta <- 0

  info <- vapply(available, function(i) {
    compute_item_info_single(current_theta, i, item_bank, config)
  }, numeric(1))

  if (all(is.na(info) | info <= 0)) {
    return(available[sample.int(length(available), 1L)])
  }

  best_items <- available[info >= 0.9 * max(info, na.rm = TRUE)]
  if (length(best_items) == 0) {
    best_items <- available[which.max(info)]
  }

  return(best_items[sample.int(length(best_items), 1L)])
}
