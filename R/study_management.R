#' Study Management for increp Package
#' 
#' This file consolidates all study management functions including:
#' - Study flow helpers (from study_flow_helpers.R)
#' - Study simulations (from study_simulations.R)
#' - Custom page flow (from custom_page_flow.R)
#' - Flow validation (from custom_page_flow_validation.R)
#' 
#' @name study_management
#' @keywords internal

# ============================================================================
# SECTION 1: STUDY FLOW HELPERS (from study_flow_helpers.R)
# ============================================================================

# Enhanced Study Flow Helper Functions
# Functions to create default content for introduction, briefing, consent, GDPR, and debriefing

#' Create Default Introduction Content
#'
#' @param ui_labels Language labels for UI elements
#' @return HTML string with default introduction content
#' @export
create_default_introduction_content <- function(ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      study_overview = "Study Overview",
      what_to_expect = "What to Expect",
      important_notes = "Important Notes",
      voluntary_participation = "Voluntary Participation",
      data_protection = "Data Protection",
      technical_requirements = "Technical Requirements"
    )
  }
  
  paste0(
    '<div class="study-introduction">',
    '<h2 class="section-title">Welcome to Our Research Study</h2>',
    '<div class="introduction-content">',
    '<p class="lead">Thank you for your interest in participating in this research study. Your contribution will help advance our understanding of important psychological and behavioral factors.</p>',
    '<div class="study-overview">',
    paste0('<h3>', ui_labels$study_overview, '</h3>'),
    '<ul>',
    '<li>Duration: Approximately 15-30 minutes</li>',
    '<li>Format: Interactive online questionnaire</li>',
    '<li>Purpose: Academic research and scientific publication</li>',
    '<li>Privacy: All responses are completely anonymous</li>',
    '</ul>',
    '</div>',
    '<div class="what-to-expect">',
    paste0('<h3>', ui_labels$what_to_expect, '</h3>'),
    '<p>This study consists of several sections:</p>',
    '<ol>',
    '<li>Brief introduction and study information</li>',
    '<li>Informed consent and data protection information</li>',
    '<li>Optional demographic questions</li>',
    '<li>Main questionnaire with interactive questions</li>',
    '<li>Debriefing and results summary</li>',
    '</ol>',
    '</div>',
    '<div class="participation-notes">',
    paste0('<h3>', ui_labels$important_notes, '</h3>'),
    paste0('<p><strong>', ui_labels$voluntary_participation, ':</strong> Your participation is completely voluntary. You may withdraw at any time without consequences.</p>'),
    paste0('<p><strong>', ui_labels$data_protection, ':</strong> We follow strict data protection guidelines and comply with GDPR/DSGVO requirements.</p>'),
    paste0('<p><strong>', ui_labels$technical_requirements, ':</strong> This study works best with modern web browsers and stable internet connection.</p>'),
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default Briefing Content
#'
#' @param ui_labels Language labels for UI elements
#' @return HTML string with default briefing content
#' @export
create_default_briefing_content <- function(ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      research_details = "Research Details",
      principal_investigator = "Principal Investigator",
      institution = "Institution",
      study_procedures = "Study Procedures",
      during_study_you_will = "During this study, you will:",
      answer_questions_experiences = "Answer questions about your experiences and opinions",
      provide_optional_demographics = "Provide optional demographic information",
      complete_interactive_questionnaire = "Complete an interactive questionnaire",
      receive_personalized_feedback = "Receive personalized feedback on your responses",
      risks_and_benefits = "Risks and Benefits",
      confidentiality = "Confidentiality",
      contact_information = "Contact Information"
    )
  }
  
  paste0(
    '<div class="study-briefing">',
    '<h2 class="section-title">Study Briefing</h2>',
    '<div class="briefing-content">',
    '<div class="research-details">',
    paste0('<h3>', ui_labels$research_details, '</h3>'),
    paste0('<p><strong>', ui_labels$principal_investigator, ':</strong> Research Team</p>'),
    paste0('<p><strong>', ui_labels$institution, ':</strong> Research Institute</p>'),
    '<p><strong>Study Purpose:</strong> This research examines psychological factors and their relationships to behavior and decision-making.</p>',
    '<p><strong>Publication:</strong> Results may be published in peer-reviewed academic journals.</p>',
    '</div>',
    '<div class="procedures">',
            paste0('<h3>', ui_labels$study_procedures, '</h3>'),
            paste0('<p>', ui_labels$during_study_you_will, '</p>'),
    '<ul>',
            paste0('<li>', ui_labels$answer_questions_experiences, '</li>'),
            paste0('<li>', ui_labels$provide_optional_demographics, '</li>'),
            paste0('<li>', ui_labels$complete_interactive_questionnaire, '</li>'),
            paste0('<li>', ui_labels$receive_personalized_feedback, '</li>'),
    '</ul>',
    '</div>',
    '<div class="risks-benefits">',
    paste0('<h3>', ui_labels$risks_and_benefits, '</h3>'),
    '<p><strong>Risks:</strong> This study involves minimal risk. Some questions may ask about personal experiences or opinions.</p>',
    '<p><strong>Benefits:</strong> You will contribute to scientific knowledge and may gain insights about the topic area.</p>',
    '</div>',
    '<div class="confidentiality">',
    paste0('<h3>', ui_labels$confidentiality, '</h3>'),
    '<p>Your responses are completely anonymous. We do not collect:</p>',
    '<ul>',
    '<li>Your name or email address</li>',
    '<li>IP addresses or device identifiers</li>',
    '<li>Any information that could identify you personally</li>',
    '</ul>',
    '<p>All data is stored securely and will only be used for research purposes.</p>',
    '</div>',
    '<div class="contact-info">',
    paste0('<h3>', ui_labels$contact_information, '</h3>'),
    '<p>If you have questions about this study, please contact:</p>',
    '<p><strong>Research Team:</strong> research@institution.edu</p>',
    '<p><strong>Ethics Committee:</strong> ethics@institution.edu</p>',
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default Consent Content
#'
#' @param ui_labels Language labels for UI elements
#' @return HTML string with default consent content
#' @export
create_default_consent_content <- function(ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      consent_to_participate = "Consent to Participate",
      data_use_and_storage = "Data Use and Storage",
      right_to_withdraw = "Right to Withdraw"
    )
  }
  
  paste0(
    '<div class="consent-form">',
    '<h2 class="section-title">Informed Consent</h2>',
    '<div class="consent-content">',
    '<div class="consent-statement">',
    '<p class="lead">Please read the following information carefully before deciding whether to participate in this research study.</p>',
    '</div>',
    '<div class="consent-details">',
    paste0('<h3>', ui_labels$consent_to_participate, '</h3>'),
    '<p>By providing your consent below, you acknowledge that:</p>',
    '<ul>',
    '<li>You have read and understood the study information</li>',
    '<li>You understand that participation is voluntary</li>',
    '<li>You know you can withdraw at any time without consequences</li>',
    '<li>You understand how your data will be used and protected</li>',
    '<li>You are at least 18 years old</li>',
    '</ul>',
    '</div>',
    '<div class="data-use">',
    paste0('<h3>', ui_labels$data_use_and_storage, '</h3>'),
    '<p>Your anonymous responses will be:</p>',
    '<ul>',
    '<li>Stored securely on encrypted servers</li>',
    '<li>Used only for research purposes</li>',
    '<li>Potentially included in academic publications</li>',
    '<li>Shared only in aggregate form</li>',
    '<li>Retained according to institutional data retention policies</li>',
    '</ul>',
    '</div>',
    '<div class="withdrawal">',
    paste0('<h3>', ui_labels$right_to_withdraw, '</h3>'),
    '<p>You have the right to:</p>',
    '<ul>',
    '<li>Withdraw from the study at any time</li>',
    '<li>Skip any questions you prefer not to answer</li>',
    '<li>Contact the research team with concerns</li>',
    '</ul>',
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default GDPR Content
#'
#' @param ui_labels Language labels for UI elements
#' @return HTML string with default GDPR compliance content
#' @export
create_default_gdpr_content <- function(ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      data_controller = "Data Controller",
      legal_basis_for_processing = "Legal Basis for Processing",
      article_6_gdpr = "Article 6 GDPR - Legitimate Interest",
      article_9_gdpr = "Article 9 GDPR - Research Purposes",
      legitimate_interest = "Legitimate Interest",
      categories_of_data = "Categories of Data",
      we_may_process_data = "We may process the following categories of data:",
      response_data_questionnaires = "Response data from questionnaires",
      optional_demographics = "Optional demographic information",
      technical_data = "Technical data (browser type, response times)",
      no_personal_identifiers = "No personal identifiers",
      data_retention = "Data Retention",
      your_rights_under_gdpr = "Your Rights Under GDPR",
      access = "Access",
      rectification = "Rectification",
      erasure = "Erasure",
      portability = "Portability",
      restriction = "Restriction",
      objection = "Objection",
      complaint = "Complaint",
      data_sharing = "Data Sharing",
      contact_for_data_protection = "Contact for Data Protection"
    )
  }
  
  paste0(
    '<div class="gdpr-compliance">',
    '<h2 class="section-title">Data Protection Information (GDPR/DSGVO)</h2>',
    '<div class="gdpr-content">',
    '<div class="gdpr-intro">',
    '<p class="lead">In accordance with the General Data Protection Regulation (GDPR) and German Data Protection Act (DSGVO), we provide the following information about data processing:</p>',
    '</div>',
    '<div class="data-controller">',
    paste0('<h3>', ui_labels$data_controller, '</h3>'),
    '<p><strong>Institution:</strong> Research Institute</p>',
    '<p><strong>Address:</strong> [Institution Address]</p>',
    '<p><strong>Email:</strong> privacy@institution.edu</p>',
    '<p><strong>Data Protection Officer:</strong> dpo@institution.edu</p>',
    '</div>',
    '<div class="legal-basis">',
    paste0('<h3>', ui_labels$legal_basis_for_processing, '</h3>'),
    '<p>Data processing is based on:</p>',
    '<ul>',
            paste0('<li><strong>', ui_labels$article_6_gdpr, '</strong></li>'),
            paste0('<li><strong>', ui_labels$article_9_gdpr, '</strong></li>'),
            paste0('<li><strong>', ui_labels$legitimate_interest, '</strong></li>'),
    '</ul>',
    '</div>',
    '<div class="data-categories">',
            paste0('<h3>', ui_labels$categories_of_data, '</h3>'),
            paste0('<p>', ui_labels$we_may_process_data, '</p>'),
    '<ul>',
            paste0('<li>', ui_labels$response_data_questionnaires, '</li>'),
            paste0('<li>', ui_labels$optional_demographics, '</li>'),
            paste0('<li>', ui_labels$technical_data, '</li>'),
            paste0('<li>', ui_labels$no_personal_identifiers, '</li>'),
    '</ul>',
    '</div>',
    '<div class="retention-period">',
    paste0('<h3>', ui_labels$data_retention, '</h3>'),
    '<p>Data will be retained for:</p>',
    '<ul>',
    '<li>Active research period: Up to 10 years</li>',
    '<li>Publication requirements: As required by journals</li>',
    '<li>Legal obligations: As required by law</li>',
    '</ul>',
    '</div>',
    '<div class="gdpr-rights">',
    paste0('<h3>', ui_labels$your_rights_under_gdpr, '</h3>'),
    '<p>You have the right to:</p>',
    '<ul>',
    paste0('<li><strong>', ui_labels$access, '</strong></li>'),
    paste0('<li><strong>', ui_labels$rectification, '</strong></li>'),
            paste0('<li><strong>', ui_labels$erasure, '</strong></li>'),
            paste0('<li><strong>', ui_labels$portability, '</strong></li>'),
            paste0('<li><strong>', ui_labels$restriction, '</strong></li>'),
            paste0('<li><strong>', ui_labels$objection, '</strong></li>'),
            paste0('<li><strong>', ui_labels$complaint, '</strong></li>'),
    '</ul>',
    '</div>',
    '<div class="data-sharing">',
    paste0('<h3>', ui_labels$data_sharing, '</h3>'),
    '<p>Anonymous data may be shared with:</p>',
    '<ul>',
    '<li>Research collaborators</li>',
    '<li>Academic journals for publication</li>',
    '<li>Open science repositories</li>',
    '<li>No data sharing with commercial entities</li>',
    '</ul>',
    '</div>',
    '<div class="contact-gdpr">',
    paste0('<h3>', ui_labels$contact_for_data_protection, '</h3>'),
    '<p>For questions about data protection:</p>',
    '<p><strong>Data Protection Officer:</strong> dpo@institution.edu</p>',
    '<p><strong>Supervisory Authority:</strong> [Local Data Protection Authority]</p>',
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default Debriefing Content
#'
#' @param ui_labels Language labels for UI elements
#' @return HTML string with default debriefing content
#' @export
create_default_debriefing_content <- function(ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      study_purpose = "Study Purpose",
      research_methodology = "Research Methodology",
      research_implications = "Research Implications",
      next_steps = "Next Steps",
      additional_resources = "Additional Resources",
      support_and_concerns = "Support and Concerns"
    )
  }
  
  paste0(
    '<div class="study-debriefing">',
    '<h2 class="section-title">Study Debriefing</h2>',
    '<div class="debriefing-content">',
    '<div class="thank-you">',
    '<p class="lead">Thank you for participating in this research study. Your contribution is valuable for advancing scientific knowledge.</p>',
    '</div>',
    '<div class="study-purpose">',
    paste0('<h3>', ui_labels$study_purpose, '</h3>'),
    '<p>This study examined psychological factors and their relationships to behavior, attitudes, and decision-making processes. Your responses help us understand:</p>',
    '<ul>',
    '<li>Individual differences in psychological characteristics</li>',
    '<li>Relationships between different psychological measures</li>',
    '<li>Factors that influence behavior and decision-making</li>',
    '</ul>',
    '</div>',
    '<div class="methodology">',
    paste0('<h3>', ui_labels$research_methodology, '</h3>'),
    '<p>This study used validated psychological instruments and advanced statistical methods to:</p>',
    '<ul>',
    '<li>Measure psychological constructs accurately</li>',
    '<li>Adapt questions to your response patterns</li>',
    '<li>Provide personalized feedback</li>',
    '<li>Contribute to scientific understanding</li>',
    '</ul>',
    '</div>',
    '<div class="implications">',
    paste0('<h3>', ui_labels$research_implications, '</h3>'),
    '<p>The results of this study may contribute to:</p>',
    '<ul>',
    '<li>Better understanding of psychological processes</li>',
    '<li>Development of improved assessment tools</li>',
    '<li>Evidence-based interventions and treatments</li>',
    '<li>Educational and training programs</li>',
    '</ul>',
    '</div>',
    '<div class="next-steps">',
    paste0('<h3>', ui_labels$next_steps, '</h3>'),
    '<p>Following this study:</p>',
    '<ul>',
    '<li>Data will be analyzed using advanced statistical methods</li>',
    '<li>Results will be prepared for publication in academic journals</li>',
    '<li>Findings will be presented at scientific conferences</li>',
    '<li>Summary results may be made available to participants</li>',
    '</ul>',
    '</div>',
    '<div class="resources">',
    paste0('<h3>', ui_labels$additional_resources, '</h3>'),
    '<p>If you are interested in learning more about this topic area:</p>',
    '<ul>',
    '<li>Visit our research website: [website]</li>',
    '<li>Follow our research on social media: [social media]</li>',
    '<li>Contact us for research updates: [email]</li>',
    '</ul>',
    '</div>',
    '<div class="support">',
    paste0('<h3>', ui_labels$support_and_concerns, '</h3>'),
    '<p>If you have any concerns or questions about this study:</p>',
    '<ul>',
    '<li>Contact the research team: research@institution.edu</li>',
    '<li>Contact the ethics committee: ethics@institution.edu</li>',
    '<li>If you experienced any distress, consider contacting support services</li>',
    '</ul>',
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default Demographic Configurations
#'
#' @param demographics Character vector of demographic field names
#' @param input_types Named list of input types for demographic fields
#' @return List of demographic configurations with full control
#' @export
create_default_demographic_configs <- function(demographics, input_types, ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      enter_age = "Enter your age",
      demographics_provide_info = "Please provide your %s",
      enter_field = "Enter your %s"
    )
  }
  
  if (is.null(demographics)) {
    return(NULL)
  }
  
  # Default demographic configurations with full control
  configs <- list()
  
  for (demo in demographics) {
    input_type <- input_types[[demo]] %||% "text"
    
    config <- list(
      field_name = demo,
      input_type = input_type,
      required = FALSE,
      allow_skip = TRUE,
      validation_rules = list(),
      display_order = match(demo, demographics)
    )
    
    # Customize based on common demographic fields
    if (demo %in% c("Age", "age", "AGE")) {
      config$question_text <- "What is your age?"
      config$input_type <- "numeric"
      config$placeholder <- ui_labels$enter_age
      config$validation_rules <- list(
        min_value = 18,
        max_value = 120,
        integer_only = TRUE
      )
      config$options <- NULL
      
    } else if (demo %in% c("Gender", "gender", "GENDER")) {
      config$question_text <- "What is your gender?"
      config$input_type <- "select"
      config$options <- c(
        "Female" = "female",
        "Male" = "male", 
        "Non-binary" = "non_binary",
        "Prefer not to say" = "prefer_not_to_say",
        "Other" = "other"
      )
      config$allow_other_text <- TRUE
      
    } else if (demo %in% c("Education", "education", "EDUCATION")) {
      config$question_text <- "What is your highest level of education?"
      config$input_type <- "select"
      config$options <- c(
        "Less than high school" = "less_than_high_school",
        "High school diploma" = "high_school",
        "Some college" = "some_college",
        "Bachelor's degree" = "bachelor",
        "Master's degree" = "master",
        "Doctoral degree" = "doctoral",
        "Professional degree" = "professional"
      )
      
    } else if (demo %in% c("Country", "country", "COUNTRY")) {
      config$question_text <- "What is your country of residence?"
      config$input_type <- "select"
      config$options <- c(
        "Germany" = "DE",
        "United States" = "US",
        "United Kingdom" = "GB",
        "France" = "FR",
        "Spain" = "ES",
        "Italy" = "IT",
        "Other" = "other"
      )
      config$allow_other_text <- TRUE
      
    } else if (demo %in% c("Experience", "experience", "EXPERIENCE")) {
      config$question_text <- "How many years of experience do you have?"
      config$input_type <- "select"
      config$options <- c(
        "Less than 1 year" = "less_than_1",
        "1-3 years" = "1_to_3",
        "3-5 years" = "3_to_5",
        "5-10 years" = "5_to_10",
        "More than 10 years" = "more_than_10"
      )
      
    } else if (demo %in% c("Role", "role", "ROLE")) {
      config$question_text <- "What is your primary role?"
      config$input_type <- "select"
      config$options <- c(
        "Student" = "student",
        "Researcher" = "researcher",
        "Professional" = "professional",
        "Other" = "other"
      )
      config$allow_other_text <- TRUE
      
    } else {
      # Generic configuration for custom demographics
      config$question_text <- sprintf(ui_labels$demographics_provide_info, demo)
      config$input_type <- input_type
              config$placeholder <- sprintf(ui_labels$enter_field, demo)
      config$options <- NULL
    }
    
    configs[[demo]] <- config
  }
  
  return(configs)
}

