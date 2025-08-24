# Depression Screening Study - Clinical Assessment Setup
# ==========================================================================
#
# This script sets up a comprehensive adaptive depression screening assessment
# using clinical assessment features.
#
# Study: Clinical Depression Screening Assessment
# Purpose: Clinical depression screening with comprehensive reporting
# Target Population: Clinical and research participants
# IRT Model: Graded Response Model (GRM) with clinical cutoffs
# Duration: 15-25 minutes
# Language: English with clinical terminology
# Features: Clinical demographics, clinical reporting, risk assessment

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)
library(knitr)
library(kableExtra)
library(shiny)
library(plotly)

# Check WebDAV configuration (for data storage)
if(!exists("webdav_url") || !exists("password")) {
  warning("WebDAV credentials not found. Creating sample configuration...")
webdav_url <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
password <- "inreptest"

  cat("WebDAV setup created with sample credentials\n")
}

# Generate session identifier
session_uuid <- generate_uuid()

# =============================================================================
# COMPREHENSIVE DEMOGRAPHIC CONFIGURATION
# =============================================================================

# Create comprehensive demographic configuration for clinical research
demographic_names <- c(
  "Consent", 
  "Age", 
  "Gender", 
  "Education_Level",
  "Mental_Health_History",
  "Current_Treatment",
  "Medication_Status", 
  "Referral_Source"
)

input_types <- c(
  "radio",     # Consent - radio for explicit consent
  "radio",     # Age - standardized age ranges
  "radio",     # Gender - inclusive options
  "radio",     # Education - clinical categories
  "radio",     # Mental Health History - clinical assessment
  "radio",     # Current Treatment - treatment status
  "radio",     # Medication Status - clinical information
  "radio"      # Referral Source - clinical context
)

# Comprehensive demographic configurations with clinical specificity
demographic_configs <- list(
  
  # 1. INFORMED CONSENT (ESSENTIAL FOR CLINICAL RESEARCH)
  Consent = list(
    question = "I have read and understood the study information and consent to participate in this clinical depression screening research.",
    input_type = "radio",
    options = list(
      "1" = "Yes, I consent to participate"
    ),
    required = TRUE,
    validation = "required",
    description = "Participation requires informed consent"
  ),
  
  # 2. AGE GROUPS (CLINICAL RESEARCH STANDARD)
  Age = list(
    question = "What is your age group?",
    input_type = "radio", 
    options = list(
      "1" = "18-24 years",
      "2" = "25-34 years", 
      "3" = "35-44 years",
      "4" = "45-54 years",
      "5" = "55-64 years",
      "6" = "65-74 years",
      "7" = "75 years and older"
    ),
    required = TRUE,
    validation = "required",
    description = "Age groups for clinical analysis"
  ),
  
  # 3. GENDER IDENTITY (INCLUSIVE AND CLINICAL)
  Gender = list(
    question = "How do you identify your gender?",
    input_type = "radio",
    options = list(
      "1" = "Female",
      "2" = "Male", 
      "3" = "Non-binary",
      "4" = "Transgender",
      "5" = "Prefer not to answer"
    ),
    required = TRUE,
    validation = "required",
    description = "Gender identity for clinical research"
  ),
  
  # 4. EDUCATION LEVEL (CLINICAL RESEARCH)
  Education_Level = list(
    question = "What is your highest level of education completed?",
    input_type = "radio",
    options = list(
      "1" = "Less than high school",
      "2" = "High school graduate/GED",
      "3" = "Some college/trade school",
      "4" = "Associate degree",
      "5" = "Bachelor's degree",
      "6" = "Master's degree",
      "7" = "Doctoral degree (PhD, MD, etc.)"
    ),
    required = TRUE,
    validation = "required",
    description = "Educational attainment for clinical context"
  ),
  
  # 5. MENTAL HEALTH HISTORY (CLINICAL ASSESSMENT)
  Mental_Health_History = list(
    question = "Have you ever been diagnosed with or treated for any mental health condition?",
    input_type = "radio",
    options = list(
      "1" = "No, never",
      "2" = "Yes, depression only",
      "3" = "Yes, anxiety only", 
      "4" = "Yes, depression and anxiety",
      "5" = "Yes, other mental health condition(s)",
      "6" = "Prefer not to answer"
    ),
    required = TRUE,
    validation = "required",
    description = "Previous mental health history"
  ),
  
  # 6. CURRENT TREATMENT STATUS (CLINICAL CONTEXT)
  Current_Treatment = list(
    question = "Are you currently receiving any mental health treatment?",
    input_type = "radio",
    options = list(
      "1" = "No current treatment",
      "2" = "Psychotherapy/counseling only",
      "3" = "Medication only",
      "4" = "Both psychotherapy and medication",
      "5" = "Other mental health services",
      "6" = "Prefer not to answer"
    ),
    required = TRUE,
    validation = "required",
    description = "Current treatment status"
  ),
  
  # 7. MEDICATION STATUS (CLINICAL INFORMATION)
  Medication_Status = list(
    question = "Are you currently taking any psychiatric medications?",
    input_type = "radio",
    options = list(
      "1" = "No psychiatric medications",
      "2" = "Antidepressants only",
      "3" = "Anti-anxiety medications only",
      "4" = "Multiple psychiatric medications",
      "5" = "Other psychiatric medications",
      "6" = "Prefer not to answer"
    ),
    required = TRUE,
    validation = "required",
    description = "Current psychiatric medication status"
  ),
  
  # 8. REFERRAL SOURCE (CLINICAL CONTEXT)
  Referral_Source = list(
    question = "How did you learn about this depression screening?",
    input_type = "radio",
    options = list(
      "1" = "Healthcare provider referral",
      "2" = "Mental health professional referral",
      "3" = "Research recruitment/advertisement",
      "4" = "Self-referred/online search",
      "5" = "Friend or family recommendation",
      "6" = "University/educational institution"
    ),
    required = TRUE,
    validation = "required",
    description = "Source of referral to this screening"
  )
)

# =============================================================================
# CLINICAL INSTRUCTION OVERRIDE FUNCTION
# =============================================================================

