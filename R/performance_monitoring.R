# File: performance_monitoring.R

#' Performance Monitoring and Optimization for inrep Package
#'
#' This file contains functions for monitoring and optimizing performance
#' in the inrep package, including parallel processing efficiency and
#' resource utilization.

#' Performance Monitor Class
#'
#' Creates a performance monitoring object for tracking inrep operations.
#'
#' @param config Study configuration object
#' @return Performance monitor object
#' @export
create_performance_monitor <- function(config) {
  monitor <- list(
    config = config,
    metrics = list(),
    start_time = Sys.time(),
    operations = list(),
    parallel_stats = list(),
    memory_usage = list(),
    cache_stats = list()
  )
  
  class(monitor) <- "inrep_performance_monitor"
  return(monitor)
}

#' Start Operation Timing
#'
#' Starts timing an operation for performance monitoring.
#'
#' @param monitor Performance monitor object
#' @param operation_name Name of the operation
#' @param operation_type Type of operation ("item_selection", "ability_estimation", "batch_processing")
#' @return Updated monitor object
#' @export
start_operation_timing <- function(monitor, operation_name, operation_type = "general") {
  monitor$operations[[operation_name]] <- list(
    start_time = Sys.time(),
    operation_type = operation_type,
    status = "running"
  )
  return(monitor)
}

#' End Operation Timing
#'
#' Ends timing an operation and records performance metrics.
#'
#' @param monitor Performance monitor object
#' @param operation_name Name of the operation
#' @param additional_metrics Additional metrics to record
#' @return Updated monitor object
#' @export
end_operation_timing <- function(monitor, operation_name, additional_metrics = list()) {
  if (is.null(monitor$operations[[operation_name]])) {
    warning(sprintf("Operation '%s' was not started", operation_name))
    return(monitor)
  }
  
  end_time <- Sys.time()
  start_time <- monitor$operations[[operation_name]]$start_time
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  # Record basic metrics
  monitor$operations[[operation_name]]$end_time <- end_time
  monitor$operations[[operation_name]]$duration <- duration
  monitor$operations[[operation_name]]$status <- "completed"
  
  # Add additional metrics
  monitor$operations[[operation_name]]$additional_metrics <- additional_metrics
  
  # Record memory usage if available
  if (requireNamespace("pryr", quietly = TRUE)) {
    monitor$operations[[operation_name]]$memory_usage <- pryr::mem_used()
  }
  
  return(monitor)
}

#' Record Parallel Processing Stats
#'
#' Records statistics about parallel processing performance.
#'
#' @param monitor Performance monitor object
#' @param operation_name Name of the operation
#' @param n_workers Number of workers used
#' @param n_items Number of items processed
#' @param parallel_method Method used ("future", "parallel", "sequential")
#' @return Updated monitor object
#' @export
record_parallel_stats <- function(monitor, operation_name, n_workers, n_items, parallel_method) {
  if (is.null(monitor$parallel_stats[[operation_name]])) {
    monitor$parallel_stats[[operation_name]] <- list()
  }
  
  monitor$parallel_stats[[operation_name]]$n_workers <- n_workers
  monitor$parallel_stats[[operation_name]]$n_items <- n_items
  monitor$parallel_stats[[operation_name]]$parallel_method <- parallel_method
  
  # Calculate efficiency metrics
  if (n_workers > 1) {
    monitor$parallel_stats[[operation_name]]$efficiency <- 
      (n_items / monitor$operations[[operation_name]]$duration) / n_workers
  } else {
    monitor$parallel_stats[[operation_name]]$efficiency <- 
      n_items / monitor$operations[[operation_name]]$duration
  }
  
  return(monitor)
}

#' Record Cache Statistics
#'
#' Records statistics about caching performance.
#'
#' @param monitor Performance monitor object
#' @param operation_name Name of the operation
#' @param cache_hits Number of cache hits
#' @param cache_misses Number of cache misses
#' @param cache_size Size of cache
#' @return Updated monitor object
#' @export
record_cache_stats <- function(monitor, operation_name, cache_hits, cache_misses, cache_size) {
  if (is.null(monitor$cache_stats[[operation_name]])) {
    monitor$cache_stats[[operation_name]] <- list()
  }
  
  total_requests <- cache_hits + cache_misses
  hit_rate <- if (total_requests > 0) cache_hits / total_requests else 0
  
  monitor$cache_stats[[operation_name]]$cache_hits <- cache_hits
  monitor$cache_stats[[operation_name]]$cache_misses <- cache_misses
  monitor$cache_stats[[operation_name]]$cache_size <- cache_size
  monitor$cache_stats[[operation_name]]$hit_rate <- hit_rate
  
  return(monitor)
}

