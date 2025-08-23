#' Custom Page Flow Support for Multi-Page Studies
#'
#' This module provides support for custom page flows in studies,
#' allowing for complex multi-page questionnaires with progressive display.
#'
#' @export

#' Create custom page flow configuration
#' @export
create_custom_page_flow <- function(pages) {
  # Validate page structure
  required_fields <- c("id", "type", "title")
  
  for (i in seq_along(pages)) {
    page <- pages[[i]]
    missing <- setdiff(required_fields, names(page))
    if (length(missing) > 0) {
      stop(sprintf("Page %d missing required fields: %s", i, paste(missing, collapse=", ")))
    }
  }
  
  structure(
    pages,
    class = c("custom_page_flow", "list")
  )
}

#' Process custom page flow for UI rendering
#' @export
process_page_flow <- function(config, rv, input, output, session, item_bank, ui_labels, logger, current_language = NULL) {
  
  # Check if custom page flow is defined
  if (is.null(config$custom_page_flow)) {
    return(NULL)
  }
  
  # Get current page
  current_page_idx <- rv$current_page %||% 1
  current_page <- config$custom_page_flow[[current_page_idx]]
  
  if (is.null(current_page)) {
    logger(sprintf("Invalid page index: %d", current_page_idx), level = "ERROR")
    return(NULL)
  }
  
  # Get current language from reactive value if available
  current_lang <- if (!is.null(current_language) && is.function(current_language)) {
    current_language()
  } else {
    config$language %||% "de"
  }
  
  # Use language-specific title if available
  if (current_lang == "en" && !is.null(current_page$title_en)) {
    current_page$title <- current_page$title_en
  }
  
  # Use language-specific instructions if available
  if (current_lang == "en" && !is.null(current_page$instructions_en)) {
    current_page$instructions <- current_page$instructions_en
  }
  
  # Render page based on type
  page_ui <- switch(current_page$type,
    
    "instructions" = render_instructions_page(current_page, config, ui_labels, current_lang),
    
    "demographics" = render_demographics_page(current_page, config, rv, ui_labels, current_lang),
    
    "items" = render_items_page(current_page, config, rv, item_bank, ui_labels, current_lang),
    
    "custom" = render_custom_page(current_page, config, rv, ui_labels, input, current_lang),
    
    "results" = render_results_page(current_page, config, rv, item_bank, ui_labels, current_lang),
    
    # Default fallback
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(current_page$title %||% "Page", class = "card-header"),
      shiny::p("Page type not recognized")
    )
  )
  
  # Add navigation
  nav_ui <- render_page_navigation(rv, config, current_page_idx, current_lang)
  
  shiny::tagList(
    page_ui,
    nav_ui
  )
}

#' Render instructions page
render_instructions_page <- function(page, config, ui_labels, current_lang = "de") {
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page$title, class = "card-header"),
    if (!is.null(page$content)) {
      shiny::HTML(page$content)
    } else if (!is.null(page$text)) {
      shiny::p(page$text, class = "welcome-text")
    },
    if (!is.null(page$consent) && page$consent) {
      shiny::div(
        class = "consent-section",
        shiny::checkboxInput(
          "consent_checkbox",
          label = page$consent_text %||% "Ich bin mit der Teilnahme an der Befragung einverstanden",
          value = FALSE
        )
      )
    }
  )
}

#' Render demographics page
render_demographics_page <- function(page, config, rv, ui_labels, current_lang = "de") {
  # Get demographics for this page
  demo_vars <- page$demographics %||% config$demographics
  
  if (is.null(demo_vars)) {
    return(shiny::div("No demographics configured for this page"))
  }
  
  # Create inputs for each demographic
  demo_inputs <- lapply(demo_vars, function(dem) {
    demo_config <- config$demographic_configs[[dem]]
    
    if (is.null(demo_config)) {
      return(NULL)
    }
    
    input_id <- paste0("demo_", dem)
    input_type <- config$input_types[[dem]] %||% "text"
    
    # Create input based on type
    input_element <- create_demographic_input(
      input_id, 
      demo_config, 
      input_type,
      rv$demo_data[[dem]],
      current_lang
    )
    
    # Use language-specific question
    question_text <- if (current_lang == "en" && !is.null(demo_config$question_en)) {
      demo_config$question_en
    } else {
      demo_config$question %||% dem
    }
    
    shiny::div(
      class = "form-group",
      shiny::tags$label(question_text, class = "input-label"),
      input_element,
      if (!is.null(demo_config$help_text)) {
        shiny::tags$small(class = "form-text text-muted", demo_config$help_text)
      }
    )
  })
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page$title %||% ui_labels$demo_title, class = "card-header"),
    if (!is.null(page$description)) {
      shiny::p(page$description, class = "welcome-text")
    },
    demo_inputs
  )
}

