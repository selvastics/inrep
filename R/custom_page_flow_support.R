#' Custom Page Flow Support Functions
#'
#' Functions to handle custom page flows like HilFo study
#' These ensure compatibility with complex studies while maintaining fast loading
#'
#' @name custom_page_flow_support
#' @keywords internal

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

#' Render custom page
render_custom_page <- function(page, config, rv, ui_labels, input) {
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Get title based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% ""
  }
  
  shiny::div(
    class = "assessment-card custom-page",
    style = "margin: 0 auto !important; position: relative !important;",
    if (page_title != "") shiny::h3(page_title, class = "card-header"),
    if (!is.null(page$content)) {
      shiny::HTML(page$content)
    } else if (!is.null(page$html)) {
      shiny::HTML(page$html)
    } else {
      shiny::p("Custom page content not provided")
    }
  )
}

#' Render page navigation
render_page_navigation <- function(rv, config, current_page_idx) {
  total_pages <- length(config$custom_page_flow)
  
  # Check if navigation should be shown for this page
  current_page <- config$custom_page_flow[[current_page_idx]]
  if (isTRUE(current_page$hide_navigation)) {
    return(NULL)
  }
  
  # Determine which buttons to show
  show_prev <- current_page_idx > 1 && !isTRUE(current_page$hide_prev)
  show_next <- current_page_idx < total_pages && !isTRUE(current_page$hide_next)
  show_submit <- current_page_idx == total_pages || isTRUE(current_page$show_submit)
  
  shiny::div(
    class = "nav-buttons",
    style = "margin-top: 30px; text-align: center;",
    
    # Previous button
    if (show_prev) {
      shiny::actionButton(
        "prev_page",
        rv$ui_labels$prev_button %||% "Back",
        class = "btn btn-secondary",
        style = "margin-right: 10px;"
      )
    },
    
    # Next button
    if (show_next) {
      shiny::actionButton(
        "next_page",
        rv$ui_labels$next_button %||% "Next",
        class = "btn btn-primary"
      )
    },
    
    # Submit button
    if (show_submit) {
      shiny::actionButton(
        "submit_study",
        rv$ui_labels$submit_button %||% "Submit",
        class = "btn btn-success"
      )
    }
  )
}

#' Render instructions page
render_instructions_page <- function(page, config, ui_labels) {
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important;",
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
          label = page$consent_text %||% "I agree to participate",
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
  
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Create inputs for each demographic
  demo_inputs <- lapply(demo_vars, function(dem) {
    demo_config <- config$demographic_configs[[dem]]
    
    if (is.null(demo_config)) {
      return(NULL)
    }
    
    # Get question text based on language
    question_text <- if (current_lang == "en" && !is.null(demo_config$question_en)) {
      demo_config$question_en
    } else {
      demo_config$question %||% demo_config$question_de %||% dem
    }
    
    input_id <- paste0("demo_", dem)
    input_type <- config$input_types[[dem]] %||% demo_config$type %||% "text"
    
    # Create the input element
    input_element <- create_demographic_input(
      input_id, 
      demo_config, 
      input_type,
      rv$demo_data[[dem]],
      current_lang
    )
    
    shiny::div(
      class = "form-group",
      shiny::tags$label(question_text, class = "input-label"),
      input_element,
      if (!is.null(demo_config$help_text)) {
        shiny::tags$small(class = "form-text text-muted", demo_config$help_text)
      }
    )
  })
  
  # Get page title based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% ui_labels$demo_title
  }
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important;",
    shiny::h3(page_title, class = "card-header"),
    if (!is.null(page$description)) {
      shiny::p(page$description, class = "welcome-text")
    },
    demo_inputs
  )
}

#' Create demographic input element
create_demographic_input <- function(input_id, demo_config, input_type, current_value = NULL, language = "de") {
  
  # Get options based on language
  options <- if (language == "en" && !is.null(demo_config$options_en)) {
    demo_config$options_en
  } else {
    demo_config$options %||% demo_config$choices
  }
  
  # Create input based on type
  switch(input_type,
    "text" = shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% "",
      placeholder = demo_config$placeholder %||% ""
    ),
    
    "numeric" = shiny::numericInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% NA,
      min = demo_config$min,
      max = demo_config$max
    ),
    
    "select" = shiny::selectInput(
      inputId = input_id,
      label = NULL,
      choices = c("" = "", options),
      selected = current_value %||% ""
    ),
    
    "radio" = shiny::radioButtons(
      inputId = input_id,
      label = NULL,
      choices = options,
      selected = current_value %||% character(0),
      inline = demo_config$inline %||% FALSE
    ),
    
    "checkbox" = shiny::checkboxGroupInput(
      inputId = input_id,
      label = NULL,
      choices = options,
      selected = current_value %||% character(0),
      inline = demo_config$inline %||% FALSE
    ),
    
    # Default to text input
    shiny::textInput(
      inputId = input_id,
      label = NULL,
      value = current_value %||% ""
    )
  )
}

