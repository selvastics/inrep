#' Complete Unified UI Function - All Aspects in One
#' 
#' Ultimate single function that handles all UI aspects for adaptive testing
#' Includes themes, accessibility, responsive design, demographics, assessment items,
#' progress tracking, and complete study flow in one comprehensive function
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
  
  # Get theme CSS
  css <- get_theme_css(config$theme)
  
  # Calculate progress
  total_items <- nrow(item_bank)
  progress_percent <- min(100, (current_item / config$max_items) * 100)
  
  # Current item data
  current_item_data <- if(current_item <= nrow(item_bank)) {
    item_bank[current_item, ]
  } else {
    item_bank[nrow(item_bank), ]
  }
  
  # Build complete UI
  shiny::fluidPage(
    # Head section with CSS and meta tags
    shiny::tags$head(
      shiny::tags$style(type = "text/css", css),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      shiny::tags$link(href = "https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap", rel = "stylesheet"),
      shiny::tags$script(shiny::HTML("
        // Enhanced accessibility and interaction
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
            opt.classList.remove('selected');
            opt.setAttribute('aria-selected', 'false');
          });
          element.classList.add('selected');
          element.setAttribute('aria-selected', 'true');
        }
      "))
    ),
    
    # Main container
    shiny::div(class = "study-container",
      # Header
      shiny::div(class = "study-header",
        shiny::h1(config$name, class = "study-title"),
        shiny::p(config$subtitle %||% "Psychological Assessment", class = "study-subtitle"),
        shiny::div(class = "progress-container",
          shiny::div(class = "progress-bar", 
                    style = paste0("width: ", progress_percent, "%"),
                    `aria-valuenow` = progress_percent,
                    `aria-valuemin` = "0",
                    `aria-valuemax` = "100",
                    role = "progressbar",
                    `aria-label` = paste("Progress:", progress_percent, "percent"))
        )
      ),
      
      # Content area based on phase
      shiny::div(class = "study-content",
        
        # Introduction Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'introduction'",
          shiny::div(class = "phase-container introduction",
            shiny::h2("Welcome to the Assessment", class = "phase-title"),
            shiny::div(class = "phase-content",
              shiny::p("This assessment will help us understand your psychological profile through a series of carefully designed questions."),
              shiny::p("The assessment typically takes 10-15 minutes to complete."),
              shiny::p("All responses are confidential and will be used for research purposes only.")
            ),
            shiny::actionButton("start_introduction", "Begin Introduction", class = "btn-primary")
          )
        ),
        
        # Demographics Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'demographics'",
          shiny::div(class = "phase-container demographics",
            shiny::h2("Demographic Information", class = "phase-title"),
            shiny::div(class = "phase-content",
              shiny::p("Please provide some basic information about yourself. All questions are optional."),
              
              # Dynamic demographics
              shiny::div(class = "demographics-form",
                lapply(seq_along(config$demographics), function(i) {
                  demo <- config$demographics[i]
                  shiny::div(class = "form-group",
                    shiny::tags$label(demo, class = "form-label"),
                    shiny::selectInput(
                      inputId = paste0("demo_", i),
                      label = NULL,
                      choices = c("Select" = "", "Male", "Female", "Other", "Prefer not to say"),
                      width = "100%"
                    )
                  )
                })
              ),
              
              shiny::actionButton("start_assessment", "Start Assessment", class = "btn-primary")
            )
          )
        ),
        
        # Assessment Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'assessment'",
          shiny::div(class = "phase-container assessment",
            shiny::div(class = "item-display",
              shiny::div(class = "item-counter",
                shiny::span(paste("Item", current_item, "of", config$max_items))
              ),
              shiny::div(class = "item-text",
                shiny::HTML(current_item_data$text %||% "Loading question...")
              )
            ),
            
            # Response options
            shiny::div(class = "response-container",
              shiny::div(class = "response-options",
                shiny::radioGroupButtons(
                  inputId = "item_response",
                  label = NULL,
                  choices = c(
                    "Strongly Disagree" = 1,
                    "Disagree" = 2,
                    "Neutral" = 3,
                    "Agree" = 4,
                    "Strongly Agree" = 5
                  ),
                  selected = character(0),
                  direction = "vertical",
                  status = "default",
                  individual = TRUE,
                  width = "100%"
                )
              ),
              
              shiny::div(class = "navigation-buttons",
                shiny::actionButton("prev_item", "Previous", class = "btn-secondary"),
                shiny::actionButton("next_item", "Next", class = "btn-primary")
              )
            )
          )
        ),
        
        # Results Phase
        shiny::conditionalPanel(
          condition = "input.phase == 'results'",
          shiny::div(class = "phase-container results",
            shiny::h2("Assessment Complete", class = "phase-title"),
            shiny::div(class = "phase-content",
              shiny::p("Thank you for completing the assessment!"),
              
              shiny::div(class = "results-summary",
                shiny::h3("Your Results"),
                shiny::div(class = "result-item",
                  shiny::strong("Trait Score:"),
                  shiny::span("0.5", class = "score-value")
                ),
                shiny::div(class = "result-item",
                  shiny::strong("Measurement Precision:"),
                  shiny::span("High", class = "precision-value")
                ),
                shiny::div(class = "result-item",
                  shiny::strong("Items Completed:"),
                  shiny::span(current_item, class = "items-value")
                )
              ),
              
              shiny::div(class = "results-actions",
                shiny::downloadButton("download_results", "Download Report", class = "btn-success"),
                shiny::actionButton("restart_assessment", "Take Another Assessment", class = "btn-secondary")
              )
            )
          )
        )
      ),
      
      # Footer
      shiny::div(class = "study-footer",
        shiny::p("Powered by INREP - Instant Reports for Adaptive Testing"),
        shiny::p("© 2024 Research Platform")
      )
    ),
    
    # Additional CSS for complete styling
    shiny::tags$style(shiny::HTML("
      :root {
        --primary-color: #2563eb;
        --background-color: #ffffff;
        --text-color: #1a1a1a;
        --border-color: #e5e7eb;
        --success-color: #10b981;
        --warning-color: #f59e0b;
        --error-color: #ef4444;
        --shadow: 0 4px 12px rgba(0,0,0,0.1);
        --border-radius: 0.5rem;
      }
      
      * {
        box-sizing: border-box;
      }
      
      body {
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        background: var(--background-color);
        color: var(--text-color);
        line-height: 1.6;
        margin: 0;
        padding: 1rem;
        min-height: 100vh;
      }
      
      .study-container {
        max-width: 800px;
        margin: 0 auto;
        padding: 1rem;
      }
      
      .study-header {
        text-align: center;
        margin-bottom: 2rem;
      }
      
      .study-title {
        font-size: 2rem;
        font-weight: 700;
        margin-bottom: 0.5rem;
        color: var(--text-color);
      }
      
      .study-subtitle {
        font-size: 1.2rem;
        color: #6b7280;
        margin-bottom: 1rem;
      }
      
      .progress-container {
        background: var(--border-color);
        height: 0.5rem;
        border-radius: var(--border-radius);
        overflow: hidden;
        margin: 1rem 0;
      }
      
      .progress-bar {
        background: var(--primary-color);
        height: 100%;
        transition: width 0.3s ease;
      }
      
      .study-content {
        margin: 2rem 0;
      }
      
      .phase-container {
        background: white;
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius);
        padding: 2rem;
        box-shadow: var(--shadow);
        margin: 1rem 0;
      }
      
      .phase-title {
        font-size: 1.5rem;
        font-weight: 600;
        margin-bottom: 1rem;
        color: var(--text-color);
      }
      
      .phase-content {
        margin-bottom: 2rem;
      }
      
      .phase-content p {
        margin-bottom: 1rem;
        font-size: 1.1rem;
      }
      
      .demographics-form {
        display: grid;
        gap: 1rem;
      }
      
      .form-group {
        margin-bottom: 1rem;
      }
      
      .form-label {
        display: block;
        font-weight: 500;
        margin-bottom: 0.5rem;
      }
      
      .item-display {
        margin-bottom: 2rem;
      }
      
      .item-counter {
        font-size: 0.9rem;
        color: #6b7280;
        margin-bottom: 1rem;
      }
      
      .item-text {
        font-size: 1.3rem;
        font-weight: 500;
        margin-bottom: 2rem;
        text-align: center;
      }
      
      .response-container {
        margin: 2rem 0;
      }
      
      .response-options {
        margin: 2rem 0;
      }
      
      .navigation-buttons {
        display: flex;
        gap: 1rem;
        justify-content: center;
        margin-top: 2rem;
      }
      
      .btn-primary, .btn-secondary, .btn-success {
        padding: 0.75rem 1.5rem;
        border: none;
        border-radius: var(--border-radius);
        font-size: 1rem;
        cursor: pointer;
        transition: all 0.2s ease;
        min-width: 120px;
      }
      
      .btn-primary {
        background: var(--primary-color);
        color: white;
      }
      
      .btn-secondary {
        background: #6b7280;
        color: white;
      }
      
      .btn-success {
        background: var(--success-color);
        color: white;
      }
      
      .btn-primary:hover, .btn-secondary:hover, .btn-success:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 20px rgba(0,0,0,0.15);
      }
      
      .results-summary {
        background: #f9fafb;
        border: 1px solid var(--border-color);
        border-radius: var(--border-radius);
        padding: 1.5rem;
        margin: 1rem 0;
      }
      
      .result-item {
        display: flex;
        justify-content: space-between;
        padding: 0.5rem 0;
        border-bottom: 1px solid var(--border-color);
      }
      
      .result-item:last-child {
        border-bottom: none;
      }
      
      .study-footer {
        text-align: center;
        margin-top: 3rem;
        padding: 2rem;
        border-top: 1px solid var(--border-color);
        color: #6b7280;
      }
      
      @media (max-width: 768px) {
        .study-container {
          padding: 0.5rem;
        }
        
        .study-title {
          font-size: 1.5rem;
        }
        
        .phase-container {
          padding: 1.5rem;
        }
        
        .navigation-buttons {
          flex-direction: column;
        }
        
        .btn-primary, .btn-secondary, .btn-success {
          width: 100%;
        }
      }
      
      @media (prefers-reduced-motion: reduce) {
        * {
          transition: none !important;
        }
      }
      
      @media (prefers-contrast: high) {
        .phase-container {
          border-width: 2px;
        }
      }
    "))
  )
}

