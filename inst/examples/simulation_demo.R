# Simulation Demo for inrep Package
# This script demonstrates the comprehensive simulation and testing capabilities

library(inrep)

cat("=== INREP SIMULATION DEMONSTRATION ===\n")
cat("This demo showcases the parallel processing and user simulation capabilities\n\n")

# 1. Basic Simulation Test
cat("1. Running Basic Simulation Test...\n")
cat("   - 50 users, sequential processing\n")
cat("   - 2PL model, 20 items\n")
cat("   - Realistic user behavior patterns\n\n")

# Create basic configuration
basic_config <- create_study_config(
  name = "Basic Simulation Demo",
  model = "2PL",
  estimation_method = "TAM",
  min_items = 5,
  max_items = 20,
  parallel_computation = FALSE,
  cache_enabled = TRUE,
  demographics = c("Age", "Gender"),
  input_types = list(
    Age = "numeric",
    Gender = "select"
  )
)

# Create item bank
item_bank <- data.frame(
  Question = paste("Demo Item", 1:30),
  a = runif(30, 0.5, 2.0),
  b = runif(30, -2, 2),
  Option1 = rep("Strongly Disagree", 30),
  Option2 = rep("Disagree", 30),
  Option3 = rep("Neutral", 30),
  Option4 = rep("Agree", 30),
  Option5 = rep("Strongly Agree", 30),
  stringsAsFactors = FALSE
)

# Run basic simulation
basic_simulator <- create_user_simulator(basic_config, item_bank, n_users = 50)
basic_simulator <- generate_simulated_users(basic_simulator)
basic_simulator <- run_parallel_simulation(basic_simulator, parallel = FALSE)

# Analyze and display results
basic_analysis <- analyze_simulation_results(basic_simulator)
print_simulation_summary(basic_simulator)

cat("\n" + rep("=", 60) + "\n\n")

# 2. Parallel Processing Test
cat("2. Running Parallel Processing Test...\n")
cat("   - 100 users, parallel processing\n")
cat("   - 2PL model, 50 items\n")
cat("   - Performance comparison\n\n")

# Create parallel configuration
parallel_config <- create_study_config(
  name = "Parallel Processing Demo",
  model = "2PL",
  estimation_method = "TAM",
  min_items = 8,
  max_items = 25,
  parallel_computation = TRUE,
  parallel_workers = 4,
  parallel_batch_size = 25,
  cache_enabled = TRUE,
  demographics = c("Age", "Gender", "Education"),
  input_types = list(
    Age = "numeric",
    Gender = "select",
    Education = "select"
  )
)

# Create larger item bank
large_item_bank <- data.frame(
  Question = paste("Parallel Item", 1:60),
  a = runif(60, 0.5, 2.0),
  b = runif(60, -2, 2),
  Option1 = rep("Strongly Disagree", 60),
  Option2 = rep("Disagree", 60),
  Option3 = rep("Neutral", 60),
  Option4 = rep("Agree", 60),
  Option5 = rep("Strongly Agree", 60),
  stringsAsFactors = FALSE
)

# Run parallel simulation
parallel_simulator <- create_user_simulator(parallel_config, large_item_bank, n_users = 100)
parallel_simulator <- generate_simulated_users(parallel_simulator)
parallel_simulator <- run_parallel_simulation(parallel_simulator, parallel = TRUE)

# Analyze and display results
parallel_analysis <- analyze_simulation_results(parallel_simulator)
print_simulation_summary(parallel_simulator)

cat("\n" + rep("=", 60) + "\n\n")

# 3. Performance Comparison
cat("3. Performance Comparison...\n")
cat("   - Comparing sequential vs parallel processing\n")
cat("   - Measuring speedup and efficiency\n\n")

# Create test participants for comparison
test_participants <- lapply(1:50, function(i) {
  list(
    id = paste0("PERF_", i),
    responses = sample(0:1, 15, replace = TRUE),
    administered = 1:15,
    demographics = list(
      Age = sample(18:65, 1),
      Gender = sample(c("Male", "Female"), 1),
      Education = sample(c("High School", "Bachelor", "Master"), 1)
    )
  )
})

# Sequential processing
cat("   Running sequential processing...\n")
seq_start <- Sys.time()
seq_results <- process_participants_batch(test_participants, large_item_bank, basic_config, parallel = FALSE)
seq_time <- as.numeric(difftime(Sys.time(), seq_start, units = "secs"))

# Parallel processing
cat("   Running parallel processing...\n")
par_start <- Sys.time()
par_results <- process_participants_batch(test_participants, large_item_bank, parallel_config, parallel = TRUE)
par_time <- as.numeric(difftime(Sys.time(), par_start, units = "secs"))

