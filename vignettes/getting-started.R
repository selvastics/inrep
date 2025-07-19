## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 7,
  fig.height = 5
)
library(inrep)


## ----eval=FALSE---------------------------------------------------------------
# 
# # Install development version from GitHub
# devtools::install_github("your-repo/inrep")


## ----basic_example, eval=FALSE------------------------------------------------
# library(inrep)
# 
# # Load the built-in personality item bank
# data(bfi_items)
# 
# # Create a basic study configuration
# config <- create_study_config(
#   name = "My First Adaptive Test",
#   model = "2PL",                    # Two-parameter logistic model
#   estimation_method = "TAM",        # Use TAM for estimation
#   max_items = 10,                   # Maximum 10 items
#   min_items = 5,                    # Minimum 5 items
#   criteria = "MI"                   # Maximum Information criterion
# )
# 
# # Launch the adaptive test
# launch_study(config, bfi_items)


## ----examine_items------------------------------------------------------------
# Load the built-in Big Five personality item bank
data(bfi_items)

# Examine the structure
head(bfi_items, 3)
cat("Number of items:", nrow(bfi_items), "\n")
cat("Available columns:", names(bfi_items), "\n")


## ----detailed_config----------------------------------------------------------
# Create a more detailed configuration
advanced_config <- create_study_config(
  name = "Advanced Personality Assessment",
  model = "2PL",
  estimation_method = "TAM",        # Use TAM (MIRT will be added later)
  max_items = 20,
  min_items = 8,
  min_SEM = 0.3,                    # Stop when standard error < 0.3
  criteria = "MI",                  # Maximum Information
  adaptive = TRUE,                  # Enable adaptive selection
  theta_prior = c(0, 1),           # Prior: mean=0, sd=1
  demographics = c("Age", "Gender") # Collect demographics
)

# View the configuration
str(advanced_config)


## ----models_demo, eval=FALSE--------------------------------------------------
# # 1-Parameter Logistic (Rasch) Model - Equal discrimination
# config_1pl <- create_study_config(
#   name = "Rasch Model Test",
#   model = "1PL",
#   estimation_method = "TAM"
# )
# 
# # 2-Parameter Logistic Model - Variable discrimination
# config_2pl <- create_study_config(
#   name = "2PL Model Test",
#   model = "2PL",
#   estimation_method = "TAM"
# )
# 
# # 3-Parameter Logistic Model - Includes guessing
# config_3pl <- create_study_config(
#   name = "3PL Model Test",
#   model = "3PL",
#   estimation_method = "TAM"
# )
# 
# # Graded Response Model - For polytomous items
# config_grm <- create_study_config(
#   name = "GRM Likert Scale Test",
#   model = "GRM",
#   estimation_method = "TAM"
# )


## ----estimation_comparison, eval=FALSE----------------------------------------
# # Compare estimation methods
# set.seed(123)
# 
# # Simulate some responses
# responses <- c(1, 0, 1, 1, 0, 1, 0, 1)
# administered <- 1:8
# 
# # TAM estimation
# tam_result <- estimate_ability(
#   rv = list(responses = responses, administered = administered),
#   item_bank = bfi_items,
#   config = create_study_config(estimation_method = "TAM")
# )
# 
# # MIRT estimation
# mirt_result <- estimate_ability_mirt(
#   responses = responses,
#   administered = administered,
#   item_bank = bfi_items,
#   model = "2PL",
#   method = "EAP"
# )
# 
# cat("TAM estimate:", sprintf("θ = %.3f (SE = %.3f)", tam_result$theta, tam_result$se), "\n")
# cat("MIRT estimate:", sprintf("θ = %.3f (SE = %.3f)", mirt_result$theta, mirt_result$se), "\n")


## ----demographics_demo, eval=FALSE--------------------------------------------
# config_with_demographics <- create_study_config(
#   name = "Research Study",
#   demographics = c("Age", "Gender", "Education", "Experience"),
#   input_types = list(
#     Age = "numeric",
#     Gender = "select",
#     Education = "select",
#     Experience = "text"
#   )
# )


## ----stopping_rules, eval=FALSE-----------------------------------------------
# # Create a custom stopping rule
# custom_stopping <- function(rv, item_bank, config) {
#   # Stop if we have 10+ items AND standard error < 0.4
#   if (length(rv$administered) >= 10 && rv$current_se < 0.4) {
#     return(TRUE)
#   }
#   # Or if we've reached maximum items
#   if (length(rv$administered) >= config$max_items) {
#     return(TRUE)
#   }
#   return(FALSE)
# }
# 
# config_custom_stop <- create_study_config(
#   name = "Custom Stopping Rule Test",
#   stopping_rule = custom_stopping,
#   max_items = 25
# )


## ----validation---------------------------------------------------------------
# Validate item bank
validation_result <- validate_item_bank(bfi_items, "GRM")
cat("Item bank validation:", ifelse(validation_result, "PASSED", "FAILED"), "\n")

# Check configuration
config_test <- create_study_config(
  name = "Validation Test",
  model = "2PL",
  max_items = 10
)

cat("Configuration created successfully!\n")
cat("Study name:", config_test$name, "\n") 
cat("Model:", config_test$model, "\n")
cat("Max items:", config_test$max_items, "\n")


## ----educational_pattern, eval=FALSE------------------------------------------
# education_config <- create_study_config(
#   name = "Math Proficiency Test",
#   model = "1PL",                    # Rasch model for education
#   estimation_method = "TAM",        # Fast, reliable
#   max_items = 15,
#   min_items = 10,
#   min_SEM = 0.32,                   # Educational standard
#   criteria = "MI"
# )


## ----psychology_pattern, eval=FALSE-------------------------------------------
# research_config <- create_study_config(
#   name = "Personality Research Study",
#   model = "2PL",                    # Better fit for traits
#   estimation_method = "TAM",        # Reliable and fast
#   max_items = 30,
#   min_items = 15,
#   demographics = c("Age", "Gender", "Country"),
#   session_save = TRUE               # Save for later analysis
# )


## ----clinical_pattern, eval=FALSE---------------------------------------------
# clinical_config <- create_study_config(
#   name = "Depression Screening",
#   model = "GRM",                    # Polytomous responses
#   estimation_method = "TAM",        # Reliable for clinical use
#   max_items = 12,
#   min_items = 8,
#   min_SEM = 0.25,                   # High precision needed
#   criteria = "MI"
# )