#' Render items page with pagination
render_items_page <- function(page, config, rv, item_bank, ui_labels, current_lang = "de") {
  # Get items for this page
  if (!is.null(page$item_indices)) {
    page_items <- item_bank[page$item_indices, ]
  } else if (!is.null(page$item_range)) {
    page_items <- item_bank[page$item_range[1]:page$item_range[2], ]
  } else {
    # Use items_per_page to paginate
    items_per_page <- page$items_per_page %||% config$items_per_page %||% 5
    start_idx <- ((rv$item_page %||% 1) - 1) * items_per_page + 1
    end_idx <- min(start_idx + items_per_page - 1, nrow(item_bank))
    page_items <- item_bank[start_idx:end_idx, ]
  }
  
  # Create item UI elements
  item_elements <- lapply(seq_len(nrow(page_items)), function(i) {
    item <- page_items[i, ]
    item_id <- paste0("item_", item$id %||% i)
    
    # Get response options
    if (!is.null(item$ResponseCategories)) {
      choices <- as.numeric(unlist(strsplit(as.character(item$ResponseCategories), ",")))
    } else {
      choices <- 1:5
    }
    
    # Get response labels based on scale type
    labels <- get_response_labels(page$scale_type %||% "likert", choices, current_lang)
    
    # Get question text in the correct language
    question_text <- if (current_lang == "en" && !is.null(item$Question_EN)) {
      item$Question_EN
    } else {
      item$Question %||% item$content %||% paste("Item", i)
    }
    
    shiny::div(
      class = "item-container",
      shiny::h4(question_text),
      shiny::radioButtons(
        inputId = item_id,
        label = NULL,
        choices = setNames(choices, labels),
        selected = rv$item_responses[[item_id]] %||% character(0),
        inline = TRUE
      )
    )
  })
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
    shiny::h3(page$title %||% "Questionnaire", class = "card-header"),
    if (!is.null(page$instructions)) {
      shiny::p(page$instructions, class = "instructions-text")
    },
    item_elements
  )
}

#' Render custom page
render_custom_page <- function(page, config, rv, ui_labels, input = NULL, current_lang = "de") {
  # Special handling for filter page
  if (page$id == "page3" || page$title == "Filter") {
    # Load validation module if needed for filter functionality
    if (!exists("create_filter_page")) {
      validation_file <- system.file("R", "custom_page_flow_validation.R", package = "inrep")
      if (file.exists(validation_file)) {
        source(validation_file)
      }
    }
    
    if (exists("create_filter_page") && !is.null(input)) {
      return(create_filter_page(input, config))
    }
  }
  
  # Default rendering
  if (!is.null(page$render_function) && is.function(page$render_function)) {
    page$render_function(page, config, rv, ui_labels)
  } else {
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(page$title, class = "card-header"),
      if (!is.null(page$content)) {
        shiny::HTML(page$content)
      } else {
        shiny::p("Custom page content not defined")
      }
    )
  }
}

