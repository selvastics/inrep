# Parallel Processing Example for inrep Package
# This example demonstrates the enhanced parallel processing capabilities

library(inrep)

# Create a comprehensive study configuration with parallel processing enabled
config <- create_study_config(
  name = "Parallel Processing Demo Study",
  model = "2PL",
  estimation_method = "TAM",
  min_items = 10,
  max_items = 25,
  min_SEM = 0.3,
  criteria = "MI",
  
  # Enable parallel processing
  parallel_computation = TRUE,
  parallel_workers = NULL,  # Auto-detect
  parallel_batch_size = 50,
  parallel_optimization = TRUE,
  
  # Enable caching for better performance
  cache_enabled = TRUE,
  
  # Demographics
  demographics = c("Age", "Gender", "Education"),
  input_types = list(
    Age = "numeric",
    Gender = "select",
    Education = "select"
  ),
  
  # Performance monitoring
  theme = "Professional",
  language = "en",
  session_save = TRUE
)

# Create a large item bank for demonstration
set.seed(123)
n_items <- 100
item_bank <- data.frame(
  Question = paste("Item", 1:n_items),
  a = runif(n_items, 0.5, 2.0),  # Discrimination parameters
  b = runif(n_items, -2, 2),     # Difficulty parameters
  Option1 = rep("Strongly Disagree", n_items),
  Option2 = rep("Disagree", n_items),
  Option3 = rep("Neutral", n_items),
  Option4 = rep("Agree", n_items),
  Option5 = rep("Strongly Agree", n_items),
  stringsAsFactors = FALSE
)

# Create multiple participants for batch processing
n_participants <- 50
participants <- lapply(1:n_participants, function(i) {
  # Generate realistic response patterns
  true_theta <- rnorm(1, 0, 1)
  responses <- rbinom(n_items, 1, plogis(true_theta - item_bank$b))
  
  list(
    id = paste0("P", sprintf("%03d", i)),
    responses = responses,
    administered = 1:n_items,
    demographics = list(
      Age = sample(18:65, 1),
      Gender = sample(c("Male", "Female", "Other"), 1),
      Education = sample(c("High School", "Bachelor", "Master", "PhD"), 1)
    ),
    response_time = runif(1, 30, 120)  # Response time in seconds
  )
})

cat("=== INREP PARALLEL PROCESSING DEMONSTRATION ===\n\n")

# 1. Performance Monitoring Setup
cat("1. Setting up performance monitoring...\n")
monitor <- create_performance_monitor(config)

# 2. Batch Processing with Parallel Computation
cat("2. Processing", n_participants, "participants in parallel...\n")
start_operation_timing(monitor, "batch_processing", "batch_processing")

start_time <- Sys.time()
results <- process_participants_batch(participants, item_bank, config, parallel = TRUE)
end_time <- Sys.time()

end_operation_timing(monitor, "batch_processing", list(
  n_participants = n_participants,
  n_items = n_items,
  duration = as.numeric(difftime(end_time, start_time, units = "secs"))
))

# Record parallel processing statistics
record_parallel_stats(monitor, "batch_processing", 
                     n_workers = config$parallel_workers %||% 4,
                     n_items = n_items * n_participants,
                     parallel_method = "future")

cat("   Completed in", round(as.numeric(difftime(end_time, start_time, units = "secs")), 2), "seconds\n")

# 3. Individual Item Selection Performance
cat("3. Testing parallel item selection...\n")
start_operation_timing(monitor, "item_selection", "item_selection")

# Create test states for item selection
test_states <- lapply(1:10, function(i) {
  list(
    administered = sample(1:n_items, 5),
    responses = sample(0:1, 5, replace = TRUE),
    current_ability = rnorm(1, 0, 1),
    ability_se = runif(1, 0.1, 0.5),
    item_info_cache = list()
  )
})

selection_start <- Sys.time()
selected_items <- batch_item_selection(test_states, item_bank, config, parallel = TRUE)
selection_end <- Sys.time()

end_operation_timing(monitor, "item_selection", list(
  n_selections = length(selected_items),
  duration = as.numeric(difftime(selection_end, selection_start, units = "secs"))
))

cat("   Selected", length(selected_items), "items in", 
    round(as.numeric(difftime(selection_end, selection_start, units = "secs")), 3), "seconds\n")

