# Check key files for roxygen issues
check_file <- function(file_path) {
  cat("Checking", file_path, "...\n")
  
  # Read the file
  lines <- readLines(file_path, warn = FALSE)
  
  # Look for @export tags
  export_lines <- grep("@export", lines)
  if (length(export_lines) > 0) {
    cat("  Found @export at lines:", export_lines, "\n")
  } else {
    cat("  WARNING: No @export found\n")
  }
  
  # Look for function definitions
  func_lines <- grep("^[a-zA-Z_][a-zA-Z0-9_]* <- function", lines)
  if (length(func_lines) > 0) {
    func_names <- sub(" <- function.*", "", lines[func_lines])
    cat("  Found functions:", paste(func_names, collapse = ", "), "\n")
  }
  
  cat("\n")
}

check_file("R/create_study_config.R")
check_file("R/launch_study.R")