#' Render results page
render_results_page <- function(page, config, rv, item_bank, ui_labels, current_lang = "de") {
  # Use custom results processor if available
  if (!is.null(config$results_processor) && is.function(config$results_processor)) {
    # Check if function accepts demographics parameter
    processor_args <- names(formals(config$results_processor))
    
    # Use cat_result if available (contains cleaned responses), otherwise use raw responses
    if (!is.null(rv$cat_result) && !is.null(rv$cat_result$responses)) {
      if ("demographics" %in% processor_args) {
        results_content <- config$results_processor(rv$cat_result$responses, item_bank, rv$demographics)
      } else {
        results_content <- config$results_processor(rv$cat_result$responses, item_bank)
      }
    } else {
      # Clean responses before passing to processor
      clean_responses <- rv$responses[!is.na(rv$responses)]
      if (length(clean_responses) > 0) {
        if ("demographics" %in% processor_args) {
          results_content <- config$results_processor(clean_responses, item_bank, rv$demographics)
        } else {
          results_content <- config$results_processor(clean_responses, item_bank)
        }
      } else {
        results_content <- shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>")
      }
    }
  } else {
    results_content <- shiny::HTML("<p>Assessment completed. Thank you!</p>")
  }
  
  shiny::div(
    class = "assessment-card results-container",
    shiny::h3(page$title %||% "Results", class = "card-header"),
    results_content
  )
}

#' Render page navigation
render_page_navigation <- function(rv, config, current_page_idx, current_lang = "de") {
  total_pages <- length(config$custom_page_flow)
  current_page <- config$custom_page_flow[[current_page_idx]]
  
  # Don't show navigation on results page
  if (!is.null(current_page$type) && current_page$type == "results") {
    return(NULL)
  }
  
  shiny::div(
    class = "nav-container",
    style = "margin-top: 30px;",
    
    # Single row with all navigation elements
    shiny::div(
      class = "nav-buttons",
      style = "display: flex; justify-content: center; align-items: center; gap: 30px; margin-bottom: 15px;",
      
      # Previous button or spacer
      shiny::div(
        style = "min-width: 100px;",
        if (current_page_idx > 1) {
          shiny::actionButton(
            "prev_page",
            label = if (current_lang == "en") "Back" else "Zurück",
            class = "btn-secondary",
            style = "width: 100px;"
          )
        }
      ),
      
      # Progress indicator in the middle
      shiny::div(
        class = "page-indicator",
        style = "font-size: 14px; color: #666; white-space: nowrap;",
        if (current_lang == "en") {
          sprintf("Page %d of %d", current_page_idx, total_pages)
        } else {
          sprintf("Seite %d von %d", current_page_idx, total_pages)
        }
      ),
      
      # Next/Submit button or spacer
      shiny::div(
        style = "min-width: 100px;",
        if (current_page_idx < total_pages) {
          shiny::actionButton(
            "next_page",
            label = if (current_lang == "en") "Next" else "Weiter",
            class = "btn-primary",
            style = "width: 100px;"
          )
        } else {
          # Check if next page is results page
          next_page <- config$custom_page_flow[[current_page_idx + 1]]
          if (!is.null(next_page) && !is.null(next_page$type) && next_page$type == "results") {
            # Show submit button before results page
            shiny::actionButton(
              "submit_study",
              label = if (current_lang == "en") "Complete" else "Abschließen",
              class = "btn-success",
              style = "width: 120px;"
            )
          } else {
            # Still show next button
            shiny::actionButton(
              "next_page",
              label = if (current_lang == "en") "Next" else "Weiter",
              class = "btn-primary",
              style = "width: 100px;"
            )
          }
        }
      )
    ),
    
    # Validation errors placeholder
    shiny::uiOutput("validation_errors")
  )
}

