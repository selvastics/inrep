#' Theme System for increp Package
#' 
#' This file consolidates all theme-related functions including:
#' - Theme definitions (from themes.R)
#' - CSS loading functions (from get_theme_css.R)
#' - Font consistency (from ensure_font_consistency.R)
#' 
#' @name theme_system
#' @keywords internal

# ============================================================================
# SECTION 1: THEME DEFINITIONS (from themes.R)
# ============================================================================

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
        comfortable = "1.5rem",
        spacious = "2rem"
      ),
      borders = list(
        radius = "8px",
        width = "1px",
        style = "solid"
      ),
      shadows = list(
        small = "0 1px 3px rgba(0,0,0,0.12)",
        medium = "0 4px 6px rgba(0,0,0,0.1)",
        large = "0 10px 20px rgba(0,0,0,0.15)"
      )
    ),
    
    # Default theme - alias for clean
    default = list(
      name = "Default",
      description = "Default theme (same as clean)",
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
      )
    ),
    
    # Minimal theme
    minimal = list(
      name = "Minimal",
      description = "Minimalist black and white theme",
      colors = list(
        primary = "#000000",
        secondary = "#333333",
        success = "#000000",
        info = "#666666",
        warning = "#333333",
        danger = "#000000",
        background = "#FFFFFF",
        surface = "#FAFAFA",
        text = "#000000",
        text_secondary = "#666666",
        border = "#E0E0E0"
      ),
      fonts = list(
        heading = "Georgia, serif",
        body = "Georgia, serif",
        mono = "Courier, monospace"
      )
    ),
    
    # Light theme
    light = list(
      name = "Light",
      description = "Bright and airy theme",
      colors = list(
        primary = "#4A90E2",
        secondary = "#7BB3EC",
        success = "#7ED321",
        info = "#50E3C2",
        warning = "#F5A623",
        danger = "#D0021B",
        background = "#FFFFFF",
        surface = "#F7F9FC",
        text = "#333333",
        text_secondary = "#828282",
        border = "#E1E8ED"
      )
    ),
    
    # Dark theme
    dark = list(
      name = "Dark",
      description = "Dark mode theme for reduced eye strain",
      colors = list(
        primary = "#BB86FC",
        secondary = "#03DAC6",
        success = "#00C853",
        info = "#2196F3",
        warning = "#FFB300",
        danger = "#CF6679",
        background = "#121212",
        surface = "#1E1E1E",
        text = "#FFFFFF",
        text_secondary = "#B3B3B3",
        border = "#333333"
      )
    ),
    
    # Midnight theme
    midnight = list(
      name = "Midnight",
      description = "Deep blue dark theme",
      colors = list(
        primary = "#5E72E4",
        secondary = "#825EE4",
        success = "#2DCE89",
        info = "#11CDEF",
        warning = "#FB6340",
        danger = "#F5365C",
        background = "#0B1929",
        surface = "#172B4D",
        text = "#E9ECEF",
        text_secondary = "#ADB5BD",
        border = "#2B3553"
      )
    ),
    
    # Modern theme
    modern = list(
      name = "Modern",
      description = "Contemporary design with gradients",
      colors = list(
        primary = "#667EEA",
        secondary = "#764BA2",
        success = "#48BB78",
        info = "#4299E1",
        warning = "#ED8936",
        danger = "#F56565",
        background = "#F7FAFC",
        surface = "#FFFFFF",
        text = "#2D3748",
        text_secondary = "#718096",
        border = "#E2E8F0"
      )
    ),
    
    # Professional theme
    professional = list(
      name = "Professional",
      description = "Business-appropriate theme",
      colors = list(
        primary = "#003366",
        secondary = "#336699",
        success = "#006600",
        info = "#0066CC",
        warning = "#FF9900",
        danger = "#CC0000",
        background = "#F5F5F5",
        surface = "#FFFFFF",
        text = "#333333",
        text_secondary = "#666666",
        border = "#CCCCCC"
      )
    ),
    
    # Clinical theme
    clinical = list(
      name = "Clinical",
      description = "Medical/clinical setting theme",
      colors = list(
        primary = "#0077B5",
        secondary = "#00A8E1",
        success = "#00B74A",
        info = "#17A2B8",
        warning = "#FFC107",
        danger = "#DC3545",
        background = "#FAFBFC",
        surface = "#FFFFFF",
        text = "#212529",
        text_secondary = "#6C757D",
        border = "#DEE2E6"
      )
    ),
    
    # Educational theme
    educational = list(
      name = "Educational",
      description = "Friendly educational theme",
      colors = list(
        primary = "#4CAF50",
        secondary = "#8BC34A",
        success = "#689F38",
        info = "#03A9F4",
        warning = "#FF9800",
        danger = "#F44336",
        background = "#FAFAFA",
        surface = "#FFFFFF",
        text = "#424242",
        text_secondary = "#757575",
        border = "#E0E0E0"
      )
    ),
    
    # Research theme
    research = list(
      name = "Research",
      description = "Academic research theme",
      colors = list(
        primary = "#1E3A8A",
        secondary = "#3B82F6",
        success = "#10B981",
        info = "#06B6D4",
        warning = "#F59E0B",
        danger = "#EF4444",
        background = "#F9FAFB",
        surface = "#FFFFFF",
        text = "#111827",
        text_secondary = "#6B7280",
        border = "#E5E7EB"
      )
    ),
    
    # Corporate theme
    corporate = list(
      name = "Corporate",
      description = "Corporate professional theme",
      colors = list(
        primary = "#1B365D",
        secondary = "#4A6FA5",
        success = "#57A773",
        info = "#5DADE2",
        warning = "#F4D03F",
        danger = "#E74C3C",
        background = "#F8F9FA",
        surface = "#FFFFFF",
        text = "#2C3E50",
        text_secondary = "#7F8C8D",
        border = "#D5DBDB"
      )
    ),
    
    # Hildesheim theme (custom)
    hildesheim = list(
      name = "Hildesheim",
      description = "University of Hildesheim theme",
      colors = list(
        primary = "#003560",
        secondary = "#0066A1",
        success = "#6BA644",
        info = "#00A9E0",
        warning = "#FFB81C",
        danger = "#E4002B",
        background = "#F5F5F5",
        surface = "#FFFFFF",
        text = "#003560",
        text_secondary = "#5C6670",
        border = "#D0D3D4"
      )
    ),
    
    # Colorful themes
    sunset = list(
      name = "Sunset",
      description = "Warm sunset colors",
      colors = list(
        primary = "#FF6B6B",
        secondary = "#4ECDC4",
        success = "#95E77E",
        info = "#45B7D1",
        warning = "#FDCB6E",
        danger = "#EE5A24",
        background = "#FFF5F5",
        surface = "#FFFFFF",
        text = "#2C3E50",
        text_secondary = "#7F8C8D",
        border = "#FFE0E0"
      )
    ),
    
    forest = list(
      name = "Forest",
      description = "Natural forest colors",
      colors = list(
        primary = "#2E7D32",
        secondary = "#558B2F",
        success = "#689F38",
        info = "#00ACC1",
        warning = "#FFB300",
        danger = "#C62828",
        background = "#F1F8E9",
        surface = "#FFFFFF",
        text = "#1B5E20",
        text_secondary = "#558B2F",
        border = "#C8E6C9"
      )
    ),
    
    ocean = list(
      name = "Ocean",
      description = "Deep ocean blues",
      colors = list(
        primary = "#006994",
        secondary = "#0288D1",
        success = "#00BFA5",
        info = "#00ACC1",
        warning = "#FFB300",
        danger = "#D32F2F",
        background = "#E0F7FA",
        surface = "#FFFFFF",
        text = "#004D66",
        text_secondary = "#00838F",
        border = "#B2EBF2"
      )
    ),
    
    berry = list(
      name = "Berry",
      description = "Rich berry tones",
      colors = list(
        primary = "#8E24AA",
        secondary = "#D81B60",
        success = "#43A047",
        info = "#1E88E5",
        warning = "#FB8C00",
        danger = "#E53935",
        background = "#FCE4EC",
        surface = "#FFFFFF",
        text = "#4A148C",
        text_secondary = "#7B1FA2",
        border = "#F8BBD0"
      )
    )
  )
  
  # Return requested theme or default to light
  theme <- themes[[theme_name]]
  if (is.null(theme)) {
    message(sprintf(
      "Theme '%s' not found. Using 'light' theme instead.",
      theme_name
    ))
    theme <- themes[["light"]]
  }
  
  return(theme)
}

