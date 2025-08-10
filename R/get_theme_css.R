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