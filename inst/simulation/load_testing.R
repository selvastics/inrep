# File: load_testing.R
# Load Testing Framework for inrep Package

#' Load Testing Framework for inrep Package
#'
#' This framework tests the inrep package under various load conditions
#' to validate performance and identify bottlenecks.

library(inrep)

#' Load Test Configuration
#'
#' Creates configurations for different load testing scenarios.
#'
#' @param test_type Type of load test ("light", "medium", "heavy", "extreme")
#' @return Load test configuration
#' @export
create_load_test_config <- function(test_type = "medium") {
  switch(test_type,
    "light" = list(
      name = "Light Load Test",
      n_users = 10,
      n_items = 20,
      parallel_workers = 2,
      test_duration = 60,  # seconds
      user_arrival_rate = 0.5  # users per second
    ),
    
    "medium" = list(
      name = "Medium Load Test",
      n_users = 50,
      n_items = 50,
      parallel_workers = 4,
      test_duration = 300,  # 5 minutes
      user_arrival_rate = 2.0
    ),
    
    "heavy" = list(
      name = "Heavy Load Test",
      n_users = 200,
      n_items = 100,
      parallel_workers = 8,
      test_duration = 600,  # 10 minutes
      user_arrival_rate = 5.0
    ),
    
    "extreme" = list(
      name = "Extreme Load Test",
      n_users = 500,
      n_items = 200,
      parallel_workers = 16,
      test_duration = 1200,  # 20 minutes
      user_arrival_rate = 10.0
    )
  )
}

#' Create Load Test Study Configuration
#'
#' Creates study configuration optimized for load testing.
#'
#' @param load_config Load test configuration
#' @return Study configuration
#' @export
create_load_test_study_config <- function(load_config) {
  create_study_config(
    name = load_config$name,
    model = "2PL",
    estimation_method = "TAM",
    min_items = 5,
    max_items = min(20, load_config$n_items),
    min_SEM = 0.4,
    criteria = "MI",
    
    # Parallel processing settings
    parallel_computation = TRUE,
    parallel_workers = load_config$parallel_workers,
    parallel_batch_size = min(50, load_config$n_users),
    parallel_optimization = TRUE,
    
    # Performance settings
    cache_enabled = TRUE,
    max_session_duration = 30,  # 30 minutes max per session
    
    # Demographics
    demographics = c("Age", "Gender"),
    input_types = list(
      Age = "numeric",
      Gender = "select"
    )
  )
}

#' Simulate User Arrival Pattern
#'
#' Simulates realistic user arrival patterns for load testing.
#'
#' @param load_config Load test configuration
#' @return User arrival times
#' @export
simulate_user_arrivals <- function(load_config) {
  n_users <- load_config$n_users
  arrival_rate <- load_config$user_arrival_rate
  
  # Generate arrival times using Poisson process
  arrival_times <- cumsum(rexp(n_users, arrival_rate))
  
  # Ensure arrivals are within test duration
  arrival_times <- arrival_times[arrival_times <= load_config$test_duration]
  
  return(arrival_times)
}

