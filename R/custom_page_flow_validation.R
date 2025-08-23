#' Validation for Custom Page Flow
#' 
#' Ensures all required fields are filled before allowing progression

#' Validate page before allowing navigation
#' @export
validate_page_progression <- function(current_page, input, config, current_language = NULL) {
  page <- config$custom_page_flow[[current_page]]
  
  if (is.null(page)) return(list(valid = TRUE))
  
  errors <- character()
  missing_fields <- character()
  
  # Check based on page type
  if (page$type == "instructions" && isTRUE(page$consent)) {
    # Check consent checkbox
    if (!isTRUE(input$consent_checkbox)) {
      errors <- c(errors, "Bitte bestätigen Sie Ihre Einverständnis zur Teilnahme.")
    }
  } else if (page$type == "demographics") {
    # Check all required demographics
    demo_vars <- page$demographics
    for (dem in demo_vars) {
      demo_config <- config$demographic_configs[[dem]]
      if (isTRUE(demo_config$required)) {
        input_id <- paste0("demo_", dem)
        value <- input[[input_id]]
        
        if (is.null(value) || value == "" || (is.character(value) && nchar(trimws(value)) == 0)) {
          # Get current language
          current_lang <- if (!is.null(current_language) && is.function(current_language)) {
            current_language()
          } else {
            config$language %||% "de"
          }
          
          # Get question in the correct language
          question <- if (current_lang == "en" && !is.null(demo_config$question_en)) {
            demo_config$question_en
          } else {
            demo_config$question %||% dem
          }
          
          # Truncate long questions for error message
          if (nchar(question) > 50) {
            question <- paste0(substr(question, 1, 47), "...")
          }
          
          # Use language-specific error message
          error_prefix <- if (current_lang == "en") {
            "Please answer: "
          } else {
            "Bitte beantworten Sie: "
          }
          errors <- c(errors, paste0(error_prefix, question))
          missing_fields <- c(missing_fields, input_id)
        }
      }
    }
  } else if (page$type == "items") {
    # Check all items have responses
    if (!is.null(page$item_indices)) {
      # Try to get item_bank from config or parent environment
      item_bank <- config$item_bank
      if (is.null(item_bank) && exists("item_bank", envir = parent.frame())) {
        item_bank <- get("item_bank", envir = parent.frame())
      }
      
      if (!is.null(item_bank)) {
        has_missing_items <- FALSE
        for (i in page$item_indices) {
          # Get the actual item from the item bank
          if (i <= nrow(item_bank)) {
            item <- item_bank[i, ]
            # Use the item's id field if available, otherwise use index
            item_id <- paste0("item_", item$id %||% i)
            if (is.null(input[[item_id]]) || input[[item_id]] == "") {
              has_missing_items <- TRUE
              missing_fields <- c(missing_fields, item_id)
              # Don't break, collect all missing fields for highlighting
            }
          }
        }
        # Only add the error message once if there are missing items
        if (has_missing_items) {
          # Get current language
          current_lang <- if (!is.null(current_language) && is.function(current_language)) {
            current_language()
          } else {
            config$language %||% "de"
          }
          
          # Use language-specific error message
          error_msg <- if (current_lang == "en") {
            "Please answer all questions on this page."
          } else {
            "Bitte beantworten Sie alle Fragen auf dieser Seite."
          }
          errors <- c(errors, error_msg)
        }
      }
    }
  }
  
  return(list(
    valid = length(errors) == 0,
    errors = errors,
    missing_fields = missing_fields
  ))
}

#' Create filter page with actual functionality
#' @export
create_filter_page <- function(input, config) {
  # Get the selected study program
  studiengang <- input$demo_Studiengang
  
  if (is.null(studiengang) || studiengang == "") {
    return(shiny::div(
      class = "assessment-card",
      shiny::h3("Filter", class = "card-header"),
      shiny::p("Bitte wählen Sie zuerst Ihren Studiengang aus.",
               style = "padding: 20px; color: #dc3545;")
    ))
  }
  
  # Create different content based on Bachelor/Master
  content <- if (studiengang == "1") {  # Bachelor
    shiny::div(
      style = "padding: 20px;",
      shiny::h4("Bachelor Psychologie", style = "color: #003366;"),
      shiny::p("Als Bachelor-Studierende/r werden Ihnen nun Fragen zu Ihrem Bildungshintergrund gestellt."),
      shiny::p("Diese Informationen helfen uns, die Heterogenität der Studierendenschaft besser zu verstehen."),
      shiny::div(
        class = "alert alert-info",
        style = "margin-top: 20px;",

        " Die folgenden Fragen beziehen sich auf Ihre schulischen Leistungen."
      )
    )
  } else {  # Master
    shiny::div(
      style = "padding: 20px;",
      shiny::h4("Master Psychologie", style = "color: #003366;"),
      shiny::p("Als Master-Studierende/r werden Ihnen nun Fragen zu Ihrem Bildungshintergrund gestellt."),
      shiny::p("Ihre vorherigen akademischen Erfahrungen sind für unsere Forschung von besonderem Interesse."),
      shiny::div(
        class = "alert alert-info",
        style = "margin-top: 20px;",

        " Die folgenden Fragen beziehen sich auf Ihre akademischen Leistungen."
      )
    )
  }
  
  shiny::div(
    class = "assessment-card",
    shiny::h3("Filter", class = "card-header"),
    content
  )
}

#' Show validation errors in UI
#' @export
show_validation_errors <- function(errors, current_lang = "de") {
  if (length(errors) == 0) return(NULL)
  
  # Use language-specific header
  header_text <- if (current_lang == "en") {
    "Please complete the following:"
  } else {
    "Bitte vervollständigen Sie Folgendes:"
  }
  
  shiny::div(
    class = "validation-error",
    shiny::h4(header_text),
    shiny::tags$ul(
      style = "margin: 10px 0; padding-left: 20px;",
      lapply(errors, function(e) shiny::tags$li(e))
    )
  )
}