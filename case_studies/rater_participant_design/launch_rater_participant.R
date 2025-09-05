# =============================================================================
# RATER-PARTICIPANT DESIGN ASSESSMENT - LAUNCH SCRIPT
# =============================================================================
# 
# This case study demonstrates the MULTI-RATER ASSESSMENT features of inrep:
# 
# 🔗 UNIQUE FEATURES HIGHLIGHTED:
# 1. MULTI-RATER ASSESSMENT - Multiple raters evaluating participants with reliability analysis
# 2. INTER-RATER RELIABILITY - ICC calculations and agreement analysis
# 3. ADVANCED SAMPLE LINKING - Bidirectional linking between participants and raters
# 4. QUALITY ASSURANCE - Agreement thresholds and rater calibration
# 5. COMPREHENSIVE REPORTING - Multi-rater comparisons and consensus analysis
#
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(inrep)
  library(shiny)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(psych)
  library(irr)
})

# Source the study setup
source("study_setup.R")

# =============================================================================
# ENHANCED LAUNCH FUNCTION WITH MULTI-RATER FEATURES
# =============================================================================

launch_rater_participant_study <- function(
  port = 3841,
  host = "0.0.0.0",
  max_raters_per_participant = 3,
  agreement_threshold = 0.7
) {
  
  cat("🔗 RATER-PARTICIPANT DESIGN ASSESSMENT - MULTI-RATER FEATURES\n")
  cat("============================================================\n")
  cat("🎯 UNIQUE FEATURES DEMONSTRATED:\n")
  cat("   • Multi-Rater Assessment with Reliability Analysis\n")
  cat("   • Inter-Rater Reliability (ICC calculations)\n")
  cat("   • Advanced Sample Linking (Bidirectional)\n")
  cat("   • Quality Assurance & Rater Calibration\n")
  cat("   • Comprehensive Multi-Rater Reporting\n")
  cat("   • Agreement Analysis & Consensus Building\n")
  cat("============================================================\n\n")
  
  # Enhanced configuration for multi-rater demonstration
  enhanced_config <- rater_participant_config
  
  # Enable all multi-rater features
  enhanced_config$enhanced_features <- list(
    multi_rater_assessment = list(
      enabled = TRUE,
      max_raters_per_participant = max_raters_per_participant,
      rater_assignment_algorithm = "balanced",
      expertise_matching = TRUE,
      availability_scheduling = TRUE
    ),
    inter_rater_reliability = list(
      enabled = TRUE,
      icc_calculations = TRUE,
      agreement_analysis = TRUE,
      reliability_threshold = agreement_threshold,
      trend_monitoring = TRUE
    ),
    sample_linking = list(
      enabled = TRUE,
      bidirectional_linking = TRUE,
      multi_level_connections = TRUE,
      cross_validation_networks = TRUE,
      dynamic_assignment = TRUE
    ),
    quality_assurance = list(
      enabled = TRUE,
      agreement_thresholds = TRUE,
      rater_calibration = TRUE,
      performance_monitoring = TRUE,
      feedback_systems = TRUE
    ),
    comprehensive_reporting = list(
      enabled = TRUE,
      multi_rater_comparisons = TRUE,
      consensus_analysis = TRUE,
      disagreement_identification = TRUE,
      recommendation_systems = TRUE
    )
  )
  
  # Launch with enhanced features
  app <- inrep::launch_study(
    config = enhanced_config,
    item_bank = rater_participant_items,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
    study_key = session_uuid,
    fresh_session = TRUE,
    clear_cache = TRUE,
    language = "en",
    force_custom_ui = TRUE,
    enable_plots = TRUE,
    port = port,
    host = host
  )
  
  cat("🚀 STUDY LAUNCHED SUCCESSFULLY!\n")
  cat("📊 Access the study at: http://localhost:", port, "\n")
  cat("📈 Features available:\n")
  cat("   • Multi-rater assessment with 3+ raters per participant\n")
  cat("   • Inter-rater reliability analysis with ICC calculations\n")
  cat("   • Advanced sample linking and rater management\n")
  cat("   • Quality assurance with agreement thresholds\n")
  cat("   • Comprehensive multi-rater reporting and analysis\n")
  cat("   • Consensus building and disagreement resolution\n\n")
  
  return(app)
}

# =============================================================================
# DEMONSTRATION FUNCTIONS
# =============================================================================

