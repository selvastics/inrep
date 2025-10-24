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

# Create study configuration using the Monochrome theme
study_config <- create_study_config(
  name = "Psychological Study on R Package Testing Experience",

  # Use the elegant Monochrome theme
  theme = "Monochrome",

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
  max_session_duration = 20,

  # Demographic configurations
  demographics = c("age_range", "r_experience"),
  input_types = list(
    age_range = "radio",
    r_experience = "radio"
  ),
  demographic_configs = demographic_questions
)

# Fix item bank structure to match current API
r_testing_items$Question <- r_testing_items$item_text
r_testing_items$ResponseCategories <- rep("1,2,3,4,5", 6)
r_testing_items <- r_testing_items[, c("Question", "a", "b1", "b2", "b3", "b4", "ResponseCategories")]
r_testing_items$stringsAsFactors <- FALSE

# Instructions for participants
cat("Psychological Study on R Package Testing Experience\n")
cat("=============================================================\n")
cat("This study examines how R package testing tools affect developer confidence,\n")
cat("stress, and motivation. Uses a fixed 6-item questionnaire with Monochrome theme.\n")
cat("Estimated completion time: 15-20 minutes.\n")
cat("=============================================================\n\n")

# Launch the study
cat("Launching psychological study...\n")
cat("Access at: http://localhost:3838\n")
launch_study(study_config, r_testing_items)

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
  cat("[OK] Item bank validation passed\n")
} else {
  cat("X Item bank validation failed:\n")
  cat(validation_result$errors, "\n")
}

# Test theme loading
cat("\n=== Theme Test ===\n")
theme_css <- load_theme_css("Monochrome")
if (nchar(theme_css) > 1000) {
  cat("[OK] Monochrome theme loaded successfully (", nchar(theme_css), " characters)\n")
} else {
  cat("X Monochrome theme loading failed\n")
}

# Show case-insensitive theme matching
cat("\n=== Case-Insensitive Theme Matching ===\n")
test_themes <- c("monochrome", "MONOCHROME", "Monochrome", "MonoChrome")
for (theme in test_themes) {
  result <- validate_theme_name(theme)
  if (!is.null(result)) {
    cat("[OK]", theme, "->", result, "\n")
  } else {
    cat("X", theme, "-> validation failed\n")
  }
}

# Example launch (commented out to prevent automatic execution)
# launch_study(
#   config = study_config,
#   item_bank = r_testing_items,
#   port = 3838,
#   launch_browser = TRUE
# )
