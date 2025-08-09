#' Generate LLM Prompts for Advanced Package Customization
#'
#' @description
#' Provides comprehensive LLM assistance prompts for various aspects of inrep package
#' customization, including study configuration, item bank optimization, demographic
#' questionnaires, validation procedures, and advanced UI customization.
#'
#' @param component Character string specifying which component to generate prompts for.
#'   Options: "study_config", "item_bank", "demographics", "validation", 
#'   "ui_theme", "multilingual", "analysis", "deployment", "documentation"
#' @param context List containing specific context information for the prompt.
#'   Structure varies by component type.
#' @param study_type Character string specifying the type of study.
#'   Options: "personality", "cognitive", "clinical", "educational", "organizational"
#' @param output_format Character string specifying output format.
#'   Options: "console", "file", "clipboard"
#' @param include_examples Logical indicating whether to include example configurations
#'   in the prompt. Default is TRUE.
#' @param verbose Logical indicating whether to display detailed information.
#'   Default is TRUE.
#'
#' @return Character string containing the LLM prompt, or invisibly returns the prompt
#'   if output_format is "file" or "clipboard".
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Generate study configuration prompt for personality assessment
#' generate_llm_prompt(
#'   component = "study_config",
#'   study_type = "personality",
#'   context = list(
#'     target_population = "University students",
#'     duration = "15-20 minutes",
#'     research_questions = c("Big Five traits", "Academic performance")
#'   )
#' )
#' 
#' # Generate item bank optimization prompt
#' generate_llm_prompt(
#'   component = "item_bank",
#'   study_type = "cognitive",
#'   context = list(
#'     domain = "Mathematical reasoning",
#'     difficulty_range = c(-2, 2),
#'     num_items = 50
#'   )
#' )
#' }
generate_llm_prompt <- function(component = "study_config",
                               context = list(),
                               study_type = "personality",
                               output_format = "console",
                               include_examples = TRUE,
                               verbose = TRUE) {
  
  # Validate inputs
  valid_components <- c("study_config", "item_bank", "demographics", "validation", 
                       "ui_theme", "multilingual", "analysis", "deployment", "documentation")
  valid_study_types <- c("personality", "cognitive", "clinical", "educational", "organizational")
  valid_formats <- c("console", "file", "clipboard")
  
  if (!component %in% valid_components) {
    stop("Invalid component. Must be one of: ", paste(valid_components, collapse = ", "))
  }
  
  if (!study_type %in% valid_study_types) {
    stop("Invalid study_type. Must be one of: ", paste(valid_study_types, collapse = ", "))
  }
  
  if (!output_format %in% valid_formats) {
    stop("Invalid output_format. Must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  # Generate component-specific prompt
  prompt <- switch(component,
    "study_config" = generate_study_config_prompt(context, study_type, include_examples),
    "item_bank" = generate_item_bank_prompt(context, study_type, include_examples),
    "demographics" = generate_demographics_prompt(context, study_type, include_examples),
    "validation" = generate_validation_prompt(context, study_type, include_examples),
    "ui_theme" = generate_ui_theme_prompt(context, study_type, include_examples),
    "multilingual" = generate_multilingual_prompt(context, study_type, include_examples),
    "analysis" = generate_analysis_prompt(context, study_type, include_examples),
    "deployment" = generate_deployment_prompt(context, study_type, include_examples),
    "documentation" = generate_documentation_prompt(context, study_type, include_examples)
  )
  
  # Handle output format
  if (output_format == "console") {
    if (verbose) {
      message("=" %r% 80)
      message("LLM PROMPT FOR ", toupper(component), " CUSTOMIZATION")
      message("=" %r% 80)
      message("")
    }
    message(prompt)
    message("")
    message("")
    if (verbose) {
      message("=" %r% 80)
      message("Copy the above prompt to your preferred LLM (ChatGPT, Claude, etc.)")
      message("=" %r% 80)
    }
    return(invisible(prompt))
  } else if (output_format == "file") {
    filename <- paste0("inrep_", component, "_prompt_", Sys.Date(), ".txt")
    writeLines(prompt, filename)
    if (verbose) message("Prompt saved to: ", filename)
    return(invisible(prompt))
  } else if (output_format == "clipboard") {
    if (requireNamespace("clipr", quietly = TRUE)) {
      clipr::write_clip(prompt)
      if (verbose) message("Prompt copied to clipboard!")
    } else {
      message("clipr package not available. Displaying prompt instead:")
      message("")
      message(prompt)
    }
    return(invisible(prompt))
  }
}

# Helper function for string repetition
`%r%` <- function(string, times) {
  paste(rep(string, times), collapse = "")
}

#' Generate Study Configuration Optimization Prompt
#' @noRd
generate_study_config_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT PSYCHOMETRIC STUDY CONFIGURATION\n\n",
    "You are an expert psychometrician and R programmer specializing in adaptive testing with Item Response Theory (IRT). ",
    "I need help optimizing a study configuration for the inrep R package, which uses TAM for all psychometric computations.\n\n",
    
    "## STUDY CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", context$target_population %||% "Not specified", "\n",
    "- Duration: ", context$duration %||% "Not specified", "\n",
    "- Research Goals: ", paste(context$research_questions %||% "Not specified", collapse = ", "), "\n",
    "- Sample Size: ", context$sample_size %||% "Not specified", "\n\n",
    
    "## TASK\n",
    "Please optimize the following create_study_config() parameters for maximum psychometric validity and user experience:\n\n",
    
    "### Core IRT Parameters\n",
    "- model: Choose optimal IRT model (1PL, 2PL, 3PL, GRM) based on study type\n",
    "- min_items/max_items: Balance precision vs participant burden\n",
    "- min_SEM: Set appropriate standard error threshold\n",
    "- criteria: Select best item selection method (MI, MFI, WEIGHTED, RANDOM)\n",
    "- theta_prior: Adjust prior distribution for target population\n\n",
    
    "### Adaptive Testing Optimization\n",
    "- stopping_rule: Custom stopping criteria beyond SEM\n",
    "- adaptive_start: When to begin adaptive selection\n",
    "- fixed_items: Essential items that must be administered\n",
    "- item_groups: Content balancing across domains\n\n",
    
    "### User Experience\n",
    "- theme: Professional appearance for research context\n",
    "- language: Appropriate for target population\n",
    "- demographics: Essential vs optional demographic data\n",
    "- max_session_duration: Realistic time limits\n",
    "- progress_style: Visual feedback approach\n\n",
    
    "### Quality Control\n",
    "- response_validation_fun: Custom response validation\n",
    "- max_response_time: Rapid response detection\n",
    "- session_save: Data integrity considerations\n",
    "- parallel_computation: Performance optimization\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete create_study_config() function call with optimized parameters\n",
      "2. Justification for each parameter choice based on psychometric principles\n",
      "3. Potential modifications for different subpopulations\n",
      "4. Quality assurance recommendations\n",
      "5. Expected outcomes and performance metrics\n\n",
      
      "## CURRENT BASIC CONFIGURATION\n",
      "```r\n",
      "config <- create_study_config(\n",
      "  name = 'Basic Assessment',\n",
      "  model = 'GRM',\n",
      "  min_items = 5,\n",
      "  max_items = 20,\n",
      "  min_SEM = 0.3\n",
      ")\n",
      "```\n\n",
      
      "Please provide an enhanced configuration with detailed explanations for each parameter choice."
    )
  }
  
  return(prompt)
}

