# Rater-Participant Design Case Study
# ===================================
#
# This case study demonstrates a rater-participant design where:
# - Multiple raters evaluate participants
# - Raters and participants are linked
# - Comprehensive reporting shows rater agreement
# - Inter-rater reliability analysis
# - Participant performance across raters
#
# Study: Inter-Rater Reliability Assessment
# Version: 1.0
# Last Updated: 2025-01-20
# Design: Rater-Participant Linked Assessment

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)
library(knitr)
library(kableExtra)

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

# Create rater-participant study configuration
rater_participant_config <- create_study_config(
  name = "Inter-Rater Reliability Assessment",
  study_key = "rater_participant_2025",
  model = "GRM",
  max_items = 20,
  min_items = 15,
  min_SEM = 0.25,
  max_session_duration = 45,
  adaptive_start = 5,
  estimation_method = "TAM",
  
  # Rater-specific settings
  rater_design = TRUE,
  max_raters_per_participant = 3,
  min_raters_per_participant = 2,
  rater_agreement_threshold = 0.7,
  
  # Demographics for both raters and participants
  demographics = c("Age", "Gender", "Education", "Experience_Level"),
  rater_demographics = c("Rater_ID", "Rater_Type", "Experience_Years", "Training_Level"),
  
  # Study phases
  show_introduction = TRUE,
  show_briefing = TRUE,
  show_consent = TRUE,
  show_gdpr_compliance = TRUE,
  show_debriefing = TRUE,
  
  # Custom content
  introduction_content = "
    <h2>Inter-Rater Reliability Assessment</h2>
    <p>This study examines the consistency of ratings across multiple evaluators. 
    You will be rated by multiple trained raters on various performance dimensions.</p>
    <p><strong>What you'll do:</strong></p>
    <ul>
      <li>Complete performance assessments</li>
      <li>Be evaluated by multiple raters</li>
      <li>Receive comprehensive feedback</li>
    </ul>
  ",
  
  briefing_content = "
    <h3>Study Information</h3>
    <p><strong>Purpose:</strong> This study investigates inter-rater reliability in performance assessment.</p>
    <p><strong>Procedure:</strong> You will complete performance tasks that will be evaluated by multiple trained raters.</p>
    <p><strong>Duration:</strong> Approximately 30-45 minutes</p>
    <p><strong>Benefits:</strong> You will receive detailed feedback from multiple perspectives.</p>
  ",
  
  consent_content = "
    <h3>Informed Consent</h3>
    <p>By participating, you agree to:</p>
    <ul>
      <li>Complete performance assessments honestly</li>
      <li>Allow multiple raters to evaluate your performance</li>
      <li>Receive comprehensive feedback</li>
    </ul>
  ",
  
  debriefing_content = "
    <h3>Thank you for participating!</h3>
    <p>Your performance has been evaluated by multiple raters. 
    You will receive a comprehensive report showing your performance across all raters.</p>
  ",
  
  # Enhanced features
  enhanced_features = list(
    rater_management = list(
      enabled = TRUE,
      rater_training = TRUE,
      quality_monitoring = TRUE,
      agreement_tracking = TRUE
    ),
    reporting = list(
      enabled = TRUE,
      rater_comparison = TRUE,
      agreement_analysis = TRUE,
      participant_performance = TRUE
    )
  )
)

# =============================================================================
# ITEM BANK FOR RATER EVALUATION
# =============================================================================