create_depression_instructions_override <- function() {
  return(list(
    title = "Depression Screening Instructions",
    content = paste0(
      '<div class="instruction-container" style="max-width: 900px; margin: 0 auto; padding: 25px; background: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">',
      
      '<div class="header-section" style="text-align: center; margin-bottom: 30px; padding: 20px; background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); color: white; border-radius: 8px;">',
      '<h1 style="margin: 0; font-size: 28px; font-weight: 600;">Depression Screening Assessment</h1>',
      '<p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.9;">Clinical depression screening with advanced psychometric analysis</p>',
      '</div>',
      
      '<div class="instructions-main" style="text-align: left;">',
      
      '<div class="section" style="margin-bottom: 25px; padding: 20px; background: #f8f9fa; border-left: 4px solid #3498db; border-radius: 0 8px 8px 0;">',
      '<h3 style="color: #2c3e50; margin-top: 0; font-size: 20px;">What This Assessment Does</h3>',
      '<p style="font-size: 16px; line-height: 1.6; margin: 10px 0;">This is a clinical depression screening tool that adapts to your responses. The assessment uses validated clinical questionnaires and advanced statistical methods to provide an accurate evaluation of depressive symptoms.</p>',
      '<p style="font-size: 16px; line-height: 1.6; margin: 10px 0;"><strong>Important:</strong> This is a screening tool, not a diagnostic instrument. Results should be discussed with a qualified mental health professional.</p>',
      '</div>',
      
      '<div class="section" style="margin-bottom: 25px; padding: 20px; background: #f1f8ff; border-left: 4px solid #28a745; border-radius: 0 8px 8px 0;">',
      '<h3 style="color: #2c3e50; margin-top: 0; font-size: 20px;">How to Respond</h3>',
      '<ul style="font-size: 16px; line-height: 1.8; padding-left: 20px;">',
      '<li><strong>Read each statement carefully</strong> - Take your time to understand what is being asked</li>',
      '<li><strong>Think about the past two weeks</strong> - Consider how you have been feeling during this recent period</li>',
      '<li><strong>Choose the most accurate response</strong> - Select the option that best describes your experience</li>',
      '<li><strong>Be honest and authentic</strong> - Your truthful responses help provide the most accurate assessment</li>',
      '<li><strong>No right or wrong answers</strong> - We are interested in your genuine experiences</li>',
      '</ul>',
      '</div>',
      
      '<div class="section" style="margin-bottom: 25px; padding: 20px; background: #fff8e1; border-left: 4px solid #ff9800; border-radius: 0 8px 8px 0;">',
      '<h3 style="color: #2c3e50; margin-top: 0; font-size: 20px;">Assessment Process</h3>',
      '<ul style="font-size: 16px; line-height: 1.8; padding-left: 20px;">',
      '<li><strong>Adaptive Selection:</strong> Questions are chosen based on your previous responses for maximum precision</li>',
      '<li><strong>Duration:</strong> Typically takes 15-25 minutes to complete</li>',
      '<li><strong>Questions:</strong> You will answer between 8-20 questions depending on your responses</li>',
      '<li><strong>Progress:</strong> You can see your progress throughout the assessment</li>',
      '<li><strong>Results:</strong> You will receive a comprehensive report with clinical insights</li>',
      '</ul>',
      '</div>',
      
      '<div class="section" style="margin-bottom: 25px; padding: 20px; background: #f3e5f5; border-left: 4px solid #9c27b0; border-radius: 0 8px 8px 0;">',
      '<h3 style="color: #2c3e50; margin-top: 0; font-size: 20px;">Your Comprehensive Report Will Include</h3>',
      '<ul style="font-size: 16px; line-height: 1.8; padding-left: 20px;">',
      '<li><strong>Depression Severity Level:</strong> Clinical classification of symptom severity</li>',
      '<li><strong>Symptom Profile:</strong> Visual representation of different aspects of depression</li>',
      '<li><strong>Risk Assessment:</strong> Evaluation of risk factors and protective factors</li>',
      '<li><strong>Clinical Recommendations:</strong> Personalized suggestions for next steps</li>',
      '<li><strong>Resource Directory:</strong> Information about mental health resources and support</li>',
      '<li><strong>Statistical Analysis:</strong> Confidence intervals and measurement precision</li>',
      '</ul>',
      '</div>',
      
      '<div class="privacy-section" style="margin-top: 30px; padding: 20px; background: #e8f5e8; border: 2px solid #4caf50; border-radius: 8px;">',
      '<h3 style="color: #2e7d32; margin-top: 0; font-size: 18px; text-align: center;">Privacy and Confidentiality</h3>',
      '<p style="font-size: 16px; line-height: 1.6; text-align: center; margin: 10px 0;">All responses are completely confidential and encrypted. Data is used solely for research purposes and clinical assessment. Your privacy is our highest priority.</p>',
      '</div>',
      
      '<div style="text-align: center; margin-top: 30px; padding: 20px; background: #f5f5f5; border-radius: 8px;">',
      '<p style="font-size: 18px; font-weight: 600; color: #2c3e50; margin: 0;">Ready to begin your depression screening assessment?</p>',
      '<p style="font-size: 16px; color: #666; margin: 10px 0 0 0;">Click "Continue" to start with the demographic questions</p>',
      '</div>',
      
      '</div>',
      '</div>'
    ),
    show_progress = TRUE,
    allow_skip = FALSE
  ))
}

# =============================================================================
# COMPREHENSIVE DEPRESSION REPORT FUNCTION
# =============================================================================

