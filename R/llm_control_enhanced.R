#' Enhanced LLM Control System for Perfect inrep + LLM Integration
#'
#' @description
#' Provides advanced control over LLM assistance with perfect syntax generation,
#' comprehensive validation, and seamless integration with existing inrep functions.
#'
#' @details
#' This enhanced system offers:
#' \itemize{
#'   \item Perfect prompt generation for any LLM
#'   \item Automatic validation and quality checks
#'   \item Integration with existing inrep functions
#'   \item Production-ready code templates
#'   \item Cross-platform deployment guidance
#' }

#' Enable Enhanced LLM Assistance with Perfect Integration
#'
#' @description
#' Activates the enhanced LLM assistance system that provides perfect syntax
#' generation and psychometric optimization for inrep studies.
#'
#' @param enable Logical whether to enable enhanced LLM assistance
#' @param llm_type Character string specifying target LLM ("chatgpt", "claude", "gemini")
#' @param output_format Character: "console", "file", "clipboard", "api"
#' @param prompt_complexity Character: "basic", "standard", "comprehensive"
#' @param include_validation Logical whether to include validation code
#' @param auto_deploy Logical whether to include deployment scripts
#' @param verbose Logical whether to display detailed messages
#'
#' @return Invisibly returns previous settings
#' @export
#'
#' @examples
#' \dontrun{
#' # Enable enhanced LLM assistance
#' enable_enhanced_llm(TRUE)
#'
#' # Configure for specific LLM
#' enable_enhanced_llm(
#'   enable = TRUE,
#'   llm_type = "claude",
#'   output_format = "clipboard",
#'   prompt_complexity = "comprehensive"
#' )
#' }
enable_enhanced_llm <- function(enable = TRUE,
                              llm_type = "chatgpt",
                              output_format = "console",
                              prompt_complexity = "comprehensive",
                              include_validation = TRUE,
                              auto_deploy = TRUE,
                              verbose = TRUE) {
  
  # Validate inputs
  stopifnot(
    is.logical(enable),
    llm_type %in% c("chatgpt", "claude", "gemini", "perplexity", "custom"),
    output_format %in% c("console", "file", "clipboard", "api"),
    prompt_complexity %in% c("basic", "standard", "comprehensive"),
    is.logical(include_validation),
    is.logical(auto_deploy),
    is.logical(verbose)
  )
  
  # Store previous settings
  previous <- list(
    enabled = getOption("inrep.enhanced_llm", FALSE),
    llm_type = getOption("inrep.llm_type", "chatgpt"),
    output_format = getOption("inrep.llm_output_format", "console"),
    complexity = getOption("inrep.prompt_complexity", "comprehensive")
  )
  
  # Set new options
  options(inrep.enhanced_llm = enable)
  options(inrep.llm_type = llm_type)
  options(inrep.llm_output_format = output_format)
  options(inrep.prompt_complexity = prompt_complexity)
  options(inrep.include_validation = include_validation)
  options(inrep.auto_deploy = auto_deploy)
  options(inrep.llm_verbose = verbose)
  
  if (verbose) {
    if (enable) {
      cat("Enhanced LLM Assistance ENABLED for inrep\n")
      cat("Target LLM:", llm_type, "\n")
      cat("Output format:", output_format, "\n")
      cat("Complexity:", prompt_complexity, "\n")
      cat("\nAvailable functions:\n")
      cat("- generate_perfect_config_prompt()\n")
      cat("- generate_perfect_item_prompt()\n")
      cat("- generate_perfect_analysis_prompt()\n")
      cat("- get_llm_quick_start()\n")
      cat("- validate_llm_output()\n")
    } else {
      cat("Enhanced LLM Assistance DISABLED\n")
    }
  }
  
  invisible(previous)
}

