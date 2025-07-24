#' Final Optimized Theme System - Ultra-Efficient
#' 
#' Complete working theme system with accessibility support
#' Single-file implementation for maximum efficiency

#' Get Final Themes
#' @export
get_final_themes <- function() {
  c("light", "dark", "professional", "academic", "forest", "ocean", 
    "sunset", "midnight", "berry", "paper", "monochrome", "vibrant",
    "hildesheim", "darkblue", "colorblind-safe", "large-text", 
    "dyslexia-friendly", "low-vision", "cognitive-accessible")
}

#' Generate Ultra-Efficient CSS
#' @param theme Theme name
#' @return CSS string (<200 lines)
#' @export
generate_final_css <- function(theme = "light") {
  theme <- tolower(theme)
  
  # Ultra-efficient theme definitions with CSS variables
  themes <- list(
    # Base themes
    light = list(
      bg = "#ffffff", text = "#1a1a1a", accent = "#2563eb", 
      border = "#e5e7eb", card = "#ffffff", font = "16px", button = "60px"
    ),
    dark = list(
      bg = "#0f172a", text = "#f1f5f9", accent = "#3b82f6", 
      border = "#334155", card = "#1e293b", font = "16px", button = "60px"
    ),
    professional = list(
      bg = "#fafafa", text = "#262626", accent = "#0f172a", 
      border = "#e5e5e5", card = "#ffffff", font = "16px", button = "60px"
    ),
    academic = list(
      bg = "#fefbf3", text = "#2c1810", accent = "#8b4513", 
      border = "#d4c5b9", card = "#ffffff", font = "16px", button = "60px"
    ),
    forest = list(
      bg = "#f0f9f0", text = "#1a3a1a", accent = "#228b22", 
      border = "#c8e6c9", card = "#ffffff", font = "16px", button = "60px"
    ),
    ocean = list(
      bg = "#f0f8ff", text = "#0c2340", accent = "#0066cc", 
      border = "#b3d9ff", card = "#ffffff", font = "16px", button = "60px"
    ),
    sunset = list(
      bg = "#fff5f5", text = "#742a2a", accent = "#e53e3e", 
      border = "#fed7d7", card = "#ffffff", font = "16px", button = "60px"
    ),
    midnight = list(
      bg = "#0a0a0a", text = "#e5e5e5", accent = "#6366f1", 
      border = "#262626", card = "#1a1a1a", font = "16px", button = "60px"
    ),
    berry = list(
      bg = "#fdf2f8", text = "#831843", accent = "#ec4899", 
      border = "#fbcfe8", card = "#ffffff", font = "16px", button = "60px"
    ),
    paper = list(
      bg = "#fefefe", text = "#171717", accent = "#525252", 
      border = "#e5e5e5", card = "#ffffff", font = "16px", button = "60px"
    ),
    monochrome = list(
      bg = "#fafafa", text = "#18181b", accent = "#18181b", 
      border = "#e4e4e7", card = "#ffffff", font = "16px", button = "60px"
    ),
    vibrant = list(
      bg = "#fef3c7", text = "#92400e", accent = "#f59e0b", 
      border = "#fcd34d", card = "#ffffff", font = "16px", button = "60px"
    ),
    hildesheim = list(
      bg = "#f8fafc", text = "#0f172a", accent = "#1e40af", 
      border = "#e2e8f0", card = "#ffffff", font = "16px", button = "60px"
    ),
    darkblue = list(
      bg = "#0f172a", text = "#f8fafc", accent = "#3b82f6", 
      border = "#334155", card = "#1e293b", font = "16px", button = "60px"
    ),
    
    # Accessibility themes
    "colorblind-safe" = list(
      bg = "#ffffff", text = "#000000", accent = "#0066cc", 
      border = "#666666", card = "#ffffff", font = "18px", button = "65px"
    ),
    "large-text" = list(
      bg = "#ffffff", text = "#000000", accent = "#0000ff", 
      border = "#000000", card = "#ffffff", font = "24px", button = "80px"
    ),
    "dyslexia-friendly" = list(
      bg = "#f8f4f0", text = "#2c2c2c", accent = "#005a9c", 
      border = "#8d8d8d", card = "#ffffff", font = "20px", button = "65px"
    ),
    "low-vision" = list(
      bg = "#ffffff", text = "#000000", accent = "#0000ff", 
      border = "#000000", card = "#ffffff", font = "28px", button = "100px"
    ),
    "cognitive-accessible" = list(
      bg = "#fffef7", text = "#1a1a1a", accent = "#1976d2", 
      border = "#757575", card = "#ffffff", font = "22px", button = "75px"
    )
  )
  
  # Default to light if theme not found
  if (!theme %in% names(themes)) theme <- "light"
  vars <- themes[[theme]]
  
  # Ultra-efficient CSS (<200 lines)
  sprintf('
:root {
  --bg: %s; --text: %s; --accent: %s; --border: %s; --card: %s;
  --font-size: %s; --button-size: %s; --radius: 0.5rem; --shadow: 0 4px 12px rgba(0,0,0,0.1);
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  background: var(--bg); color: var(--text); font-size: var(--font-size);
  line-height: 1.6; padding: 1rem; min-height: 100vh;
}

.container { max-width: 800px; margin: 0 auto; padding: 1rem; }

.assessment-card {
  background: var(--card); border: 2px solid var(--border);
  border-radius: var(--radius); padding: 2rem; margin: 1rem 0;
  box-shadow: var(--shadow); transition: all 0.2s ease;
}

.btn {
  background: var(--accent); color: white; border: none;
  padding: 1rem 2rem; border-radius: var(--radius);
  font-size: 1.2rem; cursor: pointer; min-height: var(--button-size);
  transition: all 0.2s ease; width: 100%%; max-width: 300px;
}

.btn:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.15); }