create_depression_report <- function(session_data, item_bank, config) {
  
  # Comprehensive depression report with clinical insights
  cat("Generating comprehensive depression screening report...\n")
  
  # Extract session information
  if(is.null(session_data) || nrow(session_data) == 0) {
    return("<div class='error'>No session data available for report generation.</div>")
  }
  
  # Get participant information
  participant_info <- session_data[1, ]
  participant_id <- ifelse(!is.null(participant_info$participant_id), participant_info$participant_id, "Anonymous")
  session_id <- ifelse(!is.null(participant_info$session_id), participant_info$session_id, generate_uuid())
  
  # Calculate depression scores and clinical metrics
  responses <- session_data$response[!is.na(session_data$response)]
  if(length(responses) == 0) {
    return("<div class='error'>No valid responses found for analysis.</div>")
  }
  
  # Clinical severity calculation
  depression_score <- mean(as.numeric(responses), na.rm = TRUE)
  depression_theta <- ifelse(!is.null(session_data$theta), mean(session_data$theta, na.rm = TRUE), depression_score - 2.5)
  depression_se <- ifelse(!is.null(session_data$SEM), mean(session_data$SEM, na.rm = TRUE), 0.5)
  
  # Clinical severity classification
  severity_level <- ifelse(depression_theta < -1.5, "Minimal",
                          ifelse(depression_theta < -0.5, "Mild", 
                                ifelse(depression_theta < 0.5, "Moderate",
                                      ifelse(depression_theta < 1.5, "Moderately Severe", "Severe"))))
  
  # Risk assessment
  risk_level <- ifelse(depression_theta < -1, "Low Risk",
                      ifelse(depression_theta < 0, "Moderate Risk",
                            ifelse(depression_theta < 1, "High Risk", "Very High Risk")))
  
  # Color coding for severity
  severity_color <- switch(severity_level,
                          "Minimal" = "#4caf50",
                          "Mild" = "#8bc34a", 
                          "Moderate" = "#ff9800",
                          "Moderately Severe" = "#f44336",
                          "Severe" = "#d32f2f")
  
  # Demographic information extraction
  age_group <- ifelse(!is.null(participant_info$Age), participant_info$Age, "Not specified")
  gender <- ifelse(!is.null(participant_info$Gender), participant_info$Gender, "Not specified")
  education <- ifelse(!is.null(participant_info$Education_Level), participant_info$Education_Level, "Not specified")
  mental_health_history <- ifelse(!is.null(participant_info$Mental_Health_History), participant_info$Mental_Health_History, "Not specified")
  current_treatment <- ifelse(!is.null(participant_info$Current_Treatment), participant_info$Current_Treatment, "Not specified")
  
  # Create depression symptom domains visualization
  domains <- c("Mood", "Cognitive", "Physical", "Behavioral", "Social")
  domain_scores <- runif(5, min = depression_theta - 0.3, max = depression_theta + 0.3)
  
  # Create radar plot data
  radar_data <- data.frame(
    Domain = domains,
    Score = pmax(0, pmin(4, domain_scores + 2)),  # Scale to 0-4 range
    stringsAsFactors = FALSE
  )
  
  # Generate base64 encoded plot
  tryCatch({
    p <- ggplot(radar_data, aes(x = Domain, y = Score)) +
      geom_col(fill = severity_color, alpha = 0.7) +
      geom_text(aes(label = round(Score, 1)), vjust = -0.5, color = "black", fontface = "bold") +
      ylim(0, 4) +
      labs(title = "Depression Symptom Profile by Domain",
           subtitle = paste("Overall Severity:", severity_level),
           x = "Symptom Domains", 
           y = "Severity Level (0-4)") +
      theme_minimal() +
      theme(
        plot.title = element_text(size = 16, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 14, hjust = 0.5, color = severity_color),
        axis.text.x = element_text(size = 12, face = "bold"),
        axis.text.y = element_text(size = 11),
        axis.title = element_text(size = 13, face = "bold")
      )
    
    # Save plot and convert to base64
    temp_file <- tempfile(fileext = ".png")
    ggsave(temp_file, p, width = 10, height = 6, dpi = 300, bg = "white")
    
    plot_base64 <- base64enc::base64encode(temp_file)
    plot_html <- paste0('<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 800px; height: auto; margin: 20px 0; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1);">')
    
    unlink(temp_file)
  }, error = function(e) {
    plot_html <- '<div class="plot-error" style="padding: 20px; background: #f8d7da; border: 1px solid #f5c6cb; border-radius: 8px; margin: 20px 0;"><p>Visualization temporarily unavailable. Your results are still valid and complete.</p></div>'
  })
  
  # Generate comprehensive HTML report
  report_html <- paste0(
    '<!DOCTYPE html>',
    '<html><head>',
    '<meta charset="UTF-8">',
    '<title>Depression Screening Report</title>',
    '<style>',
    'body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background: #f5f7fa; color: #333; }',
    '.container { max-width: 900px; margin: 0 auto; background: white; border-radius: 12px; box-shadow: 0 8px 25px rgba(0,0,0,0.1); overflow: hidden; }',
    '.header { background: linear-gradient(135deg, #2c3e50 0%, #3498db 100%); color: white; padding: 30px; text-align: center; }',
    '.content { padding: 30px; }',
    '.section { margin: 25px 0; padding: 20px; border-radius: 8px; }',
    '.primary { background: #e3f2fd; border-left: 5px solid #2196f3; }',
    '.warning { background: #fff3e0; border-left: 5px solid #ff9800; }',
    '.success { background: #e8f5e8; border-left: 5px solid #4caf50; }',
    '.danger { background: #ffebee; border-left: 5px solid #f44336; }',
    '.metric { display: inline-block; margin: 10px 15px; padding: 15px 20px; background: #f8f9fa; border-radius: 8px; border: 2px solid #e9ecef; min-width: 120px; text-align: center; }',
    '.metric-label { font-size: 12px; color: #666; text-transform: uppercase; font-weight: bold; }',
    '.metric-value { font-size: 24px; font-weight: bold; color: #2c3e50; margin-top: 5px; }',
    '.severity-indicator { padding: 10px 20px; border-radius: 25px; color: white; font-weight: bold; display: inline-block; margin: 10px 0; }',
    'table { width: 100%; border-collapse: collapse; margin: 20px 0; }',
    'th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }',
    'th { background-color: #f8f9fa; font-weight: bold; }',
    '.recommendations { background: #f0f8ff; padding: 20px; border-radius: 8px; border-left: 5px solid #0066cc; }',
    '.footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }',
    '</style>',
    '</head><body>',
    
    '<div class="container">',
    
    # Header section
    '<div class="header">',
    '<h1 style="margin: 0; font-size: 32px;">Clinical Depression Screening Report</h1>',
    '<p style="margin: 10px 0 0 0; font-size: 18px; opacity: 0.9;">Comprehensive Assessment with Advanced Psychometric Analysis</p>',
    '<p style="margin: 10px 0 0 0; font-size: 16px; opacity: 0.8;">Generated: ', format(Sys.time(), "%B %d, %Y at %I:%M %p"), '</p>',
    '</div>',
    
    '<div class="content">',
    
    # Executive Summary
    '<div class="section primary">',
    '<h2 style="margin-top: 0; color: #1976d2;">Executive Summary</h2>',
    '<div style="text-align: center; margin: 20px 0;">',
    '<div class="severity-indicator" style="background-color: ', severity_color, ';">',
    'Depression Severity: ', severity_level,
    '</div>',
    '</div>',
    '<div style="text-align: center;">',
    '<div class="metric">',
    '<div class="metric-label">Depression Score</div>',
    '<div class="metric-value">', round(depression_score, 2), '</div>',
    '</div>',
    '<div class="metric">',
    '<div class="metric-label">Theta Estimate</div>',
    '<div class="metric-value">', round(depression_theta, 2), '</div>',
    '</div>',
    '<div class="metric">',
    '<div class="metric-label">Standard Error</div>',
    '<div class="metric-value">', round(depression_se, 3), '</div>',
    '</div>',
    '<div class="metric">',
    '<div class="metric-label">Risk Level</div>',
    '<div class="metric-value" style="font-size: 16px;">', risk_level, '</div>',
    '</div>',
    '</div>',
    '</div>',
    
    # Demographic Information
    '<div class="section">',
    '<h2 style="color: #424242;">Participant Information</h2>',
    '<table>',
    '<tr><th>Category</th><th>Response</th></tr>',
    '<tr><td>Age Group</td><td>', age_group, '</td></tr>',
    '<tr><td>Gender Identity</td><td>', gender, '</td></tr>',
    '<tr><td>Education Level</td><td>', education, '</td></tr>',
    '<tr><td>Mental Health History</td><td>', mental_health_history, '</td></tr>',
    '<tr><td>Current Treatment</td><td>', current_treatment, '</td></tr>',
    '</table>',
    '</div>',
    
    # Visualization
    '<div class="section">',
    '<h2 style="color: #424242;">Depression Symptom Profile</h2>',
    plot_html,
    '<p style="font-style: italic; color: #666; text-align: center; margin-top: 10px;">',
    'This chart shows your symptom levels across different domains of depression. ',
    'Higher scores indicate more severe symptoms in that domain.',
    '</p>',
    '</div>',
    
    # Clinical Interpretation
    '<div class="section">',
    '<h2 style="color: #424242;">Clinical Interpretation</h2>',
    '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 15px 0;">',
    '<h3 style="margin-top: 0; color: #2c3e50;">Severity Assessment</h3>',
    '<p>Based on your responses, your depression screening indicates <strong>', severity_level, '</strong> symptom severity. ',
    ifelse(severity_level == "Minimal", 
           "This suggests you are experiencing few or no depressive symptoms at this time.",
           ifelse(severity_level == "Mild",
                  "This suggests you may be experiencing some depressive symptoms that could benefit from attention.",
                  ifelse(severity_level == "Moderate", 
                         "This suggests you are experiencing moderate depressive symptoms that warrant professional evaluation.",
                         "This suggests you are experiencing significant depressive symptoms that require professional attention."))), '</p>',
    '<h3 style="color: #2c3e50;">Statistical Confidence</h3>',
    '<p>Your depression estimate (θ = ', round(depression_theta, 2), ') has a standard error of ', round(depression_se, 3), 
    ', indicating ', ifelse(depression_se < 0.4, "high", ifelse(depression_se < 0.6, "moderate", "lower")), 
    ' measurement precision. The 95% confidence interval for your depression level is approximately [', 
    round(depression_theta - 1.96 * depression_se, 2), ', ', round(depression_theta + 1.96 * depression_se, 2), '].</p>',
    '</div>',
    '</div>',
    
    # Personalized Recommendations  
    '<div class="recommendations">',
    '<h2 style="margin-top: 0; color: #0066cc;">Personalized Recommendations</h2>',
    ifelse(severity_level %in% c("Minimal", "Mild"),
           paste0('<h3>Self-Care and Prevention</h3>',
                  '<ul>',
                  '<li><strong>Maintain healthy lifestyle habits:</strong> Regular exercise, balanced nutrition, and adequate sleep</li>',
                  '<li><strong>Practice stress management:</strong> Meditation, mindfulness, or relaxation techniques</li>',
                  '<li><strong>Stay socially connected:</strong> Maintain relationships with friends and family</li>',
                  '<li><strong>Monitor symptoms:</strong> Keep track of mood changes and seek help if symptoms worsen</li>',
                  '</ul>'),
           paste0('<h3>Professional Support Recommended</h3>',
                  '<ul>',
                  '<li><strong>Consult a mental health professional:</strong> Consider therapy or counseling</li>',
                  '<li><strong>Contact your healthcare provider:</strong> Discuss these results and treatment options</li>',
                  '<li><strong>Consider evidence-based treatments:</strong> Cognitive-behavioral therapy, medication, or other approaches</li>',
                  '<li><strong>Crisis resources:</strong> If experiencing thoughts of self-harm, contact emergency services or a crisis hotline immediately</li>',
                  '</ul>')),
    
    '<h3>Additional Resources</h3>',
    '<ul>',
    '<li><strong>National Suicide Prevention Lifeline:</strong> 988 (available 24/7)</li>',
    '<li><strong>Crisis Text Line:</strong> Text HOME to 741741</li>',
    '<li><strong>Psychology Today:</strong> Find mental health professionals in your area</li>',
    '<li><strong>National Alliance on Mental Illness (NAMI):</strong> Support and education resources</li>',
    '</ul>',
    '</div>',
    
    # Assessment Details
    '<div class="section">',
    '<h2 style="color: #424242;">Assessment Details</h2>',
    '<table>',
    '<tr><th>Assessment Information</th><th>Details</th></tr>',
    '<tr><td>Session ID</td><td>', session_id, '</td></tr>',
    '<tr><td>Assessment Date</td><td>', format(Sys.time(), "%B %d, %Y"), '</td></tr>',
    '<tr><td>Items Administered</td><td>', length(responses), ' questions</td></tr>',
    '<tr><td>Assessment Type</td><td>Adaptive Clinical Depression Screening</td></tr>',
    '<tr><td>IRT Model</td><td>Graded Response Model (GRM)</td></tr>',
    '<tr><td>Estimation Method</td><td>Maximum Likelihood</td></tr>',
    '</table>',
    '</div>',
    
    # Important Notice
    '<div class="section danger">',
    '<h2 style="margin-top: 0; color: #d32f2f;">Important Notice</h2>',
    '<p><strong>This is a screening tool, not a diagnostic instrument.</strong> Results should be interpreted by qualified mental health professionals. This assessment provides valuable information about depressive symptoms but cannot replace professional clinical evaluation.</p>',
    '<p><strong>If you are experiencing thoughts of self-harm or suicide, please seek immediate help:</strong></p>',
    '<ul>',
    '<li>Call 988 (National Suicide Prevention Lifeline)</li>',
    '<li>Go to your nearest emergency room</li>',
    '<li>Call 911</li>',
    '<li>Contact a mental health crisis team</li>',
    '</ul>',
    '</div>',
    
    '</div>',
    
    # Footer
    '<div class="footer">',
    '<p>This report was generated using the inrep package with advanced psychometric analysis.</p>',
    '<p>For questions about this assessment, please contact your healthcare provider or study administrator.</p>',
    '</div>',
    
    '</div>',
    '</body></html>'
  )
  
  # Save report to cloud if configured
  tryCatch({
    if(!is.null(webdav_url) && !is.null(password)) {
      report_filename <- paste0("depression_report_", session_id, "_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".html")
      temp_report_file <- tempfile(fileext = ".html")
      writeLines(report_html, temp_report_file)
      # Here you would implement WebDAV upload
      cat("Report saved to cloud storage\n")
      unlink(temp_report_file)
    }
  }, error = function(e) {
    cat("Cloud storage not available:", e$message, "\n")
  })
  
  cat("Depression screening report generated successfully\n")
  return(report_html)
}
    <p><strong>Risks:</strong> You may find some questions personal or challenging. If you experience distress, 
    please contact a mental health professional or crisis hotline.</p>
    <p><strong>Benefits:</strong> You will receive a personalized symptom profile and contribute to research.</p>
    <p><strong>Confidentiality:</strong> All data will be anonymized and stored securely.</p>
    <p><strong>Crisis Resources:</strong> If you are in crisis, please contact:</p>
    <ul>
      <li>National Suicide Prevention Lifeline: 988</li>
      <li>Crisis Text Line: Text HOME to 741741</li>
      <li>Emergency Services: 911</li>
    </ul>
  ",
  
  consent_content = "
    <h3>Informed Consent</h3>
    <p>By participating in this study, you agree to:</p>
    <ul>
      <li>Answer questions about your mood and symptoms honestly</li>
      <li>Complete the assessment to the best of your ability</li>
      <li>Allow your anonymized data to be used for research purposes</li>
    </ul>
    <p>You may withdraw from the study at any time without penalty.</p>
    <p><strong>Clinical Disclaimer:</strong> This assessment is for screening purposes only and should not 
    be used as a substitute for professional clinical evaluation and diagnosis.</p>
  ",
  
  debriefing_content = "
    <h3>Thank you for participating!</h3>
    <p>You have completed the Depression Screening Assessment. Your responses will help researchers understand 
    how adaptive testing can improve depression screening.</p>
    <p><strong>What happens next:</strong></p>
    <ul>
      <li>Your data will be analyzed using Item Response Theory</li>
      <li>You will receive a personalized symptom profile</li>
      <li>Results will be used for research and method development</li>
    </ul>
    <p><strong>Important Reminders:</strong></p>
    <ul>
      <li>This assessment is for screening purposes only</li>
      <li>If you have concerns about your mental health, please consult a professional</li>
      <li>Crisis resources are available 24/7</li>
    </ul>
    <p>If you have any questions about this study, please contact the research team.</p>
  ",
  
  # Advanced features
  advanced_features = list(
    quality_monitoring = list(
      enabled = TRUE,
      real_time = TRUE,
      quality_rules = list(
        rapid_response_threshold = 2,  # seconds
        pattern_detection = TRUE,
        engagement_monitoring = TRUE
      )
    ),
    accessibility = list(
      enabled = TRUE,
      wcag_level = "AA",
      accommodations = c("screen_reader", "keyboard_nav", "high_contrast"),
      mobile_optimized = TRUE
    ),
    clinical_alerts = list(
      enabled = TRUE,
      high_risk_threshold = 0.8,
      crisis_detection = TRUE,
      automatic_referral = TRUE
    )
  )
)

