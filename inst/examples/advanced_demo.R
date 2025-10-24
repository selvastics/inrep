# =============================================================================
# CASE STUDY: Advanced Psychological Study on R Package Testing Experience
# =============================================================================
# This case study demonstrates how to replicate a sophisticated psychological
# research study using the inrep package with enhanced features including:
# - Reverse-coded items for validity checks
# - Detailed debriefing and results analysis
# - Statistical summary with bar charts
# - 25-minute timer with warnings
# - Three demographic questions
# - Eight main survey questions with explanations
# - Professional academic presentation

library(inrep)

# =============================================================================
# 1. ENHANCED ITEM BANK WITH REVERSE-CODED ITEMS
# =============================================================================
cat("=== CASE STUDY: Advanced Psychological Study ===\n")
cat("Creating enhanced item bank with reverse-coded items...\n")

# Create comprehensive item bank with reverse-coded items
advanced_psychological_items <- data.frame(
  item_id = 1:8,
  
  # Mix of regular and reverse-coded items
  Question = c(
    "I feel confident in my ability to write effective unit tests using testthat.",
    "Using devtools for package testing increases my cognitive load significantly.",  # REVERSE
    "Interpreting covr's code coverage reports is intuitive and supports my testing strategy.",
    "Testing R packages reduces my stress when preparing for a package release.",
    "I am motivated to incorporate regular testing into my R development workflow.",
    "The documentation for testthat is difficult to navigate and understand.",  # REVERSE
    "I feel satisfied with the feedback provided by covr when testing my R packages.",
    "Using automated testing tools like testthat makes me feel less competent as a developer."  # REVERSE
  ),
  
  # Detailed explanations for each item
  explanation = c(
    "Self-efficacy in testing correlates with higher code quality and fewer errors.",
    "High cognitive load can hinder efficient integration of testing tools.",
    "Intuitive reports enable targeted improvements in test coverage.",
    "Effective testing mitigates anxiety about introducing bugs.",
    "Motivation to test regularly enhances code reliability.",
    "Clear documentation is critical for effective tool use.",
    "Satisfaction with feedback influences tool adoption and testing frequency.",
    "Perceived competence affects willingness to adopt testing practices."
  ),
  
  # Reverse coding indicators
  reverse_coded = c(FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE),
  
  # Construct categories for analysis
  construct = c(
    "Self-Efficacy", "Cognitive Load", "Usability", "Stress Reduction",
    "Motivation", "Documentation", "Satisfaction", "Competence"
  ),
  
  # Enhanced IRT parameters (more realistic discrimination values)
  a = c(1.9, 1.7, 1.5, 1.8, 2.0, 1.6, 1.4, 1.7),  # Discrimination parameters
  b1 = c(-2.2, -1.9, -2.1, -1.8, -2.3, -2.0, -1.7, -1.9),  # Threshold 1
  b2 = c(-0.9, -0.7, -0.8, -0.6, -1.0, -0.9, -0.5, -0.7),  # Threshold 2
  b3 = c(0.3, 0.1, 0.2, 0.0, 0.4, 0.3, 0.1, 0.2),         # Threshold 3
  b4 = c(1.2, 1.0, 1.1, 0.9, 1.3, 1.2, 1.0, 1.1),         # Threshold 4
  
  # 5-point Likert scale options
  ResponseCategories = rep("1,2,3,4,5", 8),
  
  stringsAsFactors = FALSE
)

cat("[OK] Enhanced item bank created with", nrow(advanced_psychological_items), "items\n")
cat("[OK] Reverse-coded items:", sum(advanced_psychological_items$reverse_coded), "\n")
cat("[OK] Constructs:", paste(unique(advanced_psychological_items$construct), collapse = ", "), "\n")

# =============================================================================
# 2. ENHANCED DEMOGRAPHIC CONFIGURATION
# =============================================================================
cat("\nCreating enhanced demographic configuration...\n")

# Three demographic questions as in the original study
enhanced_demographics <- list(
  age_range = list(
    question = "What is your age range?",
    options = c("18-24", "25-34", "35-44", "45-54", "55+"),
    required = FALSE
  ),
  
  r_experience = list(
    question = "How many years have you been developing R packages?",
    options = c("Less than 1 year", "1-3 years", "3-5 years", "5+ years"),
    required = FALSE
  ),
  
  developer_role = list(
    question = "What is your primary role in R development?",
    options = c("Data Scientist", "Software Developer", "Researcher/Academic", "Student", "Other"),
    required = FALSE
  )
)

cat("[OK] Enhanced demographics created with", length(enhanced_demographics), "questions\n")

# =============================================================================
# 3. ADVANCED RESULTS PROCESSING FUNCTION
# =============================================================================
cat("\nCreating advanced results processing function...\n")