#' Run Load Test
#'
#' Runs a comprehensive load test.
#'
#' @param load_config Load test configuration
#' @param monitor_performance Logical indicating whether to monitor performance
#' @return Load test results
#' @export
run_load_test <- function(load_config, monitor_performance = TRUE) {
  cat("=== RUNNING LOAD TEST:", load_config$name, "===\n")
  cat("Users:", load_config$n_users, "\n")
  cat("Items:", load_config$n_items, "\n")
  cat("Duration:", load_config$test_duration, "seconds\n")
  cat("Parallel Workers:", load_config$parallel_workers, "\n\n")
  
  # Create study configuration
  config <- create_load_test_study_config(load_config)
  
  # Create item bank
  item_bank <- create_test_item_bank("basic", load_config$n_items)
  
  # Create performance monitor
  if (monitor_performance) {
    monitor <- create_performance_monitor(config)
    monitor <- start_operation_timing(monitor, "load_test", "batch_processing")
  }
  
  # Simulate user arrivals
  arrival_times <- simulate_user_arrivals(load_config)
  n_actual_users <- length(arrival_times)
  
  cat("Simulated", n_actual_users, "user arrivals\n")
  
  # Create user simulator
  simulator <- create_user_simulator(config, item_bank, n_actual_users)
  simulator <- generate_simulated_users(simulator)
  
  # Run simulation with arrival timing
  start_time <- Sys.time()
  results <- list()
  
  cat("Starting user simulation...\n")
  
  # Process users in batches to simulate realistic load
  batch_size <- min(10, n_actual_users)
  n_batches <- ceiling(n_actual_users / batch_size)
  
  for (batch in 1:n_batches) {
    batch_start <- (batch - 1) * batch_size + 1
    batch_end <- min(batch * batch_size, n_actual_users)
    batch_users <- batch_start:batch_end
    
    cat(sprintf("Processing batch %d/%d (users %d-%d)...\n", 
               batch, n_batches, batch_start, batch_end))
    
    # Simulate batch processing
    batch_start_time <- Sys.time()
    
    # Process users in parallel within batch
    batch_results <- future.apply::future_lapply(batch_users, function(user_id) {
      simulate_user_session(simulator, user_id, parallel = FALSE)
    }, future.seed = TRUE)
    
    batch_end_time <- Sys.time()
    batch_duration <- as.numeric(difftime(batch_end_time, batch_start_time, units = "secs"))
    
    cat(sprintf("Batch %d completed in %.2f seconds\n", batch, batch_duration))
    
    # Update simulator with batch results
    for (i in seq_along(batch_results)) {
      user_id <- batch_users[i]
      simulator <- batch_results[[i]]
    }
    
    # Small delay between batches to simulate realistic load
    if (batch < n_batches) {
      Sys.sleep(0.1)
    }
  }
  
  end_time <- Sys.time()
  total_duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # End performance monitoring
  if (monitor_performance) {
    monitor <- end_operation_timing(monitor, "load_test", list(
      n_users = n_actual_users,
      n_items = load_config$n_items,
      total_duration = total_duration
    ))
  }
  
  # Analyze results
  analysis <- analyze_simulation_results(simulator)
  
  # Create load test results
  load_test_results <- list(
    load_config = load_config,
    n_actual_users = n_actual_users,
    total_duration = total_duration,
    users_per_second = n_actual_users / total_duration,
    analysis = analysis,
    performance_metrics = if (monitor_performance) monitor$performance_metrics else NULL,
    simulator = simulator
  )
  
  # Print summary
  print_load_test_summary(load_test_results)
  
  return(load_test_results)
}

#' Print Load Test Summary
#'
#' Prints a summary of load test results.
#'
#' @param results Load test results
#' @export
print_load_test_summary <- function(results) {
  cat("\n=== LOAD TEST SUMMARY ===\n")
  cat(sprintf("Test: %s\n", results$load_config$name))
  cat(sprintf("Users: %d\n", results$n_actual_users))
  cat(sprintf("Duration: %.2f seconds\n", results$total_duration))
  cat(sprintf("Throughput: %.2f users/second\n", results$users_per_second))
  
  if (!is.null(results$analysis)) {
    cat(sprintf("Completion Rate: %.1f%%\n", results$analysis$overall_analysis$completion_rate * 100))
    cat(sprintf("Average Items: %.1f\n", results$analysis$overall_analysis$avg_items))
    cat(sprintf("Average Time: %.1f minutes\n", results$analysis$overall_analysis$avg_time))
  }
  
  if (!is.null(results$performance_metrics)) {
    cat(sprintf("Simulation Time: %.2f seconds\n", results$performance_metrics$simulation_time))
    cat(sprintf("Users/Second: %.2f\n", results$performance_metrics$users_per_second))
  }
}

#' Run Load Test Suite
#'
#' Runs a comprehensive suite of load tests.
#'
#' @param test_types Types of load tests to run
#' @param output_dir Output directory for results
#' @return Load test suite results
#' @export
run_load_test_suite <- function(test_types = c("light", "medium", "heavy"), 
                               output_dir = "./load_test_results") {
  cat("=== INREP LOAD TEST SUITE ===\n")
  cat("Starting load test suite at", format(Sys.time()), "\n\n")
  
  # Create output directory
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  suite_results <- list()
  start_time <- Sys.time()
  
  for (test_type in test_types) {
    cat(sprintf("\n--- Running %s load test ---\n", toupper(test_type)))
    
    # Create load test configuration
    load_config <- create_load_test_config(test_type)
    
    # Run load test
    test_results <- run_load_test(load_config, monitor_performance = TRUE)
    
    # Save individual test results
    test_file <- file.path(output_dir, paste0("load_test_", test_type, ".rds"))
    saveRDS(test_results, test_file)
    
    suite_results[[test_type]] <- test_results
    
    # Brief pause between tests
    if (test_type != test_types[length(test_types)]) {
      cat("Pausing 10 seconds before next test...\n")
      Sys.sleep(10)
    }
  }
  
  end_time <- Sys.time()
  total_time <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Generate suite summary
  suite_summary <- generate_load_test_suite_summary(suite_results, total_time)
  
  # Save suite results
  suite_file <- file.path(output_dir, "load_test_suite_results.rds")
  saveRDS(list(results = suite_results, summary = suite_summary), suite_file)
  
  # Print suite summary
  print_load_test_suite_summary(suite_summary)
  
  cat("\nLoad test suite completed!\n")
  cat("Results saved to:", output_dir, "\n")
  
  return(list(results = suite_results, summary = suite_summary))
}