#' Generate Item Bank Optimization Prompt
#' @noRd
generate_item_bank_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT ITEM BANK OPTIMIZATION FOR IRT\n\n",
    "You are an expert psychometrician specializing in Item Response Theory and test development. ",
    "I need help optimizing an item bank for the inrep R package (which uses TAM for psychometric computations).\n\n",
    
    "## ITEM BANK CONTEXT\n",
    "- Domain: ", context$domain %||% study_type, "\n",
    "- Current Items: ", context$num_items %||% "Not specified", "\n",
    "- Difficulty Range: ", paste(context$difficulty_range %||% c("Not specified"), collapse = " to "), "\n",
    "- Model: ", context$model %||% "GRM", "\n",
    "- Target Precision: ", context$target_sem %||% "0.3", "\n\n",
    
    "## OPTIMIZATION TASKS\n\n",
    
    "### 1. Item Parameter Analysis\n",
    "- Analyze discrimination parameters (a) for optimal range\n",
    "- Evaluate difficulty parameters (b) for population coverage\n",
    "- Check threshold parameters (b1-b4) for GRM items\n",
    "- Identify parameter optimization opportunities\n\n",
    
    "### 2. Content Coverage\n",
    "- Ensure adequate representation across ability spectrum\n",
    "- Balance content domains if applicable\n",
    "- Identify gaps in difficulty coverage\n",
    "- Recommend item development priorities\n\n",
    
    "### 3. Adaptive Testing Efficiency\n",
    "- Optimize item information curves\n",
    "- Evaluate item selection efficiency\n",
    "- Minimize test length while maintaining precision\n",
    "- Handle unknown parameters strategically\n\n",
    
    "### 4. Quality Control\n",
    "- Validate item parameter constraints\n",
    "- Check for psychometric anomalies\n",
    "- Ensure model appropriateness\n",
    "- Plan calibration and validation studies\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete item bank validation strategy using validate_item_bank()\n",
      "2. Parameter optimization recommendations\n",
      "3. Unknown parameter handling strategy using initialize_unknown_parameters()\n",
      "4. Content balancing approach\n",
      "5. Quality metrics and monitoring plan\n\n",
      
      "## SAMPLE ITEM BANK STRUCTURE\n",
      "```r\n",
      "item_bank <- data.frame(\n",
      "  item_id = paste0('item_', 1:20),\n",
      "  content = paste('Sample item', 1:20),\n",
      "  domain = rep(c('Factor1', 'Factor2'), each = 10),\n",
      "  a = runif(20, 0.8, 2.5),\n",
      "  b1 = rnorm(20, -1.5, 0.5),\n",
      "  b2 = rnorm(20, -0.5, 0.5),\n",
      "  b3 = rnorm(20, 0.5, 0.5),\n",
      "  b4 = rnorm(20, 1.5, 0.5)\n",
      ")\n",
      "```\n\n",
      
      "Please provide optimization recommendations with specific R code."
    )
  }
  
  return(prompt)
}

