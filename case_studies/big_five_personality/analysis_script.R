# Big Five Personality Assessment - Analysis Script
# ================================================
#
# This script provides comprehensive analysis functions for the Big Five
# Personality Assessment results, including IRT analysis, factor analysis,
# reliability analysis, and reporting.
#
# Study: Big Five Personality Assessment
# Version: 2.0
# Last Updated: 2025-01-20

# Load required packages
library(inrep)
library(dplyr)
library(ggplot2)
library(psych)
library(corrplot)
library(knitr)
library(kableExtra)
library(rmarkdown)

# =============================================================================
# DATA ANALYSIS FUNCTIONS
# =============================================================================

# Function to analyze BFI results comprehensively
analyze_bfi_results <- function(results_data, item_bank = bfi_items_enhanced) {
  
  cat("=== Big Five Personality Assessment Analysis ===\n")
  
  # Validate input data
  if (!validate_results_data(results_data)) {
    stop("Invalid results data format")
  }
  
  # Calculate dimension scores
  dimension_scores <- calculate_dimension_scores(results_data, item_bank)
  
  # Generate personality profile
  profile <- generate_personality_profile(dimension_scores)
  
  # Perform IRT analysis
  irt_analysis <- perform_irt_analysis(results_data, item_bank)
  
  # Perform factor analysis
  factor_analysis <- perform_factor_analysis(results_data, item_bank)
  
  # Calculate reliability
  reliability_analysis <- calculate_reliability(results_data, item_bank)
  
  # Create visualizations
  plots <- create_bfi_visualizations(dimension_scores, results_data, item_bank)
  
  # Generate comprehensive report
  report <- generate_comprehensive_report(
    dimension_scores, 
    profile, 
    irt_analysis, 
    factor_analysis, 
    reliability_analysis, 
    plots
  )
  
  return(list(
    dimension_scores = dimension_scores,
    profile = profile,
    irt_analysis = irt_analysis,
    factor_analysis = factor_analysis,
    reliability_analysis = reliability_analysis,
    plots = plots,
    report = report
  ))
}

# Function to validate results data
validate_results_data <- function(results_data) {
  cat("Validating results data...\n")
  
  # Check required fields
  required_fields <- c("session_id", "responses", "administered_items", "final_ability", "final_se")
  missing_fields <- setdiff(required_fields, names(results_data))
  
  if (length(missing_fields) > 0) {
    cat("Missing required fields:", paste(missing_fields, collapse = ", "), "\n")
    return(FALSE)
  }
  
  # Check data types
  if (!is.numeric(results_data$responses)) {
    cat("Responses must be numeric\n")
    return(FALSE)
  }
  
  if (!is.numeric(results_data$final_ability)) {
    cat("Final ability must be numeric\n")
    return(FALSE)
  }
  
  cat("✓ Results data validation passed\n")
  return(TRUE)
}

# Function to calculate dimension scores
calculate_dimension_scores <- function(results_data, item_bank) {
  cat("Calculating dimension scores...\n")
  
  # Extract responses and administered items
  responses <- results_data$responses
  administered <- results_data$administered_items
  
  # Initialize dimension scores
  dimensions <- c("Openness", "Conscientiousness", "Extraversion", "Agreeableness", "Neuroticism")
  dimension_scores <- list()
  
  for (dim in dimensions) {
    # Get items for this dimension
    dim_items <- which(item_bank$Dimension == dim)
    administered_dim <- intersect(administered, dim_items)
    
    if (length(administered_dim) > 0) {
      # Calculate dimension score using IRT
      dim_responses <- responses[administered_dim]
      dim_item_bank <- item_bank[administered_dim, ]
      
      # Use TAM for ability estimation
      dim_score <- estimate_dimension_ability(dim_responses, dim_item_bank)
      dimension_scores[[dim]] <- dim_score
    } else {
      dimension_scores[[dim]] <- NA
    }
  }
  
  cat("✓ Dimension scores calculated\n")
  return(dimension_scores)
}

