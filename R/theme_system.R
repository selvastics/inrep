# =============================================================================
# THEME SYSTEM
# =============================================================================
# This file consolidates theme-related functions from the original files:
# - themes.R
# - get_theme_css.R
# - ensure_font_consistency.R

#' Theme Definitions for inrep Package
#' 
#' Provides comprehensive theme definitions for the UI
#' 
#' @name themes
#' @docType data
NULL

#' Get Theme Configuration
#' 
#' Returns complete theme configuration
#' 
#' @param theme_name Name of the theme
#' @return Theme configuration list
#' @export
get_theme_config <- function(theme_name = "light") {
  
  # Validate theme name
  if (!is.null(theme_name)) {
    theme_name <- tolower(as.character(theme_name))
  } else {
    theme_name <- "light"
  }
  
  themes <- list(
    # Clean theme - professional and minimal
    clean = list(
      name = "Clean",
      description = "Clean, professional theme with excellent readability",
      colors = list(
        primary = "#2C3E50",
        secondary = "#34495E", 
        success = "#27AE60",
        info = "#3498DB",
        warning = "#F39C12",
        danger = "#E74C3C",
        background = "#FFFFFF",
        surface = "#F8F9FA",
        text = "#2C3E50",
        text_secondary = "#7F8C8D",
        border = "#DEE2E6"
      ),
      fonts = list(
        heading = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        body = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        mono = "'SF Mono', Monaco, 'Cascadia Code', monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.5rem",
        loose = "1.5rem"
      )
    ),
    
    # Light theme - default bright theme
    light = list(
      name = "Light",
      description = "Bright, clean theme for general use",
      colors = list(
        primary = "#007BFF",
        secondary = "#6C757D",
        success = "#28A745",
        info = "#17A2B8",
        warning = "#FFC107",
        danger = "#DC3545",
        background = "#FFFFFF",
        surface = "#F8F9FA",
        text = "#212529",
        text_secondary = "#6C757D",
        border = "#DEE2E6"
      ),
      fonts = list(
        heading = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        body = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        mono = "'SF Mono', Monaco, 'Cascadia Code', monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.5rem",
        loose = "1.5rem"
      )
    ),
    
    # Dark theme
    dark = list(
      name = "Dark",
      description = "Dark theme for reduced eye strain",
      colors = list(
        primary = "#0D6EFD",
        secondary = "#6C757D",
        success = "#198754",
        info = "#0DCAF0",
        warning = "#FFC107",
        danger = "#DC3545",
        background = "#212529",
        surface = "#343A40",
        text = "#FFFFFF",
        text_secondary = "#ADB5BD",
        border = "#495057"
      ),
      fonts = list(
        heading = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        body = "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
        mono = "'SF Mono', Monaco, 'Cascadia Code', monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.5rem",
        loose = "1.5rem"
      )
    ),
    
    # Professional theme
    professional = list(
      name = "Professional",
      description = "Conservative theme for business environments",
      colors = list(
        primary = "#003366",
        secondary = "#666666",
        success = "#006600",
        info = "#0066CC",
        warning = "#CC6600",
        danger = "#CC0000",
        background = "#FFFFFF",
        surface = "#F5F5F5",
        text = "#333333",
        text_secondary = "#666666",
        border = "#CCCCCC"
      ),
      fonts = list(
        heading = "'Times New Roman', Times, serif",
        body = "'Times New Roman', Times, serif",
        mono = "'Courier New', Courier, monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.75rem",
        loose = "1.25rem"
      )
    ),
    
    # Hildesheim theme - custom university theme
    hildesheim = list(
      name = "Hildesheim",
      description = "University of Hildesheim brand colors",
      colors = list(
        primary = "#0066CC",
        secondary = "#666666",
        success = "#009900",
        info = "#00AACC",
        warning = "#FF9900",
        danger = "#CC3333",
        background = "#FFFFFF",
        surface = "#F8F9FA",
        text = "#333333",
        text_secondary = "#666666",
        border = "#DDDDDD"
      ),
      fonts = list(
        heading = "'Arial', 'Helvetica Neue', Helvetica, sans-serif",
        body = "'Arial', 'Helvetica Neue', Helvetica, sans-serif",
        mono = "'Consolas', 'Monaco', monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.5rem",
        loose = "1.5rem"
      )
    ),
    
    # Minimal theme
    minimal = list(
      name = "Minimal",
      description = "Ultra-clean minimal design",
      colors = list(
        primary = "#000000",
        secondary = "#666666",
        success = "#4CAF50",
        info = "#2196F3",
        warning = "#FF9800",
        danger = "#F44336",
        background = "#FFFFFF",
        surface = "#FAFAFA",
        text = "#000000",
        text_secondary = "#666666",
        border = "#E0E0E0"
      ),
      fonts = list(
        heading = "'Helvetica Neue', Helvetica, Arial, sans-serif",
        body = "'Helvetica Neue', Helvetica, Arial, sans-serif",
        mono = "'Monaco', 'Menlo', monospace"
      ),
      spacing = list(
        base = "1rem",
        compact = "0.25rem",
        loose = "2rem"
      )
    )
  )
  
  # Return the requested theme or default to light
  if (theme_name %in% names(themes)) {
    return(themes[[theme_name]])
  } else {
    warning(sprintf("Theme '%s' not found, using 'light' theme", theme_name))
    return(themes[["light"]])
  }
}

