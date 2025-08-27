#' Ensure Font Consistency in Theme CSS
#' 
#' Adds font consistency CSS to ensure all elements use the theme's font-family
#' 
#' @param theme_css The base theme CSS
#' @return Enhanced CSS with font consistency rules
#' @export
ensure_font_consistency <- function(theme_css) {
  # Add font consistency rules
  font_consistency_css <- "
    /* Ensure font consistency across all elements */
    body, 
    input, 
    select, 
    textarea, 
    button,
    .btn,
    .shiny-input-container,
    .shiny-input-container label,
    .radio label,
    .checkbox label,
    .control-label,
    h1, h2, h3, h4, h5, h6,
    p, span, div, a,
    .selectize-input,
    .selectize-dropdown,
    .form-control,
    .question-text,
    .response-option,
    .progress-text,
    .card-title,
    .card-text {
      font-family: var(--font-family) !important;
    }
    
    /* Ensure consistent font rendering */
    body {
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
      text-rendering: optimizeLegibility;
    }
    
    /* Fix font in specific Shiny elements */
    .shiny-text-output,
    .shiny-html-output,
    .shiny-plot-output,
    .shiny-table-output {
      font-family: var(--font-family) !important;
    }
    
    /* Fix font in radio buttons and checkboxes */
    input[type='radio'] + span,
    input[type='checkbox'] + span,
    .radio-inline,
    .checkbox-inline {
      font-family: var(--font-family) !important;
    }
    
    /* Fix font in progress indicators */
    .progress-bar,
    .progress-text,
    .question-counter {
      font-family: var(--font-family) !important;
    }
    
    /* Fix font in buttons */
    .btn,
    button,
    input[type='submit'],
    input[type='button'],
    .action-button {
      font-family: var(--font-family) !important;
    }
  "
  
  # Combine the CSS
  paste0(theme_css, "\n", font_consistency_css)
}