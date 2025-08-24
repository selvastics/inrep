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
            shiny::actionButton("download_results", "Download Results", 
              class = "bg-blue-500 hover:bg-blue-700 text-white font-bold py-3 px-6 rounded-lg text-lg")
          )
        )
        
      )
    )
  )
}