# Function to process results with statistical analysis
process_advanced_results <- function(responses, demographics, session_data) {
  # Handle reverse coding
  reverse_indices <- which(advanced_psychological_items$reverse_coded)
  processed_responses <- responses
  
  # Reverse code items (5-point scale: 1->5, 2->4, 3->3, 4->2, 5->1)
  for (i in reverse_indices) {
    if (!is.na(responses[i])) {
      processed_responses[i] <- 6 - responses[i]
    }
  }
  
  # Calculate construct scores
  constructs <- unique(advanced_psychological_items$construct)
  construct_scores <- list()
  
  for (construct in constructs) {
    construct_items <- which(advanced_psychological_items$construct == construct)
    construct_scores[[construct]] <- mean(processed_responses[construct_items], na.rm = TRUE)
  }
  
  # Calculate overall statistics
  valid_responses <- processed_responses[!is.na(processed_responses)]
  response_rate <- length(valid_responses) / length(responses) * 100
  mean_score <- mean(valid_responses, na.rm = TRUE)
  sd_score <- sd(valid_responses, na.rm = TRUE)
  
  # Create response distribution
  response_counts <- table(factor(valid_responses, levels = 1:5))
  
  # Generate detailed feedback
  feedback <- list(
    overall_score = mean_score,
    response_rate = response_rate,
    construct_scores = construct_scores,
    response_distribution = response_counts,
    statistical_summary = list(
      mean = mean_score,
      sd = sd_score,
      min = min(valid_responses, na.rm = TRUE),
      max = max(valid_responses, na.rm = TRUE),
      median = median(valid_responses, na.rm = TRUE)
    ),
    demographic_profile = demographics,
    session_duration = session_data$duration_minutes
  )
  
  return(feedback)
}

# =============================================================================
# 4. ENHANCED STUDY CONFIGURATION
# =============================================================================
cat("\nCreating enhanced study configuration...\n")

# Create comprehensive study configuration
enhanced_study_config <- create_study_config(
  # Study identification
  name = "Advanced Psychological Study on R Package Testing Experience",
  study_key = "advanced_r_testing_psych_2025",
  
  # Enhanced Monochrome theme
  theme = "Monochrome",
  
  # Demographics configuration
  demographics = c("age_range", "r_experience", "developer_role"),
  input_types = list(
    age_range = "select",
    r_experience = "select",
    developer_role = "select"
  ),
  
  # Psychometric model
  model = "GRM",  # Graded Response Model
  
  # Study design (fixed questionnaire)
  adaptive = FALSE,
  max_items = 8,
  min_items = 8,
  
  # Extended session management
  session_save = TRUE,
  max_session_duration = 25,  # 25-minute timer

  # UI configuration
  response_ui_type = "radio",
  progress_style = "bar",

  # Enhanced validation
  response_validation_fun = function(response) {
    !is.null(response) && nzchar(as.character(response))
  },

  # Demographic configurations
  demographic_configs = enhanced_demographics,

  # Advanced recommendation function with construct analysis
  recommendation_fun = function(theta, demographics) {
    if (is.null(theta) || length(theta) == 0) {
      return("Thank you for participating in this advanced psychological study on R package testing.")
    }
    
    # Process responses with reverse coding
    processed_responses <- theta
    reverse_indices <- which(advanced_psychological_items$reverse_coded)
    for (i in reverse_indices) {
      if (!is.na(theta[i])) {
        processed_responses[i] <- 6 - theta[i]
      }
    }
    
    # Calculate construct scores
    constructs <- unique(advanced_psychological_items$construct)
    construct_scores <- list()
    
    for (construct in constructs) {
      construct_items <- which(advanced_psychological_items$construct == construct)
      construct_scores[[construct]] <- mean(processed_responses[construct_items], na.rm = TRUE)
    }
    
    # Generate personalized feedback
    avg_score <- mean(processed_responses, na.rm = TRUE)
    
    feedback <- paste(
      "Based on your responses, your overall testing experience score is",
      round(avg_score, 2), "out of 5.0."
    )
    
    # Analyze strongest and weakest areas
    scores_df <- data.frame(
      construct = names(construct_scores),
      score = unlist(construct_scores),
      stringsAsFactors = FALSE
    )
    scores_df <- scores_df[!is.na(scores_df$score), ]
    
    if (nrow(scores_df) > 0) {
      highest_construct <- scores_df$construct[which.max(scores_df$score)]
      lowest_construct <- scores_df$construct[which.min(scores_df$score)]
      
      feedback <- paste(feedback, 
        "Your strongest area appears to be", highest_construct, 
        "while", lowest_construct, "may benefit from additional attention.")
    }
    
    # Provide recommendations based on overall score
    if (avg_score >= 4.0) {
      feedback <- paste(feedback,
        "Your responses indicate highly positive experiences with R testing tools.",
        "Consider sharing your expertise through tutorials, mentoring, or contributing",
        "to testing tool development."
      )
    } else if (avg_score >= 3.0) {
      feedback <- paste(feedback,
        "Your responses show generally positive experiences with some areas for growth.",
        "Consider exploring advanced testing techniques or joining R testing communities",
        "for peer support and knowledge sharing."
      )
    } else {
      feedback <- paste(feedback,
        "Your responses suggest significant room for improvement in testing practices.",
        "Consider starting with basic testthat tutorials and gradually building skills",
        "through practice and community engagement."
      )
    }
    
    return(feedback)
  },
  
  # Custom results processing
  results_processing_fun = process_advanced_results,
  
  # Enhanced timer settings
  timer_settings = list(
    show_timer = TRUE,
    warning_threshold = 3,  # Warning at 3 minutes remaining
    style = "academic"
  ),
  
  # Quality control settings
  quality_control = list(
    minimum_response_rate = 0.5,  # At least 50% of questions must be answered
    detect_straight_lining = TRUE,
    minimum_time_per_question = 3  # At least 3 seconds per question
  )
)

