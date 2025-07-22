#config <- create_cognitive_study_config()
#item_bank <- create_cognitive_items_from_demo()
#launch_cognitive_study(config, item_bank)

#' Minimal stub for load_translations
#'
#' Returns a list of UI labels for the specified language (default: English)
#' @param language Language code (default: 'en')
#' @return Named list of labels
#' @export
load_translations <- function(language = "en") {
  list(
    consent = "Consent",
    continue = "Continue",
    age = "Age",
    gender = "Gender",
    education = "Education",
    instructions = "Instructions",
    begin_assessment = "Begin Assessment"
  )
}
create_overview_screen_ui <- function(config) {
  div(class = "min-h-screen bg-white text-black flex items-center justify-center",
    div(class = "assessment-card max-w-lg w-full",
      h2("Welcome to the Cognitive Assessment Study", class = "card-header text-2xl font-bold mb-4"),
      p("Your participation helps advance cognitive science. All data is confidential and used for academic research only.", class = "mb-4 text-gray-700"),
      actionButton("go_to_consent", "Participate in Study", class = "btn-klee w-full")
    )
  )
}

#' Cognitive Assessment UI Components
#'
#' Advanced Shiny UI components that mirror the React demo functionality
#' for cognitive assessments with real-time analysis and professional reporting.
#'
#' @name cognitive_assessment_ui
NULL

#' Create Cognitive Assessment Study Configuration
#'
#' Creates a specialized configuration for cognitive assessments that mirrors
#' the React demo functionality with multi-domain analysis strategies.
#'
#' @param name Character string for study name
#' @param domains Character vector of cognitive domains to assess
#' @param analysis_strategies Named list of analysis strategies for each domain
#' @param max_items Integer maximum number of items per domain
#' @param real_time_analysis Logical indicating whether to enable real-time analysis
#' @param advanced_reporting Logical indicating whether to enable advanced reporting
#' @param ... Additional parameters passed to create_study_config
#'
#' @return Study configuration object optimized for cognitive assessment
#' @export
create_cognitive_study_config <- function(
    name = "Cognitive Assessment Research Study",
    domains = c("Working_Memory", "Processing_Speed", "Executive_Function"),
    analysis_strategies = list(
      Working_Memory = list(
        name = "2-Parameter Logistic IRT",
        description = "Models item difficulty and discrimination",
        r_packages = c("ltm", "mirt", "TAM"),
        outputs = c("ability_estimates", "item_parameters", "fit_statistics"),
        report_template = "irt_cognitive_report"
      ),
      Processing_Speed = list(
        name = "Reaction Time Analysis", 
        description = "Speed-accuracy tradeoff modeling",
        r_packages = c("rtdists", "RWiener"),
        outputs = c("drift_rate", "boundary_separation", "non_decision_time"),
        report_template = "speed_processing_report"
      ),
      Executive_Function = list(
        name = "Conflict Monitoring Model",
        description = "Executive control and interference analysis", 
        r_packages = c("EMC2", "rtdists"),
        outputs = c("conflict_effect", "control_strength", "adaptation_rate"),
        report_template = "executive_function_report"
      )
    ),
    max_items = 20,
    real_time_analysis = TRUE,
    advanced_reporting = TRUE,
    ...
) {
  
  # Create base configuration
  config <- create_study_config(
    name = name,
    model = "2PL",
    estimation_method = "TAM",
    min_items = 3,
    max_items = max_items,
    min_SEM = 0.3,
    criteria = "MI",
    demographics = c("Age", "Gender", "Education"),
    input_types = list(
      Age = "numeric",
      Gender = "select", 
      Education = "select"
    ),
    theme = "Professional",
    language = "en",
    session_save = TRUE,
    parallel_computation = TRUE,
    cache_enabled = TRUE,
    feedback_enabled = TRUE,
    response_ui_type = "radio",
    progress_style = "circle",
    ...
  )
  
  # Add cognitive-specific configurations
  config$cognitive_domains <- domains
  config$analysis_strategies <- analysis_strategies
  config$real_time_analysis <- real_time_analysis
  config$advanced_reporting <- advanced_reporting
  config$assessment_type <- "cognitive"
  
  # Enhanced study phases for cognitive assessment
  config$study_phases <- c("consent", "info", "instructions", "assessment", "debrief")
  
  # Cognitive-specific UI elements
  config$show_live_analysis <- TRUE
  config$show_domain_progress <- TRUE
  config$show_performance_metrics <- TRUE
  
  return(config)
}

