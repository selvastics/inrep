#' Get Built-in Themes for inrep Assessments
#'
#' Returns a character vector of available built-in themes designed for professional
#' psychological and educational assessments. Each theme is optimized for different
#' contexts and user populations, following accessibility and design best practices.
#'
#' @return Character vector containing names of available built-in themes:
#'   \itemize{
#'     \item \code{"Light"}: Clean, minimalist design with high contrast for readability
#'     \item \code{"Midnight"}: Dark theme optimized for low-light environments
#'     \item \code{"Sunset"}: Warm color palette with orange and red accents
#'     \item \code{"Forest"}: Nature-inspired greens with earthy tones
#'     \item \code{"Ocean"}: Cool blues and teals for calming effect
#'     \item \code{"Berry"}: Purple and magenta palette for creative applications
#'     \item \code{"Professional"}: Corporate theme with blue-gray professional styling
#'     \item \code{"Hildesheim"}: University-themed design with academic styling
#'     \item \code{"Vibrant"}: Dynamic creative energy theme with animated elements
#'     \item \code{"DarkBlue"}: Deep blue professional theme with neural network patterns
#'     \item \code{"Paper"}: Classic paper-like aesthetic with academic styling
#'     \item \code{"Monochrome"}: Elegant black and white design for psychological studies
#'   }
#' 
#' @export
#' 
#' @details
#' Each theme is professionally designed with consideration for:
#' \itemize{
#'   \item Accessibility compliance (WCAG 2.1 AA standards)
#'   \item Color contrast ratios for users with visual impairments
#'   \item Psychological impact of color choices on assessment performance
#'   \item Cross-browser compatibility and responsive design
#'   \item Print-friendly alternatives when applicable
#'   \item Cognitive load optimization for assessment contexts
#' }
#' 
#' @section Case-Insensitive Theme Names:
#' All theme names are case-insensitive throughout the package. This user-friendly
#' feature allows maximum flexibility in theme specification.
#' 
#' @examples
#' \dontrun{
#' # Get all available themes
#' themes <- get_builtin_themes()
#' print(themes)
#' }
get_builtin_themes <- function() {
  c("Light", "Midnight", "Sunset", "Forest", "Ocean", "Berry", "Professional", "Hildesheim", "Vibrant", "DarkBlue", "Paper", "Monochrome")
}

#' Validate and Normalize Theme Name
#'
#' Validates a theme name with case-insensitive matching and provides helpful
#' error messages listing all supported themes when an invalid theme is provided.
#'
#' @param theme_name Character string specifying the theme name to validate
#' @param error_on_invalid Logical; if TRUE, throws an error for invalid themes.
#'   If FALSE, returns NULL for invalid themes with a warning.
#' @param suggest_alternatives Logical; if TRUE, suggests similar theme names
#'   when an exact match is not found.
#'
#' @return Character string with the correctly capitalized theme name, or NULL
#'   if the theme is invalid and error_on_invalid is FALSE.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Valid theme names (case-insensitive)
#' validate_theme_name("hildesheim")    # Returns "Hildesheim"
#' validate_theme_name("MIDNIGHT")      # Returns "Midnight"
#' validate_theme_name("ocean")         # Returns "Ocean"
#' }
validate_theme_name <- function(theme_name, error_on_invalid = FALSE, suggest_alternatives = TRUE) {
  if (!is.character(theme_name) || length(theme_name) != 1) {
    error_msg <- "Theme name must be a single character string"
    if (error_on_invalid) {
      stop(error_msg, call. = FALSE)
    } else {
      warning(error_msg, call. = FALSE)
      return(NULL)
    }
  }
  
  valid_themes <- get_builtin_themes()
  theme_name_lower <- tolower(theme_name)
  valid_themes_lower <- tolower(valid_themes)
  
  # Check for exact match (case-insensitive)
  match_index <- match(theme_name_lower, valid_themes_lower)
  
  if (!is.na(match_index)) {
    # Found exact match, return properly capitalized version
    return(valid_themes[match_index])
  }
  
  # No exact match found
  error_msg <- sprintf(
    "Invalid theme name '%s'.\n\nSupported themes are:\n%s\n\nTheme names are case-insensitive.",
    theme_name,
    paste("  -", valid_themes, collapse = "\n")
  )
  
  # Add suggestions for similar names if requested
  if (suggest_alternatives) {
    suggestions <- find_similar_themes(theme_name, valid_themes)
    if (length(suggestions) > 0) {
      error_msg <- paste0(error_msg, "\n\nDid you mean: ", paste(suggestions, collapse = ", "), "?")
    }
  }
  
  if (error_on_invalid) {
    stop(error_msg, call. = FALSE)
  } else {
    warning(error_msg, call. = FALSE)
    return(NULL)
  }
}

