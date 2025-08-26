# =============================================================================
# FAST LAUNCH PATCH FOR INREP
# =============================================================================
# This patch modifies launch_study to show UI immediately

# Override the launch_study function with fast version
launch_study_fast <- function(config, item_bank, 
                             webdav_url = NULL,
                             webdav_password = NULL,
                             show_ui_immediately = TRUE,
                             ...) {
  
  # Create UI immediately (before loading packages)
  ui <- shiny::fluidPage(
    # Minimal CSS for immediate display
    shiny::tags$head(
      shiny::tags$style(shiny::HTML("
        .loading { display: none; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
      ")),
      # Include jsPDF for PDF download
      shiny::tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"),
      shiny::tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js")
    ),
    
    # Main UI container
    shiny::uiOutput("study_ui"),
    
    # Hidden loading indicator
    shiny::div(class = "loading", id = "loading-packages", "Loading packages...")
  )
  
  # Server with deferred loading
  server <- function(input, output, session) {
    
    # Initialize reactive values
    rv <- shiny::reactiveValues(
      current_page = 1,
      responses = list(),
      demographics = list(),
      packages_loaded = FALSE,
      start_time = Sys.time()
    )
    
    # Render first page immediately
    output$study_ui <- shiny::renderUI({
      if (rv$current_page == 1) {
        # First page - no packages needed
        return(render_first_page_fast(config))
      } else {
        # Other pages - load packages if needed
        if (!rv$packages_loaded) {
          load_packages_deferred()
          rv$packages_loaded <- TRUE
        }
        return(render_page(rv$current_page, config, item_bank))
      }
    })
    
    # Fast first page renderer
    render_first_page_fast <- function(config) {
      shiny::tagList(
        shiny::div(style = "max-width: 800px; margin: 0 auto; padding: 20px;",
          shiny::h1(config$name),
          shiny::div(style = "background: #f8f9fa; padding: 20px; border-radius: 8px;",
            shiny::p("Willkommen zur Studie!"),
            shiny::p("Diese Befragung dauert etwa 10-15 Minuten."),
            shiny::br(),
            shiny::checkboxInput("consent", "Ich bin mit der Teilnahme einverstanden"),
            shiny::br(),
            shiny::actionButton("start", "Studie beginnen", 
                        style = "background: #007bff; color: white; padding: 10px 20px; border: none;")
          )
        )
      )
    }
    
    # Deferred package loading
    load_packages_deferred <- function() {
      # Load in background after UI is shown
      later::later(function() {
        suppressPackageStartupMessages({
          if (!requireNamespace("ggplot2", quietly = TRUE)) library(ggplot2)
          if (!requireNamespace("DT", quietly = TRUE)) library(DT)
        })
      }, delay = 0.1)
    }
    
    # Handle start button
    shiny::observeEvent(input$start, {
      if (!input$consent) {
        shiny::showNotification("Bitte bestätigen Sie Ihre Einverständnis", type = "error")
        return()
      }
      rv$current_page <- 2
    })
    
    # Handle navigation
    shiny::observeEvent(input$next_page, {
      save_current_page_data(rv, input)
      rv$current_page <- rv$current_page + 1
    })
    
    # Results page with downloads
    render_results_page <- function(rv, config) {
      # Generate CSV data
      csv_data <- prepare_csv_data(rv$responses, rv$demographics)
      
      shiny::tagList(
        shiny::h2("Ihre Ergebnisse"),
        shiny::p("Vielen Dank für Ihre Teilnahme!"),
        shiny::br(),
        
        # Download buttons
        shiny::downloadButton("download_csv", "CSV herunterladen",
                      style = "background: #28a745; color: white; margin-right: 10px;"),
        
        shiny::actionButton("download_pdf", "PDF herunterladen",
                    style = "background: #dc3545; color: white;"),
        
        # JavaScript for PDF generation
        shiny::tags$script(shiny::HTML(sprintf("
          document.getElementById('download_pdf').onclick = function() {
            const { jsPDF } = window.jspdf;
            const doc = new jsPDF();
            
            doc.setFontSize(20);
            doc.text('%s - Ergebnisse', 20, 20);
            
            doc.setFontSize(12);
            doc.text('Datum: %s', 20, 40);
            doc.text('Teilnehmer: %s', 20, 50);
            
            // Add results
            %s
            
            doc.save('ergebnisse.pdf');
          }
        ", config$name, Sys.Date(), "session_id", 
        generate_pdf_content_js(rv$responses))))
      )
    }
    
    # CSV download handler
    output$download_csv <- shiny::downloadHandler(
      filename = function() {
        paste0("hilfo_results_", Sys.Date(), ".csv")
      },
      content = function(file) {
        data <- prepare_csv_data(rv$responses, rv$demographics)
        write.csv(data, file, row.names = FALSE)
        
        # Also upload to cloud
        if (!is.null(webdav_url)) {
          upload_to_webdav_async(data, webdav_url, webdav_password)
        }
      }
    )
    
    # Async WebDAV upload
    upload_to_webdav_async <- function(data, url, password) {
      later::later(function() {
        tryCatch({
          # Create temporary file
          temp_file <- tempfile(fileext = ".csv")
          write.csv(data, temp_file, row.names = FALSE)
          
          # Upload using curl
          httr::PUT(
            url = paste0(url, "hilfo_", Sys.Date(), "_", 
                        format(Sys.time(), "%H%M%S"), ".csv"),
            body = upload_file(temp_file),
            authenticate("inrep_test", password)
          )
          
          unlink(temp_file)
          message("Data uploaded to cloud successfully")
        }, error = function(e) {
          warning("Cloud upload failed: ", e$message)
        })
      }, delay = 0.5)
    }
    
    # Session cleanup
    session$onSessionEnded(function() {
      # Final save to cloud
      if (length(rv$responses) > 0) {
        data <- prepare_csv_data(rv$responses, rv$demographics)
        upload_to_webdav_async(data, webdav_url, webdav_password)
      }
    })
  }
  
  # Launch app immediately
  app <- shiny::shinyApp(ui, server)
  
  # Run with immediate display
  shiny::runApp(app, launch.browser = TRUE, quiet = TRUE)
}

# Helper function to prepare CSV data
prepare_csv_data <- function(responses, demographics) {
  data.frame(
    Timestamp = Sys.time(),
    Session_ID = paste0("HILFO_", format(Sys.time(), "%Y%m%d_%H%M%S")),
    # Demographics
    Alter = demographics$age %||% NA,
    Studiengang = demographics$studiengang %||% NA,
    Geschlecht = demographics$geschlecht %||% NA,
    # Item responses
    BFE_01 = responses[[1]] %||% NA,
    BFV_01 = responses[[2]] %||% NA,
    BFG_01 = responses[[3]] %||% NA,
    BFN_01 = responses[[4]] %||% NA,
    BFO_01 = responses[[5]] %||% NA,
    # ... continue for all items
    # Calculated scores
    Score_Extraversion = mean(c(responses[[1]], responses[[6]], responses[[11]], responses[[16]]), na.rm = TRUE),
    Score_Vertraeglichkeit = mean(c(responses[[2]], responses[[7]], responses[[12]], responses[[17]]), na.rm = TRUE),
    Score_Gewissenhaftigkeit = mean(c(responses[[3]], responses[[8]], responses[[13]], responses[[18]]), na.rm = TRUE),
    Score_Neurotizismus = mean(c(responses[[4]], responses[[9]], responses[[14]], responses[[19]]), na.rm = TRUE),
    Score_Offenheit = mean(c(responses[[5]], responses[[10]], responses[[15]], responses[[20]]), na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}

# Export the fast launch function
assign("launch_study_fast", launch_study_fast, envir = .GlobalEnv)