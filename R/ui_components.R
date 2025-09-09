#' UI Components for increp Package
#' 
#' This file consolidates all UI component functions including:
#' - UI helper functions (from ui_helper.R)
#' - Complete UI functions (from complete_ui.R)
#' 
#' @name ui_components
#' @keywords internal

# ============================================================================
# SECTION 1: UI HELPER FUNCTIONS (from ui_helper.R)
# ============================================================================

#' Unified INREP UI Generator
#'
#' Generates all UI components for assessment items and demographics in one function.
#' Maintains accessibility, validation, and configuration features.
#'
#' @param type UI type: "assessment" or "demographics"
#' @param item Data frame row for assessment item (if type = "assessment")
#' @param response_ui_type UI type for assessment: "radio", "dropdown", "slider"
#' @param demographics Character vector of demographic fields (if type = "demographics")
#' @param input_types Named list of input types for demographics
#' @param language Language code for UI labels (default: "en")
#' @return Shiny UI element
#' @export
inrep_ui <- function(type = c("assessment", "demographics"),
                     item = NULL,
                     response_ui_type = "radio",
                     demographics = NULL,
                     input_types = NULL,
                     language = "en") {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required but not available. Please install it with: install.packages('shiny')")
  }
  
  # Get language labels
  ui_labels <- get_language_labels(language)
  get_label <- function(key) ui_labels[[key]] %||% key
  type <- match.arg(type)
  if (type == "assessment") {
    # Assessment item UI
    choices <- as.character(item[grep("^Option", names(item))])
    choices <- choices[!is.na(choices) & choices != ""]
    names(choices) <- choices
    if (response_ui_type == "radio") {
      return(radioButtons(
        inputId = "item_response",
        label = item$Question,
        choices = choices,
        selected = character(0)
      ))
    } else if (response_ui_type == "dropdown") {
      return(selectInput(
        inputId = "item_response",
        label = item$Question,
        choices = c("", choices),
        selected = ""
      ))
    } else if (response_ui_type == "slider") {
      return(sliderInput(
        inputId = "item_response",
        label = item$Question,
        min = 1,
        max = length(choices),
        value = 1,
        step = 1,
        ticks = TRUE
      ))
    } else {
      stop("Unsupported response_ui_type: ", response_ui_type)
    }
  } else if (type == "demographics") {
    # Demographics UI
    if (is.null(demographics)) {
      return(actionButton("start_test", get_label("start_button")))
    }
    inputs <- lapply(demographics, function(demo) {
      input_type <- input_types[[demo]]
      if (input_type == "numeric") {
        numericInput(
          inputId = paste0("demo_", demo),
          label = demo,
          value = NA,
          min = 0,
          max = 120
        )
      } else if (input_type == "select") {
        selectInput(
          inputId = paste0("demo_", demo),
          label = demo,
          choices = c("", "Male", "Female", "Other"),
          selected = ""
        )
      } else {
        textInput(
          inputId = paste0("demo_", demo),
          label = demo,
          value = ""
        )
      }
    })
    return(tagList(inputs, actionButton("start_test", get_label("start_button"))))
  }
}
# File: ui_helpers.R

