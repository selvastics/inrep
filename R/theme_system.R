#' Theme System for inrep Package
#' 
#' This file consolidates all theme-related functions including:
#' - Theme definitions (from themes.R)
#' - CSS loading functions (from get_theme_css.R)
#' - Font consistency (from ensure_font_consistency.R)
#' 
#' @name theme_system
#' @keywords internal
NULL

# ============================================================================
# SECTION 1: THEME DEFINITIONS (from themes.R)
# ============================================================================

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
      /* Core Colors */
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

      /* Theme Colors (aliases for compatibility) */
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

      /* Typography */
      --font-heading: %s;
      --font-body: %s;
      --font-mono: %s;

      /* Layout */
      --border-radius: %s;
      --border-width: %s;
      --border-style: solid;

      /* Spacing */
      --spacing-xs: 0.25rem;
      --spacing-sm: 0.5rem;
      --spacing-md: 1rem;
      --spacing-lg: 1.5rem;
      --spacing-xl: 2rem;

      /* Shadows */
      --shadow-sm: 0 1px 3px rgba(0,0,0,0.12);
      --shadow-md: 0 4px 6px rgba(0,0,0,0.1);
      --shadow-lg: 0 10px 20px rgba(0,0,0,0.15);
      --shadow-xl: 0 20px 40px rgba(0,0,0,0.2);

      /* Transitions */
      --transition-fast: 0.15s ease;
      --transition-normal: 0.3s ease;
      --transition-slow: 0.5s ease;
    }
    
    * {
      border-radius: var(--border-radius) !important;
    }
    
    /* Base Styles */
    body {
      background-color: var(--background-color);
      color: var(--text-color);
      font-family: var(--font-body);
      line-height: 1.6;
      margin: 0;
      padding: 0;
      min-height: 100vh;
      -webkit-font-smoothing: antialiased;
      -moz-osx-font-smoothing: grayscale;
      text-rendering: optimizeLegibility;
    }

    /* Typography */
    h1, h2, h3, h4, h5, h6 {
      font-family: var(--font-heading);
      color: var(--text-color);
      font-weight: 600;
      letter-spacing: -0.02em;
      margin-bottom: 1rem;
      line-height: 1.2;
    }

    h1 { font-size: 2.5rem; }
    h2 { font-size: 2rem; }
    h3 { font-size: 1.75rem; }
    h4 { font-size: 1.5rem; }
    h5 { font-size: 1.25rem; }
    h6 { font-size: 1.125rem; }

    p {
      margin-bottom: 1rem;
      line-height: 1.6;
    }

    /* Buttons */
    .btn, button {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      border-radius: var(--border-radius);
      border-width: var(--border-width);
      border-style: var(--border-style);
      font-weight: 500;
      padding: 0.75rem 1.5rem;
      transition: all var(--transition-fast);
      text-transform: none;
      letter-spacing: 0.025em;
      font-size: 1rem;
      font-family: var(--font-body);
      cursor: pointer;
      text-decoration: none;
      background: transparent;
      color: var(--text-color);
      min-height: 44px;
      box-sizing: border-box;
    }

    .btn-primary, .btn-klee {
      background-color: var(--primary-color);
      border-color: var(--primary-color);
      color: %s;
    }

    .btn-primary:hover, .btn-klee:hover {
      background-color: var(--secondary-color);
      border-color: var(--secondary-color);
      color: var(--background-color);
      transform: translateY(-1px);
      box-shadow: var(--shadow-md);
    }

    .btn-primary:active, .btn-klee:active {
      transform: translateY(0);
      box-shadow: var(--shadow-sm);
    }

    .btn-secondary {
      background-color: transparent;
      border-color: var(--border-color);
      color: var(--text-color);
    }

    .btn-secondary:hover {
      background-color: var(--surface-color);
      border-color: var(--primary-color);
    }

    .btn-success {
      background-color: var(--success-color);
      border-color: var(--success-color);
      color: white;
    }

    .btn-warning {
      background-color: var(--warning-color);
      border-color: var(--warning-color);
      color: white;
    }

    .btn-danger {
      background-color: var(--danger-color);
      border-color: var(--danger-color);
      color: white;
    }

    .btn-info {
      background-color: var(--info-color);
      border-color: var(--info-color);
      color: white;
    }
    
    /* Cards */
    .card, .assessment-card {
      background-color: var(--surface-color);
      border: var(--border-width) solid var(--border-color);
      border-radius: var(--border-radius);
      box-shadow: var(--shadow-sm);
      padding: var(--spacing-lg);
      margin-bottom: var(--spacing-md);
      transition: all var(--transition-fast);
    }

    .card:hover, .assessment-card:hover {
      box-shadow: var(--shadow-md);
      transform: translateY(-1px);
    }

    /* Form Elements */
    input, select, textarea {
      width: 100%;
      border: var(--border-width) solid var(--border-color);
      border-radius: var(--border-radius);
      background: var(--background-color);
      color: var(--text-color);
      padding: var(--spacing-sm) var(--spacing-md);
      font-family: var(--font-body);
      font-size: 1rem;
      transition: all var(--transition-fast);
      box-sizing: border-box;
    }

    input:focus, select:focus, textarea:focus {
      outline: none;
      border-color: var(--primary-color);
      box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1);
    }

    input:disabled, select:disabled, textarea:disabled {
      background-color: var(--surface-color);
      opacity: 0.6;
      cursor: not-allowed;
    }

    /* Progress Bars */
    .progress {
      height: 8px;
      background: var(--border-color);
      border-radius: var(--border-radius);
      overflow: hidden;
      margin: var(--spacing-md) 0;
    }

    .progress-bar {
      background: var(--primary-color);
      height: 100%;
      border-radius: var(--border-radius);
      transition: width var(--transition-normal);
    }

    /* Utility Classes */
    .text-muted, .text-secondary {
      color: var(--text-secondary-color) !important;
    }

    .text-primary {
      color: var(--primary-color) !important;
    }

    .text-success {
      color: var(--success-color) !important;
    }

    .text-warning {
      color: var(--warning-color) !important;
    }

    .text-danger {
      color: var(--danger-color) !important;
    }

    .text-info {
      color: var(--info-color) !important;
    }

    .border {
      border-color: var(--border-color) !important;
    }

    .border-primary {
      border-color: var(--primary-color) !important;
    }

    .border-success {
      border-color: var(--success-color) !important;
    }

    .border-warning {
      border-color: var(--warning-color) !important;
    }

    .border-danger {
      border-color: var(--danger-color) !important;
    }

    /* Alerts */
    .alert {
      border: var(--border-width) solid var(--border-color);
      border-radius: var(--border-radius);
      background: var(--background-color);
      color: var(--text-color);
      padding: var(--spacing-md);
      margin-bottom: var(--spacing-md);
    }

    .alert-success {
      border-color: var(--success-color);
      background-color: rgba(40, 167, 69, 0.1);
      color: var(--success-color);
    }

    .alert-info {
      border-color: var(--info-color);
      background-color: rgba(23, 162, 184, 0.1);
      color: var(--info-color);
    }

    .alert-warning {
      border-color: var(--warning-color);
      background-color: rgba(255, 193, 7, 0.1);
      color: var(--warning-color);
    }

    .alert-danger {
      border-color: var(--danger-color);
      background-color: rgba(220, 53, 69, 0.1);
      color: var(--danger-color);
    }
    
    /* Assessment-specific styles */
    .question-text {
      font-size: 1.25rem;
      font-weight: 500;
      margin-bottom: var(--spacing-xl);
      line-height: 1.6;
      color: var(--text-color);
    }

    .response-option, .answer-option {
      border: var(--border-width) solid var(--border-color);
      padding: var(--spacing-md);
      margin: var(--spacing-sm) 0;
      cursor: pointer;
      transition: all var(--transition-fast);
      background: var(--background-color);
      border-radius: var(--border-radius);
      position: relative;
    }

    .response-option:hover, .answer-option:hover {
      border-color: var(--primary-color);
      background: rgba(0, 123, 255, 0.05);
      transform: translateX(4px);
    }

    .response-option.selected, .answer-option.selected {
      background: var(--primary-color);
      color: white;
      border-color: var(--primary-color);
      transform: translateX(8px);
    }

    /* Focus styles for accessibility */
    *:focus {
      outline: 2px solid var(--primary-color);
      outline-offset: 2px;
    }

    .btn:focus, button:focus {
      outline: 2px solid var(--primary-color);
      outline-offset: 2px;
      box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.2);
    }

    /* Radio buttons and checkboxes */
    input[type="radio"], input[type="checkbox"] {
      accent-color: var(--primary-color);
      margin-right: var(--spacing-sm);
    }

    /* Responsive design */
    @media (max-width: 768px) {
      body {
        font-size: 0.9rem;
      }

      h1 { font-size: 2rem; }
      h2 { font-size: 1.75rem; }
      h3 { font-size: 1.5rem; }

      .card, .assessment-card {
        padding: var(--spacing-md);
        margin: var(--spacing-sm);
      }

      .btn, button {
        padding: var(--spacing-sm) var(--spacing-md);
        font-size: 0.9rem;
      }

      .question-text {
        font-size: 1.125rem;
      }
    }

    /* High contrast mode support */
    @media (prefers-contrast: high) {
      :root {
        --border-width: 2px;
        --shadow-sm: 0 2px 4px rgba(0,0,0,0.3);
        --shadow-md: 0 4px 8px rgba(0,0,0,0.4);
      }
    }

    /* Reduced motion support */
    @media (prefers-reduced-motion: reduce) {
      * {
        animation-duration: 0.01ms !important;
        animation-iteration-count: 1 !important;
        transition-duration: 0.01ms !important;
      }
    }

    /* Print styles */
    @media print {
      body {
        background: white !important;
        color: black !important;
        font-size: 12pt;
      }

      .btn, button {
        display: none !important;
      }

      .card, .assessment-card {
        border: 1px solid black !important;
        box-shadow: none !important;
        break-inside: avoid;
      }

      .question-text {
        font-weight: bold;
        margin-bottom: 1rem;
      }
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

    # Aliases for compatibility
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

    # Typography
    fonts$heading %||% "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
    fonts$body %||% "system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif",
    fonts$mono %||% "'SF Mono', Monaco, 'Cascadia Code', monospace",

    # Layout
    borders$radius %||% "8px",
    borders$width %||% "1px",

    # Button text color
    button_text_color
  )
  
  return(css)
}


