# Purpose: Demonstrates various use cases of the inrep package for adaptive and non-adaptive psychological assessments.
# This script provides clear, self-contained examples that guide users from basic to advanced configurations.
# Each chunk launches a study and includes detailed explanations for educational purposes.

# Required packages
library(inrep)
library(uuid)
library(shiny)

# Example 1: Basic Adaptive Test with GRM
# Purpose: Introduce beginners to a simple adaptive test using the Graded Response Model (GRM).
#' @description A straightforward adaptive test with default settings, ideal for users new to the inrep package.
#' @details Uses the built-in bfi_items dataset to assess personality traits with a maximum of 10 items.
#' @example
#' # Load the package and data
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create a basic configuration
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   max_items = 10,         # Stop after 10 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 1: Basic Adaptive Test with GRM\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)
#' 
#' # Alternatively, define a custom item bank
#' item_bank <- data.frame(
#'   Question = c("I am talkative.", "I am reserved.", "I am full of energy.", "I am quiet.", "I am outgoing."),
#'   a = c(1.2, 1.1, 1.3, 1.0, 1.2),
#'   b1 = c(-0.5, 0.5, -1.0, 1.0, -0.8),
#'   b2 = c(0.0, 1.0, -0.5, 1.5, -0.3),
#'   b3 = c(0.5, 1.5, 0.0, 2.0, 0.2),
#'   b4 = c(1.0, 2.0, 0.5, 2.5, 0.7),
#'   ResponseCategories = rep("1,2,3,4,5", 5)
#' )
#' 
#' # Launch with custom item bank
#' cat("Launching Example 1 (Custom Item Bank): Basic Adaptive Test with GRM\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, item_bank)

# Example 2: Multilingual Test in German
# Purpose: Demonstrate multilingual support for international users.
#' @description Runs an adaptive test in German, showcasing the package's ability to handle translations.
#' @details Uses the bfi_items dataset with a maximum of 12 items and German language settings.
#' @example
#' # Create configuration for German test
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   language = "de",        # German language
#'   max_items = 12,         # Stop after 12 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 2: Multilingual Test in German\n")
#' cat("Access at: http://localhost:3838\n")
#' cat("Note: Requires translated item bank (bfi_translations) for full functionality.\n")
#' launch_study(config, bfi_items)

