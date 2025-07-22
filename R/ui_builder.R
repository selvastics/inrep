# File: ui_builder.R

#' Build Themed Study UI for IRT-Based Assessments
#'
#' @description
#' Builds a comprehensive Shiny UI for adaptive testing with customizable themes,
#' professional styling, and accessibility features. Integrates scraped website
#' assets, custom CSS, and responsive design elements for research-grade assessments.
#'
#' @param study_config List containing study configuration with theme settings.
#'   Common elements include \code{title}, \code{subtitle}, \code{logo_path},
#'   \code{show_progress}, and \code{max_items}.
#' @param theme_config List containing theme configuration with styling parameters.
#'   Elements include \code{primary_color}, \code{background_color}, \code{font_family},
#'   and \code{logo_path}.
#' @param custom_css Optional character string of custom CSS to include for
#'   additional styling and branding.
#' @param enable_responsive Logical indicating whether to enable responsive design
#'   for mobile and tablet compatibility. Default is \code{TRUE}.
#' @param enable_accessibility Logical indicating whether to enable accessibility
#'   features (ARIA labels, keyboard navigation). Default is \code{TRUE}.
#' @param custom_js Optional character string of custom JavaScript to include
#'   for advanced interactions and analytics.
#' @param additional_assets Optional list of additional assets (CSS/JS files)
#'   to include from external sources.
#'
#' @return Shiny UI object with the specified theme and configuration,
#'   ready for use with \code{\link{launch_study}} or custom Shiny server functions.
#'
#' @export
#'
#' @details
#' This function creates a comprehensive Shiny UI for adaptive testing with:
#' 
#' \strong{Core Features:}
#' \itemize{
#'   \item Professional header with optional logo and branding
#'   \item Progress indicators and navigation elements
#'   \item Responsive item presentation with mobile support
#'   \item Accessibility features (ARIA labels, keyboard navigation)
#'   \item Custom CSS/JS integration for advanced customization
#'   \item Theme switching capabilities for user preferences
#' }
#' 
#' \strong{Theme Integration:}
#' \itemize{
#'   \item Integration with scraped website assets via \code{\link{scrape_website_ui}}
#'   \item Custom color schemes and typography
#'   \item Professional styling for research contexts
#'   \item Responsive design for multiple screen sizes
#' }
#' 
#' \strong{Accessibility Compliance:}
#' \itemize{
#'   \item WCAG 2.1 AA compliance when accessibility is enabled
#'   \item Screen reader support with proper ARIA labels
#'   \item Keyboard navigation for all interactive elements
#'   \item High contrast options and scalable text
#' }
#' 
#' \strong{Performance Optimization:}
#' \itemize{
#'   \item Efficient CSS and JavaScript loading
#'   \item Responsive image handling
#'   \item Minimal external dependencies
#'   \item Progressive enhancement approach
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic UI with Default Theme
#' library(inrep)
#' 
#' # Create basic study configuration
#' study_config <- list(
#'   title = "Big Five Personality Assessment",
#'   subtitle = "Research Study",
#'   max_items = 20,
#'   show_progress = TRUE
#' )
#' 
#' # Build UI with default theme
#' ui <- build_study_ui(study_config = study_config)
#' 
#' # View UI structure
#' cat("UI created successfully\n")
#' 
#' # Example 2: Custom Theme from Scraped Website
#' # First, scrape website for theme assets
#' scraped_data <- scrape_website_ui("https://www.uni-hildesheim.de/")
#' 
#' # Use scraped theme
#' custom_study_config <- list(
#'   title = "Cognitive Assessment Study",
#'   subtitle = "University Research Project",
#'   logo_path = "path/to/logo.png",
#'   max_items = 30,
#'   show_progress = TRUE,
#'   enable_theme_switching = TRUE
#' )
#' 
#' # Build UI with scraped theme
#' themed_ui <- build_study_ui(
#'   study_config = custom_study_config,
#'   theme_config = scraped_data$themes[[1]],
#'   custom_css = "
#'     .assessment-container {
#'       max-width: 800px;
#'       margin: 0 auto;
#'       padding: 20px;
#'     }
#'     .progress-bar {
#'       background: linear-gradient(45deg, #007bff, #0056b3);
#'     }
#'   "
#' )
#' 
#' # Example 3: Professional Clinical Interface
#' # Create clinical assessment configuration
#' clinical_config <- list(
#'   title = "Clinical Depression Inventory",
#'   subtitle = "Confidential Assessment",
#'   max_items = 15,
#'   show_progress = TRUE,
#'   enable_theme_switching = FALSE  # Fixed theme for consistency
#' )
#' 
#' # Clinical theme configuration
#' clinical_theme <- list(
#'   name = "Clinical Theme",
#'   primary_color = "#2c3e50",
#'   background_color = "#f8f9fa",
#'   font_family = "'Helvetica Neue', Arial, sans-serif",
#'   logo_path = "clinical_logo.png"
#' )
#' 
#' # Build clinical UI
#' clinical_ui <- build_study_ui(
#'   study_config = clinical_config,
#'   theme_config = clinical_theme,
#'   enable_accessibility = TRUE,
#'   custom_css = "
#'     .clinical-interface {
#'       background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
#'       min-height: 100vh;
#'     }
#'     .question-card {
#'       border: 1px solid #dee2e6;
#'       border-radius: 8px;
#'       padding: 24px;
#'       margin: 16px 0;
#'       background: white;
#'       box-shadow: 0 2px 8px rgba(0,0,0,0.1);
#'     }
#'   "
#' )
#' 
#' # Example 4: Mobile-Optimized Educational Interface
#' # Create educational assessment configuration
#' educational_config <- list(
#'   title = "Mathematics Proficiency Test",
#'   subtitle = "Grade 8 Assessment",
#'   max_items = 25,
#'   show_progress = TRUE,
#'   enable_theme_switching = TRUE
#' )
#' 
#' # Educational theme with bright colors
#' educational_theme <- list(
#'   name = "Educational Theme",
#'   primary_color = "#28a745",
#'   background_color = "#f8f9fa",
#'   font_family = "'Comic Sans MS', cursive",
#'   logo_path = "school_logo.png"
#' )
#' 
#' # Build educational UI with mobile optimization
#' educational_ui <- build_study_ui(
#'   study_config = educational_config,
#'   theme_config = educational_theme,
#'   enable_responsive = TRUE,
#'   custom_css = "
#'     @media (max-width: 768px) {
#'       .main-container {
#'         padding: 10px;
#'       }
#'       .question-text {
#'         font-size: 18px;
#'         line-height: 1.5;
#'       }
#'       .response-options {
#'         margin-top: 20px;
#'       }
#'     }
#'     .educational-header {
#'       background: linear-gradient(45deg, #28a745, #20c997);
#'       color: white;
#'       padding: 20px;
#'       text-align: center;
#'     }
#'   "
#' )
#' 
#' # Example 5: Advanced UI with Custom JavaScript
#' # Create advanced configuration
#' advanced_config <- list(
#'   title = "Advanced Personality Research",
#'   subtitle = "Longitudinal Study",
#'   max_items = 50,
#'   show_progress = TRUE,
#'   enable_theme_switching = TRUE
#' )
#' 
#' # Advanced theme
#' advanced_theme <- list(
#'   name = "Research Theme",
#'   primary_color = "#6f42c1",
#'   background_color = "#f8f9fa",
#'   font_family = "'Inter', sans-serif",
#'   logo_path = "research_logo.png"
#' )
#' 
#' # Custom JavaScript for analytics and interactions
#' custom_js <- "
#'   // Response time tracking
#'   let responseStartTime = Date.now();
#'   
#'   // Track user interactions
#'   document.addEventListener('click', function(e) {
#'     if (e.target.type === 'radio') {
#'       const responseTime = Date.now() - responseStartTime;
#'       Shiny.setInputValue('response_time', responseTime);
#'     }
#'   });
#'   
#'   // Accessibility enhancements
#'   document.addEventListener('keydown', function(e) {
#'     if (e.key === 'Tab') {
#'       document.body.classList.add('keyboard-navigation');
#'     }
#'   });
#' "
#' 
#' # Build advanced UI
#' advanced_ui <- build_study_ui(
#'   study_config = advanced_config,
#'   theme_config = advanced_theme,
#'   enable_responsive = TRUE,
#'   enable_accessibility = TRUE,
#'   custom_js = custom_js,
#'   additional_assets = list(
#'     css = c("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap"),
#'     js = c("https://cdn.jsdelivr.net/npm/chart.js")
#'   )
#' )
#' 
#' # Example 6: Complete Assessment Application
#' # Create complete Shiny application
#' create_complete_assessment <- function(config, theme, item_bank) {
#'   # Build UI
#'   ui <- build_study_ui(
#'     study_config = config,
#'     theme_config = theme,
#'     enable_responsive = TRUE,
#'     enable_accessibility = TRUE
#'   )
#'   
#'   # Create server function
#'   server <- function(input, output, session) {
#'     # Initialize reactive values
#'     rv <- init_reactive_values(config)
#'     
#'     # Launch study logic would go here
#'     # This would typically use launch_study() function
#'     
#'     output$ui_status <- renderText({
#'       "Assessment UI loaded successfully"
#'     })
#'   }
#'   
#'   # Return Shiny app
#'   return(shinyApp(ui = ui, server = server))
#' }
#' 
#' # Example usage (commented out to prevent data conflicts):
#' # data(bfi_items)
#' # config <- create_study_config(name = "BFI Assessment", model = "GRM")
#' 
#' # This would create a complete Shiny application
#' # app <- create_complete_assessment(study_config, NULL, bfi_items)
#' # runApp(app)
#' 
#' # Example 7: UI Validation and Testing
#' # Test UI generation and validation
#' test_ui_generation <- function() {
#'   cat("Testing UI generation...\n")
#'   
#'   # Test configurations
#'   test_configs <- list(
#'     basic = list(title = "Basic Test"),
#'     advanced = list(title = "Advanced Test", max_items = 30, show_progress = TRUE),
#'     minimal = list(title = "Minimal Test", show_progress = FALSE)
#'   )
#'   
#'   # Test themes
#'   test_themes <- list(
#'     default = NULL,
#'     custom = list(primary_color = "#007bff", background_color = "#ffffff")
#'   )
#'   
#'   results <- list()
#'   
#'   for (config_name in names(test_configs)) {
#'     for (theme_name in names(test_themes)) {
#'       cat("Testing:", config_name, "config with", theme_name, "theme\n")
#'       
#'       tryCatch({
#'         ui <- build_study_ui(
#'           study_config = test_configs[[config_name]],
#'           theme_config = test_themes[[theme_name]]
#'         )
#'         
#'         results[[paste(config_name, theme_name, sep = "_")]] <- "SUCCESS"
#'         cat("  [OK] Success\n")
#'         
#'       }, error = function(e) {
#'         results[[paste(config_name, theme_name, sep = "_")]] <- paste("ERROR:", e$message)
#'         cat("  X Error:", e$message, "\n")
#'       })
#'     }
#'   }
#'   
#'   cat("\nUI Generation Test Results:\n")
#'   cat("===========================\n")
#'   for (test_name in names(results)) {
#'     cat(sprintf("%-20s: %s\n", test_name, results[[test_name]]))
#'   }
#'   
#'   return(results)
#' }
#' 
#' # Run UI tests
#' test_results <- test_ui_generation()
#' }
#'
#' @seealso
#' \itemize{
#'   \item \code{\link{scrape_website_ui}} for theme asset extraction
#'   \item \code{\link{launch_study}} for complete assessment workflow
#'   \item \code{\link{create_study_config}} for configuration setup
#'   \item \code{\link{get_builtin_themes}} for available built-in themes
#' }
#'
#' @references
#' Chang, W., Cheng, J., Allaire, J., Xie, Y., & McPherson, J. (2021). 
#' shiny: Web Application Framework for R. R package version 1.6.0. 
#' \url{https://CRAN.R-project.org/package=shiny}
#' 
#' @keywords UI interface shiny themes accessibility responsive-design
build_study_ui <- function(
    study_config = list(),
    theme_config = NULL,
    custom_css = NULL,
    enable_responsive = TRUE,
    enable_accessibility = TRUE,
    custom_js = NULL,
    additional_assets = NULL
) {
  # Load required packages
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required for UI building. Please install it with install.packages('shiny')")
  }
  if (!requireNamespace("shinydashboard", quietly = TRUE)) {
    stop("Package 'shinydashboard' is required for UI building. Please install it with install.packages('shinydashboard')")
  }
  if (!requireNamespace("DT", quietly = TRUE)) {
    stop("Package 'DT' is required for UI building. Please install it with install.packages('DT')")
  }
  
  # Default study configuration
  default_config <- list(
    title = "Adaptive Testing Study",
    subtitle = "Psychological Assessment",
    logo_path = NULL,
    show_progress = TRUE,
    enable_theme_switching = TRUE,
    max_items = 20,
    min_items = 5
  )
  study_config <- modifyList(default_config, study_config)
  
  # Default theme configuration
  default_theme <- list(
    name = "Default Theme",
    primary_color = "#007bff",
    background_color = "#f8f9fa",
    font_family = "'Inter', sans-serif",
    logo_path = NULL
  )
  if (is.null(theme_config)) {
    theme_config <- default_theme
  } else {
    theme_config <- modifyList(default_theme, theme_config)
  }
  
  # Generate theme CSS
  theme_css <- generate_theme_css(theme_config, enable_responsive, enable_accessibility)
  
  # Combine all CSS
  all_css <- paste(
    theme_css,
    if (!is.null(custom_css)) custom_css else "",
    sep = "\n"
  )
  
  # Generate header
  header <- generate_header(study_config, theme_config)
  
  # Generate sidebar
  sidebar <- generate_sidebar(study_config, theme_config)
  
  # Generate main content with study flow support
  main_content <- generate_main_content(study_config, theme_config)
  
  # Generate study flow UI if enabled
  study_flow_ui <- NULL
  if (study_config$show_introduction || study_config$show_briefing || 
      study_config$show_consent || study_config$show_gdpr_compliance ||
      study_config$show_debriefing) {
    study_flow_ui <- generate_study_flow_ui(study_config, theme_config)
  }
  
  # Generate footer
  footer <- generate_footer(study_config, theme_config)
  
  # Build complete UI
  ui <- shiny::fluidPage(
    # Head section with meta tags and assets
    shiny::tags$head(
      # Meta tags
      shiny::tags$meta(charset = "utf-8"),
      shiny::tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
      shiny::tags$meta(name = "description", content = study_config$subtitle),
      
      # External CSS libraries
      shiny::tags$link(
        rel = "stylesheet",
        href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
      ),
      shiny::tags$link(
        rel = "stylesheet",
        href = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css"
      ),
      
      # Custom CSS
      shiny::tags$style(shiny::HTML(all_css)),
      
      # Additional CSS assets
      if (!is.null(additional_assets$css)) {
        lapply(additional_assets$css, function(css_file) {
          if (file.exists(css_file)) {
            shiny::tags$style(shiny::HTML(readLines(css_file, warn = FALSE)))
          }
        })
      },
      
      # Custom JavaScript
      if (!is.null(custom_js)) {
        shiny::tags$script(shiny::HTML(custom_js))
      },
      
      # Additional JS assets
      if (!is.null(additional_assets$js)) {
        lapply(additional_assets$js, function(js_file) {
          if (file.exists(js_file)) {
            shiny::tags$script(src = js_file)
          }
        })
      },
      
      # Accessibility enhancements
      if (enable_accessibility) {
        shiny::tags$script(shiny::HTML("
          // Keyboard navigation support
          document.addEventListener('keydown', function(e) {
            if (e.key === 'Tab') {
              document.body.classList.add('keyboard-nav');
            }
          });
          
          // Screen reader announcements
          function announceToScreenReader(message) {
            const announcement = document.createElement('div');
            announcement.setAttribute('aria-live', 'polite');
            announcement.setAttribute('aria-atomic', 'true');
            announcement.setAttribute('class', 'sr-only');
            announcement.textContent = message;
            document.body.appendChild(announcement);
            setTimeout(() => document.body.removeChild(announcement), 1000);
          }
        "))
      }
    ),
    
    # Main layout
    shiny::div(
      class = "study-container",
      id = "main-container",
      
      # Header
      header,
      
      # Main content area
      shiny::div(
        class = "content-wrapper",
        
        # Sidebar (if enabled)
        if (study_config$enable_theme_switching || !is.null(sidebar)) {
          shiny::div(
            class = "sidebar-wrapper",
            sidebar
          )
        },
        
        # Main content
        shiny::div(
          class = if (study_config$enable_theme_switching) "main-content with-sidebar" else "main-content",
          
          # Study flow UI (if enabled)
          if (!is.null(study_flow_ui)) study_flow_ui,
          
          # Main assessment content
          main_content
        )
      ),
      
      # Footer
      footer
    )
  )
  
  # Generate LLM assistance prompt if enabled
  if (getOption("inrep.llm_assistance", FALSE) && is_llm_assistance_enabled("ui")) {
    prompt <- generate_ui_optimization_prompt(
      study_configuration = study_config,
      theme_configuration = theme_config,
      custom_styling = custom_css,
      responsive_enabled = enable_responsive,
      accessibility_enabled = enable_accessibility
    )
    display_llm_prompt(prompt, "ui")
  }
  
  return(ui)
}

#' Generate LLM Prompt for UI Design Optimization
#'
#' @description
#' Creates detailed prompts for optimizing user interface design and user experience.
#'
#' @param study_configuration Study configuration object
#' @param theme_configuration Theme configuration object
#' @param custom_styling Custom CSS string
#' @param responsive_enabled Whether responsive design is enabled
#' @param accessibility_enabled Whether accessibility features are enabled
#' @param include_examples Whether to include code examples
#'
#' @return Character string containing the UI optimization prompt
#'
#' @export
#'
#' @examples
#' \dontrun{
#' prompt <- generate_ui_optimization_prompt(
#'   study_configuration = list(title = "Personality Study"),
#'   theme_configuration = list(primary_color = "#007bff"),
#'   custom_styling = ".custom { color: red; }",
#'   responsive_enabled = TRUE,
#'   accessibility_enabled = TRUE
#' )
#' cat(prompt)
#' }
generate_ui_optimization_prompt <- function(study_configuration,
                                           theme_configuration,
                                           custom_styling = NULL,
                                           responsive_enabled = TRUE,
                                           accessibility_enabled = TRUE,
                                           include_examples = TRUE) {
  
  prompt <- paste0(
    "# UI/UX DESIGN OPTIMIZATION CONSULTATION\n\n",
    "You are a senior UX designer and web accessibility expert specializing in research-grade assessment interfaces. I need comprehensive guidance for optimizing the user interface and experience of my inrep adaptive testing study.\n\n",
    
    "## CURRENT UI CONFIGURATION\n",
    "- Study Title: '", study_configuration$title %||% "Untitled Study", "'\n",
    "- Subtitle: '", study_configuration$subtitle %||% "Assessment", "'\n",
    "- Logo: ", ifelse(!is.null(study_configuration$logo_path), "Yes", "No"), "\n",
    "- Progress Display: ", study_configuration$show_progress %||% TRUE, "\n",
    "- Theme Switching: ", study_configuration$enable_theme_switching %||% FALSE, "\n",
    "- Max Items: ", study_configuration$max_items %||% 20, "\n",
    "- Primary Color: ", theme_configuration$primary_color %||% "#007bff", "\n",
    "- Background: ", theme_configuration$background_color %||% "#f8f9fa", "\n",
    "- Font Family: ", theme_configuration$font_family %||% "Inter", "\n",
    "- Responsive Design: ", responsive_enabled, "\n",
    "- Accessibility: ", accessibility_enabled, "\n",
    "- Custom CSS: ", ifelse(!is.null(custom_styling), nchar(custom_styling), 0), " characters\n\n"
  )
  
  # Add detailed analysis sections
  prompt <- paste0(prompt,
    "## UI/UX OPTIMIZATION ANALYSIS\n\n",
    
    "### 1. User Experience Design\n",
    "- Evaluate current interface for research context appropriateness\n",
    "- Assess cognitive load and participant fatigue considerations\n",
    "- Analyze navigation flow and task completion efficiency\n",
    "- Review visual hierarchy and information architecture\n",
    "- Suggest improvements for engagement and completion rates\n\n",
    
    "### 2. Accessibility and Inclusion\n",
    "- WCAG 2.1 AA compliance assessment\n",
    "- Screen reader compatibility and ARIA implementation\n",
    "- Keyboard navigation and focus management\n",
    "- Color contrast and visual accessibility\n",
    "- Motor impairment and assistive technology support\n\n",
    
    "### 3. Responsive and Mobile Design\n",
    "- Mobile and tablet experience optimization\n",
    "- Touch interface design considerations\n",
    "- Cross-browser compatibility testing\n",
    "- Performance optimization for various devices\n",
    "- Progressive enhancement strategies\n\n",
    
    "### 4. Psychology-Informed Design\n",
    "- Reduce test anxiety through design choices\n",
    "- Minimize cognitive bias from visual elements\n",
    "- Optimize for different age groups and populations\n",
    "- Cultural sensitivity in design decisions\n",
    "- Motivation and engagement design patterns\n\n",
    
    "### 5. Technical Implementation\n",
    "- CSS/JavaScript optimization recommendations\n",
    "- Performance and loading speed improvements\n",
    "- Security considerations for research data\n",
    "- Analytics and user behavior tracking\n",
    "- Quality assurance and testing procedures\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE COMPREHENSIVE RECOMMENDATIONS\n",
      "1. **Design Improvements**: Specific UI/UX enhancements with rationale\n",
      "2. **Accessibility Upgrades**: WCAG-compliant implementation examples\n",
      "3. **Custom CSS/JS**: Code examples for advanced functionality\n",
      "4. **Responsive Enhancements**: Mobile-first design optimizations\n",
      "5. **Psychology Integration**: Research-backed design principles\n",
      "6. **Performance Optimization**: Technical improvements for speed and reliability\n",
      "7. **Quality Assurance**: Testing procedures and validation methods\n\n",
      
      "Please provide actionable recommendations with specific code examples, design mockups descriptions, and implementation strategies."
    )
  }
  
  return(prompt)
}

