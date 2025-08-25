#' Launch Study - Clean version with immediate display
#' 
#' @export
launch_study_clean <- function(config, item_bank, ...) {
  # Simple, clean launch without complex JavaScript
  
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style("
        body { margin: 0; padding: 0; font-family: system-ui, sans-serif; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; }
      ")
    ),
    shiny::uiOutput("main_ui")
  )
  
  server <- function(input, output, session) {
    # Initialize reactive values
    rv <- shiny::reactiveValues(
      stage = "instructions",
      current_item = 1,
      responses = c(),
      administered = c()
    )
    
    # Render main UI
    output$main_ui <- shiny::renderUI({
      if (rv$stage == "instructions") {
        shiny::div(class = "container",
          shiny::h1(config$name),
          shiny::p(config$instructions$welcome %||% "Welcome to this assessment"),
          shiny::p(config$instructions$purpose %||% "Click below to begin"),
          shiny::actionButton("start", "Begin Assessment")
        )
      } else if (rv$stage == "assessment") {
        item <- item_bank[rv$current_item, ]
        shiny::div(class = "container",
          shiny::h2(paste("Question", length(rv$administered) + 1)),
          shiny::p(item$Question),
          shiny::radioButtons("response", "Select your answer:",
            choices = 1:5,
            selected = character(0)
          ),
          shiny::actionButton("next", "Next")
        )
      } else {
        shiny::div(class = "container",
          shiny::h1("Assessment Complete"),
          shiny::p("Thank you for completing the assessment")
        )
      }
    })
    
    # Handle start button
    shiny::observeEvent(input$start, {
      rv$stage <- "assessment"
    })
    
    # Handle next button
    shiny::observeEvent(input$next, {
      if (!is.null(input$response)) {
        rv$responses <- c(rv$responses, as.numeric(input$response))
        rv$administered <- c(rv$administered, rv$current_item)
        
        if (length(rv$administered) >= config$max_items) {
          rv$stage <- "complete"
        } else {
          # Select next item (simple random for now)
          available <- setdiff(1:nrow(item_bank), rv$administered)
          if (length(available) > 0) {
            rv$current_item <- sample(available, 1)
          } else {
            rv$stage <- "complete"
          }
        }
      }
    })
  }
  
  shiny::shinyApp(ui, server, ...)
}