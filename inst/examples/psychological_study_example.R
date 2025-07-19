# Psychological Study on R Package Testing Experience
# Example implementation using inrep package with Monochrome theme

# Load the inrep package
library(inrep)

# Create the item bank for the psychological study
r_testing_items <- data.frame(
  item_id = 1:6,
  item_text = c(
    "I feel confident in my ability to write effective unit tests using testthat.",
    "Using devtools to manage and test R packages is intuitive and efficient.",
    "Interpreting code coverage reports from covr helps me improve my testing strategy.",
    "Testing R packages reduces my stress when preparing for a package release.",
    "I feel motivated to incorporate regular testing into my R package development process.",
    "The documentation for testthat is clear and supports my testing needs."
  ),
  explanation = c(
    "Confidence in testing skills can enhance code quality and reduce development errors.",
    "Ease of use in testing workflows impacts developer productivity and adoption.",
    "Clear coverage reports enable targeted improvements in test coverage.",
    "Effective testing can alleviate concerns about introducing bugs in production.",
    "Motivation to test regularly correlates with higher code reliability and quality.",
    "Clear documentation is critical for effective use of testing tools."
  ),
  # Graded Response Model parameters for Likert scales
  a = rep(1.5, 6),  # Discrimination parameter
  b1 = rep(-2, 6),  # Threshold 1 (Strongly Disagree -> Disagree)
  b2 = rep(-1, 6),  # Threshold 2 (Disagree -> Neutral)
  b3 = rep(0, 6),   # Threshold 3 (Neutral -> Agree)
  b4 = rep(1, 6),   # Threshold 4 (Agree -> Strongly Agree)
  response_options = I(rep(list(c(
    "Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"
  )), 6))
)

# Create demographic questions
demographic_questions <- list(
  age_range = list(
    question = "What is your age range?",
    options = c("18-24", "25-34", "35-44", "45-54", "55+"),
    required = FALSE
  ),
  r_experience = list(
    question = "How many years have you been using R for package development?",
    options = c("Less than 1 year", "1-3 years", "3-5 years", "5+ years"),
    required = FALSE
  )
)

# Create study configuration using the new Monochrome theme
study_config <- create_study_config(
  name = "Psychological Study on R Package Testing Experience",
  
  # Use the elegant Monochrome theme
  theme = "Monochrome",
  
  # Demographics configuration
  demographics = c("age_range", "r_experience"),
  input_types = list(
    age_range = "radio",
    r_experience = "radio"
  ),
  
  # Study parameters
  study_key = "r_testing_psychology_2025",
  model = "GRM",  # Graded Response Model for Likert scales
  
  # Fixed questionnaire (not adaptive)
  adaptive = FALSE,
  max_items = 6,
  min_items = 6,
  
  # UI configuration
  response_ui_type = "radio",
  progress_style = "bar",
  
  # Session management (20-minute timer)
  session_save = TRUE,
  session_timeout = 20,
  
  # Demographic configurations
  demographic_configs = demographic_questions,
  
  # Custom instructions
  instructions = list(
    welcome = paste0(
      "Thank you for participating in this psychological study conducted by researchers ",
      "investigating the experiences of R developers in package testing. This study explores ",
      "how tools such as testthat, covr, and devtools influence developer confidence, stress, ",
      "and motivation. Your participation will contribute to improving tools and support for ",
      "the R community."
    ),
    
    purpose = "To examine psychological factors affecting R package testing workflows.",
    duration = "Approximately 15-20 minutes.",
    
    structure = paste0(
      "The study consists of a consent form, demographic questions, and a main survey ",
      "with Likert-scale questions. All questions are optional, but complete responses ",
      "are appreciated."
    ),
    
    confidentiality = paste0(
      "Your responses are anonymous and will be used solely for research purposes. ",
      "Data will be stored securely and reported in aggregate form."
    ),
    
    consent_text = paste0(
      "This study involves completing a survey about your experiences with R package ",
      "testing tools. Participation is voluntary, and you may withdraw at any time by ",
      "closing this window. Your responses will be anonymized and used for academic ",
      "research only. There are no known risks, and your participation will help advance ",
      "knowledge in software development psychology."
    ),
    
    contact = "For questions, contact the research team at research@example.edu."
  ),
  
  # Custom recommendation function based on responses
  recommendation_fun = function(theta, demographics) {
    if (is.null(theta) || length(theta) == 0) {
      return("Thank you for participating in this psychological study on R package testing.")
    }
    
    # Calculate average response level
    avg_score <- mean(theta, na.rm = TRUE)
    
    # Provide personalized feedback
    if (avg_score >= 1) {
      feedback <- paste0(
        "Your responses indicate high confidence and positive experiences with R testing tools. ",
        "Consider sharing your expertise with the community through tutorials or mentoring. ",
        "Your positive attitude toward testing contributes to the overall quality of R packages."
      )
    } else if (avg_score >= 0) {
      feedback <- paste0(
        "Your responses show moderate comfort with R testing tools. Consider exploring ",
        "advanced testing techniques or joining R testing communities for support. ",
        "Resources like the R Testing Guide and testthat documentation may be helpful."
      )
    } else {
      feedback <- paste0(
        "Your responses suggest room for growth in R testing practices. Consider starting ",
        "with basic testthat tutorials and gradually building your testing skills. ",
        "The R community offers many resources for learning testing best practices."
      )
    }
    
    return(feedback)
  }
)

# Display study information
cat("=== Psychological Study on R Package Testing Experience ===\n")
cat("Theme: Monochrome\n")
cat("Items:", nrow(r_testing_items), "\n")
cat("Demographics:", length(study_config$demographics), "\n")
cat("Timer: 20 minutes\n")
cat("Model: GRM (Graded Response Model)\n")
cat("\nAvailable themes:", paste(get_builtin_themes(), collapse = ", "), "\n")
cat("\nTo launch the study, run:\n")
cat("launch_study(config = study_config, item_bank = r_testing_items, port = 3838)\n")

# Validate the configuration
cat("\n=== Validation ===\n")
validation_result <- validate_item_bank(r_testing_items, model = "GRM")
if (validation_result$valid) {
  cat("✓ Item bank validation passed\n")
} else {
  cat("✗ Item bank validation failed:\n")
  cat(validation_result$errors, "\n")
}

# Test theme loading
cat("\n=== Theme Test ===\n")
theme_css <- load_theme_css("Monochrome")
if (nchar(theme_css) > 1000) {
  cat("✓ Monochrome theme loaded successfully (", nchar(theme_css), " characters)\n")
} else {
  cat("✗ Monochrome theme loading failed\n")
}

# Show case-insensitive theme matching
cat("\n=== Case-Insensitive Theme Matching ===\n")
test_themes <- c("monochrome", "MONOCHROME", "Monochrome", "MonoChrome")
for (theme in test_themes) {
  result <- validate_theme_name(theme)
  if (!is.null(result)) {
    cat("✓", theme, "->", result, "\n")
  } else {
    cat("✗", theme, "-> validation failed\n")
  }
}

# Example launch (commented out to prevent automatic execution)
# launch_study(
#   config = study_config,
#   item_bank = r_testing_items,
#   port = 3838,
#   launch_browser = TRUE
# )