#' Generate Load Test Suite Summary
#'
#' Generates a summary of load test suite results.
#'
#' @param suite_results Load test suite results
#' @param total_time Total suite time
#' @return Suite summary
#' @noRd
generate_load_test_suite_summary <- function(suite_results, total_time) {
  summary <- list(
    total_tests = length(suite_results),
    total_time = total_time,
    timestamp = Sys.time()
  )
  
  # Calculate performance metrics
  throughputs <- sapply(suite_results, function(x) x$users_per_second)
  completion_rates <- sapply(suite_results, function(x) {
    if (!is.null(x$analysis)) {
      x$analysis$overall_analysis$completion_rate
    } else {
      NA
    }
  })
  
  summary$avg_throughput <- mean(throughputs, na.rm = TRUE)
  summary$max_throughput <- max(throughputs, na.rm = TRUE)
  summary$avg_completion_rate <- mean(completion_rates, na.rm = TRUE)
  summary$min_completion_rate <- min(completion_rates, na.rm = TRUE)
  
  # Performance by test type
  summary$test_performance <- list()
  for (test_type in names(suite_results)) {
    result <- suite_results[[test_type]]
    summary$test_performance[[test_type]] <- list(
      throughput = result$users_per_second,
      completion_rate = if (!is.null(result$analysis)) {
        result$analysis$overall_analysis$completion_rate
      } else NA,
      duration = result$total_duration
    )
  }
  
  return(summary)
}

#' Print Load Test Suite Summary
#'
#' Prints a summary of load test suite results.
#'
#' @param summary Suite summary
#' @export
print_load_test_suite_summary <- function(summary) {
  cat("\n=== LOAD TEST SUITE SUMMARY ===\n")
  cat(sprintf("Total Tests: %d\n", summary$total_tests))
  cat(sprintf("Total Time: %.2f seconds\n", summary$total_time))
  cat(sprintf("Average Throughput: %.2f users/second\n", summary$avg_throughput))
  cat(sprintf("Maximum Throughput: %.2f users/second\n", summary$max_throughput))
  cat(sprintf("Average Completion Rate: %.1f%%\n", summary$avg_completion_rate * 100))
  cat(sprintf("Minimum Completion Rate: %.1f%%\n", summary$min_completion_rate * 100))
  
  cat("\n=== TEST PERFORMANCE BREAKDOWN ===\n")
  for (test_type in names(summary$test_performance)) {
    perf <- summary$test_performance[[test_type]]
    cat(sprintf("%s: %.2f users/sec, %.1f%% completion\n", 
               toupper(test_type), perf$throughput, perf$completion_rate * 100))
  }
}

#' Create Load Test Report
#'
#' Creates a comprehensive load test report.
#'
#' @param suite_results Load test suite results
#' @param output_file Output file path
#' @return Load test report
#' @export
create_load_test_report <- function(suite_results, output_file = NULL) {
  # Generate summary
  summary <- generate_load_test_suite_summary(suite_results, NA)
  
  # Create report content
  report <- list(
    timestamp = Sys.time(),
    package_version = if (requireNamespace("inrep", quietly = TRUE)) {
      utils::packageVersion("inrep")
    } else "unknown",
    system_info = list(
      r_version = R.version.string,
      platform = R.version$platform,
      cores = if (requireNamespace("parallel", quietly = TRUE)) {
        parallel::detectCores()
      } else "unknown"
    ),
    summary = summary,
    detailed_results = suite_results
  )
  
  # Write to file if specified
  if (!is.null(output_file)) {
    if (requireNamespace("jsonlite", quietly = TRUE)) {
      jsonlite::write_json(report, output_file, pretty = TRUE)
    } else {
      saveRDS(report, output_file)
    }
  }
  
  return(report)
}