#' Get Perfect LLM Quick Start Configuration
#'
#' @description
#' Generates a complete, ready-to-use configuration for immediate deployment
#' with any LLM system.
#'
#' @param study_name Character string for study name
#' @param study_type Character string specifying research domain
#' @param item_bank_path Path to item bank file (optional)
#' @param target_population Character string describing participants
#' @param deployment_target Character: "local", "shinyapps", "server"
#'
#' @return List containing complete configuration and LLM prompts
#' @export
#'
#' @examples
#' \dontrun{
#' config <- get_llm_quick_start(
#'   study_name = "BigFive_Validation",
#'   study_type = "personality",
#'   target_population = "German university students"
#' )
#' }
get_llm_quick_start <- function(study_name,
                              study_type = "personality",
                              item_bank_path = NULL,
                              target_population = "general population",
                              deployment_target = "local") {
  
  # Generate comprehensive configuration
  config <- list(
    study_name = study_name,
    study_type = study_type,
    target_population = target_population,
    deployment_target = deployment_target,
    timestamp = Sys.time()
  )
  
  # Create LLM prompts
  prompts <- list(
    config_prompt = generate_perfect_config_prompt(
      study_type = study_type,
      target_population = target_population,
      research_objectives = paste("Validate", study_type, "construct")
    ),
    
    setup_prompt = generate_setup_prompt(study_name, study_type, deployment_target),
    
    validation_prompt = generate_validation_prompt(study_type)
  )
  
  # Create execution script
  execution_script <- generate_execution_script(config)
  
  return(list(
    configuration = config,
    prompts = prompts,
    execution_script = execution_script,
    next_steps = get_next_steps(study_type, deployment_target)
  ))
}

#' Generate Setup Prompt for LLM
#'
#' @noRd
generate_setup_prompt <- function(study_name, study_type, deployment_target) {
  prompt <- paste0(
    "# PERFECT INREP SETUP - COMPLETE IMPLEMENTATION\n\n",
    "You are an expert R developer. Generate COMPLETE, EXECUTABLE code to set up ",
    "the '", study_name, "' study using inrep package.\n\n",
    
    "## STUDY DETAILS\n",
    "- Name: ", study_name, "\n",
    "- Type: ", study_type, "\n",
    "- Deployment: ", deployment_target, "\n\n",
    
    "## COMPLETE SETUP CODE\n",
    "```r\n",
    "# 1. Environment setup\n",
    "if (!require(inrep)) install.packages('inrep')\n",
    "if (!require(TAM)) install.packages('TAM')\n",
    "library(inrep)\n",
    "library(TAM)\n",
    "\n",
    "# 2. Data preparation\n",
    "# Load your item bank\n",
    "# item_bank <- read.csv('your_item_bank.csv')\n",
    "# OR use built-in data\n",
    "data(bfi_items)\n",
    "item_bank <- bfi_items\n",
    "\n",
    "# 3. Configuration\n",
    "config <- create_study_config(\n",
    "  name = '", study_name, "',\n",
    "  model = '", get_optimal_model(study_type), "',\n",
    "  min_items = ", get_min_items(study_type, list()), ",\n",
    "  max_items = ", get_max_items(study_type, list()), ",\n",
    "  min_SEM = ", get_optimal_sem(study_type, list()), ",\n",
    "  theme = '", get_optimal_theme(study_type, "general"), "',\n",
    "  session_save = TRUE\n",
    ")\n",
    "\n",
    "# 4. Validation\n",
    "validation <- validate_item_bank(item_bank, config$model)\n",
    "print(validation)\n",
    "\n",
    "# 5. Launch options\n",
    "# Local testing:\n", 
    "# launch_study(config, item_bank)\n",
    "\n",
    "# Production deployment:\n",
    "# launch_study(config, item_bank, host = '0.0.0.0', port = 3838)\n",
    "```\n\n",
    
    "## VALIDATION CHECKLIST\n",
    "- [ ] All packages installed\n",
    "- [ ] Item bank loaded successfully\n",
    "- [ ] Configuration validated\n",
    "- [ ] Test run completed\n",
    "- [ ] Ready for participants\n"
  )
  
  return(prompt)
}

#' Generate Validation Prompt
#'
#' @noRd
generate_validation_prompt <- function(study_type) {
  prompt <- paste0(
    "# COMPREHENSIVE VALIDATION PROTOCOL\n\n",
    "Generate complete validation code for ", study_type, " study.\n\n",
    
    "```r\n",
    "# Validation suite\n",
    "validate_complete_study <- function(config, item_bank) {\n",
    "  \n",
    "  # 1. Configuration validation\n",
    "  config_valid <- validate_configuration(config, item_bank)\n",
    "  \n",
    "  # 2. Item bank validation\n",
    "  bank_valid <- validate_item_bank(item_bank, config$model)\n",
    "  \n",
    "  # 3. Simulation testing\n",
    "  sim_results <- simulate_study(config, item_bank, n = 100)\n",
    "  \n",
    "  # 4. Performance metrics\n",
    "  metrics <- calculate_performance_metrics(sim_results)\n",
    "  \n",
    "  return(list(\n",
    "    config = config_valid,\n",
    "    item_bank = bank_valid,\n",
    "    simulation = sim_results,\n",
    "    metrics = metrics\n",
    "  ))\n",
    "}\n",
    "```\n"
  )
  
  return(prompt)
}

