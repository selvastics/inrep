#' Enhanced LLM Integration for Perfect inrep + LLM Fine-tuning Support
#'
#' @description
#' Provides comprehensive, expert-level LLM prompts that generate perfectly formatted
#' inrep code with psychometrically optimal parameters. These prompts are designed
#' to work with any LLM (ChatGPT, Claude, Gemini, etc.) to produce production-ready
#' configurations that integrate seamlessly with inrep's architecture.
#'
#' @details
#' This enhanced system provides:
#' \itemize{
#'   \item Perfect syntax generation for all inrep functions
#'   \item Psychometrically validated parameter optimization
#'   \item Context-aware recommendations based on study type
#'   \item Production-ready code templates
#'   \item Validation and quality assurance protocols
#'   \item Cross-platform deployment strategies
#' }

#' Generate Perfect LLM Prompt for inrep Study Configuration
#'
#' @description
#' Creates expert-level prompts that instruct LLMs to generate perfectly formatted
#' inrep study configurations with psychometrically optimal parameters.
#'
#' @param study_type Character string specifying the research domain
#' @param target_population Character string describing participants
#' @param research_objectives Character vector of specific research goals
#' @param constraints List of practical constraints (time, sample size, etc.)
#' @param advanced_features Logical whether to include advanced features
#' @param validation_level Character: "basic", "standard", "comprehensive"
#'
#' @return Character string containing the complete LLM prompt
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate perfect configuration prompt
#' prompt <- generate_perfect_config_prompt(
#'   study_type = "personality",
#'   target_population = "German university students aged 18-35",
#'   research_objectives = c("Validate Big Five structure", "Test measurement invariance"),
#'   constraints = list(max_duration = 15, min_sample = 500, language = "de")
#' )
#' }
generate_perfect_config_prompt <- function(study_type = "personality",
                                         target_population = "general population",
                                         research_objectives = NULL,
                                         constraints = list(),
                                         advanced_features = TRUE,
                                         validation_level = "comprehensive") {
  
  prompt <- paste0(
    "# EXPERT INREP CONFIGURATION - PERFECT SYNTAX GENERATION\n\n",
    "You are a world-class psychometrician and R programming expert specializing in the inrep package. ",
    "Generate a PERFECTLY FORMATTED, PRODUCTION-READY inrep study configuration that will run without errors.\n\n",
    
    "## CRITICAL REQUIREMENTS\n",
    "- Generate COMPLETE, EXECUTABLE R code\n",
    "- Use EXACT inrep function syntax\n",
    "- Include ALL required parameters\n",
    "- Provide psychometric justification for each choice\n",
    "- Ensure cross-validation and quality assurance\n\n",
    
    "## STUDY SPECIFICATIONS\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", target_population, "\n",
    "- Research Objectives: ", paste(research_objectives %||% "general assessment", collapse = "; "), "\n",
    "- Constraints: ", paste(names(constraints), unlist(constraints), sep = ": ", collapse = "; "), "\n\n",
    
    "## PERFECT CONFIGURATION TEMPLATE\n",
    "Generate the following EXACT structure:\n\n",
    
    "### 1. Core Study Configuration\n",
    "```r\n",
    "# Load required packages\n",
    "library(inrep)\n",
    "library(TAM)\n",
    "\n",
    "# Create optimized study configuration\n",
    "config <- create_study_config(\n",
    "  name = '", toupper(study_type), "_STUDY_', format(Sys.Date(), '%Y%m%d'), \"_\",\n    "  model = '", get_optimal_model(study_type), "',\n",
    "  min_items = ", get_min_items(study_type, constraints), ",\n",
    "  max_items = ", get_max_items(study_type, constraints), ",\n",
    "  min_SEM = ", get_optimal_sem(study_type, constraints), ",\n",
    "  criteria = '", get_optimal_criteria(study_type), "',\n",
    "  theta_prior = c(", get_theta_prior(study_type, target_population), "),\n",
    "  stopping_rule = function(theta, sem, items_administered, responses) {\n", 
    "    ", get_stopping_rule(study_type, constraints), "\n",
    "  },\n",
    "  adaptive_start = ", get_adaptive_start(study_type), ",\n",
    "  max_session_duration = ", constraints$max_duration %||% 20, ",\n",
    "  theme = '", get_optimal_theme(study_type, target_population), "',\n",
    "  language = '", constraints$language %||% "en", "',\n",
    "  demographics = ", get_demographics_config(study_type, target_population), ",\n",
    "  input_types = ", get_input_types(study_type), ",\n",
    "  response_validation_fun = ", get_validation_function(study_type), ",\n",
    "  session_save = TRUE,\n",
    "  parallel_computation = TRUE\n",
    ")\n",
    "```\n\n",
    
    "### 2. Item Bank Optimization\n",
    "```r\n",
    "# Validate and optimize item bank\n",
    "validation_result <- validate_item_bank(\n",
    "  item_bank = your_item_bank,\n",
    "  model = config$model,\n",
    "  min_items = config$min_items,\n",
    "  max_items = config$max_items,\n",
    "  target_sem = config$min_SEM\n",
    ")\n",
    "\n",
    "# Handle unknown parameters\n",
    "if (any(is.na(your_item_bank[, c('a', 'b', 'b1', 'b2', 'b3', 'b4')]))) {\n",
    "  your_item_bank <- initialize_unknown_parameters(\n",
    "    item_bank = your_item_bank,\n",
    "    model = config$model,\n",
    "    method = '", get_initialization_method(study_type), "'\n",
    "  )\n",
    "}\n",
    "```\n\n",
    
    "### 3. Quality Assurance Setup\n",
    "```r\n",
    "# Comprehensive validation protocol\n",
    "qa_protocol <- list(\n",
    "  pre_launch_checks = ", get_pre_launch_checks(study_type), ",\n",
    "  monitoring = ", get_monitoring_config(study_type), ",\n",
    "  data_validation = ", get_data_validation(study_type), ",\n",
    "  backup_strategy = ", get_backup_strategy(study_type), "\n",
    ")\n",
    "```\n\n",
    
    "### 4. Deployment Configuration\n",
    "```r\n",
    "# Production deployment settings\n",
    "deployment_config <- list(\n",
    "  platform = '", get_deployment_platform(study_type, constraints), "',\n",
    "  security = ", get_security_config(study_type, constraints), ",\n",
    "  performance = ", get_performance_config(study_type), ",\n",
    "  monitoring = ", get_monitoring_setup(study_type), "\n",
    ")\n",
    "```\n\n",
    
    "## PSYCHOMETRIC JUSTIFICATIONS\n",
    "For each parameter choice, provide:\n",
    "1. **Statistical rationale** based on IRT theory\n",
    "2. **Empirical evidence** from validation studies\n",
    "3. **Practical considerations** for target population\n",
    "4. **Quality metrics** for evaluation\n",
    "5. **Alternative configurations** for sensitivity analysis\n\n",
    
    "## VALIDATION CHECKLIST\n",
    "- [ ] All parameters within acceptable ranges\n",
    "- [ ] Cross-validation with simulated data\n",
    "- [ ] Pilot testing protocol\n",
    "- [ ] Ethical approval documentation\n",
    "- [ ] Data quality monitoring plan\n",
    "- [ ] Reproducibility verification\n\n",
    
    "## EXECUTION COMMANDS\n",
    "```r\n",
    "# Test configuration\n",
    "test_results <- validate_configuration(config, your_item_bank)\n",
    "\n",
    "# Launch study\n",
    "study_results <- launch_study(\n",
    "  config = config,\n",
    "  item_bank = your_item_bank,\n",
    "  save_path = 'data/study_results',\n",
    "  verbose = TRUE\n",
    ")\n",
    "```\n\n",
    
    "Generate COMPLETE, EXECUTABLE code with ALL parameters specified. ",
    "Ensure the configuration will run successfully in production."
  )
  
  return(prompt)
}