# Function to demonstrate multi-rater assessment
demonstrate_multi_rater_assessment <- function(participant_id, rater_responses) {
  cat("🔗 MULTI-RATER ASSESSMENT DEMONSTRATION\n")
  cat("======================================\n")
  cat("This feature provides comprehensive multi-rater evaluation:\n\n")
  
  # Analyze multi-rater responses
  multi_rater_analysis <- analyze_multi_rater_responses(participant_id, rater_responses)
  
  cat("Multi-Rater Analysis for Participant", participant_id, ":\n")
  cat("• Number of Raters:", multi_rater_analysis$n_raters, "\n")
  cat("• Average Score:", sprintf("%.2f", multi_rater_analysis$average_score), "\n")
  cat("• Score Range:", sprintf("%.2f - %.2f", 
                                multi_rater_analysis$min_score, 
                                multi_rater_analysis$max_score), "\n")
  cat("• Standard Deviation:", sprintf("%.2f", multi_rater_analysis$sd_score), "\n")
  
  # Rater-specific analysis
  cat("\nRater-Specific Scores:\n")
  for (rater in names(multi_rater_analysis$rater_scores)) {
    cat("• Rater", rater, ":", sprintf("%.2f", multi_rater_analysis$rater_scores[[rater]]), "\n")
  }
  
  return(multi_rater_analysis)
}

# Function to demonstrate inter-rater reliability
demonstrate_inter_rater_reliability <- function(rater_data) {
  cat("📊 INTER-RATER RELIABILITY DEMONSTRATION\n")
  cat("=======================================\n")
  cat("This feature provides ICC calculations and agreement analysis:\n\n")
  
  # Calculate ICC values
  icc_results <- calculate_inter_rater_reliability(rater_data)
  
  cat("Inter-Rater Reliability Results:\n")
  cat("• ICC(1,1) - Single Rater, Absolute Agreement:", sprintf("%.3f", icc_results$icc_1_1), "\n")
  cat("• ICC(1,k) - Average Rater, Absolute Agreement:", sprintf("%.3f", icc_results$icc_1_k), "\n")
  cat("• ICC(2,1) - Single Rater, Consistency:", sprintf("%.3f", icc_results$icc_2_1), "\n")
  cat("• ICC(2,k) - Average Rater, Consistency:", sprintf("%.3f", icc_results$icc_2_k), "\n")
  
  # Agreement analysis
  agreement_analysis <- analyze_rater_agreement(rater_data)
  cat("\nAgreement Analysis:\n")
  cat("• Overall Agreement Rate:", sprintf("%.1f%%", agreement_analysis$overall_agreement * 100), "\n")
  cat("• Perfect Agreement:", sprintf("%.1f%%", agreement_analysis$perfect_agreement * 100), "\n")
  cat("• Disagreement Rate:", sprintf("%.1f%%", agreement_analysis$disagreement_rate * 100), "\n")
  
  # Reliability interpretation
  reliability_interpretation <- interpret_reliability(icc_results$icc_2_k)
  cat("\nReliability Interpretation:", reliability_interpretation, "\n")
  
  return(list(
    icc = icc_results,
    agreement = agreement_analysis,
    interpretation = reliability_interpretation
  ))
}

# Function to demonstrate sample linking
demonstrate_sample_linking <- function(participant_data, rater_data) {
  cat("🔗 SAMPLE LINKING DEMONSTRATION\n")
  cat("==============================\n")
  cat("This feature provides advanced bidirectional linking:\n\n")
  
  # Create sample links
  sample_links <- create_sample_links(participant_data, rater_data)
  
  cat("Sample Linking Results:\n")
  cat("• Total Participants:", sample_links$n_participants, "\n")
  cat("• Total Raters:", sample_links$n_raters, "\n")
  cat("• Total Assessments:", sample_links$n_assessments, "\n")
  cat("• Average Raters per Participant:", sprintf("%.1f", sample_links$avg_raters_per_participant), "\n")
  cat("• Average Participants per Rater:", sprintf("%.1f", sample_links$avg_participants_per_rater), "\n")
  
  # Link quality analysis
  link_quality <- analyze_link_quality(sample_links)
  cat("\nLink Quality Analysis:\n")
  cat("• Balanced Assignments:", sprintf("%.1f%%", link_quality$balanced_assignments * 100), "\n")
  cat("• Expertise Matching:", sprintf("%.1f%%", link_quality$expertise_matching * 100), "\n")
  cat("• Cross-Validation Coverage:", sprintf("%.1f%%", link_quality$cross_validation * 100), "\n")
  
  return(list(links = sample_links, quality = link_quality))
}

