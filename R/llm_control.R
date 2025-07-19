#' Enable or Disable LLM Assistance Throughout inrep Package
#'
#' @description
#' Controls whether LLM assistance prompts are displayed during package operations.
#' When enabled, relevant functions will generate detailed prompts for ChatGPT, Claude,
#' or other Large Language Models to provide expert-level optimization advice.
#'
#' @param enable Logical indicating whether to enable LLM assistance prompts.
#'   Default is TRUE.
#' @param output_format Character string specifying how to display prompts.
#'   Options: "console" (default), "file", "clipboard".
#' @param prompt_types Character vector specifying which types of prompts to enable.
#'   Options: "all" (default), "validation", "configuration", "estimation", "analysis".
#' @param verbose Logical indicating whether to display status messages.
#'   Default is TRUE.
#'
#' @return Invisibly returns the previous setting for LLM assistance.
#'
#' @export
#'
#' @details
#' The inrep package includes comprehensive LLM assistance capabilities that generate
#' expert-level prompts for optimizing various aspects of adaptive testing studies.
#' These prompts leverage the knowledge of Large Language Models to provide:
#'
#' \strong{Available Assistance Types:}
#' \itemize{
#'   \item \strong{Study Configuration}: Optimize parameters for specific research contexts
#'   \item \strong{Item Bank Validation}: Analyze psychometric properties and recommend improvements
#'   \item \strong{Ability Estimation}: Assess estimation quality and efficiency
#'   \item \strong{Theme Customization}: Design psychology-informed user interfaces
#'   \item \strong{Multilingual Setup}: Configure cross-cultural assessment strategies
#'   \item \strong{Analysis Planning}: Develop comprehensive analytical approaches
#'   \item \strong{Deployment Strategy}: Plan technical infrastructure and quality control
#'   \item \strong{Documentation}: Create publication-ready methodology descriptions
#' }
#'
#' \strong{Integration Points:}
#' LLM assistance is integrated into major package functions:
#' \itemize{
#'   \item \code{\link{create_study_config}}: Configuration optimization
#'   \item \code{\link{validate_item_bank}}: Psychometric validation insights
#'   \item \code{\link{estimate_ability}}: Ability estimation analysis
#'   \item \code{\link{scrape_website_ui}}: Theme customization guidance
#'   \item \code{\link{generate_llm_prompt}}: Standalone prompt generation
#' }
#'
#' \strong{Privacy and Ethics:}
#' All prompts are generated locally and contain no participant data or confidential
#' information. Only configuration parameters, statistical summaries, and technical
#' specifications are included in prompts.
#'
#' @examples
#' \dontrun{
#' # Enable LLM assistance with console output
#' enable_llm_assistance(TRUE)
#'
#' # Now when you run package functions, you'll get optimization prompts:
#' config <- create_study_config(
#'   name = "Personality Study",
#'   model = "GRM"
#' )
#' # Displays prompt for configuration optimization
#'
#' validate_item_bank(bfi_items, "GRM")
#' # Displays prompt for validation insights
#'
#' # Enable specific prompt types only
#' enable_llm_assistance(
#'   enable = TRUE,
#'   prompt_types = c("validation", "configuration")
#' )
#'
#' # Save prompts to files instead of console
#' enable_llm_assistance(
#'   enable = TRUE,
#'   output_format = "file"
#' )
#'
#' # Disable all LLM assistance
#' enable_llm_assistance(FALSE)
#' }
enable_llm_assistance <- function(enable = TRUE,
                                 output_format = "console",
                                 prompt_types = "all",
                                 verbose = TRUE) {
  
  # Validate inputs
  stopifnot(
    is.logical(enable),
    is.character(output_format),
    output_format %in% c("console", "file", "clipboard"),
    is.character(prompt_types),
    all(prompt_types %in% c("all", "validation", "configuration", "estimation", "analysis", "ui", "multilingual", "deployment", "documentation")),
    is.logical(verbose)
  )
  
  # Store previous setting
  previous_setting <- getOption("inrep.llm_assistance", FALSE)
  
  # Set new options
  options(inrep.llm_assistance = enable)
  options(inrep.llm_output_format = output_format)
  options(inrep.llm_prompt_types = prompt_types)
  options(inrep.llm_verbose = verbose)
  
  if (verbose) {
    if (enable) {
      cat("LLM Assistance ENABLED for inrep package\n")
      cat("Output format:", output_format, "\n")
      cat("Prompt types:", paste(prompt_types, collapse = ", "), "\n")
      cat("\nAvailable assistance:\n")
      cat("- create_study_config(): Configuration optimization prompts\n")
      cat("- validate_item_bank(): Psychometric validation insights\n")
      cat("- estimate_ability(): Ability estimation analysis\n")
      cat("- scrape_website_ui(): Theme customization guidance\n")
      cat("- generate_llm_prompt(): Standalone prompt generation\n")
      cat("\nPrompts contain NO participant data - only technical parameters.\n")
    } else {
      cat("LLM Assistance DISABLED for inrep package\n")
    }
  }
  
  invisible(previous_setting)
}

