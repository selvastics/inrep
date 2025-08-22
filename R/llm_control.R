#' Enable or Disable External Assistance Throughout inrep Package
#'
#' @description
#' Controls whether assistance prompts are displayed during package operations.
#' When enabled, relevant functions will generate detailed prompts for external
#' consultation to provide expert-level optimization advice.
#'
#' @param enable Logical indicating whether to enable assistance prompts.
#'   Default is TRUE.
#' @param output_format Character string specifying how to display prompts.
#'   Options: "console" (default), "file", "clipboard".
#' @param prompt_types Character vector specifying which types of prompts to enable.
#'   Options: "all" (default), "validation", "configuration", "estimation", "analysis".
#' @param enhanced_mode Logical indicating whether to use enhanced formatting practices.
#'   Default is TRUE for optimal assistance quality.
#' @param complexity_level Character string specifying the complexity level for enhanced prompts.
#'   Options: "basic", "intermediate", "advanced", "expert". Default is "intermediate".
#' @param verbose Logical indicating whether to display status messages.
#'   Default is TRUE.
#'
#' @return Invisibly returns the previous setting for assistance.
#'
#' @export
#'
#' @details
#' The inrep package includes comprehensive assistance capabilities that generate
#' expert-level prompts for optimizing various aspects of adaptive testing studies.
#' These prompts can be used with external consultation services to provide:
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
#' \strong{Enhanced Mode Features (Claude 4 Best Practices):}
#' When enhanced_mode is TRUE, the system uses:
#' \itemize{
#'   \item Clear and direct instructions with specific objectives
#'   \item Multishot examples for better context understanding
#'   \item Chain of thought reasoning for complex problem solving
#'   \item XML tags for structured, parseable output
#'   \item System prompts for consistent role definition
#'   \item Extended thinking for sophisticated analysis
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
#'   \item \code{\link{generate_task_specific_prompt}}: Enhanced task-specific prompts
#' }
#'
#' \strong{Privacy and Ethics:}
#' All prompts are generated locally and contain no participant data or confidential
#' information. Only configuration parameters, statistical summaries, and technical
#' specifications are included in prompts.
#'
#' @examples
#' \dontrun{
#' # Enable enhanced assistance with console output
#' enable_llm_assistance(TRUE, enhanced_mode = TRUE)
#'
#' # Now when you run package functions, you'll get optimization prompts:
#' config <- create_study_config(
#'   name = "Personality Study",
#'   model = "GRM"
#' )
#' # Displays enhanced prompt for configuration optimization
#'
#' validate_item_bank(bfi_items, "GRM")
#' # Displays enhanced prompt for validation insights
#'
#' # Enable specific prompt types with advanced complexity
#' enable_llm_assistance(
#'   enable = TRUE,
#'   prompt_types = c("validation", "configuration"),
#'   enhanced_mode = TRUE,
#'   complexity_level = "advanced"
#' )
#'
#' # Save enhanced prompts to files instead of console
#' enable_llm_assistance(
#'   enable = TRUE,
#'   output_format = "file",
#'   enhanced_mode = TRUE
#' )
#'
#' # Disable all assistance
#' enable_llm_assistance(FALSE)
#' }
enable_llm_assistance <- function(enable = TRUE,
                                 output_format = "console",
                                 prompt_types = "all",
                                 enhanced_mode = TRUE,
                                 complexity_level = "intermediate",
                                 verbose = TRUE) {
  
  # Validate inputs
  stopifnot(
    is.logical(enable),
    is.character(output_format),
    output_format %in% c("console", "file", "clipboard"),
    is.character(prompt_types),
    all(prompt_types %in% c("all", "validation", "configuration", "estimation", "analysis", "ui", "multilingual", "deployment", "documentation")),
    is.logical(enhanced_mode),
    is.character(complexity_level),
    complexity_level %in% c("basic", "intermediate", "advanced", "expert"),
    is.logical(verbose)
  )
  
  # Store previous setting
  previous_setting <- getOption("inrep.llm_assistance", FALSE)
  
  # Set new options
  options(
    inrep.llm_assistance = enable,
    inrep.llm_output_format = output_format,
    inrep.llm_prompt_types = prompt_types,
    inrep.llm_enhanced_mode = enhanced_mode,
    inrep.llm_complexity_level = complexity_level
  )
  
  # Display status message
  if (verbose) {
    if (enable) {
      message("LLM assistance enabled")
      if (enhanced_mode) {
        message("Enhanced mode active (Claude 4 best practices)")
        message("Complexity level: ", complexity_level)
      }
      message("Output format: ", output_format)
      message("Prompt types: ", paste(prompt_types, collapse = ", "))
    } else {
      message("LLM assistance disabled")
    }
  }
  
  invisible(previous_setting)
}

