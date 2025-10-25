# Purpose: Demonstrates various use cases of the inrep package following vignette patterns
# This script provides clear, self-contained examples that guide users from basic to advanced configurations.
# Each example launches a study and includes detailed explanations for educational purposes.
# Based on patterns from vignettes and case studies.

# Required packages
library(inrep)

# =============================================================================
# HELPER: Simple Results Processor (following vignette patterns)
# =============================================================================

create_simple_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  tryCatch({
    if (is.null(responses) || length(responses) == 0) {
      return(shiny::HTML("<p>No responses available.</p>"))
    }

    mean_score <- mean(responses, na.rm = TRUE)

    # Create basic visualization (following vignette approach)
    plot_base64 <- ""
    if (requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("base64enc", quietly = TRUE)) {
      tryCatch({
        plot_data <- data.frame(
          Item = 1:length(responses),
          Score = responses
        )

        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = Item, y = Score)) +
          ggplot2::geom_bar(stat = "identity", fill = "#4A90E2", alpha = 0.7) +
          ggplot2::labs(title = "Your Responses", x = "Item", y = "Score") +
          ggplot2::theme_minimal()

        temp_file <- tempfile(fileext = ".png")
        ggplot2::ggsave(temp_file, p, width = 8, height = 5, dpi = 150, bg = "white")
        plot_base64 <- base64enc::base64encode(temp_file)
        unlink(temp_file)
      }, error = function(e) invisible(NULL))
    }

    # Simple HTML report (following vignette style)
    html <- paste0(
      '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
      '<h1 style="color: #4A90E2; text-align: center;">Study Results</h1>',

      if (plot_base64 != "" && nchar(plot_base64) > 100) paste0(
        '<div style="margin: 30px 0;">',
        '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 20px auto;">',
        '</div>'
      ) else "",

      '<div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<h2 style="color: #4A90E2;">Summary</h2>',
      '<p style="font-size: 18px;">Average Score: <strong>', round(mean_score, 2), '</strong></p>',
      '<p>Thank you for your participation!</p>',
      '</div>',

      '</div>'
    )

    return(shiny::HTML(html))
  }, error = function(e) {
    return(shiny::HTML('<div style="padding: 20px;"><h2>Error generating report</h2></div>'))
  })
}

# =============================================================================
# Example 1: Basic Adaptive Test with GRM (from vignettes)
# =============================================================================
# Purpose: Introduce beginners to a simple adaptive test using the Graded Response Model (GRM).

# Create a basic configuration (from getting-started vignette)
config <- create_study_config(
  name = "A First Adaptive Test",
  model = "GRM",
  max_items = 10,
  min_items = 5,
  criteria = "MI",
  results_processor = create_simple_report
)

# Launch the adaptive test
launch_study(config, bfi_items)

# =============================================================================
# Example 2: Custom Work Personality Assessment (from vignettes)
# =============================================================================
# Purpose: Demonstrate creating a custom item bank for workplace personality assessment.

# Custom personality item bank for work-related traits (from vignette)
  work_personality_items <- data.frame(
    # Unique identifiers
    item_id = paste0("WORK_", sprintf("%03d", 1:20)),

    # Question text
    Question = c(
      "I prefer working in teams rather than alone.",
      "I enjoy taking on leadership responsibilities.",
      "I am comfortable with ambiguity and uncertainty.",
      "I pay close attention to details in my work.",
      "I am good at managing my time effectively.",
      "I enjoy learning new skills and technologies.",
      "I handle stress well in demanding situations.",
      "I am comfortable presenting ideas to others.",
      "I prefer structure and routine in my work.",
      "I am motivated by challenging goals.",
      "I enjoy helping and supporting my colleagues.",
      "I am comfortable with public speaking.",
      "I prefer working with data and numbers.",
      "I enjoy creative problem-solving.",
      "I am good at meeting deadlines.",
      "I prefer working independently.",
      "I am comfortable with change and adaptation.",
      "I enjoy mentoring and teaching others.",
      "I pay attention to quality in my work.",
      "I am good at organizing tasks and projects."
    ),

    # IRT parameters
    a = c(1.2, 1.4, 1.1, 1.3, 1.5, 1.2, 1.4, 1.1, 1.3, 1.2,
          1.3, 1.1, 1.4, 1.2, 1.5, 1.1, 1.3, 1.2, 1.4, 1.1),

    # Threshold parameters for 5-point scale
    b1 = c(-1.8, -1.5, -1.9, -1.6, -1.4, -1.7, -1.5, -1.8, -1.6, -1.7,
           -1.5, -1.9, -1.4, -1.8, -1.3, -1.9, -1.6, -1.7, -1.5, -1.8),
    b2 = c(-0.8, -0.5, -0.9, -0.6, -0.4, -0.7, -0.5, -0.8, -0.6, -0.7,
           -0.5, -0.9, -0.4, -0.8, -0.3, -0.9, -0.6, -0.7, -0.5, -0.8),
    b3 = c(0.2, 0.5, 0.1, 0.4, 0.6, 0.3, 0.5, 0.2, 0.4, 0.3,
           0.5, 0.1, 0.6, 0.2, 0.7, 0.1, 0.4, 0.3, 0.5, 0.2),
    b4 = c(1.2, 1.5, 1.1, 1.4, 1.6, 1.3, 1.5, 1.2, 1.4, 1.3,
           1.5, 1.1, 1.6, 1.2, 1.7, 1.1, 1.4, 1.3, 1.5, 1.2),

    # Response categories (5-point Likert scale)
    ResponseCategories = rep("1,2,3,4,5", 20),

    # Domain classification
    domain = c(
      rep("Extraversion", 4),
      rep("Conscientiousness", 4),
      rep("Openness", 4),
      rep("Agreeableness", 4),
      rep("Neuroticism", 4)
    ),

    # Reverse coded items (negative wording)
    reverse_coded = c(FALSE, FALSE, FALSE, FALSE, FALSE,
                      FALSE, FALSE, FALSE, TRUE, FALSE,
                      FALSE, FALSE, FALSE, FALSE, FALSE,
                      TRUE, FALSE, FALSE, FALSE, FALSE),

    stringsAsFactors = FALSE
  )