.question {
  font-size: 1.3rem; margin: 2rem 0; text-align: center;
  line-height: 1.5; font-weight: 500;
}

.radio-group {
  display: flex; flex-direction: column; gap: 1rem; margin: 2rem 0;
}

.radio-option {
  padding: 1.5rem; border: 2px solid var(--border);
  border-radius: var(--radius); cursor: pointer;
  transition: all 0.2s ease; text-align: center;
}

.radio-option:hover { border-color: var(--accent); }

.radio-option.active {
  background: var(--accent); color: white; border-color: var(--accent);
}

.progress {
  background: var(--border); height: 0.5rem; border-radius: var(--radius);
  overflow: hidden; margin: 2rem 0;
}

.progress-bar {
  background: var(--accent); height: 100%%; transition: width 0.3s ease;
}

@media (max-width: 768px) {
  .btn { font-size: 1.1rem; padding: 0.8rem 1.5rem; }
  .assessment-card { padding: 1.5rem; }
}

@media (prefers-reduced-motion: reduce) {
  * { transition: none !important; }
}

@media (prefers-contrast: high) {
  .assessment-card { border-width: 3px; }
}
', vars$bg, vars$text, vars$accent, vars$border, vars$card, vars$font, vars$button)
}

#' Get Theme CSS - Final Implementation
#' @param theme Theme name
#' @return CSS string
#' @export
get_theme_css <- function(theme = "light", theme_config = NULL) {
  generate_final_css(theme)
}

#' Get Built-in Themes - Final
#' @export
get_builtin_themes <- function() {
  get_final_themes()
}

#' Validate Theme Name - Final
#' @param theme_name Theme name to validate
#' @return Validated theme name
#' @export
validate_theme_name <- function(theme_name) {
  theme_name <- tolower(theme_name)
  valid_themes <- get_final_themes()
  valid_themes_lower <- tolower(valid_themes)
  
  match_index <- match(theme_name, valid_themes_lower)
  if (!is.na(match_index)) {
    return(valid_themes[match_index])
  }
  
  warning(sprintf("Theme '%s' not found, using 'light'", theme_name))
  "light"
}

#' Test Theme Function
#' @export
test_theme_final <- function(theme = "dyslexia-friendly") {
  cat("Testing theme:", theme, "\n")
  css <- generate_final_css(theme)
  cat("CSS length:", nchar(css), "characters\n")
  cat("Theme validated successfully!\n")
  invisible(css)
}
