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
#' @param llm_model Character string specifying the target LLM model for optimization.
#'   Options: "claude", "gpt4", "gemini", "generic". Default is "generic".
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
                               verbose = TRUE,
                               llm_model = "generic") {
  
  # Validate inputs
  valid_components <- c("study_config", "item_bank", "demographics", "validation", 
                       "ui_theme", "multilingual", "analysis", "deployment", "documentation")
  valid_study_types <- c("personality", "cognitive", "clinical", "educational", "organizational")
  valid_formats <- c("console", "file", "clipboard")
  valid_llm_models <- c("claude", "gpt4", "gemini", "generic")
  
  if (!component %in% valid_components) {
    stop("Invalid component. Must be one of: ", paste(valid_components, collapse = ", "))
  }
  
  if (!study_type %in% valid_study_types) {
    stop("Invalid study_type. Must be one of: ", paste(valid_study_types, collapse = ", "))
  }
  
  if (!output_format %in% valid_formats) {
    stop("Invalid output_format. Must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  if (!llm_model %in% valid_llm_models) {
    stop("Invalid llm_model. Must be one of: ", paste(valid_llm_models, collapse = ", "))
  }
  
  # Generate component-specific prompt with LLM model optimization
  prompt <- switch(component,
    "study_config" = generate_study_config_prompt(context, study_type, include_examples, llm_model),
    "item_bank" = generate_item_bank_prompt(context, study_type, include_examples, llm_model),
    "demographics" = generate_demographics_prompt(context, study_type, include_examples, llm_model),
    "validation" = generate_validation_prompt(context, study_type, include_examples, llm_model),
    "ui_theme" = generate_ui_theme_prompt(context, study_type, include_examples, llm_model),
    "multilingual" = generate_multilingual_prompt(context, study_type, include_examples, llm_model),
    "analysis" = generate_analysis_prompt(context, study_type, include_examples, llm_model),
    "deployment" = generate_deployment_prompt(context, study_type, include_examples, llm_model),
    "documentation" = generate_documentation_prompt(context, study_type, include_examples, llm_model)
  )
  
  # Add LLM model-specific instructions
  prompt <- add_llm_model_instructions(prompt, llm_model)
  
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
      message("")
      message("IMPORTANT: After getting the LLM response, use the provided R code")
      message("directly in your inrep package workflow!")
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

#' Add LLM Model-Specific Instructions to Prompts
#' @noRd
add_llm_model_instructions <- function(prompt, llm_model) {
  model_instructions <- switch(llm_model,
    "claude" = paste0(
      "\n\n## CLAUDE-SPECIFIC INSTRUCTIONS\n",
      "As Claude, you excel at structured reasoning and detailed analysis. Please:\n",
      "1. **Think step-by-step** through each psychometric decision\n",
      "2. **Provide comprehensive explanations** for each parameter choice\n",
      "3. **Use clear, academic language** appropriate for research contexts\n",
      "4. **Structure your response** with clear headings and bullet points\n",
      "5. **Include both theoretical justification** and practical implementation\n",
      "6. **Anticipate potential issues** and provide mitigation strategies\n",
      "7. **Format R code** with clear comments explaining each section\n",
      "8. **Provide multiple options** when appropriate, with pros/cons\n\n"
    ),
    "gpt4" = paste0(
      "\n\n## GPT-4 SPECIFIC INSTRUCTIONS\n",
      "As GPT-4, you excel at creative problem-solving and comprehensive analysis. Please:\n",
      "1. **Analyze the problem holistically** considering multiple perspectives\n",
      "2. **Provide innovative solutions** that go beyond standard approaches\n",
      "3. **Include practical examples** and real-world applications\n",
      "4. **Consider edge cases** and provide robust error handling\n",
      "5. **Structure your response** with clear sections and logical flow\n",
      "6. **Provide both simple and advanced** implementation options\n",
      "7. **Include performance considerations** and optimization tips\n",
      "8. **Format code professionally** with comprehensive documentation\n\n"
    ),
    "gemini" = paste0(
      "\n\n## GEMINI SPECIFIC INSTRUCTIONS\n",
      "As Gemini, you excel at multimodal thinking and systematic analysis. Please:\n",
      "1. **Break down complex problems** into manageable components\n",
      "2. **Provide systematic solutions** with clear implementation steps\n",
      "3. **Include validation strategies** for each recommendation\n",
      "4. **Consider scalability** and future expansion possibilities\n",
      "5. **Provide clear decision trees** for parameter selection\n",
      "6. **Include quality metrics** and success indicators\n",
      "7. **Format responses** with clear visual structure\n",
      "8. **Provide both theoretical and practical** perspectives\n\n"
    ),
    "generic" = paste0(
      "\n\n## GENERAL LLM INSTRUCTIONS\n",
      "Please provide a comprehensive, professional response that:\n",
      "1. **Follows the prompt structure** exactly as requested\n",
      "2. **Provides actionable recommendations** with specific R code\n",
      "3. **Includes clear explanations** for each parameter choice\n",
      "4. **Considers psychometric best practices** and research standards\n",
      "5. **Provides multiple options** when appropriate\n",
      "6. **Includes error handling** and validation strategies\n",
      "7. **Formats code professionally** with clear comments\n",
      "8. **Anticipates common issues** and provides solutions\n\n"
    )
  )
  
  # Add output format requirements
  output_requirements <- paste0(
    "## REQUIRED OUTPUT FORMAT\n",
    "Your response MUST include:\n",
    "1. **Executive Summary**: 2-3 sentence overview of recommendations\n",
    "2. **Detailed Analysis**: Step-by-step reasoning for each decision\n",
    "3. **Complete R Code**: Ready-to-use code blocks with all necessary functions\n",
    "4. **Parameter Justification**: Clear explanation for each parameter value\n",
    "5. **Quality Assurance**: Validation and testing procedures\n",
    "6. **Implementation Steps**: Ordered list of actions to take\n",
    "7. **Troubleshooting**: Common issues and solutions\n",
    "8. **Next Steps**: Recommendations for further optimization\n\n",
    
    "## CODE REQUIREMENTS\n",
    "- All R code must be **immediately executable** in the inrep package\n",
    "- Include **complete function calls** with all necessary parameters\n",
    "- Provide **clear variable names** and avoid hardcoded values\n",
    "- Include **error handling** and validation checks\n",
    "- Add **comprehensive comments** explaining each section\n",
    "- Ensure **reproducibility** with set.seed() when appropriate\n\n"
  )
  
  return(paste0(prompt, model_instructions, output_requirements))
}

#' Generate Study Configuration Optimization Prompt
#' @noRd
generate_study_config_prompt <- function(context, study_type, include_examples, llm_model) {
  prompt <- paste0(
    "# EXPERT PSYCHOMETRIC STUDY CONFIGURATION OPTIMIZATION\n\n",
    "You are an expert psychometrician and R programmer specializing in adaptive testing with Item Response Theory (IRT). ",
    "I need help optimizing a study configuration for the inrep R package, which uses TAM for all psychometric computations.\n\n",
    
    "## STUDY CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", context$target_population %||% "Not specified", "\n",
    "- Duration: ", context$duration %||% "Not specified", "\n",
    "- Research Goals: ", paste(context$research_questions %||% "Not specified", collapse = ", "), "\n",
    "- Sample Size: ", context$sample_size %||% "Not specified", "\n",
    "- Expected Response Rate: ", context$response_rate %||% "Not specified", "\n",
    "- Data Collection Method: ", context$collection_method %||% "Online assessment", "\n\n",
    
    "## CRITICAL OPTIMIZATION TASKS\n\n",
    
    "### 1. IRT Model Selection & Justification\n",
    "- **Model Type**: Choose optimal IRT model (1PL, 2PL, 3PL, GRM) with detailed justification\n",
    "- **Model Assumptions**: Verify assumptions are met for target population\n",
    "- **Parameter Estimation**: Plan for item parameter calibration\n",
    "- **Model Comparison**: Consider multiple models and selection criteria\n\n",
    
    "### 2. Adaptive Testing Parameters\n",
    "- **Item Selection**: Choose between MI, MFI, WEIGHTED, RANDOM with justification\n",
    "- **Stopping Rules**: Design comprehensive stopping criteria beyond SEM\n",
    "- **Precision Targets**: Set appropriate min_SEM based on research goals\n",
    "- **Item Limits**: Balance min_items/max_items for precision vs burden\n",
    "- **Adaptive Start**: Determine when adaptive selection begins\n\n",
    
    "### 3. Population-Specific Optimization\n",
    "- **Theta Prior**: Design prior distribution for target population\n",
    "- **Content Balancing**: Ensure adequate coverage across ability spectrum\n",
    "- **Cultural Adaptation**: Consider language and cultural factors\n",
    "- **Accessibility**: Plan for diverse participant needs\n\n",
    
    "### 4. Quality Control & Validation\n",
    "- **Response Validation**: Design custom validation functions\n",
    "- **Time Monitoring**: Set appropriate response time limits\n",
    "- **Data Integrity**: Implement comprehensive session saving\n",
    "- **Parallel Processing**: Optimize computational performance\n\n",
    
    "### 5. User Experience & Engagement\n",
    "- **Theme Selection**: Choose professional appearance for research context\n",
    "- **Progress Feedback**: Design appropriate progress indicators\n",
    "- **Session Management**: Plan for long assessments and interruptions\n",
    "- **Mobile Optimization**: Ensure cross-device compatibility\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## COMPREHENSIVE OUTPUT REQUIREMENTS\n\n",
      
      "### A. Complete Study Configuration\n",
      "Provide a complete `create_study_config()` function call with:\n",
      "- All parameters optimized for the specific study type\n",
      "- Clear variable names and logical structure\n",
      "- Comprehensive error handling and validation\n",
      "- Professional theme and appearance settings\n\n",
      
      "### B. Parameter Justification Matrix\n",
      "For each parameter, provide:\n",
      "- **Current Value**: What you recommend\n",
      "- **Justification**: Why this value is optimal\n",
      "- **Alternatives**: Other options considered\n",
      "- **Risks**: Potential issues and mitigation\n",
      "- **Validation**: How to verify the choice\n\n",
      
      "### C. Implementation Strategy\n",
      "Include:\n",
      "- **Setup Steps**: Ordered implementation sequence\n",
      "- **Testing Protocol**: Validation procedures\n",
      "- **Quality Metrics**: Success indicators\n",
      "- **Monitoring Plan**: Ongoing assessment\n",
      "- **Optimization Timeline**: When to review and adjust\n\n",
      
      "### D. Example Configurations\n",
      "Provide 3 different configurations:\n",
      "1. **Conservative**: High precision, longer assessment\n",
      "2. **Balanced**: Optimal precision vs time\n",
      "3. **Efficient**: Shorter assessment, acceptable precision\n\n",
      
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
      
      "## EXPECTED OUTPUT STRUCTURE\n",
      "Your response must be structured as:\n",
      "1. **Executive Summary** (2-3 sentences)\n",
      "2. **Model Selection Analysis** (detailed reasoning)\n",
      "3. **Parameter Optimization** (each parameter with justification)\n",
      "4. **Complete R Code** (ready to execute)\n",
      "5. **Implementation Guide** (step-by-step)\n",
      "6. **Quality Assurance** (validation procedures)\n",
      "7. **Risk Assessment** (potential issues and solutions)\n",
      "8. **Next Steps** (further optimization)\n\n",
      
      "Please provide a comprehensive, professional response that can be directly implemented in the inrep package."
    )
  }
  
  return(prompt)
}

#' Generate Item Bank Optimization Prompt
#' @noRd
generate_item_bank_prompt <- function(context, study_type, include_examples, llm_model) {
  prompt <- paste0(
    "# EXPERT ITEM BANK OPTIMIZATION FOR IRT ANALYSIS\n\n",
    "You are an expert psychometrician specializing in Item Response Theory, test development, and item bank optimization. ",
    "I need help optimizing an item bank for the inrep R package (which uses TAM for psychometric computations).\n\n",
    
    "## ITEM BANK CONTEXT\n",
    "- Domain: ", context$domain %||% study_type, "\n",
    "- Current Items: ", context$num_items %||% "Not specified", "\n",
    "- Difficulty Range: ", paste(context$difficulty_range %||% c("Not specified"), collapse = " to "), "\n",
    "- Target Model: ", context$model %||% "GRM", "\n",
    "- Target Precision: ", context$target_sem %||% "0.3", "\n",
    "- Population Size: ", context$population_size %||% "Not specified", "\n",
    "- Calibration Method: ", context$calibration_method %||% "Not specified", "\n",
    "- Content Areas: ", paste(context$content_areas %||% "Not specified", collapse = ", "), "\n\n",
    
    "## CRITICAL OPTIMIZATION TASKS\n\n",
    
    "### 1. Item Parameter Analysis & Optimization\n",
    "- **Discrimination Parameters (a)**: Analyze and optimize for optimal range (0.8-2.5)\n",
    "- **Difficulty Parameters (b)**: Ensure adequate coverage across ability spectrum\n",
    "- **Threshold Parameters**: Optimize b1-b4 for GRM items with proper spacing\n",
    "- **Parameter Constraints**: Implement realistic constraints based on psychometric theory\n",
    "- **Parameter Stability**: Assess and improve parameter estimation precision\n\n",
    
    "### 2. Content Coverage & Balance\n",
    "- **Ability Spectrum Coverage**: Ensure adequate representation across theta range\n",
    "- **Content Domain Balance**: Balance representation across different content areas\n",
    "- **Difficulty Distribution**: Optimize for target population characteristics\n",
    "- **Item Type Diversity**: Balance different item formats and response types\n",
    "- **Cultural Sensitivity**: Ensure items are appropriate for target population\n\n",
    
    "### 3. Adaptive Testing Efficiency\n",
    "- **Item Information Curves**: Optimize for maximum information at target theta levels\n",
    "- **Item Selection Efficiency**: Minimize test length while maintaining precision\n",
    "- **Content Balancing**: Implement content constraints for adaptive selection\n",
    "- **Exposure Control**: Prevent overuse of high-quality items\n",
    "- **Item Pool Redundancy**: Ensure adequate backup items for all difficulty levels\n\n",
    
    "### 4. Quality Control & Validation\n",
    "- **Parameter Validation**: Verify parameter estimates meet psychometric standards\n",
    "- **Model Fit Assessment**: Ensure items fit the chosen IRT model\n",
    "- **Differential Item Functioning**: Check for bias across population subgroups\n",
    "- **Local Independence**: Verify items meet local independence assumptions\n",
    "- **Unidimensionality**: Confirm items measure a single latent construct\n\n",
    
    "### 5. Calibration & Maintenance\n",
    "- **Calibration Strategy**: Design optimal calibration procedures\n",
    "- **Sample Size Requirements**: Determine minimum sample sizes for reliable estimation\n",
    "- **Cross-Validation**: Implement validation procedures for parameter stability\n",
    "- **Item Pool Maintenance**: Plan for ongoing item quality monitoring\n",
    "- **Item Replacement**: Strategy for replacing underperforming items\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## COMPREHENSIVE OUTPUT REQUIREMENTS\n\n",
      
      "### A. Item Bank Validation Strategy\n",
      "Provide complete validation procedures using:\n",
      "- `validate_item_bank()` with comprehensive checks\n",
      "- Parameter quality assessment metrics\n",
      "- Model fit evaluation procedures\n",
      "- Content coverage analysis\n",
      "- Population-specific validation\n\n",
      
      "### B. Parameter Optimization Recommendations\n",
      "For each parameter type, provide:\n",
      "- **Current Status**: What the parameters look like now\n",
      "- **Target Values**: What they should be\n",
      "- **Optimization Method**: How to achieve target values\n",
      "- **Quality Metrics**: How to measure improvement\n",
      "- **Implementation Steps**: Specific actions to take\n\n",
      
      "### C. Unknown Parameter Handling\n",
      "Provide strategy using:\n",
      "- `initialize_unknown_parameters()` with appropriate defaults\n",
      "- Calibration procedures for new items\n",
      "- Integration with existing calibrated items\n",
      "- Quality assurance for parameter estimates\n\n",
      
      "### D. Content Balancing Implementation\n",
      "Include:\n",
      "- Content constraint definitions\n",
      "- Adaptive selection modifications\n",
      "- Balance monitoring procedures\n",
      "- Adjustment strategies for imbalances\n\n",
      
      "### E. Quality Metrics & Monitoring\n",
      "Provide:\n",
      "- Comprehensive quality dashboard\n",
      "- Regular monitoring procedures\n",
      "- Alert systems for quality issues\n",
      "- Improvement tracking over time\n\n",
      
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
      
      "## EXPECTED OUTPUT STRUCTURE\n",
      "Your response must include:\n",
      "1. **Executive Summary** (2-3 sentences)\n",
      "2. **Current State Analysis** (what exists and what needs improvement)\n",
      "3. **Optimization Strategy** (step-by-step approach)\n",
      "4. **Complete R Code** (validation, optimization, and monitoring)\n",
      "5. **Quality Metrics** (how to measure success)\n",
      "6. **Implementation Timeline** (when to do what)\n",
      "7. **Risk Assessment** (potential issues and solutions)\n",
      "8. **Maintenance Plan** (ongoing optimization)\n\n",
      
      "Please provide a comprehensive, professional response with immediately executable R code for the inrep package."
    )
  }
  
  return(prompt)
}