#' Generate Perfect Item Bank Optimization Prompt
#'
#' @description
#' Creates expert prompts for LLMs to generate perfectly formatted item bank
#' optimization code with psychometric validation.
#'
#' @param item_bank The item bank data frame
#' @param study_type Character string specifying the research domain
#' @param target_precision Numeric target standard error
#' @param validation_level Character: "basic", "standard", "comprehensive"
#' @param include_simulation Logical whether to include simulation code
#'
#' @return Character string containing the complete LLM prompt
#' @export
#'
#' @examples
#' \dontrun{
#' data(bfi_items)
#' prompt <- generate_perfect_item_prompt(
#'   item_bank = bfi_items,
#'   study_type = "personality",
#'   target_precision = 0.3,
#'   validation_level = "comprehensive"
#' )
#' }
generate_perfect_item_prompt <- function(item_bank,
                                       study_type = "personality",
                                       target_precision = 0.3,
                                       validation_level = "comprehensive",
                                       include_simulation = TRUE) {
  
  n_items <- nrow(item_bank)
  domains <- unique(item_bank$domain)
  
  prompt <- paste0(
    "# EXPERT ITEM BANK OPTIMIZATION - PERFECT SYNTAX\n\n",
    "You are a world-class psychometrician. Generate PERFECTLY FORMATTED R code ",
    "to optimize this item bank for the inrep package with comprehensive validation.\n\n",
    
    "## ITEM BANK SPECIFICATIONS\n",
    "- Total Items: ", n_items, "\n",
    "- Domains: ", paste(domains, collapse = ", "), "\n",
    "- Study Type: ", study_type, "\n",
    "- Target Precision: ", target_precision, "\n",
    "- Model: ", get_optimal_model(study_type), "\n\n",
    
    "## PERFECT OPTIMIZATION CODE\n",
    "```r\n",
    "# Load packages\n",
    "library(inrep)\n",
    "library(TAM)\n",
    "library(psych)\n",
    "\n",
    "# Item bank analysis and optimization\n",
    "optimize_item_bank <- function(item_bank) {\n",
    "  \n",
    "  # Step 1: Parameter validation\n",
    "  cat('Validating item parameters...\\n')\n",
    "  validation <- validate_item_bank(\n",
    "    item_bank = item_bank,\n",
    "    model = '", get_optimal_model(study_type), "',\n",
    "    target_sem = ", target_precision, "\n",
    "  )\n",
    "  \n",
    "  # Step 2: Content coverage analysis\n",
    "  coverage_analysis <- analyze_content_coverage(\n",
    "    item_bank = item_bank,\n",
    "    domains = c('", paste(domains, collapse = "', '"), "'),\n",
    "    difficulty_range = c(-3, 3),\n",
    "    target_points = 50\n",
    "  )\n",
    "  \n",
    "  # Step 3: Information curve optimization\n",
    "  info_curves <- calculate_information_curves(\n",
    "    item_bank = item_bank,\n",
    "    theta_range = seq(-4, 4, 0.1),\n",
    "    model = '", get_optimal_model(study_type), "'\n",
    "  )\n",
    "  \n",
    "  # Step 4: Item selection efficiency\n",
    "  efficiency_metrics <- calculate_efficiency(\n",
    "    item_bank = item_bank,\n",
    "    target_sem = ", target_precision, ",\n",
    "    max_items = 30,\n",
    "    n_sim = 1000\n",
    "  )\n",
    "  \n",
    "  # Step 5: Generate optimization report\n",
    "  optimization_report <- list(\n",
    "    validation = validation,\n",
    "    coverage = coverage_analysis,\n",
    "    efficiency = efficiency_metrics,\n",
    "    recommendations = generate_recommendations(validation, coverage_analysis)\n",
    "  )\n",
    "  \n",
    "  return(optimization_report)\n",
    "}\n",
    "\n",
    "# Execute optimization\n",
    "opt_results <- optimize_item_bank(your_item_bank)\n",
    "\n",
    "# Generate optimized item bank\n",
    "optimized_bank <- implement_recommendations(\n",
    "  original_bank = your_item_bank,\n",
    "  recommendations = opt_results$recommendations\n",
    ")\n",
    "```\n\n",
    
    "## VALIDATION PROTOCOL\n",
    "```r\n",
    "# Comprehensive validation\n",
    "validate_optimized_bank <- function(item_bank) {\n",
    "  \n",
    "  # Psychometric validation\n",
    "  psychometric_checks <- list(\n",
    "    parameter_ranges = validate_parameter_ranges(item_bank),\n",
    "    model_fit = assess_model_fit(item_bank),\n",
    "    local_independence = check_local_independence(item_bank),\n",
    "    differential_functioning = check_dif(item_bank)\n",
    "  )\n",
    "  \n", 
    "  # Simulation validation\n",
    "  simulation_results <- simulate_adaptive_test(\n",
    "    item_bank = item_bank,\n",
    "    n_persons = 1000,\n", 
    "    n_replications = 100,\n",
    "    model = '", get_optimal_model(study_type), "',\n",
    "    stopping_rule = list(criterion = 'sem', value = ", target_precision, ")\n",
    "  )\n",
    "  \n",
    "  return(list(\n",
    "    psychometric = psychometric_checks,\n",
    "    simulation = simulation_results,\n",
    "    quality_metrics = calculate_quality_metrics(simulation_results)\n",
    "  ))\n",
    "}\n",
    "```\n\n",
    
    "## QUALITY METRICS\n",
    "- Test information function ≥ 10 at θ = 0\n",
    "- Standard error ≤ ", target_precision, " for 95% of population\n",
    "- Item exposure rates between 0.05 and 0.8\n",
    "- Content balance across domains\n",
    "- No items with negative discrimination\n",
    "- All difficulty parameters within [-3, 3] range\n\n",
    
    "## EXECUTION CHECKLIST\n",
    "- [ ] All parameters validated\n",
    "- [ ] Simulation results reviewed\n",
    "- [ ] Quality metrics achieved\n",
    "- [ ] Documentation complete\n",
    "- [ ] Ready for production deployment\n\n",
    
    "Generate COMPLETE, EXECUTABLE code with ALL validation steps included."
  )
  
  return(prompt)
}

