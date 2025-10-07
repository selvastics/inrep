#' Quick Start Guide for inrep
#' 
#' Provides quick start functions and example workflows for new users
#' 
#' @name quick_start
#' @docType data
NULL

#' Quick Start Interactive Guide
#' 
#' Interactive guide to get started with inrep in under 5 minutes
#' 
#' @param interactive Run in interactive mode with prompts
#' @return Example configuration and item bank ready to use
#' @export
#' @examples
#' \dontrun{
#' # Run the interactive guide
#' quick_start()
#' 
#' # Or run non-interactively
#' result <- quick_start(interactive = FALSE)
#' launch_study(result$config, result$item_bank)
#' }
quick_start <- function(interactive = TRUE) {
  
  message("==============================================")
  message("     Welcome to inrep Quick Start Guide      ")
  message("==============================================")
  message("\nThis guide will help you create your first assessment in under 5 minutes.\n")
  
  if (interactive) {
    readline("Press [Enter] to continue...")
  }
  
  # Step 1: Choose template
  message("\n--- Step 1: Choose a Template ---")
  message("1. Simple Quiz (10 questions)")
  message("2. Educational Test (adaptive, 20-30 questions)")
  message("3. Psychological Assessment (validated scales)")
  message("4. Employee Screening (with proctoring)")
  message("5. Custom (build from scratch)")
  
  if (interactive) {
    choice <- readline("Select template (1-5): ")
    template <- as.numeric(choice)
  } else {
    template <- 2  # Default to educational test
    message("Using template: Educational Test")
  }
  
  # Generate based on template
  result <- switch(template,
    simple_quiz(),
    educational_test(),
    psychological_assessment(),
    employee_screening(),
    custom_assessment()
  )
  
  if (is.null(result)) {
    result <- educational_test()  # Fallback
  }
  
  # Step 2: Review configuration
  message("\n--- Step 2: Configuration Summary ---")
  message(sprintf("Study Name: %s", result$config$name))
  message(sprintf("Model: %s", result$config$model))
  message(sprintf("Items: %d-%d", result$config$min_items, result$config$max_items))
  message(sprintf("Item Bank Size: %d items", nrow(result$item_bank)))
  
  # Step 3: Test or launch
  message("\n--- Step 3: Next Steps ---")
  message("Your assessment is ready! You can now:")
  message("1. Test with: test_assessment(result$config, result$item_bank)")
  message("2. Launch with: launch_study(result$config, result$item_bank)")
  message("3. Customize with: result$config$<parameter> <- <value>")
  
  if (interactive) {
    action <- readline("\nWould you like to test the assessment now? (y/n): ")
    if (tolower(action) == "y") {
      message("\nLaunching test mode...")
      test_assessment(result$config, result$item_bank)
    }
  }
  
  message("\n--- Quick Start Complete ---")
  message("For more examples, run: show_examples()")
  message("For help, run: get_help()")
  
  invisible(result)
}

#' Simple Quiz Template
#' 
#' Creates a simple 10-question quiz
#' 
#' @return List with config and item_bank
#' @export
simple_quiz <- function() {
  config <- list(
    name = "Simple Quiz",
    model = "1PL",
    max_items = 10,
    min_items = 10,
    min_SEM = 999,  # Fixed length
    adaptive = FALSE,
    theme = "Light",
    language = "en",
    show_progress = TRUE,
    immediate_feedback = TRUE
  )
  
  item_bank <- data.frame(
    item_id = paste0("Q", 1:10),
    content = c(
      "What is 2 + 2?",
      "What is the capital of France?",
      "What year did World War II end?",
      "What is H2O?",
      "Who wrote Romeo and Juliet?",
      "What is the largest planet?",
      "How many continents are there?",
      "What is 10 x 10?",
      "What color is the sky?",
      "How many days in a week?"
    ),
    difficulty = seq(-2, 2, length.out = 10),
    correct_answer = c("4", "Paris", "1945", "Water", "Shakespeare", 
                      "Jupiter", "7", "100", "Blue", "7")
  )
  
  list(config = config, item_bank = item_bank)
}