#' Generate Demographics Configuration Prompt
#' @noRd
generate_demographics_prompt <- function(context, study_type, include_examples, llm_model) {
  prompt <- paste0(
    "# EXPERT DEMOGRAPHIC QUESTIONNAIRE DESIGN FOR PSYCHOLOGICAL ASSESSMENT\n\n",
    "You are an expert in survey methodology, psychological assessment, and cross-cultural research. ",
    "I need help designing an optimal demographic questionnaire for the inrep R package that balances data quality with participant experience.\n\n",
    
    "## STUDY CONTEXT\n",
    "- Study Type: ", study_type, "\n",
    "- Target Population: ", context$target_population %||% "Not specified", "\n",
    "- Research Goals: ", paste(context$research_questions %||% "Not specified", collapse = ", "), "\n",
    "- Data Privacy Level: ", context$privacy_level %||% "Standard academic", "\n",
    "- Cultural Context: ", context$cultural_context %||% "Not specified", "\n",
    "- Age Range: ", context$age_range %||% "Not specified", "\n",
    "- Geographic Scope: ", context$geographic_scope %||% "Not specified", "\n",
    "- Language Requirements: ", context$language_requirements %||% "Not specified", "\n\n",
    
    "## CRITICAL DESIGN CONSIDERATIONS\n\n",
    
    "### 1. Essential vs Optional Demographics\n",
    "- **Core Demographics**: Age, gender, education level, occupation\n",
    "- **Research-Specific**: Variables directly related to research questions\n",
    "- **Control Variables**: Factors that may influence assessment outcomes\n",
    "- **Optional Demographics**: Interesting but not essential for analysis\n",
    "- **Sensitive Information**: Handle with appropriate privacy measures\n\n",
    
    "### 2. Question Design & Validation\n",
    "- **Question Wording**: Clear, unambiguous language appropriate for target population\n",
    "- **Response Options**: Inclusive, culturally sensitive, and comprehensive\n",
    "- **Input Types**: Optimal input methods (text, select, numeric, radio, checkbox)\n",
    "- **Validation Rules**: Client-side and server-side validation procedures\n",
    "- **Skip Logic**: Conditional questions based on previous responses\n\n",
    
    "### 3. Cultural Sensitivity & Accessibility\n",
    "- **Cultural Adaptation**: Ensure questions are appropriate for all cultural backgrounds\n",
    "- **Language Considerations**: Support for multiple languages if needed\n",
    "- **Accessibility**: Design for participants with diverse abilities\n",
    "- **Inclusive Language**: Use terminology that respects all identities\n",
    "- **Local Context**: Adapt to regional or cultural specificities\n\n",
    
    "### 4. Data Quality & Privacy\n",
    "- **Data Validation**: Comprehensive validation rules and error messages\n",
    "- **Privacy Protection**: Anonymization and data security measures\n",
    "- **Consent Process**: Clear information about data collection and use\n",
    "- **Data Retention**: Policies for data storage and deletion\n",
    "- **Compliance**: Adherence to relevant regulations (GDPR, HIPAA, etc.)\n\n",
    
    "### 5. User Experience & Engagement\n",
    "- **Question Flow**: Logical order that minimizes participant burden\n",
    "- **Progress Indication**: Clear feedback on completion status\n",
    "- **Mobile Optimization**: Ensure usability across all devices\n",
    "- **Response Time**: Minimize time required to complete demographics\n",
    "- **Visual Design**: Professional appearance consistent with study theme\n\n"
  )
  
  if (include_examples) {
    prompt <- paste0(prompt,
      "## COMPREHENSIVE OUTPUT REQUIREMENTS\n\n",
      
      "### A. Complete Demographics Configuration\n",
      "Provide a complete demographics setup using inrep functions:\n",
      "- `create_demographics_ui()` with optimized parameters\n",
      "- `validate_demographics()` with comprehensive validation rules\n",
      "- `process_demographics()` with data cleaning procedures\n",
      "- Integration with study configuration\n\n",
      
      "### B. Question Design Matrix\n",
      "For each demographic variable, provide:\n",
      "- **Variable Name**: Standardized naming convention\n",
      "- **Question Text**: Exact wording to use\n",
      "- **Response Type**: Input method and options\n",
      "- **Validation Rules**: Required vs optional, format requirements\n",
      "- **Privacy Level**: How sensitive is this information\n",
      "- **Analysis Use**: How this variable will be used in research\n\n",
      
      "### C. Implementation Strategy\n",
      "Include:\n",
      "- **Setup Steps**: How to implement in inrep\n",
      "- **Testing Protocol**: Validation procedures\n",
      "- **Quality Metrics**: How to measure success\n",
      "- **Privacy Audit**: Security and compliance checks\n",
      "- **User Testing**: Participant feedback procedures\n\n",
      
      "### D. Cultural Adaptation Plan\n",
      "Provide:\n",
      "- Cultural sensitivity guidelines\n",
      "- Language adaptation strategies\n",
      "- Regional customization options\n",
      "- Accessibility improvements\n",
      "- Inclusive design principles\n\n",
      
      "### E. Data Management & Analysis\n",
      "Include:\n",
      "- Data cleaning procedures\n",
      "- Quality control measures\n",
      "- Analysis integration strategies\n",
      "- Reporting and visualization\n",
      "- Long-term data management\n\n",
      
      "## SAMPLE DEMOGRAPHICS STRUCTURE\n",
      "```r\n",
      "demographics_config <- list(\n",
      "  essential = c('age', 'gender', 'education', 'occupation'),\n",
      "  research_specific = c('clinical_history', 'medication_use'),\n",
      "  optional = c('income_level', 'marital_status'),\n",
      "  validation_rules = list(\n",
      "    age = list(min = 18, max = 100, required = TRUE),\n",
      "    gender = list(options = c('Male', 'Female', 'Non-binary', 'Prefer not to say'), required = TRUE)\n",
      "  )\n",
      ")\n",
      "```\n\n",
      
      "## EXPECTED OUTPUT STRUCTURE\n",
      "Your response must include:\n",
      "1. **Executive Summary** (2-3 sentences)\n",
      "2. **Demographics Strategy** (what to collect and why)\n",
      "3. **Question Design** (exact wording and response options)\n",
      "4. **Complete R Code** (implementation in inrep)\n",
      "5. **Validation Rules** (data quality assurance)\n",
      "6. **Privacy & Compliance** (security measures)\n",
      "7. **Cultural Adaptation** (inclusivity strategies)\n",
      "8. **Implementation Guide** (step-by-step setup)\n\n",
      
      "Please provide a comprehensive, professional response with immediately executable R code for the inrep package."
    )
  }
  
  return(prompt)
}

