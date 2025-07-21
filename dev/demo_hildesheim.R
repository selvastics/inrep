# Quick Hildesheim Theme Demo Launcher
library(inrep)

cat("🎓 University of Hildesheim Theme Demo\n")
cat("=====================================\n")

# Create demo item bank (using correct inrep format)
demo_items <- data.frame(
  Question = c(
    "How confident do you feel about completing academic tasks?",
    "Do you enjoy working in group projects?", 
    "How organized are you with your study materials?",
    "Do you prefer theoretical or practical learning?",
    "How well do you manage your time?"
  ),
  Option1 = c("Strongly Disagree", "Never", "Very Disorganized", "Theoretical", "Very Poorly"),
  Option2 = c("Disagree", "Rarely", "Somewhat Disorganized", "Mixed", "Poorly"),
  Option3 = c("Neutral", "Sometimes", "Average", "Neutral", "Average"),
  Option4 = c("Agree", "Often", "Somewhat Organized", "Mixed", "Well"),
  Option5 = c("Strongly Agree", "Always", "Very Organized", "Practical", "Very Well"),
  Answer = c("Option3", "Option4", "Option4", "Option3", "Option3"),
  ResponseCategories = rep(5, 5),  # 5-point Likert scale
  a = c(1.2, 1.5, 1.1, 1.3, 1.4),
  b1 = c(-2, -1.5, -1.8, -1.2, -1.6),
  b2 = c(-1, -0.5, -0.8, -0.2, -0.6),
  b3 = c(0, 0.5, 0.2, 0.8, 0.4),
  b4 = c(1, 1.5, 1.2, 1.8, 1.6),
  stringsAsFactors = FALSE
)

# Create study configuration
study_config <- create_study_config(
  name = "University of Hildesheim Assessment Demo",
  model = "GRM",  # Graded Response Model for Likert items
  theme = "hildesheim",
  max_items = 5,
  min_items = 3,
  adaptive = TRUE,
  demographics = c("age", "study_program"),
  input_types = list(
    age = "numeric",
    study_program = "select"
  )
)

cat("Demo items created:", nrow(demo_items), "questions\n")
cat("Theme: hildesheim (with enhanced testing environment)\n")
cat("Launching Shiny application...\n")
cat("The app will open in your browser at http://localhost:3838\n")
cat("\n🧪 Testing features available:\n")
cat("- Visual debugging tools\n")
cat("- Interactive control panel\n")
cat("- Responsive testing modes\n")
cat("- Accessibility validation\n")
cat("- Performance monitoring\n")

# Launch the study
tryCatch({
  result <- launch_study(
    config = study_config,
    item_bank = demo_items,
    theme = "hildesheim",
    port = 3838,
    launch.browser = TRUE
  )
}, error = function(e) {
  cat("Error launching study:", e$message, "\n")
  cat("Trying alternative approach...\n")
  
  # Alternative launch
  shiny::runApp(
    appDir = system.file("shiny", package = "inrep"),
    port = 3838,
    launch.browser = TRUE
  )
})
