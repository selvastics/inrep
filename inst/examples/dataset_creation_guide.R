# =============================================================================
# GUIDE: How to Add New Datasets to the inrep Package
# =============================================================================
# This guide explains the complete process for adding new item bank datasets
# following the structure used by bfi_items, cognitive_items, and math_items.

# =============================================================================
# STEP 1: Create the Dataset Creation Script
# =============================================================================

# Example: Creating a "reading_items" dataset
create_reading_items <- function() {
  
  # Set seed for reproducibility
  set.seed(456)
  
  # Create the dataset
  reading_items <- data.frame(
    # Unique identifiers
    item_id = paste0("READ_", sprintf("%03d", 1:25)),
    
    # Question text
    Question = c(
      # Vocabulary items (1-10)
      "What does the word 'meticulous' mean?",
      "Choose the synonym for 'arduous':",
      "What is the opposite of 'diminish'?",
      "Which word means 'showing little emotion'?",
      "What does 'ubiquitous' mean?",
      "Choose the best meaning for 'pragmatic':",
      "What does 'ephemeral' mean?",
      "Which word means 'stubbornly refusing to change'?", 
      "What is a synonym for 'verbose'?",
      "What does 'ambiguous' mean?",
      
      # Reading comprehension (11-20)
      "What is the main idea of this passage?",
      "Which detail supports the author's argument?",
      "What can you infer from the text?",
      "What is the author's tone in this passage?",
      "Which sentence best summarizes the paragraph?",
      "What does the pronoun 'it' refer to in line 3?",
      "Based on the context, what does this word mean?",
      "What is the author's purpose in writing this?",
      "Which statement would the author likely agree with?",
      "What conclusion can be drawn from the evidence?",
      
      # Grammar and syntax (21-25)
      "Which sentence is grammatically correct?",
      "Choose the proper verb tense for this sentence:",
      "What type of clause is underlined in the sentence?",
      "Which punctuation mark is needed?",
      "What is the subject of this sentence?"
    ),
    
    # Domain classification
    domain = c(
      rep("Vocabulary", 10),
      rep("Reading_Comprehension", 10),
      rep("Grammar_Syntax", 5)
    ),
    
    # Difficulty levels
    difficulty_level = c(
      rep("Medium", 10),    # Vocabulary
      rep("Hard", 10),      # Reading comprehension
      rep("Easy", 5)        # Grammar
    ),
    
    # IRT parameters for GRM model
    a = round(runif(25, 0.9, 2.3), 2),  # Discrimination
    
    # Threshold parameters (ensure b1 < b2 < b3 < b4)
    b1 = round(rnorm(25, -1.4, 0.4), 2),
    b2 = round(rnorm(25, -0.4, 0.4), 2),
    b3 = round(rnorm(25, 0.6, 0.4), 2),
    b4 = round(rnorm(25, 1.6, 0.4), 2),
    
    # Response categories
    ResponseCategories = rep("1,2,3,4,5", 25),
    
    # Additional metadata
    grade_level = c(
      rep("8-10", 10),    # Vocabulary
      rep("9-12", 10),    # Reading comprehension  
      rep("6-9", 5)       # Grammar
    ),
    
    stringsAsFactors = FALSE
  )
  
  # Ensure proper threshold ordering
  for (i in 1:nrow(reading_items)) {
    thresholds <- sort(c(reading_items$b1[i], reading_items$b2[i], 
                        reading_items$b3[i], reading_items$b4[i]))
    reading_items$b1[i] <- thresholds[1]
    reading_items$b2[i] <- thresholds[2]
    reading_items$b3[i] <- thresholds[3]
    reading_items$b4[i] <- thresholds[4]
  }
  
  return(reading_items)
}

# =============================================================================
# STEP 2: Create the R Documentation File
# =============================================================================

create_reading_documentation <- function() {
  doc_content <- '
#\' Reading Assessment Item Bank for Educational Testing
#\'
#\' @description
#\' A comprehensive reading assessment item bank containing 25 items across three
#\' literacy domains, calibrated using the Graded Response Model (GRM) for adaptive
#\' testing in educational settings. This dataset focuses on reading comprehension,
#\' vocabulary knowledge, and language mechanics.
#\'
#\' @format Data frame with 25 rows and 9 columns:
#\' \\describe{
#\'   \\item{\\code{item_id}}{Character. Unique identifier (READ_001 to READ_025)}
#\'   \\item{\\code{Question}}{Character. Reading assessment question text}
#\'   \\item{\\code{domain}}{Character. Literacy domain classification:
#\'     \\itemize{
#\'       \\item Vocabulary - Word meaning and usage
#\'       \\item Reading_Comprehension - Text analysis and inference
#\'       \\item Grammar_Syntax - Language mechanics and structure
#\'     }
#\'   }
#\'   \\item{\\code{difficulty_level}}{Character. Subjective difficulty: Easy, Medium, Hard}
#\'   \\item{\\code{a}}{Numeric. Discrimination parameter for GRM model (0.9 to 2.3)}
#\'   \\item{\\code{b1,b2,b3,b4}}{Numeric. Threshold parameters for 5-point scale}
#\'   \\item{\\code{ResponseCategories}}{Character. Response scale "1,2,3,4,5"}
#\'   \\item{\\code{grade_level}}{Character. Recommended grade level}
#\' }
#\' 
#\' @source Simulated data based on common literacy assessment standards
#\'   and psychometric principles for educational measurement.
#\' 
#\' @keywords datasets reading literacy education assessment
#\' @name reading_items
#\' @usage data(reading_items)
#\'
#\' @examples
#\' \\dontrun{
#\' # Load and examine the dataset
#\' library(inrep)
#\' data(reading_items)
#\' 
#\' # Basic exploration
#\' str(reading_items)
#\' table(reading_items$domain)
#\' 
#\' # Create reading assessment
#\' config <- create_study_config(
#\'   name = "Reading Skills Assessment",
#\'   model = "GRM",
#\'   max_items = 15,
#\'   min_items = 8
#\' )
#\' 
#\' # Launch assessment
#\' # launch_study(config, reading_items)
#\' }
#\' 
#\' @seealso \\code{\\link{bfi_items}}, \\code{\\link{math_items}}, \\code{\\link{cognitive_items}}
"reading_items"
'
  
  # Write to file (you would save this as R/reading_items_data.R)
  writeLines(doc_content, "reading_items_documentation_template.R")
  cat("Documentation template created\n")
}