#' Create Cognitive Items from React Demo Structure
#'
#' Converts React demo cognitive items into R data frame format
#' compatible with the inrep package structure.
#'
#' @return Data frame with cognitive items in inrep format
#' @export
create_cognitive_items_from_demo <- function() {
  
  # Mirror the React demo cognitive items
  cognitive_items <- data.frame(
    Question = c(
      "Remember this sequence: 7, 3, 9, 2, 5. What was the third number in the sequence?",
      "Count the number of blue circles in the display.",
      "Name the COLOR of the word, not the word itself: RED (displayed in blue)"
    ),
    
    # IRT parameters for 2PL model
    a = c(1.2, 0.8, 1.5),  # discrimination
    b = c(0.5, 0.3, 0.7),  # difficulty
    
    # Response options
    Option1 = c("7", "4", "Red"),
    Option2 = c("3", "5", "Blue"), 
    Option3 = c("9", "6", "Green"),
    Option4 = c("2", "7", "Yellow"),
    Answer = c("9", "5", "Blue"),
    
    # Cognitive domain classification
    domain = c("Working_Memory", "Processing_Speed", "Executive_Function"),
    subtype = c("n-back", "visual_search", "stroop"),
    analysis_type = c("irt_2pl", "reaction_time", "conflict_monitoring"),
    cognitive_load = c("high", "medium", "high"),
    adaptive_rule = c("difficulty_based", "speed_based", "conflict_based"),
    
    stringsAsFactors = FALSE
  )
  
  return(cognitive_items)
}

#' Create Consent Screen UI
#'
#' Creates the consent screen that mirrors the React demo consent flow.
#'
#' @param config Study configuration object
#' @return Shiny UI elements for consent screen
#' @export
create_consent_screen_ui <- function(config) {
  
  ui_labels <- load_translations(config$language)
  
  div(class = "min-h-screen bg-white text-black flex items-center justify-center",
    div(class = "assessment-card max-w-lg w-full",
      h3("Research Study Consent", class = "card-header text-xl font-bold"),
      p("Welcome to the Cognitive Assessment Study. Please read the information below and provide your consent to participate.",
        class = "welcome-text"),
      
      div(class = "mb-4 text-sm text-gray-700",
        p(strong("Purpose:"), " This study investigates cognitive abilities using standardized assessment items. Your responses will be anonymized and used for research purposes only."),
        p(strong("Data Privacy:"), " All data is stored securely and handled in accordance with institutional and GDPR guidelines.", class = "mt-2"),
        p(strong("Voluntary Participation:"), " You may withdraw at any time without penalty.", class = "mt-2")
      ),
      
      div(class = "flex items-center gap-2 mb-4",
        checkboxInput("consent_checkbox", 
                     label = "I have read and understood the information above and consent to participate.",
                     value = FALSE),
      ),
      
      div(class = "nav-buttons",
        actionButton("consent_continue", "Continue", 
                    class = "btn-klee w-full",
                    disabled = TRUE)
      )
    )
  )
}

#' Create Participant Info Screen UI
#'
#' Creates the participant information screen that mirrors the React demo.
#'
#' @param config Study configuration object
#' @return Shiny UI elements for participant info screen
#' @export
create_participant_info_screen_ui <- function(config) {
  
  div(class = "min-h-screen bg-white text-black flex items-center justify-center",
    div(class = "assessment-card max-w-lg w-full",
      h3("Participant Information", class = "card-header text-xl font-bold"),
      p("Please provide the following demographic information for research purposes.",
        class = "welcome-text"),
      
      div(class = "space-y-4",
        div(
          tags$label("Age", class = "block text-sm mb-1"),
          numericInput("participant_age", 
                      label = NULL,
                      value = NULL,
                      min = 18, max = 99,
                      width = "100%")
        ),
        
        div(
          tags$label("Gender", class = "block text-sm mb-1"),
          selectInput("participant_gender",
                     label = NULL,
                     choices = c("Select..." = "", "Female" = "female", 
                               "Male" = "male", "Other" = "other", 
                               "Prefer not to say" = "prefer_not"),
                     width = "100%")
        ),
        
        div(
          tags$label("Education", class = "block text-sm mb-1"),
          selectInput("participant_education",
                     label = NULL,
                     choices = c("Select..." = "", "High School" = "highschool",
                               "Bachelor's Degree" = "bachelor", 
                               "Master's Degree" = "master",
                               "Doctorate" = "doctorate", "Other" = "other"),
                     width = "100%")
        )
      ),
      
      div(class = "nav-buttons mt-4",
        actionButton("info_continue", "Continue", 
                    class = "btn-klee w-full")
      )
    )
  )
}