# Example 3: Demographics with Custom Input Types
# Purpose: Show how to collect demographic data with varied input methods.
#' @description Configures a study with demographic questions (Age, Gender, Occupation) using numeric, select, and text inputs.
#' @details Runs an 8-item adaptive test with demographic collection before the assessment.
#' @example
#' # Create configuration with demographics
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   demographics = c("Age", "Gender", "Occupation"),
#'   input_types = list(Age = "numeric", Gender = "select", Occupation = "text"),
#'   max_items = 8,          # Stop after 8 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 3: Demographics with Custom Input Types\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 4: Fixed Item Sequence for Training
# Purpose: Demonstrate a non-adaptive test with a fixed item sequence.
#' @description Uses a predefined set of items for standardized assessments, ideal for training scenarios.
#' @details Administers 5 fixed items from the bfi_items dataset without adaptation.
#' @example
#' # Create configuration with fixed items
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   fixed_items = c(1, 4, 8, 11, 13), # Specific item indices
#'   adaptive = FALSE        # Disable adaptive selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 4: Fixed Item Sequence for Training\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 5: Early Adaptive Start with Initial Fixed Items
# Purpose: Combine fixed and adaptive testing for a hybrid approach.
#' @description Starts with 3 fixed items, then switches to adaptive selection up to 10 items.
#' @details Useful for ensuring initial standardization before adaptive testing.
#' @example
#' # Create configuration with hybrid approach
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   fixed_items = c(1, 2, 3), # Initial fixed items
#'   adaptive_start = 3,     # Start adaptive selection after 3 items
#'   max_items = 10,         # Stop after 10 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 5: Early Adaptive Start with Initial Fixed Items\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 6: Strict Stopping Rule Based on Precision
# Purpose: Highlight precision-based stopping for high-stakes testing.
#' @description Stops the test when the standard error (SE) drops below 0.25, between 5 and 15 items.
#' @details Prioritizes measurement accuracy for reliable results.
#' @example
#' # Create configuration with precision-based stopping
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   min_SEM = 0.25,         # Stop when SE < 0.25
#'   min_items = 5,          # Minimum 5 items
#'   max_items = 15,         # Maximum 15 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 6: Strict Stopping Rule Based on Precision\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 7: Custom Scoring for Reverse-Coded Items
# Purpose: Demonstrate custom scoring for complex response handling.
#' @description Reverses scoring for specific BFI items (e.g., reverse-coded items) in a 10-item test.
#' @details Shows flexibility in handling scoring logic.
#' @example
#' # Define custom scoring function
#' custom_scoring <- function(response, correct_answer) {
#'   reverse_items <- c(2, 5, 7, 10, 12, 15) # Example reverse-coded item indices
#'   if (response %in% reverse_items) {
#'     return(6 - as.numeric(response))
#'   } else {
#'     return(as.numeric(response))
#'   }
#' }
#' 
#' # Create configuration with custom scoring
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   scoring_fun = custom_scoring, # Custom scoring function
#'   max_items = 10,         # Stop after 10 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 7: Custom Scoring for Reverse-Coded Items\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 8: Trait-Specific Test (Extraversion Only)
# Purpose: Focus on a single personality trait for targeted assessment.
#' @description Limits the test to Extraversion items, stopping after 8 items.
#' @details Useful for research focusing on specific traits.
#' @example
#' # Create configuration for Extraversion-only test
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   item_groups = list(Extraversion = c(1, 2, 3, 5)), # Extraversion item indices
#'   max_items = 8,          # Stop after 8 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 8: Trait-Specific Test (Extraversion Only)\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 9: Personalized Recommendations
# Purpose: Provide tailored feedback based on test results.
#' @description Offers custom recommendations based on the theta score after a 10-item test.
#' @details Enhances user engagement with personalized feedback.
#' @example
#' # Define recommendation function
#' recommendation_fun <- function(theta, demographics) {
#'   if (theta > 1) return("You’re highly extraverted! Consider leadership roles.")
#'   else if (theta < -1) return("You’re introverted. Try solo creative tasks.")
#'   else return("You’re balanced. Explore diverse social settings.")
#' }
#' 
#' # Create configuration with recommendations
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   recommendation_fun = recommendation_fun, # Custom recommendation function
#'   max_items = 10,         # Stop after 10 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 9: Personalized Recommendations\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 10: Cloud-Based Study with Session Saving
# Purpose: Demonstrate session saving with cloud storage for persistent assessments.
#' @description Runs a 10-item test with session saving to a WebDAV server, using a unique study key.
#' @details Shows how to save progress for resumable sessions.
#' @example
#' # Create configuration with cloud saving
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   max_items = 10,         # Stop after 10 items
#'   session_save = TRUE,    # Enable session saving
#'   study_key = paste0("HILDESHEIM_", UUIDgenerate()), # Unique study key
#'   theme = "Berry"         # Custom theme
#' )
#' 
#' # Define WebDAV parameters
#' webdav_url <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
#' password <- "inreptest"   # Password for the public share
#' 
#' # Launch the study
#' cat("Launching Example 10: Cloud-Based Study with Session Saving\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(
#'   config = config,
#'   item_bank = bfi_items,
#'   save_format = "json",
#'   webdav_url = webdav_url,
#'   password = password
#' )