#' Validate Demographic Configuration
#'
#' @param config Single demographic configuration
#' @return TRUE if valid, FALSE otherwise
#' @export
validate_demographic_config <- function(config) {
  required_fields <- c("field_name", "question_text", "input_type")
  
  if (!all(required_fields %in% names(config))) {
    return(FALSE)
  }
  
  if (!config$input_type %in% c("text", "numeric", "select", "radio", "checkbox")) {
    return(FALSE)
  }
  
  if (config$input_type %in% c("select", "radio", "checkbox") && is.null(config$options)) {
    return(FALSE)
  }
  
  return(TRUE)
}

#' Create Custom Demographic UI
#'
#' @param demographic_configs List of demographic configurations
#' @param theme Theme configuration
#' @param ui_labels Language labels for UI elements
#' @return Shiny UI elements for demographics
#' @export
create_custom_demographic_ui <- function(demographic_configs, theme = NULL, ui_labels = NULL) {
  # Get default labels if none provided
  if (is.null(ui_labels)) {
    ui_labels <- list(
      demo_title = "Demographic Information",
      demographics_optional_info = "The following questions are optional and help us better understand our research population."
    )
  }
  
  if (is.null(demographic_configs)) {
    return(NULL)
  }
  
  # Create UI elements for each demographic field
  ui_elements <- list()
  
  for (demo_name in names(demographic_configs)) {
    config <- demographic_configs[[demo_name]]
    
    # Validate configuration
    if (!validate_demographic_config(config)) {
      warning(paste("Invalid demographic configuration for", demo_name))
      next
    }
    
    # Get question text based on current language
    current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
    question_text <- if (current_lang == "en" && !is.null(config$question_en)) {
      config$question_en
    } else {
      config$question_text
    }
    
    # Get options based on current language
    options_to_use <- if (current_lang == "en" && !is.null(config$options_en)) {
      config$options_en
    } else {
      config$options
    }
    
    # Create UI element based on input type
    if (config$input_type == "text") {
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(question_text, `for` = demo_name),
        shiny::textInput(
          inputId = demo_name,
          label = NULL,
          placeholder = config$placeholder %||% ""
        ),
        if (config$allow_skip) shiny::div(
          class = "skip-option",
          shiny::checkboxInput(
            inputId = paste0(demo_name, "_skip"),
            label = "Prefer not to answer",
            value = FALSE
          )
        )
      )
      
    } else if (config$input_type == "numeric") {
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(question_text, `for` = demo_name),
        shiny::numericInput(
          inputId = demo_name,
          label = NULL,
          value = NA,
          min = config$validation_rules$min_value %||% NA,
          max = config$validation_rules$max_value %||% NA
        ),
        if (config$allow_skip) shiny::div(
          class = "skip-option",
          shiny::checkboxInput(
            inputId = paste0(demo_name, "_skip"),
            label = "Prefer not to answer",
            value = FALSE
          )
        )
      )
      
    } else if (config$input_type == "select") {
      choices <- options_to_use %||% config$options
      if (config$allow_skip) {
        choices <- c(choices, "Prefer not to answer" = "skip")
      }
      
      # Translate "Please select..." based on language
      placeholder_text <- if (current_lang == "en") "Please select..." else "Bitte wählen..."
      
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(question_text, `for` = demo_name),
        shiny::selectInput(
          inputId = demo_name,
          label = NULL,
          choices = c(setNames("", placeholder_text), choices),
          selected = ""
        ),
        if (config$allow_other_text) shiny::conditionalPanel(
          condition = paste0("input.", demo_name, " == 'other'"),
          shiny::textInput(
            inputId = paste0(demo_name, "_other"),
            label = "Please specify:",
            placeholder = "Enter details..."
          )
        )
      )
      
    } else if (config$input_type == "radio") {
      choices <- options_to_use %||% config$options
      if (config$allow_skip) {
        choices <- c(choices, "Prefer not to answer" = "skip")
      }
      
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(question_text),
        shiny::radioButtons(
          inputId = demo_name,
          label = NULL,
          choices = choices,
          selected = character(0)
        ),
        if (config$allow_other_text) shiny::conditionalPanel(
          condition = paste0("input.", demo_name, " == 'other'"),
          shiny::textInput(
            inputId = paste0(demo_name, "_other"),
            label = "Please specify:",
            placeholder = "Enter details..."
          )
        )
      )
    }
  }
  
  return(shiny::div(
    class = "demographic-section",
    shiny::h3(ui_labels$demo_title),
                       shiny::p(ui_labels$demographics_optional_info),
    ui_elements
  ))
}

