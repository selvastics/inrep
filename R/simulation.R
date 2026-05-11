# File: simulation.R
# Population-level simulation and individual-level Shiny replay.
#
# Public API:
#   run_simulation()        — Monte Carlo adaptive vs. MCAR comparison
#   launch_study_sim()      — Shiny replay of one simulated participant
#   print.inrep_simulation  — S3 print method

# ─────────────────────────────────────────────────────────────────────────────

#' Run Population Simulation: Adaptive vs. MCAR
#'
#' Runs a Monte Carlo simulation comparing adaptive (CAT) item selection with
#' Missing Completely At Random (MCAR / random) item selection.  Both arms
#' administer exactly \code{cat_k} items per participant — a fixed-length
#' design that eliminates the stopping-rule confound and keeps the information
#' budget equal.
#'
#' The returned \code{inrep_simulation} object stores full per-participant
#' trajectories (item sequence, responses, \eqn{\hat{\theta}}, SE) and can be
#' passed to \code{\link{launch_study_sim}()} to replay any individual's
#' assessment in an interactive Shiny app.
#'
#' @param config Study configuration from \code{\link{create_study_config}}.
#'   The fields \code{model}, \code{criteria}, \code{theta_prior}, and
#'   \code{estimation_method} drive the simulation.  \code{max_items} is
#'   overridden internally by \code{cat_k}.
#' @param item_bank Data frame with item parameters compatible with
#'   \code{config$model}.
#' @param n_sim Integer.  Number of simulated participants.  Default 500.
#'   Set to at least 200 for stable RMSE estimates.
#' @param cat_k Integer.  Fixed items per participant (both arms).  Must not
#'   exceed \code{nrow(item_bank)}.  Default 15.
#' @param seed Integer random seed for reproducibility.  Default 42.
#' @param include_mcar Logical.  Also run the MCAR (random selection) arm?
#'   Default \code{TRUE}.  MCAR collects a full per-step trajectory so it can
#'   be replayed with \code{launch_study_sim(condition = "mcar")}.
#' @param true_theta_dist Optional numeric vector of length \code{n_sim}
#'   providing true ability values.  When \code{NULL} (default), draws from
#'   \eqn{N(\mu, \sigma^2)} where \eqn{(\mu, \sigma)} = \code{config$theta_prior}.
#' @param progress Logical.  Print progress dots to console?  Default
#'   \code{TRUE}.
#' @param ... Reserved for future arguments.
#'
#' @return An object of class \code{inrep_simulation} (a named list):
#' \describe{
#'   \item{\code{participants}}{List of length \code{n_sim}.  Each element is
#'     a list with fields: \code{id}, \code{true_theta},
#'     \code{adaptive} (and \code{mcar} if \code{include_mcar = TRUE}).
#'     Both arm sub-lists contain: \code{item_seq}, \code{responses},
#'     \code{theta_traj}, \code{se_traj}, \code{info_traj},
#'     \code{final_theta}, \code{final_se}.}
#'   \item{\code{summary}}{Data frame with population metrics: RMSE, bias,
#'     mean SE, mean Fisher info per item, and (if MCAR) gain percentages.}
#'   \item{\code{config}}{The config object used.}
#'   \item{\code{item_bank}}{The item bank used.}
#'   \item{\code{n_sim}, \code{cat_k}, \code{seed}, \code{include_mcar}}{
#'     Simulation parameters.}
#'   \item{\code{true_thetas}}{Numeric vector of the true ability values.}
#' }
#'
#' @section Design rationale:
#' A common error in adaptive-vs-fixed comparisons is allowing the adaptive
#' test to stop early (via a SE threshold) while the MCAR test runs a fixed
#' number of items.  The resulting SE difference is a tautology, not a finding.
#' \code{run_simulation} enforces equal item counts (\code{cat_k}) in both
#' arms; SE and RMSE become the sole outcome, measuring precision for a fixed
#' information budget.
#'
#' @section Duplicate-selection guard:
#' A defensive re-selection guard wraps every \code{select_next_item()} call.
#' If floating-point ties in MEI/MI values cause an already-administered item
#' to be returned, the guard falls back to the unadministered item with the
#' highest point-estimate Fisher information.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' config <- create_study_config(
#'   model    = "GRM",
#'   criteria = "MEI",
#'   adaptive = TRUE
#' )
#'
#' sim <- run_simulation(config, bfi_items, n_sim = 200, cat_k = 10, seed = 1)
#' print(sim)
#'
#' # Replay participant 42
#' launch_study_sim(sim, id = 42)
#' }
#'
#' @seealso \code{\link{launch_study_sim}}, \code{\link{select_next_item}},
#'   \code{\link{estimate_ability}}
#'
#' @references
#' Liu, X., & Loken, E. (2025). The impact of missing data on parameter
#'   estimation: three examples in computerized adaptive testing.
#'   \emph{Educational and Psychological Measurement}, 85(3), 617--635.
#'   \doi{10.1177/00131644241306990}
#'
#' Veerkamp, W. J. J., & Berger, M. P. F. (1997). Some new item selection
#'   criteria for adaptive testing. \emph{Journal of Educational and Behavioral
#'   Statistics}, 22(2), 203--226. https://doi.org/10.3102/10769986022002203
run_simulation <- function(config,
                           item_bank,
                           n_sim        = 500L,
                           cat_k        = 15L,
                           seed         = 42L,
                           include_mcar = TRUE,
                           true_theta_dist = NULL,
                           progress     = TRUE,
                           ...) {

  # ── Validate inputs ────────────────────────────────────────────────────────
  if (!is.list(config) || is.null(config$model))
    stop("config must be a create_study_config() object.")
  if (!is.data.frame(item_bank) || nrow(item_bank) == 0L)
    stop("item_bank must be a non-empty data frame.")

  cat_k <- as.integer(cat_k)
  n_sim <- as.integer(n_sim)
  if (cat_k < 1L)
    stop("cat_k must be >= 1.")
  if (n_sim < 1L)
    stop("n_sim must be >= 1.")
  if (cat_k > nrow(item_bank))
    stop(sprintf("cat_k (%d) exceeds item bank size (%d).", cat_k, nrow(item_bank)))

  # Override max_items so select_next_item respects cat_k
  config$max_items <- cat_k

  # ── Setup ──────────────────────────────────────────────────────────────────
  set.seed(seed)
  pool_size <- nrow(item_bank)
  prior_mu  <- if (!is.null(config$theta_prior) && length(config$theta_prior) >= 1)
                 config$theta_prior[1] else 0
  prior_sd  <- if (!is.null(config$theta_prior) && length(config$theta_prior) >= 2)
                 config$theta_prior[2] else 1

  if (is.null(true_theta_dist)) {
    true_thetas <- stats::rnorm(n_sim, mean = prior_mu, sd = prior_sd)
  } else {
    if (length(true_theta_dist) != n_sim)
      stop("true_theta_dist must have length n_sim.")
    true_thetas <- as.numeric(true_theta_dist)
  }

  # Threshold column names for GRM
  b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
  model_upper <- toupper(config$model %||% "2PL")

  # ── Internal response simulators ──────────────────────────────────────────
  sim_grm <- function(theta, row) {
    a      <- row$a
    b      <- as.numeric(row[, b_cols, drop = TRUE])
    n_cat  <- length(b) + 1L
    P_star <- c(1, 1 / (1 + exp(-a * (theta - b))), 0)
    P_cat  <- pmax(P_star[-length(P_star)] - P_star[-1L], 1e-10)
    sample.int(n_cat, 1L, prob = P_cat / sum(P_cat))
  }

  sim_binary <- function(theta, row) {
    a <- if (!is.null(row$a)) row$a else 1
    b <- row$b
    c_par <- if (!is.null(row$c) && !is.na(row$c)) row$c else 0
    p <- c_par + (1 - c_par) / (1 + exp(-a * (theta - b)))
    sample.int(2L, 1L, prob = c(1 - p, p)) - 1L
  }

  sim_response <- if (model_upper == "GRM" && length(b_cols) > 0)
    function(theta, row) sim_grm(theta, row)
  else
    function(theta, row) sim_binary(theta, row)

  # ── Defensive item selection (silent in simulation context) ────────────────
  safe_select <- function(rv_s) {
    suppressMessages(select_next_item(rv_s, item_bank, config))
  }

  fresh_rv <- function() {
    list(
      administered    = integer(0L),
      responses       = integer(0L),
      current_ability = prior_mu,
      ability_se      = prior_sd,
      item_counter    = 0L,
      item_info_cache = list(),
      session_start   = Sys.time()
    )
  }

  # ── Main loop ──────────────────────────────────────────────────────────────
  if (progress) {
    cat(sprintf(
      "\nrun_simulation: N = %d, K = %d items, model = %s, criteria = %s\n",
      n_sim, cat_k, config$model, config$criteria %||% "MI"))
    cat("Progress:\n  ")
  }

  participants <- vector("list", n_sim)

  for (sim_i in seq_len(n_sim)) {
    if (progress && sim_i %% 10L == 0L) cat("."); if (progress && sim_i %% 100L == 0L) cat(sim_i)

    true_th <- true_thetas[sim_i]

    # ── Adaptive arm ──────────────────────────────────────────────────────────
    rv_a         <- fresh_rv()
    item_seq_a   <- integer(cat_k)
    resp_seq_a   <- integer(cat_k)
    theta_traj_a <- numeric(cat_k)
    se_traj_a    <- numeric(cat_k)
    info_traj_a  <- numeric(cat_k)

    for (step in seq_len(cat_k)) {
      rv_a$item_counter <- length(rv_a$administered)
      ni <- safe_select(rv_a)
      if (is.null(ni)) break

      info_traj_a[step] <- tryCatch(
        compute_item_info_single(rv_a$current_ability, ni, item_bank, config),
        error = function(e) NA_real_)

      resp <- sim_response(true_th, item_bank[ni, , drop = FALSE])

      rv_a$administered <- c(rv_a$administered, ni)
      rv_a$responses    <- c(rv_a$responses,    resp)

      est               <- suppressMessages(estimate_ability(rv_a, item_bank, config))
      rv_a$current_ability <- est$theta
      rv_a$ability_se      <- est$se

      item_seq_a[step]   <- ni
      resp_seq_a[step]   <- resp
      theta_traj_a[step] <- est$theta
      se_traj_a[step]    <- est$se
    }

    p <- list(
      id         = sim_i,
      true_theta = true_th,
      adaptive   = list(
        item_seq    = item_seq_a,
        responses   = resp_seq_a,
        theta_traj  = theta_traj_a,
        se_traj     = se_traj_a,
        info_traj   = info_traj_a,
        final_theta = theta_traj_a[cat_k],
        final_se    = se_traj_a[cat_k]
      )
    )

    # ── MCAR arm ──────────────────────────────────────────────────────────────
    if (include_mcar) {
      rv_m         <- fresh_rv()
      item_seq_m   <- sample(pool_size, cat_k, replace = FALSE)
      resp_seq_m   <- integer(cat_k)
      theta_traj_m <- numeric(cat_k)
      se_traj_m    <- numeric(cat_k)
      info_traj_m  <- numeric(cat_k)

      for (k in seq_len(cat_k)) {
        ni_m  <- item_seq_m[k]
        resp_m <- sim_response(true_th, item_bank[ni_m, , drop = FALSE])

        rv_m$administered <- c(rv_m$administered, ni_m)
        rv_m$responses    <- c(rv_m$responses,    resp_m)
        rv_m$item_counter <- k

        est_m               <- suppressMessages(estimate_ability(rv_m, item_bank, config))
        rv_m$current_ability <- est_m$theta
        rv_m$ability_se      <- est_m$se

        resp_seq_m[k]   <- resp_m
        theta_traj_m[k] <- est_m$theta
        se_traj_m[k]    <- est_m$se
        info_traj_m[k]  <- tryCatch(
          compute_item_info_single(true_th, ni_m, item_bank, config),
          error = function(e) NA_real_)
      }

      p$mcar <- list(
        item_seq    = item_seq_m,
        responses   = resp_seq_m,
        theta_traj  = theta_traj_m,
        se_traj     = se_traj_m,
        info_traj   = info_traj_m,
        final_theta = theta_traj_m[cat_k],
        final_se    = se_traj_m[cat_k]
      )
    }

    participants[[sim_i]] <- p
  }

  if (progress) cat("\n")

  # ── Population summary ─────────────────────────────────────────────────────
  fin_theta_a <- vapply(participants, function(p) p$adaptive$final_theta, numeric(1L))
  fin_se_a    <- vapply(participants, function(p) p$adaptive$final_se,    numeric(1L))
  mean_info_a <- vapply(participants, function(p) mean(p$adaptive$info_traj, na.rm = TRUE), numeric(1L))
  errors_a    <- fin_theta_a - true_thetas

  smry <- data.frame(
    metric   = c("RMSE", "Bias", "Mean_SE", "Mean_info_per_item"),
    adaptive = c(sqrt(mean(errors_a^2,    na.rm = TRUE)),
                 mean(errors_a,           na.rm = TRUE),
                 mean(fin_se_a,           na.rm = TRUE),
                 mean(mean_info_a,        na.rm = TRUE)),
    stringsAsFactors = FALSE
  )

  if (include_mcar) {
    fin_theta_m <- vapply(participants, function(p) p$mcar$final_theta, numeric(1L))
    fin_se_m    <- vapply(participants, function(p) p$mcar$final_se,    numeric(1L))
    mean_info_m <- vapply(participants,
      function(p) mean(p$mcar$info_traj, na.rm = TRUE), numeric(1L))
    errors_m    <- fin_theta_m - true_thetas

    smry$mcar <- c(sqrt(mean(errors_m^2,  na.rm = TRUE)),
                   mean(errors_m,         na.rm = TRUE),
                   mean(fin_se_m,         na.rm = TRUE),
                   mean(mean_info_m,      na.rm = TRUE))

    smry$gain_pct <- c(
      (smry$mcar[1] - smry$adaptive[1]) / smry$mcar[1] * 100,  # RMSE: lower adaptive is gain
      NA_real_,                                                  # Bias: no directional expectation
      (smry$mcar[3] - smry$adaptive[3]) / smry$mcar[3] * 100,  # SE: lower adaptive is gain
      (smry$adaptive[4] - smry$mcar[4]) / smry$mcar[4] * 100   # Info: higher adaptive is gain
    )
  }

  if (progress) {
    cat(sprintf("  Adaptive : RMSE = %.4f  |  Mean SE = %.4f\n",
                smry$adaptive[1], smry$adaptive[3]))
    if (include_mcar)
      cat(sprintf("  MCAR     : RMSE = %.4f  |  Mean SE = %.4f\n",
                  smry$mcar[1], smry$mcar[3]))
    cat(sprintf("  Use launch_study_sim(sim, id = <1..%d>) to replay a participant.\n", n_sim))
  }

  structure(
    list(
      participants = participants,
      summary      = smry,
      config       = config,
      item_bank    = item_bank,
      n_sim        = n_sim,
      cat_k        = cat_k,
      seed         = seed,
      include_mcar = include_mcar,
      true_thetas  = true_thetas
    ),
    class = "inrep_simulation"
  )
}


