#' Study Simulation Framework
#' 
#' Simulates various real-world study scenarios to identify and fix potential errors
#' 
#' @name study_simulations
#' @docType data
NULL

#' Simulate Educational Assessment Studies
#' 
#' Tests various educational assessment scenarios that users might create
#' 
#' @return List of simulation results with errors and fixes
#' @export
simulate_educational_studies <- function() {
  results <- list()
  
  # Scenario 1: Math test with adaptive branching
  tryCatch({
    config1 <- create_study_config(
      name = "Adaptive Math Assessment Grade 5-8",
      model = "2PL",
      max_items = 45,
      min_items = 15,
      min_SEM = 0.25,
      criteria = "MI",
      start_theta = -2,  # Students might start below average
      demographics = c("Grade", "School_ID", "Teacher", "Previous_Score"),
      input_types = list(
        Grade = "select",
        School_ID = "text", 
        Teacher = "text",
        Previous_Score = "numeric"
      ),
      language = "en"
    )
    
    # Simulate item bank with grade-specific items
    item_bank1 <- data.frame(
      item_id = paste0("MATH_", 1:200),
      content = rep(c("What is 2+2?", "Solve for x: 2x=10"), 100),
      difficulty = c(rnorm(50, -2, 0.5), rnorm(50, 0, 0.5), 
                    rnorm(50, 1, 0.5), rnorm(50, 2, 0.5)),
      discrimination = runif(200, 0.5, 2.5),
      grade_level = rep(5:8, each = 50),
      topic = rep(c("Arithmetic", "Algebra", "Geometry", "Statistics"), 50)
    )
    
    results$educational_math <- list(status = "success", config = config1)
  }, error = function(e) {
    results$educational_math <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Language assessment with multimedia items
  tryCatch({
    config2 <- create_study_config(
      name = "English Proficiency Test",
      model = "GRM",
      max_items = 60,
      min_items = 30,
      min_SEM = 0.3,
      demographics = c("Native_Language", "Years_Study", "Age", "Country"),
      input_types = list(
        Native_Language = "select",
        Years_Study = "numeric",
        Age = "numeric",
        Country = "select"
      ),
      theme = "Academic",
      language = "en",
      time_limit = 7200  # 2 hour time limit
    )
    
    # Items with audio/video components (URLs)
    item_bank2 <- data.frame(
      item_id = paste0("ENG_", 1:150),
      content = c(
        rep("Listen to audio and answer: [AUDIO_URL]", 30),
        rep("Watch video and respond: [VIDEO_URL]", 30),
        rep("Read passage and answer questions", 90)
      ),
      difficulty = rnorm(150, 0, 1),
      discrimination = runif(150, 0.8, 2.0),
      skill = rep(c("Listening", "Speaking", "Reading", "Writing"), length.out = 150),
      media_url = c(
        paste0("https://example.com/audio/", 1:30, ".mp3"),
        paste0("https://example.com/video/", 1:30, ".mp4"),
        rep(NA, 90)
      )
    )
    
    results$educational_language <- list(status = "success", config = config2)
  }, error = function(e) {
    results$educational_language <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Special education assessment with accommodations
  tryCatch({
    config3 <- create_study_config(
      name = "Special Education Screening",
      model = "1PL",  # Simpler model for special needs
      max_items = 20,
      min_items = 10,
      min_SEM = 0.4,  # More lenient stopping criterion
      demographics = c("IEP_Status", "Accommodations", "Disability_Type"),
      input_types = list(
        IEP_Status = "select",
        Accommodations = "checkbox",  # Multiple accommodations
        Disability_Type = "select"
      ),
      accessibility_enhanced = TRUE,
      font_size_adjustable = TRUE,
      high_contrast_available = TRUE,
      screen_reader_compatible = TRUE,
      extended_time_factor = 2.0  # Double time for special needs
    )
    
    results$educational_special <- list(status = "success", config = config3)
  }, error = function(e) {
    results$educational_special <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Clinical Psychology Studies
#' 
#' Tests various clinical assessment scenarios
#' 
#' @return List of simulation results
#' @export
simulate_clinical_studies <- function() {
  results <- list()
  
  # Scenario 1: Depression screening with skip logic
  tryCatch({
    config1 <- create_study_config(
      name = "PHQ-9 Depression Screening",
      model = "GRM",
      max_items = 9,
      min_items = 9,  # Fixed length assessment
      min_SEM = 999,  # Disable adaptive stopping
      demographics = c("Patient_ID", "Clinician", "Session_Number", "Medication"),
      input_types = list(
        Patient_ID = "text",
        Clinician = "select",
        Session_Number = "numeric",
        Medication = "checkbox"
      ),
      save_format = "encrypted_json",  # HIPAA compliance
      data_retention_days = 90,
      require_consent = TRUE,
      suicide_item_alert = c(9)  # Alert on item 9 (suicide ideation)
    )
    
    # Clinical items with severity levels
    item_bank1 <- data.frame(
      item_id = paste0("PHQ_", 1:9),
      content = c(
        "Little interest or pleasure in doing things",
        "Feeling down, depressed, or hopeless",
        "Trouble falling asleep or sleeping too much",
        "Feeling tired or having little energy",
        "Poor appetite or overeating",
        "Feeling bad about yourself",
        "Trouble concentrating",
        "Moving or speaking slowly",
        "Thoughts of self-harm"
      ),
      difficulty = seq(-2, 2, length.out = 9),
      discrimination = rep(1.5, 9),
      clinical_flag = c(rep(FALSE, 8), TRUE),  # Item 9 is flagged
      response_options = rep(4, 9)  # 0-3 scale
    )
    
    results$clinical_depression <- list(status = "success", config = config1)
  }, error = function(e) {
    results$clinical_depression <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Anxiety assessment with branching
  tryCatch({
    config2 <- create_study_config(
      name = "Comprehensive Anxiety Assessment",
      model = "2PL",
      max_items = 50,
      min_items = 20,
      min_SEM = 0.3,
      branching_rules = list(
        high_anxiety = list(theta_threshold = 1.5, next_module = "panic_items"),
        low_anxiety = list(theta_threshold = -1.5, next_module = "screening_only")
      ),
      demographics = c("Age", "Gender", "Diagnosis", "Treatment_History"),
      clinical_cutoffs = list(
        mild = -0.5,
        moderate = 0.5,
        severe = 1.5
      )
    )
    
    results$clinical_anxiety <- list(status = "success", config = config2)
  }, error = function(e) {
    results$clinical_anxiety <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Neuropsychological battery
  tryCatch({
    config3 <- create_study_config(
      name = "Cognitive Function Battery",
      model = "3PL",  # Include guessing parameter
      max_items = 120,
      min_items = 60,
      min_SEM = 0.25,
      modules = c("Memory", "Attention", "Executive", "Language", "Visuospatial"),
      demographics = c("Age", "Education", "Medical_History", "Medications"),
      time_per_item = 30,  # 30 seconds per item
      break_after_items = 30,  # Mandatory break every 30 items
      practice_items = TRUE,
      warm_up_items = 5
    )
    
    # Complex item bank with multiple domains
    item_bank3 <- data.frame(
      item_id = paste0("COG_", 1:300),
      content = rep("Cognitive task", 300),
      difficulty = rnorm(300, 0, 1.5),
      discrimination = runif(300, 0.5, 2.5),
      guessing = runif(300, 0.1, 0.3),
      domain = rep(c("Memory", "Attention", "Executive", "Language", "Visuospatial"), 60),
      item_type = rep(c("Recognition", "Recall", "Problem_Solving"), 100),
      requires_timer = sample(c(TRUE, FALSE), 300, replace = TRUE)
    )
    
    results$clinical_neuropsych <- list(status = "success", config = config3)
  }, error = function(e) {
    results$clinical_neuropsych <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Corporate HR Assessments
#' 
#' Tests various workplace assessment scenarios
#' 
#' @return List of simulation results
#' @export
simulate_corporate_studies <- function() {
  results <- list()
  
  # Scenario 1: Pre-employment screening
  tryCatch({
    config1 <- create_study_config(
      name = "Technical Skills Assessment",
      model = "2PL",
      max_items = 40,
      min_items = 25,
      min_SEM = 0.3,
      demographics = c("Applicant_ID", "Position", "Experience_Years", "Education"),
      proctoring_enabled = TRUE,
      webcam_monitoring = TRUE,
      prevent_copy_paste = TRUE,
      randomize_items = TRUE,
      time_limit = 3600,  # 1 hour
      passing_score = 0.5  # Theta > 0.5 to pass
    )
    
    # Technical items with categories
    item_bank1 <- data.frame(
      item_id = paste0("TECH_", 1:200),
      content = rep("Technical question", 200),
      difficulty = c(
        rnorm(50, -1, 0.5),  # Easy
        rnorm(100, 0, 0.5),   # Medium
        rnorm(50, 1, 0.5)     # Hard
      ),
      discrimination = runif(200, 1.0, 2.5),
      category = rep(c("Programming", "Database", "Networking", "Security"), 50),
      job_level = rep(c("Junior", "Mid", "Senior"), length.out = 200),
      contains_code = sample(c(TRUE, FALSE), 200, replace = TRUE)
    )
    
    results$corporate_technical <- list(status = "success", config = config1)
  }, error = function(e) {
    results$corporate_technical <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: 360-degree feedback assessment
  tryCatch({
    config2 <- create_study_config(
      name = "Leadership 360 Feedback",
      model = "GRM",
      max_items = 60,
      min_items = 60,  # Fixed length
      min_SEM = 999,
      demographics = c("Rater_ID", "Relationship", "Department", "Time_Known"),
      input_types = list(
        Rater_ID = "text",
        Relationship = "select",  # Self, Manager, Peer, Direct Report
        Department = "select",
        Time_Known = "numeric"
      ),
      anonymous_mode = TRUE,
      aggregate_results = TRUE,
      minimum_raters = 5,
      rater_categories = c("Self", "Manager", "Peer", "Direct_Report", "Customer")
    )
    
    # 360 feedback items
    item_bank2 <- data.frame(
      item_id = paste0("LEAD_", 1:60),
      content = rep("Leadership behavior", 60),
      difficulty = rep(seq(-2, 2, length.out = 5), 12),
      discrimination = runif(60, 1.0, 2.0),
      competency = rep(c("Communication", "Decision_Making", "Team_Building", 
                        "Strategic_Thinking", "Innovation"), 12),
      reverse_scored = sample(c(TRUE, FALSE), 60, replace = TRUE, prob = c(0.2, 0.8))
    )
    
    results$corporate_360 <- list(status = "success", config = config2)
  }, error = function(e) {
    results$corporate_360 <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Personality assessment for team building
  tryCatch({
    config3 <- create_study_config(
      name = "Team Dynamics Assessment",
      model = "GRM",
      max_items = 100,
      min_items = 50,
      min_SEM = 0.35,
      demographics = c("Employee_ID", "Team", "Role", "Tenure"),
      facets = c("Extraversion", "Agreeableness", "Conscientiousness", 
                "Neuroticism", "Openness"),
      report_type = "comprehensive",
      include_norms = TRUE,
      norm_group = "corporate_professionals",
      team_report = TRUE,
      gap_analysis = TRUE
    )
    
    results$corporate_personality <- list(status = "success", config = config3)
  }, error = function(e) {
    results$corporate_personality <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Simulate Research Studies with Extreme Parameters
#' 
#' Tests edge cases and extreme configurations
#' 
#' @return List of simulation results
#' @export
simulate_extreme_studies <- function() {
  results <- list()
  
  # Scenario 1: Massive item bank
  tryCatch({
    config1 <- create_study_config(
      name = "Large Scale International Study",
      model = "2PL",
      max_items = 500,  # Very long assessment
      min_items = 100,
      min_SEM = 0.1,  # Very strict criterion
      demographics = paste0("Var_", 1:50),  # 50 demographic variables
      language = "multi",  # Multiple languages
      countries = 50,  # 50 countries
      expected_n = 100000  # 100k participants
    )
    
    # Huge item bank
    item_bank1 <- data.frame(
      item_id = paste0("ITEM_", 1:10000),  # 10,000 items
      content = rep("Item content", 10000),
      difficulty = rnorm(10000, 0, 1.5),
      discrimination = runif(10000, 0.3, 3.0),
      language = rep(c("en", "es", "fr", "de", "zh"), 2000),
      translation_verified = sample(c(TRUE, FALSE), 10000, replace = TRUE)
    )
    
    results$extreme_massive <- list(status = "success", config = config1)
  }, error = function(e) {
    results$extreme_massive <- list(status = "error", message = e$message)
  })
  
  # Scenario 2: Minimal configuration
  tryCatch({
    config2 <- create_study_config(
      name = "A",  # Minimal name
      model = "1PL",
      max_items = 1,  # Single item
      min_items = 1,
      min_SEM = 999  # No adaptive stopping
    )
    
    # Single item bank
    item_bank2 <- data.frame(
      item_id = "Q1",
      content = "?",  # Minimal content
      difficulty = 0,
      discrimination = 1
    )
    
    results$extreme_minimal <- list(status = "success", config = config2)
  }, error = function(e) {
    results$extreme_minimal <- list(status = "error", message = e$message)
  })
  
  # Scenario 3: Unusual characters and encoding
  tryCatch({
    config3 <- create_study_config(
      name = "测试 τεστ тест ทดสอบ",  # Unicode characters
      model = "GRM",
      max_items = 30,
      min_items = 15,
      min_SEM = 0.3,
      demographics = c("名前", "Âge", "Город"),  # Non-ASCII demographics
      special_characters = TRUE
    )
    
    # Items with special characters
    item_bank3 <- data.frame(
      item_id = paste0("题目_", 1:50),
      content = c(
        rep("¿Cómo está?", 10),
        rep("Qu'est-ce que c'est?", 10),
        rep("Was ist das?", 10),
        rep("これは何ですか？", 10),
        rep("Что это?", 10)
      ),
      difficulty = rnorm(50, 0, 1),
      discrimination = runif(50, 0.8, 2.0)
    )
    
    results$extreme_unicode <- list(status = "success", config = config3)
  }, error = function(e) {
    results$extreme_unicode <- list(status = "error", message = e$message)
  })
  
  # Scenario 4: Rapid fire assessment
  tryCatch({
    config4 <- create_study_config(
      name = "Speed Test",
      model = "1PL",
      max_items = 1000,  # Many items
      min_items = 500,
      min_SEM = 0.5,
      time_per_item = 2,  # 2 seconds per item
      no_review_allowed = TRUE,
      auto_advance = TRUE,
      rapid_mode = TRUE
    )
    
    results$extreme_speed <- list(status = "success", config = config4)
  }, error = function(e) {
    results$extreme_speed <- list(status = "error", message = e$message)
  })
  
  # Scenario 5: Complex branching logic
  tryCatch({
    config5 <- create_study_config(
      name = "Complex Adaptive Design",
      model = "3PL",
      max_items = 100,
      min_items = 20,
      min_SEM = 0.2,
      branching_rules = list(
        rule1 = list(condition = "theta > 2", action = "skip_to_end"),
        rule2 = list(condition = "theta < -2", action = "add_easy_items"),
        rule3 = list(condition = "se > 0.5", action = "continue"),
        rule4 = list(condition = "items_answered > 50", action = "check_fatigue"),
        rule5 = list(condition = "time_elapsed > 3600", action = "save_and_exit")
      ),
      multi_stage = TRUE,
      stages = 5,
      routing_rules = "complex"
    )
    
    results$extreme_branching <- list(status = "success", config = config5)
  }, error = function(e) {
    results$extreme_branching <- list(status = "error", message = e$message)
  })
  
  return(results)
}

#' Run All Study Simulations
#' 
#' Executes all simulation scenarios and identifies errors
#' 
#' @return Comprehensive results with error analysis
#' @export
run_all_simulations <- function() {
  all_results <- list()
  errors_found <- list()
  
  # Run educational simulations
  message("Running educational study simulations...")
  edu_results <- simulate_educational_studies()
  all_results$educational <- edu_results
  
  # Run clinical simulations
  message("Running clinical study simulations...")
  clinical_results <- simulate_clinical_studies()
  all_results$clinical <- clinical_results
  
  # Run corporate simulations
  message("Running corporate study simulations...")
  corporate_results <- simulate_corporate_studies()
  all_results$corporate <- corporate_results
  
  # Run extreme simulations
  message("Running extreme parameter simulations...")
  extreme_results <- simulate_extreme_studies()
  all_results$extreme <- extreme_results
  
  # Analyze errors
  for (category in names(all_results)) {
    for (scenario in names(all_results[[category]])) {
      if (all_results[[category]][[scenario]]$status == "error") {
        errors_found[[paste(category, scenario, sep = "_")]] <- 
          all_results[[category]][[scenario]]$message
      }
    }
  }
  
  # Summary
  total_scenarios <- sum(sapply(all_results, length))
  total_errors <- length(errors_found)
  success_rate <- (total_scenarios - total_errors) / total_scenarios * 100
  
  return(list(
    results = all_results,
    errors = errors_found,
    summary = list(
      total_scenarios = total_scenarios,
      total_errors = total_errors,
      success_rate = success_rate,
      categories_tested = names(all_results)
    )
  ))
}