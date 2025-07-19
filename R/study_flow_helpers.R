# Enhanced Study Flow Helper Functions
# Functions to create default content for introduction, briefing, consent, GDPR, and debriefing

#' Create Default Introduction Content
#'
#' @return HTML string with default introduction content
#' @export
create_default_introduction_content <- function() {
  paste0(
    '<div class="study-introduction">',
    '<h2 class="section-title">Welcome to Our Research Study</h2>',
    '<div class="introduction-content">',
    '<p class="lead">Thank you for your interest in participating in this research study. Your contribution will help advance our understanding of important psychological and behavioral factors.</p>',
    '<div class="study-overview">',
    '<h3>Study Overview</h3>',
    '<ul>',
    '<li>Duration: Approximately 15-30 minutes</li>',
    '<li>Format: Interactive online questionnaire</li>',
    '<li>Purpose: Academic research and scientific publication</li>',
    '<li>Privacy: All responses are completely anonymous</li>',
    '</ul>',
    '</div>',
    '<div class="what-to-expect">',
    '<h3>What to Expect</h3>',
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
    '<h3>Important Notes</h3>',
    '<p><strong>Voluntary Participation:</strong> Your participation is completely voluntary. You may withdraw at any time without consequences.</p>',
    '<p><strong>Data Protection:</strong> We follow strict data protection guidelines and comply with GDPR/DSGVO requirements.</p>',
    '<p><strong>Technical Requirements:</strong> This study works best with modern web browsers and stable internet connection.</p>',
    '</div>',
    '</div>',
    '</div>'
  )
}

