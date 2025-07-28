#' Validate Theme Name
#' @param theme_name Theme name to validate
#' @return Validated theme name if found, otherwise 'light'
#' @export
validate_theme_name <- function(theme_name) {
  theme_name <- tolower(theme_name)
  valid_themes <- tolower(get_builtin_themes())
  match_index <- match(theme_name, valid_themes)
  if (!is.na(match_index)) {
    return(get_builtin_themes()[match_index])
  }
  warning(sprintf("Theme '%s' not found, using 'light'", theme_name))
  "light"
}

#' Get All Available Themes
#' @return Character vector of available themes
#' @export
get_builtin_themes <- function() {
  # Get all CSS files from inst/themes/
  theme_files <- list.files(
    system.file("themes", package = "inrep"), 
    pattern = "\\.css$", 
    full.names = FALSE
  )
  # Remove .css extension and return
  tools::file_path_sans_ext(theme_files)
}

#' Generate CSS for Theme
#' @param theme Theme name (case-insensitive)
#' @param custom_css Optional custom CSS to append
#' @return CSS string
#' @export
get_theme_css <- function(theme = "light", custom_css = NULL) {
  theme <- tolower(theme)
  
  # Get available themes
  available_themes <- tolower(get_builtin_themes())
  
  # Find matching theme
  match_index <- match(theme, available_themes)
  
  if (is.na(match_index)) {
    warning(sprintf("Theme '%s' not found, using 'light'", theme))
    theme <- "light"
  } else {
    theme <- get_builtin_themes()[match_index]
  }
  
  # Construct CSS file path
  css_path <- system.file("themes", paste0(theme, ".css"), package = "inrep")
  
  if (!file.exists(css_path)) {
    warning(sprintf("CSS file for theme '%s' not found: %s", theme, css_path))
    return("")
  }
  
  # Read CSS content
  css_content <- paste(readLines(css_path, warn = FALSE), collapse = "\n")
  
  # Append custom CSS if provided
  if (!is.null(custom_css)) {
    css_content <- paste0(css_content, "\n", custom_css)
  }
  
  return(css_content)
}

#' Get Theme CSS File Path
#' @param theme Theme name
#' @return Full path to CSS file
#' @export
get_theme_css_path <- function(theme) {
  theme <- tolower(theme)
  available_themes <- tolower(get_builtin_themes())
  
  match_index <- match(theme, available_themes)
  if (is.na(match_index)) {
    theme <- "light"
  } else {
    theme <- get_builtin_themes()[match_index]
  }
  
  system.file("themes", paste0(theme, ".css"), package = "inrep")
}

#' List Available Theme Files
#' @return Data frame with theme names and file paths
#' @export
list_theme_files <- function() {
  theme_dir <- system.file("themes", package = "inrep")
  files <- list.files(theme_dir, pattern = "\\.css$", full.names = TRUE)
  
  data.frame(
    theme_name = tools::file_path_sans_ext(basename(files)),
    file_path = files,
    stringsAsFactors = FALSE
  )
}
