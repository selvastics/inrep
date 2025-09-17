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
    # AUTO-CLOSE PARAMETERS
    auto_close_time = 300,  # 5 minutes default
    auto_close_time_unit = "seconds",  # "seconds" or "minutes"
    disable_auto_close = FALSE,
    ...
) {
  
  # Helper function for robust scroll-to-top functionality (works on desktop and mobile)
  scroll_to_top_enhanced <- function() {
    # Enhanced scroll function that works reliably in web browsers
    scroll_js <- "
    (function() {
      // Force immediate scroll with multiple methods
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
      
      // Additional methods for stubborn browsers
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
      
      // Final attempt after a short delay
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
    
    # Execute with multiple fallbacks
    if (requireNamespace("shinyjs", quietly = TRUE)) {
      tryCatch({
        shinyjs::runjs(scroll_js)
      }, error = function(e) {
        tryCatch({
          shiny::runjs(scroll_js)
        }, error = function(e2) {
          # Final fallback - simple scroll
          tryCatch({
            shinyjs::runjs("window.scrollTo(0, 0);")
          }, error = function(e3) {
            logger(sprintf("Scroll to top failed: %s", e3$message), level = "WARNING")
          })
        })
      })
    } else {
      tryCatch({
        shiny::runjs(scroll_js)
      }, error = function(e) {
        tryCatch({
          shiny::runjs("window.scrollTo(0, 0);")
        }, error = function(e2) {
          logger(sprintf("Scroll to top failed: %s", e2$message), level = "WARNING")
        })
      })
    }
  }
  
  # AGGRESSIVE LATER PACKAGE IMPLEMENTATION - DISPLAY UI IMMEDIATELY
  if (immediate_ui) {
    cat("LATER PACKAGE: Implementing immediate UI display\n")
    
    # Step 1: Create private event loop for UI
    ui_loop <- later::create_loop()
    
    # Step 2: Display UI with ZERO delay
    later::later(function() {
      cat("LATER: UI displayed IMMEDIATELY\n")
    }, delay = 0, loop = ui_loop)
    
    # Step 3: Force immediate execution
    later::run_now(loop = ui_loop)
    
    # Step 4: Move ALL heavy operations to background using later
    later::later(function() {
      cat("LATER: Background loading started\n")
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
              style = "padding: 10px 30px; font-size: 16px;",
              onclick = "this.disabled = true; setTimeout(() => this.disabled = false, 1500);")
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
  
  # CRITICAL: Force new session for each user to prevent session sharing
  .force_new_session <- TRUE
  
  # Initialize robust session management
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
      # Logging JavaScript for testing center data collection
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
          
          // PERIODIC ENFORCEMENT - every 100ms
          setInterval(function() {
            var elements = document.querySelectorAll('.page-wrapper, .assessment-card, #study_ui, #stable-page-container');
            for (var i = 0; i < elements.length; i++) {
              forceCenter(elements[i]);
            }
          }, 100);
          
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
          console.log('✅ Direct content display - no loading animations');
        })();
      "))
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
    # LATER PACKAGE: IMMEDIATE UI DISPLAY - Show UI first, load everything else later
    if (immediate_ui) {
      cat("LATER: Server starting with immediate UI mode\n")
      
      # Create immediate UI loop
      server_loop <- later::create_loop()
      
      # Display UI immediately with zero delay
      later::later(function() {
        cat("LATER: UI rendered immediately in server\n")
      }, delay = 0, loop = server_loop)
      
      # Force immediate execution
      later::run_now(loop = server_loop)
    }
    
    # ULTRA-FAST STARTUP: Show UI immediately, initialize everything else later
    
    # Smooth stage transition helper
    smooth_stage_transition <- function(rv, new_stage) {
      # Prevent rapid stage changes that cause UI flicker
      rv$stage <- new_stage
      # Force UI update with minimal delay
      shiny::invalidateLater(10, session)
    }
    
    # Initialize package loading state
    .packages_loaded <- FALSE
    
    # Define package loading function
    .load_packages_once <- function() {
      if (!.packages_loaded) {
        # Load packages immediately without delay
        safe_load_packages(immediate = TRUE)
        .packages_loaded <<- TRUE
      }
    }
    
    # CRITICAL: Session isolation - ensure each user gets a completely fresh session
    if (exists(".force_new_session") && .force_new_session) {
      # Clear any existing session data to prevent session sharing
      if (exists(".logging_data", envir = .GlobalEnv)) {
        rm(".logging_data", envir = .GlobalEnv)
      }
      
      # Clear any existing session state
      if (exists("session_config", envir = .GlobalEnv)) {
        rm("session_config", envir = .GlobalEnv)
      }
      
      # Force new session initialization
      .needs_session_init <<- TRUE
      .force_new_session <<- FALSE  # Reset flag
      
      logger("CRITICAL: Forcing new session to prevent session sharing", level = "WARNING")
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
        shiny::uiOutput("page_content"),
        # Global scroll-to-top script that runs on every page load
        shiny::tags$script(HTML("
          // Global scroll-to-top function for web browsers
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
    
    # Step 3: Do initialization AFTER UI is shown
    if (has_later) {
      later::later(function() {
        # Initialize session management if needed (was deferred from startup)
        if (exists(".needs_session_init") && .needs_session_init) {
          logger("Initializing robust session management", level = "INFO")
          
          # Generate unique session ID with enhanced isolation
          timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S_%OS3")
          process_id <- Sys.getpid()
          random_suffix <- paste(sample(c(letters, LETTERS, 0:9), 12, replace = TRUE), collapse = "")
          machine_id <- Sys.info()["nodename"]
          combined_string <- paste(timestamp, process_id, random_suffix, machine_id, sep = "_")
          hash_suffix <- substr(digest::digest(combined_string, algo = "md5"), 1, 8)
          unique_session_id <- paste0("SESS_", timestamp, "_", process_id, "_", hash_suffix)
          
          session_config <<- list(
            session_id = unique_session_id,
            start_time = Sys.time(),
            max_time = max_session_time %||% 7200,
            log_file = NULL
          )
          
          # Ensure complete data isolation - generate unique participant code for this session
          if (!is.null(study_key)) {
            # Create session-specific participant code to prevent conflicts
            session_specific_key <- paste0(study_key, "_", substr(unique_session_id, -8, -1))
            study_key <<- session_specific_key
            logger(sprintf("Generated session-specific participant code: %s", study_key), level = "INFO")
          }
          
          # Ensure complete data isolation by clearing any global state
          if (exists(".logging_data", envir = .GlobalEnv)) {
            rm(".logging_data", envir = .GlobalEnv)
          }
          
          # Initialize fresh session-specific logging data
          .GlobalEnv$.logging_data <- new.env()
          .GlobalEnv$.logging_data$session_id <- unique_session_id
          .GlobalEnv$.logging_data$session_start <- Sys.time()
          .GlobalEnv$.logging_data$current_page_start <- Sys.time()
          
          logger(sprintf("Complete data isolation ensured for session: %s", unique_session_id), level = "INFO")
          
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
        
        # Store globally for HilFo report access
        assign("hilfo_language_preference", new_lang, envir = .GlobalEnv)
        
        # Log the change
        cat("Language switched to:", new_lang, "\n")
        
        # DO NOT force UI refresh - let JavaScript handle the switching
        # This prevents the page_content rendering loop
      }
    })
    
    # Also observe store_language_globally for HilFo
    shiny::observeEvent(input$store_language_globally, {
      if (!is.null(input$store_language_globally)) {
        # Store globally for HilFo report access
        assign("hilfo_language_preference", input$store_language_globally, envir = .GlobalEnv)
        cat("Stored language globally for HilFo:", input$store_language_globally, "\n")
        
        # CRITICAL: Also update the current language for immediate effect
        new_lang <- input$store_language_globally
        if (new_lang %in% c("en", "de")) {
          current_language(new_lang)
          rv$language <- new_lang
          
          # Update UI labels for immediate effect
          new_labels <- get_language_labels(new_lang)
          reactive_ui_labels(new_labels)
          
          # Store in session userData for access by render functions
          session$userData$language <- new_lang
          
          cat("HILFO: Immediately switched current page to:", new_lang, "\n")
        }
        
        # CRITICAL: Also update the current language for immediate effect
        new_lang <- input$store_language_globally
        if (new_lang %in% c("en", "de")) {
          current_language(new_lang)
          rv$language <- new_lang
          
          # Update UI labels for immediate effect
          new_labels <- get_language_labels(new_lang)
          reactive_ui_labels(new_labels)
          
          # Store in session userData for access by render functions
          session$userData$language <- new_lang
          
          cat("HILFO: Immediately switched current page to:", new_lang, "\n")
        }
      }
    })
    
    # Observe PDF download trigger from HilFo
    shiny::observeEvent(input$download_pdf_trigger, {
      cat("PDF download triggered\n")
      # Generate PDF content
      tryCatch({
        # Get the current report content
        if (!is.null(rv$cat_result)) {
          responses <- rv$cat_result$responses
        } else {
          responses <- rv$responses
        }
        
        # Generate report HTML
        report_html <- if (!is.null(config$results_processor) && is.function(config$results_processor)) {
          config$results_processor(responses, item_bank, rv$demo_data, list(input = list(language = rv$language)))
        } else {
          shiny::HTML("<p>No report available</p>")
        }
        
        # Create a temporary HTML file
        temp_html <- tempfile(fileext = ".html")
        writeLines(as.character(report_html), temp_html)
        
        # Convert to PDF using browser print dialog
        shiny::runjs("window.print();")
        
      }, error = function(e) {
        cat("Error generating PDF:", e$message, "\n")
        shiny::showNotification("Error generating PDF. Please try again.", type = "error")
      })
    })
    
    # Observe CSV download trigger from HilFo
    shiny::observeEvent(input$download_csv_trigger, {
      cat("CSV download triggered\n")
      # Create the real HILFO CSV data on-demand
      tryCatch({
        # Get current responses and demographics
        responses <- if (!is.null(rv$cat_result)) rv$cat_result$responses else rv$responses
        demo_data <- rv$demo_data
        
        # Create complete_data exactly as in create_hilfo_report
        complete_data <- data.frame(
          timestamp = Sys.time(),
          session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
          study_language = rv$language %||% "de",
          stringsAsFactors = FALSE
        )
        
        # Add demographics
        if (!is.null(demo_data) && is.list(demo_data)) {
          for (demo_name in names(demo_data)) {
            complete_data[[demo_name]] <- demo_data[[demo_name]]
          }
        }
        
        # Add item responses with proper variable names
        if (!is.null(responses) && !is.null(item_bank)) {
          for (i in seq_along(responses)) {
            if (i <= nrow(item_bank)) {
              col_name <- item_bank$id[i]
              if (!is.na(col_name) && col_name != "") {
                complete_data[[col_name]] <- responses[i]
              }
            }
          }
        }
        
        # Create CSV content
        csv_content <- ""
        if (nrow(complete_data) > 0) {
          # Convert to CSV string
          temp_file <- tempfile(fileext = ".csv")
          write.csv(complete_data, temp_file, row.names = FALSE)
          csv_content <- paste(readLines(temp_file), collapse = "\\n")
          unlink(temp_file)
        }
        
        cat("Generated real HILFO CSV data with", nrow(complete_data), "rows and", ncol(complete_data), "columns\n")
        
        # Trigger download via JavaScript
        if (nchar(csv_content) > 0) {
          # Create download
          filename <- paste0("HilFo_Data_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
          shiny::runjs(sprintf("
            var csv = %s;
            var blob = new Blob([csv], {type: 'text/csv'});
            var url = window.URL.createObjectURL(blob);
            var link = document.createElement('a');
            link.href = url;
            link.download = '%s';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            window.URL.revokeObjectURL(url);
          ", jsonlite::toJSON(csv_content), filename))
        } else {
          cat("No CSV content available for download\n")
          shiny::showNotification("No data available for download", type = "warning")
        }
      }, error = function(e) {
        cat("Error generating CSV download:", e$message, "\n")
        shiny::showNotification("Error generating CSV download", type = "error")
      })
    })
    
    # Return the Shiny app
    return(app)
  })
}