#' Generate Demographics Configuration Prompt
#' @noRd
generate_demographics_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT DEMOGRAPHIC QUESTIONNAIRE DESIGN\n\n",
    "You are an expert in survey methodology and psychological assessment. ",
    "I need help designing an optimal demographic questionnaire for the inrep R package.\n\n",
    
    "## STUDY CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Population: ", context$target_population %||% "Not specified", "\n",
    "- Research Goals: ", paste(context$research_questions %||% "Not specified", collapse = ", "), "\n",
    "- Data Privacy Level: ", context$privacy_level %||% "Standard academic", "\n",
    "- Cultural Context: ", context$cultural_context %||% "Not specified", "\n\n",
    
    "## DESIGN CONSIDERATIONS\n\n",
    
    "### 1. Essential vs Optional Demographics\n",
    "- Determine which demographics are crucial for analysis\n",
    "- Balance data needs with participant burden\n",
    "- Consider ethical and privacy implications\n",
    "- Plan for missing data handling\n\n",
    
    "### 2. Question Design\n",
    "- Optimize question wording for clarity\n",
    "- Choose appropriate input types (text, select, numeric)\n",
    "- Design inclusive response options\n",
    "- Consider cultural sensitivity\n\n",
    
    "### 3. Data Quality\n",
    "- Implement validation rules\n",
    "- Handle sensitive questions appropriately\n",
    "- Plan for data verification\n",
    "- Ensure GDPR/privacy compliance\n\n",
    
    "### 4. User Experience\n",
    "- Minimize demographic fatigue\n",
    "- Organize questions logically\n",
    "- Provide clear instructions\n",
    "- Optimize for accessibility\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete demographic_configs list for create_study_config()\n",
      "2. Optimized question wording and response options\n",
      "3. Input validation strategies\n",
      "4. Privacy and ethics considerations\n",
      "5. Cultural adaptation recommendations\n\n",
      
      "## CURRENT BASIC SETUP\n",
      "```r\n",
      "demographics = c('Age', 'Gender', 'Education'),\n",
      "input_types = list(\n",
      "  Age = 'numeric',\n",
      "  Gender = 'select',\n",
      "  Education = 'select'\n",
      ")\n",
      "```\n\n",
      
      "Please provide an enhanced demographic configuration with detailed justifications."
    )
  }
  
  return(prompt)
}