#' Find Similar Theme Names
#'
#' Helper function to suggest similar theme names based on string distance.
#'
#' @param input_theme Character string with the input theme name
#' @param valid_themes Character vector of valid theme names
#' @param max_distance Maximum edit distance for suggestions (default: 3)
#'
#' @return Character vector of similar theme names, or empty vector if none found
#'
#' @noRd
find_similar_themes <- function(input_theme, valid_themes, max_distance = 3) {
  if (!requireNamespace("utils", quietly = TRUE)) {
    return(character(0))
  }
  
  # Calculate string distances
  distances <- utils::adist(tolower(input_theme), tolower(valid_themes))
  
  # Find themes within acceptable distance
  similar_indices <- which(distances <= max_distance)
  
  if (length(similar_indices) == 0) {
    return(character(0))
  }
  
  # Return similar themes sorted by distance
  similar_themes <- valid_themes[similar_indices]
  similar_distances <- distances[similar_indices]
  
  # Sort by distance (closest first)
  order_idx <- order(similar_distances)
  return(similar_themes[order_idx])
}

#' Load Theme CSS for inrep Interface
#'
#' Loads CSS code for a specified built-in theme from the package's theme directory.
#'
#' @param theme_name Character string specifying the theme name. Must match one of
#'   the themes returned by \code{\link{get_builtin_themes}}. Case-insensitive.
#' 
#' @return Character string containing complete CSS code for the specified theme.
#' 
#' @export
#' 
#' @examples
#' \dontrun{
#' # Load CSS for midnight theme - case insensitive
#' midnight_css <- load_theme_css("Midnight")
#' midnight_css <- load_theme_css("midnight")    # Same result
#' }
load_theme_css <- function(theme_name) {
  # Validate and normalize theme name (case-insensitive)
  validated_theme <- validate_theme_name(theme_name, error_on_invalid = FALSE)
  
  if (is.null(validated_theme)) {
    # Theme validation failed, fall back to Light theme
    message("Falling back to 'Light' theme due to invalid theme name.")
    validated_theme <- "Light"
  }
  
  # Load CSS file
  css_file <- system.file("themes", paste0(tolower(validated_theme), ".css"), package = "inrep")
  if (css_file == "" || !file.exists(css_file)) {
    warning(sprintf("Theme CSS file for '%s' not found. Using default CSS.", validated_theme))
    return(get_default_css())
  }
  
  tryCatch({
    css_content <- readLines(css_file, encoding = "UTF-8", warn = FALSE)
    paste(css_content, collapse = "\n")
  }, error = function(e) {
    warning(sprintf("Failed to read theme CSS file: %s. Using default CSS.", e$message))
    return(get_default_css())
  })
}

#' Get Default CSS
#'
#' Returns a basic CSS theme as fallback when theme files are not found.
#'
#' @return Character string containing default CSS
#' @noRd
get_default_css <- function() {
  "/* Default Light Theme CSS */
:root {
  --primary-color: #212529;
  --secondary-color: #343a40;
  --background-color: #f8f9fa;
  --text-color: #212529;
  --border-color: #dee2e6;
  --border-radius: 8px;
  --shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
  --container-width: 900px;
  --card-padding: 2rem;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
  background-color: var(--background-color);
  color: var(--text-color);
  margin: 0;
  padding: 0;
  line-height: 1.6;
}

.container-fluid {
  max-width: var(--container-width);
  margin: 0 auto;
  padding: var(--card-padding);
}

.assessment-card {
  background: #ffffff;
  border: 1px solid var(--border-color);
  border-radius: var(--border-radius);
  padding: var(--card-padding);
  margin-bottom: 2rem;
  box-shadow: var(--shadow);
}

.btn-klee {
  background: var(--primary-color);
  color: #ffffff;
  border: none;
  padding: 0.75rem 2rem;
  font-size: 1.1rem;
  border-radius: var(--border-radius);
  cursor: pointer;
}

.btn-klee:hover {
  background-color: var(--secondary-color);
}"
}

#' Get Theme CSS
#'
#' Generates CSS for the Shiny interface based on a built-in theme.
#'
#' @param theme Name of the built-in theme. Case-insensitive.
#' @param theme_config Optional list of custom theme parameters.
#'
#' @return A character string containing the CSS for the theme.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Use built-in themes - case insensitive
#' css1 <- get_theme_css(theme = "Midnight")
#' css2 <- get_theme_css(theme = "midnight")    # Same result
#' }
get_theme_css <- function(theme = "Light", theme_config = NULL) {
  # Validate and normalize theme name (case-insensitive)
  validated_theme <- validate_theme_name(theme, error_on_invalid = FALSE)
  
  if (is.null(validated_theme)) {
    message("Invalid theme name provided, falling back to 'Light' theme.")
    validated_theme <- "Light"
  }
  
  # Use custom theme_config if provided, otherwise use built-in theme
  if (!is.null(theme_config)) {
    # For custom themes, still use the CSS loading system
    css <- load_theme_css(validated_theme)
    message("Custom theme configuration provided. Loading base theme: ", validated_theme)
  } else {
    # Use built-in theme with case-insensitive matching
    css <- load_theme_css(validated_theme)
  }
  
  # Generate LLM assistance prompt if enabled
  if (getOption("inrep.llm_assistance", FALSE) && is_llm_assistance_enabled("ui")) {
    prompt <- generate_theme_optimization_prompt(
      theme_name = validated_theme,
      theme_configuration = theme_config,
      available_themes = get_builtin_themes()
    )
    display_llm_prompt(prompt, "theme")
  }
  
  return(css)
}