# Example 11: Enhanced Study Flow with Comprehensive Features
# Purpose: Showcase a fully featured study with introduction, consent, demographics, and debriefing.
#' @description Creates a comprehensive study with custom UI, GDPR compliance, and adaptive testing.
#' @details Includes all study phases and advanced UI customization for professional assessments.
#' @example
#' # Create comprehensive study configuration
#' create_enhanced_study_demo <- function() {
#'   cat("Creating Enhanced Study Flow Demonstration...\n")
#'   
#'   # Define custom demographic configurations
#'   demographic_configs <- list(
#'     Age = list(
#'       field_name = "Age",
#'       question_text = "What is your age in years?",
#'       input_type = "numeric",
#'       required = FALSE,
#'       allow_skip = TRUE,
#'       placeholder = "Enter your age",
#'       validation_rules = list(min_value = 18, max_value = 120, integer_only = TRUE)
#'     ),
#'     Gender = list(
#'       field_name = "Gender",
#'       question_text = "How do you identify your gender?",
#'       input_type = "select",
#'       required = FALSE,
#'       allow_skip = TRUE,
#'       options = c("Female" = "female", "Male" = "male", "Non-binary" = "non_binary", 
#'                   "Genderfluid" = "genderfluid", "Other" = "other", "Prefer not to answer" = "skip"),
#'       allow_other_text = TRUE
#'     )
#'   )
#'   
#'   # Create custom demographic UI
#'   custom_demographic_ui <- create_custom_demographic_ui(demographic_configs)
#'   
#'   # Create study configuration
#'   study_config <- create_study_config(
#'     name = "Enhanced Big Five Personality Assessment",
#'     model = "GRM",
#'     items = bfi_items,
#'     title = "Enhanced Big Five Personality Assessment",
#'     subtitle = "A Comprehensive Psychological Study with Full Study Flow",
#'     theme = "monochrome",
#'     show_introduction = TRUE,
#'     introduction_content = create_default_introduction_content(),
#'     show_briefing = TRUE,
#'     briefing_content = create_default_briefing_content(),
#'     show_consent = TRUE,
#'     consent_content = create_default_consent_content(),
#'     show_gdpr_compliance = TRUE,
#'     gdpr_content = create_default_gdpr_content(),
#'     show_debriefing = TRUE,
#'     debriefing_content = create_default_debriefing_content(),
#'     demographics = c("Age", "Gender"),
#'     demographic_configs = demographic_configs,
#'     custom_demographic_ui = custom_demographic_ui,
#'     study_phases = c("introduction", "briefing", "consent", "gdpr", "demographics", "assessment", "debriefing"),
#'     page_transitions = TRUE,
#'     enable_back_navigation = TRUE,
#'     max_items = 10,
#'     min_items = 5,
#'     se_target = 0.3,
#'     show_progress = TRUE,
#'     enable_adaptive = TRUE,
#'     stopping_rule = "se",
#'     ability_estimation = "EAP"
#'   )
#'   
#'   cat("Enhanced study configuration created successfully!\n")
#'   return(study_config)
#' }
#' 
#' # Launch the study
#' cat("Launching Example 11: Enhanced Study Flow with Comprehensive Features\n")
#' cat("Access at: http://localhost:3838\n")
#' study_config <- create_enhanced_study_demo()
#' launch_study(study_config)

# Example 12: Mathematics Proficiency with 2PL Model
# Purpose: Demonstrate an adaptive test for a non-personality domain using the 2PL model.
#' @description Assesses mathematics proficiency with adaptive testing and custom recommendations.
#' @details Uses a custom item bank with multiple-choice math questions and demographic collection.
#' @example
#' # Create item bank for mathematics
#' item_bank_2pl <- data.frame(
#'   Question = c("What is 2 + 2?", "What is 5 * 3?", "What is 10 - 4?", "What is 3 * 4?", "What is 8 / 2?"),
#'   a = c(1.2, 1.0, 1.1, 0.9, 1.3),
#'   b = c(0.5, -0.5, 0.0, 0.2, -0.3),
#'   Option1 = c("2", "10", "4", "9", "2"),
#'   Option2 = c("3", "12", "5", "10", "3"),
#'   Option3 = c("4", "15", "6", "12", "4"),
#'   Option4 = c("5", "18", "7", "15", "5"),
#'   Answer = c("4", "15", "6", "12", "4")
#' )
#' 
#' # Create configuration for math proficiency
#' config_2pl <- create_study_config(
#'   name = "Mathematics Proficiency",
#'   model = "2PL",
#'   max_items = 20,
#'   min_items = 5,
#'   min_SEM = 0.3,
#'   theta_prior = c(0, 1),
#'   adaptive = TRUE,
#'   theme = "Midnight",
#'   language = "en",
#'   demographics = c("Age", "Gender"),
#'   input_types = list(Age = "numeric", Gender = "select"),
#'   response_ui_type = "radio",
#'   progress_style = "circle",
#'   session_save = TRUE,
#'   max_session_duration = 30,
#'   recommendation_fun = function(theta, demo) {
#'     if (theta > 0) c("Consider advanced coursework", "Practice complex problems")
#'     else c("Review basic concepts", "Seek tutoring support")
#'   },
#'   response_validation_fun = function(resp) !is.null(resp) && length(resp) > 0,
#'   scoring_fun = function(resp, ans) as.numeric(resp == ans),
#'   study_key = paste0("MATH_", UUIDgenerate())
#' )
#' 
#' # Launch the study
#' cat("Launching Example 12: Mathematics Proficiency with 2PL Model\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config_2pl, item_bank_2pl)