#' Generate Perfect Analysis Pipeline Prompt
#'
#' @description
#' Creates expert prompts for LLMs to generate complete analysis pipelines
#' with perfect inrep syntax and psychometric validation.
#'
#' @param study_results Study results object from inrep
#' @param analysis_goals Character vector of specific analysis objectives
#' @param reporting_level Character: "basic", "standard", "comprehensive"
#' @param include_visualization Logical whether to include plotting code
#'
#' @return Character string containing the complete LLM prompt
#' @export
#'
#' @examples
#' \dontrun{
#' prompt <- generate_perfect_analysis_prompt(
#'   study_results = results,
#'   analysis_goals = c("validate construct", "test measurement invariance"),
#'   reporting_level = "comprehensive"
#' )
#' }
generate_perfect_analysis_prompt <- function(study_results,
                                           analysis_goals = NULL,
                                           reporting_level = "comprehensive",
                                           include_visualization = TRUE) {
  
  prompt <- paste0(
    "# EXPERT ANALYSIS PIPELINE - PERFECT SYNTAX\n\n",
    "You are a world-class data analyst and psychometrician. Generate PERFECTLY FORMATTED R code ",
    "for comprehensive analysis of inrep study results with publication-ready outputs.\n\n",
    
    "## ANALYSIS OBJECTIVES\n",
    "- Goals: ", paste(analysis_goals %||% "comprehensive analysis", collapse = "; "), "\n",
    "- Reporting Level: ", reporting_level, "\n",
    "- Visualization: ", ifelse(include_visualization, "included", "basic"), "\n\n",
    
    "## PERFECT ANALYSIS PIPELINE\n",
    "```r\n",
    "# Load packages\n",
    "library(inrep)\n",
    "library(TAM)\n",
    "library(ggplot2)\n",
    "library(dplyr)\n",
    "library(tidyr)\n",
    "library(knitr)\n",
    "library(rmarkdown)\n",
    "\n",
    "# Complete analysis function\n",
    "analyze_study_results <- function(study_results) {\n",
    "  \n",
    "  # 1. Data extraction and validation\n",
    "  cat('Extracting and validating data...\\n')\n",
    "  clean_data <- extract_and_validate(study_results)\n",
    "  \n",
    "  # 2. Descriptive analysis\n",
    "  descriptive_results <- conduct_descriptive_analysis(clean_data)\n",
    "  \n",
    "  # 3. Psychometric analysis\n",
    "  psychometric_results <- conduct_psychometric_analysis(clean_data)\n",
    "  \n",
    "  # 4. Adaptive testing efficiency\n",
    "  efficiency_results <- analyze_adaptive_efficiency(clean_data)\n",
    "  \n",
    "  # 5. Advanced analysis based on goals\n",
    "  advanced_results <- conduct_advanced_analysis(\n",
    "    clean_data, \n",
    "    goals = c('", paste(analysis_goals %||% "general", collapse = "', '"), "')\n",
    "  )\n",
    "  \n",
    "  # 6. Generate comprehensive report\n",
    "  report <- generate_publication_report(\n",
    "    descriptive = descriptive_results,\n",
    "    psychometric = psychometric_results,\n",
    "    efficiency = efficiency_results,\n",
    "    advanced = advanced_results\n",
    "  )\n",
    "  \n",
    "  return(report)\n",
    "}\n",
    "\n",
    "# Execute analysis\n",
    "analysis_results <- analyze_study_results(your_study_results)\n",
    "```\n\n",
    
    "## DETAILED ANALYSIS COMPONENTS\n",
    
    "### 1. Descriptive Analysis\n",
    "```r\n",
    "conduct_descriptive_analysis <- function(data) {\n",
    "  list(\n",
    "    sample_characteristics = summarize_participants(data),\n",
    "    response_patterns = analyze_response_patterns(data),\n",
    "    missing_data = assess_missing_data(data),\n",
    "    test_length = analyze_test_length_distribution(data),\n",
    "    completion_rates = calculate_completion_rates(data)\n",
    "  )\n",
    "}\n",
    "```\n\n",
    
    "### 2. Psychometric Analysis\n",
    "```r\n",
    "conduct_psychometric_analysis <- function(data) {\n",
    "  list(\n",
    "    ability_estimates = estimate_final_abilities(data),\n",
    "    reliability = calculate_reliability(data),\n",
    "    validity = assess_validity(data),\n",
    "    model_fit = evaluate_model_fit(data),\n",
    "    item_analysis = conduct_item_analysis(data)\n",
    "  )\n",
    "}\n",
    "```\n\n",
    
    "### 3. Visualization Suite\n",
    "```r\n",
    "create_analysis_plots <- function(results) {\n",
    "  plots <- list(\n",
    "    ability_distribution = plot_ability_distribution(results),\n",
    "    test_length_efficiency = plot_test_length_vs_precision(results),\n",
    "    item_information = plot_item_information_curves(results),\n",
    "    response_patterns = plot_response_patterns(results),\n",
    "    convergence = plot_convergence_diagnostics(results)\n",
    "  )\n",
    "  return(plots)\n",
    "}\n",
    "```\n\n",
    
    "## PUBLICATION-READY OUTPUTS\n",
    "- APA-formatted tables\n",
    "- High-resolution figures (300 DPI)\n",
    "- Complete methodology section\n",
    "- Results with effect sizes and confidence intervals\n",
    "- Reproducible analysis scripts\n",
    "- Interactive HTML reports\n\n",
    
    "## QUALITY ASSURANCE\n",
    "```r\n",
    "# Validate all results\n",
    "validate_analysis <- function(results) {\n",
    "  checks <- list(\n",
    "    data_integrity = check_data_integrity(results),\n",
    "    statistical_assumptions = check_assumptions(results),\n",
    "    reproducibility = test_reproducibility(results),\n",
    "    reporting_completeness = check_reporting_standards(results)\n",
    "  )\n",
    "  return(checks)\n",
    "}\n",
    "```\n\n",
    
    "Generate COMPLETE, EXECUTABLE analysis code with ALL components included."
  )
  
  return(prompt)
}