#' Get Performance Summary
#'
#' Generates a summary of performance metrics.
#'
#' @param monitor Performance monitor object
#' @return Performance summary
#' @export
get_performance_summary <- function(monitor) {
  total_time <- as.numeric(difftime(Sys.time(), monitor$start_time, units = "secs"))
  
  # Calculate overall metrics
  completed_operations <- monitor$operations[sapply(monitor$operations, function(x) x$status == "completed")]
  total_operations <- length(completed_operations)
  
  if (total_operations == 0) {
    return(list(
      total_time = total_time,
      total_operations = 0,
      average_operation_time = 0,
      parallel_efficiency = 0,
      cache_hit_rate = 0
    ))
  }
  
  # Calculate average operation time
  operation_times <- sapply(completed_operations, function(x) x$duration)
  average_operation_time <- mean(operation_times, na.rm = TRUE)
  
  # Calculate parallel efficiency
  parallel_ops <- monitor$parallel_stats[sapply(monitor$parallel_stats, function(x) !is.null(x$efficiency))]
  parallel_efficiency <- if (length(parallel_ops) > 0) {
    mean(sapply(parallel_ops, function(x) x$efficiency), na.rm = TRUE)
  } else {
    0
  }
  
  # Calculate cache hit rate
  cache_ops <- monitor$cache_stats[sapply(monitor$cache_stats, function(x) !is.null(x$hit_rate))]
  cache_hit_rate <- if (length(cache_ops) > 0) {
    mean(sapply(cache_ops, function(x) x$hit_rate), na.rm = TRUE)
  } else {
    0
  }
  
  return(list(
    total_time = total_time,
    total_operations = total_operations,
    average_operation_time = average_operation_time,
    parallel_efficiency = parallel_efficiency,
    cache_hit_rate = cache_hit_rate,
    operations = completed_operations,
    parallel_stats = monitor$parallel_stats,
    cache_stats = monitor$cache_stats
  ))
}

#' Print Performance Summary
#'
#' Prints a formatted performance summary.
#'
#' @param monitor Performance monitor object
#' @export
print_performance_summary <- function(monitor) {
  summary <- get_performance_summary(monitor)
  
  cat("=== INREP PERFORMANCE SUMMARY ===\n")
  cat(sprintf("Total Runtime: %.2f seconds\n", summary$total_time))
  cat(sprintf("Operations Completed: %d\n", summary$total_operations))
  cat(sprintf("Average Operation Time: %.3f seconds\n", summary$average_operation_time))
  cat(sprintf("Parallel Efficiency: %.2f items/second/worker\n", summary$parallel_efficiency))
  cat(sprintf("Cache Hit Rate: %.1f%%\n", summary$cache_hit_rate * 100))
  
  if (length(summary$operations) > 0) {
    cat("\n=== OPERATION DETAILS ===\n")
    for (op_name in names(summary$operations)) {
      op <- summary$operations[[op_name]]
      cat(sprintf("%s: %.3f seconds (%s)\n", op_name, op$duration, op$operation_type))
    }
  }
  
  if (length(summary$parallel_stats) > 0) {
    cat("\n=== PARALLEL PROCESSING STATS ===\n")
    for (op_name in names(summary$parallel_stats)) {
      ps <- summary$parallel_stats[[op_name]]
      cat(sprintf("%s: %d workers, %d items, %.2f efficiency\n", 
                 op_name, ps$n_workers, ps$n_items, ps$efficiency))
    }
  }
  
  if (length(summary$cache_stats) > 0) {
    cat("\n=== CACHE STATISTICS ===\n")
    for (op_name in names(summary$cache_stats)) {
      cs <- summary$cache_stats[[op_name]]
      cat(sprintf("%s: %.1f%% hit rate (%d hits, %d misses)\n", 
                 op_name, cs$hit_rate * 100, cs$cache_hits, cs$cache_misses))
    }
  }
}