cat("[OK] Enhanced study configuration created\n")

# =============================================================================
# 5. COMPREHENSIVE VALIDATION
# =============================================================================
cat("\nValidating enhanced configuration...\n")

# Validate item bank
validation_result <- validate_item_bank(advanced_psychological_items, model = "GRM")
if (is.logical(validation_result) && validation_result) {
  cat("[OK] Enhanced item bank validation passed\n")
} else if (is.list(validation_result) && validation_result$valid) {
  cat("[OK] Enhanced item bank validation passed\n")
} else {
  cat("X Enhanced item bank validation failed:\n")
  if (is.list(validation_result) && !is.null(validation_result$errors)) {
    print(validation_result$errors)
  }
}

# Test theme loading
theme_css <- load_theme_css("Monochrome")
if (nchar(theme_css) > 1000) {
  cat("[OK] Monochrome theme loaded successfully (", nchar(theme_css), " characters)\n")
} else {
  cat("X Monochrome theme loading failed\n")
}

# Validate reverse coding
reverse_count <- sum(advanced_psychological_items$reverse_coded)
cat("[OK] Reverse-coded items identified:", reverse_count, "items\n")

# =============================================================================
# 6. LAUNCH FUNCTIONS
# =============================================================================
cat("\nCreating launch functions...\n")

# Function to launch the enhanced study
launch_enhanced_study <- function(auto_launch = FALSE) {
  cat("=== LAUNCHING ENHANCED PSYCHOLOGICAL STUDY ===\n")
  cat("Study Features:\n")
  cat("- 8 Likert-scale questions (", sum(advanced_psychological_items$reverse_coded), "reverse-coded)\n")
  cat("- 3 demographic questions\n")
  cat("- 25-minute timer with warnings\n")
  cat("- Statistical analysis and bar charts\n")
  cat("- Detailed debriefing\n")
  cat("- Enhanced Monochrome theme\n")
  cat("- Construct-based analysis\n")
  cat("===========================================\n")
  
  if (auto_launch) {
    cat("Auto-launching study...\n")
    launch_study(
      config = enhanced_study_config,
      item_bank = advanced_psychological_items,
      port = 3838
    )
  } else {
    cat("To launch manually, run:\n")
    cat("launch_study(config = enhanced_study_config, item_bank = advanced_psychological_items, port = 3838)\n")
  }
}

# Function to create a demo version with pre-filled responses
create_demo_version <- function() {
  cat("Creating demo version with sample responses...\n")
  
  # Create sample responses
  demo_responses <- c(4, 2, 4, 3, 5, 2, 4, 1)  # Mix of responses including reverse-coded
  demo_demographics <- list(
    age_range = 2,  # 25-34
    r_experience = 3,  # 3-5 years
    developer_role = 1  # Data Scientist
  )
  
  # Process demo results
  demo_results <- process_advanced_results(
    responses = demo_responses,
    demographics = demo_demographics,
    session_data = list(duration_minutes = 18)
  )
  
  cat("Demo Results:\n")
  cat("- Overall Score:", round(demo_results$overall_score, 2), "\n")
  cat("- Response Rate:", round(demo_results$response_rate, 1), "%\n")
  cat("- Construct Scores:\n")
  for (construct in names(demo_results$construct_scores)) {
    cat("  ", construct, ":", round(demo_results$construct_scores[[construct]], 2), "\n")
  }
  
  return(demo_results)
}

# =============================================================================
# 7. USAGE EXAMPLES
# =============================================================================





# Load the launcher
source("launch_advanced_study.R")

# Auto-launch the study
launch_enhanced_study(auto_launch = TRUE)


# Step 1: Load inrep package
library(inrep)

# Step 2: Load case study
source("inst/examples/advanced_psychological_study_case_study.R")

# Step 3: Launch
launch_study(
  config = enhanced_study_config,
  item_bank = advanced_psychological_items,
  port = 3838,
  launch_browser = TRUE
)

# Load configuration
source("launch_advanced_study.R")

# Run demo with sample responses
demo_results <- create_demo_version()
print(demo_results)


library(inrep)
source("launch_advanced_study.R")
launch_enhanced_study(auto_launch = TRUE)

