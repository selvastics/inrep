# Rater-Participant Design Case Study Demo
# =========================================
#
# This demo script demonstrates the key features of the rater-participant design
# including rater management, participant assignment, and inter-rater reliability analysis.

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)

# =============================================================================
# DEMO 1: BASIC SETUP AND CONFIGURATION
# =============================================================================

cat("=== DEMO 1: Basic Setup and Configuration ===\n")

# Display the study configuration
cat("Study Configuration:\n")
cat("Name:", rater_participant_config$name, "\n")
cat("Study Key:", rater_participant_config$study_key, "\n")
cat("Model:", rater_participant_config$model, "\n")
cat("Items:", rater_participant_config$min_items, "-", rater_participant_config$max_items, "\n")
cat("Rater Design:", rater_participant_config$rater_design, "\n")
cat("Max Raters per Participant:", rater_participant_config$max_raters_per_participant, "\n\n")

# Display rater profiles
cat("Rater Profiles:\n")
print(rater_profiles[, c("Rater_ID", "Rater_Name", "Rater_Type", "Experience_Years", "Reliability_Score")])
cat("\n")

# =============================================================================
# DEMO 2: PARTICIPANT-RATER ASSIGNMENT
# =============================================================================

cat("=== DEMO 2: Participant-Rater Assignment ===\n")

# Create assignments for 10 participants with 3 raters each
assignments <- create_participant_rater_assignments(
  n_participants = 10,
  n_raters_per_participant = 3,
  rater_profiles = rater_profiles
)

cat("Created assignments for", nrow(assignments)/3, "participants with", 3, "raters each\n")
cat("Total assignments:", nrow(assignments), "\n\n")

# Display first few assignments
cat("Sample Assignments:\n")
print(head(assignments, 9))
cat("\n")

# =============================================================================
# DEMO 3: SIMULATED RATINGS DATA
# =============================================================================

cat("=== DEMO 3: Simulated Ratings Data ===\n")

# Create simulated ratings data for demonstration
set.seed(12345)

# Generate ratings for 5 participants across 5 dimensions
participant_ids <- 1:5
dimensions <- c("Communication", "Problem_Solving", "Technical", "Professional", "Overall")

# Create comprehensive ratings data
ratings_data <- data.frame()

for (pid in participant_ids) {
  for (dim in dimensions) {
    # Get raters assigned to this participant
    participant_assignments <- assignments[assignments$Participant_ID == pid, ]
    
    for (i in 1:nrow(participant_assignments)) {
      rater_id <- participant_assignments$Rater_ID[i]
      
      # Generate realistic rating based on dimension and rater
      base_rating <- runif(1, 2.5, 4.5)  # Base rating between 2.5-4.5
      
      # Add some rater-specific variation
      rater_profile <- rater_profiles[rater_profiles$Rater_ID == rater_id, ]
      rater_bias <- (rater_profile$Reliability_Score - 0.85) * 0.5  # Rater bias
      
      # Add dimension-specific variation
      if (dim == "Communication") dim_bias <- 0.2
      else if (dim == "Problem_Solving") dim_bias <- -0.1
      else if (dim == "Technical") dim_bias <- 0.3
      else if (dim == "Professional") dim_bias <- 0.1
      else dim_bias <- 0.0  # Overall
      
      final_rating <- base_rating + rater_bias + dim_bias + rnorm(1, 0, 0.3)
      final_rating <- max(1, min(5, final_rating))  # Ensure 1-5 range
      
      # Create rating record
      rating_record <- data.frame(
        Participant_ID = pid,
        Rater_ID = rater_id,
        Dimension = dim,
        Rating = round(final_rating, 2),
        Rating_Date = Sys.Date(),
        Comments = paste("Rating for", dim, "dimension"),
        stringsAsFactors = FALSE
      )
      
      ratings_data <- rbind(ratings_data, rating_record)
    }
  }
}

cat("Generated simulated ratings for", length(participant_ids), "participants\n")
cat("Total ratings:", nrow(ratings_data), "\n")
cat("Dimensions:", paste(unique(ratings_data$Dimension), collapse = ", "), "\n\n")

# Display sample ratings
cat("Sample Ratings Data:\n")
print(head(ratings_data, 12))
cat("\n")

# =============================================================================
# DEMO 4: INTER-RATER RELIABILITY ANALYSIS
# =============================================================================

cat("=== DEMO 4: Inter-Rater Reliability Analysis ===\n")

# Calculate inter-rater reliability for each dimension
reliability_results <- calculate_inter_rater_reliability(ratings_data)

cat("Inter-Rater Reliability Results:\n")
for (dim in names(reliability_results)) {
  cat("\nDimension:", dim, "\n")
  cat("  ICC (Single Rater):", reliability_results[[dim]]$icc_1, "\n")
  cat("  ICC (Average of K Raters):", reliability_results[[dim]]$icc_k, "\n")
  cat("  Agreement Rate:", reliability_results[[dim]]$agreement, "\n")
}
cat("\n")

# =============================================================================
# DEMO 5: COMPREHENSIVE REPORTING
# =============================================================================

cat("=== DEMO 5: Comprehensive Reporting ===\n")

# Generate comprehensive report for participant 1
participant_report <- generate_rater_participant_report(
  participant_id = 1,
  ratings_data = ratings_data,
  rater_profiles = rater_profiles,
  assignments = assignments
)

cat("Generated comprehensive report for Participant 1\n")
cat("Report Date:", participant_report$generated_date, "\n")
cat("Executive Summary:\n")

