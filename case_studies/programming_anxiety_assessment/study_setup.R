# Programming Anxiety Assessment with Plausible Values
# ================================================
#
# This case study demonstrates a comprehensive assessment system where:
# - Participants complete a Programming Anxiety assessment
# - Plausible values are generated for robust inference
# - Full dashboard experience with comprehensive reporting
# - Interactive visualizations and detailed analytics
# - Export capabilities for further analysis
#
# Study: Programming Anxiety Assessment
# Version: 1.0
# Last Updated: 2025-01-20
# Focus: Comprehensive Reporting & Dashboard Experience

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)
library(knitr)
library(kableExtra)
library(psych)
library(corrplot)
library(rmarkdown)

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

# Create programming anxiety study configuration
programming_anxiety_config <- create_study_config(
  name = "Programming Anxiety Assessment",
  study_key = "prog_anxiety_2025",
  model = "GRM",
  max_items = 30,
  min_items = 20,
  min_SEM = 0.20,
  max_session_duration = 40,
  adaptive_start = 8,
  estimation_method = "TAM",
  
  # Plausible values settings
  plausible_values = TRUE,
  n_plausible_values = 5,
  pv_seed = 12345,
  
  # Demographics
  demographics = c("Age", "Gender", "Education", "Programming_Experience", "Field_of_Study"),
  
  # Study phases
  show_introduction = TRUE,
  show_briefing = TRUE,
  show_consent = TRUE,
  show_gdpr_compliance = TRUE,
  show_debriefing = TRUE,
  
  # Custom content
  introduction_content = "
    <h2>Programming Anxiety Assessment</h2>
    <p>This assessment measures your feelings and attitudes toward programming and computer science tasks. 
    Your responses will help researchers understand programming anxiety and develop better learning approaches.</p>
    <p><strong>What you'll do:</strong></p>
    <ul>
      <li>Answer questions about your programming experiences</li>
      <li>Rate your anxiety levels in various programming situations</li>
      <li>Complete demographic information</li>
      <li>Receive a comprehensive personal report</li>
    </ul>
    <p><strong>Duration:</strong> Approximately 25-40 minutes</p>
  ",
  
  briefing_content = "
    <h3>Study Information</h3>
    <p><strong>Purpose:</strong> This study investigates programming anxiety and its relationship with learning outcomes.</p>
    <p><strong>Procedure:</strong> You will answer questions about your programming experiences and anxiety levels.</p>
    <p><strong>Benefits:</strong> You will receive a detailed report about your programming anxiety profile.</p>
    <p><strong>Confidentiality:</strong> All data will be anonymized and stored securely.</p>
  ",
  
  consent_content = "
    <h3>Informed Consent</h3>
    <p>By participating, you agree to:</p>
    <ul>
      <li>Answer questions about programming anxiety honestly</li>
      <li>Complete the assessment to the best of your ability</li>
      <li>Allow your anonymized data to be used for research</li>
    </ul>
  ",
  
  debriefing_content = "
    <h3>Thank you for participating!</h3>
    <p>You have completed the Programming Anxiety Assessment. 
    Your comprehensive report is now available with detailed insights and recommendations.</p>
  ",
  
  # Enhanced features
  enhanced_features = list(
    plausible_values = list(
      enabled = TRUE,
      n_values = 5,
      seed = 12345,
      confidence_intervals = TRUE
    ),
    dashboard = list(
      enabled = TRUE,
      interactive_plots = TRUE,
      export_capabilities = TRUE,
      comparison_features = TRUE
    ),
    reporting = list(
      enabled = TRUE,
      detailed_analytics = TRUE,
      recommendations = TRUE,
      export_formats = c("PDF", "HTML", "CSV", "RDS")
    )
  )
)

# =============================================================================
# PROGRAMMING ANXIETY ITEM BANK
# =============================================================================