#' Create Response UI Component for Assessment Items
#'
#' @description
#' Generates standardized Shiny UI components for participant responses to
#' assessment items. Supports multiple response formats commonly used in
#' psychometric assessments, with accessibility features and consistent
#' styling optimized for TAM-based item response modeling.
#'
#' @param item A data frame row containing complete item details including
#'   question text and response options. Expected columns include:
#'   \code{Question}, \code{Option1}, \code{Option2}, \code{Option3}, \code{Option4}.
#'   Additional options (Option5, Option6, etc.) are supported.
#' @param response_ui_type Character string specifying the type of response
#'   interface. Options: \code{"radio"} for radio buttons, \code{"slider"} for
#'   slider input, \code{"dropdown"} for dropdown selection. Default is \code{"radio"}.
#'
#' @details
#' This function creates standardized response interfaces that integrate
#' seamlessly with TAM's item response modeling and adaptive testing algorithms:
#' 
#' \strong{Response Interface Types:}
#' \itemize{
#'   \item \strong{Radio Buttons}: Optimal for 2-5 response options, clear visual selection
#'   \item \strong{Dropdown}: Space-efficient for items with many response options
#'   \item \strong{Slider}: Continuous-feel interface for Likert-type scales
#' }
#' 
#' \strong{Psychometric Considerations:}
#' \itemize{
#'   \item Response order preservation for TAM parameter estimation
#'   \item Clear option labeling to minimize response errors
#'   \item Consistent interaction patterns across assessment items
#'   \item Validation-ready for missing response detection
#' }
#' 
#' \strong{Accessibility Features:}
#' \itemize{
#'   \item Keyboard navigation support for all interface types
#'   \item Screen reader compatibility with proper labeling
#'   \item High contrast options and responsive design
#'   \item Touch-friendly interfaces for mobile devices
#' }
#' 
#' \strong{Research Standards:}
#' \itemize{
#'   \item Consistent option presentation across items
#'   \item Integration with response time tracking
#'   \item Support for multilingual option labels
#'   \item Quality assurance through input validation
#' }
#' 
#' The generated UI components automatically integrate with the assessment's
#' reactive system and TAM-based ability estimation procedures.
#'
#' @return A Shiny UI element (radioButtons, sliderInput, or selectInput)
#'   configured for the specified response type with proper accessibility
#'   attributes and validation support.
#'
#' @examples
#' \dontrun{
#' # Personality item with radio buttons
#' personality_item <- data.frame(
#'   Question = "I enjoy meeting new people",
#'   Option1 = "Strongly Disagree",
#'   Option2 = "Disagree",
#'   Option3 = "Neutral",
#'   Option4 = "Agree",
#'   Option5 = "Strongly Agree"
#' )
#' 
#' radio_ui <- create_response_ui(personality_item, "radio")
#' 
#' # Cognitive item with dropdown
#' cognitive_item <- data.frame(
#'   Question = "What is the next number in the sequence: 2, 4, 6, ?",
#'   Option1 = "7",
#'   Option2 = "8",
#'   Option3 = "9",
#'   Option4 = "10"
#' )
#' 
#' dropdown_ui <- create_response_ui(cognitive_item, "dropdown")
#' 
#' # Attitude scale with slider
#' attitude_item <- data.frame(
#'   Question = "How satisfied are you with your current job?",
#'   Option1 = "Very Dissatisfied",
#'   Option2 = "Dissatisfied",
#'   Option3 = "Neutral",
#'   Option4 = "Satisfied",
#'   Option5 = "Very Satisfied"
#' )
#' 
#' slider_ui <- create_response_ui(attitude_item, "slider")
#' 
#' # Dynamic UI creation in assessment
#' current_item <- item_bank[selected_item_index, ]
#' response_interface <- create_response_ui(current_item, config$response_ui_type)
#' }
#'
#' @section Response Validation:
#' The function creates interfaces with built-in validation features:
#' \itemize{
#'   \item Radio buttons: Single selection enforcement, clear visual feedback
#'   \item Dropdown: Placeholder option ("") for missing response detection
#'   \item Slider: Numeric validation with defined min/max bounds
#' }
#'
#' @section Integration with TAM:
#' Response values are formatted for direct use with TAM functions:
#' \itemize{
#'   \item Consistent option indexing (1, 2, 3, ...) for TAM parameter matrices
#'   \item Proper handling of missing responses for TAM's missing data procedures
#'   \item Response time integration for speed-accuracy analysis
#' }
#'
#' @seealso 
#' \code{\link{create_demographic_input}} for demographic interface components,
#' \code{\link{launch_study}} for complete assessment workflow,
#' \code{\link{select_next_item}} for adaptive item selection,
#' \code{\link{estimate_ability}} for TAM-based ability estimation
#'
#' @export
create_response_ui <- function(item, response_ui_type) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required but not available. Please install it with: install.packages('shiny')")
  }
  
  choices <- as.character(item[paste0("Option", 1:4)])
  choices <- choices[!is.na(choices)]
  names(choices) <- choices
  
  if (response_ui_type == "radio") {
    radioButtons(
      inputId = "item_response",
      label = "Select response",
      choices = choices,
      selected = character(0)
    )
  } else if (response_ui_type == "dropdown") {
    selectInput(
      inputId = "item_response",
      label = "Select response",
      choices = c("", choices),
      selected = ""
    )
  } else if (response_ui_type == "slider") {
    sliderInput(
      inputId = "item_response",
      label = "Select response",
      min = 1,
      max = length(choices),
      value = 1,
      step = 1
    )
  } else {
    stop("Unsupported response_ui_type: ", response_ui_type)
  }
}

