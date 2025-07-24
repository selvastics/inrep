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
  if (is.null(config$name)) config$name <- "Assessment"
  if (is.null(config$theme)) config$theme <- "professional"
  if (is.null(config$demographics)) config$demographics <- character(0)
  if (is.null(config$max_items)) config$max_items <- nrow(item_bank)
  
  # Calculate progress
  total_items <- nrow(item_bank)
  progress_percent <- min(100, round((current_item / config$max_items) * 100, 1))
  
  # Current item data
  current_item_data <- if (current_item <= nrow(item_bank) && current_item > 0) {
    item_bank[current_item, ]
  } else {
    list(text = "Loading question...", ResponseCategories = "1,2,3,4,5")
  }
  
  # Language labels
  labels <- list(
    en = list(
      intro_title = "Welcome to the Assessment",
      intro_text = "This assessment will help us understand your profile through carefully designed questions.",
      demo_title = "Demographic Information",
      demo_text = "Please provide some basic information about yourself. All questions are optional.",
      assessment_title = "Assessment",
      results_title = "Assessment Complete",
      start_button = "Begin Assessment",
      submit_button = "Submit",
      prev_button = "Previous",
      next_button = "Next",
      download_button = "Download Report",
      restart_button = "Restart Assessment"
    ),
    de = list(
      intro_title = "Willkommen zur Bewertung",
      intro_text = "Diese Bewertung hilft uns, Ihr Profil durch sorgfältig gestaltete Fragen zu verstehen.",
      demo_title = "Demografische Informationen",
      demo_text = "Bitte geben Sie einige grundlegende Informationen über sich selbst ein. Alle Fragen sind optional.",
      assessment_title = "Bewertung",
      results_title = "Bewertung abgeschlossen",
      start_button = "Bewertung beginnen",
      submit_button = "Absenden",
      prev_button = "Zurück",
      next_button = "Weiter",
      download_button = "Bericht herunterladen",
      restart_button = "Bewertung neu starten"
    )
  )
  ui_labels <- labels[[config$language %||% "en"]]
  
  # Build complete UI
  shiny::fluidPage(
    shinyjs::useShinyjs(),
    # Head section with Tailwind CSS and custom styles
    shiny::tags$head(
      shiny::tags$link(rel = "stylesheet", href = "https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css"),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      shiny::tags$style(type = "text/css", get_theme_css(config$theme)),
      shiny::tags$script(shiny::HTML("
        // Enhanced accessibility
        document.addEventListener('keydown', function(e) {
          if (e.key === 'Tab') {
            document.body.classList.add('keyboard-nav');
          }
        });
        // Progress animation
        function updateProgress(percent) {
          const progressBar = document.querySelector('.progress-bar');
          if (progressBar) {
            progressBar.style.width = percent + '%';
            progressBar.setAttribute('aria-valuenow', percent);
          }
        }
        // Response selection
        function selectResponse(element) {
          document.querySelectorAll('.response-option').forEach(opt => {
            opt.classList.remove('bg-blue-100', 'border-blue-500');
            opt.setAttribute('aria-selected', 'false');
          });
          element.classList.add('bg-blue-100', 'border-blue-500');
          element.setAttribute('aria-selected', 'true');
          element.focus();
        }
      "))
    ),
    
    # Main container
    shiny::div(class = "container mx-auto px-4 sm:px-6 lg:px-8 max-w-4xl",
      `data-theme` = config$theme,
      `aria-live` = "polite",
      
      # Header
      shiny::div(class = "study-header text-center mb-8",
        shiny::h1(class = "text-3xl sm:text-4xl font-bold text-gray-900 dark:text-white", 
                 config$name, 
                 role = "heading", 
                 `aria-level` = "1"),
        shiny::p(class = "text-lg text-gray-600 dark:text-gray-300 mt-2", 
                config$subtitle %||% "Psychological Assessment"),
        shiny::div(class = "progress-container mt-4 bg-gray-200 dark:bg-gray-700 rounded-full h-2 overflow-hidden",
          shiny::div(class = "progress-bar bg-blue-600 dark:bg-blue-400 h-full transition-all duration-300 ease-in-out",
                    style = sprintf("width: %s%%", progress_percent),
                    `aria-valuenow` = progress_percent,
                    `aria-valuemin` = "0",
                    `aria-valuemax` = "100",
                    role = "progressbar",
                    `aria-label` = sprintf("Progress: %s%%", progress_percent))
        )
      ),
      
      # Content area based on phase
      shiny::div(class = "study-content",
        # Introduction Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'introduction'",
          shiny::div(class = "phase-container bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6 shadow-lg",
            shiny::h2(class = "text-2xl font-semibold text-gray-900 dark:text-white mb-4", 
                     ui_labels$intro_title, 
                     role = "heading", 
                     `aria-level` = "2"),
            shiny::div(class = "phase-content",
              shiny::p(class = "text-gray-700 dark:text-gray-300 mb-4", ui_labels$intro_text),
              shiny::p(class = "text-gray-700 dark:text-gray-300 mb-4", 
                      "The assessment typically takes 10-15 minutes to complete."),
              shiny::p(class = "text-gray-700 dark:text-gray-300", 
                      "All responses are confidential and used for research purposes only.")
            ),
            shiny::actionButton("start_introduction", 
                               ui_labels$start_button, 
                               class = "btn-primary mt-4 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                               `aria-label` = ui_labels$start_button)
          )
        ),
        
        # Demographics Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'demographics'",
          shiny::div(class = "phase-container bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6 shadow-lg",
            shiny::h2(class = "text-2xl font-semibold text-gray-900 dark:text-white mb-4", 
                     ui_labels$demo_title, 
                     role = "heading", 
                     `aria-level` = "2"),
            shiny::div(class = "phase-content",
              shiny::p(class = "text-gray-700 dark:text-gray-300 mb-4", ui_labels$demo_text),
              shiny::div(class = "demographics-form grid gap-4",
                lapply(seq_along(config$demographics), function(i) {
                  demo <- config$demographics[i]
                  input_type <- config$input_types[[demo]] %||% "select"
                  input_id <- paste0("demo_", i)
                  shiny::div(class = "form-group",
                    shiny::tags$label(class = "block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1", 
                                     demo, 
                                     `for` = input_id),
                    switch(input_type,
                           "numeric" = shiny::numericInput(
                             inputId = input_id,
                             label = NULL,
                             value = NA,
                             min = 1,
                             max = 150,
                             width = "100%",
                             `aria-describedby` = paste0(input_id, "_desc")
                           ),
                           "text" = shiny::textInput(
                             inputId = input_id,
                             label = NULL,
                             value = "",
                             width = "100%",
                             `aria-describedby` = paste0(input_id, "_desc")
                           ),
                           shiny::selectInput(
                             inputId = input_id,
                             label = NULL,
                             choices = c("Select" = "", "Male", "Female", "Other", "Prefer not to say"),
                             selected = "",
                             width = "100%",
                             `aria-describedby` = paste0(input_id, "_desc")
                           )
                    ),
                    shiny::div(id = paste0(input_id, "_desc"), 
                              class = "text-sm text-gray-500 dark:text-gray-400", 
                              sprintf("Enter your %s (optional)", demo))
                  )
                })
              ),
              shiny::div(id = "demo_error", 
                        class = "text-red-600 dark:text-red-400 mt-2 hidden", 
                        "Please complete all required fields correctly.")
            ),
            shiny::actionButton("start_assessment", 
                               ui_labels$start_button, 
                               class = "btn-primary mt-4 bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                               `aria-label` = ui_labels$start_button)
          )
        ),
        
        # Assessment Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'assessment'",
          shiny::div(class = "phase-container bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6 shadow-lg",
            shiny::div(class = "item-display",
              shiny::div(class = "item-counter text-gray-600 dark:text-gray-300 text-sm mb-4", 
                        sprintf("Item %d of %d", current_item, config$max_items)),
              shiny::div(class = "item-text text-lg font-medium text-gray-900 dark:text-white text-center mb-6", 
                        shiny::HTML(current_item_data$Question %||% current_item_data$text %||% "Loading question..."),
                        role = "region",
                        `aria-live` = "assertive")
            ),
            shiny::div(class = "response-container",
              shiny::div(class = "response-options grid gap-2",
                {
                  choices <- if (!is.null(current_item_data$ResponseCategories)) {
                    as.numeric(unlist(strsplit(current_item_data$ResponseCategories, ",")))
                  } else {
                    1:5
                  }
                  labels <- switch(config$language %||% "en",
                                   en = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")[1:length(choices)],
                                   de = c("Stark abgelehnt", "Abgelehnt", "Neutral", "Zustimmen", "Stark zustimmen")[1:length(choices)],
                                   es = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo")[1:length(choices)],
                                   fr = c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")[1:length(choices)]
                  )
                  shinyWidgets::radioGroupButtons(
                    inputId = "item_response",
                    label = NULL,
                    choices = stats::setNames(choices, labels),
                    selected = character(0),
                    direction = "vertical",
                    status = "default",
                    individual = TRUE,
                    width = "100%",
                    checkIcon = list(yes = shiny::icon("check-circle"))
                  )
                }
              ),
              shiny::div(id = "response_error", 
                        class = "text-red-600 dark:text-red-400 mt-2 hidden", 
                        "Please select a response."),
              shiny::div(class = "navigation-buttons flex gap-4 justify-center mt-6",
                shiny::actionButton("prev_item", 
                                   ui_labels$prev_button, 
                                   class = "btn-secondary bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                                   `aria-label` = ui_labels$prev_button),
                shiny::actionButton("next_item", 
                                   ui_labels$next_button, 
                                   class = "btn-primary bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                                   `aria-label` = ui_labels$next_button)
              )
            )
          )
        ),
        
        # Results Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'results'",
          shiny::div(class = "phase-container bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg p-6 shadow-lg",
            shiny::h2(class = "text-2xl font-semibold text-gray-900 dark:text-white mb-4", 
                     ui_labels$results_title, 
                     role = "heading", 
                     `aria-level` = "2"),
            shiny::div(class = "phase-content",
              shiny::p(class = "text-gray-700 dark:text-gray-300 mb-4", 
                      "Thank you for completing the assessment!"),
              shiny::div(class = "results-summary bg-gray-50 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg p-4",
                shiny::h3(class = "text-xl font-medium text-gray-900 dark:text-white mb-4", "Your Results"),
                shiny::div(class = "result-item flex justify-between py-2 border-b border-gray-200 dark:border-gray-600",
                  shiny::strong(class = "text-gray-700 dark:text-gray-300", "Trait Score:"),
                  shiny::span(class = "score-value text-gray-900 dark:text-white font-medium", 
                             sprintf("%.2f", mean(responses, na.rm = TRUE)))
                ),
                shiny::div(class = "result-item flex justify-between py-2 border-b border-gray-200 dark:border-gray-600",
                  shiny::strong(class = "text-gray-700 dark:text-gray-300", "Measurement Precision:"),
                  shiny::span(class = "precision-value text-gray-900 dark:text-white font-medium", 
                             if (config$adaptive) sprintf("SE: %.3f", sd(responses, na.rm = TRUE)) else "High")
                ),
                shiny::div(class = "result-item flex justify-between py-2",
                  shiny::strong(class = "text-gray-700 dark:text-gray-300", "Items Completed:"),
                  shiny::span(class = "items-value text-gray-900 dark:text-white font-medium", 
                             length(responses))
                )
              ),
              shiny::div(class = "results-actions flex gap-4 justify-center mt-6",
                shiny::downloadButton("download_results", 
                                     ui_labels$download_button, 
                                     class = "btn-success bg-green-600 hover:bg-green-700 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                                     `aria-label` = ui_labels$download_button),
                shiny::actionButton("restart_assessment", 
                                   ui_labels$restart_button, 
                                   class = "btn-secondary bg-gray-500 hover:bg-gray-600 text-white font-medium py-2 px-4 rounded-lg transition-transform hover:-translate-y-1 hover:shadow-lg",
                                   `aria-label` = ui_labels$restart_button)
              )
            )
          )
        )
      ),
      
      # Footer
      shiny::div(class = "study-footer text-center mt-8 py-4 border-t border-gray-200 dark:border-gray-700 text-gray-600 dark:text-gray-300",
        shiny::p("Powered by INREP - Instant Reports for Adaptive Testing"),
        shiny::p(sprintf("© %s Research Platform", format(Sys.time(), "%Y")))
      )
    )
  )
}

#' Get Theme CSS
#' @param theme Theme name
#' @return CSS string
#' @export
get_theme_css <- function(theme = "professional") {
  theme <- tolower(theme)
  
  # Theme definitions
  themes <- list(
    professional = list(bg = "#fafafa", text = "#262626", accent = "#0f172a", border = "#e5e5e5", font = "16px", button = "48px"),
    light = list(bg = "#ffffff", text = "#000000", accent = "#2563eb", border = "#e5e7eb", font = "16px", button = "48px"),
    dark = list(bg = "#0f172a", text = "#f1f5f9", accent = "#3b82f6", border = "#334155", font = "16px", button = "48px"),
    forest = list(bg = "#f0f9f0", text = "#1a3a1a", accent = "#228b22", border = "#c8e6c9", font = "16px", button = "48px"),
    ocean = list(bg = "#f0f8ff", text = "#0c2340", accent = "#0066cc", border = "#b3d9ff", font = "16px", button = "48px"),
    sunset = list(bg = "#fff5f5", text = "#742a2a", accent = "#e53e3e", border = "#fed7d7", font = "16px", button = "48px"),
    midnight = list(bg = "#0a0a0a", text = "#e5e5e5", accent = "#6366f1", border = "#262626", font = "16px", button = "48px"),
    berry = list(bg = "#fdf2f8", text = "#831843", accent = "#ec4899", border = "#fbcfe8", font = "16px", button = "48px"),
    colorblind-safe = list(bg = "#ffffff", text = "#000000", accent = "#0066cc", border = "#666666", font = "18px", button = "52px"),
    large-text = list(bg = "#ffffff", text = "#000000", accent = "#0000ff", border = "#000000", font = "24px", button = "60px"),
    dyslexia-friendly = list(bg = "#f8f4f0", text = "#2c2c2c", accent = "#005a9c", border = "#8d8d8d", font = "20px", button = "56px"),
    low-vision = list(bg = "#ffffff", text = "#000000", accent = "#0000ff", border = "#000000", font = "28px", button = "64px"),
    cognitive-accessible = list(bg = "#fffef7", text = "#1a1a1a", accent = "#1976d2", border = "#757575", font = "22px", button = "60px")
  )
  
  # Default to professional if theme not found
  if (!theme %in% names(themes)) theme <- "professional"
  vars <- themes[[theme]]
  
  # CSS with Tailwind overrides and accessibility enhancements
  sprintf('
:root {
  --bg: %s;
  --text: %s;
  --accent: %s;
  --border: %s;
  --font-size: %s;
  --button-height: %s;
  --shadow: 0 4px 12px rgba(0,0,0,0.1);
}

body {
  font-family: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  font-size: var(--font-size);
  line-height: 1.6;
}

.phase-container {
  transition: all 0.3s ease;
}

.btn-primary, .btn-secondary, .btn-success {
  min-height: var(--button-height);
  width: 100%%;
  max-width: 200px;
}

.radio-group-buttons .btn {
  border: 2px solid var(--border);
  border-radius: 0.5rem;
  padding: 0.75rem;
  text-align: left;
  width: 100%%;
  transition: all 0.2s ease;
}

.radio-group-buttons .btn:hover {
  border-color: var(--accent);
  background-color: rgba(37, 99, 235, 0.1);
}

.radio-group-buttons .btn.active {
  background-color: var(--accent);
  color: white;
  border-color: var(--accent);
}

.keyboard-nav .radio-group-buttons .btn:focus {
  outline: 3px solid var(--accent);
  outline-offset: 2px;
}

@media (max-width: 640px) {
  body { font-size: calc(var(--font-size) * 0.9); }
  .phase-container { padding: 1rem; }
  .btn-primary, .btn-secondary, .btn-success { max-width: 100%%; }
}

@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}

@media (prefers-contrast: high) {
  .phase-container { border-width: 3px; }
  .radio-group-buttons .btn { border-width: 3px; }
  :root {
    --text: #000000;
    --accent: #0000ff;
    --border: #000000;
  }
}
', vars$bg, vars$text, vars$accent, vars$border, vars$font, vars$button)
}