# Launch study with custom item bank
config <- create_study_config(
  name = "Work Personality Assessment",
  model = "GRM",
  max_items = 10,
  min_items = 5,
  criteria = "MI",
  theme = "Professional",
  results_processor = create_simple_report
)

launch_study(config, work_personality_items)

# =============================================================================
# Example 3: Binary Math Knowledge Test (from vignettes)
# =============================================================================
# Purpose: Demonstrate binary item bank for knowledge assessment.

# Binary item bank for mathematics knowledge test (from vignette)
  math_knowledge_items <- data.frame(
    item_id = paste0("MATH_", sprintf("%03d", 1:30)),

    Question = c(
      # Basic arithmetic
      "What is 15 + 27?",
      "What is 84 ÷ 12?",
      "What is 7 × 9?",
      "What is 144 ÷ 16?",
      "What is 25% of 200?",

      # Fractions
      "What is 1/2 + 1/4?",
      "What is 3/4 - 1/2?",
      "What is 2/3 × 3/4?",
      "What is 5/6 ÷ 1/3?",
      "What is 40% as a fraction?",

      # Algebra
      "Solve: 2x + 3 = 11",
      "What is x if 3x - 7 = 14?",
      "Simplify: 4x + 2x - x",
      "If y = 2x + 1, what is y when x = 3?",
      "What is the slope of y = 3x + 2?",

      # Geometry
      "What is the area of a rectangle (length 8, width 5)?",
      "What is the circumference of a circle (radius 4)?",
      "What is the area of a triangle (base 6, height 8)?",
      "How many degrees in a triangle?",
      "What is the volume of a cube (side 3)?",

      # Advanced topics
      "What is √144?",
      "What is 2³ (2 cubed)?",
      "What is the perimeter of a square (side 6)?",
      "What is 30% of 150?",
      "Solve: x² = 36",
      "What is the area of a circle (radius 5)?",
      "What is 5! (5 factorial)?",
      "What is log₁₀(100)?",
      "What is sin(90°)?",
      "What is the hypotenuse of a 3-4-5 triangle?"
    ),

    # IRT parameters for 2PL model
    a = round(runif(30, 0.8, 2.5), 2),
    b = round(rnorm(30, 0, 1.2), 2),

    # Correct answers (for scoring)
    Answer = c(
      42, 7, 63, 9, 50,    # Basic arithmetic
      0.75, 0.25, 0.5, 2.5, 0.4,  # Fractions
      4, 7, 5, 7, 3,       # Algebra
      40, 25.12, 24, 180, 27,  # Geometry
      12, 8, 36, 45, 6, 78.5, 120, 2, 1, 5  # Advanced
    ),

    # Domain classification
    domain = c(
      rep("Arithmetic", 5),
      rep("Fractions", 5),
      rep("Algebra", 5),
      rep("Geometry", 5),
      rep("Advanced", 10)
    ),

    # Difficulty levels
    difficulty_level = c(
      rep("Easy", 10),
      rep("Medium", 10),
      rep("Hard", 10)
    ),

    stringsAsFactors = FALSE
  )

# Launch binary assessment
config <- create_study_config(
  name = "Math Knowledge Test",
  model = "2PL",
  max_items = 15,
  min_items = 8,
  criteria = "MI",
  theme = "Midnight",
  results_processor = create_simple_report
)

