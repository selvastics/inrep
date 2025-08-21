#' Smooth Page Transitions for inrep
#'
#' This module provides smooth, flicker-free page transitions
#' using CSS animations and proper DOM management
#'
#' @export

#' Create smooth transition CSS
get_transition_css <- function() {
  "
  /* Page transition animations */
  .page-container {
    position: relative;
    min-height: 400px;
  }
  
  .page-content {
    opacity: 1;
    transform: translateX(0);
    transition: all 0.3s ease-in-out;
  }
  
  .page-content.fade-out {
    opacity: 0;
    transform: translateX(-20px);
  }
  
  .page-content.fade-in {
    animation: fadeInPage 0.3s ease-in-out;
  }
  
  @keyframes fadeInPage {
    from {
      opacity: 0;
      transform: translateX(20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }
  
  /* Prevent content jumping */
  .assessment-card {
    min-height: 300px;
    opacity: 0;
    animation: fadeInCard 0.4s ease-in-out forwards;
    animation-delay: 0.1s;
  }
  
  @keyframes fadeInCard {
    from {
      opacity: 0;
      transform: translateY(10px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
  
  /* Loading state */
  .loading-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(255, 255, 255, 0.9);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.2s ease-in-out;
  }
  
  .loading-overlay.active {
    opacity: 1;
    pointer-events: all;
  }
  
  .loading-spinner {
    width: 40px;
    height: 40px;
    border: 3px solid #f3f3f3;
    border-top: 3px solid var(--primary-color, #007bff);
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
  
  /* Smooth button states */
  .btn-primary, .btn-secondary {
    transition: all 0.2s ease-in-out;
    transform: translateY(0);
  }
  
  .btn-primary:hover, .btn-secondary:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.15);
  }
  
  .btn-primary:active, .btn-secondary:active {
    transform: translateY(0);
  }
  
  /* Prevent text selection during transitions */
  .transitioning {
    user-select: none;
    pointer-events: none;
  }
  
  /* Radio button smooth transitions */
  .radio-group-container input[type='radio'] {
    transition: all 0.2s ease;
  }
  
  .radio-group-container label {
    transition: all 0.2s ease;
    cursor: pointer;
  }
  
  .radio-group-container label:hover {
    color: var(--primary-color, #007bff);
  }
  
  /* Progress bar smooth updates */
  .progress-bar {
    transition: width 0.4s ease-in-out;
  }
  
  /* Prevent layout shift */
  .form-group {
    min-height: 80px;
  }
  
  .item-container {
    min-height: 100px;
    padding: 15px 0;
    border-bottom: 1px solid #f0f0f0;
  }
  
  .item-container:last-child {
    border-bottom: none;
  }
  "
}

#' Render page with smooth transition
#'
#' @export
render_page_smooth <- function(page_content, transition_type = "fade") {
  shiny::div(
    class = "page-container",
    shiny::div(
      class = "loading-overlay",
      id = "page-loader",
      shiny::div(class = "loading-spinner")
    ),
    shiny::div(
      class = paste("page-content", transition_type),
      id = "page-content",
      page_content
    ),
    shiny::tags$script(shiny::HTML("
      // Smooth page transition
      setTimeout(function() {
        document.getElementById('page-loader').classList.remove('active');
        document.getElementById('page-content').classList.add('fade-in');
      }, 100);
    "))
  )
}

#' Create navigation buttons with loading state
#'
#' @export
create_nav_buttons <- function(show_back = TRUE, 
                              show_next = TRUE, 
                              next_label = "Next",
                              back_label = "Back",
                              submit_mode = FALSE) {
  shiny::div(
    class = "nav-buttons",
    style = "margin-top: 30px; display: flex; justify-content: space-between; align-items: center;",
    
    # Back button
    if (show_back) {
      shiny::actionButton(
        "back_btn",
        back_label,
        class = "btn btn-secondary",
        style = "min-width: 100px;"
      )
    } else {
      shiny::div(style = "width: 100px;")  # Spacer
    },
    
    # Progress indicator (optional)
    shiny::div(
      id = "nav-progress",
      style = "flex: 1; text-align: center; color: #666; font-size: 14px;"
    ),
    
    # Next/Submit button
    if (show_next) {
      shiny::actionButton(
        if (submit_mode) "submit_btn" else "next_btn",
        next_label,
        class = if (submit_mode) "btn btn-success" else "btn btn-primary",
        style = "min-width: 100px;",
        onclick = "this.classList.add('loading'); this.disabled = true;"
      )
    } else {
      shiny::div(style = "width: 100px;")  # Spacer
    }
  )
}

#' JavaScript for smooth transitions
#'
#' @export
get_transition_js <- function() {
  "
  // Smooth page transition handler
  Shiny.addCustomMessageHandler('smoothTransition', function(message) {
    var content = document.getElementById('page-content');
    var loader = document.getElementById('page-loader');
    
    // Start transition
    content.classList.add('fade-out');
    loader.classList.add('active');
    
    // Wait for fade out
    setTimeout(function() {
      // Update content (handled by Shiny)
      
      // Fade in new content
      setTimeout(function() {
        content.classList.remove('fade-out');
        content.classList.add('fade-in');
        loader.classList.remove('active');
        
        // Re-enable buttons
        var buttons = document.querySelectorAll('.btn');
        buttons.forEach(function(btn) {
          btn.classList.remove('loading');
          btn.disabled = false;
        });
        
        // Scroll to top smoothly
        window.scrollTo({top: 0, behavior: 'smooth'});
      }, 100);
    }, 300);
  });
  
  // Prevent double-clicks
  document.addEventListener('click', function(e) {
    if (e.target.classList.contains('btn') && e.target.classList.contains('loading')) {
      e.preventDefault();
      e.stopPropagation();
      return false;
    }
  });
  
  // Handle form validation smoothly
  Shiny.addCustomMessageHandler('validateForm', function(message) {
    var invalid = document.querySelectorAll('.is-invalid');
    invalid.forEach(function(el) {
      el.classList.remove('is-invalid');
    });
    
    if (message.errors && message.errors.length > 0) {
      message.errors.forEach(function(error) {
        var el = document.getElementById(error.field);
        if (el) {
          el.classList.add('is-invalid');
          // Smooth scroll to first error
          if (message.errors.indexOf(error) === 0) {
            el.scrollIntoView({behavior: 'smooth', block: 'center'});
          }
        }
      });
    }
  });
  "
}

#' Enhanced render function for custom page flow
#'
#' @export
render_custom_page_enhanced <- function(page, config, rv, item_bank, ui_labels) {
  # Determine page type and render accordingly
  page_content <- switch(page$type,
    "instructions" = render_instructions_smooth(page, config, ui_labels),
    "demographics" = render_demographics_smooth(page, config, rv, ui_labels),
    "items" = render_items_smooth(page, config, rv, item_bank, ui_labels),
    "custom" = render_custom_smooth(page),
    "results" = render_results_smooth(page, config, rv, item_bank, ui_labels),
    shiny::div("Unknown page type")
  )
  
  # Wrap in smooth transition container
  render_page_smooth(page_content)
}

#' Smooth instructions page
render_instructions_smooth <- function(page, config, ui_labels) {
  shiny::div(
    class = "assessment-card",
    style = "opacity: 0; animation: fadeInCard 0.5s ease-out forwards;",
    shiny::h2(page$title %||% ui_labels$instructions_title, 
              class = "card-header",
              style = "margin-bottom: 25px;"),
    shiny::div(
      class = "instructions-content",
      shiny::HTML(page$content %||% ui_labels$instructions_text)
    ),
    if (!is.null(page$consent) && page$consent) {
      shiny::div(
        class = "consent-container",
        style = "margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;",
        shiny::checkboxInput(
          "consent_checkbox",
          page$consent_text %||% ui_labels$consent_text,
          value = FALSE
        )
      )
    }
  )
}

#' Smooth demographics page
render_demographics_smooth <- function(page, config, rv, ui_labels) {
  demo_vars <- page$demographics %||% config$demographics
  
  if (is.null(demo_vars)) {
    return(shiny::div("No demographics configured"))
  }
  
  # Create inputs with staggered animation
  demo_inputs <- lapply(seq_along(demo_vars), function(i) {
    dem <- demo_vars[i]
    demo_config <- config$demographic_configs[[dem]]
    
    if (is.null(demo_config)) return(NULL)
    
    input_id <- paste0("demo_", dem)
    input_type <- config$input_types[[dem]] %||% "text"
    
    shiny::div(
      class = "form-group",
      style = paste0("opacity: 0; animation: fadeInCard 0.4s ease-out forwards; animation-delay: ", 
                     0.1 + (i * 0.05), "s;"),
      shiny::tags$label(demo_config$question %||% dem, 
                       class = "input-label",
                       style = "font-weight: 500; margin-bottom: 8px;"),
      create_demographic_input(input_id, demo_config, input_type, rv$demo_data[[dem]]),
      if (!is.null(demo_config$help_text)) {
        shiny::tags$small(class = "form-text text-muted", demo_config$help_text)
      }
    )
  })
  
  shiny::div(
    class = "assessment-card",
    shiny::h3(page$title %||% ui_labels$demo_title, class = "card-header"),
    if (!is.null(page$description)) {
      shiny::p(page$description, class = "welcome-text", 
               style = "margin-bottom: 25px; color: #666;")
    },
    demo_inputs
  )
}

#' Smooth items page
render_items_smooth <- function(page, config, rv, item_bank, ui_labels) {
  # Get items for this page
  if (!is.null(page$item_indices)) {
    page_items <- item_bank[page$item_indices, , drop = FALSE]
  } else {
    return(shiny::div("No items configured"))
  }
  
  # Create items with staggered animation
  item_elements <- lapply(seq_len(nrow(page_items)), function(i) {
    item <- page_items[i, ]
    item_id <- paste0("item_", item$id %||% page$item_indices[i])
    
    # Get response options
    choices <- if (!is.null(item$ResponseCategories)) {
      as.numeric(unlist(strsplit(as.character(item$ResponseCategories), ",")))
    } else {
      1:5
    }
    
    labels <- get_response_labels(page$scale_type %||% "likert", choices, config$language)
    
    shiny::div(
      class = "item-container",
      style = paste0("opacity: 0; animation: fadeInCard 0.4s ease-out forwards; animation-delay: ",
                     0.1 + (i * 0.05), "s;"),
      shiny::h4(item$Question %||% item$content %||% paste("Item", i),
                style = "color: #333; margin-bottom: 15px;"),
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
    shiny::h3(page$title %||% "Questionnaire", class = "card-header"),
    if (!is.null(page$instructions)) {
      shiny::p(page$instructions, class = "instructions-text",
               style = "margin-bottom: 25px; color: #666; font-style: italic;")
    },
    item_elements
  )
}

#' Smooth custom page
render_custom_smooth <- function(page) {
  shiny::div(
    class = "assessment-card",
    style = "opacity: 0; animation: fadeInCard 0.5s ease-out forwards;",
    if (!is.null(page$title)) {
      shiny::h3(page$title, class = "card-header")
    },
    shiny::HTML(page$content %||% "")
  )
}

#' Smooth results page
render_results_smooth <- function(page, config, rv, item_bank, ui_labels) {
  shiny::div(
    class = "assessment-card",
    style = "opacity: 0; animation: fadeInCard 0.5s ease-out forwards;",
    shiny::h3(page$title %||% "Results", class = "card-header"),
    shiny::div(
      id = "results-container",
      style = "min-height: 300px;",
      if (!is.null(config$results_processor) && is.function(config$results_processor)) {
        if (!is.null(rv$cat_result) && !is.null(rv$cat_result$responses)) {
          config$results_processor(rv$cat_result$responses, item_bank)
        } else {
          clean_responses <- rv$responses[!is.na(rv$responses)]
          if (length(clean_responses) > 0) {
            config$results_processor(clean_responses, item_bank)
          } else {
            shiny::HTML("<p>No responses available for analysis.</p>")
          }
        }
      } else {
        shiny::HTML("<p>Assessment completed. Thank you!</p>")
      }
    )
  )
}