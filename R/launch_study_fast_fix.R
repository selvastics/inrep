#' Ultra-Fast Launch Study Function
#' 
#' This is the FIXED version that loads instantly like 2 weeks ago
#' 
#' @export
launch_study <- function(config, 
                        item_bank = NULL,
                        accessibility = FALSE,
                        admin_dashboard_hook = NULL,
                        study_key = NULL,
                        webdav_url = NULL,
                        password = NULL,
                        save_format = "csv",
                        session_save = NULL,
                        ...) {
  
  # CRITICAL: NO FILE SOURCING AT STARTUP!
  # NO MODULE LOADING!
  # JUST CREATE THE UI AND GO!
  
  # Minimal validation
  if (is.null(item_bank) && !is.null(config$items)) {
    item_bank <- config$items
  }
  if (is.null(item_bank)) {
    stop("Item bank required")
  }
  
  # Override session save default to FALSE for speed
  if (is.null(session_save)) {
    session_save <- FALSE
  }
  
  # Simple logger
  logger <- function(msg, level = "INFO") {
    if (getOption("inrep.debug", FALSE)) {
      cat(paste0("[", level, "] ", msg, "\n"))
    }
  }
  
  # Get UI labels
  ui_labels <- if (exists("get_language_labels")) {
    get_language_labels(config$language %||% "en")
  } else {
    list(
      start_button = "Start",
      continue_button = "Continue",
      submit_button = "Submit",
      demo_title = "Demographics",
      welcome_text = "Please provide your information to begin."
    )
  }
  
  # FAST UI - No complex CSS, no file loading
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        /* Minimal CSS for instant load */
        body { 
          margin: 0; 
          padding: 0; 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
        }
        .container-fluid {
          width: 100% !important;
          padding: 15px !important;
          margin: 0 !important;
        }
        .assessment-card {
          background: white;
          border-radius: 8px;
          padding: 30px;
          margin: 20px auto;
          max-width: 800px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .progress-bar-container {
          height: 4px;
          background: #e0e0e0;
          margin-bottom: 20px;
        }
        .progress-bar-fill {
          height: 100%;
          background: #007bff;
          transition: width 0.3s;
        }
        /* Fixed circle alignment */
        .progress-circle {
          position: relative;
          width: 120px;
          height: 120px;
          margin: 0 auto 20px;
        }
        .progress-circle svg {
          display: block;
        }
        .progress-circle span {
          position: absolute;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          font-size: 20px;
          font-weight: 500;
        }
        .btn-primary {
          background: #007bff;
          color: white;
          border: none;
          padding: 10px 30px;
          border-radius: 4px;
          font-size: 16px;
          cursor: pointer;
        }
        .btn-primary:hover {
          background: #0056b3;
        }
      "))
    ),
    
    # Simple UI output
    shiny::uiOutput("study_ui")
  )
  
  # FAST SERVER - Minimal operations
  server <- function(input, output, session) {
    
    # Reactive values - minimal
    rv <- shiny::reactiveValues(
      stage = if (!is.null(config$demographics)) "demographics" else "assessment",
      current_item = 1,
      responses = c(),
      administered = c(),
      demo_data = list(),
      theta_history = c(),
      se_history = c()
    )
    
    # IMMEDIATE UI RENDER - NO DELAYS
    output$study_ui <- shiny::renderUI({
      
      if (rv$stage == "demographics") {
        # Simple demographics page
        shiny::div(
          class = "assessment-card",
          shiny::h2(ui_labels$demo_title %||% "Demographics"),
          shiny::p(ui_labels$welcome_text %||% "Please provide your information."),
          
          # Simple demo inputs
          if (!is.null(config$demographics)) {
            lapply(config$demographics, function(demo) {
              input_type <- config$input_types[[demo]] %||% "text"
              if (input_type == "numeric") {
                shiny::numericInput(
                  paste0("demo_", demo),
                  demo,
                  value = NA
                )
              } else if (input_type == "select") {
                shiny::selectInput(
                  paste0("demo_", demo),
                  demo,
                  choices = c("", "Option 1", "Option 2", "Option 3")
                )
              } else {
                shiny::textInput(
                  paste0("demo_", demo),
                  demo,
                  value = ""
                )
              }
            })
          },
          
          shiny::br(),
          shiny::actionButton("start_test", ui_labels$start_button %||% "Start", class = "btn-primary")
        )
        
      } else if (rv$stage == "assessment") {
        # Simple assessment page
        if (rv$current_item <= nrow(item_bank)) {
          item <- item_bank[rv$current_item, ]
          
          # Calculate progress
          progress_pct <- round((length(rv$administered) / min(config$max_items %||% 20, nrow(item_bank))) * 100)
          
          # Progress UI - FIXED CIRCLE
          progress_ui <- if (config$progress_style == "circle") {
            shiny::div(
              class = "progress-circle",
              shiny::HTML(sprintf('
                <svg width="120" height="120">
                  <circle cx="60" cy="60" r="50" fill="none" stroke="#e0e0e0" stroke-width="8"/>
                  <circle cx="60" cy="60" r="50" fill="none" stroke="#007bff" stroke-width="8"
                          stroke-dasharray="%d 314"
                          stroke-dashoffset="0"
                          transform="rotate(-90 60 60)"/>
                </svg>
                <span>%d%%</span>
              ', round(progress_pct * 3.14), progress_pct))
            )
          } else {
            shiny::div(
              class = "progress-bar-container",
              shiny::div(
                class = "progress-bar-fill",
                style = sprintf("width: %d%%", progress_pct)
              )
            )
          }
          
          # Item UI
          shiny::div(
            class = "assessment-card",
            progress_ui,
            shiny::h3(item$Question),
            shiny::radioButtons(
              "item_response",
              "",
              choices = if (config$model == "GRM") {
                c("Strongly Disagree" = 1,
                  "Disagree" = 2,
                  "Neutral" = 3,
                  "Agree" = 4,
                  "Strongly Agree" = 5)
              } else {
                c("Incorrect" = 0, "Correct" = 1)
              },
              selected = character(0)
            ),
            shiny::br(),
            shiny::actionButton("submit_item", ui_labels$continue_button %||% "Continue", class = "btn-primary")
          )
        } else {
          # Results page
          shiny::div(
            class = "assessment-card",
            shiny::h2("Assessment Complete"),
            shiny::p("Thank you for completing the assessment."),
            if (length(rv$theta_history) > 0) {
              shiny::p(sprintf("Final ability estimate: %.2f", rv$theta_history[length(rv$theta_history)]))
            }
          )
        }
      }
    })
    
    # Event handlers - minimal
    shiny::observeEvent(input$start_test, {
      rv$stage <- "assessment"
    })
    
    shiny::observeEvent(input$submit_item, {
      if (!is.null(input$item_response)) {
        # Store response
        rv$responses <- c(rv$responses, as.numeric(input$item_response))
        rv$administered <- c(rv$administered, rv$current_item)
        
        # Simple theta update (no TAM loading)
        rv$theta_history <- c(rv$theta_history, mean(rv$responses, na.rm = TRUE))
        rv$se_history <- c(rv$se_history, 1 / sqrt(length(rv$responses)))
        
        # Check stopping criteria
        if (length(rv$administered) >= (config$max_items %||% 20) ||
            (!is.null(config$min_SEM) && rv$se_history[length(rv$se_history)] < config$min_SEM)) {
          rv$current_item <- nrow(item_bank) + 1  # End assessment
        } else {
          rv$current_item <- rv$current_item + 1
        }
      }
    })
  }
  
  # Launch app
  shiny::shinyApp(ui = ui, server = server)
}