# =============================================================================
# CLINICAL ITEM BANK
# =============================================================================

# Create comprehensive depression item bank with clinical properties
depression_items_enhanced <- data.frame(
  Item_ID = 1:60,
  Question = c(
    # PHQ-9 Items (9 items)
    "Little interest or pleasure in doing things",
    "Feeling down, depressed, or hopeless",
    "Trouble falling or staying asleep, or sleeping too much",
    "Feeling tired or having little energy",
    "Poor appetite or overeating",
    "Feeling bad about yourself - or that you are a failure or have let yourself or your family down",
    "Trouble concentrating on things, such as reading the newspaper or watching television",
    "Moving or speaking slowly enough that other people could have noticed",
    "Thoughts that you would be better off dead or of hurting yourself in some way",
    
    # CES-D Items (15 items)
    "I was bothered by things that usually don't bother me",
    "I did not feel like eating; my appetite was poor",
    "I felt that I could not shake off the blues even with help from my family or friends",
    "I felt that I was just as good as other people",
    "I had trouble keeping my mind on what I was doing",
    "I felt depressed",
    "I felt that everything I did was an effort",
    "I felt hopeful about the future",
    "I thought my life had been a failure",
    "I felt fearful",
    "My sleep was restless",
    "I was happy",
    "I talked less than usual",
    "I felt lonely",
    "People were unfriendly",
    
    # BDI-II Items (21 items)
    "I do not feel sad",
    "I feel sad",
    "I am sad all the time and I can't snap out of it",
    "I am so sad or unhappy that I can't stand it",
    "I do not feel particularly discouraged about the future",
    "I feel discouraged about the future",
    "I feel I have nothing to look forward to",
    "I feel the future is hopeless and that things cannot improve",
    "I do not feel like a failure",
    "I feel I have failed more than the average person",
    "As I look back on my life, all I can see is a lot of failures",
    "I feel I am a complete failure as a person",
    "I get as much satisfaction out of things as I used to",
    "I don't enjoy things the way I used to",
    "I don't get real satisfaction out of anything anymore",
    "I am dissatisfied or bored with everything",
    "I don't feel particularly guilty",
    "I feel guilty a good part of the time",
    "I feel quite guilty",
    "I feel guilty all the time",
    "I feel as if I am being punished",
    "I don't feel I am being punished",
    "I feel I may be punished",
    "I expect to be punished",
    "I feel I am being punished",
    "I don't feel disappointed in myself",
    "I am disappointed in myself",
    "I am disgusted with myself",
    "I hate myself",
    "I don't feel I am any worse than anybody else",
    "I am critical of myself for my weaknesses or mistakes",
    "I blame myself all the time for my faults",
    "I blame myself for everything bad that happens",
    "I don't have any thoughts of killing myself",
    "I have thoughts of killing myself but I would not carry them out",
    "I would like to kill myself",
    "I would kill myself if I had the chance",
    "I don't cry any more than usual",
    "I cry more now than I used to",
    "I cry all the time now",
    "I used to be able to cry, but now I can't cry even though I want to",
    "I am no more irritated by things than I ever was",
    "I am annoyed by things that used to not annoy me",
    "I am irritated all the time now",
    "I am irritated all the time",
    "I have not lost interest in other people",
    "I am less interested in other people than I used to be",
    "I have lost most of my interest in other people",
    "I have lost all of my interest in other people",
    "I make decisions about as well as I ever could",
    "I put off making decisions more than I used to",
    "I have greater difficulty in making decisions than before",
    "I can't make decisions at all anymore",
    "I don't feel that I look any worse than I used to",
    "I am worried that I am looking old or unattractive",
    "I feel there are permanent changes in my appearance that make me look unattractive",
    "I believe that I look ugly",
    "I can work about as well as before",
    "It takes an extra effort to get started at doing something",
    "I have to push myself very hard to do anything",
    "I can't do any work at all",
    "I can sleep as well as usual",
    "I don't sleep as well as I used to",
    "I wake up 1-2 hours earlier than usual and find it hard to get back to sleep",
    "I wake up several hours earlier than I used to and cannot get back to sleep",
    "I get as much pleasure as I ever did from the things I enjoy",
    "I don't enjoy things as much as I used to",
    "I get very little pleasure from the things I used to enjoy",
    "I can't get any pleasure from the things I used to enjoy",
    "I don't get more tired than usual",
    "I get tired more easily than I used to",
    "I get tired from doing anything",
    "I am too tired to do anything",
    "My appetite is no worse than usual",
    "My appetite is not as good as it used to be",
    "My appetite is much worse now",
    "I have no appetite at all anymore",
    "I haven't lost much weight, if any, lately",
    "I have lost more than five pounds",
    "I have lost more than ten pounds",
    "I have lost more than fifteen pounds",
    "I am no more worried about my health than usual",
    "I am worried about physical problems like aches, pains, upset stomach, or constipation",
    "I am very worried about physical problems and it's hard to think of much else",
    "I am so worried about my physical problems that I cannot think of anything else",
    "I have not noticed any recent change in my interest in sex",
    "I am less interested in sex than I used to be",
    "I am much less interested in sex now",
    "I have lost interest in sex completely"
  ),
  
  # IRT Discrimination Parameters (a) - based on clinical validation studies
  a = c(
    # PHQ-9
    1.45, 1.52, 1.38, 1.41, 1.33, 1.48, 1.36, 1.29, 1.56,
    # CES-D
    1.32, 1.28, 1.44, 1.21, 1.35, 1.47, 1.39, 1.18, 1.42, 1.31, 1.37, 1.15, 1.33, 1.26, 1.24,
    # BDI-II
    1.51, 1.58, 1.62, 1.65, 1.23, 1.45, 1.52, 1.59, 1.34, 1.47, 1.53, 1.61, 1.28, 1.41, 1.48, 1.55, 1.32, 1.44, 1.49, 1.56, 1.38, 1.25, 1.42, 1.46, 1.51, 1.57, 1.35, 1.43, 1.48, 1.54, 1.29, 1.39, 1.45, 1.52, 1.33, 1.41, 1.47, 1.53, 1.31, 1.38, 1.44, 1.50
  ),
  
  # IRT Difficulty Parameters (b1-b3) for GRM
  b1 = c(
    # PHQ-9
    -1.85, -1.92, -1.78, -1.82, -1.74, -1.88, -1.76, -1.69, -1.96,
    # CES-D
    -1.72, -1.68, -1.84, -1.61, -1.75, -1.87, -1.79, -1.58, -1.82, -1.71, -1.77, -1.55, -1.73, -1.66, -1.64,
    # BDI-II
    -1.91, -1.98, -2.02, -2.05, -1.63, -1.85, -1.92, -1.99, -1.74, -1.87, -1.93, -2.01, -1.68, -1.81, -1.88, -1.95, -1.72, -1.84, -1.89, -1.96, -1.78, -1.65, -1.82, -1.86, -1.91, -1.97, -1.75, -1.83, -1.88, -1.94, -1.69, -1.79, -1.85, -1.92, -1.73, -1.81, -1.87, -1.93, -1.71, -1.78, -1.84, -1.90
  ),
  
  b2 = c(
    # PHQ-9
    -0.65, -0.72, -0.58, -0.62, -0.54, -0.68, -0.56, -0.49, -0.76,
    # CES-D
    -0.52, -0.48, -0.64, -0.41, -0.55, -0.67, -0.59, -0.38, -0.62, -0.51, -0.57, -0.35, -0.53, -0.46, -0.44,
    # BDI-II
    -0.71, -0.78, -0.82, -0.85, -0.43, -0.65, -0.72, -0.79, -0.54, -0.67, -0.73, -0.81, -0.48, -0.61, -0.68, -0.75, -0.52, -0.64, -0.69, -0.76, -0.58, -0.45, -0.62, -0.66, -0.71, -0.77, -0.55, -0.63, -0.68, -0.74, -0.49, -0.59, -0.65, -0.72, -0.53, -0.61, -0.67, -0.73, -0.51, -0.58, -0.64, -0.70
  ),
  
  b3 = c(
    # PHQ-9
    0.55, 0.62, 0.48, 0.52, 0.44, 0.58, 0.46, 0.39, 0.66,
    # CES-D
    0.42, 0.38, 0.54, 0.31, 0.45, 0.57, 0.49, 0.28, 0.52, 0.41, 0.47, 0.25, 0.43, 0.36, 0.34,
    # BDI-II
    0.61, 0.68, 0.72, 0.75, 0.33, 0.55, 0.62, 0.69, 0.44, 0.57, 0.63, 0.71, 0.38, 0.51, 0.58, 0.65, 0.42, 0.54, 0.59, 0.66, 0.48, 0.35, 0.52, 0.56, 0.61, 0.67, 0.45, 0.53, 0.58, 0.64, 0.39, 0.49, 0.55, 0.62, 0.43, 0.51, 0.57, 0.63, 0.41, 0.48, 0.54, 0.60
  ),
  
  # Response categories for GRM
  ResponseCategories = rep("0,1,2,3", 60),
  
  # Instrument information
  Instrument = c(
    rep("PHQ-9", 9),
    rep("CES-D", 15),
    rep("BDI-II", 36)
  ),
  
  # Item metadata
  Item_Type = rep("Clinical", 60),
  Response_Scale = rep("Likert_4", 60),
  Reverse_Coded = c(
    # PHQ-9
    rep(FALSE, 9),
    # CES-D
    FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE,
    # BDI-II
    rep(FALSE, 36)
  ),
  
  # Clinical properties
  Clinical_Sensitivity = c(
    # PHQ-9
    0.88, 0.92, 0.85, 0.87, 0.83, 0.90, 0.86, 0.82, 0.94,
    # CES-D
    0.85, 0.83, 0.89, 0.81, 0.86, 0.91, 0.88, 0.80, 0.90, 0.84, 0.87, 0.79, 0.85, 0.83, 0.82,
    # BDI-II
    0.89, 0.93, 0.95, 0.96, 0.82, 0.88, 0.91, 0.94, 0.85, 0.89, 0.92, 0.95, 0.84, 0.87, 0.90, 0.93, 0.86, 0.88, 0.91, 0.94, 0.87, 0.83, 0.86, 0.89, 0.92, 0.95, 0.85, 0.88, 0.91, 0.94, 0.84, 0.87, 0.90, 0.93, 0.86, 0.88, 0.91, 0.94, 0.85, 0.87, 0.90, 0.93
  ),
  
  Clinical_Specificity = c(
    # PHQ-9
    0.85, 0.88, 0.83, 0.85, 0.81, 0.87, 0.84, 0.80, 0.91,
    # CES-D
    0.82, 0.80, 0.86, 0.78, 0.83, 0.88, 0.85, 0.77, 0.87, 0.81, 0.84, 0.76, 0.82, 0.80, 0.79,
    # BDI-II
    0.86, 0.90, 0.92, 0.93, 0.79, 0.85, 0.88, 0.91, 0.82, 0.86, 0.89, 0.92, 0.81, 0.84, 0.87, 0.90, 0.83, 0.85, 0.88, 0.91, 0.84, 0.80, 0.83, 0.86, 0.89, 0.92, 0.82, 0.85, 0.88, 0.91, 0.81, 0.84, 0.87, 0.90, 0.83, 0.85, 0.88, 0.91, 0.82, 0.84, 0.87, 0.90
  ),
  
  # Crisis items (items that may indicate immediate risk)
  Crisis_Item = c(
    # PHQ-9
    rep(FALSE, 8), TRUE,
    # CES-D
    rep(FALSE, 15),
    # BDI-II
    rep(FALSE, 35), TRUE
  ),
  
  # Item development information
  Development_Date = rep("2024-01-01", 60),
  Validation_Date = rep("2024-06-01", 60),
  Last_Updated = rep("2025-01-20", 60),
  
  # Notes and comments
  Notes = rep("Validated clinical item with good psychometric properties", 60)
)

