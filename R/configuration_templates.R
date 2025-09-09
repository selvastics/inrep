#' Configuration Templates for Common Study Types
#' 
#' Provides pre-configured study templates for common assessment scenarios
#' to reduce setup time and ensure best practices.
#' 
#' @name configuration_templates
#' @keywords internal
NULL

#' Get Configuration Template
#' 
#' Retrieves a pre-configured study template for common assessment types
#' 
#' @param template_name Name of the template to retrieve
#' @param customizations Named list of customizations to apply to the template
#' @return Study configuration object
#' @export
get_config_template <- function(template_name, customizations = NULL) {
  
  templates <- list(
    
    # Personality Assessment Template
    personality_assessment = list(
      name = "Personality Assessment",
      model = "GRM",
      adaptive = TRUE,
      max_items = 20,
      min_items = 10,
      min_SEM = 0.3,
      criteria = "MI",
      demographics = c("Age", "Gender", "Education"),
      theme = "professional",
      participant_report = list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = TRUE,
        use_enhanced_report = TRUE
      ),
      save_format = "pdf"
    ),
    
    # Cognitive Ability Template
    cognitive_ability = list(
      name = "Cognitive Ability Assessment",
      model = "2PL",
      adaptive = TRUE,
      max_items = 25,
      min_items = 15,
      min_SEM = 0.25,
      criteria = "MFI",
      demographics = c("Age", "Gender", "Education", "Native_Language"),
      theme = "professional",
      parallel_computation = TRUE,
      cache_enabled = TRUE,
      participant_report = list(
        show_theta_plot = TRUE,
        show_item_difficulty_trend = TRUE,
        show_domain_breakdown = TRUE,
        use_enhanced_report = TRUE
      ),
      save_format = "pdf"
    ),
    
    # Educational Diagnostic Template
    educational_diagnostic = list(
      name = "Educational Diagnostic Assessment",
      model = "3PL",
      adaptive = TRUE,
      max_items = 30,
      min_items = 20,
      min_SEM = 0.2,
      criteria = "WEIGHTED",
      demographics = c("Age", "Grade_Level", "Subject_Area", "Previous_Experience"),
      theme = "educational",
      session_save = TRUE,
      participant_report = list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = TRUE,
        show_domain_breakdown = TRUE,
        use_enhanced_report = TRUE
      ),
      save_format = "pdf"
    ),
    
    # Clinical Assessment Template
    clinical_assessment = list(
      name = "Clinical Assessment",
      model = "GRM",
      adaptive = TRUE,
      max_items = 40,
      min_items = 25,
      min_SEM = 0.15,
      criteria = "MI",
      demographics = c("Age", "Gender", "Clinical_History", "Current_Medication"),
      theme = "clinical",
      accessibility_enhanced = TRUE,
      participant_report = list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = TRUE,
        use_enhanced_report = TRUE
      ),
      save_format = "pdf"
    ),
    
    # Research Study Template
    research_study = list(
      name = "Research Study Assessment",
      model = "2PL",
      adaptive = TRUE,
      max_items = 50,
      min_items = 30,
      min_SEM = 0.2,
      criteria = "MI",
      demographics = c("Age", "Gender", "Education", "Research_Experience"),
      theme = "research",
      parallel_computation = TRUE,
      cache_enabled = TRUE,
      participant_report = list(
        show_theta_plot = TRUE,
        show_response_table = TRUE,
        show_recommendations = TRUE,
        use_enhanced_report = TRUE
      ),
      save_format = "pdf"
    )
  )
  
  # Get the template
  if (!template_name %in% names(templates)) {
    stop("Template '", template_name, "' not found. Available templates: ", 
         paste(names(templates), collapse = ", "))
  }
  
  template <- templates[[template_name]]
  
  # Apply customizations if provided
  if (!is.null(customizations)) {
    for (key in names(customizations)) {
      template[[key]] <- customizations[[key]]
    }
  }
  
  # Create the configuration using create_study_config
  do.call(create_study_config, template)
}

#' List Available Templates
#' 
#' Returns a list of available configuration templates
#' 
#' @return Character vector of template names
#' @export
list_config_templates <- function() {
  c("personality_assessment", "cognitive_ability", "educational_diagnostic", 
    "clinical_assessment", "research_study")
}

#' Quick Study Setup
#' 
#' Creates a complete study setup with template and item bank
#' 
#' @param template_name Name of the template to use
#' @param item_bank Item bank data frame
#' @param customizations Named list of customizations
#' @return List containing config and ready-to-launch study
#' @export
quick_study_setup <- function(template_name, item_bank, customizations = NULL) {
  
  # Get configuration template
  config <- get_config_template(template_name, customizations)
  
  # Validate item bank
  if (!is.null(item_bank)) {
    validation <- validate_item_bank(item_bank, config$model)
    if (!validation$valid) {
      warning("Item bank validation issues: ", paste(validation$errors, collapse = ", "))
    }
  }
  
  # Return setup
  list(
    config = config,
    item_bank = item_bank,
    ready_to_launch = TRUE,
    template_used = template_name
  )
}