# Helper functions for optimal parameter selection
get_optimal_model <- function(study_type) {
  models <- list(
    "personality" = "GRM",
    "cognitive" = "2PL",
    "clinical" = "GRM",
    "educational" = "2PL",
    "organizational" = "GRM"
  )
  return(models[[study_type]] %||% "GRM")
}

get_min_items <- function(study_type, constraints) {
  mins <- list(
    "personality" = 10,
    "cognitive" = 15,
    "clinical" = 20,
    "educational" = 12,
    "organizational" = 8
  )
  return(mins[[study_type]] %||% 10)
}

get_max_items <- function(study_type, constraints) {
  maxs <- list(
    "personality" = 30,
    "cognitive" = 50,
    "clinical" = 60,
    "educational" = 40,
    "organizational" = 25
  )
  return(maxs[[study_type]] %||% 30)
}

get_optimal_sem <- function(study_type, constraints) {
  sems <- list(
    "personality" = 0.3,
    "cognitive" = 0.25,
    "clinical" = 0.2,
    "educational" = 0.25,
    "organizational" = 0.35
  )
  return(sems[[study_type]] %||% 0.3)
}

get_optimal_criteria <- function(study_type) {
  criteria <- list(
    "personality" = "MFI",
    "cognitive" = "MI",
    "clinical" = "MFI",
    "educational" = "MI",
    "organizational" = "WEIGHTED"
  )
  return(criteria[[study_type]] %||% "MFI")
}