#' Get Current LLM Assistance Settings
#'
#' @description
#' Returns the current LLM assistance configuration settings.
#'
#' @return Named list containing current LLM assistance settings:
#' \describe{
#'   \item{enabled}{Logical indicating if LLM assistance is enabled}
#'   \item{output_format}{Current output format for prompts}
#'   \item{prompt_types}{Types of prompts currently enabled}
#'   \item{verbose}{Verbose output setting}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Check current settings
#' settings <- get_llm_assistance_settings()
#' print(settings)
#' }
get_llm_assistance_settings <- function() {
  list(
    enabled = getOption("inrep.llm_assistance", FALSE),
    output_format = getOption("inrep.llm_output_format", "console"),
    prompt_types = getOption("inrep.llm_prompt_types", "all"),
    verbose = getOption("inrep.llm_verbose", TRUE)
  )
}

#' Check if LLM Assistance is Available for Specific Component
#' @noRd
is_llm_assistance_enabled <- function(component = "all") {
  if (!getOption("inrep.llm_assistance", FALSE)) {
    return(FALSE)
  }
  
  enabled_types <- getOption("inrep.llm_prompt_types", "all")
  
  if ("all" %in% enabled_types) {
    return(TRUE)
  }
  
  return(component %in% enabled_types)
}