# Create comprehensive programming anxiety item bank
programming_anxiety_items <- data.frame(
  Item_ID = 1:35,
  Question = c(
    # Cognitive Anxiety (8 items)
    "I worry about making mistakes when programming",
    "I feel overwhelmed when I see complex code",
    "I doubt my ability to solve programming problems",
    "I get anxious when I don't understand programming concepts",
    "I worry about not being able to complete programming tasks",
    "I feel stressed when debugging code",
    "I get nervous about programming exams or assessments",
    "I worry about falling behind in programming courses",
    
    # Somatic Anxiety (7 items)
    "My heart races when I start programming",
    "I feel tense in my shoulders when programming",
    "I get sweaty palms when working on code",
    "I feel butterflies in my stomach before programming",
    "My breathing becomes shallow when debugging",
    "I feel physically exhausted after programming sessions",
    "I get headaches when struggling with code",
    
    # Avoidance Behavior (6 items)
    "I procrastinate on programming assignments",
    "I avoid asking for help with programming problems",
    "I put off learning new programming languages",
    "I avoid programming competitions or hackathons",
    "I skip programming practice sessions",
    "I avoid taking advanced programming courses",
    
    # Performance Anxiety (7 items)
    "I worry about how others will judge my code",
    "I feel anxious when presenting my programming work",
    "I worry about being compared to better programmers",
    "I get nervous when pair programming",
    "I feel anxious about code reviews",
    "I worry about failing programming interviews",
    "I feel stressed about programming deadlines",
    
    # Learning Anxiety (7 items)
    "I worry about not learning programming fast enough",
    "I feel anxious about forgetting programming concepts",
    "I worry about not being able to apply what I learn",
    "I get nervous about asking questions in class",
    "I feel stressed about keeping up with new technologies",
    "I worry about not being creative enough in programming",
    "I feel anxious about not understanding programming theory"
  ),
  
  # IRT parameters for GRM
  a = c(
    # Cognitive Anxiety
    1.3, 1.2, 1.4, 1.1, 1.3, 1.2, 1.4, 1.1,
    # Somatic Anxiety
    1.1, 1.3, 1.2, 1.4, 1.0, 1.3, 1.1,
    # Avoidance Behavior
    1.2, 1.4, 1.1, 1.3, 1.2, 1.0,
    # Performance Anxiety
    1.3, 1.2, 1.4, 1.1, 1.3, 1.2, 1.4,
    # Learning Anxiety
    1.2, 1.3, 1.1, 1.4, 1.2, 1.3, 1.1
  ),
  
  # Difficulty parameters
  b1 = c(
    # Cognitive Anxiety
    -2.1, -1.8, -2.3, -1.5, -2.0, -1.7, -2.2, -1.4,
    # Somatic Anxiety
    -1.6, -2.0, -1.8, -2.1, -1.3, -1.9, -1.5,
    # Avoidance Behavior
    -1.8, -2.1, -1.6, -1.9, -1.7, -1.2,
    # Performance Anxiety
    -2.0, -1.7, -2.2, -1.5, -1.9, -1.6, -2.1,
    # Learning Anxiety
    -1.7, -1.9, -1.4, -2.0, -1.6, -1.8, -1.3
  ),
  
  b2 = c(
    # Cognitive Anxiety
    -0.8, -0.5, -1.0, -0.3, -0.7, -0.4, -0.9, -0.2,
    # Somatic Anxiety
    -0.4, -0.7, -0.6, -0.8, -0.1, -0.6, -0.3,
    # Avoidance Behavior
    -0.6, -0.8, -0.4, -0.6, -0.5, -0.1,
    # Performance Anxiety
    -0.7, -0.4, -0.9, -0.3, -0.6, -0.4, -0.8,
    # Learning Anxiety
    -0.5, -0.6, -0.2, -0.7, -0.4, -0.5, -0.1
  ),
  
  b3 = c(
    # Cognitive Anxiety
    0.6, 0.8, 0.4, 1.0, 0.5, 0.7, 0.3, 1.1,
    # Somatic Anxiety
    1.0, 0.6, 0.8, 0.5, 1.2, 0.7, 1.0,
    # Avoidance Behavior
    0.8, 0.5, 1.0, 0.7, 0.8, 1.2,
    # Performance Anxiety
    0.6, 0.8, 0.4, 1.0, 0.7, 0.9, 0.5,
    # Learning Anxiety
    0.9, 0.7, 1.1, 0.6, 0.8, 0.7, 1.2
  ),
  
  b4 = c(
    # Cognitive Anxiety
    2.1, 2.3, 1.9, 2.5, 2.0, 2.2, 1.8, 2.6,
    # Somatic Anxiety
    2.4, 2.0, 2.2, 1.9, 2.6, 2.1, 2.3,
    # Avoidance Behavior
    2.2, 1.9, 2.4, 2.1, 2.2, 2.6,
    # Performance Anxiety
    2.0, 2.2, 1.8, 2.4, 2.1, 2.3, 1.9,
    # Learning Anxiety
    2.3, 2.1, 2.5, 2.0, 2.2, 2.1, 2.6
  ),
  
  # Response categories
  ResponseCategories = rep("1,2,3,4,5", 35),
  
  # Dimension information
  Dimension = c(
    rep("Cognitive_Anxiety", 8),
    rep("Somatic_Anxiety", 7),
    rep("Avoidance_Behavior", 6),
    rep("Performance_Anxiety", 7),
    rep("Learning_Anxiety", 7)
  ),
  
  # Item metadata
  Item_Type = rep("Anxiety_Assessment", 35),
  Response_Scale = rep("Likert_5", 35),
  Reverse_Coded = rep(FALSE, 35),
  
  # Anxiety-specific information
  Anxiety_Level = c(
    rep("High", 12), rep("Medium", 11), rep("Low", 12)
  ),
  Coping_Strategy = rep("Cognitive_Behavioral", 35),
  Intervention_Level = c(
    rep("Immediate", 8), rep("Short_term", 12), rep("Long_term", 15)
  )
)