#' Create Default Briefing Content
#'
#' @return HTML string with default briefing content
#' @export
create_default_briefing_content <- function() {
  paste0(
    '<div class="study-briefing">',
    '<h2 class="section-title">Study Briefing</h2>',
    '<div class="briefing-content">',
    '<div class="research-details">',
    '<h3>Research Details</h3>',
    '<p><strong>Principal Investigator:</strong> Research Team</p>',
    '<p><strong>Institution:</strong> Research Institute</p>',
    '<p><strong>Study Purpose:</strong> This research examines psychological factors and their relationships to behavior and decision-making.</p>',
    '<p><strong>Publication:</strong> Results may be published in peer-reviewed academic journals.</p>',
    '</div>',
    '<div class="procedures">',
    '<h3>Study Procedures</h3>',
    '<p>During this study, you will:</p>',
    '<ul>',
    '<li>Answer questions about your experiences, attitudes, and behaviors</li>',
    '<li>Provide optional demographic information</li>',
    '<li>Complete an interactive questionnaire</li>',
    '<li>Receive personalized feedback about your responses</li>',
    '</ul>',
    '</div>',
    '<div class="risks-benefits">',
    '<h3>Risks and Benefits</h3>',
    '<p><strong>Risks:</strong> This study involves minimal risk. Some questions may ask about personal experiences or opinions.</p>',
    '<p><strong>Benefits:</strong> You will contribute to scientific knowledge and may gain insights about the topic area.</p>',
    '</div>',
    '<div class="confidentiality">',
    '<h3>Confidentiality</h3>',
    '<p>Your responses are completely anonymous. We do not collect:</p>',
    '<ul>',
    '<li>Your name or email address</li>',
    '<li>IP addresses or device identifiers</li>',
    '<li>Any information that could identify you personally</li>',
    '</ul>',
    '<p>All data is stored securely and will only be used for research purposes.</p>',
    '</div>',
    '<div class="contact-info">',
    '<h3>Contact Information</h3>',
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
#' @return HTML string with default consent content
#' @export
create_default_consent_content <- function() {
  paste0(
    '<div class="consent-form">',
    '<h2 class="section-title">Informed Consent</h2>',
    '<div class="consent-content">',
    '<div class="consent-statement">',
    '<p class="lead">Please read the following information carefully before deciding whether to participate in this research study.</p>',
    '</div>',
    '<div class="consent-details">',
    '<h3>Consent to Participate</h3>',
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
    '<h3>Data Use and Storage</h3>',
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
    '<h3>Right to Withdraw</h3>',
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
#' @return HTML string with default GDPR compliance content
#' @export
create_default_gdpr_content <- function() {
  paste0(
    '<div class="gdpr-compliance">',
    '<h2 class="section-title">Data Protection Information (GDPR/DSGVO)</h2>',
    '<div class="gdpr-content">',
    '<div class="gdpr-intro">',
    '<p class="lead">In accordance with the General Data Protection Regulation (GDPR) and German Data Protection Act (DSGVO), we provide the following information about data processing:</p>',
    '</div>',
    '<div class="data-controller">',
    '<h3>Data Controller</h3>',
    '<p><strong>Institution:</strong> Research Institute</p>',
    '<p><strong>Address:</strong> [Institution Address]</p>',
    '<p><strong>Email:</strong> privacy@institution.edu</p>',
    '<p><strong>Data Protection Officer:</strong> dpo@institution.edu</p>',
    '</div>',
    '<div class="legal-basis">',
    '<h3>Legal Basis for Processing</h3>',
    '<p>Data processing is based on:</p>',
    '<ul>',
    '<li><strong>Article 6(1)(a) GDPR:</strong> Your explicit consent</li>',
    '<li><strong>Article 9(2)(a) GDPR:</strong> Explicit consent for special categories of data (if applicable)</li>',
    '<li><strong>Legitimate interest:</strong> Scientific research purposes</li>',
    '</ul>',
    '</div>',
    '<div class="data-categories">',
    '<h3>Categories of Data</h3>',
    '<p>We may process the following categories of data:</p>',
    '<ul>',
    '<li>Response data from questionnaires</li>',
    '<li>Optional demographic information</li>',
    '<li>Technical data (session duration, response times)</li>',
    '<li>No personal identifiers or contact information</li>',
    '</ul>',
    '</div>',
    '<div class="retention-period">',
    '<h3>Data Retention</h3>',
    '<p>Data will be retained for:</p>',
    '<ul>',
    '<li>Active research period: Up to 10 years</li>',
    '<li>Publication requirements: As required by journals</li>',
    '<li>Legal obligations: As required by law</li>',
    '</ul>',
    '</div>',
    '<div class="gdpr-rights">',
    '<h3>Your Rights under GDPR</h3>',
    '<p>You have the right to:</p>',
    '<ul>',
    '<li><strong>Access:</strong> Request information about your data</li>',
    '<li><strong>Rectification:</strong> Correct inaccurate data</li>',
    '<li><strong>Erasure:</strong> Request deletion of your data</li>',
    '<li><strong>Portability:</strong> Receive your data in a portable format</li>',
    '<li><strong>Restriction:</strong> Limit processing of your data</li>',
    '<li><strong>Objection:</strong> Object to processing based on legitimate interests</li>',
    '<li><strong>Complaint:</strong> Lodge a complaint with supervisory authorities</li>',
    '</ul>',
    '</div>',
    '<div class="data-sharing">',
    '<h3>Data Sharing</h3>',
    '<p>Anonymous data may be shared with:</p>',
    '<ul>',
    '<li>Research collaborators</li>',
    '<li>Academic journals for publication</li>',
    '<li>Open science repositories</li>',
    '<li>No data sharing with commercial entities</li>',
    '</ul>',
    '</div>',
    '<div class="contact-gdpr">',
    '<h3>Contact for Data Protection</h3>',
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
#' @return HTML string with default debriefing content
#' @export
create_default_debriefing_content <- function() {
  paste0(
    '<div class="study-debriefing">',
    '<h2 class="section-title">Study Debriefing</h2>',
    '<div class="debriefing-content">',
    '<div class="thank-you">',
    '<p class="lead">Thank you for participating in this research study. Your contribution is valuable for advancing scientific knowledge.</p>',
    '</div>',
    '<div class="study-purpose">',
    '<h3>Study Purpose</h3>',
    '<p>This study examined psychological factors and their relationships to behavior, attitudes, and decision-making processes. Your responses help us understand:</p>',
    '<ul>',
    '<li>Individual differences in psychological characteristics</li>',
    '<li>Relationships between different psychological measures</li>',
    '<li>Factors that influence behavior and decision-making</li>',
    '</ul>',
    '</div>',
    '<div class="methodology">',
    '<h3>Research Methodology</h3>',
    '<p>This study used validated psychological instruments and advanced statistical methods to:</p>',
    '<ul>',
    '<li>Measure psychological constructs accurately</li>',
    '<li>Adapt questions to your response patterns</li>',
    '<li>Provide personalized feedback</li>',
    '<li>Contribute to scientific understanding</li>',
    '</ul>',
    '</div>',
    '<div class="implications">',
    '<h3>Research Implications</h3>',
    '<p>The results of this study may contribute to:</p>',
    '<ul>',
    '<li>Better understanding of psychological processes</li>',
    '<li>Development of improved assessment tools</li>',
    '<li>Evidence-based interventions and treatments</li>',
    '<li>Educational and training programs</li>',
    '</ul>',
    '</div>',
    '<div class="next-steps">',
    '<h3>Next Steps</h3>',
    '<p>Following this study:</p>',
    '<ul>',
    '<li>Data will be analyzed using advanced statistical methods</li>',
    '<li>Results will be prepared for publication in academic journals</li>',
    '<li>Findings will be presented at scientific conferences</li>',
    '<li>Summary results may be made available to participants</li>',
    '</ul>',
    '</div>',
    '<div class="resources">',
    '<h3>Additional Resources</h3>',
    '<p>If you are interested in learning more about this topic area:</p>',
    '<ul>',
    '<li>Visit our research website: [website]</li>',
    '<li>Follow our research on social media: [social media]</li>',
    '<li>Contact us for research updates: [email]</li>',
    '</ul>',
    '</div>',
    '<div class="support">',
    '<h3>Support and Concerns</h3>',
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
create_default_demographic_configs <- function(demographics, input_types) {
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
      config$placeholder <- "Enter your age"
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
      config$question_text <- paste("Please provide information about", demo)
      config$input_type <- input_type
      config$placeholder <- paste("Enter", demo)
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
#' @return Shiny UI elements for demographics
#' @export
create_custom_demographic_ui <- function(demographic_configs, theme = NULL) {
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
    
    # Create UI element based on input type
    if (config$input_type == "text") {
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(config$question_text, `for` = demo_name),
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
        shiny::label(config$question_text, `for` = demo_name),
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
      choices <- config$options
      if (config$allow_skip) {
        choices <- c(choices, "Prefer not to answer" = "skip")
      }
      
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(config$question_text, `for` = demo_name),
        shiny::selectInput(
          inputId = demo_name,
          label = NULL,
          choices = c("Please select..." = "", choices),
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
      choices <- config$options
      if (config$allow_skip) {
        choices <- c(choices, "Prefer not to answer" = "skip")
      }
      
      ui_elements[[demo_name]] <- shiny::div(
        class = "demographic-field",
        shiny::label(config$question_text),
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
    shiny::h3("Demographic Information"),
    shiny::p("Please provide some optional information about yourself. All fields are optional and you may skip any questions you prefer not to answer."),
    ui_elements
  ))
}

# Helper function for NULL coalescing
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}
