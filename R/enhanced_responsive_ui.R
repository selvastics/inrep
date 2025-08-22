#' Enhanced Responsive UI Module
#' 
#' Provides responsive, mobile-optimized UI with improved themes and layouts
#' 
#' @name enhanced_responsive_ui
#' @docType data
NULL

#' Get Responsive CSS
#' 
#' Returns comprehensive responsive CSS for all screen sizes
#' 
#' @param theme Theme name or custom theme object
#' @return CSS string with responsive styles
#' @export
get_responsive_css <- function(theme = "modern") {
  base_css <- '
  /* Responsive Base Styles */
  * {
    box-sizing: border-box;
  }
  
  body {
    margin: 0;
    padding: 0;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
  
  /* Container System */
  .container {
    width: 100%;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 15px;
  }
  
  /* Responsive Grid */
  .row {
    display: flex;
    flex-wrap: wrap;
    margin: 0 -15px;
  }
  
  .col {
    flex: 1;
    padding: 0 15px;
  }
  
  /* Mobile First Breakpoints */
  @media (max-width: 575px) {
    /* Extra small devices (phones) */
    .container {
      padding: 0 10px;
    }
    
    .col-xs-12 {
      flex: 0 0 100%;
      max-width: 100%;
    }
    
    .hide-mobile {
      display: none !important;
    }
    
    .survey-container {
      padding: 10px;
    }
    
    .question-text {
      font-size: 16px;
      line-height: 1.5;
    }
    
    .btn {
      width: 100%;
      padding: 12px;
      font-size: 16px;
    }
    
    /* Touch-friendly inputs */
    input[type="radio"],
    input[type="checkbox"] {
      min-width: 24px;
      min-height: 24px;
      margin: 8px;
    }
    
    .radio-group label,
    .checkbox-group label {
      padding: 12px;
      margin: 4px 0;
      display: block;
      background: #f8f9fa;
      border-radius: 8px;
      cursor: pointer;
    }
  }
  
  @media (min-width: 576px) and (max-width: 767px) {
    /* Small devices (landscape phones) */
    .col-sm-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
    
    .col-sm-12 {
      flex: 0 0 100%;
      max-width: 100%;
    }
  }
  
  @media (min-width: 768px) and (max-width: 991px) {
    /* Medium devices (tablets) */
    .col-md-4 {
      flex: 0 0 33.333333%;
      max-width: 33.333333%;
    }
    
    .col-md-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
    
    .col-md-8 {
      flex: 0 0 66.666667%;
      max-width: 66.666667%;
    }
  }
  
  @media (min-width: 992px) and (max-width: 1199px) {
    /* Large devices (desktops) */
    .col-lg-3 {
      flex: 0 0 25%;
      max-width: 25%;
    }
    
    .col-lg-4 {
      flex: 0 0 33.333333%;
      max-width: 33.333333%;
    }
    
    .col-lg-6 {
      flex: 0 0 50%;
      max-width: 50%;
    }
  }
  
  @media (min-width: 1200px) {
    /* Extra large devices (large desktops) */
    .col-xl-2 {
      flex: 0 0 16.666667%;
      max-width: 16.666667%;
    }
    
    .col-xl-3 {
      flex: 0 0 25%;
      max-width: 25%;
    }
  }
  
  /* Enhanced Progress Bar */
  .progress-container {
    position: relative;
    background: #e9ecef;
    border-radius: 10px;
    height: 8px;
    overflow: hidden;
    margin: 20px 0;
  }
  
  .progress-bar {
    height: 100%;
    background: linear-gradient(90deg, #007bff, #0056b3);
    border-radius: 10px;
    transition: width 0.5s ease;
    position: relative;
  }
  
  .progress-text {
    position: absolute;
    top: -25px;
    right: 0;
    font-size: 14px;
    color: #6c757d;
  }
  
  /* Card System */
  .card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    padding: 20px;
    margin-bottom: 20px;
    transition: transform 0.2s, box-shadow 0.2s;
  }
  
  .card:hover {
    /* Removed transform to prevent positioning issues */
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  }
  
  /* Responsive Tables */
  .table-responsive {
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
  
  table {
    width: 100%;
    border-collapse: collapse;
  }
  
  @media (max-width: 767px) {
    table {
      font-size: 14px;
    }
    
    th, td {
      padding: 8px 4px;
    }
  }
  
  /* Accessibility Features */
  .sr-only {
    position: absolute;
    width: 1px;
    height: 1px;
    padding: 0;
    margin: -1px;
    overflow: hidden;
    clip: rect(0,0,0,0);
    white-space: nowrap;
    border: 0;
  }
  
  /* Focus Indicators */
  *:focus {
    outline: 3px solid #4A90E2;
    outline-offset: 2px;
  }
  
  /* High Contrast Mode Support */
  @media (prefers-contrast: high) {
    .card {
      border: 2px solid black;
    }
    
    .btn {
      border: 2px solid currentColor;
    }
  }
  
  /* Dark Mode Support */
  @media (prefers-color-scheme: dark) {
    body {
      background: #1a1a1a;
      color: #ffffff;
    }
    
    .card {
      background: #2d2d2d;
      color: #ffffff;
    }
    
    input, select, textarea {
      background: #3d3d3d;
      color: #ffffff;
      border-color: #555;
    }
  }
  
  /* Print Styles */
  @media print {
    .no-print {
      display: none !important;
    }
    
    body {
      font-size: 12pt;
    }
    
    .card {
      box-shadow: none;
      border: 1px solid #ddd;
    }
  }
  '
  
  return(base_css)
}

#' Create Responsive Question UI
#' 
#' Creates responsive UI for different question types
#' 
#' @param question_type Type of question
#' @param question_id Unique question ID
#' @param question_text Question text
#' @param options Answer options
#' @param required Is answer required
#' @param config Additional configuration
#' @return Shiny UI element
#' @export
create_responsive_question <- function(
  question_type,
  question_id,
  question_text,
  options = NULL,
  required = FALSE,
  config = list()
) {
  
  # Main question container
  question_ui <- shiny::div(
    class = "question-container card",
    `data-question-id` = question_id,
    
    # Question header
    shiny::div(
      class = "question-header",
      shiny::h3(
        class = "question-text",
        question_text,
        if (required) shiny::span(class = "required-indicator", "*")
      )
    ),
    
    # Question body based on type
    shiny::div(
      class = "question-body",
      switch(question_type,
        # Single choice (radio buttons)
        "single" = create_radio_group(question_id, options, config),
        
        # Multiple choice (checkboxes)
        "multiple" = create_checkbox_group(question_id, options, config),
        
        # Slider
        "slider" = create_slider_input(question_id, config),
        
        # Text input
        "text" = create_text_input(question_id, config),
        
        # Matrix/Grid
        "matrix" = create_matrix_question(question_id, options, config),
        
        # Ranking
        "ranking" = create_ranking_question(question_id, options, config),
        
        # Likert scale
        "likert" = create_likert_scale(question_id, config),
        
        # Date picker
        "date" = shiny::dateInput(
          question_id,
          label = NULL,
          width = "100%"
        ),
        
        # File upload
        "file" = shiny::fileInput(
          question_id,
          label = NULL,
          width = "100%",
          accept = config$accept %||% NULL
        ),
        
        # Default fallback
        create_radio_group(question_id, options, config)
      )
    ),
    
    # Error message container
    shiny::div(
      id = paste0(question_id, "_error"),
      class = "error-message",
      style = "display: none; color: red; margin-top: 5px;"
    )
  )
  
  return(question_ui)
}

#' Create Radio Button Group
#' 
#' Creates responsive radio button group
#' 
#' @param input_id Input ID
#' @param choices Choice options
#' @param config Configuration
#' @return Shiny UI element
create_radio_group <- function(input_id, choices, config = list()) {
  shiny::div(
    class = "radio-group",
    shiny::radioButtons(
      input_id,
      label = NULL,
      choices = choices,
      selected = config$selected %||% character(0),
      inline = config$inline %||% FALSE,
      width = "100%"
    )
  )
}

#' Create Checkbox Group
#' 
#' Creates responsive checkbox group
#' 
#' @param input_id Input ID
#' @param choices Choice options
#' @param config Configuration
#' @return Shiny UI element
create_checkbox_group <- function(input_id, choices, config = list()) {
  shiny::div(
    class = "checkbox-group",
    shiny::checkboxGroupInput(
      input_id,
      label = NULL,
      choices = choices,
      selected = config$selected %||% character(0),
      inline = config$inline %||% FALSE,
      width = "100%"
    )
  )
}

#' Create Slider Input
#' 
#' Creates responsive slider input
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_slider_input <- function(input_id, config = list()) {
  shiny::sliderInput(
    input_id,
    label = NULL,
    min = config$min %||% 0,
    max = config$max %||% 100,
    value = config$value %||% 50,
    step = config$step %||% 1,
    width = "100%",
    ticks = config$ticks %||% TRUE
  )
}

#' Create Text Input
#' 
#' Creates responsive text input
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_text_input <- function(input_id, config = list()) {
  if (config$multiline %||% FALSE) {
    shiny::textAreaInput(
      input_id,
      label = NULL,
      value = config$value %||% "",
      width = "100%",
      height = config$height %||% "100px",
      placeholder = config$placeholder %||% "",
      resize = config$resize %||% "vertical"
    )
  } else {
    shiny::textInput(
      input_id,
      label = NULL,
      value = config$value %||% "",
      width = "100%",
      placeholder = config$placeholder %||% ""
    )
  }
}

#' Create Matrix Question
#' 
#' Creates responsive matrix/grid question
#' 
#' @param input_id Input ID
#' @param options Matrix options (rows and columns)
#' @param config Configuration
#' @return Shiny UI element
create_matrix_question <- function(input_id, options, config = list()) {
  rows <- options$rows %||% c("Row 1", "Row 2")
  cols <- options$cols %||% c("Col 1", "Col 2")
  
  shiny::div(
    class = "matrix-question table-responsive",
    shiny::tags$table(
      class = "table matrix-table",
      shiny::tags$thead(
        shiny::tags$tr(
          shiny::tags$th(""),
          lapply(cols, function(col) shiny::tags$th(col))
        )
      ),
      shiny::tags$tbody(
        lapply(seq_along(rows), function(i) {
          shiny::tags$tr(
            shiny::tags$td(rows[i]),
            lapply(seq_along(cols), function(j) {
              shiny::tags$td(
                shiny::tags$input(
                  type = if (config$multiple %||% FALSE) "checkbox" else "radio",
                  name = paste0(input_id, "_row_", i),
                  value = j,
                  id = paste0(input_id, "_", i, "_", j)
                )
              )
            })
          )
        })
      )
    )
  )
}

#' Create Ranking Question
#' 
#' Creates drag-and-drop ranking question
#' 
#' @param input_id Input ID
#' @param options Items to rank
#' @param config Configuration
#' @return Shiny UI element
create_ranking_question <- function(input_id, options, config = list()) {
  shiny::div(
    class = "ranking-question",
    id = input_id,
    shiny::tags$ul(
      class = "ranking-list sortable",
      `data-input-id` = input_id,
      lapply(seq_along(options), function(i) {
        shiny::tags$li(
          class = "ranking-item",
          `data-value` = i,
          shiny::span(class = "rank-number", paste0(i, ".")),
          shiny::span(class = "rank-text", options[i]),
          shiny::span(class = "drag-handle", "☰")
        )
      })
    ),
    shiny::tags$script(HTML(sprintf('
      $(function() {
        $("#%s .sortable").sortable({
          handle: ".drag-handle",
          update: function(event, ui) {
            var order = $(this).sortable("toArray", {attribute: "data-value"});
            Shiny.setInputValue("%s", order);
          }
        });
      });
    ', input_id, input_id)))
  )
}

#' Create Likert Scale
#' 
#' Creates responsive Likert scale
#' 
#' @param input_id Input ID
#' @param config Configuration
#' @return Shiny UI element
create_likert_scale <- function(input_id, config = list()) {
  levels <- config$levels %||% 5
  labels <- config$labels %||% c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
  
  if (length(labels) != levels) {
    labels <- seq_len(levels)
  }
  
  shiny::div(
    class = "likert-scale",
    shiny::radioButtons(
      input_id,
      label = NULL,
      choices = setNames(seq_len(levels), labels),
      selected = character(0),
      inline = TRUE,
      width = "100%"
    )
  )
}

#' Apply Responsive Theme
#' 
#' Applies responsive theme to Shiny app
#' 
#' @param theme_name Name of theme to apply
#' @param custom_css Additional custom CSS
#' @return HTML head tags
#' @export
apply_responsive_theme <- function(theme_name = "modern", custom_css = NULL) {
  shiny::tags$head(
    # Viewport meta tag for mobile
    shiny::tags$meta(
      name = "viewport",
      content = "width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes"
    ),
    
    # Base responsive CSS
    shiny::tags$style(HTML(get_responsive_css(theme_name))),
    
    # Theme-specific CSS
    shiny::tags$style(HTML(get_theme_styles(theme_name))),
    
    # Custom CSS if provided
    if (!is.null(custom_css)) shiny::tags$style(HTML(custom_css)),
    
    # jQuery UI for sortable
    shiny::tags$script(src = "https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"),
    
    # Touch support for mobile
    shiny::tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js")
  )
}

#' Get Theme Styles
#' 
#' Returns theme-specific styles
#' 
#' @param theme_name Name of theme
#' @return CSS string
get_theme_styles <- function(theme_name) {
  themes <- list(
    modern = '
      :root {
        --primary: #007bff;
        --secondary: #6c757d;
        --success: #28a745;
        --danger: #dc3545;
        --warning: #ffc107;
        --info: #17a2b8;
        --light: #f8f9fa;
        --dark: #343a40;
      }
      
      .btn-primary {
        background: var(--primary);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        cursor: pointer;
        transition: all 0.3s;
      }
      
      .btn-primary:hover {
        background: #0056b3;
        /* Removed transform to prevent positioning issues */
      }
    ',
    
    minimal = '
      :root {
        --primary: #000000;
        --secondary: #666666;
        --background: #ffffff;
        --border: #e0e0e0;
      }
      
      body {
        background: var(--background);
        color: var(--primary);
      }
      
      .card {
        border: 1px solid var(--border);
        box-shadow: none;
      }
    ',
    
    professional = '
      :root {
        --primary: #2c3e50;
        --secondary: #34495e;
        --accent: #3498db;
        --background: #ecf0f1;
      }
      
      body {
        background: var(--background);
        color: var(--primary);
      }
      
      .card {
        background: white;
        border-left: 4px solid var(--accent);
      }
    '
  )
  
  return(themes[[theme_name]] %||% themes[["modern"]])
}