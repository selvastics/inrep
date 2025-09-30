# =============================================================================
# PROGRAMMING ANXIETY ASSESSMENT - LAUNCH SCRIPT
# =============================================================================
# 
# This case study demonstrates the ADVANCED IRT FEATURES of inrep:
# 
#  UNIQUE FEATURES HIGHLIGHTED:
# 1. PLAUSIBLE VALUES GENERATION - Multiple estimates for robust statistical inference
# 2. ADVANCED IRT MODELS - Graded Response Model (GRM) with confidence intervals
# 3. INTERACTIVE DASHBOARD - Real-time analytics and visualizations
# 4. MULTI-DIMENSIONAL PROFILING - 5 anxiety dimensions with detailed analysis
# 5. RISK ASSESSMENT - Personalized recommendations and intervention strategies
#
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(inrep)
  library(shiny)
  library(ggplot2)
  library(plotly)
  library(DT)
})

# Source the study setup
source("study_setup.R")

# =============================================================================
# ENHANCED LAUNCH FUNCTION WITH IRT FEATURES
# =============================================================================

launch_programming_anxiety_study <- function(
  port = 3838,
  host = "0.0.0.0",
  demo_mode = FALSE
) {
  
  cat(" PROGRAMMING ANXIETY ASSESSMENT - IRT FEATURES\n")
  cat("================================================================\n")
  cat(" UNIQUE FEATURES DEMONSTRATED:\n")
  cat("   • Plausible Values Generation (5 estimates)\n")
  cat("   • IRT Models (GRM with confidence intervals)\n")
  cat("   • Interactive Dashboard with Real-time Analytics\n")
  cat("   • Multi-dimensional Anxiety Profiling (5 dimensions)\n")
  cat("   • Risk Assessment & Intervention Recommendations\n")
  cat("   • Statistical Robustness for Research Applications\n")
  cat("================================================================\n\n")
  
  # Enhanced configuration for IRT demonstration
  enhanced_config <- programming_anxiety_config
  
  # Enable all IRT features
  enhanced_config$enhanced_features <- list(
    plausible_values = list(
      enabled = TRUE,
      n_values = 5,
      confidence_intervals = TRUE,
      seed_control = TRUE
    ),
    dashboard = list(
      enabled = TRUE,
      real_time_analytics = TRUE,
      interactive_plots = TRUE,
      export_capabilities = TRUE
    ),
    risk_assessment = list(
      enabled = TRUE,
      intervention_recommendations = TRUE,
      population_norms = TRUE,
      trend_analysis = TRUE
    ),
    statistical_robustness = list(
      multiple_estimates = TRUE,
      uncertainty_quantification = TRUE,
      reproducibility = TRUE
    )
  )
  
  # Launch with enhanced features
  app <- inrep::launch_study(
    config = enhanced_config,
    item_bank = programming_anxiety_items,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
    study_key = session_uuid,
    fresh_session = TRUE,
    clear_cache = TRUE,
    language = "en",
    force_custom_ui = TRUE,
    enable_plots = TRUE,
    enable_plausible_values = TRUE,
    port = port,
    host = host
  )
  
  
  return(app)
}

# =============================================================================
# DEMONSTRATION FUNCTIONS
# =============================================================================

# Function to demonstrate plausible values
demonstrate_plausible_values <- function(responses) {
  cat("PLAUSIBLE VALUES DEMONSTRATION\n")
  cat("================================\n")
  cat("This feature generates multiple estimates for robust statistical inference:\n\n")
  
  # Generate plausible values
  pv_results <- generate_plausible_values(
    responses = responses,
    item_bank = programming_anxiety_items,
    n_values = 5,
    model = "GRM"
  )
  
  cat("Generated 5 plausible values:\n")
  print(pv_results$plausible_values)
  cat("\nConfidence intervals (95%):\n")
  print(pv_results$confidence_intervals)
  cat("\nStatistical robustness metrics:\n")
  print(pv_results$robustness_metrics)
  
  return(pv_results)
}

# Function to demonstrate interactive dashboard
demonstrate_dashboard <- function(results) {
  cat("INTERACTIVE DASHBOARD DEMONSTRATION\n")
  cat("=====================================\n")
  cat("This feature provides real-time analytics and visualizations:\n\n")
  
  # Create dashboard
  dashboard <- create_anxiety_dashboard(results)
  
  cat("Dashboard components created:\n")
  cat("• Real-time anxiety level monitoring\n")
  cat("• Multi-dimensional anxiety profiling\n")
  cat("• Risk assessment visualization\n")
  cat("• Population norm comparisons\n")
  cat("• Trend analysis over time\n")
  cat("• Export capabilities\n\n")
  
  return(dashboard)
}

# Function to demonstrate risk assessment
demonstrate_risk_assessment <- function(results) {
  cat("RISK ASSESSMENT DEMONSTRATION\n")
  cat("===============================\n")
  cat("This feature provides personalized recommendations:\n\n")
  
  # Perform risk assessment
  risk_analysis <- assess_programming_anxiety_risk(results)
  
  cat("Risk assessment completed:\n")
  cat("• Overall risk level:", risk_analysis$overall_risk, "\n")
  cat("• High-risk dimensions:", paste(risk_analysis$high_risk_dimensions, collapse = ", "), "\n")
  cat("• Recommended interventions:\n")
  for (i in seq_along(risk_analysis$interventions)) {
    cat("  ", i, ". ", risk_analysis$interventions[i], "\n")
  }
  cat("\n")
  
  return(risk_analysis)
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

cat("PROGRAMMING ANXIETY ASSESSMENT - ADVANCED IRT FEATURES\n")
cat("================================================================\n")
cat("This case study demonstrates the most advanced IRT capabilities of inrep:\n\n")
cat("UNIQUE FEATURES:\n")
cat("1. PLAUSIBLE VALUES - Multiple estimates for robust statistical inference\n")
cat("2. ADVANCED IRT MODELS - GRM with confidence intervals and uncertainty quantification\n")
cat("3. INTERACTIVE DASHBOARD - Real-time analytics and visualizations\n")
cat("4. MULTI-DIMENSIONAL PROFILING - 5 anxiety dimensions with detailed analysis\n")
cat("5. RISK ASSESSMENT - Personalized recommendations and intervention strategies\n\n")
cat("TO LAUNCH THE STUDY:\n")
cat("   launch_programming_anxiety_study()\n\n")
cat("TO DEMONSTRATE FEATURES:\n")
cat("   # After completing the assessment:\n")
cat("   results <- get_study_results()\n")
cat("   demonstrate_plausible_values(results$responses)\n")
cat("   demonstrate_dashboard(results)\n")
cat("   demonstrate_risk_assessment(results)\n\n")
cat("TO EXPORT REPORTS:\n")
cat("   export_report(results, 'PDF')\n")
cat("   export_report(results, 'HTML')\n")
cat("   export_report(results, 'CSV')\n\n")
cat("================================================================\n")