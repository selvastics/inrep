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
process_page_flow <- function(config, rv, input, output, session, item_bank, ui_labels, logger) {
  
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
  
  # Render page based on type
  page_ui <- switch(current_page$type,
    
    "instructions" = render_instructions_page(current_page, config, ui_labels),
    
    "demographics" = render_demographics_page(current_page, config, rv, ui_labels),
    
    "items" = render_items_page(current_page, config, rv, item_bank, ui_labels),
    
    "custom" = render_custom_page(current_page, config, rv, ui_labels, input),
    
    "results" = render_results_page(current_page, config, rv, item_bank, ui_labels),
    
    # Default fallback
    shiny::div(
      class = "assessment-card",
      style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
      shiny::h3(current_page$title %||% "Page", class = "card-header"),
      shiny::p("Page type not recognized")
    )
  )
  
  # Add navigation
  nav_ui <- render_page_navigation(rv, config, current_page_idx)
  
  shiny::tagList(
    page_ui,
    nav_ui
  )
}

#' Render instructions page
render_instructions_page <- function(page, config, ui_labels) {
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
render_demographics_page <- function(page, config, rv, ui_labels) {
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
      rv$demo_data[[dem]]
    )
    
    shiny::div(
      class = "form-group",
      shiny::tags$label(demo_config$question %||% dem, class = "input-label"),
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
render_items_page <- function(page, config, rv, item_bank, ui_labels) {
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
    labels <- get_response_labels(page$scale_type %||% "likert", choices, config$language)
    
    shiny::div(
      class = "item-container",
      shiny::h4(item$Question %||% item$content %||% paste("Item", i)),
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
render_custom_page <- function(page, config, rv, ui_labels, input = NULL) {
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
render_results_page <- function(page, config, rv, item_bank, ui_labels) {
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
render_page_navigation <- function(rv, config, current_page_idx) {
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
            label = "Zurück",
            class = "btn-secondary",
            style = "width: 100px;"
          )
        }
      ),
      
      # Progress indicator in the middle
      shiny::div(
        class = "page-indicator",
        style = "font-size: 14px; color: #666; white-space: nowrap;",
        sprintf("Seite %d von %d", current_page_idx, total_pages)
      ),
      
      # Next/Submit button or spacer
      shiny::div(
        style = "min-width: 100px;",
        if (current_page_idx < total_pages) {
          shiny::actionButton(
            "next_page",
            label = "Weiter",
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
              label = "Abschließen",
              class = "btn-success",
              style = "width: 120px;"
            )
          } else {
            # Still show next button
            shiny::actionButton(
              "next_page",
              label = "Weiter",
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
create_demographic_input <- function(input_id, demo_config, input_type, current_value = NULL) {
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
      choices = c("Bitte wählen..." = "", demo_config$options),
      selected = current_value %||% "",
      width = "100%"
    ),
    
    "radio" = shiny::radioButtons(
      inputId = input_id,
      label = NULL,
      choices = demo_config$options,
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