#' Generate Theme CSS
#' 
#' Generates CSS from theme configuration
#' 
#' @param theme_name Name of the theme
#' @return CSS string
#' @export
generate_theme_css <- function(theme_name = "light") {
  
  theme <- get_theme_config(theme_name)
  colors <- theme$colors
  fonts <- theme$fonts %||% list(
    heading = "'Helvetica Neue', sans-serif",
    body = "'Helvetica Neue', sans-serif"
  )
  borders <- theme$borders %||% list(
    radius = "0px",
    width = "1px",
    style = "solid"
  )
  
  # Button text color is always white for primary buttons
  button_text_color <- "white"
  
  css <- sprintf('
    :root {
      --color-primary: %s;
      --color-secondary: %s;
      --color-success: %s;
      --color-info: %s;
      --color-warning: %s;
      --color-danger: %s;
      --color-background: %s;
      --color-surface: %s;
      --color-text: %s;
      --color-text-secondary: %s;
      --color-border: %s;
      --font-heading: %s;
      --font-body: %s;
      --border-radius: %s;
      --border-width: %s;
    }
    
    * {
      border-radius: var(--border-radius) !important;
    }
    
    body {
      background-color: var(--color-background);
      color: var(--color-text);
      font-family: var(--font-body);
      line-height: 1.6;
    }
    
    h1, h2, h3, h4, h5, h6 {
      font-family: var(--font-heading);
      color: var(--color-text);
      font-weight: 600;
      letter-spacing: -0.02em;
    }
    
    .btn, button {
      border-radius: var(--border-radius) !important;
      border-width: var(--border-width);
      font-weight: 500;
      padding: 0.75rem 1.5rem;
      transition: all 0.2s;
      text-transform: uppercase;
      letter-spacing: 0.05em;
      font-size: 0.875rem;
    }
    
    .btn-primary {
      background-color: var(--color-primary);
      border: var(--border-width) solid var(--color-primary);
      color: %s;
    }
    
    .btn-primary:hover {
      background-color: var(--color-background);
      color: var(--color-primary);
      border-color: var(--color-primary);
    }
    
    .card {
      background-color: var(--color-surface);
      border: var(--border-width) solid var(--color-border);
      border-radius: var(--border-radius) !important;
      box-shadow: none !important;
      padding: 2rem;
    }
    
    input, select, textarea {
      border: var(--border-width) solid var(--color-border) !important;
      border-radius: var(--border-radius) !important;
      background: var(--color-background);
      color: var(--color-text);
      padding: 0.5rem 0.75rem;
    }
    
    input:focus, select:focus, textarea:focus {
      outline: none !important;
      border-color: var(--color-primary) !important;
      box-shadow: none !important;
    }
    
    .progress {
      height: 2px;
      background: var(--color-border);
      border-radius: 0 !important;
    }
    
    .progress-bar {
      background: var(--color-primary);
      border-radius: 0 !important;
    }
    
    .text-muted {
      color: var(--color-text-secondary) !important;
    }
    
    .border {
      border-color: var(--color-border) !important;
    }
    
    .alert {
      border: var(--border-width) solid var(--color-border);
      border-radius: var(--border-radius) !important;
      background: var(--color-background);
      color: var(--color-text);
    }
    
    .alert-success {
      border-color: var(--color-success);
    }
    
    .alert-info {
      border-color: var(--color-info);
    }
    
    .alert-warning {
      border-color: var(--color-warning);
    }
    
    .alert-danger {
      border-color: var(--color-danger);
    }
    
    /* Minimalist specific styles */
    .assessment-card {
      border: var(--border-width) solid var(--color-border);
      padding: 3rem;
      margin: 2rem auto;
      max-width: 600px;
      background: var(--color-background);
    }
    
    .question-text {
      font-size: 1.25rem;
      font-weight: 400;
      margin-bottom: 2rem;
      line-height: 1.5;
    }
    
    .response-option {
      border: var(--border-width) solid var(--color-border);
      padding: 1rem;
      margin: 0.5rem 0;
      cursor: pointer;
      transition: all 0.2s;
      background: var(--color-background);
    }
    
    .response-option:hover {
      background: var(--color-primary);
      color: var(--color-background);
    }
    
    .response-option.selected {
      background: var(--color-primary);
      color: var(--color-background);
    }
  ',
    colors$primary %||% "#4A90E2",
    colors$secondary %||% "#7BB3EC",
    colors$success %||% "#7ED321",
    colors$info %||% "#50E3C2",
    colors$warning %||% "#F5A623",
    colors$danger %||% "#D0021B",
    colors$background %||% "#FFFFFF",
    colors$surface %||% "#F7F9FC",
    colors$text %||% "#333333",
    colors$text_secondary %||% "#828282",
    colors$border %||% "#E1E8ED",
    fonts$heading %||% "system-ui, sans-serif",
    fonts$body %||% "system-ui, sans-serif",
    borders$radius %||% "8px",
    borders$width %||% "1px",
    button_text_color
  )
  
  return(css)
}


