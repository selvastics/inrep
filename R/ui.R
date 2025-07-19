
#' Create Shiny UI
#'
#' Creates the Shiny UI for the adaptive testing application.
#'
#' @param config Study configuration object.
#' @param custom_css Optional CSS string.
#' @return Shiny UI object.
#' @keywords internal
create_ui <- function(config, custom_css = NULL) {
  ui_labels <- load_translations(config$language)
  if (is.null(custom_css)) {
    custom_css <- "
      body {
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
        background-color: #f8f9fa;
        color: #212529;
        margin: 0;
        padding: 0;
        line-height: 1.6;
      }
      .container-fluid {
        max-width: 900px;
        margin: 0 auto;
        padding: 2rem;
        display: flex;
        flex-direction: column;
        align-items: center;
      }
      .section-title {
        font-size: 2rem;
        font-weight: 700;
        color: #212529;
        text-align: center;
        margin: 2rem 0;
      }
      .assessment-card {
        background: #ffffff;
        border: 1px solid #dee2e6;
        border-radius: 12px;
        padding: 2rem;
        margin-bottom: 2rem;
        width: 100%;
        max-width: 800px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
      }
      .card-header {
        font-size: 1.5rem;
        font-weight: 600;
        color: #212529;
        text-align: center;
        margin-bottom: 1.5rem;
      }
      .welcome-text {
        font-size: 1.1rem;
        color: #495057;
        text-align: center;
        margin-bottom: 2rem;
      }
      .test-question {
        font-size: 1.2rem;
        font-weight: 400;
        color: #212529;
        text-align: center;
        margin: 1.5rem 0;
      }
      .btn-klee {
        background: #212529;
        color: #ffffff;
        border: none;
        padding: 0.75rem 2rem;
        font-size: 1.1rem;
        font-weight: 500;
        border-radius: 8px;
        cursor: pointer;
        transition: background-color 0.3s ease, transform 0.1s ease;
      }
      .btn-klee:hover {
        background-color: #343a40;
        transform: translateY(-1px);
      }
      .progress-circle {
        width: 100px;
        height: 100px;
        margin: 2rem auto;
        position: relative;
      }
      .progress-circle svg {
        transform: rotate(-90deg);
      }
      .progress-circle circle {
        fill: none;
        stroke: #dee2e6;
        stroke-width: 10;
      }
      .progress-circle .progress {
        stroke: #212529;
        stroke-linecap: round;
        transition: stroke-dashoffset 0.5s ease;
      }
      .progress-circle span {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        color: #212529;
        font-weight: 600;
        font-size: 1.2rem;
      }
      .error-message {
        color: #dc3545;
        background-color: #f8d7da;
        text-align: center;
        margin: 1rem 0;
        font-weight: 500;
        border: 1px solid #dc3545;
        padding: 0.75rem;
        border-radius: 8px;
      }
      .feedback-message {
        color: #28a745;
        background-color: #d4edda;
        text-align: center;
        margin: 1rem 0;
        font-weight: 500;
        padding: 0.75rem;
        border-radius: 8px;
      }
      .radio-group-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 0.75rem;
        margin: 1.5rem 0;
      }
      .btn-radio {
        border: 1px solid #dee2e6;
        background: #ffffff;
        color: #212529;
        padding: 0.75rem;
        border-radius: 8px;
        width: 100%;
        max-width: 600px;
        transition: background-color 0.2s ease, border-color 0.2s ease;
      }
      .btn-radio:hover {
        background: #f1f3f5;
        border-color: #adb5bd;
      }
      .btn-radio.active {
        border-color: #212529;
        background: #e9ecef;
      }
      .slider-container {
        width: 100%;
        max-width: 600px;
        margin: 1.5rem auto;
      }
      .results-section {
        margin: 2rem 0;
      }
      .results-title {
        font-size: 1.25rem;
        font-weight: 600;
        color: #212529;
      }
      .dimension-score {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
      .dimension-title {
        display: flex;
        justify-content: space-between;
        font-size: 1.1rem;
        font-weight: 500;
      }
      .dimension-value {
        color: #212529;
      }
      .dimension-bar {
        background: #dee2e6;
        height: 10px;
        border-radius: 5px;
      }
      .dimension-fill {
        background: #212529;
        height: 100%;
        border-radius: 5px;
        transition: width 0.5s ease;
      }
      .recommendation-list {
        list-style-type: disc;
        margin-left: 1.5rem;
        font-size: 1rem;
      }
      .footer {
        text-align: center;
        font-size: 0.9rem;
        color: #495057;
        margin-top: 2rem;
      }
      .btn-klee:focus, .btn-radio:focus {
        outline: 2px solid #212529;
        outline-offset: 2px;
      }
      .input-label {
        font-size: 1rem;
        font-weight: 500;
        color: #212529;
        margin-bottom: 0.5rem;
      }
      .form-control {
        border-radius: 8px;
        border: 1px solid #dee2e6;
        padding: 0.75rem;
        font-size: 1rem;
      }
      .loading-spinner {
        display: flex;
        justify-content: center;
        align-items: center;
        margin: 2rem 0;
      }
      @media (max-width: 768px) {
        .container-fluid { padding: 1.5rem; }
        .section-title { font-size: 1.75rem; }
        .assessment-card { padding: 1.5rem; }
        .test-question { font-size: 1.1rem; }
        .btn-klee { width: 100%; }
        .btn-radio { max-width: 100%; }
      }
      @media (max-width: 480px) {
        .section-title { font-size: 1.5rem; }
        .assessment-card { padding: 1rem; }
        .test-question { font-size: 1rem; }
        .progress-circle { width: 80px; height: 80px; }
        .progress-circle span { font-size: 1rem; }
      }
    "
  }
  
  fluidPage(
    shinyjs::useShinyjs(),
    tags$head(
      tags$style(type = "text/css", custom_css),
      tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet")
    ),
    div(class = "container-fluid",
        role = "main",
        if (!is.null(config$custom_ui_pre)) config$custom_ui_pre,
        h2(config$name, class = "section-title", role = "heading", `aria-level` = "1"),
        shinycssloaders::withSpinner(uiOutput("study_ui"), type = 6)
    )
  )
}

#' Load UI Translations
#'
#' Loads translations from a JSON file for the specified language.
#'
#' @param language Language code ("en", "de", "es", "fr").
#' @return List of UI labels.
#' @keywords internal
load_translations <- function(language) {
  translation_file <- system.file("shiny", "translations.json", package = "inrep")
  if (!file.exists(translation_file)) {
    print("Translation file not found, using default English labels")
    return(list(
      demo_title = "Demographic Information",
      welcome_text = "Please provide your demographic details to begin the assessment.",
      start_button = "Start Assessment",
      submit_button = "Submit",
      results_title = "Assessment Results",
      save_button = "Download Report",
      restart_button = "Restart",
      restart_confirm = "Are you sure you want to restart the test? All progress will be lost.",
      proficiency = "Trait Score",
      precision = "Measurement Precision",
      items_administered = "Items Completed",
      recommendations = "Recommendations",
      feedback_correct = "Correct",
      feedback_incorrect = "Incorrect",
      timeout_message = "Session timed out. Please restart.",
      demo_error = "Please complete all required fields.",
      age_error = "Please enter a valid age (1-150)."
    ))
  }
  translations <- jsonlite::fromJSON(translation_file)
  translations[[language]] %||% translations[["en"]]
}