launch_study(config, math_knowledge_items)

# =============================================================================
# Example 4: Hildesheim University Theme (from case studies)
# =============================================================================
# Purpose: Demonstrate university-branded assessment with custom styling.

# Use Hildesheim theme (from case study)
config <- create_study_config(
  name = "Big Five Personality Assessment",
  model = "GRM",
  max_items = 20,
  min_items = 10,
  criteria = "MI",
  theme = "Hildesheim",
  estimation_method = "EAP",
  results_processor = create_simple_report
)

# Add demographic collection
demographic_configs <- list(
  Age = list(
    field_name = "Age",
    question_text = "What is your age?",
    input_type = "radio",
    options = c(
      "18 or younger" = 1, "19-20" = 2, "21-25" = 3,
      "26-30" = 4, "31-40" = 5, "41-50" = 6,
      "51-60" = 7, "61 or older" = 8
    ),
    required = TRUE
  ),

  Gender = list(
    field_name = "Gender",
    question_text = "How do you identify your gender?",
    input_type = "radio",
    options = c(
      "Female" = 1, "Male" = 2, "Non-binary" = 3,
      "Other" = 4, "Prefer not to say" = 5
    ),
    required = TRUE
  )
)

config$demographics <- names(demographic_configs)
config$demographic_configs <- demographic_configs
config$input_types <- list(Age = "radio", Gender = "radio")

launch_study(config, bfi_items)

# =============================================================================
# Example 5: Accessibility-Focused Assessment (from theme system)
# =============================================================================
# Purpose: Demonstrate accessibility features for users with different needs.

# Dyslexia-friendly assessment
config <- create_study_config(
  name = "Dyslexia-Friendly Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 8,
  criteria = "MI",
  theme = "Dyslexia-Friendly",
  estimation_method = "EAP",
  results_processor = create_simple_report
)

launch_study(config, bfi_items)

# High contrast assessment
config_hc <- create_study_config(
  name = "High Contrast Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 8,
  criteria = "MI",
  theme = "High-Contrast",
  results_processor = create_simple_report
)

launch_study(config_hc, bfi_items)

# =============================================================================
# Example 6: Mixed Parameter Item Bank (from vignettes)
# =============================================================================
# Purpose: Demonstrate handling of item banks with mixed known/unknown parameters.

# Item bank with mixed known/unknown parameters (from vignette)
mixed_items <- data.frame(
  item_id = paste0("MIX_", sprintf("%03d", 1:15)),

  Question = c(
    "I enjoy working in teams.",           # Known parameters
    "I am detail-oriented.",               # Known parameters
    "I prefer challenging tasks.",         # Known parameters
    "I am comfortable with uncertainty.",  # Unknown - will use defaults
    "I enjoy learning new things.",        # Unknown - will use defaults
    "I handle stress well.",               # Unknown - will use defaults
    "I am organized.",                     # Known parameters
    "I am creative.",                      # Known parameters
    "I am reliable.",                      # Known parameters
    "I enjoy routine work.",               # Unknown - will use defaults
    "I am patient.",                       # Unknown - will use defaults
    "I am decisive.",                      # Unknown - will use defaults
    "I am analytical.",                    # Known parameters
    "I am empathetic.",                    # Known parameters
    "I am ambitious."                      # Known parameters
  ),

  # Mix of known and unknown parameters
  a = c(1.3, 1.4, 1.2, NA, NA, NA, 1.5, 1.1, 1.3, NA, NA, NA, 1.4, 1.2, 1.1),
  b1 = c(-1.5, -1.2, -1.8, NA, NA, NA, -1.1, -1.7, -1.4, NA, NA, NA, -1.3, -1.6, -1.9),
  b2 = c(-0.5, -0.2, -0.8, NA, NA, NA, -0.1, -0.7, -0.4, NA, NA, NA, -0.3, -0.6, -0.9),
  b3 = c(0.5, 0.8, 0.2, NA, NA, NA, 0.9, 0.3, 0.6, NA, NA, NA, 0.7, 0.4, 0.1),
  b4 = c(1.5, 1.8, 1.2, NA, NA, NA, 1.9, 1.3, 1.6, NA, NA, NA, 1.7, 1.4, 1.1),

  ResponseCategories = rep("1,2,3,4,5", 15),
  domain = rep(c("Known", "Unknown"), c(9, 6)),

  stringsAsFactors = FALSE
)

# This will work perfectly - inrep handles the NA values automatically
config <- create_study_config(
  name = "Mixed Parameter Assessment",
  model = "GRM",
  max_items = 10,
  min_items = 5,
  criteria = "MI",
  theme = "Forest",
  results_processor = create_simple_report
)

launch_study(config, mixed_items)