# ============================================================================
# SECTION 2: CSS LOADING FUNCTIONS (from get_theme_css.R)
# ============================================================================

#' Get Theme CSS
#'
#' Loads theme CSS from file system with comprehensive support
#'
#' @param theme Theme name or configuration
#' @param custom_css Additional custom CSS
#' @param theme_config Named list of theme parameters
#' @return CSS string
#' @export
get_theme_css <- function(theme = "Light", custom_css = NULL, theme_config = NULL) {
  # Normalize theme name to lowercase for file lookup
  theme_lower <- tolower(as.character(theme))

  # Check if theme is a built-in theme or custom configuration
  if (is.list(theme)) {
    # Custom theme configuration provided
    theme_css <- generate_theme_css_from_config(theme)
  } else {
    # Load from file system
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
      generate_fallback_css()
    }
  }

  # Add theme_config overrides if provided
  if (!is.null(theme_config)) {
    theme_css <- add_theme_config_overrides(theme_css, theme_config)
  }

  # Ensure font consistency
  theme_css <- ensure_font_consistency(theme_css)

  # Add custom CSS if provided
  if (!is.null(custom_css)) {
    theme_css <- paste(theme_css, custom_css, sep = "\n")
  }

  return(theme_css)
}

#' Generate CSS from theme configuration
#'
#' @param config Theme configuration list
#' @return CSS string
#' @export
generate_theme_css_from_config <- function(config) {
  css <- ":root{\n"

  # Colors
  colors <- config$colors %||% list()
  css <- paste0(css, sprintf("  --primary-color: %s;\n", colors$primary %||% "#007bff"))
  css <- paste0(css, sprintf("  --secondary-color: %s;\n", colors$secondary %||% "#6c757d"))
  css <- paste0(css, sprintf("  --success-color: %s;\n", colors$success %||% "#28a745"))
  css <- paste0(css, sprintf("  --info-color: %s;\n", colors$info %||% "#17a2b8"))
  css <- paste0(css, sprintf("  --warning-color: %s;\n", colors$warning %||% "#ffc107"))
  css <- paste0(css, sprintf("  --danger-color: %s;\n", colors$danger %||% "#dc3545"))
  css <- paste0(css, sprintf("  --background-color: %s;\n", colors$background %||% "#ffffff"))
  css <- paste0(css, sprintf("  --surface-color: %s;\n", colors$surface %||% "#f8f9fa"))
  css <- paste0(css, sprintf("  --text-color: %s;\n", colors$text %||% "#212529"))
  css <- paste0(css, sprintf("  --text-secondary-color: %s;\n", colors$text_secondary %||% "#6c757d"))
  css <- paste0(css, sprintf("  --border-color: %s;\n", colors$border %||% "#dee2e6"))

  # Typography
  fonts <- config$fonts %||% list()
  css <- paste0(css, sprintf("  --font-heading: %s;\n", fonts$heading %||% "system-ui, sans-serif"))
  css <- paste0(css, sprintf("  --font-body: %s;\n", fonts$body %||% "system-ui, sans-serif"))
  css <- paste0(css, sprintf("  --font-mono: %s;\n", fonts$mono %||% "monospace"))

  # Layout
  borders <- config$borders %||% list()
  css <- paste0(css, sprintf("  --border-radius: %s;\n", borders$radius %||% "8px"))
  css <- paste0(css, sprintf("  --border-width: %s;\n", borders$width %||% "1px"))

  css <- paste0(css, "}\n")

  return(css)
}