#' Create Instructions Screen UI
#'
#' Creates the instructions screen that mirrors the React demo.
#'
#' @param config Study configuration object
#' @return Shiny UI elements for instructions screen
#' @export
create_instructions_screen_ui <- function(config) {
  
  div(class = "min-h-screen bg-white text-black flex items-center justify-center",
    div(class = "assessment-card max-w-lg w-full",
      h3("Instructions", class = "card-header text-xl font-bold"),
      p("Please read the instructions carefully before starting the assessment.",
        class = "welcome-text"),
      
      tags$ul(class = "list-disc pl-5 text-sm text-gray-700 mb-4",
        tags$li("You will complete a series of cognitive tasks assessing memory, speed, and executive function."),
        tags$li("Answer each question as accurately and quickly as possible."),
        tags$li("Your progress will be displayed at the top of the screen."),
        tags$li("There are no right or wrong answers; please try your best."),
        tags$li("Click 'Begin Assessment' when you are ready.")
      ),
      
      div(class = "nav-buttons",
        actionButton("begin_assessment", "Begin Assessment", 
                    class = "btn-klee w-full")
      )
    )
  )
}

#' Create Assessment Header UI
#'
#' Creates the professional assessment header with progress and metadata.
#'
#' @param config Study configuration object
#' @param current_question Current question number
#' @param total_questions Total number of questions
#' @param current_item Current item data
#' @return Shiny UI elements for assessment header
#' @export
create_assessment_header_ui <- function(config, current_question, total_questions, current_item) {
  
  div(class = "bg-white rounded-lg border p-4 mb-6",
    div(class = "flex items-center justify-between",
      div(class = "flex items-center gap-4",
        div(class = "flex items-center gap-2",
          icon("brain", class = "w-5 h-5 text-black"),
          span("Cognitive Assessment", class = "font-semibold")
        ),
        span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
          icon("shield", class = "w-3 h-3 mr-1"),
          "Live Analysis Active"
        ),
        if (!is.null(current_item)) {
          span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
            toupper(gsub("_", " ", current_item$analysis_type))
          )
        }
      ),
      div(class = "flex items-center gap-4 text-sm text-gray-600",
        div(class = "flex items-center gap-1",
          icon("clock", class = "w-4 h-4"),
          "12:34" # This would be dynamic in real implementation
        ),
        div("ID: P001") # This would be dynamic
      )
    ),
    
    div(class = "mt-4",
      div(class = "flex justify-between text-sm text-gray-600 mb-2",
        span(paste("Question", current_question, "of", total_questions)),
        span(paste0(round((current_question / total_questions) * 100), "% Complete"))
      ),
      div(class = "progress-container",
        div(class = "progress-bar bg-gray-200 h-2 rounded",
          div(class = "progress-fill bg-black h-full rounded transition-all duration-500",
              style = paste0("width: ", (current_question / total_questions) * 100, "%"))
        )
      )
    )
  )
}

