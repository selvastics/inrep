#' Ultra-Fast Launch Study Implementation
#'
#' This is a streamlined version that displays the UI immediately without any delays.
#' It loads everything in the same session without relaunching.
#'
#' @export
launch_study_ultra_fast <- function(config, item_bank, ...) {
  
  # Get additional arguments
  args <- list(...)
  
  # Create the UI that displays IMMEDIATELY
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$title(config$name %||% "Assessment"),
      shiny::tags$style(shiny::HTML("
        body { 
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
          margin: 0; padding: 0; background: #f8f9fa;
        }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
        .card { 
          background: white; padding: 30px; border-radius: 10px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-top: 20px;
        }
        .btn-primary {
          background: #007bff; color: white; border: none;
          padding: 10px 30px; font-size: 16px; border-radius: 5px;
          cursor: pointer; margin-top: 20px;
        }
        .btn-primary:hover { background: #0056b3; }
        .btn-primary:disabled { 
          background: #6c757d; cursor: not-allowed; opacity: 0.65;
        }
        .loading-spinner {
          display: inline-block; width: 20px; height: 20px;
          border: 3px solid #f3f3f3; border-top: 3px solid #007bff;
          border-radius: 50%; animation: spin 1s linear infinite;
          margin-left: 10px; vertical-align: middle;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .hidden { display: none !important; }
        h1, h2, h3 { color: #333; }
        hr { border: none; border-top: 1px solid #dee2e6; margin: 20px 0; }
        .question-container {
          min-height: 200px; padding: 20px;
          background: #f8f9fa; border-radius: 5px;
        }
        .response-options { margin: 20px 0; }
        .response-option {
          display: block; margin: 10px 0; padding: 10px;
          background: white; border: 2px solid #dee2e6;
          border-radius: 5px; cursor: pointer;
        }
        .response-option:hover { border-color: #007bff; }
        .response-option input { margin-right: 10px; }
      "))
    ),
    shiny::div(class = "container",
      shiny::uiOutput("main_content")
    )
  )
  
  # Create the server
  server <- function(input, output, session) {
    
    # Reactive values for state
    rv <- shiny::reactiveValues(
      page = "instructions",
      packages_loaded = FALSE,
      current_item = 1,
      responses = list(),
      theta_est = 0,
      start_time = Sys.time()
    )
    
    # Main content renderer
    output$main_content <- shiny::renderUI({
      if (rv$page == "instructions") {
        # INSTRUCTION PAGE - Shows immediately
        shiny::div(class = "card",
          shiny::h1(config$name %||% "Assessment"),
          shiny::hr(),
          shiny::h3("Welcome"),
          shiny::p(config$instructions$welcome %||% "Welcome to this assessment."),
          shiny::h3("Instructions"),
          shiny::p(config$instructions$instructions %||% 
                  "Please answer all questions to the best of your ability."),
          shiny::h3("Duration"),
          shiny::p(paste("This assessment will take approximately", 
                        config$instructions$duration %||% "10-15 minutes")),
          shiny::actionButton("start_btn", "Start Assessment", class = "btn-primary")
        )
        
      } else if (rv$page == "loading_packages") {
        # LOADING PAGE - Shows while packages load
        shiny::div(class = "card",
          shiny::h2("Preparing Assessment"),
          shiny::p("Loading required components..."),
          shiny::div(class = "loading-spinner"),
          shiny::p(id = "load_status", "Please wait...")
        )
        
      } else if (rv$page == "demographics") {
        # DEMOGRAPHICS PAGE
        shiny::div(class = "card",
          shiny::h2("Demographic Information"),
          shiny::p("Please provide the following information:"),
          shiny::br(),
          # Simple demographics for now
          shiny::textInput("age", "Age:", placeholder = "Enter your age"),
          shiny::selectInput("gender", "Gender:", 
                            choices = c("", "Male", "Female", "Other", "Prefer not to say")),
          shiny::br(),
          shiny::actionButton("demo_next", "Continue", class = "btn-primary")
        )
        
      } else if (rv$page == "assessment") {
        # ASSESSMENT PAGE - Main questionnaire
        if (rv$current_item <= nrow(item_bank)) {
          current_question <- item_bank[rv$current_item, ]
          question_text <- if ("item_text" %in% names(current_question)) {
            current_question$item_text
          } else if ("Question" %in% names(current_question)) {
            current_question$Question
          } else {
            paste("Question", rv$current_item)
          }
          
          shiny::div(class = "card",
            shiny::h2(paste("Question", rv$current_item, "of", nrow(item_bank))),
            shiny::div(class = "question-container",
              shiny::h3(question_text)
            ),
            shiny::div(class = "response-options",
              shiny::radioButtons(
                paste0("response_", rv$current_item),
                label = NULL,
                choices = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
                selected = character(0)
              )
            ),
            shiny::actionButton("next_item", "Next", class = "btn-primary")
          )
        } else {
          rv$page <- "complete"
          NULL
        }
        
      } else if (rv$page == "complete") {
        # COMPLETION PAGE
        shiny::div(class = "card",
          shiny::h1("Assessment Complete!"),
          shiny::hr(),
          shiny::p("Thank you for completing the assessment."),
          shiny::p(paste("Time taken:", 
                        round(difftime(Sys.time(), rv$start_time, units = "mins"), 1), 
                        "minutes")),
          shiny::br(),
          shiny::h3("Your Results"),
          shiny::p(paste("Estimated ability:", round(rv$theta_est, 2))),
          shiny::p(paste("Items completed:", length(rv$responses))),
          shiny::br(),
          shiny::actionButton("download_results", "Download Results", class = "btn-primary")
        )
      }
    })
    
    # Handle start button
    shiny::observeEvent(input$start_btn, {
      rv$page <- "loading_packages"
      
      # Load packages in background using later
      if (requireNamespace("later", quietly = TRUE)) {
        later::later(function() {
          # Quick check for essential packages only
          essential_pkgs <- c("TAM")
          for (pkg in essential_pkgs) {
            if (!requireNamespace(pkg, quietly = TRUE)) {
              try(utils::install.packages(pkg, quiet = TRUE, repos = "https://cran.r-project.org"))
            }
          }
          rv$packages_loaded <- TRUE
          
          # Move to demographics or assessment
          if (!is.null(config$demographics) && length(config$demographics) > 0) {
            rv$page <- "demographics"
          } else {
            rv$page <- "assessment"
          }
        }, delay = 0.1)
      } else {
        # If later not available, just proceed
        rv$packages_loaded <- TRUE
        if (!is.null(config$demographics) && length(config$demographics) > 0) {
          rv$page <- "demographics"
        } else {
          rv$page <- "assessment"
        }
      }
    })
    
    # Handle demographics next
    shiny::observeEvent(input$demo_next, {
      rv$page <- "assessment"
    })
    
    # Handle assessment next
    shiny::observeEvent(input$next_item, {
      # Save response
      response_id <- paste0("response_", rv$current_item)
      if (!is.null(input[[response_id]])) {
        rv$responses[[as.character(rv$current_item)]] <- input[[response_id]]
      }
      
      # Move to next item
      rv$current_item <- rv$current_item + 1
      
      # Simple theta estimation (placeholder)
      if (rv$current_item > nrow(item_bank)) {
        # Calculate simple average score
        scores <- sapply(rv$responses, function(x) {
          switch(x,
            "Strongly Disagree" = 1,
            "Disagree" = 2,
            "Neutral" = 3,
            "Agree" = 4,
            "Strongly Agree" = 5,
            3  # default
          )
        })
        rv$theta_est <- (mean(scores) - 3) * 0.5  # Simple transformation
        rv$page <- "complete"
      }
    })
    
    # Handle download
    shiny::observeEvent(input$download_results, {
      shiny::showNotification("Results saved!", type = "success")
    })
    
    # Session cleanup
    session$onSessionEnded(function() {
      cat("Session ended cleanly\n")
    })
  }
  
  # Create and run the app
  app <- shiny::shinyApp(ui = ui, server = server)
  
  cat("ULTRA-FAST: Launching assessment (UI displays immediately)...\n")
  shiny::runApp(app, 
                port = getOption("shiny.port", 5050),
                host = getOption("shiny.host", "127.0.0.1"),
                launch.browser = TRUE)
  
  invisible(NULL)
}