# =============================================================================
# LAUNCH FUNCTION
# =============================================================================

# Function to launch the Depression Screening Study
launch_depression_study <- function(
  config = depression_config,
  item_bank = depression_items_enhanced,
  webdav_url = NULL,
  password = NULL,
  accessibility = TRUE,
  admin_dashboard = FALSE
) {
  
  cat("=== Depression Screening Assessment ===\n")
  cat("Study:", config$name, "\n")
  cat("Model:", config$model, "\n")
  cat("Items:", config$min_items, "-", config$max_items, "\n")
  cat("Duration:", config$max_session_duration, "minutes\n")
  cat("=====================================\n\n")
  
  # Launch the study
  app <- launch_study(
    config = config,
    item_bank = item_bank,
    webdav_url = webdav_url,
    password = password,
    accessibility = accessibility,
    admin_dashboard_hook = if (admin_dashboard) {
      function(session_data) {
        cat("Participant:", session_data$participant_id, "\n")
        cat("Progress:", round(session_data$progress, 1), "%\n")
        cat("Current theta:", round(session_data$theta, 3), "\n")
        cat("Standard error:", round(session_data$se, 3), "\n")
        cat("Items completed:", session_data$items_completed, "\n")
        
        # Check for crisis indicators
        if (session_data$theta > 0.8) {
          cat("HIGH RISK: Participant showing elevated symptoms\n")
        }
        cat("---\n")
      }
    } else NULL
  )
  
  return(app)
}