# Helper function for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}


# ============================================================================
# SECTION 2: STUDY SIMULATIONS (from study_simulations.R)
# ============================================================================

#' Study Simulation Framework
#' 
#' Simulates various real-world study scenarios to identify and fix potential errors
#' 
#' @name study_simulations
#' @docType data
NULL

#' Simulate Educational Assessment Studies
#' 
#' Tests various educational assessment scenarios that users might create
#' 
#' @return List of simulation results with errors and fixes
#' @export
simulate_educational_studies <- function() {
  results <- list()
  
  # Scenario 1: Math test with adaptive branching
  tryCatch({
    config1 <- create_study_config(
      name = "Adaptive Math Assessment Grade 5-8",
      model = "2PL",
      max_items = 45,
      min_items = 15,
      min_SEM = 0.25,
      criteria = "MI",
      start_theta = -2,  # Students might start below average
      demographics = c("Grade", "School_ID", "Teacher", "Previous_Score"),
      input_types = list(
        Grade = "select",
        School_ID = "text", 
        Teacher = "text",
        Previous_Score = "numeric"
      ),
      language = "en"
    )
    
    # Simulate item bank with grade-specific items
    item_bank1 <- data.frame(
      item_id = paste0("MATH_", 1:200),
      content = rep(c("What is 2+2?", "Solve for x: 2x=10"), 100),
      difficulty = c(rnorm(50, -2, 0.5), rnorm(50, 0, 0.5), 
                    rnorm(50, 1, 0.5), rnorm(50, 2, 0.5)),
      discrimination = runif(200, 0.5, 2.5),
      grade_level = rep(5:8, each = 50),
      topic = rep(c("Arithmetic", "Algebra", "Geometry", "Statistics"), 50)
    )
    
    results$educational_math <- list(status = "success", config = config1)
  }, error = function(e) {
    results$educational_math <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Language assessment with multimedia items
  tryCatch({
    config2 <- create_study_config(
      name = "English Proficiency Test",
      model = "GRM",
      max_items = 60,
      min_items = 30,
      min_SEM = 0.3,
      demographics = c("Native_Language", "Years_Study", "Age", "Country"),
      input_types = list(
        Native_Language = "select",
        Years_Study = "numeric",
        Age = "numeric",
        Country = "select"
      ),
      theme = "Academic",
      language = "en",
      time_limit = 7200  # 2 hour time limit
    )
    
    # Items with audio/video components (URLs)
    item_bank2 <- data.frame(
      item_id = paste0("ENG_", 1:150),
      content = c(
        rep("Listen to audio and answer: [AUDIO_URL]", 30),
        rep("Watch video and respond: [VIDEO_URL]", 30),
        rep("Read passage and answer questions", 90)
      ),
      difficulty = rnorm(150, 0, 1),
      discrimination = runif(150, 0.8, 2.0),
      skill = rep(c("Listening", "Speaking", "Reading", "Writing"), length.out = 150),
      media_url = c(
        paste0("https://example.com/audio/", 1:30, ".mp3"),
        paste0("https://example.com/video/", 1:30, ".mp4"),
        rep(NA, 90)
      )
    )
    
    results$educational_language <- list(status = "success", config = config2)
  }, error = function(e) {
    results$educational_language <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Special education assessment with accommodations
  tryCatch({
    config3 <- create_study_config(
      name = "Special Education Screening",
      model = "1PL",  # Simpler model for special needs
      max_items = 20,
      min_items = 10,
      min_SEM = 0.4,  # More lenient stopping criterion
      demographics = c("IEP_Status", "Accommodations", "Disability_Type"),
      input_types = list(
        IEP_Status = "select",
        Accommodations = "checkbox",  # Multiple accommodations
        Disability_Type = "select"
      ),
      accessibility_enhanced = TRUE,
      font_size_adjustable = TRUE,
      high_contrast_available = TRUE,
      screen_reader_compatible = TRUE,
      extended_time_factor = 2.0  # Double time for special needs
    )
    
    results$educational_special <- list(status = "success", config = config3)
  }, error = function(e) {
    results$educational_special <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Clinical Psychology Studies
#' 
#' Tests various clinical assessment scenarios
#' 
#' @return List of simulation results
#' @export
simulate_clinical_studies <- function() {
  results <- list()
  
  # Scenario 1: Depression screening with skip logic
  tryCatch({
    config1 <- create_study_config(
      name = "PHQ-9 Depression Screening",
      model = "GRM",
      max_items = 9,
      min_items = 9,  # Fixed length assessment
      min_SEM = 999,  # Disable adaptive stopping
      demographics = c("Patient_ID", "Clinician", "Session_Number", "Medication"),
      input_types = list(
        Patient_ID = "text",
        Clinician = "select",
        Session_Number = "numeric",
        Medication = "checkbox"
      ),
      save_format = "encrypted_json",  # HIPAA compliance
      data_retention_days = 90,
      require_consent = TRUE,
      suicide_item_alert = c(9)  # Alert on item 9 (suicide ideation)
    )
    
    # Clinical items with severity levels
    item_bank1 <- data.frame(
      item_id = paste0("PHQ_", 1:9),
      content = c(
        "Little interest or pleasure in doing things",
        "Feeling down, depressed, or hopeless",
        "Trouble falling asleep or sleeping too much",
        "Feeling tired or having little energy",
        "Poor appetite or overeating",
        "Feeling bad about yourself",
        "Trouble concentrating",
        "Moving or speaking slowly",
        "Thoughts of self-harm"
      ),
      difficulty = seq(-2, 2, length.out = 9),
      discrimination = rep(1.5, 9),
      clinical_flag = c(rep(FALSE, 8), TRUE),  # Item 9 is flagged
      response_options = rep(4, 9)  # 0-3 scale
    )
    
    results$clinical_depression <- list(status = "success", config = config1)
  }, error = function(e) {
    results$clinical_depression <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Anxiety assessment with branching
  tryCatch({
    config2 <- create_study_config(
      name = "Comprehensive Anxiety Assessment",
      model = "2PL",
      max_items = 50,
      min_items = 20,
      min_SEM = 0.3,
      branching_rules = list(
        high_anxiety = list(theta_threshold = 1.5, next_module = "panic_items"),
        low_anxiety = list(theta_threshold = -1.5, next_module = "screening_only")
      ),
      demographics = c("Age", "Gender", "Diagnosis", "Treatment_History"),
      clinical_cutoffs = list(
        mild = -0.5,
        moderate = 0.5,
        severe = 1.5
      )
    )
    
    results$clinical_anxiety <- list(status = "success", config = config2)
  }, error = function(e) {
    results$clinical_anxiety <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Neuropsychological battery
  tryCatch({
    config3 <- create_study_config(
      name = "Cognitive Function Battery",
      model = "3PL",  # Include guessing parameter
      max_items = 120,
      min_items = 60,
      min_SEM = 0.25,
      modules = c("Memory", "Attention", "Executive", "Language", "Visuospatial"),
      demographics = c("Age", "Education", "Medical_History", "Medications"),
      time_per_item = 30,  # 30 seconds per item
      break_after_items = 30,  # Mandatory break every 30 items
      practice_items = TRUE,
      warm_up_items = 5
    )
    
    # Complex item bank with multiple domains
    item_bank3 <- data.frame(
      item_id = paste0("COG_", 1:300),
      content = rep("Cognitive task", 300),
      difficulty = rnorm(300, 0, 1.5),
      discrimination = runif(300, 0.5, 2.5),
      guessing = runif(300, 0.1, 0.3),
      domain = rep(c("Memory", "Attention", "Executive", "Language", "Visuospatial"), 60),
      item_type = rep(c("Recognition", "Recall", "Problem_Solving"), 100),
      requires_timer = sample(c(TRUE, FALSE), 300, replace = TRUE)
    )
    
    results$clinical_neuropsych <- list(status = "success", config = config3)
  }, error = function(e) {
    results$clinical_neuropsych <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Corporate HR Assessments
#' 
#' Tests various workplace assessment scenarios
#' 
#' @return List of simulation results
#' @export
simulate_corporate_studies <- function() {
  results <- list()
  
  # Scenario 1: Pre-employment screening
  tryCatch({
    config1 <- create_study_config(
      name = "Technical Skills Assessment",
      model = "2PL",
      max_items = 40,
      min_items = 25,
      min_SEM = 0.3,
      demographics = c("Applicant_ID", "Position", "Experience_Years", "Education"),
      proctoring_enabled = TRUE,
      webcam_monitoring = TRUE,
      prevent_copy_paste = TRUE,
      randomize_items = TRUE,
      time_limit = 3600,  # 1 hour
      passing_score = 0.5  # Theta > 0.5 to pass
    )
    
    # Technical items with categories
    item_bank1 <- data.frame(
      item_id = paste0("TECH_", 1:200),
      content = rep("Technical question", 200),
      difficulty = c(
        rnorm(50, -1, 0.5),  # Easy
        rnorm(100, 0, 0.5),   # Medium
        rnorm(50, 1, 0.5)     # Hard
      ),
      discrimination = runif(200, 1.0, 2.5),
      category = rep(c("Programming", "Database", "Networking", "Security"), 50),
      job_level = rep(c("Junior", "Mid", "Senior"), length.out = 200),
      contains_code = sample(c(TRUE, FALSE), 200, replace = TRUE)
    )
    
    results$corporate_technical <- list(status = "success", config = config1)
  }, error = function(e) {
    results$corporate_technical <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: 360-degree feedback assessment
  tryCatch({
    config2 <- create_study_config(
      name = "Leadership 360 Feedback",
      model = "GRM",
      max_items = 60,
      min_items = 60,  # Fixed length
      min_SEM = 999,
      demographics = c("Rater_ID", "Relationship", "Department", "Time_Known"),
      input_types = list(
        Rater_ID = "text",
        Relationship = "select",  # Self, Manager, Peer, Direct Report
        Department = "select",
        Time_Known = "numeric"
      ),
      anonymous_mode = TRUE,
      aggregate_results = TRUE,
      minimum_raters = 5,
      rater_categories = c("Self", "Manager", "Peer", "Direct_Report", "Customer")
    )
    
    # 360 feedback items
    item_bank2 <- data.frame(
      item_id = paste0("LEAD_", 1:60),
      content = rep("Leadership behavior", 60),
      difficulty = rep(seq(-2, 2, length.out = 5), 12),
      discrimination = runif(60, 1.0, 2.0),
      competency = rep(c("Communication", "Decision_Making", "Team_Building", 
                        "Strategic_Thinking", "Innovation"), 12),
      reverse_scored = sample(c(TRUE, FALSE), 60, replace = TRUE, prob = c(0.2, 0.8))
    )
    
    results$corporate_360 <- list(status = "success", config = config2)
  }, error = function(e) {
    results$corporate_360 <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Personality assessment for team building
  tryCatch({
    config3 <- create_study_config(
      name = "Team Dynamics Assessment",
      model = "GRM",
      max_items = 100,
      min_items = 50,
      min_SEM = 0.35,
      demographics = c("Employee_ID", "Team", "Role", "Tenure"),
      facets = c("Extraversion", "Agreeableness", "Conscientiousness", 
                "Neuroticism", "Openness"),
      report_type = "comprehensive",
      include_norms = TRUE,
      norm_group = "corporate_professionals",
      team_report = TRUE,
      gap_analysis = TRUE
    )
    
    results$corporate_personality <- list(status = "success", config = config3)
  }, error = function(e) {
    results$corporate_personality <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Research Studies with Extreme Parameters
#' 
#' Tests edge cases and extreme configurations
#' 
#' @return List of simulation results
#' @export
simulate_extreme_studies <- function() {
  results <- list()
  
  # Scenario 1: Massive item bank
  tryCatch({
    config1 <- create_study_config(
      name = "Large Scale International Study",
      model = "2PL",
      max_items = 500,  # Very long assessment
      min_items = 100,
      min_SEM = 0.1,  # Very strict criterion
      demographics = paste0("Var_", 1:50),  # 50 demographic variables
      language = "multi",  # Multiple languages
      countries = 50,  # 50 countries
      expected_n = 100000  # 100k participants
    )
    
    # Huge item bank
    item_bank1 <- data.frame(
      item_id = paste0("ITEM_", 1:10000),  # 10,000 items
      content = rep("Item content", 10000),
      difficulty = rnorm(10000, 0, 1.5),
      discrimination = runif(10000, 0.3, 3.0),
      language = rep(c("en", "es", "fr", "de", "zh"), 2000),
      translation_verified = sample(c(TRUE, FALSE), 10000, replace = TRUE)
    )
    
    results$extreme_massive <- list(status = "success", config = config1)
  }, error = function(e) {
    results$extreme_massive <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Minimal configuration
  tryCatch({
    config2 <- create_study_config(
      name = "A",  # Minimal name
      model = "1PL",
      max_items = 1,  # Single item
      min_items = 1,
      min_SEM = 999  # No adaptive stopping
    )
    
    # Single item bank
    item_bank2 <- data.frame(
      item_id = "Q1",
      content = "?",  # Minimal content
      difficulty = 0,
      discrimination = 1
    )
    
    results$extreme_minimal <- list(status = "success", config = config2)
  }, error = function(e) {
    results$extreme_minimal <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Unusual characters and encoding
  tryCatch({
    config3 <- create_study_config(
      name = "测试 τεστ тест ทดสอบ",  # Unicode characters
      model = "GRM",
      max_items = 30,
      min_items = 15,
      min_SEM = 0.3,
      demographics = c("名前", "Âge", "Город"),  # Non-ASCII demographics
      special_characters = TRUE
    )
    
    # Items with special characters
    item_bank3 <- data.frame(
      item_id = paste0("题目_", 1:50),
      content = c(
        rep("¿Cómo está?", 10),
        rep("Qu'est-ce que c'est?", 10),
        rep("Was ist das?", 10),
        rep("これは何ですか？", 10),
        rep("Что это?", 10)
      ),
      difficulty = rnorm(50, 0, 1),
      discrimination = runif(50, 0.8, 2.0)
    )
    
    results$extreme_unicode <- list(status = "success", config = config3)
  }, error = function(e) {
    results$extreme_unicode <- list(status = "error", message = e$message)
  })
  
  # Scenario 4: Rapid fire assessment
  tryCatch({
    config4 <- create_study_config(
      name = "Speed Test",
      model = "1PL",
      max_items = 1000,  # Many items
      min_items = 500,
      min_SEM = 0.5,
      time_per_item = 2,  # 2 seconds per item
      no_review_allowed = TRUE,
      auto_advance = TRUE,
      rapid_mode = TRUE
    )
    
    results$extreme_speed <- list(status = "success", config = config4)
  }, error = function(e) {
    results$extreme_speed <- list(status = "error", message = e$message)
  })
  
  # Scenario 5: Complex branching logic
  tryCatch({
    config5 <- create_study_config(
      name = "Complex Adaptive Design",
      model = "3PL",
      max_items = 100,
      min_items = 20,
      min_SEM = 0.2,
      branching_rules = list(
        rule1 = list(condition = "theta > 2", action = "skip_to_end"),
        rule2 = list(condition = "theta < -2", action = "add_easy_items"),
        rule3 = list(condition = "se > 0.5", action = "continue"),
        rule4 = list(condition = "items_answered > 50", action = "check_fatigue"),
        rule5 = list(condition = "time_elapsed > 3600", action = "save_and_exit")
      ),
      multi_stage = TRUE,
      stages = 5,
      routing_rules = "complex"
    )
    
    results$extreme_branching <- list(status = "success", config = config5)
  }, error = function(e) {
    results$extreme_branching <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Run All Study Simulations
#' 
#' Executes all simulation scenarios and identifies errors
#' 
#' @return Comprehensive results with error analysis
#' @export
run_all_simulations <- function() {
  all_results <- list()
  errors_found <- list()
  
  # Run educational simulations
  message("Running educational study simulations...")
  edu_results <- simulate_educational_studies()
  all_results$educational <- edu_results
  
  # Run clinical simulations
  message("Running clinical study simulations...")
  clinical_results <- simulate_clinical_studies()
  all_results$clinical <- clinical_results
  
  # Run corporate simulations
  message("Running corporate study simulations...")
  corporate_results <- simulate_corporate_studies()
  all_results$corporate <- corporate_results
  
  # Run extreme simulations
  message("Running extreme parameter simulations...")
  extreme_results <- simulate_extreme_studies()
  all_results$extreme <- extreme_results
  
  # Analyze errors
  for (category in names(all_results)) {
    for (scenario in names(all_results[[category]])) {
      if (all_results[[category]][[scenario]]$status == "error") {
        errors_found[[paste(category, scenario, sep = "_")]] <- 
          all_results[[category]][[scenario]]$message
      }
    }
  }
  
  # Summary
  total_scenarios <- sum(sapply(all_results, length))
  total_errors <- length(errors_found)
  success_rate <- (total_scenarios - total_errors) / total_scenarios * 100
  
  return(list(
    results = all_results,
    errors = errors_found,
    summary = list(
      total_scenarios = total_scenarios,
      total_errors = total_errors,
      success_rate = success_rate,
      categories_tested = names(all_results)
    )
  ))
}

# ============================================================================
# SECTION 3: CUSTOM PAGE FLOW (from custom_page_flow.R)
# ============================================================================

#' Custom Page Flow Support for Multi-Page Studies
#'
#' This module provides support for custom page flows in studies,
#' allowing for complex multi-page questionnaires with progressive display.
#'
#' @export

#' Create custom page flow configuration
#' @export
create_custom_page_flow <- function(pages) {
  # Validate page structure
  required_fields <- c("id", "type", "title")
  
  for (i in seq_along(pages)) {
    page <- pages[[i]]
    missing <- setdiff(required_fields, names(page))
    if (length(missing) > 0) {
      stop(sprintf("Page %d missing required fields: %s", i, paste(missing, collapse=", ")))
    }
  }
  
  structure(
    pages,
    class = c("custom_page_flow", "list")
  )
}

#' Process custom page flow for UI rendering
#' @export
process_page_flow <- function(config, rv, input, output, session, item_bank, ui_labels, logger, auto_close_time = 300, auto_close_time_unit = "seconds", disable_auto_close = FALSE) {
  
  # Check if custom page flow is defined
  if (is.null(config$custom_page_flow)) {
    return(NULL)
  }
  
  # Get current page
  current_page_idx <- rv$current_page %||% 1
  current_page <- config$custom_page_flow[[current_page_idx]]
  
  if (is.null(current_page)) {
    logger(sprintf("Invalid page index: %d", current_page_idx), level = "ERROR")
    return(NULL)
  }
  
  # Render page based on type
  page_ui <- switch(current_page$type,
    
    "instructions" = render_instructions_page(current_page, config, ui_labels),
    
    "demographics" = render_demographics_page(current_page, config, rv, ui_labels),
    
    "items" = render_items_page(current_page, config, rv, item_bank, ui_labels),
    
    "custom" = render_custom_page(current_page, config, rv, ui_labels, input),
    
    "results" = render_results_page(current_page, config, rv, item_bank, ui_labels, auto_close_time, auto_close_time_unit, disable_auto_close),
    
    # Default fallback
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(current_page$title %||% "Page", class = "card-header"),
      shiny::p("Page type not recognized")
    )
  )
  
  # Add navigation
  nav_ui <- render_page_navigation(rv, config, current_page_idx)
  
  shiny::tagList(
    page_ui,
    nav_ui
  )
}

#' Render instructions page
render_instructions_page <- function(page, config, ui_labels) {
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page$title, class = "card-header"),
    if (!is.null(page$content)) {
      shiny::HTML(page$content)
    } else if (!is.null(page$text)) {
      shiny::p(page$text, class = "welcome-text")
    },
    if (!is.null(page$consent) && page$consent) {
      shiny::div(
        class = "consent-section",
        shiny::checkboxInput(
          "consent_checkbox",
          label = page$consent_text %||% "Ich bin mit der Teilnahme an der Befragung einverstanden",
          value = FALSE
        )
      )
    }
  )
}

#' Render demographics page
render_demographics_page <- function(page, config, rv, ui_labels) {
  # Get demographics for this page
  demo_vars <- page$demographics %||% config$demographics
  
  if (is.null(demo_vars)) {
    return(shiny::div("No demographics configured for this page"))
  }
  
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Create inputs for each demographic
  demo_inputs <- lapply(demo_vars, function(dem) {
    demo_config <- config$demographic_configs[[dem]]
    
    if (is.null(demo_config)) {
      return(NULL)
    }
    
    # Get question text based on language
    question_text <- if (current_lang == "en" && !is.null(demo_config$question_en)) {
      demo_config$question_en
    } else {
      demo_config$question %||% demo_config$question_de %||% dem
    }
    
    input_id <- paste0("demo_", dem)
    input_type <- config$input_types[[dem]] %||% "text"
    
    # Pass language to create_demographic_input
    input_element <- create_demographic_input(
      input_id, 
      demo_config, 
      input_type,
      rv$demo_data[[dem]],
      current_lang
    )
    
    shiny::div(
      class = "form-group",
      shiny::tags$label(question_text, class = "input-label"),
      input_element,
      if (!is.null(demo_config$help_text)) {
        shiny::tags$small(class = "form-text text-muted", demo_config$help_text)
      }
    )
  })
  
  # Get page title based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% ui_labels$demo_title
  }
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page_title, class = "card-header"),
    if (!is.null(page$description)) {
      shiny::p(page$description, class = "welcome-text")
    },
    demo_inputs
  )
}

#' Render items page with pagination
render_items_page <- function(page, config, rv, item_bank, ui_labels) {
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Get items for this page
  if (!is.null(page$item_indices)) {
    page_items <- item_bank[page$item_indices, ]
  } else if (!is.null(page$item_range)) {
    page_items <- item_bank[page$item_range[1]:page$item_range[2], ]
  } else {
    # Use items_per_page to paginate
    items_per_page <- page$items_per_page %||% config$items_per_page %||% 5
    start_idx <- ((rv$item_page %||% 1) - 1) * items_per_page + 1
    end_idx <- min(start_idx + items_per_page - 1, nrow(item_bank))
    page_items <- item_bank[start_idx:end_idx, ]
  }
  
  # Create item UI elements
  item_elements <- lapply(seq_len(nrow(page_items)), function(i) {
    item <- page_items[i, ]
    item_id <- paste0("item_", item$id %||% i)
    
    # Get question text based on language
    question_text <- if (current_lang == "en" && !is.null(item$Question_EN)) {
      item$Question_EN
    } else {
      item$Question %||% item$content %||% paste("Item", i)
    }
    
    # Get response options
    if (!is.null(item$ResponseCategories)) {
      choices <- as.numeric(unlist(strsplit(as.character(item$ResponseCategories), ",")))
    } else {
      choices <- 1:5
    }
    
    # Get response labels based on scale type and language
    labels <- get_response_labels(page$scale_type %||% "likert", choices, current_lang)
    
    shiny::div(
      class = "item-container",
      shiny::h4(question_text),
      shiny::radioButtons(
        inputId = item_id,
        label = NULL,
        choices = setNames(choices, labels),
        selected = rv$item_responses[[item_id]] %||% character(0),
        inline = TRUE
      )
    )
  })
  
  # Get page title and instructions based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% "Questionnaire"
  }
  
  page_instructions <- if (current_lang == "en" && !is.null(page$instructions_en)) {
    page$instructions_en
  } else {
    page$instructions
  }
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page_title, class = "card-header"),
    if (!is.null(page_instructions)) {
      # Convert markdown formatting to HTML
      formatted_instructions <- convert_markdown_to_html(page_instructions)
      shiny::HTML(formatted_instructions)
    },
    item_elements
  )
}

#' Convert markdown formatting to HTML for instructions
convert_markdown_to_html <- function(text) {
  if (is.null(text) || text == "") {
    return("")
  }
  
  # Convert line breaks to HTML
  text <- gsub("\n\n", "</p><p>", text)
  text <- paste0("<p>", text, "</p>")
  
  # Convert bold and underline: _text_ to <strong><u>text</u></strong>
  text <- gsub("_([^_]+)_", "<strong><u>\\1</u></strong>", text)
  
  # Convert bold: **text** to <strong>text</strong>
  text <- gsub("\\*\\*([^*]+)\\*\\*", "<strong>\\1</strong>", text)
  
  # Convert italic: *text* to <em>text</em>
  text <- gsub("\\*([^*]+)\\*", "<em>\\1</em>", text)
  
  return(text)
}

#' Render custom page
render_custom_page <- function(page, config, rv, ui_labels, input = NULL) {
  # Special handling for filter page
  if (page$id == "page3" || page$title == "Filter") {
    # Load validation module if needed for filter functionality
    if (!exists("create_filter_page")) {
      validation_file <- system.file("R", "custom_page_flow_validation.R", package = "inrep")
      if (file.exists(validation_file)) {
        source(validation_file)
      }
    }
    
    if (exists("create_filter_page") && !is.null(input)) {
      return(create_filter_page(input, config))
    }
  }
  
  # GENERIC approach: Check if page has a render_function that handles language
  if (!is.null(page$render_function) && is.function(page$render_function)) {
    # Pass rv (which contains language) to the render function
    # The study-specific render function should handle language switching
    tryCatch({
      page$render_function(input, NULL, NULL, rv)
    }, error = function(e) {
      # Fallback to content if render function fails
      shiny::div(
        class = "assessment-card",
        style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
        shiny::h3(page$title, class = "card-header"),
        shiny::p("Error rendering custom page"),
        if (!is.null(page$content)) {
          shiny::HTML(page$content)
        }
      )
    })
  } else if (!is.null(page$content_en) && !is.null(rv$language) && rv$language == "en") {
    # GENERIC: If page provides content_en and we're in English mode, use it
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(page$title_en %||% page$title %||% "Page", class = "card-header"),
      shiny::HTML(page$content_en)
    )
  } else {
    # Default rendering with original content
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(page$title, class = "card-header"),
      if (!is.null(page$content)) {
        shiny::HTML(page$content)
      } else {
        shiny::p("Custom page content not defined")
      }
    )
  }
}

#' Render results page
render_results_page <- function(page, config, rv, item_bank, ui_labels, auto_close_time = 300, auto_close_time_unit = "seconds", disable_auto_close = FALSE) {
  # Use custom results processor if available
  if (!is.null(config$results_processor) && is.function(config$results_processor)) {
    # Check if function accepts demographics parameter
    processor_args <- names(formals(config$results_processor))
    
    # Use cat_result if available (contains cleaned responses), otherwise use raw responses
    if (!is.null(rv$cat_result) && !is.null(rv$cat_result$responses)) {
      if ("demographics" %in% processor_args) {
        results_content <- config$results_processor(rv$cat_result$responses, item_bank, rv$demo_data)
      } else {
        results_content <- config$results_processor(rv$cat_result$responses, item_bank)
      }
    } else {
      # ROBUST: Ensure all responses are collected before processing
      # Don't remove NA values - they might be valid missing responses
      all_responses <- rv$responses
      
      # Log response collection status
      if (!is.null(all_responses)) {
        message("DEBUG: Total responses in rv$responses: ", length(all_responses))
        message("DEBUG: Non-NA responses: ", sum(!is.na(all_responses)))
        message("DEBUG: Response indices: ", paste(which(!is.na(all_responses)), collapse=", "))
      }
      
      # For non-adaptive studies, ensure we have the expected number of responses
      if (!is.null(config$fixed_items) && length(config$fixed_items) > 0) {
        expected_items <- length(config$fixed_items)
        if (length(all_responses) < expected_items) {
          message("WARNING: Only ", length(all_responses), " responses collected, expected ", expected_items)
          # Pad with NA to maintain proper indexing
          all_responses <- c(all_responses, rep(NA, expected_items - length(all_responses)))
        }
      }
      
      if (length(all_responses) > 0) {
        if ("demographics" %in% processor_args) {
          results_content <- config$results_processor(all_responses, item_bank, rv$demo_data)
        } else {
          results_content <- config$results_processor(all_responses, item_bank)
        }
      } else {
        results_content <- shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>")
      }
    }
  } else {
    results_content <- shiny::HTML("<p>Assessment completed. Thank you!</p>")
  }
  
  # Convert time to seconds if needed
  if (auto_close_time_unit == "minutes") {
    auto_close_seconds <- auto_close_time * 60
  } else {
    auto_close_seconds <- auto_close_time
  }
  
  # Create auto-close timer UI if not disabled
  auto_close_ui <- NULL
  if (!disable_auto_close && auto_close_seconds > 0) {
    # Get current language for auto-close messages
    current_lang <- rv$language %||% config$language %||% "de"
    
    # Set language-dependent messages
    auto_close_title <- if (current_lang == "en") "Session will close automatically" else "Die Sitzung wird automatisch geschlossen"
    
    auto_close_ui <- shiny::div(
      id = "auto-close-timer",
      class = "auto-close-timer",
      style = "text-align: center; margin-top: 20px; padding: 15px; background-color: #f8f9fa; border-radius: 8px; border: 2px solid #007bff;",
      shiny::h4(auto_close_title, style = "color: #007bff; margin-bottom: 10px;"),
      shiny::div(
        id = "countdown-display",
        style = "font-size: 24px; font-weight: bold; color: #dc3545; margin-bottom: 10px;",
        shiny::textOutput("countdown_timer", inline = TRUE)
      ),
      # Add JavaScript-based auto-close as backup
      shiny::tags$script(HTML(sprintf("
        (function() {
          var timeLeft = %d;
          var countdownElement = document.getElementById('countdown-display');
          
          function updateCountdown() {
            if (countdownElement) {
              countdownElement.textContent = timeLeft;
            }
            
            if (timeLeft <= 0) {
              // Auto-close with multiple methods
              try {
                window.close();
              } catch(e) {
                try {
                  if (window.opener) {
                    window.opener = null;
                    window.close();
                  } else {
                    window.location.href = 'about:blank';
                  }
                } catch(e2) {
                  try {
                    alert('Session completed. Please close this tab.');
                    window.location.href = 'about:blank';
                  } catch(e3) {
                    document.body.innerHTML = '<div style=\"text-align: center; padding: 50px; font-size: 18px;\">Session completed. Please close this tab.</div>';
                  }
                }
              }
            } else {
              timeLeft--;
              setTimeout(updateCountdown, 1000);
            }
          }
          
          // Start countdown
          setTimeout(updateCountdown, 1000);
        })();
      ", auto_close_seconds))),
      # Add meta refresh as additional fallback for mobile
      shiny::tags$meta(HTML(sprintf("
        <meta http-equiv='refresh' content='%d;url=about:blank'>
      ", auto_close_seconds + 1)))
    )
  }
  
  shiny::div(
    class = "assessment-card results-container",
    shiny::h3(page$title %||% "Results", class = "card-header"),
    results_content,
    auto_close_ui
  )
}

#' Render page navigation
render_page_navigation <- function(rv, config, current_page_idx) {
  total_pages <- length(config$custom_page_flow)
  current_page <- config$custom_page_flow[[current_page_idx]]
  
  # Don't show navigation on results page
  if (!is.null(current_page$type) && current_page$type == "results") {
    return(NULL)
  }
  
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Set navigation text based on language
  back_text <- if (current_lang == "en") "Back" else "Zurück"
  next_text <- if (current_lang == "en") "Next" else "Weiter"
  submit_text <- if (current_lang == "en") "Submit" else "Abschließen"
  page_text <- if (current_lang == "en") {
    sprintf("Page %d of %d", current_page_idx, total_pages)
  } else {
    sprintf("Seite %d von %d", current_page_idx, total_pages)
  }
  
  shiny::div(
    class = "nav-container",
    style = "margin-top: 30px;",
    
    # Single row with all navigation elements
    shiny::div(
      class = "nav-buttons",
      style = "display: flex; justify-content: center; align-items: center; gap: 30px; margin-bottom: 15px;",
      
      # Previous button or spacer
      shiny::div(
        style = "min-width: 100px;",
        if (current_page_idx > 1) {
          shiny::actionButton(
            "prev_page",
            label = back_text,
            class = "btn-secondary",
            style = "width: 100px;"
          )
        }
      ),
      
      # Progress indicator in the middle
      shiny::div(
        class = "page-indicator",
        style = "font-size: 14px; color: #666; white-space: nowrap;",
        page_text
      ),
      
      # Next/Submit button or spacer
      shiny::div(
        style = "min-width: 100px;",
        if (current_page_idx < total_pages) {
          shiny::actionButton(
            "next_page",
            label = next_text,
            class = "btn-primary",
            style = "width: 100px;"
          )
        } else {
          # Check if next page is results page
          next_page <- config$custom_page_flow[[current_page_idx + 1]]
          if (!is.null(next_page) && !is.null(next_page$type) && next_page$type == "results") {
            # Show submit button before results page
            shiny::actionButton(
              "submit_study",
              label = submit_text,
              class = "btn-success",
              style = "width: 120px;"
            )
          } else {
            # Still show next button
            shiny::actionButton(
              "next_page",
              label = next_text,
              class = "btn-primary",
              style = "width: 100px;"
            )
          }
        }
      )
    ),
    
    # Validation errors placeholder
    shiny::uiOutput("validation_errors")
  )
}

#' Create demographic input element
create_demographic_input <- function(input_id, demo_config, input_type, current_value = NULL, language = "de") {
  # Debug logging for checkbox issues
  if (input_type == "checkbox" && getOption("inrep.debug", FALSE)) {
    cat("DEBUG: Creating checkbox for", input_id, "\n")
    cat("  Options:", str(demo_config$options), "\n")
    cat("  Current value:", current_value, "\n")
  }
  
  # Get language-specific options
  options_to_use <- if (language == "en" && !is.null(demo_config$options_en)) {
    demo_config$options_en
  } else {
    demo_config$options
  }
  
  # Get language-specific placeholder
  placeholder_text <- if (language == "en") "Please select..." else "Bitte wählen..."
  
  switch(input_type,
    "text" = shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% "",
      placeholder = demo_config$placeholder %||% "",
      width = "100%"
    ),
    
    "numeric" = shiny::numericInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% NA,
      min = demo_config$min %||% 1,
      max = demo_config$max %||% 150,
      width = "100%"
    ),
    
    "select" = shiny::selectInput(
      inputId = input_id,
      label = NULL,
      choices = c(setNames("", placeholder_text), options_to_use),
      selected = current_value %||% "",
      width = "100%"
    ),
    
    "radio" = shiny::radioButtons(
      inputId = input_id,
      label = NULL,
      choices = options_to_use,
      selected = current_value %||% character(0),
      width = "100%"
    ),
    
    "checkbox" = {
      if (length(demo_config$options) == 1) {
        # Single checkbox - extract label with maximum safety
        label_text <- "Please confirm"  # Absolute fallback
        
        # Try to get label from names
        tryCatch({
          if (!is.null(names(demo_config$options))) {
            potential_label <- names(demo_config$options)[1]
            if (!is.null(potential_label) && 
                !is.na(potential_label) && 
                is.character(potential_label) &&
                nchar(potential_label) > 0) {
              label_text <- potential_label
            } else {
              # Try the value itself
              potential_value <- demo_config$options[1]
              if (!is.null(potential_value) && 
                  !is.na(potential_value)) {
                label_text <- as.character(potential_value)
              }
            }
          }
        }, error = function(e) {
          # Keep default "Please confirm"
        })
        
        # Ensure value is a valid boolean (never NA)
        checkbox_value <- FALSE
        tryCatch({
          if (!is.null(current_value) && !is.na(current_value)) {
            if (is.logical(current_value)) {
              checkbox_value <- current_value
            } else {
              checkbox_value <- as.character(current_value) %in% c("1", "TRUE", "true", "yes", "ja")
            }
          }
        }, error = function(e) {
          checkbox_value <- FALSE
        })
        
        # Final safety check before creating checkbox
        final_label <- tryCatch({
          if (is.null(label_text) || is.na(label_text) || !is.character(label_text) || nchar(label_text) == 0) {
            "Please confirm"
          } else {
            as.character(label_text)
          }
        }, error = function(e) "Please confirm")
        
        final_value <- tryCatch({
          if (is.null(checkbox_value) || is.na(checkbox_value) || !is.logical(checkbox_value)) {
            FALSE
          } else {
            as.logical(checkbox_value)
          }
        }, error = function(e) FALSE)
        
        # Create checkbox with absolutely guaranteed non-NA parameters
        shiny::checkboxInput(
          inputId = input_id,
          label = final_label,
          value = final_value
        )
      } else {
        # Multiple checkboxes
        shiny::checkboxGroupInput(
          inputId = input_id,
          label = NULL,
          choices = demo_config$options,
          selected = current_value %||% character(0),
          width = "100%"
        )
      }
    },
    
    # Default to text
    shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% "",
      width = "100%"
    )
  )
}

#' Get response labels for different scale types
#' 
#' This function generates appropriate labels for any number of response options
#' and supports various scale types including Likert scales of any length.
#' 
#' @param scale_type Type of scale ("likert", "difficulty", "frequency", "numeric", "custom")
#' @param choices Numeric vector of response options (e.g., 1:7 for 7-point scale)
#' @param language Language code ("de", "en", "es", etc.)
#' @param custom_labels Optional custom labels (overrides automatic generation)
#' @return Character vector of labels
#' @export
get_response_labels <- function(scale_type, choices, language = "de", custom_labels = NULL) {
  n_choices <- length(choices)
  
  # If custom labels provided, use them (but ensure correct length)
  if (!is.null(custom_labels)) {
    if (length(custom_labels) >= n_choices) {
      return(custom_labels[1:n_choices])
    } else {
      # Extend custom labels if needed
      extended_labels <- c(custom_labels, rep("", n_choices - length(custom_labels)))
      return(extended_labels[1:n_choices])
    }
  }
  
  # Generate labels based on scale type and number of choices
  labels <- switch(scale_type,
    "likert" = generate_likert_labels(n_choices, language),
    "difficulty" = generate_difficulty_labels(n_choices, language),
    "frequency" = generate_frequency_labels(n_choices, language),
    "numeric" = as.character(choices),
    "custom" = as.character(choices),
    # Default fallback
    as.character(choices)
  )
  
  return(labels)
}

#' Generate Likert scale labels for any number of points
#' 
#' @param n_choices Number of response options
#' @param language Language code
#' @return Character vector of labels
#' @keywords internal
generate_likert_labels <- function(n_choices, language = "de") {
  switch(language,
    "de" = {
      if (n_choices == 2) {
        c("Nein", "Ja")
      } else if (n_choices == 3) {
        c("Stimme nicht zu", "Neutral", "Stimme zu")
      } else if (n_choices == 4) {
        c("Stimme nicht zu", "Stimme eher nicht zu", "Stimme eher zu", "Stimme zu")
      } else if (n_choices == 5) {
        c("Stimme überhaupt nicht zu", "Stimme eher nicht zu", "Teils, teils", 
          "Stimme eher zu", "Stimme voll und ganz zu")
      } else if (n_choices == 6) {
        c("Stimme überhaupt nicht zu", "Stimme nicht zu", "Stimme eher nicht zu",
          "Stimme eher zu", "Stimme zu", "Stimme voll und ganz zu")
      } else if (n_choices == 7) {
        c("Stimme überhaupt nicht zu", "Stimme nicht zu", "Stimme eher nicht zu", 
          "Weder noch", "Stimme eher zu", "Stimme zu", "Stimme voll und ganz zu")
      } else if (n_choices == 10) {
        c("1 - Stimme überhaupt nicht zu", "2", "3", "4", "5 - Neutral", 
          "6", "7", "8", "9", "10 - Stimme voll und ganz zu")
      } else if (n_choices == 20) {
        c("1 - Stimme überhaupt nicht zu", "2", "3", "4", "5", "6", "7", "8", "9", "10 - Neutral",
          "11", "12", "13", "14", "15", "16", "17", "18", "19", "20 - Stimme voll und ganz zu")
      } else {
        # Generic labels for any number of choices
        if (n_choices %% 2 == 1) {
          # Odd number of choices - include neutral middle
          middle <- ceiling(n_choices / 2)
          labels <- paste0(1:n_choices)
          labels[middle] <- paste0(middle, " - Neutral")
          labels[1] <- paste0("1 - Stimme überhaupt nicht zu")
          labels[n_choices] <- paste0(n_choices, " - Stimme voll und ganz zu")
          labels
        } else {
          # Even number of choices - no neutral middle
          labels <- paste0(1:n_choices)
          labels[1] <- paste0("1 - Stimme überhaupt nicht zu")
          labels[n_choices] <- paste0(n_choices, " - Stimme voll und ganz zu")
          labels
        }
      }
    },
    "en" = {
      if (n_choices == 2) {
        c("No", "Yes")
      } else if (n_choices == 3) {
        c("Disagree", "Neutral", "Agree")
      } else if (n_choices == 4) {
        c("Disagree", "Somewhat Disagree", "Somewhat Agree", "Agree")
      } else if (n_choices == 5) {
        c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
      } else if (n_choices == 6) {
        c("Strongly Disagree", "Disagree", "Somewhat Disagree",
          "Somewhat Agree", "Agree", "Strongly Agree")
      } else if (n_choices == 7) {
        c("Strongly Disagree", "Disagree", "Somewhat Disagree", 
          "Neither Agree nor Disagree", "Somewhat Agree", "Agree", "Strongly Agree")
      } else if (n_choices == 10) {
        c("1 - Strongly Disagree", "2", "3", "4", "5 - Neutral", 
          "6", "7", "8", "9", "10 - Strongly Agree")
      } else if (n_choices == 20) {
        c("1 - Strongly Disagree", "2", "3", "4", "5", "6", "7", "8", "9", "10 - Neutral",
          "11", "12", "13", "14", "15", "16", "17", "18", "19", "20 - Strongly Agree")
      } else {
        # Generic labels for any number of choices
        if (n_choices %% 2 == 1) {
          # Odd number of choices - include neutral middle
          middle <- ceiling(n_choices / 2)
          labels <- paste0(1:n_choices)
          labels[middle] <- paste0(middle, " - Neutral")
          labels[1] <- paste0("1 - Strongly Disagree")
          labels[n_choices] <- paste0(n_choices, " - Strongly Agree")
          labels
        } else {
          # Even number of choices - no neutral middle
          labels <- paste0(1:n_choices)
          labels[1] <- paste0("1 - Strongly Disagree")
          labels[n_choices] <- paste0(n_choices, " - Strongly Agree")
          labels
        }
      }
    },
    # Default to English if language not supported
    generate_likert_labels(n_choices, "en")
  )
}

#' Generate difficulty scale labels for any number of points
#' 
#' @param n_choices Number of response options
#' @param language Language code
#' @return Character vector of labels
#' @keywords internal
generate_difficulty_labels <- function(n_choices, language = "de") {
  switch(language,
    "de" = {
      if (n_choices <= 5) {
        c("sehr schwer", "eher schwer", "teils-teils", "eher leicht", "sehr leicht")[1:n_choices]
      } else {
        # Generic labels for more choices
        labels <- paste0(1:n_choices)
        labels[1] <- paste0("1 - sehr schwer")
        labels[n_choices] <- paste0(n_choices, " - sehr leicht")
        if (n_choices %% 2 == 1) {
          middle <- ceiling(n_choices / 2)
          labels[middle] <- paste0(middle, " - teils-teils")
        }
        labels
      }
    },
    "en" = {
      if (n_choices <= 5) {
        c("Very Difficult", "Difficult", "Neutral", "Easy", "Very Easy")[1:n_choices]
      } else {
        # Generic labels for more choices
        labels <- paste0(1:n_choices)
        labels[1] <- paste0("1 - Very Difficult")
        labels[n_choices] <- paste0(n_choices, " - Very Easy")
        if (n_choices %% 2 == 1) {
          middle <- ceiling(n_choices / 2)
          labels[middle] <- paste0(middle, " - Neutral")
        }
        labels
      }
    },
    # Default to English
    generate_difficulty_labels(n_choices, "en")
  )
}

#' Generate frequency scale labels for any number of points
#' 
#' @param n_choices Number of response options
#' @param language Language code
#' @return Character vector of labels
#' @keywords internal
generate_frequency_labels <- function(n_choices, language = "de") {
  switch(language,
    "de" = {
      if (n_choices <= 5) {
        c("Nie", "Selten", "Manchmal", "Oft", "Immer")[1:n_choices]
      } else {
        # Generic labels for more choices
        labels <- paste0(1:n_choices)
        labels[1] <- paste0("1 - Nie")
        labels[n_choices] <- paste0(n_choices, " - Immer")
        labels
      }
    },
    "en" = {
      if (n_choices <= 5) {
        c("Never", "Rarely", "Sometimes", "Often", "Always")[1:n_choices]
      } else {
        # Generic labels for more choices
        labels <- paste0(1:n_choices)
        labels[1] <- paste0("1 - Never")
        labels[n_choices] <- paste0(n_choices, " - Always")
        labels
      }
    },
    # Default to English
    generate_frequency_labels(n_choices, "en")
  )
}

#' Generate ResponseCategories string for any scale
#' 
#' This helper function creates the ResponseCategories string needed for item banks
#' with any number of response options.
#' 
#' @param n_points Number of response points (e.g., 7 for 7-point scale)
#' @param start_value Starting value (default: 1)
#' @return Character string of comma-separated values
#' @export
#' @examples
#' # 7-point scale
#' generate_response_categories(7)  # "1,2,3,4,5,6,7"
#' 
#' # 10-point scale starting from 0
#' generate_response_categories(10, 0)  # "0,1,2,3,4,5,6,7,8,9"
#' 
#' # 20-point scale
#' generate_response_categories(20)  # "1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20"
generate_response_categories <- function(n_points, start_value = 1) {
  if (n_points < 2) {
    stop("Number of response points must be at least 2")
  }
  
  end_value <- start_value + n_points - 1
  values <- start_value:end_value
  paste(values, collapse = ",")
}

#' Update item bank ResponseCategories for any scale
#' 
#' This function updates all items in an item bank to use the specified
#' number of response points.
#' 
#' @param item_bank Data frame with item bank
#' @param n_points Number of response points
#' @param start_value Starting value (default: 1)
#' @return Updated item bank with ResponseCategories column
#' @export
#' @examples
#' # Update all items to use 7-point scale
#' updated_bank <- update_item_bank_scale(bfi_items, 7)
#' 
#' # Update all items to use 10-point scale starting from 0
#' updated_bank <- update_item_bank_scale(bfi_items, 10, 0)
update_item_bank_scale <- function(item_bank, n_points, start_value = 1) {
  if (!is.data.frame(item_bank)) {
    stop("item_bank must be a data frame")
  }
  
  # Generate the ResponseCategories string
  response_categories <- generate_response_categories(n_points, start_value)
  
  # Update the item bank
  item_bank$ResponseCategories <- response_categories
  
  return(item_bank)
}

# ============================================================================
# SECTION 4: FLOW VALIDATION (from custom_page_flow_validation.R)
# ============================================================================

#' Validation for Custom Page Flow
#' 
#' Ensures all required fields are filled before allowing progression

#' Validate page before allowing navigation
#' @export
validate_page_progression <- function(current_page, input, config) {
  page <- config$custom_page_flow[[current_page]]
  
  if (is.null(page)) return(list(valid = TRUE))
  
  errors <- character()
  missing_fields <- character()
  
  # Check based on page type
  if (page$type == "instructions" && isTRUE(page$consent)) {
    # Check consent checkbox
    if (!isTRUE(input$consent_checkbox)) {
      errors <- c(errors, "Bitte bestätigen Sie Ihre Einverständnis zur Teilnahme.")
    }
  } else if (page$type == "demographics") {
    # Check all required demographics
    demo_vars <- page$demographics
    for (dem in demo_vars) {
      demo_config <- config$demographic_configs[[dem]]
      if (isTRUE(demo_config$required)) {
        input_id <- paste0("demo_", dem)
        value <- input[[input_id]]
        
        if (is.null(value) || value == "" || (is.character(value) && nchar(trimws(value)) == 0)) {
          question <- demo_config$question %||% dem
          # Truncate long questions for error message
          if (nchar(question) > 50) {
            question <- paste0(substr(question, 1, 47), "...")
          }
          # Get language from rv or config
          current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
          error_prefix <- if (current_lang == "en") "Please answer: " else "Bitte beantworten Sie: "
          errors <- c(errors, paste0(error_prefix, question))
          missing_fields <- c(missing_fields, input_id)
        }
      }
    }
  } else if (page$type == "items") {
    # Check all items have responses
    if (!is.null(page$item_indices)) {
      # Try to get item_bank from config or parent environment
      item_bank <- config$item_bank
      if (is.null(item_bank) && exists("item_bank", envir = parent.frame())) {
        item_bank <- get("item_bank", envir = parent.frame())
      }
      
      if (!is.null(item_bank)) {
        for (i in page$item_indices) {
          # Get the actual item from the item bank
          if (i <= nrow(item_bank)) {
            item <- item_bank[i, ]
            # Use the item's id field if available, otherwise use index
            item_id <- paste0("item_", item$id %||% i)
            if (is.null(input[[item_id]]) || input[[item_id]] == "") {
              # Get language
              current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
              error_msg <- if (current_lang == "en") {
                "Please answer all questions on this page."
              } else {
                "Bitte beantworten Sie alle Fragen auf dieser Seite."
              }
              errors <- c(errors, error_msg)
              missing_fields <- c(missing_fields, item_id)
              # Don't break, collect all missing fields for highlighting
            }
          }
        }
      }
    }
  } else if (page$type == "custom" && isTRUE(page$required)) {
    # Handle custom pages with required fields
    # Check for specific required fields if defined
    if (!is.null(page$required_fields)) {
      for (field in page$required_fields) {
        value <- input[[field]]
        if (is.null(value) || value == "" || (is.character(value) && nchar(trimws(value)) == 0)) {
          # Get language
          current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
          error_msg <- if (current_lang == "en") {
            "Please complete all required fields on this page."
          } else {
            "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
          }
          errors <- c(errors, error_msg)
          missing_fields <- c(missing_fields, field)
        }
      }
    } else {
      # For custom pages without specific required_fields, check common input patterns
      # This handles cases like page2 with demo_Teilnahme_Code
      page_id <- page$id %||% paste0("page_", current_page)
      
      # Check for demographic-style inputs (demo_ prefix)
      if (page_id == "page2") {
        # Special case for page2 - check for code input
        code_value <- input$demo_Teilnahme_Code
        if (is.null(code_value) || trimws(code_value) == "") {
          current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
          error_msg <- if (current_lang == "en") {
            "Please complete all required fields on this page."
          } else {
            "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
          }
          errors <- c(errors, error_msg)
          missing_fields <- c(missing_fields, "demo_Teilnahme_Code")
        }
      } else {
        # Generic check for other custom pages - look for any input fields
        # This is a fallback for custom pages that don't specify required_fields
        # but still need validation
        current_lang <- if (exists("rv") && !is.null(rv$language)) rv$language else "de"
        error_msg <- if (current_lang == "en") {
          "Please complete all required fields on this page."
        } else {
          "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
        }
        errors <- c(errors, error_msg)
      }
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    missing_fields = missing_fields
  ))
}

#' Create filter page with actual functionality
#' @export
create_filter_page <- function(input, config) {
  # Get the selected study program
  studiengang <- input$demo_Studiengang
  
  if (is.null(studiengang) || studiengang == "") {
    return(shiny::div(
      class = "assessment-card",
      shiny::h3("Filter", class = "card-header"),
      shiny::p("Bitte wählen Sie zuerst Ihren Studiengang aus.",
               style = "padding: 20px; color: #dc3545;")
    ))
  }
  
  # Create different content based on Bachelor/Master
  content <- if (studiengang == "1") {  # Bachelor
    shiny::div(
      style = "padding: 20px;",
      shiny::h4("Bachelor Psychologie", style = "color: #003366;"),
      shiny::p("Als Bachelor-Studierende/r werden Ihnen nun Fragen zu Ihrem Bildungshintergrund gestellt."),
      shiny::p("Diese Informationen helfen uns, die Heterogenität der Studierendenschaft besser zu verstehen."),
      shiny::div(
        class = "alert alert-info",
        style = "margin-top: 20px;",

        " Die folgenden Fragen beziehen sich auf Ihre schulischen Leistungen."
      )
    )
  } else {  # Master
    shiny::div(
      style = "padding: 20px;",
      shiny::h4("Master Psychologie", style = "color: #003366;"),
      shiny::p("Als Master-Studierende/r werden Ihnen nun Fragen zu Ihrem Bildungshintergrund gestellt."),
      shiny::p("Ihre vorherigen akademischen Erfahrungen sind für unsere Forschung von besonderem Interesse."),
      shiny::div(
        class = "alert alert-info",
        style = "margin-top: 20px;",

        " Die folgenden Fragen beziehen sich auf Ihre akademischen Leistungen."
      )
    )
  }
  
  shiny::div(
    class = "assessment-card",
    shiny::h3("Filter", class = "card-header"),
    content
  )
}

#' Show validation errors in UI
#' @export
show_validation_errors <- function(errors, language = "de") {
  if (length(errors) == 0) return(NULL)
  
  # Use passed language or default to German
  header_text <- if (language == "en") {
    "Please complete the following:"
  } else {
    "Bitte vervollständigen Sie die folgenden Angaben:"
  }
  
  shiny::div(
    class = "validation-error",
    shiny::h4(header_text),
    shiny::tags$ul(
      style = "margin: 10px 0; padding-left: 20px;",
      lapply(errors, function(e) shiny::tags$li(e))
    )
  )
}