#' Generate Theme CSS
#' 
#' Generates CSS from theme configuration
#' 
#' @param theme_config Theme configuration from get_theme_config()
#' @return CSS string
#' @export
generate_theme_css <- function(theme_config) {
  
  # Generate CSS variables
  css_vars <- sprintf("
    :root {
      --primary-color: %s;
      --secondary-color: %s;
      --success-color: %s;
      --info-color: %s;
      --warning-color: %s;
      --danger-color: %s;
      --background-color: %s;
      --surface-color: %s;
      --text-color: %s;
      --text-secondary-color: %s;
      --border-color: %s;
      --font-family: %s;
      --heading-font: %s;
      --mono-font: %s;
      --spacing-base: %s;
      --spacing-compact: %s;
      --spacing-loose: %s;
    }
  ",
    theme_config$colors$primary,
    theme_config$colors$secondary,
    theme_config$colors$success,
    theme_config$colors$info,
    theme_config$colors$warning,
    theme_config$colors$danger,
    theme_config$colors$background,
    theme_config$colors$surface,
    theme_config$colors$text,
    theme_config$colors$text_secondary,
    theme_config$colors$border,
    theme_config$fonts$body,
    theme_config$fonts$heading,
    theme_config$fonts$mono,
    theme_config$spacing$base,
    theme_config$spacing$compact,
    theme_config$spacing$loose
  )
  
  # Generate base styles
  base_css <- "
    body {
      background-color: var(--background-color);
      color: var(--text-color);
      font-family: var(--font-family);
    }
    
    .card, .well {
      background-color: var(--surface-color);
      border: 1px solid var(--border-color);
    }
    
    .btn-primary {
      background-color: var(--primary-color);
      border-color: var(--primary-color);
    }
    
    .btn-secondary {
      background-color: var(--secondary-color);
      border-color: var(--secondary-color);
    }
    
    .text-muted {
      color: var(--text-secondary-color) !important;
    }
    
    h1, h2, h3, h4, h5, h6 {
      font-family: var(--heading-font);
      color: var(--text-color);
    }
    
    .form-control {
      background-color: var(--background-color);
      border-color: var(--border-color);
      color: var(--text-color);
    }
    
    .form-control:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 0.2rem rgba(var(--primary-color), 0.25);
    }
  "
  
  return(paste0(css_vars, base_css))
}

#' Get Theme CSS
#' 
#' Loads theme CSS from file system or generates it
#' 
#' @param theme Theme name
#' @param custom_css Additional custom CSS
#' @return CSS string
#' @export
get_theme_css <- function(theme = "light", custom_css = NULL) {
  # Normalize theme name to lowercase for file lookup
  theme_lower <- tolower(as.character(theme))
  
  # First try to load from file system
  theme_file <- system.file(
    "themes", 
    paste0(theme_lower, ".css"), 
    package = "inrep"
  )
  
  # Check if theme file exists
  if (file.exists(theme_file)) {
    # Read the CSS file
    theme_css <- paste(readLines(theme_file, warn = FALSE), collapse = "\n")
  } else {
    # Generate CSS from theme configuration
    theme_config <- get_theme_config(theme_lower)
    theme_css <- generate_theme_css(theme_config)
  }
  
  # Ensure font consistency
  theme_css <- ensure_font_consistency(theme_css)
  
  # Add custom CSS if provided
  if (!is.null(custom_css)) {
    theme_css <- paste(theme_css, custom_css, sep = "\n")
  }
  
  return(theme_css)
}

#' Get Available Themes
#' 
#' Lists all available theme files and built-in themes
#' 
#' @return Character vector of theme names
#' @export
get_available_themes <- function() {
  # Built-in themes
  builtin_themes <- c("light", "dark", "clean", "minimal", "professional", "hildesheim")
  
  # Check for theme files
  theme_dir <- system.file("themes", package = "inrep")
  
  if (dir.exists(theme_dir)) {
    theme_files <- list.files(theme_dir, pattern = "\\.css$", full.names = FALSE)
    file_themes <- gsub("\\.css$", "", theme_files)
    
    # Combine and remove duplicates
    all_themes <- unique(c(builtin_themes, file_themes))
  } else {
    all_themes <- builtin_themes
  }
  
  return(sort(all_themes))
}

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