# =============================================================================
# BIG FIVE PERSONALITY ASSESSMENT - LAUNCH SCRIPT
# =============================================================================
# 
# This case study demonstrates the MULTI-DIMENSIONAL ASSESSMENT features of inrep:
# 
#  UNIQUE FEATURES HIGHLIGHTED:
# 1. MULTI-DIMENSIONAL PERSONALITY MODEL - Five-factor model with trait-specific adaptation
# 2. CROSS-CULTURAL VALIDATION - Multiple language support and cultural adaptations
# 3. COMPREHENSIVE PROFILING - Radar plots, bar charts, and detailed trait analysis
# 4. NORMATIVE COMPARISONS - Population norms and percentile rankings
# 5. ADAPTIVE TESTING - Trait-specific item selection and stopping criteria
#
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(inrep)
  library(shiny)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(ggradar)
})

# Source the study setup
source("study_setup.R")

# =============================================================================
# ENHANCED LAUNCH FUNCTION WITH MULTI-DIMENSIONAL FEATURES
# =============================================================================

launch_big_five_study <- function(
  port = 3839,
  host = "0.0.0.0",
  language = "en",
  cultural_adaptation = TRUE
) {
  
  cat(" BIG FIVE PERSONALITY ASSESSMENT - MULTI-DIMENSIONAL FEATURES\n")
  cat("================================================================\n")
  cat(" UNIQUE FEATURES DEMONSTRATED:\n")
  cat("   • Multi-dimensional Personality Model (5 factors)\n")
  cat("   • Cross-cultural Validation & Language Support\n")
  cat("   • Comprehensive Personality Profiling\n")
  cat("   • Normative Comparisons & Percentile Rankings\n")
  cat("   • Adaptive Testing with Trait-specific Selection\n")
  cat("   • Advanced Visualization (Radar, Bar, Scatter plots)\n")
  cat("================================================================\n\n")
  
  # Enhanced configuration for multi-dimensional demonstration
  enhanced_config <- bfi_config
  
  # Enable all multi-dimensional features
  enhanced_config$enhanced_features <- list(
    multi_dimensional = list(
      enabled = TRUE,
      dimensions = c("Extraversion", "Agreeableness", "Conscientiousness", 
                     "Neuroticism", "Openness"),
      trait_specific_adaptation = TRUE,
      cross_trait_analysis = TRUE
    ),
    cultural_adaptation = list(
      enabled = cultural_adaptation,
      languages = c("en", "de", "es", "fr"),
      cultural_norms = TRUE,
      validation_studies = TRUE
    ),
    comprehensive_profiling = list(
      enabled = TRUE,
      radar_plots = TRUE,
      bar_charts = TRUE,
      scatter_plots = TRUE,
      trait_correlations = TRUE
    ),
    normative_comparisons = list(
      enabled = TRUE,
      population_norms = TRUE,
      percentile_rankings = TRUE,
      age_group_comparisons = TRUE,
      gender_comparisons = TRUE
    ),
    adaptive_testing = list(
      enabled = TRUE,
      trait_specific_selection = TRUE,
      stopping_criteria = "SEM < 0.3",
      max_items_per_trait = 4
    )
  )
  
  # Launch with enhanced features
  app <- inrep::launch_study(
    config = enhanced_config,
    item_bank = bfi_items_enhanced,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
    study_key = session_uuid,
    fresh_session = TRUE,
    clear_cache = TRUE,
    language = language,
    force_custom_ui = TRUE,
    enable_plots = TRUE,
    port = port,
    host = host
  )
  
  cat(" STUDY LAUNCHED SUCCESSFULLY!\n")
  cat(" Access the study at: http://localhost:", port, "\n")
  cat(" Features available:\n")
  cat("   • Multi-dimensional personality assessment (5 factors)\n")
  cat("   • Cross-cultural validation and language support\n")
  cat("   • Comprehensive personality profiling with visualizations\n")
  cat("   • Normative comparisons and percentile rankings\n")
  cat("   • Adaptive testing with trait-specific item selection\n")
  cat("   • Advanced reporting and export capabilities\n\n")
  
  return(app)
}

# =============================================================================
# DEMONSTRATION FUNCTIONS
# =============================================================================

# Function to demonstrate multi-dimensional analysis
demonstrate_multi_dimensional_analysis <- function(responses) {
  cat(" MULTI-DIMENSIONAL ANALYSIS DEMONSTRATION\n")
  cat("==========================================\n")
  cat("This feature provides comprehensive personality profiling:\n\n")
  
  # Calculate Big Five scores
  bfi_scores <- calculate_big_five_scores(responses)
  
  cat("Big Five Personality Scores:\n")
  for (trait in names(bfi_scores)) {
    cat("• ", trait, ": ", sprintf("%.2f", bfi_scores[[trait]]), "\n")
  }
  
  # Calculate trait correlations
  trait_correlations <- calculate_trait_correlations(bfi_scores)
  cat("\nTrait Correlations:\n")
  print(trait_correlations)
  
  return(list(scores = bfi_scores, correlations = trait_correlations))
}