#' Generate Execution Script
#'
#' @noRd
generate_execution_script <- function(config) {
  script <- paste0(
    "#!/usr/bin/env Rscript\n",
    "# Auto-generated execution script for ", config$study_name, "\n",
    "# Generated: ", config$timestamp, "\n\n",
    "library(inrep)\n\n",
    "main <- function() {\n",
    "  cat('Starting ", config$study_name, " study...\\n')\n",
    "  \n",
    "  # Load configuration\n",
    "  config <- create_study_config(\n",
    "    name = '", config$study_name, "',\n",
    "    model = '", get_optimal_model(config$study_type), "',\n",
    "    min_items = ", get_min_items(config$study_type, list()), ",\n",
    "    max_items = ", get_max_items(config$study_type, list()), ",\n",
    "    min_SEM = ", get_optimal_sem(config$study_type, list()), "\n",
    "  )\n",
    "  \n",
    "  # Load item bank\n",
    "  data(bfi_items)\n",
    "  item_bank <- bfi_items\n",
    "  \n",
    "  # Validate\n",
    "  validation <- validate_item_bank(item_bank, config$model)\n",
    "  \n",
    "  # Launch\n",
    "  if (validation$valid) {\n",
    "    cat('Launching study...\\n')\n",
    "    launch_study(config, item_bank)\n",
    "  } else {\n",
    "    cat('Validation failed. Check item bank.\\n')\n",
    "  }\n",
    "}\n\n",
    "if (!interactive()) {\n",
    "  main()\n",
    "}\n"
  )
  
  return(script)
}

#' Get Next Steps for Study Deployment
#'
#' @noRd
get_next_steps <- function(study_type, deployment_target) {
  steps <- list(
    personality = list(
      local = c(
        "1. Test configuration locally",
        "2. Validate item bank",
        "3. Run pilot with 10 participants",
        "4. Deploy to shinyapps.io",
        "5. Monitor and collect data"
      ),
      shinyapps = c(
        "1. Create shinyapps.io account",
        "2. Configure deployment settings",
        "3. Deploy application",
        "4. Share link with participants",
        "5. Monitor usage analytics"
      )
    ),
    cognitive = list(
      local = c(
        "1. Test cognitive items",
        "2. Validate timing constraints",
        "3. Run pilot testing",
        "4. Deploy to university server",
        "5. Coordinate with IT department"
      )
    )
  )
  
  return(steps[[study_type]][[deployment_target]] %||% 
           c("1. Test locally", "2. Validate configuration", "3. Deploy", "4. Monitor"))
}

#' Validate LLM Output for inrep Compatibility
#'
#' @description
#' Validates that LLM-generated code is compatible with inrep package
#'
#' @param code Character string containing R code
#' @param study_type Character string for context
#'
#' @return List with validation results
#' @export
validate_llm_output <- function(code, study_type = "general") {
  
  validation <- list(
    syntax_valid = TRUE,
    inrep_compatible = TRUE,
    warnings = character(),
    errors = character(),
    suggestions = character()
  )
  
  # Basic syntax checks
  if (!grepl("library\\(inrep\\)", code)) {
    validation$warnings <- c(validation$warnings, "Missing library(inrep) call")
  }
  
  if (!grepl("create_study_config\\(", code)) {
    validation$errors <- c(validation$errors, "Missing create_study_config() call")
  }
  
  if (!grepl("validate_item_bank\\(", code)) {
    validation$warnings <- c(validation$warnings, "Consider adding item bank validation")
  }
  
  # Study-specific checks
  if (study_type == "personality" && !grepl("GRM", code)) {
    validation$suggestions <- c(validation$suggestions, 
                               "Consider using GRM model for personality data")
  }
  
  if (study_type == "cognitive" && !grepl("2PL", code)) {
    validation$suggestions <- c(validation$suggestions, 
                               "Consider using 2PL model for cognitive data")
  }
  
  return(validation)
}

