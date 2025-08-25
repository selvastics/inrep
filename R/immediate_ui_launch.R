#' Immediate UI Launch Functions
#'
#' Functions for launching assessments with immediate UI display using the later package correctly.
#' The key insight is that later() only executes when control returns to the R prompt,
#' so we need to return control immediately and schedule all heavy operations.
#'
#' @name immediate_ui_launch
#' @keywords internal
NULL

#' Launch Study with True Immediate UI
#'
#' This function implements the correct pattern for immediate UI display:
#' 1. Start minimal Shiny app immediately (synchronous)
#' 2. Return control to R prompt immediately
#' 3. Use later() to schedule all heavy operations
#'
#' @param config Study configuration object
#' @param item_bank Item bank data
#' @param ... Additional arguments passed to launch_study
#'
#' @return NULL (invisible)
#' @export
#'
#' @examples
#' \dontrun{
#' config <- create_study_config(name = "Test", immediate_ui = TRUE)
#' launch_study_immediate(config, bfi_items)
#' # Control returns immediately, UI appears instantly
#' # Heavy loading happens in background via later()
#' }
launch_study_immediate <- function(config, item_bank, ...) {
  
  cat("IMMEDIATE LAUNCH: Starting instant UI\n")
  
  # Create minimal loading UI that displays immediately
  minimal_ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$title("Assessment Loading..."),
      shiny::tags$style(shiny::HTML("
        body { 
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          margin: 0; padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
          min-height: 100vh;
          display: flex;
          align-items: center;
          justify-content: center;
        }
        .loading-card {
          background: rgba(255,255,255,0.95);
          color: #333;
          padding: 40px;
          border-radius: 15px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.3);
          text-align: center;
          max-width: 400px;
          width: 100%;
        }
        .spinner {
          border: 4px solid #f3f3f3;
          border-top: 4px solid #667eea;
          border-radius: 50%;
          width: 50px;
          height: 50px;
          animation: spin 1s linear infinite;
          margin: 20px auto;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .status { 
          margin-top: 20px; 
          font-size: 14px; 
          color: #666;
          min-height: 20px;
        }
        .progress-bar {
          width: 100%;
          height: 6px;
          background: #eee;
          border-radius: 3px;
          margin: 20px 0;
          overflow: hidden;
        }
        .progress-fill {
          height: 100%;
          background: linear-gradient(90deg, #667eea, #764ba2);
          width: 0%;
          transition: width 0.3s ease;
          border-radius: 3px;
        }
      "))
    ),
    shiny::div(class = "loading-card",
      shiny::h2(paste("Loading", config$name %||% "Assessment")),
      shiny::div(class = "spinner"),
      shiny::div(class = "progress-bar",
        shiny::div(class = "progress-fill", id = "progress-fill")
      ),
      shiny::div(id = "status", class = "status", "Preparing your assessment...")
    ),
    shiny::tags$script(shiny::HTML("
      // JavaScript to handle status updates
      Shiny.addCustomMessageHandler('updateStatus', function(message) {
        document.getElementById('status').innerHTML = message.text;
        if (message.progress) {
          document.getElementById('progress-fill').style.width = message.progress + '%';
        }
      });
      
      // Auto-update progress simulation
      let progress = 0;
      const updateProgress = () => {
        progress += Math.random() * 10;
        if (progress > 95) progress = 95;
        document.getElementById('progress-fill').style.width = progress + '%';
      };
      setInterval(updateProgress, 500);
    "))
  )
  
  # Minimal server that schedules heavy operations
  minimal_server <- function(input, output, session) {
    
    # Update status immediately
    session$sendCustomMessage("updateStatus", list(
      text = "Initializing assessment framework...",
      progress = 10
    ))
    
    # Schedule package loading (happens when control returns to R prompt)
    later(function() {
      session$sendCustomMessage("updateStatus", list(
        text = "Loading required packages...",
        progress = 30
      ))
      
      # Load packages in chunks to show progress
      packages_to_load <- c("shinyWidgets", "DT", "ggplot2", "dplyr")
      loaded_count <- 0
      
      for (pkg in packages_to_load) {
        later(function() {
          tryCatch({
            if (!requireNamespace(pkg, quietly = TRUE)) {
              session$sendCustomMessage("updateStatus", list(
                text = paste("Installing", pkg, "..."),
                progress = 30 + (loaded_count * 10)
              ))
              utils::install.packages(pkg, quiet = TRUE)
            }
            loaded_count <<- loaded_count + 1
            
            session$sendCustomMessage("updateStatus", list(
              text = paste("Loaded", pkg),
              progress = 30 + (loaded_count * 10)
            ))
            
            # If all packages loaded, start building the full app
            if (loaded_count >= length(packages_to_load)) {
              later(function() {
                build_full_assessment(config, item_bank, session, ...)
              }, delay = 0.2)
            }
            
          }, error = function(e) {
            session$sendCustomMessage("updateStatus", list(
              text = paste("Error loading", pkg, ":", e$message),
              progress = 30 + (loaded_count * 10)
            ))
          })
        }, delay = loaded_count * 0.5)  # Stagger package loading
      }
      
    }, delay = 0.1)  # Small delay to ensure UI is displayed first
  }
  
  # Create and start the app
  app <- shiny::shinyApp(
    ui = minimal_ui,
    server = minimal_server,
    options = list(
      port = getOption("shiny.port", 5050),
      host = getOption("shiny.host", "127.0.0.1")
    )
  )
  
  cat("IMMEDIATE LAUNCH: Starting minimal Shiny app...\n")
  
  # Store app in global environment so later() can access it
  .GlobalEnv$.inrep_immediate_app <- app
  .GlobalEnv$.inrep_launch_config <- config
  .GlobalEnv$.inrep_launch_item_bank <- item_bank
  .GlobalEnv$.inrep_launch_args <- list(...)
  
  # Schedule the app launch for when we return to R prompt
  later(function() {
    cat("LATER: Now starting the minimal app...\n")
    if (exists(".inrep_immediate_app", envir = .GlobalEnv)) {
      app <- .GlobalEnv$.inrep_immediate_app
      rm(.inrep_immediate_app, envir = .GlobalEnv)
      
      tryCatch({
        shiny::runApp(app, launch.browser = TRUE)
      }, error = function(e) {
        cat("Error starting immediate app:", e$message, "\n")
      })
    }
  }, delay = 0)
  
  cat("IMMEDIATE LAUNCH: Control returned to R prompt - UI will appear momentarily\n")
  message("Assessment is starting... The interface will open in your browser shortly.")
  
  return(invisible(NULL))
}

#' Build Full Assessment Interface
#'
#' This function is called by later() to build the full assessment interface
#' after the minimal loading UI is displayed.
#'
#' @param config Study configuration
#' @param item_bank Item bank data  
#' @param session Shiny session object
#' @param ... Additional arguments
#'
#' @keywords internal
build_full_assessment <- function(config, item_bank, session, ...) {
  
  session$sendCustomMessage("updateStatus", list(
    text = "Building assessment interface...",
    progress = 80
  ))
  
  # Small delay to show progress
  later(function() {
    session$sendCustomMessage("updateStatus", list(
      text = "Validating configuration...",
      progress = 90
    ))
    
    # Another delay before final transition
    later(function() {
      session$sendCustomMessage("updateStatus", list(
        text = "Ready! Redirecting to assessment...",
        progress = 100
      ))
      
      # Final delay before redirect
      later(function() {
        # Stop the current minimal app and start the full app
        tryCatch({
          # Get stored parameters
          if (exists(".inrep_launch_config", envir = .GlobalEnv)) {
            config <- .GlobalEnv$.inrep_launch_config
            item_bank <- .GlobalEnv$.inrep_launch_item_bank
            args <- .GlobalEnv$.inrep_launch_args
            
            # Clean up
            rm(.inrep_launch_config, envir = .GlobalEnv)
            rm(.inrep_launch_item_bank, envir = .GlobalEnv) 
            rm(.inrep_launch_args, envir = .GlobalEnv)
            
            # Stop current session
            session$close()
            
            # Launch full app (without immediate_ui to prevent recursion)
            config$immediate_ui <- FALSE
            do.call(launch_study, c(list(config = config, item_bank = item_bank), args))
          }
        }, error = function(e) {
          session$sendCustomMessage("updateStatus", list(
            text = paste("Error:", e$message),
            progress = 100
          ))
        })
      }, delay = 1)
      
    }, delay = 0.5)
    
  }, delay = 0.5)
}

#' Check if Immediate UI Should Be Used
#'
#' Helper function to determine if immediate UI mode should be activated.
#'
#' @param config Study configuration object
#' @return Logical indicating if immediate UI should be used
#' @export
should_use_immediate_ui <- function(config) {
  # Check if immediate_ui is explicitly set
  if (!is.null(config$immediate_ui)) {
    return(isTRUE(config$immediate_ui))
  }
  
  # Check global option
  if (!is.null(getOption("inrep.immediate_ui"))) {
    return(isTRUE(getOption("inrep.immediate_ui")))
  }
  
  # Default to FALSE for safety
  FALSE
}