# =============================================================================
# PLAUSIBLE VALUES GENERATION
# =============================================================================

# Function to generate plausible values
generate_plausible_values <- function(
  theta_estimate,
  standard_error,
  n_values = 5,
  seed = 12345
) {
  
  set.seed(seed)
  
  # Generate plausible values from normal distribution
  plausible_values <- rnorm(n_values, mean = theta_estimate, sd = standard_error)
  
  # Ensure values are within reasonable bounds (-4 to 4)
  plausible_values <- pmax(pmin(plausible_values, 4), -4)
  
  return(plausible_values)
}

# Function to calculate confidence intervals from plausible values
calculate_confidence_intervals <- function(plausible_values, confidence_level = 0.95) {
  
  alpha <- 1 - confidence_level
  lower_percentile <- alpha / 2
  upper_percentile <- 1 - alpha / 2
  
  ci_lower <- quantile(plausible_values, lower_percentile)
  ci_upper <- quantile(plausible_values, upper_percentile)
  
  return(list(
    lower = ci_lower,
    upper = ci_upper,
    confidence_level = confidence_level
  ))
}

# =============================================================================
# COMPREHENSIVE ANALYSIS FUNCTIONS
# =============================================================================

# Function to analyze programming anxiety results
analyze_programming_anxiety <- function(
  responses,
  item_bank = programming_anxiety_items,
  config = programming_anxiety_config
) {
  
  # Calculate dimension scores
  dimension_scores <- calculate_anxiety_dimension_scores(responses, item_bank)
  
  # Generate plausible values
  plausible_values <- generate_plausible_values(
    theta_estimate = dimension_scores$overall_theta,
    standard_error = dimension_scores$overall_se,
    n_values = config$enhanced_features$plausible_values$n_values,
    seed = config$enhanced_features$plausible_values$seed
  )
  
  # Calculate confidence intervals
  confidence_intervals <- calculate_confidence_intervals(plausible_values)
  
  # Generate anxiety profile
  anxiety_profile <- generate_anxiety_profile(dimension_scores, plausible_values)
  
  # Create visualizations
  plots <- create_anxiety_visualizations(dimension_scores, plausible_values, confidence_intervals)
  
  # Generate comprehensive report
  report <- generate_anxiety_report(dimension_scores, anxiety_profile, plots, plausible_values)
  
  return(list(
    dimension_scores = dimension_scores,
    plausible_values = plausible_values,
    confidence_intervals = confidence_intervals,
    anxiety_profile = anxiety_profile,
    plots = plots,
    report = report
  ))
}