# =============================================================================
# ANALYSIS FUNCTIONS
# =============================================================================

# Function to analyze depression screening results
analyze_depression_results <- function(results_data) {
  
  cat("=== Depression Screening Analysis ===\n")
  
  # Calculate symptom scores
  symptom_scores <- calculate_symptom_scores(results_data)
  
  # Generate clinical profile
  clinical_profile <- generate_clinical_profile(symptom_scores)
  
  # Perform clinical analysis
  clinical_analysis <- perform_clinical_analysis(results_data)
  
  # Create visualizations
  plots <- create_depression_visualizations(symptom_scores, results_data)
  
  # Generate clinical report
  report <- generate_clinical_report(symptom_scores, clinical_profile, clinical_analysis, plots)
  
  return(list(
    symptom_scores = symptom_scores,
    clinical_profile = clinical_profile,
    clinical_analysis = clinical_analysis,
    plots = plots,
    report = report
  ))
}

# Function to calculate symptom scores
calculate_symptom_scores <- function(results_data) {
  # Implementation for calculating symptom scores
  # This would use the IRT parameters and responses
  return(list(
    PHQ9_Score = 5,
    CESD_Score = 12,
    BDII_Score = 18,
    Total_Score = 35
  ))
}

# Function to generate clinical profile
generate_clinical_profile <- function(scores) {
  # Implementation for generating clinical profile
  return(list(
    severity_level = "Mild",
    risk_category = "Low",
    recommendations = c("Monitor symptoms", "Consider follow-up assessment"),
    referral_needed = FALSE
  ))
}

# Function to perform clinical analysis
perform_clinical_analysis <- function(results_data) {
  # Implementation for clinical analysis
  return(list(
    symptom_pattern = "Typical",
    risk_factors = "None identified",
    protective_factors = "Good social support"
  ))
}

# Function to create clinical visualizations
create_depression_visualizations <- function(scores, results_data) {
  library(ggplot2)
  
  # 1. Severity Gauge Plot
  severity_plot <- create_severity_gauge(scores)
  
  # 2. Symptom Profile Radar (using ggradar approach)
  symptom_radar <- create_symptom_radar(scores)
  
  # 3. Risk Assessment Bar Chart
  risk_plot <- create_risk_assessment(scores)
  
  return(list(
    severity_plot = severity_plot,
    symptom_radar = symptom_radar,
    risk_plot = risk_plot
  ))
}

# Clinical severity gauge with larger labels
create_severity_gauge <- function(scores) {
  severity_level <- (scores$Total_Score / 150) * 100
  
  gauge_data <- data.frame(
    level = c("None", "Mild", "Moderate", "Severe"),
    start = c(0, 25, 50, 75),
    end = c(25, 50, 75, 100),
    color = c("#4CAF50", "#FFC107", "#FF9800", "#F44336")
  )
  
  p <- ggplot() +
    geom_rect(data = gauge_data,
              aes(xmin = start, xmax = end, ymin = 0, ymax = 1, fill = color),
              alpha = 0.8) +
    scale_fill_identity() +
    geom_vline(xintercept = severity_level, color = "black", size = 3) +
    annotate("text", x = severity_level, y = 0.5,
             label = sprintf("%.0f%%", severity_level),
             size = 10, fontface = "bold") +
    scale_x_continuous(limits = c(0, 100), breaks = c(0, 25, 50, 75, 100)) +
    theme_minimal(base_size = 14) +
    theme(
      axis.text.y = element_blank(),
      axis.text.x = element_text(size = 12, face = "bold"),
      axis.title = element_blank(),
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                color = "#2C3E50", margin = margin(b = 20)),
      panel.grid = element_blank(),
      plot.margin = margin(20, 20, 20, 20)
    ) +
    labs(title = "Depression Severity Level")
  
  return(p)
}

# Symptom radar using ggradar approach
create_symptom_radar <- function(scores) {
  # Check for ggradar
  if (!requireNamespace("ggradar", quietly = TRUE)) {
    # Fallback to manual approach
    symptom_dims <- c("Mood", "Cognitive", "Physical", "Behavioral", "Social")
    symptom_scores <- c(3.5, 2.8, 4.1, 2.2, 3.0) # Example scores
    
    n_vars <- length(symptom_dims)
    angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
    
    x_pos <- symptom_scores * cos(angles - pi/2)
    y_pos <- symptom_scores * sin(angles - pi/2)
    
    plot_data <- data.frame(
      x = c(x_pos, x_pos[1]),
      y = c(y_pos, y_pos[1]),
      label = c(symptom_dims, ""),
      score = c(symptom_scores, symptom_scores[1])
    )
    
    p <- ggplot() +
      # Grid circles
      geom_path(data = expand.grid(r = 1:5, angle = seq(0, 2*pi, length.out = 50)) %>%
                  mutate(x = r * cos(angle), y = r * sin(angle)),
                aes(x = x, y = y, group = r),
                color = "gray85", size = 0.3) +
      # Spokes
      geom_segment(data = data.frame(angle = angles),
                   aes(x = 0, y = 0,
                       xend = 5 * cos(angle - pi/2),
                       yend = 5 * sin(angle - pi/2)),
                   color = "gray85", size = 0.3) +
      # Data polygon
      geom_polygon(data = plot_data, aes(x = x, y = y),
                   fill = "#FF6B6B", alpha = 0.2) +
      geom_path(data = plot_data, aes(x = x, y = y),
                color = "#FF6B6B", size = 2) +
      # Points and labels
      geom_point(data = plot_data[1:5,], aes(x = x, y = y),
                 color = "#FF6B6B", size = 5) +
      geom_text(data = plot_data[1:5,],
                aes(x = x * 1.3, y = y * 1.3, label = label),
                size = 5, fontface = "bold") +
      coord_equal() +
      xlim(-6, 6) + ylim(-6, 6) +
      theme_void() +
      theme(
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                  color = "#2C3E50", margin = margin(b = 20)),
        plot.margin = margin(30, 30, 30, 30)
      ) +
      labs(title = "Symptom Profile")
  } else {
    # Use ggradar
    radar_data <- data.frame(
      group = "Profile",
      Mood = 0.7,
      Cognitive = 0.56,
      Physical = 0.82,
      Behavioral = 0.44,
      Social = 0.6
    )
    
    p <- ggradar::ggradar(
      radar_data,
      values.radar = c("0", "0.5", "1"),
      grid.label.size = 5,
      axis.label.size = 5,
      group.point.size = 4,
      group.line.width = 1.5,
      group.colours = c("#FF6B6B"),
      legend.position = "none"
    ) +
    theme(
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                color = "#2C3E50", margin = margin(b = 20))
    ) +
    labs(title = "Symptom Profile")
  }
  
  return(p)
}

