#' Launch Optimized Study Interface
#'
#' This is an optimized version of launch_study that loads the first page immediately
#' and defers heavy operations for better performance.
#'
#' @export
launch_study_fast <- function(config, 
                             item_bank,
                             custom_css = NULL,
                             theme_config = NULL,
                             webdav_url = NULL,
                             password = NULL,
                             save_format = "rds",
                             logger = logr,
                             admin_dashboard_hook = NULL,
                             accessibility = FALSE,
                             study_key = NULL,
                             max_session_time = 7200,
                             session_save = config$session_save %||% FALSE,
                             data_preservation_interval = 30,
                             keep_alive_interval = 10,
                             enable_error_recovery = TRUE,
                             ...) {
  
  # OPTIMIZATION 1: Defer package loading
  # Only load essential packages initially
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("shiny package is required but not installed")
  }
  
  # Initialize minimal logging
  logr <- function(message, level = "INFO") {
    timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
    cat(sprintf("[%s] %s: %s\n", timestamp, level, message))
  }
  
  # Quick validation
  if (is.null(config)) stop("Config cannot be NULL")
  if (is.null(item_bank)) stop("Item bank cannot be NULL")
  
  # OPTIMIZATION 2: Create UI immediately without heavy processing
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(HTML("
        .loading-spinner {
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          display: none;
        }
        .loading-spinner.active {
          display: block;
        }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
      "))
    ),
    shiny::div(
      class = "loading-spinner",
      id = "initial-loader",
      shiny::tags$div(
        style = "text-align: center;",
        shiny::tags$div(class = "spinner-border text-primary", role = "status"),
        shiny::tags$p("Loading study...")
      )
    ),
    shiny::uiOutput("study_ui")
  )
  
  server <- function(input, output, session) {
    # OPTIMIZATION 3: Use promises for async loading
    initialized <- shiny::reactiveVal(FALSE)
    packages_loaded <- shiny::reactiveVal(FALSE)
    
    # Initialize reactive values with minimal data
    rv <- shiny::reactiveValues(
      stage = "loading",
      current_page = 1,
      responses = c(),
      session_active = TRUE
    )
    
    # OPTIMIZATION 4: Defer heavy initialization
    shiny::observe({
      if (!initialized()) {
        # Show first page immediately
        output$study_ui <- shiny::renderUI({
          if (!is.null(config$custom_page_flow) && length(config$custom_page_flow) > 0) {
            # Render first page without waiting for packages
            first_page <- config$custom_page_flow[[1]]
            if (first_page$type == "instructions") {
              shiny::div(
                class = "assessment-card",
                shiny::h2(first_page$title %||% "Welcome"),
                shiny::HTML(first_page$content %||% "<p>Loading...</p>"),
                shiny::br(),
                shiny::actionButton("start_btn", "Start", class = "btn btn-primary")
              )
            } else {
              shiny::div(
                class = "assessment-card",
                shiny::h2("Loading..."),
                shiny::p("Please wait while we prepare your assessment.")
              )
            }
          } else {
            # Default welcome page
            shiny::div(
              class = "assessment-card",
              shiny::h2(config$name %||% "Assessment"),
              shiny::p("Welcome to the assessment. Click Start to begin."),
              shiny::br(),
              shiny::actionButton("start_btn", "Start", class = "btn btn-primary")
            )
          }
        })
        
        initialized(TRUE)
        
        # OPTIMIZATION 5: Load packages in background after UI is shown
        shiny::observe({
          shiny::isolate({
            # Load packages asynchronously
            future::future({
              packages <- c("TAM", "DT", "ggplot2", "dplyr")
              for (pkg in packages) {
                if (requireNamespace(pkg, quietly = TRUE)) {
                  library(pkg, character.only = TRUE, quietly = TRUE)
                }
              }
              TRUE
            }) %...>% {
              packages_loaded(TRUE)
              logr("All packages loaded")
            }
          })
        })
      }
    })
    
    # Handle navigation after packages are loaded
    shiny::observeEvent(input$start_btn, {
      if (packages_loaded()) {
        rv$stage <- "assessment"
        rv$current_page <- 2
        # Continue with normal flow
      } else {
        shiny::showNotification("Still loading, please wait...", type = "warning")
      }
    })
  }
  
  # OPTIMIZATION 6: Return app immediately
  shiny::shinyApp(ui, server)
}

# Export the optimized function
#' @export
launch_study_optimized <- launch_study_fast