# Display summary statistics
summary_stats <- participant_report$summary_stats
for (i in 1:nrow(summary_stats)) {
  dim <- summary_stats$Dimension[i]
  mean_rating <- summary_stats$Mean_Rating[i]
  sd_rating <- summary_stats$SD_Rating[i]
  n_raters <- summary_stats$N_Raters[i]
  agreement <- summary_stats$Agreement_Rate[i]
  
  cat("  ", dim, ":\n")
  cat("    Mean Rating:", mean_rating, "\n")
  cat("    SD:", sd_rating, "\n")
  cat("    N Raters:", n_raters, "\n")
  cat("    Agreement Rate:", agreement, "\n")
}

cat("\nRecommendations:\n")
recommendations <- participant_report$recommendations
for (dim in names(recommendations)) {
  cat("  ", dim, ":", recommendations[[dim]], "\n")
}
cat("\n")

# =============================================================================
# DEMO 6: QUALITY ASSURANCE AND MONITORING
# =============================================================================

cat("=== DEMO 6: Quality Assurance and Monitoring ===\n")

# Calculate rater performance metrics
rater_performance <- data.frame()

for (rater_id in unique(rater_profiles$Rater_ID)) {
  rater_ratings <- ratings_data[ratings_data$Rater_ID == rater_id, ]
  
  if (nrow(rater_ratings) > 0) {
    # Calculate average rating and consistency
    avg_rating <- mean(rater_ratings$Rating, na.rm = TRUE)
    rating_consistency <- sd(rater_ratings$Rating, na.rm = TRUE)
    
    # Calculate agreement with other raters (simplified)
    agreement_score <- runif(1, 0.7, 0.95)  # Simulated agreement
    
    rater_performance <- rbind(rater_performance, data.frame(
      Rater_ID = rater_id,
      N_Ratings = nrow(rater_ratings),
      Avg_Rating = round(avg_rating, 2),
      Rating_Consistency = round(rating_consistency, 2),
      Agreement_Score = round(agreement_score, 2),
      stringsAsFactors = FALSE
    ))
  }
}

cat("Rater Performance Summary:\n")
print(rater_performance)
cat("\n")

# Identify potential quality issues
cat("Quality Assurance Check:\n")
for (i in 1:nrow(rater_performance)) {
  rater_id <- rater_performance$Rater_ID[i]
  agreement <- rater_performance$Agreement_Score[i]
  consistency <- rater_performance$Rating_Consistency[i]
  
  if (agreement < 0.8) {
    cat("  WARNING: Rater", rater_id, "has low agreement (", agreement, ")\n")
  }
  
  if (consistency > 1.5) {
    cat("  WARNING: Rater", rater_id, "has high rating variability (", consistency, ")\n")
  }
}

# =============================================================================
# DEMO 7: ADVANCED ANALYTICS
# =============================================================================

cat("=== DEMO 7: Advanced Analytics ===\n")

# Calculate dimension-level statistics across all participants
dimension_summary <- ratings_data %>%
  group_by(Dimension) %>%
  summarise(
    N_Ratings = n(),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    SD_Rating = sd(Rating, na.rm = TRUE),
    Min_Rating = min(Rating, na.rm = TRUE),
    Max_Rating = max(Rating, na.rm = TRUE),
    .groups = 'drop'
  )

cat("Dimension-Level Summary:\n")
print(dimension_summary)
cat("\n")

# Calculate participant-level summary
participant_summary <- ratings_data %>%
  group_by(Participant_ID) %>%
  summarise(
    N_Ratings = n(),
    Mean_Rating = mean(Rating, na.rm = TRUE),
    SD_Rating = sd(Rating, na.rm = TRUE),
    .groups = 'drop'
  )

cat("Participant-Level Summary:\n")
print(participant_summary)
cat("\n")

# =============================================================================
# DEMO 8: EXPORT AND INTEGRATION
# =============================================================================

cat("=== DEMO 8: Export and Integration ===\n")

# Prepare data for export
export_data <- list(
  study_config = rater_participant_config,
  rater_profiles = rater_profiles,
  assignments = assignments,
  ratings_data = ratings_data,
  reliability_results = reliability_results,
  participant_reports = list(participant_1 = participant_report),
  quality_metrics = rater_performance,
  dimension_summary = dimension_summary,
  participant_summary = participant_summary,
  export_date = Sys.Date(),
  export_version = "1.0"
)

cat("Prepared comprehensive export data\n")
cat("Export Date:", export_data$export_date, "\n")
cat("Export Version:", export_data$export_version, "\n")
cat("Components:", paste(names(export_data), collapse = ", "), "\n\n")

# =============================================================================
# DEMO SUMMARY
# =============================================================================

cat("=== DEMO SUMMARY ===\n")
cat("Successfully demonstrated:\n")
cat("✓ Study configuration and setup\n")
cat("✓ Rater profile management\n")
cat("✓ Participant-rater assignment\n")
cat("✓ Simulated ratings generation\n")
cat("✓ Inter-rater reliability analysis\n")
cat("✓ Comprehensive reporting\n")
cat("✓ Quality assurance monitoring\n")
cat("✓ Advanced analytics\n")
cat("✓ Data export preparation\n\n")

cat("Next Steps:\n")
cat("1. Customize the study configuration for your needs\n")
cat("2. Modify the item bank and dimensions\n")
cat("3. Implement real data collection\n")
cat("4. Customize the reporting functions\n")
cat("5. Deploy in your research or assessment environment\n\n")

cat("For questions or customization help, refer to the README.md file\n")
cat("or contact the inrep development team.\n")