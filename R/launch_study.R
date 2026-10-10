#' Launch a Study
#'
#' Builds the Shiny application for a study and either returns it or runs it.
#' The study is either a fixed-form questionnaire or a computerized adaptive
#' test (CAT), as set in \code{config}. The function is currently one large
#' function and is meant to be split into smaller internal helpers.
#'
#' @export
#' @param config A study configuration list created by
#'   \code{\link{create_study_config}}.
#' @param item_bank Data frame with the items. Required columns depend on the
#'   model and on whether the study is adaptive (see \strong{Item Bank
#'   Requirements}). If missing or \code{NULL}, \code{config$items} is used.
#' @param custom_css Character string with CSS. It is appended after the
#'   theme CSS, so its rules take precedence over the theme.
#' @param theme_config Named list. Only \code{primary_color} is used, as the
#'   color of the progress indicator, the PDF button and the ability plot.
#'   Other entries are ignored; use \code{custom_css} or a theme to change
#'   other colors and fonts.
#' @param webdav_url Where inrep stores each participant's session file
#'   (JSON) on a WebDAV server, or \code{NULL} for local storage only. Any
#'   WebDAV server works; the accepted forms are:
#'   \itemize{
#'     \item a Nextcloud/ownCloud share link as shown in the browser, e.g.
#'       \code{"https://cloud.example.org/index.php/s/AbCdEf123"};
#'     \item a public share WebDAV address, \code{".../public.php/webdav/"}
#'       (then also give \code{webdav_share_token}) or
#'       \code{".../public.php/dav/files/<token>/"};
#'     \item any WebDAV folder, e.g.
#'       \code{"https://cloud.example.org/remote.php/dav/files/jdoe/study/"}
#'       (then also give \code{webdav_user}).
#'   }
#'   A character vector of URLs is tried in order (for a share that may live
#'   on one of several hosts). The academiccloud URLs in the case studies are
#'   those studies' own storage: replace them with yours. See
#'   \code{\link{webdav_upload}} for how each form is handled.
#' @param password Share password (public shares) or account/app password
#'   (plain WebDAV); \code{NULL} or \code{""} for none. Do not write it into
#'   scripts that are shared or pushed; use e.g.
#'   \code{Sys.getenv("WEBDAV_PASSWORD")} with the value in \code{~/.Renviron}.
#' @param webdav_share_token Token of a public share (the part after
#'   \code{/s/} in the share link). Only needed when \code{webdav_url} is a
#'   bare \code{.../public.php/webdav/} address.
#' @param webdav_user User name for a plain (non-share) WebDAV folder.
#' @param save_format Format of the report file offered by the download
#'   button on the built-in results page (shown only when
#'   \code{config$participant_report$show_legacy_buttons = TRUE}). One of
#'   \code{"rds"} (default), \code{"csv"}, \code{"json"} or \code{"pdf"}.
#'   \code{"pdf"} needs a LaTeX installation via \pkg{tinytex}; if the PDF
#'   cannot be built, a JSON file is written instead.
#' @param logger Logging function called as \code{logger(msg, level = ...)}.
#'   The default passes every message, including debug messages, to
#'   \code{message()}.
#' @param admin_dashboard_hook Optional function. In the built-in assessment
#'   flow (not in a \code{custom_page_flow}) it is called after each response
#'   and item selection with a list containing \code{participant_id},
#'   \code{progress} (percent of \code{max_items}), \code{theta}, \code{se},
#'   \code{items_administered} and \code{responses}.
#' @param accessibility Currently ignored.
#' @param study_key Character string identifying the study. Overrides
#'   \code{config$study_key}. Local session files are stored under
#'   \code{study_data/<study_key>/}.
#' @param max_session_time Maximum duration of a participant session in
#'   seconds (default 7200). The session is checked once per minute and
#'   closed when this time is exceeded.
#' @param session_save Logical. If \code{TRUE}, the participant's reactive
#'   state is written to \code{study_data/<study_key>/session.rds} on page
#'   changes, on responses and when the session ends (default \code{FALSE}).
#' @param data_preservation_interval Passed to the internal session state
#'   (seconds, default 30).
#' @param keep_alive_interval Passed to the internal session state (seconds,
#'   default 10).
#' @param enable_error_recovery Logical, stored in the internal
#'   error-handling state. \code{launch_study()} does not install the global
#'   error handler that reads it, so it currently has no visible effect.
#' @param debug_mode Logical (default \code{FALSE}). If \code{TRUE}, a debug
#'   panel is shown and keyboard shortcuts are enabled: Ctrl+A fills the
#'   current page, Ctrl+Q fills and advances through all pages until the
#'   results, Ctrl+Y does the same with shorter delays. For development and
#'   testing only.
#' @param ui_render_delay,package_loading_delay,session_init_delay,show_loading_screen
#'   Currently ignored.
#' @param immediate_ui Logical (default \code{FALSE}). If \code{TRUE}, the
#'   optional packages \pkg{ggplot2}, \pkg{DT} and \pkg{shinyWidgets} are
#'   treated as unavailable, so plots, interactive tables and button-style
#'   response options are not used.
#' @param auto_close_time Numeric. Time until the window is closed after the
#'   final results page. Used only in a \code{custom_page_flow} with results
#'   pages.
#' @param auto_close_time_unit Character. Either \code{"seconds"} or \code{"minutes"}.
#' @param disable_auto_close Logical. If TRUE, disables automatic closing.
#' @param port Port number (default 3838), used when \code{launch_browser = TRUE}.
#' @param launch_browser Logical (default \code{FALSE}). If \code{TRUE}, the
#'   app is run with \code{shiny::runApp()} and opened in the browser. If
#'   \code{FALSE}, the Shiny app object is returned.
#' @param host Host address (default \code{"127.0.0.1"}), used when
#'   \code{launch_browser = TRUE}. Use \code{"0.0.0.0"} to accept connections
#'   from other machines.
#' @param ... Not used; any arguments given here are reported and ignored.
#'
#' @return If \code{launch_browser = FALSE} (default), a Shiny app object that
#'   can be run with \code{shiny::runApp()}. Otherwise the app is run and the
#'   value of \code{shiny::runApp()} is returned when it stops.
#'
#' @details
#' \strong{Psychometric computations.} inrep does not calibrate items. In an
#' adaptive study the item parameters in \code{item_bank} are taken as known.
#' After each response, ability is estimated by \code{\link{estimate_ability}}
#' (expected a posteriori estimate on a grid with the normal prior
#' \code{config$theta_prior}; the reported SE is the posterior standard
#' deviation), and the next item is chosen by
#' \code{\link{fast_select_next_item}} (maximum Fisher information, the
#' default) or \code{\link{select_next_item}} when
#' \code{config$fast_item_selection = FALSE}. Items before position
#' \code{config$adaptive_start} (default: \code{min_items}) are drawn at
#' random. The test stops when
#' \code{min_items} have been given and either \code{max_items} is reached or
#' the SE falls to \code{min_SEM}, unless
#' \code{config$stopping_rule} is supplied. Supported models are 1PL, 2PL,
#' 3PL and the graded response model (GRM).
#'
#' In a non-adaptive study the items are presented in a fixed order and no
#' ability estimate is computed.
#'
#' @section Cloud Storage Configuration:
#' Optional upload of completed session data to a WebDAV endpoint.
#' \itemize{
#'   \item \code{password} without \code{webdav_url} is an error.
#'   \item \code{webdav_url} without \code{password} uploads anonymously
#'     (public shares that allow uploads).
#'   \item The URL must start with \code{http://} or \code{https://};
#'     prefer HTTPS.
#'   \item Read the password from an environment variable, for example
#'     \code{password = Sys.getenv("WEBDAV_PASSWORD")}, and prefer an app
#'     password or share password over an account password.
#' }
#'
#' \preformatted{
#' # Local storage only (default)
#' launch_study(config, item_bank)
#'
#' # With upload to a Nextcloud/ownCloud share (replace with your own)
#' launch_study(
#'   config,
#'   item_bank,
#'   webdav_url = "https://cloud.example.org/index.php/s/YourShareToken",
#'   password = Sys.getenv("WEBDAV_PASSWORD")
#' )
#'
#' # With upload to a personal WebDAV folder
#' launch_study(
#'   config,
#'   item_bank,
#'   webdav_url = "https://cloud.example.org/remote.php/dav/files/jdoe/study/",
#'   webdav_user = "jdoe",
#'   password = Sys.getenv("WEBDAV_PASSWORD")
#' )
#' }
#'
#' @section Notes:
#' Most runtime behavior is configured via \code{create_study_config()}. For
#' WebDAV upload behavior, see \code{save_session_to_cloud()}.
#'
#' @section Item Bank Requirements:
#' Every item bank needs a \code{Question} column with the item text (a
#' column \code{content} or \code{item_id} is copied to \code{Question} if
#' \code{Question} is missing; \code{discrimination} and \code{difficulty} are
#' copied to \code{a} and \code{b}). In a non-adaptive study no parameter
#' columns are checked.
#'
#' In an adaptive study \code{\link{validate_item_bank}} checks that these
#' columns exist (it does not check values, ranges or threshold order):
#' \describe{
#'   \item{1PL}{\code{b} (difficulty). \code{a} is set to 1 for all items.}
#'   \item{2PL}{\code{a} (discrimination) and \code{b}.}
#'   \item{3PL}{\code{a} and \code{b}. A column \code{c} (lower
#'     asymptote) is used when present; otherwise \code{c = 0}.}
#'   \item{GRM}{\code{a} and thresholds \code{b1} to \code{b4}, which should
#'     be in increasing order.}
#' }
#' For dichotomous models the response options are taken from
#' \code{Option1} to \code{Option4} and the keyed option from \code{Answer}.
#' For the GRM, the response categories are read from
#' \code{ResponseCategories}, a comma-separated string such as
#' \code{"1,2,3,4,5"}.
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' # Example 1: adaptive personality assessment with the GRM
#' basic_config <- create_study_config(
#'   name = "Big Five Personality Assessment",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.3,
#'   demographics = c("Age", "Gender", "Education"),
#'   theme = "Light",
#'   language = "en"
#' )
#' launch_study(basic_config, bfi_items)
#'
#' # Example 2: adaptive cognitive test with the 2PL and a monitoring hook
#' data(cognitive_items)
#' cog_config <- create_study_config(
#'   name = "Cognitive Ability Assessment",
#'   model = "2PL",
#'   max_items = 20,
#'   min_items = 10,
#'   min_SEM = 0.25,
#'   theta_prior = c(0, 1),
#'   demographics = c("Age", "Gender"),
#'   theme = "Professional"
#' )
#' launch_study(
#'   config = cog_config,
#'   item_bank = cognitive_items,
#'   admin_dashboard_hook = function(session_data) {
#'     cat("Participant ID:", session_data$participant_id, "\n")
#'     cat("Progress:", session_data$progress, "%\n")
#'     cat("Current theta:", round(session_data$theta, 3), "\n")
#'     cat("Standard error:", round(session_data$se, 3), "\n")
#'   }
#' )
#'
#' # Example 3: custom colors via CSS variables
#' launch_study(
#'   config = basic_config,
#'   item_bank = bfi_items,
#'   theme_config = list(primary_color = "#2E86AB"),
#'   custom_css = ":root { --primary-color: #2E86AB; --secondary-color: #A23B72; }"
#' )
#'
#' # Example 4: WebDAV upload and a custom logger
#' launch_study(
#'   config = basic_config,
#'   item_bank = bfi_items,
#'   webdav_url = "https://cloud.example.org/index.php/s/YourShareToken",
#'   password = Sys.getenv("WEBDAV_PASSWORD"),
#'   study_key = paste0("BFI_", generate_uuid()),
#'   logger = function(msg, level = "INFO") {
#'     timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
#'     cat(sprintf("[%s] %s: %s\n", timestamp, level, msg))
#'   }
#' )
#' }
#' @importFrom shiny shinyApp fluidPage tags div numericInput selectInput actionButton downloadButton uiOutput renderUI plotOutput h2 h3 h4 p tagList
#' @importFrom jsonlite write_json
launch_study <- function(
    config,
    item_bank,
    custom_css = NULL,
    theme_config = NULL,
    webdav_url = NULL,
    password = NULL,
    webdav_share_token = NULL,
    webdav_user = NULL,
    save_format = "rds",
    logger = function(msg, ...) message(msg),
    study_key = NULL,
    accessibility = FALSE,
    admin_dashboard_hook = NULL,
    max_session_time = 7200,
    session_save = FALSE,
    data_preservation_interval = 30,
    keep_alive_interval = 10,
    enable_error_recovery = TRUE,
    debug_mode = FALSE,
    ui_render_delay = NULL,
    package_loading_delay = NULL,
    session_init_delay = NULL,
    show_loading_screen = NULL,
    immediate_ui = FALSE,
    auto_close_time = 300,
    auto_close_time_unit = "seconds",
    disable_auto_close = FALSE,
    port = 3838,
    launch_browser = FALSE,
    host = "127.0.0.1",
    ...
) {
  
  # Helper function for language-aware validation messages
  get_validation_fallback_message <- function(current_lang) {
    if (current_lang == "en") {
      return("Please complete all required fields.\nPlease answer all questions on this page.")
    } else {
      return("Bitte vervollst\u00E4ndigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite.")
    }
  }
  
  # Scroll the participant's browser window to the top after a page change.
  scroll_to_top_enhanced <- function() {
    scroll_js <- "
    (function() {
      try {
        // Method 1: Modern scrollTo with options
        if (window.scrollTo) {
          window.scrollTo({
            top: 0,
            left: 0,
            behavior: 'instant'
          });
        }
      } catch(e) {
        try {
          // Method 2: Simple scrollTo
          window.scrollTo(0, 0);
        } catch(e2) {
          // Method 3: Direct element scrolling
          if (document.documentElement) {
            document.documentElement.scrollTop = 0;
            document.documentElement.scrollLeft = 0;
          }
          if (document.body) {
            document.body.scrollTop = 0;
            document.body.scrollLeft = 0;
          }
        }
      }

      setTimeout(function() {
        try {
          window.scrollTo(0, 0);
        } catch(e) {
          if (document.documentElement) {
            document.documentElement.scrollTop = 0;
          }
          if (document.body) {
            document.body.scrollTop = 0;
          }
        }
      }, 10);

      setTimeout(function() {
        try {
          window.scrollTo(0, 0);
        } catch(e) {
          if (document.documentElement) {
            document.documentElement.scrollTop = 0;
          }
        }
      }, 100);
    })();
    "

    if (requireNamespace("shinyjs", quietly = TRUE)) {
      tryCatch({
        shinyjs::runjs(scroll_js)
      }, error = function(e) {
        tryCatch({
          shinyjs::runjs("window.scrollTo(0, 0);")
        }, error = function(e2) {
          logger(sprintf("Scroll to top failed: %s", e2$message), level = "WARNING")
        })
      })
    } else {
      logger("shinyjs not available, skipping scroll to top", level = "WARNING")
    }
  }
  
  # Configuration checks and corrections (R/enhanced_features.R). Errors
  # here are logged and the study starts with the configuration as given.
  tryCatch({
    if (exists("validate_and_fix_config")) {
      config <- validate_and_fix_config(config, item_bank)
      
      # Show warnings if any
      if (!is.null(config$validation_warnings)) {
        for (warning_name in names(config$validation_warnings)) {
          logger(paste("Config warning:", config$validation_warnings[[warning_name]]))
        }
      }
    }
    
    if (exists("handle_extreme_parameters")) {
      config <- handle_extreme_parameters(config)
    }

  }, error = function(e) {
    logger(paste("Configuration check failed:", e$message))
  })
  
  # Check if shiny is available (required for UI)
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required but not available. Please install it with: install.packages('shiny')")
  }
  
  # 'later' is in Imports, so this is TRUE in an installed package.
  has_later <- requireNamespace("later", quietly = TRUE)

  extra_params <- list(...)
  if (length(extra_params) > 0) {
    logger(paste("Ignoring unused parameters:", paste(names(extra_params), collapse = ", ")), level = "INFO")
  }
  
  # Wire admin_dashboard_hook into config if provided
  if (!is.null(admin_dashboard_hook) && is.function(admin_dashboard_hook)) {
    config$admin_dashboard_hook <- admin_dashboard_hook
  }
  
  # Check if item_bank is provided, if not try to extract from config
  if (missing(item_bank) || is.null(item_bank)) {
    if (!is.null(config$items)) {
      item_bank <- config$items
      logger("Extracted items from config$items", level = "INFO")
    } else {
      stop("Argument 'item_bank' is required. Please provide the item bank data or include 'items' in your config.")
    }
  }
  
  # Records which optional packages are installed. Namespaces of the deferred
  # packages are loaded through 'later' after the app has started.
  safe_load_packages <- function(immediate = FALSE) {

    # With immediate_ui = TRUE, all optional packages are reported as
    # unavailable (no plots, no DT tables, no shinyWidgets buttons).
    if (immediate_ui) {
      return(list(
        shiny = TRUE,
        ggplot2 = FALSE,
        DT = FALSE, 
        dplyr = FALSE,
        shinyWidgets = FALSE,
        TAM = FALSE
      ))
    }
    critical_packages <- c("shiny")
    deferred_packages <- c("ggplot2", "DT", "dplyr", "shinyWidgets")
    optional_packages <- if (isTRUE(config$adaptive)) "TAM" else character(0)
    
    all_packages <- c(critical_packages, deferred_packages, optional_packages)
    loaded_packages <- as.list(setNames(rep(FALSE, length(all_packages)), all_packages))
    
    if (!immediate) {
      for (pkg in critical_packages) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
          stop(sprintf("Critical package '%s' is required", pkg))
        }
        loaded_packages[[pkg]] <- TRUE
      }
      
      for (pkg in c(deferred_packages, optional_packages)) {
        loaded_packages[[pkg]] <- requireNamespace(pkg, quietly = TRUE)
      }
      
      if (has_later) {
        package_loop <- NULL
        tryCatch({
          package_loop <- later::create_loop()
        }, error = function(e) {
          package_loop <<- later::global_loop()
        })

        later::later(function() {
          for (pkg in optional_packages) {
            tryCatch({
              if (loaded_packages[[pkg]]) {
                logger(sprintf("Package %s available", pkg), level = "DEBUG")
              }
            }, error = function(e) {
              logger(sprintf("Optional package %s not available", pkg), level = "DEBUG")
            })
          }
          later::run_now(timeoutSecs = 0, all = FALSE, loop = package_loop)
        }, delay = 0, loop = package_loop)

        later::later(function() {
          for (pkg in deferred_packages) {
            tryCatch({
              if (loaded_packages[[pkg]]) {
                loadNamespace(pkg)
                logger(sprintf("Background loaded: %s", pkg), level = "DEBUG")
              }
            }, error = function(e) {
              logger(sprintf("Could not load %s: %s", pkg, e$message), level = "DEBUG")
            })
          }
          later::run_now(timeoutSecs = 0, all = TRUE, loop = package_loop)
        }, delay = 0.001, loop = package_loop)

        # The private loop only runs when run_now() is called on it.
        later::later(function() {
          later::run_now(timeoutSecs = 0, all = TRUE, loop = package_loop)
        }, delay = 0)
      }
    } else {
      for (pkg in c(critical_packages, optional_packages)) {
        if (requireNamespace(pkg, quietly = TRUE)) {
          if (!pkg %in% loadedNamespaces()) {
            loadNamespace(pkg)
          }
          loaded_packages[[pkg]] <- TRUE
        }
      }
    }
    
    return(loaded_packages)
  }
  
  available_packages <- safe_load_packages(immediate = FALSE)
  
  # renderDT() when DT is installed, otherwise a text placeholder.
  safe_render_dt <- function(expr, ...) {
    dt_available <- if (!is.null(available_packages) && is.list(available_packages)) {
      isTRUE(available_packages[["DT"]])
    } else {
      requireNamespace("DT", quietly = TRUE)
    }
    
    if (dt_available) {
      tryCatch({
        DT::renderDT(expr, ...)
      }, error = function(e) {
        logger(sprintf("DT::renderDT error: %s", e$message), level = "ERROR")
        # Fallback to text output
        shiny::renderPrint({
          "Table rendering failed - displaying data as text instead"
        })
      })
    } else {
      shiny::renderPrint({
        "Table rendering not available - DT package not installed"
      })
    }
  }
  
  if (base::is.null(config)) {
    logger("Configuration is NULL", level = "ERROR")
    base::stop("Configuration is NULL")
  }
  if (base::is.null(item_bank)) {
    logger("Item bank is NULL", level = "ERROR")
    base::stop("Item bank is NULL")
  }
  if (!save_format %in% base::c("rds", "csv", "json", "pdf")) {
    logger("Invalid save_format", level = "ERROR")
    base::stop("Invalid save_format")
  }
  
  # Cloud storage validation
  if (!base::is.null(webdav_url) || !base::is.null(password)) {
    if (base::is.null(webdav_url) && !base::is.null(password)) {
      logger("Password provided without WebDAV URL", level = "ERROR")
      base::stop("Cloud storage requires both 'webdav_url' and 'password' arguments.\n",
                 "You provided a password but no WebDAV URL.\n",
                 "Please provide both arguments together:\n",
                 "  webdav_url = \"https://your-cloud-storage.com/path/\"\n",
                 "  password = \"your-access-password\"\n",
                 "Or remove both arguments to use local storage only.")
    }
    if (!base::is.null(webdav_url) && base::is.null(password)) {
      # Public shares without a password accept anonymous uploads
      logger("WebDAV URL without password - uploading anonymously", level = "INFO")
    }
    if (!base::is.null(webdav_url)) {
      # Validate URL format
      if (!all(grepl("^https?://", webdav_url))) {
        logger("Invalid WebDAV URL format", level = "ERROR")
        base::stop("WebDAV URL must start with 'http://' or 'https://'\n",
                   "Provided: ", paste(webdav_url, collapse = ", "), "\n",
                   "Example: webdav_url = \"https://cloud.example.org/index.php/s/YourShareToken\"")
      }
      logger(paste("Cloud storage enabled:", paste(webdav_url, collapse = ", ")), level = "INFO")
    }
  } else {
    logger("No webdav_url given: data are stored locally only", level = "INFO")
  }
  
  theme_display <- if (is.list(config$theme)) "custom" else (config$theme %||% "Light")
  logger(base::sprintf("Launching study: %s with theme: %s", config$name, theme_display), level = "INFO")
  
  if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
    logger("Admin dashboard hook registered", level = "INFO")
  }
  
  # Per-participant initialization happens in the server function.
  .needs_session_init <- session_save
  session_config <- NULL
  error_config <- NULL

  # Read once by the first server session (see "Per-session state" below).
  .force_new_session <- TRUE

  # Note: this runs once per launch_study() call, not once per participant,
  # so the state it creates (R/robust_session.R) is shared by all sessions.
  logger("Initializing session management", level = "INFO")
  session_config <- tryCatch({
    if (exists("initialize_robust_session") && is.function(initialize_robust_session)) {
      initialize_robust_session(
        max_session_time = max_session_time,
        data_preservation_interval = data_preservation_interval,
        keep_alive_interval = keep_alive_interval,
        enable_logging = TRUE
      )
    } else {
      # Fallback to basic session management
      list(
        session_id = paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S")),
        start_time = Sys.time(),
        max_time = max_session_time,
        log_file = NULL
      )
    }
      }, error = function(e) {
        logger(sprintf("Failed to initialize session management: %s", e$message), level = "WARNING")
        list(
          session_id = paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S")),
          start_time = Sys.time(),
          max_time = max_session_time,
          log_file = NULL
        )
      })
      
      error_config <- tryCatch({
        if (exists("initialize_robust_error_handling") && is.function(initialize_robust_error_handling)) {
          initialize_robust_error_handling(
            max_recovery_attempts = 3,
            enable_auto_recovery = enable_error_recovery
          )
        } else {
          list(
            max_recovery_attempts = 3,
            enable_auto_recovery = enable_error_recovery
          )
        }
      }, error = function(e) {
        logger(sprintf("Failed to initialize error handling: %s", e$message), level = "WARNING")
        list(
          max_recovery_attempts = 3,
          enable_auto_recovery = enable_error_recovery
        )
      })
      
      backup_observer <- tryCatch({
        if (exists("create_periodic_backup") && is.function(create_periodic_backup)) {
          create_periodic_backup(backup_interval = 300)  # 5 minutes
        } else {
          NULL
        }
      }, error = function(e) {
        logger(sprintf("Failed to create periodic backup: %s", e$message), level = "WARNING")
        NULL
      })
      
      if (session_save && exists("start_data_preservation_monitoring") && is.function(start_data_preservation_monitoring)) {
        tryCatch({
          start_data_preservation_monitoring()
        }, error = function(e) {
          logger(sprintf("Failed to start data preservation monitoring: %s", e$message), level = "WARNING")
        })
      } else if (session_save) {
        logger("Session saving enabled (basic mode)", level = "INFO")
      }
      
      if (session_save && exists("log_session_event") && is.function(log_session_event)) {
        tryCatch({
          log_session_event(
            event_type = "session_initialized",
            message = "Session initialized successfully",
            details = list(
              session_id = session_config$session_id,
              max_time = max_session_time,
              data_preservation_interval = data_preservation_interval,
              keep_alive_interval = keep_alive_interval,
              study_name = config$name,
              participant_id = if (!is.null(study_key)) study_key else "unknown",
              timestamp = Sys.time()
            )
          )
        }, error = function(e) {
          logger(sprintf("Session event logging failed: %s", e$message), level = "WARNING")
        })
      }
      
      logger(sprintf("Session initialized: %s (max time: %d seconds)", 
                     session_config$session_id, session_config$max_time), level = "INFO")
  
  # Normalize common alternative column names before validation
  if ("content" %in% names(item_bank) && !"Question" %in% names(item_bank)) item_bank$Question <- item_bank$content
  if ("item_id" %in% names(item_bank) && !"Question" %in% names(item_bank)) item_bank$Question <- as.character(item_bank$item_id)
  if ("discrimination" %in% names(item_bank) && !"a" %in% names(item_bank)) item_bank$a <- item_bank$discrimination
  if ("difficulty" %in% names(item_bank) && !"b" %in% names(item_bank)) item_bank$b <- item_bank$difficulty
  
  # Validate item bank; stop if critical mismatch detected.
  # IRT column checks are skipped for non-adaptive studies (adaptive = FALSE).
  validation <- inrep::validate_item_bank(item_bank, config$model, adaptive = isTRUE(config$adaptive))
  if (is.list(validation) && !isTRUE(validation$is_valid)) {
    stop(paste0("Item bank / model mismatch:\n", paste(validation$messages, collapse = "\n")),
         call. = FALSE)
  }

  # Validate custom page flow early with a direct, actionable error.
  if (!is.null(config$custom_page_flow) && length(config$custom_page_flow) > 0) {
    page_types <- vapply(config$custom_page_flow, function(p) p$type %||% NA_character_, character(1))
    if (!any(page_types == "results", na.rm = TRUE)) {
      message(
        "Note: custom_page_flow has no page with type = 'results'. ",
        "The study will route to the last page after items complete. ",
        "Add type = 'results' to the final page (or use type = 'custom') to serve as an offboarding page."
      )
    }
  }
  
  # DEFER model conversion - will be done in server after UI shows
  .needs_conversion <- config$model %in% c("1PL", "2PL", "3PL") && 
                       "ResponseCategories" %in% names(item_bank) && 
                       !all(c("Option1", "Option2", "Option3", "Option4", "Answer") %in% names(item_bank))
  
  # Adjust max_items if necessary
  if (base::is.null(config$max_items) || config$max_items > base::nrow(item_bank)) {
    logger(base::sprintf("Adjusting max_items to item bank size: %d", base::nrow(item_bank)))
    config$max_items <- base::nrow(item_bank)
  }
  
  # Add default values for missing config parameters
  if (base::is.null(config$adaptive_start)) {
    config$adaptive_start <- config$min_items %||% 3
    logger(base::sprintf("Setting default adaptive_start: %d", config$adaptive_start))
  }

  # theme_config is not passed on: get_theme_css() expects a nested list
  # (colors$primary, ...) and would replace the theme's whole :root block.
  theme_css <- get_theme_css(
    theme = config$theme %||% "Light",
    custom_css = custom_css
  )
  
  if (config$model == "1PL") item_bank$a <- base::rep(1, base::nrow(item_bank))
  
  # Base layout CSS using the theme's CSS variables
  enhanced_css <- paste0(theme_css, "
    body { 
      font-family: var(--font-family);
      color: var(--text-color);
      background-color: var(--background-color);
      margin: 0;
      padding: 20px;
      line-height: 1.6;
    }
    
    /* Container fluid - removed conflicting rules, handled by layout fixes below */
    
    /* Prevent weird scaling */
    * {
      box-sizing: border-box;
    }
    
    html {
      overflow-x: hidden;
      width: 100%;
    }
    
    .card {
      border-radius: var(--border-radius);
    }
    
    .assessment-card {
      border-radius: var(--border-radius);
      padding: 30px;
      margin: 20px 0;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      border: 1px solid var(--secondary-color);
      animation: fadeInCard 0.1s ease-in;
    }
    
    @keyframes fadeInCard {
      from {
        opacity: 1;
      }
      to {
        opacity: 1;
      }
    }
    
    .card-header {
      color: var(--text-color);
      margin-bottom: 25px;
      font-size: 28px;
      font-weight: 600;
      text-align: center;
    }
    
    .form-group {
      margin-bottom: 20px;
    }
    
    .input-label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: var(--text-color);
    }
    
    .nav-buttons {
      margin-top: 30px;
      text-align: center;
    }
    
    .btn-klee {
      background-color: var(--primary-color);
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: var(--border-radius);
      cursor: pointer;
      margin: 0 10px;
      font-size: 16px;
      font-weight: 500;
      transition: background-color 0.2s;
    }
    
    .btn-klee:hover {
      background-color: var(--button-hover-color, var(--secondary-color));
    }
    
    /* Use the theme colors for Bootstrap buttons (all themes) */
    .btn-primary {
      background-color: var(--primary-color) !important;
      border-color: var(--primary-color) !important;
    }
    
    .btn-primary:hover {
      background-color: var(--button-hover-color, var(--secondary-color)) !important;
      border-color: var(--button-hover-color, var(--secondary-color)) !important;
    }
    
    .btn-success {
      background-color: var(--success-color, var(--primary-color)) !important;
      border-color: var(--success-color, var(--primary-color)) !important;
    }
    
    .btn-secondary {
      background-color: #6c757d !important;
      border-color: #6c757d !important;
    }
    
    .test-question {
      font-size: 20px;
      font-weight: 500;
      margin: 25px 0;
      line-height: 1.5;
      color: var(--text-color);
    }
    
    .radio-group-container {
      margin: 25px 0;
    }
    
    .error-message {
      color: var(--error-color);
      background-color: rgba(var(--error-color), 0.1);
      border: 1px solid var(--error-color);
      padding: 12px;
      border-radius: var(--border-radius);
      margin: 15px 0;
    }
    
    .error-card {
      border-color: var(--error-color);
      background-color: rgba(var(--error-color), 0.05);
    }
    
    .error-header {
      color: var(--error-color);
    }
    
    .session-status-indicator {
      font-family: 'Inter', sans-serif;
      box-shadow: 0 2px 8px rgba(0,0,0,0.3);
      transition: all 0.3s ease;
    }
    
    .session-status-indicator:hover {
      /* Removed transform to prevent positioning issues */
      opacity: 0.95;
    }
    
    .feedback-message {
      color: var(--success-color);
      background-color: rgba(var(--success-color), 0.1);
      border: 1px solid var(--success-color);
      padding: 12px;
      border-radius: var(--border-radius);
      margin: 15px 0;
    }
    
    .welcome-text {
      color: var(--text-color);
      opacity: 0.8;
      margin-bottom: 25px;
      line-height: 1.6;
      font-size: 16px;
    }
    
    .results-section {
      margin: 25px 0;
    }
    
    .dimension-score {
      background: rgba(var(--primary-color), 0.05);
      padding: 20px;
      border-radius: var(--border-radius);
      margin: 15px 0;
      border-left: 4px solid var(--primary-color);
    }
    
    .dimension-title {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 10px;
    }
    
    .dimension-value {
      font-weight: bold;
      color: var(--primary-color);
    }
    
    .dimension-bar {
      width: 100%;
      height: 8px;
      background: var(--progress-bg-color);
      border-radius: 4px;
      overflow: hidden;
    }
    
    .dimension-fill {
      height: 100%;
      background: var(--primary-color);
      transition: width 0.3s ease;
    }
    
    .progress-bar-container {
      width: 100%;
      background: var(--progress-bg-color, #e5e7eb);
      height: 12px;
      border-radius: 6px;
      margin: 25px 0;
      overflow: hidden;
    }
    
    .progress-bar-fill {
      height: 100%;
      background: var(--primary-color, #2c3e50);
      transition: width 0.3s ease;
      border-radius: 6px;
    }
    
    .progress-circle {
      text-align: center;
      margin: 20px 0;
    }
    
    .progress-circle svg {
      display: block;
      margin: 0 auto;
    }
    
    .progress-circle span {
      font-size: 18px;
      font-weight: bold;
      color: var(--primary-color);
    }
    
    .shiny-input-radiogroup {
      margin: 15px 0;
    }
    
    .shiny-input-radiogroup label {
      display: block;
      margin: 10px 0;
      cursor: pointer;
      padding: 12px;
      padding-left: 40px !important;  /* More space for radio button */
      border-radius: var(--border-radius);
      transition: background-color 0.2s;
      border: 1px solid var(--secondary-color);
      background-color: rgba(var(--secondary-color), 0.05);
      text-align: left;
      position: relative;  /* For absolute positioning of radio */
    }
    
    /* Fix all labels to have same alignment */
    .shiny-input-radiogroup label {
      margin-left: 0 !important;
    }
    
    .shiny-input-radiogroup label:hover {
      background-color: rgba(var(--primary-color), 0.1);
    }
    
    .shiny-input-radiogroup input[type='radio'] {
      position: relative;
      margin-right: 8px;
      vertical-align: middle;
    }
    
    /* Ensure text doesn't overlap with radio button */
    .shiny-input-radiogroup label span {
      display: inline-block;
      margin-left: 0;
    }
    
    .slider-container {
      margin: 25px 0;
    }
    
    .footer {
      text-align: center;
      margin-top: 30px;
      padding-top: 20px;
      border-top: 1px solid var(--secondary-color);
      color: var(--text-color);
      opacity: 0.7;
    }
    
    .recommendation-list {
      list-style-type: none;
      padding: 0;
    }
    
    .recommendation-list li {
      background: rgba(var(--primary-color), 0.05);
      padding: 10px;
      margin: 5px 0;
      border-radius: var(--border-radius);
      border-left: 4px solid var(--primary-color);
    }
  ")
  
  # Interface labels; the default language is German when config$language is unset
  default_language <- config$language %||% "de"
  ui_labels <- get_language_labels(default_language)
  
  ui <- shiny::fluidPage(
    class = "full-width-app",
    if (requireNamespace("shinyjs", quietly = TRUE)) shinyjs::useShinyjs(),
  
    
    # Layout CSS/JS that keeps page content centred while Shiny swaps pages
    # (prevents content from briefly appearing in the top-left corner).
    shiny::tags$head(
      # With config$log_data = TRUE: record input changes, button clicks,
      # tab visibility changes and a count of mouse movements.
      if (config$log_data %||% FALSE) {
        shiny::tags$script(shiny::HTML(paste0("
          $(document).ready(function() {
            // Track input changes
            $(document).on('change input', 'input, select, textarea', function() {
              Shiny.setInputValue('log_input_change', {
                element_id: $(this).attr('id'),
                element_type: this.tagName.toLowerCase(),
                timestamp: new Date().toISOString(),
                value: $(this).val()
              }, {priority: 'event'});
            });
            
            // Track button clicks
            $(document).on('click', 'button, .btn, input[type=\"button\"], input[type=\"submit\"]', function() {
              Shiny.setInputValue('log_button_click', {
                element_id: $(this).attr('id'),
                element_text: $(this).text().trim(),
                timestamp: new Date().toISOString()
              }, {priority: 'event'});
            });
            
            // Track page visibility changes (tab switching)
            document.addEventListener('visibilitychange', function() {
              Shiny.setInputValue('log_visibility_change', {
                hidden: document.hidden,
                timestamp: new Date().toISOString()
              }, {priority: 'event'});
            });
            
            // Track mouse movements (throttled)
            var mouseMoveCount = 0;
            $(document).on('mousemove', function() {
              mouseMoveCount++;
              if (mouseMoveCount % 100 === 0) { // Log every 100 mouse movements
                Shiny.setInputValue('log_mouse_activity', {
                  count: mouseMoveCount,
                  timestamp: new Date().toISOString()
                }, {priority: 'event'});
              }
            });
          });
        ")))
      },
      shiny::tags$style(shiny::HTML("
        /* Reset positioning of all elements so content stays centred.
           Slider internals (.irs, from shiny::sliderInput) are excluded: they
           are positioned absolutely by design and break completely otherwise. */
        *:not(.irs):not(.irs *) {
          box-sizing: border-box !important;
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          transform: none !important;
        }
        
        body, html {
          margin: 0 !important;
          padding: 0 !important;
          overflow-x: hidden !important;
        }
        
        /* Centre the Shiny output containers */
        .page-wrapper, .assessment-card, #study_ui, 
        .shiny-html-output, .shiny-bound-output, #stable-page-container,
        .container-fluid, #main-study-container, .shiny-output-binding {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin: 0 auto !important;
          transform: none !important;
          width: 100% !important;
          max-width: 1200px !important;
          display: block !important;
        }
        
        /* Override inline absolute/fixed positioning */
        [style*='position: absolute']:not(.irs *), [style*='position: fixed']:not(.irs *),
        [style*='left:']:not(.irs *), [style*='right:']:not(.irs *), [style*='top:']:not(.irs *) {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin: 0 auto !important;
          transform: none !important;
        }
        
        /* Progress circle */
        .progress-circle-gradient {
          position: relative !important;
          width: 120px !important;
          height: 120px !important;
          margin: 20px auto !important;
          display: flex !important;
          align-items: center !important;
          justify-content: center !important;
        }
        
        .progress-circle-gradient svg {
          position: absolute !important;
          top: 0 !important;
          left: 0 !important;
          width: 120px !important;
          height: 120px !important;
          display: block !important;
        }
        
        .progress-circle-gradient span {
          position: absolute !important;
          top: 50% !important;
          left: 50% !important;
          transform: translate(-50%, -50%) !important;
          font-size: 18px !important;
          font-weight: bold !important;
          color: var(--text-color) !important;
          text-align: center !important;
          z-index: 100 !important;
          margin: 0 !important;
          padding: 0 !important;
          line-height: 1 !important;
          width: auto !important;
          height: auto !important;
        }
        
        .session-status-indicator {
          position: relative !important;
          display: block !important;
          margin: 10px auto !important;
          text-align: center !important;
          max-width: 300px !important;
        }
        
        /* Overridden by the #study_ui rules in the next <head> block */
        #study_ui {
          visibility: visible !important;
          opacity: 1 !important;
        }
        
        /* Spinner animation */
        @keyframes spin {
          0% { transform: rotate(0deg) !important; }
          100% { transform: rotate(360deg) !important; }
        }
      ")),
      
      # Debug shortcuts (empty unless debug_mode = TRUE)
      generate_debug_mode_js(debug_mode),

      # Re-apply centred positioning to page containers as they are added
      shiny::tags$script(shiny::HTML("
        (function() {
          function forceCenter(element) {
            if (element && element.style) {
              element.style.position = 'relative';
              element.style.left = '0';
              element.style.right = '0';
              element.style.top = '0';
              element.style.margin = '0 auto';
              element.style.transform = 'none';
              element.style.width = '100%';
              element.style.maxWidth = '1200px';
            }
          }
          
          var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList') {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1) { // Element node
                    var isMainContainer = (
                      (node.classList && (
                        node.classList.contains('page-wrapper') ||
                        node.classList.contains('assessment-card') ||
                        node.classList.contains('shiny-html-output') ||
                        node.classList.contains('shiny-bound-output')
                      )) ||
                      node.id === 'study_ui' ||
                      node.id === 'stable-page-container' ||
                      node.id === 'main-study-container'
                    );
                    
                    if (isMainContainer) {
                      forceCenter(node);
                    }
                    
                    // Also check child elements
                    var children = node.querySelectorAll('.page-wrapper, .assessment-card, .shiny-html-output');
                    for (var i = 0; i < children.length; i++) {
                      forceCenter(children[i]);
                    }
                  }
                });
              }
            });
          });
          
          // MAINTENANCE NOTE (2026-05-03): Transition stability depends on
          // attaching this observer only when document.body exists.
          // If you change observer startup, keep this guard or startup may fail
          // with 'observe ... parameter 1 is not of type Node', which can break
          // first-render timing and reintroduce page-transition flicker.
          // Start observing only when a valid target node exists
          function startCenterObserver() {
            var target = document.body;
            if (target && target.nodeType === 1) {
              observer.observe(target, {
                childList: true,
                subtree: true,
                attributes: true,
                attributeFilter: ['style', 'class']
              });
            }
          }
          if (document.body && document.body.nodeType === 1) {
            startCenterObserver();
          } else {
            document.addEventListener('DOMContentLoaded', startCenterObserver, { once: true });
          }
          
          // Re-applied every 100 ms for the lifetime of the page
          setInterval(function() {
            var elements = document.querySelectorAll('.page-wrapper, .assessment-card, #study_ui, #stable-page-container');
            for (var i = 0; i < elements.length; i++) {
              forceCenter(elements[i]);
            }
          }, 100);
          
           document.addEventListener('DOMContentLoaded', function() {
             setTimeout(function() {
               var elements = document.querySelectorAll('.page-wrapper, .assessment-card, #study_ui, #stable-page-container');
               for (var i = 0; i < elements.length; i++) {
                 forceCenter(elements[i]);
               }
             }, 1);
           });
        })();
      "))
    ),

          shiny::tags$head(
      # Keep #study_ui hidden until it has been positioned (class "positioned")
      shiny::tags$style(shiny::HTML("
        /* Prevents content from flashing in the top-left corner */
        * {
          box-sizing: border-box;
        }
        
        body, html {
          margin: 0 !important;
          padding: 0 !important;
        }
        
        .page-wrapper,
        #study_ui,
        #study_ui > *,
        #study_ui > div,
        .shiny-html-output,
        .shiny-html-output > *,
        .assessment-card,
        .container-fluid,
        .shiny-bound-output {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin-left: auto !important;
          margin-right: auto !important;
          transform: none !important;
          width: 100% !important;
          max-width: 1200px !important;
        }
        
        /* Hide ALL content initially to prevent corner flash */
        #study_ui {
          visibility: hidden !important;
        }
        
        #study_ui.positioned {
          visibility: visible !important;
        }
        
        /* Force immediate centering */
        .container-fluid {
          display: block !important;
          width: 100% !important;
          max-width: 1200px !important;
          margin: 0 auto !important;
          padding: 0 15px !important;
        }
      ")),
      

      
      # Add spinner animation
      shiny::tags$style(shiny::HTML("
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes fadeInIndicator {
          from { opacity: 0; transform: translateX(20px); }
          to { opacity: 1; transform: translateX(0); }
        }
      ")),
      
      # ion.rangeSlider (shiny::sliderInput) measures its own width when Shiny
      # binds it. inrep binds new page content before it is laid out, so the
      # width is 0 and the handle and value start in the left corner, then jump
      # into place a few hundred ms later. Keep each slider invisible (its space
      # stays reserved) until it has been measured with its real width.
      shiny::tags$style(shiny::HTML("
        .irs.irs--shiny:not(.inrep-irs-ready) { visibility: hidden; }
      ")),
      shiny::tags$script(shiny::HTML("
        (function() {
          function settle(tries) {
            var pending = false;
            $('.js-range-slider').each(function() {
              var s = $(this).data('ionRangeSlider');
              if (!s || !s.$cache || !s.$cache.cont) return;
              var $cont = s.$cache.cont;
              if ($cont.hasClass('inrep-irs-ready')) return;
              // The slider stylesheet arrives with the first page that has a
              // slider, a moment after the slider itself: wait until it applies
              // (.irs becomes display: block) and the slider has its real width.
              var styled = $cont.css('display') === 'block';
              var width = s.$cache.rs ? s.$cache.rs.outerWidth() : 0;
              if (styled && width > 0) {
                if (Math.abs((s.coords.w_rs || 0) - width) > 1) s.update({});
                s.$cache.cont.addClass('inrep-irs-ready');
              } else if (tries > 120) {
                $cont.addClass('inrep-irs-ready');
              } else {
                pending = true;
              }
            });
            if (pending) requestAnimationFrame(function() { settle(tries + 1); });
          }
          $(document).on('shiny:bound shiny:value', function() {
            requestAnimationFrame(function() { settle(0); });
          });
        })();
      ")),

      # JavaScript to ensure proper positioning
      shiny::tags$script(shiny::HTML("
        // Smooth page transition handler
        (function() {
          let isTransitioning = false;
          
          // Add stable styles immediately to prevent corner flash
          var style = document.createElement('style');
          style.innerHTML = '.page-wrapper, .assessment-card {' +
            'position: relative !important;' +
            'left: 0 !important;' +
            'right: 0 !important;' +
            'top: 0 !important;' +
            'margin: 0 auto !important;' +
            'transform: none !important;' +
            'opacity: 1 !important;' +
            'width: 100% !important;' +
            'max-width: 1200px !important;' +
            'visibility: visible !important;' +
            '}' +
            '#study_ui > *, .shiny-html-output > *, .page-wrapper > * {' +
            'position: relative !important;' +
            'left: 0 !important;' +
            'right: 0 !important;' +
            'top: 0 !important;' +
            'margin-left: auto !important;' +
            'margin-right: auto !important;' +
            'transform: none !important;' +
            '}' +
            '.page-wrapper { visibility: hidden !important; }' +
            '.page-wrapper.positioned { visibility: visible !important; }';
          document.head.appendChild(style);
          
          // Immediately apply positioning classes
          function positionContent() {
            $('.page-wrapper, #study_ui > div').each(function() {
              $(this).css({
                'position': 'relative',
                'left': '0',
                'right': '0',
                'top': '0',
                'margin': '0 auto',
                'transform': 'none',
                'width': '100%',
                'max-width': '1200px'
              }).addClass('positioned');
            });
          }
          
          // Apply immediately and repeatedly to catch all cases
          positionContent();
          setTimeout(positionContent, 1);
          setTimeout(positionContent, 10);
          setTimeout(positionContent, 50);
          
          // Also position the main study UI immediately
          setTimeout(function() {
            var studyUi = document.getElementById('study_ui');
            if (studyUi) {
              studyUi.classList.add('positioned');
              studyUi.style.visibility = 'visible';
            }
          }, 1);
          
          // Simple transition function with debouncing
          function smoothTransition() {
            if (isTransitioning) return;
            isTransitioning = true;
            
            // Ensure stable positioning without flicker
            $('.page-wrapper, .assessment-card').css({
              'position': 'relative',
              'left': '0',
              'right': '0',
              'margin': '0 auto',
              'transform': 'none',
              'opacity': '1'
            });
            
            setTimeout(() => {
              isTransitioning = false;
            }, 100);
          }
          
          // Apply on page load
          smoothTransition();
        })();
        
        // Handle Shiny updates with minimal interference
        $(document).ready(function() {
          let updateTimeout;
          
                                // Immediate positioning on any content change
            $(document).on('shiny:value', function(event) {
              // Immediately position any new content
              $('.page-wrapper, .assessment-card').css({
                'position': 'relative',
                'left': '0',
                'right': '0',
                'top': '0',
                'margin': '0 auto',
                'transform': 'none',
                'opacity': '1',
                'width': '100%',
                'max-width': '1200px'
              });
              
              // Add positioned class immediately
              $('.page-wrapper').addClass('positioned');
            });
            
            // MAINTENANCE NOTE (2026-05-03): This study_ui-specific handler and
            // the generic shiny:value handler above work together.
            // Keep ordering and visibility writes consistent, otherwise old/new
            // page DOM can race and briefly flash in the corner during swaps.
            // Handle stage transitions with immediate positioning
            $(document).on('shiny:value', function(event) {
              if (event.name === 'study_ui') {
                // Immediately position new content to prevent corner flash
                $('.page-wrapper').css({
                  'visibility': 'hidden'
                });
                
                setTimeout(function() {
                  $('.page-wrapper').css({
                    'position': 'relative',
                    'left': '0',
                    'right': '0', 
                    'top': '0',
                    'margin': '0 auto',
                    'transform': 'none',
                    'width': '100%',
                    'max-width': '1200px',
                    'visibility': 'visible'
                  }).addClass('positioned');
                }, 1);
              }
            });
          
                      // Watch for any new content and position it immediately
            var observer = new MutationObserver(function(mutations) {
              mutations.forEach(function(mutation) {
                if (mutation.type === 'childList') {
                  mutation.addedNodes.forEach(function(node) {
                    if (node.nodeType === 1) { // Element node
                      var $node = $(node);
                      if ($node.hasClass('page-wrapper') || $node.find('.page-wrapper').length > 0) {
                        // Immediately position new page content
                        $node.find('.page-wrapper, .assessment-card').addBack('.page-wrapper, .assessment-card').css({
                          'position': 'relative',
                          'left': '0',
                          'right': '0',
                          'top': '0',
                          'margin': '0 auto',
                          'transform': 'none',
                          'width': '100%',
                          'max-width': '1200px',
                          'visibility': 'visible'
                        }).addClass('positioned');
                      }
                    }
                  });
                }
              });
            });
          
          // Start observing immediately
          if (document.getElementById('main-study-container')) {
            observer.observe(document.getElementById('main-study-container'), {
              childList: true,
              subtree: true
            });
          } else {
            // Observe the body if main container not found
            observer.observe(document.body, {
              childList: true,
              subtree: true
            });
          }
          
          // Additional immediate positioning on page load
          window.addEventListener('load', function() {
            var studyUi = document.getElementById('study_ui');
            if (studyUi) {
              studyUi.classList.add('positioned');
              studyUi.style.visibility = 'visible';
            }
          });
        });
      ")),
        shiny::tags$style(shiny::HTML("
          /* Simple full-width fix */
          .full-width-app > .container-fluid {
            padding: 0 15px !important;
            margin: 0 auto !important;
            width: 100% !important;
            max-width: 100% !important;
          }
          
          /* Ensure columns use full width */
          .full-width-app .col-sm-12 {
            width: 100% !important;
            padding: 0 !important;
          }
          
          /* Study UI full width */
          #study_ui {
            width: 100% !important;
            margin: 0 !important;
            padding: 0 !important;
          }
        ")),
        shiny::tags$style(type = "text/css", enhanced_css),
        shiny::tags$style(shiny::HTML("
        /* Simple centered layout */
        body > .container-fluid {
          padding: 15px !important;
          margin: 0 auto !important;
          max-width: 100% !important;
        }
        
        #main-study-container {
          width: 100%;
          max-width: 1200px;
          margin: 0 auto;
          min-height: 600px;
        }
        
        .page-wrapper {
          width: 100%;
          max-width: 1200px;
          margin: 0 auto;
          position: relative;
        }
        
        /* PREVENT CORNER FLASH - Content positioned immediately */
        .page-wrapper {
          width: 100% !important;
          max-width: 1200px !important;
          margin: 0 auto !important;
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          opacity: 1 !important;
          transform: none !important;
          visibility: hidden; /* Hidden until properly positioned */
        }
        
        .page-wrapper.positioned {
          visibility: visible !important;
        }
        
        /* Ensure all child elements are also properly positioned */
        .page-wrapper > *,
        .assessment-card {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin-left: auto !important;
          margin-right: auto !important;
          transform: none !important;
          opacity: 1 !important;
        }
        
        /* Specifically target Shiny output containers */
        #study_ui,
        .shiny-html-output {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin: 0 auto !important;
          transform: none !important;
          width: 100% !important;
        }
        
        /* Prevent any content flash in corners - apply to all possible containers */
        .container-fluid,
        .shiny-output-error,
        .shiny-bound-output {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin: 0 auto !important;
          transform: none !important;
        }
        
        /* Hide all content initially until positioned */
        #study_ui > div:not(.positioned) {
          visibility: hidden !important;
        }
        
        #study_ui > div.positioned {
          visibility: visible !important;
        }
        
        /* Simple fade transition for stage changes */
        .stage-transition {
          opacity: 0.95;
          transition: opacity 0.1s ease-out;
        }
        
        /* Remove problematic animations */
        @keyframes smoothFadeIn {
          from { opacity: 1; }
          to { opacity: 1; }
        }
        
        /* Assessment card - stable and immediate */
        .assessment-card {
          min-height: 400px;
          width: 100%;
          max-width: 800px;
          margin: 0 auto 30px auto;
          padding: 40px;
          border-radius: var(--border-radius);
          box-shadow: 0 4px 20px rgba(0,0,0,0.08);
          border: 1px solid var(--secondary-color);
          background-color: var(--background-color);
          color: var(--text-color);
          /* Remove animation completely */
        }
        
        /* Demographics, instructions, results pages */
        .demographics-page,
        .instructions-page,
        .results-page {
          position: relative !important;
          width: 100% !important;
          margin: 0 auto !important;
        }
        
        /* Container fluid - stable */
        .container-fluid {
          position: relative !important;
          width: 100% !important;
          padding: 0 15px;
        }
        
        /* Force all content to be centered */
        .shiny-html-output {
          width: 100% !important;
          position: relative !important;
          margin: 0 auto !important;
          transform: none !important;
          left: 0 !important;
          right: 0 !important;
        }
        
        /* Fix Shiny's default positioning */
        .shiny-html-output > * {
          position: relative !important;
          margin: 0 auto !important;
        }
        
        /* Prevent any absolute positioning */
        #page_content {
          position: relative !important;
          width: 100% !important;
          left: 0 !important;
          right: 0 !important;
          margin: 0 !important;
          padding: 0 !important;
        }
        
        /* Main study container */
        #main-study-container {
          position: relative !important;
          width: 100% !important;
          overflow-x: hidden !important;
        }
        
        #study_ui {
          position: relative !important;
          width: 100% !important;
        }
        
        #page_content {
          position: relative !important;
          width: 100% !important;
        }
        
        /* Buttons - smooth hover only */
        .btn-klee, .nav-buttons button {
          transition: background-color 0.2s ease, box-shadow 0.2s ease !important;
          transform: none !important;
          position: relative !important;
        }
        
        .btn-klee:active, .nav-buttons button:active {
          transform: none !important;
        }
        
        /* Validation highlighting - no animations */
        .shiny-input-container.has-error input,
        .shiny-input-container.has-error select,
        .shiny-input-container.has-error textarea {
          border: 2px solid #dc3545 !important;
          background-color: #fff5f5 !important;
        }
        
        .shiny-input-container.has-error label {
          color: #dc3545 !important;
          font-weight: bold;
        }
        
        .shiny-input-container.has-error::after {
          content: 'This field is required';
          color: #dc3545;
          font-size: 12px;
          display: block;
          margin-top: 5px;
        }
        
        /* Validation error messages - no animation */
        .validation-error {
          background-color: #f8d7da;
          border: 1px solid #f5c6cb;
          border-radius: 4px;
          color: #721c24;
          padding: 12px;
          margin: 10px 0;
          opacity: 1;
        }
        
        /* Custom loading indicator */
        .loading-overlay {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(255, 255, 255, 0.8);
          z-index: 9999;
          display: none;
          align-items: center;
          justify-content: center;
        }
        
        .loading-overlay.active {
          display: flex;
        }
        
        .loading-spinner {
          width: 40px;
          height: 40px;
          border: 3px solid #f3f3f3;
          border-top: 3px solid #e8041c;
          border-radius: 50%;
          animation: spin 0.8s linear infinite;
        }
        
        @keyframes spin {
          /* Removed rotation to prevent positioning issues */
          0% { opacity: 0.3; }
          50% { opacity: 1; }
          100% { opacity: 0.3; }
        }
        
        /* Show Shiny's natural busy indicator more prominently */
        .shiny-busy {
          position: fixed;
          top: 50%;
          left: 50%;
          margin-left: -50px;
          margin-top: -50px;
          z-index: 1000;
        }
        
        /* Stable content - no animations */
        body {
          opacity: 1;
        }
        
        /* Stable form inputs */
        input, select, textarea {
          transition: none !important;
        }
        
        /* Controlled reset - allow specific animations */
        .no-animation {
          animation: none !important;
          transition: none !important;
          transform: none !important;
        }
        
        /* Ensure stable rendering */
        body {
          overflow-x: hidden;
          overflow-y: auto;
        }
        
        /* Prevent flicker */
        .page-wrapper, .assessment-card {
          backface-visibility: hidden !important;
        }
        
        /* Prevent any zoom or scale */
        html, body {
          zoom: 1 !important;
          -webkit-text-size-adjust: 100% !important;
        }
        

        
        /* Override any theme-specific positioning for cards only */
        .card, .assessment-card {
          position: relative !important;
          left: auto !important;
          right: auto !important;
          margin-left: auto !important;
          margin-right: auto !important;
        }
              ")),
        
        # Responsive design CSS
        shiny::tags$style(shiny::HTML("
          /* Responsive Layout System */
          @media (max-width: 575px) {
            /* Mobile phones */
            .assessment-card {
              padding: 15px !important;
              margin: 10px 0 !important;
            }
            
            .btn-klee, .btn-primary, .btn-secondary {
              width: 100% !important;
              margin: 5px 0 !important;
              padding: 12px 20px !important;
              font-size: 16px !important;
            }
            
            .nav-buttons {
              display: flex !important;
              flex-direction: column !important;
              gap: 10px !important;
            }
            
            h1, .card-header {
              font-size: 1.5rem !important;
            }
            
            h2 {
              font-size: 1.3rem !important;
            }
            
            h3 {
              font-size: 1.1rem !important;
            }
            
            .container-fluid {
              padding: 10px !important;
            }
            
            .shiny-input-container {
              margin-bottom: 15px !important;
            }
            
            /* Stack radio buttons vertically on mobile */
            .shiny-input-radiogroup .radio {
              display: block !important;
              margin: 10px 0 !important;
            }
            
            /* Adjust text size */
            body {
              font-size: 14px !important;
            }
            
            /* Progress indicators */
            .progress {
              height: 30px !important;
            }
            
            .progress-text {
              font-size: 12px !important;
            }
          }
          

          

          
          /* Responsive form elements */
          input[type='text'],
          input[type='number'],
          input[type='email'],
          select,
          textarea {
            width: 100% !important;
            box-sizing: border-box !important;
          }
          
          /* Responsive images and plots */
          img, svg {
            max-width: 100% !important;
            height: auto !important;
          }
          
          /* Responsive tables */
          @media (max-width: 767px) {
            table {
              font-size: 12px !important;
            }
            
            th, td {
              padding: 5px !important;
            }
          }
          
          /* Viewport meta tag support */
          body {
            min-width: 320px !important;
          }
          
          /* Prevent horizontal scroll */
          html, body {
            overflow-x: hidden !important;
          }
          
          #main-study-container {
            overflow-x: hidden !important;
          }
          
          /* Responsive navigation - buttons closer together */
          .nav-buttons {
            display: flex !important;
            flex-wrap: wrap !important;
            gap: 20px !important;
            justify-content: center !important;
            margin-top: 30px !important;
            padding: 0 20px !important;
          }
          
          @media (min-width: 768px) {
            .nav-buttons {
              justify-content: center !important;
              gap: 30px !important;
            }
            
            /* For pages with only one button, center it */
            .nav-buttons:has(button:only-child) {
              justify-content: center !important;
            }
            
            /* For pages with two buttons, bring them closer */
            .nav-buttons:has(button:nth-child(2):last-child) {
              max-width: 400px !important;
              margin-left: auto !important;
              margin-right: auto !important;
            }
          }
          
          /* Responsive progress bars */
          .progress {
            width: 100% !important;
            margin: 10px 0 !important;
          }
          
          /* Touch-friendly buttons */
          @media (hover: none) {
            .btn, button {
              min-height: 44px !important;
              min-width: 44px !important;
            }
          }
        ")),
        
        shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1, maximum-scale=5"),
      # Loaded from Google's servers, so participants' browsers contact Google.
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      # config$custom_css is added in addition to the custom_css argument
      if (!is.null(config$custom_css)) {
        shiny::tags$style(shiny::HTML(config$custom_css))
      },
      # CSS for per-item response layout options
      shiny::tags$style(shiny::HTML("
        /* Horizontal endpoint-labels only: hide middle labels, keep spacing */
        .rl-endpoint-only .shiny-options-group .radio-inline:not(:first-child):not(:last-child) span {
          visibility: hidden;
        }
      "))

    ),
    if (is.character(config$theme) && tolower(config$theme) == "hildesheim") shiny::div(class = "hildesheim-logo"),
    # Session status indicator for session saving
    if (session_save) {
      shiny::uiOutput("session_status_ui")
    },
    if (isTRUE(debug_mode)) {
      shiny::div(
        id = "debug-mode-panel",
        style = "width: 100%; background: #E8E8E8; color: #333; padding: 14px 16px; border-bottom: 3px solid #FFD700; font-family: monospace; font-size: 12px; text-align: center; line-height: 1.5; box-shadow: 0 2px 8px rgba(0,0,0,0.15); z-index: 9998;",
        shiny::HTML('<strong> DEBUG MODE ACTIVE</strong><br><small><strong>Ctrl+A:</strong> Fill Current Page | <strong>Ctrl+Q:</strong> Auto-Fill Normal | <strong>Ctrl+Y:</strong> Auto-Fill Fast</small>')
      )
    },
    shiny::uiOutput("study_ui", style = "position: relative !important; left: 0 !important; right: 0 !important; top: 0 !important; margin: 0 auto !important; transform: none !important; width: 100% !important; max-width: 1200px !important; display: block !important; visibility: visible !important; opacity: 1 !important;")
  )
  
  server <- function(input, output, session) {
    .packages_loaded <- FALSE

    .load_packages_once <- function() {
      if (!.packages_loaded) {
        safe_load_packages(immediate = TRUE)
        .packages_loaded <<- TRUE
      }
    }
    
    # Per-session state ----
    # The flag lives in launch_study()'s environment, so this block runs only
    # for the first session; it also switches on the per-session
    # initialization below for all later sessions.
    if (exists(".force_new_session") && .force_new_session) {
      session$userData$logging_data <- NULL
      session$userData$session_dataset <- NULL
      .needs_session_init <<- TRUE
      .force_new_session <<- FALSE
    }

    current_language <- shiny::reactiveVal(default_language)
    reactive_ui_labels <- shiny::reactiveVal(ui_labels)
    heavy_computations_done <- shiny::reactiveVal(FALSE)
    
    output$study_ui <- shiny::renderUI({
      # Load optional package namespaces after the first render
      if (!.packages_loaded && has_later) {
        later::later(function() {
          .load_packages_once()
          later::run_now(timeoutSecs = 0, all = TRUE)
        }, delay = 0)
      }

      shiny::div(
        id = "main-study-container",
        style = "min-height: 500px; width: 100%; max-width: 100%; margin: 0 auto; padding: 0; position: relative; overflow: hidden;",
        shiny::uiOutput("page_content"),
        # Scroll to the top whenever Shiny updates an output
        shiny::tags$script(shiny::HTML("
          function forceScrollToTop() {
            try {
              window.scrollTo(0, 0);
            } catch(e) {
              try {
                document.documentElement.scrollTop = 0;
                document.body.scrollTop = 0;
              } catch(e2) {
                // Ignore errors
              }
            }
          }
          
          // Execute scroll on page load
          document.addEventListener('DOMContentLoaded', forceScrollToTop);
          
          // Execute scroll when Shiny updates content
          $(document).on('shiny:value', function(event) {
            setTimeout(forceScrollToTop, 10);
          });
          
          // Execute scroll on any content change
          $(document).on('shiny:recalculated', function(event) {
            setTimeout(forceScrollToTop, 10);
          });
        "))
      )
    })
    
    # Per-session initialization, run after the first render
    if (has_later) {
      later::later(function() {
        if (exists(".needs_session_init") && .needs_session_init) {
          timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S_%OS3")
          process_id <- Sys.getpid()
          random_suffix <- paste(sample(c(letters, LETTERS, 0:9), 12, replace = TRUE), collapse = "")
          machine_id <- Sys.info()["nodename"]
          combined_string <- paste(timestamp, process_id, random_suffix, machine_id, sep = "_")
          hash_suffix <- substring(paste0(as.hexmode(sample(256, 4, replace = TRUE) - 1L), collapse = ""), 1, 8)
          unique_session_id <- paste0("SESS_", timestamp, "_", process_id, "_", hash_suffix)
          
          session_config <<- list(
            session_id = unique_session_id,
            start_time = Sys.time(),
            max_time = max_session_time %||% 7200,
            log_file = NULL
          )
          
          # Session-specific key. Stored per session: assigning it to the
          # shared study_key (as before) appended a new suffix for every
          # participant.
          if (!is.null(study_key)) {
            session_specific_key <- paste0(study_key, "_", substr(unique_session_id, nchar(unique_session_id) - 7, nchar(unique_session_id)))
            session$userData$session_study_key <- session_specific_key
            logger(sprintf("Session-specific study key: %s", session_specific_key), level = "INFO")
          }

          session$userData$logging_data <- new.env(parent = emptyenv())
          session$userData$logging_data$session_id <- unique_session_id
          session$userData$logging_data$session_start <- Sys.time()
          session$userData$logging_data$current_page_start <- Sys.time()
          
          logger(sprintf("Session initialized: %s (max time: %d seconds)", 
                        session_config$session_id, session_config$max_time), level = "INFO")
        }
        
        # Note: the assignments to item_bank below create a copy local to
        # this callback, so they do not change the item bank the app uses.
        if (exists(".needs_conversion") && .needs_conversion) {
          logger("Converting GRM item bank for dichotomous model", level = "INFO")
          
          # Add b parameter if missing
          if (!"b" %in% names(item_bank) && "b1" %in% names(item_bank)) {
            item_bank$b <- item_bank$b1
            logger("Using b1 as b parameter", level = "INFO")
          }
          
          # Add dummy options for compatibility
          if (!"Option1" %in% names(item_bank)) {
            item_bank$Option1 <- "Option 1"
            item_bank$Option2 <- "Option 2" 
            item_bank$Option3 <- "Option 3"
            item_bank$Option4 <- "Option 4"
            item_bank$Answer <- "Option 1"
            logger("Added dummy options for dichotomous model compatibility", level = "INFO")
          }
        }
        
        session$userData$heavy_init_complete <- TRUE
        heavy_computations_done(TRUE)
        logger("Session initialization complete", level = "DEBUG")

        later::run_now(timeoutSecs = 0, all = TRUE)
      }, delay = 0)
    }
    
    # Single language observer - handles language switching efficiently
    shiny::observeEvent(input$study_language, {
      if (!is.null(input$study_language)) {
        new_lang <- input$study_language
        
        # Only update if actually different to prevent toggle loops
        if (!is.null(rv$language) && rv$language == new_lang) {
          return()
        }
        
        current_language(new_lang)
        
        # Update UI labels
        new_labels <- get_language_labels(new_lang)
        reactive_ui_labels(new_labels)
        
        # Store in session
        session$userData$language <- new_lang
        
        # Store in rv for access by render functions
        rv$language <- new_lang
        
        # Update config language
        config$language <<- new_lang
        
        # Store in session only
        session$userData$study_language_preference <- new_lang
        
        # Log the change
        cat("Language switched to:", new_lang, "\n")
        
        # DO NOT force UI refresh - let JavaScript handle the switching
        # This prevents the page_content rendering loop
      }
    })
    
    # Observe store_language_globally for any study that needs it
    # Guard against rapid repeats and initial firing to avoid render loops
    shiny::observeEvent(input$store_language_globally, {
      # ignore NULLs and empty values early
      if (is.null(input$store_language_globally) || input$store_language_globally == "") return()

      # Simple de-duplication: skip if identical to last value within short window
      last_val <- session$userData$last_store_language %||% NULL
      last_time <- session$userData$last_store_language_time %||% as.POSIXct(0)
      now_time <- Sys.time()
      # If same value and last seen less than 1 second ago, ignore to break event storms
      if (!is.null(last_val) && identical(last_val, input$store_language_globally) && difftime(now_time, last_time, units = "secs") < 1) {
        # Silently ignore near-duplicate events
        return()
      }

      # Record last seen value/time
      session$userData$last_store_language <- input$store_language_globally
      session$userData$last_store_language_time <- now_time

      # Store in session only
      session$userData$study_language_preference <- input$store_language_globally
      cat("Stored language globally:", input$store_language_globally, "\n")

      # Update language for FUTURE pages only (not current page to prevent loops)
      new_lang <- input$store_language_globally
      if (new_lang %in% c("en", "de")) {
        # Only update if we're NOT on page 1 to prevent re-rendering loops
        current_page <- rv$current_page %||% 1
        if (current_page != 1) {
          current_language(new_lang)
          rv$language <- new_lang
          session$userData$language <- new_lang
          cat("Language switched to:", new_lang, "\n")
        } else {
          # For page 1, just store for future use without triggering re-render
          session$userData$language <- new_lang
          cat("Language preference stored for future pages:", new_lang, "\n")
        }
      }
    }, ignoreInit = TRUE)
    
    # "Download PDF Report": the report's HTML and CSS are sent to the server
    # (input$pdf_html_content), but no PDF is generated from them; the
    # observer below only opens the browser's print dialog.
    shiny::observeEvent(input$download_pdf_trigger, {
      if (isTRUE(getOption("inrep.debug", FALSE))) cat("PDF download triggered\n")
      
      shiny::showNotification("Capturing report for PDF...", type = "message", duration = 3)

      tryCatch({
        if (requireNamespace("shinyjs", quietly = TRUE)) {
          shinyjs::runjs("
            var reportContent = document.getElementById('report-content');
            if (!reportContent) {
              // Fallback: try to find main content area
              reportContent = document.querySelector('.assessment-card') || document.querySelector('.page-content');
            }
            
            if (reportContent) {
              var htmlContent = reportContent.outerHTML;
              var styles = Array.from(document.styleSheets)
                .map(sheet => {
                  try {
                    return Array.from(sheet.cssRules).map(rule => rule.cssText).join('\\n');
                  } catch(e) {
                    return '';
                  }
                }).join('\\n');
              
              // Send to Shiny server
              Shiny.setInputValue('pdf_html_content', {
                html: htmlContent,
                styles: styles,
                timestamp: Date.now()
              }, {priority: 'event'});
            } else {
              alert('Could not find report content for PDF generation');
            }
          ")
        } else {
          cat("shinyjs not available for PDF generation\n")
          shiny::showNotification("PDF generation requires shinyjs package", type = "error")
        }
        
      }, error = function(e) {
        cat("Error initiating PDF capture:", e$message, "\n")
        shiny::showNotification(paste("Error:", e$message), type = "error")
      })
    })
    
    # Open the browser's print dialog, from which the participant can save a PDF
    shiny::observeEvent(input$pdf_html_content, {
      if (isTRUE(getOption("inrep.debug", FALSE))) cat("PDF download: Using browser print dialog\n")

      tryCatch({
        if (requireNamespace("shinyjs", quietly = TRUE)) {
          shinyjs::runjs("window.print();")
          shiny::showNotification("Use your browser's print dialog to save as PDF (Ctrl+P or Cmd+P)", type = "message", duration = 5)
        } else {
          shiny::showNotification("PDF generation not available. Please print manually.", type = "error")
        }
        
      }, error = function(e) {
        cat("Error generating PDF:", e$message, "\n")
        shiny::showNotification(paste("Error generating PDF:", e$message), type = "error", duration = 5)
      })
    })
    
    # CSV export of the participant's data, triggered from page JavaScript
    shiny::observeEvent(input$download_csv_trigger, {
      if (isTRUE(getOption("inrep.debug", FALSE))) cat("CSV download triggered\n")
      
      shiny::showNotification("Generating CSV export...", type = "message", duration = 2)
      
      tryCatch({
        csv_data <- data.frame(
          timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
          session_id = rv$unique_session_id %||% paste0("session_", format(Sys.time(), "%Y%m%d_%H%M%S")),
          study_name = config$name %||% "study",
          study_language = rv$language %||% "en"
        )
        
        # Add demographics (with last-chance input fallback)
        if (!is.null(rv$demo_data)) {
          # Last-chance: fill any still-empty demo fields from Shiny input
          if (!is.null(config$demographics)) {
            for (dem_name in config$demographics) {
              v <- rv$demo_data[[dem_name]]
              if (is.null(v) || (length(v) == 1 && (is.na(v) || trimws(as.character(v)) == ""))) {
                fallback <- tryCatch(input[[paste0("demo_", dem_name)]], error = function(e) NULL)
                if (!is.null(fallback) && nchar(trimws(as.character(fallback))) > 0) {
                  rv$demo_data[[dem_name]] <- trimws(as.character(fallback))
                  cat("CSV FALLBACK: Recovered demo field", dem_name, "from input\n")
                }
              }
            }
          }
          for (name in names(rv$demo_data)) {
            csv_data[[name]] <- rv$demo_data[[name]]
          }
        }
        
        # Add responses using item bank column names if available
        if (!is.null(rv$responses)) {
          # Try to get proper item names from item bank
          if (!is.null(item_bank) && nrow(item_bank) > 0) {
            # Check for common ID columns in item banks
            id_column <- NULL
            if ("id" %in% names(item_bank)) id_column <- "id"
            else if ("ID" %in% names(item_bank)) id_column <- "ID"
            else if ("item_id" %in% names(item_bank)) id_column <- "item_id"
            else if ("Item" %in% names(item_bank)) id_column <- "Item"
            
            if (!is.null(id_column)) {
              # Use item bank IDs
              for (i in seq_along(rv$responses)) {
                if (i <= nrow(item_bank)) {
                  col_name <- item_bank[[id_column]][i]
                  csv_data[[col_name]] <- rv$responses[i]
                } else {
                  csv_data[[paste0("item_", i)]] <- rv$responses[i]
                }
              }
            } else {
              # No ID column found, use generic names
              for (i in seq_along(rv$responses)) {
                csv_data[[paste0("item_", i)]] <- rv$responses[i]
              }
            }
          } else {
            # No item bank, use generic names
            for (i in seq_along(rv$responses)) {
              csv_data[[paste0("item_", i)]] <- rv$responses[i]
            }
          }
        }
        
        # Add ability estimates if available (for adaptive tests)
        if (!is.null(rv$current_ability)) {
          csv_data$theta <- rv$current_ability
        }
        if (!is.null(rv$current_se)) {
          csv_data$se <- rv$current_se
        }
        
        # Call study-specific CSV processor if defined
        # This allows each study to add custom calculated columns
        if (!is.null(config$csv_processor) && is.function(config$csv_processor)) {
          tryCatch({
            csv_data <- config$csv_processor(csv_data, rv$responses, rv$demo_data, item_bank)
            cat("Applied custom CSV processor\n")
          }, error = function(e) {
            cat("Warning: Custom CSV processor failed:", e$message, "\n")
          })
        }
        
        # Convert to CSV string
        temp_csv <- tempfile(fileext = ".csv")
        write.csv(csv_data, temp_csv, row.names = FALSE, na = "")
        csv_content <- readLines(temp_csv, warn = FALSE)
        unlink(temp_csv)
        
        # Trigger download via JavaScript
        if (requireNamespace("shinyjs", quietly = TRUE)) {
          timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
          study_name <- gsub("[^a-zA-Z0-9_]", "_", config$name %||% "study")
          filename <- paste0(study_name, "_results_", timestamp, ".csv")
          
          shinyjs::runjs(sprintf("
            var csv = %s;
            var blob = new Blob([csv], {type: 'text/csv;charset=utf-8;'});
            var url = window.URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = '%s';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            window.URL.revokeObjectURL(url);
          ", jsonlite::toJSON(paste(csv_content, collapse = "\n")), filename))
          
          shiny::showNotification("CSV downloaded successfully!", type = "message", duration = 3)
        } else {
          cat("shinyjs not available for CSV download\n")
          shiny::showNotification("CSV download not available", type = "error")
        }
        
      }, error = function(e) {
        cat("Error generating CSV:", e$message, "\n")
        shiny::showNotification(paste("Error generating CSV:", e$message), type = "error", duration = 5)
      })
    })
    
  generate_study_key <- function() {
    generate_uuid()
  }

  rv <- shiny::reactiveValues()

  # WebDAV settings are kept in rv so that the results pages
  # (render_results_page) can upload, also when the participant chooses not
  # to see the results.
  rv$webdav_url <- webdav_url
  rv$webdav_password <- password
  rv$webdav_share_token <- webdav_share_token
  rv$webdav_user <- webdav_user

  tryCatch({
    if (exists("register_session_objects") && is.function(register_session_objects)) {
      register_session_objects(
        rv = rv,
        config = config,
        item_bank = item_bank
      )
    }
  }, error = function(e) {})
  
  unique_session_id <- paste0("USER_", format(Sys.time(), "%Y%m%d_%H%M%S_%OS3"), "_",
                              paste0(sample(c(letters, LETTERS, 0:9), 12, replace = TRUE), collapse = ""))

  rv$session_isolation_enforced <- TRUE
  rv$session_start_time <- Sys.time()
  rv$unique_session_id <- unique_session_id

  # Maximum session time ----
  # Checked once a minute; the session is closed after max_session_time
  # seconds. (This was hard-coded to 7200 s and ignored max_session_time.)
  rv$max_session_duration <- max_session_time %||% 7200

  shiny::observe({
    shiny::invalidateLater(60000, session)

    session_duration <- as.numeric(difftime(Sys.time(), rv$session_start_time, units = "secs"))

    if (session_duration > rv$max_session_duration) {
      logger(sprintf("Maximum session time reached (%.0f seconds) - ending session", session_duration), level = "INFO")

      .inrep_end_session(session)
    }
  })

  # Skipped pages ----
  # If the current page is listed in rv$skipped_pages (for example an
  # adaptive page whose prerequisite items were not answered), move forward
  # to the next page that is not skipped.
  shiny::observe({
    req(rv$current_page)
    
    # Check if current page is in skip list
    if (!is.null(rv$skipped_pages) && length(rv$skipped_pages) > 0) {
      if (rv$current_page %in% rv$skipped_pages) {
        # Current page should be skipped - auto-advance
        logger(sprintf("AUTO-SKIP: Page %d is marked as skipped, auto-advancing", rv$current_page))
        
        new_page <- rv$current_page + 1
        # Keep skipping until we find a non-skipped page
        while (new_page %in% rv$skipped_pages && new_page <= rv$total_pages) {
          new_page <- new_page + 1
        }
        
        if (new_page <= rv$total_pages) {
          rv$current_page <- new_page
          logger(sprintf("AUTO-SKIP: Jumped to page %d", new_page))
        }
      }
    }
  })
  
  logger(sprintf("New participant session: %s", unique_session_id), level = "INFO")

  # Local session file ----
  # All sessions of a study share study_data/<study_key>/session.rds (a new
  # key is generated per session only when no study_key is given). Any
  # existing file is deleted when a new session starts.
  effective_study_key <- study_key %||% config$study_key %||% generate_study_key()
  data_dir <- base::file.path("study_data", effective_study_key)
  if (!base::dir.exists(data_dir)) base::dir.create(data_dir, recursive = TRUE)
  session_file <- base::file.path(data_dir, "session.rds")
  
  if (base::file.exists(session_file)) {
    file_time <- file.mtime(session_file)
    time_diff <- as.numeric(difftime(Sys.time(), file_time, units = "mins"))

    if (time_diff < 5) {
      logger(sprintf("Session file is %.1f minutes old and is removed; another participant may still be writing to it", time_diff), level = "WARNING")

      tryCatch({
        file.remove(session_file)
        logger("Removed existing session file", level = "WARNING")
      }, error = function(e) {
        logger(sprintf("Failed to remove existing session file: %s", e$message), level = "ERROR")
      })
    } else {
      tryCatch({
        file.remove(session_file)
        logger("Removed old session file", level = "INFO")
      }, error = function(e) {
        logger(sprintf("Failed to remove old session file: %s", e$message), level = "WARNING")
      })
    }
  }
  
  # Initial participant state
  rv$demo_data <- base::as.list(stats::setNames(base::rep(NA, base::length(config$demographics)), config$demographics))
  rv$config <- config  # Store config in rv for access by validation functions
  rv$language <- config$language %||% "de"  # Initialize language in rv
  
      # Initialize session dataset system (if functions are available)
    if (exists("initialize_session_dataset", mode = "function")) {
      tryCatch({
        session_dataset <- initialize_session_dataset(config, item_bank, effective_study_key, session = session)
        rv$session_dataset <- session_dataset
        logger("Session dataset initialized", level = "INFO")
        
        # Initialize page start time for logging
        if (config$log_data %||% FALSE && exists("update_page_start_time", mode = "function")) {
          tryCatch({
            update_page_start_time("page_1", session = session)
          }, error = function(e) {
            logger(sprintf("Failed to initialize page start time: %s", e$message), level = "WARNING")
          })
        }
      }, error = function(e) {
        logger(sprintf("Failed to initialize session dataset: %s", e$message), level = "WARNING")
      })
    } else {
      logger("Session dataset functions not available - using basic data storage", level = "INFO")
    }
  rv$stage <- if (!is.null(config$custom_page_flow)) {
    "custom_page_flow"
  } else if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
    config$custom_study_flow$start_with %||% "demographics"
  } else if (config$show_introduction) {
    "instructions"
  } else {
    # Skip demographics if not provided
    if (!is.null(config$demographics) && length(config$demographics) > 0) {
      "demographics"
    } else {
      "items"
    }
  }
  rv$current_page <- 1
  rv$total_pages <- if (!is.null(config$custom_page_flow)) length(config$custom_page_flow) else 1
  rv$item_page <- 1
  rv$item_responses <- list()
  rv$current_ability <- config$theta_prior[1]
  rv$current_se <- config$theta_prior[2]
  rv$administered <- base::c()
  rv$responses <- if (!is.null(config$custom_page_flow)) {
    rep(NA_real_, nrow(item_bank))  # Pre-allocate responses vector
  } else {
    base::c()
  }
  rv$response_times <- base::c()
  rv$start_time <- NULL
  rv$session_start <- base::Sys.time()
  rv$current_item <- NULL
  rv$theta_history <- as.numeric(base::c())
  rv$se_history <- as.numeric(base::c())
  rv$cat_result <- NULL
  rv$item_counter <- 0
  rv$error_message <- NULL
  rv$feedback_message <- NULL
  rv$item_info_cache <- base::list()
  rv$session_active <- TRUE
  rv$submission_in_progress <- FALSE
  rv$submission_lock_time <- NULL
  rv$last_submission_time <- NULL
  rv$initialized <- TRUE

  # Session restoration. Note: an existing session_file was deleted above,
  # so in practice nothing is restored here.
  if (config$session_save && base::file.exists(session_file)) {
    base::tryCatch({
      saved_state <- base::readRDS(session_file)
      for (name in base::names(saved_state)) rv[[name]] <- saved_state[[name]]
      logger(base::sprintf("Restored session from %s", session_file))
    }, error = function(e) {
      logger(base::sprintf("Failed to restore session: %s", e$message))
    })
  }

  # Storage for all session persistence paths. Local saving requires
  # session_save (argument and config); the WebDAV upload at the end of the
  # built-in assessment only requires webdav_url.
  run_storage_pipeline <- function(trigger = "event", force = FALSE, include_cloud = FALSE) {
    save_local <- isTRUE(session_save) && isTRUE(config$session_save)
    save_cloud <- isTRUE(include_cloud) && !base::is.null(webdav_url)
    if (!save_local && !save_cloud) {
      return(invisible(FALSE))
    }

    preserved <- FALSE

    if (save_local) {
      if (exists("preserve_session_data") && is.function(preserve_session_data)) {
        preserved <- isTRUE(tryCatch({
          preserve_session_data(force = force)
        }, error = function(e) {
          logger(sprintf("Storage pipeline preserve failed [%s]: %s", trigger, e$message), level = "ERROR")
          FALSE
        }))
      }

      tryCatch({
        base::saveRDS(shiny::reactiveValuesToList(rv), session_file)
      }, error = function(e) {
        logger(sprintf("Storage pipeline local save failed [%s]: %s", trigger, e$message), level = "WARNING")
      })
    }

    if (save_cloud) {
      tryCatch({
        save_session_to_cloud(rv, config, webdav_url, password, session = session,
                              share_token = webdav_share_token, user = webdav_user)
      }, error = function(e) {
        logger(sprintf("Storage pipeline cloud save failed [%s]: %s", trigger, e$message), level = "WARNING")
      })
    }

    invisible(preserved)
  }
  
  logger("Participant state initialized", level = "DEBUG")

    if (session_save) {
      # Timeout check with data preservation. This observer has no timer:
      # it re-runs only when rv$session_start changes (start, restart). The
      # per-minute check above is what enforces max_session_time.
      shiny::observe({
          if (base::difftime(base::Sys.time(), rv$session_start, units = "secs") > max_session_time) {
            rv$session_active <- FALSE
            rv$stage = "timeout"
            logger("Session timed out due to maximum session time", level = "WARNING")
            
            run_storage_pipeline(trigger = "session_timeout", force = TRUE, include_cloud = FALSE)

            tryCatch({
              if (requireNamespace("shinyjs", quietly = TRUE)) {
                # window.close() silently no-ops (no exception) on a tab opened
                # via normal navigation, so detect failure via window.closed
                # rather than relying on a catch that never triggers.
                shinyjs::runjs("
                  (function() {
                    try { window.close(); } catch(e) {}
                    setTimeout(function() {
                      if (window.closed) return;
                      try {
                        window.location.href = 'about:blank';
                      } catch(e2) {}
                    }, 300);
                  })();
                ")
              }
            }, error = function(e) {
              logger(sprintf("Browser close failed: %s", e$message), level = "WARNING")
            })
            
            logger("Ending participant session due to timeout", level = "INFO")
            tryCatch({
              later::later(function() .inrep_end_session(session), delay = 2)
            }, error = function(e) {
              logger(sprintf("App stop failed: %s", e$message), level = "ERROR")
            })
          }
        
        if (exists("update_activity") && is.function(update_activity)) {
          tryCatch({
            update_activity()
          }, error = function(e) {
            logger(sprintf("Activity update failed: %s", e$message), level = "WARNING")
          })
        }
      })

      # Save on page changes and responses (a timer-based save made the page
      # jump to the top)
      observe_data_preservation <- function() {
        if (rv$session_active) {
          run_storage_pipeline(trigger = "event_monitor", force = FALSE, include_cloud = FALSE)
        }
      }
      
      shiny::observeEvent(rv$current_page, {
        observe_data_preservation()
      }, ignoreInit = TRUE)

      shiny::observeEvent(rv$responses, {
        observe_data_preservation()
      }, ignoreInit = TRUE)
    }

    # Keep-alive monitoring is started once in initialize_robust_session().

    # Session status indicator, shown only with config$show_session_time = TRUE
    if (session_save && isTRUE(config$show_session_time)) {
      output$session_status_ui <- shiny::renderUI({
        if (exists("get_session_status") && is.function(get_session_status)) {
          tryCatch({
            session_status <- get_session_status()
            if (session_status$active) {
              remaining_minutes <- round(session_status$remaining_time / 60, 1)
              shiny::div(
                class = "session-status-indicator",
                style = "position: fixed; top: 10px; right: 10px; z-index: 1000; background: rgba(0,0,0,0.8); color: white; padding: 8px 12px; border-radius: 6px; font-size: 12px; opacity: 0; animation: fadeInIndicator 0.5s ease-out 0.5s forwards;",
                shiny::div("Session Active", style = "font-weight: bold;"),
                shiny::div(sprintf("Time remaining: %s min", remaining_minutes))
              )
            } else {
              shiny::div(
                class = "session-status-indicator",
                style = "position: fixed; top: 10px; right: 10px; z-index: 1000; background: rgba(255,0,0,0.8); color: white; padding: 8px 12px; border-radius: 6px; font-size: 12px; opacity: 0; animation: fadeInIndicator 0.5s ease-out 0.5s forwards;",
                shiny::div("Session Expired", style = "font-weight: bold;"),
                shiny::div("Please refresh or restart")
              )
            }
          }, error = function(e) {
            # Fallback to basic status
            shiny::div(
              class = "session-status-indicator",
              style = "position: fixed; top: 10px; right: 10px; z-index: 1000; background: rgba(0,0,0,0.8); color: white; padding: 8px 12px; border-radius: 6px; font-size: 12px; opacity: 0; animation: fadeInIndicator 0.5s ease-out 0.5s forwards;",
              shiny::div("Session Active", style = "font-weight: bold;"),
              shiny::div("Session saving enabled")
            )
          })
        } else {
          # Without get_session_status()
          shiny::div(
            class = "session-status-indicator",
            style = "position: fixed; top: 10px; right: 10px; z-index: 1000; background: rgba(0,0,0,0.8); color: white; padding: 8px 12px; border-radius: 6px; font-size: 12px; opacity: 0; animation: fadeInIndicator 0.5s ease-out 0.5s forwards;",
            shiny::div("Session Active", style = "font-weight: bold;"),
            shiny::div("Session saving enabled")
          )
        }
      })
    } else {
      # Hide session status UI by default
      output$session_status_ui <- shiny::renderUI({
        NULL
      })
    }
    
    # Save local data when the participant's session ends (session_save only)
    session$onSessionEnded(function() {
      if (session_save) {
        logger("Session ending - saving final data", level = "INFO")
        run_storage_pipeline(trigger = "session_end", force = TRUE, include_cloud = FALSE)

        if (exists("cleanup_session") && is.function(cleanup_session)) {
          tryCatch({
            cleanup_session(save_final_data = TRUE)
          }, error = function(e) {
            logger(sprintf("Session cleanup failed: %s", e$message), level = "WARNING")
          })
        }
      }

      # Single-user local runs (options(inrep.stop_app_on_finish = TRUE)) should
      # stop the whole app process when the participant's window/tab closes,
      # not just end their Shiny session.
      if (isTRUE(getOption("inrep.stop_app_on_finish", FALSE))) {
        try(shiny::stopApp(), silent = TRUE)
      }
    })
    
    # Record activity after each flush to the browser
    session$onFlush(function() {
      if (session_save && exists("update_activity") && is.function(update_activity)) {
        tryCatch({
          update_activity()
        }, error = function(e) {
          logger(sprintf("Activity update failed: %s", e$message), level = "WARNING")
        })
      }
    })

    get_item_content <- function(item_idx) {
      lang <- current_language()

      # Bilingual item banks: English wording in a Question_EN column
      if ("Question_EN" %in% names(item_bank) && lang == "en") {
        item <- item_bank[item_idx, ]
        item$Question <- item$Question_EN
        return(item)
      }
      
      if (base::is.null(config$item_translations) || base::is.null(config$item_translations[[lang]])) {
        # Ensure minimal fields exist
        if (!"Question" %in% base::names(item_bank) && "content" %in% base::names(item_bank)) item_bank$Question <- item_bank$content
        return(item_bank[item_idx, ])
      }
      translations <- config$item_translations[[lang]][item_idx, ]
      item <- item_bank[item_idx, ]
      item$Question <- translations$Question %||% item$Question
      if (config$model != "GRM") {
        for (i in 1:4) item[[base::paste0("Option", i)]] <- translations[[base::paste0("Option", i)]] %||% item[[base::paste0("Option", i)]]
        item$Answer <- translations$Answer %||% item$Answer
      }
      item
    }
    
    check_stopping_criteria <- function() {
      if (!config$adaptive) {
        group_items <- if (!base::is.null(config$fixed_items)) config$fixed_items else base::unlist(config$item_groups)
        if (base::is.null(group_items)) group_items <- base::seq_len(base::nrow(item_bank))
        return(base::length(rv$administered) >= config$max_items || base::length(rv$administered) >= base::length(group_items))
      }
      if (!base::is.null(config$stopping_rule)) {
        base::tryCatch({
          return(config$stopping_rule(rv$current_ability, rv$current_se, base::length(rv$administered), rv))
        }, error = function(e) {
          logger(base::sprintf("Custom stopping rule failed: %s. Using default rules.", e$message))
        })
      }
      base::length(rv$administered) >= config$min_items &&
        (base::length(rv$administered) >= config$max_items || rv$current_se <= config$min_SEM)
    }
    
      # Content of the current stage or page
      output$page_content <- shiny::renderUI({
        current_page <- rv$current_page
        stage <- rv$stage
        
        logger(sprintf("page_content rendering: stage=%s, page=%s, session_active=%s, initialized=%s", 
               stage %||% "NULL", current_page %||% "NULL", rv$session_active %||% "NULL", rv$initialized %||% "NULL"), level = "DEBUG")

        if (!isTRUE(rv$session_active)) {
          logger("Session not active - showing timeout message", level = "DEBUG")
          return(
            shiny::div(class = "assessment-card",
                       shiny::h3(ui_labels$timeout_message, class = "card-header"),
                       shiny::div(class = "nav-buttons",
                                  shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee",
                                                     onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);")
                       )
            )
          )
        }
        
          # The container id stays the same across pages; the positioning
          # scripts in the page head rely on it.
          shiny::div(
            id = "stable-page-container",
            class = "page-wrapper",
            style = "width: 100% !important; max-width: 1200px !important; margin: 0 auto !important; position: relative !important; left: 0 !important; right: 0 !important; top: 0 !important; transform: none !important; display: block !important;",
          base::switch(stage,
                   "custom_page_flow" = {
                     # Process and render custom page flow
                     process_page_flow(config, rv, input, output, session, item_bank, ui_labels, logger, auto_close_time, auto_close_time_unit, disable_auto_close)
                   },
                   "error" = {
                     shiny::div(class = "assessment-card error-card",
                                shiny::h3(ui_labels$system_error, class = "card-header error-header"),
                                shiny::div(class = "error-message",
                                                                                        shiny::p(rv$error_message %||% ui_labels$error_message),
                                                                                        shiny::p(ui_labels$error_save_progress),
                                             shiny::p(ui_labels$error_contact_support)
                                ),
                                shiny::div(class = "nav-buttons",
                                                                                        shiny::actionButton("retry_continue", ui_labels$error_continue_button, class = "btn-klee",
                                                                                                           onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);"),
                                                                                        shiny::actionButton("restart_test", ui_labels$error_restart_button, class = "btn-klee")
                                )
                     )
                   },
                   "demographics" = {
                                         demo_inputs <- base::lapply(base::seq_along(config$demographics), function(i) {
                      dem <- config$demographics[i]
                      input_type <- config$input_types[[dem]]
                      input_id <- base::paste0("demo_", i)
                      
                      # Get demographic configuration if available
                      demo_config <- NULL
                      if (!base::is.null(config$demographic_configs) && 
                          !base::is.null(config$demographic_configs[[dem]])) {
                        demo_config <- config$demographic_configs[[dem]]
                      }
                      
                      # A demographic entry with html_content is shown as raw HTML
                      if (!base::is.null(demo_config) && !base::is.null(demo_config$html_content)) {
                        if (isTRUE(getOption("inrep.debug", FALSE))) cat("DEBUG: Found HTML content in demographics stage for", dem, "\n")
                        if (isTRUE(getOption("inrep.debug", FALSE))) cat("DEBUG: HTML content length:", nchar(demo_config$html_content), "\n")

                        return(shiny::div(
                          class = "demographic-field custom-html-content",
                          shiny::HTML(demo_config$html_content)
                        ))
                      }
                      
                      # Label text: question_en (English), question, label, or the field name
                      current_lang <- rv$language %||% config$language %||% "de"
                      label_text <- if (current_lang == "en" && !base::is.null(demo_config$question_en)) {
                        demo_config$question_en
                      } else if (!base::is.null(demo_config$question)) {
                        demo_config$question
                      } else if (!base::is.null(demo_config$label)) {
                        demo_config$label
                      } else {
                        dem
                      }
                      
                      # Create appropriate input based on type
                      input_element <- base::switch(input_type,
                        "numeric" = shiny::numericInput(
                          inputId = input_id,
                          label = NULL,
                          value = rv$demo_data[i] %||% NA,
                          min = if (!base::is.null(demo_config$min)) demo_config$min else 1,
                          max = if (!base::is.null(demo_config$max)) demo_config$max else 150,
                          width = "100%"
                        ),
                        "select" = shiny::selectInput(
                          inputId = input_id,
                          label = NULL,
                          choices = if (!base::is.null(demo_config$options)) {
                            setNames(c("", demo_config$options), c(ui_labels$please_select, names(demo_config$options) %||% demo_config$options))
                          } else {
                            setNames(c("", ui_labels$gender_male, ui_labels$gender_female, ui_labels$gender_other, ui_labels$gender_prefer_not), c(ui_labels$select_option, ui_labels$gender_male, ui_labels$gender_female, ui_labels$gender_other, ui_labels$gender_prefer_not))
                          },
                          selected = rv$demo_data[i] %||% "",
                          width = "100%"
                        ),
                        "radio" = shiny::radioButtons(
                          inputId = input_id,
                          label = NULL,
                          choices = if (!base::is.null(demo_config$options)) {
                            demo_config$options
                          } else {
                            base::c("Yes" = "yes", "No" = "no")
                          },
                          selected = rv$demo_data[i] %||% base::character(0),
                          width = "100%"
                        ),
                        "checkbox" = shiny::checkboxGroupInput(
                          inputId = input_id,
                          label = NULL,
                          choices = if (!base::is.null(demo_config$options)) {
                            demo_config$options
                          } else {
                            base::c("Option 1" = "opt1", "Option 2" = "opt2")
                          },
                          selected = rv$demo_data[i] %||% base::character(0),
                          width = "100%"
                        ),
                                                "slider" = {
                          min_val <- if (!base::is.null(demo_config$min)) demo_config$min else 0
                          max_val <- if (!base::is.null(demo_config$max)) demo_config$max else 100
                          step_val <- if (!base::is.null(demo_config$step)) demo_config$step else 1
                          current_val <- rv$demo_data[[dem]]
                          if (base::is.null(current_val) || base::is.na(current_val)) {
                            current_val <- if (!base::is.null(demo_config$default)) demo_config$default else base::round((min_val + max_val) / 2)
                          }
                          current_val <- base::as.numeric(current_val)
                          if (base::is.na(current_val)) {
                            current_val <- if (!base::is.null(demo_config$default)) demo_config$default else base::round((min_val + max_val) / 2)
                          }
                          current_val <- base::max(base::min(current_val, max_val), min_val)
                          
                          shiny::sliderInput(
                            inputId = input_id,
                            label = NULL,
                            min = min_val,
                            max = max_val,
                            value = current_val,
                            step = step_val,
                            width = "100%"
                          )
                        },
                        # Default to text input
                        shiny::textInput(
                          inputId = input_id,
                          label = NULL,
                          value = rv$demo_data[i] %||% "",
                          placeholder = if (!base::is.null(demo_config$placeholder)) demo_config$placeholder else "",
                          width = "100%"
                        )
                      )
                      
                      # Return the complete form group
                      shiny::div(
                        class = "form-group",
                        # Check if label_text contains HTML tags, if so render as HTML
                        if (grepl("<[^>]+>", label_text)) {
                          shiny::div(class = "input-label", shiny::HTML(label_text))
                        } else {
                          shiny::tags$label(label_text, class = "input-label")
                        },
                        input_element,
                        if (!base::is.null(demo_config$help_text)) {
                          shiny::tags$small(class = "form-text text-muted", demo_config$help_text)
                        }
                      )
                    })
                     
                     shiny::tagList(
                       shiny::div(class = "assessment-card",
                                  shiny::h3(ui_labels$demo_title, class = "card-header"),
                                  shiny::p(ui_labels$welcome_text, class = "welcome-text"),
                                  demo_inputs,
                                  if (!base::is.null(rv$error_message)) shiny::div(class = "error-message", rv$error_message),
                                  shiny::div(class = "nav-buttons",
                                             shiny::actionButton("start_test", ui_labels$start_button, class = "btn-klee",
                                                                onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);")
                                  )
                       )
                     )
                   },
                   "instructions" = {
                     # Use custom instructions if provided, otherwise use default labels
                     instructions_content <- if (!base::is.null(config$instructions)) {
                       shiny::tagList(
                         if (!base::is.null(config$instructions$welcome)) {
                           shiny::h3(config$instructions$welcome, class = "card-header")
                         } else {
                           shiny::h3(ui_labels$instructions_title, class = "card-header")
                         },
                         if (!base::is.null(config$instructions$purpose)) {
                           shiny::HTML(paste0("<div class='welcome-text'>", config$instructions$purpose, "</div>"))
                         } else {
                           shiny::p(ui_labels$instructions_text, class = "welcome-text")
                         },
                         if (!base::is.null(config$instructions$duration)) {
                           shiny::p(config$instructions$duration, class = "welcome-text")
                         },
                         if (!base::is.null(config$instructions$structure)) {
                           shiny::HTML(paste0("<div class='welcome-text'>", config$instructions$structure, "</div>"))
                         }
                       )
                     } else {
                       shiny::tagList(
                         shiny::h3(ui_labels$instructions_title, class = "card-header"),
                         shiny::p(ui_labels$instructions_text, class = "welcome-text"),
                         # Only true for an adaptive study
                         if (isTRUE(config$adaptive)) shiny::p("The assessment will adapt based on your responses.", class = "welcome-text")
                       )
                     }
                     
                    shiny::div(class = "assessment-card",
                               instructions_content,
                               shiny::div(class = "nav-buttons",
                                          shiny::actionButton("begin_test", ui_labels$begin_button, class = "btn-klee",
                                                             onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);")
                               )
                    )
                   },
                   "assessment" = {
                     # Debug: Log item display state
                     logger(sprintf("Rendering assessment UI - stage: %s, current_item: %s", rv$stage, rv$current_item))
                     
                     if (base::is.null(rv$current_item)) {
                       logger("current_item is NULL in assessment stage; showing placeholder", level = "ERROR")
                                                return(shiny::div(class = "assessment-card",
                                           shiny::h3(ui_labels$preparing, class = "card-header"),
                                         shiny::p(ui_labels$loading_question)))
                     }
                     
                     logger(sprintf("Getting content for item %d", rv$current_item))
                     item <- get_item_content(rv$current_item)
                     logger(sprintf("Item content retrieved - Question: %s", substr(item$Question, 1, 50)))
                     
                     # Determine effective layout: per-item column overrides global config
                     item_layout <- tryCatch({
                       rl <- item$response_layout
                       if (!is.null(rl) && length(rl) > 0 && !is.na(rl) && base::nzchar(as.character(rl))) as.character(rl)
                       else config$response_layout %||% "vertical"
                     }, error = function(e) config$response_layout %||% "vertical")
                     is_inline <- item_layout %in% c("horizontal", "horizontal_all", "horizontal_endpoints")
                     is_endpoint_only <- item_layout == "horizontal_endpoints"
                     
                     response_ui <- if (config$model == "GRM") {
                       choices <- base::as.numeric(base::unlist(base::strsplit(item$ResponseCategories, ",")))
                       
                       # Ensure we have valid choices
                       if (length(choices) == 0 || all(is.na(choices))) {
                         choices <- 1:5
                       }
                       
                       labels <- get_response_labels(
                         scale_type = "likert",
                         choices = choices,
                         language = current_language()
                       )
                       base::switch(config$response_ui_type,
                                    "slider" = shiny::div(class = "slider-container",
                                                          shiny::sliderInput(
                                                            inputId = "item_response",
                                                            label = NULL,
                                                            min = base::min(choices),
                                                            max = base::max(choices),
                                                            value = base::min(choices),
                                                            step = 1,
                                                            ticks = TRUE,
                                                            width = "100%"
                                                          )),
                                    "dropdown" = shiny::selectInput(
                                      inputId = "item_response",
                                      label = NULL,
                                      choices = stats::setNames(choices, labels),
                                      selected = NULL,
                                      width = "100%"
                                    ),
                                    if (available_packages$shinyWidgets) {
                                      shinyWidgets::radioGroupButtons(
                                        inputId = "item_response",
                                        label = NULL,
                                        choices = stats::setNames(choices, labels),
                                        selected = base::character(0),
                                        direction = if (is_inline) "horizontal" else "vertical",
                                        status = "default",
                                        individual = TRUE,
                                        width = "100%"
                                      )
                                    } else {
                                      radio_ui <- shiny::radioButtons(
                                        inputId = "item_response",
                                        label = NULL,
                                        choices = stats::setNames(choices, labels),
                                        selected = base::character(0),
                                        inline = is_inline,
                                        width = "100%"
                                      )
                                      if (is_endpoint_only) shiny::div(class = "rl-endpoint-only", radio_ui) else radio_ui
                                    }
                       )
                                          } else {
                        choices <- base::c(item$Option1, item$Option2, item$Option3, item$Option4)
                         # If options are missing for dichotomous model, synthesize simple options
                         if (length(choices) == 0 || all(is.na(choices) | choices == "")) {
                           choices <- c("1", "2")
                           item$Answer <- item$Answer %||% "1"
                         } else {
                           choices <- choices[!is.na(choices) & choices != ""]
                         }
                        
                        shiny::radioButtons(
                          inputId = "item_response",
                          label = NULL,
                          choices = choices,
                          selected = base::character(0),
                          inline = is_inline,
                          width = "100%"
                        )
                      }
                     progress_pct <- base::round((base::length(rv$administered) / (config$max_items %||% max(1, nrow(item_bank)))) * 100)
                     # Theme primary color for the progress indicator
                     progress_theme_primary <- if (!is.null(theme_config) && !is.null(theme_config$primary_color)) {
                       theme_config$primary_color
                     } else if (is.character(config$theme) && nzchar(config$theme)) {
                       theme_name <- tolower(config$theme)
                       switch(theme_name,
                         "light" = "#007bff",
                         "midnight" = "#6366f1",
                         "sunset" = "#ff6f61",
                         "forest" = "#2e7d32",
                         "ocean" = "#0288d1",
                         "berry" = "#c2185b",
                         "hildesheim" = "#e8041c",
                         "professional" = "#2c3e50",
                         "clinical" = "#A23B72",
                         "research" = "#007bff",
                         "sepia" = "#8B4513",
                         "paper" = "#005073",
                         "monochrome" = "#333333",
                         "large-text" = "#2E5BBA",
                         "inrep" = "#000000",
                         "high-contrast" = "#000000",
                         "dyslexia-friendly" = "#005F73",
                         "darkblue" = "#64ffda",
                         "dark-mode" = "#00D4AA",
                         "colorblind-safe" = "#0072B2",
                         "vibrant" = "#e74c3c",
                         "#007bff"
                       )
                     } else {
                       "#007bff"
                     }
                     progress_ui <- base::switch(config$progress_style %||% "circle",
                       "none" = NULL,
                       "circle" = {
                         theme_primary <- progress_theme_primary
                         shiny::div(
                           class = "progress-circle progress-circle-gradient",
                           shiny::tags$style(base::sprintf("
                             .progress-circle-gradient {
                               position: relative;
                               display: flex;
                               justify-content: center;
                               align-items: center;
                               width: 120px;
                               height: 120px;
                               background: transparent;
                             }
                             .progress-circle-gradient svg {
                               position: absolute;
                               left: 0;
                               top: 0;
                               display: block;
                             }
                             .progress-circle-gradient .progress-bg {
                               stroke: #e0e0e0;
                               stroke-width: 8;
                               fill: none;
                             }
                             .progress-circle-gradient .progress {
                               transition: stroke-dashoffset 0.5s cubic-bezier(.4,2,.3,1);
                               stroke: url(#progressGradient);
                               stroke-width: 8;
                               fill: none;
                             }
                             .progress-circle-gradient .tiny-full {
                               stroke: %s;
                               stroke-width: 3;
                               fill: none;
                               opacity: 0.5;
                             }
                             .progress-circle-gradient span {
                               position: absolute;
                               top: 50%%;
                               left: 50%%;
                               margin-left: -30px;
                               margin-top: -15px;
                               font-family: 'Helvetica Neue', 'Arial', sans-serif;
                               font-size: 20px;
                               font-weight: 500;
                               color: var(--text-color);
                             }
                           ", theme_primary)),
                           shiny::tags$svg(
                             width = "120", height = "120",
                             shiny::tags$defs(
                               shiny::tags$linearGradient(id = "progressGradient",
                                 shiny::tags$stop(offset = "0%", style = base::sprintf("stop-color: %s;", theme_primary)),
                                 shiny::tags$stop(offset = "100%", style = base::sprintf("stop-color: %s; stop-opacity: 0.7;", theme_primary))
                               )
                             ),
                             # Tiny full circle indicator (background)
                             shiny::tags$circle(cx = "60", cy = "60", r = "52", class = "tiny-full"),
                             # Main progress background circle
                             shiny::tags$circle(cx = "60", cy = "60", r = "50", class = "progress-bg"),
                             # Main progress arc (foreground) as SVG path
                             {
                               # Calculate arc sweep for progress
                               pct <- max(0, min(progress_pct, 100))
                               theta <- (pct / 100) * 2 * pi
                               r <- 50
                               cx <- 60
                               cy <- 60
                               x <- cx + r * cos(pi/2 - theta)
                               y <- cy - r * sin(pi/2 - theta)
                               large_arc <- ifelse(pct > 50, 1, 0)
                               path_d <- if (pct == 0) {
                                 # No progress
                                 sprintf("M %f %f", cx, cy - r)
                               } else {
                                 sprintf("M %f %f A %d %d 0 %d 1 %f %f", cx, cy - r, r, r, large_arc, x, y)
                               }
                               shiny::tags$path(
                                 d = path_d,
                                 class = "progress",
                                 stroke = "url(#progressGradient)",
                                 strokeWidth = 8,
                                 fill = "none"
                               )
                             },
                           ),
                           shiny::span(base::sprintf("%d%%", progress_pct))
                         )
                       },
                       "bar" = shiny::div(
                         class = "progress-bar-container",
                         style = "background: #e5e7eb;",
                         shiny::div(class = "progress-bar-fill", style = base::sprintf("width: %d%%; background: %s;", progress_pct, progress_theme_primary))
                       ),
                       # Default fallback for unknown style values
                       shiny::div(
                         class = "progress-bar-container",
                         style = "background: #e5e7eb;",
                         shiny::div(class = "progress-bar-fill", style = base::sprintf("width: %d%%; background: %s;", progress_pct, progress_theme_primary))
                       )
                     )
                     shiny::tagList(
                       shiny::div(class = "assessment-card",
                         shiny::h3(config$name, class = "card-header"),
                         shiny::div(
                           style = "display: flex; flex-direction: column; align-items: center; justify-content: center; width: 100%;",
                           progress_ui,
                                                    shiny::p(
                                                      base::tryCatch(
                                                        base::sprintf(
                                                          ui_labels$question_progress %||% "Question %d of %d",
                                                          base::length(rv$administered) + 1,
                                                          config$max_items
                                                        ),
                                                        error = function(e) base::sprintf(
                                                          "Question %d of %d",
                                                          base::length(rv$administered) + 1,
                                                          config$max_items
                                                        )
                                                      ),
                                                      style = "text-align: center; margin: 15px 0; width: 100%;"
                                                    )
                         ),
                         shiny::div(class = "test-question", item$Question),
                         shiny::div(class = "radio-group-container", response_ui),
                         if (!base::is.null(rv$error_message)) shiny::div(class = "error-message", rv$error_message),
                         shiny::uiOutput("error_boundary"),
                         if (!base::is.null(rv$feedback_message)) shiny::div(class = "feedback-message", rv$feedback_message),
                         shiny::div(class = "nav-buttons",
                           # The button is disabled for 2 s after a click
        shiny::div(
          style = "position: relative;",
          shiny::actionButton(
            "submit_response", 
            ui_labels$submit_button, 
            class = "btn-klee",
            onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 2000);"
          ),
          shiny::uiOutput("submission_status")
        )
                         )
                       )
                     )
                   },
                   "results" = {
                     if (base::is.null(rv$cat_result)) return()

                     # A results_processor replaces the default summary here as
                     # well, not only on a results page of a custom_page_flow.
                     # The responses are passed in item bank order, with NA for
                     # items that were not administered.
                     if (base::is.function(config$results_processor)) {
                       resp_full <- base::rep(NA_real_, base::nrow(item_bank))
                       n_given <- base::min(base::length(rv$cat_result$administered),
                                            base::length(rv$cat_result$responses))
                       if (n_given > 0) {
                         idx <- rv$cat_result$administered[base::seq_len(n_given)]
                         resp_full[idx] <- base::as.numeric(rv$cat_result$responses[base::seq_len(n_given)])
                       }
                       rp <- config$results_processor
                       rp_formals <- base::names(base::formals(rp))
                       rp_args <- base::list(responses = resp_full, item_bank = item_bank)
                       if ("demographics" %in% rp_formals) rp_args$demographics <- rv$demo_data
                       if ("session"      %in% rp_formals) rp_args$session      <- session
                       if ("rv"           %in% rp_formals) rp_args$rv           <- rv
                       if ("input"        %in% rp_formals) rp_args$input        <- input
                       if ("config"       %in% rp_formals) rp_args$config       <- config
                       report <- base::tryCatch(base::do.call(rp, rp_args), error = function(e) {
                         logger(base::sprintf("results_processor failed: %s", e$message), level = "ERROR")
                         shiny::p(base::paste("The report could not be created:", e$message))
                       })
                       return(shiny::div(class = "assessment-card", report))
                     }

                     results_content <- base::list(
                       shiny::h3(ui_labels$results_title, class = "card-header"),
                       shiny::div(class = "results-section",
                                  shiny::h4("Assessment Summary"),
                                  shiny::p(base::paste("Items completed:", base::length(rv$cat_result$administered))),
                                  if (config$adaptive) shiny::p(base::paste("Estimated ability:", base::round(rv$cat_result$theta, 2))),
                                  if (config$adaptive) shiny::p(base::paste("Standard error:", base::round(rv$cat_result$se, 3)))
                       )
                     )
                     
                                           # Participant report controls
                      pr <- config$participant_report %||% list()
                      if (isTRUE(pr$show_theta_plot) && config$adaptive && base::length(rv$theta_history) > 1 && base::length(rv$se_history) > 1) {
                         logger(sprintf("Adding plot to results - theta_history length: %d", base::length(rv$theta_history)))
                         results_content <- base::c(results_content, base::list(
                           shiny::plotOutput("theta_plot", height = "220px")
                         ))
                       } else {
                         logger(sprintf("Plot not added - adaptive: %s, theta_history length: %d, se_history length: %d", config$adaptive, base::length(rv$theta_history), base::length(rv$se_history)))
                       }
                      
                      # Domain breakdown visualization (if available)
                      if (isTRUE(pr$show_domain_breakdown) && "domain" %in% base::names(item_bank)) {
                        results_content <- base::c(results_content, base::list(
                          shiny::div(class = "results-section",
                                     shiny::h4("Domain Coverage", class = "results-title"),
                                     shiny::plotOutput("domain_plot", height = "220px")
                          )
                        ))
                      }
                      
                      # Difficulty trend visualization (if available)
                      if (isTRUE(pr$show_item_difficulty_trend) && "b" %in% base::names(item_bank)) {
                        results_content <- base::c(results_content, base::list(
                          shiny::div(class = "results-section",
                                     shiny::h4("Item Difficulty Trend", class = "results-title"),
                                     shiny::plotOutput("difficulty_trend", height = "220px")
                          )
                        ))
                      }
                      
                      # Response table (enhanced or basic)
                      if (!isFALSE(pr$show_response_table)) {
                        results_content <- base::c(results_content, base::list(
                          shiny::div(class = "results-section",
                                     shiny::h4(ui_labels$items_administered, class = "results-title"),
                                     if (!is.null(available_packages) && isTRUE(available_packages[["DT"]])) DT::DTOutput("item_table") else shiny::verbatimTextOutput("item_table")
                          )
                        ))
                      }
                     
                     # Recommendations
                     if (!isFALSE(pr$show_recommendations)) {
                       results_content <- base::c(results_content, base::list(
                         shiny::div(class = "results-section",
                                    shiny::h4(ui_labels$recommendations, class = "results-title"),
                                    shiny::uiOutput("recommendations")
                         )
                       ))
                     }
                     
                     # PDF button in the theme's primary color
                     theme_primary_color <- "#667eea"  # Default color
                     if (!base::is.null(theme_config) && !base::is.null(theme_config$primary_color)) {
                       theme_primary_color <- theme_config$primary_color
                     } else {
                       theme_name <- if (is.character(config$theme)) tolower(config$theme) else "professional"
                       theme_primary_color <- base::switch(theme_name,
                                                           "light" = "#212529",
                                                           "midnight" = "#6366f1",
                                                           "sunset" = "#ff6f61",
                                                           "forest" = "#2e7d32",
                                                           "ocean" = "#0288d1",
                                                           "berry" = "#c2185b",
                                                           "hildesheim" = "#e8041c",
                                                           "professional" = "#2c3e50",
                                                           "clinical" = "#A23B72",
                                                           "research" = "#007bff",
                                                           "sepia" = "#8B4513",
                                                           "paper" = "#005073",
                                                           "monochrome" = "#333333",
                                                           "large-text" = "#2E5BBA",
                                                           "inrep" = "#000000",
                                                           "high-contrast" = "#000000",
                                                           "dyslexia-friendly" = "#005F73",
                                                           "darkblue" = "#64ffda",
                                                           "dark-mode" = "#00D4AA",
                                                           "colorblind-safe" = "#0072B2",
                                                           "vibrant" = "#e74c3c",
                                                           "#667eea"  # Default fallback
                       )
                     }
                     
                     results_content <- base::c(results_content, base::list(
                       shiny::div(
                        class = "download-section",
                        style = "padding: 20px; border-radius: 5px; margin: 20px 0; text-align: center;",
                        shiny::h4("Export Your Results", style = "color: var(--text-color); margin-bottom: 15px;"),
                         shiny::div(
                           style = "display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;",
                           shiny::tags$button(
                             onclick = "if(typeof Shiny !== 'undefined') { Shiny.setInputValue('download_pdf_trigger', Math.random(), {priority: 'event'}); } else { alert('Download not available'); }",
                             class = "btn btn-primary",
                             style = sprintf("background: %s; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500;", theme_primary_color),
                             shiny::tags$i(class = "fas fa-file-pdf", style = "margin-right: 8px;"),
                             "Download PDF Report"
                           )
                         )
                       )
                     ))
                     
                     # Footer and controls
                     results_content <- base::c(results_content, base::list(
                       shiny::div(class = "footer",
                                  shiny::p(config$name),
                                  shiny::p(base::format(base::Sys.time(), "%B %d, %Y"))
                       )
                     ))
                     
                     # Optional legacy download/restart buttons (disabled by default)
                     # Can be enabled via participant_report$show_legacy_buttons = TRUE
                     if (isTRUE(pr$show_legacy_buttons)) {
                       results_content <- base::c(results_content, base::list(
                         shiny::div(class = "nav-buttons",
                                    shiny::downloadButton("save_report", ui_labels$save_button, class = "btn-klee"),
                                    shiny::downloadButton("download_session_dataset", "Download Complete Dataset", class = "btn-klee"),
                                    shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee",
                                                       onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);")
                         )
                       ))
                     }
                     
                     shiny::tagList(
                                             shiny::div(id = "report-content", class = "assessment-card", results_content)
                    )
                  }
          ) # End of switch
          ) # End of page-wrapper div
      })
    
    # Countdown timer output for auto-close functionality
    output$countdown_timer <- shiny::renderText({
      if (isTRUE(rv$auto_close_timer_active) && !is.null(rv$countdown_time)) {
        sprintf("%d", rv$countdown_time)
      } else {
        ""
      }
    })

    # Auto-close countdown observer (runs only when enabled).
    # Stored in session$userData to prevent duplicate observers.
    if (is.null(session$userData$countdown_observer)) {
      countdown_observer <- shiny::observe({
        if (!isTRUE(rv$auto_close_timer_active)) {
          return(NULL)
        }
        # Read the countdown in isolate(): writing it below must not re-run this
        # observer immediately (that drained the whole countdown in an instant).
        remaining <- shiny::isolate(rv$countdown_time)
        if (is.null(remaining)) {
          return(NULL)
        }

        if (remaining > 0) {
          rv$countdown_time <- remaining - 1
          shiny::invalidateLater(1000, session)
          return(NULL)
        }

        # Time's up - close the app/tab/browser
        logger("Auto-close timer expired - closing app/tab/browser", level = "INFO")
        rv$auto_close_timer_active <- FALSE

        # Auto-close JavaScript (best effort; depends on the browser).
        # window.close() is a silent no-op (it does NOT throw) on a tab the
        # browser opened via normal navigation - which is every participant's
        # tab, since they reach the study through a plain URL, not a
        # window.open() popup. A try/catch around it therefore never reaches
        # its fallback. Detect failure via window.closed instead.
        auto_close_js <- "
        (function() {
          try { window.close(); } catch(e) {}
          setTimeout(function() {
            if (window.closed) return;
            try {
              window.location.href = 'about:blank';
            } catch(e2) {
              try {
                document.body.innerHTML = '<div style=\"text-align: center; padding: 50px; font-size: 18px;\">Session completed. Please close this tab.</div>';
              } catch(e3) {}
            }
          }, 300);
        })();
        "

        if (requireNamespace("shinyjs", quietly = TRUE)) {
          tryCatch({
            shinyjs::runjs(auto_close_js)
          }, error = function(e) {
            logger(sprintf("Auto-close failed: %s", e$message), level = "WARNING")
          })
        } else {
          logger("shinyjs not available for auto-close", level = "WARNING")
        }

        logger("Ending participant session after study completion", level = "INFO")
        tryCatch({
          later::later(function() .inrep_end_session(session), delay = 3)
        }, error = function(e) {
          logger(sprintf("App stop failed: %s", e$message), level = "ERROR")
          .inrep_end_session(session)
        })
      })
      session$userData$countdown_observer <- countdown_observer
    }

    output$theta_plot <- shiny::renderPlot({
      logger(sprintf("Plot rendering triggered - adaptive: %s, theta_history length: %d", config$adaptive, base::length(rv$theta_history)))
      
      if (!config$adaptive || base::length(rv$theta_history) < 2 || base::length(rv$se_history) < 2) {
        logger("Plot not rendered - conditions not met")
        return(NULL)
      }
      
      # Get theme colors for plot
      theme_colors <- list(
        primary = "#007bff",
        secondary = "#6c757d"
      )
      
      if (!base::is.null(theme_config) && !base::is.null(theme_config$primary_color)) {
        theme_colors$primary <- theme_config$primary_color
      } else {
        theme_name <- if (is.character(config$theme)) tolower(config$theme) else "light"
        theme_colors$primary <- base::switch(theme_name,
                                             "light" = "#212529",
                                             "midnight" = "#6366f1",
                                             "sunset" = "#ff6f61",
                                             "forest" = "#2e7d32",
                                             "ocean" = "#0288d1",
                                             "berry" = "#c2185b",
                                             "hildesheim" = "#e8041c",
                                             "professional" = "#2c3e50",
                                             "clinical" = "#A23B72",
                                             "research" = "#007bff",
                                             "sepia" = "#8B4513",
                                             "paper" = "#005073",
                                             "monochrome" = "#333333",
                                             "large-text" = "#2E5BBA",
                                             "inrep" = "#000000",
                                             "high-contrast" = "#000000",
                                             "dyslexia-friendly" = "#005F73",
                                             "darkblue" = "#64ffda",
                                             "dark-mode" = "#00D4AA",
                                             "colorblind-safe" = "#0072B2",
                                             "vibrant" = "#e74c3c",
                                             "#007bff"  # Default fallback
        )
      }
      
      # Align history vectors to same length to avoid rendering errors
      n <- base::min(base::length(rv$theta_history), base::length(rv$se_history))
      if (n < 2) return(NULL)
      data <- base::data.frame(
        Item = 1:n,
        Theta = rv$theta_history[1:n],
        SE = rv$se_history[1:n]
      )
      
      # Robust plotting with multiple fallbacks
      tryCatch({
        # Try ggplot2 first
        if (!is.null(available_packages) && isTRUE(available_packages[["ggplot2"]]) && requireNamespace("ggplot2", quietly = TRUE)) {
          p <- ggplot2::ggplot(data, ggplot2::aes(x = Item, y = Theta)) +
            ggplot2::geom_line(color = theme_colors$primary, linewidth = 1) +
            ggplot2::geom_ribbon(ggplot2::aes(ymin = Theta - SE, ymax = Theta + SE), alpha = 0.2, fill = theme_colors$primary) +
            ggplot2::theme_minimal() +
            ggplot2::labs(y = "Trait Score", x = "Item Number", title = "Ability Progression") +
            ggplot2::theme(
              text = ggplot2::element_text(family = "Inter", size = 12),
              plot.title = ggplot2::element_text(face = "bold", size = 14),
              axis.title = ggplot2::element_text(size = 12)
            )
          print(p)  # Explicitly print the plot
        } else {
          # Fallback to base R plot
          plot(data$Item, data$Theta, type = "l", col = theme_colors$primary, 
               xlab = "Item Number", ylab = "Trait Score", main = "Ability Progression",
               lwd = 2, ylim = range(c(data$Theta - data$SE, data$Theta + data$SE)))
          polygon(c(data$Item, rev(data$Item)), 
                  c(data$Theta - data$SE, rev(data$Theta + data$SE)), 
                  col = paste0(theme_colors$primary, "20"), border = NA)
          grid()
        }
      }, error = function(e) {
        # Ultimate fallback to base R plot
        logger(sprintf("Plot rendering failed: %s", e$message), level = "WARNING")
        plot(data$Item, data$Theta, type = "l", col = theme_colors$primary, 
             xlab = "Item Number", ylab = "Trait Score", main = "Ability Progression (Fallback)",
             lwd = 2)
        grid()
      })
    })
    
    # Optional domain breakdown plot
    output$domain_plot <- shiny::renderPlot({
      pr <- config$participant_report %||% list()
      if (!isTRUE(pr$show_domain_breakdown) || !("domain" %in% base::names(item_bank))) return(NULL)
      if (is.null(available_packages) || !isTRUE(available_packages[["ggplot2"]]) || !requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
      
      if (base::length(rv$cat_result$administered) < 1) return(NULL)
      used <- rv$cat_result$administered
      dat <- base::as.data.frame(table(item_bank$domain[used]))
      base::names(dat) <- c("Domain", "Count")
      ggplot2::ggplot(dat, ggplot2::aes(x = Domain, y = Count)) +
        ggplot2::geom_col(fill = "#2c3e50") +
        ggplot2::theme_minimal() +
        ggplot2::labs(title = "Domain Coverage", x = NULL, y = "Items") +
        ggplot2::theme(text = ggplot2::element_text(family = "Inter", size = 11))
    })
    
    # Optional difficulty trend plot
    output$difficulty_trend <- shiny::renderPlot({
      pr <- config$participant_report %||% list()
      if (!isTRUE(pr$show_item_difficulty_trend) || !("b" %in% base::names(item_bank))) return(NULL)
      if (is.null(available_packages) || !isTRUE(available_packages[["ggplot2"]]) || !requireNamespace("ggplot2", quietly = TRUE)) return(NULL)
      
      if (base::length(rv$cat_result$administered) < 2) return(NULL)
      used <- rv$cat_result$administered
      dat <- base::data.frame(
        Order = seq_along(used),
        Difficulty = item_bank$b[used]
      )
      ggplot2::ggplot(dat, ggplot2::aes(x = Order, y = Difficulty)) +
        ggplot2::geom_line(color = "#2c3e50", linewidth = 1) +
        ggplot2::geom_point(color = "#2c3e50", size = 2) +
        ggplot2::theme_minimal() +
        ggplot2::labs(title = "Item Difficulty Trend", x = "Item Order", y = "b") +
        ggplot2::theme(text = ggplot2::element_text(family = "Inter", size = 11))
    })
    
    output$item_table <- safe_render_dt({
      if (base::is.null(rv$cat_result)) return()
      items <- rv$cat_result$administered
      responses <- rv$cat_result$responses
      # Align lengths defensively
      if (length(items) != length(responses)) {
        n <- min(length(items), length(responses))
        items <- items[seq_len(n)]
        responses <- responses[seq_len(n)]
      }
      # Use enhanced reporting when requested
      pr <- config$participant_report %||% list()
      if (isTRUE(pr$use_enhanced_report)) {
        dat <- create_response_report(config, rv$cat_result, item_bank)
      } else {
        dat <- if (config$model == "GRM") {
          base::data.frame(
            Item = 1:base::length(items),
            Question = item_bank$Question[items],
            Response = responses,
            Time = base::round(rv$cat_result$response_times[seq_len(length(items))], 1),
            check.names = FALSE
          )
        } else {
          base::data.frame(
            Item = 1:base::length(items),
            Question = item_bank$Question[items],
            Response = base::ifelse(responses == 1, "Correct", "Incorrect"),
            Correct = item_bank$Answer[items],
            Time = base::round(rv$cat_result$response_times[seq_len(length(items))], 1),
            check.names = FALSE
          )
        }
      }
      columnDefs <- base::list(
        base::list(width = '50%', targets = 0),
        base::list(width = '25%', targets = 1)
      )
      if (config$model == "GRM") {
        columnDefs[[3]] <- base::list(width = '25%', targets = 2)
      } else if ("Correct" %in% base::names(dat)) {
        columnDefs[[3]] <- base::list(width = '25%', targets = 2)
        columnDefs[[4]] <- base::list(width = '25%', targets = 3)
      } else {
        columnDefs[[3]] <- base::list(width = '25%', targets = 2)
      }
      DT::datatable(
        dat,
        rownames = FALSE,
        options = base::list(
          dom = 't',
          paging = FALSE,
          searching = FALSE,
          autoWidth = TRUE,
          columnDefs = columnDefs
        )
      ) -> dt_table
      
      DT::formatStyle(dt_table, columns = base::names(dat), color = 'var(--text-color)', fontFamily = 'var(--font-family)')
    })
    
    output$recommendations <- shiny::renderUI({
      shiny::req(rv$cat_result)
      recs <- base::tryCatch(
        config$recommendation_fun(if (config$adaptive) rv$cat_result$theta else base::mean(rv$cat_result$responses, na.rm = TRUE), rv$demo_data),
        error = function(e) {
          logger(base::sprintf("Recommendation function error: %s", e$message))
          NULL
        }
      )
      if (base::is.null(recs) || base::length(recs) == 0) {
        shiny::p("No recommendations available.")
      } else {
        shiny::tags$ul(class = "recommendation-list", base::lapply(recs, shiny::tags$li))
      }
    })
    
    output$save_report <- shiny::downloadHandler(
      filename = function() {
        base::paste0(config$study_key %||% "study", "_", base::format(base::Sys.time(), "%Y%m%d_%H%M%S"), ".", save_format)
      },
      content = function(file) {
        report_data <- base::as.list(base::list(
          config = config,
          demographics = base::as.list(rv$demo_data),
          theta = if (config$adaptive) rv$cat_result$theta else NULL,
          se = if (config$adaptive) rv$cat_result$se else NULL,
          administered = item_bank$Question[rv$cat_result$administered],
          responses = rv$cat_result$responses,
          response_times = rv$cat_result$response_times,
          recommendations = config$recommendation_fun(if (config$adaptive) rv$cat_result$theta else base::mean(rv$cat_result$responses, na.rm = TRUE), rv$demo_data),
          timestamp = base::Sys.time(),
          theta_history = if (config$adaptive) rv$theta_history else NULL,
          se_history = if (config$adaptive) rv$se_history else NULL
        ))
        if (save_format == "pdf") {
          safe_title <- gsub("([_%&#$])", "\\\\\\1", config$name)
          latex_content <- sprintf('
            \\documentclass{article}
            \\usepackage{geometry}
            \\usepackage{booktabs}
            \\usepackage[utf8]{inputenc}
            \\usepackage{amsmath}
            \\geometry{margin=0.75in}
            \\begin{document}
            
            \\title{%s}
            \\author{}
            \\date{%s}
            \\maketitle
            
            \\section{Participant Information}
            \\begin{tabular}{ll}
            %s
            \\end{tabular}
            
            \\section{Assessment Results}
            \\begin{itemize}
            %s
                \\item \\textbf{Items Administered}: %d
            \\end{itemize}
            
            \\section{Responses}
            \\begin{table}[h]
            \\centering
            \\small
            \\begin{tabular}{p{5cm}lp{2cm}}
            \\toprule
            \\textbf{Question} & \\textbf{Response} & \\textbf{Time (Sec.)} \\\\
            \\midrule
            %s
            \\bottomrule
            \\end{tabular}
            \\caption{Individual Item Results}
            \\end{table}
            
            \\section{Recommendations}
            \\begin{itemize}
            %s
            \\end{itemize}
            
            \\end{document}
            ',
                                   safe_title,
                                   format(Sys.time(), "%B %d, %Y"),
                                   base::paste(base::sapply(base::names(rv$demo_data), function(d) base::sprintf("%s & %s \\\\", d, rv$demo_data[d] %||% "N/A")), collapse = "\n"),
                                   if (config$adaptive) base::sprintf("\\item \\textbf{Trait Score}: %.2f\n\\item \\textbf{Standard Error}: %.3f", rv$cat_result$theta, rv$cat_result$se) else "",
                                   base::length(rv$cat_result$administered),
                                   base::paste(base::sapply(base::seq_along(rv$cat_result$administered), function(i) {
                                     base::sprintf("%s & %s & %.1f \\\\", 
                                                   item_bank$Question[rv$cat_result$administered[i]], 
                                                   rv$cat_result$responses[i],
                                                   rv$cat_result$response_times[i])
                                   }), collapse = "\n"),
                                   base::paste(base::sprintf("\\item %s", report_data$recommendations), collapse = "\n")
          )
          temp_dir <- base::tempdir()
          tex_file <- base::file.path(temp_dir, "report.tex")
          base::writeLines(latex_content, tex_file)
          base::tryCatch({
            tinytex::latexmk(tex_file, "pdflatex")
            base::file.copy(base::paste0(tools::file_path_sans_ext(tex_file), ".pdf"), file)
          }, error = function(e) {
            logger(base::sprintf("PDF generation failed: %s", e$message))
            jsonlite::write_json(report_data, file, pretty = TRUE, auto_unbox = TRUE)
          })
        } else if (save_format == "rds") {
          base::saveRDS(report_data, file)
        } else if (save_format == "csv") {
          # Use session dataset if available, otherwise fall back to original method
          tryCatch({
            if (exists("get_session_dataset", mode = "function")) {
              session_data <- get_session_dataset(session = session)
              if (!is.null(session_data)) {
                # Use session dataset for export
                utils::write.csv(session_data, file, row.names = FALSE)
                logger("Exported session dataset to CSV", level = "INFO")
              } else {
                # Fall back to original method
              flat_data <- base::data.frame(
                Timestamp = report_data$timestamp,
                Theta = if (config$adaptive) report_data$theta else NA,
                SE = if (config$adaptive) report_data$se else NA,
                base::t(report_data$demographics),
                Items = base::paste(report_data$administered, collapse = ";"),
                Responses = base::paste(report_data$responses, collapse = ";"),
                Response_Times = base::paste(report_data$response_times, collapse = ";"),
                Recommendations = base::paste(report_data$recommendations, collapse = ";")
              )
              utils::write.csv(flat_data, file, row.names = FALSE)
              }
            }
          }, error = function(e) {
            logger(sprintf("Failed to export session dataset, using fallback: %s", e$message), level = "WARNING")
            # Fall back to original method
            flat_data <- base::data.frame(
              Timestamp = report_data$timestamp,
              Theta = if (config$adaptive) report_data$theta else NA,
              SE = if (config$adaptive) report_data$se else NA,
              base::t(report_data$demographics),
              Items = base::paste(report_data$administered, collapse = ";"),
              Responses = base::paste(report_data$responses, collapse = ";"),
              Response_Times = base::paste(report_data$response_times, collapse = ";"),
              Recommendations = base::paste(report_data$recommendations, collapse = ";")
            )
            utils::write.csv(flat_data, file, row.names = FALSE)
          })
        } else if (save_format == "json") {
          jsonlite::write_json(report_data, file, pretty = TRUE, auto_unbox = TRUE)
        }
      }
    )
    
    # Session dataset download handler
    output$download_session_dataset <- shiny::downloadHandler(
      filename = function() {
        base::paste0("session_data_", config$study_key %||% "study", "_", base::format(base::Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
      },
      content = function(file) {
        tryCatch({
          if (exists("get_session_dataset", mode = "function")) {
            session_data <- get_session_dataset(session = session)
            if (!is.null(session_data)) {
              utils::write.csv(session_data, file, row.names = FALSE)
              logger("Session dataset downloaded successfully", level = "INFO")
            } else {
              # Fallback to basic data
            basic_data <- data.frame(
              study_key = config$study_key %||% "study",
              timestamp = Sys.time(),
              demographics = paste(rv$demo_data, collapse = ";"),
              theta = if (config$adaptive) rv$cat_result$theta else NA,
              se = if (config$adaptive) rv$cat_result$se else NA,
              items_administered = length(rv$cat_result$administered %||% 0),
              responses = paste(rv$cat_result$responses, collapse = ";")
            )
            utils::write.csv(basic_data, file, row.names = FALSE)
            logger("Downloaded basic dataset (session dataset not available)", level = "WARNING")
            }
          }
        }, error = function(e) {
          logger(sprintf("Failed to download session dataset: %s", e$message), level = "ERROR")
          # Create minimal fallback
          fallback_data <- data.frame(
            error = "Dataset download failed",
            timestamp = Sys.time(),
            message = e$message
          )
          utils::write.csv(fallback_data, file, row.names = FALSE)
        })
      }
    )
    
    # Paradata logging (config$log_data = TRUE), fed by the script in the page head
    if (config$log_data %||% FALSE) {
      # Track input changes
      shiny::observeEvent(input$log_input_change, {
        tryCatch({
          log_data <- input$log_input_change
          current_page_id <- paste0("page_", rv$current_page)
          if (exists("log_action", mode = "function")) {
            log_action("input_change", log_data, current_page_id, session = session)
          }
        }, error = function(e) {
          logger(sprintf("Failed to log input change: %s", e$message), level = "WARNING")
        })
      }, ignoreInit = TRUE)
      
      # Track button clicks
      shiny::observeEvent(input$log_button_click, {
        tryCatch({
          log_data <- input$log_button_click
          current_page_id <- paste0("page_", rv$current_page)
          if (exists("log_action", mode = "function")) {
            log_action("button_click", log_data, current_page_id, session = session)
          }
        }, error = function(e) {
          logger(sprintf("Failed to log button click: %s", e$message), level = "WARNING")
        })
      }, ignoreInit = TRUE)
      
      # Track visibility changes (tab switching)
      shiny::observeEvent(input$log_visibility_change, {
        tryCatch({
          log_data <- input$log_visibility_change
          current_page_id <- paste0("page_", rv$current_page)
          action_type <- if (log_data$hidden) "tab_switch_away" else "tab_switch_back"
          if (exists("log_action", mode = "function")) {
            log_action(action_type, log_data, current_page_id, session = session)
          }
        }, error = function(e) {
          logger(sprintf("Failed to log visibility change: %s", e$message), level = "WARNING")
        })
      }, ignoreInit = TRUE)
      
      # Track mouse activity
      shiny::observeEvent(input$log_mouse_activity, {
        tryCatch({
          log_data <- input$log_mouse_activity
          current_page_id <- paste0("page_", rv$current_page)
          if (exists("log_action", mode = "function")) {
            log_action("mouse_activity", log_data, current_page_id, session = session)
          }
        }, error = function(e) {
          logger(sprintf("Failed to log mouse activity: %s", e$message), level = "WARNING")
        })
      }, ignoreInit = TRUE)
    }
    
    shiny::observe({
      if (config$session_save) {
        run_storage_pipeline(trigger = "reactive_state", force = FALSE, include_cloud = FALSE)
      }
    })
    
    # Run a page's completion_handler (used by both "next" and the final submit,
    # so the last page before the results page gets its handler too).
    run_page_completion_handler <- function(current_page) {
      handler <- current_page$completion_handler
      if (is.null(handler) || !is.function(handler)) return(invisible(NULL))
      tryCatch({
        # Pass arguments by name, according to the handler's formals, so that
        # function(input, rv, ...) and function(session, rv, input, config)
        # both work.
        handler_args <- tryCatch(names(formals(handler)), error = function(e) NULL)
        if (!is.null(handler_args)) {
          call_args <- list()
          if ("session" %in% handler_args) call_args$session <- session
          if ("input"   %in% handler_args) call_args$input   <- input
          if ("inputs"  %in% handler_args) call_args$inputs  <- input   # alias used by some studies (e.g. HilFo)
          if ("rv"      %in% handler_args) call_args$rv      <- rv
          if ("config"  %in% handler_args) call_args$config  <- config
          do.call(handler, call_args)
        } else {
          # Fallback: pass all four positionally (legacy behaviour)
          handler(session, rv, input, config)
        }
        logger(sprintf("Called completion handler for %s page", current_page$type), level = "DEBUG")
      }, error = function(e) {
        logger(sprintf("Error in completion handler for %s page: %s", current_page$type, e$message), level = "WARNING")
      })
      invisible(NULL)
    }

    # Custom page flow navigation observers
    shiny::observeEvent(input$next_page, {
      if (rv$stage == "custom_page_flow" && rv$current_page < rv$total_pages) {
        # Validate current page before progression
        validation_passed <- TRUE
        
        # First check built-in validation
        if (exists("validate_page_progression")) {
          # Pass item_bank and current language in config for validation
          config_with_items <- config
          config_with_items$item_bank <- item_bank
          config_with_items$current_language <- rv$language
          validation <- validate_page_progression(rv$current_page, input, config_with_items)
          if (!validation$valid) {
            # Show error messages
            output$validation_errors <- shiny::renderUI({
              current_lang <- rv$language %||% config$language %||% "de"
              show_validation_errors(validation$errors, language = current_lang)
            })
            
            # Field highlighting disabled for performance
            # (shinyjs was causing lag in page transitions)
            
            validation_passed <- FALSE
          }
        }
        
        # Then check custom validation function if provided
        if (validation_passed && !is.null(config$validation_function) && is.function(config$validation_function)) {
          tryCatch({
            # Get current page info for custom validation
            current_page <- config$custom_page_flow[[rv$current_page]]
            page_id <- current_page$id %||% paste0("page_", rv$current_page)
            
            # Call custom validation function
            custom_validation <- config$validation_function(page_id, input, rv)
            
            if (!is.null(custom_validation) && !custom_validation$valid) {
              # Show custom validation error messages
              output$validation_errors <- shiny::renderUI({
                current_lang <- rv$language %||% config$language %||% "de"
                # Use language-aware fallback message
                error_message <- custom_validation$message %||% get_validation_fallback_message(current_lang)
                show_validation_errors(error_message, language = current_lang)
              })
              
              validation_passed <- FALSE
            }
          }, error = function(e) {
            logger(sprintf("Error in custom validation function: %s", e$message), level = "WARNING")
            # Continue with validation passed if custom validation fails
          })
        }
        
        if (!validation_passed) {
          return()  # Don't proceed if validation fails
        }
        
        # Clear any previous validation errors
        output$validation_errors <- shiny::renderUI({ NULL })
        
        # Clear error highlighting from all fields (removed shinyjs for performance)
        
        # Save current page data
        current_page <- config$custom_page_flow[[rv$current_page]]
        
        # Collect demographics from current page
        if (current_page$type == "demographics") {
          demo_vars <- current_page$demographics %||% config$demographics
          page_data <- list()
          for (dem in demo_vars) {
            input_id <- paste0("demo_", dem)
            value <- input[[input_id]]
            # value may be a vector (checkbox group)
            if (!is.null(value) && length(value) > 0 && !all(value == "")) {
              rv$demo_data[[dem]] <- value
              page_data[[dem]] <- value
              logger(sprintf("Saved demographic %s: %s", dem, substr(as.character(value), 1, 20)))
            }
          }
          
          # Update session dataset (if function is available)
          if (length(page_data) > 0 && exists("update_session_dataset", mode = "function")) {
            tryCatch({
              update_session_dataset("demographics", page_data, stage = rv$stage, current_page = rv$current_page, session = session)
              logger("Updated session dataset with demographic data", level = "DEBUG")
            }, error = function(e) {
              logger(sprintf("Failed to update session dataset with demographics: %s", e$message), level = "WARNING")
            })
          }
        }
        
        # Collect item responses from current page
        if (current_page$type == "items") {
          if (!is.null(item_bank)) {
            page_data <- list()
            current_page_num <- rv$current_page %||% 1
            page_id <- current_page$id %||% paste0("page_", current_page_num)
            # Pages whose items were chosen at render time (adaptive, or a
            # function such as a booklet draw) are read from the page cache
            if (is.null(current_page$item_indices) ||
                is.function(current_page$item_indices) ||
                identical(current_page$item_indices, "adaptive")) {
              if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION DEBUG: Adaptive page", page_id, "\n")
              if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION DEBUG: page_selected_items available:", !is.null(session$userData$page_selected_items), "\n")
              if (!is.null(session$userData$page_selected_items)) {
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION DEBUG: Cached pages:", names(session$userData$page_selected_items), "\n")
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION DEBUG: page_id cache:", session$userData$page_selected_items[[page_id]], "\n")
              }
              
              if (!is.null(session$userData$page_selected_items) && !is.null(session$userData$page_selected_items[[page_id]])) {
                item_indices_to_collect <- session$userData$page_selected_items[[page_id]]
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Using cached item selection for page", page_id, "-> item", item_indices_to_collect, "\n")
                logger(sprintf("Using cached item selection for page %s: items %s", page_id, paste(item_indices_to_collect, collapse = ", ")))
              } else if (!is.null(rv$administered) && length(rv$administered) > 0) {
                # Fallback: get the last administered item
                item_indices_to_collect <- tail(rv$administered, 1)
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Using last administered item as fallback:", item_indices_to_collect, "\n")
                logger(sprintf("Using last administered item as fallback: item %d", item_indices_to_collect))
              } else {
                item_indices_to_collect <- integer(0)
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: ERROR - No item found for adaptive page!\n")
                logger("WARNING: No item found to collect response for adaptive page")
              }
            } else {
              item_indices_to_collect <- current_page$item_indices
              if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Using fixed item_indices:", paste(item_indices_to_collect, collapse=", "), "\n")
            }
            
            if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Items to collect:", paste(item_indices_to_collect, collapse=", "), "\n")
            
            # Copy items recorded in session$userData$administered (at render
            # time) into rv$administered, which the results use
            if (!is.null(session$userData$administered) && length(session$userData$administered) > 0) {
              if (is.null(rv$administered)) rv$administered <- integer(0)
              # Add any items from session that aren't in rv yet
              new_items <- setdiff(session$userData$administered, rv$administered)
              if (length(new_items) > 0) {
                rv$administered <- c(rv$administered, new_items)
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Synced", length(new_items), "items from session$userData to rv$administered\n")
              }
            }
            
            for (idx in item_indices_to_collect) {
              # MUST match UI rendering logic: item_id <- item$id %||% paste0("item_", actual_idx)
              item <- item_bank[idx, ]
              item_id <- item$id %||% paste0("item_", idx)
              input_id <- .inrep_make_page_item_input_id(page_id, item_id)
              response_key <- .inrep_make_page_item_response_key(page_id, item_id)
              value <- input[[input_id]]
              
              if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: Checking idx", idx, "item_id", item_id, "input_id", input_id, "value", value, "\n")
              
              if (!is.null(value) && value != "") {
                rv$item_responses[[response_key]] <- value
                rv$item_responses[[item_id]] <- value
                rv$responses[idx] <- as.numeric(value)
                page_data[[response_key]] <- as.numeric(value)
                
                # Update rv$administered during response collection (not during rendering)
                if (is.null(rv$administered)) rv$administered <- integer(0)
                if (!idx %in% rv$administered) {
                  rv$administered <- c(rv$administered, idx)
                }
                
                logger(sprintf("Saved item response %d: %s", idx, value))
              } else {
                if (isTRUE(getOption("inrep.debug", FALSE))) cat("RESPONSE COLLECTION: No value found for input_id", item_id, "\n")
              }
            }
            
            # Update session dataset
            if (length(page_data) > 0) {
                              if (exists("update_session_dataset", mode = "function")) {
                  tryCatch({
                    update_session_dataset("items", page_data, stage = rv$stage, current_page = rv$current_page, session = session)
                    logger("Updated session dataset with item responses", level = "DEBUG")
                  }, error = function(e) {
                    logger(sprintf("Failed to update session dataset with item responses: %s", e$message), level = "WARNING")
                  })
                }
            }
          }
        }
        
        # Collect data from other custom page types
        if (current_page$type != "demographics" && current_page$type != "items") {
          page_data <- list()
          page_id <- current_page$id %||% paste0("page_", rv$current_page)
          
          # Inputs listed in current_page$input_fields (id custom_<page>_<field>)
          if (!is.null(current_page$input_fields)) {
            for (field in current_page$input_fields) {
              field_id <- paste0("custom_", page_id, "_", field)
              value <- input[[field_id]]
              # value may be a vector (checkbox group); `value != ""` alone
              # fails in if() for length > 1
              if (!is.null(value) && length(value) > 0 && !all(value == "")) {
                page_data[[field]] <- value
              }
            }
          }
          
          # Update session dataset
          if (length(page_data) > 0) {
                          if (exists("update_session_dataset", mode = "function")) {
                tryCatch({
                  update_session_dataset("custom_page", page_data, page_id = page_id, stage = rv$stage, current_page = rv$current_page, session = session)
                  logger("Updated session dataset with custom page data", level = "DEBUG")
                }, error = function(e) {
                  logger(sprintf("Failed to update session dataset with custom page data: %s", e$message), level = "WARNING")
                })
              }
          }
        }
        
        # Call completion handler for ALL page types (custom, demographics, items, etc.)
        run_page_completion_handler(current_page)

        # Copy demo_<name> inputs on custom pages into rv$demo_data when the
        # field is still empty (for pages whose completion_handler does not
        # store them).
        if (!is.null(config$demographics) && length(config$demographics) > 0) {
          if (is.null(rv$demo_data) || !is.list(rv$demo_data)) {
            rv$demo_data <- stats::setNames(
              as.list(rep(NA, length(config$demographics))),
              config$demographics
            )
          }
          for (dem_name in config$demographics) {
            input_id <- paste0("demo_", dem_name)
            val <- tryCatch(input[[input_id]], error = function(e) NULL)
            if (!is.null(val) && !identical(val, "")) {
              current_val <- rv$demo_data[[dem_name]]
              # Only overwrite if the current value is missing / empty
              is_current_empty <- is.null(current_val) ||
                (length(current_val) == 1 && (is.na(current_val) || trimws(as.character(current_val)) == ""))
              if (is_current_empty) {
                rv$demo_data[[dem_name]] <- trimws(as.character(val))
                logger(sprintf("Auto-collected demo field '%s' = '%s' from input", dem_name, trimws(as.character(val))), level = "DEBUG")
              }
            }
          }
          # Also sync participant_code from common demographic fields
          for (code_field in c("Teilnahme_Code", "participant_code", "code", "Code")) {
            if (!is.null(rv$demo_data[[code_field]]) &&
                !is.na(rv$demo_data[[code_field]]) &&
                nchar(trimws(as.character(rv$demo_data[[code_field]]))) > 0) {
              rv$participant_code <- trimws(as.character(rv$demo_data[[code_field]]))
              break
            }
          }
        }
        
                  # Log page time before moving
          if (exists("log_page_time") && exists("update_page_start_time")) {
            tryCatch({
              current_page_id <- paste0("page_", rv$current_page)
              time_spent <- as.numeric(difftime(Sys.time(), session$userData$logging_data$current_page_start, units = "secs"))
              log_page_time(current_page_id, time_spent, session = session)
            }, error = function(e) {
              logger(sprintf("Failed to log page time: %s", e$message), level = "WARNING")
            })
          }
          
                  # Move to next page immediately - CSS handles the transition
          old_page <- rv$current_page
          rv$current_page <- rv$current_page + 1
          
          # Skip over any pages marked as skipped (e.g., adaptive pages when prerequisites not met)
          if (!is.null(rv$skipped_pages) && length(rv$skipped_pages) > 0) {
            while (rv$current_page %in% rv$skipped_pages && rv$current_page <= rv$total_pages) {
              rv$current_page <- rv$current_page + 1
              logger(sprintf("Skipping page %d (marked as skipped)", rv$current_page - 1))
            }
          }
          
          logger(sprintf("Moving to page %d of %d", rv$current_page, rv$total_pages))
          
          # Apply language preference when moving FROM page 1 (language selection page)
          # ONLY if user clicked a language button in THIS session (not from old sessions)
          # DO NOT call current_language() as it triggers page re-render
          if (old_page == 1 && !is.null(session$userData$language)) {
            stored_lang <- session$userData$language

             if (stored_lang %in% c("en", "de") && !identical(rv$language, stored_lang)) {
              # Only update rv$language when it actually changes to avoid double re-render
              rv$language <- stored_lang
              cat("Applied language preference when leaving page 1:", stored_lang, "\n")
            }
          }
          
          # Log page switch and update start time
          if (exists("update_page_start_time")) {
            tryCatch({
              new_page_id <- paste0("page_", rv$current_page)
              update_page_start_time(new_page_id, session = session)
            }, error = function(e) {
              logger(sprintf("Failed to update page start time: %s", e$message), level = "WARNING")
            })
          }
          
          # Scroll to top of page when navigating to next page (enhanced for mobile/app)
          scroll_to_top_enhanced()
          
          # Additional browser-specific scroll fix
          if (requireNamespace("shinyjs", quietly = TRUE)) {
            shinyjs::runjs("
              setTimeout(function() {
                window.scrollTo(0, 0);
                document.documentElement.scrollTop = 0;
                document.body.scrollTop = 0;
              }, 50);
            ")
          }
      }
    })
    
    shiny::observeEvent(input$prev_page, {
      if (rv$stage == "custom_page_flow" && rv$current_page > 1) {
        # Clear any validation errors when going back
        output$validation_errors <- shiny::renderUI({ NULL })
        
        # Log page time before moving back
        if (exists("log_page_time") && exists("update_page_start_time")) {
          tryCatch({
            current_page_id <- paste0("page_", rv$current_page)
            time_spent <- as.numeric(difftime(Sys.time(), session$userData$logging_data$current_page_start, units = "secs"))
            log_page_time(current_page_id, time_spent, session = session)
          }, error = function(e) {
            logger(sprintf("Failed to log page time: %s", e$message), level = "WARNING")
          })
        }
        
                  # Move to previous page immediately - CSS handles the transition
          old_page <- rv$current_page
          new_page <- rv$current_page - 1
          
          # Skip over any pages marked as skipped (e.g., adaptive pages when prerequisites not met)
          if (!is.null(rv$skipped_pages) && length(rv$skipped_pages) > 0) {
            while (new_page %in% rv$skipped_pages && new_page > 1) {
              logger(sprintf("Skipping backwards over page %d (was skipped during forward navigation)", new_page))
              new_page <- new_page - 1
            }
          }
          
          rv$current_page <- new_page
          logger(sprintf("Moving back to page %d of %d", rv$current_page, rv$total_pages))
          
          # When moving TO page 1, don't apply language changes to prevent loops
          if (rv$current_page == 1) {
            cat("Moved back to page 1 - language switching handled by page itself\n")
          }
          
          # Log page switch and update start time
          if (exists("update_page_start_time")) {
            tryCatch({
              new_page_id <- paste0("page_", rv$current_page)
              update_page_start_time(new_page_id, session = session)
            }, error = function(e) {
              logger(sprintf("Failed to update page start time: %s", e$message), level = "WARNING")
            })
          }
          
          # Scroll to top of page when navigating to previous page (enhanced for mobile/app)
          scroll_to_top_enhanced()
          
          # Additional browser-specific scroll fix
          if (requireNamespace("shinyjs", quietly = TRUE)) {
            shinyjs::runjs("
              setTimeout(function() {
                window.scrollTo(0, 0);
                document.documentElement.scrollTop = 0;
                document.body.scrollTop = 0;
              }, 50);
            ")
          }
      }
    })
    
    shiny::observeEvent(input$submit_study, {
      if (rv$stage == "custom_page_flow") {
        # Prevent duplicate submission loops on final pages.
        if (isTRUE(rv$submission_in_progress)) {
          logger("Duplicate custom-flow submit detected; ignoring.", level = "WARNING")
          return()
        }
        rv$submission_in_progress <- TRUE
        on.exit({ rv$submission_in_progress <- FALSE }, add = TRUE)

        # Identify results pages (supports multi-part results sections)
        results_indices <- which(vapply(config$custom_page_flow, function(p) identical(p$type, "results"), logical(1)))
        first_results_idx <- if (length(results_indices) > 0) results_indices[1] else length(config$custom_page_flow)
        last_results_idx <- if (length(results_indices) > 0) results_indices[length(results_indices)] else length(config$custom_page_flow)

        # Validate final page before submission
        validation_passed <- TRUE
        
        # First check built-in validation
        if (exists("validate_page_progression")) {
          # Pass item_bank and current language in config for validation
          config_with_items <- config
          config_with_items$item_bank <- item_bank
          config_with_items$current_language <- rv$language
          validation <- validate_page_progression(rv$current_page, input, config_with_items)
          if (!validation$valid) {
            output$validation_errors <- shiny::renderUI({
              current_lang <- rv$language %||% config$language %||% "de"
              show_validation_errors(validation$errors, language = current_lang)
            })
            validation_passed <- FALSE
          }
        }
        
        # Then check custom validation function if provided
        if (validation_passed && !is.null(config$validation_function) && is.function(config$validation_function)) {
          tryCatch({
            # Get current page info for custom validation
            current_page <- config$custom_page_flow[[rv$current_page]]
            page_id <- current_page$id %||% paste0("page_", rv$current_page)
            
            # Call custom validation function
            custom_validation <- config$validation_function(page_id, input, rv)
            
            if (!is.null(custom_validation) && !custom_validation$valid) {
              # Show custom validation error messages
              output$validation_errors <- shiny::renderUI({
                current_lang <- rv$language %||% config$language %||% "de"
                # Use language-aware fallback message
                error_message <- custom_validation$message %||% get_validation_fallback_message(current_lang)
                show_validation_errors(error_message, language = current_lang)
              })
              
              validation_passed <- FALSE
            }
          }, error = function(e) {
            logger(sprintf("Error in custom validation function: %s", e$message), level = "WARNING")
            # Continue with validation passed if custom validation fails
          })
        }
        
        if (!validation_passed) {
          return()  # Don't proceed if validation fails
        }
        
        # Collect current page data (could be demographics or items)
        current_page <- config$custom_page_flow[[rv$current_page]]
        
        if (current_page$type == "demographics") {
          # Same rule as for "next": page fields, else config$demographics
          demo_vars <- current_page$demographics %||% config$demographics
          page_data <- list()
          for (dem in demo_vars) {
            input_id <- paste0("demo_", dem)
            value <- input[[input_id]]
            if (!is.null(value) && length(value) > 0 && !all(value == "")) {
              rv$demo_data[[dem]] <- value
              page_data[[dem]] <- value
            }
          }
          
          # Update session dataset with final demographic data
          if (length(page_data) > 0 && exists("update_session_dataset", mode = "function")) {
            tryCatch({
              update_session_dataset("demographics", page_data, stage = rv$stage, current_page = rv$current_page, session = session)
            }, error = function(e) {
              logger(sprintf("Failed to update session dataset with final demographics: %s", e$message), level = "WARNING")
            })
          }
        } else if (current_page$type == "items") {
          # Collect item responses from final page
          if (!is.null(item_bank)) {
            page_data <- list()
            current_page_num <- rv$current_page %||% 1
            page_id <- current_page$id %||% paste0("page_", current_page_num)
            # Pages whose items were chosen at render time (adaptive, or a
            # function such as a booklet draw) are read from the page cache
            if (is.null(current_page$item_indices) ||
                is.function(current_page$item_indices) ||
                identical(current_page$item_indices, "adaptive")) {
              if (!is.null(session$userData$page_selected_items) && !is.null(session$userData$page_selected_items[[page_id]])) {
                item_indices_to_collect <- session$userData$page_selected_items[[page_id]]
                logger(sprintf("Using cached item selection for final page %s: items %s", page_id, paste(item_indices_to_collect, collapse = ", ")))
              } else if (!is.null(rv$administered) && length(rv$administered) > 0) {
                # Fallback: get the last administered item
                item_indices_to_collect <- tail(rv$administered, 1)
                logger(sprintf("Using last administered item as fallback for final page: item %d", item_indices_to_collect))
              } else {
                item_indices_to_collect <- integer(0)
                logger("WARNING: No item found to collect response for final adaptive page")
              }
            } else {
              item_indices_to_collect <- current_page$item_indices
            }
            
            for (idx in item_indices_to_collect) {
              if (idx <= nrow(item_bank)) {
                item <- item_bank[idx, ]
                item_id <- item$id %||% paste0("item_", idx)
                input_id <- .inrep_make_page_item_input_id(page_id, item_id)
                input_candidates <- c(input_id, item_id, paste0("item_", item_id))
                value <- NULL
                found_input <- NA_character_
                for (iid in input_candidates) {
                  if (!is.null(input[[iid]]) && input[[iid]] != "") {
                    value <- input[[iid]]
                    found_input <- iid
                    break
                  }
                }
                if (!is.null(value) && value != "") {
                  response_key <- .inrep_make_page_item_response_key(page_id, item_id)
                  rv$responses[idx] <- as.numeric(value)
                  page_data[[response_key]] <- as.numeric(value)
                  # also store legacy/keyed entry
                  rv$item_responses[[response_key]] <- value
                  rv$item_responses[[paste0("item_", item_id)]] <- value
                  rv$item_responses[[item_id]] <- value
                  
                  logger(sprintf("Saved final page item response %d (id: %s) from input %s: %s", idx, item_id, found_input, value))
                }
              }
            }
            
            # Update session dataset with final item responses
            if (length(page_data) > 0 && exists("update_session_dataset", mode = "function")) {
              tryCatch({
                update_session_dataset("items", page_data, stage = rv$stage, current_page = rv$current_page, session = session)
              }, error = function(e) {
                logger(sprintf("Failed to update session dataset with final item responses: %s", e$message), level = "WARNING")
              })
            }
          }
        }
        
        # Final page before the results: run its completion_handler as "next" does
        if (!identical(current_page$type, "results")) run_page_completion_handler(current_page)

        # rv$responses is indexed by item bank row; NA marks items without a
        # response, so NAs are kept to preserve the indexing.
        all_responses <- rv$responses

        logger(sprintf("Study completed with %d total responses (including NAs)", length(all_responses)))
        logger(sprintf("Non-NA responses: %d", sum(!is.na(all_responses))))
        logger(sprintf("Response indices with data: %s", paste(which(!is.na(all_responses)), collapse=", ")))
        
        # With config$fixed_items, the vector is cut or padded to one slot per
        # fixed item. Note: this keeps bank positions 1..n_fixed, which are
        # the fixed items only if fixed_items is 1:n_fixed.
        n_fixed <- length(config$fixed_items %||% integer(0))
        if (n_fixed > 0 && length(all_responses) != n_fixed) {
          logger(sprintf("Expected %d responses but got %d; padding/truncating to %d.", n_fixed, length(all_responses), n_fixed), level = "WARNING")
          all_responses <- c(all_responses, rep(NA, max(0, n_fixed - length(all_responses))))[seq_len(n_fixed)]
        }
        
        # If we're already on a results page, the button is the final "finish"
        # action and does not reset navigation.
        if (!is.null(current_page$type) && identical(current_page$type, "results")) {
          # On the last results page the participant is done: close right away.
          # Setting the countdown to 0 lets the auto-close observer run its
          # close-tab script and end the session (or the app, with
          # options(inrep.stop_app_on_finish = TRUE)). The automatic countdown
          # shown on the page still closes it if nobody clicks.
          if (isTRUE(rv$current_page == last_results_idx)) {
            rv$countdown_time <- 0
            rv$auto_close_timer_active <- TRUE
            logger("Finish clicked on the last results page - closing now", level = "INFO")
          }
          return()
        }

        # Build rv$cat_result for the results pages (also when a
        # results_processor is given). First copy any demo_<name> inputs that
        # are still missing from rv$demo_data.
        if (!is.null(config$demographics) && length(config$demographics) > 0) {
          if (is.null(rv$demo_data) || !is.list(rv$demo_data)) {
            rv$demo_data <- stats::setNames(
              as.list(rep(NA, length(config$demographics))),
              config$demographics
            )
          }
          for (dem_name in config$demographics) {
            input_id <- paste0("demo_", dem_name)
            val <- tryCatch(input[[input_id]], error = function(e) NULL)
            if (!is.null(val) && !identical(trimws(as.character(val)), "")) {
              current_val <- rv$demo_data[[dem_name]]
              is_current_empty <- is.null(current_val) ||
                (length(current_val) == 1 && (is.na(current_val) || trimws(as.character(current_val)) == ""))
              if (is_current_empty) {
                rv$demo_data[[dem_name]] <- trimws(as.character(val))
                logger(sprintf("Collected demo field '%s' = '%s' at submit", dem_name, trimws(as.character(val))), level = "INFO")
              }
            }
          }
          # Warn about any still-missing demographics (respecting exclude_from_recording)
          excluded_fields <- config$exclude_from_recording %||% character(0)
          for (dem_name in config$demographics) {
            if (dem_name %in% excluded_fields) next
            v <- rv$demo_data[[dem_name]]
            if (is.null(v) || (length(v) == 1 && (is.na(v) || trimws(as.character(v)) == ""))) {
              logger(sprintf("WARNING: Demographic field '%s' is still empty at results stage. Check that 'demo_%s' input exists in your custom pages.", dem_name, dem_name), level = "WARNING")
            }
          }
        }

        # administered is every bank position (1..n), not only the items
        # shown; responses is aligned with it and holds NA for items not
        # shown or not answered.
        rv$cat_result <- list(
          theta = rv$current_ability,
          se = rv$current_se,
          administered = 1:length(all_responses),
          responses = all_responses,
          response_times = rv$response_times,
          demo_data = rv$demo_data
        )
        
        # Update session dataset with final results
        tryCatch({
          results_data <- list(
            theta = rv$current_ability,
            se = rv$current_se,
            administered = 1:length(all_responses)
          )
          if (exists("update_session_dataset", mode = "function")) {
            update_session_dataset("results", results_data, stage = "results", current_page = length(config$custom_page_flow), session = session)
            logger("Updated session dataset with final results", level = "INFO")
          }
        }, error = function(e) {
          logger(sprintf("Failed to update session dataset with final results: %s", e$message), level = "WARNING")
        })
        
        # Route into the FIRST results page (supports multiple results pages)
        rv$current_page <- first_results_idx
        rv$stage <- "custom_page_flow"  # Stay in custom flow to show results pages
        
        # Scroll to top of page when showing results (enhanced for mobile/app)
        scroll_to_top_enhanced()
        
        # Auto-close timer is started on the last results page when the user finishes.
        # (See the auto-close countdown observer.)
        
        logger("Study completed via custom page flow")
      }
    })
    
    shiny::observeEvent(input$start_test, {
      # Log demographic submission
      if (session_save && exists("log_session_event") && is.function(log_session_event)) {
        tryCatch({
          log_session_event(
            event_type = "demographics_submitted",
            message = "Demographics submitted by participant",
            details = list(
              demographics = sapply(seq_along(config$demographics), function(i) {
                val <- input[[paste0("demo_", i)]]
                if (is.null(val) || is.na(val) || val == "") return(NA)
                return(val)
              }),
              timestamp = Sys.time()
            )
          )
        }, error = function(e) {
          logger(sprintf("Failed to log demographics: %s", e$message), level = "WARNING")
        })
      }
      
      rv$demo_data <- base::sapply(base::seq_along(config$demographics), function(i) {
        val <- input[[base::paste0("demo_", i)]]
        dem <- config$demographics[i]
        input_type <- config$input_types[[dem]]
        
        if (input_type == "numeric") {
          if (base::is.null(val) || base::is.na(val) || val == "") {
            return(NA)
          }
          if (!base::is.numeric(val) || val < 1 || val > 150) {
            rv$error_message <- ui_labels$age_error
            logger(base::sprintf("Invalid age input: %s", val))
            return(NA)
          }
          return(val)
        } else {
          # Check for language-specific placeholder text
          current_lang <- rv$language %||% config$language %||% "de"
          labels <- get_language_labels(current_lang)
          placeholder_text <- labels$please_select
          if (base::is.null(val) || base::is.na(val) || val == "" || val == placeholder_text) {
            return(NA)
          }
          if (base::is.character(val)) {
            val <- base::trimws(base::gsub("[<>\"&]", "", val))
          }
          return(val)
        }
      })
      base::names(rv$demo_data) <- config$demographics
      
      # Update session dataset with demographic data
      tryCatch({
        # Convert to list format for session dataset
        if (exists("update_session_dataset", mode = "function")) {
          demo_list <- as.list(rv$demo_data)
          update_session_dataset("demographics", demo_list, stage = rv$stage, current_page = rv$current_page, session = session)
          logger("Updated session dataset with demographic data", level = "DEBUG")
        }
      }, error = function(e) {
        logger(sprintf("Failed to update session dataset with demographics: %s", e$message), level = "WARNING")
      })
      
      # More flexible demographic validation - allow some empty fields
      non_age_dems <- base::setdiff(config$demographics, "Age")
      if (base::length(non_age_dems) > 0) {
        # Check if at least N non-age demographics are filled
        filled_dems <- base::sapply(non_age_dems, function(dem) {
          !base::is.na(rv$demo_data[dem]) && rv$demo_data[dem] != ""
        })
        
        min_required <- config$min_required_non_age_demographics %||% 1
        if (base::sum(filled_dems) < min_required) {
          rv$error_message <- ui_labels$demo_error
          logger(base::sprintf("Insufficient non-age demographics: %d < required %d", base::sum(filled_dems), min_required))
          return()
        }
      }
      
      rv$error_message <- NULL
      
      # Custom or standard flow navigation
      if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
        # Custom flow: get next stage from configuration
        next_stage <- config$custom_study_flow$page_sequence[2] %||% "assessment"
        rv$stage <- next_stage
        logger(sprintf("Custom flow: proceeding to %s stage", next_stage))
      } else {
        # Standard flow: proceed to assessment (demographics already shown)
        rv$stage <- "assessment"
        logger("Standard flow: proceeding to assessment stage after demographics")
      }
      
      # Initialize first item for assessment
      if (!config$adaptive) {
        # For non-adaptive mode, start with first item
        if (!base::is.null(config$fixed_items)) {
          rv$current_item <- config$fixed_items[1]
        } else {
          rv$current_item <- 1
        }
        logger(sprintf("Non-adaptive mode: Starting with item %s", rv$current_item))
      } else {
        # For adaptive mode, select first item
        temp_rv <- list(
          administered = base::integer(0),
          responses = base::numeric(0),
          current_ability = config$theta_prior[1] %||% 0,
          current_se = config$theta_prior[2] %||% 1
        )
        first_item <- if (isTRUE(config$fast_item_selection)) {
          inrep::fast_select_next_item(temp_rv, item_bank, config)
        } else {
          inrep::select_next_item(temp_rv, item_bank, config)
        }
        rv$current_item <- first_item
        logger(sprintf("Adaptive mode: Starting with item %s", first_item))
      }
      # Start the response timer for the first item. Without this, a study that
      # starts on the demographics page (show_introduction = FALSE) had
      # rv$start_time = NULL, the response time computation failed and the
      # response was not stored.
      rv$start_time <- base::Sys.time()
    })

    shiny::observeEvent(input$begin_test, {
      # Log test start
      if (session_save && exists("log_session_event") && is.function(log_session_event)) {
        tryCatch({
          log_session_event(
            event_type = "test_started",
            message = "Assessment test started",
            details = list(
              start_time = Sys.time(),
              demographics = rv$demo_data,
              timestamp = Sys.time()
            )
          )
        }, error = function(e) {
          logger(sprintf("Failed to log test start: %s", e$message), level = "WARNING")
        })
      }
      
      # After introduction, go to demographics if provided, otherwise start assessment
      rv$stage <- if (!is.null(config$demographics) && length(config$demographics) > 0) {
        "demographics"
      } else {
        "assessment"
      }
      rv$start_time <- base::Sys.time()
      
      # Scroll to top of page when transitioning
      scroll_to_top_enhanced()
      
      # Initialize item selection for assessment stage
      if (!config$adaptive) {
        # For non-adaptive mode, start with first item
        if (!base::is.null(config$fixed_items)) {
          rv$current_item <- config$fixed_items[1]
        } else {
          rv$current_item <- 1
        }
        logger(sprintf("Non-adaptive mode: Starting with item %s", rv$current_item))
      } else {
        # For adaptive mode, select first item
        # Initialize rv with minimal required values for first item selection
        temp_rv <- list(
          administered = base::integer(0),
          responses = base::numeric(0),
          current_ability = config$theta_prior[1] %||% 0,
          current_se = config$theta_prior[2] %||% 1
        )
        first_item <- if (isTRUE(config$fast_item_selection)) {
          inrep::fast_select_next_item(temp_rv, item_bank, config)
        } else {
          inrep::select_next_item(temp_rv, item_bank, config)
        }
        rv$current_item <- first_item
        logger(sprintf("Adaptive mode: Starting with item %s", first_item))
      }
    })
    
    # Button "proceed_from_custom_instructions" (R/ui_components.R). Note:
    # page_content has no "custom_instructions" or "items" stage, so the
    # stages set here can render an empty page.
    shiny::observeEvent(input$proceed_from_custom_instructions, {
      if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
        # Get next stage from custom flow configuration
        current_index <- which(config$custom_study_flow$page_sequence == "custom_instructions")
        if (length(current_index) > 0 && current_index < length(config$custom_study_flow$page_sequence)) {
          next_stage <- config$custom_study_flow$page_sequence[current_index + 1]
          rv$stage <- next_stage
          logger(sprintf("Custom flow: proceeding from instructions to %s stage", next_stage))
        } else {
          # Fallback to standard flow - skip demographics if not provided
          rv$stage <- if (!is.null(config$demographics) && length(config$demographics) > 0) {
            "demographics"
          } else {
            "items"
          }
          logger(sprintf("Custom flow: fallback to %s stage", rv$stage))
        }
      } else {
        # Standard flow - skip demographics if not provided
        rv$stage <- if (!is.null(config$demographics) && length(config$demographics) > 0) {
          "demographics"
        } else {
          "items"
        }
        logger(sprintf("Standard flow: proceeding to %s stage", rv$stage))
      }
      

      
      logger("Attempting to select next item...")
      logger(sprintf("rv$current_ability: %s", rv$current_ability))
      logger(sprintf("config$adaptive: %s", config$adaptive))
      logger(sprintf("config$model: %s", config$model))
      logger(sprintf("Item bank columns: %s", paste(names(item_bank), collapse = ", ")))
      
      rv$current_item <- if (isTRUE(config$fast_item_selection)) {
        inrep::fast_select_next_item(rv, item_bank, config)
      } else {
        inrep::select_next_item(rv, item_bank, config)
      }
      if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
        base::tryCatch({
          config$admin_dashboard_hook(list(
            participant_id = study_key %||% config$study_key %||% "unknown",
            progress = (length(rv$administered) / (config$max_items %||% max(1, nrow(item_bank)))) * 100,
            theta = rv$current_ability,
            se = rv$current_se,
            items_administered = rv$administered,
            responses = rv$responses
          ))
        }, error = function(e) {
          logger(base::sprintf("admin_dashboard_hook failed: %s", e$message), level = "WARNING")
        })
      }
      
      logger(sprintf("Item selection result: %s", rv$current_item))
      
      if (is.null(rv$current_item)) {
        logger("Item selection returned NULL; using the first item not yet administered", level = "ERROR")
        available_items <- setdiff(seq_len(nrow(item_bank)), rv$administered)
        if (length(available_items) > 0) {
          rv$current_item <- available_items[1]
          logger(sprintf("Fallback: selected item %d", rv$current_item))
        }
      }
      
      logger("Beginning assessment")
    })
    
    # Response submission in the built-in assessment ----
    shiny::observeEvent(input$submit_response, {
      # Ignore a second click while a submission is processed
      if (rv$submission_in_progress) {
        logger("Double-click detected - ignoring duplicate submission", level = "WARNING")
        return()
      }

      if (is.null(rv$current_item) || rv$stage != "assessment") {
        logger("Invalid submission state - ignoring submission", level = "WARNING")
        return()
      }

      rv$submission_in_progress <- TRUE
      rv$submission_lock_time <- Sys.time()

      # Set to TRUE once the response is stored. If an error occurs before
      # that, the handler stops below and the same item stays on screen.
      response_recorded <- FALSE

      tryCatch({
        if (is.null(input$item_response)) {
          logger("No response selected - resetting submission lock", level = "WARNING")
          rv$submission_in_progress <- FALSE
          current_lang <- rv$language %||% config$language %||% "de"
          labels <- get_language_labels(current_lang)
          rv$error_message <- labels$select_answer
          return()
        }

        if (!config$response_validation_fun(input$item_response)) {
          logger(sprintf("Invalid response submitted for item %d", rv$current_item), level = "WARNING")
          rv$submission_in_progress <- FALSE
          current_lang <- rv$language %||% config$language %||% "de"
          labels <- get_language_labels(current_lang)
          rv$error_message <- labels$select_answer
          return()
        }
        
        rv$error_message <- NULL

        response_time <- base::as.numeric(base::difftime(base::Sys.time(), rv$start_time, units = "secs"))

        # Very fast responses are logged but recorded as given
        if (response_time < 0.2) {
          logger(sprintf("Quick response: item %d (%.3fs)", rv$current_item, response_time), level = "DEBUG")
        }

        item_index <- rv$current_item
        correct_answer <- item_bank$Answer[item_index] %||% NULL
        
        # Score with config$scoring_fun; if it fails, use a fallback
        response_score <- base::tryCatch(
          config$scoring_fun(input$item_response, correct_answer),
          error = function(e) {
            logger(base::sprintf("Scoring function error, using fallback: %s", e$message), level = "WARNING")
            if (config$model == "GRM") {
              as.numeric(input$item_response)
            } else {
              opts <- base::c(item_bank$Option1[item_index], item_bank$Option2[item_index], item_bank$Option3[item_index], item_bank$Option4[item_index])
              opts <- opts[!is.na(opts) & opts != ""]
              if (is.null(correct_answer) || is.na(correct_answer) || !(correct_answer %in% opts)) {
                # No usable key: the first option is treated as the keyed
                # answer. This is an assumption, not information from the bank.
                correct_answer_fallback <- (opts)[1] %||% "1"
                as.numeric(input$item_response == correct_answer_fallback)
              } else {
                as.numeric(input$item_response == correct_answer)
              }
            }
          }
        )
        
        rv$response_times <- base::c(rv$response_times, response_time)
        rv$responses <- base::c(rv$responses, response_score)
        rv$administered <- base::c(rv$administered, item_index)
        response_recorded <- TRUE

        # Correct/incorrect feedback: only with feedback_enabled = TRUE and an
        # Answer key for the item. Rating-scale (GRM) items have no key, so
        # no feedback is shown for them.
        if (isTRUE(config$feedback_enabled)) {
          item_answer <- if ("Answer" %in% names(item_bank)) item_bank$Answer[item_index] else NULL
          if (!is.null(item_answer) && !is.na(item_answer) &&
              nchar(trimws(as.character(item_answer))) > 0) {
            is_correct <- isTRUE(response_score >= 0.5)
            shiny::showNotification(
              ui       = if (is_correct) ui_labels$feedback_correct   %||% "Correct"
                         else            ui_labels$feedback_incorrect %||% "Incorrect",
              type     = if (is_correct) "message" else "warning",
              duration = 2.5,
              session  = session
            )
          }
        }

        if (session_save && exists("log_session_event") && is.function(log_session_event)) {
          tryCatch({
            log_session_event(
              event_type = "response_submitted",
              message = "Response submitted by participant",
              details = list(
                item_index = item_index,
                response = input$item_response,
                response_score = response_score,
                response_time = response_time,
                current_ability = if (config$adaptive) rv$current_ability else NULL,
                current_se = if (config$adaptive) rv$current_se else NULL,
                items_administered = length(rv$administered),
                timestamp = Sys.time()
              )
            )
          }, error = function(e) {
            logger(sprintf("Failed to log response (non-critical): %s", e$message), level = "WARNING")
          })
        }
        
        logger(sprintf("Response successfully processed for item %d", item_index), level = "INFO")
        
        if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
          base::tryCatch({
            config$admin_dashboard_hook(list(
              participant_id = study_key %||% config$study_key %||% "unknown",
              progress = (length(rv$administered) / (config$max_items %||% max(1, nrow(item_bank)))) * 100,
              theta = rv$current_ability,
              se = rv$current_se,
              items_administered = rv$administered,
              responses = rv$responses
            ))
          }, error = function(e) {
            logger(base::sprintf("admin_dashboard_hook failed: %s", e$message), level = "WARNING")
          })
        }
        
      }, error = function(e) {
        logger(sprintf("Error in response processing: %s", e$message), level = "ERROR")

        if (session_save && exists("emergency_data_preservation") && is.function(emergency_data_preservation)) {
          tryCatch({
            emergency_data_preservation()
            logger("Emergency data preservation completed", level = "INFO")
          }, error = function(preserve_error) {
            logger(sprintf("Emergency data preservation failed: %s", preserve_error$message), level = "ERROR")
          })
        }

        # The old message ("Your response has been saved") was shown also
        # when the response had not been stored.
        if (!response_recorded) {
          rv$error_message <- "Your response could not be processed. Please answer this question again."
        }
        rv$submission_in_progress <- FALSE
      })

      # Response not stored: keep the current item, do not estimate or advance
      if (!response_recorded) {
        rv$submission_in_progress <- FALSE
        return()
      }

      rv$submission_in_progress <- FALSE
      rv$last_submission_time <- Sys.time()

      if (config$adaptive) {
        base::tryCatch({
          ability <- inrep::estimate_ability(rv, item_bank, config)
          rv$current_ability <- ability$theta
          rv$current_se <- ability$se
          logger(base::sprintf("Estimated ability: theta=%.2f, se=%.3f", ability$theta, ability$se))
          rv$theta_history <- base::c(rv$theta_history, rv$current_ability)
          rv$se_history <- base::c(rv$se_history, rv$current_se)
          
          if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
            base::tryCatch({
              config$admin_dashboard_hook(list(
            participant_id = study_key %||% config$study_key %||% "unknown",
            progress = (length(rv$administered) / (config$max_items %||% max(1, nrow(item_bank)))) * 100,
            theta = rv$current_ability,
            se = rv$current_se,
                items_administered = rv$administered,
                responses = rv$responses,
                theta_history = rv$theta_history,
                se_history = rv$se_history
              ))
            }, error = function(e) {
              logger(base::sprintf("admin_dashboard_hook failed: %s", e$message), level = "WARNING")
            })
          }
        }, error = function(e) {
          # Keep the previous theta and SE. The former fallback used the mean
          # of the raw item scores as theta and their SD / sqrt(n) as SE,
          # which are not on the theta scale and were then compared with
          # min_SEM by the stopping rule.
          logger(base::sprintf("Ability estimation failed; keeping the previous estimate: %s", e$message), level = "WARNING")
        })
      }

      # Data preservation is handled by observeEvent(rv$responses).

      if (rv$submission_in_progress) {
        rv$submission_in_progress <- FALSE
      }

      # Stop or select the next item
      base::tryCatch({
        if (base::tryCatch({
          check_stopping_criteria()
        }, error = function(e) {
          logger(sprintf("Stopping criteria check failed, continuing assessment: %s", e$message), level = "WARNING")
          FALSE  # Continue assessment if stopping criteria fails
        })) {
          rv$cat_result <- base::list(
            theta = if (config$adaptive) rv$current_ability else base::mean(rv$responses, na.rm = TRUE),
            se = if (config$adaptive) rv$current_se else NULL,
            responses = rv$responses,
            administered = rv$administered,
            response_times = rv$response_times
          )
          rv$stage <- "results"
          logger("Test completed, proceeding to results")
        
        # Log test completion
        if (session_save && exists("log_session_event") && is.function(log_session_event)) {
          tryCatch({
            log_session_event(
              event_type = "test_completed",
              message = "Assessment test completed",
              details = list(
                final_theta = if (config$adaptive) rv$current_ability else NULL,
                final_se = if (config$adaptive) rv$current_se else NULL,
                total_items = length(rv$administered),
                total_time = as.numeric(difftime(Sys.time(), rv$session_start, units = "secs")),
                completion_reason = "stopping_criteria_met",
                timestamp = Sys.time()
              )
            )
          }, error = function(e) {
            logger(sprintf("Failed to log test completion: %s", e$message), level = "WARNING")
          })
        }
        
        run_storage_pipeline(trigger = "assessment_complete_stopping", force = TRUE, include_cloud = TRUE)
        logger("Final assessment data preserved", level = "INFO")
      } else {
        next_item_result <- base::tryCatch({
          if (isTRUE(config$fast_item_selection)) {
            inrep::fast_select_next_item(rv, item_bank, config)
          } else {
            inrep::select_next_item(rv, item_bank, config)
          }
        }, error = function(e) {
          logger(sprintf("Next item selection failed; using the first item not yet administered: %s", e$message), level = "WARNING")
          remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
          if (length(remaining_items) > 0) {
            remaining_items[1]
          } else {
            NULL
          }
        })
        
        rv$current_item <- next_item_result
        
        if (base::is.null(rv$current_item)) {
          rv$cat_result <- base::list(
            theta = if (config$adaptive) rv$current_ability else base::mean(rv$responses, na.rm = TRUE),
            se = if (config$adaptive) rv$current_se else NULL,
            responses = rv$responses,
            administered = rv$administered,
            response_times = rv$response_times
          )
          rv$stage = "results"
          logger("No more items available, proceeding to results")
          
          # Update session dataset with final results
          tryCatch({
            results_data <- list(
              theta = rv$current_ability,
              se = rv$current_se,
              administered = rv$administered
            )
            if (exists("update_session_dataset", mode = "function")) {
              update_session_dataset("results", results_data, stage = "results", current_page = rv$current_page, session = session)
              logger("Updated session dataset with assessment results", level = "INFO")
            }
          }, error = function(e) {
            logger(sprintf("Failed to update session dataset with assessment results: %s", e$message), level = "WARNING")
          })
          
          # Scroll to top of page when showing results
          scroll_to_top_enhanced()
          
          # Log test completion
          if (session_save && exists("log_session_event") && is.function(log_session_event)) {
            tryCatch({
              log_session_event(
                event_type = "test_completed",
                message = "Assessment test completed (no more items)",
                details = list(
                  final_theta = if (config$adaptive) rv$current_ability else NULL,
                  final_se = if (config$adaptive) rv$current_se else NULL,
                  total_items = length(rv$administered),
                  total_time = as.numeric(difftime(Sys.time(), rv$session_start, units = "secs")),
                  completion_reason = "no_more_items",
                  timestamp = Sys.time()
                )
              )
            }, error = function(e) {
              logger(sprintf("Failed to log test completion: %s", e$message), level = "WARNING")
            })
          }
          
          run_storage_pipeline(trigger = "assessment_complete_no_items", force = TRUE, include_cloud = TRUE)
          logger("Final assessment data preserved", level = "INFO")
        } else {
          rv$start_time <- base::Sys.time()
          if (config$response_ui_type == "slider") {
            shiny::updateSliderInput(session, "item_response", value = base::min(base::as.numeric(base::unlist(base::strsplit(item_bank$ResponseCategories[rv$current_item], ",")))))
          } else if (config$response_ui_type == "dropdown") {
            shiny::updateSelectInput(session, "item_response", selected = NULL)
          } else {
            if (available_packages$shinyWidgets) {
              shinyWidgets::updateRadioGroupButtons(session, "item_response", selected = base::character(0))
            } else {
              shiny::updateRadioButtons(session, "item_response", selected = base::character(0))
            }
          }
        }
      }
      
      }, error = function(e) {
        # Errors in stopping or item selection: stay in the assessment
        logger(sprintf("Error after response processing: %s", e$message), level = "ERROR")

        rv$submission_in_progress <- FALSE
        rv$error_message <- NULL
        rv$stage <- "assessment"

        scroll_to_top_enhanced()

        if (is.null(rv$current_item)) {
          remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
          if (length(remaining_items) > 0) {
            rv$current_item <- remaining_items[1]
            logger("Selected the first item not yet administered after an error", level = "WARNING")
          }
        }
      })
    })

    output$submission_status <- shiny::renderUI({
      if (rv$submission_in_progress) {
        shiny::div(
          class = "submission-status",
          style = "color: #007bff; font-weight: bold; margin-top: 10px; padding: 10px; background-color: #f8f9fa; border: 2px solid #007bff; border-radius: 5px;",
          "Processing your response... Please wait."
        )
      } else {
        NULL
      }
    })

    # Error box with recovery buttons. Note: it is only shown when
    # rv$stage == "error", but it is placed in the assessment page and no
    # code sets rv$stage to "error", so it is currently never displayed.
    output$error_boundary <- shiny::renderUI({
      if (!is.null(rv$error_message) && rv$stage == "error") {
        shiny::div(
          class = "error-boundary",
          style = "background-color: #fff3cd; border: 2px solid #ffc107; border-radius: 8px; padding: 15px; margin: 15px 0;",
          shiny::h4("Assessment Paused", style = "color: #856404; margin-top: 0;"),
          shiny::p(rv$error_message, style = "color: #856404; margin-bottom: 15px;"),
          shiny::div(
            style = "display: flex; gap: 10px;",
            shiny::actionButton("auto_recover", "Auto-Recover", class = "btn-warning"),
            shiny::actionButton("manual_recover", "Manual Recovery", class = "btn-info")
          )
        )
      } else {
        NULL
      }
    })
    
    shiny::observeEvent(input$auto_recover, {
      logger("Auto-recovery initiated by user", level = "INFO")

      rv$submission_in_progress <- FALSE
      rv$error_message <- NULL
      rv$stage <- "assessment"

      scroll_to_top_enhanced()

      if (is.null(rv$current_item)) {
        remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
        if (length(remaining_items) > 0) {
          rv$current_item <- remaining_items[1]
          logger("Auto-recovery: selected next item", level = "INFO")
        }
      }
      
      logger("Assessment continuing after auto-recovery", level = "INFO")
    })
    
    # Note: rv$show_recovery_options is not read anywhere
    shiny::observeEvent(input$manual_recover, {
      logger("Manual recovery initiated by user", level = "INFO")

      rv$show_recovery_options <- TRUE
      rv$error_message <- "Select recovery option:"
    })
    
    # "Continue" button of the "error" stage page
    shiny::observeEvent(input$retry_continue, {
      if (session_save && exists("attempt_error_recovery") && is.function(attempt_error_recovery)) {
        tryCatch({
          recovery_result <- attempt_error_recovery()
          if (isTRUE(recovery_result$success)) {
            # There is no "test" stage; "assessment" is the item stage
            rv$stage <- recovery_result$stage %||% "assessment"
            rv$error_message <- NULL
            logger("Error recovery successful, continuing assessment", level = "INFO")
          } else {
            rv$error_message <- "Recovery failed. Please restart the assessment."
            logger("Error recovery failed", level = "ERROR")
          }
        }, error = function(e) {
          rv$error_message <- "Recovery attempt failed. Please restart the assessment."
          logger(sprintf("Recovery attempt error: %s", e$message), level = "ERROR")
        })
      } else {
        rv$stage <- "assessment"
        rv$error_message <- NULL
        logger("Fallback error recovery - returning to assessment", level = "INFO")

        scroll_to_top_enhanced()
      }
    })
    
    # Checked when rv$stage or rv$submission_in_progress changes (not on a
    # timer): release a submission lock older than 10 s, leave an "error"
    # stage after 5 s, and save local data in sessions longer than 1 h.
    check_error_states <- function() {
      if (rv$submission_in_progress && !is.null(rv$submission_lock_time)) {
        lock_duration <- as.numeric(difftime(Sys.time(), rv$submission_lock_time, units = "secs"))
        if (lock_duration > 10) {  # Reset lock after 10 seconds
          logger("Automatic submission lock reset after timeout", level = "WARNING")
          rv$submission_in_progress <- FALSE
          rv$submission_lock_time <- NULL
        }
      }
      
      if (rv$stage == "error" && !is.null(rv$last_submission_time)) {
        error_duration <- as.numeric(difftime(Sys.time(), rv$last_submission_time, units = "secs"))
        if (error_duration > 5) {
          logger("Automatic error recovery - continuing assessment", level = "INFO")
          rv$stage <- "assessment"
          rv$error_message <- NULL

          scroll_to_top_enhanced()

          if (is.null(rv$current_item)) {
            remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
            if (length(remaining_items) > 0) {
              rv$current_item <- remaining_items[1]
              logger("Auto-selected next item for continuation", level = "INFO")
            }
          }
        }
      }
      
      # Note: rv$start_time is reset for every item, so this measures the
      # time on the current item, not the session.
      if (rv$session_active && !is.null(rv$start_time)) {
        session_duration <- as.numeric(difftime(Sys.time(), rv$start_time, units = "secs"))
        if (session_duration > 3600) {
          logger("Long session detected - saving data", level = "INFO")
          run_storage_pipeline(trigger = "health_check", force = TRUE, include_cloud = FALSE)
        }
      }
    }

    shiny::observeEvent(rv$stage, {
      check_error_states()
    }, ignoreInit = TRUE)
    
    shiny::observeEvent(rv$submission_in_progress, {
      check_error_states()
    }, ignoreInit = TRUE)
    
    shiny::observeEvent(input$restart_test, {
      if (session_save && exists("cleanup_session") && is.function(cleanup_session)) {
        tryCatch({
          cleanup_session(save_final_data = TRUE)
        }, error = function(e) {
          logger(sprintf("Session cleanup failed during restart: %s", e$message), level = "WARNING")
        })
      }
      
      # Back to demographics, or to "items" without demographics. Note:
      # page_content has no "items" stage, so the latter shows an empty page.
      rv$stage = if (!is.null(config$demographics) && length(config$demographics) > 0) {
        "demographics"
      } else {
        "items"
      }
      rv$current_ability <- config$theta_prior[1]
      rv$current_se <- config$theta_prior[2]
      
      scroll_to_top_enhanced()
      rv$administered <- base::c()
      rv$responses = base::c()
      rv$response_times = base::c()
      rv$current_item <- NULL
      rv$cat_result <- NULL
      rv$theta_history <- base::c()
      rv$se_history <- base::c()
      rv$item_counter = 0
      rv$error_message <- NULL
      rv$feedback_message <- NULL
      rv$item_info_cache = base::list()
      rv$session_start <- base::Sys.time()
      rv$session_active <- TRUE
      
      if (session_save && exists("log_session_event") && is.function(log_session_event)) {
        tryCatch({
          log_session_event(
            event_type = "test_restarted",
            message = "Assessment test restarted",
            details = list(
              restart_time = Sys.time(),
                              previous_session_data = list(
                  responses = length(rv$responses),
                  administered = length(rv$administered),
                  final_ability = if (config$adaptive) rv$current_ability else NULL
                ),
              timestamp = Sys.time()
            )
          )
        }, error = function(e) {
          logger(sprintf("Failed to log test restart: %s", e$message), level = "WARNING")
        })
      }
      
      logger("Test restarted")
    })
  } # End of server function
  
  # Cleanup when the package is unloaded or R exits (session_save only)
  if (session_save) {
    .inrep_set_cleanup_hook(function() {
      if (exists("cleanup_session") && is.function(cleanup_session)) {
        tryCatch({
          cleanup_session(save_final_data = TRUE)
          logger("Final cleanup completed on exit", level = "INFO")
        }, error = function(e) {
          logger(sprintf("Final cleanup failed: %s", e$message), level = "ERROR")
        })
      }
    })
    
    reg.finalizer(environment(), function(env) {
      .inrep_run_cleanup_hook()
    }, onexit = TRUE)
  }

  app <- shiny::shinyApp(ui = ui, server = server)

  if (launch_browser) {
    logger(sprintf("Launching study in browser at http://%s:%d", host, port), level = "INFO")
    tryCatch({
      shiny::runApp(app, port = port, host = host, launch.browser = TRUE)
    }, error = function(e) {
      logger(sprintf("Failed to launch browser: %s", e$message), level = "ERROR")
      logger(sprintf("Running app without browser launch on port 3838. Access at: http://%s:3838", host), level = "WARNING")
      shiny::runApp(app, port = 3838, host = host, launch.browser = FALSE)
    })
  } else {
    logger(sprintf("Study ready. Run shiny::runApp(app) or access at http://%s:%d", host, port), level = "INFO")
    return(app)
  }
}