#' Generate LLM Prompt for Theme Design Optimization
#'
#' @description
#' Creates detailed prompts for optimizing theme design and visual aesthetics.
#'
#' @param theme_name Name of the selected theme
#' @param theme_configuration Custom theme configuration (if any)
#' @param available_themes Vector of available built-in themes
#' @param include_examples Whether to include implementation examples
#'
#' @return Character string containing the theme optimization prompt
#'
#' @export
#'
#' @examples
#' \dontrun{
#' prompt <- generate_theme_optimization_prompt(
#'   theme_name = "Midnight",
#'   theme_configuration = NULL,
#'   available_themes = get_builtin_themes()
#' )
#' cat(prompt)
#' }
generate_theme_optimization_prompt <- function(theme_name,
                                              theme_configuration = NULL,
                                              available_themes = get_builtin_themes(),
                                              include_examples = TRUE) {
  
  prompt <- paste0(
    "# THEME DESIGN AND VISUAL AESTHETICS OPTIMIZATION\n\n",
    "You are a senior UI/UX designer and color psychology expert specializing in research-grade assessment interfaces. I need comprehensive guidance for optimizing theme design and visual aesthetics for my inrep adaptive testing study.\n\n",
    
    "## CURRENT THEME CONFIGURATION\n",
    "- Selected Theme: ", theme_name, "\n",
    "- Custom Configuration: ", ifelse(!is.null(theme_configuration), "Yes", "No"), "\n",
    "- Available Built-in Themes: ", length(available_themes), " options\n",
    "- Built-in Options: ", paste(available_themes, collapse = ", "), "\n\n"
  )
  
  if (!is.null(theme_configuration)) {
    prompt <- paste0(prompt,
      "## CUSTOM THEME DETAILS\n",
      "- Custom theme configuration provided\n",
      "- Base theme: ", theme_name, "\n",
      "- Configuration elements: ", length(theme_configuration), " parameters\n\n"
    )
  }
  
  # Add detailed analysis sections
  prompt <- paste0(prompt,
    "## THEME OPTIMIZATION ANALYSIS\n\n",
    
    "### 1. Color Psychology and User Experience\n",
    "- Evaluate color choices for psychological research contexts\n",
    "- Assess impact on participant mood and performance\n",
    "- Analyze cultural sensitivity and accessibility of color palette\n",
    "- Review contrast ratios and visual hierarchy\n",
    "- Suggest improvements for test anxiety reduction\n\n",
    
    "### 2. Accessibility and Inclusion\n",
    "- WCAG 2.1 AA compliance for color contrast\n",
    "- Color blindness considerations and alternative indicators\n",
    "- High contrast mode compatibility\n",
    "- Screen reader and assistive technology support\n",
    "- Age-appropriate design for target demographics\n\n",
    
    "### 3. Professional and Academic Standards\n",
    "- Appropriateness for research and academic contexts\n",
    "- Brand consistency and institutional requirements\n",
    "- Cross-cultural acceptability and neutrality\n",
    "- Print and documentation compatibility\n",
    "- Long-term visual fatigue considerations\n\n",
    
    "### 4. Technical Implementation\n",
    "- CSS optimization and performance considerations\n",
    "- Cross-browser compatibility testing\n",
    "- Responsive design for multiple screen sizes\n",
    "- Dark mode and light mode variations\n",
    "- Animation and transition guidelines\n\n",
    
    "### 5. Theme Customization Strategy\n",
    "- Recommend theme selection for specific study types\n",
    "- Suggest custom theme development approaches\n",
    "- Design theme switching and user preference systems\n",
    "- Plan for institutional branding integration\n",
    "- Create theme validation and testing procedures\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE COMPREHENSIVE RECOMMENDATIONS\n",
      "1. **Theme Selection**: Best theme choice for my specific research context\n",
      "2. **Color Optimization**: Specific color palette improvements with rationale\n",
      "3. **Custom CSS**: Code examples for advanced theme customization\n",
      "4. **Accessibility Enhancements**: WCAG-compliant color and contrast improvements\n",
      "5. **Psychology Integration**: Research-backed design principles for assessments\n",
      "6. **Cross-Platform Compatibility**: Testing and validation procedures\n",
      "7. **Implementation Strategy**: Step-by-step theme deployment plan\n\n",
      
      "Please provide actionable recommendations with specific CSS code examples, color specifications (hex codes), and implementation guidelines."
    )
  }
  
  return(prompt)
}

#' Launch Theme Editor
#'
#' Opens a web-based GUI for creating custom themes.
#'
#' @return Opens the theme editor in the default browser.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Launch the theme editor
#' launch_theme_editor()
#' }
launch_theme_editor <- function() {
  editor_path <- system.file("theme_editor", "index.html", package = "inrep")
  if (editor_path == "" || !file.exists(editor_path)) {
    stop("Theme editor not found. Please ensure the package is installed correctly.")
  }
  utils::browseURL(editor_path)
}
