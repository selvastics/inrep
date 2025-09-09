# =============================================================================
# DEPRESSION SCREENING ASSESSMENT - LAUNCH SCRIPT
# =============================================================================
# 
# This case study demonstrates the CLINICAL ASSESSMENT features of inrep:
# 
# 🏥 UNIQUE FEATURES HIGHLIGHTED:
# 1. CLINICAL CUTOFFS & SEVERITY CLASSIFICATION - Automatic severity assessment
# 2. RISK ASSESSMENT & INTERVENTION RECOMMENDATIONS - Actionable clinical insights
# 3. MULTIPLE VALIDATED INSTRUMENTS - PHQ-9, CES-D, BDI-II, DASS-21 integration
# 4. CLINICAL REPORTING - Professional reports with actionable recommendations
# 5. SAFETY PROTOCOLS - Crisis intervention and referral systems
#
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(inrep)
  library(shiny)
  library(ggplot2)
  library(plotly)
  library(DT)
  library(knitr)
})

# Source the study setup
source("study_setup.R")

# =============================================================================
# ENHANCED LAUNCH FUNCTION WITH CLINICAL FEATURES
# =============================================================================

launch_depression_screening_study <- function(
  port = 3840,
  host = "0.0.0.0",
  clinical_mode = TRUE,
  safety_protocols = TRUE
) {
  
  cat("🏥 DEPRESSION SCREENING ASSESSMENT - CLINICAL FEATURES\n")
  cat("====================================================\n")
  cat("🎯 UNIQUE FEATURES DEMONSTRATED:\n")
  cat("   • Clinical Cutoffs & Severity Classification\n")
  cat("   • Risk Assessment & Intervention Recommendations\n")
  cat("   • Multiple Validated Instruments (PHQ-9, CES-D, BDI-II, DASS-21)\n")
  cat("   • Clinical Reporting with Actionable Insights\n")
  cat("   • Safety Protocols & Crisis Intervention\n")
  cat("   • Professional-grade Clinical Documentation\n")
  cat("====================================================\n\n")
  
  # Enhanced configuration for clinical demonstration
  enhanced_config <- depression_screening_config
  
  # Enable all clinical features
  enhanced_config$enhanced_features <- list(
    clinical_assessment = list(
      enabled = clinical_mode,
      severity_classification = TRUE,
      clinical_cutoffs = TRUE,
      risk_assessment = TRUE,
      intervention_recommendations = TRUE
    ),
    validated_instruments = list(
      enabled = TRUE,
      instruments = c("PHQ-9", "CES-D", "BDI-II", "DASS-21"),
      cross_validation = TRUE,
      reliability_analysis = TRUE
    ),
    safety_protocols = list(
      enabled = safety_protocols,
      crisis_intervention = TRUE,
      referral_system = TRUE,
      emergency_contacts = TRUE,
      follow_up_protocols = TRUE
    ),
    clinical_reporting = list(
      enabled = TRUE,
      professional_reports = TRUE,
      actionable_recommendations = TRUE,
      treatment_planning = TRUE,
      progress_monitoring = TRUE
    ),
    quality_assurance = list(
      enabled = TRUE,
      reliability_checks = TRUE,
      validity_indicators = TRUE,
      response_consistency = TRUE
    )
  )
  
  # Launch with enhanced features
  app <- inrep::launch_study(
    config = enhanced_config,
    item_bank = depression_screening_items,
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
  cat(" Access the study at: http://localhost:", port, "\n")
  cat(" Features available:\n")
  cat("   • Clinical depression screening with validated instruments\n")
  cat("   • Automatic severity classification and risk assessment\n")
  cat("   • Intervention recommendations and treatment planning\n")
  cat("   • Safety protocols and crisis intervention systems\n")
  cat("   • Professional clinical reporting and documentation\n")
  cat("   • Quality assurance and reliability monitoring\n\n")
  
  return(app)
}

# =============================================================================
# DEMONSTRATION FUNCTIONS
# =============================================================================

# Function to demonstrate clinical cutoffs
demonstrate_clinical_cutoffs <- function(responses) {
  cat("🏥 CLINICAL CUTOFFS DEMONSTRATION\n")
  cat("================================\n")
  cat("This feature provides automatic severity classification:\n\n")
  
  # Calculate depression scores
  depression_scores <- calculate_depression_scores(responses)
  
  # Apply clinical cutoffs
  severity_classification <- classify_depression_severity(depression_scores)
  
  cat("Depression Severity Classification:\n")
  for (instrument in names(severity_classification)) {
    cat("• ", instrument, ": ", severity_classification[[instrument]]$severity, 
        " (Score: ", severity_classification[[instrument]]$score, ")\n")
  }
  
  # Risk assessment
  risk_level <- assess_depression_risk(depression_scores)
  cat("\nOverall Risk Level:", risk_level$level, "\n")
  cat("Risk Factors:", paste(risk_level$factors, collapse = ", "), "\n")
  
  return(list(
    scores = depression_scores,
    classification = severity_classification,
    risk = risk_level
  ))
}

# Function to demonstrate intervention recommendations
demonstrate_intervention_recommendations <- function(results) {
  cat("💡 INTERVENTION RECOMMENDATIONS DEMONSTRATION\n")
  cat("===========================================\n")
  cat("This feature provides actionable clinical insights:\n\n")
  
  # Generate intervention recommendations
  interventions <- generate_intervention_recommendations(results)
  
  cat("Recommended Interventions:\n")
  for (i in seq_along(interventions$recommendations)) {
    cat(i, ". ", interventions$recommendations[i], "\n")
  }
  
  cat("\nTreatment Planning:\n")
  cat("• Immediate Actions:", paste(interventions$immediate, collapse = ", "), "\n")
  cat("• Short-term Goals:", paste(interventions$short_term, collapse = ", "), "\n")
  cat("• Long-term Goals:", paste(interventions$long_term, collapse = ", "), "\n")
  
  # Referral recommendations
  if (interventions$referral_needed) {
    cat("\nReferral Recommendations:\n")
    for (referral in interventions$referrals) {
      cat("• ", referral, "\n")
    }
  }
  
  return(interventions)
}

# Function to demonstrate safety protocols
demonstrate_safety_protocols <- function(results) {
  cat("🚨 SAFETY PROTOCOLS DEMONSTRATION\n")
  cat("===============================\n")
  cat("This feature provides crisis intervention and safety measures:\n\n")
  
  # Assess safety risk
  safety_assessment <- assess_safety_risk(results)
  
  cat("Safety Assessment:\n")
  cat("• Suicide Risk Level:", safety_assessment$suicide_risk, "\n")
  cat("• Self-harm Risk Level:", safety_assessment$self_harm_risk, "\n")
  cat("• Crisis Intervention Needed:", safety_assessment$crisis_intervention, "\n")
  
  if (safety_assessment$crisis_intervention) {
    cat("\nCrisis Intervention Protocol Activated:\n")
    cat("• Emergency Contacts:", paste(safety_assessment$emergency_contacts, collapse = ", "), "\n")
    cat("• Immediate Actions:", paste(safety_assessment$immediate_actions, collapse = ", "), "\n")
    cat("• Follow-up Required:", safety_assessment$follow_up_required, "\n")
  }
  
  return(safety_assessment)
}

# Function to demonstrate clinical reporting
demonstrate_clinical_reporting <- function(results) {
  cat(" CLINICAL REPORTING DEMONSTRATION\n")
  cat("==================================\n")
  cat("This feature provides professional clinical documentation:\n\n")
  
  # Generate clinical report
  clinical_report <- generate_clinical_report(results)
  
  cat("Clinical Report Generated:\n")
  cat("• Executive Summary:", clinical_report$executive_summary, "\n")
  cat("• Assessment Results:", length(clinical_report$assessment_results), "instruments\n")
  cat("• Risk Factors:", length(clinical_report$risk_factors), "identified\n")
  cat("• Recommendations:", length(clinical_report$recommendations), "provided\n")
  cat("• Follow-up Plan:", clinical_report$follow_up_plan, "\n")
  
  # Export capabilities
  export_options <- c("PDF", "HTML", "DOCX", "CSV")
  cat("\nExport Options Available:\n")
  for (format in export_options) {
    cat("• ", format, " format\n")
  }
  
  return(clinical_report)
}

# Function to demonstrate quality assurance
demonstrate_quality_assurance <- function(results) {
  cat("✔ QUALITY ASSURANCE DEMONSTRATION\n")
  cat("=================================\n")
  cat("This feature provides reliability and validity monitoring:\n\n")
  
  # Perform quality checks
  quality_checks <- perform_quality_checks(results)
  
  cat("Quality Assurance Results:\n")
  cat("• Response Consistency:", quality_checks$consistency, "\n")
  cat("• Reliability Score:", quality_checks$reliability, "\n")
  cat("• Validity Indicators:", quality_checks$validity, "\n")
  cat("• Missing Data:", quality_checks$missing_data, "%\n")
  
  if (quality_checks$flags > 0) {
    cat("\nQuality Flags Raised:\n")
    for (flag in quality_checks$flag_details) {
      cat("• ", flag, "\n")
    }
  } else {
    cat("\n✔ All quality checks passed\n")
  }
  
  return(quality_checks)
}

# =============================================================================
# USAGE INSTRUCTIONS
# =============================================================================

cat("🏥 DEPRESSION SCREENING ASSESSMENT - CLINICAL FEATURES\n")
cat("====================================================\n")
cat("This case study demonstrates the clinical assessment capabilities of inrep:\n\n")
cat("🎯 UNIQUE FEATURES:\n")
cat("1. CLINICAL CUTOFFS - Automatic severity classification using validated instruments\n")
cat("2. RISK ASSESSMENT - Comprehensive risk evaluation with intervention recommendations\n")
cat("3. VALIDATED INSTRUMENTS - PHQ-9, CES-D, BDI-II, DASS-21 integration\n")
cat("4. CLINICAL REPORTING - Professional reports with actionable recommendations\n")
cat("5. SAFETY PROTOCOLS - Crisis intervention and referral systems\n\n")
cat("🚀 TO LAUNCH THE STUDY:\n")
cat("   launch_depression_screening_study()\n")
cat("   launch_depression_screening_study(clinical_mode = TRUE)\n")
cat("   launch_depression_screening_study(safety_protocols = TRUE)\n\n")
cat(" TO DEMONSTRATE FEATURES:\n")
cat("   # After completing the assessment:\n")
cat("   results <- get_study_results()\n")
cat("   demonstrate_clinical_cutoffs(results$responses)\n")
cat("   demonstrate_intervention_recommendations(results)\n")
cat("   demonstrate_safety_protocols(results)\n")
cat("   demonstrate_clinical_reporting(results)\n")
cat("   demonstrate_quality_assurance(results)\n\n")
cat(" TO EXPORT REPORTS:\n")
cat("   export_clinical_report(results, 'PDF')\n")
cat("   export_clinical_report(results, 'HTML')\n")
cat("   export_clinical_report(results, 'DOCX')\n\n")
cat("====================================================\n")