#' Render items page
render_items_page <- function(page, config, rv, item_bank, ui_labels) {
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Get items for this page
  if (!is.null(page$item_indices)) {
    page_items <- item_bank[page$item_indices, ]
  } else if (!is.null(page$item_range)) {
    page_items <- item_bank[page$item_range[1]:page$item_range[2], ]
  } else {
    # Default: show all items
    page_items <- item_bank
  }
  
  # Create item UI elements
  item_elements <- lapply(seq_len(nrow(page_items)), function(i) {
    item <- page_items[i, ]
    item_id <- paste0("item_", item$id %||% page$item_indices[i] %||% i)
    
    # Get question text based on language
    question_text <- if (current_lang == "en" && !is.null(item$Question_EN)) {
      item$Question_EN
    } else {
      item$Question %||% item$content %||% paste("Item", i)
    }
    
    # Get response options
    if (!is.null(item$ResponseCategories)) {
      choices <- as.numeric(unlist(strsplit(as.character(item$ResponseCategories), ",")))
    } else {
      choices <- 1:5
    }
    
    # Get response labels based on scale type and language
    labels <- get_response_labels(page$scale_type %||% "likert", choices, current_lang)
    
    shiny::div(
      class = "item-container",
      style = "margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 5px;",
      shiny::h4(question_text, style = "margin-bottom: 15px;"),
      shiny::radioButtons(
        inputId = item_id,
        label = NULL,
        choices = setNames(choices, labels),
        selected = rv$item_responses[[item_id]] %||% character(0),
        inline = TRUE
      )
    )
  })
  
  # Get page title and instructions based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% "Questionnaire"
  }
  
  page_instructions <- if (current_lang == "en" && !is.null(page$instructions_en)) {
    page$instructions_en
  } else {
    page$instructions %||% ""
  }
  
  shiny::div(
    class = "assessment-card",
    style = "margin: 0 auto !important; position: relative !important;",
    shiny::h3(page_title, class = "card-header"),
    if (page_instructions != "") shiny::p(page_instructions, class = "instructions"),
    item_elements
  )
}

#' Get response labels based on scale type and language
get_response_labels <- function(scale_type, choices, language = "de") {
  
  if (scale_type == "likert") {
    if (language == "en") {
      return(c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")[choices])
    } else {
      return(c("trifft nicht zu", "trifft eher nicht zu", "teils/teils", 
               "trifft eher zu", "trifft zu")[choices])
    }
  } else if (scale_type == "difficulty") {
    if (language == "en") {
      return(c("Very Easy", "Easy", "Moderate", "Difficult", "Very Difficult")[choices])
    } else {
      return(c("Sehr leicht", "Leicht", "Mittel", "Schwer", "Sehr schwer")[choices])
    }
  } else {
    # Default numeric labels
    return(as.character(choices))
  }
}

#' Render results page
render_results_page <- function(page, config, rv, item_bank, ui_labels) {
  # Get current language
  current_lang <- rv$language %||% config$language %||% "de"
  
  # Check if custom results processor is defined
  if (!is.null(config$results_processor) && is.function(config$results_processor)) {
    # Call the custom results processor (e.g., create_hilfo_report)
    results_content <- config$results_processor(
      responses = rv$responses,
      item_bank = item_bank,
      demographics = rv$demo_data,
      session = rv
    )
  } else {
    # Default results display
    results_content <- shiny::div(
      shiny::h4("Assessment Complete"),
      shiny::p(paste("Total items completed:", length(rv$responses))),
      shiny::p("Thank you for your participation!")
    )
  }
  
  # Get page title based on language
  page_title <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% ui_labels$results_title %||% "Results"
  }
  
  shiny::div(
    class = "assessment-card results-page",
    style = "margin: 0 auto !important; position: relative !important;",
    shiny::h3(page_title, class = "card-header"),
    results_content
  )
}