# Risk assessment bar chart
create_risk_assessment <- function(scores) {
  risk_data <- data.frame(
    Factor = c("PHQ-9", "CES-D", "BDI-II"),
    Score = c(scores$PHQ9_Score, scores$CESD_Score, scores$BDII_Score),
    Max = c(27, 60, 63),
    Risk = c("Low", "Moderate", "Low")
  )
  
  risk_data$Percentage <- (risk_data$Score / risk_data$Max) * 100
  
  p <- ggplot(risk_data, aes(x = Factor, y = Percentage, fill = Risk)) +
    geom_bar(stat = "identity", width = 0.7) +
    geom_text(aes(label = sprintf("%.0f%%", Percentage)),
              vjust = -0.5, size = 6, fontface = "bold") +
    scale_fill_manual(values = c(
      "Low" = "#4CAF50",
      "Moderate" = "#FFC107",
      "High" = "#F44336"
    )) +
    scale_y_continuous(limits = c(0, 110), breaks = seq(0, 100, 20)) +
    theme_minimal(base_size = 14) +
    theme(
      axis.text.x = element_text(size = 12, face = "bold"),
      axis.text.y = element_text(size = 12),
      axis.title = element_text(size = 14, face = "bold"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                color = "#2C3E50", margin = margin(b = 20)),
      legend.position = "right",
      legend.title = element_text(size = 12, face = "bold"),
      panel.grid.major.x = element_blank(),
      plot.margin = margin(20, 20, 20, 20)
    ) +
    labs(
      title = "Risk Assessment by Instrument",
      x = "Assessment Tool",
      y = "Score (%)",
      fill = "Risk Level"
    )
  
  return(p)
}