# Create comprehensive item bank for rater evaluation
rater_evaluation_items <- data.frame(
  Item_ID = 1:25,
  Question = c(
    # Communication Skills (5 items)
    "Demonstrates clear and effective communication",
    "Uses appropriate language and terminology",
    "Provides constructive feedback",
    "Listens actively and responds appropriately",
    "Maintains professional communication style",
    
    # Problem-Solving Skills (5 items)
    "Identifies key issues and problems",
    "Develops logical and creative solutions",
    "Evaluates alternative approaches",
    "Implements solutions effectively",
    "Monitors and adjusts solutions as needed",
    
    # Technical Competence (5 items)
    "Demonstrates technical knowledge and skills",
    "Applies technical concepts appropriately",
    "Uses tools and resources effectively",
    "Stays current with technical developments",
    "Demonstrates technical problem-solving ability",
    
    # Professional Behavior (5 items)
    "Maintains professional standards",
    "Shows initiative and responsibility",
    "Works effectively in teams",
    "Manages time and resources efficiently",
    "Demonstrates ethical behavior",
    
    # Overall Performance (5 items)
    "Meets or exceeds performance expectations",
    "Shows consistent quality in work",
    "Demonstrates continuous improvement",
    "Contributes positively to team success",
    "Overall performance rating"
  ),
  
  # IRT parameters for GRM
  a = c(
    # Communication
    1.2, 1.1, 1.3, 1.0, 1.2,
    # Problem-Solving
    1.3, 1.2, 1.1, 1.4, 1.0,
    # Technical
    1.1, 1.3, 1.2, 1.0, 1.4,
    # Professional
    1.2, 1.1, 1.3, 1.0, 1.2,
    # Overall
    1.4, 1.2, 1.1, 1.3, 1.5
  ),
  
  # Difficulty parameters
  b1 = c(
    # Communication
    -1.8, -1.5, -2.0, -1.3, -1.7,
    # Problem-Solving
    -2.1, -1.8, -1.6, -2.2, -1.4,
    # Technical
    -1.6, -2.0, -1.8, -1.2, -2.1,
    # Professional
    -1.7, -1.4, -2.0, -1.1, -1.8,
    # Overall
    -2.2, -1.8, -1.5, -2.0, -2.5
  ),
  
  b2 = c(
    # Communication
    -0.5, -0.3, -0.7, -0.2, -0.6,
    # Problem-Solving
    -0.8, -0.5, -0.4, -0.9, -0.3,
    # Technical
    -0.4, -0.7, -0.6, -0.1, -0.8,
    # Professional
    -0.6, -0.3, -0.7, -0.1, -0.5,
    # Overall
    -0.9, -0.6, -0.4, -0.8, -1.2
  ),
  
  b3 = c(
    # Communication
    0.8, 1.0, 0.6, 1.2, 0.7,
    # Problem-Solving
    0.5, 0.8, 1.0, 0.4, 1.1,
    # Technical
    1.0, 0.6, 0.8, 1.3, 0.5,
    # Professional
    0.7, 1.0, 0.6, 1.2, 0.8,
    # Overall
    0.4, 0.7, 1.0, 0.5, 0.2
  ),
  
  b4 = c(
    # Communication
    2.1, 2.3, 1.9, 2.5, 2.0,
    # Problem-Solving
    1.8, 2.1, 2.3, 1.7, 2.4,
    # Technical
    2.3, 1.9, 2.1, 2.6, 1.8,
    # Professional
    2.0, 2.3, 1.9, 2.5, 2.1,
    # Overall
    1.7, 2.0, 2.3, 1.8, 1.5
  ),
  
  # Response categories
  ResponseCategories = rep("1,2,3,4,5", 25),
  
  # Dimension information
  Dimension = c(
    rep("Communication", 5),
    rep("Problem_Solving", 5),
    rep("Technical", 5),
    rep("Professional", 5),
    rep("Overall", 5)
  ),
  
  # Item metadata
  Item_Type = rep("Performance_Evaluation", 25),
  Response_Scale = rep("Likert_5", 25),
  Reverse_Coded = rep(FALSE, 25),
  
  # Rater-specific information
  Rater_Instructions = rep("Rate the participant's performance on this dimension", 25),
  Evidence_Required = rep(TRUE, 25),
  Comments_Required = rep(FALSE, 25)
)

# =============================================================================
# RATER MANAGEMENT SYSTEM
# =============================================================================

# Create rater profiles and training data
rater_profiles <- data.frame(
  Rater_ID = c("R001", "R002", "R003", "R004", "R005"),
  Rater_Name = c("Dr. Smith", "Prof. Johnson", "Dr. Williams", "Prof. Brown", "Dr. Davis"),
  Rater_Type = c("Expert", "Expert", "Trained", "Trained", "Novice"),
  Experience_Years = c(15, 12, 8, 6, 2),
  Training_Level = c("Advanced", "Advanced", "Intermediate", "Intermediate", "Basic"),
  Specialization = c("Communication", "Problem_Solving", "Technical", "Professional", "General"),
  Reliability_Score = c(0.92, 0.89, 0.85, 0.82, 0.78),
  Agreement_Rate = c(0.88, 0.85, 0.82, 0.79, 0.75),
  Last_Calibration = c("2025-01-15", "2025-01-10", "2025-01-08", "2025-01-05", "2025-01-01"),
  Status = c("Active", "Active", "Active", "Active", "Training")
)

# =============================================================================
# PARTICIPANT-RATER LINKING SYSTEM
# =============================================================================

# Function to create participant-rater assignments
create_participant_rater_assignments <- function(
  n_participants = 30,
  n_raters_per_participant = 3,
  rater_profiles = rater_profiles
) {
  
  # Ensure we have enough raters
  if (n_raters_per_participant > nrow(rater_profiles)) {
    stop("Not enough raters available")
  }
  
  # Create balanced assignments
  assignments <- data.frame(
    Participant_ID = rep(1:n_participants, each = n_raters_per_participant),
    Rater_ID = rep(sample(rater_profiles$Rater_ID), length.out = n_participants * n_raters_per_participant),
    Assignment_Date = Sys.Date(),
    Status = "Assigned",
    Completion_Date = NA,
    Quality_Score = NA,
    Agreement_Score = NA
  )
  
  return(assignments)
}

# =============================================================================
# INTER-RATER RELIABILITY ANALYSIS
# =============================================================================

# Function to calculate inter-rater reliability
calculate_inter_rater_reliability <- function(ratings_data) {
  
  # Calculate ICC (Intraclass Correlation Coefficient)
  icc_results <- list()
  
  # For each dimension
  dimensions <- unique(ratings_data$Dimension)
  
  for (dim in dimensions) {
    dim_data <- ratings_data[ratings_data$Dimension == dim, ]
    
    # Calculate ICC for each dimension
    icc_results[[dim]] <- list(
      icc_1 = calculate_icc_1(dim_data),  # Single rater
      icc_k = calculate_icc_k(dim_data),  # Average of k raters
      agreement = calculate_agreement_rate(dim_data)
    )
  }
  
  return(icc_results)
}

