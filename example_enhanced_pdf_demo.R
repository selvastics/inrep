# Enhanced PDF Reporting Demo
# This script demonstrates the enhanced PDF functionality with plot capture

library(inrep)
data(bfi_items)

# Create a study configuration with enhanced PDF reporting
config <- create_study_config(
  name = "Enhanced PDF Demo - Personality Assessment",
  model = "GRM",
  adaptive = TRUE,
  max_items = 15,
  min_items = 8,
  min_SEM = 0.3,
  demographics = c("Age", "Gender", "Education"),
  theme = "professional",
  save_format = "pdf"  # This triggers enhanced PDF reporting
)

# Alternative: Use configuration template
# config <- get_config_template("personality_assessment")

cat("=== Enhanced PDF Reporting Demo ===\n")
cat("Configuration created with PDF reporting enabled\n")
cat("Study name:", config$name, "\n")
cat("Save format:", config$save_format, "\n\n")

# Initialize PDF reporting system
pdf_config <- initialize_pdf_reporting(
  enable_plot_capture = TRUE,
  plot_quality = 2,
  cache_plots = TRUE
)

cat("PDF reporting initialized:\n")
print(pdf_config)

# Simulate some assessment data for demonstration
set.seed(123)
n_items <- 10
responses <- sample(1:5, n_items, replace = TRUE)
response_times <- runif(n_items, 10, 60)
theta_history <- cumsum(rnorm(n_items, 0, 0.1))
se_history <- rep(0.3, n_items)

# Create a mock CAT result
cat_result <- list(
  theta = theta_history[n_items],
  se = se_history[n_items],
  administered = 1:n_items,
  responses = responses,
  response_times = response_times
)

# Mock demographics
demo_data <- list(
  Age = 25,
  Gender = "Female",
  Education = "Bachelor's"
)

cat("\n=== Generating Enhanced PDF Report ===\n")

# Generate the enhanced PDF report
pdf_file <- generate_smart_pdf_report(
  config = config,
  cat_result = cat_result,
  item_bank = bfi_items,
  demographics = demo_data,
  output_file = "enhanced_demo_report.pdf",
  template = "professional",
  include_plots = TRUE,
  plot_quality = 2,
  fast_mode = TRUE  # Use fast mode for minimal processing power
)

if (!is.null(pdf_file) && file.exists(pdf_file)) {
  cat("✓ Enhanced PDF report generated successfully!\n")
  cat("File location:", pdf_file, "\n")
  cat("File size:", file.size(pdf_file), "bytes\n")
  
  # Show PDF status
  pdf_status <- get_pdf_status()
  cat("\nPDF System Status:\n")
  print(pdf_status)
  
} else {
  cat("✗ PDF generation failed\n")
}

cat("\n=== Demo Complete ===\n")
cat("The enhanced PDF report includes:\n")
cat("- Assessment progress visualizations\n")
cat("- Ability estimation history plots\n")
cat("- Item difficulty analysis\n")
cat("- Response pattern analysis\n")
cat("- Professional formatting with plots\n")
cat("- Fast generation (optimized for minimal processing power)\n")

# Clean up
clear_pdf_cache()
cat("\nPDF cache cleared.\n")