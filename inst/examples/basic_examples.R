# INREP Package - Basic Examples
# ==============================
# 
# This file contains simple, clean examples for using the inrep package
# for adaptive testing and psychological assessment.

library(inrep)

# Example 1: Basic Study Launch
# -----------------------------
# Launch a study with default settings using the built-in BFI item bank

\dontrun{
  # Basic study launch (interactive - opens in browser)
  config <- create_study_config(
    name = "Personality Assessment Study",
    model = "GRM",
    max_items = 20,
    min_items = 10,
    criteria = "MI",
    theme = "Professional"
  )

  launch_study(config, inrep::bfi_items)
}

# Example 2: Customized Study Configuration
# -----------------------------------------
# Create a more customized study with specific parameters

\dontrun{
  # Configure study parameters
  study_config <- create_study_config(
    study_title = "Big Five Personality Assessment",
    instructions = "Please respond to the following statements based on how accurately they describe you.",
    max_items = 25,
    min_items = 10,
    theta_range = c(-4, 4),
    se_threshold = 0.3,
    response_format = list(
      type = "likert",
      scale = 1:5,
      labels = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
    )
  )

  # Launch study with custom configuration
  launch_study(
    item_bank = inrep::bfi_items,
    config = study_config,
    theme = "professional"
  )
}

# Example 3: Advanced Features
# ----------------------------
# Demonstrate advanced adaptive testing features

\dontrun{
  # Advanced study with comprehensive configuration
  config <- create_study_config(
    name = "Advanced Adaptive Assessment",
    model = "GRM",
    max_items = 30,
    min_items = 15,
    criteria = "MI",
    theme = "Midnight",
    estimation_method = "EAP",
    adaptive = TRUE,
    show_progress = TRUE,
    session_save = TRUE
  )

  launch_study(config, inrep::bfi_items)
}

# Example 4: Custom Item Bank
# ---------------------------
# Using your own item bank

\dontrun{
  # Example item bank structure for GRM model
  custom_items <- data.frame(
    Question = c(
      "I enjoy working in teams.",
      "I am detail-oriented.",
      "I prefer challenging tasks.",
      "I am comfortable with uncertainty.",
      "I enjoy learning new things.",
      "I handle stress well.",
      "I am organized.",
      "I am creative.",
      "I am reliable.",
      "I enjoy routine work."
    ),
    a = c(1.3, 1.4, 1.2, 1.1, 1.2, 1.4, 1.5, 1.1, 1.3, 1.2),
    b1 = c(-1.5, -1.2, -1.8, -1.9, -1.7, -1.5, -1.1, -1.7, -1.4, -1.5),
    b2 = c(-0.5, -0.2, -0.8, -0.9, -0.7, -0.5, -0.1, -0.7, -0.4, -0.5),
    b3 = c(0.5, 0.8, 0.2, 0.1, 0.3, 0.5, 0.9, 0.3, 0.6, 0.5),
    b4 = c(1.5, 1.8, 1.2, 1.1, 1.3, 1.5, 1.9, 1.3, 1.6, 1.5),
    ResponseCategories = rep("1,2,3,4,5", 10),
    domain = c("Extraversion", "Conscientiousness", "Openness",
               "Openness", "Openness", "Neuroticism",
               "Conscientiousness", "Openness", "Conscientiousness",
               "Conscientiousness"),
    stringsAsFactors = FALSE
  )

  # Launch study with custom items
  config <- create_study_config(
    name = "Custom Work Personality Assessment",
    model = "GRM",
    max_items = 10,
    min_items = 5,
    criteria = "MI",
    theme = "Forest"
  )

  launch_study(config, custom_items)
}

# Example 5: Theme Customization
# ------------------------------
# Creating and using custom themes

\dontrun{
  # Option 1: Use built-in themes
  config <- create_study_config(
    name = "Dyslexia-Friendly Assessment",
    model = "GRM",
    max_items = 20,
    min_items = 10,
    criteria = "MI",
    theme = "Dyslexia-Friendly"  # Built-in accessibility theme
  )

  launch_study(config, inrep::bfi_items)

  # Option 2: Custom theme configuration
  custom_theme_config <- list(
    colors = list(
      primary = "#2E5984",
      secondary = "#4A90B8",
      background = "#F8F9FA",
      text = "#2C3E50",
      border = "#E1E8ED"
    ),
    fonts = list(
      heading = "Georgia, serif",
      body = "Georgia, serif"
    ),
    borders = list(
      radius = "12px",
      width = "2px"
    )
  )

  config_custom <- create_study_config(
    name = "Custom Themed Study",
    model = "GRM",
    max_items = 20,
    min_items = 10,
    criteria = "MI",
    theme = custom_theme_config
  )

  launch_study(config_custom, inrep::bfi_items)

  # Option 3: Use theme editor
  # launch_theme_editor()  # Opens interactive theme editor
}
