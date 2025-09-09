# Advanced Analytics and Reporting System for inrep Package
# Provides comprehensive psychometric analysis and reporting capabilities

#' Advanced Analytics and Reporting System
#' 
#' This module provides comprehensive psychometric analysis, statistical testing,
#' and automated report generation for inrep assessments.
#' 
#' @name advanced_analytics
#' @keywords internal
NULL

#' Psychometric Diagnostics
#' 
#' Comprehensive psychometric analysis and diagnostics.

#' Calculate item difficulty statistics
#' 
#' @param item_bank Item bank data frame
#' @param responses Response data
#' @return List with difficulty statistics
#' @export
calculate_item_difficulty <- function(item_bank, responses) {
  if (is.null(responses) || length(responses) == 0) {
    return(list(
      difficulty = numeric(0),
      p_values = numeric(0),
      discrimination = numeric(0)
    ))
  }
  
  # Calculate p-values (proportion correct)
  p_values <- sapply(1:nrow(item_bank), function(i) {
    item_responses <- responses[responses$item_id == item_bank$item_id[i], ]
    if (nrow(item_responses) == 0) return(NA)
    mean(item_responses$response, na.rm = TRUE)
  })
  
  # Calculate difficulty (logit transformation)
  difficulty <- -log(p_values / (1 - p_values))
  difficulty[is.infinite(difficulty)] <- NA
  
  # Calculate discrimination (point-biserial correlation)
  discrimination <- sapply(1:nrow(item_bank), function(i) {
    item_responses <- responses[responses$item_id == item_bank$item_id[i], ]
    if (nrow(item_responses) < 2) return(NA)
    
    total_scores <- aggregate(response ~ participant_id, data = responses, sum, na.rm = TRUE)
    item_scores <- item_responses$response
    
    if (length(unique(item_scores)) < 2) return(NA)
    
    cor(total_scores$response, item_scores, use = "complete.obs")
  })
  
  list(
    difficulty = difficulty,
    p_values = p_values,
    discrimination = discrimination,
    item_ids = item_bank$item_id
  )
}

#' Calculate reliability statistics
#' 
#' @param responses Response data
#' @param method Reliability method ("alpha", "split_half", "test_retest")
#' @return Reliability statistics
#' @export
calculate_reliability <- function(responses, method = "alpha") {
  if (is.null(responses) || nrow(responses) == 0) {
    return(list(reliability = NA, method = method))
  }
  
  # Convert to wide format
  wide_data <- reshape2::dcast(responses, participant_id ~ item_id, 
                              value.var = "response", fill = NA)
  
  # Remove participant_id column
  response_matrix <- as.matrix(wide_data[, -1])
  
  if (method == "alpha") {
    # Cronbach's alpha
    n_items <- ncol(response_matrix)
    item_variances <- apply(response_matrix, 2, var, na.rm = TRUE)
    total_variance <- var(rowSums(response_matrix, na.rm = TRUE))
    
    alpha <- (n_items / (n_items - 1)) * (1 - sum(item_variances, na.rm = TRUE) / total_variance)
    
    return(list(
      reliability = alpha,
      method = method,
      n_items = n_items,
      interpretation = ifelse(alpha >= 0.9, "Excellent",
                             ifelse(alpha >= 0.8, "Good",
                                   ifelse(alpha >= 0.7, "Acceptable",
                                         ifelse(alpha >= 0.6, "Questionable", "Poor"))))
    ))
  }
  
  return(list(reliability = NA, method = method))
}

#' Calculate standard error of measurement
#' 
#' @param responses Response data
#' @param ability_estimates Ability estimates
#' @return Standard error statistics
#' @export
calculate_standard_error <- function(responses, ability_estimates) {
  if (is.null(ability_estimates) || length(ability_estimates) == 0) {
    return(list(sem = NA, confidence_interval = NA))
  }
  
  # Calculate standard error of measurement
  sem <- sd(ability_estimates, na.rm = TRUE) * sqrt(1 - 0.8)  # Assuming 0.8 reliability
  
  # Calculate 95% confidence interval
  ci_lower <- ability_estimates - 1.96 * sem
  ci_upper <- ability_estimates + 1.96 * sem
  
  list(
    sem = sem,
    confidence_interval = list(
      lower = ci_lower,
      upper = ci_upper
    ),
    interpretation = ifelse(sem <= 0.3, "High precision",
                           ifelse(sem <= 0.5, "Moderate precision", "Low precision"))
  )
}

