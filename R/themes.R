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
  # Try to get themes from installed package first
  theme_dir <- system.file("themes", package = "inrep")
  
  # If package not installed, try to find themes in current directory
  if (theme_dir == "") {
    theme_dir <- "inst/themes"
  }
  
  # Check if theme directory exists
  if (!dir.exists(theme_dir)) {
    # Fallback to hardcoded list of known themes
    return(c("light", "dark", "professional", "clinical", "research", "hildesheim", 
             "inrep", "accessible-blue", "colorblind-safe", "dyslexia-friendly", 
             "high-contrast", "large-text", "midnight", "ocean", "forest", 
             "berry", "sunset", "sepia", "paper", "monochrome", "vibrant", 
             "darkblue", "dark-mode"))
  }
  
  # Get all CSS files from theme directory
  theme_files <- list.files(
    theme_dir, 
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
  
  # If package not installed, try to find CSS in current directory
  if (css_path == "") {
    css_path <- file.path("inst/themes", paste0(theme, ".css"))
  }
  
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
  
  css_path <- system.file("themes", paste0(theme, ".css"), package = "inrep")
  
  # If package not installed, try to find CSS in current directory
  if (css_path == "") {
    css_path <- file.path("inst/themes", paste0(theme, ".css"))
  }
  
  css_path
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

#' Launch Theme Editor
#' @description
#' Launches an interactive web-based theme editor for customizing the appearance
#' of inrep assessment interfaces. Provides real-time preview and CSS customization
#' capabilities.
#' @return A Shiny application object for the theme editor
#' @export
launch_theme_editor <- function() {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Shiny package is required for theme editor")
  }
  
  ui <- shiny::fluidPage(
    shiny::titlePanel("inrep Theme Editor"),
    shiny::sidebarLayout(
      shiny::sidebarPanel(
        shiny::selectInput("theme_select", "Select Theme", choices = get_builtin_themes()),
        shiny::colourInput("primary_color", "Primary Color", value = "#007bff"),
        shiny::colourInput("secondary_color", "Secondary Color", value = "#6c757d"),
        shiny::colourInput("background_color", "Background Color", value = "#ffffff"),
        shiny::colourInput("text_color", "Text Color", value = "#212529"),
        shiny::textInput("font_family", "Font Family", value = "Inter, sans-serif"),
        shiny::sliderInput("border_radius", "Border Radius", min = 0, max = 20, value = 8),
        shiny::actionButton("apply_changes", "Apply Changes"),
        shiny::downloadButton("download_css", "Download CSS")
      ),
      shiny::mainPanel(
        shiny::h3("Theme Preview"),
        shiny::tags$div(
          id = "theme_preview",
          style = "padding: 20px; border: 1px solid #ddd; border-radius: 8px;",
          shiny::tags$h4("Sample Assessment Question"),
          shiny::tags$p("This is how your assessment will look with the selected theme."),
          shiny::tags$div(
            class = "btn-group",
            shiny::tags$button(class = "btn btn-primary", "Option 1"),
            shiny::tags$button(class = "btn btn-secondary", "Option 2"),
            shiny::tags$button(class = "btn btn-success", "Option 3")
          )
        ),
        shiny::verbatimTextOutput("css_output")
      )
    )
  )
  
  server <- function(input, output, session) {
    theme_css <- shiny::reactive({
      css <- sprintf('
        :root {
          --primary-color: %s;
          --secondary-color: %s;
          --background-color: %s;
          --text-color: %s;
          --font-family: %s;
          --border-radius: %spx;
        }
        
        body {
          font-family: var(--font-family);
          background-color: var(--background-color);
          color: var(--text-color);
        }
        
        .btn-primary {
          background-color: var(--primary-color);
          border-color: var(--primary-color);
          border-radius: var(--border-radius);
        }
        
        .btn-secondary {
          background-color: var(--secondary-color);
          border-color: var(--secondary-color);
          border-radius: var(--border-radius);
        }
        
        .assessment-card {
          background-color: var(--background-color);
          color: var(--text-color);
          border-radius: var(--border-radius);
          padding: 20px;
          margin: 10px 0;
          box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
      ', 
      input$primary_color, 
      input$secondary_color, 
      input$background_color, 
      input$text_color, 
      input$font_family, 
      input$border_radius
      )
      css
    })
    
    output$css_output <- shiny::renderText({
      theme_css()
    })
    
    shiny::observeEvent(input$apply_changes, {
      shiny::runjs(sprintf('
        document.getElementById("theme_preview").style.cssText = `
          background-color: %s;
          color: %s;
          border-radius: %spx;
        `;
      ', input$background_color, input$text_color, input$border_radius))
    })
    
    output$download_css <- shiny::downloadHandler(
      filename = function() {
        paste0("inrep_custom_theme_", Sys.Date(), ".css")
      },
      content = function(file) {
        writeLines(theme_css(), file)
      }
    )
  }
  
  shiny::shinyApp(ui = ui, server = server)
}