# Function to demonstrate cultural adaptation
demonstrate_cultural_adaptation <- function(results, language = "en") {
  cat(" CULTURAL ADAPTATION DEMONSTRATION\n")
  cat("===================================\n")
  cat("This feature provides cross-cultural validation:\n\n")
  
  # Get cultural norms
  cultural_norms <- get_cultural_norms(language)
  
  cat("Cultural norms for", language, "population:\n")
  for (trait in names(cultural_norms)) {
    cat("• ", trait, ": M = ", sprintf("%.2f", cultural_norms[[trait]]$mean), 
        ", SD = ", sprintf("%.2f", cultural_norms[[trait]]$sd), "\n")
  }
  
  # Calculate cultural comparisons
  cultural_comparison <- compare_to_cultural_norms(results, cultural_norms)
  cat("\nCultural comparison results:\n")
  print(cultural_comparison)
  
  return(cultural_comparison)
}

# Function to demonstrate normative comparisons
demonstrate_normative_comparisons <- function(results) {
  cat(" NORMATIVE COMPARISONS DEMONSTRATION\n")
  cat("=====================================\n")
  cat("This feature provides population comparisons:\n\n")
  
  # Get population norms
  population_norms <- get_population_norms()
  
  # Calculate percentile rankings
  percentile_rankings <- calculate_percentile_rankings(results, population_norms)
  
  cat("Percentile Rankings:\n")
  for (trait in names(percentile_rankings)) {
    cat("• ", trait, ": ", percentile_rankings[[trait]], "th percentile\n")
  }
  
  # Age and gender comparisons
  demographic_comparisons <- compare_to_demographic_groups(results)
  cat("\nDemographic comparisons:\n")
  print(demographic_comparisons)
  
  return(list(percentiles = percentile_rankings, demographics = demographic_comparisons))
}

# Function to demonstrate comprehensive profiling
demonstrate_comprehensive_profiling <- function(results) {
  cat(" COMPREHENSIVE PROFILING DEMONSTRATION\n")
  cat("=======================================\n")
  cat("This feature provides advanced visualizations:\n\n")
  
  # Create radar plot
  radar_plot <- create_personality_radar_plot(results)
  cat("• Radar plot created showing personality profile\n")
  
  # Create bar chart
  bar_chart <- create_personality_bar_chart(results)
  cat("• Bar chart created showing trait comparisons\n")
  
  # Create scatter plot matrix
  scatter_matrix <- create_personality_scatter_matrix(results)
  cat("• Scatter plot matrix created showing trait relationships\n")
  
  # Generate comprehensive report
  comprehensive_report <- generate_comprehensive_personality_report(results)
  cat("• Comprehensive report generated with all visualizations\n")
  
  return(list(
    radar = radar_plot,
    bar = bar_chart,
    scatter = scatter_matrix,
    report = comprehensive_report
  ))
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

cat(" BIG FIVE PERSONALITY ASSESSMENT - MULTI-DIMENSIONAL FEATURES\n")
cat("================================================================\n")
cat("This case study demonstrates the multi-dimensional assessment capabilities of inrep:\n\n")
cat(" UNIQUE FEATURES:\n")
cat("1. MULTI-DIMENSIONAL MODEL - Five-factor personality model with trait-specific adaptation\n")
cat("2. CROSS-CULTURAL VALIDATION - Multiple language support and cultural adaptations\n")
cat("3. COMPREHENSIVE PROFILING - Radar plots, bar charts, and detailed trait analysis\n")
cat("4. NORMATIVE COMPARISONS - Population norms and percentile rankings\n")
cat("5. ADAPTIVE TESTING - Trait-specific item selection and stopping criteria\n\n")
cat(" TO LAUNCH THE STUDY:\n")
cat("   launch_big_five_study()\n")
cat("   launch_big_five_study(language = 'de')  # German version\n")
cat("   launch_big_five_study(language = 'es')  # Spanish version\n\n")
cat(" TO DEMONSTRATE FEATURES:\n")
cat("   # After completing the assessment:\n")
cat("   results <- get_study_results()\n")
cat("   demonstrate_multi_dimensional_analysis(results$responses)\n")
cat("   demonstrate_cultural_adaptation(results, 'en')\n")
cat("   demonstrate_normative_comparisons(results)\n")
cat("   demonstrate_comprehensive_profiling(results)\n\n")
cat(" TO EXPORT REPORTS:\n")
cat("   export_personality_report(results, 'PDF')\n")
cat("   export_personality_report(results, 'HTML')\n")
cat("   export_personality_report(results, 'CSV')\n\n")
cat("================================================================\n")