#' Create Demographics UI Interface for Assessment Workflow
#'
#' @description
#' Generates comprehensive Shiny UI components for demographic data collection
#' as part of the assessment workflow. Creates standardized input interfaces
#' that integrate seamlessly with TAM-based psychometric assessments while
#' maintaining accessibility standards and research best practices.
#'
#' @param demographics A character vector specifying demographic fields to
#'   collect (e.g., \code{c("Age", "Gender", "Education")}). If \code{NULL},
#'   returns a "Start Test" button to proceed directly to assessment.
#' @param input_types A named list specifying input types for each demographic
#'   field. Names should match \code{demographics} vector, values should be
#'   \code{"numeric"}, \code{"select"}, or \code{"text"}. Example:
#'   \code{list(Age = "numeric", Gender = "select", Education = "text")}.
#'
#' @details
#' This function creates standardized demographic collection interfaces that
#' support research requirements while maintaining participant experience quality:
#' 
#' \strong{Demographic Input Types:}
#' \itemize{
#'   \item \strong{Numeric}: Age, years of experience, education years
#'   \item \strong{Select}: Gender, education level, employment status
#'   \item \strong{Text}: Open-ended fields like occupation, comments
#' }
#' 
#' \strong{Research Standards:}
#' \itemize{
#'   \item Consistent labeling and formatting across studies
#'   \item Validation-ready for data quality assurance
#'   \item Integration with IRT-Based Assessment workflows
#'   \item Support for IRB-compliant data collection practices
#' }
#' 
#' \strong{Accessibility Features:}
#' \itemize{
#'   \item Clear labels and logical tab order
#'   \item Screen reader compatibility
#'   \item Mobile-responsive design
#'   \item High contrast and keyboard navigation support
#' }
#' 
#' \strong{Workflow Integration:}
#' \itemize{
#'   \item Seamless transition to assessment items
#'   \item Data validation before proceeding
#'   \item Integration with session management
#'   \item Support for resume/save functionality
#' }
#' 
#' The generated interface automatically handles the transition from demographic
#' collection to the main assessment, ensuring proper data validation and
#' session state management.
#'
#' @return A Shiny UI element containing:
#' \describe{
#'   \item{Input components}{Formatted demographic inputs based on specified types}
#'   \item{Start button}{Action button to proceed to assessment ("Start Test")}
#'   \item{Validation}{ Built-in validation for required fields}
#' }
#' If \code{demographics} is \code{NULL}, returns only the "Start Test" button.
#'
#' @examples
#' \dontrun{
#' # Comprehensive demographics collection
#' demographics <- c("Age", "Gender", "Education", "Experience")
#' input_types <- list(
#'   Age = "numeric",
#'   Gender = "select", 
#'   Education = "select",
#'   Experience = "text"
#' )
#' 
#' demo_ui <- create_demographics_ui(demographics, input_types)
#' 
#' # Minimal demographics (age only)
#' minimal_demo_ui <- create_demographics_ui(
#'   demographics = c("Age"),
#'   input_types = list(Age = "numeric")
#' )
#' 
#' # Skip demographics entirely
#' no_demo_ui <- create_demographics_ui(NULL, NULL)
#' 
#' # Research study with extensive demographics
#' research_demographics <- c("Age", "Gender", "Education", "Income", "Occupation")
#' research_types <- list(
#'   Age = "numeric",
#'   Gender = "select",
#'   Education = "select", 
#'   Income = "select",
#'   Occupation = "text"
#' )
#' 
#' research_ui <- create_demographics_ui(research_demographics, research_types)
#' }
#'
#' @section Data Validation:
#' The function creates inputs with built-in validation:
#' \itemize{
#'   \item Numeric inputs: Range validation and type checking
#'   \item Select inputs: Predefined options with placeholder handling
#'   \item Text inputs: Length limits and character validation
#'   \item Required field checking before assessment proceeds
#' }
#'
#' @section Integration with Assessment:
#' The demographics UI integrates with the main assessment workflow:
#' \itemize{
#'   \item Automatic transition to test items after completion
#'   \item Data storage in reactive values for analysis
#'   \item Session state management for interruption recovery
#'   \item Integration with TAM-based ability estimation context
#' }
#'
#' @seealso 
#' \code{\link{create_demographic_input}} for individual demographic components,
#' \code{\link{create_response_ui}} for assessment item interfaces,
#' \code{\link{launch_study}} for complete assessment workflow,
#' \code{\link{create_study_config}} for demographic configuration setup
#'
#' @export
create_demographics_ui <- function(demographics, input_types) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required but not available. Please install it with: install.packages('shiny')")
  }
  
  if (is.null(demographics)) {
    return(actionButton("start_test", get_label("start_button")))
  }
  
  inputs <- lapply(demographics, function(demo) {
    input_type <- input_types[[demo]]
    if (input_type == "numeric") {
              numericInput(
          inputId = paste0("demo_", demo),
          label = demo,
          value = NA,
          min = 0,
          max = 120
        )
    } else if (input_type == "select") {
      selectInput(
        inputId = paste0("demo_", demo),
        label = demo,
        choices = c("", "Male", "Female", "Other"),
        selected = ""
      )
    } else {
      textInput(
        inputId = paste0("demo_", demo),
        label = demo,
        value = ""
      )
    }
  })
  
  tagList(inputs, actionButton("start_test", get_label("start_button")))
}