#' Generate and Display LLM Prompt Based on Settings
#' @noRd
display_llm_prompt <- function(prompt, component = "general") {
  if (!is_llm_assistance_enabled(component)) {
    return(invisible(NULL))
  }
  
  output_format <- getOption("inrep.llm_output_format", "console")
  verbose <- getOption("inrep.llm_verbose", TRUE)
  
  if (output_format == "console") {
    if (verbose) {
      cat("\n" %r% 60, "\n")
      cat("LLM ASSISTANCE:", toupper(component), "OPTIMIZATION\n")
      cat("=" %r% 60, "\n")
      cat("Copy the following prompt to ChatGPT, Claude, or your preferred LLM:\n\n")
    }
    cat(prompt)
    if (verbose) {
      cat("\n" %r% 60, "\n\n")
    }
  } else if (output_format == "file") {
    filename <- paste0("inrep_", component, "_prompt_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
    writeLines(prompt, filename)
    if (verbose) {
      cat("LLM prompt saved to:", filename, "\n")
    }
  } else if (output_format == "clipboard") {
    if (requireNamespace("clipr", quietly = TRUE)) {
      clipr::write_clip(prompt)
      if (verbose) {
        cat("LLM prompt copied to clipboard!\n")
      }
    } else {
      if (verbose) {
        cat("clipr package not available. Displaying prompt:\n\n")
      }
      cat(prompt)
    }
  }
  
  invisible(prompt)
}

#' Comprehensive LLM Assistance for Complete Study Optimization
#'
#' @description
#' Generates comprehensive prompts for optimizing all aspects of an inrep study,
#' including configuration, item banks, analysis strategy, and deployment.
#'
#' @param config Study configuration object from create_study_config()
#' @param item_bank Item bank data frame (optional)
#' @param study_type Character string describing study type for context
#' @param research_goals Character vector of research objectives
#' @param target_population Character string describing target participants
#' @param timeline Character string describing project timeline
#'
#' @return Invisibly returns the comprehensive prompt string
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate comprehensive study optimization prompt
#' config <- create_study_config(name = "Big Five Study")
#' data(bfi_items)
#'
#' comprehensive_llm_assistance(
#'   config = config,
#'   item_bank = bfi_items,
#'   study_type = "Personality assessment",
#'   research_goals = c("Validate Big Five structure", "Test measurement invariance"),
#'   target_population = "University students aged 18-25",
#'   timeline = "6 months data collection"
#' )
#' }
comprehensive_llm_assistance <- function(config,
                                       item_bank = NULL,
                                       study_type = "Psychological assessment",
                                       research_goals = NULL,
                                       target_population = "Not specified",
                                       timeline = "Not specified") {
  
  # Generate comprehensive analysis
  n_items <- if (!is.null(item_bank)) nrow(item_bank) else "Not specified"
  
  prompt <- paste0(
    "# COMPREHENSIVE STUDY OPTIMIZATION CONSULTATION\n\n",
    "You are a senior psychometrician and research methodology expert. I need comprehensive guidance for optimizing every aspect of my adaptive testing study using the inrep R package.\n\n",
    
    "## STUDY OVERVIEW\n",
    "- Study Name: ", config$name, "\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", target_population, "\n",
    "- Timeline: ", timeline, "\n",
    "- Research Goals: ", paste(research_goals %||% "Not specified", collapse = "; "), "\n",
    "- Item Bank Size: ", n_items, " items\n",
    "- IRT Model: ", config$model, "\n\n",
    
    "## CURRENT CONFIGURATION\n",
    "- Test Length: ", config$min_items, " to ", config$max_items %||% "unlimited", " items\n",
    "- Stopping Criterion: SEM ≤ ", config$min_SEM, "\n",
    "- Item Selection: ", config$criteria, "\n",
    "- Theme: ", config$theme, "\n",
    "- Language: ", config$language, "\n",
    "- Session Duration: ", config$max_session_duration, " minutes\n",
    "- Demographics: ", paste(config$demographics %||% "None", collapse = ", "), "\n\n",
    
    "## COMPREHENSIVE OPTIMIZATION REQUESTS\n\n",
    "### 1. PSYCHOMETRIC OPTIMIZATION\n",
    "- Evaluate and optimize all IRT parameters for study goals\n",
    "- Assess item bank adequacy and recommend improvements\n",
    "- Design validation and calibration procedures\n",
    "- Plan for measurement invariance testing across groups\n",
    "- Recommend bias detection and mitigation strategies\n\n",
    
    "### 2. METHODOLOGICAL EXCELLENCE\n",
    "- Optimize study design for research objectives\n",
    "- Plan sampling strategy and power analysis\n",
    "- Design quality control and data monitoring procedures\n",
    "- Recommend ethical considerations and IRB preparation\n",
    "- Plan for publication and reproducibility\n\n",
    
    "### 3. TECHNICAL IMPLEMENTATION\n",
    "- Optimize configuration for target population\n",
    "- Design user experience for maximum engagement\n",
    "- Plan deployment strategy and infrastructure\n",
    "- Recommend security and privacy measures\n",
    "- Design backup and data recovery procedures\n\n",
    
    "### 4. ANALYSIS AND REPORTING\n",
    "- Design comprehensive analysis strategy\n",
    "- Plan for descriptive and inferential statistics\n",
    "- Recommend visualization and reporting approaches\n",
    "- Design interpretation guidelines and benchmarks\n",
    "- Plan for manuscript preparation and submission\n\n",
    
    "## DELIVERABLES REQUESTED\n\n",
    "Please provide:\n",
    "1. **Executive Summary**: Key recommendations and priorities\n",
    "2. **Optimized Configuration**: Complete R code with improvements\n",
    "3. **Methodological Protocol**: Step-by-step research procedures\n",
    "4. **Quality Assurance Plan**: Monitoring and validation procedures\n",
    "5. **Analysis Strategy**: Comprehensive statistical analysis plan\n",
    "6. **Timeline and Milestones**: Project management recommendations\n",
    "7. **Risk Assessment**: Potential issues and mitigation strategies\n",
    "8. **Publication Strategy**: Manuscript and dissemination planning\n\n",
    "Please provide expert-level guidance with specific, actionable recommendations and complete R code examples for implementation."
  )
  
  display_llm_prompt(prompt, "comprehensive")
  
  invisible(prompt)
}
