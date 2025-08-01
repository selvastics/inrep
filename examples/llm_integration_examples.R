#' LLM Integration Examples for inrep Package
#' 
#' This file demonstrates how to use the enhanced LLM capabilities
#' to generate perfect inrep configurations with any LLM system.
#' 
#' @examples
#' \dontrun{
#' # Run these examples to see LLM integration in action
#' }

# Load required packages
library(inrep)

# ============================================================================
# EXAMPLE 1: Basic LLM-Assisted Study Configuration
# ============================================================================

# Enable enhanced LLM assistance
enable_enhanced_llm(
  enable = TRUE,
  llm_type = "chatgpt",
  output_format = "console",
  prompt_complexity = "comprehensive"
)

# Generate perfect configuration prompt for personality study
personality_prompt <- generate_perfect_config_prompt(
  study_type = "personality",
  target_population = "German university students aged 18-35",
  research_objectives = c(
    "Validate Big Five structure",
    "Test measurement invariance across gender",
    "Establish norm scores"
  ),
  constraints = list(
    max_duration = 15,
    min_sample = 500,
    language = "de",
    ethical_approval = TRUE
  )
)

# Print the prompt to use with ChatGPT
cat("=== COPY THIS PROMPT TO CHATGPT ===\n")
cat(personality_prompt)

# ============================================================================
# EXAMPLE 2: Item Bank Optimization with LLM
# ============================================================================

# Load sample data
data(bfi_items)

# Generate item optimization prompt
item_prompt <- generate_perfect_item_prompt(
  item_bank = bfi_items,
  study_type = "personality",
  target_precision = 0.3,
  validation_level = "comprehensive"
)

cat("\n\n=== ITEM OPTIMIZATION PROMPT ===\n")
cat(item_prompt)

# ============================================================================
# EXAMPLE 3: Complete LLM Quick Start
# ============================================================================

# Get complete quick-start configuration
quick_start <- get_llm_quick_start(
  study_name = "BigFive_German_Validation",
  study_type = "personality",
  target_population = "German university students",
  deployment_target = "shinyapps"
)

# Display configuration
cat("\n\n=== QUICK START CONFIGURATION ===\n")
print(quick_start$configuration)

# Display prompts
cat("\n=== LLM PROMPTS ===\n")
cat("Configuration prompt length:", nchar(quick_start$prompts$config_prompt), "characters\n")
cat("Setup prompt length:", nchar(quick_start$prompts$setup_prompt), "characters\n")

# Display execution script
cat("\n=== EXECUTION SCRIPT ===\n")
cat(quick_start$execution_script)

# ============================================================================
# EXAMPLE 4: Advanced LLM Integration
# ============================================================================

# Create advanced context for complex study
advanced_context <- list(
  study_type = "cognitive",
  target_population = "Adults with ADHD",
  research_objectives = c(
    "Assess working memory capacity",
    "Measure attention control",
    "Evaluate processing speed"
  ),
  constraints = list(
    max_duration = 30,
    clinical_population = TRUE,
    adaptive_difficulty = TRUE,
    real_time_monitoring = TRUE
  )
)

# Generate enhanced prompt for Claude
claude_prompt <- generate_enhanced_llm_prompt(
  component = "study_config",
  context = advanced_context,
  llm_type = "claude",
  complexity = "comprehensive"
)

cat("\n\n=== CLAUDE-OPTIMIZED PROMPT ===\n")
cat(claude_prompt)

# ============================================================================
# EXAMPLE 5: Validation and Quality Assurance
# ============================================================================

# Sample LLM-generated code for validation
sample_code <- "
library(inrep)
config <- create_study_config(
  name = 'Test_Study',
  model = 'GRM',
  min_items = 10,
  max_items = 30
)
"

# Validate the code
validation <- validate_llm_output(sample_code, "personality")
cat("\n\n=== VALIDATION RESULTS ===\n")
print(validation)

# ============================================================================
# EXAMPLE 6: Production Deployment with LLM
# ============================================================================

# Generate deployment configuration
deployment_config <- list(
  study_name = "Clinical_Depression_Screening",
  study_type = "clinical",
  target_population = "Adults seeking mental health services",
  deployment_target = "secure_server"
)

# Get complete deployment package
deployment_package <- get_llm_quick_start(
  study_name = deployment_config$study_name,
  study_type = deployment_config$study_type,
  target_population = deployment_config$target_population,
  deployment_target = deployment_config$deployment_target
)

# Save deployment package
saveRDS(deployment_package, "clinical_deployment_package.rds")
cat("\n=== DEPLOYMENT PACKAGE SAVED ===\n")

# ============================================================================
# EXAMPLE 7: Interactive LLM Session
# ============================================================================