#' Statistical Significance Testing
#' 
#' Comprehensive statistical testing for assessment results.

#' Test for differential item functioning (DIF)
#' 
#' @param responses Response data
#' @param group_variable Grouping variable
#' @param item_id Item ID to test
#' @return DIF test results
#' @export
test_dif <- function(responses, group_variable, item_id) {
  # Filter responses for the specific item
  item_responses <- responses[responses$item_id == item_id, ]
  
  if (nrow(item_responses) < 10) {
    return(list(
      significant = FALSE,
      p_value = NA,
      effect_size = NA,
      message = "Insufficient data for DIF testing"
    ))
  }
  
  # Perform chi-square test
  contingency_table <- table(item_responses$response, item_responses[[group_variable]])
  
  if (nrow(contingency_table) < 2 || ncol(contingency_table) < 2) {
    return(list(
      significant = FALSE,
      p_value = NA,
      effect_size = NA,
      message = "Insufficient variation for DIF testing"
    ))
  }
  
  chi_square_test <- chisq.test(contingency_table)
  
  # Calculate effect size (Cramer's V)
  n <- sum(contingency_table)
  chi_square <- chi_square_test$statistic
  effect_size <- sqrt(chi_square / (n * (min(nrow(contingency_table), ncol(contingency_table)) - 1)))
  
  list(
    significant = chi_square_test$p.value < 0.05,
    p_value = chi_square_test$p.value,
    effect_size = effect_size,
    interpretation = ifelse(effect_size < 0.1, "Negligible",
                           ifelse(effect_size < 0.3, "Small",
                                 ifelse(effect_size < 0.5, "Medium", "Large")))
  )
}

#' Test for unidimensionality
#' 
#' @param responses Response data
#' @return Unidimensionality test results
#' @export
test_unidimensionality <- function(responses) {
  if (is.null(responses) || nrow(responses) == 0) {
    return(list(
      unidimensional = NA,
      p_value = NA,
      message = "No data available for testing"
    ))
  }
  
  # Convert to wide format
  wide_data <- reshape2::dcast(responses, participant_id ~ item_id, 
                              value.var = "response", fill = NA)
  
  # Remove participant_id column
  response_matrix <- as.matrix(wide_data[, -1])
  
  # Calculate correlation matrix
  cor_matrix <- cor(response_matrix, use = "complete.obs")
  
  # Calculate first eigenvalue
  eigen_values <- eigen(cor_matrix)$values
  first_eigenvalue <- eigen_values[1]
  second_eigenvalue <- eigen_values[2]
  
  # Calculate ratio
  ratio <- first_eigenvalue / second_eigenvalue
  
  # Unidimensionality if ratio > 3
  unidimensional <- ratio > 3
  
  list(
    unidimensional = unidimensional,
    ratio = ratio,
    first_eigenvalue = first_eigenvalue,
    second_eigenvalue = second_eigenvalue,
    interpretation = ifelse(unidimensional, "Unidimensional", "Multidimensional")
  )
}