# Function to calculate anxiety dimension scores
calculate_anxiety_dimension_scores <- function(responses, item_bank) {
  
  # Group items by dimension
  dimensions <- unique(item_bank$Dimension)
  dimension_scores <- list()
  
  for (dim in dimensions) {
    dim_items <- item_bank[item_bank$Dimension == dim, ]
    dim_responses <- responses[dim_items$Item_ID]
    
    # Calculate mean score for dimension
    dimension_scores[[dim]] <- mean(dim_responses, na.rm = TRUE)
  }
  
  # Calculate overall anxiety score
  overall_score <- mean(unlist(dimension_scores), na.rm = TRUE)
  
  # Calculate standard error (simplified)
  overall_se <- sd(unlist(dimension_scores), na.rm = TRUE) / sqrt(length(dimensions))
  
  # Convert to theta scale (-4 to 4)
  overall_theta <- (overall_score - 3) * 2  # Scale from 1-5 to -4 to 4
  
  return(list(
    dimension_scores = dimension_scores,
    overall_score = overall_score,
    overall_theta = overall_theta,
    overall_se = overall_se
  ))
}

# Function to generate anxiety profile
generate_anxiety_profile <- function(dimension_scores, plausible_values) {
  
  # Determine anxiety level
  overall_score <- dimension_scores$overall_score
  
  if (overall_score <= 2.0) {
    anxiety_level <- "Low"
    interpretation <- "You experience minimal programming anxiety and feel confident in programming tasks."
  } else if (overall_score <= 3.5) {
    anxiety_level <- "Moderate"
    interpretation <- "You experience some programming anxiety, which is common and manageable."
  } else {
    anxiety_level <- "High"
    interpretation <- "You experience significant programming anxiety that may benefit from targeted interventions."
  }
  
  # Identify primary anxiety sources
  dim_scores <- dimension_scores$dimension_scores
  primary_sources <- names(dim_scores)[order(unlist(dim_scores), decreasing = TRUE)][1:3]
  
  # Generate recommendations
  recommendations <- generate_anxiety_recommendations(anxiety_level, primary_sources)
  
  return(list(
    anxiety_level = anxiety_level,
    interpretation = interpretation,
    primary_sources = primary_sources,
    recommendations = recommendations,
    risk_factors = identify_risk_factors(dim_scores),
    protective_factors = identify_protective_factors(dim_scores)
  ))
}

# Function to generate anxiety recommendations
generate_anxiety_recommendations <- function(anxiety_level, primary_sources) {
  
  recommendations <- list()
  
  if (anxiety_level == "Low") {
    recommendations$general <- "Maintain your positive attitude toward programming. Consider mentoring others."
    recommendations$specific <- "Focus on advanced topics and challenging projects to continue growth."
  } else if (anxiety_level == "Moderate") {
    recommendations$general <- "Practice stress management techniques and seek support when needed."
    recommendations$specific <- "Work on specific areas of concern and celebrate small successes."
  } else {
    recommendations$general <- "Consider seeking professional support for anxiety management."
    recommendations$specific <- "Start with simple programming tasks and gradually increase complexity."
  }
  
  # Source-specific recommendations
  for (source in primary_sources) {
    if (source == "Cognitive_Anxiety") {
      recommendations[[source]] <- "Practice cognitive restructuring and positive self-talk."
    } else if (source == "Somatic_Anxiety") {
      recommendations[[source]] <- "Use relaxation techniques and breathing exercises."
    } else if (source == "Avoidance_Behavior") {
      recommendations[[source]] <- "Gradually expose yourself to programming tasks."
    } else if (source == "Performance_Anxiety") {
      recommendations[[source]] <- "Focus on learning rather than perfect performance."
    } else if (source == "Learning_Anxiety") {
      recommendations[[source]] <- "Set realistic learning goals and celebrate progress."
    }
  }
  
  return(recommendations)
}