get_theta_prior <- function(study_type, population) {
  priors <- list(
    "personality" = "0, 1",
    "cognitive" = "0, 1.5",
    "clinical" = "0, 1.2",
    "educational" = "0, 1.5",
    "organizational" = "0, 0.8"
  )
  return(priors[[study_type]] %||% "0, 1")
}

get_stopping_rule <- function(study_type, constraints) {
  rules <- list(
    "personality" = "sem <= 0.3 || items_administered >= 25",
    "cognitive" = "sem <= 0.25 || items_administered >= 40",
    "clinical" = "sem <= 0.2 || items_administered >= 50",
    "educational" = "sem <= 0.25 || items_administered >= 35",
    "organizational" = "sem <= 0.35 || items_administered >= 20"
  )
  return(rules[[study_type]] %||% "sem <= 0.3")
}

get_adaptive_start <- function(study_type) {
  starts <- list(
    "personality" = 3,
    "cognitive" = 5,
    "clinical" = 5,
    "educational" = 4,
    "organizational" = 2
  )
  return(starts[[study_type]] %||% 3)
}

get_optimal_theme <- function(study_type, population) {
  themes <- list(
    "personality" = "professional",
    "cognitive" = "accessible-blue",
    "clinical" = "high-contrast",
    "educational" = "light",
    "organizational" = "professional"
  )
  return(themes[[study_type]] %||% "professional")
}