# =============================================================================
# STEP 3: Manual Steps to Complete the Process
# =============================================================================

manual_steps <- function() {
  cat("=== MANUAL STEPS TO ADD NEW DATASETS ===\n\n")
  
  cat("1. CREATE THE DATASET:\n")
  cat("   - Run the dataset creation function in R console\n")
  cat("   - Ensure you are in the package root directory\n")
  cat("   - Example: reading_items <- create_reading_items()\n\n")
  
  cat("2. SAVE THE DATASET:\n")
  cat("   - save(reading_items, file = 'data/reading_items.rda')\n\n")
  
  cat("3. CREATE DOCUMENTATION FILE:\n")
  cat("   - Create R/reading_items_data.R with roxygen2 documentation\n")
  cat("   - Follow the template provided by create_reading_documentation()\n\n")
  
  cat("4. UPDATE PACKAGE DOCUMENTATION:\n")
  cat("   - Run devtools::document() to generate .Rd files\n")
  cat("   - This creates man/reading_items.Rd\n\n")
  
  cat("5. UPDATE NAMESPACE (if needed):\n")
  cat("   - Usually automatic with roxygen2\n")
  cat("   - Check that dataset is exported properly\n\n")
  
  cat("6. VALIDATE THE DATASET:\n")
  cat("   - Test loading: data(reading_items)\n")
  cat("   - Run validation: validate_item_bank(reading_items, 'GRM')\n")
  cat("   - Check structure: str(reading_items)\n\n")
  
  cat("7. BUILD AND CHECK:\n")
  cat("   - devtools::check() to ensure package integrity\n")
  cat("   - devtools::build() to create package bundle\n\n")
  
  cat("8. EXAMPLE DATASETS YOU CAN CREATE:\n")
  cat("   - science_items (physics, chemistry, biology)\n")
  cat("   - social_studies_items (history, geography, civics)\n") 
  cat("   - language_items (foreign language proficiency)\n")
  cat("   - professional_skills_items (workplace competencies)\n")
  cat("   - clinical_items (psychological/medical assessments)\n\n")
}

# =============================================================================
# USAGE EXAMPLES
# =============================================================================

usage_examples <- function() {
  cat("=== USAGE EXAMPLES ===\n\n")
  
  cat("# Run this in R console from package directory:\n")
  cat('setwd("c:/Users/Selva/Documents/rpackages/inrep/github_version/inrep")\n')
  cat("source('inst/examples/dataset_creation_guide.R')\n\n")
  
  cat("# Create a new dataset:\n") 
  cat("reading_items <- create_reading_items()\n")
  cat("save(reading_items, file = 'data/reading_items.rda')\n\n")
  
  cat("# Create documentation template:\n")
  cat("create_reading_documentation()\n\n")
  
  cat("# View manual steps:\n")
  cat("manual_steps()\n\n")
}

# =============================================================================
# DATASET VALIDATION FUNCTIONS
# =============================================================================

validate_new_dataset <- function(dataset_name, dataset) {
  cat("=== VALIDATING DATASET:", dataset_name, "===\n")
  
  # Check structure
  cat("Structure check:\n")
  cat("  Rows:", nrow(dataset), "\n")
  cat("  Columns:", ncol(dataset), "\n")
  cat("  Required columns present:", 
      all(c("Question", "ResponseCategories", "a", "b1", "b2", "b3", "b4") %in% names(dataset)), "\n")
  
  # Check IRT parameters
  cat("\nIRT Parameter checks:\n")
  cat("  Discrimination range:", range(dataset$a), "\n")
  cat("  All discriminations > 0:", all(dataset$a > 0), "\n")
  
  # Check threshold ordering
  threshold_ordered <- TRUE
  for (i in 1:nrow(dataset)) {
    thresholds <- c(dataset$b1[i], dataset$b2[i], dataset$b3[i], dataset$b4[i])
    if (any(diff(thresholds) <= 0)) {
      threshold_ordered <- FALSE
      break
    }
  }
  cat("  Thresholds properly ordered:", threshold_ordered, "\n")
  
  # Check response categories
  cat("  Response categories consistent:", 
      all(dataset$ResponseCategories == "1,2,3,4,5"), "\n")
  
  cat("\nDataset validation:", ifelse(threshold_ordered, "PASSED", "FAILED"), "\n")
}

# Run examples and show usage
cat("=== DATASET CREATION GUIDE LOADED ===\n")
cat("Available functions:\n")
cat("  - create_reading_items(): Create example reading dataset\n")
cat("  - create_reading_documentation(): Create documentation template\n") 
cat("  - manual_steps(): Show step-by-step process\n")
cat("  - usage_examples(): Show usage examples\n")
cat("  - validate_new_dataset(): Validate dataset structure\n\n")

cat("To get started, run: manual_steps()\n")