#' Get Theme CSS
#' @param theme Theme name
#' @return CSS string
#' @export
get_theme_css <- function(theme = "light") {
  theme <- tolower(theme)
  
  # Theme definitions
  themes <- list(
    light = list(bg = "#fff", text = "#000", accent = "#2563eb", border = "#e5e7eb", font = "16px", button = "60px"),
    dark = list(bg = "#0f172a", text = "#f1f5f9", accent = "#3b82f6", border = "#334155", font = "16px", button = "60px"),
    professional = list(bg = "#fafafa", text = "#262626", accent = "#0f172a", border = "#e5e5e5", font = "16px", button = "60px"),
    academic = list(bg = "#fefbf3", text = "#2c1810", accent = "#8b4513", border = "#d4c5b9", font = "16px", button = "60px"),
    forest = list(bg = "#f0f9f0", text = "#1a3a1a", accent = "#228b22", border = "#c8e6c9", font = "16px", button = "60px"),
    ocean = list(bg = "#f0f8ff", text = "#0c2340", accent = "#0066cc", border = "#b3d9ff", font = "16px", button = "60px"),
    sunset = list(bg = "#fff5f5", text = "#742a2a", accent = "#e53e3e", border = "#fed7d7", font = "16px", button = "60px"),
    midnight = list(bg = "#0a0a0a", text = "#e5e5e5", accent = "#6366f1", border = "#262626", font = "16px", button = "60px"),
    berry = list(bg = "#fdf2f8", text = "#831843", accent = "#ec4899", border = "#fbcfe8", font = "16px", button = "60px"),
    paper = list(bg = "#fefefe", text = "#171717", accent = "#525252", border = "#e5e5e5", font = "16px", button = "60px"),
    monochrome = list(bg = "#fafafa", text = "#18181b", accent = "#18181b", border = "#e4e4e7", font = "16px", button = "60px"),
    vibrant = list(bg = "#fef3c7", text = "#92400e", accent = "#f59e0b", border = "#fcd34d", font = "16px", button = "60px"),
    hildesheim = list(bg = "#f8fafc", text = "#0f172a", accent = "#1e40af", border = "#e2e8f0", font = "16px", button = "60px"),
    darkblue = list(bg = "#0f172a", text = "#f8fafc", accent = "#3b82f6", border = "#334155", font = "16px", button = "60px"),
    
    # Accessibility themes
    "colorblind-safe" = list(bg = "#ffffff", text = "#000000", accent = "#0066cc", border = "#666666", font = "18px", button = "65px"),
    "large-text" = list(bg = "#ffffff", text = "#000000", accent = "#0000ff", border = "#000000", font = "24px", button = "80px"),
    "dyslexia-friendly" = list(bg = "#f8f4f0", text = "#2c2c2c", accent = "#005a9c", border = "#8d8d8d", font = "20px", button = "65px"),
    "low-vision" = list(bg = "#ffffff", text = "#000000", accent = "#0000ff", border = "#000000", font = "28px", button = "100px"),
    "cognitive-accessible" = list(bg = "#fffef7", text = "#1a1a1a", accent = "#1976d2", border = "#757575", font = "22px", button = "75px")
  )
  
  # Default to light if theme not found
  if (!theme %in% names(themes)) theme <- "light"
  vars <- themes[[theme]]
  
  # Ultra-efficient CSS (<200 lines)
  sprintf('
:root {
  --bg: %s; --text: %s; --accent: %s; --border: %s; --card: %s;
  --font-size: %s; --button-size: %s; --radius: 0.5rem; --shadow: 0 4px 12px rgba(0,0,0,0.1);
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background: var(--bg); color: var(--text); font-size: var(--font-size);
  line-height: 1.6; padding: 1rem; min-height: 100vh;
}

.container { max-width: 800px; margin: 0 auto; padding: 1rem; }

.assessment-card {
  background: var(--card); border: 2px solid var(--border);
  border-radius: var(--radius); padding: 2rem; margin: 1rem 0;
  box-shadow: var(--shadow); transition: all 0.2s ease;
}

.btn {
  background: var(--accent); color: white; border: none;
  padding: 1rem 2rem; border-radius: var(--radius);
  font-size: 1.2rem; cursor: pointer; min-height: var(--button-size);
  transition: all 0.2s ease; width: 100%%; max-width: 300px;
}

.btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.15); }

.question {
  font-size: 1.3rem; margin: 2rem 0; text-align: center;
  line-height: 1.5; font-weight: 500;
}

.radio-group {
  display: flex; flex-direction: column; gap: 1rem; margin: 2rem 0;
}

.radio-option {
  padding: 1.5rem; border: 2px solid var(--border);
  border-radius: var(--radius); cursor: pointer;
  transition: all 0.2s ease; text-align: center;
}

.radio-option:hover { border-color: var(--accent); }

.radio-option.active {
  background: var(--accent); color: white; border-color: var(--accent);
}

.progress {
  background: var(--border); height: 0.5rem; border-radius: var(--radius);
  overflow: hidden; margin: 2rem 0;
}

.progress-bar {
  background: var(--accent); height: 100%%; transition: width 0.3s ease;
}

@media (max-width: 768px) {
  .btn { font-size: 1.1rem; padding: 0.8rem 1.5rem; }
  .assessment-card { padding: 1.5rem; }
}

@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}

@media (prefers-contrast: high) {
  .assessment-card { border-width: 3px; }
}
', vars$bg, vars$text, vars$accent, vars$border, vars$card, vars$font, vars$button)
}