get_demographics_config <- function(study_type, population) {
  configs <- list(
    "personality" = "c('age', 'gender', 'education', 'occupation')",
    "cognitive" = "c('age', 'gender', 'education', 'handedness')",
    "clinical" = "c('age', 'gender', 'education', 'clinical_history')",
    "educational" = "c('age', 'gender', 'education', 'grade_level')",
    "organizational" = "c('age', 'gender', 'education', 'job_role', 'experience')"
  )
  return(configs[[study_type]] %||% "c('age', 'gender', 'education')")
}

get_input_types <- function(study_type) {
  types <- list(
    "personality" = "list(age = 'numeric', gender = 'select', education = 'select', occupation = 'text')",
    "cognitive" = "list(age = 'numeric', gender = 'select', education = 'select', handedness = 'select')",
    "clinical" = "list(age = 'numeric', gender = 'select', education = 'select', clinical_history = 'textarea')",
    "educational" = "list(age = 'numeric', gender = 'select', education = 'select', grade_level = 'select')",
    "organizational" = "list(age = 'numeric', gender = 'select', education = 'select', job_role = 'select', experience = 'select')"
  )
  return(types[[study_type]] %||% "list(age = 'numeric', gender = 'select', education = 'select')")
}

get_validation_function <- function(study_type) {
  return("function(response, item) { validate_response_range(response, item, min = 1, max = 5) }")
}

get_initialization_method <- function(study_type) {
  methods <- list(
    "personality" = "marginal",
    "cognitive" = "jml",
    "clinical" = "marginal",
    "educational" = "jml",
    "organizational" = "marginal"
  )
  return(methods[[study_type]] %||% "marginal")
}

get_deployment_platform <- function(study_type, constraints) {
  platforms <- list(
    "personality" = "shinyapps.io",
    "cognitive" = "university_server",
    "clinical" = "secure_server",
    "educational" = "shinyapps.io",
    "organizational" = "corporate_server"
  )
  return(platforms[[study_type]] %||% "shinyapps.io")
}