#' Generate Validation Strategy Prompt
#' @noRd
generate_validation_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT PSYCHOMETRIC VALIDATION STRATEGY\n\n",
    "You are an expert psychometrician specializing in test validation and quality assurance. ",
    "I need help developing a comprehensive validation strategy for the inrep R package.\n\n",
    
    "## VALIDATION CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Validation Phase: ", context$validation_phase %||% "Pre-launch", "\n",
    "- Sample Size: ", context$sample_size %||% "Not specified", "\n",
    "- Timeline: ", context$timeline %||% "Not specified", "\n",
    "- Resources: ", context$resources %||% "Standard academic", "\n\n",
    
    "## VALIDATION COMPONENTS\n\n",
    
    "### 1. Item Bank Validation\n",
    "- Parameter accuracy verification\n",
    "- Model fit assessment\n",
    "- Content validity evaluation\n",
    "- Cross-validation procedures\n\n",
    
    "### 2. Adaptive Algorithm Testing\n",
    "- Item selection efficiency\n",
    "- Stopping rule effectiveness\n",
    "- Ability estimation accuracy\n",
    "- Bias detection and mitigation\n\n",
    
    "### 3. Technical Validation\n",
    "- Cross-platform compatibility\n",
    "- User interface usability\n",
    "- Data integrity verification\n",
    "- Performance benchmarking\n\n",
    
    "### 4. Ethical and Legal Compliance\n",
    "- Privacy protection verification\n",
    "- Accessibility compliance\n",
    "- Informed consent procedures\n",
    "- Data security assessment\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete validation protocol using validate_item_bank() and related functions\n",
      "2. Statistical validation procedures\n",
      "3. Quality metrics and benchmarks\n",
      "4. Risk assessment and mitigation strategies\n",
      "5. Documentation and reporting plan\n\n",
      
      "## VALIDATION TOOLS AVAILABLE\n",
      "```r\n",
      "# Item bank validation\n",
      "validation_result <- validate_item_bank(item_bank, model = 'GRM')\n",
      "\n",
      "# Unknown parameter detection\n",
      "unknown_patterns <- detect_unknown_parameters(item_bank)\n",
      "\n",
      "# Parameter initialization testing\n",
      "initialized <- initialize_unknown_parameters(item_bank, model = 'GRM')\n",
      "```\n\n",
      
      "Please provide a comprehensive validation strategy with specific R implementations."
    )
  }
  
  return(prompt)
}

#' Generate UI Theme Customization Prompt
#' @noRd
generate_ui_theme_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT UI THEME DESIGN FOR PSYCHOLOGICAL ASSESSMENTS\n\n",
    "You are an expert in UI/UX design specializing in psychological assessment interfaces. ",
    "I need help creating optimal themes for the inrep R package that enhance user experience while maintaining scientific rigor.\n\n",
    
    "## DESIGN CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", context$target_population %||% "Not specified", "\n",
    "- Assessment Duration: ", context$duration %||% "Not specified", "\n",
    "- Institutional Branding: ", context$branding %||% "Academic", "\n",
    "- Accessibility Requirements: ", context$accessibility %||% "WCAG 2.1 AA", "\n\n",
    
    "## THEME DESIGN PRINCIPLES\n\n",
    
    "### 1. Psychological Considerations\n",
    "- Color psychology for assessment contexts\n",
    "- Cognitive load minimization\n",
    "- Attention and focus optimization\n",
    "- Stress reduction through design\n\n",
    
    "### 2. Professional Aesthetics\n",
    "- Academic and research credibility\n",
    "- Institutional alignment\n",
    "- Cross-cultural appropriateness\n",
    "- Timeless design principles\n\n",
    
    "### 3. Functional Requirements\n",
    "- Readability and contrast optimization\n",
    "- Mobile and desktop compatibility\n",
    "- Accessibility compliance\n",
    "- Performance considerations\n\n",
    
    "### 4. Customization Options\n",
    "- Flexible color schemes\n",
    "- Typography choices\n",
    "- Logo and branding integration\n",
    "- Progressive enhancement\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete theme configuration using scraped website assets\n",
      "2. Color palette recommendations with psychological rationale\n",
      "3. Typography and layout optimization\n",
      "4. Custom CSS for enhanced functionality\n",
      "5. Accessibility and usability enhancements\n\n",
      
      "## THEME TOOLS AVAILABLE\n",
      "```r\n",
      "# Scrape website for theme inspiration\n",
      "scraped_themes <- scrape_website_ui('https://institution.edu/')\n",
      "\n",
      "# Build custom UI\n",
      "ui <- build_study_ui(\n",
      "  study_config = config,\n",
      "  theme_config = scraped_themes$themes[[1]]\n",
      ")\n",
      "\n",
      "# Validate built-in themes\n",
      "available_themes <- get_builtin_themes()\n",
      "```\n\n",
      
      "Please provide comprehensive theme customization with detailed design rationale."
    )
  }
  
  return(prompt)
}