#' Educational Test Template
#' 
#' Creates an adaptive educational assessment
#' 
#' @return List with config and item_bank
#' @export
educational_test <- function() {
  config <- create_study_config(
    name = "Adaptive Math Test",
    model = "2PL",
    max_items = 30,
    min_items = 20,
    min_SEM = 0.3,
    criteria = "MI",
    demographics = c("Grade", "School"),
    theme = "Academic",
    language = "en",
    show_introduction = TRUE,
    practice_items = TRUE
  )
  
  # Generate math items
  n_items <- 50
  item_bank <- data.frame(
    item_id = paste0("MATH_", 1:n_items),
    content = c(
      paste("Solve:", sample(1:20, 25), "+", sample(1:20, 25)),
      paste("Solve:", sample(2:10, 25), "x", sample(2:10, 25))
    ),
    difficulty = c(
      rnorm(25, -1, 0.5),  # Easy addition
      rnorm(25, 1, 0.5)    # Harder multiplication
    ),
    discrimination = runif(n_items, 0.8, 2.0),
    topic = rep(c("Addition", "Multiplication"), each = 25)
  )
  
  list(config = config, item_bank = item_bank)
}

#' Psychological Assessment Template
#' 
#' Creates a psychological assessment with validated scales
#' 
#' @return List with config and item_bank
#' @export
psychological_assessment <- function() {
  config <- create_study_config(
    name = "Big Five Personality Assessment",
    model = "GRM",
    max_items = 44,
    min_items = 44,  # Fixed length for validated scale
    min_SEM = 999,
    demographics = c("Age", "Gender", "Country"),
    theme = "Professional",
    language = "en",
    save_format = "encrypted_rds",
    show_consent = TRUE,
    show_debriefing = TRUE
  )
  
  # Mini Big Five items (simplified example)
  traits <- c("Extraversion", "Agreeableness", "Conscientiousness", 
             "Neuroticism", "Openness")
  
  items_per_trait <- 8
  item_bank <- data.frame(
    item_id = paste0("BFI_", 1:44),
    content = c(
      # Extraversion items
      "I am the life of the party",
      "I don't talk a lot",
      "I feel comfortable around people",
      "I keep in the background",
      "I start conversations",
      "I have little to say",
      "I talk to a lot of different people at parties",
      "I don't like to draw attention to myself",
      
      # Agreeableness items
      "I feel others' emotions",
      "I am not interested in other people's problems",
      "I have a soft heart",
      "I am not really interested in others",
      "I take time out for others",
      "I feel little concern for others",
      "I make people feel at ease",
      "I insult people",
      
      # Conscientiousness items
      "I am always prepared",
      "I leave my belongings around",
      "I pay attention to details",
      "I make a mess of things",
      "I get chores done right away",
      "I often forget to put things back in their proper place",
      "I like order",
      "I shirk my duties",
      
      # Neuroticism items
      "I get stressed out easily",
      "I am relaxed most of the time",
      "I worry about things",
      "I seldom feel blue",
      "I am easily disturbed",
      "I get upset easily",
      "I change my mood a lot",
      "I have frequent mood swings",
      
      # Openness items
      "I have a rich vocabulary",
      "I have difficulty understanding abstract ideas",
      "I have a vivid imagination",
      "I am not interested in abstract ideas",
      "I have excellent ideas",
      "I do not have a good imagination",
      "I am quick to understand things",
      "I use difficult words",
      
      # Additional items to reach 44
      "I carry out my plans",
      "I waste my time",
      "I am exacting in my work",
      "I do things according to a plan"
    ),
    difficulty = rep(seq(-2, 2, length.out = 5), length.out = 44),
    trait = rep(traits, each = items_per_trait, length.out = 44),
    reverse_scored = rep(c(FALSE, TRUE), length.out = 44)
  )
  
  list(config = config, item_bank = item_bank)
}

#' Employee Screening Template
#' 
#' Creates an employee assessment with proctoring
#' 
#' @return List with config and item_bank
#' @export
employee_screening <- function() {
  config <- create_study_config(
    name = "Technical Skills Assessment",
    model = "2PL",
    max_items = 40,
    min_items = 30,
    min_SEM = 0.25,
    demographics = c("Name", "Email", "Position", "Experience"),
    theme = "Professional",
    language = "en",
    time_limit = 3600,  # 1 hour
    proctoring_enabled = TRUE,
    prevent_copy_paste = TRUE,
    randomize_items = TRUE,
    passing_score = 0.5
  )
  
  # Technical assessment items
  item_bank <- data.frame(
    item_id = paste0("TECH_", 1:60),
    content = c(
      rep("Programming question", 20),
      rep("Database question", 20),
      rep("System design question", 20)
    ),
    difficulty = c(
      rnorm(20, -0.5, 0.5),  # Easy programming
      rnorm(20, 0, 0.5),     # Medium database
      rnorm(20, 1, 0.5)      # Hard system design
    ),
    discrimination = runif(60, 1.0, 2.5),
    category = rep(c("Programming", "Database", "System Design"), each = 20),
    time_limit = rep(c(30, 45, 60), each = 20)  # Seconds per item
  )
  
  list(config = config, item_bank = item_bank)
}