#' Test for local independence
#' 
#' @param responses Response data
#' @param alpha Significance level
#' @return Local independence test results
#' @export
test_local_independence <- function(responses, alpha = 0.05) {
  if (is.null(responses) || nrow(responses) == 0) {
    return(list(
      independent = NA,
      p_value = NA,
      message = "No data available for testing"
    ))
  }
  
  # Get unique item pairs
  item_ids <- unique(responses$item_id)
  n_items <- length(item_ids)
  
  if (n_items < 2) {
    return(list(
      independent = NA,
      p_value = NA,
      message = "Insufficient items for independence testing"
    ))
  }
  
  # Calculate pairwise correlations
  correlations <- matrix(NA, n_items, n_items)
  p_values <- matrix(NA, n_items, n_items)
  
  for (i in 1:(n_items-1)) {
    for (j in (i+1):n_items) {
      item1_responses <- responses[responses$item_id == item_ids[i], ]
      item2_responses <- responses[responses$item_id == item_ids[j], ]
      
      # Merge responses by participant
      merged <- merge(item1_responses, item2_responses, by = "participant_id", 
                     suffixes = c("_1", "_2"))
      
      if (nrow(merged) > 2) {
        cor_test <- cor.test(merged$response_1, merged$response_2)
        correlations[i, j] <- cor_test$estimate
        p_values[i, j] <- cor_test$p.value
      }
    }
  }
  
  # Check for significant correlations
  significant_correlations <- sum(p_values < alpha, na.rm = TRUE)
  total_tests <- sum(!is.na(p_values))
  
  independent <- significant_correlations == 0
  
  list(
    independent = independent,
    significant_correlations = significant_correlations,
    total_tests = total_tests,
    max_correlation = max(abs(correlations), na.rm = TRUE),
    interpretation = ifelse(independent, "Locally independent", "Local dependence detected")
  )
}

#' Automated Report Generation
#' 
#' Generate comprehensive assessment reports.

#' Generate psychometric report
#' 
#' @param responses Response data
#' @param ability_estimates Ability estimates
#' @param item_bank Item bank data
#' @param config Study configuration
#' @return Comprehensive psychometric report
#' @export
generate_psychometric_report <- function(responses, ability_estimates, item_bank, config) {
  # Calculate basic statistics
  n_participants <- length(unique(responses$participant_id))
  n_items <- nrow(item_bank)
  
  # Calculate item difficulty
  difficulty_stats <- calculate_item_difficulty(item_bank, responses)
  
  # Calculate reliability
  reliability_stats <- calculate_reliability(responses)
  
  # Calculate standard error
  sem_stats <- calculate_standard_error(responses, ability_estimates)
  
  # Test unidimensionality
  unidimensionality_test <- test_unidimensionality(responses)
  
  # Test local independence
  independence_test <- test_local_independence(responses)
  
  # Generate report
  report <- list(
    study_info = list(
      name = config$name,
      model = config$model,
      n_participants = n_participants,
      n_items = n_items,
      date = Sys.Date()
    ),
    item_statistics = list(
      difficulty = difficulty_stats$difficulty,
      p_values = difficulty_stats$p_values,
      discrimination = difficulty_stats$discrimination,
      item_ids = difficulty_stats$item_ids
    ),
    reliability = reliability_stats,
    standard_error = sem_stats,
    dimensionality = unidimensionality_test,
    local_independence = independence_test,
    recommendations = generate_recommendations(difficulty_stats, reliability_stats, 
                                             unidimensionality_test, independence_test)
  )
  
  return(report)
}

#' Generate recommendations based on analysis
#' 
#' @param difficulty_stats Item difficulty statistics
#' @param reliability_stats Reliability statistics
#' @param unidimensionality_test Unidimensionality test results
#' @param independence_test Local independence test results
#' @return List of recommendations
#' @export
generate_recommendations <- function(difficulty_stats, reliability_stats, 
                                   unidimensionality_test, independence_test) {
  recommendations <- list()
  
  # Item difficulty recommendations
  if (!is.null(difficulty_stats$p_values)) {
    extreme_difficulty <- sum(difficulty_stats$p_values < 0.1 | difficulty_stats$p_values > 0.9, na.rm = TRUE)
    if (extreme_difficulty > 0) {
      recommendations <- c(recommendations, 
                          paste("Consider revising", extreme_difficulty, "items with extreme difficulty"))
    }
  }
  
  # Discrimination recommendations
  if (!is.null(difficulty_stats$discrimination)) {
    low_discrimination <- sum(difficulty_stats$discrimination < 0.3, na.rm = TRUE)
    if (low_discrimination > 0) {
      recommendations <- c(recommendations, 
                          paste("Consider revising", low_discrimination, "items with low discrimination"))
    }
  }
  
  # Reliability recommendations
  if (!is.null(reliability_stats$reliability)) {
    if (reliability_stats$reliability < 0.7) {
      recommendations <- c(recommendations, "Consider adding more items to improve reliability")
    }
  }
  
  # Dimensionality recommendations
  if (!is.null(unidimensionality_test$unidimensional) && !unidimensionality_test$unidimensional) {
    recommendations <- c(recommendations, "Consider using multidimensional IRT models")
  }
  
  # Local independence recommendations
  if (!is.null(independence_test$independent) && !independence_test$independent) {
    recommendations <- c(recommendations, "Consider investigating local dependence issues")
  }
  
  return(recommendations)
}

