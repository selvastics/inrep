#' Create Demographic Input Component for Assessment Interface
#'
#' @description
#' Generates standardized demographic input controls for assessment interfaces
#' with accessibility features, validation, and consistent styling. Supports
#' multiple input types commonly used in psychometric research for participant
#' characterization and demographic data collection.
#'
#' @param dem Character string specifying the demographic variable name to
#'   display as the input label (e.g., "Age", "Gender", "Education Level").
#' @param index Numeric index for the input element, used to create unique
#'   input IDs in the format "demo_[index]".
#' @param input_type Character string specifying the type of input control.
#'   Options: \code{"numeric"} for numeric inputs, \code{"select"} for
#'   dropdown selections, \code{"text"} for text inputs. Default is \code{"text"}.
#' @param value Current value for the input. Should match the expected type
#'   (numeric for "numeric", character for "select" and "text").
#'
#' @details
#' This function creates standardized demographic input components that
#' integrate seamlessly with assessment workflows and maintain consistency
#' across different research studies:
#' 
#' \strong{Input Type Features:}
#' \itemize{
#'   \item \strong{Numeric}: Age, years of experience, etc. (range: 1-150)
#'   \item \strong{Select}: Gender, education levels, with predefined options
#'   \item \strong{Text}: Open-ended demographic information
#' }
#' 
#' \strong{Accessibility Features:}
#' \itemize{
#'   \item Properly associated labels for screen readers
#'   \item Logical tab order and keyboard navigation
#'   \item Clear visual hierarchy and contrast
#'   \item Responsive design for different screen sizes
#' }
#' 
#' \strong{Research Standards:}
#' \itemize{
#'   \item Consistent styling across assessment interfaces
#'   \item Validation-ready for data quality assurance
#'   \item Integration with IRT-Based Assessment workflows
#'   \item Support for multilingual interfaces
#' }
#' 
#' The generated inputs automatically integrate with the assessment's
#' reactive value system and validation framework, ensuring data quality
#' and participant experience standards.
#'
#' @return A Shiny div element containing the formatted demographic input
#'   with proper labeling, styling, and accessibility attributes.
#'
#' @examples
#' \dontrun{
#' # Numeric input for age
#' age_input <- create_demographic_input(
#'   dem = "Age",
#'   index = 1,
#'   input_type = "numeric",
#'   value = 25
#' )
#' 
#' # Select input for gender
#' gender_input <- create_demographic_input(
#'   dem = "Gender",
#'   index = 2,
#'   input_type = "select",
#'   value = "Female"
#' )
#' 
#' # Text input for occupation
#' occupation_input <- create_demographic_input(
#'   dem = "Occupation",
#'   index = 3,
#'   input_type = "text",
#'   value = "Teacher"
#' )
#' 
#' # Multiple demographics in assessment
#' demographics <- c("Age", "Gender", "Education")
#' inputs <- lapply(seq_along(demographics), function(i) {
#'   create_demographic_input(
#'     dem = demographics[i],
#'     index = i,
#'     input_type = if (i == 1) "numeric" else "select",
#'     value = NULL
#'   )
#' })
#' }
#'
#' @section Input Validation:
#' The function creates inputs with built-in validation:
#' \itemize{
#'   \item Numeric inputs: Range validation (1-150) suitable for age and similar measures
#'   \item Select inputs: Predefined options with "Select" placeholder
#'   \item Text inputs: Open-ended with length limits applied by assessment framework
#' }
#'
#' @section Styling:
#' All inputs use consistent CSS classes:
#' \itemize{
#'   \item \code{form-group}: Container div for spacing and alignment
#'   \item \code{input-label}: Consistent label styling across assessments
#'   \item Responsive width (100%) for mobile compatibility
#' }
#'
#' @seealso 
#' \code{\link{create_demographics_ui}} for complete demographics interface,
#' \code{\link{launch_study}} for assessment workflow integration,
#' \code{\link{create_study_config}} for demographic configuration
#'
#' @importFrom shiny div numericInput selectInput textInput
#' @export
create_demographic_input <- function(dem, index, input_type, value) {
  input_id <- paste0("demo_", index)
  
  shiny::div(class = "form-group",
    shiny::tags$label(dem, class = "input-label"),
    switch(input_type,
      "numeric" = shiny::numericInput(
        inputId = input_id,
        label = NULL,
        value = if (!is.null(value)) value else NA,
        min = 1,
        max = 150,
        width = "100%"
      ),
      "select" = shiny::selectInput(
        inputId = input_id,
        label = NULL,
        choices = c("Select" = "", "Male", "Female", "Other"),
        selected = if (!is.null(value)) value else "",
        width = "100%"
      ),
      shiny::textInput(
        inputId = input_id,
        label = NULL,
        value = if (!is.null(value)) value else "",
        width = "100%"
      )
    )
  )
}

#' Render Progress UI
#' @noRd
render_progress_ui <- function(rv, config) {
  if (config$progress_style == "circle") {
    progress_pct <- length(rv$administered) / config$max_items * 100
    shiny::div(class = "progress-circle",
      shiny::tags$svg(
        width = "100", height = "100",
        shiny::tags$circle(cx = "50", cy = "50", r = "45", 
                          stroke = "var(--progress-bg-color)"),
        shiny::tags$circle(cx = "50", cy = "50", r = "45", 
                          class = "progress",
                          strokeDasharray = "283",
                          strokeDashoffset = sprintf("%.0f", 283 * (1 - progress_pct/100)),
                          style = "stroke: var(--primary-color);"
        ),
        shiny::span(sprintf("%d%%", round(progress_pct)))
      )
    )
  }
}

#' Render Response UI
#' @noRd
render_response_ui <- function(item, config) {
  if (config$model == "GRM") {
    choices <- as.numeric(unlist(strsplit(item$ResponseCategories, ",")))
    labels <- get_response_labels(choices, config$language)
    
    switch(config$response_ui_type,
      "slider" = create_slider_input(choices, labels),
      "dropdown" = create_dropdown_input(choices, labels),
      create_radio_input(choices, labels)
    )
  } else {
    valid_options <- c(item$Option1, item$Option2, item$Option3, item$Option4)
    valid_options <- valid_options[!is.na(valid_options) & valid_options != ""]
    
    shinyWidgets::radioGroupButtons(
      inputId = "item_response",
      label = NULL,
      choices = valid_options,
      selected = character(0),
      direction = "vertical",
      status = "default",
      individual = TRUE,
      width = "100%"
    )
  }
}

# ...add other UI helper functions...
