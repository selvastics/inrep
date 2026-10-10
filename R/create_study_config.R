#' Create Study Configuration
#'
#' Creates a configuration object for adaptive (or fixed-form) assessment studies.
#' The configuration controls assessment workflow, session handling, and reporting.
#' inrep does not calibrate items. In adaptive mode it uses the item parameters in
#' the item bank as fixed and known (see Details).
#'
#' @param name Character string specifying the study name for identification and reporting.
#' @param demographics Character vector of demographic field names to collect, 
#'   or \code{NULL} for no demographic data collection.
#' @param study_key Character string providing unique identifier for the study. 
#'   Defaults to auto-generated UUID for session tracking.
#' @param min_SEM Numeric value specifying minimum standard error for stopping criterion.
#'   The standard error is the posterior standard deviation of inrep's EAP estimate.
#'   Typical values: 0.2-0.4.
#' @param min_items Integer minimum number of items to administer before stopping rules apply.
#' @param max_items Integer maximum number of items to administer, or \code{NULL} to use 
#'   full item bank size. Prevents excessive test length.
#' @param criteria Character string specifying item selection criterion. Options:
#'   \code{"MI"}, \code{"MEI"}, \code{"RANDOM"}, \code{"WEIGHTED"}, \code{"MFI"}.
#'
#'   These options only apply when \code{fast_item_selection = FALSE}.
#'
#'   \strong{\code{"MI"} (default):} the item with the highest Fisher information
#'   at the current EAP estimate \eqn{\hat{\theta}}. Early in a test, when
#'   \eqn{\hat{\theta}} is uncertain, information at this single point may be a
#'   poor guide.
#'
#'   \strong{\code{"MEI"}:} Fisher information averaged over a normal
#'   approximation \eqn{N(\hat{\theta}, SE^2)} of the posterior. Despite the
#'   label, this is a posterior-weighted information criterion in the sense of
#'   van der Linden (1998, \emph{Psychometrika}, 63, 201--216), not the maximum
#'   expected information criterion of that paper. It may help early in a test
#'   or in short tests; for long tests it gives results close to \code{"MI"}.
#'
#'   \strong{\code{"WEIGHTED"}}: a random draw with probability proportional to
#'   information times a group weight that is larger for groups in
#'   \code{item_groups} with fewer administered items.
#'
#'   \strong{\code{"MFI"}}: a random draw among the items within 95\% of the
#'   maximum information. No exposure rates are tracked.
#'
#'   \strong{\code{"RANDOM"}}: random selection.
#' @param model Character string naming the IRT model of the item parameters in
#'   the item bank. Options: \code{"1PL"}, \code{"2PL"}, \code{"3PL"}, \code{"GRM"}
#'   (Samejima's graded response model with thresholds \code{b1}, \code{b2}, ...).
#'   The parameters must come from a calibration done beforehand, for example with
#'   TAM or mirt. Note that TAM fits partial credit models, not the GRM.
#' @param estimation_method Character string, \code{"EAP"} (default) or \code{"WLE"}.
#'   Kept for compatibility. During administration inrep always computes an EAP
#'   estimate on \code{theta_grid} with the item parameters held fixed. A WLE or any
#'   other final score can be computed in the \code{results_processor}, for example
#'   with \code{TAM::tam.wle()} and a calibrated model.
#' @param recommendation_fun Function called as \code{recommendation_fun(theta, demographics)}
#'   that returns recommendation texts for the results page, or \code{NULL}. With
#'   \code{NULL}, no recommendations are generated and the recommendations section
#'   is hidden unless \code{participant_report$show_recommendations} is set.
#' @param theta_prior Numeric vector of length 2 specifying prior mean and standard deviation
#'   of the ability distribution, used for inrep's EAP estimate. It should match the
#'   population distribution of the calibration.
#' @param stopping_rule Custom function implementing stopping logic, or \code{NULL} for 
#'   default SEM-based stopping. It is called as \code{stopping_rule(theta, se, n_items, rv)}
#'   and returns \code{TRUE} to stop.
#' @param input_types Named list specifying input types for demographic fields.
#'   Options: \code{"text"}, \code{"numeric"}, \code{"select"}, \code{"radio"}, \code{"checkbox"}.
#' @param scoring_fun Function to score item responses, or \code{NULL} for default scoring.
#'   Should accept response and correct answer, return numeric score.
#' @param adaptive_start Integer item number at which adaptive (Fisher-information)
#'   selection begins. Items before it are selected at random. Defaults to
#'   \code{min_items} (5 by default, so items 1 to 4 are random). Set to 1 for
#'   adaptive selection from the first item.
#' @param fixed_items Integer vector of item indices administered first, in this
#'   order, or \code{NULL} for no fixed items.
#' @param adaptive Logical indicating whether to use adaptive item selection based on 
#'   inrep's running EAP estimate. When \code{TRUE} (default), items are selected dynamically 
#'   based on the participant's estimated ability to maximize information. When \code{FALSE}, 
#'   items are administered in sequential order from the item bank (non-adaptive mode).
#'   Note: When \code{adaptive = FALSE}, the assessment simply presents items 1 through 
#'   \code{max_items} in order, making it a standard fixed-form questionnaire.
#' @param item_groups Named list of item index vectors. Used by the
#'   \code{"WEIGHTED"} criterion and, in non-adaptive mode, to restrict the items
#'   administered; \code{NULL} for none.
#' @param custom_ui_pre Stored in the configuration; currently not used by inrep.
#' @param progress_style Character string specifying progress indicator style.
#'   Options: \code{"bar"}, \code{"circle"}, \code{"modern-circle"}, \code{"enhanced-bar"}, \code{"segmented"}, \code{"minimal"}, \code{"card"}, \code{"none"} (hidden).
#' @param response_validation_fun Function to validate participant responses, 
#'   or \code{NULL} for default validation. Should return logical.
#' @param response_ui_type Character string specifying response input interface.
#'   Options: \code{"radio"}, \code{"slider"}, \code{"dropdown"}.
#' @param response_layout Character string specifying how radio button choices are
#'   displayed. \code{"vertical"} (default) stacks each option on its own line,
#'   matching standard Shiny output. \code{"horizontal"} places all options side by
#'   side; works well for short labels (e.g. 2-4 options) but can be crowded for
#'   5+ options with long labels.
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
#' @param report_formats Character vector, a subset of \code{"rds"}, \code{"csv"},
#'   \code{"json"}, \code{"pdf"}. Validated and stored; currently not read
#'   elsewhere in inrep.
#' @param show_scale_scores Logical. If \code{FALSE}, results pages act as a
#'   plain thank-you page: the \code{results_processor} still runs on the final
#'   results page for its side effects (e.g. uploads), but its report is not shown.
#' @param max_session_duration Integer maximum session duration in minutes for timeout.
#' @param max_response_time Stored in the configuration; currently not used by inrep.
#' @param cache_enabled Stored in the configuration; currently not used by inrep.
#' @param parallel_computation Stored in the configuration; currently not used by inrep.
#' @param fast_item_selection Logical. When \code{TRUE} (default), each selection step
#'   evaluates Fisher information at the current estimate for a random subset of at
#'   most 15 available items and draws among those within 90\% of the maximum, for
#'   every \code{criteria}. Set to \code{FALSE} to select by \code{criteria} as described.
#' @param feedback_enabled Logical indicating whether to provide immediate feedback
#'   after each item response.
#' @param theta_grid Numeric vector, the grid on which inrep evaluates the posterior
#'   for its EAP estimate.
#' @param show_introduction Logical indicating whether to display introduction page
#'   with study overview and briefing information.
#' @param introduction_content Character string containing HTML content for 
#'   introduction page, or \code{NULL} for default content.
#' @param show_briefing Logical indicating whether to display detailed briefing
#'   about study procedures, ethics, and expectations.
#' @param briefing_content Character string containing HTML content for briefing,
#'   or \code{NULL} for default academic briefing.
#' @param show_consent Logical indicating whether to display an informed consent page.
#' @param consent_content Character string containing HTML consent form content,
#'   or \code{NULL} for a default template (review and edit for your study).
#' @param show_gdpr_compliance Logical indicating whether to include a GDPR/DSGVO
#'   data protection information page/template.
#' @param gdpr_content Character string containing GDPR/DSGVO information text,
#'   or \code{NULL} for a default template (review and edit for your study).
#' @param show_debriefing Logical indicating whether to display debriefing page
#'   after study completion with study purpose and resources.
#' @param debriefing_content Character string containing HTML debriefing content,
#'   or \code{NULL} for default debriefing.
#' @param demographic_configs Named list providing full control over demographic
#'   questions, including custom labels, response options, validation rules,
#'   and display formatting.
#' @param custom_demographic_ui Function to generate custom demographic UI,
#'   or \code{NULL} for default demographic interface.
#' @param custom_study_flow Named list defining custom study flow for specific studies
#'   (e.g., Hildesheim study). Allows specification of exact page order and content.
#'   Example: \code{list(start_with = "instructions", page_sequence = c("instructions", "demographics", "assessment", "results"))}.
#'   Defaults to NULL for standard flow.
#' @param custom_page_configs Named list providing configuration for each custom page,
#'   including content, validation rules, and navigation logic.
#'   Example: \code{list(instructions = list(content = "Custom instructions", validation = "required"))}.
#'   Defaults to NULL for standard flow.
#' @param enable_custom_navigation Logical indicating whether to enable custom page navigation
#'   for studies requiring specific flow control. Defaults to FALSE for backward compatibility.
#' @param study_phases Stored in the configuration; currently not used by inrep.
#' @param page_transitions Stored in the configuration; currently not used by inrep.
#' @param enable_back_navigation Stored in the configuration; currently not used by inrep.
#' @param unknown_param_handling Stored in the configuration; currently not used.
#'   Missing item parameters are always replaced by fixed defaults in
#'   \code{\link{estimate_ability}} and \code{\link{compute_item_info_single}}.
#' @param param_initialization_method Stored in the configuration; currently not used.
#' @param auto_initialize_unknowns Stored in the configuration; currently not used.
#' @param calibration_mode Stored in the configuration; currently not used. inrep
#'   does not calibrate items.
#' @param study_pages Optional list defining an explicit page structure.
#' @param page_contents Optional list of per-page content definitions.
#' @param advanced_demographics Optional list providing advanced demographic collection
#'   configuration.
#' @param ui_config Optional list of UI-related configuration.
#' @param language_config Optional list of language-related configuration.
#' @param data_config Optional list of data export/storage configuration.
#' @param quality_config Optional list of quality checks configuration.
#' @param analytics_config Optional list of analytics configuration.
#' @param integration_config Optional list of integration settings.
#' @param custom_functions Optional named list of custom hooks/callbacks.
#' @param study_metadata Optional named list of metadata to attach to the configuration.
#' @param participant_report Optional configuration controlling participant-facing
#'   report generation.
#' @param min_required_non_age_demographics Integer specifying the minimum number of
#'   required demographic fields other than age.
#' @param exclude_from_recording Optional character vector of demographic field names
#'   to exclude from data-recording validation. By default every field listed in
#'   \code{demographics} must map to a recorded variable in the final data; listing
#'   a field here suppresses the warning for that specific field.
#' @param ... Additional named values, appended to the configuration as they are.
#'
#' @return Named list containing complete study configuration with all specified parameters
#'   and computed defaults. Compatible with \code{\link{launch_study}} and other inrep functions.
#' 
#' @details
#' \strong{What inrep computes:} inrep administers items, records responses and
#' carries out the study logic. It does not estimate item parameters, test model fit
#' or draw plausible values; these steps belong to a psychometric package such as TAM,
#' and their results can be passed to inrep (as item parameters in the item bank, or
#' as a calibrated model used in the \code{results_processor}).
#'
#' \strong{Adaptive Testing Configuration:} When \code{adaptive = TRUE}, inrep
#' \itemize{
#'   \item computes an EAP estimate and its posterior standard deviation after every
#'     response, on \code{theta_grid} with the prior \code{theta_prior} and the item
#'     parameters held fixed,
#'   \item selects the next item by Fisher information at that estimate (see
#'     \code{criteria} and \code{fast_item_selection}),
#'   \item stops by \code{stopping_rule}, or by default once \code{min_items} are
#'     answered and either \code{max_items} is reached or the standard error is at most
#'     \code{min_SEM}.
#' }
#' 
#' Response times are recorded per item; no rapid-response screening is done.
#'
#' \strong{Language:} \code{language} selects the built-in interface texts
#' (navigation, messages, progress and default demographic labels). Item texts
#' are only translated if \code{item_translations} provides them.
#'
#' \strong{HTML customization:} Pages in custom page flows accept these optional
#' fields:
#' \itemize{
#'   \item \code{custom_css}/\code{custom_css_en}: Inline CSS for page styling
#'   \item \code{html_prefix}/\code{html_prefix_en}: HTML content before main page
#'   \item \code{html_suffix}/\code{html_suffix_en}: HTML content after main page
#'   \item \code{wrapper_class}: CSS class for content wrapper
#'   \item \code{wrapper_style}: Inline styles for content wrapper
#' }
#' Parameters with \code{_en} suffix are used when language is English.
#' 
#' @examples
#' \dontrun{
#' # Example 1: Adaptive GRM study
#' basic_config <- create_study_config(
#'   name = "Big Five Example",
#'   model = "GRM",
#'   demographics = c("Age", "Gender", "Education"),
#'   max_items = 15,
#'   min_SEM = 0.3,
#'   language = "en",
#'   theme = "Light"
#' )
#' 
#' # Example 1b: Non-adaptive (fixed order) questionnaire
#' # Items 1 to 5 of the item bank are presented in order
#' fixed_config <- create_study_config(
#'   name = "Personality Questionnaire",
#'   adaptive = FALSE,
#'   max_items = 5,
#'   session_save = TRUE
#' )
#' 
#' # Example 2: 2PL study with selection by criteria and a recommendation function
#' research_config <- create_study_config(
#'   name = "Cognitive Ability Study",
#'   model = "2PL",
#'   min_items = 12,
#'   max_items = 25,
#'   min_SEM = 0.25,
#'   criteria = "MEI",
#'   fast_item_selection = FALSE,
#'   theta_prior = c(0, 1),
#'   demographics = c("Age", "Gender", "Education", "Native_Language", "Country"),
#'   input_types = list(
#'     Age = "numeric",
#'     Gender = "select", 
#'     Education = "select",
#'     Native_Language = "text",
#'     Country = "select"
#'   ),
#'   theme = "Professional",
#'   language = "en",
#'   session_save = TRUE,
#'   max_session_duration = 45,
#'   recommendation_fun = function(theta, demographics) {
#'     # Replace with texts written for the study
#'     if (theta < -0.5) "Text for lower scores" else "Text for other scores"
#'   }
#' )
#' 
#' # Example 3: Group weights with the WEIGHTED criterion
#' education_config <- create_study_config(
#'   name = "Mathematics Example",
#'   model = "2PL",
#'   min_items = 15,
#'   max_items = 30,
#'   min_SEM = 0.3,
#'   criteria = "WEIGHTED",
#'   fast_item_selection = FALSE,
#'   demographics = c("Grade", "School"),
#'   input_types = list(Grade = "select", School = "text"),
#'   item_groups = list(
#'     "Algebra" = c(1, 3, 5, 7, 9, 11, 13, 15),
#'     "Geometry" = c(2, 4, 6, 8, 10, 12, 14, 16),
#'     "Statistics" = c(17, 18, 19, 20, 21, 22, 23, 24)
#'   ),
#'   language = "en"
#' )
#' 
#' # Example 4: Item translations
#' multilingual_config <- create_study_config(
#'   name = "Cross-Cultural Personality Study",
#'   model = "GRM",
#'   min_items = 20,
#'   max_items = 40,
#'   min_SEM = 0.25,
#'   language = "en",
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
#'   demographics = c("Age", "Gender", "Country"),
#'   session_save = TRUE
#' )
#' 
#' str(basic_config)
#' }
#' 
#' @references
#' Robitzsch, A., Kiefer, T., & Wu, M. (2024). \emph{TAM: Test Analysis Modules}.
#'   R package version 4.2-21. \url{https://CRAN.R-project.org/package=TAM}
#'
#' Samejima, F. (1969). Estimation of latent ability using a response pattern of
#'   graded scores. \emph{Psychometrika Monograph Supplement}, No. 17.
#'
#' van der Linden, W. J. (1998). Bayesian item selection criteria for adaptive
#'   testing. \emph{Psychometrika}, 63(2), 201--216.
#'
#' van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). \emph{Elements of
#'   adaptive testing}. Springer.
#' 
#' @seealso \code{\link{launch_study}}, \code{\link{validate_item_bank}},
#'   \code{\link{estimate_ability}}, \code{\link{select_next_item}}
#' @export
create_study_config <- function(
    name = "Personality Assessment",
    demographics = c("Age", "Gender"),
    study_key = paste0("STUDY_", generate_uuid()),
    min_SEM = 0.3,
    min_items = 5,
    max_items = NULL,
    criteria = "MI",
    model = "GRM",
    estimation_method = "EAP",
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
    response_layout = "vertical",
    session_save = FALSE,
    show_session_time = FALSE,  # Hide session time display by default
    theme = "Professional",
    language = "en",
    item_translations = NULL,
    report_formats = c("rds", "csv", "json", "pdf"),
    show_scale_scores = TRUE,
    max_session_duration = 60,
    max_response_time = 300,
    cache_enabled = TRUE,
    parallel_computation = TRUE,
    fast_item_selection = TRUE,
    feedback_enabled = FALSE,
    theta_grid = seq(-4, 4, length.out = 100),
    # Study flow pages
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
    # Custom study flow support for specific studies (e.g., Hildesheim)
    custom_study_flow = NULL,
    custom_page_configs = NULL,
    enable_custom_navigation = FALSE,
    
    study_phases = c("introduction", "briefing", "consent", "demographics", "survey", "debriefing"),
    page_transitions = "fade",
    enable_back_navigation = TRUE,
    
    # Unknown parameter support
    unknown_param_handling = TRUE,
    param_initialization_method = "smart_defaults",
    auto_initialize_unknowns = TRUE,
    calibration_mode = FALSE,
    # Optional customization lists
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
    
    # Participant report controls and demographic requirement
    participant_report = NULL,
    min_required_non_age_demographics = 1,
    exclude_from_recording = NULL,
    ...
) {
  # Set default options to avoid inrep package reference issues
  if (is.null(getOption("inrep.verbose"))) {
    options(inrep.verbose = TRUE)
  }
  if (is.null(getOption("inrep.llm_assistance"))) {
    options(inrep.llm_assistance = FALSE)
  }
  
  if (getOption("inrep.verbose", TRUE)) {
    message("Creating study configuration for: ", name)
  }
  
  # Capture extra parameters
  extra_params <- list(...)
  
  tryCatch({
    # Input validation
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
    
    if (!criteria %in% c("MI", "MEI", "RANDOM", "WEIGHTED", "MFI")) {
      validation_errors <- c(validation_errors, paste0(
        "criteria must be one of: MI, MEI, RANDOM, WEIGHTED, MFI\n",
        "  MI       = maximum Fisher information at the current estimate\n",
        "  MEI      = Fisher information averaged over a normal approximation of the posterior\n",
        "  WEIGHTED = random draw weighted by information and item group weights\n",
        "  MFI      = random draw among items within 95% of the maximum information\n",
        "  RANDOM   = random selection"))
    }

    # Only these models are implemented in estimate_ability() and
    # compute_item_info_single(); others would silently be treated as 2PL.
    model_ok <- tryCatch({
      model <- validate_model(model)
      TRUE
    }, error = function(e) FALSE)
    if (!model_ok || !model %in% c("1PL", "2PL", "3PL", "GRM")) {
      validation_errors <- c(validation_errors, "model must be one of: 1PL, 2PL, 3PL, GRM")
    }

    if (!estimation_method %in% c("EAP", "WLE")) {
      validation_errors <- c(validation_errors, "estimation_method must be EAP or WLE (inrep computes an EAP estimate in both cases)")
    }
    
    if (!is.numeric(theta_prior) || length(theta_prior) != 2 || theta_prior[2] <= 0) {
      validation_errors <- c(validation_errors, "theta_prior must be a numeric vector of length 2 with positive standard deviation")
    }
    
    if (!progress_style %in% c("bar", "circle", "modern-circle", "enhanced-bar", "segmented", "minimal", "card", "none")) {
      validation_errors <- c(validation_errors, "progress_style must be one of: bar, circle, modern-circle, enhanced-bar, segmented, minimal, card, none")
    }
    
    if (!response_ui_type %in% c("radio", "slider", "dropdown")) {
      validation_errors <- c(validation_errors, "response_ui_type must be one of: radio, slider, dropdown")
    }
    
    if (!response_layout %in% c("vertical", "horizontal", "horizontal_all", "horizontal_endpoints")) {
      validation_errors <- c(validation_errors, "response_layout must be one of: vertical, horizontal, horizontal_all, horizontal_endpoints")
    }
    
    # An invalid theme is ignored here (the value is kept as given)
    tryCatch({
      theme <- validate_theme(theme)
    }, error = function(e) {
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
    
    # Validate max_items and min_items relationship (only meaningful for adaptive CAT)
    if (isTRUE(adaptive) && !is.null(max_items) && max_items < min_items) {
      stop("max_items (", max_items, ") must be at least min_items (", min_items, ") for adaptive studies")
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
        valid_types <- c("text", "numeric", "select", "radio", "checkbox", "slider")
        invalid_types <- setdiff(unlist(input_types), valid_types)
        if (length(invalid_types) > 0) {
          stop("Invalid input types: ", paste(invalid_types, collapse = ", "), 
               ". Valid types are: ", paste(valid_types, collapse = ", "))
        }
      }
    } else {
      input_types <- NULL
    }
    
    # Without a user function there are no recommendations to show
    has_recommendation_fun <- !is.null(recommendation_fun)
    if (!has_recommendation_fun) {
      recommendation_fun <- function(theta, demographics, item_responses = NULL) {
        character(0)
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
    
    # Items before adaptive_start are drawn at random
    if (is.null(adaptive_start)) {
      adaptive_start <- min_items %||% 3
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
      response_layout = response_layout,
      session_save = session_save,
      show_session_time = show_session_time,
      theme = theme,
      language = language,
      item_translations = item_translations,
      report_formats = report_formats,
      show_scale_scores = show_scale_scores,
      max_session_duration = max_session_duration,
      max_response_time = max_response_time,
      fast_item_selection = fast_item_selection,
      cache_enabled = cache_enabled,
      parallel_computation = parallel_computation,
      feedback_enabled = feedback_enabled,
      theta_grid = theta_grid,
      
      # Participant report controls and demographic requirement
      participant_report = participant_report %||% list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = has_recommendation_fun,
        show_item_difficulty_trend = FALSE,
        show_domain_breakdown = FALSE,
        use_enhanced_report = TRUE
      ),
      min_required_non_age_demographics = min_required_non_age_demographics,
      
      # Fields to exclude from data-recording validation.
      # By default all demographics must map to a recorded variable;
      # list field names here to suppress the warning for specific fields.
      exclude_from_recording = exclude_from_recording,
      
      # Study flow pages
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
      
      # Custom study flow support for specific studies (e.g., Hildesheim)
      custom_study_flow = custom_study_flow,
      custom_page_configs = custom_page_configs,
      enable_custom_navigation = enable_custom_navigation,
      
      study_phases = study_phases,
      page_transitions = page_transitions,
      enable_back_navigation = enable_back_navigation,
      
      # Unknown parameter support
      unknown_param_handling = unknown_param_handling,
      param_initialization_method = param_initialization_method,
      auto_initialize_unknowns = auto_initialize_unknowns,
      calibration_mode = calibration_mode
    )
    
    # Options such as multidimensional, advanced_selection, quality_monitoring,
    # enterprise_security or accessibility_enhanced passed through `...` are
    # stored as given (below); inrep implements none of these features.
    
    # Optional customization lists
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
        message("Custom page or UI configuration supplied")
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
    
    
    return(config)
    
  }, error = function(e) {
    stop("Configuration creation failed: ", e$message, call. = FALSE)
  })
}