#' Generate Validation Strategy Prompt
#' @noRd
generate_validation_prompt <- function(context, study_type, include_examples, llm_model) {
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
generate_ui_theme_prompt <- function(context, study_type, include_examples, llm_model) {
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
generate_multilingual_prompt <- function(context, study_type, include_examples, llm_model) {
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
generate_analysis_prompt <- function(context, study_type, include_examples, llm_model) {
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
generate_deployment_prompt <- function(context, study_type, include_examples, llm_model) {
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
generate_documentation_prompt <- function(context, study_type, include_examples, llm_model) {
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
#' This function provides comprehensive configuration for the enhanced LLM assistance system.
#'
#' @param enable Logical indicating whether to enable LLM assistance prompts.
#' @param output_format Character string specifying the default output format.
#'   Options: "console", "file", "clipboard"
#' @param prompt_types Character vector specifying which types of prompts to enable.
#'   Options: "all", "study_config", "item_bank", "demographics", "validation", 
#'   "ui_theme", "multilingual", "analysis", "deployment", "documentation"
#' @param verbose Logical indicating whether to display detailed information.
#' @param auto_suggest Logical indicating whether to automatically suggest LLM assistance
#'   during common operations.
#' @param llm_model Character string specifying the default LLM model for optimization.
#'   Options: "claude", "gpt4", "gemini", "generic"
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
#' # Enable with specific configuration
#' enable_llm_assistance(
#'   enable = TRUE,
#'   output_format = "console",
#'   prompt_types = c("study_config", "item_bank"),
#'   verbose = TRUE,
#'   auto_suggest = TRUE,
#'   llm_model = "claude"
#' )
#' 
#' # Disable all LLM assistance
#' enable_llm_assistance(FALSE)
#' 
#' # Check current settings
#' settings <- get_llm_assistance_settings()
#' print(settings)
#' }
enable_llm_assistance <- function(enable = TRUE,
                                 output_format = "console",
                                 prompt_types = "all",
                                 verbose = TRUE,
                                 auto_suggest = FALSE,
                                 llm_model = "generic") {
  
  # Validate inputs
  valid_formats <- c("console", "file", "clipboard")
  valid_prompt_types <- c("all", "study_config", "item_bank", "demographics", "validation", 
                          "ui_theme", "multilingual", "analysis", "deployment", "documentation")
  valid_llm_models <- c("claude", "gpt4", "gemini", "generic")
  
  if (!output_format %in% valid_formats) {
    stop("Invalid output_format. Must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  if (!all(prompt_types %in% valid_prompt_types)) {
    stop("Invalid prompt_types. Must be one of: ", paste(valid_prompt_types, collapse = ", "))
  }
  
  if (!llm_model %in% valid_llm_models) {
    stop("Invalid llm_model. Must be one of: ", paste(valid_llm_models, collapse = ", "))
  }
  
  # Store previous setting
  previous_setting <- getOption("inrep.llm_assistance", FALSE)
  
  # Set new options
  options(inrep.llm_assistance = enable)
  options(inrep.llm_output_format = output_format)
  options(inrep.llm_prompt_types = prompt_types)
  options(inrep.llm_verbose = verbose)
  options(inrep.llm_auto_suggest = auto_suggest)
  options(inrep.llm_model = llm_model)
  
  # Display status message
  if (enable) {
    message("=" %r% 80)
    message("LLM ASSISTANCE ENABLED for inrep package")
    message("=" %r% 80)
    message("")
    message("Configuration:")
    message("- Output Format: ", output_format)
    message("- Prompt Types: ", paste(prompt_types, collapse = ", "))
    message("- Verbose Mode: ", verbose)
    message("- Auto-Suggest: ", auto_suggest)
    message("- Default LLM Model: ", llm_model)
    message("")
    message("Available Functions:")
    message("- generate_llm_prompt(): Create custom prompts")
    message("- quick_llm_assistance(): Get quick help for common tasks")
    message("- display_llm_prompt(): Format prompts for external LLMs")
    message("- get_llm_assistance_settings(): Check current configuration")
    message("")
    message("Usage Examples:")
    message("- quick_llm_assistance('personality_assessment', 'standard', 'claude')")
    message("- generate_llm_prompt('study_config', study_type = 'cognitive')")
    message("")
    message("=" %r% 80)
  } else {
    message("=" %r% 80)
    message("LLM ASSISTANCE DISABLED for inrep package")
    message("=" %r% 80)
    message("")
    message("To re-enable, use: enable_llm_assistance(TRUE)")
    message("=" %r% 80)
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
    verbose = getOption("inrep.llm_verbose", TRUE),
    auto_suggest = getOption("inrep.llm_auto_suggest", FALSE),
    llm_model = getOption("inrep.llm_model", "generic")
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
}

#' Quick LLM Assistance for Common Assessment Tasks
#'
#' @description
#' Provides immediate LLM assistance for common assessment tasks without requiring
#' detailed context specification. This function generates optimized prompts for
#' typical use cases.
#'
#' @param task Character string specifying the common task.
#'   Options: "personality_assessment", "cognitive_testing", "clinical_evaluation", 
#'   "educational_assessment", "organizational_survey", "research_study"
#' @param complexity Character string specifying the desired complexity level.
#'   Options: "basic", "standard", "advanced", "expert"
#' @param llm_model Character string specifying the target LLM model.
#'   Options: "claude", "gpt4", "gemini", "generic"
#' @param output_format Character string specifying output format.
#'   Options: "console", "file", "clipboard"
#'
#' @return Character string containing the LLM prompt, or invisibly returns the prompt
#'   if output_format is "file" or "clipboard".
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get quick assistance for a personality assessment
#' quick_llm_assistance("personality_assessment", "standard", "claude")
#' 
#' # Get expert-level assistance for cognitive testing
#' quick_llm_assistance("cognitive_testing", "expert", "gpt4")
#' }
quick_llm_assistance <- function(task = "personality_assessment",
                                complexity = "standard",
                                llm_model = "generic",
                                output_format = "console") {
  
  # Validate inputs
  valid_tasks <- c("personality_assessment", "cognitive_testing", "clinical_evaluation", 
                   "educational_assessment", "organizational_survey", "research_study")
  valid_complexities <- c("basic", "standard", "advanced", "expert")
  valid_llm_models <- c("claude", "gpt4", "gemini", "generic")
  valid_formats <- c("console", "file", "clipboard")
  
  if (!task %in% valid_tasks) {
    stop("Invalid task. Must be one of: ", paste(valid_tasks, collapse = ", "))
  }
  
  if (!complexity %in% valid_complexities) {
    stop("Invalid complexity. Must be one of: ", paste(valid_complexities, collapse = ", "))
  }
  
  if (!llm_model %in% valid_llm_models) {
    stop("Invalid llm_model. Must be one of: ", paste(valid_llm_models, collapse = ", "))
  }
  
  if (!output_format %in% valid_formats) {
    stop("Invalid output_format. Must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  # Generate task-specific context
  context <- generate_task_context(task, complexity)
  
  # Determine appropriate component based on task
  component <- switch(task,
    "personality_assessment" = "study_config",
    "cognitive_testing" = "item_bank",
    "clinical_evaluation" = "validation",
    "educational_assessment" = "study_config",
    "organizational_survey" = "demographics",
    "research_study" = "deployment"
  )
  
  # Generate the prompt using the main function
  generate_llm_prompt(
    component = component,
    context = context,
    study_type = map_task_to_study_type(task),
    output_format = output_format,
    include_examples = TRUE,
    verbose = TRUE,
    llm_model = llm_model
  )
}

#' Generate Task-Specific Context for Quick Assistance
#' @noRd
generate_task_context <- function(task, complexity) {
  base_context <- switch(task,
    "personality_assessment" = list(
      target_population = "General adult population",
      duration = "15-20 minutes",
      research_questions = c("Big Five personality traits", "Individual differences"),
      sample_size = "100-500 participants",
      response_rate = "Expected 70-80%",
      collection_method = "Online assessment platform"
    ),
    "cognitive_testing" = list(
      domain = "General cognitive ability",
      num_items = "30-50 items",
      difficulty_range = c(-2, 2),
      target_sem = "0.3",
      population_size = "200-1000 participants",
      calibration_method = "Maximum likelihood estimation"
    ),
    "clinical_evaluation" = list(
      target_population = "Clinical population",
      duration = "20-30 minutes",
      research_questions = c("Clinical symptom severity", "Treatment response"),
      privacy_level = "High (HIPAA compliant)",
      cultural_context = "Clinical psychology",
      age_range = "18-65 years"
    ),
    "educational_assessment" = list(
      target_population = "University students",
      duration = "25-35 minutes",
      research_questions = c("Academic achievement", "Learning outcomes"),
      sample_size = "150-300 students",
      response_rate = "Expected 85-90%",
      collection_method = "Institutional learning platform"
    ),
    "organizational_survey" = list(
      target_population = "Workplace employees",
      duration = "10-15 minutes",
      research_questions = c("Job satisfaction", "Organizational climate"),
      privacy_level = "Medium (anonymized)",
      cultural_context = "Organizational psychology",
      geographic_scope = "Multi-national organization"
    ),
    "research_study" = list(
      target_population = "Research participants",
      duration = "Variable based on design",
      research_questions = c("Research hypothesis testing", "Data collection"),
      sample_size = "Determined by power analysis",
      response_rate = "Expected 60-80%",
      collection_method = "Research platform"
    )
  )
  
  # Add complexity-specific enhancements
  if (complexity == "advanced" || complexity == "expert") {
    base_context$advanced_features <- TRUE
    base_context$quality_metrics <- "Comprehensive psychometric validation"
    base_context$monitoring <- "Real-time quality monitoring"
  }
  
  if (complexity == "expert") {
    base_context$expert_level <- TRUE
    base_context$custom_validation <- "Advanced validation procedures"
    base_context$optimization <- "Continuous parameter optimization"
  }
  
  return(base_context)
}

#' Map Task to Study Type
#' @noRd
map_task_to_study_type <- function(task) {
  switch(task,
    "personality_assessment" = "personality",
    "cognitive_testing" = "cognitive",
    "clinical_evaluation" = "clinical",
    "educational_assessment" = "educational",
    "organizational_survey" = "organizational",
    "research_study" = "personality"  # Default fallback
  )
}

#' Display LLM Prompt with Enhanced Formatting
#'
#' @description
#' Displays and formats LLM prompts for optimal use with external LLM services.
#' This function provides enhanced formatting and guidance for users.
#'
#' @param prompt Character string containing the LLM prompt to display.
#' @param component Character string specifying the component type for context.
#' @param format_type Character string specifying the display format.
#'   Options: "enhanced", "minimal", "copy_ready"
#'
#' @return Invisibly returns the formatted prompt.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Display a prompt with enhanced formatting
#' prompt <- generate_llm_prompt("study_config", study_type = "personality")
#' display_llm_prompt(prompt, "study_config", "enhanced")
#' }
display_llm_prompt <- function(prompt, component = "unknown", format_type = "enhanced") {
  
  # Validate format type
  valid_formats <- c("enhanced", "minimal", "copy_ready")
  if (!format_type %in% valid_formats) {
    stop("Invalid format_type. Must be one of: ", paste(valid_formats, collapse = ", "))
  }
  
  if (format_type == "enhanced") {
    message("=" %r% 80)
    message("ENHANCED LLM PROMPT DISPLAY")
    message("=" %r% 80)
    message("")
    message("Component: ", toupper(component))
    message("Format: Enhanced with guidance")
    message("")
    message("Copy this prompt to your preferred LLM service:")
    message("")
    message("- ChatGPT (OpenAI)")
    message("- Claude (Anthropic)")
    message("- Gemini (Google)")
    message("- Other LLM services")
    message("")
    message("=" %r% 80)
    message("PROMPT START")
    message("=" %r% 80)
    message("")
    message(prompt)
    message("")
    message("=" %r% 80)
    message("PROMPT END")
    message("=" %r% 80)
    message("")
    message("IMPORTANT GUIDANCE:")
    message("1. Copy the entire prompt (from PROMPT START to PROMPT END)")
    message("2. Paste into your LLM service")
    message("3. Review the response for completeness")
    message("4. Use the provided R code directly in inrep")
    message("5. Test the implementation before production use")
    message("=" %r% 80)
    
  } else if (format_type == "minimal") {
    message("LLM PROMPT FOR ", toupper(component))
    message("=" %r% 50)
    message(prompt)
    message("=" %r% 50)
    
  } else if (format_type == "copy_ready") {
    message("COPY-READY LLM PROMPT")
    message("=" %r% 50)
    message("")
    message(prompt)
    message("")
    message("=" %r% 50)
    message("Copy the above text to your LLM service")
  }
  
  invisible(prompt)
}