#' Generate Multilingual Configuration Prompt
#' @noRd
generate_multilingual_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT MULTILINGUAL ASSESSMENT DESIGN\n\n",
    "You are an expert in cross-cultural psychology and multilingual assessment. ",
    "I need help optimizing multilingual support for the inrep R package.\n\n",
    
    "## MULTILINGUAL CONTEXT\n",
    "- Primary Language: ", context$primary_language %||% "English", "\n",
    "- Target Languages: ", paste(context$target_languages %||% "Not specified", collapse = ", "), "\n",
    "- Cultural Groups: ", paste(context$cultural_groups %||% "Not specified", collapse = ", "), "\n",
    "- Translation Resources: ", context$translation_resources %||% "Not specified", "\n",
    "- Validation Requirements: ", context$validation_requirements %||% "Standard", "\n\n",
    
    "## MULTILINGUAL CONSIDERATIONS\n\n",
    
    "### 1. Translation Strategy\n",
    "- Professional vs automated translation\n",
    "- Cultural adaptation requirements\n",
    "- Back-translation validation\n",
    "- Linguistic equivalence testing\n\n",
    
    "### 2. Cross-Cultural Validity\n",
    "- Item functioning across cultures\n",
    "- Response scale equivalence\n",
    "- Cultural bias detection\n",
    "- Measurement invariance testing\n\n",
    
    "### 3. Technical Implementation\n",
    "- UTF-8 encoding considerations\n",
    "- Right-to-left language support\n",
    "- Font and character rendering\n",
    "- Dynamic language switching\n\n",
    
    "### 4. User Experience\n",
    "- Language selection interface\n",
    "- Cultural UI preferences\n",
    "- Help and instruction clarity\n",
    "- Error message localization\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete multilingual configuration strategy\n",
      "2. Translation quality assurance procedures\n",
      "3. Cross-cultural validation plan\n",
      "4. Technical implementation recommendations\n",
      "5. Cultural adaptation guidelines\n\n",
      
      "## MULTILINGUAL SETUP\n",
      "```r\n",
      "config <- create_study_config(\n",
      "  language = 'en',\n",
      "  item_translations = list(\n",
      "    'de' = german_translations,\n",
      "    'es' = spanish_translations,\n",
      "    'fr' = french_translations\n",
      "  )\n",
      ")\n",
      "```\n\n",
      
      "Please provide comprehensive multilingual optimization with cultural considerations."
    )
  }
  
  return(prompt)
}

#' Generate Analysis Strategy Prompt
#' @noRd
generate_analysis_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT PSYCHOMETRIC ANALYSIS STRATEGY\n\n",
    "You are an expert psychometrician and data analyst specializing in IRT and adaptive testing. ",
    "I need help developing optimal analysis strategies for data collected with the inrep R package.\n\n",
    
    "## ANALYSIS CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Sample Size: ", context$sample_size %||% "Not specified", "\n",
    "- Research Questions: ", paste(context$research_questions %||% "Not specified", collapse = ", "), "\n",
    "- Data Structure: ", context$data_structure %||% "Adaptive testing", "\n",
    "- Analysis Timeline: ", context$timeline %||% "Not specified", "\n\n",
    
    "## ANALYSIS COMPONENTS\n\n",
    
    "### 1. Descriptive Analysis\n",
    "- Participant characteristic summaries\n",
    "- Response pattern analysis\n",
    "- Item administration frequencies\n",
    "- Missing data assessment\n\n",
    
    "### 2. Psychometric Analysis\n",
    "- Ability estimate distributions\n",
    "- Standard error analysis\n",
    "- Item information evaluation\n",
    "- Model fit assessment\n\n",
    
    "### 3. Adaptive Testing Efficiency\n",
    "- Test length optimization\n",
    "- Stopping rule effectiveness\n",
    "- Item selection efficiency\n",
    "- Precision vs burden trade-offs\n\n",
    
    "### 4. Validity and Reliability\n",
    "- Measurement precision analysis\n",
    "- Bias detection procedures\n",
    "- Cross-validation studies\n",
    "- Generalizability assessment\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete analysis pipeline using inrep and TAM functions\n",
      "2. Statistical procedures and R code\n",
      "3. Visualization and reporting strategies\n",
      "4. Quality control and validation checks\n",
      "5. Interpretation guidelines and benchmarks\n\n",
      
      "## ANALYSIS TOOLS\n",
      "```r\n",
      "# Ability estimation\n",
      "abilities <- estimate_ability(responses, item_bank, model = 'GRM')\n",
      "\n",
      "# Session data analysis\n",
      "session_data <- extract_session_data(study_results)\n",
      "\n",
      "# Performance metrics\n",
      "metrics <- calculate_efficiency_metrics(session_data)\n",
      "```\n\n",
      
      "Please provide comprehensive analysis strategy with specific implementations."
    )
  }
  
  return(prompt)
}