# ============================================================================
# SECTION 2: CSS LOADING FUNCTIONS (from get_theme_css.R)
# ============================================================================

#' Get Theme CSS
#' 
#' Loads theme CSS from file system
#' 
#' @param theme Theme name
#' @param custom_css Additional custom CSS
#' @return CSS string
#' @export
get_theme_css <- function(theme = "Light", custom_css = NULL) {
  # Normalize theme name to lowercase for file lookup
  theme_lower <- tolower(as.character(theme))
  
  # Build path to theme CSS file
  theme_file <- system.file(
    "themes", 
    paste0(theme_lower, ".css"), 
    package = "inrep"
  )
  
  # Check if theme file exists
  if (!file.exists(theme_file)) {
    warning(sprintf("Theme '%s' not found, using 'light' theme", theme))
    theme_file <- system.file("themes", "light.css", package = "inrep")
  }
  
  # Read the CSS file
  theme_css <- if (file.exists(theme_file)) {
    paste(readLines(theme_file, warn = FALSE), collapse = "\n")
  } else {
    # Fallback CSS if no theme file found
    ":root { --primary-color: #007bff; --background-color: #ffffff; }"
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
#' Lists all available theme files
#' 
#' @return Character vector of theme names
#' @export
get_available_themes <- function() {
  theme_dir <- system.file("themes", package = "inrep")
  
  if (dir.exists(theme_dir)) {
    theme_files <- list.files(theme_dir, pattern = "\\.css$", full.names = FALSE)
    return(gsub("\\.css$", "", theme_files))
  }
  
  return(c("light", "dark", "hildesheim"))
}

# ============================================================================
# SECTION 3: FONT CONSISTENCY (from ensure_font_consistency.R)
# ============================================================================

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