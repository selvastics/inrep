# File: ui_scraper.R

#' Scrape Website UI Components for Professional Theme Generation
#'
#' @description
#' Scrapes a website to extract UI components (logo, colors, fonts) and generates multiple
#' professional theme configurations for use in TAM-based adaptive testing interfaces.
#' This function enables researchers to create cohesive, branded assessment experiences
#' that align with institutional aesthetics and research requirements.
#'
#' @param url Character string specifying the website URL to scrape (e.g., "https://www.uni-hildesheim.de/").
#'   Must be a valid HTTP or HTTPS URL.
#' @param output_dir Character string specifying the directory to save scraped files.
#'   Default is a temporary directory that will be cleaned up after the session.
#' @param user_agent Character string specifying the user agent for HTTP requests.
#'   Default is a standard browser user agent for compatibility.
#' @param timeout Numeric specifying the request timeout in seconds. Default is 30.
#'   Increase for slower connections or complex websites.
#' @param num_themes Integer specifying the number of theme variations to generate.
#'   Default is 3 (light, dark, and minimal variations).
#' @param interactive_mode Logical indicating whether to prompt user for confirmation
#'   when processing large batches. Default is \code{TRUE}.
#' @param batch_size Integer specifying the maximum number of assets to process
#'   in each batch before asking for user confirmation. Default is 10.
#' @param verbose Logical indicating whether to display detailed progress messages
#'   and logging. Default is \code{TRUE}.
#'
#' @return Named list containing comprehensive scraping results:
#' \describe{
#'   \item{\code{themes}}{List of theme configurations, each containing \code{primary_color}, 
#'     \code{background_color}, \code{font_family}, \code{logo_path}, and metadata}
#'   \item{\code{html_file}}{Path to the saved HTML file}
#'   \item{\code{css_files}}{Vector of paths to downloaded CSS files}
#'   \item{\code{js_files}}{Vector of paths to downloaded JavaScript files}
#'   \item{\code{image_files}}{Vector of paths to downloaded images}
#'   \item{\code{scraped_colors}}{Vector of all colors extracted from CSS files}
#'   \item{\code{scraped_fonts}}{Vector of all fonts extracted from CSS files}
#'   \item{\code{processing_log}}{Vector of processing messages and status updates}
#'   \item{\code{errors}}{Vector of error messages encountered during scraping}
#'   \item{\code{warnings}}{Vector of warning messages and potential issues}
#'   \item{\code{source}}{Character string indicating the source of the themes}
#' }
#'
#' @export
#'
#' @details
#' This function provides comprehensive website scraping capabilities for theme generation:
#' 
#' \strong{Scraping Process:}
#' \enumerate{
#'   \item Downloads and parses the main HTML page
#'   \item Extracts and downloads linked CSS stylesheets
#'   \item Identifies and downloads JavaScript files
#'   \item Locates and downloads images (logos, backgrounds)
#'   \item Analyzes CSS for color schemes and typography
#'   \item Generates multiple theme variations
#' }
#' 
#' \strong{Theme Generation:}
#' \itemize{
#'   \item \strong{Light Theme}: Bright backgrounds with dark text for readability
#'   \item \strong{Dark Theme}: Dark backgrounds with light text for reduced eye strain
#'   \item \strong{Minimal Theme}: Clean, distraction-free design for focus
#'   \item \strong{Custom Variations}: Based on extracted brand colors and fonts
#' }
#' 
#' \strong{Quality Assurance:}
#' \itemize{
#'   \item Comprehensive error handling and fallback mechanisms
#'   \item Interactive batch processing for large websites
#'   \item Detailed logging and progress reporting
#'   \item Validation of extracted assets and color schemes
#' }
#' 
#' \strong{File Organization:}
#' \itemize{
#'   \item \code{html/}: Downloaded HTML files
#'   \item \code{css/}: Extracted CSS stylesheets
#'   \item \code{js/}: JavaScript files
#'   \item \code{images/}: Logo and background images
#' }
#' 
#' \strong{AI-Assisted Customization:} We strongly encourage using Large Language Models
#' (LLMs) like ChatGPT, Claude, or Copilot to fine-tune the scraped components for your
#' specific study needs. Since psychological studies have unique requirements, AI assistance
#' can help you adapt themes for specific populations, accessibility requirements, 
#' cross-cultural research, and institutional branding guidelines.
#' 
#' \strong{Legal Compliance:} Before scraping a website, check its \code{robots.txt} and
#' terms of use to ensure compliance with legal and ethical guidelines. Respect privacy
#' and intellectual property rights when reusing website content.
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic Website Scraping
#' library(inrep)
#' 
#' # Scrape university website for institutional branding
#' result <- scrape_website_ui("https://www.uni-hildesheim.de/")
#' 
#' # Preview scraped themes
#' cat("=== Scraped Themes Preview ===\n")
#' for (i in seq_along(result$themes)) {
#'   theme <- result$themes[[i]]
#'   cat(sprintf("Theme %d: %s\n", i, theme$name))
#'   cat(sprintf("  Primary Color: %s\n", theme$primary_color))
#'   cat(sprintf("  Background: %s\n", theme$background_color))
#'   cat(sprintf("  Font Family: %s\n", theme$font_family))
#'   cat(sprintf("  Logo: %s\n", ifelse(is.null(theme$logo_path), "None", "Available")))
#'   cat("\n")
#' }
#' 
#' # Example 2: Corporate Assessment with Brand Consistency
#' # Scrape corporate website for brand alignment
#' corporate_result <- scrape_website_ui(
#'   url = "https://www.company-website.com/",
#'   num_themes = 2,  # Light and dark versions
#'   verbose = TRUE
#' )
#' 
#' # Create study configuration with corporate theme
#' corporate_config <- create_study_config(
#'   name = "Employee Engagement Survey",
#'   model = "GRM",
#'   max_items = 20,
#'   theme = corporate_result$themes[[1]]$name,
#'   language = "en"
#' )
#' 
#' # Launch corporate assessment
#' launch_study(
#'   config = corporate_config,
#'   item_bank = bfi_items,
#'   theme_options = corporate_result$themes
#' )
#' 
#' # Example 3: Clinical Research with Professional Themes
#' # Scrape medical institution website
#' clinical_result <- scrape_website_ui(
#'   url = "https://www.medical-center.edu/",
#'   num_themes = 3,
#'   interactive_mode = FALSE,  # Automated processing
#'   timeout = 45  # Longer timeout for complex sites
#' )
#' 
#' # Create clinical assessment configuration
#' clinical_config <- create_study_config(
#'   name = "Depression Screening Tool",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.4,
#'   demographics = c("Age", "Gender", "Previous_Treatment"),
#'   theme = "Clinical"
#' )
#' 
#' # Customize clinical themes for patient comfort
#' clinical_themes <- lapply(clinical_result$themes, function(theme) {
#'   # Soften colors for clinical environment
#'   theme$primary_color <- "#4a90a4"  # Calming blue
#'   theme$background_color <- "#f8f9fa"  # Soft white
#'   theme$font_family <- "'Helvetica Neue', Arial, sans-serif"
#'   theme$name <- paste("Clinical", theme$name)
#'   return(theme)
#' })
#' 
#' # Launch clinical assessment
#' launch_study(
#'   config = clinical_config,
#'   item_bank = bfi_items,
#'   theme_options = clinical_themes
#' )
#' 
#' # Example 4: Educational Assessment with School Branding
#' # Scrape school website for educational context
#' school_result <- scrape_website_ui(
#'   url = "https://www.school-district.edu/",
#'   output_dir = "school_themes",
#'   num_themes = 4,
#'   batch_size = 5
#' )
#' 
#' # Create educational assessment
#' educational_config <- create_study_config(
#'   name = "Mathematics Assessment",
#'   model = "2PL",
#'   max_items = 30,
#'   demographics = c("Grade", "Teacher", "School"),
#'   theme = "Educational"
#' )
#' 
#' # Adapt themes for young learners
#' educational_themes <- lapply(school_result$themes, function(theme) {
#'   # Bright, engaging colors for students
#'   theme$primary_color <- "#28a745"  # Encouraging green
#'   theme$accent_color <- "#ffc107"   # Attention-grabbing yellow
#'   theme$font_family <- "'Comic Sans MS', cursive"  # Kid-friendly font
#'   theme$name <- paste("Student", theme$name)
#'   return(theme)
#' })
#' 
#' # Example 5: Multi-Site Research with Consistent Branding
#' # Scrape multiple institutional websites
#' institutions <- c(
#'   "https://www.university1.edu/",
#'   "https://www.university2.edu/",
#'   "https://www.research-center.org/"
#' )
#' 
#' multi_site_themes <- list()
#' for (i in seq_along(institutions)) {
#'   cat("Scraping institution", i, ":", institutions[i], "\n")
#'   
#'   site_result <- scrape_website_ui(
#'     url = institutions[i],
#'     num_themes = 2,
#'     interactive_mode = FALSE,
#'     verbose = FALSE
#'   )
#'   
#'   # Add site identifier to themes
#'   site_themes <- lapply(site_result$themes, function(theme) {
#'     theme$site_id <- i
#'     theme$site_url <- institutions[i]
#'     theme$name <- paste("Site", i, theme$name)
#'     return(theme)
#'   })
#'   
#'   multi_site_themes <- c(multi_site_themes, site_themes)
#' }
#' 
#' # Create multi-site study configuration
#' multi_site_config <- create_study_config(
#'   name = "Multi-Site Personality Study",
#'   model = "GRM",
#'   max_items = 25,
#'   demographics = c("Site", "Age", "Gender", "Education"),
#'   language = "en"
#' )
#' 
#' # Launch with all scraped themes
#' launch_study(
#'   config = multi_site_config,
#'   item_bank = bfi_items,
#'   theme_options = multi_site_themes
#' )
#' 
#' # Example 6: AI-Assisted Theme Customization
#' # Prepare themes for AI customization
#' ai_customization_prompt <- function(scraped_result, study_context) {
#'   cat("=== AI Customization Prompt ===\n")
#'   cat("Please help me customize these scraped themes for a", study_context, "study.\n")
#'   cat("The themes should be professional, accessible, and appropriate for the context.\n\n")
#'   cat("Scraped themes:\n")
#'   cat(jsonlite::toJSON(scraped_result$themes, pretty = TRUE))
#'   cat("\n\nPlease provide:\n")
#'   cat("1. Customized color schemes appropriate for", study_context, "\n")
#'   cat("2. Font recommendations for optimal readability\n")
#'   cat("3. Accessibility improvements\n")
#'   cat("4. Cultural considerations if applicable\n")
#'   cat("5. Mobile optimization suggestions\n")
#' }
#' 
#' # Generate AI prompt for clinical study
#' ai_customization_prompt(clinical_result, "clinical depression assessment")
#' 
#' # Example 7: Theme Validation and Testing
#' # Validate scraped themes for assessment use
#' validate_scraped_themes <- function(scraped_result) {
#'   cat("Validating scraped themes...\n")
#'   cat("============================\n")
#'   
#'   validation_results <- list()
#'   
#'   for (i in seq_along(scraped_result$themes)) {
#'     theme <- scraped_result$themes[[i]]
#'     cat("Theme", i, ":", theme$name, "\n")
#'     
#'     # Color validation
#'     color_valid <- grepl("^#[0-9A-Fa-f]{6}$", theme$primary_color)
#'     cat("  Color format:", if (color_valid) "✓ Valid" else "✗ Invalid", "\n")
#'     
#'     # Font validation
#'     font_valid <- !is.null(theme$font_family) && nchar(theme$font_family) > 0
#'     cat("  Font family:", if (font_valid) "✓ Present" else "✗ Missing", "\n")
#'     
#'     # Logo validation
#'     logo_present <- !is.null(theme$logo_path) && file.exists(theme$logo_path)
#'     cat("  Logo file:", if (logo_present) "✓ Available" else "✗ Missing", "\n")
#'     
#'     # Overall validation
#'     overall_valid <- color_valid && font_valid
#'     validation_results[[i]] <- overall_valid
#'     cat("  Overall:", if (overall_valid) "✓ Valid" else "✗ Issues found", "\n\n")
#'   }
#'   
#'   # Summary
#'   valid_themes <- sum(unlist(validation_results))
#'   total_themes <- length(validation_results)
#'   cat("Summary:", valid_themes, "of", total_themes, "themes are valid\n")
#'   
#'   return(validation_results)
#' }
#' 
#' # Validate all scraped themes
#' validation_results <- validate_scraped_themes(result)
#' 
#' # Example 8: Error Handling and Fallback
#' # Demonstrate robust error handling
#' safe_scrape_website <- function(url) {
#'   tryCatch({
#'     result <- scrape_website_ui(url)
#'     cat("Successfully scraped:", url, "\n")
#'     return(result)
#'   }, error = function(e) {
#'     cat("Error scraping", url, ":", e$message, "\n")
#'     cat("Using default themes instead\n")
#'     
#'     # Return default themes as fallback
#'     return(list(
#'       themes = list(
#'         list(
#'           name = "Default Light",
#'           primary_color = "#007bff",
#'           background_color = "#ffffff",
#'           font_family = "'Inter', sans-serif",
#'           logo_path = NULL
#'         )
#'       ),
#'       source = "default_fallback"
#'     ))
#'   })
#' }
#' 
#' # Test with potentially problematic URLs
#' test_urls <- c(
#'   "https://www.valid-website.com/",
#'   "https://www.invalid-url-that-does-not-exist.com/",
#'   "https://www.timeout-prone-site.com/"
#' )
#' 
#' for (url in test_urls) {
#'   result <- safe_scrape_website(url)
#'   cat("Result source:", result$source, "\n\n")
#' }
#' }
#'
#' @seealso
#' \itemize{
#'   \item \code{\link{build_study_ui}} for using scraped themes in UI construction
#'   \item \code{\link{launch_study}} for complete assessment workflow with themes
#'   \item \code{\link{get_builtin_themes}} for alternative built-in themes
#'   \item \code{\link{create_study_config}} for configuration with theme options
#' }
#'
#' @references
#' \itemize{
#'   \item World Wide Web Consortium (W3C). (2018). Web Content Accessibility Guidelines (WCAG) 2.1. 
#'     \url{https://www.w3.org/WAI/WCAG21/Understanding/}
#'   \item Mozilla Developer Network. (2023). CSS Color Module Level 3. 
#'     \url{https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_Color}
#' }
#'
#' @keywords scraping themes UI web-scraping branding accessibility
#' @examples
#' \dontrun{
#' # Multiple website scraping for comparison
#' sites <- c(
#'   "https://www.uni-hildesheim.de/",
#'   "https://www.example-university.edu/",
#'   "https://www.research-institute.org/"
#' )
#' 
#' all_themes <- list()
#' for (site in sites) {
#'   cat(sprintf("Scraping %s...\n", site))
#'   result <- scrape_website_ui(site, num_themes = 3)
#'   all_themes <- c(all_themes, result$themes)
#' }
#' 
#' # Compare and select best themes
#' cat(sprintf("Total themes collected: %d\n", length(all_themes)))
#' 
#' # Error handling demonstration
#' tryCatch({
#'   result <- scrape_website_ui("https://invalid-url.com/")
#' }, error = function(e) {
#'   cat("Scraping failed gracefully with fallback themes\n")
#' })
#' }
#'
#' @export
scrape_website_ui <- function(
    url,
    output_dir = tempdir(),
    user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
    timeout = 30,
    num_themes = 3,
    interactive_mode = TRUE,
    batch_size = 10,
    verbose = TRUE
) {
  # Enhanced logging function
  log_message <- function(message, level = "INFO") {
    if (verbose) {
      timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
      cat(sprintf("[%s] %s: %s\n", timestamp, level, message))
    }
  }
  
  # Progress tracking
  progress_tracker <- function(current, total, description) {
    if (verbose) {
      percentage <- round((current / total) * 100)
      cat(sprintf("Progress: %d%% (%d/%d) - %s\n", percentage, current, total, description))
    }
  }
  
  # Interactive user confirmation
  ask_user_confirmation <- function(message, default = TRUE) {
    if (!interactive_mode || !interactive()) {
      return(default)
    }
    
    cat(sprintf("\n%s\n", message))
    response <- readline(prompt = "Continue? (y/n, default is y): ")
    
    if (nchar(response) == 0) {
      return(default)
    }
    
    return(tolower(substr(response, 1, 1)) == "y")
  }
  
  # Load required packages with error handling
  required_packages <- c("rvest", "stringr", "colorspace", "httr")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      stop(sprintf("Package '%s' is required for web scraping. Please install it with install.packages('%s')", pkg, pkg))
    }
  }
  
  log_message("Starting website scraping process")
  
  # Default themes as fallback
  default_themes <- list(
    light = list(
      name = "Light Theme",
      primary_color = "#007bff",
      background_color = "#f8f9fa",
      font_family = "'Inter', sans-serif",
      logo_path = NULL,
      source = "default"
    ),
    dark = list(
      name = "Dark Theme",
      primary_color = "#007bff",
      background_color = "#212529",
      font_family = "'Inter', sans-serif",
      logo_path = NULL,
      source = "default"
    ),
    minimal = list(
      name = "Minimal Theme",
      primary_color = "#6c757d",
      background_color = "#ffffff",
      font_family = "'Arial', sans-serif",
      logo_path = NULL,
      source = "default"
    )
  )
  
  # Enhanced input validation
  validation_errors <- c()
  
  if (!is.character(url) || !grepl("^https?://", url)) {
    validation_errors <- c(validation_errors, "Invalid URL: Must start with http:// or https://")
  }
  
  if (!is.character(output_dir) || !nzchar(output_dir)) {
    validation_errors <- c(validation_errors, "Invalid output_dir: Must be a valid directory path")
  }
  
  if (!is.character(user_agent) || !nzchar(user_agent)) {
    validation_errors <- c(validation_errors, "Invalid user_agent: Must be a non-empty string")
  }
  
  if (!is.numeric(timeout) || timeout <= 0) {
    validation_errors <- c(validation_errors, "Invalid timeout: Must be a positive number")
  }
  
  if (!is.numeric(num_themes) || num_themes < 1) {
    validation_errors <- c(validation_errors, "Invalid num_themes: Must be a positive integer")
    num_themes <- 3
  }
  
  if (!is.numeric(batch_size) || batch_size < 1) {
    validation_errors <- c(validation_errors, "Invalid batch_size: Must be a positive integer")
    batch_size <- 10
  }
  
  if (length(validation_errors) > 0) {
    for (error in validation_errors) {
      log_message(error, "ERROR")
    }
    log_message("Returning default themes due to validation errors", "WARNING")
    return(list(
      themes = default_themes[1:min(num_themes, length(default_themes))], 
      html_file = NULL, 
      css_files = NULL, 
      js_files = NULL, 
      image_files = NULL,
      errors = validation_errors,
      source = "validation_fallback"
    ))
  }
  
  log_message(sprintf("Scraping website: %s", url))
  log_message(sprintf("Configuration: %d themes, %ds timeout, batch size %d", num_themes, timeout, batch_size))
  
  # Create output directories with error handling
  directories <- c("html", "css", "js", "images")
  created_dirs <- list()
  
  for (dir_name in directories) {
    dir_path <- file.path(output_dir, dir_name)
    tryCatch({
      dir.create(dir_path, showWarnings = FALSE, recursive = TRUE)
      created_dirs[[dir_name]] <- dir_path
      log_message(sprintf("Created directory: %s", dir_path))
    }, error = function(e) {
      log_message(sprintf("Failed to create directory %s: %s", dir_path, e$message), "ERROR")
      created_dirs[[dir_name]] <- tempdir()
    })
  }
  
  # Initialize results with enhanced metadata
  result <- list(
    themes = default_themes[1:min(num_themes, length(default_themes))],
    html_file = NULL,
    css_files = character(),
    js_files = character(),
    image_files = character(),
    scraped_colors = character(),
    scraped_fonts = character(),
    processing_log = character(),
    errors = character(),
    warnings = character(),
    source = "scraping_fallback"
  )
  
  # HTTP request with enhanced error handling
  log_message("Initiating HTTP request...")
  
  tryCatch({
    # Check robots.txt first
    robots_url <- paste0(regmatches(url, regexpr("^https?://[^/]+", url))[[1]], "/robots.txt")
    log_message(sprintf("Checking robots.txt at: %s", robots_url))
    
    robots_response <- tryCatch({
      httr::GET(robots_url, httr::timeout(10))
    }, error = function(e) {
      log_message("Could not access robots.txt (this is often normal)", "WARNING")
      NULL
    })
    
    if (!is.null(robots_response) && httr::status_code(robots_response) == 200) {
      robots_content <- httr::content(robots_response, "text")
      if (grepl("Disallow:.*\\*", robots_content) || grepl("Disallow: /", robots_content)) {
        log_message("robots.txt suggests restricted access - proceeding with caution", "WARNING")
        result$warnings <- c(result$warnings, "robots.txt indicates potential access restrictions")
      }
    }
    
    # Main HTTP request
    log_message("Fetching main page...")
    response <- httr::GET(
      url,
      httr::user_agent(user_agent),
      httr::timeout(timeout),
      httr::add_headers("Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    )
    
    status_code <- httr::status_code(response)
    log_message(sprintf("HTTP response: %d", status_code))
    
    if (status_code != 200) {
      error_msg <- sprintf("Failed to retrieve page: HTTP %d", status_code)
      log_message(error_msg, "ERROR")
      result$errors <- c(result$errors, error_msg)
      return(result)
    }
    
    # Parse HTML with error handling
    log_message("Parsing HTML content...")
    page <- tryCatch({
      rvest::read_html(response)
    }, error = function(e) {
      log_message(sprintf("HTML parsing failed: %s", e$message), "ERROR")
      result$errors <- c(result$errors, sprintf("HTML parsing error: %s", e$message))
      return(NULL)
    })
    
    if (is.null(page)) {
      return(result)
    }
    
    base_url <- regmatches(url, regexpr("^https?://[^/]+", url))[[1]]
    log_message(sprintf("Base URL extracted: %s", base_url))
    
    # Save HTML
    result$html_file <- file.path(created_dirs$html, "index.html")
    tryCatch({
      writeLines(as.character(page), result$html_file)
      log_message(sprintf("HTML saved to: %s", result$html_file))
    }, error = function(e) {
      log_message(sprintf("Failed to save HTML: %s", e$message), "WARNING")
    })
    
    # Enhanced asset download function
    download_asset <- function(links, folder, asset_type, base_url) {
      if (length(links) == 0) {
        log_message(sprintf("No %s links found", asset_type))
        return(character())
      }
      
      log_message(sprintf("Found %d %s links", length(links), asset_type))
      
      # Process in batches with user confirmation
      downloaded_files <- character()
      total_batches <- ceiling(length(links) / batch_size)
      
      for (batch_num in 1:total_batches) {
        start_idx <- (batch_num - 1) * batch_size + 1
        end_idx <- min(batch_num * batch_size, length(links))
        batch_links <- links[start_idx:end_idx]
        
        if (batch_num > 1) {
          should_continue <- ask_user_confirmation(
            sprintf("Process batch %d/%d (%d more %s files)? This will download %d additional files.", 
                    batch_num, total_batches, length(links) - start_idx + 1, asset_type, length(batch_links)),
            default = FALSE
          )
          if (!should_continue) {
            log_message(sprintf("User skipped remaining %s downloads", asset_type))
            break
          }
        }
        
        log_message(sprintf("Processing %s batch %d/%d (%d files)", asset_type, batch_num, total_batches, length(batch_links)))
        
        for (i in seq_along(batch_links)) {
          link <- batch_links[i]
          progress_tracker(start_idx + i - 1, length(links), sprintf("Downloading %s", asset_type))
          
          if (!nzchar(link)) next
          
          # Resolve relative URLs
          link_full <- if (grepl("^//", link)) {
            paste0("https:", link)
          } else if (grepl("^/", link)) {
            paste0(base_url, link)
          } else if (grepl("^https?://", link)) {
            link
          } else {
            next
          }
          
          filename <- basename(gsub("\\?.*$", "", link_full))
          if (!nzchar(filename)) {
            filename <- sprintf("%s_%d.%s", asset_type, i, 
                              ifelse(asset_type == "css", "css", 
                                     ifelse(asset_type == "js", "js", "file")))
          }
          
          filepath <- file.path(folder, filename)
          
          tryCatch({
            download_response <- httr::GET(
              link_full,
              httr::user_agent(user_agent),
              httr::write_disk(filepath, overwrite = TRUE),
              httr::timeout(timeout)
            )
            
            if (httr::status_code(download_response) == 200 && 
                file.exists(filepath) && file.size(filepath) > 0) {
              downloaded_files <- c(downloaded_files, filepath)
              log_message(sprintf("Downloaded: %s", filename))
            } else {
              if (file.exists(filepath)) file.remove(filepath)
              log_message(sprintf("Failed to download: %s (HTTP %d)", filename, httr::status_code(download_response)), "WARNING")
            }
          }, error = function(e) {
            log_message(sprintf("Error downloading %s: %s", filename, e$message), "WARNING")
          })
        }
      }
      
      log_message(sprintf("Successfully downloaded %d/%d %s files", length(downloaded_files), length(links), asset_type))
      return(downloaded_files)
    }
    
    # Download CSS files
    log_message("Extracting CSS links...")
    css_links <- rvest::html_nodes(page, "link[rel='stylesheet']") %>%
      rvest::html_attr("href")
    css_links <- css_links[!is.na(css_links)]
    result$css_files <- download_asset(css_links, created_dirs$css, "css", base_url)
    
    # Download JavaScript files
    log_message("Extracting JavaScript links...")
    js_links <- rvest::html_nodes(page, "script[src]") %>%
      rvest::html_attr("src")
    js_links <- js_links[!is.na(js_links)]
    result$js_files <- download_asset(js_links, created_dirs$js, "js", base_url)
    
    # Download Images
    log_message("Extracting image links...")
    img_links <- rvest::html_nodes(page, "img[src]") %>%
      rvest::html_attr("src")
    img_links <- img_links[!is.na(img_links)]
    result$image_files <- download_asset(img_links, created_dirs$images, "images", base_url)
    
    # Extract inline styles
    log_message("Extracting inline styles...")
    inline_styles <- rvest::html_nodes(page, "style") %>%
      rvest::html_text()
    
    if (length(inline_styles) > 0) {
      inline_css_file <- file.path(created_dirs$css, "inline_styles.css")
      tryCatch({
        writeLines(paste(inline_styles, collapse = "\n"), inline_css_file)
        result$css_files <- c(result$css_files, inline_css_file)
        log_message("Extracted inline styles")
      }, error = function(e) {
        log_message(sprintf("Failed to save inline styles: %s", e$message), "WARNING")
      })
    }
    
    # Enhanced logo detection
    log_message("Detecting logo...")
    logo <- NULL
    img_nodes <- rvest::html_nodes(page, "img")
    
    logo_keywords <- c("logo", "brand", "header", "nav", "identity")
    for (img in img_nodes) {
      alt <- tolower(rvest::html_attr(img, "alt") %||% "")
      class <- tolower(rvest::html_attr(img, "class") %||% "")
      id <- tolower(rvest::html_attr(img, "id") %||% "")
      src <- tolower(rvest::html_attr(img, "src") %||% "")
      
      if (any(sapply(logo_keywords, function(kw) grepl(kw, alt) || grepl(kw, class) || grepl(kw, id) || grepl(kw, src)))) {
        logo_src <- rvest::html_attr(img, "src")
        logo <- if (grepl("^//", logo_src)) {
          paste0("https:", logo_src)
        } else if (grepl("^/", logo_src)) {
          paste0(base_url, logo_src)
        } else if (grepl("^https?://", logo_src)) {
          logo_src
        } else {
          NULL
        }
        
        if (!is.null(logo)) {
          log_message(sprintf("Logo detected: %s", logo))
          break
        }
      }
    }
    
    # Download logo if found
    if (!is.null(logo)) {
      logo_file <- tryCatch({
        logo_filename <- basename(gsub("\\?.*$", "", logo))
        logo_filepath <- file.path(created_dirs$images, logo_filename)
        
        logo_response <- httr::GET(
          logo,
          httr::user_agent(user_agent),
          httr::write_disk(logo_filepath, overwrite = TRUE),
          httr::timeout(timeout)
        )
        
        if (httr::status_code(logo_response) == 200 && 
            file.exists(logo_filepath) && file.size(logo_filepath) > 0) {
          log_message(sprintf("Logo downloaded: %s", logo_filename))
          logo_filepath
        } else {
          log_message("Logo download failed", "WARNING")
          NULL
        }
      }, error = function(e) {
        log_message(sprintf("Logo download error: %s", e$message), "WARNING")
        NULL
      })
      
      if (!is.null(logo_file)) {
        logo <- logo_file
      }
    }
    
    # Enhanced color and font extraction
    log_message("Analyzing colors and fonts...")
    colors <- character()
    fonts <- character()
    
    # Process CSS files for colors and fonts
    total_css_files <- length(result$css_files)
    if (total_css_files > 0) {
      log_message(sprintf("Analyzing %d CSS files for design elements", total_css_files))
      
      for (i in seq_along(result$css_files)) {
        css_file <- result$css_files[i]
        progress_tracker(i, total_css_files, "Analyzing CSS")
        
        if (file.exists(css_file)) {
          tryCatch({
            css_content <- readLines(css_file, warn = FALSE)
            css_content <- paste(css_content, collapse = " ")
            
            # Extract hex colors
            hex_colors <- stringr::str_extract_all(css_content, "#[0-9A-Fa-f]{6}")[[1]]
            colors <- unique(c(colors, hex_colors))
            
            # Extract RGB colors
            rgb_colors <- stringr::str_extract_all(css_content, "rgb\\([0-9, ]+\\)")[[1]]
            colors <- unique(c(colors, rgb_colors))
            
            # Extract font families
            font_families <- stringr::str_extract_all(css_content, "font-family:\\s*[^;]+")[[1]]
            font_families <- gsub("font-family:\\s*", "", font_families)
            font_families <- gsub("['\";]", "", font_families)
            fonts <- unique(c(fonts, font_families))
            
          }, error = function(e) {
            log_message(sprintf("Error analyzing CSS file %s: %s", basename(css_file), e$message), "WARNING")
          })
        }
      }
    }
    
    # Store extracted design elements
    result$scraped_colors <- colors
    result$scraped_fonts <- fonts
    
    log_message(sprintf("Extracted %d colors and %d fonts", length(colors), length(fonts)))
    
    if (length(colors) > 10) {
      log_message(sprintf("Found many colors (%d), using first 10 for theme generation", length(colors)))
      colors <- colors[1:10]
    }
    
    if (length(fonts) > 5) {
      log_message(sprintf("Found many fonts (%d), using first 5 for theme generation", length(fonts)))
      fonts <- fonts[1:5]
    }
    
    # Enhanced theme generation
    log_message("Generating themes...")
    themes <- list()
    
    # Primary colors and fonts
    primary_color <- if (length(colors) > 0) colors[1] else "#007bff"
    secondary_color <- if (length(colors) > 1) colors[2] else "#6c757d"
    accent_color <- if (length(colors) > 2) colors[3] else "#28a745"
    font_family <- if (length(fonts) > 0) fonts[1] else "'Inter', sans-serif"
    
    # Theme 1: Light (website-inspired)
    themes[[1]] <- list(
      name = "Website Light Theme",
      primary_color = primary_color,
      background_color = "#f8f9fa",
      font_family = font_family,
      logo_path = logo,
      source = "scraped",
      accent_color = accent_color,
      scraped_from = url
    )
    
    # Theme 2: Dark (adapted)
    themes[[2]] <- list(
      name = "Website Dark Theme",
      primary_color = if (requireNamespace("colorspace", quietly = TRUE)) {
        tryCatch({
          colorspace::lighten(primary_color, 0.3)
        }, error = function(e) {
          primary_color
        })
      } else {
        primary_color
      },
      background_color = "#212529",
      font_family = font_family,
      logo_path = logo,
      source = "scraped",
      accent_color = accent_color,
      scraped_from = url
    )
    
    # Theme 3: Minimal (clean)
    themes[[3]] <- list(
      name = "Website Minimal Theme",
      primary_color = secondary_color,
      background_color = "#ffffff",
      font_family = font_family,
      logo_path = logo,
      source = "scraped",
      accent_color = accent_color,
      scraped_from = url
    )
    
    # Generate additional themes if requested
    if (num_themes > 3) {
      for (i in 4:num_themes) {
        color_idx <- ((i - 1) %% length(colors)) + 1
        font_idx <- ((i - 1) %% length(fonts)) + 1
        
        themes[[i]] <- list(
          name = sprintf("Website Custom Theme %d", i - 2),
          primary_color = if (length(colors) >= color_idx) colors[color_idx] else primary_color,
          background_color = if (i %% 2 == 0) "#f8f9fa" else "#ffffff",
          font_family = if (length(fonts) >= font_idx) fonts[font_idx] else font_family,
          logo_path = logo,
          source = "scraped",
          accent_color = accent_color,
          scraped_from = url
        )
      }
    }
    
    result$themes <- themes[1:min(num_themes, length(themes))]
    result$source <- "scraped"
    
    log_message("Website scraping and theme generation completed successfully!")
    log_message(sprintf("Generated %d themes from %s", length(result$themes), url))
    
    # Summary of scraped assets
    log_message("=== SCRAPING SUMMARY ===")
    log_message(sprintf("HTML files: %d", if (is.null(result$html_file)) 0 else 1))
    log_message(sprintf("CSS files: %d", length(result$css_files)))
    log_message(sprintf("JS files: %d", length(result$js_files)))
    log_message(sprintf("Images: %d", length(result$image_files)))
    log_message(sprintf("Colors found: %d", length(result$scraped_colors)))
    log_message(sprintf("Fonts found: %d", length(result$scraped_fonts)))
    log_message(sprintf("Logo: %s", if (is.null(logo)) "Not found" else "Found"))
    log_message(sprintf("Themes generated: %d", length(result$themes)))
    
    # AI customization prompt
    if (verbose) {
      cat("\n=== AI CUSTOMIZATION SUGGESTION ===\n")
      cat("Copy this information to your preferred AI assistant for theme customization:\n\n")
      cat("Please help me customize these scraped website themes for my psychological study.\n")
      cat("The themes should be appropriate for [DESCRIBE YOUR STUDY TYPE AND POPULATION].\n")
      cat("Consider accessibility, cultural sensitivity, and research best practices.\n\n")
      cat("Scraped themes data:\n")
      cat(jsonlite::toJSON(result$themes, pretty = TRUE, auto_unbox = TRUE))
      cat("\n\nPlease provide modified theme configurations with explanations for the changes.\n")
      cat("=====================================\n\n")
    }
    
    return(result)
    
  }, error = function(e) {
    error_msg <- sprintf("Error scraping website: %s", e$message)
    log_message(error_msg, "ERROR")
    result$errors <- c(result$errors, error_msg)
    return(result)
  })
}
