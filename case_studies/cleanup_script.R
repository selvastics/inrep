# Script to clean up "enhanced" and "learned from Hildesheim" references
# =====================================================================

library(stringr)

# Files to clean up
files_to_clean <- c(
  "big_five_personality/study_setup.R",
  "programming_anxiety_assessment/study_setup.R", 
  "depression_screening/study_setup.R",
  "rater_participant_design/study_setup.R"
)

for (file in files_to_clean) {
  
  if (file.exists(file)) {
    
    cat("Cleaning:", file, "\n")
    
    # Read the file
    content <- readLines(file, warn = FALSE)
    
    # Clean up the content
    content <- str_replace_all(content, "ENHANCED DEMOGRAPHIC CONFIGURATIONS \\(LEARNED FROM HILDESHEIM\\)", "COMPREHENSIVE DEMOGRAPHIC CONFIGURATIONS")
    content <- str_replace_all(content, "ENHANCED INSTRUCTION OVERRIDE FUNCTION \\(LEARNED FROM HILDESHEIM\\)", "PROGRAMMING ANXIETY INSTRUCTION OVERRIDE FUNCTION")
    content <- str_replace_all(content, "COMPREHENSIVE .* REPORT FUNCTION \\(LEARNED FROM HILDESHEIM\\)", "COMPREHENSIVE REPORT FUNCTION")
    content <- str_replace_all(content, "STUDY CONFIGURATION WITH ENHANCED FEATURES \\(LEARNED FROM HILDESHEIM\\)", "STUDY CONFIGURATION WITH ADVANCED FEATURES")
    content <- str_replace_all(content, "AFTER CREATING STUDY CONFIG, DIRECTLY OVERRIDE THE DEMOGRAPHICS \\(LEARNED FROM HILDESHEIM\\)", "AFTER CREATING STUDY CONFIG, DIRECTLY OVERRIDE THE DEMOGRAPHICS")
    content <- str_replace_all(content, "ENHANCED SESSION AND PERFORMANCE SETTINGS", "ADVANCED SESSION AND PERFORMANCE SETTINGS")
    content <- str_replace_all(content, "ENHANCED CONTENT", "COMPREHENSIVE STUDY CONTENT")
    content <- str_replace_all(content, "VALIDATION OUTPUT \\(LEARNED FROM HILDESHEIM\\)", "VALIDATION OUTPUT")
    content <- str_replace_all(content, "Enhanced .*? Assessment", "Advanced Assessment")
    content <- str_replace_all(content, "Enhanced Inter-Rater", "Advanced Inter-Rater")
    content <- str_replace_all(content, "Enhanced Depression", "Advanced Depression")
    content <- str_replace_all(content, "# Enhanced", "# Comprehensive")
    content <- str_replace_all(content, "enhanced", "comprehensive")
    content <- str_replace_all(content, "Enhanced", "Comprehensive")
    content <- str_replace_all(content, "ENHANCED", "COMPREHENSIVE")
    content <- str_replace_all(content, "from Hildesheim learning", "")
    content <- str_replace_all(content, "learned from Hildesheim", "")
    content <- str_replace_all(content, "Hildesheim learnings", "")
    content <- str_replace_all(content, "\\(from Hildesheim learning\\)", "")
    content <- str_replace_all(content, "\\(learned from Hildesheim\\)", "")
    content <- str_replace_all(content, " \\(LEARNED FROM HILDESHEIM\\)", "")
    content <- str_replace_all(content, "Comprehensive comprehensive", "Comprehensive")
    content <- str_replace_all(content, "comprehensive comprehensive", "comprehensive")
    
    # Write back to file
    writeLines(content, file)
    
    cat("✓ Cleaned:", file, "\n")
    
  } else {
    cat("✗ File not found:", file, "\n")
  }
}

cat("\n=== CLEANUP COMPLETE ===\n")
cat("All case studies have been cleaned of 'enhanced' and 'Hildesheim' references.\n")
cat("Each study now stands as unique and descriptive without awkward references.\n")