# Example 13: Advanced Customization with Mixed IRT Models
# Purpose: Showcase the use of mixed IRT models for different item subsets in an adaptive test.
#' @description Applies a 2PL model to one subset and a GRM to another, demonstrating advanced flexibility.
#' @details Uses the bfi_items dataset with subset-specific models for a 12-item test.
#' @example
#' # Define item subsets with different models
#' item_subsets <- list(
#'   subset1 = list(indices = 1:5, model = "2PL"),
#'   subset2 = list(indices = 6:15, model = "GRM")
#' )
#' 
#' # Create configuration with mixed models
#' config <- create_study_config(
#'   model = "mixed",        # Mixed-model flag
#'   item_subsets = item_subsets, # Subset-specific models
#'   adaptive = TRUE,        # Adaptive testing
#'   criteria = "MFI",       # Maximum Fisher Information
#'   max_items = 12,         # Stop after 12 items
#'   min_items = 3,          # Minimum 3 items
#'   theme = "default",
#'   language = "en"
#' )
#' 
#' # Launch the study
#' cat("Launching Example 13: Advanced Customization with Mixed IRT Models\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)

# Example 14: Generate Standalone Assessment Script
# Purpose: Create a self-contained R script that runs independently of the inrep package.
#' @description Uses inrep_code() to generate a complete standalone script with smart features.
#' @details Perfect for sharing assessments, quick deployment, or console copy-paste.
#' @example
#' # Create configuration for standalone deployment
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   name = "Standalone Personality Assessment",
#'   max_items = 10,         # Stop after 10 items
#'   theme = "hildesheim",   # University theme
#'   session_save = TRUE,    # Enable session saving
#'   language = "en"
#' )
#' 
#' # Define cloud storage (optional)
#' webdav_url <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
#' password <- "inreptest"
#' 
#' # Method 1: Auto-save to file with auto-run (EASIEST!)
#' inrep_code(
#'   launch_study(config, bfi_items, 
#'                webdav_url = webdav_url, 
#'                password = password),
#'   output_file = "standalone_assessment",  # .R added automatically
#'   auto_run = TRUE  # Will launch immediately when run!
#' )
#' 
#' # Method 2: Console-ready for copy-paste deployment
#' standalone_script <- inrep_code(
#'   launch_study(config, bfi_items),
#'   console_ready = TRUE  # Optimized for copy-paste
#' )
#' # Now you can copy 'standalone_script' and paste into any R console!
#' 
#' # Method 3: Save to specific directory
#' inrep_code(
#'   launch_study(config, bfi_items),
#'   output_file = "C:/Projects/my_assessment.R",
#'   auto_run = FALSE  # User must uncomment launch line
#' )
#' 
#' cat("Launching Example 14: Generate Standalone Assessment Script\n")
#' cat("✅ Multiple deployment methods demonstrated!\n")
#' cat("🚀 Auto-run mode: Immediate deployment\n")
#' cat("📋 Console-ready: Copy-paste deployment\n")
#' cat("💾 File output: Smart file handling\n")
#' cat("🎯 Choose the method that works best for your workflow!\n")