# ─────────────────────────────────────────────────────────────────────────────
#' Print an inrep_simulation Object
#'
#' @param x An \code{inrep_simulation} object.
#' @param ... Ignored.
#' @export
print.inrep_simulation <- function(x, ...) {
  cat("inrep_simulation\n")
  cat(sprintf("  Participants : %d\n",              x$n_sim))
  cat(sprintf("  Items / each : %d  (fixed-length, equal budget)\n", x$cat_k))
  cat(sprintf("  Item bank    : %d items,  model = %s\n",
              nrow(x$item_bank), x$config$model))
  cat(sprintf("  Criteria     : %s\n",              x$config$criteria %||% "MI"))
  cat(sprintf("  MCAR arm     : %s\n",              if (x$include_mcar) "yes" else "no"))
  cat(sprintf("  Seed         : %d\n",              x$seed))
  cat("\nPopulation summary:\n")
  print(x$summary, row.names = FALSE, digits = 4)
  cat(sprintf(
    "\nUse launch_study_sim(sim, id = <1..%d>) to replay any participant.\n",
    x$n_sim))
  invisible(x)
}


# ─────────────────────────────────────────────────────────────────────────────

#' Replay a Simulated Participant's Assessment in Shiny
#'
#' Launches a Shiny app that walks through the exact item sequence, pre-filled
#' responses, and live-updating \eqn{\hat{\theta}} / SE trajectory of a single
#' simulated participant from an \code{\link{run_simulation}} result.
#'
#' This bridges population-level simulation findings with individual-level
#' understanding: you can inspect \emph{why} a particular participant received
#' certain items, how the ability estimate evolved, and how the adaptive arm
#' compared to a random draw.
#'
#' @param sim_object An \code{inrep_simulation} object from
#'   \code{\link{run_simulation}}.
#' @param id Integer. Participant ID to replay (1-based, \code{1..n_sim}).
#' @param condition Character. Which arm to replay: \code{"adaptive"}
#'   (default) or \code{"mcar"} (only if \code{sim_object$include_mcar = TRUE}).
#' @param show_comparison Logical. Show the MCAR final result alongside the
#'   adaptive result on the summary page?  Default \code{TRUE}.  Has no effect
#'   when \code{condition = "mcar"} or MCAR was not simulated.
#' @param launch_browser Logical. Open in browser?  Default \code{TRUE}.
#' @param ... Passed to \code{shiny::runApp()}.
#'
#' @return Launches a Shiny app.  Does not return a value.
#'
#' @section Individual vs. population:
#' The replay shows one person's data.  Differences between adaptive and MCAR
#' SE at the individual level are not statistically meaningful — adaptive
#' \emph{consistently} outperforms MCAR on RMSE(\eqn{\theta}) only at the
#' population level (Liu & Loken, 2025).  The summary page includes a reminder.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#' config <- create_study_config(model = "GRM", criteria = "MEI", adaptive = TRUE)
#' sim    <- run_simulation(config, bfi_items, n_sim = 100, cat_k = 10)
#' launch_study_sim(sim, id = 42)
#'
#' # Replay the MCAR arm for the same participant
#' launch_study_sim(sim, id = 42, condition = "mcar")
#' }
#'
#' @seealso \code{\link{run_simulation}}
launch_study_sim <- function(sim_object,
                             id,
                             condition       = "adaptive",
                             show_comparison = TRUE,
                             launch_browser  = TRUE,
                             ...) {

  # ── Validate ───────────────────────────────────────────────────────────────
  if (!inherits(sim_object, "inrep_simulation"))
    stop("sim_object must be an inrep_simulation from run_simulation().")

  id <- as.integer(id)
  if (id < 1L || id > sim_object$n_sim)
    stop(sprintf("id must be between 1 and %d.", sim_object$n_sim))

  condition <- match.arg(condition, c("adaptive", "mcar"))
  if (condition == "mcar" && !sim_object$include_mcar)
    stop("MCAR arm was not included (run_simulation(..., include_mcar = TRUE)).")

  # ── Extract data ───────────────────────────────────────────────────────────
  p         <- sim_object$participants[[id]]
  arm       <- p[[condition]]
  item_bank <- sim_object$item_bank
  config    <- sim_object$config
  cat_k     <- sim_object$cat_k
  n_sim     <- sim_object$n_sim
  true_th   <- p$true_theta

  item_seq    <- arm$item_seq
  responses   <- arm$responses
  theta_traj  <- arm$theta_traj
  se_traj     <- arm$se_traj
  info_traj   <- arm$info_traj
  has_info    <- !is.null(info_traj) && any(!is.na(info_traj))

  show_mcar <- show_comparison && sim_object$include_mcar && condition == "adaptive"
  mcar_arm  <- if (show_mcar) p$mcar else NULL

  # ── Response label helper ──────────────────────────────────────────────────
  has_resp_cats <- "ResponseCategories" %in% names(item_bank)
  get_resp_labels <- function(idx) {
    if (has_resp_cats) {
      s <- as.character(item_bank$ResponseCategories[idx])
      if (!is.na(s) && nzchar(s))
        return(trimws(strsplit(s, ",")[[1]]))
    }
    c("0", "1")
  }

  # ── Item ID helper ─────────────────────────────────────────────────────────
  get_item_id <- function(idx) {
    if ("item_id" %in% names(item_bank))
      return(as.character(item_bank$item_id[idx]))
    as.character(idx)
  }

  # ── CSS ────────────────────────────────────────────────────────────────────
  sim_css <- "
body  { font-family: 'Segoe UI', Arial, sans-serif; background: #f4f6f9; margin: 0; }
.sim-header { background: #1a4f72; color: #fff; padding: 11px 22px;
              border-radius: 0 0 6px 6px; margin-bottom: 18px; }
.sim-header h5 { margin: 0; font-size: .93em; font-weight: 400; opacity: .9; }
.sim-header h4 { margin: 0 0 2px; font-size: 1.05em; font-weight: 600; }
.item-card { background: #fff; border-radius: 10px; padding: 22px 26px;
             box-shadow: 0 1px 5px rgba(0,0,0,.09); margin-bottom: 14px; }
.item-num-lbl { font-size: .72em; color: #999; text-transform: uppercase;
                letter-spacing: .08em; margin-bottom: 6px; }
.item-q { font-size: 1.0em; color: #1a1a1a; line-height: 1.65; }
.resp-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 14px; }
.resp-chip { padding: 6px 16px; border-radius: 20px; font-size: .86em;
             border: 2px solid #dde2e8; background: #f7f9fb; cursor: default; }
.resp-chip.chosen { background: #2E86AB; color: #fff; border-color: #2E86AB;
                    font-weight: 700; box-shadow: 0 0 0 3px rgba(46,134,171,.2); }
.traj-panel { background: #fff; border-radius: 10px; padding: 14px 16px;
              box-shadow: 0 1px 5px rgba(0,0,0,.09); }
.nav-strip { display: flex; align-items: center; gap: 8px; margin-top: 10px;
             flex-wrap: wrap; }
.stat-chip { display: inline-block; background: #eaf4fb; border-radius: 8px;
             padding: 7px 14px; text-align: center; margin: 2px; }
.stat-v { font-size: 1.22em; font-weight: 700; color: #1a4f72; }
.stat-l { font-size: .68em; color: #6a7a8a; display: block; margin-top: 1px; }
.info-chip { font-size: .73em; color: #888; background: #f0f0f0; border-radius: 12px;
             padding: 3px 10px; display: inline-block; margin-top: 6px; }
.prog-lbl { font-size: .79em; color: #aaa; margin-bottom: 5px; }
.res-card { background: #fff; border-radius: 12px; padding: 26px 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,.10); }
.res-card h3 { color: #1a4f72; margin-top: 0; }
.cmp-note { font-size: .79em; color: #888; margin-top: 10px; line-height: 1.5; }
.cond-tag { display: inline-block; border-radius: 4px; padding: 2px 8px;
            font-size: .74em; font-weight: 700; text-transform: uppercase; }
.cond-adapt { background: #d3ecf8; color: #1a4f72; }
.cond-mcar  { background: #fde8c8; color: #7a3e00; }
"

  # ── UI ─────────────────────────────────────────────────────────────────────
  ui <- shiny::fluidPage(
    shiny::tags$head(shiny::tags$style(shiny::HTML(sim_css))),

    # Header
    shiny::div(class = "sim-header",
      shiny::h4(sprintf(
        "Simulation Replay \u2014 Participant #%d  |  %s arm  |  K\u202f=\u202f%d items",
        id, toupper(condition), cat_k)),
      shiny::h5(sprintf(
        "True \u03b8 = %+.3f  |  Pool = %d items  |  Model = %s  |  Criteria = %s  |  N_sim = %d",
        true_th, nrow(item_bank),
        config$model %||% "?",
        config$criteria %||% "MI",
        n_sim))
    ),

    shiny::uiOutput("main_content")
  )

  # ── Server ─────────────────────────────────────────────────────────────────
  server <- function(input, output, session) {

    step <- shiny::reactiveVal(1L)
    view <- shiny::reactiveVal("assessment")   # "assessment" | "results"

    # ── Main content switch ──────────────────────────────────────────────────
    output$main_content <- shiny::renderUI({
      if (view() == "results") {
        # ─── Results page ────────────────────────────────────────────────────
        shiny::fluidRow(
          shiny::column(8, offset = 2,
            shiny::div(class = "res-card",
              shiny::h3("Assessment Complete"),
              shiny::hr(),
              shiny::uiOutput("results_stats"),
              shiny::plotOutput("final_traj_plot", height = "250px"),
              shiny::hr(),
              shiny::actionButton("btn_restart",
                "\u21BA Replay from Item 1",
                style = paste(
                  "background:#2E86AB; color:#fff; border:none;",
                  "border-radius:5px; padding:8px 20px; margin-top:4px;"))
            )
          )
        )
      } else {
        # ─── Assessment page ─────────────────────────────────────────────────
        s   <- step()
        idx <- item_seq[s]

        q_text <- if ("Question" %in% names(item_bank))
                    item_bank$Question[idx]
                  else sprintf("Item %d", idx)

        labels  <- get_resp_labels(idx)
        given   <- responses[s]
        # GRM responses are 1-based; binary 0-based (0 or 1)
        model_is_grm <- toupper(config$model %||% "") == "GRM" &&
                        length(get_resp_labels(idx)) > 2

        resp_chips <- lapply(seq_along(labels), function(k) {
          is_sel <- if (model_is_grm) (k == given) else ((k - 1L) == given)
          shiny::tags$span(
            class = paste("resp-chip", if (is_sel) "chosen" else ""),
            labels[k])
        })

        info_ui <- if (has_info && !is.na(info_traj[s])) {
          shiny::div(class = "info-chip",
            sprintf("Fisher info at \u03b8\u0302 = %.4f", info_traj[s]))
        } else shiny::tagList()

        prog_pct <- round(100 * s / cat_k)

        shiny::fluidRow(
          # Left: item + controls
          shiny::column(7,
            shiny::div(class = "prog-lbl",
              sprintf("Item %d of %d  (%d%%)", s, cat_k, prog_pct)),
            shiny::div(class = "item-card",
              shiny::div(class = "item-num-lbl",
                sprintf("Item %d  \u2022  bank[%d]  \u2022  %s",
                        s, idx, get_item_id(idx))),
              shiny::div(class = "item-q", q_text),
              shiny::div(class = "resp-row", resp_chips),
              info_ui
            ),
            shiny::div(class = "nav-strip",
              shiny::actionButton("btn_prev", "\u25C0 Back",
                style = paste(
                  "background:#eee; border:none; border-radius:5px;",
                  "padding:7px 16px;")),
              shiny::actionButton("btn_next",
                if (s < cat_k) "Next \u25B6" else "Results \u25B6",
                style = paste(
                  "background:#2E86AB; color:#fff; border:none;",
                  "border-radius:5px; padding:7px 16px;")),
              shiny::actionButton("btn_end", "Jump to Results",
                style = paste(
                  "background:#888; color:#fff; border:none;",
                  "border-radius:5px; padding:7px 14px; font-size:.82em;")),
              shiny::span(style = "flex:1;"),
              shiny::div(
                shiny::span(class = "stat-chip",
                  shiny::span(class = "stat-v",
                    sprintf("%+.3f", theta_traj[s])),
                  shiny::span(class = "stat-l",
                    "\u03b8\u0302 (EAP)")),
                shiny::span(class = "stat-chip",
                  shiny::span(class = "stat-v",
                    sprintf("%.3f", se_traj[s])),
                  shiny::span(class = "stat-l", "SE"))
              )
            )
          ),
          # Right: trajectory plots
          shiny::column(5,
            shiny::div(class = "traj-panel",
              shiny::plotOutput("theta_plot", height = "270px"),
              shiny::plotOutput("se_plot",    height = "155px")
            )
          )
        )
      }
    })

    # ── Trajectory plots ─────────────────────────────────────────────────────
    output$theta_plot <- shiny::renderPlot({
      if (view() == "results") return(invisible(NULL))
      s     <- step()
      steps <- seq_len(s)
      col_a <- "#2E86AB"
      ylim  <- range(c(theta_traj, true_th), na.rm = TRUE) + c(-0.35, 0.35)

      plot(steps, theta_traj[steps],
           type = "b", pch = 19, col = col_a, lwd = 2.2,
           xlim = c(1, cat_k), ylim = ylim,
           xlab = "Item", ylab = expression(hat(theta)),
           main = "Ability trajectory", bty = "l", las = 1, cex.axis = .82)
      abline(h = true_th,  lty = 2, col = "#A23B72", lwd = 1.6)
      points(s, theta_traj[s], pch = 19, col = col_a, cex = 1.9)
      legend("topright", bty = "n", cex = .76,
             legend = c(expression(hat(theta) ~ "(EAP)"), "True \u03b8"),
             col = c(col_a, "#A23B72"), lwd = c(2.2, 1.6), lty = c(1, 2))
    }, bg = "white")

    output$se_plot <- shiny::renderPlot({
      if (view() == "results") return(invisible(NULL))
      s     <- step()
      steps <- seq_len(s)

      plot(steps, se_traj[steps],
           type = "b", pch = 19, col = "#F18F01", lwd = 2.2,
           xlim = c(1, cat_k),
           ylim = c(0, max(se_traj, na.rm = TRUE) + 0.06),
           xlab = "Item", ylab = "SE",
           main = "Standard error", bty = "l", las = 1, cex.axis = .82)
      if (is.numeric(config$min_SEM))
        abline(h = config$min_SEM, lty = 3, col = "grey50", lwd = 1.2)
    }, bg = "white")

    # ── Results stats UI ──────────────────────────────────────────────────────
    output$results_stats <- shiny::renderUI({
      ft   <- arm$final_theta
      fse  <- arm$final_se
      aerr <- abs(ft - true_th)

      stat_box <- function(val, lbl) {
        shiny::div(class = "stat-chip",
          shiny::span(class = "stat-v", val),
          shiny::span(class = "stat-l", lbl))
      }

      rows <- shiny::fluidRow(
        shiny::column(3, stat_box(sprintf("%+.3f", ft),    "\u03b8\u0302 (final EAP)")),
        shiny::column(3, stat_box(sprintf("%.3f",  fse),   "SE")),
        shiny::column(3, stat_box(sprintf("%+.3f", true_th),"True \u03b8")),
        shiny::column(3, stat_box(sprintf("%.3f",  aerr),  "|\u03b8\u0302 \u2212 \u03b8|"))
      )

      cmp_rows <- if (show_mcar && !is.null(mcar_arm)) {
        mcar_aerr   <- abs(mcar_arm$final_theta - true_th)
        se_diff_pct <- (mcar_arm$final_se - fse) / mcar_arm$final_se * 100
        se_col      <- if (se_diff_pct > 0) "#2a7a3a" else "#c0392b"

        shiny::tagList(
          shiny::hr(),
          shiny::p(
            shiny::span(class = "cond-tag cond-mcar", "MCAR arm"),
            " — same individual, random item selection"),
          shiny::fluidRow(
            shiny::column(3,
              stat_box(sprintf("%+.3f", mcar_arm$final_theta), "\u03b8\u0302 MCAR")),
            shiny::column(3,
              stat_box(sprintf("%.3f", mcar_arm$final_se), "SE MCAR")),
            shiny::column(3,
              stat_box(sprintf("%.3f", mcar_aerr), "|\u03b8\u0302 \u2212 \u03b8| MCAR")),
            shiny::column(3,
              shiny::div(class = "stat-chip",
                shiny::span(class = "stat-v",
                  style = sprintf("color:%s;", se_col),
                  sprintf("%+.1f%%", se_diff_pct)),
                shiny::span(class = "stat-l", "SE reduction (adaptive)")))
          ),
          shiny::p(class = "cmp-note",
            sprintf(
              "Note: this is one participant from N\u202f=\u202f%d. Individual-level SE ",
              n_sim),
            "differences are not statistically meaningful. The adaptive advantage ",
            "operates at the population level \u2014 see sim$summary for RMSE(\u03b8) gains.")
        )
      } else shiny::tagList()

      shiny::tagList(
        shiny::p(shiny::span(class = "cond-tag cond-adapt", toupper(condition)),
                 sprintf("  |  %d items administered", cat_k)),
        rows,
        cmp_rows
      )
    })

    # ── Final trajectory plot (results page) ─────────────────────────────────
    output$final_traj_plot <- shiny::renderPlot({
      col_a <- "#2E86AB"
      col_m <- "#F18F01"

      par(mfrow = c(1, 2), mar = c(4, 4, 3, 1.5))

      # Theta
      ylim <- range(c(theta_traj, true_th,
                      if (!is.null(mcar_arm)) mcar_arm$theta_traj else numeric(0)),
                    na.rm = TRUE) + c(-0.3, 0.3)
      plot(seq_len(cat_k), theta_traj,
           type = "b", pch = 19, col = col_a, lwd = 2.2,
           xlab = "Item", ylab = expression(hat(theta)),
           main = sprintf("Ability: participant #%d", id),
           ylim = ylim, bty = "l", las = 1, cex.axis = .82)
      abline(h = true_th, lty = 2, col = "#A23B72", lwd = 1.6)
      if (show_mcar && !is.null(mcar_arm))
        lines(seq_len(cat_k), mcar_arm$theta_traj,
              col = col_m, lwd = 1.5, lty = 3)
      lgd <- c(expression(hat(theta) ~ "adaptive"), "True \u03b8")
      lcl <- c(col_a, "#A23B72")
      llw <- c(2.2, 1.6); llt <- c(1, 2)
      if (show_mcar && !is.null(mcar_arm)) {
        lgd <- c(lgd, expression(hat(theta) ~ "MCAR"))
        lcl <- c(lcl, col_m); llw <- c(llw, 1.5); llt <- c(llt, 3)
      }
      legend("topright", bty = "n", cex = .76,
             legend = lgd, col = lcl, lwd = llw, lty = llt)

      # SE
      ylim_se <- c(0, max(c(se_traj,
                             if (!is.null(mcar_arm)) mcar_arm$se_traj else numeric(0)),
                          na.rm = TRUE) + 0.06)
      plot(seq_len(cat_k), se_traj,
           type = "b", pch = 19, col = col_a, lwd = 2.2,
           xlab = "Item", ylab = "SE",
           main = "Standard error",
           ylim = ylim_se, bty = "l", las = 1, cex.axis = .82)
      if (show_mcar && !is.null(mcar_arm))
        lines(seq_len(cat_k), mcar_arm$se_traj,
              col = col_m, lwd = 1.5, lty = 3)
      if (is.numeric(config$min_SEM))
        abline(h = config$min_SEM, lty = 3, col = "grey50", lwd = 1.2)
      if (show_mcar && !is.null(mcar_arm))
        legend("topright", bty = "n", cex = .76,
               legend = c("Adaptive", "MCAR"),
               col = c(col_a, col_m), lwd = c(2.2, 1.5), lty = c(1, 3))
    }, bg = "white")

    # ── Navigation observers ──────────────────────────────────────────────────
    shiny::observeEvent(input$btn_next, {
      s <- step()
      if (s < cat_k) step(s + 1L) else view("results")
    })

    shiny::observeEvent(input$btn_prev, {
      s <- step()
      if (s > 1L) step(s - 1L)
    })

    shiny::observeEvent(input$btn_end, {
      view("results")
    })

    shiny::observeEvent(input$btn_restart, {
      step(1L)
      view("assessment")
    })
  }

  shiny::runApp(
    shiny::shinyApp(ui = ui, server = server),
    launch.browser = launch_browser,
    ...
  )
}
