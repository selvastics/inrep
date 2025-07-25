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
#'   TAM ability estimates. \code{FALSE} results in fixed-order administration.
#' @param item_groups Named list defining item groups for content balancing, 
#'   or \code{NULL} for no grouping constraints.
#' @param custom_ui_pre Custom UI elements to display before assessment, 
#'   or \code{NULL} for standard interface.
#' @param progress_style Character string specifying progress indicator style.
#'   Options: \code{"bar"}, \code{"circle"}.
#' @param response_validation_fun Function to validate participant responses, 
#'   or \code{NULL} for default validation. Should return logical.
#' @param response_ui_type Character string specifying response input interface.
#'   Options: \code{"radio"}, \code{"slider"}, \code{"dropdown"}.
#' @param session_save Logical indicating whether to enable session state persistence
#'   for interrupted session recovery.
#' @param theme Character string specifying built-in UI theme. Options: \code{"Light"}, 
#'   \code{"Midnight"}, \code{"Sunset"}, \code{"Forest"}, \code{"Ocean"}, \code{"Berry"}.
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
    study_key = paste0("STUDY_", uuid::UUIDgenerate()),
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
    theme = "Light",
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
    ...
) {
  print("Creating study configuration...")
  
  # Capture extra parameters
  extra_params <- list(...)
  
  tryCatch({
    # Validate inputs
    stopifnot(
      is.character(name) && nzchar(name),
      is.null(demographics) || (is.character(demographics) && length(demographics) > 0),
      is.character(study_key) && nzchar(study_key),
      is.numeric(min_SEM) && min_SEM > 0 && min_SEM <= 1,
      is.numeric(min_items) && min_items > 0 && min_items <= 100,
      is.null(max_items) || (is.numeric(max_items) && max_items > 0),
      is.character(criteria) && criteria %in% c("MI", "RANDOM", "WEIGHTED", "MFI"),
      is.character(model) && model %in% c("1PL", "2PL", "3PL", "GRM"),
      is.character(estimation_method) && estimation_method %in% c("TAM", "MIRT"),
      is.numeric(theta_prior) && length(theta_prior) == 2 && theta_prior[2] > 0,
      is.character(progress_style) && progress_style %in% c("bar", "circle"),
      is.character(response_ui_type) && response_ui_type %in% c("radio", "slider", "dropdown"),
      is.logical(session_save),
      is.character(theme) && !is.null(validate_theme_name(theme)),
      is.character(language) && language %in% c("en", "de", "es", "fr"),
      is.character(report_formats) && all(report_formats %in% c("rds", "csv", "json", "pdf")),
      is.numeric(max_session_duration) && max_session_duration > 0,
      is.numeric(max_response_time) && max_response_time > 0,
      is.logical(cache_enabled),
      is.logical(parallel_computation),
      is.logical(feedback_enabled),
      is.null(item_translations) || is.list(item_translations),
      is.null(fixed_items) || (is.numeric(fixed_items) && all(fixed_items > 0)),
      is.numeric(theta_grid) && length(theta_grid) >= 2
    )
    
    # Validate max_items and min_items
    if (!is.null(max_items) && max_items < min_items) {
      print("max_items must be at least min_items")
      stop("max_items must be at least min_items")
    }
    
    # Validate fixed_items
    if (!is.null(fixed_items) && length(fixed_items) > 0) {
      if (!is.null(max_items) && max_items < length(fixed_items)) {
        print("max_items adjusted to match fixed_items length")
        max_items <- length(fixed_items)
      }
      min_items <- min(min_items, length(fixed_items))
    }
    
    # Validate item_translations
    if (!is.null(item_translations)) {
      valid_langs <- c("en", "de", "es", "fr")
      if (!all(names(item_translations) %in% valid_langs)) {
        print("Item translations must be for languages: en, de, es, fr")
        stop("Item translations must be for languages: en, de, es, fr")
      }
      for (lang in names(item_translations)) {
        if (!is.data.frame(item_translations[[lang]]) || 
            nrow(item_translations[[lang]]) != nrow(item_translations[[names(item_translations)[1]]])) {
          print(sprintf("Translations for %s must be a data frame with consistent rows", lang))
          stop(sprintf("Translations for %s must be a data frame with consistent rows", lang))
        }
      }
    }
    
    # Validate demographics and input_types
    if (!is.null(demographics)) {
      if (is.null(input_types)) {
        input_types <- setNames(rep("text", length(demographics)), demographics)
        if ("Age" %in% demographics) input_types["Age"] <- "numeric"
        if ("Gender" %in% demographics) input_types["Gender"] <- "select"
      } else {
        if (!is.list(input_types) || !all(demographics %in% names(input_types))) {
          print("input_types must be a named list with entries for all demographics")
          stop("input_types must be a named list with entries for all demographics")
        }
        valid_types <- c("text", "numeric", "select")
        if (!all(sapply(input_types, function(x) x %in% valid_types))) {
          print("input_types must be 'text', 'numeric', or 'select'")
          stop("input_types must be 'text', 'numeric', or 'select'")
        }
      }
    } else {
      input_types <- NULL
    }
    
    # Set default recommendation_fun
    if (is.null(recommendation_fun)) {
      recommendation_fun <- function(theta, demographics) {
        if (!is.numeric(theta) || length(theta) == 0 || is.na(theta)) theta <- 0
        if (theta < -1) c("Focus on foundational skills", "Seek supportive resources")
        else if (theta < 1) c("Engage in balanced development", "Explore intermediate challenges")
        else c("Pursue advanced opportunities", "Apply skills in complex scenarios")
      }
    }
    
    # Set default scoring_fun
    if (is.null(scoring_fun)) {
      scoring_fun <- if (model == "GRM") {
        function(response, correct_answer) as.numeric(response)
      } else {
        function(response, correct_answer) as.numeric(response == correct_answer)
      }
    }
    
    # Set default response_validation_fun
    if (is.null(response_validation_fun)) {
      response_validation_fun <- function(response) !is.null(response) && nzchar(as.character(response))
    }
    
    # Set default adaptive_start
    if (is.null(adaptive_start)) {
      adaptive_start <- ceiling((if(is.null(max_items)) min_items else max_items) / 2)
    }
    
    # Core configuration
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
      # Enhanced study flow features
      show_introduction = show_introduction,
      introduction_content = introduction_content %||% create_default_introduction_content(),
      show_briefing = show_briefing,
      briefing_content = briefing_content %||% create_default_briefing_content(),
      show_consent = show_consent,
      consent_content = consent_content %||% create_default_consent_content(),
      show_gdpr_compliance = show_gdpr_compliance,
      gdpr_content = gdpr_content %||% create_default_gdpr_content(),
      show_debriefing = show_debriefing,
      debriefing_content = debriefing_content %||% create_default_debriefing_content(),
      demographic_configs = demographic_configs %||% create_default_demographic_configs(demographics, input_types),
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
    
    # Enhanced features from extra_params (opt-in basis)
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
    
    # Cognitive load reduction
    if (!is.null(extra_params$cognitive_support) && extra_params$cognitive_support) {
      enhanced_features$cognitive_support <- list(
        enabled = TRUE,
        complexity_analysis = extra_params$complexity_analysis %||% TRUE,
        progressive_disclosure = extra_params$progressive_disclosure %||% TRUE,
        cognitive_aids = extra_params$cognitive_aids %||% c("visual_cues", "chunking")
      )
    }
    
    # Add enhanced features if any are configured
    if (length(enhanced_features) > 0) {
      config$enhanced_features <- enhanced_features
      print(sprintf("Enhanced features enabled: %s", 
                       paste(names(enhanced_features), collapse = ", ")))
    }
    
    # Add advanced customization features if provided
    if (!is.null(study_pages)) {
      config$study_pages <- study_pages
    }
    
    if (!is.null(page_contents)) {
      config$page_contents <- page_contents
    }
    
    if (!is.null(advanced_demographics)) {
      config$advanced_demographics <- advanced_demographics
      # Process advanced demographics into standard format
      if (is.null(config$demographic_configs)) {
        processed_demos <- list()
        demo_names <- c()
        input_types_adv <- list()
        
        for (section_name in names(advanced_demographics)) {
          section <- advanced_demographics[[section_name]]
          if ("questions" %in% names(section)) {
            for (q_name in names(section$questions)) {
              question <- section$questions[[q_name]]
              demo_names <- c(demo_names, q_name)
              input_types_adv[[q_name]] <- question$type
              
              processed_demos[[q_name]] <- list(
                question = question$question,
                input_type = question$type,
                required = question$required %||% FALSE,
                options = question$options,
                section_title = section$section_title
              )
            }
          }
        }
        
        if (length(processed_demos) > 0) {
          config$demographic_configs <- processed_demos
          config$demographics <- demo_names
          config$input_types <- input_types_adv
        }
      }
    }
    
    if (!is.null(ui_config)) {
      config$ui_config <- ui_config
      # Override theme if specified in ui_config
      if (!is.null(ui_config$theme)) {
        config$theme <- ui_config$theme
      }
    }
    
    if (!is.null(language_config)) {
      config$language_config <- language_config
      # Override language if specified
      if (!is.null(language_config$default_language)) {
        config$language <- language_config$default_language
      }
    }
    
    if (!is.null(data_config)) {
      config$data_config <- data_config
      # Override session settings if specified
      if (!is.null(data_config$session_timeout)) {
        config$max_session_duration <- data_config$session_timeout
      }
      if (!is.null(data_config$save_format)) {
        config$report_formats <- data_config$save_format
      }
    }
    
    if (!is.null(quality_config)) {
      config$quality_config <- quality_config
    }
    
    if (!is.null(analytics_config)) {
      config$analytics_config <- analytics_config
    }
    
    if (!is.null(integration_config)) {
      config$integration_config <- integration_config
    }
    
    if (!is.null(custom_functions)) {
      config$custom_functions <- custom_functions
    }
    
    if (!is.null(study_metadata)) {
      config$study_metadata <- study_metadata
    } else {
      # Add default metadata
      config$study_metadata <- list(
        creation_date = Sys.Date(),
        last_modified = Sys.time(),
        config_version = "2.0"
      )
    }
    
    # Mark as advanced configuration if advanced features are used
    advanced_features_used <- !is.null(study_pages) || !is.null(page_contents) || 
                              !is.null(advanced_demographics) || !is.null(ui_config)
    
    if (advanced_features_used) {
      config$is_advanced_config <- TRUE
      config$config_version <- "2.0"
      print("Advanced configuration features enabled")
    }
    
    # Add extra parameters to config
    if (length(extra_params) > 0) {
      config <- c(config, extra_params)
      print(sprintf("Added %d extra parameters to configuration", length(extra_params)))
    }
    
    print("Study configuration created successfully")
    
    # Generate LLM assistance prompt for configuration optimization
    if (getOption("inrep.llm_assistance", FALSE)) {
      llm_prompt <- generate_config_optimization_prompt(config)
      cat("\n" %r% 60, "\n")
      cat("LLM ASSISTANCE: CONFIGURATION OPTIMIZATION\n")
      cat("=" %r% 60, "\n")
      cat("Copy the following prompt to ChatGPT, Claude, or your preferred LLM for advanced configuration insights:\n\n")
      cat(llm_prompt)
      cat("\n" %r% 60, "\n\n")
    }
    
    return(config)
  }, error = function(e) {
    print(paste("Configuration creation failed:", e$message))
    stop(e)
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