#' Generate Deployment Strategy Prompt
#' @noRd
generate_deployment_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT DEPLOYMENT STRATEGY FOR RESEARCH ASSESSMENTS\n\n",
    "You are an expert in research technology deployment and data management. ",
    "I need help developing optimal deployment strategies for the inrep R package.\n\n",
    
    "## DEPLOYMENT CONTEXT\n",
    "- Study Scale: ", context$study_scale %||% "Not specified", "\n",
    "- Participant Numbers: ", context$participant_numbers %||% "Not specified", "\n",
    "- Data Sensitivity: ", context$data_sensitivity %||% "Standard academic", "\n",
    "- Infrastructure: ", context$infrastructure %||% "University servers", "\n",
    "- Timeline: ", context$timeline %||% "Not specified", "\n\n",
    
    "## DEPLOYMENT CONSIDERATIONS\n\n",
    
    "### 1. Platform Selection\n",
    "- Local vs cloud deployment\n",
    "- Scalability requirements\n",
    "- Security and privacy needs\n",
    "- Cost and resource optimization\n\n",
    
    "### 2. Technical Architecture\n",
    "- Server configuration\n",
    "- Database design\n",
    "- Backup and recovery\n",
    "- Performance monitoring\n\n",
    
    "### 3. Data Management\n",
    "- Collection and storage\n",
    "- Privacy and security\n",
    "- Quality control procedures\n",
    "- Export and analysis workflows\n\n",
    
    "### 4. User Management\n",
    "- Participant recruitment\n",
    "- Access control\n",
    "- Support and troubleshooting\n",
    "- Progress monitoring\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete deployment strategy using launch_to_inrep_platform()\n",
      "2. Infrastructure recommendations\n",
      "3. Security and privacy implementation\n",
      "4. Quality assurance procedures\n",
      "5. Monitoring and maintenance plan\n\n",
      
      "## DEPLOYMENT OPTIONS\n",
      "```r\n",
      "# Professional platform deployment\n",
      "deployment <- launch_to_inrep_platform(\n",
      "  study_config = config,\n",
      "  item_bank = item_bank,\n",
      "  deployment_type = 'inrep_platform'\n",
      ")\n",
      "\n",
      "# Custom server deployment\n",
      "launch_study(config, item_bank, host = '0.0.0.0', port = 3838)\n",
      "```\n\n",
      
      "Please provide comprehensive deployment strategy with technical specifications."
    )
  }
  
  return(prompt)
}