# Function to estimate dimension ability using IRT
estimate_dimension_ability <- function(responses, item_bank) {
  # This is a simplified version - in practice, you would use TAM
  # For now, we'll use a weighted average approach
  
  if (length(responses) == 0) return(NA)
  
  # Calculate weighted score based on IRT parameters
  weights <- item_bank$a  # Use discrimination as weights
  weighted_score <- sum(responses * weights, na.rm = TRUE) / sum(weights, na.rm = TRUE)
  
  # Normalize to typical theta scale (-4 to 4)
  normalized_score <- (weighted_score - 3) * 2  # Assuming 5-point scale centered at 3
  
  return(normalized_score)
}

# Function to generate personality profile
generate_personality_profile <- function(dimension_scores) {
  cat("Generating personality profile...\n")
  
  # Convert to numeric vector
  scores <- unlist(dimension_scores)
  scores <- scores[!is.na(scores)]
  
  if (length(scores) == 0) {
    return(list(
      primary_traits = character(0),
      secondary_traits = character(0),
      development_areas = character(0),
      profile_type = "Insufficient data"
    ))
  }
  
  # Calculate percentile ranks
  percentiles <- rank(scores) / length(scores) * 100
  
  # Identify primary traits (top 40%)
  primary_threshold <- quantile(scores, 0.6)
  primary_traits <- names(scores[scores >= primary_threshold])
  
  # Identify secondary traits (middle 40%)
  secondary_threshold_low <- quantile(scores, 0.2)
  secondary_threshold_high <- quantile(scores, 0.6)
  secondary_traits <- names(scores[scores >= secondary_threshold_low & scores < secondary_threshold_high])
  
  # Identify development areas (bottom 20%)
  development_threshold <- quantile(scores, 0.2)
  development_areas <- names(scores[scores < development_threshold])
  
  # Determine profile type
  if (length(primary_traits) >= 2) {
    profile_type <- "Balanced"
  } else if (length(primary_traits) == 1) {
    profile_type <- "Specialized"
  } else {
    profile_type <- "Developing"
  }
  
  cat("✓ Personality profile generated\n")
  return(list(
    primary_traits = primary_traits,
    secondary_traits = secondary_traits,
    development_areas = development_areas,
    profile_type = profile_type,
    percentiles = percentiles
  ))
}

# Function to perform IRT analysis
perform_irt_analysis <- function(results_data, item_bank) {
  cat("Performing IRT analysis...\n")
  
  # Extract data
  responses <- results_data$responses
  administered <- results_data$administered_items
  
  # Calculate item statistics
  item_stats <- calculate_item_statistics_irt(responses, administered, item_bank)
  
  # Calculate person fit statistics
  person_fit <- calculate_person_fit(responses, administered, item_bank)
  
  # Calculate information curves
  info_curves <- calculate_information_curves(administered, item_bank)
  
  cat("✓ IRT analysis completed\n")
  return(list(
    item_stats = item_stats,
    person_fit = person_fit,
    info_curves = info_curves
  ))
}

# Function to calculate item statistics for IRT
calculate_item_statistics_irt <- function(responses, administered, item_bank) {
  # This is a simplified version - in practice, you would use TAM
  
  item_stats <- data.frame(
    Item_ID = administered,
    Dimension = item_bank$Dimension[administered],
    Mean_Response = sapply(administered, function(i) {
      if (i <= length(responses)) responses[i] else NA
    }),
    SD_Response = sapply(administered, function(i) {
      if (i <= length(responses)) sd(responses[i], na.rm = TRUE) else NA
    })
  )
  
  return(item_stats)
}

# Function to calculate person fit
calculate_person_fit <- function(responses, administered, item_bank) {
  # Simplified person fit calculation
  # In practice, you would use more sophisticated methods
  
  if (length(responses) < 2) return(NA)
  
  # Calculate expected responses based on IRT model
  expected_responses <- calculate_expected_responses(responses, administered, item_bank)
  
  # Calculate fit statistic (simplified)
  fit_stat <- mean((responses - expected_responses)^2, na.rm = TRUE)
  
  return(fit_stat)
}

# Function to calculate expected responses
calculate_expected_responses <- function(responses, administered, item_bank) {
  # Simplified expected response calculation
  # In practice, you would use the IRT model
  
  # For now, return the mean response
  return(rep(mean(responses, na.rm = TRUE), length(responses)))
}