# Function to calculate ICC type 1 (single rater)
calculate_icc_1 <- function(data) {
  # Simplified ICC calculation
  # In practice, use proper ICC functions from psych package
  return(0.85)  # Placeholder
}

# Function to calculate ICC type k (average of k raters)
calculate_icc_k <- function(data) {
  # Simplified ICC calculation for average of k raters
  return(0.92)  # Placeholder
}

# Function to calculate agreement rate
calculate_agreement_rate <- function(data) {
  # Calculate percentage of ratings that agree within 1 point
  return(0.78)  # Placeholder
}

# =============================================================================
# COMPREHENSIVE REPORTING SYSTEM
# =============================================================================

# Function to generate rater-participant report
generate_rater_participant_report <- function(
  participant_id,
  ratings_data,
  rater_profiles,
  assignments
) {
  
  # Get participant's ratings
  participant_ratings <- ratings_data[ratings_data$Participant_ID == participant_id, ]
  
  # Get assigned raters
  participant_assignments <- assignments[assignments$Participant_ID == participant_id, ]
  
  # Calculate summary statistics
  summary_stats <- participant_ratings %>%
    group_by(Dimension) %>%
    summarise(
      Mean_Rating = mean(Rating, na.rm = TRUE),
      SD_Rating = sd(Rating, na.rm = TRUE),
      Min_Rating = min(Rating, na.rm = TRUE),
      Max_Rating = max(Rating, na.rm = TRUE),
      N_Raters = n(),
      Agreement_Rate = calculate_agreement_rate(participant_ratings[participant_ratings$Dimension == first(Dimension), ])
    )
  
  # Create comprehensive report
  report <- list(
    participant_id = participant_id,
    summary_stats = summary_stats,
    rater_details = participant_assignments,
    reliability_analysis = calculate_inter_rater_reliability(participant_ratings),
    recommendations = generate_recommendations(summary_stats),
    generated_date = Sys.Date()
  )
  
  return(report)
}

# Function to generate recommendations
generate_recommendations <- function(summary_stats) {
  
  recommendations <- list()
  
  for (i in 1:nrow(summary_stats)) {
    dim <- summary_stats$Dimension[i]
    mean_rating <- summary_stats$Mean_Rating[i]
    agreement <- summary_stats$Agreement_Rate[i]
    
    if (mean_rating >= 4.0) {
      recommendations[[dim]] <- "Excellent performance - continue current approach"
    } else if (mean_rating >= 3.0) {
      recommendations[[dim]] <- "Good performance - focus on specific areas for improvement"
    } else {
      recommendations[[dim]] <- "Needs improvement - consider targeted training or support"
    }
    
    if (agreement < 0.7) {
      recommendations[[dim]] <- paste(recommendations[[dim]], 
                                    "Note: Low rater agreement suggests need for clarification")
    }
  }
  
  return(recommendations)
}

# =============================================================================
# LAUNCH FUNCTION
# =============================================================================

# Function to launch rater-participant study
launch_rater_participant_study <- function(
  config = rater_participant_config,
  item_bank = rater_evaluation_items,
  rater_profiles = rater_profiles,
  n_participants = 30,
  n_raters_per_participant = 3
) {
  
  cat("=== Inter-Rater Reliability Assessment ===\n")
  cat("Study:", config$name, "\n")
  cat("Model:", config$model, "\n")
  cat("Items:", config$min_items, "-", config$max_items, "\n")
  cat("Raters per participant:", n_raters_per_participant, "\n")
  cat("Total participants:", n_participants, "\n")
  cat("==========================================\n\n")
  
  # Create participant-rater assignments
  assignments <- create_participant_rater_assignments(
    n_participants = n_participants,
    n_raters_per_participant = n_raters_per_participant,
    rater_profiles = rater_profiles
  )
  
  # Launch the study
  app <- launch_study(
    config = config,
    item_bank = item_bank,
    rater_design = TRUE,
    rater_profiles = rater_profiles,
    assignments = assignments
  )
  
  return(list(
    app = app,
    assignments = assignments,
    rater_profiles = rater_profiles
  ))
}

# =============================================================================
# INITIALIZATION
# =============================================================================

# Print study information
cat("=== Inter-Rater Reliability Assessment Setup Complete ===\n")
cat("Study Name:", rater_participant_config$name, "\n")
cat("Study Key:", rater_participant_config$study_key, "\n")
cat("Model:", rater_participant_config$model, "\n")
cat("Items:", rater_participant_config$min_items, "-", rater_participant_config$max_items, "\n")
cat("Raters Available:", nrow(rater_profiles), "\n")
cat("====================================================\n\n")

cat("To launch the study, run:\n")
cat("launch_rater_participant_study()\n\n")

cat("To generate reports, run:\n")
cat("generate_rater_participant_report(participant_id, ratings_data, rater_profiles, assignments)\n\n")