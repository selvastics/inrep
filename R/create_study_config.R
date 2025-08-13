#' Create Study Configuration for IRT-Based Assessment
#'
#' Creates a comprehensive configuration object for adaptive testing studies that utilize 
#' the TAM package for all psychometric computations. This function configures the parameters 
#' that control how \code{inrep} interfaces with TAM's statistical functions and manages
#' the overall assessment workflow, session management, and result reporting.
#'
#' @param name Character string specifying the study name for identification and reporting.
#' @param demographics Character vector of demographic field names to collect, 
#'   or \code{NULL} for no demographic data collection.
#' @param study_key Character string providing unique identifier for the study. 
#'   Defaults to auto-generated UUID for session tracking.
#' @param min_SEM Numeric value specifying minimum standard error for stopping criterion.
#'   Computed by TAM estimation procedures. Typical values: 0.2-0.4.
#' @param min_items Integer minimum number of items to administer before stopping rules apply.
#' @param max_items Integer maximum number of items to administer, or \code{NULL} to use 
#'   full item bank size. Prevents excessive test length.
#' @param criteria Character string specifying item selection criterion. Options:
#'   \code{"MI"} (Maximum Information), \code{"RANDOM"}, \code{"WEIGHTED"}, \code{"MFI"} (Maximum Fisher Information).
#' @param model Character string specifying IRT model passed to TAM functions.
#'   Options: \code{"1PL"}, \code{"2PL"}, \code{"3PL"}, \code{"GRM"}.
#' @param estimation_method Character string specifying ability estimation method.
#'   Primary option: \code{"TAM"}. Alternative compatibility: \code{"MIRT"}, \code{"EAP"}, \code{"WLE"}.
#' @param recommendation_fun Function to generate personalized recommendations based on 
#'   ability estimates and demographics, or \code{NULL} for default recommendations.
#' @param theta_prior Numeric vector of length 2 specifying prior mean and standard deviation
#'   for ability distribution. Used in TAM's Bayesian estimation procedures.
#' @param stopping_rule Custom function implementing stopping logic, or \code{NULL} for 
#'   default SEM-based stopping. Function should accept theta, SE, and item count.
#' @param input_types Named list specifying input types for demographic fields.
#'   Options: \code{"text"}, \code{"numeric"}, \code{"select"}, \code{"radio"}, \code{"checkbox"}.
#' @param scoring_fun Function to score item responses, or \code{NULL} for default scoring.
#'   Should accept response and correct answer, return numeric score.
#' @param adaptive_start Integer item number to begin adaptive selection, or \code{NULL} 
#'   for immediate adaptive selection. Allows fixed item administration initially.
#' @param fixed_items Integer vector of item indices that must be administered, 
#'   or \code{NULL} for no fixed items. Useful for anchor items or content requirements.
#' @param adaptive Logical indicating whether to use adaptive item selection based on 
#'   TAM ability estimates. When \code{TRUE} (default), items are selected dynamically 
#'   based on the participant's estimated ability to maximize information. When \code{FALSE}, 
#'   items are administered in sequential order from the item bank (non-adaptive mode).
#'   Note: When \code{adaptive = FALSE}, the assessment simply presents items 1 through 
#'   \code{max_items} in order, making it a standard fixed-form questionnaire.
#' @param item_groups Named list defining item groups for content balancing, 
#'   or \code{NULL} for no grouping constraints.
#' @param custom_ui_pre Custom UI elements to display before assessment, 
#'   or \code{NULL} for standard interface.
#' @param progress_style Character string specifying progress indicator style.
#'   Options: \code{"bar"}, \code{"circle"}, \code{"modern-circle"}, \code{"enhanced-bar"}, \code{"segmented"}, \code{"minimal"}, \code{"card"}.
#' @param response_validation_fun Function to validate participant responses, 
#'   or \code{NULL} for default validation. Should return logical.
#' @param response_ui_type Character string specifying response input interface.
#'   Options: \code{"radio"}, \code{"slider"}, \code{"dropdown"}.
#' @param session_save Logical indicating whether to enable session state persistence
#'   for interrupted session recovery.
#' @param show_session_time Logical indicating whether to display session time remaining
#'   in the top-right corner. Defaults to FALSE for cleaner interface.
#' @param theme Character string specifying built-in UI theme. Options: \code{"Light"}, 
#'   \code{"Midnight"}, \code{"Sunset"}, \code{"Forest"}, \code{"Ocean"}, \code{"Berry"}, \code{"Professional"}.
#' @param language Character string specifying interface language. 
#'   Options: \code{"en"}, \code{"de"}, \code{"es"}, \code{"fr"}.
#' @param item_translations Named list of item translations by language code, 
#'   or \code{NULL} for single-language studies.
#' @param report_formats Character vector specifying supported export formats.
#'   Options: \code{"rds"}, \code{"csv"}, \code{"json"}, \code{"pdf"}.
#' @param max_session_duration Integer maximum session duration in minutes for timeout.
#' @param max_response_time Integer maximum response time per item in seconds.
#' @param cache_enabled Logical indicating whether to cache item information calculations
#'   for performance optimization.
#' @param parallel_computation Logical indicating whether to enable parallel processing
#'   for TAM estimation procedures when computationally intensive.
#' @param feedback_enabled Logical indicating whether to provide immediate feedback
#'   after each item response.
#' @param theta_grid Numeric vector specifying theta grid for TAM's numerical integration,
#'   or \code{NULL} for TAM's default grid specification.
#' @param show_introduction Logical indicating whether to display introduction page
#'   with study overview and briefing information.
#' @param introduction_content Character string containing HTML content for 
#'   introduction page, or \code{NULL} for default content.
#' @param show_briefing Logical indicating whether to display detailed briefing
#'   about study procedures, ethics, and expectations.
#' @param briefing_content Character string containing HTML content for briefing,
#'   or \code{NULL} for default academic briefing.
#' @param show_consent Logical indicating whether to display informed consent form
#'   with GDPR/DSGVO compliance options.
#' @param consent_content Character string containing HTML consent form content,
#'   or \code{NULL} for default GDPR-compliant consent.
#' @param show_gdpr_compliance Logical indicating whether to include GDPR/DSGVO
#'   data protection information and consent checkboxes.
#' @param gdpr_content Character string containing GDPR/DSGVO compliance text,
#'   or \code{NULL} for default German/EU compliant text.
#' @param show_debriefing Logical indicating whether to display debriefing page
#'   after study completion with study purpose and resources.
#' @param debriefing_content Character string containing HTML debriefing content,
#'   or \code{NULL} for default debriefing.
#' @param demographic_configs Named list providing full control over demographic
#'   questions, including custom labels, response options, validation rules,
#'   and display formatting.
#' @param custom_demographic_ui Function to generate custom demographic UI,
#'   or \code{NULL} for default demographic interface.
#' @param study_phases Character vector specifying order of study phases.
#'   Default: c("introduction", "briefing", "consent", "demographics", "survey", "debriefing").
#' @param page_transitions Character string specifying transition animations
#'   between study phases. Options: "fade", "slide", "none".
#' @param enable_back_navigation Logical indicating whether participants can
#'   navigate back to previous pages.
#' @param ... Additional parameters captured and included in configuration object
#'   for custom extensions and advanced features.
#'
#' @return Named list containing complete study configuration with all specified parameters
#'   and computed defaults. Compatible with \code{\link{launch_study}} and other inrep functions.
#' 
#' @details
#' \strong{TAM Integration Architecture:} This configuration object serves as the primary
#' interface layer between \code{inrep}'s workflow management and TAM's psychometric functions:
#' 
#' \strong{Core TAM Parameters:}
#' \itemize{
#'   \item \code{model}: Determines which TAM function to invoke (\code{\link[TAM]{tam.mml}}, 
#'     \code{\link[TAM]{tam.mml.2pl}}, \code{\link[TAM]{tam.mml.3pl}})
#'   \item \code{estimation_method}: Controls TAM's ability estimation procedures 
#'     (\code{\link[TAM]{tam.wle}}, \code{\link[TAM]{tam.eap}})
#'   \item \code{theta_prior}: Prior distribution parameters passed to TAM's Bayesian procedures
#'   \item \code{min_SEM}: Stopping criterion based on TAM's standard error calculations
#'   \item \code{theta_grid}: Grid specification for TAM's numerical integration algorithms
#' }
#' 
#' \strong{Framework Responsibilities:} \code{inrep} provides workflow orchestration while
#' TAM performs all psychometric computations:
#' \itemize{
#'   \item Session management and state persistence across assessment sessions
#'   \item User interface rendering and interaction handling via Shiny
#'   \item Data flow coordination between UI components and TAM functions
#'   \item Result formatting, reporting, and export in multiple formats
#'   \item Quality monitoring, logging, and administrative features
#' }
#' 
#' \strong{Adaptive Testing Configuration:} When \code{adaptive = TRUE}, the system:
#' \itemize{
#'   \item Uses TAM ability estimates to drive item selection algorithms
#'   \item Applies stopping rules based on TAM-computed standard errors
#'   \item Implements content balancing with psychometric optimization
#'   \item Provides real-time ability tracking throughout the assessment
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Automatic validation of parameter ranges for TAM compatibility
#'   \item Response time monitoring and rapid-response detection
#'   \item Session timeout management and graceful degradation
#'   \item Comprehensive audit logging for research compliance
#' }
#' 
#' \strong{Multilingual Support:} Language configuration affects:
#' \itemize{
#'   \item Interface text and navigation elements
#'   \item Error messages and validation feedback
#'   \item Progress indicators and completion messages
#'   \item Demographic field labels and response options
#' }
#' 
#' All psychometric modeling is performed exclusively by TAM (Robitzsch et al., 2024).
#' \code{inrep} focuses on providing the technological infrastructure and user experience
#' layer around TAM's validated statistical procedures.
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Personality Assessment Configuration
#' basic_config <- create_study_config(
#'   name = "Big Five Personality Assessment",
#'   model = "GRM",
#'   estimation_method = "TAM",
#'   demographics = c("Age", "Gender", "Education"),
#'   max_items = 15,
#'   min_SEM = 0.3,
#'   language = "en",
#'   theme = "Light"
#' )
#' 
#' # Example 1b: Non-Adaptive (Fixed Order) Assessment
#' # Items are presented sequentially: 1, 2, 3, 4, 5 from the item bank
#' # This creates a standard questionnaire without adaptive item selection
#' fixed_config <- create_study_config(
#'   name = "Personality Questionnaire",
#'   adaptive = FALSE,  # Disable adaptive testing
#'   max_items = 5,     # Present exactly 5 items in order
#'   theme = "hildesheim",
#'   session_save = TRUE
#' )
#' 
#' # Example 2: Advanced Research Configuration with Full Customization
#' research_config <- create_study_config(
#'   name = "Cognitive Ability Validation Study",
#'   model = "2PL",
#'   estimation_method = "TAM",
#'   min_items = 12,
#'   max_items = 25,
#'   min_SEM = 0.25,
#'   criteria = "MI",  # Maximum Information selection
#'   theta_prior = c(0, 1.2),  # Slightly wider prior for diverse population
#'   
#'   # Comprehensive demographics
#'   demographics = c("Age", "Gender", "Education", "Native_Language", "Country"),
#'   input_types = list(
#'     Age = "numeric",
#'     Gender = "select", 
#'     Education = "select",
#'     Native_Language = "text",
#'     Country = "select"
#'   ),
#'   
#'   # Advanced features
#'   theme = "Professional",
#'   language = "en",
#'   session_save = TRUE,
#'   parallel_computation = TRUE,
#'   cache_enabled = TRUE,
#'   feedback_enabled = TRUE,
#'   
#'   # Performance optimization
#'   max_session_duration = 45,
#'   max_response_time = 120,
#'   
#'   # Custom recommendation function
#'   recommendation_fun = function(theta, demographics, item_responses) {
#'     ability_level <- cut(theta, breaks = c(-Inf, -0.5, 0.5, Inf), 
#'                         labels = c("Developing", "Proficient", "Advanced"))
#'     
#'     recommendations <- switch(ability_level,
#'       "Developing" = c("Focus on foundational skills", 
#'                       "Consider additional practice materials"),
#'       "Proficient" = c("Continue current learning approach", 
#'                       "Explore intermediate challenges"),
#'       "Advanced" = c("Seek advanced coursework", 
#'                     "Consider mentoring others")
#'     )
#'     
#'     return(recommendations)
#'   }
#' )
#' 
#' # Example 3: Clinical Assessment with Enterprise Features
#' clinical_config <- create_study_config(
#'   name = "Depression Screening Instrument",
#'   model = "GRM",
#'   estimation_method = "TAM",
#'   min_items = 8,
#'   max_items = 15,
#'   min_SEM = 0.4,  # Slightly higher for clinical screening
#'   criteria = "WEIGHTED",  # Balanced selection
#'   
#'   # Clinical demographics
#'   demographics = c("Age", "Gender", "Previous_Treatment", "Referral_Source"),
#'   input_types = list(
#'     Age = "numeric",
#'     Gender = "select",
#'     Previous_Treatment = "radio",
#'     Referral_Source = "select"
#'   ),
#'   
#'   # Clinical interface settings
#'   theme = "Clinical",
#'   language = "en",
#'   response_ui_type = "radio",
#'   progress_style = "bar",
#'   
#'   # Enterprise security
#'   session_save = TRUE,
#'   max_session_duration = 20,
#'   
#'   # Custom validation for clinical context
#'   response_validation_fun = function(response) {
#'     # Ensure response is provided and within expected range
#'     if (is.null(response) || is.na(response)) {
#'       return(FALSE)
#'     }
#'     # Clinical scale typically 0-3 or 1-4
#'     return(response %in% 0:3)
#'   }
#' )
#' 
#' # Example 4: Educational Assessment with Content Balancing
#' education_config <- create_study_config(
#'   name = "Mathematics Proficiency Assessment",
#'   model = "2PL",
#'   estimation_method = "TAM",
#'   min_items = 15,
#'   max_items = 30,
#'   min_SEM = 0.3,
#'   criteria = "MI",
#'   
#'   # Educational demographics
#'   demographics = c("Grade", "School", "Teacher", "Previous_Score"),
#'   input_types = list(
#'     Grade = "select",
#'     School = "text",
#'     Teacher = "text",
#'     Previous_Score = "numeric"
#'   ),
#'   
#'   # Content balancing
#'   item_groups = list(
#'     "Algebra" = c(1, 3, 5, 7, 9, 11, 13, 15),
#'     "Geometry" = c(2, 4, 6, 8, 10, 12, 14, 16),
#'     "Statistics" = c(17, 18, 19, 20, 21, 22, 23, 24)
#'   ),
#'   
#'   # Educational interface
#'   theme = "Educational",
#'   language = "en",
#'   response_ui_type = "radio",
#'   progress_style = "circle",
#'   feedback_enabled = TRUE,
#'   
#'   # Performance settings
#'   cache_enabled = TRUE,
#'   parallel_computation = TRUE,
#'   max_session_duration = 50
#' )
#' 
#' # Example 5: Multilingual Cross-Cultural Study
#' multilingual_config <- create_study_config(
#'   name = "Cross-Cultural Personality Study",
#'   model = "GRM",
#'   estimation_method = "TAM",
#'   min_items = 20,
#'   max_items = 40,
#'   min_SEM = 0.25,
#'   
#'   # Multilingual setup
#'   language = "en",  # Default language
#'   item_translations = list(
#'     "de" = list(
#'       "I see myself as someone who is talkative" = "Ich sehe mich als jemanden, der gesprächig ist",
#'       "I see myself as someone who is reserved" = "Ich sehe mich als jemanden, der reserviert ist"
#'     ),
#'     "es" = list(
#'       "I see myself as someone who is talkative" = "Me veo como alguien que es hablador",
#'       "I see myself as someone who is reserved" = "Me veo como alguien que es reservado"
#'     )
#'   ),
#'   
#'   # Cross-cultural demographics
#'   demographics = c("Age", "Gender", "Country", "Native_Language", "Education"),
#'   input_types = list(
#'     Age = "numeric",
#'     Gender = "select",
#'     Country = "select",
#'     Native_Language = "text",
#'     Education = "select"
#'   ),
#'   
#'   # Research features
#'   theme = "Research",
#'   session_save = TRUE,
#'   parallel_computation = TRUE,
#'   report_formats = c("rds", "csv", "json"),
#'   
#'   # Extended session for international participants
#'   max_session_duration = 60,
#'   max_response_time = 180
#' )
#' 
#' # View configuration structure
#' str(basic_config)
#' cat("Configuration created for:", basic_config$name, "\n")
#' cat("Model:", basic_config$model, "\n")
#' cat("Max items:", basic_config$max_items, "\n")
#' }
#' 
#' @references
#' \itemize{
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). 
#'     \emph{Elements of adaptive testing}. Springer.
#'   \item Chalmers, R. P. (2012). mirt: A multidimensional item response theory package 
#'     for the R environment. \emph{Journal of Statistical Software}, 48(6), 1-29.
#'   \item Embretson, S. E., & Reise, S. P. (2000). 
#'     \emph{Item response theory for psychologists}. Lawrence Erlbaum Associates.
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{launch_study}} for running assessments with this configuration
#'   \item \code{\link{validate_item_bank}} for validating item banks with configuration
#'   \item \code{\link{estimate_ability}} for ability estimation using configuration
#'   \item \code{\link{select_next_item}} for item selection using configuration
#' }
#' 
#' @references Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. 
#'   R package version 4.2-21. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @seealso \code{\link{launch_study}}, \code{\link{estimate_ability}}, 
#'   \code{\link{validate_item_bank}}
#' @importFrom uuid UUIDgenerate
#' @export
create_study_config <- function(
    name = "Personality Assessment",
    demographics = c("Age", "Gender"),
    study_key = paste0("STUDY_", if (requireNamespace("uuid", quietly = TRUE)) uuid::UUIDgenerate() else paste0("STUDY_", Sys.time())),
    min_SEM = 0.3,
    min_items = 5,
    max_items = NULL,
    criteria = "MI",
    model = "GRM",
    estimation_method = "TAM",
    recommendation_fun = NULL,
    theta_prior = c(0, 1),
    stopping_rule = NULL,
    input_types = NULL,
    scoring_fun = NULL,
    adaptive_start = NULL,
    fixed_items = NULL,
    adaptive = TRUE,
    item_groups = NULL,
    custom_ui_pre = NULL,
    progress_style = "circle",
    response_validation_fun = NULL,
    response_ui_type = "radio",
    session_save = FALSE,
    show_session_time = FALSE,  # Hide session time display by default
    theme = "Professional",
    language = "en",
    item_translations = NULL,
    report_formats = c("rds", "csv", "json", "pdf"),
    max_session_duration = 60,
    max_response_time = 300,
    cache_enabled = TRUE,
    parallel_computation = FALSE,
    feedback_enabled = FALSE,
    theta_grid = seq(-4, 4, length.out = 100),
    # Enhanced study flow features
    show_introduction = TRUE,
    introduction_content = NULL,
    show_briefing = TRUE,
    briefing_content = NULL,
    show_consent = TRUE,
    consent_content = NULL,
    show_gdpr_compliance = TRUE,
    gdpr_content = NULL,
    show_debriefing = TRUE,
    debriefing_content = NULL,
    demographic_configs = NULL,
    custom_demographic_ui = NULL,
    study_phases = c("introduction", "briefing", "consent", "demographics", "survey", "debriefing"),
    page_transitions = "fade",
    enable_back_navigation = TRUE,
    
    # Unknown parameter support
    unknown_param_handling = TRUE,
    param_initialization_method = "smart_defaults",
    auto_initialize_unknowns = TRUE,
    calibration_mode = FALSE,
    # Advanced customization parameters
    study_pages = NULL,
    page_contents = NULL,
    advanced_demographics = NULL,
    ui_config = NULL,
    language_config = NULL,
    data_config = NULL,
    quality_config = NULL,
    analytics_config = NULL,
    integration_config = NULL,
    custom_functions = NULL,
    study_metadata = NULL,
    
    # NEW: Participant report controls and demographic requirement
    participant_report = NULL,
    min_required_non_age_demographics = 1,
    ...
) {
  # Set default options to avoid inrep package reference issues
  if (is.null(getOption("inrep.verbose"))) {
    options(inrep.verbose = TRUE)
  }
  if (is.null(getOption("inrep.llm_assistance"))) {
    options(inrep.llm_assistance = FALSE)
  }
  
  # Initialize logging
  if (getOption("inrep.verbose", TRUE)) {
    message("Creating study configuration for: ", name)
  }
  
  # Capture extra parameters
  extra_params <- list(...)
  
  tryCatch({
    # Enhanced input validation with detailed error messages
    validation_errors <- c()
    
    # Validate required parameters
    if (!is.character(name) || nchar(name) == 0) {
      validation_errors <- c(validation_errors, "name must be a non-empty character string")
    }
    
    if (!is.null(demographics) && (!is.character(demographics) || length(demographics) == 0)) {
      validation_errors <- c(validation_errors, "demographics must be NULL or a non-empty character vector")
    }
    
    if (!is.character(study_key) || nchar(study_key) == 0) {
      validation_errors <- c(validation_errors, "study_key must be a non-empty character string")
    }
    
    if (!is.numeric(min_SEM) || min_SEM <= 0 || min_SEM > 1) {
      validation_errors <- c(validation_errors, "min_SEM must be a numeric value between 0 and 1")
    }
    
    if (!is.numeric(min_items) || min_items <= 0 || min_items > 100) {
      validation_errors <- c(validation_errors, "min_items must be a positive integer <= 100")
    }
    
    if (!is.null(max_items) && (!is.numeric(max_items) || max_items <= 0)) {
      validation_errors <- c(validation_errors, "max_items must be NULL or a positive integer")
    }
    
    if (!criteria %in% c("MI", "RANDOM", "WEIGHTED", "MFI")) {
      validation_errors <- c(validation_errors, "criteria must be one of: MI, RANDOM, WEIGHTED, MFI")
    }
    
    # Use smart model validation
    tryCatch({
      model <- validate_model(model)
    }, error = function(e) {
      # Don't add to validation_errors here, validate_model will show helpful message
      NULL
    })
    
    if (!estimation_method %in% c("TAM", "MIRT", "EAP", "WLE")) {
      validation_errors <- c(validation_errors, "estimation_method must be one of: TAM, MIRT, EAP, WLE")
    }
    
    if (!is.numeric(theta_prior) || length(theta_prior) != 2 || theta_prior[2] <= 0) {
      validation_errors <- c(validation_errors, "theta_prior must be a numeric vector of length 2 with positive standard deviation")
    }
    
    if (!progress_style %in% c("bar", "circle", "modern-circle", "enhanced-bar", "segmented", "minimal", "card")) {
      validation_errors <- c(validation_errors, "progress_style must be one of: bar, circle, modern-circle, enhanced-bar, segmented, minimal, card")
    }
    
    if (!response_ui_type %in% c("radio", "slider", "dropdown")) {
      validation_errors <- c(validation_errors, "response_ui_type must be one of: radio, slider, dropdown")
    }
    
    # Use smart theme validation
    tryCatch({
      theme <- validate_theme(theme)
    }, error = function(e) {
      # Don't add to validation_errors here, validate_theme will show helpful message
      NULL
    })
    
    if (!language %in% c("en", "de", "es", "fr")) {
      validation_errors <- c(validation_errors, "language must be one of: en, de, es, fr")
    }
    
    if (!all(report_formats %in% c("rds", "csv", "json", "pdf"))) {
      validation_errors <- c(validation_errors, "report_formats must be a subset of: rds, csv, json, pdf")
    }
    
    if (!is.numeric(max_session_duration) || max_session_duration <= 0) {
      validation_errors <- c(validation_errors, "max_session_duration must be a positive number")
    }
    
    if (!is.numeric(max_response_time) || max_response_time <= 0) {
      validation_errors <- c(validation_errors, "max_response_time must be a positive number")
    }
    
    # Check for validation errors
    if (length(validation_errors) > 0) {
      stop("Configuration validation failed:\n", paste("  -", validation_errors, collapse = "\n"))
    }
    
    # Validate max_items and min_items relationship
    if (!is.null(max_items) && max_items < min_items) {
      stop("max_items (", max_items, ") must be at least min_items (", min_items, ")")
    }
    
    # Validate fixed_items
    if (!is.null(fixed_items) && length(fixed_items) > 0) {
      if (!is.numeric(fixed_items) || any(fixed_items <= 0)) {
        stop("fixed_items must be a vector of positive integers")
      }
      if (!is.null(max_items) && max_items < length(fixed_items)) {
        if (getOption("inrep.verbose", TRUE)) {
          message("Adjusting max_items to accommodate fixed_items")
        }
        max_items <- length(fixed_items)
      }
      min_items <- min(min_items, length(fixed_items))
    }
    
    # Validate item_translations
    if (!is.null(item_translations)) {
      valid_langs <- c("en", "de", "es", "fr")
      invalid_langs <- setdiff(names(item_translations), valid_langs)
      if (length(invalid_langs) > 0) {
        stop("Invalid languages in item_translations: ", paste(invalid_langs, collapse = ", "), 
             ". Valid languages are: ", paste(valid_langs, collapse = ", "))
      }
    }
    
    # Validate demographics and input_types
    if (!is.null(demographics)) {
      if (is.null(input_types)) {
        # Set sensible defaults
        input_types <- setNames(rep("text", length(demographics)), demographics)
        if ("Age" %in% demographics) input_types["Age"] <- "numeric"
        if ("Gender" %in% demographics) input_types["Gender"] <- "select"
        if ("Education" %in% demographics) input_types["Education"] <- "select"
      } else {
        if (!is.list(input_types) || !all(demographics %in% names(input_types))) {
          stop("input_types must be a named list with entries for all demographics")
        }
        valid_types <- c("text", "numeric", "select", "radio", "checkbox")
        invalid_types <- setdiff(unlist(input_types), valid_types)
        if (length(invalid_types) > 0) {
          stop("Invalid input types: ", paste(invalid_types, collapse = ", "), 
               ". Valid types are: ", paste(valid_types, collapse = ", "))
        }
      }
    } else {
      input_types <- NULL
    }
    
    # Set default functions if not provided
    if (is.null(recommendation_fun)) {
      recommendation_fun <- function(theta, demographics, item_responses) {
        if (!is.numeric(theta) || length(theta) == 0 || is.na(theta)) theta <- 0
        if (theta < -1) {
          c("Focus on foundational skills", "Seek supportive resources", "Consider additional practice")
        } else if (theta < 1) {
          c("Engage in balanced development", "Explore intermediate challenges", "Build on current strengths")
        } else {
          c("Pursue advanced opportunities", "Apply skills in complex scenarios", "Consider mentoring others")
        }
      }
    }
    
    if (is.null(scoring_fun)) {
      scoring_fun <- if (model == "GRM") {
        function(response, correct_answer) as.numeric(response)
      } else {
        function(response, correct_answer) {
          # Graceful fallback when correct answers are not available
          if (is.null(correct_answer) || length(correct_answer) == 0 || is.na(correct_answer)) {
            if (is.numeric(response)) {
              # If already numeric (0/1), return as-is
              if (length(response) == 0) NA_real_ else as.numeric(response)
            } else {
              # Treat first option ("1") as correct when no key is available
              as.numeric(as.character(response) == "1")
            }
          } else {
            as.numeric(response == correct_answer)
          }
        }
      }
    }
    
    if (is.null(response_validation_fun)) {
      response_validation_fun <- function(response) {
        !is.null(response) && !is.na(response) && nchar(as.character(response)) > 0
      }
    }
    
    # Set default adaptive_start
    if (is.null(adaptive_start)) {
      adaptive_start <- if (!is.null(max_items)) {
        max(1, ceiling(max_items / 2))
      } else {
        max(1, ceiling(min_items / 2))
      }
    }
    
    # Create core configuration
    config <- list(
      name = name,
      demographics = demographics,
      study_key = study_key,
      min_SEM = min_SEM,
      min_items = min_items,
      max_items = max_items,
      criteria = criteria,
      model = model,
      estimation_method = estimation_method,
      recommendation_fun = recommendation_fun,
      theta_prior = theta_prior,
      stopping_rule = stopping_rule,
      input_types = input_types,
      scoring_fun = scoring_fun,
      adaptive_start = adaptive_start,
      fixed_items = fixed_items,
      adaptive = adaptive,
      item_groups = item_groups,
      custom_ui_pre = custom_ui_pre,
      progress_style = progress_style,
      response_validation_fun = response_validation_fun,
      response_ui_type = response_ui_type,
      session_save = session_save,
      theme = theme,
      language = language,
      item_translations = item_translations,
      report_formats = report_formats,
      max_session_duration = max_session_duration,
      max_response_time = max_response_time,
      cache_enabled = cache_enabled,
      parallel_computation = parallel_computation,
      feedback_enabled = feedback_enabled,
      theta_grid = theta_grid,
      
      # Participant report controls and demographic requirement
      participant_report = participant_report %||% list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = TRUE,
        show_item_difficulty_trend = FALSE,
        show_domain_breakdown = FALSE,
        use_enhanced_report = TRUE
      ),
      min_required_non_age_demographics = min_required_non_age_demographics,
      
      # Enhanced study flow features
      show_introduction = show_introduction,
      introduction_content = introduction_content %||% create_default_introduction_content(get_language_labels(language)),
      show_briefing = show_briefing,
              briefing_content = briefing_content %||% create_default_briefing_content(get_language_labels(language)),
      show_consent = show_consent,
              consent_content = consent_content %||% create_default_consent_content(get_language_labels(language)),
      show_gdpr_compliance = show_gdpr_compliance,
              gdpr_content = gdpr_content %||% create_default_gdpr_content(get_language_labels(language)),
      show_debriefing = show_debriefing,
              debriefing_content = debriefing_content %||% create_default_debriefing_content(get_language_labels(language)),
              demographic_configs = demographic_configs %||% create_default_demographic_configs(demographics, input_types, get_language_labels(language)),
      custom_demographic_ui = custom_demographic_ui,
      study_phases = study_phases,
      page_transitions = page_transitions,
      enable_back_navigation = enable_back_navigation,
      
      # Unknown parameter support
      unknown_param_handling = unknown_param_handling,
      param_initialization_method = param_initialization_method,
      auto_initialize_unknowns = auto_initialize_unknowns,
      calibration_mode = calibration_mode
    )
    
    # Add enhanced features if specified
    enhanced_features <- list()
    
    # Multidimensional IRT support
    if (!is.null(extra_params$multidimensional) && extra_params$multidimensional) {
      enhanced_features$multidimensional <- list(
        enabled = TRUE,
        dimensions = extra_params$dimensions %||% 2,
        model_type = extra_params$multidim_model %||% "M2PL",
        estimation_method = extra_params$multidim_estimation %||% "MIRT"
      )
    }
    
    # Advanced item selection
    if (!is.null(extra_params$advanced_selection) && extra_params$advanced_selection) {
      enhanced_features$advanced_selection <- list(
        enabled = TRUE,
        methods = extra_params$selection_methods %||% c("MI", "ensemble"),
        constraints = extra_params$selection_constraints %||% list(),
        exposure_control = extra_params$exposure_control %||% list(),
        ml_model = extra_params$ml_selection_model %||% NULL
      )
    }
    
    # Quality control and monitoring
    if (!is.null(extra_params$quality_monitoring) && extra_params$quality_monitoring) {
      enhanced_features$quality_monitoring <- list(
        enabled = TRUE,
        real_time = extra_params$real_time_monitoring %||% FALSE,
        quality_rules = extra_params$quality_rules %||% list(),
        alert_callback = extra_params$alert_callback %||% NULL
      )
    }
    
    # Enterprise security features
    if (!is.null(extra_params$enterprise_security) && extra_params$enterprise_security) {
      enhanced_features$enterprise_security <- list(
        enabled = TRUE,
        auth_provider = extra_params$auth_provider %||% "local",
        encryption_enabled = extra_params$encryption_enabled %||% TRUE,
        audit_logging = extra_params$audit_logging %||% TRUE,
        session_timeout = extra_params$secure_session_timeout %||% 60
      )
    }
    
    # Accessibility and mobile features
    if (!is.null(extra_params$accessibility_enhanced) && extra_params$accessibility_enhanced) {
      enhanced_features$accessibility <- list(
        enabled = TRUE,
        wcag_level = extra_params$wcag_level %||% "AA",
        accommodations = extra_params$accommodations %||% c("screen_reader", "keyboard_nav"),
        mobile_optimized = extra_params$mobile_optimized %||% TRUE,
        pwa_enabled = extra_params$pwa_enabled %||% FALSE
      )
    }
    
    # Add enhanced features if any are configured
    if (length(enhanced_features) > 0) {
      config$enhanced_features <- enhanced_features
      if (getOption("inrep.verbose", TRUE)) {
        message("Enhanced features enabled: ", paste(names(enhanced_features), collapse = ", "))
      }
    }
    
    # Add advanced customization features if provided
    if (!is.null(study_pages)) config$study_pages <- study_pages
    if (!is.null(page_contents)) config$page_contents <- page_contents
    if (!is.null(advanced_demographics)) config$advanced_demographics <- advanced_demographics
    if (!is.null(ui_config)) config$ui_config <- ui_config
    if (!is.null(language_config)) config$language_config <- language_config
    if (!is.null(data_config)) config$data_config <- data_config
    if (!is.null(quality_config)) config$quality_config <- quality_config
    if (!is.null(analytics_config)) config$analytics_config <- analytics_config
    if (!is.null(integration_config)) config$integration_config <- integration_config
    if (!is.null(custom_functions)) config$custom_functions <- custom_functions
    
    # Add study metadata
    if (!is.null(study_metadata)) {
      config$study_metadata <- study_metadata
    } else {
      config$study_metadata <- list(
        creation_date = Sys.Date(),
        last_modified = Sys.time(),
        config_version = "2.0",
        package_version = if (requireNamespace("inrep", quietly = TRUE)) utils::packageVersion("inrep") else "unknown"
      )
    }
    
    # Mark as advanced configuration if advanced features are used
    advanced_features_used <- !is.null(study_pages) || !is.null(page_contents) || 
                              !is.null(advanced_demographics) || !is.null(ui_config)
    
    if (advanced_features_used) {
      config$is_advanced_config <- TRUE
      config$config_version <- "2.0"
      if (getOption("inrep.verbose", TRUE)) {
        message("Advanced configuration features enabled")
      }
    }
    
    # Add extra parameters to config
    if (length(extra_params) > 0) {
      config <- c(config, extra_params)
      if (getOption("inrep.verbose", TRUE)) {
        message("Added ", length(extra_params), " extra parameters to configuration")
      }
    }
    
    if (getOption("inrep.verbose", TRUE)) {
      message("Study configuration created successfully for: ", name)
    }
    
    # Generate LLM assistance prompt if enabled
    if (getOption("inrep.llm_assistance", FALSE)) {
      llm_prompt <- generate_config_optimization_prompt(config)
      message(paste(rep("=", 60), collapse = ""))
      message("LLM ASSISTANCE: CONFIGURATION OPTIMIZATION")
      message(paste(rep("=", 60), collapse = ""))
      message("Copy the following prompt to ChatGPT, Claude, or your preferred LLM for advanced configuration insights:")
      message("")
      message(llm_prompt)
      message("")
      message(paste(rep("=", 60), collapse = ""))
      message("")
    }
    
    return(config)
    
  }, error = function(e) {
    stop("Configuration creation failed: ", e$message, call. = FALSE)
  })
}