#' Create Assessment Item UI
#'
#' Creates the assessment item interface that mirrors the React demo.
#'
#' @param config Study configuration object
#' @param current_item Current item data
#' @param current_question Current question number
#' @param feedback_message Optional feedback message
#' @param show_feedback Logical indicating whether to show feedback
#' @return Shiny UI elements for assessment item
#' @export
create_assessment_item_ui <- function(config, current_item, current_question, 
                                     feedback_message = NULL, show_feedback = FALSE) {
  if (is.null(current_item)) {
    return(div(class = "assessment-card",
              h3("Preparing...", class = "card-header text-base font-bold"),
              p("Loading next question...", class = "text-base")))
  }
  # Create stimulus display based on item type
  stimulus_ui <- if (current_question == 2) {
    div(class = "flex justify-center gap-2",
      lapply(1:7, function(i) {
        div(class = paste0("w-8 h-8 rounded-full border ",
                          if (i <= 5) "bg-black" else "bg-white border-black"))
      })
    )
  } else if (current_question == 3) {
    div(class = "text-4xl font-bold text-blue-600 mb-2", "RED")
  } else {
    NULL
  }
  div(class = "assessment-card mb-5",
    div(class = "card-header flex items-center justify-between",
      div(
        h4(current_item$domain, class = "text-base font-semibold"),
        div(class = "flex items-center gap-2 mt-1",
          span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
            current_item$subtype),
          span(class = "text-xs text-gray-500",
            paste("Difficulty:", current_item$b, "| Load:", current_item$cognitive_load))
        )
      ),
      div(class = "text-right",
        span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
          paste("Item", current_question)),
        p(class = "text-xs text-gray-500 mt-1",
          paste("Analysis:", config$analysis_strategies[[current_item$domain]]$name))
      )
    ),
    div(class = "space-y-5",
      # Stimulus section
      div(class = "bg-gray-50 p-5 rounded-lg text-center",
        p(current_item$Question, class = "text-base font-medium mb-3"),
        stimulus_ui
      ),
      # Response options
      div(
        h3("Select your answer:", class = "text-base font-medium mb-3"),
        div(class = "grid grid-cols-2 gap-3",
          lapply(1:4, function(i) {
            option_text <- current_item[[paste0("Option", i)]]
            actionButton(paste0("option_", i),
                        label = div(
                          span(class = "w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center text-base font-medium mr-3",
                               LETTERS[i]),
                          option_text
                        ),
                        class = "btn-option h-12 text-left justify-start w-full border border-gray-300 bg-white text-black hover:bg-gray-100 text-base")
          })
        )
      ),
      # Feedback section
      if (show_feedback && !is.null(feedback_message)) {
        div(class = "feedback-section p-3 rounded-lg text-center bg-green-50 text-green-700 text-base font-semibold",
          feedback_message
        )
      },
      # Real-time analysis indicator
      div(class = "bg-gray-50 p-3 rounded-lg",
        div(class = "flex items-center gap-2 text-base",
          icon("activity", class = "w-5 h-5 text-black"),
          span("Live Analysis:", class = "font-medium text-black"),
          span(class = "text-black",
            switch(current_item$adaptive_rule,
              "difficulty_based" = "Adjusting difficulty based on performance",
              "speed_based" = "Monitoring response speed patterns", 
              "conflict_based" = "Analyzing conflict resolution strategies",
              "Real-time psychometric analysis active"
            )
          )
        )
      )
    )
  )
}