#' Get Current LLM Assistance Settings
#'
#' @description
#' Retrieves the current configuration for LLM assistance throughout the package
#'
#' @return List containing current LLM assistance settings
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get current settings
#' current_settings <- get_llm_assistance_settings()
#' print(current_settings)
#' }
get_llm_assistance_settings <- function() {
  
  list(
    enabled = getOption("inrep.llm_assistance", FALSE),
    output_format = getOption("inrep.llm_output_format", "console"),
    prompt_types = getOption("inrep.llm_prompt_types", "all"),
    enhanced_mode = getOption("inrep.llm_enhanced_mode", TRUE),
    complexity_level = getOption("inrep.llm_complexity_level", "intermediate")
  )
}

#' Set LLM Assistance Settings
#'
#' @description
#' Configures multiple LLM assistance settings at once
#'
#' @param ... Named arguments for LLM assistance settings
#'
#' @return Invisibly returns the previous settings
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Configure multiple settings at once
#' set_llm_assistance_settings(
#'   enable = TRUE,
#'   enhanced_mode = TRUE,
#'   complexity_level = "advanced",
#'   output_format = "file"
#' )
#' }
set_llm_assistance_settings <- function(...) {
  
  args <- list(...)
  previous_settings <- get_llm_assistance_settings()
  
  # Validate and set each argument
  if ("enable" %in% names(args)) {
    stopifnot(is.logical(args$enable))
    options(inrep.llm_assistance = args$enable)
  }
  
  if ("output_format" %in% names(args)) {
    stopifnot(is.character(args$output_format),
              args$output_format %in% c("console", "file", "clipboard"))
    options(inrep.llm_output_format = args$output_format)
  }
  
  if ("prompt_types" %in% names(args)) {
    stopifnot(is.character(args$prompt_types),
              all(args$prompt_types %in% c("all", "validation", "configuration", "estimation", "analysis", "ui", "multilingual", "deployment", "documentation")))
    options(inrep.llm_prompt_types = args$prompt_types)
  }
  
  if ("enhanced_mode" %in% names(args)) {
    stopifnot(is.logical(args$enhanced_mode))
    options(inrep.llm_enhanced_mode = args$enhanced_mode)
  }
  
  if ("complexity_level" %in% names(args)) {
    stopifnot(is.character(args$complexity_level),
              args$complexity_level %in% c("basic", "intermediate", "advanced", "expert"))
    options(inrep.llm_complexity_level = args$complexity_level)
  }
  
  # Display updated settings
  message("LLM assistance settings updated:")
  current_settings <- get_llm_assistance_settings()
  for (name in names(current_settings)) {
    message("  ", name, ": ", paste(current_settings[[name]], collapse = ", "))
  }
  
  invisible(previous_settings)
}