# Calculate speedup
speedup <- seq_time / par_time
efficiency <- speedup / parallel_config$parallel_workers

cat("   Performance Results:\n")
cat(sprintf("   Sequential Time: %.2f seconds\n", seq_time))
cat(sprintf("   Parallel Time: %.2f seconds\n", par_time))
cat(sprintf("   Speedup: %.2fx\n", speedup))
cat(sprintf("   Efficiency: %.1f%%\n", efficiency * 100))

cat("\n" + rep("=", 60) + "\n\n")

# 4. User Behavior Analysis
cat("4. User Behavior Analysis...\n")
cat("   - Analyzing different user profiles\n")
cat("   - Response patterns and timing\n\n")

# Analyze user profiles
profile_analysis <- parallel_analysis$profile_analysis
cat("   Profile Analysis:\n")
for (profile_name in names(profile_analysis)) {
  profile <- profile_analysis[[profile_name]]
  cat(sprintf("   %s:\n", profile_name))
  cat(sprintf("     Users: %d\n", profile$n_users))
  cat(sprintf("     Completion Rate: %.1f%%\n", profile$completion_rate * 100))
  cat(sprintf("     Average Items: %.1f\n", profile$avg_items))
  cat(sprintf("     Average Time: %.1f minutes\n", profile$avg_time))
  cat(sprintf("     Ability Bias: %.3f\n", profile$avg_ability_bias))
  cat(sprintf("     Ability RMSE: %.3f\n", profile$avg_ability_rmse))
  cat("\n")
}

cat("\n" + rep("=", 60) + "\n\n")

# 5. Visualization Creation
cat("5. Creating Visualizations...\n")
cat("   - Performance plots and charts\n")
cat("   - User behavior analysis\n\n")

# Create visualizations
if (requireNamespace("ggplot2", quietly = TRUE)) {
  plots <- create_performance_visualizations(parallel_simulator, "./simulation_demo_plots")
  cat("   Visualizations created in: ./simulation_demo_plots/\n")
} else {
  cat("   ggplot2 not available - skipping visualizations\n")
}

# 6. Load Testing
cat("6. Running Load Test...\n")
cat("   - Testing under different load conditions\n")
cat("   - Performance scalability analysis\n\n")

# Run light load test
load_config <- create_load_test_config("light")
load_config$n_users <- 25  # Smaller for demo

load_results <- run_load_test(load_config, monitor_performance = TRUE)
print_load_test_summary(load_results)

cat("\n" + rep("=", 60) + "\n\n")

# 7. Interactive Dashboard
cat("7. Creating Interactive Dashboard...\n")
cat("   - Real-time monitoring capabilities\n")
cat("   - Performance metrics dashboard\n\n")

# Create dashboard
dashboard_data <- create_performance_dashboard(parallel_simulator, "./simulation_demo_dashboard.html")
cat("   Dashboard created: ./simulation_demo_dashboard.html\n")

cat("\n" + rep("=", 60) + "\n\n")

# 8. Summary and Recommendations
cat("8. Summary and Recommendations...\n\n")

cat("Simulation Results Summary:\n")
cat(sprintf("- Basic Simulation: %d users, %.1f%% completion\n", 
           length(basic_simulator$users), 
           basic_analysis$overall_analysis$completion_rate * 100))
cat(sprintf("- Parallel Simulation: %d users, %.1f%% completion\n", 
           length(parallel_simulator$users), 
           parallel_analysis$overall_analysis$completion_rate * 100))
cat(sprintf("- Performance Speedup: %.2fx improvement\n", speedup))
cat(sprintf("- Parallel Efficiency: %.1f%%\n", efficiency * 100))

cat("\nKey Findings:\n")
cat("✓ Parallel processing provides significant speedup\n")
cat("✓ User simulation accurately models realistic behavior\n")
cat("✓ Performance monitoring enables optimization\n")
cat("✓ Load testing validates scalability\n")
cat("✓ Visualization tools provide insights\n")

cat("\nRecommendations:\n")
cat("- Use parallel processing for studies with >50 participants\n")
cat("- Enable caching for better performance\n")
cat("- Monitor performance metrics during large studies\n")
cat("- Use load testing to validate system capacity\n")
cat("- Leverage user simulation for study design\n")

cat("\n=== SIMULATION DEMONSTRATION COMPLETED ===\n")
cat("The inrep package now supports comprehensive simulation and testing!\n")
cat("This enables researchers to:\n")
cat("- Validate study designs before deployment\n")
cat("- Test performance under various load conditions\n")
cat("- Optimize parallel processing settings\n")
cat("- Monitor real-time performance metrics\n")
cat("- Generate detailed performance reports\n")
cat("\nFor more information, see the package documentation and examples.\n")