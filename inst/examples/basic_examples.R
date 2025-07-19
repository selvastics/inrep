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
  launch_study(
    item_bank = inrep::bfi_items,
    study_title = "Personality Assessment Study",
    max_items = 20,
    theme = "academic"
  )
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
  # Advanced study with multiple IRT models and adaptive selection
  launch_study(
    item_bank = inrep::bfi_items,
    study_title = "Advanced Adaptive Assessment",
    max_items = 30,
    irt_model = "grm",  # Graded Response Model
    selection_method = "mfi",  # Maximum Fisher Information
    theme = "modern",
    enable_progress = TRUE,
    save_responses = TRUE
  )
}

# Example 4: Custom Item Bank
# ---------------------------
# Using your own item bank

\dontrun{
  # Example item bank structure
  custom_items <- data.frame(
    Item_ID = paste0("ITEM_", 1:10),
    Question = paste("Statement", 1:10),
    Trait = rep(c("Factor1", "Factor2"), each = 5),
    a = runif(10, 0.5, 2.0),  # Discrimination parameters
    b = rnorm(10, 0, 1),      # Difficulty parameters
    stringsAsFactors = FALSE
  )
  
  # Launch study with custom items
  launch_study(
    item_bank = custom_items,
    study_title = "Custom Assessment",
    max_items = 10,
    theme = "minimal"
  )
}

# Example 5: Theme Customization
# ------------------------------
# Creating and using custom themes

\dontrun{
  # Create custom theme
  my_theme <- create_theme(
    name = "my_custom_theme",
    primary_color = "#2E5984",
    secondary_color = "#4A90B8",
    background_color = "#F8F9FA",
    text_color = "#2C3E50",
    font_family = "Arial, sans-serif"
  )
  
  # Launch study with custom theme
  launch_study(
    item_bank = inrep::bfi_items,
    study_title = "Custom Themed Study",
    max_items = 20,
    theme = my_theme
  )
}