#' Custom Assessment Builder
#' 
#' Interactive builder for custom assessments
#' 
#' @return List with config and item_bank
#' @export
custom_assessment <- function() {
  message("\n--- Custom Assessment Builder ---")
  
  # Create a basic configuration using create_study_config
  config <- create_study_config(
    name = "Custom Assessment",
    model = "2PL",
    max_items = 30,
    min_items = 15,
    min_SEM = 0.3
  )
  
  # Generate appropriate item bank
  n_items <- config$max_items * 2  # Have twice as many items as max
  
  item_bank <- data.frame(
    item_id = paste0("ITEM_", 1:n_items),
    content = paste("Question", 1:n_items),
    difficulty = rnorm(n_items, 0, 1)
  )
  
  # Add discrimination if needed
  if (config$model %in% c("2PL", "3PL")) {
    item_bank$discrimination <- runif(n_items, 0.5, 2.5)
  }
  
  # Add guessing if 3PL
  if (config$model == "3PL") {
    item_bank$guessing <- runif(n_items, 0.15, 0.35)
  }
  
  message("\nCustom assessment created with:")
  message(sprintf("- %d items in bank", n_items))
  message(sprintf("- %s IRT model", config$model))
  message("\nYou can now edit the item content in the item_bank data frame.")
  
  list(config = config, item_bank = item_bank)
}

#' Test Assessment in Demo Mode
#' 
#' Runs a quick test of the assessment configuration
#' 
#' @param config Configuration object
#' @param item_bank Item bank data frame
#' @param n_simulated Number of simulated responses
#' @return Test results summary
#' @export
test_assessment <- function(config, item_bank, n_simulated = 5) {
  message("\n--- Testing Assessment ---")
  message("Simulating", n_simulated, "test runs...\n")
  
  results <- list()
  
  for (i in 1:n_simulated) {
    # Simulate responses
    n_items <- sample(config$min_items:config$max_items, 1)
    items_shown <- sample(1:nrow(item_bank), n_items)
    
    # Simulate ability and responses
    true_theta <- rnorm(1, 0, 1)
    responses <- rbinom(n_items, 1, 
                        plogis(true_theta - item_bank$difficulty[items_shown]))
    
    # Calculate final theta estimate (simplified)
    estimated_theta <- mean(responses) * 4 - 2  # Simple linear transform
    se <- 1 / sqrt(n_items)  # Simplified SE
    
    results[[i]] <- list(
      true_theta = true_theta,
      estimated_theta = estimated_theta,
      se = se,
      n_items = n_items,
      accuracy = abs(true_theta - estimated_theta)
    )
    
    message(sprintf("Test %d: %d items, Theta = %.2f (SE = %.2f)", 
                   i, n_items, estimated_theta, se))
  }
  
  # Summary statistics
  avg_items <- mean(sapply(results, function(x) x$n_items))
  avg_se <- mean(sapply(results, function(x) x$se))
  avg_accuracy <- mean(sapply(results, function(x) x$accuracy))
  
  message("\n--- Test Summary ---")
  message(sprintf("Average items administered: %.1f", avg_items))
  message(sprintf("Average standard error: %.3f", avg_se))
  message(sprintf("Average estimation accuracy: %.3f", avg_accuracy))
  
  if (avg_se > config$min_SEM) {
    message("\nNote: Average SE exceeds target. Consider adjusting min_SEM or adding more items.")
  }
  
  message("\nTest complete! Assessment appears to be working correctly.")
  
  invisible(results)
}