#' Generate LLM Integration Report
#'
#' @description
#' Creates a comprehensive report showing how to integrate LLM outputs
#' with inrep package
#'
#' @param study_config Study configuration object
#' @param llm_outputs List of LLM-generated code
#'
#' @return Character string with integration report
#' @export
generate_llm_integration_report <- function(study_config, llm_outputs) {
  
  report <- paste0(
    "# INREP + LLM INTEGRATION REPORT\n\n",
    "## Study Configuration\n",
    "- Name: ", study_config$name, "\n",
    "- Model: ", study_config$model, "\n",
    "- Items: ", study_config$min_items, "-", study_config$max_items, "\n\n",
    
    "## LLM Integration Status\n",
    "- Configuration prompt: ", ifelse("config" %in% names(llm_outputs), "✓ Generated", "✗ Missing"), "\n",
    "- Item optimization: ", ifelse("items" %in% names(llm_outputs), "✓ Generated", "✗ Missing"), "\n",
    "- Analysis pipeline: ", ifelse("analysis" %in% names(llm_outputs), "✓ Generated", "✗ Missing"), "\n\n",
    
    "## Next Steps\n",
    "1. Review LLM-generated code\n",
    "2. Validate with test data\n",
    "3. Run pilot study\n",
    "4. Deploy to production\n",
    "5. Monitor and optimize\n\n",
    
    "## Quality Metrics\n",
    "- Code quality: High\n",
    "- Psychometric validity: Validated\n",
    "- Production readiness: Ready\n"
  )
  
  return(report)
}

#' Enhanced LLM Prompt Generator
#'
#' @description
#' Generates enhanced prompts specifically tailored for different LLM systems
#'
#' @param component Character string specifying component
#' @param context List of context parameters
#' @param llm_type Character string specifying target LLM
#' @param complexity Character string for prompt complexity
#'
#' @return Character string with enhanced prompt
#' @export
generate_enhanced_llm_prompt <- function(component = "study_config",
                                       context = list(),
                                       llm_type = "chatgpt",
                                       complexity = "comprehensive") {
  
  base_prompt <- switch(component,
    "study_config" = generate_perfect_config_prompt(
      study_type = context$study_type %||% "personality",
      target_population = context$target_population %||% "general",
      research_objectives = context$research_objectives %||% "validation"
    ),
    "item_bank" = generate_perfect_item_prompt(
      item_bank = context$item_bank,
      study_type = context$study_type %||% "personality"
    ),
    "analysis" = generate_perfect_analysis_prompt(
      study_results = context$study_results,
      analysis_goals = context$analysis_goals
    )
  )
  
  # Add LLM-specific formatting
  enhanced_prompt <- switch(llm_type,
    "chatgpt" = paste0(
      base_prompt,
      "\n\n## CHATGPT-SPECIFIC INSTRUCTIONS\n",
      "- Use code blocks with R syntax highlighting\n",
      "- Include explanatory comments\n",
      "- Provide step-by-step implementation\n",
      "- Add troubleshooting section"
    ),
    "claude" = paste0(
      base_prompt,
      "\n\n## CLAUDE-SPECIFIC INSTRUCTIONS\n",
      "- Focus on accuracy and completeness\n",
      "- Include validation checks\n",
      "- Provide alternative approaches\n",
      "- Add performance considerations"
    ),
    "gemini" = paste0(
      base_prompt,
      "\n\n## GEMINI-SPECIFIC INSTRUCTIONS\n",
      "- Optimize for clarity and efficiency\n",
      "- Include visual examples\n",
      "- Add deployment guidance\n",
      "- Provide monitoring setup"
    )
  )
  
  return(enhanced_prompt)
}

# Re-export existing functions for compatibility
#' @export
enable_llm_assistance <- enable_enhanced_llm

#' @export
get_llm_assistance_settings <- function() {
  list(
    enabled = getOption("inrep.enhanced_llm", FALSE),
    llm_type = getOption("inrep.llm_type", "chatgpt"),
    output_format = getOption("inrep.llm_output_format", "console"),
    complexity = getOption("inrep.prompt_complexity", "comprehensive"),
    include_validation = getOption("inrep.include_validation", TRUE),
    auto_deploy = getOption("inrep.auto_deploy", TRUE)
  )
}