get_security_config <- function(study_type, constraints) {
  configs <- list(
    "personality" = "list(https = TRUE, authentication = 'basic', encryption = 'AES256')",
    "cognitive" = "list(https = TRUE, authentication = 'university_sso', encryption = 'AES256')",
    "clinical" = "list(https = TRUE, authentication = 'multi_factor', encryption = 'AES256', hipaa_compliant = TRUE)",
    "educational" = "list(https = TRUE, authentication = 'basic', encryption = 'AES256')",
    "organizational" = "list(https = TRUE, authentication = 'corporate_sso', encryption = 'AES256')"
  )
  return(configs[[study_type]] %||% "list(https = TRUE, authentication = 'basic', encryption = 'AES256')")
}

get_performance_config <- function(study_type) {
  configs <- list(
    "personality" = "list(max_connections = 100, timeout = 1800, memory_limit = '2GB')",
    "cognitive" = "list(max_connections = 50, timeout = 3600, memory_limit = '4GB')",
    "clinical" = "list(max_connections = 25, timeout = 2700, memory_limit = '8GB')",
    "educational" = "list(max_connections = 200, timeout = 1800, memory_limit = '2GB')",
    "organizational" = "list(max_connections = 75, timeout = 1800, memory_limit = '4GB')"
  )
  return(configs[[study_type]] %||% "list(max_connections = 100, timeout = 1800, memory_limit = '2GB')")
}

get_monitoring_setup <- function(study_type) {
  setups <- list(
    "personality" = "list(logging = TRUE, metrics = c('response_time', 'completion_rate', 'dropout_rate'))",
    "cognitive" = "list(logging = TRUE, metrics = c('response_time', 'completion_rate', 'accuracy'))",
    "clinical" = "list(logging = TRUE, metrics = c('response_time', 'completion_rate', 'data_quality'))",
    "educational" = "list(logging = TRUE, metrics = c('response_time', 'completion_rate', 'engagement'))",
    "organizational" = "list(logging = TRUE, metrics = c('response_time', 'completion_rate', 'satisfaction'))"
  )
  return(setups[[study_type]] %||% "list(logging = TRUE, metrics = c('response_time', 'completion_rate'))")
}

get_pre_launch_checks <- function(study_type) {
  checks <- list(
    "personality" = "c('parameter_validation', 'simulation_testing', 'pilot_study')",
    "cognitive" = "c('parameter_validation', 'simulation_testing', 'pilot_study', 'cognitive_interview')",
    "clinical" = "c('parameter_validation', 'simulation_testing', 'clinical_review', 'ethics_check')",
    "educational" = "c('parameter_validation', 'simulation_testing', 'pilot_study', 'teacher_review')",
    "organizational" = "c('parameter_validation', 'simulation_testing', 'pilot_study', 'hr_review')"
  )
  return(checks[[study_type]] %||% "c('parameter_validation', 'simulation_testing')")
}

get_monitoring_config <- function(study_type) {
  configs <- list(
    "personality" = "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE)",
    "cognitive" = "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE, proctoring = TRUE)",
    "clinical" = "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE, clinical_monitoring = TRUE)",
    "educational" = "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE, progress_tracking = TRUE)",
    "organizational" = "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE, performance_tracking = TRUE)"
  )
  return(configs[[study_type]] %||% "list(real_time = TRUE, alerts = TRUE, dashboard = TRUE)")
}

get_data_validation <- function(study_type) {
  validations <- list(
    "personality" = "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE)",
    "cognitive" = "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE, response_time_checks = TRUE)",
    "clinical" = "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE, clinical_validity = TRUE)",
    "educational" = "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE, educational_validity = TRUE)",
    "organizational" = "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE, job_relatedness = TRUE)"
  )
  return(validations[[study_type]] %||% "list(completeness = TRUE, consistency = TRUE, range_checks = TRUE)")
}

get_backup_strategy <- function(study_type) {
  strategies <- list(
    "personality" = "list(frequency = 'daily', retention = '30_days', encryption = TRUE)",
    "cognitive" = "list(frequency = 'daily', retention = '90_days', encryption = TRUE)",
    "clinical" = "list(frequency = 'hourly', retention = '7_years', encryption = TRUE, hipaa_compliant = TRUE)",
    "educational" = "list(frequency = 'daily', retention = '1_year', encryption = TRUE)",
    "organizational" = "list(frequency = 'daily', retention = '3_years', encryption = TRUE)"
  )
  return(strategies[[study_type]] %||% "list(frequency = 'daily', retention = '30_days', encryption = TRUE)")
}

# Utility function for safe parameter access
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0) y else x