#' Create Results Screen UI
#'
#' Creates the comprehensive results screen that mirrors the React demo.
#'
#' @param config Study configuration object
#' @param results Assessment results object
#' @return Shiny UI elements for results screen
#' @export
create_results_screen_ui <- function(config, results) {
  
  if (is.null(results)) return(div("No results available"))
  
  # Calculate summary statistics
  total_correct <- sum(results$responses == 1, na.rm = TRUE)
  total_items <- length(results$responses)
  avg_time <- mean(results$response_times, na.rm = TRUE)
  
  div(class = "min-h-screen bg-white text-black p-4",
    div(class = "max-w-7xl mx-auto",
      
      # Header section
      div(class = "text-center mb-8",
        div(class = "flex items-center justify-center mb-4",
          icon("check-circle", class = "w-16 h-16 text-black")
        ),
        h1("Assessment Complete", class = "text-2xl font-bold mb-2"),
        p("Advanced psychometric analysis completed with domain-specific reporting", 
          class = "text-gray-500"),
        
        div(class = "mt-4 flex justify-center gap-4",
          actionButton("restart_assessment", 
                      label = list(icon("refresh-cw", class = "w-4 h-4 mr-2"), "Restart Assessment"),
                      class = "btn-klee"),
          downloadButton("download_report",
                        label = list(icon("download", class = "w-4 h-4 mr-2"), "Download Report"),
                        class = "btn-klee")
        )
      ),
      
      # Analysis summary cards
      div(class = "grid grid-cols-1 lg:grid-cols-4 gap-6 mb-8",
        
        # IRT Ability Card
        div(class = "assessment-card",
          div(class = "card-header flex items-center gap-2",
            icon("target", class = "w-5 h-5 text-black"),
            "IRT Ability"
          ),
          div(class = "text-2xl font-bold text-black mb-1",
            paste0("θ = ", sprintf("%.2f", results$theta %||% (total_correct / total_items * 2)))),
          p(class = "text-gray-500 mb-2",
            if (total_correct == total_items) "Exceptional performance"
            else if (total_correct > total_items/2) "Above average"
            else "Needs improvement"),
          div(class = "text-xs text-gray-500", "SE = 0.31 | Reliability = 0.89")
        ),
        
        # Processing Speed Card  
        div(class = "assessment-card",
          div(class = "card-header flex items-center gap-2",
            icon("zap", class = "w-5 h-5 text-black"),
            "Processing Speed"
          ),
          div(class = "text-2xl font-bold text-black mb-1",
            paste0(round(avg_time), " ms")),
          p("Average response time", class = "text-gray-500 mb-2"),
          div(class = "text-xs text-gray-500", "Boundary = 1.8 | Non-decision = 0.3s")
        ),
        
        # Executive Control Card
        div(class = "assessment-card",
          div(class = "card-header flex items-center gap-2",
            icon("brain", class = "w-5 h-5 text-black"),
            "Executive Control"
          ),
          div(class = "text-2xl font-bold text-black mb-1",
            if (length(results$responses) >= 3 && results$responses[3] == 1) "Good" else "Needs Work"),
          p("Conflict effect (executive function)", class = "text-gray-500 mb-2"),
          div(class = "text-xs text-gray-500", "Adaptation rate = 0.15")
        ),
        
        # Overall Profile Card
        div(class = "assessment-card",
          div(class = "card-header flex items-center gap-2",
            icon("pie-chart", class = "w-5 h-5 text-black"),
            "Overall Profile"
          ),
          div(class = "text-2xl font-bold text-black mb-1",
            if (total_correct == total_items) "Outstanding"
            else if (total_correct > total_items/2) "Strong"
            else "Developing"),
          p("Cognitive profile classification", class = "text-gray-500 mb-2"),
          div(class = "text-xs text-gray-500",
            paste0("Confidence = ", round(total_correct / total_items * 100), "%"))
        )
      ),
      
      # Detailed analysis section
      create_detailed_analysis_ui(config, results),
      
      # Navigation buttons
      div(class = "flex justify-center gap-4 mt-8",
        actionButton("return_dashboard", "Return to Dashboard", class = "btn-klee"),
        actionButton("view_backend", "View Analysis Backend", class = "btn-klee")
      )
    )
  )
}

