#' Zero-Delay Launch Study Implementation
#'
#' This implementation has ABSOLUTELY ZERO delays - the UI appears instantly
#' with no loading screens, no waiting, no background messages.
#'
#' @export
launch_study_zero_delay <- function(config, item_bank, ...) {
  
  # Suppress ALL messages and warnings during startup
  suppressMessages({
    suppressWarnings({
      
      # Pre-check critical packages silently
      has_shiny <- requireNamespace("shiny", quietly = TRUE)
      if (!has_shiny) {
        stop("Shiny package is required. Install with: install.packages('shiny')")
      }
      
      # Check for later package but don't require specific version
      has_later <- requireNamespace("later", quietly = TRUE)
      
    })
  })
  
  # Extract config values with defaults
  study_name <- config$name %||% "Assessment"
  welcome_text <- if (!is.null(config$instructions)) {
    config$instructions$welcome %||% "Welcome to this assessment."
  } else {
    "Welcome to this assessment."
  }
  instructions_text <- if (!is.null(config$instructions)) {
    config$instructions$instructions %||% "Please answer all questions to the best of your ability."
  } else {
    "Please answer all questions to the best of your ability."
  }
  duration_text <- if (!is.null(config$instructions)) {
    config$instructions$duration %||% "10-15 minutes"
  } else {
    "10-15 minutes"
  }
  
  # Create MINIMAL UI - absolutely nothing that could delay
  ui <- shiny::tagList(
    shiny::tags$head(
      shiny::tags$title(study_name),
      shiny::tags$style(shiny::HTML("
        * { box-sizing: border-box; }
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
          margin: 0; padding: 0; background: #f5f7fa; line-height: 1.6;
        }
        .container { 
          max-width: 800px; margin: 0 auto; padding: 20px;
          opacity: 0; animation: fadeIn 0.3s forwards;
        }
        @keyframes fadeIn { to { opacity: 1; } }
        .card { 
          background: white; padding: 40px; border-radius: 12px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.08); margin: 20px 0;
        }
        h1 { color: #2c3e50; margin: 0 0 10px 0; font-size: 28px; }
        h3 { color: #34495e; margin: 25px 0 10px 0; font-size: 18px; font-weight: 600; }
        p { color: #555; margin: 10px 0; }
        hr { border: none; border-top: 1px solid #e0e5eb; margin: 25px 0; }
        .btn {
          background: #3498db; color: white; border: none;
          padding: 12px 32px; font-size: 16px; border-radius: 6px;
          cursor: pointer; margin: 20px 0; transition: all 0.2s;
          font-weight: 500;
        }
        .btn:hover { background: #2980b9; transform: translateY(-1px); }
        .btn:active { transform: translateY(0); }
        .question-box {
          background: #f8f9fa; padding: 25px; border-radius: 8px;
          margin: 20px 0; border: 1px solid #e9ecef;
        }
        .question-text { font-size: 18px; color: #2c3e50; margin-bottom: 20px; }
        .radio-group { margin: 15px 0; }
        .radio-option {
          display: block; margin: 8px 0; padding: 12px;
          background: white; border: 2px solid #ddd; border-radius: 6px;
          cursor: pointer; transition: all 0.2s;
        }
        .radio-option:hover { border-color: #3498db; background: #f0f8ff; }
        .radio-option input { margin-right: 10px; }
        .progress-bar {
          height: 4px; background: #e0e5eb; border-radius: 2px;
          margin: 20px 0; overflow: hidden;
        }
        .progress-fill {
          height: 100%; background: #3498db; transition: width 0.3s;
          border-radius: 2px;
        }
        .fade-out { animation: fadeOut 0.2s forwards; }
        @keyframes fadeOut { to { opacity: 0; } }
        .fade-in { animation: fadeIn 0.3s forwards; }
      "))
    ),
    shiny::div(class = "container", id = "main-container",
      shiny::uiOutput("content")
    )
  )
  
  # Create server with instant response
  server <- function(input, output, session) {
    
    # State management - no reactive values needed for speed
    current_page <- "welcome"
    current_item <- 1
    responses <- list()
    start_time <- Sys.time()
    
    # Helper to update page instantly
    update_page <- function(new_page) {
      current_page <<- new_page
      output$content <- shiny::renderUI({
        render_page(new_page)
      })
    }
    
    # Page renderer - returns UI immediately
    render_page <- function(page) {
      if (page == "welcome") {
        # Welcome page - shows INSTANTLY
        shiny::div(class = "card fade-in",
          shiny::h1(study_name),
          shiny::hr(),
          shiny::h3("Welcome"),
          shiny::p(welcome_text),
          shiny::h3("Instructions"),
          shiny::p(instructions_text),
          shiny::h3("Duration"),
          shiny::p(paste("This assessment will take approximately", duration_text)),
          shiny::actionButton("start", "Start Assessment", class = "btn")
        )
        
      } else if (page == "demographics" && !is.null(config$demographics)) {
        # Demographics page - optional
        shiny::div(class = "card fade-in",
          shiny::h1("About You"),
          shiny::p("Please provide some basic information:"),
          shiny::br(),
          shiny::textInput("demo_age", "Age:", width = "200px"),
          shiny::selectInput("demo_gender", "Gender:", 
                           choices = c("", "Male", "Female", "Other", "Prefer not to say"),
                           width = "200px"),
          shiny::br(),
          shiny::actionButton("demo_next", "Continue", class = "btn")
        )
        
      } else if (page == "assessment") {
        # Assessment page - show questions
        if (current_item <= nrow(item_bank)) {
          item <- item_bank[current_item, ]
          question_text <- item$item_text %||% item$Question %||% item$question %||% 
                          paste("Question", current_item)
          
          shiny::div(class = "card fade-in",
            shiny::div(class = "progress-bar",
              shiny::div(class = "progress-fill", 
                        style = paste0("width: ", 
                                      round(100 * (current_item - 1) / nrow(item_bank)), "%"))
            ),
            shiny::h3(paste("Question", current_item, "of", nrow(item_bank))),
            shiny::div(class = "question-box",
              shiny::div(class = "question-text", question_text),
              shiny::radioButtons(
                inputId = "response",
                label = NULL,
                choices = c("Strongly Disagree" = 1, 
                           "Disagree" = 2, 
                           "Neutral" = 3, 
                           "Agree" = 4, 
                           "Strongly Agree" = 5),
                selected = character(0)
              )
            ),
            shiny::actionButton("next", "Next", class = "btn")
          )
        } else {
          update_page("complete")
          NULL
        }
        
      } else if (page == "complete") {
        # Completion page
        time_taken <- round(difftime(Sys.time(), start_time, units = "mins"), 1)
        shiny::div(class = "card fade-in",
          shiny::h1("Thank You!"),
          shiny::hr(),
          shiny::p("You have completed the assessment."),
          shiny::p(paste("Time taken:", time_taken, "minutes")),
          shiny::p(paste("Questions answered:", length(responses))),
          shiny::br(),
          shiny::actionButton("finish", "Finish", class = "btn")
        )
      } else {
        # Default: skip to next appropriate page
        if (!is.null(config$demographics) && length(config$demographics) > 0) {
          update_page("demographics")
        } else {
          update_page("assessment")
        }
        NULL
      }
    }
    
    # Initial render - INSTANT
    output$content <- shiny::renderUI({
      render_page("welcome")
    })
    
    # Handle start button - NO DELAYS
    shiny::observeEvent(input$start, {
      if (!is.null(config$demographics) && length(config$demographics) > 0) {
        update_page("demographics")
      } else {
        update_page("assessment")
      }
    })
    
    # Handle demographics next - INSTANT
    shiny::observeEvent(input$demo_next, {
      update_page("assessment")
    })
    
    # Handle assessment next - INSTANT
    shiny::observeEvent(input$next, {
      # Save response if provided
      if (!is.null(input$response) && input$response != "") {
        responses[[as.character(current_item)]] <<- input$response
      }
      
      # Move to next item
      current_item <<- current_item + 1
      
      # Update page
      if (current_item <= nrow(item_bank)) {
        update_page("assessment")
      } else {
        update_page("complete")
      }
    })
    
    # Handle finish
    shiny::observeEvent(input$finish, {
      shiny::stopApp()
    })
    
    # Clean session end
    session$onSessionEnded(function() {
      # Silent cleanup - no messages
    })
  }
  
  # Create app
  app <- shiny::shinyApp(ui = ui, server = server)
  
  # Launch with NO messages
  invisible(capture.output({
    shiny::runApp(app, 
                  port = getOption("shiny.port", 5050),
                  host = getOption("shiny.host", "127.0.0.1"),
                  launch.browser = TRUE,
                  quiet = TRUE)
  }))
  
  invisible(NULL)
}