#' Optimize Configuration Based on Performance
#'
#' Suggests configuration optimizations based on performance data.
#'
#' @param monitor Performance monitor object
#' @param item_bank_size Size of item bank
#' @param expected_participants Expected number of participants
#' @return Optimization suggestions
#' @export
optimize_configuration <- function(monitor, item_bank_size, expected_participants) {
  summary <- get_performance_summary(monitor)
  suggestions <- list()
  
  # Parallel processing optimization
  if (summary$parallel_efficiency < 10 && item_bank_size > 100) {
    suggestions$parallel_processing <- list(
      issue = "Low parallel efficiency detected",
      recommendation = "Consider reducing number of workers or increasing batch size",
      current_efficiency = summary$parallel_efficiency,
      suggested_workers = min(4, parallel::detectCores() - 1)
    )
  }
  
  # Cache optimization
  if (summary$cache_hit_rate < 0.5) {
    suggestions$caching <- list(
      issue = "Low cache hit rate detected",
      recommendation = "Consider increasing cache size or improving cache strategy",
      current_hit_rate = summary$cache_hit_rate,
      suggested_cache_size = item_bank_size * 2
    )
  }
  
  # Memory optimization
  if (requireNamespace("pryr", quietly = TRUE)) {
    current_memory <- pryr::mem_used()
    if (current_memory > 1e9) {  # More than 1GB
      suggestions$memory <- list(
        issue = "High memory usage detected",
        recommendation = "Consider reducing batch size or enabling garbage collection",
        current_memory = current_memory,
        suggested_batch_size = max(10, expected_participants / 4)
      )
    }
  }
  
  # Operation timing optimization
  if (summary$average_operation_time > 5) {
    suggestions$operation_timing <- list(
      issue = "Slow operation times detected",
      recommendation = "Consider enabling parallel processing or optimizing algorithms",
      current_avg_time = summary$average_operation_time,
      suggested_parallel = TRUE
    )
  }
  
  return(suggestions)
}

#' Benchmark Different Configurations
#'
#' Benchmarks different configuration settings to find optimal performance.
#'
#' @param participants List of participant data
#' @param item_bank Item bank data frame
#' @param base_config Base configuration
#' @param test_configs List of configurations to test
#' @return Benchmark results
#' @export
benchmark_configurations <- function(participants, item_bank, base_config, test_configs) {
  if (length(participants) == 0) {
    warning("No participants provided for benchmarking")
    return(list())
  }
  
  results <- list()
  
  for (i in seq_along(test_configs)) {
    config_name <- names(test_configs)[i] %||% paste0("config_", i)
    test_config <- test_configs[[i]]
    
    # Create performance monitor
    monitor <- create_performance_monitor()
    
    # Benchmark the configuration
    start_time <- Sys.time()
    tryCatch({
      # Process participants with test configuration
      test_results <- process_participants_batch(participants, item_bank, test_config, parallel = TRUE)
      
      end_time <- Sys.time()
      duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
      
      results[[config_name]] <- list(
        config = test_config,
        duration = duration,
        n_participants = length(participants),
        participants_per_second = length(participants) / duration,
        success = TRUE,
        results = test_results
      )
      
    }, error = function(e) {
      results[[config_name]] <- list(
        config = test_config,
        duration = NA,
        n_participants = length(participants),
        participants_per_second = NA,
        success = FALSE,
        error = e$message
      )
    })
  }
  
  return(results)
}

#' Generate Performance Report
#'
#' Generates a comprehensive performance report.
#'
#' @param monitor Performance monitor object
#' @param output_file Output file path (optional)
#' @return Performance report
#' @export
generate_performance_report <- function(monitor, output_file = NULL) {
  summary <- get_performance_summary(monitor)
  
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
    performance_summary = summary,
    recommendations = if (exists("optimize_configuration")) {
      optimize_configuration(monitor, 100, 50)  # Default values
    } else list()
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

#' Memory Usage Monitoring
#'
#' Monitors memory usage during operations.
#'
#' @param operation_name Name of the operation
#' @return Memory usage information
#' @export
monitor_memory_usage <- function(operation_name) {
  if (!requireNamespace("pryr", quietly = TRUE)) {
    warning("pryr package not available for memory monitoring")
    return(list(available = FALSE))
  }
  
  memory_info <- list(
    operation = operation_name,
    timestamp = Sys.time(),
    memory_used = pryr::mem_used(),
    memory_used_mb = pryr::mem_used() / 1024^2,
    available = TRUE
  )
  
  # Force garbage collection
  gc()
  
  memory_info$memory_after_gc <- pryr::mem_used()
  memory_info$memory_after_gc_mb <- pryr::mem_used() / 1024^2
  
  return(memory_info)
}