#' Generate Configuration Optimization Prompt for LLM Assistance
#' @noRd
generate_config_optimization_prompt <- function(config) {
  study_type <- if (config$model == "GRM") "personality/psychological" else "cognitive/educational"
  
  prompt <- paste0(
    "# EXPERT STUDY CONFIGURATION OPTIMIZATION\n\n",
    "You are an expert psychometrician specializing in adaptive testing and Item Response Theory. ",
    "I need help optimizing my study configuration for maximum psychometric validity and user experience.\n\n",
    
    "## CURRENT CONFIGURATION SUMMARY\n",
    "- Study Name: ", config$name, "\n",
    "- IRT Model: ", config$model, "\n",
    "- Item Range: ", config$min_items, " to ", config$max_items %||% "unlimited", " items\n",
    "- Stopping Criterion: SEM ≤ ", config$min_SEM, "\n",
    "- Selection Method: ", config$criteria, "\n",
    "- Theme: ", config$theme, "\n",
    "- Language: ", config$language, "\n",
    "- Session Duration: ", config$max_session_duration, " minutes\n",
    "- Demographics: ", paste(config$demographics %||% "None", collapse = ", "), "\n\n",
    
    "## OPTIMIZATION REQUESTS\n\n",
    "### 1. Psychometric Parameter Optimization\n",
    "- Evaluate min_SEM (", config$min_SEM, ") appropriateness for ", study_type, " assessment\n",
    "- Optimize min_items/max_items balance for precision vs burden\n",
    "- Assess ", config$criteria, " item selection strategy effectiveness\n",
    "- Review theta_prior distribution for target population\n\n",
    
    "### 2. User Experience Enhancement\n",
    "- Optimize session duration (", config$max_session_duration, " min) for target population\n",
    "- Evaluate demographic data collection strategy\n",
    "- Assess theme choice (", config$theme, ") psychological impact\n",
    "- Review progress feedback and motivation elements\n\n",
    
    "### 3. Quality Control Strategy\n",
    "- Recommend response validation procedures\n",
    "- Suggest rapid response detection thresholds\n",
    "- Plan data quality monitoring approaches\n",
    "- Design bias detection and mitigation strategies\n\n",
    
    "### 4. Research Validity Considerations\n",
    "- Ensure configuration supports research objectives\n",
    "- Plan for measurement invariance testing\n",
    "- Consider ethical and privacy implications\n",
    "- Design validation and calibration procedures\n\n",
    
    "## PROVIDE\n",
    "1. Detailed assessment of current configuration strengths/weaknesses\n",
    "2. Specific parameter optimization recommendations with rationale\n",
    "3. Enhanced configuration code with improvements\n",
    "4. Quality assurance and validation strategy\n",
    "5. Expected performance metrics and outcomes\n\n",
    
    "Please provide expert-level recommendations with specific, actionable improvements and R code examples."
  )
  
  return(prompt)
}
