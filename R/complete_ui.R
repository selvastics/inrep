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
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      shiny::tags$style(type = "text/css", generate_theme_css(config$theme %||% "light"))
    ),
    shiny::div(class = "min-h-screen bg-white text-black flex items-center justify-center",
      shiny::div(class = "assessment-card max-w-lg w-full",
        shiny::conditionalPanel(
          condition = "input.phase == 'introduction'",
          shiny::div(
            shiny::h2(ui_labels$welcome_title %||% "Welcome to the Cognitive Assessment Study", class = "card-header text-2xl font-bold mb-4"),
            shiny::p(ui_labels$welcome_description %||% "Your participation helps advance cognitive science. All data is confidential and used for academic research only.", class = "mb-4 text-gray-700"),
            shiny::actionButton("go_to_consent", ui_labels$participate_button %||% "Participate in Study", class = "btn-klee w-full")
          )
        ),
        shiny::conditionalPanel(
          condition = "input.phase == 'consent'",
          shiny::div(
            shiny::h3(ui_labels$consent_title, class = "card-header text-xl font-bold"),
            shiny::p(ui_labels$consent_welcome %||% "Welcome to the Cognitive Assessment Study. Please read the information below and provide your consent to participate.", class = "welcome-text"),
            shiny::div(class = "mb-4 text-sm text-gray-700",
              shiny::p(shiny::strong(ui_labels$consent_purpose_label %||% "Purpose:"), ui_labels$consent_purpose_text %||% " This study investigates cognitive abilities using standardized assessment items. Your responses will be anonymized and used for research purposes only."),
              shiny::p(shiny::strong(ui_labels$consent_privacy_label %||% "Data Privacy:"), ui_labels$consent_privacy_text %||% " All data is stored securely and handled in accordance with institutional and GDPR guidelines.", class = "mt-2"),
              shiny::p(shiny::strong(ui_labels$consent_voluntary_label %||% "Voluntary Participation:"), ui_labels$consent_voluntary_text %||% " You may withdraw at any time without penalty.", class = "mt-2")
            ),
            shiny::div(class = "flex items-center gap-2 mb-4",
              shiny::checkboxInput("consent_checkbox", label = ui_labels$consent_checkbox_text %||% "I have read and understood the information above and consent to participate.", value = FALSE)
            ),
            shiny::div(class = "nav-buttons",
              shiny::actionButton("consent_continue", ui_labels$continue_button, class = "btn-klee w-full", disabled = TRUE)
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.phase == 'info'",
          shiny::div(
            shiny::h3(ui_labels$demo_title, class = "card-header text-xl font-bold"),
            shiny::p(ui_labels$welcome_text, class = "welcome-text"),
            shiny::div(class = "space-y-4",
              shiny::div(
                shiny::tags$label(ui_labels$age_label, class = "block text-sm mb-1"),
                shiny::numericInput("participant_age", label = NULL, value = NULL, min = 18, max = 99, width = "100%")
              ),
              shiny::div(
                shiny::tags$label(ui_labels$gender_label, class = "block text-sm mb-1"),
                shiny::selectInput("participant_gender", label = NULL, choices = c(
                  "Select..." = "", 
                  "Female" = "female", 
                  "Male" = "male", 
                  "Other" = "other", 
                  "Prefer not to say" = "prefer_not"
                ), width = "100%")
              ),
              shiny::div(
                shiny::tags$label(ui_labels$education_label, class = "block text-sm mb-1"),
                shiny::selectInput("participant_education", label = NULL, choices = c(
                  "Select..." = "", 
                  "High School" = "highschool", 
                  "Bachelor's Degree" = "bachelor", 
                  "Master's Degree" = "master", 
                  "Doctorate" = "doctorate", 
                  "Other" = "other"
                ), width = "100%")
              )
            ),
            shiny::div(class = "nav-buttons mt-4",
              shiny::actionButton("info_continue", ui_labels$continue_button, class = "btn-klee w-full")
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.phase == 'instructions'",
          shiny::div(
            shiny::h3(ui_labels$instructions_title, class = "card-header text-xl font-bold"),
            shiny::p(ui_labels$instructions_read_carefully %||% "Please read the instructions carefully before starting the assessment.", class = "welcome-text"),
            shiny::tags$ul(class = "list-disc pl-5 text-sm text-gray-700 mb-4",
              shiny::tags$li(ui_labels$instructions_cognitive_tasks %||% "You will complete a series of cognitive tasks assessing memory, speed, and executive function."),
              shiny::tags$li(ui_labels$instructions_answer_accurately %||% "Answer each question as accurately and quickly as possible."),
              shiny::tags$li(ui_labels$instructions_progress_display %||% "Your progress will be displayed at the top of the screen."),
              shiny::tags$li(ui_labels$instructions_no_right_wrong %||% "There are no right or wrong answers; please try your best."),
              shiny::tags$li(ui_labels$instructions_click_begin %||% "Click 'Begin Assessment' when you are ready.")
            ),
            shiny::div(class = "nav-buttons",
              shiny::actionButton("begin_assessment", ui_labels$begin_button, class = "btn-klee w-full")
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.phase == 'assessment'",
          shiny::div(
            # Assessment header
            shiny::div(class = "bg-white rounded-lg border p-4 mb-6",
              shiny::div(class = "flex items-center justify-between",
                shiny::div(class = "flex items-center gap-4",
                  shiny::div(class = "flex items-center gap-2",
                    shiny::icon("brain", class = "w-5 h-5 text-black"),
                                      shiny::span(ui_labels$cognitive_assessment %||% "Cognitive Assessment", class = "font-semibold")
                ),
                shiny::span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
                  shiny::icon("shield", class = "w-3 h-3 mr-1"),
                  ui_labels$live_analysis_active %||% "Live Analysis Active"
                ),
                  if (!is.null(current_item_data)) {
                    shiny::span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs",
                      toupper(current_item_data$analysis_type %||% "")
                    )
                  }
                ),
                shiny::div(class = "flex items-center gap-4 text-sm text-gray-600",
                  shiny::div(class = "flex items-center gap-1",
                    shiny::icon("clock", class = "w-4 h-4"),
                    ui_labels$session_time %||% "12:34"
                  ),
                  shiny::div(sprintf(ui_labels$participant_id %||% "ID: %s", "P001"))
                )
              ),
              shiny::div(class = "mt-4",
                shiny::div(class = "flex justify-between text-sm text-gray-600 mb-2",
                  shiny::span(paste(ui_labels$question_progress %||% paste("Question", current_item, "of", config$max_items %||% "?"))),
                  shiny::span(paste0(round((current_item / (config$max_items %||% 1)) * 100), "% Complete"))
                ),
                shiny::div(class = "progress-container",
                                      shiny::div(class = "progress-bar bg-gray-200 h-2 rounded",
                      shiny::div(class = "progress-fill bg-black h-full rounded transition-all duration-500",
                        style = sprintf("width: %s%%", round((current_item / (config$max_items %||% 1)) * 100))
                      )
                    )
                )
              )
            ),
            # Assessment item
            shiny::div(class = "assessment-card mb-5",
              shiny::div(class = "card-header flex items-center justify-between",
                shiny::div(
                  shiny::h4(current_item_data$domain %||% "", class = "text-base font-semibold"),
                  shiny::div(class = "flex items-center gap-2 mt-1",
                    shiny::span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs", current_item_data$subtype %||% ""),
                    shiny::span(class = "text-xs text-gray-500", sprintf(ui_labels$difficulty_load_format %||% "Difficulty: %s | Load: %s", current_item_data$b %||% "", current_item_data$cognitive_load %||% ""))
                  )
                ),
                shiny::div(class = "text-right",
                  shiny::span(class = "badge border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs", sprintf(ui_labels$item_number %||% "Item %d", current_item)),
                  shiny::p(class = "text-xs text-gray-500 mt-1", sprintf(ui_labels$analysis_type_format %||% "Analysis: %s", config$analysis_strategies[[current_item_data$domain]]$name %||% ""))
                )
              ),
              shiny::div(class = "space-y-5",
                shiny::div(class = "bg-gray-50 p-5 rounded-lg text-center",
                  shiny::p(current_item_data$Question %||% ui_labels$loading_question, class = "text-base font-medium mb-3")
                  # Stimulus UI omitted for brevity
                ),
                shiny::div(
                  shiny::h3(ui_labels$select_answer %||% "Select your answer:", class = "text-base font-medium mb-3"),
                  shiny::div(class = "grid grid-cols-2 gap-3",
                    lapply(1:4, function(i) {
                      option_text <- current_item_data[[paste0("Option", i)]] %||% ""
                      shiny::actionButton(paste0("option_", i), label = shiny::div(
                        shiny::span(class = "w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center text-base font-medium mr-3", LETTERS[i]),
                        option_text
                      ), class = "btn-option h-12 text-left justify-start w-full border border-gray-300 bg-white text-black hover:bg-gray-100 text-base")
                    })
                  )
                )
                # Feedback and analysis indicator omitted for brevity
              )
            )
          )
        ),
        shiny::conditionalPanel(
          condition = "input.phase == 'results'",
          shiny::div(class = "min-h-screen bg-white text-black p-4",
            shiny::div(class = "max-w-7xl mx-auto",
              shiny::div(class = "text-center mb-8",
                shiny::div(class = "flex items-center justify-center mb-4",
                  shiny::icon("check-circle", class = "w-16 h-16 text-black")
                ),
                shiny::h1(ui_labels$assessment_complete %||% "Assessment Complete", class = "text-2xl font-bold mb-2"),
                shiny::p(ui_labels$analysis_completed %||% "Advanced psychometric analysis completed with domain-specific reporting", class = "text-gray-500"),
                shiny::div(class = "mt-4 flex justify-center gap-4",
                  shiny::actionButton("restart_assessment", label = list(shiny::icon("refresh-cw", class = "w-4 h-4 mr-2"), ui_labels$restart_button), class = "btn-klee"),
                  shiny::downloadButton("download_report", label = list(shiny::icon("download", class = "w-4 h-4 mr-2"), ui_labels$save_button), class = "btn-klee")
                )
              ),
              # Analysis summary cards omitted for brevity
              shiny::div(class = "flex justify-center gap-4 mt-8",
                shiny::actionButton("return_dashboard", ui_labels$return_dashboard %||% "Return to Dashboard", class = "btn-klee"),
                shiny::actionButton("view_backend", ui_labels$view_backend %||% "View Analysis Backend", class = "btn-klee")
              )
            )
          )
        )
      )
    )
  )
}

# Use the generate_theme_css function from themes.R instead of duplicating it here