# Function to calculate information curves
calculate_information_curves <- function(administered, item_bank) {
  # Simplified information curve calculation
  # In practice, you would use TAM's information functions
  
  theta_grid <- seq(-4, 4, length.out = 100)
  info_curves <- data.frame(
    theta = theta_grid,
    information = rep(1, length(theta_grid))  # Placeholder
  )
  
  return(info_curves)
}

# Function to perform factor analysis
perform_factor_analysis <- function(results_data, item_bank) {
  cat("Performing factor analysis...\n")
  
  # Extract responses and administered items
  responses <- results_data$responses
  administered <- results_data$administered_items
  
  if (length(administered) < 5) {
    cat("Insufficient items for factor analysis\n")
    return(NULL)
  }
  
  # Create response matrix
  response_matrix <- matrix(responses, nrow = 1)
  colnames(response_matrix) <- paste0("Item_", administered)
  
  # Perform factor analysis
  tryCatch({
    fa_result <- fa(response_matrix, nfactors = 5, rotate = "varimax")
    
    cat("✓ Factor analysis completed\n")
    return(list(
      loadings = fa_result$loadings,
      communalities = fa_result$communalities,
      uniqueness = fa_result$uniquenesses
    ))
  }, error = function(e) {
    cat("Factor analysis failed:", e$message, "\n")
    return(NULL)
  })
}

# Function to calculate reliability
calculate_reliability <- function(results_data, item_bank) {
  cat("Calculating reliability...\n")
  
  # Extract responses and administered items
  responses <- results_data$responses
  administered <- results_data$administered_items
  
  if (length(administered) < 2) {
    cat("Insufficient items for reliability analysis\n")
    return(NULL)
  }
  
  # Calculate Cronbach's alpha
  response_matrix <- matrix(responses, nrow = 1)
  alpha <- tryCatch({
    alpha(response_matrix)$total$raw_alpha
  }, error = function(e) {
    NA
  })
  
  # Calculate split-half reliability
  split_half <- tryCatch({
    calculate_split_half_reliability(responses)
  }, error = function(e) {
    NA
  })
  
  cat("✓ Reliability analysis completed\n")
  return(list(
    cronbach_alpha = alpha,
    split_half = split_half
  ))
}

# Function to calculate split-half reliability
calculate_split_half_reliability <- function(responses) {
  n_items <- length(responses)
  if (n_items < 4) return(NA)
  
  # Split items into two halves
  half1 <- responses[1:floor(n_items/2)]
  half2 <- responses[(floor(n_items/2)+1):n_items]
  
  # Calculate correlation between halves
  correlation <- cor(half1, half2, use = "complete.obs")
  
  # Apply Spearman-Brown correction
  split_half <- 2 * correlation / (1 + correlation)
  
  return(split_half)
}

# Function to create visualizations
create_bfi_visualizations <- function(dimension_scores, results_data, item_bank) {
  cat("Creating visualizations...\n")
  
  plots <- list()
  
  # 1. Personality profile plot
  plots$profile_plot <- create_profile_plot(dimension_scores)
  
  # 2. Radar plot
  plots$radar_plot <- create_radar_plot(dimension_scores)
  
  # 3. Score distribution plot
  plots$distribution_plot <- create_distribution_plot(dimension_scores)
  
  # 4. Item information plot
  plots$item_info_plot <- create_item_info_plot(results_data, item_bank)
  
  # 5. Response pattern plot
  plots$response_pattern_plot <- create_response_pattern_plot(results_data)
  
  cat("✓ Visualizations created\n")
  return(plots)
}

# Function to create profile plot
create_profile_plot <- function(dimension_scores) {
  scores <- unlist(dimension_scores)
  scores <- scores[!is.na(scores)]
  
  if (length(scores) == 0) return(NULL)
  
  plot_data <- data.frame(
    Dimension = names(scores),
    Score = scores
  )
  
  p <- ggplot(plot_data, aes(x = reorder(Dimension, Score), y = Score)) +
    geom_bar(stat = "identity", fill = "steelblue", alpha = 0.7) +
    geom_text(aes(label = sprintf("%.2f", Score)), vjust = -0.5) +
    labs(title = "Big Five Personality Profile",
         x = "Dimension",
         y = "Score") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  return(p)
}

