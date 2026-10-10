# inrep: basic examples ----
# Each example starts a Shiny app; run them one at a time. The item
# parameters used here (bfi_items and the custom bank) are simulated, so the
# adaptive examples only show the mechanics.

library(inrep)

# Example 1: adaptive study with the built-in bank ----
config <- create_study_config(
  name = "Personality Assessment Study",
  model = "GRM",
  max_items = 20,
  min_items = 10,
  criteria = "MI",
  theme = "Professional"
)

launch_study(config, inrep::bfi_items)

# Example 2: more settings ----
# Response labels follow the study language; the stopping rule is
# max_items or a standard error below min_SEM.
study_config <- create_study_config(
  name = "Big Five Personality Assessment",
  instructions = "Please respond to the following statements based on how accurately they describe you.",
  max_items = 25,
  min_items = 10,
  min_SEM = 0.3,
  theta_grid = seq(-4, 4, length.out = 100),
  theme = "Professional"
)

launch_study(
  item_bank = inrep::bfi_items,
  config = study_config
)

# Example 3: EAP estimation and session saving ----
config <- create_study_config(
  name = "Adaptive Assessment",
  model = "GRM",
  max_items = 30,
  min_items = 15,
  criteria = "MI",
  theme = "Midnight",
  estimation_method = "EAP",
  adaptive = TRUE,
  progress_style = "bar",
  session_save = TRUE
)

launch_study(config, inrep::bfi_items)

# Example 4: your own item bank ----
# Structure for the GRM: a, b1 to b4 for five categories. The values are
# invented; in practice they come from a calibration (e.g. with TAM or mirt).
# The domain column is only descriptive here: the CAT treats all items as
# one dimension.
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

# Example 5: themes ----

# Option 1: a built-in theme
config <- create_study_config(
  name = "Dyslexia-Friendly Assessment",
  model = "GRM",
  max_items = 20,
  min_items = 10,
  criteria = "MI",
  theme = "Dyslexia-Friendly"  # cream background, OpenDyslexic font if installed; not tested for accessibility
)

launch_study(config, inrep::bfi_items)

# Option 2: a theme given as a list of colours, fonts and borders
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