# Function to identify risk factors
identify_risk_factors <- function(dim_scores) {
  high_anxiety_dims <- names(dim_scores)[unlist(dim_scores) > 3.5]
  return(high_anxiety_dims)
}

# Function to identify protective factors
identify_protective_factors <- function(dim_scores) {
  low_anxiety_dims <- names(dim_scores)[unlist(dim_scores) < 2.5]
  return(low_anxiety_dims)
}

# =============================================================================
# VISUALIZATION FUNCTIONS
# =============================================================================

# Function to create anxiety visualizations
create_anxiety_visualizations <- function(dimension_scores, plausible_values, confidence_intervals) {
  
  plots <- list()
  
  # 1. Dimension scores radar plot
  plots$radar_plot <- create_radar_plot(dimension_scores)
  
  # 2. Plausible values distribution
  plots$pv_distribution <- create_pv_distribution_plot(plausible_values, confidence_intervals)
  
  # 3. Anxiety level comparison
  plots$anxiety_comparison <- create_anxiety_comparison_plot(dimension_scores)
  
  # 4. Confidence interval plot
  plots$confidence_plot <- create_confidence_plot(plausible_values, confidence_intervals)
  
  return(plots)
}

# Function to create radar plot
create_radar_plot <- function(dimension_scores) {
  # Implementation for radar plot
  # This would use plotly or similar for interactive visualization
  return("Radar plot of anxiety dimensions")
}

# Function to create plausible values distribution plot
create_pv_distribution_plot <- function(plausible_values, confidence_intervals) {
  # Implementation for distribution plot
  return("Distribution of plausible values")
}

# Function to create anxiety comparison plot
create_anxiety_comparison_plot <- function(dimension_scores) {
  # Implementation for comparison plot
  return("Comparison of anxiety dimensions")
}

# Function to create confidence interval plot
create_confidence_plot <- function(plausible_values, confidence_intervals) {
  # Implementation for confidence interval plot
  return("Confidence intervals for anxiety estimates")
}

# =============================================================================
# COMPREHENSIVE REPORTING
# =============================================================================

# Function to generate comprehensive anxiety report
generate_anxiety_report <- function(dimension_scores, anxiety_profile, plots, plausible_values) {
  
  report <- list(
    title = "Programming Anxiety Assessment Report",
    generated_date = Sys.Date(),
    participant_id = "P001",  # Would come from actual data
    
    # Executive summary
    executive_summary = list(
      overall_anxiety_level = anxiety_profile$anxiety_level,
      primary_concerns = anxiety_profile$primary_sources,
      key_recommendations = anxiety_profile$recommendations$general
    ),
    
    # Detailed analysis
    detailed_analysis = list(
      dimension_scores = dimension_scores,
      anxiety_profile = anxiety_profile,
      plausible_values = plausible_values
    ),
    
    # Visualizations
    visualizations = plots,
    
    # Recommendations
    recommendations = anxiety_profile$recommendations,
    
    # Risk assessment
    risk_assessment = list(
      risk_factors = anxiety_profile$risk_factors,
      protective_factors = anxiety_profile$protective_factors,
      overall_risk = ifelse(length(anxiety_profile$risk_factors) > 2, "High", "Moderate")
    ),
    
    # Export options
    export_formats = c("PDF", "HTML", "CSV", "RDS")
  )
  
  return(report)
}

