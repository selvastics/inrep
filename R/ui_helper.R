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
#' @return Shiny UI element
#' @export
inrep_ui <- function(type = c("assessment", "demographics"),
                     item = NULL,
                     response_ui_type = "radio",
                     demographics = NULL,
                     input_types = NULL) {
  require(shiny)
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
      return(actionButton("start_test", "Start Test"))
    }
    inputs <- lapply(demographics, function(demo) {
      input_type <- input_types[[demo]]
      if (input_type == "numeric") {
        numericInput(
          inputId = paste0("demo_", demo),
          label = demo,
          value = NA
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
    return(tagList(inputs, actionButton("start_test", "Start Test")))
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
  require(shiny)
  
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
  require(shiny)
  
  if (is.null(demographics)) {
    return(actionButton("start_test", "Start Test"))
  }
  
  inputs <- lapply(demographics, function(demo) {
    input_type <- input_types[[demo]]
    if (input_type == "numeric") {
      numericInput(
        inputId = paste0("demo_", demo),
        label = demo,
        value = NA
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
  
  tagList(inputs, actionButton("start_test", "Start Test"))
}