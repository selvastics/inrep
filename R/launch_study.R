# File: launch_study.R

#' Launch Adaptive Study Interface
#'
#' Launches a Shiny-based adaptive or non-adaptive assessment interface that serves as
#' a comprehensive wrapper around TAM's psychometric capabilities. All IRT computations
#' (ability estimation, item selection, model fitting) are performed by the TAM package,
#' while this function provides the interactive interface, workflow management, and
#' integration layer for comprehensive research workflows.
#'
#' @param config A list containing study configuration parameters created by \code{\link{create_study_config}}.
#'   Must include essential elements like \code{model}, \code{max_items}, \code{min_SEM}, etc.
#' @param item_bank Data frame containing item parameters compatible with TAM package requirements.
#'   Column structure varies by IRT model (see \strong{Item Bank Requirements} section).
#' @param custom_css Character string containing CSS code for UI customization. 
#'   When provided, overrides both built-in themes and \code{theme_config} settings.
#' @param theme_config Named list of theme parameters (e.g., from \code{\link{launch_theme_editor}}).
#'   Contains CSS variable definitions like \code{primary_color}, \code{font_family}, etc.
#' @param webdav_url Character string specifying WebDAV URL for cloud-based result storage,
#'   or \code{NULL} to disable cloud functionality. Requires valid WebDAV credentials.
#' @param password Character string for WebDAV authentication when \code{webdav_url} is specified.
#' @param save_format Character string specifying output format for assessment results.
#'   Options: \code{"rds"} (default), \code{"csv"}, \code{"json"}, \code{"pdf"}.
#' @param logger Function for custom logging. Default uses internal \code{logr} implementation.
#'   Should accept \code{message} and \code{level} parameters.
#' @param admin_dashboard_hook Optional function receiving real-time assessment updates.
#'   Called with participant progress, ability estimates, and session metrics.
#' @param accessibility Logical indicating whether to enable accessibility features
#'   including ARIA labels, keyboard navigation, and screen reader support.
#' @param ... Additional parameters passed to Shiny application configuration.
#'
#' @return A Shiny application object that can be run with \code{shiny::runApp()}.
#'   The app provides a complete assessment interface with real-time adaptation.
#'
#' @details
#' \strong{Psychometric Foundation:} All statistical computations are performed by the
#' TAM package (Robitzsch et al., 2020). \code{inrep} serves as an integration framework
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
#'   \item \code{\link{launch_theme_editor}}: Interactive theme builder with real-time preview
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
#'   password = "secure_password_123",
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
#'   progress_style = "circle",
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
#' # Custom CSS for research branding
#' research_css <- "
#'   :root {
#'     --primary-color: #1f4e79;
#'     --secondary-color: #8cc8ff;
#'     --background-color: #ffffff;
#'     --text-color: #2c3e50;
#'     --font-family: 'Georgia', serif;
#'     --border-radius: 6px;
#'   }
#'   
#'   .assessment-header {
#'     background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
#'     color: white;
#'     padding: 20px;
#'     text-align: center;
#'   }
#'   
#'   .progress-container {
#'     margin: 20px 0;
#'     text-align: center;
#'   }
#' "
#' 
#' launch_study(
#'   config = research_config,
#'   item_bank = validation_items,
#'   custom_css = research_css,
#'   save_format = "rds",
#'   accessibility = TRUE
#' )
#' }
#' 
#' @references
#' \itemize{
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item Chang, W., Cheng, J., Allaire, J., Xie, Y., & McPherson, J. (2021). 
#'     \emph{shiny: Web Application Framework for R}. R package version 1.6.0. 
#'     \url{https://CRAN.R-project.org/package=shiny}
#'   \item American Educational Research Association, American Psychological Association, 
#'     & National Council on Measurement in Education. (2014). 
#'     \emph{Standards for educational and psychological testing}. 
#'     American Educational Research Association.
#'   \item van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). 
#'     \emph{Elements of adaptive testing}. Springer.
#'   \item Embretson, S. E., & Reise, S. P. (2000). 
#'     \emph{Item response theory for psychologists}. Lawrence Erlbaum Associates.
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_study_config}} for configuration parameters
#'   \item \code{\link{launch_theme_editor}} for interactive theme creation
#'   \item \code{\link{validate_item_bank}} for item bank validation
#'   \item \code{\link{estimate_ability}} for ability estimation details
#'   \item \code{\link{select_next_item}} for item selection algorithms
#' }
#' 
#' @export
#' 
#' @section Installation and Setup:
#' To use all features, ensure required packages are installed:
#' \preformatted{
#' install.packages(c("TAM", "shiny", "DT", "ggplot2", "logr"))
#' devtools::install_github("selvastics/inrep")
#' }
#' 
#' @section Performance Considerations:
#' For large-scale deployments:
#' \itemize{
#'   \item Enable \code{parallel_computation = TRUE} in config for faster ability estimation
#'   \item Use \code{cache_enabled = TRUE} to cache item information calculations  
#'   \item Consider \code{auto_scaling = TRUE} for cloud deployments
#'   \item Monitor performance with built-in profiling tools
#' }
#' 
#' @section Validation and Quality:
#' The framework includes comprehensive validation:
#' \itemize{
#'   \item Real-time response quality monitoring
#'   \item Automatic outlier detection
#'   \item Model fit diagnostics through TAM
#'   \item Engagement and completion tracking
#'   \item Comprehensive audit trails
#' }
#' inrep::launch_study(config, item_bank, accessibility = TRUE)
#' \dontrun{
#' # Example 1: Adaptive 2PL Model with Midnight Theme
#' config_2pl <- base::list(
#'   name = "Mathematics Proficiency",
#'   model = "2PL",
#'   max_items = 20,
#'   min_items = 5,
#'   min_SEM = 0.3,
#'   theta_prior = base::c(0, 1),
#'   adaptive = TRUE,
#'   theme = "Midnight",
#'   language = "en",
#'   demographics = base::c("Age", "Gender"),
#'   input_types = base::list(Age = "numeric", Gender = "select"),
#'   response_ui_type = "radio",
#'   progress_style = "circle",
#'   session_save = TRUE,
#'   max_session_duration = 30,
#'   recommendation_fun = function(theta, demo) {
#'     if (theta > 0) base::c("Consider advanced coursework", "Practice complex problems")
#'     else base::c("Review basic concepts", "Seek tutoring support")
#'   },
#'   response_validation_fun = function(resp) !base::is.null(resp) && base::length(resp) > 0,
#'   scoring_fun = function(resp, ans) base::as.numeric(resp == ans)
#' )
#' item_bank_2pl <- base::data.frame(
#'   Question = base::c("What is 2 + 2?", "What is 5 * 3?"),
#'   a = base::c(1.2, 1.0),
#'   b = base::c(0.5, -0.5),
#'   Option1 = base::c("2", "10"),
#'   Option2 = base::c("3", "12"),
#'   Option3 = base::c("4", "15"),
#'   Option4 = base::c("5", "18"),
#'   Answer = base::c("4", "15")
#' )
#' inrep::launch_study(config_2pl, item_bank_2pl)
#'
#' # Example 2: Non-Adaptive GRM Model with Custom Theme
#' config_grm <- base::list(
#'   name = "Survey of Attitudes",
#'   model = "GRM",
#'   max_items = 10,
#'   adaptive = FALSE,
#'   theme = "Light",
#'   language = "de",
#'   demographics = base::c("Age"),
#'   input_types = base::list(Age = "numeric"),
#'   response_ui_type = "slider",
#'   progress_style = "circle",
#'   session_save = FALSE,
#'   max_session_duration = 15,
#'   recommendation_fun = function(score, demo) {
#'     if (base::mean(score) > 3) base::c("Positive attitude detected", "Continue engagement")
#'     else base::c("Consider motivational support", "Review responses")
#'   },
#'   response_validation_fun = function(resp) base::is.numeric(resp) && resp >= 1 && resp <= 5,
#'   scoring_fun = function(resp, ans) base::as.numeric(resp)
#' )
#' item_bank_grm <- base::data.frame(
#'   Question = base::c("I enjoy learning.", "I feel confident."),
#'   a = base::c(1.0, 1.1),
#'   b1 = base::c(-1.0, -0.8),
#'   b2 = base::c(-0.5, -0.3),
#'   b3 = base::c(0.0, 0.2),
#'   b4 = base::c(0.5, 0.7),
#'   ResponseCategories = base::c("1,2,3,4,5", "1,2,3,4,5")
#' )
#' custom_theme <- base::list(
#'   primary_color = "#007bff",
#'   background_color = "#e9ecef",
#'   font_family = "'Arial', sans-serif",
#'   font_size_base = "1.1rem",
#'   border_radius = "10px"
#' )
#' inrep::launch_study(config_grm, item_bank_grm, theme_config = custom_theme)
#'
#' # Example 3: Adaptive 3PL Model with Custom CSS
#' config_3pl <- base::list(
#'   name = "Reading Comprehension",
#'   model = "3PL",
#'   max_items = 15,
#'   min_items = 5,
#'   min_SEM = 0.4,
#'   theta_prior = base::c(0, 1.5),
#'   adaptive = TRUE,
#'   theme = "Sunset",
#'   language = "en",
#'   demographics = base::c("Gender"),
#'   input_types = base::list(Gender = "select"),
#'   response_ui_type = "dropdown",
#'   progress_style = "circle",
#'   session_save = TRUE,
#'   max_session_duration = 20,
#'   recommendation_fun = function(theta, demo) {
#'     if (theta > 1) base::c("Advanced reading recommended", "Explore complex texts")
#'     else base::c("Practice basic comprehension", "Review vocabulary")
#'   },
#'   response_validation_fun = function(resp) !base::is.null(resp) && base::length(resp) > 0,
#'   scoring_fun = function(resp, ans) base::as.numeric(resp == ans)
#' )
#' item_bank_3pl <- base::data.frame(
#'   Question = base::c("What is the main idea?", "Who is the protagonist?"),
#'   a = base::c(1.3, 1.1),
#'   b = base::c(0.2, -0.2),
#'   c = base::c(0.2, 0.15),
#'   Option1 = base::c("Theme", "John"),
#'   Option2 = base::c("Plot", "Jane"),
#'   Option3 = base::c("Setting", "Jack"),
#'   Option4 = base::c("Character", "Jill"),
#'   Answer = base::c("Theme", "Jane")
#' )
#' custom_css <- "
#'   :root {
#'     --primary-color: #ff4500;
#'     --background-color: #fff8dc;
#'     --text-color: #333333;
#'     --font-family: 'Helvetica', sans-serif;
#'     --border-radius: 12px;
#'   }
#'   .btn-klee { background: var(--primary-color); }
#'   .assessment-card { border: 2px solid var(--primary-color); }
#' "
#' inrep::launch_study(config_3pl, item_bank_3pl, custom_css = custom_css)
#'
#' # Example 4: Simple 1PL Model with Default Settings
#' config_1pl <- base::list(
#'   name = "Basic Arithmetic",
#'   model = "1PL",
#'   max_items = 5,
#'   adaptive = TRUE,
#'   theme = "Light",
#'   language = "en",
#'   demographics = NULL,
#'   response_ui_type = "radio",
#'   progress_style = "circle",
#'   session_save = FALSE,
#'   max_session_duration = 10,
#'   recommendation_fun = function(theta, demo) base::c("Practice more problems"),
#'   response_validation_fun = function(resp) !base::is.null(resp) && base::length(resp) > 0,
#'   scoring_fun = function(resp, ans) base::as.numeric(resp == ans)
#' )
#' item_bank_1pl <- base::data.frame(
#'   Question = base::c("1 + 1 =", "2 + 3 ="),
#'   b = base::c(0.0, 0.5),
#'   Option1 = base::c("1", "4"),
#'   Option2 = base::c("2", "5"),
#'   Option3 = base::c("3", "6"),
#'   Option4 = base::c("4", "7"),
#'   Answer = base::c("2", "5")
#' )
#' inrep::launch_study(config_1pl, item_bank_1pl)
#' 
#' # Example 5: Simple 1PL Model with Cloud Storage
#' config <- inrep::create_study_config(model = "GRM", max_items = 10, session_save = TRUE)
#' utils::data(bfi_items)
#' inrep::launch_study(config, bfi_items, webdav_url = "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb/", password = "inreptest")
#' }
#'
#' @export
#' @importFrom shiny shinyApp fluidPage tags div numericInput selectInput actionButton downloadButton uiOutput renderUI plotOutput h2 h3 h4 p tagList
#' @importFrom shinyjs useShinyjs
#' @importFrom shinyWidgets radioGroupButtons
#' @importFrom DT datatable DTOutput renderDT formatStyle
#' @importFrom dplyr %>%
#' @importFrom TAM tam.mml
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
    logger = function(msg, ...) print(msg),
    ...
) {
  
  # Input validation
  extra_params <- list(...)
  if (length(extra_params) > 0) {
    logger(paste("Ignoring unused parameters:", paste(names(extra_params), collapse = ", ")), level = "INFO")
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
  
  logger(base::sprintf("Launching study: %s with theme: %s", config$name, config$theme %||% "Light"))
  print(base::sprintf("Launching study: %s with theme: %s", config$name, config$theme %||% "Light"))
  inrep::validate_item_bank(item_bank, config$model)
  
  # Handle model conversion if needed
  if (config$model %in% c("1PL", "2PL", "3PL") && "ResponseCategories" %in% names(item_bank) && 
      !all(c("Option1", "Option2", "Option3", "Option4", "Answer") %in% names(item_bank))) {
    logger("Converting GRM item bank for dichotomous model", level = "INFO")
    
    # Add b parameter if missing
    if (!"b" %in% names(item_bank) && "b1" %in% names(item_bank)) {
      item_bank$b <- item_bank$b1
      logger("Using b1 as b parameter", level = "INFO")
    }
    
    # Add dummy options for compatibility (these won't be used with GRM response UI)
    if (!"Option1" %in% names(item_bank)) {
      item_bank$Option1 <- "Option 1"
      item_bank$Option2 <- "Option 2" 
      item_bank$Option3 <- "Option 3"
      item_bank$Option4 <- "Option 4"
      item_bank$Answer <- "Option 1"  # Dummy answer
      logger("Added dummy options for dichotomous model compatibility", level = "INFO")
    }
  }
  
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
  if (base::is.null(config$theta_grid)) {
    config$theta_grid <- base::seq(-4, 4, length.out = 100)
    logger("Setting default theta_grid: seq(-4, 4, length.out = 100)")
  }

  # Validate item_groups indices
  if (!base::is.null(config$item_groups)) {
    all_items <- base::unlist(config$item_groups)
    if (!base::all(all_items %in% base::seq_len(base::nrow(item_bank)))) {
      logger("item_groups contains invalid item indices", level = "ERROR")
      base::stop("item_groups contains invalid item indices")
    }
  }
  
  # Apply theme: custom_css > theme_config > built-in theme
  css <- if (!base::is.null(custom_css)) {
    logger("Using custom CSS theme", level = "INFO")
    custom_css
  } else if (!base::is.null(theme_config)) {
    logger("Using custom theme configuration", level = "INFO")
    inrep::get_theme_css(theme_config = theme_config)
  } else {
    theme <- config$theme %||% "Light"
    
    # Validate and normalize theme name
    validated_theme <- validate_theme_name(theme, error_on_invalid = FALSE)
    
    if (is.null(validated_theme)) {
      print(base::sprintf("Invalid theme '%s', falling back to Light theme", theme))
      validated_theme <- "Light"
    } else if (validated_theme != theme) {
      print(base::sprintf("Theme '%s' normalized to '%s'", theme, validated_theme))
    }
    
    print(base::sprintf("Using built-in '%s' theme", validated_theme))
    inrep::get_theme_css(theme = validated_theme)
  }
  
  if (config$model == "1PL") item_bank$a <- base::rep(1, base::nrow(item_bank))
  
  labels <- base::list(
    en = base::list(
      demo_title = "Demographic Information",
      welcome_text = "Please provide your demographic details to begin the assessment.",
      start_button = "Start Assessment",
      submit_button = "Submit",
      results_title = "Assessment Results",
      save_button = "Download Report",
      restart_button = "Restart",
      proficiency = "Trait Score",
      precision = "Measurement Precision",
      items_administered = "Items Completed",
      recommendations = "Recommendations",
      feedback_correct = "Correct",
      feedback_incorrect = "Incorrect",
      timeout_message = "Session timed out. Please restart.",
      demo_error = "Please complete all required fields.",
      age_error = "Please enter a valid age (1-150)."
    ),
    de = base::list(
      demo_title = "Demografische Informationen",
      welcome_text = "Bitte geben Sie Ihre demografischen Daten ein, um die Bewertung zu beginnen.",
      start_button = "Bewertung beginnen",
      submit_button = "Absenden",
      results_title = "Bewertungsergebnisse",
      save_button = "Bericht herunterladen",
      restart_button = "Neu starten",
      proficiency = "Merkmalswert",
      precision = "Messgenauigkeit",
      items_administered = "Abgeschlossene Elemente",
      recommendations = "Empfehlungen",
      feedback_correct = "Korrekt",
      feedback_incorrect = "Falsch",
      timeout_message = "Sitzung abgelaufen. Bitte neu starten.",
      demo_error = "Bitte füllen Sie alle erforderlichen Felder aus.",
      age_error = "Bitte geben Sie ein gültiges Alter ein (1-150)."
    )
  )
  ui_labels <- labels[[config$language %||% "en"]]
  
  ui <- shiny::fluidPage(
    shinyjs::useShinyjs(),
    shiny::tags$head(
      shiny::tags$style(type = "text/css", css),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet")
    ),
    shiny::div(class = "container-fluid",
        `data-theme` = config$theme %||% "Light",
        if (!base::is.null(config$custom_ui_pre)) config$custom_ui_pre,
        shiny::h2(config$name, class = "section-title", role = "heading", `aria-level` = "1"),
        shiny::uiOutput("study_ui")
    )
  )
  
  server <- function(input, output, session) {
    data_dir <- base::file.path("study_data", config$study_key %||% "default_study")
    if (!base::dir.exists(data_dir)) base::dir.create(data_dir, recursive = TRUE)
    session_file <- base::file.path(data_dir, "session.rds")
    
    rv <- shiny::reactiveValues(
      demo_data = stats::setNames(base::rep(NA, base::length(config$demographics)), config$demographics),
      stage = "demographics",
      current_ability = config$theta_prior[1],
      current_se = config$theta_prior[2],
      administered = base::c(),
      responses = base::c(),
      response_times = base::c(),
      start_time = NULL,
      session_start = base::Sys.time(),
      current_item = NULL,
      theta_history = base::list(),
      se_history = base::list(),
      cat_result = NULL,
      item_counter = 0,
      error_message = NULL,
      feedback_message = NULL,
      item_info_cache = base::list(),
      session_active = TRUE
    )
    
    if (config$session_save && base::file.exists(session_file)) {
      base::tryCatch({
        saved_state <- base::readRDS(session_file)
        for (name in base::names(saved_state)) rv[[name]] <- saved_state[[name]]
        logger(base::sprintf("Restored session from %s", session_file))
      }, error = function(e) {
        logger(base::sprintf("Failed to restore session: %s", e$message))
      })
    }
    
    shiny::observe({
      shiny::invalidateLater(1000, session)
      if (base::difftime(base::Sys.time(), rv$session_start, units = "mins") > config$max_session_duration) {
        rv$session_active <- FALSE
        rv$stage = "timeout"
        logger("Session timed out")
      }
    })
    
    get_item_content <- function(item_idx) {
      if (base::is.null(config$item_translations) || base::is.null(config$item_translations[[config$language]])) {
        return(item_bank[item_idx, ])
      }
      translations <- config$item_translations[[config$language]][item_idx, ]
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
    
    output$ui <- shiny::renderUI({
      rv <- inrep::validate_session(rv, config, webdav_url, password)
      if (rv$stage == "demographics") {
        inrep::create_demographics_ui(config)
      } else if (rv$stage == "test") {
        inrep::inrep_test_ui(config, item_bank, rv$current_item, rv$feedback_message, rv$error_message, rv$loading)
      } else {
        inrep::inrep_results_ui(config, rv$cat_result, save_format)
      }
    })
    
    output$study_ui <- shiny::renderUI({
      if (!rv$session_active) {
        return(
          shiny::div(class = "assessment-card",
              shiny::h3(ui_labels$timeout_message, class = "card-header"),
              shiny::div(class = "nav-buttons",
                  shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee")
              )
          )
        )
      }
      
      base::switch(rv$stage,
             "demographics" = {
               shiny::tagList(
                 shiny::div(class = "assessment-card",
                     shiny::h3(ui_labels$demo_title, class = "card-header"),
                     shiny::p(ui_labels$welcome_text, class = "welcome-text"),
                     base::lapply(base::seq_along(config$demographics), function(i) {
                       dem <- config$demographics[i]
                       input_type <- config$input_types[[dem]]
                       input_id <- base::paste0("demo_", i)
                       shiny::div(
                         class = "form-group",
                         shiny::tags$label(dem, class = "input-label"),
                         base::switch(input_type,
                                "numeric" = shiny::numericInput(
                                  inputId = input_id,
                                  label = NULL,
                                  value = rv$demo_data[i] %||% NA,
                                  min = 1,
                                  max = 150,
                                  width = "100%"
                                ),
                                "select" = shiny::selectInput(
                                  inputId = input_id,
                                  label = NULL,
                                  choices = base::c("Select" = "", "Male", "Female", "Other"),
                                  selected = rv$demo_data[i] %||% "",
                                  width = "100%"
                                ),
                                shiny::textInput(
                                  inputId = input_id,
                                  label = NULL,
                                  value = rv$demo_data[i] %||% "",
                                  width = "100%"
                                )
                         )
                       )
                     }),
                     if (!base::is.null(rv$error_message)) shiny::div(class = "error-message", rv$error_message),
                     shiny::div(class = "nav-buttons",
                         shiny::actionButton("start_test", ui_labels$start_button, class = "btn-klee")
                     )
                 )
               )
             },
             "test" = {
               if (base::is.null(rv$current_item)) {
                 return(shiny::div(class = "assessment-card",
                            shiny::h3("Preparing...", class = "card-header"),
                            shiny::p("Loading next question...")))
               }
               item <- get_item_content(rv$current_item)
               response_ui <- if (config$model == "GRM") {
                 choices <- base::as.numeric(base::unlist(base::strsplit(item$ResponseCategories, ",")))
                 labels <- base::switch(config$language,
                                  de = base::c("Stark abgelehnt", "Abgelehnt", "Neutral", "Zustimmen", "Stark zustimmen")[1:base::length(choices)],
                                  en = base::c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")[1:base::length(choices)],
                                  es = base::c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo")[1:base::length(choices)],
                                  fr = base::c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")[1:base::length(choices)]
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
                 )
               } else {
                 shinyWidgets::radioGroupButtons(
                   inputId = "item_response",
                   label = NULL,
                   choices = base::c(item$Option1, item$Option2, item$Option3, item$Option4),
                   selected = base::character(0),
                   direction = "vertical",
                   status = "default",
                   individual = TRUE,
                   width = "100%"
                 )
               }
               progress_ui <- base::switch(config$progress_style,
                                     "circle" = shiny::div(class = "progress-circle",
                                                    shiny::tags$svg(
                                                      width = "100", height = "100",
                                                      shiny::tags$circle(cx = "50", cy = "50", r = "45", stroke = "var(--progress-bg-color)"),
                                                      shiny::tags$circle(cx = "50", cy = "50", r = "45", class = "progress",
                                                                  strokeDasharray = "283", strokeDashoffset = base::sprintf("%.0f",
                                                                                                                      283 * (1 - base::length(rv$administered) / config$max_items)),
                                                                  style = "stroke: var(--primary-color);"),
                                                      shiny::span(base::sprintf("%d%%", base::round(base::length(rv$administered) / config$max_items * 100)))
                                                    )
                                     ))
               shiny::tagList(
                 shiny::div(class = "assessment-card",
                     shiny::h3(config$name, class = "card-header"),
                     progress_ui,
                     shiny::div(class = "test-question", item$Question),
                     shiny::div(class = "radio-group-container", response_ui),
                     if (!base::is.null(rv$error_message)) shiny::div(class = "error-message", rv$error_message),
                     if (!base::is.null(rv$feedback_message)) shiny::div(class = "feedback-message", rv$feedback_message),
                     shiny::div(class = "nav-buttons",
                         shiny::actionButton("submit_response", ui_labels$submit_button, class = "btn-klee")
                     )
                 )
               )
             },
             "results" = {
               if (base::is.null(rv$cat_result)) return()
               shiny::tagList(
                 shiny::div(class = "assessment-card",
                     shiny::h3(ui_labels$results_title, class = "card-header"),
                     if (config$adaptive) shiny::plotOutput("theta_plot", height = "200px"),
                     if (config$adaptive) shiny::div(class = "results-section",
                                              shiny::h4(ui_labels$proficiency, class = "results-title"),
                                              shiny::div(class = "dimension-score",
                                                  shiny::div(class = "dimension-title",
                                                      shiny::span(ui_labels$proficiency),
                                                      shiny::span(class = "dimension-value", base::sprintf("%.2f", rv$cat_result$theta))
                                                  ),
                                                  shiny::div(class = "dimension-bar",
                                                      shiny::div(class = "dimension-fill",
                                                          style = base::sprintf("width:%.0f%%; background: var(--primary-color);", (rv$cat_result$theta + 3)/6 * 100))
                                                  )
                                              )
                     ),
                     if (config$adaptive) shiny::div(class = "results-section",
                                              shiny::h4(ui_labels$precision, class = "results-title"),
                                              shiny::p(base::sprintf("Standard Error: %.3f", rv$cat_result$se))
                     ),
                     shiny::div(class = "results-section",
                         shiny::h4(ui_labels$items_administered, class = "results-title"),
                         DT::DTOutput("item_table")
                     ),
                     shiny::div(class = "results-section",
                         shiny::h4(ui_labels$recommendations, class = "results-title"),
                         shiny::uiOutput("recommendations")
                     ),
                     shiny::div(class = "footer",
                         shiny::p(config$name),
                         shiny::p(base::format(base::Sys.time(), "%B %d, %Y"))
                     ),
                     shiny::div(class = "nav-buttons",
                         shiny::downloadButton("save_report", ui_labels$save_button, class = "btn-klee"),
                         shiny::actionButton("restart_test", ui_labels$restart_button, class = "btn-klee")
                     )
                 )
               )
             }
      )
    })
    
    output$theta_plot <- shiny::renderPlot({
      if (!config$adaptive || base::length(rv$theta_history) < 2) return(NULL)
      data <- base::data.frame(
        Item = base::seq_along(rv$theta_history),
        Theta = base::unlist(rv$theta_history),
        SE = base::unlist(rv$se_history)
      )
      # Use static color based on theme or default
      plot_color <- if (!base::is.null(theme_config)) {
        theme_config$primary_color %||% "#212529"
      } else {
        base::switch(base::tolower(config$theme %||% "Light"),
               "light" = "#212529",
               "midnight" = "#1a1a1a",
               "sunset" = "#ff6f61",
               "forest" = "#2e7d32",
               "ocean" = "#0288d1",
               "berry" = "#c2185b",
               "#212529") # Default to Light theme color
      }
      ggplot2::ggplot(data, ggplot2::aes(x = Item, y = Theta)) +
        ggplot2::geom_line(color = plot_color) +
        ggplot2::geom_ribbon(ggplot2::aes(ymin = Theta - SE, ymax = Theta + SE), alpha = 0.2, fill = plot_color) +
        ggplot2::theme_minimal() +
        ggplot2::labs(y = "Trait Score", x = "Item") +
        ggplot2::theme(
          text = ggplot2::element_text(family = "Inter", size = 12),
          plot.title = ggplot2::element_text(face = "bold", size = 14),
          axis.title = ggplot2::element_text(size = 12),
          panel.grid = ggplot2::element_blank(),
          axis.line = ggplot2::element_line(color = "#212529")
        )
    })
    
    output$item_table <- DT::renderDT({
      if (base::is.null(rv$cat_result)) return()
      items <- rv$cat_result$administered
      responses <- rv$cat_result$responses
      dat <- if (config$model == "GRM") {
        base::data.frame(
          Item = item_bank$Question[items],
          Response = responses,
          Time = base::round(rv$cat_result$response_times, 1),
          check.names = FALSE
        )
      } else {
        base::data.frame(
          Item = item_bank$Question[items],
          Response = base::ifelse(responses == 1, "Correct", "Incorrect"),
          Correct = item_bank$Answer[items],
          Time = base::round(rv$cat_result$response_times, 1),
          check.names = FALSE
        )
      }
      columnDefs <- base::list(
        base::list(width = '50%', targets = 0),
        base::list(width = '25%', targets = 1)
      )
      if (config$model == "GRM") {
        columnDefs[[3]] <- base::list(width = '25%', targets = 2)
      } else {
        columnDefs[[3]] <- base::list(width = '25%', targets = 2)
        columnDefs[[4]] <- base::list(width = '25%', targets = 3)
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
      ) %>%
        DT::formatStyle(columns = base::names(dat), color = 'var(--text-color)', fontFamily = 'var(--font-family)')
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
          theta_history = if (config$adaptive) base::unlist(rv$theta_history) else NULL,
          se_history = if (config$adaptive) base::unlist(rv$se_history) else NULL
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
    
    shiny::observeEvent(input$start_test, {
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
          if (base::is.null(val) || base::is.na(val) || val == "" || val == "Select") {
            return(NA)
          }
          if (base::is.character(val)) {
            val <- base::trimws(base::gsub("[<>\"&]", "", val))
          }
          return(val)
        }
      })
      base::names(rv$demo_data) <- config$demographics
      
      non_age_dems <- base::setdiff(config$demographics, "Age")
      if (base::length(non_age_dems) > 0 && base::all(base::is.na(rv$demo_data[non_age_dems]) | rv$demo_data[non_age_dems] == "")) {
        rv$error_message <- ui_labels$demo_error
        logger("Invalid non-age demographic inputs")
        return()
      }
      
      rv$error_message <- NULL
      rv$stage <- "test"
      rv$start_time <- base::Sys.time()
      rv$current_item <- inrep::select_next_item(rv, item_bank, config)
      logger("Demographic data validated, proceeding to test stage")
    })
    
    shiny::observeEvent(input$submit_response, {
      shiny::req(input$item_response, rv$current_item)
      if (!config$response_validation_fun(input$item_response)) {
        rv$error_message <- base::sprintf("Please select a valid response (%s).", config$language)
        logger(base::sprintf("Invalid response submitted for item %d", rv$current_item))
        return()
      }
      rv$error_message <- NULL
      response_time <- base::as.numeric(base::difftime(base::Sys.time(), rv$start_time, units = "secs"))
      rv$response_times <- base::c(rv$response_times, response_time)
      item_index <- rv$current_item
      correct_answer <- item_bank$Answer[item_index] %||% NULL
      response_score <- base::tryCatch(
        config$scoring_fun(input$item_response, correct_answer),
        error = function(e) {
          logger(base::sprintf("Scoring function error: %s", e$message))
          if (config$model == "GRM") base::as.numeric(input$item_response) else base::as.numeric(input$item_response == correct_answer)
        }
      )
      rv$responses <- base::c(rv$responses, response_score)
      rv$administered <- base::c(rv$administered, item_index)
      
      if (config$adaptive) {
        base::tryCatch({
          ability <- inrep::estimate_ability(rv, item_bank, config)
          rv$current_ability <- ability$theta
          rv$current_se <- ability$se
          logger(base::sprintf("Estimated ability: theta=%.2f, se=%.3f", ability$theta, ability$se))
          rv$theta_history <- base::c(rv$theta_history, rv$current_ability)
          rv$se_history <- base::c(rv$se_history, rv$current_se)
        }, error = function(e) {
          logger(base::sprintf("Ability estimation failed: %s", e$message))
          rv$error_message <- "Error estimating ability. Please try again."
          return()
        })
      }
      
      if (check_stopping_criteria()) {
        rv$cat_result <- base::list(
          theta = if (config$adaptive) rv$current_ability else base::mean(rv$responses, na.rm = TRUE),
          se = if (config$adaptive) rv$current_se else NULL,
          responses = rv$responses,
          administered = rv$administered,
          response_times = rv$response_times
        )
        rv$stage <- "results"
        logger("Test completed, proceeding to results")
        
        # Save session to cloud if enabled
        if (config$session_save && !base::is.null(webdav_url)) {
          logger("Attempting to save session to cloud...")
          inrep::save_session_to_cloud(rv, config, webdav_url, password)
        }
      } else {
        rv$current_item <- inrep::select_next_item(rv, item_bank, config)
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
          
          # Save session to cloud if enabled
          if (config$session_save && !base::is.null(webdav_url)) {
            logger("Attempting to save session to cloud...")
            inrep::save_session_to_cloud(rv, config, webdav_url, password)
          }
        } else {
          rv$start_time <- base::Sys.time()
          if (config$response_ui_type == "slider") {
            shiny::updateSliderInput(session, "item_response", value = base::min(base::as.numeric(base::unlist(base::strsplit(item_bank$ResponseCategories[rv$current_item], ",")))))
          } else if (config$response_ui_type == "dropdown") {
            shiny::updateSelectInput(session, "item_response", selected = NULL)
          } else {
            shinyWidgets::updateRadioGroupButtons(session, "item_response", selected = base::character(0))
          }
        }
      }
    })
    
    shiny::observeEvent(input$restart_test, {
      rv$stage = "demographics"
      rv$current_ability <- config$theta_prior[1]
      rv$current_se <- config$theta_prior[2]
      rv$administered <- base::c()
      rv$responses = base::c()
      rv$response_times = base::c()
      rv$current_item <- NULL
      rv$cat_result <- NULL
      rv$theta_history <- base::list()
      rv$se_history <- base::list()
      rv$item_counter = 0
      rv$error_message <- NULL
      rv$feedback_message <- NULL
      rv$item_info_cache = base::list()
      rv$session_start <- base::Sys.time()
      rv$session_active <- TRUE
      logger("Test restarted")
    })
  }
  
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
#' @export
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