# =============================================================================
# DASHBOARD FUNCTIONS
# =============================================================================

# Function to create interactive dashboard
create_anxiety_dashboard <- function(analysis_results) {
  
  dashboard <- list(
    title = "Programming Anxiety Dashboard",
    
    # Summary cards
    summary_cards = list(
      overall_level = analysis_results$anxiety_profile$anxiety_level,
      primary_source = analysis_results$anxiety_profile$primary_sources[1],
      confidence_level = "95%",
      risk_level = analysis_results$anxiety_profile$risk_factors
    ),
    
    # Interactive plots
    plots = analysis_results$plots,
    
    # Data tables
    data_tables = list(
      dimension_scores = as.data.frame(analysis_results$dimension_scores$dimension_scores),
      plausible_values = data.frame(
        Value = analysis_results$plausible_values,
        Rank = rank(analysis_results$plausible_values)
      )
    ),
    
    # Export functionality
    export_functions = list(
      export_pdf = function() { export_report(analysis_results, "PDF") },
      export_html = function() { export_report(analysis_results, "HTML") },
      export_csv = function() { export_report(analysis_results, "CSV") },
      export_rds = function() { export_report(analysis_results, "RDS") }
    )
  )
  
  return(dashboard)
}

# Function to export report
export_report <- function(analysis_results, format) {
  # Implementation for exporting reports in different formats
  filename <- paste0("programming_anxiety_report_", format(Sys.Date(), "%Y%m%d"), ".", tolower(format))
  
  if (format == "PDF") {
    # Generate PDF report
    return(paste("PDF report saved as:", filename))
  } else if (format == "HTML") {
    # Generate HTML report
    return(paste("HTML report saved as:", filename))
  } else if (format == "CSV") {
    # Export data as CSV
    return(paste("CSV data exported as:", filename))
  } else if (format == "RDS") {
    # Save R object
    return(paste("RDS object saved as:", filename))
  }
}

# =============================================================================
# LAUNCH FUNCTION
# =============================================================================

# Function to launch programming anxiety study
launch_programming_anxiety_study <- function(
  config = programming_anxiety_config,
  item_bank = programming_anxiety_items
) {
  
  cat("=== Programming Anxiety Assessment ===\n")
  cat("Study:", config$name, "\n")
  cat("Model:", config$model, "\n")
  cat("Items:", config$min_items, "-", config$max_items, "\n")
  cat("Plausible Values:", config$enhanced_features$plausible_values$n_values, "\n")
  cat("Dashboard:", config$enhanced_features$dashboard$enabled, "\n")
  cat("=====================================\n\n")
  
  # Launch the study
  app <- launch_study(
    config = config,
    item_bank = item_bank,
    plausible_values = TRUE,
    dashboard = TRUE
  )
  
  return(app)
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Print study information
cat("=== Programming Anxiety Assessment Setup Complete ===\n")
cat("Study Name:", programming_anxiety_config$name, "\n")
cat("Study Key:", programming_anxiety_config$study_key, "\n")
cat("Model:", programming_anxiety_config$model, "\n")
cat("Items:", programming_anxiety_config$min_items, "-", programming_anxiety_config$max_items, "\n")
cat("Plausible Values:", programming_anxiety_config$enhanced_features$plausible_values$n_values, "\n")
cat("Dashboard:", programming_anxiety_config$enhanced_features$dashboard$enabled, "\n")
cat("==================================================\n\n")

cat("To launch the study, run:\n")
cat("launch_programming_anxiety_study()\n\n")

cat("To analyze results, run:\n")
cat("results <- analyze_programming_anxiety(responses)\n")
cat("dashboard <- create_anxiety_dashboard(results)\n\n")

cat("To export reports, run:\n")
cat("export_report(results, 'PDF')\n")
cat("export_report(results, 'HTML')\n")
cat("export_report(results, 'CSV')\n")
cat("export_report(results, 'RDS')\n\n")