# 4. Parallel Data Export
cat("4. Testing parallel data export...\n")
start_operation_timing(monitor, "data_export", "batch_processing")

export_start <- Sys.time()
exported_files <- batch_data_export(results, config, 
                                   formats = c("csv", "json", "rds"),
                                   output_dir = tempdir(),
                                   parallel = TRUE)
export_end <- Sys.time()

end_operation_timing(monitor, "data_export", list(
  n_files = length(exported_files),
  duration = as.numeric(difftime(export_end, export_start, units = "secs"))
))

cat("   Exported", length(exported_files), "files in", 
    round(as.numeric(difftime(export_end, export_start, units = "secs")), 3), "seconds\n")

# 5. Performance Analysis
cat("5. Analyzing performance...\n")
summary <- get_performance_summary(monitor)
print_performance_summary(monitor)

# 6. Configuration Optimization
cat("\n6. Optimizing configuration...\n")
optimization_suggestions <- optimize_configuration(monitor, n_items, n_participants)

if (length(optimization_suggestions) > 0) {
  cat("   Optimization suggestions:\n")
  for (suggestion_name in names(optimization_suggestions)) {
    suggestion <- optimization_suggestions[[suggestion_name]]
    cat("   -", suggestion$issue, "\n")
    cat("     Recommendation:", suggestion$recommendation, "\n")
  }
} else {
  cat("   No optimization suggestions - configuration is well-tuned!\n")
}

# 7. Benchmark Different Configurations
cat("\n7. Benchmarking different configurations...\n")

# Test different parallel settings
test_configs <- list(
  "sequential" = modifyList(config, list(parallel_computation = FALSE)),
  "parallel_2" = modifyList(config, list(parallel_workers = 2)),
  "parallel_4" = modifyList(config, list(parallel_workers = 4)),
  "parallel_8" = modifyList(config, list(parallel_workers = 8))
)

# Use a subset for benchmarking
benchmark_participants <- participants[1:20]
benchmark_results <- benchmark_configurations(benchmark_participants, item_bank, config, test_configs)

cat("   Benchmark results:\n")
for (config_name in names(benchmark_results)) {
  result <- benchmark_results[[config_name]]
  if (result$success) {
    cat(sprintf("   %s: %.2f participants/second\n", 
               config_name, result$participants_per_second))
  } else {
    cat(sprintf("   %s: Failed - %s\n", config_name, result$error))
  }
}

# 8. Memory Usage Monitoring
cat("\n8. Monitoring memory usage...\n")
memory_info <- monitor_memory_usage("parallel_demo")
if (memory_info$available) {
  cat(sprintf("   Memory used: %.1f MB\n", memory_info$memory_used_mb))
  cat(sprintf("   Memory after GC: %.1f MB\n", memory_info$memory_after_gc_mb))
}

# 9. Generate Performance Report
cat("\n9. Generating performance report...\n")
report_file <- file.path(tempdir(), "inrep_performance_report.json")
report <- generate_performance_report(monitor, report_file)
cat("   Report saved to:", report_file, "\n")

# 10. Results Summary
cat("\n=== RESULTS SUMMARY ===\n")
cat("Participants processed:", length(results), "\n")
cat("Successful results:", sum(sapply(results, function(x) !is.null(x$theta))), "\n")
cat("Average theta:", round(mean(sapply(results, function(x) x$theta %||% NA), na.rm = TRUE), 3), "\n")
cat("Average SE:", round(mean(sapply(results, function(x) x$se %||% NA), na.rm = TRUE), 3), "\n")

# Show some individual results
cat("\nSample results:\n")
for (i in 1:min(5, length(results))) {
  result <- results[[i]]
  cat(sprintf("Participant %s: theta=%.3f, se=%.3f, items=%d\n",
             result$participant_id, result$theta, result$se, result$n_items))
}

cat("\n=== PARALLEL PROCESSING DEMONSTRATION COMPLETE ===\n")
cat("The inrep package now supports efficient parallel processing for:\n")
cat("- Item selection with parallel information computation\n")
cat("- Ability estimation with parallel TAM processing\n")
cat("- Batch processing of multiple participants\n")
cat("- Parallel data export in multiple formats\n")
cat("- Performance monitoring and optimization\n")
cat("- Memory usage tracking and optimization\n")
cat("\nThis significantly improves performance for large-scale studies!\n")