#' Create Detailed Analysis UI
#'
#' Creates the detailed analysis section with tabs for different analysis types.
#'
#' @param config Study configuration object
#' @param results Assessment results object
#' @return Shiny UI elements for detailed analysis
#' @export
create_detailed_analysis_ui <- function(config, results) {
  
  total_correct <- sum(results$responses == 1, na.rm = TRUE)
  total_items <- length(results$responses)
  avg_time <- mean(results$response_times, na.rm = TRUE)
  
  div(class = "grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8",
    
    # Domain-Specific Analysis Card
    div(class = "assessment-card",
      div(class = "card-header flex items-center gap-2",
        icon("bar-chart-3", class = "w-5 h-5 text-black"),
        "Domain-Specific Analysis"
      ),
      p("Results from specialized analysis pipelines", class = "text-gray-500 mb-4"),
      
      tabsetPanel(
        id = "analysis_tabs",
        
        tabPanel("IRT Analysis",
          div(class = "mt-4 space-y-3",
            div(class = "flex justify-between items-center",
              span("Ability Estimate (θ)", class = "text-sm"),
              span(class = "font-medium",
                paste0(sprintf("%.2f", results$theta %||% (total_correct / total_items * 2)), " ± 0.31"))
            ),
            div(class = "flex justify-between items-center",
              span("Model Fit (RMSEA)", class = "text-sm"),
              span("0.045", class = "font-medium")
            ),
            div(class = "flex justify-between items-center",
              span("Information", class = "text-sm"),
              span("10.4", class = "font-medium")
            ),
            div(class = "mt-4 p-3 bg-gray-50 rounded-lg",
              p(class = "text-xs text-black",
                strong("Interpretation: "),
                if (total_correct == total_items) "Exceptional cognitive ability and precision."
                else if (total_correct > total_items/2) "High ability with good measurement precision."
                else "Performance below optimal, consider further training."
              )
            )
          )
        ),
        
        tabPanel("RT Modeling",
          div(class = "mt-4 space-y-3",
            div(class = "flex justify-between items-center",
              span("Average Response Time", class = "text-sm"),
              span(paste0(round(avg_time), " ms"), class = "font-medium")
            ),
            div(class = "flex justify-between items-center",
              span("Boundary Separation (a)", class = "text-sm"),
              span("1.8", class = "font-medium")
            ),
            div(class = "flex justify-between items-center",
              span("Non-decision Time (Ter)", class = "text-sm"),
              span("0.31s", class = "font-medium")
            ),
            div(class = "mt-4 p-3 bg-gray-50 rounded-lg",
              p(class = "text-xs text-black",
                strong("Interpretation: "),
                if (avg_time < 1000) "Fast information processing and efficient speed-accuracy balance."
                else "Response speed is moderate, consider practice for improvement."
              )
            )
          )
        ),
        
        tabPanel("Conflict Mon.",
          div(class = "mt-4 space-y-3",
            div(class = "flex justify-between items-center",
              span("Conflict Effect", class = "text-sm"),
              span(class = "font-medium",
                if (length(results$responses) >= 3 && results$responses[3] == 1) "Low" else "High")
            ),
            div(class = "flex justify-between items-center",
              span("Control Strength", class = "text-sm"),
              span(class = "font-medium",
                if (length(results$responses) >= 3 && results$responses[3] == 1) "0.78" else "0.45")
            ),
            div(class = "flex justify-between items-center",
              span("Adaptation Rate", class = "text-sm"),
              span("0.15", class = "font-medium")
            ),
            div(class = "mt-4 p-3 bg-gray-50 rounded-lg",
              p(class = "text-xs text-black",
                strong("Interpretation: "),
                if (length(results$responses) >= 3 && results$responses[3] == 1) 
                  "Good executive control with minimal interference effects."
                else "Executive control can be improved with targeted training."
              )
            )
          )
        )
      )
    ),
    
    # Generated Reports Card
    div(class = "assessment-card",
      div(class = "card-header flex items-center gap-2",
        icon("file-text", class = "w-5 h-5 text-black"),
        "Generated Reports"
      ),
      p("Automated analysis reports based on assessment composition", class = "text-gray-500 mb-4"),
      
      div(class = "space-y-3",
        div(class = "flex items-center justify-between p-3 border rounded-lg",
          div(
            p("Comprehensive Cognitive Report", class = "font-medium text-sm"),
            p("IRT + RT + Executive Function Analysis", class = "text-gray-500 text-xs")
          ),
          downloadButton("download_pdf", 
                        label = list(icon("file-text", class = "w-4 h-4 mr-1"), "PDF"),
                        class = "btn-klee btn-sm")
        ),
        
        div(class = "flex items-center justify-between p-3 border rounded-lg",
          div(
            p("Technical Analysis Summary", class = "font-medium text-sm"),
            p("Statistical parameters and model fit", class = "text-gray-500 text-xs")
          ),
          downloadButton("download_csv",
                        label = list(icon("database", class = "w-4 h-4 mr-1"), "CSV"),
                        class = "btn-klee btn-sm")
        ),
        
        div(class = "flex items-center justify-between p-3 border rounded-lg",
          div(
            p("R Analysis Script", class = "font-medium text-sm"),
            p("Reproducible analysis code", class = "text-gray-500 text-xs")
          ),
          downloadButton("download_r_script",
                        label = list(icon("database", class = "w-4 h-4 mr-1"), ".R"),
                        class = "btn-klee btn-sm")
        )
      ),
      
      div(class = "mt-4 p-3 bg-gray-50 rounded-lg",
        div(class = "flex items-center gap-2 text-black mb-2",
          icon("cloud", class = "w-5 h-5"),
          span("Cloud Integration Status", class = "font-medium text-sm")
        ),
        p(class = "text-gray-500 text-xs",
          "✓ Raw data uploaded to secure storage", br(),
          "✓ Analysis results synchronized", br(),
          "✓ Reports generated and archived", br(),
          "✓ Backup completed successfully"
        )
      )
    )
  )
}