# Function to demonstrate quality assurance
demonstrate_quality_assurance <- function(rater_data) {
  cat("✅ QUALITY ASSURANCE DEMONSTRATION\n")
  cat("=================================\n")
  cat("This feature provides rater calibration and performance monitoring:\n\n")
  
  # Perform quality checks
  quality_checks <- perform_rater_quality_checks(rater_data)
  
  cat("Quality Assurance Results:\n")
  cat("• Rater Calibration Score:", sprintf("%.2f", quality_checks$calibration_score), "\n")
  cat("• Agreement Threshold Met:", quality_checks$agreement_threshold_met, "\n")
  cat("• Performance Monitoring:", quality_checks$performance_monitoring, "\n")
  
  # Individual rater performance
  cat("\nIndividual Rater Performance:\n")
  for (rater in names(quality_checks$rater_performance)) {
    perf <- quality_checks$rater_performance[[rater]]
    cat("• Rater", rater, ":\n")
    cat("  - Agreement Rate:", sprintf("%.1f%%", perf$agreement_rate * 100), "\n")
    cat("  - Consistency Score:", sprintf("%.2f", perf$consistency_score), "\n")
    cat("  - Bias Score:", sprintf("%.2f", perf$bias_score), "\n")
  }
  
  # Quality flags
  if (length(quality_checks$quality_flags) > 0) {
    cat("\nQuality Flags Raised:\n")
    for (flag in quality_checks$quality_flags) {
      cat("• ", flag, "\n")
    }
  } else {
    cat("\n✅ All quality checks passed\n")
  }
  
  return(quality_checks)
}

# Function to demonstrate comprehensive reporting
demonstrate_comprehensive_reporting <- function(multi_rater_results) {
  cat("📋 COMPREHENSIVE REPORTING DEMONSTRATION\n")
  cat("=======================================\n")
  cat("This feature provides multi-rater comparisons and consensus analysis:\n\n")
  
  # Generate comprehensive report
  comprehensive_report <- generate_multi_rater_report(multi_rater_results)
  
  cat("Comprehensive Report Generated:\n")
  cat("• Executive Summary:", comprehensive_report$executive_summary, "\n")
  cat("• Multi-Rater Comparisons:", length(comprehensive_report$comparisons), "participants\n")
  cat("• Consensus Analysis:", comprehensive_report$consensus_analysis, "\n")
  cat("• Disagreement Identification:", length(comprehensive_report$disagreements), "cases\n")
  cat("• Recommendations:", length(comprehensive_report$recommendations), "provided\n")
  
  # Consensus building
  consensus_results <- build_rater_consensus(multi_rater_results)
  cat("\nConsensus Building Results:\n")
  cat("• Consensus Achieved:", consensus_results$consensus_achieved, "\n")
  cat("• Consensus Score:", sprintf("%.2f", consensus_results$consensus_score), "\n")
  cat("• Disagreement Resolution:", consensus_results$disagreement_resolution, "\n")
  
  return(list(
    report = comprehensive_report,
    consensus = consensus_results
  ))
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

cat("🔗 RATER-PARTICIPANT DESIGN ASSESSMENT - MULTI-RATER FEATURES\n")
cat("============================================================\n")
cat("This case study demonstrates the multi-rater assessment capabilities of inrep:\n\n")
cat("🎯 UNIQUE FEATURES:\n")
cat("1. MULTI-RATER ASSESSMENT - Multiple raters evaluating participants with reliability analysis\n")
cat("2. INTER-RATER RELIABILITY - ICC calculations and agreement analysis\n")
cat("3. ADVANCED SAMPLE LINKING - Bidirectional linking between participants and raters\n")
cat("4. QUALITY ASSURANCE - Agreement thresholds and rater calibration\n")
cat("5. COMPREHENSIVE REPORTING - Multi-rater comparisons and consensus analysis\n\n")
cat("🚀 TO LAUNCH THE STUDY:\n")
cat("   launch_rater_participant_study()\n")
cat("   launch_rater_participant_study(max_raters_per_participant = 5)\n")
cat("   launch_rater_participant_study(agreement_threshold = 0.8)\n\n")
cat("📊 TO DEMONSTRATE FEATURES:\n")
cat("   # After completing the assessment:\n")
cat("   results <- get_study_results()\n")
cat("   demonstrate_multi_rater_assessment(participant_id, rater_responses)\n")
cat("   demonstrate_inter_rater_reliability(rater_data)\n")
cat("   demonstrate_sample_linking(participant_data, rater_data)\n")
cat("   demonstrate_quality_assurance(rater_data)\n")
cat("   demonstrate_comprehensive_reporting(multi_rater_results)\n\n")
cat("📈 TO EXPORT REPORTS:\n")
cat("   export_multi_rater_report(results, 'PDF')\n")
cat("   export_multi_rater_report(results, 'HTML')\n")
cat("   export_multi_rater_report(results, 'CSV')\n\n")
cat("============================================================\n")