#' Add theme configuration overrides to existing CSS
#'
#' @param css Existing CSS string
#' @param config Theme configuration overrides
#' @return Modified CSS string
#' @export
add_theme_config_overrides <- function(css, config) {
  # Extract existing :root block
  root_pattern <- ":root\\s*\\{([^{}]*(?:\\{[^{}]*\\}[^{}]*)*)\\}"
  root_match <- regexpr(root_pattern, css, perl = TRUE)

  if (root_match == -1) {
    # No :root block found, create one
    overrides <- generate_theme_css_from_config(config)
    return(paste(css, overrides, sep = "\n"))
  }

  # Get the content inside :root
  root_content <- substr(css, attr(root_match, "capture.start"),
                        attr(root_match, "capture.start") + attr(root_match, "capture.length") - 1)

  # Add overrides to existing variables or create new ones
  overrides <- generate_theme_css_from_config(config)

  # Replace the existing :root block with enhanced version
  enhanced_css <- sub(root_pattern, overrides, css, perl = TRUE)

  return(enhanced_css)
}

#' Generate fallback CSS
#'
#' @return Basic CSS fallback
#' @export
generate_fallback_css <- function() {
  return('
:root {
  --primary-color: #007bff;
  --secondary-color: #6c757d;
  --success-color: #28a745;
  --info-color: #17a2b8;
  --warning-color: #ffc107;
  --danger-color: #dc3545;
  --background-color: #ffffff;
  --surface-color: #f8f9fa;
  --text-color: #212529;
  --text-secondary-color: #6c757d;
  --border-color: #dee2e6;
  --font-heading: system-ui, sans-serif;
  --font-body: system-ui, sans-serif;
  --font-mono: monospace;
  --border-radius: 8px;
  --border-width: 1px;
}

body {
  font-family: var(--font-body);
  background-color: var(--background-color);
  color: var(--text-color);
  margin: 0;
  padding: 0;
  min-height: 100vh;
}')
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
  # Check if the theme already defines a font-family variable
  has_font_family <- grepl("--font-family:", theme_css)

  # Add font consistency rules with fallback support
  font_consistency_css <- sprintf('
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
    .answer-option,
    .progress-text,
    .card-title,
    .card-text {
      font-family: var(--font-body, var(--font-family, system-ui, sans-serif)) !important;
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
      font-family: var(--font-body, var(--font-family, system-ui, sans-serif)) !important;
    }

    /* Fix font in radio buttons and checkboxes */
    input[type="radio"] + span,
    input[type="checkbox"] + span,
    .radio-inline,
    .checkbox-inline {
      font-family: var(--font-body, var(--font-family, system-ui, sans-serif)) !important;
    }

    /* Fix font in progress indicators */
    .progress-bar,
    .progress-text,
    .question-counter {
      font-family: var(--font-body, var(--font-family, system-ui, sans-serif)) !important;
    }

    /* Fix font in buttons */
    .btn,
    button,
    input[type="submit"],
    input[type="button"],
    .action-button {
      font-family: var(--font-body, var(--font-family, system-ui, sans-serif)) !important;
    }

    /* Enhanced focus styles for accessibility */
    *:focus {
      outline: 2px solid var(--primary-color, var(--color-primary, #007bff));
      outline-offset: 2px;
    }

    .btn:focus, button:focus {
      outline: 2px solid var(--primary-color, var(--color-primary, #007bff));
      outline-offset: 2px;
      box-shadow: 0 0 0 4px rgba(0, 123, 255, 0.2);
    }

    /* Support for both naming conventions */
    .btn-primary, .btn-klee {
      background-color: var(--primary-color, var(--color-primary, #007bff)) !important;
      border-color: var(--primary-color, var(--color-primary, #007bff)) !important;
      color: white !important;
    }

    .btn-primary:hover, .btn-klee:hover {
      background-color: var(--secondary-color, var(--color-secondary, #6c757d)) !important;
      border-color: var(--secondary-color, var(--color-secondary, #6c757d)) !important;
    }

    .text-primary {
      color: var(--primary-color, var(--color-primary, #007bff)) !important;
    }

    .text-secondary {
      color: var(--text-secondary-color, var(--color-text-secondary, #6c757d)) !important;
    }

    .text-success {
      color: var(--success-color, var(--color-success, #28a745)) !important;
    }

    .text-warning {
      color: var(--warning-color, var(--color-warning, #ffc107)) !important;
    }

    .text-danger {
      color: var(--danger-color, var(--color-danger, #dc3545)) !important;
    }

    .text-info {
      color: var(--info-color, var(--color-info, #17a2b8)) !important;
    }

    /* Card styles with dual support */
    .card, .assessment-card {
      background-color: var(--surface-color, var(--color-surface, #f8f9fa)) !important;
      border: var(--border-width, 1px) solid var(--border-color, var(--color-border, #dee2e6)) !important;
      border-radius: var(--border-radius, 8px) !important;
    }

    /* Form elements with dual support */
    input, select, textarea {
      border: var(--border-width, 1px) solid var(--border-color, var(--color-border, #dee2e6)) !important;
      border-radius: var(--border-radius, 8px) !important;
      background: var(--background-color, var(--color-background, #ffffff)) !important;
      color: var(--text-color, var(--color-text, #212529)) !important;
    }

    input:focus, select:focus, textarea:focus {
      border-color: var(--primary-color, var(--color-primary, #007bff)) !important;
      box-shadow: 0 0 0 3px rgba(0, 123, 255, 0.1) !important;
    }%s', if (has_font_family) {
    "\n\n    /* Font family already defined in theme */"
  } else {
    "\n\n    /* Define fallback font family */
    :root {
      --font-family: var(--font-body, system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif);
    }"
  })

  # Combine the CSS
  paste0(theme_css, "\n", font_consistency_css)
}