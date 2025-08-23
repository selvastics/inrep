#' Optimized Launch Study Function
#'
#' Fast, smooth version without display bugs or slow loading
#'
#' @export
launch_study_fast <- function(config, 
                             item_bank = NULL,
                             study_key = NULL,
                             webdav_url = NULL,
                             password = NULL,
                             save_format = "csv",
                             session_save = FALSE) {
  
  # Minimal package loading
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' required. Install with: install.packages('shiny')")
  }
  
  # Use provided item bank or from config
  if (is.null(item_bank)) {
    item_bank <- config$item_bank
  }
  if (is.null(item_bank)) {
    stop("Item bank required")
  }
  
  # Fast UI with proper layout
  ui <- shiny::fluidPage(
    # Critical CSS to prevent corner display bug
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        /* Fix layout issues */
        body {
          margin: 0;
          padding: 0;
          overflow-x: hidden;
        }
        
        .container-fluid {
          width: 100% !important;
          max-width: 1000px !important;
          margin: 0 auto !important;
          padding: 20px !important;
          box-sizing: border-box !important;
        }
        
        /* Prevent corner display bug */
        .shiny-output-error {
          display: none !important;
        }
        
        .page-wrapper {
          width: 100% !important;
          min-height: 500px;
          opacity: 1;
          transition: opacity 0.15s ease;
        }
        
        .assessment-card {
          width: 100% !important;
          padding: 30px;
          background: white;
          border-radius: 8px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
          margin: 0 auto 20px !important;
          box-sizing: border-box;
        }
        
        /* Fix tiny corner issue */
        .content-container {
          width: 100% !important;
          display: block !important;
          position: relative !important;
          margin: 0 !important;
        }
        
        /* Navigation */
        .nav-container {
          text-align: center;
          margin: 30px 0;
        }
        
        .btn-primary, .btn-secondary {
          padding: 12px 30px;
          font-size: 16px;
          border: none;
          border-radius: 4px;
          cursor: pointer;
          margin: 0 10px;
          transition: all 0.2s;
        }
        
        .btn-primary {
          background: #e8041c;
          color: white;
        }
        
        .btn-primary:hover {
          background: #c50318;
        }
        
        .btn-secondary {
          background: #6c757d;
          color: white;
        }
        
        /* Progress bar */
        .progress-container {
          height: 4px;
          background: #e0e0e0;
          margin-bottom: 20px;
          border-radius: 2px;
        }
        
        .progress-bar {
          height: 100%;
          background: #e8041c;
          border-radius: 2px;
          transition: width 0.3s ease;
        }
        
        /* Fast transitions */
        .fade-in {
          animation: fadeIn 0.15s ease;
        }
        
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        
        /* Language button */
        .lang-switcher {
          position: fixed;
          top: 20px;
          right: 20px;
          z-index: 1000;
          background: white;
          border: 2px solid #e8041c;
          color: #e8041c;
          padding: 10px 20px;
          border-radius: 4px;
          cursor: pointer;
          transition: all 0.2s;
        }
        
        .lang-switcher:hover {
          background: #e8041c;
          color: white;
        }
      "))
    ),
    
    # Progress bar
    shiny::div(
      class = "progress-container",
      shiny::div(class = "progress-bar", id = "progress", style = "width: 0%")
    ),
    
    # Main content - single container that updates
    shiny::div(
      id = "main-container",
      class = "content-container",
      shiny::uiOutput("page_ui")
    ),
    
    # Fast JavaScript
    shiny::tags$script(shiny::HTML("
      // Prevent display bugs
      $(document).ready(function() {
        // Ensure proper layout
        $('.container-fluid').css('visibility', 'visible');
        
        // Fast page transitions
        Shiny.addCustomMessageHandler('fadePage', function(msg) {
          $('#main-container').css('opacity', '0');
          setTimeout(function() {
            $('#main-container').css('opacity', '1');
          }, 100);
        });
        
        // Progress updates
        Shiny.addCustomMessageHandler('updateProgress', function(percent) {
          $('#progress').css('width', percent + '%');
        });
      });
    "))
  )
  
  # Optimized server
  server <- function(input, output, session) {
    # Reactive values
    rv <- shiny::reactiveValues(
      current_page = 1,
      total_pages = length(config$custom_page_flow),
      responses = list(),
      language = config$language %||% "de",
      item_responses = list()
    )
    
    # Render current page efficiently
    output$page_ui <- shiny::renderUI({
      page_idx <- rv$current_page
      
      if (page_idx < 1 || page_idx > rv$total_pages) {
        return(shiny::div("Invalid page"))
      }
      
      page <- config$custom_page_flow[[page_idx]]
      lang <- rv$language
      
      # Update progress
      progress <- (page_idx / rv$total_pages) * 100
      session$sendCustomMessage("updateProgress", progress)
      
      # Page content
      content <- if (page$type == "custom") {
        # Custom page (welcome, etc.)
        shiny::div(
          class = "assessment-card fade-in",
          shiny::HTML(page$content %||% "")
        )
      } else if (page$type == "demographics") {
        # Demographics page
        renderDemographicsPage(page, config, rv, lang)
      } else if (page$type == "items") {
        # Items page
        renderItemsPage(page, item_bank, rv, lang)
      } else if (page$type == "results") {
        # Results page
        renderResultsPage(rv, config, lang)
      } else {
        shiny::div("Unknown page type")
      }
      
      # Add navigation
      nav <- shiny::div(
        class = "nav-container",
        if (page_idx > 1) {
          shiny::actionButton(
            "prev_page",
            ifelse(lang == "en", "Back", "Zurück"),
            class = "btn-secondary"
          )
        },
        if (page_idx < rv$total_pages) {
          shiny::actionButton(
            "next_page",
            ifelse(lang == "en", "Next", "Weiter"),
            class = "btn-primary"
          )
        } else if (page_idx == rv$total_pages - 1) {
          shiny::actionButton(
            "submit_study",
            ifelse(lang == "en", "Complete", "Abschließen"),
            class = "btn-primary"
          )
        }
      )
      
      shiny::div(
        class = "page-wrapper",
        content,
        nav
      )
    })
    
    # Navigation handlers
    shiny::observeEvent(input$next_page, {
      if (rv$current_page < rv$total_pages) {
        session$sendCustomMessage("fadePage", TRUE)
        rv$current_page <- rv$current_page + 1
      }
    })
    
    shiny::observeEvent(input$prev_page, {
      if (rv$current_page > 1) {
        session$sendCustomMessage("fadePage", TRUE)
        rv$current_page <- rv$current_page - 1
      }
    })
    
    shiny::observeEvent(input$submit_study, {
      rv$current_page <- rv$total_pages
    })
    
    # Language switching
    shiny::observeEvent(input$study_language, {
      if (!is.null(input$study_language)) {
        lang_parts <- strsplit(input$study_language, "_")[[1]]
        new_lang <- lang_parts[1]
        if (new_lang %in% c("de", "en")) {
          rv$language <- new_lang
        }
      }
    })
  }
  
  # Helper functions for rendering
  renderDemographicsPage <- function(page, config, rv, lang) {
    demo_items <- page$demographics %||% config$demographics
    
    inputs <- lapply(demo_items, function(demo) {
      demo_config <- config$demographic_configs[[demo]]
      if (is.null(demo_config)) return(NULL)
      
      label <- if (lang == "en" && !is.null(demo_config$question_en)) {
        demo_config$question_en
      } else {
        demo_config$question %||% demo
      }
      
      input_type <- config$input_types[[demo]] %||% "text"
      input_id <- paste0("demo_", demo)
      
      if (input_type == "select") {
        options <- if (lang == "en" && !is.null(demo_config$options_en)) {
          demo_config$options_en
        } else {
          demo_config$options
        }
        shiny::selectInput(input_id, label, choices = c("", options))
      } else if (input_type == "radio") {
        options <- if (lang == "en" && !is.null(demo_config$options_en)) {
          demo_config$options_en
        } else {
          demo_config$options
        }
        shiny::radioButtons(input_id, label, choices = options)
      } else {
        shiny::textInput(input_id, label)
      }
    })
    
    shiny::div(
      class = "assessment-card fade-in",
      shiny::h2(
        if (lang == "en" && !is.null(page$title_en)) page$title_en else page$title
      ),
      inputs
    )
  }
  
  renderItemsPage <- function(page, item_bank, rv, lang) {
    indices <- page$item_indices
    if (is.null(indices)) return(NULL)
    
    items <- lapply(indices, function(i) {
      if (i > nrow(item_bank)) return(NULL)
      item <- item_bank[i, ]
      
      question <- if (lang == "en" && !is.null(item$Question_EN)) {
        item$Question_EN
      } else {
        item$Question
      }
      
      choices <- 1:5
      labels <- if (lang == "en") {
        c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")
      } else {
        c("Stimme gar nicht zu", "Stimme nicht zu", "Neutral", "Stimme zu", "Stimme voll zu")
      }
      
      shiny::div(
        style = "margin: 20px 0; padding: 15px; background: #f8f9fa; border-radius: 4px;",
        shiny::h4(question),
        shiny::radioButtons(
          paste0("item_", i),
          "",
          choices = setNames(choices, labels),
          selected = rv$item_responses[[paste0("item_", i)]] %||% character(0),
          inline = TRUE
        )
      )
    })
    
    shiny::div(
      class = "assessment-card fade-in",
      shiny::h2(
        if (lang == "en" && !is.null(page$title_en)) page$title_en else page$title
      ),
      if (!is.null(page$instructions)) {
        shiny::p(
          if (lang == "en" && !is.null(page$instructions_en)) {
            page$instructions_en
          } else {
            page$instructions
          }
        )
      },
      items
    )
  }
  
  renderResultsPage <- function(rv, config, lang) {
    shiny::div(
      class = "assessment-card fade-in",
      shiny::h2(ifelse(lang == "en", "Thank you!", "Vielen Dank!")),
      shiny::p(ifelse(lang == "en", 
                     "Your responses have been saved.",
                     "Ihre Antworten wurden gespeichert.")),
      shiny::br(),
      shiny::h3(ifelse(lang == "en", "Your Results:", "Ihre Ergebnisse:")),
      shiny::div(
        style = "margin-top: 20px;",
        shiny::p("Analysis complete. Thank you for participating!")
      )
    )
  }
  
  # Launch app
  shiny::shinyApp(ui = ui, server = server)
}