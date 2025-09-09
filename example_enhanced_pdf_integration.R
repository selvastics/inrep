#!/usr/bin/env Rscript

# Example: Enhanced PDF Integration with HILFO Study
# This shows how to integrate the enhanced PDF reporting into an existing study

library(inrep)

cat("=== Enhanced PDF Integration Example ===\n\n")

# Load the HILFO study data
data(bfi_items)

# Create HILFO study configuration with enhanced PDF
hilfo_config <- create_study_config(
  name = "HILFO Study - Enhanced PDF Demo",
  model = "GRM",
  max_items = 20,
  min_items = 10,
  min_SEM = 0.3,
  language = "en",
  theme = "Professional",
  adaptive = TRUE,
  # Enable enhanced PDF features
  report_formats = c("pdf", "csv", "json"),
  enhanced_pdf = TRUE,
  pdf_include_plots = TRUE,
  pdf_fast_mode = TRUE
)

cat("Created HILFO configuration with enhanced PDF features\n")

# Simulate HILFO assessment data
set.seed(123)
n_items <- 15
hilfo_result <- list(
  responses = sample(1:5, n_items, replace = TRUE),
  administered = sample(1:nrow(bfi_items), n_items),
  response_times = runif(n_items, 1.2, 3.8),
  theta = 0.4,
  se = 0.25,
  theta_history = cumsum(c(0, rnorm(n_items-1, 0, 0.12))),
  se_history = seq(0.5, 0.25, length.out = n_items)
)

# HILFO demographics
hilfo_demographics <- list(
  participant_id = "HILFO_001",
  age = 22,
  gender = "Male",
  study_program = "Computer Science",
  semester = 3,
  programming_experience = "2 years"
)

cat("Simulated HILFO assessment with", n_items, "items\n")

# Initialize enhanced PDF reporting
initialize_pdf_reporting(
  enable_plot_capture = TRUE,
  plot_quality = 2,
  cache_plots = TRUE
)

# Generate HILFO-specific plots
cat("Generating HILFO-specific visualizations...\n")
hilfo_plots <- generate_assessment_plots(
  cat_result = hilfo_result,
  config = hilfo_config,
  item_bank = bfi_items,
  plot_types = c("progress", "theta_history", "item_difficulty", "response_pattern"),
  fast_mode = TRUE
)

# Create HILFO-specific PDF report
cat("Generating HILFO PDF report...\n")
hilfo_pdf <- generate_smart_pdf_report(
  config = hilfo_config,
  cat_result = hilfo_result,
  item_bank = bfi_items,
  demographics = hilfo_demographics,
  output_file = file.path(tempdir(), "hilfo_enhanced_report.pdf"),
  template = "professional",
  include_plots = TRUE,
  plot_quality = 2,
  fast_mode = TRUE
)

if (!is.null(hilfo_pdf) && file.exists(hilfo_pdf)) {
  cat("✓ HILFO PDF report generated successfully!\n")
  cat("  File size:", round(file.size(hilfo_pdf) / 1024, 1), "KB\n")
  cat("  Location:", hilfo_pdf, "\n")
} else {
  cat("✗ HILFO PDF generation failed\n")
}

# Demonstrate integration with launch_study
cat("\n=== Integration with launch_study ===\n")
cat("The enhanced PDF generation is automatically integrated into launch_study()\n")
cat("When save_format = 'pdf', the system will:\n")
cat("1. Check for enhanced PDF reporting functions\n")
cat("2. Initialize plot capture if needed\n")
cat("3. Generate assessment visualizations\n")
cat("4. Create professional PDF with plots\n")
cat("5. Fall back to simple LaTeX if needed\n")

# Show how to use in a real study
cat("\n=== Usage in Real Study ===\n")
cat("To use enhanced PDF in your study:\n")
cat("1. Set save_format = 'pdf' in launch_study()\n")
cat("2. The system automatically uses enhanced PDF if available\n")
cat("3. Plots are automatically captured and included\n")
cat("4. Fast mode is used by default for performance\n")

# Example launch_study call
cat("\nExample launch_study call:\n")
cat("launch_study(\n")
cat("  config = hilfo_config,\n")
cat("  item_bank = bfi_items,\n")
cat("  save_format = 'pdf',  # This triggers enhanced PDF\n")
cat("  # ... other parameters\n")
cat(")\n")

# Show PDF system status
cat("\n=== Current PDF System Status ===\n")
status <- get_pdf_status()
print(status)

cat("\n=== Integration Complete ===\n")
cat("The enhanced PDF reporting is now fully integrated into inrep!\n")
cat("Users get professional PDF reports with plots automatically.\n")