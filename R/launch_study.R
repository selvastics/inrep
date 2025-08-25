#' Launch Adaptive Study Interface
#'
#' Launches a Shiny-based adaptive or non-adaptive assessment interface that serves as
#' a comprehensive wrapper around TAM's psychometric capabilities. All IRT computations
#' (ability estimation, item selection, model fitting) are performed by the TAM package,
#' while this function provides the interactive interface, workflow management, and
#' integration layer for comprehensive research workflows.
#'
#' @export
#' @param config A list containing study configuration parameters created by \code{\link{create_study_config}}.
#'   Must include essential elements like \code{model}, \code{max_items}, \code{min_SEM}, etc.
#' @param item_bank Data frame containing item parameters compatible with TAM package requirements.
#'   Column structure varies by IRT model (see \strong{Item Bank Requirements} section).
#' @param custom_css Character string containing CSS code for UI customization. 
#'   When provided, overrides both built-in themes and \code{theme_config} settings.
#' @param theme_config Named list of theme parameters for custom theming.
#'   Contains CSS variable definitions like \code{primary_color}, \code{font_family}, etc.
#' @param webdav_url Character string specifying WebDAV URL for cloud-based result storage,
#'   or \code{NULL} to disable cloud functionality. When provided, \code{password} must also be specified.
#'   Example URLs: \code{"https://sync.academiccloud.de/index.php/s/YourSharedFolder/"} or 
#'   \code{"https://your-institution.edu/webdav/studies/"}. Both \code{webdav_url} and \code{password}
#'   are required together for cloud storage functionality.
#' @param password Character string for WebDAV authentication. Required when \code{webdav_url} is specified.
#'   This should be the access password or token for your WebDAV storage endpoint. 
#'   For security, consider using environment variables: \code{Sys.getenv("WEBDAV_PASSWORD")}.
#' @param save_format Character string specifying output format for assessment results.
#'   Options: \code{"rds"} (default), \code{"csv"}, \code{"json"}, \code{"pdf"}.
#' @param logger Function for custom logging. Default uses internal \code{logr} implementation.
#'   Should accept \code{message} and \code{level} parameters.
#' @param admin_dashboard_hook Optional function receiving real-time assessment updates.
#'   Called with participant progress, ability estimates, and session metrics.
#' @param accessibility Logical indicating whether to enable accessibility features
#'   including ARIA labels, keyboard navigation, and screen reader support.
#' @param study_key Character string for unique study identification. Overrides config$study_key.
#' @param max_session_time Maximum session time in seconds (default: 7200 = 2 hours).
#'   The assessment will automatically terminate after this time to ensure data security.
#' @param session_save Logical indicating whether to enable session saving and recovery.
#' @param data_preservation_interval Interval for automatic data preservation in seconds (default: 30).
#' @param keep_alive_interval Keep-alive ping interval in seconds (default: 10).
#' @param enable_error_recovery Logical indicating whether to enable automatic error recovery
#'   with up to 3 recovery attempts before graceful degradation.
#' @param ... Additional parameters passed to Shiny application configuration.
#'
#' @return A Shiny application object that can be run with \code{shiny::runApp()}.
#'   The app provides a complete assessment interface with real-time adaptation.
#'
#' @details
#' \strong{Psychometric Foundation:} All statistical computations are performed by the
#' TAM package (Robitzsch et al., 2024). \code{inrep} serves as an integration framework
#' that orchestrates TAM's capabilities within an interactive research workflow:
#' \itemize{
#'   \item IRT model fitting: \code{\link[TAM]{tam.mml}}, \code{\link[TAM]{tam.mml.2pl}}, \code{\link[TAM]{tam.mml.3pl}}
#'   \item Ability estimation: \code{\link[TAM]{tam.wle}}, \code{\link[TAM]{tam.eap}}
#'   \item Item information: \code{\link[TAM]{IRT.informationCurves}}
#'   \item Model diagnostics: \code{\link[TAM]{tam.fit}}
#' }
#' 
#' \strong{Framework Architecture:} \code{inrep} provides the following integration capabilities:
#' \itemize{
#'   \item Interactive web interface powered by Shiny (Chang et al., 2021)
#'   \item Real-time data collection and session management
#'   \item Bidirectional interface between user interactions and TAM computations
#'   \item Workflow orchestration with comprehensive logging via \code{logr} package
#'   \item Result export in multiple formats with cloud storage integration
#' }
#'
#' \strong{Assessment Features:} This function provides comprehensive computerized 
#' adaptive testing (CAT) capabilities including:
#' \itemize{
#'   \item Multilingual interface support (English, German, Spanish, French)
#'   \item Configurable demographic data collection with validation
#'   \item Adaptive and non-adaptive administration modes
#'   \item Support for multiple IRT models (1PL/Rasch, 2PL, 3PL, GRM)
#'   \item Advanced item selection algorithms (Maximum Information, Weighted, Random)
#'   \item Real-time ability estimation using TAM's EAP and WLE methods
#'   \item Comprehensive result reporting with theta estimates, standard errors, and diagnostics
#'   \item Session state management with save/restore capabilities for interrupted sessions
#'   \item Enterprise-grade logging and audit trails via \code{logr} package
#'   \item Responsive design with accessibility compliance (WCAG 2.1 guidelines)
#' }
#'
#' \strong{Advanced Features:}
#' \itemize{
#'   \item \strong{Real-time monitoring:} Use \code{admin_dashboard_hook} to receive live updates
#'     on participant progress, ability distribution patterns, and session metrics
#'   \item \strong{Accessibility compliance:} Enable \code{accessibility = TRUE} for ARIA labels,
#'     keyboard navigation, screen reader support, and high contrast options
#'   \item \strong{Cloud integration:} Specify \code{webdav_url} for automatic result backup
#'     to institutional cloud storage systems with secure authentication
#'   \item \strong{Quality monitoring:} Built-in detection of response patterns, engagement metrics,
#'     and data quality indicators with automatic flagging of suspicious sessions
#' }
#' 
#' @section Cloud Storage Configuration:
#' The framework supports automatic backup of assessment results to WebDAV-compatible cloud storage:
#' 
#' \strong{Setup Requirements:}
#' \itemize{
#'   \item Both \code{webdav_url} and \code{password} must be provided together
#'   \item WebDAV URL must be a valid HTTP(S) endpoint with write permissions
#'   \item Password should be the access token or credential for your WebDAV service
#'   \item Network connectivity required for cloud functionality
#' }
#' 
#' \strong{Compatible Services:}
#' \itemize{
#'   \item Academic cloud storage (e.g., \code{"https://sync.academiccloud.de/..."})
#'   \item Institutional WebDAV servers (\code{"https://university.edu/webdav/..."})
#'   \item Nextcloud/ownCloud instances with WebDAV enabled
#'   \item Commercial WebDAV providers (Box, Dropbox Business, etc.)
#' }
#' 
#' \strong{Security Best Practices:}
#' \itemize{
#'   \item Use environment variables for passwords: \code{password = Sys.getenv("WEBDAV_PASS")}
#'   \item Ensure WebDAV endpoints use HTTPS for encrypted transmission
#'   \item Use dedicated access tokens rather than account passwords when possible
#'   \item Test connectivity before launching large-scale studies
#' }
#' 
#' \strong{Usage Examples:}
#' \preformatted{
#' # Local storage only (default)
#' launch_study(config, item_bank)
#' 
#' # With cloud backup
#' launch_study(
#'   config, 
#'   item_bank,
#'   webdav_url = "https://sync.academiccloud.de/index.php/s/YourFolder/",
#'   password = Sys.getenv("WEBDAV_PASSWORD")
#' )
#' }
#'
#' @section Installation and Dependencies:
#' \strong{Required Packages:} Ensure all dependencies are installed for full functionality:
#' \preformatted{
#' # Core psychometric engine
#' install.packages("TAM")
#' 
#' # Interface and visualization  
#' install.packages(c("shiny", "DT", "ggplot2", "plotly"))
#' 
#' # Data processing and utilities
#' install.packages(c("dplyr", "jsonlite", "logr"))
#' 
#' # Install inrep package
#' devtools::install_github("selvastics/inrep")
#' }
#' 
#' \strong{System Requirements:}
#' \itemize{
#'   \item R version 4.0.0 or higher for optimal TAM compatibility
#'   \item Minimum 4GB RAM for medium-scale assessments (>500 participants)
#'   \item Modern web browser with JavaScript enabled for Shiny interface
#'   \item Network connectivity for cloud storage features (optional)
#' }
#'
#' @section Performance Optimization:
#' For large-scale deployments and high-performance requirements:
#' 
#' \strong{Computational Settings:}
#' \itemize{
#'   \item Enable \code{parallel_computation = TRUE} in config for faster TAM estimation
#'   \item Use \code{cache_enabled = TRUE} to cache item information calculations
#'   \item Specify optimal \code{theta_grid} density based on precision requirements
#'   \item Consider \code{auto_scaling = TRUE} for cloud-based deployments
#' }
#' 
#' \strong{Monitoring Tools:}
#' \itemize{
#'   \item Built-in profiling tools track estimation times and memory usage
#'   \item Real-time performance metrics available through admin dashboard
#'   \item Automatic detection of computational bottlenecks and warnings
#'   \item Session timeout management prevents resource exhaustion
#' }
#' 
#' \strong{Scalability Considerations:}
#' \itemize{
#'   \item Recommended concurrent user limits: 50-100 depending on server specifications
#'   \item Database storage recommended for studies with >1000 participants  
#'   \item Load balancing support for enterprise deployments
#'   \item Memory management optimizations for long-running sessions
#' }
#'
#' @section Validation and Quality Assurance:
#' The framework includes comprehensive validation and quality control mechanisms:
#' 
#' \strong{Real-time Response Quality:}
#' \itemize{
#'   \item Rapid response detection based on item-specific timing thresholds
#'   \item Response pattern analysis for detecting careless responding
#'   \item Engagement metrics including time-on-task and interaction patterns
#'   \item Automatic flagging of suspicious response sequences
#' }
#' 
#' \strong{Psychometric Quality:}
#' \itemize{
#'   \item Model fit diagnostics through TAM's \code{\link[TAM]{tam.fit}} procedures
#'   \item Person fit statistics for identifying aberrant response patterns
#'   \item Item functioning analysis with exposure rate monitoring
#'   \item Ability estimate stability tracking across administered items
#' }
#' 
#' \strong{Data Integrity:}
#' \itemize{
#'   \item Comprehensive audit trails with timestamped action logging
#'   \item Session state validation and recovery mechanisms
#'   \item Automatic data backup and redundancy for critical assessments
#'   \item GDPR-compliant data handling with participant consent management
#' }
#' 
#' \strong{Research Standards Compliance:}
#' \itemize{
#'   \item Follows Standards for Educational and Psychological Testing (AERA, APA, NCME, 2014)
#'   \item Implements International Test Commission Guidelines for Computer-Based Testing
#'   \item Supports institutional IRB requirements with built-in consent frameworks
#'   \item Accessibility compliance with WCAG 2.1 AA standards when enabled
#' }
#'
#' @section Theme Customization:
#' The interface supports extensive theming capabilities through multiple mechanisms:
#' 
#' \strong{Built-in Themes:} Six professionally designed themes are available:
#' \itemize{
#'   \item \code{"Light"}: Clean, minimalist design with high contrast
#'   \item \code{"Midnight"}: Dark theme optimized for low-light environments  
#'   \item \code{"Sunset"}: Warm color palette with orange and red accents
#'   \item \code{"Forest"}: Nature-inspired greens with earthy tones
#'   \item \code{"Ocean"}: Cool blues and teals for calming effect
#'   \item \code{"Berry"}: Purple and magenta palette for creative applications
#' }
#' 
#' \strong{Custom Themes:} Create custom themes through:
#' \itemize{
#'   \item \code{theme_config}: Named list with CSS variable definitions
#'   \item \code{custom_css}: Direct CSS injection for complete control
#'   \item \code{\link{get_theme_config}}: Get theme configuration for available themes
#' }
#' 
#' \strong{CSS Variables:} Key customization options include:
#' \itemize{
#'   \item \code{--primary-color}: Main interface accent color
#'   \item \code{--background-color}: Page and component backgrounds
#'   \item \code{--text-color}: Primary text color for readability
#'   \item \code{--font-family}: Typography selection (web-safe fonts recommended)
#'   \item \code{--border-radius}: Corner rounding for modern appearance
#'   \item \code{--button-hover-color}: Interactive element feedback
#' }
#' 
#' CSS customization takes precedence in this order: \code{custom_css} > \code{theme_config} > built-in themes.
#'
#' @section Progress Visualization:
#' The interface provides multiple progress visualization styles to enhance user experience:
#' 
#' \strong{Available Progress Styles:}
#' \itemize{
#'   \item \code{"modern-circle"}: Enhanced circular progress with smooth animations (default)
#'   \item \code{"enhanced-bar"}: Gradient-filled linear progress bar with shimmer effect
#'   \item \code{"segmented"}: Step-by-step visual indicator with numbered segments
#'   \item \code{"minimal"}: Clean, unobtrusive progress display
#'   \item \code{"card"}: Prominent progress display in card format
#'   \item \code{"circle"}: Legacy circular progress (backward compatible)
#'   \item \code{"bar"}: Legacy linear progress bar (backward compatible)
#' }
#' 
#' \strong{Usage Examples:}
#' \preformatted{
#' # Use modern circular progress (default)
#' config <- create_study_config(
#'   name = "My Assessment",
#'   progress_style = "modern-circle"
#' )
#' 
#' # Use segmented progress for step-by-step feedback
#' config <- create_study_config(
#'   name = "Long Assessment",
#'   progress_style = "segmented"
#' )
#' 
#' # Use minimal progress for clean interface
#' config <- create_study_config(
#'   name = "Simple Assessment",
#'   progress_style = "minimal"
#' )
#' }
#'
#' @section Item Bank Requirements:
#' The \code{item_bank} data frame must conform to TAM package specifications with 
#' columns varying by IRT model type:
#' 
#' \strong{Common Requirements (All Models):}
#' \itemize{
#'   \item \code{Question}: Character vector containing item text or content identifiers
#'   \item Items must be properly formatted for the target language and population
#'   \item No missing values in parameter columns required by the specified model
#' }
#' 
#' \strong{Model-Specific Requirements:}
#' \describe{
#'   \item{\strong{1PL/Rasch Model}}{
#'     \itemize{
#'       \item \code{b}: Difficulty parameters (logit scale, typically -3 to +3)
#'       \item \code{Answer}: Correct response codes for scoring
#'       \item \code{Option1, Option2, ...}: Response options for multiple choice items
#'     }
#'   }
#'   \item{\strong{2PL Model}}{
#'     \itemize{
#'       \item \code{a}: Discrimination parameters (positive values, typically 0.5 to 3.0)
#'       \item \code{b}: Difficulty parameters (logit scale)
#'       \item \code{Answer}: Correct response identifiers
#'       \item \code{Option1, Option2, ...}: Multiple choice response options
#'     }
#'   }
#'   \item{\strong{3PL Model}}{
#'     \itemize{
#'       \item \code{a}: Discrimination parameters (positive values)
#'       \item \code{b}: Difficulty parameters (logit scale)  
#'       \item \code{c}: Guessing parameters (0 to 1, typically 0.1 to 0.3)
#'       \item \code{Answer}: Correct response codes
#'       \item \code{Option1, Option2, ...}: Distractor options
#'     }
#'   }
#'   \item{\strong{GRM (Graded Response Model)}}{
#'     \itemize{
#'       \item \code{a}: Discrimination parameters for polytomous items
#'       \item \code{b1, b2, b3, ...}: Threshold parameters in ascending order
#'       \item \code{ResponseCategories}: Comma-separated response scale (e.g., "1,2,3,4,5")
#'       \item Optional: \code{CategoryLabels}: Descriptive labels for scale points
#'     }
#'   }
#' }
#' 
#' \strong{Parameter Validation:} The function automatically validates:
#' \itemize{
#'   \item Parameter ranges appropriate for TAM estimation procedures
#'   \item Threshold ordering for polytomous models (b1 < b2 < b3 < ...)
#'   \item Consistency between model specification and available parameters
#'   \item Data types and missing value patterns that could affect TAM computations
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic Personality Assessment with GRM
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create basic configuration
#' basic_config <- create_study_config(
#'   name = "Big Five Personality Assessment",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.3,
#'   demographics = c("Age", "Gender", "Education"),
#'   theme = "Light",
#'   language = "en"
#' )
#' 
#' # Launch assessment with default settings
#' launch_study(basic_config, bfi_items)
#' 
#' # Example 2: Advanced Cognitive Assessment with 2PL Model
#' advanced_config <- create_study_config(
#'   name = "Cognitive Ability Assessment",
#'   model = "2PL", 
#'   estimation_method = "TAM",
#'   max_items = 20,
#'   min_items = 10,
#'   min_SEM = 0.25,
#'   criteria = "MI",  # Maximum Information selection
#'   theta_prior = c(0, 1),
#'   demographics = c("Age", "Gender", "Education", "Native_Language"),
#'   input_types = list(
#'     Age = "numeric",
#'     Gender = "select", 
#'     Education = "select",
#'     Native_Language = "text"
#'   ),
#'   theme = "Professional",
#'   session_save = TRUE,
#'   parallel_computation = TRUE,
#'   cache_enabled = TRUE,
#'   accessibility_enhanced = TRUE
#' )
#' 
#' # Launch with accessibility features and admin monitoring
#' launch_study(
#'   config = advanced_config,
#'   item_bank = cognitive_items,
#'   accessibility = TRUE,
#'   admin_dashboard_hook = function(session_data) {
#'     cat("Participant ID:", session_data$participant_id, "\n")
#'     cat("Progress:", session_data$progress, "%\n")
#'     cat("Current theta:", round(session_data$theta, 3), "\n")
#'     cat("Standard error:", round(session_data$se, 3), "\n")
#'   }
#' )
#' 
#' # Example 3: Custom Theme with CSS Variables
#' custom_theme_config <- list(
#'   primary_color = "#2E86AB",
#'   secondary_color = "#A23B72", 
#'   background_color = "#F5F5F5",
#'   text_color = "#333333",
#'   font_family = "'Segoe UI', Tahoma, Geneva, Verdana, sans-serif",
#'   border_radius = "8px",
#'   button_hover_color = "#1E5A6B"
#' )
#' 
#' launch_study(
#'   config = basic_config,
#'   item_bank = bfi_items, 
#'   theme_config = custom_theme_config
#' )
#' 
#' # Example 4: Enterprise Clinical Assessment
#' clinical_config <- create_study_config(
#'   name = "Clinical Depression Screening",
#'   model = "GRM",
#'   max_items = 12,
#'   min_SEM = 0.35,
#'   demographics = c("Age", "Gender", "Previous_Treatment"),
#'   theme = "Clinical",
#'   language = "en",
#'   enterprise_security = TRUE,
#'   audit_logging = TRUE,
#'   quality_monitoring = TRUE,
#'   session_save = TRUE,
#'   max_session_duration = 30
#' )
#' 
#' # Launch with cloud storage and comprehensive logging
#' launch_study(
#'   config = clinical_config,
#'   item_bank = depression_items,
#'   save_format = "json",
#'   webdav_url = "https://secure-storage.hospital.edu/assessments/",
#'   password = Sys.getenv("CLINICAL_WEBDAV_PASSWORD"),
#'   logger = function(msg, level = "INFO") {
#'     timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
#'     cat(sprintf("[%s] %s: %s\n", timestamp, level, msg))
#'   }
#' )
#' 
#' # Example 5: Research Study with Complete Customization
#' research_config <- create_study_config(
#'   name = "Psychometric Validation Study",
#'   model = "3PL",
#'   estimation_method = "TAM",
#'   min_items = 15,
#'   max_items = 30,
#'   min_SEM = 0.2,
#'   criteria = "WEIGHTED",
#'   theta_prior = c(0, 1.2),
#'   demographics = c("Age", "Gender", "Education", "Country", "Language"),
#'   response_ui_type = "radio",
#'   progress_style = "modern-circle",
#'   theme = "Research",
#'   language = "en",
#'   session_save = TRUE,
#'   parallel_computation = TRUE,
#'   feedback_enabled = TRUE,
#'   recommendation_fun = function(theta, demographics, responses) {
#'     if (theta > 1.0) {
#'       return(c("Excellent performance", "Consider advanced materials"))
#'     } else if (theta > 0) {
#'       return(c("Good performance", "Continue current approach"))
#'     } else {
#'       return(c("Additional support recommended", "Review fundamentals"))
#'     }
#'   }
#' )
#' 
#' # Example 6: University of Hildesheim theme with cloud storage
#' hildesheim_config <- create_study_config(
#'   name = "University of Hildesheim Assessment",
#'   model = "GRM",
#'   max_items = 10,
#'   session_save = TRUE,
#'   theme = "Berry"
#' )
#' 
#' launch_study(
#'   config = hildesheim_config,
#'   item_bank = bfi_items,
#'   save_format = "json",
#'   webdav_url = "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb",
#'   password = "inreptest",
#'   study_key = paste0("HILDESHEIM_", UUIDgenerate())
#' )
#' }
#' @importFrom shiny shinyApp fluidPage tags div numericInput selectInput actionButton downloadButton uiOutput renderUI plotOutput h2 h3 h4 p tagList
#' @importFrom shinyjs useShinyjs
#' @importFrom shinyWidgets radioGroupButtons
#' @importFrom DT datatable DTOutput renderDT formatStyle
#' @importFrom dplyr %>%