#' Export report to various formats
#' 
#' @param report Psychometric report
#' @param format Export format ("json", "csv", "html")
#' @param file_path Output file path
#' @return Export status
#' @export
export_report <- function(report, format = "json", file_path = NULL) {
  if (is.null(file_path)) {
    file_path <- paste0("psychometric_report_", Sys.Date(), ".", format)
  }
  
  if (format == "json") {
    jsonlite::write_json(report, file_path, pretty = TRUE)
  } else if (format == "csv") {
    # Export item statistics to CSV
    item_stats <- data.frame(
      item_id = report$item_statistics$item_ids,
      difficulty = report$item_statistics$difficulty,
      p_value = report$item_statistics$p_values,
      discrimination = report$item_statistics$discrimination
    )
    write.csv(item_stats, file_path, row.names = FALSE)
  } else if (format == "html") {
    # Generate HTML report
    html_content <- generate_html_report(report)
    writeLines(html_content, file_path)
  }
  
  return(list(
    success = TRUE,
    file_path = file_path,
    format = format
  ))
}

#' Generate HTML report
#' 
#' @param report Psychometric report
#' @return HTML content
#' @export
generate_html_report <- function(report) {
  html_content <- paste0(
    "<!DOCTYPE html>
    <html>
    <head>
      <title>Psychometric Report - ", report$study_info$name, "</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1, h2 { color: #2c3e50; }
        .summary { background-color: #f8f9fa; padding: 20px; border-radius: 5px; }
        .recommendations { background-color: #fff3cd; padding: 20px; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
      </style>
    </head>
    <body>
      <h1>Psychometric Report</h1>
      <div class='summary'>
        <h2>Study Information</h2>
        <p><strong>Name:</strong> ", report$study_info$name, "</p>
        <p><strong>Model:</strong> ", report$study_info$model, "</p>
        <p><strong>Participants:</strong> ", report$study_info$n_participants, "</p>
        <p><strong>Items:</strong> ", report$study_info$n_items, "</p>
        <p><strong>Date:</strong> ", report$study_info$date, "</p>
      </div>
      
      <h2>Reliability</h2>
      <p><strong>Cronbach's Alpha:</strong> ", round(report$reliability$reliability, 3), "</p>
      <p><strong>Interpretation:</strong> ", report$reliability$interpretation, "</p>
      
      <h2>Standard Error of Measurement</h2>
      <p><strong>SEM:</strong> ", round(report$standard_error$sem, 3), "</p>
      <p><strong>Interpretation:</strong> ", report$standard_error$interpretation, "</p>
      
      <h2>Dimensionality</h2>
      <p><strong>Unidimensional:</strong> ", report$dimensionality$interpretation, "</p>
      <p><strong>Ratio:</strong> ", round(report$dimensionality$ratio, 3), "</p>
      
      <h2>Local Independence</h2>
      <p><strong>Independent:</strong> ", report$local_independence$interpretation, "</p>
      
      <div class='recommendations'>
        <h2>Recommendations</h2>
        <ul>"
  )
  
  for (rec in report$recommendations) {
    html_content <- paste0(html_content, "<li>", rec, "</li>")
  }
  
  html_content <- paste0(html_content, "
        </ul>
      </div>
    </body>
    </html>")
  
  return(html_content)
}