#!/usr/bin/env Rscript

# Demonstration of Enhanced PDF Reporting for inrep
# This script shows how the new smart PDF generation works with automatic plot capture

library(inrep)

cat("=== Enhanced PDF Reporting Demonstration ===\n\n")

# Load sample data
data(bfi_items)
cat("Loaded BFI items dataset with", nrow(bfi_items), "items\n")

# Create a realistic study configuration
config <- create_study_config(
  name = "Big Five Personality Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 10,
  min_SEM = 0.3,
  language = "en",
  theme = "Professional",
  adaptive = TRUE
)

cat("Created study configuration:", config$name, "\n")

# Simulate a realistic adaptive assessment
set.seed(42)
n_items <- 12
cat_result <- list(
  responses = sample(1:5, n_items, replace = TRUE),
  administered = sample(1:nrow(bfi_items), n_items),
  response_times = runif(n_items, 1.5, 4.2),
  theta = 0.3,
  se = 0.28,
  theta_history = cumsum(c(0, rnorm(n_items-1, 0, 0.15))),
  se_history = seq(0.6, 0.28, length.out = n_items)
)

# Demographics
demographics <- list(
  participant_id = "DEMO_001",
  age = 28,
  gender = "Female",
  education = "Master's Degree",
  occupation = "Research Assistant"
)

cat("Simulated assessment with", n_items, "items\n")
cat("Final theta estimate:", round(cat_result$theta, 3), "(SE =", round(cat_result$se, 3), ")\n\n")

# Initialize PDF reporting system
cat("Initializing enhanced PDF reporting system...\n")
pdf_config <- initialize_pdf_reporting(
  enable_plot_capture = TRUE,
  plot_quality = 2,
  cache_plots = TRUE
)

cat("PDF system initialized with plot capture enabled\n\n")

# Demonstrate plot generation
cat("Generating assessment visualizations...\n")
plot_data <- generate_assessment_plots(
  cat_result = cat_result,
  config = config,
  item_bank = bfi_items,
  plot_types = c("progress", "theta_history", "item_difficulty", "response_pattern"),
  fast_mode = TRUE
)

cat("Generated", length(plot_data$plots), "plots\n")
cat("Captured", length(plot_data$images), "images\n\n")

# Generate fast PDF report
cat("Generating fast PDF report...\n")
start_time <- Sys.time()

fast_pdf <- generate_smart_pdf_report(
  config = config,
  cat_result = cat_result,
  item_bank = bfi_items,
  demographics = demographics,
  output_file = file.path(tempdir(), "demo_fast_report.pdf"),
  template = "professional",
  include_plots = TRUE,
  plot_quality = 2,
  fast_mode = TRUE
)

fast_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

if (!is.null(fast_pdf) && file.exists(fast_pdf)) {
  cat("✓ Fast PDF generated in", round(fast_time, 2), "seconds\n")
  cat("  File size:", round(file.size(fast_pdf) / 1024, 1), "KB\n")
  cat("  Location:", fast_pdf, "\n")
} else {
  cat("✗ Fast PDF generation failed\n")
}

# Generate full PDF report
cat("\nGenerating full PDF report...\n")
start_time <- Sys.time()

full_pdf <- generate_smart_pdf_report(
  config = config,
  cat_result = cat_result,
  item_bank = bfi_items,
  demographics = demographics,
  output_file = file.path(tempdir(), "demo_full_report.pdf"),
  template = "professional",
  include_plots = TRUE,
  plot_quality = 3,
  fast_mode = FALSE
)

full_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

if (!is.null(full_pdf) && file.exists(full_pdf)) {
  cat("✓ Full PDF generated in", round(full_time, 2), "seconds\n")
  cat("  File size:", round(file.size(full_pdf) / 1024, 1), "KB\n")
  cat("  Location:", full_pdf, "\n")
} else {
  cat("✗ Full PDF generation failed\n")
}

# Performance comparison
if (!is.null(fast_pdf) && !is.null(full_pdf)) {
  cat("\n=== Performance Comparison ===\n")
  cat("Fast mode:", round(fast_time, 2), "seconds,", round(file.size(fast_pdf) / 1024, 1), "KB\n")
  cat("Full mode:", round(full_time, 2), "seconds,", round(file.size(full_pdf) / 1024, 1), "KB\n")
  cat("Speed improvement:", round((full_time - fast_time) / full_time * 100, 1), "%\n")
  cat("Size difference:", round((file.size(full_pdf) - file.size(fast_pdf)) / file.size(fast_pdf) * 100, 1), "%\n")
}

# Show PDF system status
cat("\n=== PDF System Status ===\n")
status <- get_pdf_status()
print(status)

# Demonstrate caching
cat("\n=== Caching Demonstration ===\n")
cat("Cached plots:", status$cached_plots, "\n")
cat("Cached templates:", status$cached_templates, "\n")

# Generate another PDF to show caching benefits
cat("\nGenerating second PDF (should be faster due to caching)...\n")
start_time <- Sys.time()

cached_pdf <- generate_smart_pdf_report(
  config = config,
  cat_result = cat_result,
  item_bank = bfi_items,
  demographics = demographics,
  output_file = file.path(tempdir(), "demo_cached_report.pdf"),
  template = "professional",
  include_plots = TRUE,
  plot_quality = 2,
  fast_mode = TRUE
)

cached_time <- as.numeric(difftime(Sys.time(), start_time, units = "secs"))

if (!is.null(cached_pdf) && file.exists(cached_pdf)) {
  cat("✓ Cached PDF generated in", round(cached_time, 2), "seconds\n")
  cat("  Caching speedup:", round((fast_time - cached_time) / fast_time * 100, 1), "%\n")
} else {
  cat("✗ Cached PDF generation failed\n")
}

# Clean up
cat("\n=== Cleanup ===\n")
clear_pdf_cache()
cat("PDF cache cleared\n")

cat("\n=== Demonstration Complete ===\n")
cat("The enhanced PDF reporting system provides:\n")
cat("• Automatic plot capture and integration\n")
cat("• Fast mode for minimal processing power\n")
cat("• Professional PDF templates\n")
cat("• Intelligent caching for performance\n")
cat("• Fallback mechanisms for reliability\n")
cat("• Seamless integration with existing inrep workflows\n")