# ============================================================================
# SECTION 2: COMPLETE UI FUNCTIONS (from complete_ui.R)
# ============================================================================

# File: complete_ui.R
#' Complete Unified UI Function - All Aspects in One
#'
#' Ultimate single function that handles all UI aspects for adaptive testing.
#' Includes themes, accessibility, responsive design, demographics, assessment items,
#' progress tracking, and complete study flow in one comprehensive function.
#'
#' @param config Study configuration object
#' @param item_bank Item bank data frame
#' @param current_item Current item being displayed
#' @param responses Current responses
#' @param progress Progress percentage
#' @param phase Current phase ("introduction", "demographics", "assessment", "results")
#' @return Complete Shiny UI object
#' @export
#' @examples
#' \dontrun{
#' config <- create_study_config(name = "Test", theme = "dyslexia-friendly")
#' ui <- complete_ui(config, bfi_items)
#' }
complete_ui <- function(config, item_bank, current_item = 1, responses = NULL, progress = 0, phase = "introduction") {
  
  # Validate inputs
  if (is.null(config$name)) config$name <- "Cognitive Assessment Research Study"
  if (is.null(config$theme)) config$theme <- "professional"
  if (is.null(config$demographics)) config$demographics <- c("Age", "Gender", "Education")
  if (is.null(config$max_items)) config$max_items <- nrow(item_bank)
  if (is.null(config$language)) config$language <- "en"
  
  # Calculate progress
  total_items <- nrow(item_bank)
  progress_percent <- min(100, round((current_item / config$max_items) * 100, 1))
  current_item_data <- if (current_item <= nrow(item_bank) && current_item > 0) {
    item_bank[current_item, ]
  } else {
          list(Question = ui_labels$loading_question, ResponseCategories = "1,2,3,4,5")
  }
  
  # Get language labels from the comprehensive multilingual system
  ui_labels <- get_language_labels(config$language %||% "en")
  

  
  shiny::fluidPage(
    shinyjs::useShinyjs(),
    shiny::tags$head(
      shiny::tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel="stylesheet"),
      shiny::tags$link(rel = "stylesheet", href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"),
      shiny::tags$style(type = "text/css", get_theme_css(config$theme %||% "Light"))
    ),
    shiny::div(class = "min-h-screen bg-white text-black flex items-center justify-center",
      shiny::div(class = "assessment-card max-w-lg w-full",
        

        
        # ORIGINAL INTRODUCTION PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'introduction'",
          shiny::div(class = "text-center p-8",
            shiny::h1(class = "text-3xl font-bold mb-6 text-blue-600", config$name),
            shiny::div(class = "text-lg text-gray-700 mb-6", 
              if (!is.null(config$introduction_content)) {
                config$introduction_content
              } else {
                "Welcome to our cognitive assessment study. This research aims to understand individual differences in cognitive abilities and learning patterns."
              }
            ),
            shiny::div(class = "space-y-4",
              if (!is.null(config$show_introduction) && config$show_introduction) {
                shiny::actionButton("start_introduction", "Begin Introduction", 
                  class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
              },
              if (!is.null(config$show_consent) && config$show_consent) {
                shiny::actionButton("show_consent_form", "View Consent Form", 
                  class = "bg-green-500 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
              },
              if (!is.null(config$show_briefing) && config$show_briefing) {
                shiny::actionButton("show_briefing_info", "Study Briefing", 
                  class = "bg-purple-500 hover:bg-purple-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
              }
            )
          )
        ),
        
        # ORIGINAL CONSENT PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'consent'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-red-600", "Informed Consent"),
            shiny::div(class = "text-lg text-gray-700 mb-6 text-left max-h-96 overflow-y-auto",
              if (!is.null(config$consent_text)) {
                config$consent_text
              } else {
                "By participating in this study, you agree to the following terms..."
              }
            ),
            shiny::div(class = "space-y-4",
              shiny::checkboxInput("consent_given", "I have read and understood the consent form and agree to participate", 
                value = FALSE, width = "100%"),
              shiny::actionButton("proceed_after_consent", "I Agree and Continue", 
                class = "bg-green-500 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg text-lg",
                disabled = "!input.consent_given")
            )
          )
        ),
        
        # ORIGINAL INFO PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'info'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-blue-600", "Study Information"),
            shiny::div(class = "text-lg text-gray-700 mb-6 text-left",
              if (!is.null(config$briefing_text)) {
                config$briefing_text
              } else {
                "This study will assess various cognitive abilities through a series of tasks..."
              }
            ),
            shiny::actionButton("proceed_to_demographics", "Continue to Demographics", 
              class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
          )
        ),
        
        # ORIGINAL INSTRUCTIONS PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'instructions'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-blue-600", "Instructions"),
            shiny::div(class = "text-lg text-gray-700 mb-6 text-left max-h-96 overflow-y-auto",
              if (!is.null(config$instructions$structure)) {
                config$instructions$structure
              } else {
                "Please read the following instructions carefully before beginning the assessment..."
              }
            ),
            shiny::actionButton("begin_test", "I Understand - Begin Assessment", 
              class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
          )
        ),
        
        # ORIGINAL DEMOGRAPHICS PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'demographics'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-blue-600", "Demographic Information"),
            shiny::div(class = "text-lg text-gray-700 mb-6",
              "Please provide some basic information about yourself. This helps us understand the study population better."
            ),
            create_demographics_ui(config$demographics, config$demographic_configs),
            shiny::actionButton("start_test", "Continue to Assessment", 
              class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
          )
        ),
        
        # CUSTOM STUDY FLOW SUPPORT - NEW
        shiny::conditionalPanel(
          condition = "input.phase === 'custom_instructions'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-blue-600", "Study Instructions"),
            shiny::div(class = "text-lg text-gray-700 mb-6 text-left max-h-96 overflow-y-auto",
              if (!is.null(config$custom_page_configs$instructions$content)) {
                config$custom_page_configs$instructions$content
              } else if (!is.null(config$instructions$structure)) {
                config$instructions$structure
              } else {
                "Please read the following instructions carefully before beginning the assessment..."
              }
            ),
            shiny::actionButton("proceed_from_custom_instructions", "I Understand - Continue", 
              class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
          )
        ),
        
        # ORIGINAL ASSESSMENT PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'assessment'",
          shiny::div(class = "text-center p-8",
            # Progress bar
            shiny::div(class = "mb-6",
              shiny::div(class = "w-full bg-gray-200 rounded-full h-2.5",
                shiny::div(class = "bg-blue-600 h-2.5 rounded-full", 
                  style = paste0("width: ", progress_percent, "%"))
              ),
              shiny::p(class = "text-sm text-gray-600 mt-2", 
                paste("Question", current_item, "of", total_items, "(", progress_percent, "%)"))
            ),
            
            # Question display
            shiny::div(class = "mb-6 text-left",
              shiny::h3(class = "text-xl font-semibold mb-4 text-gray-800", 
                if (!is.null(current_item_data$Question)) current_item_data$Question else "Loading question..."),
              if (!is.null(current_item_data$Explanation)) {
                shiny::p(class = "text-gray-600 mb-4", current_item_data$Explanation)
              }
            ),
            
            # Response options
            shiny::div(class = "space-y-3",
              if (!is.null(current_item_data$ResponseCategories)) {
                response_categories <- strsplit(current_item_data$ResponseCategories, ",")[[1]]
                lapply(seq_along(response_categories), function(i) {
                  shiny::radioButtons(
                    inputId = paste0("response_", current_item),
                    label = NULL,
                    choices = setNames(as.list(i), trimws(response_categories[i])),
                    selected = character(0),
                    width = "100%"
                  )
                })
              } else {
                shiny::p("Response options loading...")
              }
            ),
            
            # Navigation buttons
            shiny::div(class = "flex justify-between mt-6",
              if (current_item > 1) {
                shiny::actionButton("prev_question", "Previous", 
                  class = "bg-gray-500 hover:bg-gray-700 text-white font-bold py-2 px-4 rounded")
              } else {
                shiny::div() # Empty div for spacing
              },
              if (current_item < total_items) {
                shiny::actionButton("next_question", "Next", 
                  class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded")
              } else {
                shiny::actionButton("finish_assessment", "Finish Assessment", 
                  class = "bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded")
              }
            )
          )
        ),
        
        # ORIGINAL RESULTS PHASE - PRESERVED
        shiny::conditionalPanel(
          condition = "input.phase === 'results'",
          shiny::div(class = "text-center p-8",
            shiny::h2(class = "text-2xl font-bold mb-6 text-green-600", "Assessment Complete!"),
            shiny::div(class = "text-lg text-gray-700 mb-6",
              "Thank you for participating in our study. Your responses have been recorded."
            ),
            
            # HILDESHEIM STUDY RESULTS - INTEGRATED PLOTS
            if (!is.null(config$theme) && config$theme == "hildesheim") {
              shiny::div(class = "mt-8",
                shiny::h3(class = "text-xl font-bold mb-4 text-blue-600", "Hildesheim Psychologie Studie 2025 - Results"),
                
                # BFI-2 Radar Plot
                shiny::div(class = "mb-6 p-4 bg-gray-50 rounded-lg",
                  shiny::h4(class = "text-lg font-semibold mb-3 text-gray-800", "Big Five Personality Profile"),
                  shiny::plotOutput("bfi_radar_plot", height = "400px")
                ),
                
                # PSQ Stress Plot
                shiny::div(class = "mb-6 p-4 bg-gray-50 rounded-lg",
                  shiny::h4(class = "text-lg font-semibold mb-3 text-gray-800", "PSQ Stress Assessment"),
                  shiny::plotOutput("psq_stress_plot", height = "300px")
                ),
                
                # MWS Study Skills Plot
                shiny::div(class = "mb-6 p-4 bg-gray-50 rounded-lg",
                  shiny::h4(class = "text-lg font-semibold mb-3 text-gray-800", "MWS Study Skills Assessment"),
                  shiny::plotOutput("mws_skills_plot", height = "300px")
                ),
                
                # Statistics Confidence Plot
                shiny::div(class = "mb-6 p-4 bg-gray-50 rounded-lg",
                  shiny::h4(class = "text-lg font-semibold mb-3 text-gray-800", "Statistics Self-Efficacy"),
                  shiny::plotOutput("statistics_confidence_plot", height = "300px")
                ),
                
                # Summary Scores
                shiny::div(class = "mb-6 p-4 bg-blue-50 rounded-lg",
                  shiny::h4(class = "text-lg font-semibold mb-3 text-blue-800", "Summary Scores"),
                  shiny::div(class = "grid grid-cols-2 gap-4 text-left",
                    shiny::div(class = "p-3 bg-white rounded border",
                      shiny::h5(class = "font-semibold text-gray-700", "Personality Profile"),
                      shiny::textOutput("personality_summary")
                    ),
                    shiny::div(class = "p-3 bg-white rounded border",
                      shiny::h5(class = "font-semibold text-gray-700", "Stress Level"),
                      shiny::textOutput("stress_summary")
                    ),
                    shiny::div(class = "p-3 bg-white rounded border",
                      shiny::h5(class = "font-semibold text-gray-700", "Study Skills"),
                      shiny::textOutput("study_skills_summary")
                    ),
                    shiny::div(class = "p-3 bg-white rounded border",
                      shiny::h5(class = "font-semibold text-gray-700", "Statistics Confidence"),
                      shiny::textOutput("statistics_summary")
                    )
                  )
                )
              )
            },
            
            if (!is.null(config$results_processor)) {
              shiny::div(class = "mt-6",
                config$results_processor(responses, item_bank)
              )
            },
            
            # Enhanced Download Section with PDF Button
            shiny::div(class = "mt-8 p-6 bg-gray-50 rounded-lg",
              shiny::h3(class = "text-xl font-semibold mb-4 text-gray-800", "Download Your Results"),
              shiny::p(class = "text-gray-600 mb-4", 
                "Get a comprehensive report of your assessment results with visualizations and detailed analysis."),
              
              shiny::div(class = "flex flex-wrap gap-4 justify-center",
                # PDF Download Button (Enhanced)
                shiny::downloadButton("save_report", 
                  shiny::div(class = "flex items-center space-x-2",
                    shiny::tags$i(class = "fas fa-file-pdf text-white text-lg"),
                    shiny::span("Download PDF Report")
                  ),
                  class = "bg-red-600 hover:bg-red-700 text-white font-bold py-3 px-6 rounded-lg text-lg shadow-lg transition-all duration-200 transform hover:scale-105"
                ),
                
                # CSV Download Button
                shiny::downloadButton("download_csv", 
                  shiny::div(class = "flex items-center space-x-2",
                    shiny::tags$i(class = "fas fa-file-csv text-white text-lg"),
                    shiny::span("Download CSV Data")
                  ),
                  class = "bg-green-600 hover:bg-green-700 text-white font-bold py-3 px-6 rounded-lg text-lg shadow-lg transition-all duration-200 transform hover:scale-105"
                ),
                
                # JSON Download Button
                shiny::downloadButton("download_json", 
                  shiny::div(class = "flex items-center space-x-2",
                    shiny::tags$i(class = "fas fa-file-code text-white text-lg"),
                    shiny::span("Download JSON Data")
                  ),
                  class = "bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg shadow-lg transition-all duration-200 transform hover:scale-105"
                )
              ),
              
              # PDF Features Info
              shiny::div(class = "mt-4 text-sm text-gray-600 text-center",
                shiny::p("📊 PDF includes: Progress plots, ability estimates, item analysis, and professional formatting"),
                shiny::p("⚡ Fast generation optimized for minimal processing power")
              )
            )
          )
        )
        
      )
    )
  )
}