#' Generate Documentation Strategy Prompt
#' @noRd
generate_documentation_prompt <- function(context, study_type, include_examples) {
  prompt <- paste0(
    "# EXPERT DOCUMENTATION STRATEGY FOR RESEARCH STUDIES\n\n",
    "You are an expert in research documentation and scientific communication. ",
    "I need help creating comprehensive documentation for studies using the inrep R package.\n\n",
    
    "## DOCUMENTATION CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Target Audience: ", paste(context$target_audience %||% "Researchers", collapse = ", "), "\n",
    "- Publication Goals: ", paste(context$publication_goals %||% "Academic journals", collapse = ", "), "\n",
    "- Compliance Requirements: ", context$compliance %||% "IRB/Ethics approval", "\n",
    "- Documentation Level: ", context$documentation_level %||% "Comprehensive", "\n\n",
    
    "## DOCUMENTATION COMPONENTS\n\n",
    
    "### 1. Study Protocol Documentation\n",
    "- Methodology description\n",
    "- Procedure documentation\n",
    "- Configuration parameters\n",
    "- Quality control measures\n\n",
    
    "### 2. Technical Documentation\n",
    "- Software versions and dependencies\n",
    "- Analysis code and procedures\n",
    "- Data processing workflows\n",
    "- Reproducibility guidelines\n\n",
    
    "### 3. Participant Documentation\n",
    "- Informed consent procedures\n",
    "- Instructions and briefing\n",
    "- Privacy and data use\n",
    "- Contact and support information\n\n",
    
    "### 4. Results Documentation\n",
    "- Data structure description\n",
    "- Analysis procedures\n",
    "- Interpretation guidelines\n",
    "- Reporting standards\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE\n",
      "1. Complete documentation template\n",
      "2. Reproducibility checklist\n",
      "3. Participant communication materials\n",
      "4. Technical specification documentation\n",
      "5. Publication-ready methodology section\n\n",
      
      "## DOCUMENTATION TOOLS\n",
      "```r\n",
      "# Generate study documentation\n",
      "documentation <- generate_study_documentation(config, item_bank)\n",
      "\n",
      "# Export configuration\n",
      "export_study_config(config, format = 'markdown')\n",
      "\n",
      "# Session information\n",
      "sessionInfo()\n",
      "```\n\n",
      
      "Please provide comprehensive documentation strategy with templates and examples."
    )
  }
  
  return(prompt)
}

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
#' @examples
#' \dontrun{
#' # Enable LLM assistance with console output
#' enable_llm_assistance(TRUE)
#'
#' # Enable specific prompt types only
#' enable_llm_assistance(
#'   enable = TRUE,
#'   prompt_types = c("validation", "configuration")
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
      message("LLM Assistance ENABLED for inrep package")
      message("Output format: ", output_format)
      message("Prompt types: ", paste(prompt_types, collapse = ", "))
    } else {
      message("LLM Assistance DISABLED for inrep package")
    }
  }
  
  invisible(previous_setting)
}

#' Get Current LLM Assistance Settings
#'
#' @description
#' Returns the current LLM assistance configuration settings.
#'
#' @return Named list containing current LLM assistance settings.
#'
#' @export
#'
#' @examples
#' \dontrun{
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

# Check if LLM assistance is enabled for specific component
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

# Display LLM prompt based on current settings
display_llm_prompt <- function(prompt, component = "general") {
  if (!is_llm_assistance_enabled(component)) {
    return(invisible(NULL))
  }
  
  output_format <- getOption("inrep.llm_output_format", "console")
  verbose <- getOption("inrep.llm_verbose", TRUE)
  
  if (output_format == "console") {
    if (verbose) {
      message("")
      message(paste(rep("=", 60), collapse = ""))
      message("LLM ASSISTANCE: ", toupper(component), " OPTIMIZATION")
      message(paste(rep("=", 60), collapse = ""))
      message("Copy the following prompt to ChatGPT, Claude, or your preferred LLM:")
      message("")
    }
    message(prompt)
    if (verbose) {
      message("")
      message(paste(rep("=", 60), collapse = ""))
      message("")
    }
  } else if (output_format == "file") {
    filename <- paste0("inrep_", component, "_prompt_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
    writeLines(prompt, filename)
    if (verbose) {
      message("LLM prompt saved to: ", filename)
    }
  }
  
  invisible(prompt)
  prompt <- paste0("# LLM Assistance Prompt\n",
                   "Component: ", component, "\n",
                   "Study Type: ", study_type, "\n\n")
  if (!is.null(context) && length(context) > 0) {
    prompt <- paste0(prompt, "## Context Information\n")
    for (name in names(context)) {
      prompt <- paste0(prompt, "- ", name, ": ", context[[name]], "\n")
    }
    prompt <- paste0(prompt, "\n")
  }
  if (include_examples) {
    prompt <- paste0(prompt,
      "## PROVIDE COMPREHENSIVE RECOMMENDATIONS\n",
      "1. **Infrastructure Architecture**: Complete deployment architecture with diagrams\n",
      "2. **Security Implementation**: Specific security measures and configurations\n",
      "3. **Performance Optimization**: Technical optimizations for speed and reliability\n",
      "4. **Monitoring and Alerting**: Comprehensive monitoring strategy with tools\n",
      "5. **Quality Assurance**: Testing procedures and validation protocols\n",
      "6. **Documentation**: Deployment guides and operational procedures\n",
      "7. **Scaling Strategy**: Plans for handling increased user load\n",
      "8. **Compliance Framework**: Regulatory and ethical compliance procedures\n\n",
      "Please provide actionable recommendations with specific configuration examples, deployment scripts, and operational procedures."
    )
  }
  return(prompt)
}