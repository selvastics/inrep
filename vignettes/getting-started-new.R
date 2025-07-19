## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)


## -----------------------------------------------------------------------------
# Install from GitHub
devtools::install_github("selvastics/inrep")


## -----------------------------------------------------------------------------
library(inrep)


## -----------------------------------------------------------------------------
# Load Big Five Inventory personality items
data(bfi_items)

# Examine the structure
head(bfi_items)
str(bfi_items)


## -----------------------------------------------------------------------------
# Validate for GRM model
is_valid <- validate_item_bank(bfi_items, model = "GRM")

if (is_valid) {
  cat("Item bank is ready for use!\\n")
} else {
  cat("Item bank needs fixes before use.\\n")
}


## -----------------------------------------------------------------------------
# Basic configuration for personality assessment
config <- create_study_config(
  name = "Big Five Personality Assessment",
  model = "GRM",                    # Graded Response Model
  max_items = 20,                   # Maximum items per participant
  min_items = 5,                    # Minimum items per participant
  min_SEM = 0.4,                    # Stop when SEM drops below 0.4
  demographics = c("Age", "Gender", "Education"),
  language = "en",                  # English interface
  theme = "professional"            # Professional appearance
)


## -----------------------------------------------------------------------------
# Launch the study
launch_study(config, bfi_items)


## -----------------------------------------------------------------------------
# 1-Parameter Logistic (Rasch) Model
config_1pl <- create_study_config(
  name = "Reading Assessment",
  model = "1PL"
)

# 2-Parameter Logistic Model
config_2pl <- create_study_config(
  name = "Math Assessment", 
  model = "2PL"
)

# 3-Parameter Logistic Model
config_3pl <- create_study_config(
  name = "Multiple Choice Test",
  model = "3PL"
)

# Graded Response Model (for Likert scales)
config_grm <- create_study_config(
  name = "Personality Assessment",
  model = "GRM"
)


## -----------------------------------------------------------------------------
config <- create_study_config(
  name = "Precise Assessment",
  max_items = 30,          # Never exceed 30 items
  min_items = 10,          # Always give at least 10 items
  min_SEM = 0.3,          # Stop when precision is high (SEM < 0.3)
  max_time = 1800         # Stop after 30 minutes
)


## -----------------------------------------------------------------------------
config <- create_study_config(
  name = "Adaptive Test",
  item_selection = "maximum_information",  # Most informative items
  # Other options: "random", "fixed_sequence"
  content_balancing = TRUE,               # Balance content areas
  exposure_control = 0.2                  # Limit item overuse
)


## -----------------------------------------------------------------------------
# Load mathematics assessment items
data(math_items)

# Validate for 2PL model
validate_item_bank(math_items, model = "2PL")

# Configure mathematics assessment
math_config <- create_study_config(
  name = "Mathematics Assessment",
  model = "2PL",
  max_items = 25,
  min_SEM = 0.4,
  demographics = c("Grade", "School"),
  language = "en"
)

# Launch mathematics test
launch_study(math_config, math_items)


## -----------------------------------------------------------------------------
# Example: Simple knowledge test
custom_items <- data.frame(
  Question = c(
    "What is the capital of France?",
    "Who wrote Romeo and Juliet?",
    "What is 2 + 2?"
  ),
  a = c(1.2, 0.9, 1.5),           # Discrimination parameters
  b = c(0.0, 0.5, -1.0),          # Difficulty parameters
  Option1 = c("London", "Shakespeare", "3"),
  Option2 = c("Paris", "Dickens", "4"),
  Option3 = c("Berlin", "Austen", "5"),
  Option4 = c("Madrid", "Hemingway", "6"),
  Answer = c("Paris", "Shakespeare", "4")
)

# Validate custom item bank
validate_item_bank(custom_items, model = "2PL")

# Configure and launch
custom_config <- create_study_config(
  name = "General Knowledge Test",
  model = "2PL"
)

launch_study(custom_config, custom_items)


## -----------------------------------------------------------------------------
# German interface
config_de <- create_study_config(
  name = "Persönlichkeitsbewertung",
  language = "de",
  demographics = c("Alter", "Geschlecht")
)

# Spanish interface  
config_es <- create_study_config(
  name = "Evaluación de Personalidad",
  language = "es"
)

# French interface
config_fr <- create_study_config(
  name = "Évaluation de la Personnalité", 
  language = "fr"
)


## -----------------------------------------------------------------------------
# Professional theme
config_pro <- create_study_config(
  name = "Clinical Assessment",
  theme = "professional"
)

# Academic theme
config_academic <- create_study_config(
  name = "Research Study",
  theme = "academic"
)

# Dark theme
config_dark <- create_study_config(
  name = "Modern Assessment",
  theme = "dark"
)


## -----------------------------------------------------------------------------
# Results are saved in multiple formats:
# - RDS files for R analysis
# - CSV files for Excel/SPSS
# - JSON files for web applications
# - PDF reports for participants

# Load and analyze results
results <- readRDS("study_results.rds")

# View participant data
head(results$participants)

# View item responses
head(results$responses)

# View ability estimates
head(results$abilities)