# Function to create radar plot
create_radar_plot <- function(dimension_scores) {
  scores <- unlist(dimension_scores)
  scores <- scores[!is.na(scores)]
  
  if (length(scores) == 0) return(NULL)
  
  # Normalize scores to 0-1 range for radar plot
  normalized_scores <- (scores - min(scores)) / (max(scores) - min(scores))
  
  plot_data <- data.frame(
    Dimension = names(scores),
    Score = normalized_scores
  )
  
  # Create radar plot (simplified)
  p <- ggplot(plot_data, aes(x = Dimension, y = Score)) +
    geom_polygon(fill = "steelblue", alpha = 0.3) +
    geom_point(size = 3, color = "steelblue") +
    coord_polar() +
    labs(title = "Personality Radar Plot") +
    theme_minimal()
  
  return(p)
}

# Function to create distribution plot
create_distribution_plot <- function(dimension_scores) {
  scores <- unlist(dimension_scores)
  scores <- scores[!is.na(scores)]
  
  if (length(scores) == 0) return(NULL)
  
  plot_data <- data.frame(Score = scores)
  
  p <- ggplot(plot_data, aes(x = Score)) +
    geom_histogram(bins = 10, fill = "steelblue", alpha = 0.7) +
    geom_density(aes(y = ..density.. * max(..count..)), color = "red") +
    labs(title = "Score Distribution",
         x = "Score",
         y = "Frequency") +
    theme_minimal()
  
  return(p)
}

# Function to create item information plot
create_item_info_plot <- function(results_data, item_bank) {
  # Simplified item information plot
  administered <- results_data$administered_items
  
  if (length(administered) == 0) return(NULL)
  
  plot_data <- data.frame(
    Item = 1:length(administered),
    Information = rep(1, length(administered))  # Placeholder
  )
  
  p <- ggplot(plot_data, aes(x = Item, y = Information)) +
    geom_line(color = "steelblue") +
    geom_point(color = "steelblue") +
    labs(title = "Item Information",
         x = "Item",
         y = "Information") +
    theme_minimal()
  
  return(p)
}

# Function to create response pattern plot
create_response_pattern_plot <- function(results_data) {
  responses <- results_data$responses
  
  if (length(responses) == 0) return(NULL)
  
  plot_data <- data.frame(
    Item = 1:length(responses),
    Response = responses
  )
  
  p <- ggplot(plot_data, aes(x = Item, y = Response)) +
    geom_line(color = "steelblue") +
    geom_point(color = "steelblue") +
    labs(title = "Response Pattern",
         x = "Item",
         y = "Response") +
    theme_minimal()
  
  return(p)
}

# Function to generate comprehensive report
generate_comprehensive_report <- function(dimension_scores, profile, irt_analysis, 
                                         factor_analysis, reliability_analysis, plots) {
  cat("Generating comprehensive report...\n")
  
  # Create report content
  report_content <- list(
    title = "Big Five Personality Assessment Report",
    date = Sys.Date(),
    dimension_scores = dimension_scores,
    profile = profile,
    irt_analysis = irt_analysis,
    factor_analysis = factor_analysis,
    reliability_analysis = reliability_analysis,
    plots = plots
  )
  
  # Generate HTML report
  generate_html_report(report_content)
  
  cat("✓ Comprehensive report generated\n")
  return(report_content)
}