#' Generate Theme CSS
#'
#' Generates CSS styles based on theme configuration.
#'
#' @param theme_config List containing theme configuration.
#' @param enable_responsive Logical indicating whether to include responsive styles.
#' @param enable_accessibility Logical indicating whether to include accessibility styles.
#'
#' @return Character string containing CSS styles.
#'
#' @noRd
generate_theme_css <- function(theme_config, enable_responsive, enable_accessibility) {
  css <- sprintf("
    :root {
      --primary-color: %s;
      --background-color: %s;
      --font-family: %s;
      --text-color: %s;
      --border-color: %s;
      --shadow-color: rgba(0, 0, 0, 0.1);
      --transition: all 0.3s ease;
    }
    
    body {
      font-family: var(--font-family);
      background-color: var(--background-color);
      color: var(--text-color);
      margin: 0;
      padding: 0;
      line-height: 1.6;
    }
    
    .study-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
    }
    
    .header {
      background-color: var(--primary-color);
      color: white;
      padding: 1rem 2rem;
      box-shadow: 0 2px 4px var(--shadow-color);
    }
    
    .header h1 {
      margin: 0;
      font-size: 1.8rem;
      font-weight: 600;
    }
    
    .header p {
      margin: 0.5rem 0 0 0;
      opacity: 0.9;
    }
    
    .logo {
      max-height: 40px;
      margin-right: 1rem;
    }
    
    .content-wrapper {
      flex: 1;
      display: flex;
      min-height: 0;
    }
    
    .sidebar-wrapper {
      width: 250px;
      background-color: #f8f9fa;
      border-right: 1px solid var(--border-color);
      padding: 1rem;
    }
    
    .main-content {
      flex: 1;
      padding: 2rem;
    }
    
    .main-content.with-sidebar {
      margin-left: 0;
    }
    
    .progress-container {
      background-color: #e9ecef;
      height: 8px;
      border-radius: 4px;
      overflow: hidden;
      margin-bottom: 2rem;
    }
    
    .progress-bar {
      background-color: var(--primary-color);
      height: 100%%;
      transition: width var(--transition);
    }
    
    .item-container {
      background-color: white;
      border-radius: 8px;
      padding: 2rem;
      box-shadow: 0 2px 8px var(--shadow-color);
      margin-bottom: 2rem;
    }
    
    .item-text {
      font-size: 1.1rem;
      margin-bottom: 1.5rem;
      line-height: 1.7;
    }
    
    .response-options {
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
    }
    
    .response-option {
      display: flex;
      align-items: center;
      padding: 0.75rem;
      border: 2px solid var(--border-color);
      border-radius: 6px;
      cursor: pointer;
      transition: var(--transition);
    }
    
    .response-option:hover {
      border-color: var(--primary-color);
      background-color: rgba(var(--primary-color), 0.05);
    }
    
    .response-option.selected {
      border-color: var(--primary-color);
      background-color: var(--primary-color);
      color: white;
    }
    
    .btn {
      background-color: var(--primary-color);
      color: white;
      border: none;
      padding: 0.75rem 1.5rem;
      border-radius: 6px;
      font-size: 1rem;
      cursor: pointer;
      transition: var(--transition);
      font-family: var(--font-family);
    }
    
    .btn:hover {
      background-color: var(--primary-color);
      transform: translateY(-1px);
    }
    
    .btn:disabled {
      background-color: #6c757d;
      cursor: not-allowed;
      transform: none;
    }
    
    .footer {
      background-color: #f8f9fa;
      padding: 1rem 2rem;
      border-top: 1px solid var(--border-color);
      text-align: center;
      color: #6c757d;
    }
    
    .theme-selector {
      margin-bottom: 1rem;
    }
    
    .theme-option {
      display: flex;
      align-items: center;
      padding: 0.5rem;
      cursor: pointer;
      border-radius: 4px;
      transition: var(--transition);
    }
    
    .theme-option:hover {
      background-color: #e9ecef;
    }
    
    .theme-color {
      width: 20px;
      height: 20px;
      border-radius: 50%%;
      margin-right: 0.5rem;
      border: 2px solid white;
      box-shadow: 0 0 0 1px var(--border-color);
    }
  ",
  theme_config$primary_color,
  theme_config$background_color,
  theme_config$font_family,
  if (theme_config$background_color == "#212529") "#ffffff" else "#212529",
  if (theme_config$background_color == "#212529") "#495057" else "#dee2e6"
  )
  
  if (enable_responsive) {
    css <- paste(css, "
      @media (max-width: 768px) {
        .content-wrapper {
          flex-direction: column;
        }
        
        .sidebar-wrapper {
          width: 100%;
          order: 2;
        }
        
        .main-content {
          padding: 1rem;
        }
        
        .header {
          padding: 1rem;
        }
        
        .header h1 {
          font-size: 1.5rem;
        }
        
        .item-container {
          padding: 1.5rem;
        }
        
        .response-options {
          gap: 0.5rem;
        }
      }
      
      @media (max-width: 480px) {
        .header h1 {
          font-size: 1.3rem;
        }
        
        .item-container {
          padding: 1rem;
        }
        
        .item-text {
          font-size: 1rem;
        }
      }
    ", sep = "\n")
  }
  
  if (enable_accessibility) {
    css <- paste(css, "
      .sr-only {
        position: absolute;
        width: 1px;
        height: 1px;
        padding: 0;
        margin: -1px;
        overflow: hidden;
        clip: rect(0, 0, 0, 0);
        white-space: nowrap;
        border: 0;
      }
      
      .keyboard-nav *:focus {
        outline: 3px solid var(--primary-color);
        outline-offset: 2px;
      }
      
      .high-contrast {
        filter: contrast(150%);
      }
      
      .large-text {
        font-size: 1.2em;
      }
      
      .response-option[aria-selected='true'] {
        border-color: var(--primary-color);
        background-color: var(--primary-color);
        color: white;
      }
      
      @media (prefers-reduced-motion: reduce) {
        * {
          animation-duration: 0.01ms !important;
          animation-iteration-count: 1 !important;
          transition-duration: 0.01ms !important;
        }
      }
    ", sep = "\n")
  }
  
  return(css)
}

#' Generate Header Component
#'
#' Generates the header section of the UI.
#'
#' @param study_config List containing study configuration.
#' @param theme_config List containing theme configuration.
#'
#' @return Shiny tag object for the header.
#'
#' @noRd
generate_header <- function(study_config, theme_config) {
  logo_element <- NULL
  if (!is.null(theme_config$logo_path) && file.exists(theme_config$logo_path)) {
    logo_element <- shiny::tags$img(
      src = theme_config$logo_path,
      alt = "Logo",
      class = "logo"
    )
  }
  
  shiny::tags$header(
    class = "header",
    role = "banner",
    shiny::div(
      style = "display: flex; align-items: center;",
      logo_element,
      shiny::div(
        shiny::h1(study_config$title),
        shiny::p(study_config$subtitle)
      )
    )
  )
}

#' Generate Sidebar Component
#'
#' Generates the sidebar section of the UI.
#'
#' @param study_config List containing study configuration.
#' @param theme_config List containing theme configuration.
#'
#' @return Shiny tag object for the sidebar.
#'
#' @noRd
generate_sidebar <- function(study_config, theme_config) {
  if (!study_config$enable_theme_switching) {
    return(NULL)
  }
  
  shiny::tags$nav(
    class = "sidebar",
    role = "navigation",
    shiny::h3("Settings"),
    shiny::div(
      class = "theme-selector",
      shiny::h4("Theme"),
      shiny::div(
        id = "theme-options",
        # Theme options will be populated by JavaScript
      )
    ),
    shiny::div(
      class = "accessibility-options",
      shiny::h4("Accessibility"),
      shiny::div(
        shiny::input(
          type = "checkbox",
          id = "high-contrast",
          name = "high-contrast"
        ),
        shiny::label(
          `for` = "high-contrast",
          "High Contrast"
        )
      ),
      shiny::div(
        shiny::input(
          type = "checkbox",
          id = "large-text",
          name = "large-text"
        ),
        shiny::label(
          `for` = "large-text",
          "Large Text"
        )
      )
    )
  )
}

#' Generate Main Content Component
#'
#' Generates the main content section of the UI.
#'
#' @param study_config List containing study configuration.
#' @param theme_config List containing theme configuration.
#'
#' @return Shiny tag object for the main content.
#'
#' @noRd
generate_main_content <- function(study_config, theme_config) {
  shiny::tags$main(
    class = "main-content",
    role = "main",
    
    # Progress indicator
    if (study_config$show_progress) {
      shiny::div(
        class = "progress-container",
        shiny::div(
          class = "progress-bar",
          id = "progress-bar",
          style = "width: 0%",
          role = "progressbar",
          `aria-valuenow` = "0",
          `aria-valuemin` = "0",
          `aria-valuemax` = "100"
        )
      )
    },
    
    # Item display area
    shiny::div(
      class = "item-container",
      id = "item-container",
      
      # Item text
      shiny::div(
        class = "item-text",
        id = "item-text",
        role = "region",
        `aria-label` = "Question",
        "Loading..."
      ),
      
      # Response options
      shiny::div(
        class = "response-options",
        id = "response-options",
        role = "radiogroup",
        `aria-label` = "Response options"
      )
    ),
    
    # Navigation buttons
    shiny::div(
      class = "navigation-buttons",
      style = "margin-top: 2rem; text-align: center;",
      
      shiny::button(
        class = "btn",
        id = "prev-btn",
        type = "button",
        disabled = TRUE,
        shiny::icon("arrow-left"),
        " Previous"
      ),
      
      shiny::button(
        class = "btn",
        id = "next-btn",
        type = "button",
        style = "margin-left: 1rem;",
        "Next ",
        shiny::icon("arrow-right")
      )
    ),
    
    # Results display (initially hidden)
    shiny::div(
      class = "results-container",
      id = "results-container",
      style = "display: none;",
      
      shiny::h2("Assessment Complete"),
      shiny::p("Thank you for completing the assessment."),
      
      shiny::div(
        class = "results-summary",
        id = "results-summary"
      ),
      
      DT::DTOutput("results_table")
    )
  )
}

#' Generate Footer Component
#'
#' Generates the footer section of the UI.
#'
#' @param study_config List containing study configuration.
#' @param theme_config List containing theme configuration.
#'
#' @return Shiny tag object for the footer.
#'
#' @noRd
generate_footer <- function(study_config, theme_config) {
  shiny::tags$footer(
    class = "footer",
    role = "contentinfo",
    shiny::p(
      "Powered by ",
      shiny::a(
        href = "https://github.com/yourusername/inrep",
        target = "_blank",
        "inrep"
      ),
      " | ",
      shiny::a(
        href = "#",
        onclick = "showPrivacyPolicy()",
        "Privacy Policy"
      )
    )
  )
}

#' Generate Study Flow UI
#'
#' Generates UI components for enhanced study flow including introduction,
#' briefing, consent, GDPR compliance, and debriefing phases.
#'
#' @param study_config List containing study configuration with flow settings.
#' @param theme_config List containing theme configuration.
#'
#' @return Shiny tag object for the study flow UI.
#'
#' @export
generate_study_flow_ui <- function(study_config, theme_config) {
  # Check if study flow is enabled
  if (is.null(study_config$study_phases) || !any(study_config$study_phases)) {
    return(NULL)
  }
  
  # Create study flow container
  study_flow_container <- shiny::div(
    class = "study-flow-container",
    id = "study-flow-container",
    
    # Introduction Phase
    if (study_config$show_introduction) {
      shiny::div(
        class = "study-phase introduction-phase",
        id = "introduction-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::HTML(study_config$introduction_content)
        ),
        
        shiny::div(
          class = "phase-navigation",
          shiny::actionButton(
            inputId = "introduction_continue",
            label = "Continue",
            class = "btn btn-primary btn-lg",
            icon = shiny::icon("arrow-right")
          )
        )
      )
    },
    
    # Briefing Phase
    if (study_config$show_briefing) {
      shiny::div(
        class = "study-phase briefing-phase",
        id = "briefing-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::HTML(study_config$briefing_content)
        ),
        
        shiny::div(
          class = "phase-navigation",
          if (study_config$enable_back_navigation) {
            shiny::actionButton(
              inputId = "briefing_back",
              label = "Back",
              class = "btn btn-secondary",
              icon = shiny::icon("arrow-left")
            )
          },
          shiny::actionButton(
            inputId = "briefing_continue",
            label = "Continue",
            class = "btn btn-primary btn-lg",
            icon = shiny::icon("arrow-right")
          )
        )
      )
    },
    
    # Consent Phase
    if (study_config$show_consent) {
      shiny::div(
        class = "study-phase consent-phase",
        id = "consent-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::HTML(study_config$consent_content)
        ),
        
        shiny::div(
          class = "consent-agreement",
          shiny::checkboxInput(
            inputId = "consent_agreed",
            label = "I have read and understood the information above, and I agree to participate in this study.",
            value = FALSE
          ),
          
          shiny::div(
            class = "consent-confirmation",
            shiny::p(
              class = "text-muted",
              "Please confirm your agreement to participate by checking the box above."
            )
          )
        ),
        
        shiny::div(
          class = "phase-navigation",
          if (study_config$enable_back_navigation) {
            shiny::actionButton(
              inputId = "consent_back",
              label = "Back",
              class = "btn btn-secondary",
              icon = shiny::icon("arrow-left")
            )
          },
          shiny::actionButton(
            inputId = "consent_continue",
            label = "I Agree and Continue",
            class = "btn btn-primary btn-lg",
            icon = shiny::icon("check")
          )
        )
      )
    },
    
    # GDPR Compliance Phase
    if (study_config$show_gdpr_compliance) {
      shiny::div(
        class = "study-phase gdpr-phase",
        id = "gdpr-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::HTML(study_config$gdpr_content)
        ),
        
        shiny::div(
          class = "gdpr-agreement",
          shiny::checkboxInput(
            inputId = "gdpr_data_processing",
            label = "I understand and consent to the processing of my data as described above.",
            value = FALSE
          ),
          
          shiny::checkboxInput(
            inputId = "gdpr_anonymization",
            label = "I understand that my data will be anonymized and cannot be traced back to me.",
            value = FALSE
          ),
          
          shiny::checkboxInput(
            inputId = "gdpr_withdrawal",
            label = "I understand my right to withdraw consent at any time.",
            value = FALSE
          ),
          
          shiny::div(
            class = "gdpr-confirmation",
            shiny::p(
              class = "text-muted",
              "Please confirm your understanding of data protection by checking all boxes above."
            )
          )
        ),
        
        shiny::div(
          class = "phase-navigation",
          if (study_config$enable_back_navigation) {
            shiny::actionButton(
              inputId = "gdpr_back",
              label = "Back",
              class = "btn btn-secondary",
              icon = shiny::icon("arrow-left")
            )
          },
          shiny::actionButton(
            inputId = "gdpr_continue",
            label = "Accept and Continue",
            class = "btn btn-primary btn-lg",
            icon = shiny::icon("shield-alt")
          )
        )
      )
    },
    
    # Demographics Phase
    if (!is.null(study_config$demographic_configs)) {
      shiny::div(
        class = "study-phase demographics-phase",
        id = "demographics-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::h2("Demographic Information"),
          shiny::p("Please provide some optional information about yourself. All questions are optional."),
          
          # Custom demographic UI
          study_config$custom_demographic_ui
        ),
        
        shiny::div(
          class = "phase-navigation",
          if (study_config$enable_back_navigation) {
            shiny::actionButton(
              inputId = "demographics_back",
              label = "Back",
              class = "btn btn-secondary",
              icon = shiny::icon("arrow-left")
            )
          },
          shiny::actionButton(
            inputId = "demographics_continue",
            label = "Continue to Assessment",
            class = "btn btn-primary btn-lg",
            icon = shiny::icon("arrow-right")
          )
        )
      )
    },
    
    # Debriefing Phase
    if (study_config$show_debriefing) {
      shiny::div(
        class = "study-phase debriefing-phase",
        id = "debriefing-phase",
        style = "display: none;",
        
        shiny::div(
          class = "phase-content",
          shiny::HTML(study_config$debriefing_content)
        ),
        
        shiny::div(
          class = "phase-navigation",
          shiny::actionButton(
            inputId = "debriefing_finish",
            label = "Finish Study",
            class = "btn btn-success btn-lg",
            icon = shiny::icon("check-circle")
          )
        )
      )
    }
  )
  
  # Add study flow styles
  study_flow_styles <- shiny::tags$style(shiny::HTML("
    .study-flow-container {
      max-width: 800px;
      margin: 0 auto;
      padding: 2rem;
    }
    
    .study-phase {
      background: white;
      border-radius: 12px;
      padding: 3rem;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
      margin-bottom: 2rem;
      border: 1px solid #e9ecef;
    }
    
    .phase-content {
      margin-bottom: 2rem;
    }
    
    .phase-content h2 {
      color: var(--primary-color);
      margin-bottom: 1.5rem;
      border-bottom: 2px solid var(--primary-color);
      padding-bottom: 0.5rem;
    }
    
    .phase-content h3 {
      color: #495057;
      margin-top: 2rem;
      margin-bottom: 1rem;
    }
    
    .phase-content p {
      line-height: 1.7;
      color: #6c757d;
      margin-bottom: 1rem;
    }
    
    .phase-content ul, .phase-content ol {
      margin-left: 2rem;
      margin-bottom: 1rem;
    }
    
    .phase-content li {
      margin-bottom: 0.5rem;
      line-height: 1.6;
    }
    
    .phase-navigation {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 2rem;
      padding-top: 1.5rem;
      border-top: 1px solid #e9ecef;
    }
    
    .phase-navigation .btn {
      padding: 0.75rem 2rem;
      font-size: 1.1rem;
      border-radius: 8px;
      transition: all 0.3s ease;
    }
    
    .phase-navigation .btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }
    
    .consent-agreement, .gdpr-agreement {
      background: #f8f9fa;
      border: 1px solid #dee2e6;
      border-radius: 8px;
      padding: 1.5rem;
      margin: 1.5rem 0;
    }
    
    .consent-agreement .form-check, .gdpr-agreement .form-check {
      margin-bottom: 1rem;
    }
    
    .consent-agreement .form-check-label, .gdpr-agreement .form-check-label {
      font-weight: 500;
      color: #495057;
      cursor: pointer;
    }
    
    .consent-confirmation, .gdpr-confirmation {
      margin-top: 1rem;
      padding-top: 1rem;
      border-top: 1px solid #dee2e6;
    }
    
    .demographic-field {
      margin-bottom: 1.5rem;
      padding: 1rem;
      background: #f8f9fa;
      border-radius: 8px;
      border: 1px solid #dee2e6;
    }
    
    .demographic-field label {
      font-weight: 500;
      color: #495057;
      margin-bottom: 0.5rem;
      display: block;
    }
    
    .demographic-field .form-control {
      border-radius: 6px;
      border: 1px solid #ced4da;
      padding: 0.75rem;
    }
    
    .demographic-field .form-control:focus {
      border-color: var(--primary-color);
      box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
    }
    
    .skip-option {
      margin-top: 0.5rem;
      font-size: 0.9rem;
    }
    
    .skip-option .form-check-label {
      color: #6c757d;
    }
    
    @media (max-width: 768px) {
      .study-flow-container {
        padding: 1rem;
      }
      
      .study-phase {
        padding: 2rem;
      }
      
      .phase-navigation {
        flex-direction: column;
        gap: 1rem;
      }
      
      .phase-navigation .btn {
        width: 100%;
      }
    }
  "))
  
  return(shiny::tagList(study_flow_styles, study_flow_container))
}