#' Display LLM Prompt with Enhanced Formatting
#'
#' @description
#' Displays LLM prompts with enhanced formatting and Claude 4 best practices
#'
#' @param prompt Character string containing the LLM prompt
#' @param task_type Character string specifying the task type
#' @param context List containing context information
#' @param enhanced Logical indicating whether to use enhanced formatting
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Display a basic prompt
#' display_llm_prompt("Your prompt here", "study_config")
#'
#' # Display an enhanced prompt with context
#' context <- list(study_type = "personality", population = "students")
#' display_llm_prompt("Your prompt here", "study_config", context, enhanced = TRUE)
#' }
display_llm_prompt <- function(prompt,
                              task_type = "general",
                              context = list(),
                              enhanced = TRUE) {
  
  # Check if enhanced mode is enabled
  enhanced_mode <- getOption("inrep.llm_enhanced_mode", TRUE)
  output_format <- getOption("inrep.llm_output_format", "console")
  
  if (enhanced && enhanced_mode) {
    # Use enhanced display function
    display_enhanced_llm_prompt(prompt, task_type, output_format)
  } else {
    # Use basic display
    if (output_format == "console") {
      message("\n" %r% 60)
      message("LLM ASSISTANCE PROMPT")
      message("Task: ", toupper(task_type))
      message("=" %r% 60)
      message("")
      message(prompt)
      message("")
      message("=" %r% 60)
    } else if (output_format == "file") {
      filename <- paste0("llm_prompt_", task_type, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
      writeLines(prompt, filename)
      message("Prompt saved to: ", filename)
    } else if (output_format == "clipboard") {
      tryCatch({
        writeClipboard(prompt)
        message("Prompt copied to clipboard")
      }, error = function(e) {
        message("Could not copy to clipboard. Saving to file instead.")
        filename <- paste0("llm_prompt_", task_type, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
        writeLines(prompt, filename)
        message("Prompt saved to: ", filename)
      })
    }
  }
  
  invisible(prompt)
}

#' Generate Enhanced LLM Prompt for Specific Task
#'
#' @description
#' Creates an enhanced LLM prompt using Claude 4 best practices for a specific task
#'
#' @param task_type Character string specifying the task type
#' @param context List containing context information
#' @param complexity_level Character string specifying complexity
#' @param include_reasoning Logical indicating whether to include reasoning steps
#' @param output_structure Character string specifying output format
#'
#' @return Character string containing the enhanced LLM prompt
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate enhanced prompt for study design
#' context <- list(
#'   study_type = "personality",
#'   population = "university students",
#'   sample_size = 500,
#'   duration = "20 minutes"
#' )
#' 
#' prompt <- generate_enhanced_prompt(
#'   task_type = "study_design",
#'   context = context,
#'   complexity_level = "intermediate",
#'   include_reasoning = TRUE,
#'   output_structure = "structured"
#' )
#' 
#' # Display the enhanced prompt
#' display_llm_prompt(prompt, "study_design", context, enhanced = TRUE)
#' }
generate_enhanced_prompt <- function(task_type,
                                   context = list(),
                                   complexity_level = NULL,
                                   include_reasoning = TRUE,
                                   output_structure = "structured") {
  
  # Use global complexity level if not specified
  if (is.null(complexity_level)) {
    complexity_level <- getOption("inrep.llm_complexity_level", "intermediate")
  }
  
  # Generate the enhanced prompt using the new system
  prompt <- generate_task_specific_prompt(
    task_type = task_type,
    context = context,
    complexity_level = complexity_level,
    include_reasoning = include_reasoning,
    output_structure = output_structure
  )
  
  return(prompt)
}

#' Quick LLM Assistance for Common Tasks
#'
#' @description
#' Provides quick access to enhanced LLM assistance for common assessment tasks
#'
#' @param task Character string specifying the quick task
#' @param context List containing minimal context information
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Quick assistance for study configuration
#' quick_llm_assistance("study_config", list(study_type = "cognitive"))
#'
#' # Quick assistance for item bank validation
#' quick_llm_assistance("validation", list(model = "GRM"))
#' }
quick_llm_assistance <- function(task, context = list()) {
  
  # Map quick tasks to full task types
  task_mapping <- list(
    "study_config" = "study_design",
    "validation" = "item_bank_optimization",
    "estimation" = "ability_estimation",
    "ui" = "ui_optimization",
    "analysis" = "analysis_planning",
    "deployment" = "deployment_strategy"
  )
  
  if (task %in% names(task_mapping)) {
    task_type <- task_mapping[[task]]
  } else {
    task_type <- task
  }
  
  # Generate and display enhanced prompt
  prompt <- generate_enhanced_prompt(task_type, context)
  display_llm_prompt(prompt, task_type, context, enhanced = TRUE)
  
  invisible(prompt)
}