#' Create demographic input element
create_demographic_input <- function(input_id, demo_config, input_type, current_value = NULL, current_lang = "de") {
  # Debug logging for checkbox issues
  if (input_type == "checkbox" && getOption("inrep.debug", FALSE)) {
    cat("DEBUG: Creating checkbox for", input_id, "\n")
    cat("  Options:", str(demo_config$options), "\n")
    cat("  Current value:", current_value, "\n")
  }
  
  switch(input_type,
    "text" = shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% "",
      placeholder = demo_config$placeholder %||% "",
      width = "100%"
    ),
    
    "numeric" = shiny::numericInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% NA,
      min = demo_config$min %||% 1,
      max = demo_config$max %||% 150,
      width = "100%"
    ),
    
    "select" = shiny::selectInput(
      inputId = input_id,
      label = NULL,
      choices = if (current_lang == "en" && !is.null(demo_config$options_en)) {
        c("Please select..." = "", demo_config$options_en)
      } else {
        c("Bitte wählen..." = "", demo_config$options)
      },
      selected = current_value %||% "",
      width = "100%"
    ),
    
    "radio" = shiny::radioButtons(
      inputId = input_id,
      label = NULL,
      choices = if (current_lang == "en" && !is.null(demo_config$options_en)) {
        demo_config$options_en
      } else {
        demo_config$options
      },
      selected = current_value %||% character(0),
      width = "100%"
    ),
    
    "checkbox" = {
      if (length(demo_config$options) == 1) {
        # Single checkbox - extract label with maximum safety
        label_text <- "Please confirm"  # Absolute fallback
        
        # Try to get label from names
        tryCatch({
          if (!is.null(names(demo_config$options))) {
            potential_label <- names(demo_config$options)[1]
            if (!is.null(potential_label) && 
                !is.na(potential_label) && 
                is.character(potential_label) &&
                nchar(potential_label) > 0) {
              label_text <- potential_label
            } else {
              # Try the value itself
              potential_value <- demo_config$options[1]
              if (!is.null(potential_value) && 
                  !is.na(potential_value)) {
                label_text <- as.character(potential_value)
              }
            }
          }
        }, error = function(e) {
          # Keep default "Please confirm"
        })
        
        # Ensure value is a valid boolean (never NA)
        checkbox_value <- FALSE
        tryCatch({
          if (!is.null(current_value) && !is.na(current_value)) {
            if (is.logical(current_value)) {
              checkbox_value <- current_value
            } else {
              checkbox_value <- as.character(current_value) %in% c("1", "TRUE", "true", "yes", "ja")
            }
          }
        }, error = function(e) {
          checkbox_value <- FALSE
        })
        
        # Final safety check before creating checkbox
        final_label <- tryCatch({
          if (is.null(label_text) || is.na(label_text) || !is.character(label_text) || nchar(label_text) == 0) {
            "Please confirm"
          } else {
            as.character(label_text)
          }
        }, error = function(e) "Please confirm")
        
        final_value <- tryCatch({
          if (is.null(checkbox_value) || is.na(checkbox_value) || !is.logical(checkbox_value)) {
            FALSE
          } else {
            as.logical(checkbox_value)
          }
        }, error = function(e) FALSE)
        
        # Create checkbox with absolutely guaranteed non-NA parameters
        shiny::checkboxInput(
          inputId = input_id,
          label = final_label,
          value = final_value
        )
      } else {
        # Multiple checkboxes
        shiny::checkboxGroupInput(
          inputId = input_id,
          label = NULL,
          choices = demo_config$options,
          selected = current_value %||% character(0),
          width = "100%"
        )
      }
    },
    
    # Default to text
    shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% "",
      width = "100%"
    )
  )
}

#' Get response labels for different scale types
get_response_labels <- function(scale_type, choices, language = "de") {
  n_choices <- length(choices)
  
  labels <- switch(scale_type,
    "likert" = switch(language,
      "de" = c("Stimme überhaupt nicht zu", "Stimme eher nicht zu", 
               "Teils, teils", "Stimme eher zu", "Stimme voll und ganz zu")[1:n_choices],
      "en" = c("Strongly Disagree", "Disagree", "Neutral", 
               "Agree", "Strongly Agree")[1:n_choices]
    ),
    
    "difficulty" = switch(language,
      "de" = c("sehr schwer", "eher schwer", "teils-teils", 
               "eher leicht", "sehr leicht")[1:n_choices],
      "en" = c("Very Difficult", "Difficult", "Neutral", 
               "Easy", "Very Easy")[1:n_choices]
    ),
    
    "frequency" = switch(language,
      "de" = c("Nie", "Selten", "Manchmal", "Oft", "Immer")[1:n_choices],
      "en" = c("Never", "Rarely", "Sometimes", "Often", "Always")[1:n_choices]
    ),
    
    # Default
    as.character(choices)
  )
  
  labels
}