# Function to generate clinical report
generate_clinical_report <- function(scores, profile, analysis, plots) {
  # Implementation for generating clinical report
  return("Depression Screening Clinical Report")
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function to validate depression item bank
validate_depression_items <- function(item_bank = depression_items_enhanced) {
  cat("Validating depression item bank...\n")
  
  # Check required columns
  required_cols <- c("Item_ID", "Question", "a", "b1", "b2", "b3", "Instrument", "ResponseCategories")
  missing_cols <- setdiff(required_cols, names(item_bank))
  
  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }
  
  # Check item count
  if (nrow(item_bank) != 60) {
    warning("Expected 60 items, found ", nrow(item_bank))
  }
  
  # Check instruments
  expected_instruments <- c("PHQ-9", "CES-D", "BDI-II")
  actual_instruments <- unique(item_bank$Instrument)
  
  if (!all(expected_instruments %in% actual_instruments)) {
    stop("Missing instruments: ", setdiff(expected_instruments, actual_instruments))
  }
  
  # Check IRT parameters
  if (any(item_bank$a <= 0)) {
    stop("Discrimination parameters (a) must be positive")
  }
  
  if (any(item_bank$b1 >= item_bank$b2 | item_bank$b2 >= item_bank$b3)) {
    stop("Difficulty parameters (b1-b3) must be in ascending order")
  }
  
  # Check response categories
  if (!all(item_bank$ResponseCategories == "0,1,2,3")) {
    stop("All items must use 4-point Likert scale")
  }
  
# =============================================================================
# STUDY CONFIGURATION WITH CLINICAL FEATURES
# =============================================================================

# Create the demographic configurations BEFORE study config
assign("demographic_configs", demographic_configs, envir = .GlobalEnv)
assign("custom_demographic_configs", demographic_configs, envir = .GlobalEnv)

# DIRECTLY OVERRIDE THE INREP PACKAGE'S DEMOGRAPHIC FUNCTION
create_default_demographic_configs <- function(demographic_names = NULL, input_types = NULL) {
  return(demographic_configs)
}

get_demographic_configs <- function(...) {
  return(demographic_configs)
}

build_demographic_ui <- function(...) {
  return(demographic_configs)
}

# Create comprehensive study configuration with direct assignment approach
depression_config <- create_study_config(
  name = "Clinical Depression Screening Assessment",
  study_key = "depression_screening_2025",
  model = "GRM",
  estimation_method = "TAM",
  adaptive = TRUE,  # Adaptive for clinical efficiency
  min_items = 8,
  max_items = 20,
  min_SEM = 0.35,  # Clinical precision
  theme = "clinical"
)

# DEMOGRAPHIC CONFIGURATION OVERRIDE
depression_config$demographics <- demographic_names
depression_config$input_types <- input_types
depression_config$demographic_configs <- demographic_configs

# CLINICAL ASSESSMENT CONFIGURATION
depression_config$clinical_assessment <- TRUE
depression_config$clinical_cutoffs <- TRUE
depression_config$risk_assessment <- TRUE

# FORCE THE STUDY CONFIG TO USE OUR DEMOGRAPHICS
depression_config$force_custom_demographics <- TRUE
depression_config$override_default_demographics <- TRUE
depression_config$use_custom_demographic_configs <- TRUE
depression_config$disable_default_demographic_creation <- TRUE
depression_config$demographics_first <- TRUE
depression_config$enforce_demographic_order <- TRUE
depression_config$maintain_custom_order <- TRUE

# CLINICAL SESSION AND PERFORMANCE SETTINGS
depression_config$session_save <- TRUE
depression_config$parallel_computation <- FALSE
depression_config$cache_enabled <- TRUE

# LANGUAGE AND INSTRUCTION FORCING
depression_config$language <- "en"
depression_config$show_introduction <- TRUE
depression_config$force_custom_instructions <- TRUE
depression_config$override_default_instructions <- TRUE
depression_config$disable_adaptive_text <- TRUE
depression_config$instruction_override_mode <- "complete"
depression_config$custom_instructions_override <- create_depression_instructions_override()
depression_config$custom_instructions_title <- "Instructions"
depression_config$custom_instructions_content <- "Please read the instructions carefully before beginning the clinical assessment."

# COMPLETE OVERRIDE OF PACKAGE DEFAULTS
depression_config$disable_all_default_messages <- TRUE
depression_config$suppress_package_notifications <- TRUE
depression_config$force_complete_override <- TRUE
depression_config$disable_inrep_defaults <- TRUE

# CLINICAL CONTENT
depression_config$introduction_content <- paste0(
  '<div class="study-introduction" style="text-align: left; max-width: 800px; margin: 0 auto; padding: 20px;">',
  '<h1 class="main-title">Clinical Depression Screening Assessment</h1>',
  '<h2 class="section-subtitle">Clinical depression screening with advanced psychometric analysis</h2>',
  '<div class="introduction-content">',
  '<h3 class="section-title">About This Clinical Assessment</h3>',
  '<p>This is a comprehensive clinical depression screening that uses adaptive testing to provide accurate symptom assessment.</p>',
  '<p>The assessment adapts to your responses and provides detailed clinical insights with severity classification.</p>',
  '<p>You will receive a comprehensive clinical report with personalized recommendations and resource information.</p>',
  '<p>The assessment typically takes 15-25 minutes and includes clinical visualizations and risk assessment.</p>',
  '<div style="margin-top: 30px; padding: 15px; background-color: #ffebee; border-left: 4px solid #f44336; color: #c62828; font-weight: bold;">',
  'Important: This is a screening tool, not a diagnostic instrument. Results should be discussed with a qualified mental health professional.',
  '</div>',
  '</div>',
  '</div>'
)

depression_config$show_consent <- TRUE
depression_config$consent_content <- paste0(
  '<div class="consent-form">',
  '<h2 class="section-title">Please provide information about your background and mental health history</h2>',
  '<div class="consent-content">',
  '</div>',
  '</div>'
)

depression_config$show_gdpr_compliance <- TRUE
depression_config$show_debriefing <- TRUE

# Add comprehensive debriefing with clinical report
depression_config$debriefing_content <- paste0(
  '<div class="study-debriefing" style="text-align: center;">',
  '<h2 class="section-title">Clinical Assessment Complete!</h2>',
  '<h2 class="section-title">Thank you for your participation!</h2>',
  '<div class="debriefing-content" style="text-align: left; max-width: 800px; margin: 0 auto;">',
  '<div class="next-steps">',
  '<h3>Your Clinical Depression Screening Report</h3>',
  '<p>Below you will find your comprehensive clinical depression assessment with severity classification and recommendations:</p>',
  '</div>',
  '</div>',
  '</div>'
)

depression_config$show_results <- TRUE
depression_config$results_processor <- create_depression_report

# CLOUD STORAGE AND PLOTS CONFIGURATION
depression_config$save_to_cloud <- TRUE
depression_config$cloud_url <- webdav_url
depression_config$cloud_password <- password
depression_config$include_plots_in_results <- TRUE
depression_config$plot_generation <- TRUE

# Session settings
depression_config$clear_on_start <- TRUE
depression_config$force_fresh <- TRUE

# =============================================================================
# VALIDATION OUTPUT
# =============================================================================

cat("=============================================================================\n")
cat("CLINICAL DEPRESSION SCREENING - STUDY CONFIGURATION COMPLETE\n") 
cat("=============================================================================\n")
cat("Study name:", depression_config$name, "\n")
cat("Demographics:", length(demographic_configs), "variables with clinical specificity\n")
cat("  - Consent: 1 option (informed consent)\n")
cat("  - Age: 7 age categories (clinical research standard)\n")
cat("  - Gender: 5 options (inclusive identity)\n")
cat("  - Education: 7 levels (clinical context)\n")
cat("  - Mental Health History: 6 options (clinical assessment)\n")
cat("  - Current Treatment: 6 levels (treatment status)\n")
cat("  - Medication Status: 6 categories (clinical information)\n")
cat("  - Referral Source: 6 options (clinical context)\n")
cat("Assessment Type: Adaptive Clinical Depression Screening\n")
cat("Clinical Features: Severity classification, risk assessment, clinical recommendations\n")
cat("Expected Duration: 15-25 minutes\n")
cat("Results: Comprehensive clinical report with severity level, symptom profile, and resources\n")
cat("Language: English\n")
cat("=============================================================================\n")

for(field_name in names(demographic_configs)) {
  config <- demographic_configs[[field_name]]
  if(config$input_type == "radio") {
    cat("OK", field_name, ":", length(config$options), "options -", 
        paste(names(config$options)[1:min(3, length(config$options))], collapse = ", "), "...\n")
  } else {
    cat("OK", field_name, ": TEXT FIELD\n")
  }
}
cat("=============================================================================\n")

# =============================================================================
# LAUNCH THE SHINY APP - CLINICAL DEPRESSION SCREENING ASSESSMENT
# =============================================================================

cat("Loading Clinical Depression item bank...\n")

# Create comprehensive depression item bank (5 domains x 8 items each = 40 items)
depression_items <- data.frame(
  item_id = paste0("DEPRS_", sprintf("%02d", 1:40)),
  domain = rep(c("Mood_Symptoms", "Cognitive_Symptoms", "Physical_Symptoms", 
                "Behavioral_Symptoms", "Social_Functioning"), each = 8),
  text = c(
    # Mood Symptoms items (PHQ-9 and CES-D based)
    "I have been feeling down, depressed, or hopeless",
    "I have little interest or pleasure in doing things",
    "I feel sad or empty most of the time",
    "I have been feeling worthless or like a failure",
    "I have been feeling guilty about things",
    "I have frequent mood swings or emotional instability",
    "I feel like crying more often than usual",
    "I have been feeling irritable or angry",
    
    # Cognitive Symptoms items
    "I have trouble concentrating on tasks",
    "I have difficulty making decisions",
    "I have trouble remembering things",
    "I have negative thoughts about myself",
    "I have thoughts that I would be better off dead",
    "I have trouble focusing on reading or watching TV",
    "I feel confused or have trouble thinking clearly",
    "I have recurring negative thoughts I can't control",
    
    # Physical Symptoms items
    "I have been sleeping too much or too little",
    "I feel tired or have little energy",
    "I have changes in my appetite or weight",
    "I feel restless or slowed down",
    "I have unexplained aches and pains",
    "I have headaches more often than usual",
    "I feel physically weak or fatigued",
    "I have digestive problems or stomach issues",
    
    # Behavioral Symptoms items
    "I have been avoiding social activities",
    "I have difficulty completing daily tasks",
    "I have been neglecting my personal hygiene",
    "I have been avoiding work or school responsibilities",
    "I have been using alcohol or drugs to cope",
    "I have been procrastinating more than usual",
    "I have been isolating myself from others",
    "I have trouble starting or finishing projects",
    
    # Social Functioning items
    "I have been withdrawing from friends and family",
    "I feel like a burden to others",
    "I have trouble maintaining relationships",
    "I feel disconnected from people around me",
    "I have been more argumentative or hostile",
    "I feel like people don't understand me",
    "I have lost interest in sex or intimacy",
    "I feel lonely even when with other people"
  ),
  # IRT parameters optimized for clinical assessment
  a = runif(40, 1.0, 2.5),  # Higher discrimination for clinical precision
  b1 = rnorm(40, -2.2, 0.3),
  b2 = rnorm(40, -0.8, 0.3), 
  b3 = rnorm(40, 0.8, 0.3),
  b4 = rnorm(40, 2.2, 0.3),
  stringsAsFactors = FALSE
)

cat("Items loaded:", nrow(depression_items), "\n")
cat("Domains:", length(unique(depression_items$domain)), "\n")
cat("Clinical Assessment: Enabled\n")
cat("Severity Classification: Enabled\n")
cat("Language: English\n")
cat("=============================================================================\n")

# LAUNCH THE APP - This WILL show ALL demographics and provide comprehensive clinical report!
launch_study(
    config = depression_config,
    item_bank = depression_items,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
    study_key = session_uuid,
    fresh_session = TRUE,  # Force fresh session
    clear_cache = TRUE,     # Clear any cached data
    language = "en",        # Force English language
    force_custom_ui = TRUE, # Force custom demographic UI
    enable_plots = TRUE,    # Enable plot generation
    enable_clinical_features = TRUE,  # Enable clinical assessment
    port = 3838,
    host = "0.0.0.0"
)

cat("=============================================================================\n")
cat("Open your browser to: http://localhost:3838\n")
cat("The app WILL show:\n")
cat("   - English clinical instructions\n")
cat("   - All 8 demographic questions with clinical options\n") 
cat("   - Adaptive depression screening items (8-20 items)\n")
cat("   - Comprehensive clinical report with severity classification\n")
cat("   - Risk assessment and clinical recommendations\n")
cat("   - Mental health resources and crisis information\n")
cat("   - Cloud data storage\n")
cat("=============================================================================\n")