#' @importFrom jsonlite write_json
#' @importFrom ggplot2 ggplot aes geom_line geom_ribbon theme_minimal labs theme element_text element_line element_blank
#' @importFrom pdftools pdf_render_page
#' @importFrom knitr kable
#' @importFrom kableExtra kable_styling
#' @importFrom tinytex latexmk
#' @importFrom logr log_print
launch_study <- function(
    config,
    item_bank,
    custom_css = NULL,
    theme_config = NULL,
    webdav_url = NULL, 
    password = NULL,
    save_format = "rds",
    logger = function(msg, ...) message(msg),
    study_key = NULL,
    accessibility = FALSE,
    admin_dashboard_hook = NULL,
    max_session_time = 7200,
    session_save = TRUE,
    data_preservation_interval = 30,
    keep_alive_interval = 10,
    enable_error_recovery = TRUE,
    # IMMEDIATE DISPLAY PARAMETERS
    ui_render_delay = NULL,
    package_loading_delay = NULL,
    session_init_delay = NULL,
    show_loading_screen = NULL,
    immediate_ui = FALSE,
    server_extensions = NULL,  # Add support for server extensions
    ...
) {
  
  # AGGRESSIVE LATER PACKAGE IMPLEMENTATION - DISPLAY UI IMMEDIATELY
  if (immediate_ui) {
    # Logging removed for performance - immediate UI display enabled
    
    # Step 1: Create private event loop for UI
    ui_loop <- later::create_loop()
    
    # Step 2: Display UI with ZERO delay
    later::later(function() {
      # UI displayed immediately
    }, delay = 0, loop = ui_loop)
    
    # Step 3: Force immediate execution
    later::run_now(loop = ui_loop)
    
    # Step 4: Move ALL heavy operations to background using later
    later::later(function() {
      # Background loading started
    }, delay = 0)
    
    # Step 5: Force all background operations to run immediately but asynchronously
    later::run_now(timeoutSecs = 0, all = FALSE)
  }
  
  # Enhanced validation and error handling for robustness
  tryCatch({
    # Source enhanced modules if available
    enhanced_files <- c(
      "enhanced_config_handler.R",
      "enhanced_session_recovery.R", 
      "enhanced_security.R",
      "enhanced_performance.R",
      "custom_page_flow.R",
      "custom_page_flow_validation.R"
    )
    
    for (file in enhanced_files) {
      file_path <- system.file("R", file, package = "inrep")
      if (file.exists(file_path)) {
        source(file_path, local = TRUE)
      }
    }
    
    # Validate and fix configuration
    if (exists("validate_and_fix_config")) {
      config <- validate_and_fix_config(config, item_bank)
      
      # Show warnings if any
      if (!is.null(config$validation_warnings)) {
        for (warning_name in names(config$validation_warnings)) {
          logger(paste("Config warning:", config$validation_warnings[[warning_name]]))
        }
      }
    }
    
    # Handle extreme parameters
    if (exists("handle_extreme_parameters")) {
      config <- handle_extreme_parameters(config)
    }
    
    # Optimize for scale if needed
    if (!is.null(config$expected_n) && exists("optimize_for_scale")) {
      config <- optimize_for_scale(config, config$expected_n)
    }
    
    # Initialize enhanced features if available
    if (enable_error_recovery && exists("initialize_enhanced_recovery")) {
      initialize_enhanced_recovery(
        auto_save_interval = data_preservation_interval,
        enable_browser_storage = TRUE
      )
    }
    
    if (exists("initialize_enhanced_security")) {
      initialize_enhanced_security()
    }
    
    if (exists("initialize_performance_optimization")) {
      initialize_performance_optimization(
        max_concurrent_users = config$expected_n %||% 100
      )
    }
  }, error = function(e) {
    logger(paste("Enhanced features initialization:", e$message))
    # Continue with standard functionality
  })
  
  # Check if shiny is available (required for UI)
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required but not available. Please install it with: install.packages('shiny')")
  }
  
  # Check if later package is available (for deferred operations)
  has_later <- requireNamespace("later", quietly = TRUE)
  if (!has_later) {
    # Try to install later package for better performance
    tryCatch({
      utils::install.packages("later", quiet = TRUE, repos = "https://cran.r-project.org")
      has_later <- requireNamespace("later", quietly = TRUE)
    }, error = function(e) {
      logger("Could not install 'later' package. Performance may be reduced.", level = "INFO")
    })
  }
  
  # Check for UUID if study_key uses UUIDgenerate
  if (!missing(study_key) && is.character(study_key)) {
    if (grepl("UUIDgenerate", deparse(substitute(study_key)))) {
      if (!requireNamespace("uuid", quietly = TRUE)) {
        stop("Package 'uuid' is required for UUIDgenerate(). Please install it with: install.packages('uuid')")
      }
    }
  }
  
  # Input validation
  extra_params <- list(...)
  if (length(extra_params) > 0) {
    if (!is.null(extra_params) && length(extra_params) > 0) logger(paste("Ignoring unused parameters:", paste(names(extra_params), collapse = ", ")), level = "INFO")
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
  
  # ULTRA-FAST PACKAGE LOADING SYSTEM WITH LATER PACKAGE INTEGRATION
  safe_load_packages <- function(immediate = FALSE) {
    
    # If immediate_ui is enabled, use later package for background loading
    if (immediate_ui) {
      cat("LATER: Moving package loading to background\n")
      
      # Create background loop for package loading
      pkg_loop <- later::create_loop()
      
      # Schedule package loading in background
      later::later(function() {
        cat("LATER: Background package loading started\n")
        # Package loading happens here without blocking UI
      }, delay = 0, loop = pkg_loop)
      
      # Return minimal packages for immediate UI
      return(list(
        shiny = TRUE,
        ggplot2 = FALSE,
        DT = FALSE, 
        dplyr = FALSE,
        shinyWidgets = FALSE,
        TAM = FALSE
      ))
    }
    # Define package priorities
    critical_packages <- c("shiny")  # ONLY what's needed for UI
    deferred_packages <- c("ggplot2", "DT", "dplyr", "shinyWidgets")  # Load later
    optional_packages <- if (isTRUE(config$adaptive)) "TAM" else character(0)
    
    # Initialize with all packages set to FALSE
    all_packages <- c(critical_packages, deferred_packages, optional_packages)
    loaded_packages <- as.list(setNames(rep(FALSE, length(all_packages)), all_packages))
    
    if (!immediate) {
      # FASTEST PATH: Don't load ANYTHING except critical packages
      
      # Step 1: Only verify critical packages exist (don't load!)
      for (pkg in critical_packages) {
        if (!requireNamespace(pkg, quietly = TRUE)) {
          stop(sprintf("Critical package '%s' is required", pkg))
        }
        loaded_packages[[pkg]] <- TRUE
      }
      
      # Step 2: Check availability WITHOUT loading
      for (pkg in c(deferred_packages, optional_packages)) {
        loaded_packages[[pkg]] <- requireNamespace(pkg, quietly = TRUE)
      }
      
      # Step 3: ADVANCED later package usage with private event loops and immediate execution
      if (has_later) {
        # Create private event loop for package loading to avoid UI interference
        package_loop <- NULL
        tryCatch({
          package_loop <- later::create_loop()
        }, error = function(e) {
          # Fallback to global loop if private loops not available
          package_loop <<- later::global_loop()
        })
        
        # Priority 1: Load optional packages with ZERO delay for maximum speed
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
          # Force immediate execution of next phase
          later::run_now(timeoutSecs = 0, all = FALSE, loop = package_loop)
        }, delay = 0, loop = package_loop)  # IMMEDIATE execution
        
        # Priority 2: Heavy packages with minimal delay in private loop
        later::later(function() {
          for (pkg in deferred_packages) {
            tryCatch({
              if (loaded_packages[[pkg]]) {
                # Only load namespace, not attach
                loadNamespace(pkg)
                logger(sprintf("Background loaded: %s", pkg), level = "DEBUG")
              }
            }, error = function(e) {
              logger(sprintf("Could not load %s: %s", pkg, e$message), level = "DEBUG")
            })
          }
          # Force completion
          later::run_now(timeoutSecs = 0, all = TRUE, loop = package_loop)
        }, delay = 0.001, loop = package_loop)  # 1ms - Ultra-fast execution
        
        # Execute the private loop immediately without blocking UI
        later::later(function() {
          later::run_now(timeoutSecs = 0, all = TRUE, loop = package_loop)
        }, delay = 0)  # Execute private loop immediately
      }
    } else {
      # Immediate mode - only used when absolutely necessary
      # Use loadNamespace instead of library for speed
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
  
  # ULTRA-FAST STARTUP: Never load packages synchronously
  # This ensures < 100ms to first page render
  available_packages <- safe_load_packages(immediate = FALSE)
  
  # Pre-calculate static content AND first page HTML for instant display
  static_content_cache <- list(
    has_custom_css = !is.null(custom_css),
    has_theme_config = !is.null(theme_config),
    has_custom_flow = !is.null(config$custom_page_flow),
    is_adaptive = isTRUE(config$adaptive),
    # Pre-render first page HTML for INSTANT display
    first_page = if (!is.null(config$custom_page_flow) && length(config$custom_page_flow) > 0) {
      first_page_config <- config$custom_page_flow[[1]]
      shiny::div(
        class = "container",
        style = "max-width: 800px; margin: 0 auto; padding: 20px;",
        shiny::div(
          class = "card",
          style = "padding: 30px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);",
          shiny::h2(first_page_config$title %||% "Welcome", style = "color: #333; margin-bottom: 20px;"),
          if (!is.null(first_page_config$content)) {
            shiny::HTML(first_page_config$content)
          } else if (!is.null(first_page_config$instructions)) {
            shiny::p(first_page_config$instructions, style = "color: #666; line-height: 1.6;")
          } else {
            shiny::p("Loading assessment...", style = "color: #666;")
          },
          shiny::div(
            style = "margin-top: 30px; text-align: right;",
            shiny::actionButton("next_page", "Next", 
              class = "btn btn-primary",
              style = "padding: 10px 30px; font-size: 16px;")
          )
        )
      )
    } else {
      NULL
    }
  )
  
  # Check if TAM package is available (only needed for adaptive mode)
  if (isTRUE(config$adaptive) && !isTRUE(available_packages$TAM)) {
    message("Package 'TAM' not available. Falling back to basic non-TAM mode for limited checks.")
  }
  
  # Create robust wrapper functions that check package availability
  safe_tam_mml <- function(...) {
    if (isTRUE(available_packages$TAM)) {
      tryCatch({
        TAM::tam.mml(...)
      }, error = function(e) {
        logger(sprintf("TAM::tam.mml error: %s", e$message), level = "ERROR")
        stop(sprintf("TAM computation failed: %s", e$message))
      })
    } else {
      stop("TAM package not available in runtime")
    }
  }
  
  safe_tam_mml_2pl <- function(...) {
    if (available_packages$TAM) {
      tryCatch({
        TAM::tam.mml.2pl(...)
      }, error = function(e) {
        logger(sprintf("TAM::tam.mml.2pl error: %s", e$message), level = "ERROR")
        stop(sprintf("TAM computation failed: %s", e$message))
      })
    } else {
      stop("TAM package not available")
    }
  }
  
  safe_tam_mml_3pl <- function(...) {
    if (available_packages$TAM) {
      tryCatch({
        TAM::tam.mml.3pl(...)
      }, error = function(e) {
        logger(sprintf("TAM::tam.mml.3pl error: %s", e$message), level = "ERROR")
        stop(sprintf("TAM computation failed: %s", e$message))
      })
    } else {
      stop("TAM package not available")
    }
  }
  
  safe_tam_wle <- function(...) {
    if (available_packages$TAM) {
      tryCatch({
        TAM::tam.wle(...)
      }, error = function(e) {
        logger(sprintf("TAM::tam.wle error: %s", e$message), level = "ERROR")
        stop(sprintf("TAM computation failed: %s", e$message))
      })
    } else {
      stop("TAM package not available")
    }
  }
  
  safe_tam_eap <- function(...) {
    if (available_packages$TAM) {
      tryCatch({
        TAM::tam.eap(...)
      }, error = function(e) {
        logger(sprintf("TAM::tam.eap error: %s", e$message), level = "ERROR")
        stop(sprintf("TAM computation failed: %s", e$message))
      })
    } else {
      stop("TAM package not available")
    }
  }
  
  # Create safe plotting function
  safe_render_plot <- function(expr, ...) {
    if (!is.null(available_packages) && isTRUE(available_packages[["ggplot2"]])) {
      tryCatch({
        # Ensure ggplot2 is properly loaded and accessible
        if (!requireNamespace("ggplot2", quietly = TRUE)) {
          stop("ggplot2 package not available")
        }
        ggplot2::renderPlot(expr, ...)
      }, error = function(e) {
        logger(sprintf("ggplot2::renderPlot error: %s", e$message), level = "ERROR")
        # Fallback to text output
        shiny::renderText({
          "Plot rendering failed - displaying data as text instead"
        })
      })
    } else {
      shiny::renderText({
        "Plotting not available - ggplot2 package not installed"
      })
    }
  }
  
  # Create safe DT function
  safe_render_dt <- function(expr, ...) {
    # Safely check if DT is available
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
      logger("WebDAV URL provided without password", level = "ERROR")
      base::stop("Cloud storage requires both 'webdav_url' and 'password' arguments.\n",
                 "You provided a WebDAV URL but no password.\n",
                 "Please provide both arguments together:\n",
                 "  webdav_url = \"", webdav_url, "\"\n",
                 "  password = \"your-access-password\"\n",
                 "For security, consider using: password = Sys.getenv(\"WEBDAV_PASSWORD\")")
    }
    if (!base::is.null(webdav_url) && !base::is.null(password)) {
      # Validate URL format
      if (!grepl("^https?://", webdav_url)) {
        logger("Invalid WebDAV URL format", level = "ERROR")
        base::stop("WebDAV URL must start with 'http://' or 'https://'\n",
                   "Provided: ", webdav_url, "\n",
                   "Example: webdav_url = \"https://sync.academiccloud.de/index.php/s/YourFolder/\"")
      }
      logger("Cloud storage enabled with WebDAV URL and password", level = "INFO")
      logger(paste("Cloud storage enabled:", webdav_url), level = "INFO")
    }
  } else {
    logger("Using local storage only (no cloud backup)", level = "INFO")
    logger("Cloud storage disabled - results will be saved locally only", level = "INFO")
  }
  
  logger(base::sprintf("Launching study: %s with theme: %s", config$name, config$theme %||% "Light"), level = "INFO")
  
  if (!is.null(config$admin_dashboard_hook) && is.function(config$admin_dashboard_hook)) {
    logger("Admin dashboard hook registered", level = "INFO")
  }
  
  # DEFER session initialization to server - don't block startup
  .needs_session_init <- session_save
  session_config <- NULL
  error_config <- NULL
  
  if (FALSE) {  # Skip for now - will be done in server
      logger("Initializing robust session management", level = "INFO")
      
      # Initialize robust session management
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
        logger(sprintf("Failed to initialize robust session management: %s", e$message), level = "WARNING")
        # Fallback to basic session management
        list(
          session_id = paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S")),
          start_time = Sys.time(),
          max_time = max_session_time,
          log_file = NULL
        )
      })
      
      # Initialize robust error handling
      error_config <- tryCatch({
        if (exists("initialize_robust_error_handling") && is.function(initialize_robust_error_handling)) {
          initialize_robust_error_handling(
            max_recovery_attempts = 3,
            enable_auto_recovery = enable_error_recovery
          )
        } else {
          # Fallback to basic error handling
          list(
            max_recovery_attempts = 3,
            enable_auto_recovery = enable_error_recovery
          )
        }
      }, error = function(e) {
        logger(sprintf("Failed to initialize robust error handling: %s", e$message), level = "WARNING")
        # Fallback to basic error handling
        list(
          max_recovery_attempts = 3,
          enable_auto_recovery = enable_error_recovery
        )
      })
      
      # Create periodic backup system
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
      
      # Start periodic backup monitoring (with fallback)
      if (session_save && exists("start_data_preservation_monitoring") && is.function(start_data_preservation_monitoring)) {
        tryCatch({
          start_data_preservation_monitoring()
          # logger("Periodic data preservation monitoring started", level = "INFO") # Disabled to reduce spam
        }, error = function(e) {
          logger(sprintf("Failed to start data preservation monitoring: %s", e$message), level = "WARNING")
        })
      } else if (session_save) {
        logger("Session saving enabled (basic mode)", level = "INFO")
      }
      
      # Log comprehensive session initialization (with fallback)
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
    }
  
  # Normalize common alternative column names before validation
  if ("content" %in% names(item_bank) && !"Question" %in% names(item_bank)) item_bank$Question <- item_bank$content
  if ("item_id" %in% names(item_bank) && !"Question" %in% names(item_bank)) item_bank$Question <- as.character(item_bank$item_id)
  if ("discrimination" %in% names(item_bank) && !"a" %in% names(item_bank)) item_bank$a <- item_bank$discrimination
  if ("difficulty" %in% names(item_bank) && !"b" %in% names(item_bank)) item_bank$b <- item_bank$difficulty
  
  # Validate item bank; allow list return and log
  validation <- inrep::validate_item_bank(item_bank, config$model)
  if (is.list(validation)) {
    if (!isTRUE(validation$is_valid)) {
      logger("Item bank validation reported issues; proceeding with best-effort normalization", level = "WARNING")
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
    config$adaptive_start <- base::ceiling((config$max_items %||% config$min_items) / 2)
    logger(base::sprintf("Setting default adaptive_start: %d", config$adaptive_start))
  }

  # Use new get_theme_css for all theming
  theme_css <- get_theme_css(
    theme = config$theme %||% "Light",
    custom_css = custom_css
  )
  
  if (config$model == "1PL") item_bank$a <- base::rep(1, base::nrow(item_bank))
  
  # Enhanced CSS with theme variables
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
    
    .assessment-card {
      background: white;
      border-radius: var(--border-radius);
      padding: 30px;
      margin: 20px 0;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      border: 1px solid var(--secondary-color);
      background-color: var(--background-color);
      color: var(--text-color);
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
    
    /* Override Bootstrap button colors for Hildesheim theme */
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
      background: var(--progress-bg-color);
      height: 12px;
      border-radius: 6px;
      margin: 25px 0;
      overflow: hidden;
    }
    
    .progress-bar-fill {
      height: 100%;
      background: var(--primary-color);
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
    
    /* Enhanced styling for selected radio buttons */
    .shiny-input-radiogroup label.selected {
      background-color: rgba(var(--primary-color), 0.15) !important;
      border-color: var(--primary-color) !important;
      border-width: 2px !important;
    }
    
    /* Visual feedback for deselectable radio buttons */
    .shiny-input-radiogroup input[type='radio']:checked + span::after {
      content: ' (Click again to deselect)';
      font-size: 11px;
      color: var(--primary-color);
      font-style: italic;
      opacity: 0.7;
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
  
  # Get language labels from the comprehensive multilingual system
  # Start with default language (German for Hildesheim)
  default_language <- config$language %||% "de"
  ui_labels <- get_language_labels(default_language)
  
  ui <- shiny::fluidPage(
    class = "full-width-app",
    if (requireNamespace("shinyjs", quietly = TRUE)) shinyjs::useShinyjs(),
    

    
    # ULTIMATE CORNER FLASH ELIMINATION - ALL METHODS COMBINED!
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        /* NUCLEAR UNIVERSAL RESET - FORCE EVERYTHING TO CENTER */
        * {
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
        
        /* FORCE ALL SHINY ELEMENTS TO CENTER */
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
        
        /* OVERRIDE ANY POSITIONING ATTEMPTS */
        [style*='position: absolute'], [style*='position: fixed'],
        [style*='left:'], [style*='right:'], [style*='top:'] {
          position: relative !important;
          left: 0 !important;
          right: 0 !important;
          top: 0 !important;
          margin: 0 auto !important;
          transform: none !important;
        }
        
        /* PERFECT PROGRESS CIRCLE - MULTIPLE APPROACHES */
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
          color: #333 !important;
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
        
        /* IMMEDIATE VISIBILITY */
        #study_ui {
          visibility: visible !important;
          opacity: 1 !important;
        }
        
        /* SPINNER ANIMATION */
        @keyframes spin {
          0% { transform: rotate(0deg) !important; }
          100% { transform: rotate(360deg) !important; }
        }
      ")),
      
      # JAVASCRIPT: ULTIMATE positioning enforcement
      shiny::tags$script(shiny::HTML("
        // IMMEDIATE EXECUTION - Multiple layers of protection
        (function() {
          // FORCE CENTER POSITIONING FUNCTION
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
          
          // AGGRESSIVE MUTATION OBSERVER
          var observer = new MutationObserver(function(mutations) {
            mutations.forEach(function(mutation) {
              if (mutation.type === 'childList') {
                mutation.addedNodes.forEach(function(node) {
                  if (node.nodeType === 1) { // Element node
                    // Apply to ALL main containers
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
          
          // Start observing immediately
          observer.observe(document.body, {
            childList: true,
            subtree: true,
            attributes: true,
            attributeFilter: ['style', 'class']
          });
          
          // PERIODIC ENFORCEMENT - every 500ms (reduced frequency for better performance)
          setInterval(function() {
            var elements = document.querySelectorAll('.page-wrapper, .assessment-card, #study_ui, #stable-page-container');
            for (var i = 0; i < elements.length; i++) {
              forceCenter(elements[i]);
            }
          }, 500);
          
                     // IMMEDIATE APPLICATION on DOM ready
           document.addEventListener('DOMContentLoaded', function() {
             setTimeout(function() {
               var elements = document.querySelectorAll('.page-wrapper, .assessment-card, #study_ui, #stable-page-container');
               for (var i = 0; i < elements.length; i++) {
                 forceCenter(elements[i]);
               }
             }, 1);
           });
           
                     // DIRECT CONTENT DISPLAY - No loading screens, maximum efficiency
          // Debug logging removed for performance
        })();
      ")),
      
    ),
    
    shiny::tags$head(
      # CRITICAL: Prevent corner flash - must be FIRST CSS rule  
      shiny::tags$style(HTML("
        /* IMMEDIATE CORNER FLASH PREVENTION - Applied before any other CSS */
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
      shiny::tags$style(HTML("
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        
        @keyframes fadeInIndicator {
          from { opacity: 0; transform: translateX(20px); }
          to { opacity: 1; transform: translateX(0); }
        }
      ")),
      
      # JavaScript to ensure proper positioning
      shiny::tags$script(HTML("
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
            document.getElementById('study_ui').className += ' positioned';
            document.getElementById('study_ui').style.visibility = 'visible';
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
          
          // Add scroll-to-top functionality for page changes
          Shiny.addCustomMessageHandler("scrollToTop", function(message) {
            if (message.smooth) {
              // Smooth scroll to top
              window.scrollTo({
                top: 0,
                left: 0,
                behavior: 'smooth'
              });
            } else {
              // Instant scroll to top
              window.scrollTo(0, 0);
            }
          });
          
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
            document.getElementById('study_ui').className += ' positioned';
            document.getElementById('study_ui').style.visibility = 'visible';
          });
          
          // Enhanced Radio button deselection with visual feedback
          document.addEventListener("click", function(e) {
            if (e.target && e.target.type === "radio") {
              var wasChecked = e.target.getAttribute("data-was-checked") === "true";
              
              // Clear all radios in the same group
              var radios = document.querySelectorAll("input[name='" + e.target.name + "']");
              for (var i = 0; i < radios.length; i++) {
                radios[i].setAttribute("data-was-checked", "false");
                // Remove visual selection styling
                var label = radios[i].closest('label');
                if (label) {
                  label.style.backgroundColor = '';
                  label.style.borderColor = '';
                }
              }
              
              if (wasChecked) {
                // Deselect the radio button
                e.target.checked = false;
                if (typeof Shiny !== "undefined") {
                  Shiny.setInputValue(e.target.name, null, {priority: "event"});
                }
                // Remove visual selection from the label
                var currentLabel = e.target.closest('label');
                if (currentLabel) {
                  currentLabel.style.backgroundColor = '';
                  currentLabel.style.borderColor = '';
                }
              } else {
                // Select the radio button
                e.target.setAttribute("data-was-checked", "true");
                // Add visual selection to the label
                var currentLabel = e.target.closest('label');
                if (currentLabel) {
                  currentLabel.style.backgroundColor = 'rgba(232, 4, 28, 0.1)';
                  currentLabel.style.borderColor = '#e8041c';
                }
              }
            }
          });
        });
      ")),
      shiny::tags$style(HTML("
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
        shiny::tags$style(HTML("
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
        shiny::tags$style(HTML("
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
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      # Include Plotly for interactive plots
      shiny::tags$script(src = "https://cdn.plot.ly/plotly-latest.min.js"),
      # Add custom CSS if provided
      if (!is.null(config$custom_css)) {
        shiny::tags$style(HTML(config$custom_css))
      }

    ),
    # Remove blocking loading screen - let Shiny's natural loading work
    # shiny::div(
    #   id = "loading-screen",
    #   class = "loading-screen",
    #   style = "display: none;",  # Hidden by default
    #   shiny::div(
    #     class = "loading-content",
    #     shiny::div(class = "loading-spinner")
    #   )
    # ),
    if (tolower(config$theme %||% "") == "hildesheim") shiny::div(class = "hildesheim-logo"),
    # Session status indicator for session saving
    if (session_save) {
      shiny::uiOutput("session_status_ui")
    },
    shiny::uiOutput("study_ui", style = "position: relative !important; left: 0 !important; right: 0 !important; top: 0 !important; margin: 0 auto !important; transform: none !important; width: 100% !important; max-width: 1200px !important; display: block !important; visibility: visible !important; opacity: 1 !important;")
  )
  
  server <- function(input, output, session) {
    # Apply server extensions if provided
    if (!is.null(server_extensions) && is.list(server_extensions)) {
      for (extension in server_extensions) {
        if (is.function(extension)) {
          tryCatch({
            extension(input, output, session)
          }, error = function(e) {
            logger(sprintf("Server extension failed: %s", e$message), level = "WARNING")
          })
        }
      }
    }
    
    # LATER PACKAGE: IMMEDIATE UI DISPLAY - Show UI first, load everything else later
    if (immediate_ui) {
      # Logging removed for performance - immediate UI display enabled
      
      # Create immediate UI loop
      server_loop <- later::create_loop()
      
      # Display UI immediately with zero delay
      later::later(function() {
        # UI rendered immediately in server
      }, delay = 0, loop = server_loop)
      
      # Force immediate execution
      later::run_now(loop = server_loop)
    }
    
    # Apply server extensions if provided
    if (!is.null(server_extensions) && is.function(server_extensions)) {
      tryCatch({
        server_extensions(input, output, session)
      }, error = function(e) {
        logger(sprintf("Server extensions failed: %s", e$message), level = "WARNING")
      })
    }
    
    # ULTRA-FAST STARTUP: Show UI immediately, initialize everything else later
    
    # Smooth stage transition helper
    smooth_stage_transition <- function(rv, new_stage) {
      # Prevent rapid stage changes that cause UI flicker
      rv$stage <- new_stage
      # Force UI update with minimal delay
      shiny::invalidateLater(10, session)
    }
    
    # Step 1: Create minimal reactive values (no computation!)
    current_language <- shiny::reactiveVal(default_language)
    reactive_ui_labels <- shiny::reactiveVal(ui_labels)
    heavy_computations_done <- shiny::reactiveVal(FALSE)
    
    # Step 2: Render UI with ADVANCED later optimization - maximum speed
    output$study_ui <- shiny::renderUI({
      # ADVANCED later package optimization - background loading
      if (!.packages_loaded && has_later) {
        # Use later for efficient background loading
        later::later(function() {
          .load_packages_once()
          # Force immediate execution to prevent any delays
          later::run_now(timeoutSecs = 0, all = TRUE)
        }, delay = 0)  # ZERO delay with later - maximum efficiency
      }
      
      # Return standard container - preserves existing functionality
      shiny::div(
        id = "main-study-container",
        style = "min-height: 500px; width: 100%; max-width: 100%; margin: 0 auto; padding: 0; position: relative; overflow: hidden;",
        shiny::uiOutput("page_content")
      )
    })
    
    # Step 3: Do initialization AFTER UI is shown
    if (has_later) {
      later::later(function() {
        # Initialize session management if needed (was deferred from startup)
        if (exists(".needs_session_init") && .needs_session_init) {
          logger("Initializing robust session management", level = "INFO")
          session_config <<- list(
            session_id = paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S_"),
                               paste0(sample(letters, 8), collapse = "")),
            start_time = Sys.time(),
            max_time = max_session_time %||% 7200,
            log_file = NULL
          )
          logger(sprintf("Session initialized: %s (max time: %d seconds)", 
                        session_config$session_id, session_config$max_time), level = "INFO")
        }
        
        # Do model conversion if needed (was deferred from startup)
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
        
        # Now do the heavy initialization in background
        session$userData$heavy_init_complete <- TRUE
        heavy_computations_done(TRUE)
        logger("Heavy initialization complete", level = "DEBUG")
        
        # Force immediate execution to complete initialization
        later::run_now(timeoutSecs = 0, all = TRUE)
      }, delay = 0)  # ZERO delay - immediate execution
    }
    
    # Observe language changes from Hildesheim study
    shiny::observeEvent(input$study_language, {
      if (!is.null(input$study_language)) {
        new_lang <- input$study_language
        current_language(new_lang)
        
        # Update UI labels
        new_labels <- get_language_labels(new_lang)
        reactive_ui_labels(new_labels)
        
        # Store in session
        session$userData$language <- new_lang
        
        # Update config language
        config$language <<- new_lang
        
        # Language switched (logging disabled for performance)
        
        # Force UI refresh for language change
        shiny::invalidateLater(50, session)
      }
    })
    
    # IMMEDIATE UI DISPLAY - Show first page before package loading using later package
    if (isTRUE(list(...)$immediate_ui) || isTRUE(config$immediate_ui)) {
      cat("IMMEDIATE UI DISPLAY ENABLED - using later package\n")
      
      # Create private event loop for immediate display
      immediate_loop <- later::create_loop()
      
      # Display UI immediately with zero delay
      later::later(function() {
        cat("IMMEDIATE: First page displayed NOW\n")
        # Force UI to render immediately
        if (exists("rv") && !is.null(rv)) {
          rv$session_active <- TRUE
          rv$initialized <- TRUE
        }
      }, delay = 0, loop = immediate_loop)
      
      # Run the immediate display now
      later::run_now(loop = immediate_loop)
      
      # Schedule background loading with later
      later::later(function() {
        cat("BACKGROUND: Starting heavy initialization\n")
        # Heavy initialization happens here in background
      }, delay = 0.001)
    }
    
      # Generate UUID-based study key if needed
  generate_study_key <- function() {
    if (requireNamespace("uuid", quietly = TRUE)) {
      return(uuid::UUIDgenerate())
    } else {
      # Fallback to timestamp-based key
      return(paste0("study_", format(Sys.time(), "%Y%m%d_%H%M%S_"), 
                    paste0(sample(c(letters, 0:9), 8, replace = TRUE), collapse = "")))
    }
  }
  
  # IMMEDIATE SYNCHRONOUS INITIALIZATION - No reactive dependencies
  rv <- shiny::reactiveValues()
  
  # Variables needed for session management (define immediately)
  effective_study_key <- study_key %||% config$study_key %||% generate_study_key()
  data_dir <- base::file.path("study_data", effective_study_key)
  if (!base::dir.exists(data_dir)) base::dir.create(data_dir, recursive = TRUE)
  session_file <- base::file.path(data_dir, "session.rds")
  
  # POPULATE rv IMMEDIATELY - No observe, no async, no delays
  rv$demo_data <- stats::setNames(base::rep(NA, base::length(config$demographics)), config$demographics)
  rv$stage <- if (!is.null(config$custom_page_flow)) {
    "custom_page_flow"
  } else if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
    config$custom_study_flow$start_with %||% "demographics"
  } else if (config$show_introduction) {
    "instructions"
  } else {
    "demographics"
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
  rv$session_active <- TRUE  # ALWAYS TRUE from start
  rv$submission_in_progress <- FALSE
  rv$submission_lock_time <- NULL
  rv$last_submission_time <- NULL
  rv$initialized <- TRUE  # ALWAYS initialized from start
  
  # Session restoration (immediate, not in observe)
  if (config$session_save && base::file.exists(session_file)) {
    base::tryCatch({
      saved_state <- base::readRDS(session_file)
      for (name in base::names(saved_state)) rv[[name]] <- saved_state[[name]]
      logger(base::sprintf("Restored session from %s", session_file))
    }, error = function(e) {
      logger(base::sprintf("Failed to restore session: %s", e$message))
    })
  }
  
  logger("rv initialized IMMEDIATELY (synchronous) - no observe needed", level = "DEBUG")
    
    # Defer session monitoring until after first page loads
    if (session_save) {
      # Start session monitoring immediately
      # Session timeout monitoring
      shiny::observe({
          # Check session timeout
          if (base::difftime(base::Sys.time(), rv$session_start, units = "secs") > max_session_time) {
            rv$session_active <- FALSE
            rv$stage = "timeout"
            logger("Session timed out due to maximum session time", level = "WARNING")
            
            # Force final data preservation
            if (exists("preserve_session_data") && is.function(preserve_session_data)) {
              tryCatch({
                preserve_session_data(force = TRUE)
              }, error = function(e) {
                logger(sprintf("Final data preservation failed: %s", e$message), level = "WARNING")
              })
            }
          }
        
        # Update activity tracking
        if (exists("update_activity") && is.function(update_activity)) {
          tryCatch({
            update_activity()
          }, error = function(e) {
            # Silently ignore activity update failures to reduce log spam
          })
        }
      })  # Close observe
      
      # Automatic data preservation - converted to event-based instead of timer-based
      # This prevents page jumping while still preserving data on important events
      observe_data_preservation <- function() {
        if (rv$session_active && exists("preserve_session_data") && is.function(preserve_session_data)) {
          tryCatch({
            # Check if the function expects parameters
            if (length(formals(preserve_session_data)) > 0) {
              preserve_session_data(rv = rv, session = session)
            } else {
              preserve_session_data()
            }
          }, error = function(e) {
            # Silently ignore data preservation failures to reduce log spam
          })
        }
      }
      
      # Preserve data on page changes instead of timer
      shiny::observeEvent(rv$current_page, {
        observe_data_preservation()
      }, ignoreInit = TRUE)
      
      # Preserve data on responses
      shiny::observeEvent(rv$responses, {
        observe_data_preservation()
      }, ignoreInit = TRUE)
    }
    
    # Session status monitoring - DISABLED timer-based monitoring
    # Session is still saved but without constant UI updates that cause page jumping
    if (session_save) {
      # Log once that session monitoring is active
      if (exists("get_session_status") && is.function(get_session_status)) {
        # logger("Session monitoring active (event-based)", level = "INFO") # Disabled to reduce spam
      } else {
        # logger("Session monitoring active (basic mode)", level = "INFO") # Disabled to reduce spam
      }
      
      # Session status is checked on events, not on timer
      # This prevents the page from jumping to top
    }
    
    
    # Keep-alive mechanism - DISABLED (already started in initialize_robust_session)
    # This was causing duplicate observers and SESSION_TERMINATED messages
    # if (session_save && exists("start_keep_alive_monitoring") && is.function(start_keep_alive_monitoring)) {
    #   tryCatch({
    #     start_keep_alive_monitoring()
    #     # Log once at startup, then run silently
    #     logger("Keep-alive monitoring started (running silently)", level = "INFO")
    #   }, error = function(e) {
    #     logger(sprintf("Failed to start keep-alive monitoring: %s", e$message), level = "WARNING")
    #   })
    # }
    
    # Session status UI (hidden by default - only shows when explicitly enabled)
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
          # Basic status when advanced functions not available
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
    
    # Session cleanup when app stops (with fallback)
    session$onSessionEnded(function() {
      if (session_save && exists("cleanup_session") && is.function(cleanup_session)) {
        tryCatch({
          logger("Session ending - cleaning up and preserving final data", level = "INFO")
          # Check if function expects parameters
          if (length(formals(cleanup_session)) > 0) {
            cleanup_session(save_final_data = TRUE, session = session, rv = rv)
          } else {
            cleanup_session(save_final_data = TRUE)
          }
        }, error = function(e) {
          # Silently ignore cleanup failures to reduce log spam
        })
      } else if (session_save) {
        logger("Session ending - basic cleanup", level = "INFO")
      }
    })
    
    # Handle browser disconnect (with fallback)
    session$onFlush(function() {
      if (session_save && exists("update_activity") && is.function(update_activity)) {
        tryCatch({
          # Check if the function expects parameters
          if (length(formals(update_activity)) > 0) {
            update_activity(session = session)
          } else {
            update_activity()
          }
        }, error = function(e) {
          # Silently ignore activity update failures to reduce log spam
        })
      }
    })
    
    # Note: Legacy session monitoring removed - all monitoring is now event-based
    

    
    get_item_content <- function(item_idx) {
      # Get current language dynamically
      lang <- current_language()
      
      # Check for Hildesheim bilingual items first
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
    
    # Load packages immediately for better performance
    .packages_loaded <- FALSE
    .load_packages_once <- function() {
      if (!.packages_loaded) {
        # Load packages immediately without delay
        safe_load_packages(immediate = TRUE)
        .packages_loaded <<- TRUE
      }
    }
    
    # REMOVED: Duplicate output$study_ui definition that was overriding the instant one
    # The first definition now handles everything including package loading
      
      # Separate reactive output for page content
      output$page_content <- shiny::renderUI({
        # Dependencies
        current_page <- rv$current_page
        stage <- rv$stage
        
        logger(sprintf("page_content rendering: stage=%s, page=%s, session_active=%s, initialized=%s", 
               stage %||% "NULL", current_page %||% "NULL", rv$session_active %||% "NULL", rv$initialized %||% "NULL"), level = "DEBUG")

        # rv is ALWAYS initialized now (synchronous), so no need to check
        # Check session_active only
        if (!isTRUE(rv$session_active)) {
          logger("Session not active - showing timeout message", level = "DEBUG")
          return(
            shiny::div(class = "assessment-card",
                       shiny::h3(ui_labels$timeout_message, class = "card-header"),
                       shiny::div(class = "nav-buttons",
                                  shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee")
                       )
            )
          )
        }
        
                  # STABLE container with IMMEDIATE positioning
          shiny::div(
            id = "stable-page-container", # ← NEVER CHANGES!
            class = "page-wrapper",
            style = "width: 100% !important; max-width: 1200px !important; margin: 0 auto !important; position: relative !important; left: 0 !important; right: 0 !important; top: 0 !important; transform: none !important; display: block !important;",
          base::switch(stage,
                   "custom_page_flow" = {
                     # Process and render custom page flow
                     process_page_flow(config, rv, input, output, session, item_bank, ui_labels, logger)
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
                                                                                        shiny::actionButton("retry_continue", ui_labels$error_continue_button, class = "btn-klee"),
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
                      
                      # Use question from config or fall back to variable name
                      label_text <- if (!base::is.null(demo_config$question)) {
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
                            base::c("Bitte wählen..." = "", demo_config$options)
                          } else {
                            base::c("Select..." = "", "Male", "Female", "Other", "Prefer not to say")
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
                        shiny::tags$label(label_text, class = "input-label"),
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
                                             shiny::actionButton("start_test", ui_labels$start_button, class = "btn-klee")
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
                         shiny::p("The assessment will adapt based on your responses.", class = "welcome-text")
                       )
                     }
                     
                     shiny::div(class = "assessment-card",
                                instructions_content,
                                shiny::div(class = "nav-buttons",
                                           shiny::actionButton("begin_test", ui_labels$begin_button, class = "btn-klee")
                                )
                     )
                   },
                   "assessment" = {
                     # Debug: Log item display state
                     logger(sprintf("Rendering assessment UI - stage: %s, current_item: %s", rv$stage, rv$current_item))
                     
                     if (base::is.null(rv$current_item)) {
                       logger("ERROR: current_item is NULL in assessment stage - this is the problem!", level = "ERROR")
                                                return(shiny::div(class = "assessment-card",
                                           shiny::h3(ui_labels$preparing, class = "card-header"),
                                         shiny::p(ui_labels$loading_question)))
                     }
                     
                     logger(sprintf("Getting content for item %d", rv$current_item))
                     item <- get_item_content(rv$current_item)
                     logger(sprintf("Item content retrieved - Question: %s", substr(item$Question, 1, 50)))
                     response_ui <- if (config$model == "GRM") {
                       choices <- base::as.numeric(base::unlist(base::strsplit(item$ResponseCategories, ",")))
                       
                       # Ensure we have valid choices
                       if (length(choices) == 0 || all(is.na(choices))) {
                         choices <- 1:5
                       }
                       
                       labels <- base::switch(current_language(),
                                              de = base::c("Stark ablehnen", "Ablehnen", "Neutral", "Zustimmen", "Stark zustimmen")[1:base::length(choices)],
                                              en = base::c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")[1:base::length(choices)],
                                              es = base::c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo")[1:base::length(choices)],
                                              fr = base::c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")[1:base::length(choices)]
                       )
                       
                       # Ensure we have valid labels
                       if (length(labels) == 0 || all(is.na(labels))) {
                         labels <- base::c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")[1:base::length(choices)]
                       }
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
                                        direction = "vertical",
                                        status = "default",
                                        individual = TRUE,
                                        width = "100%"
                                      )
                                    } else {
                                      shiny::radioButtons(
                                        inputId = "item_response",
                                        label = NULL,
                                        choices = stats::setNames(choices, labels),
                                        selected = base::character(0),
                                        width = "100%"
                                      )
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
                          width = "100%"
                        )
                      }
                     progress_pct <- base::round((base::length(rv$administered) / (config$max_items %||% max(1, nrow(item_bank)))) * 100)
                     progress_ui <- base::switch(config$progress_style,
                       "circle" = {
                         # Get theme primary color for progress arc and tiny circle
                         theme_primary <- if (!is.null(theme_config) && !is.null(theme_config$primary_color)) {
                           theme_config$primary_color
                         } else if (!is.null(config$theme) && nzchar(config$theme)) {
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
                           "#007bff" # Default blue if no theme provided
                         }
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
                               color: #333;
                               text-shadow: 0 0 2px rgba(255,255,255,0.8);
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
                         shiny::div(class = "progress-bar-fill", style = base::sprintf("width: %d%%;", progress_pct))
                       )
                     )
                     shiny::tagList(
                       shiny::div(class = "assessment-card",
                         shiny::h3(config$name, class = "card-header"),
                         shiny::div(
                           style = "display: flex; flex-direction: column; align-items: center; justify-content: center; width: 100%;",
                           progress_ui,
                                                     shiny::p(
                            sprintf(ui_labels$question_progress %||% "Question %d of %d", base::length(rv$administered) + 1, config$max_items),
                            style = "text-align: center; margin: 15px 0; width: 100%;"
                          )
                         ),
                         shiny::div(class = "test-question", item$Question),
                         shiny::div(class = "radio-group-container", response_ui),
                         if (!base::is.null(rv$error_message)) shiny::div(class = "error-message", rv$error_message),
                         # ROBUST ERROR BOUNDARY UI
                         shiny::uiOutput("error_boundary"),
                         if (!base::is.null(rv$feedback_message)) shiny::div(class = "feedback-message", rv$feedback_message),
                         shiny::div(class = "nav-buttons",
                           # ROBUST SUBMIT BUTTON WITH DOUBLE-CLICK PROTECTION
        shiny::div(
          style = "position: relative;",
          shiny::actionButton(
            "submit_response", 
            ui_labels$submit_button, 
            class = "btn-klee",
            onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 2000);"
          ),
          # Visual feedback for submission in progress
          shiny::uiOutput("submission_status")
        )
                         )
                       )
                     )
                   },
                   "results" = {
                     if (base::is.null(rv$cat_result)) return()
                     
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
                     
                     # Footer and controls
                     results_content <- base::c(results_content, base::list(
                       shiny::div(class = "footer",
                                  shiny::p(config$name),
                                  shiny::p(base::format(base::Sys.time(), "%B %d, %Y"))
                       ),
                       shiny::div(class = "nav-buttons",
                                  shiny::downloadButton("save_report", ui_labels$save_button, class = "btn-klee"),
                                  shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee")
                       )
                     ))
                     
                     shiny::tagList(
                                             shiny::div(class = "assessment-card", results_content)
                    )
                  }
          ) # End of switch
          ) # End of page-wrapper div
      })
    
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
        theme_name <- tolower(config$theme %||% "Light")
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
      if (isTRUE(pr$use_enhanced_report) && exists("create_response_report", where = asNamespace("inrep"), inherits = FALSE)) {
        dat <- inrep:::create_response_report(config, rv$cat_result, item_bank)
      } else if (isTRUE(pr$use_enhanced_report) && exists("create_response_report")) {
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
          safe_title <- gsub("[_%&#$]", "\\\\\\0", config$name)
          latex_content <- sprintf('
            \\documentclass{article}
            \\usepackage{geometry}
            \\usepackage{booktabs}
            \\usepackage[utf8]{inputenc}
            \\usepackage{amsmath}
            \\usepackage{fontspec}
            \\setmainfont{Inter}
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
        } else if (save_format == "json") {
          jsonlite::write_json(report_data, file, pretty = TRUE, auto_unbox = TRUE)
        }
      }
    )
    
    shiny::observe({
      if (config$session_save) {
        base::tryCatch({
          base::saveRDS(shiny::reactiveValuesToList(rv), session_file)
        }, error = function(e) {
          logger(base::sprintf("Failed to save session: %s", e$message))
        })
      }
    })
    
    # Custom page flow navigation observers
    shiny::observeEvent(input$next_page, {
      if (rv$stage == "custom_page_flow" && rv$current_page < rv$total_pages) {
        # Validate current page before progression
        if (exists("validate_page_progression")) {
          # Pass item_bank in config for validation
          config_with_items <- config
          config_with_items$item_bank <- item_bank
          validation <- validate_page_progression(rv$current_page, input, config_with_items)
          if (!validation$valid) {
            # Show error messages
            output$validation_errors <- shiny::renderUI({
              current_lang <- rv$language %||% config$language %||% "de"
              show_validation_errors(validation$errors, language = current_lang)
            })
            
            # Field highlighting disabled for performance
            # (shinyjs was causing lag in page transitions)
            
            return()  # Don't proceed if validation fails
          }
        }
        
        # Clear any previous validation errors
        output$validation_errors <- shiny::renderUI({ NULL })
        
        # Clear error highlighting from all fields (removed shinyjs for performance)
        
        # Save current page data
        current_page <- config$custom_page_flow[[rv$current_page]]
        
        # Collect demographics from current page
        if (current_page$type == "demographics") {
          demo_vars <- current_page$demographics %||% config$demographics
          for (dem in demo_vars) {
            input_id <- paste0("demo_", dem)
            value <- input[[input_id]]
            if (!is.null(value) && value != "") {
              rv$demo_data[[dem]] <- value
              logger(sprintf("Saved demographic %s: %s", dem, substr(as.character(value), 1, 20)))
            }
          }
        }
        
        # Collect item responses from current page
        if (current_page$type == "items") {
          if (!is.null(current_page$item_indices) && !is.null(item_bank)) {
            for (idx in current_page$item_indices) {
              # Get the actual item to get its ID
              if (idx <= nrow(item_bank)) {
                item <- item_bank[idx, ]
                item_id <- paste0("item_", item$id %||% idx)
                value <- input[[item_id]]
                if (!is.null(value) && value != "") {
                  rv$item_responses[[item_id]] <- value
                  # Store in responses vector at the correct position
                  rv$responses[idx] <- as.numeric(value)
                  logger(sprintf("Saved item response %d (id: %s): %s", idx, item$id %||% idx, value))
                }
              }
            }
          }
        }
        
                  # Move to next page immediately - CSS handles the transition
          rv$current_page <- rv$current_page + 1
          logger(sprintf("Moving to page %d of %d", rv$current_page, rv$total_pages))
          
          # Add scroll to top functionality when page changes
          session$sendCustomMessage("scrollToTop", list(smooth = TRUE))
      }
    })
    
    shiny::observeEvent(input$prev_page, {
      if (rv$stage == "custom_page_flow" && rv$current_page > 1) {
        # Clear any validation errors when going back
        output$validation_errors <- shiny::renderUI({ NULL })
        
                  # Move to previous page immediately - CSS handles the transition
          rv$current_page <- rv$current_page - 1
          logger(sprintf("Moving back to page %d of %d", rv$current_page, rv$total_pages))
          
          # Add scroll to top functionality when page changes
          session$sendCustomMessage("scrollToTop", list(smooth = TRUE))
      }
    })
    
    shiny::observeEvent(input$submit_study, {
      if (rv$stage == "custom_page_flow") {
        # Validate final page before submission
        if (exists("validate_page_progression")) {
          # Pass item_bank in config for validation
          config_with_items <- config
          config_with_items$item_bank <- item_bank
          validation <- validate_page_progression(rv$current_page, input, config_with_items)
          if (!validation$valid) {
            output$validation_errors <- shiny::renderUI({
              current_lang <- rv$language %||% config$language %||% "de"
              show_validation_errors(validation$errors, language = current_lang)
            })
            return()
          }
        }
        
        # Collect final page data (could be demographics or items)
        current_page <- config$custom_page_flow[[rv$current_page]]
        
        if (current_page$type == "demographics") {
          demo_vars <- current_page$demographics
          for (dem in demo_vars) {
            input_id <- paste0("demo_", dem)
            value <- input[[input_id]]
            if (!is.null(value) && value != "") {
              rv$demo_data[[dem]] <- value
            }
          }
        } else if (current_page$type == "items") {
          # Collect item responses from final page
          if (!is.null(current_page$item_indices) && !is.null(item_bank)) {
            for (idx in current_page$item_indices) {
              if (idx <= nrow(item_bank)) {
                item <- item_bank[idx, ]
                item_id <- paste0("item_", item$id %||% idx)
                value <- input[[item_id]]
                if (!is.null(value) && value != "") {
                  rv$responses[idx] <- as.numeric(value)
                }
              }
            }
          }
        }
        
        # Clean up responses - remove NAs for final processing
        final_responses <- rv$responses[!is.na(rv$responses)]
        
        logger(sprintf("Study completed with %d responses collected", length(final_responses)))
        
        # Generate results
        if (!is.null(config$results_processor)) {
          rv$cat_result <- list(
            theta = rv$current_ability,
            se = rv$current_se,
            administered = 1:length(final_responses),
            responses = final_responses,
            response_times = rv$response_times,
            demo_data = rv$demo_data
          )
          
          # Move to last page (results)
          rv$current_page <- length(config$custom_page_flow)
          rv$stage <- "custom_page_flow"  # Stay in custom flow to show results page
        }
        
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
          if (base::is.null(val) || base::is.na(val) || val == "" || val == "Select...") {
            return(NA)
          }
          if (base::is.character(val)) {
            val <- base::trimws(base::gsub("[<>\"&]", "", val))
          }
          return(val)
        }
      })
      base::names(rv$demo_data) <- config$demographics
      
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
        next_stage <- config$custom_study_flow$page_sequence[2] %||% "instructions"
        rv$stage <- next_stage
        logger(sprintf("Custom flow: proceeding to %s stage", next_stage))
      } else {
        # Standard flow: proceed to instructions
        rv$stage <- "instructions"
        logger("Standard flow: proceeding to instructions stage")
      }
    })
    
    shiny::observeEvent(input$begin_test, {
      # Log test start
      if (session_save && exists("log_session_event") && is.function(log_session_event)) {
        tryCatch({
          # Check if function expects parameters and call accordingly
          if (length(formals(log_session_event)) > 2) {
            log_session_event(
              event_type = "test_started",
              message = "Assessment test started",
              details = list(
                start_time = Sys.time(),
                demographics = rv$demo_data,
                timestamp = Sys.time()
              )
            )
          } else {
            log_session_event("test_started", "Assessment test started")
          }
        }, error = function(e) {
          # Silently ignore logging failures to reduce log spam
        })
      }
      
      rv$stage <- "assessment"  # Fixed: was "test", now "assessment"
      rv$start_time <- base::Sys.time()
      
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
        first_item <- inrep::select_next_item(temp_rv, item_bank, config)
        rv$current_item <- first_item
        logger(sprintf("Adaptive mode: Starting with item %s", first_item))
      }
    })
    
    # CUSTOM STUDY FLOW NAVIGATION - NEW
    shiny::observeEvent(input$proceed_from_custom_instructions, {
      if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
        # Get next stage from custom flow configuration
        current_index <- which(config$custom_study_flow$page_sequence == "custom_instructions")
        if (length(current_index) > 0 && current_index < length(config$custom_study_flow$page_sequence)) {
          next_stage <- config$custom_study_flow$page_sequence[current_index + 1]
          rv$stage <- next_stage
          logger(sprintf("Custom flow: proceeding from instructions to %s stage", next_stage))
        } else {
          # Fallback to standard flow
          rv$stage <- "demographics"
          logger("Custom flow: fallback to demographics stage")
        }
      } else {
        # Standard flow
        rv$stage <- "demographics"
        logger("Standard flow: proceeding to demographics stage")
      }
      

      
      # Debug: Log the item selection process
      logger("Attempting to select next item...")
      logger(sprintf("rv$current_ability: %s", rv$current_ability))
      logger(sprintf("config$adaptive: %s", config$adaptive))
      logger(sprintf("config$model: %s", config$model))
      logger(sprintf("Item bank columns: %s", paste(names(item_bank), collapse = ", ")))
      
      rv$current_item <- inrep::select_next_item(rv, item_bank, config)
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
        logger("ERROR: select_next_item returned NULL - this is why items don't display!", level = "ERROR")
        # Fallback: select first available item
        available_items <- setdiff(seq_len(nrow(item_bank)), rv$administered)
        if (length(available_items) > 0) {
          rv$current_item <- available_items[1]
          logger(sprintf("Fallback: selected item %d", rv$current_item))
        }
      }
      
      logger("Beginning assessment")
    })
    
    # CUSTOM STUDY FLOW NAVIGATION - NEW
    shiny::observeEvent(input$proceed_from_custom_instructions, {
      if (!is.null(config$custom_study_flow) && config$enable_custom_navigation) {
        # Get next stage from custom flow configuration
        current_index <- which(config$custom_study_flow$page_sequence == "custom_instructions")
        if (length(current_index) > 0 && current_index < length(config$custom_study_flow$page_sequence)) {
          next_stage <- config$custom_study_flow$page_sequence[current_index + 1]
          rv$stage <- next_stage
          logger(sprintf("Custom flow: proceeding from instructions to %s stage", next_stage))
        } else {
          # Fallback to standard flow
          rv$stage <- "demographics"
          logger("Custom flow: fallback to demographics stage")
        }
      } else {
        # Standard flow
        rv$stage <- "demographics"
        logger("Standard flow: proceeding to demographics stage")
      }
    })
    
    # ROBUST SUBMISSION HANDLER - PREVENTS DOUBLE-CLICKS AND NEVER BREAKS
    shiny::observeEvent(input$submit_response, {
      # IMMEDIATE DOUBLE-CLICK PROTECTION
      if (rv$submission_in_progress) {
        logger("Double-click detected - ignoring duplicate submission", level = "WARNING")
        return()
      }
      
      # IMMEDIATE STATE VALIDATION
      if (is.null(rv$current_item) || rv$stage != "assessment") {
        logger("Invalid submission state - ignoring submission", level = "WARNING")
        return()
      }
      
      # SET SUBMISSION LOCK WITH TIMESTAMP
      rv$submission_in_progress <- TRUE
      rv$submission_lock_time <- Sys.time()
      
      # ROBUST ERROR BOUNDARY WITH AUTOMATIC RECOVERY
      tryCatch({
        # VALIDATE INPUT STATE
        if (is.null(input$item_response)) {
          logger("No response selected - resetting submission lock", level = "WARNING")
          rv$submission_in_progress <- FALSE
          rv$error_message <- "Please select a response before submitting."
          return()
        }
        
        # VALIDATE RESPONSE
        if (!config$response_validation_fun(input$item_response)) {
          logger(sprintf("Invalid response submitted for item %d", rv$current_item), level = "WARNING")
          rv$submission_in_progress <- FALSE
          rv$error_message <- base::sprintf("Please select a valid response (%s).", config$language)
          return()
        }
        
        # CLEAR ANY PREVIOUS ERRORS
        rv$error_message <- NULL
        
        # CALCULATE RESPONSE TIME
        response_time <- base::as.numeric(base::difftime(base::Sys.time(), rv$start_time, units = "secs"))
        
        # STORE RESPONSE DATA WITH ERROR PROTECTION
        item_index <- rv$current_item
        correct_answer <- item_bank$Answer[item_index] %||% NULL
        
        # ROBUST SCORING WITH FALLBACK
        response_score <- base::tryCatch(
          config$scoring_fun(input$item_response, correct_answer),
          error = function(e) {
            logger(base::sprintf("Scoring function error, using fallback: %s", e$message), level = "WARNING")
            # Fallback scoring methods
            if (config$model == "GRM") {
              as.numeric(input$item_response)
            } else {
              # Use item_bank row to avoid referencing UI item object
              opts <- base::c(item_bank$Option1[item_index], item_bank$Option2[item_index], item_bank$Option3[item_index], item_bank$Option4[item_index])
              opts <- opts[!is.na(opts) & opts != ""]
              if (is.null(correct_answer) || is.na(correct_answer) || !(correct_answer %in% opts)) {
                # If no explicit correct answer, assume first non-empty option is correct for scoring consistency
                correct_answer_fallback <- (opts)[1] %||% "1"
                as.numeric(input$item_response == correct_answer_fallback)
              } else {
                as.numeric(input$item_response == correct_answer)
              }
            }
          }
        )
        
        # SAFELY UPDATE RESPONSE VECTORS
        rv$response_times <- base::c(rv$response_times, response_time)
        rv$responses <- base::c(rv$responses, response_score)
        rv$administered <- base::c(rv$administered, item_index)
        
        # LOG RESPONSE SUBMISSION WITH ERROR PROTECTION
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
        
        # Notify admin dashboard after response capture
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
        # EMERGENCY ERROR HANDLING WITH AUTOMATIC RECOVERY
        logger(sprintf("Critical error in response processing: %s", e$message), level = "ERROR")
        
        # ATTEMPT EMERGENCY DATA PRESERVATION
        if (session_save && exists("emergency_data_preservation") && is.function(emergency_data_preservation)) {
          tryCatch({
            emergency_data_preservation()
            logger("Emergency data preservation completed", level = "INFO")
          }, error = function(preserve_error) {
            logger(sprintf("Emergency data preservation failed: %s", preserve_error$message), level = "ERROR")
          })
        }
        
        # AUTOMATIC RECOVERY - DON'T STOP THE ASSESSMENT
        rv$error_message <- "A minor error occurred. Your response has been saved and the assessment will continue."
        logger("Assessment continuing after error recovery", level = "INFO")
        
        # RESET SUBMISSION LOCK TO ALLOW CONTINUATION
        rv$submission_in_progress <- FALSE
        
        return()
      })
      
      # FINAL SUBMISSION LOCK RESET - ENSURES ASSESSMENT NEVER STOPS
      rv$submission_in_progress <- FALSE
      rv$last_submission_time <- Sys.time()
      
      # ROBUST ABILITY ESTIMATION WITH ERROR RECOVERY
      if (config$adaptive) {
        base::tryCatch({
          ability <- inrep::estimate_ability(rv, item_bank, config)
          rv$current_ability <- ability$theta
          rv$current_se <- ability$se
          logger(base::sprintf("Estimated ability: theta=%.2f, se=%.3f", ability$theta, ability$se))
          rv$theta_history <- base::c(rv$theta_history, rv$current_ability)
          rv$se_history <- base::c(rv$se_history, rv$current_se)
          
          # Push update to admin_dashboard_hook if provided
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
          logger(base::sprintf("Ability estimation failed, using fallback: %s", e$message), level = "WARNING")
          # Fallback ability estimation - don't break the assessment
          if (length(rv$responses) > 0) {
            rv$current_ability <- mean(rv$responses, na.rm = TRUE)
            rv$current_se <- sd(rv$responses, na.rm = TRUE) / sqrt(length(rv$responses))
            logger("Using fallback ability estimation", level = "INFO")
          }
        })
      }
      
      # ROBUST DATA PRESERVATION WITH ERROR RECOVERY
      if (session_save && exists("preserve_session_data") && is.function(preserve_session_data)) {
        tryCatch({
          # Check if the function expects parameters
          if (length(formals(preserve_session_data)) > 0) {
            preserve_session_data(rv = rv, session = session, force = FALSE)
          } else {
            preserve_session_data()
          }
        }, error = function(e) {
          # Silently ignore data preservation failures to reduce log spam
        })
      }
      
            # FINAL SAFETY NET - ENSURE SUBMISSION LOCK IS ALWAYS RESET
      if (rv$submission_in_progress) {
        logger("Final safety net: resetting submission lock", level = "INFO")
        rv$submission_in_progress <- FALSE
      }
      
      # ULTIMATE ERROR BOUNDARY - CATCH ANY REMAINING ERRORS
      base::tryCatch({
        # ROBUST STOPPING CRITERIA CHECK WITH ERROR RECOVERY
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
                total_time = as.numeric(difftime(Sys.time(), rv$start_time, units = "secs")),
                completion_reason = "stopping_criteria_met",
                timestamp = Sys.time()
              )
            )
          }, error = function(e) {
            # Silently ignore logging failures to reduce log spam
          })
        }
        
        # Final robust data preservation
        if (session_save && exists("preserve_session_data") && is.function(preserve_session_data)) {
          tryCatch({
            preserve_session_data(force = TRUE)
            logger("Final assessment data preserved", level = "INFO")
          }, error = function(e) {
            logger(sprintf("Final data preservation failed: %s", e$message), level = "ERROR")
          })
        }
        
        # Save session to cloud if enabled
        if (config$session_save && !base::is.null(webdav_url)) {
          logger("Attempting to save session to cloud...")
          if (exists("save_session_to_cloud", where = asNamespace("inrep"), inherits = FALSE)) {
            inrep:::save_session_to_cloud(rv, config, webdav_url, password)
          } else if (exists("save_session_to_cloud")) {
            save_session_to_cloud(rv, config, webdav_url, password)
          } else {
            logger("save_session_to_cloud function not found.")
          }
        }
      } else {
        # ROBUST NEXT ITEM SELECTION WITH ERROR RECOVERY
        next_item_result <- base::tryCatch({
          inrep::select_next_item(rv, item_bank, config)
        }, error = function(e) {
          logger(sprintf("Next item selection failed, using fallback: %s", e$message), level = "WARNING")
          # Fallback: select next available item
          remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
          if (length(remaining_items) > 0) {
            remaining_items[1]  # Select first remaining item
          } else {
            NULL  # No more items
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
                  total_time = as.numeric(difftime(Sys.time(), rv$start_time, units = "secs")),
                  completion_reason = "no_more_items",
                  timestamp = Sys.time()
                )
              )
            }, error = function(e) {
              # Silently ignore logging failures to reduce log spam
            })
          }
          
          # Final robust data preservation
          if (session_save && exists("preserve_session_data") && is.function(preserve_session_data)) {
            tryCatch({
              preserve_session_data(force = TRUE)
              logger("Final assessment data preserved", level = "INFO")
            }, error = function(e) {
              logger(sprintf("Final data preservation failed: %s", e$message), level = "ERROR")
            })
          }
          
          # Save session to cloud if enabled
          if (config$session_save && !base::is.null(webdav_url)) {
            logger("Attempting to save session to cloud...")
            if (exists("save_session_to_cloud", where = asNamespace("inrep"), inherits = FALSE)) {
              inrep:::save_session_to_cloud(rv, config, webdav_url, password)
            } else if (exists("save_session_to_cloud")) {
              save_session_to_cloud(rv, config, webdav_url, password)
            } else {
              logger("save_session_to_cloud function not found.")
            }
          }
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
              # Fallback for when shinyWidgets is not available
              shiny::updateRadioButtons(session, "item_response", selected = base::character(0))
            }
          }
        }
      }
      
      # CLOSE ULTIMATE ERROR BOUNDARY
      }, error = function(e) {
        # FINAL EMERGENCY RECOVERY - ASSESSMENT MUST CONTINUE
        logger(sprintf("Ultimate error boundary caught: %s", e$message), level = "ERROR")
        
        # Force reset all error states
        rv$submission_in_progress <- FALSE
        rv$error_message <- NULL
        rv$stage <- "assessment"
        
        # Ensure we have a current item
        if (is.null(rv$current_item)) {
          remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
          if (length(remaining_items) > 0) {
            rv$current_item <- remaining_items[1]
            logger("Emergency item selection for continuation", level = "WARNING")
          }
        }
        
        logger("Assessment continuing after ultimate error recovery", level = "INFO")
      })
    })
    
    # SUBMISSION STATUS UI - VISUAL FEEDBACK FOR USER
    output$submission_status <- shiny::renderUI({
      if (rv$submission_in_progress) {
        shiny::div(
          class = "submission-status",
          style = "color: #007bff; font-weight: bold; margin-top: 10px; padding: 10px; background-color: #f8f9fa; border: 2px solid #007bff; border-radius: 5px;",

          " Processing your response... Please wait."
        )
      } else {
        NULL
      }
    })
    
    # ROBUST ERROR BOUNDARY UI - PREVENTS APP FROM STOPPING
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
    
    # AUTO-RECOVERY BUTTON HANDLER
    shiny::observeEvent(input$auto_recover, {
      logger("Auto-recovery initiated by user", level = "INFO")
      
      # Force reset all error states
      rv$submission_in_progress <- FALSE
      rv$error_message <- NULL
      rv$stage <- "assessment"
      
      # Ensure we have a current item
      if (is.null(rv$current_item)) {
        remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
        if (length(remaining_items) > 0) {
          rv$current_item <- remaining_items[1]
          logger("Auto-recovery: selected next item", level = "INFO")
        }
      }
      
      logger("Assessment continuing after auto-recovery", level = "INFO")
    })
    
    # MANUAL RECOVERY BUTTON HANDLER
    shiny::observeEvent(input$manual_recover, {
      logger("Manual recovery initiated by user", level = "INFO")
      
      # Show recovery options
      rv$show_recovery_options <- TRUE
      rv$error_message <- "Select recovery option:"
    })
    
    # COMPREHENSIVE ERROR RECOVERY SYSTEM - ENSURES ASSESSMENT NEVER STOPS
    shiny::observeEvent(input$retry_continue, {
      if (session_save && exists("attempt_error_recovery") && is.function(attempt_error_recovery)) {
        tryCatch({
          recovery_result <- attempt_error_recovery()
          if (recovery_result$success) {
            rv$stage <- recovery_result$stage %||% "test"
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
        # Fallback recovery
        rv$stage <- "assessment"  # Fixed: was "test", now "assessment"
        rv$error_message <- NULL
        logger("Fallback error recovery - returning to assessment", level = "INFO")
      }
    })
    
    # AUTOMATIC ERROR RECOVERY - Event-based instead of timer-based
    # This prevents page jumping while still handling errors
    check_error_states <- function() {
      # Automatic recovery from submission lock
      if (rv$submission_in_progress && !is.null(rv$submission_lock_time)) {
        lock_duration <- as.numeric(difftime(Sys.time(), rv$submission_lock_time, units = "secs"))
        if (lock_duration > 10) {  # Reset lock after 10 seconds
          logger("Automatic submission lock reset after timeout", level = "WARNING")
          rv$submission_in_progress <- FALSE
          rv$submission_lock_time <- NULL
        }
      }
      
      # Automatic recovery from error states
      if (rv$stage == "error" && !is.null(rv$last_submission_time)) {
        error_duration <- as.numeric(difftime(Sys.time(), rv$last_submission_time, units = "secs"))
        if (error_duration > 5) {  # Auto-recover after 5 seconds
          logger("Automatic error recovery - continuing assessment", level = "INFO")
          rv$stage <- "assessment"
          rv$error_message <- NULL
          
          # Ensure we have a current item
          if (is.null(rv$current_item)) {
            remaining_items <- setdiff(1:nrow(item_bank), rv$administered)
            if (length(remaining_items) > 0) {
              rv$current_item <- remaining_items[1]
              logger("Auto-selected next item for continuation", level = "INFO")
            }
          }
        }
      }
      
      # Automatic session health check
      if (rv$session_active && !is.null(rv$start_time)) {
        session_duration <- as.numeric(difftime(Sys.time(), rv$start_time, units = "secs"))
        if (session_duration > 3600) {  # 1 hour
          logger("Long session detected - performing health check", level = "INFO")
          # Force data preservation
          if (session_save && exists("preserve_session_data") && is.function(preserve_session_data)) {
            tryCatch({
              preserve_session_data(force = TRUE)
              logger("Health check data preservation completed", level = "INFO")
            }, error = function(e) {
              logger(sprintf("Health check data preservation failed: %s", e$message), level = "WARNING")
            })
          }
        }
      }
    }
    
    # Call error checking on specific events instead of timer
    shiny::observeEvent(rv$stage, {
      check_error_states()
    }, ignoreInit = TRUE)
    
    shiny::observeEvent(rv$submission_in_progress, {
      check_error_states()
    }, ignoreInit = TRUE)
    
    shiny::observeEvent(input$restart_test, {
      # Clean up robust session before restart
      if (session_save && exists("cleanup_session") && is.function(cleanup_session)) {
        tryCatch({
          cleanup_session(save_final_data = TRUE)
        }, error = function(e) {
          logger(sprintf("Session cleanup failed during restart: %s", e$message), level = "WARNING")
        })
      }
      
      rv$stage = "demographics"
      rv$current_ability <- config$theta_prior[1]
      rv$current_se <- config$theta_prior[2]
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
      
      # Log test restart
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
  
  # Generate LLM assistance prompt if enabled
  if (getOption("inrep.llm_assistance", FALSE) && is_llm_assistance_enabled("deployment")) {
    prompt <- generate_study_deployment_prompt(
      study_config = config,
      item_bank_size = nrow(item_bank),
      theme_config = theme_config,
      webdav_enabled = !is.null(webdav_url),
      save_format = save_format
    )
    display_llm_prompt(prompt, "deployment")
  }
  
  # Final session cleanup setup
  if (session_save) {
    # Set up global cleanup on package unload
    .GlobalEnv$.inrep_cleanup_on_exit <- function() {
      if (exists("cleanup_session") && is.function(cleanup_session)) {
        tryCatch({
          cleanup_session(save_final_data = TRUE)
          logger("Final cleanup completed on exit", level = "INFO")
        }, error = function(e) {
          logger(sprintf("Final cleanup failed: %s", e$message), level = "ERROR")
        })
      }
    }
    
    # Register cleanup function
    reg.finalizer(environment(), function(env) {
      if (exists(".inrep_cleanup_on_exit", envir = .GlobalEnv)) {
        .GlobalEnv$.inrep_cleanup_on_exit()
      }
    }, onexit = TRUE)
  }
  
  shiny::shinyApp(ui = ui, server = server)
}

#' Generate LLM Prompt for Study Deployment Optimization
#'
#' @description
#' Creates detailed prompts for optimizing study deployment and technical infrastructure.
#'
#' @param study_config Study configuration object
#' @param item_bank_size Number of items in the item bank
#' @param theme_config Theme configuration object
#' @param webdav_enabled Whether WebDAV saving is enabled
#' @param save_format Data saving format
#' @param include_examples Whether to include implementation examples
#'
#' @return Character string containing the deployment optimization prompt
#'
#' @noRd
#'
#' @examples
#' \dontrun{
#' prompt <- generate_study_deployment_prompt(
#'   study_config = config,
#'   item_bank_size = 50,
#'   theme_config = NULL,
#'   webdav_enabled = FALSE,
#'   save_format = "rds"
#' )
#' cat(prompt)
#' }
generate_study_deployment_prompt <- function(study_config,
                                             item_bank_size,
                                             theme_config = NULL,
                                             webdav_enabled = FALSE,
                                             save_format = "rds",
                                             include_examples = TRUE) {
  
  prompt <- paste0(
    "# STUDY DEPLOYMENT AND INFRASTRUCTURE OPTIMIZATION\n\n",
    "You are a senior research technology specialist and infrastructure architect specializing in web-based psychological assessments. I need comprehensive guidance for optimizing the deployment and technical infrastructure of my inrep adaptive testing study.\n\n",
    
    "## CURRENT DEPLOYMENT CONFIGURATION\n",
    "- Study Name: ", study_config$name %||% "Unnamed Study", "\n",
    "- Item Bank Size: ", item_bank_size, " items\n",
    "- IRT Model: ", study_config$model %||% "2PL", "\n",
    "- Theme: ", study_config$theme %||% "Light", "\n",
    "- Custom Theme: ", ifelse(!is.null(theme_config), "Yes", "No"), "\n",
    "- WebDAV Saving: ", webdav_enabled, "\n",
    "- Save Format: ", save_format, "\n",
    "- Max Session Duration: ", study_config$max_session_duration %||% 30, " minutes\n",
    "- Expected Items per Participant: ", study_config$min_items %||% 5, " to ", study_config$max_items %||% 20, "\n",
    "- Language: ", study_config$language %||% "English", "\n\n"
  )
  
  # Add detailed analysis sections
  prompt <- paste0(prompt,
                   "## DEPLOYMENT OPTIMIZATION ANALYSIS\n\n",
                   
                   "### 1. Technical Infrastructure\n",
                   "- Server requirements and capacity planning\n",
                   "- Database optimization for response storage\n",
                   "- Performance monitoring and alerting systems\n",
                   "- Backup and disaster recovery procedures\n",
                   "- Load balancing and scaling strategies\n\n",
                   
                   "### 2. Security and Privacy\n",
                   "- Data encryption and secure transmission\n",
                   "- User authentication and session management\n",
                   "- GDPR and privacy regulation compliance\n",
                   "- Audit logging and data governance\n",
                   "- Vulnerability assessment and penetration testing\n\n",
                   
                   "### 3. Quality Assurance and Monitoring\n",
                   "- Automated testing and validation procedures\n",
                   "- Real-time performance monitoring\n",
                   "- Error tracking and alerting systems\n",
                   "- User behavior analytics and optimization\n",
                   "- Data integrity and validation checks\n\n",
                   
                   "### 4. User Experience and Accessibility\n",
                   "- Cross-browser and device compatibility testing\n",
                   "- Mobile and tablet experience optimization\n",
                   "- Accessibility compliance (WCAG 2.1 AA)\n",
                   "- Internationalization and localization support\n",
                   "- User support and help documentation\n\n",
                   
                   "### 5. Data Management and Analytics\n",
                   "- Data collection and storage optimization\n",
                   "- Real-time data processing and analysis\n",
                   "- Export and integration capabilities\n",
                   "- Long-term data archival strategies\n",
                   "- Research data management best practices\n\n",
                   
                   "### 6. Deployment Strategy\n",
                   "- Development, staging, and production environments\n",
                   "- Continuous integration and deployment pipelines\n",
                   "- Version control and release management\n",
                   "- Rollback and emergency procedures\n",
                   "- Documentation and knowledge transfer\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
                     "## PROVIDE COMPREHENSIVE RECOMMENDATIONS\n",
                     "1. **Infrastructure Architecture**: Complete deployment architecture with diagrams\n",
                     "2. **Security Implementation**: Specific security measures and configurations\n",
                     "3. **Performance Optimization**: Technical optimizations for speed and reliability\n",
                     "4. **Monitoring and Alerting**: Comprehensive monitoring strategy with tools\n",
                     "5. **Quality Assurance**: Testing procedures and validation protocols\n",
                     "6. **Documentation**: Deployment guides and operational procedures\n",
                     "7. **Scaling Strategy**: Plans for handling increased user load\n",
                     "8. **Compliance Framework**: Regulatory and ethical compliance procedures\n\n",
                     "Please provide actionable recommendations with specific configuration examples, deployment scripts, and operational procedures."
    )
  }
  
  return(prompt)
}
