#' Fast Launch Study - Optimized for immediate startup
#'
#' This version minimizes initialization time by deferring all non-essential operations
#'
#' @export
launch_study_fast <- function(config, 
                             item_bank,
                             custom_css = NULL,
                             theme_config = NULL,
                             webdav_url = NULL,
                             password = NULL,
                             save_format = "rds",
                             logger = NULL,
                             admin_dashboard_hook = NULL,
                             accessibility = FALSE,
                             study_key = NULL,
                             max_session_time = 7200,
                             session_save = FALSE,  # DISABLED by default for speed
                             data_preservation_interval = 30,
                             keep_alive_interval = 10,
                             enable_error_recovery = FALSE,  # DISABLED by default for speed
                             ...) {
  
  # Minimal logger - no file I/O
  if (is.null(logger)) {
    logger <- function(message, level = "INFO") {
      # Only log errors to console
      if (level == "ERROR") {
        cat(sprintf("[%s] %s\n", level, message))
      }
    }
  }
  
  # Quick validation only
  if (is.null(config)) stop("Config cannot be NULL")
  if (is.null(item_bank)) stop("Item bank cannot be NULL")
  
  # Get theme CSS without loading packages
  theme_css <- if (!is.null(custom_css)) {
    custom_css
  } else {
    # Minimal inline CSS for immediate display
    "
    body { 
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      margin: 0; padding: 20px; background: #f5f5f5;
    }
    .container-fluid { max-width: 800px; margin: 0 auto; }
    .assessment-card {
      background: white; border-radius: 8px; padding: 30px;
      margin: 20px 0; box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    .btn-primary {
      background: #007bff; color: white; border: none;
      padding: 10px 20px; border-radius: 4px; cursor: pointer;
      font-size: 16px;
    }
    .btn-primary:hover { background: #0056b3; }
    "
  }
  
  # Create UI immediately - no package loading
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(shiny::HTML(theme_css))
    ),
    shiny::uiOutput("study_ui")
  )
  
  # Minimal server function
  server <- function(input, output, session) {
    # Initialize only essential reactive values
    rv <- shiny::reactiveValues(
      stage = if (!is.null(config$custom_page_flow)) "custom_page_flow" else "instructions",
      current_page = 1,
      responses = c(),
      item_responses = list(),
      demo_data = list()
    )
    
    # Render first page IMMEDIATELY without any processing
    output$study_ui <- shiny::renderUI({
      if (!is.null(config$custom_page_flow) && rv$current_page <= length(config$custom_page_flow)) {
        page <- config$custom_page_flow[[rv$current_page]]
        
        # Simple page rendering without heavy processing
        if (page$type == "instructions") {
          shiny::div(
            class = "assessment-card",
            shiny::h2(page$title %||% "Welcome"),
            shiny::HTML(page$content %||% "<p>Welcome to the assessment.</p>"),
            if (!is.null(page$consent) && page$consent) {
              shiny::checkboxInput("consent", page$consent_text %||% "I agree to participate")
            },
            shiny::br(),
            shiny::actionButton("next_btn", "Next", class = "btn-primary")
          )
        } else if (page$type == "demographics") {
          shiny::div(
            class = "assessment-card",
            shiny::h2(page$title %||% "Demographics"),
            shiny::p(page$description %||% "Please provide some information about yourself."),
            # Render demographics dynamically
            shiny::uiOutput("demo_inputs"),
            shiny::br(),
            shiny::actionButton("next_btn", "Next", class = "btn-primary")
          )
        } else if (page$type == "items") {
          shiny::div(
            class = "assessment-card",
            shiny::h2(page$title %||% "Questions"),
            if (!is.null(page$instructions)) shiny::p(page$instructions),
            # Render items dynamically
            shiny::uiOutput("item_inputs"),
            shiny::br(),
            shiny::actionButton("next_btn", "Next", class = "btn-primary")
          )
        } else if (page$type == "results") {
          shiny::div(
            class = "assessment-card",
            shiny::h2(page$title %||% "Results"),
            shiny::uiOutput("results_content")
          )
        } else {
          # Custom page
          shiny::div(
            class = "assessment-card",
            shiny::h2(page$title %||% ""),
            shiny::HTML(page$content %||% ""),
            if (rv$current_page < length(config$custom_page_flow)) {
              shiny::actionButton("next_btn", "Next", class = "btn-primary")
            }
          )
        }
      } else {
        # Default simple page
        shiny::div(
          class = "assessment-card",
          shiny::h2(config$name %||% "Assessment"),
          shiny::p("Click Start to begin."),
          shiny::actionButton("start_btn", "Start", class = "btn-primary")
        )
      }
    })
    
    # Handle navigation - simple and fast
    shiny::observeEvent(input$next_btn, {
      rv$current_page <- rv$current_page + 1
    })
    
    shiny::observeEvent(input$start_btn, {
      rv$current_page <- 1
    })
    
    # Defer package loading until actually needed
    packages_loaded <- shiny::reactiveVal(FALSE)
    
    # Load packages only when reaching items or results
    shiny::observe({
      if (rv$current_page > 2 && !packages_loaded()) {
        # Load packages in background
        future::future({
          for (pkg in c("TAM", "ggplot2", "dplyr")) {
            if (requireNamespace(pkg, quietly = TRUE)) {
              library(pkg, character.only = TRUE, quietly = TRUE)
            }
          }
        })
        packages_loaded(TRUE)
      }
    })
    
    # Render demographics when needed
    output$demo_inputs <- shiny::renderUI({
      page <- config$custom_page_flow[[rv$current_page]]
      if (!is.null(page$demographics)) {
        lapply(page$demographics, function(demo) {
          if (!is.null(config$demographic_configs[[demo]])) {
            cfg <- config$demographic_configs[[demo]]
            input_type <- config$input_types[[demo]] %||% "text"
            
            if (input_type == "radio") {
              shiny::radioButtons(demo, cfg$question, choices = cfg$options)
            } else if (input_type == "select") {
              shiny::selectInput(demo, cfg$question, choices = cfg$options)
            } else if (input_type == "checkbox") {
              shiny::checkboxGroupInput(demo, cfg$question, choices = cfg$options)
            } else {
              shiny::textInput(demo, cfg$question)
            }
          }
        })
      }
    })
    
    # Render items when needed
    output$item_inputs <- shiny::renderUI({
      page <- config$custom_page_flow[[rv$current_page]]
      if (!is.null(page$item_indices) && !is.null(item_bank)) {
        lapply(page$item_indices, function(idx) {
          if (idx <= nrow(item_bank)) {
            item <- item_bank[idx, ]
            shiny::div(
              shiny::h4(item$Question %||% paste("Item", idx)),
              shiny::radioButtons(
                paste0("item_", idx),
                label = NULL,
                choices = 1:5,
                selected = rv$item_responses[[paste0("item_", idx)]],
                inline = TRUE
              )
            )
          }
        })
      }
    })
    
    # Render results when needed
    output$results_content <- shiny::renderUI({
      if (!is.null(config$results_processor)) {
        # Collect responses
        responses <- sapply(1:31, function(i) {
          val <- input[[paste0("item_", i)]]
          if (!is.null(val)) as.numeric(val) else NA
        })
        responses <- responses[!is.na(responses)]
        
        # Generate results
        config$results_processor(responses, item_bank)
      } else {
        shiny::HTML("<p>Thank you for completing the assessment!</p>")
      }
    })
  }
  
  # Return app immediately
  shiny::shinyApp(ui, server)
}

# Also export as regular launch_study for compatibility
#' @export
launch_study <- launch_study_fast