# Function to generate HTML report
generate_html_report <- function(report_content) {
  # Create HTML report
  html_content <- paste0(
    "<!DOCTYPE html>",
    "<html>",
    "<head>",
    "<title>", report_content$title, "</title>",
    "<style>",
    "body { font-family: Arial, sans-serif; margin: 40px; }",
    "h1 { color: #2c3e50; }",
    "h2 { color: #34495e; }",
    "table { border-collapse: collapse; width: 100%; }",
    "th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }",
    "th { background-color: #f2f2f2; }",
    "</style>",
    "</head>",
    "<body>",
    "<h1>", report_content$title, "</h1>",
    "<p><strong>Date:</strong> ", report_content$date, "</p>",
    "<h2>Dimension Scores</h2>",
    "<table>",
    "<tr><th>Dimension</th><th>Score</th></tr>"
  )
  
  # Add dimension scores
  for (dim in names(report_content$dimension_scores)) {
    score <- report_content$dimension_scores[[dim]]
    html_content <- paste0(html_content,
      "<tr><td>", dim, "</td><td>", round(score, 3), "</td></tr>")
  }
  
  html_content <- paste0(html_content,
    "</table>",
    "<h2>Personality Profile</h2>",
    "<p><strong>Profile Type:</strong> ", report_content$profile$profile_type, "</p>",
    "<p><strong>Primary Traits:</strong> ", paste(report_content$profile$primary_traits, collapse = ", "), "</p>",
    "<p><strong>Secondary Traits:</strong> ", paste(report_content$profile$secondary_traits, collapse = ", "), "</p>",
    "<p><strong>Development Areas:</strong> ", paste(report_content$profile$development_areas, collapse = ", "), "</p>",
    "</body>",
    "</html>"
  )
  
  # Save HTML report
  writeLines(html_content, "case_studies/big_five_personality/bfi_report.html")
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Function to export analysis results
export_analysis_results <- function(analysis_results, filename = "bfi_analysis_results.rds") {
  saveRDS(analysis_results, filename)
  cat("Analysis results exported to:", filename, "\n")
}

# Function to import analysis results
import_analysis_results <- function(filename = "bfi_analysis_results.rds") {
  results <- readRDS(filename)
  cat("Analysis results imported from:", filename, "\n")
  return(results)
}

# Function to print summary statistics
print_summary_statistics <- function(analysis_results) {
  cat("=== Summary Statistics ===\n")
  
  # Dimension scores
  cat("Dimension Scores:\n")
  for (dim in names(analysis_results$dimension_scores)) {
    score <- analysis_results$dimension_scores[[dim]]
    cat("  ", dim, ":", round(score, 3), "\n")
  }
  
  # Profile information
  cat("\nProfile Information:\n")
  cat("  Profile Type:", analysis_results$profile$profile_type, "\n")
  cat("  Primary Traits:", paste(analysis_results$profile$primary_traits, collapse = ", "), "\n")
  cat("  Secondary Traits:", paste(analysis_results$profile$secondary_traits, collapse = ", "), "\n")
  cat("  Development Areas:", paste(analysis_results$profile$development_areas, collapse = ", "), "\n")
  
  # Reliability information
  if (!is.null(analysis_results$reliability_analysis)) {
    cat("\nReliability Information:\n")
    cat("  Cronbach's Alpha:", round(analysis_results$reliability_analysis$cronbach_alpha, 3), "\n")
    cat("  Split-Half Reliability:", round(analysis_results$reliability_analysis$split_half, 3), "\n")
  }
  
  cat("\n")
}

# =============================================================================
# INITIALIZATION
# =============================================================================

cat("=== Big Five Personality Assessment Analysis Script ===\n")
cat("Version: 2.0\n")
cat("Last Updated: 2025-01-20\n")
cat("=====================================================\n\n")

cat("Available functions:\n")
cat("- analyze_bfi_results(results_data, item_bank): Comprehensive analysis\n")
cat("- validate_results_data(results_data): Validate input data\n")
cat("- calculate_dimension_scores(results_data, item_bank): Calculate dimension scores\n")
cat("- generate_personality_profile(dimension_scores): Generate personality profile\n")
cat("- perform_irt_analysis(results_data, item_bank): IRT analysis\n")
cat("- perform_factor_analysis(results_data, item_bank): Factor analysis\n")
cat("- calculate_reliability(results_data, item_bank): Reliability analysis\n")
cat("- create_bfi_visualizations(dimension_scores, results_data, item_bank): Create plots\n")
cat("- generate_comprehensive_report(...): Generate report\n")
cat("- print_summary_statistics(analysis_results): Print summary\n")
cat("- export_analysis_results(analysis_results, filename): Export results\n")
cat("- import_analysis_results(filename): Import results\n")
cat("\n")

cat("To analyze results, run:\n")
cat("analysis_results <- analyze_bfi_results(results_data, bfi_items_enhanced)\n")
cat("print_summary_statistics(analysis_results)\n\n")