# Interactive function for LLM assistance
run_llm_assistant <- function() {
  cat("=== INREP LLM ASSISTANT ===\n")
  cat("1. Personality Study\n")
  cat("2. Cognitive Assessment\n")
  cat("3. Clinical Screening\n")
  cat("4. Educational Testing\n")
  cat("5. Custom Configuration\n")
  
  choice <- readline("Select study type (1-5): ")
  
  study_types <- c("personality", "cognitive", "clinical", "educational", "custom")
  selected_type <- study_types[as.numeric(choice)]
  
  if (!is.na(selected_type)) {
    prompt <- generate_perfect_config_prompt(
      study_type = selected_type,
      target_population = "general population",
      research_objectives = paste("Validate", selected_type, "construct")
    )
    
    cat("\n=== GENERATED PROMPT ===\n")
    cat(prompt)
    
    # Save to file
    writeLines(prompt, paste0("inrep_", selected_type, "_prompt.txt"))
    cat("\n\nPrompt saved to: inrep_", selected_type, "_prompt.txt\n")
  }
}

# Uncomment to run interactive assistant
# run_llm_assistant()

# ============================================================================
# EXAMPLE 8: Batch LLM Processing
# ============================================================================

# Process multiple study types
study_types <- c("personality", "cognitive", "clinical", "educational")
batch_results <- lapply(study_types, function(type) {
  list(
    type = type,
    prompt = generate_perfect_config_prompt(
      study_type = type,
      target_population = "general population",
      research_objectives = paste("Validate", type, "construct")
    ),
    validation = validate_llm_output(
      "library(inrep)\nconfig <- create_study_config()",
      type
    )
  )
})

# Display batch results
cat("\n=== BATCH PROCESSING RESULTS ===\n")
for (result in batch_results) {
  cat(sprintf("%s: %d characters, %d warnings\n", 
              result$type, 
              nchar(result$prompt), 
              length(result$validation$warnings)))
}

# ============================================================================
# EXAMPLE 9: LLM Integration Report
# ============================================================================

# Create integration report
sample_config <- create_study_config(
  name = "Example_Report",
  model = "GRM",
  min_items = 10,
  max_items = 25
)

sample_llm_outputs <- list(
  config = "library(inrep)\nconfig <- create_study_config(...)",
  items = "validation <- validate_item_bank(...)",
  analysis = "results <- analyze_study_results(...)"
)

report <- generate_llm_integration_report(sample_config, sample_llm_outputs)
cat("\n=== INTEGRATION REPORT ===\n")
cat(report)

# ============================================================================
# EXAMPLE 10: Real-World Usage Pattern
# ============================================================================

# Complete workflow example
complete_workflow <- function() {
  cat("=== COMPLETE LLM WORKFLOW ===\n")
  
  # Step 1: Enable LLM assistance
  enable_enhanced_llm(
    enable = TRUE,
    llm_type = "chatgpt",
    output_format = "file"
  )
  
  # Step 2: Generate configuration
  config_prompt <- generate_perfect_config_prompt(
    study_type = "personality",
    target_population = "working adults",
    research_objectives = c("workplace personality assessment", "team dynamics"),
    constraints = list(max_duration = 12, language = "en")
  )
  
  # Step 3: Load and optimize item bank
  data(bfi_items)
  item_prompt <- generate_perfect_item_prompt(
    item_bank = bfi_items,
    study_type = "personality",
    target_precision = 0.35
  )
  
  # Step 4: Create quick start
  quick_start <- get_llm_quick_start(
    study_name = "WorkplacePersonality_2024",
    study_type = "personality",
    target_population = "working adults",
    deployment_target = "shinyapps"
  )
  
  # Step 5: Save all outputs
  dir.create("llm_outputs", showWarnings = FALSE)
  writeLines(config_prompt, "llm_outputs/config_prompt.txt")
  writeLines(item_prompt, "llm_outputs/item_prompt.txt")
  writeLines(quick_start$execution_script, "llm_outputs/execute_study.R")
  saveRDS(quick_start, "llm_outputs/complete_package.rds")
  
  cat("All LLM outputs saved to 'llm_outputs/' directory\n")
  cat("Ready to use with your preferred LLM!\n")
}

# Uncomment to run complete workflow
# complete_workflow()

# ============================================================================
# SUMMARY
# ============================================================================

cat("\n=== LLM INTEGRATION SUMMARY ===\n")
cat("The enhanced LLM system provides:\n")
cat("• Perfect syntax generation for all inrep functions\n")
cat("• Psychometrically validated parameter optimization\n")
cat("• Compatibility with ChatGPT, Claude, Gemini, etc.\n")
cat("• Production-ready code templates\n")
cat("• Comprehensive validation and quality assurance\n")
cat("• Cross-platform deployment guidance\n")
cat("• Interactive and batch processing capabilities\n")