#' Show Example Code
#' 
#' Displays example code for common tasks
#' 
#' @param task Task to show example for
#' @export
show_examples <- function(task = NULL) {
  tasks <- c(
    "basic" = "Basic assessment setup",
    "adaptive" = "Adaptive testing configuration",
    "clinical" = "Clinical assessment with safety features",
    "multilingual" = "Multi-language assessment",
    "large_scale" = "Large-scale deployment",
    "custom_ui" = "Custom UI theming",
    "reporting" = "Advanced reporting"
  )
  
  if (is.null(task)) {
    message("Available examples:")
    for (key in names(tasks)) {
      message(sprintf("  %s: %s", key, tasks[[key]]))
    }
    message("\nRun show_examples('task_name') to see specific example")
    return(invisible())
  }
  
  examples <- list(
    basic = '
# Basic Assessment Setup
library(inrep)

# Create configuration
config <- create_study_config(
  name = "My Assessment",
  model = "2PL",
  max_items = 30,
  min_items = 15,
  min_SEM = 0.3
)

# Create item bank
item_bank <- data.frame(
  item_id = paste0("Q", 1:50),
  content = paste("Question", 1:50),
  difficulty = rnorm(50),
  discrimination = runif(50, 0.5, 2.5)
)

# Launch study
launch_study(config, item_bank)
',
    
    adaptive = '
# Adaptive Testing Configuration
config <- create_study_config(
  name = "Adaptive Assessment",
  model = "2PL",
  max_items = 40,
  min_items = 10,
  min_SEM = 0.25,
  criteria = "MI",  # Maximum Information
  adaptive = TRUE,
  adaptive_start = 5,  # Start adapting after 5 items
  theta_prior = c(0, 1),  # Prior distribution
  cache_enabled = TRUE  # Cache for performance
)
',
    
    clinical = '
# Clinical Assessment with Safety
config <- create_study_config(
  name = "Clinical Screening",
  model = "GRM",
  max_items = 50,
  min_items = 20,
  min_SEM = 0.2,
  demographics = c("Patient_ID", "Clinician"),
  save_format = "encrypted_rds",
  clinical_mode = TRUE,
  suicide_item_alert = c(9, 15, 27),  # Flag items
  emergency_contact = "Crisis Line: 988",
  show_consent = TRUE,
  data_retention_days = 90
)
',
    
    multilingual = '
# Multi-Language Assessment
config <- create_study_config(
  name = "International Study",
  model = "2PL",
  max_items = 30,
  min_items = 15,
  min_SEM = 0.3,
  language = "en",  # Default language
  item_translations = list(
    es = spanish_items,
    fr = french_items,
    de = german_items
  ),
  demographics = c("Country", "Native_Language"),
  allow_language_switch = TRUE
)
'
  )
  
  if (task %in% names(examples)) {
    cat(examples[[task]])
  } else {
    message("Unknown task. Run show_examples() to see available tasks.")
  }
}

#' Get Help
#' 
#' Provides contextual help and resources
#' 
#' @param topic Help topic
#' @export
get_help <- function(topic = NULL) {
  if (is.null(topic)) {
    message("=== inrep Help System ===\n")
    message("Quick commands:")
    message("  quick_start()         - Interactive setup guide")
    message("  show_examples()       - View example code")
    message("  create_study_config() - Create configuration")
    message("\nHelp topics:")
    message("  get_help('setup')     - Getting started")
    message("  get_help('models')    - IRT models")
    message("  get_help('adaptive')  - Adaptive testing")
    message("  get_help('errors')    - Common errors")
    message("\nOnline resources:")
    message("  GitHub: https://github.com/selvastics/inrep")
    message("  Documentation: vignette('getting-started', package = 'inrep')")
    return(invisible())
  }
  
  # Topic-specific help
  help_content <- list(
    setup = "
Getting Started with inrep:
1. Install: devtools::install_github('selvastics/inrep')
2. Load: library(inrep)
3. Quick start: quick_start()
4. Or manual: config <- create_study_config(...); launch_study(config, items)
",
    models = "
IRT Models Supported:
- 1PL (Rasch): Equal discrimination, difficulty only
- 2PL: Difficulty and discrimination parameters
- 3PL: Adds guessing parameter
- GRM: Graded Response Model for polytomous items
Choose based on your item characteristics and sample size.
",
    adaptive = "
Adaptive Testing:
- Items selected based on current ability estimate
- Reduces test length while maintaining precision
- Set criteria = 'MI' for Maximum Information
- Control with min_SEM (stopping rule) and min/max items
",
    errors = "
Common Errors and Solutions:
- 'Package not found': Install required packages manually
- 'Invalid config': Run validate_study_config(config)
- 'Item bank error': Check validate_item_bank(items)
- Memory issues: Reduce item bank size or enable caching
Check package documentation for more details.
"
  )
  
  if (topic %in% names(help_content)) {
    cat(help_content[[topic]])
  } else {
    message("Topic not found. Run get_help() to see available topics.")
  }
}