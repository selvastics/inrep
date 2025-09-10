# File: parallel_utils.R

#' Parallel Processing Utilities for inrep Package
#'
#' This file contains utilities for parallel processing in the inrep package,
#' including batch processing, parallel item information computation, and
#' performance monitoring.

#' Initialize Parallel Processing Environment
#'
#' Sets up the optimal parallel processing environment based on system resources
#' and configuration settings.
#'
#' @param config Study configuration object
#' @param task_type Type of task ("item_selection", "ability_estimation", "batch_processing")
#' @return List containing parallel processing configuration
#' @export
initialize_parallel_env <- function(config, task_type = "item_selection") {
  # Detect available cores
  cores <- tryCatch(parallel::detectCores(), error = function(e) 2)
  
  # Determine optimal number of workers based on task type and system resources
  n_workers <- switch(task_type,
    "item_selection" = min(4, max(1, cores - 1)),
    "ability_estimation" = min(2, max(1, cores - 1)),
    "batch_processing" = min(2, max(1, cores - 1))
  )
  
  # Check if parallel processing is enabled and packages are available
  parallel_enabled <- isTRUE(config$parallel_computation) && 
                     requireNamespace("parallel", quietly = TRUE)
  
  future_enabled <- requireNamespace("future", quietly = TRUE) && 
                   requireNamespace("future.apply", quietly = TRUE)
  
  # Set up parallel processing plan
  if (parallel_enabled && future_enabled) {
    # Use future for better parallel processing
    old_plan <- future::plan()
    future::plan(future::multisession, workers = n_workers)
    
    return(list(
      method = "future",
      n_workers = n_workers,
      old_plan = old_plan,
      cleanup = function() future::plan(old_plan)
    ))
  } else if (parallel_enabled) {
    # Use base parallel processing
    cl <- parallel::makeCluster(n_workers, type = "PSOCK")
    
    return(list(
      method = "parallel",
      n_workers = n_workers,
      cluster = cl,
      cleanup = function() parallel::stopCluster(cl)
    ))
  } else {
    # Sequential processing
    return(list(
      method = "sequential",
      n_workers = 1,
      cleanup = function() NULL
    ))
  }
}

#' Parallel Item Information Computation
#'
#' Computes item information for multiple items in parallel.
#'
#' @param theta Ability estimate
#' @param item_indices Vector of item indices
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @param parallel_env Parallel processing environment
#' @return Vector of information values
#' @export
parallel_item_info <- function(theta, item_indices, item_bank, config, parallel_env) {
  if (parallel_env$method == "future") {
    # Use future.apply for parallel computation
    future.apply::future_vapply(item_indices, function(i) {
      compute_item_info_single(theta, i, item_bank, config)
    }, numeric(1), future.seed = TRUE)
  } else if (parallel_env$method == "parallel") {
    # Use base parallel processing
    parallel::clusterExport(parallel_env$cluster, 
                          c("theta", "item_bank", "config", "compute_item_info_single"), 
                          envir = environment())
    parallel::parSapply(parallel_env$cluster, item_indices, function(i) {
      compute_item_info_single(theta, i, item_bank, config)
    })
  } else {
    # Sequential processing
    vapply(item_indices, function(i) {
      compute_item_info_single(theta, i, item_bank, config)
    }, numeric(1))
  }
}

#' Single Item Information Computation
#'
#' Computes information for a single item (used in parallel processing).
#'
#' @param theta Ability estimate
#' @param item_idx Item index
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @return Information value
#' @export
compute_item_info_single <- function(theta, item_idx, item_bank, config) {
  # Handle unknown (NA) discrimination parameter
  a <- item_bank$a[item_idx]
  if (is.na(a)) {
    a <- switch(config$model,
      "1PL" = 1.0,
      "2PL" = 1.2,
      "3PL" = 1.0,
      "GRM" = 1.5,
      1.0
    )
  }
  
  # Handle unknown difficulty/threshold parameters
  if (config$model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    if (length(b_cols) == 0) {
      return(0)
    }
    b_thresholds <- as.numeric(item_bank[item_idx, b_cols])
    
    # Replace any NA thresholds with defaults
    if (any(is.na(b_thresholds))) {
      na_indices <- which(is.na(b_thresholds))
      for (i in na_indices) {
        b_thresholds[i] <- (i - (length(b_thresholds) + 1) / 2) * 1.2
      }
      b_thresholds <- sort(b_thresholds)
      for (i in 2:length(b_thresholds)) {
        if (b_thresholds[i] <= b_thresholds[i-1]) {
          b_thresholds[i] <- b_thresholds[i-1] + 0.1
        }
      }
    }
  } else {
    b <- item_bank$b[item_idx] %||% 0
    if (is.na(b)) {
      b <- 0
    }
  }
  
  # Handle unknown guessing parameter
  c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) {
    c_val <- item_bank$c[item_idx]
    if (is.na(c_val)) 0.15 else c_val
  } else 0
  
  # Compute information based on model
  info <- if (config$model == "3PL") {
    p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b)))
    q <- 1 - p
    (a^2 * (p - c_param)^2 * q) / (p * (1 - c_param)^2)
  } else if (config$model == "GRM") {
    n_categories <- length(b_thresholds) + 1
    if (n_categories < 2) {
      return(0)
    }
    probs <- numeric(n_categories)
    probs[1] <- 1 / (1 + exp(a * (theta - b_thresholds[1])))
    for (k in 2:(n_categories - 1)) {
      probs[k] <- 1 / (1 + exp(a * (theta - b_thresholds[k - 1]))) -
        1 / (1 + exp(a * (theta - b_thresholds[k])))
    }
    probs[n_categories] <- 1 - 1 / (1 + exp(a * (theta - b_thresholds[n_categories - 1])))
    a^2 * sum(probs * (1 - probs), na.rm = TRUE)
  } else {
    p <- 1 / (1 + exp(-a * (theta - b)))
    a^2 * p * (1 - p)
  }
  
  if (is.finite(info) && info > 0) info else 0
}

#' Fast Item Information Computation with Caching
#'
#' Optimized item information computation with intelligent caching.
#'
#' @param theta Ability estimate
#' @param item_idx Item index
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @param cache Cache object for storing results
#' @return Information value
#' @export
fast_item_info <- function(theta, item_idx, item_bank, config, cache = NULL) {
  if (is.null(cache)) {
    return(compute_item_info_single(theta, item_idx, item_bank, config))
  }
  
  # Create cache key
  cache_key <- paste(theta, item_idx, sep = ":")
  
  # Check cache first
  if (!is.null(cache[[cache_key]])) {
    return(cache[[cache_key]])
  }
  
  # Compute and cache
  info <- compute_item_info_single(theta, item_idx, item_bank, config)
  cache[[cache_key]] <- if (is.finite(info)) info else 0
  
  return(info)
}

#' Parallel Batch Processing for Multiple Participants
#'
#' Processes multiple participants in parallel for batch operations.
#'
#' @param participants List of participant data
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @param process_fun Function to process each participant
#' @return List of results for each participant
#' @export
parallel_batch_process <- function(participants, item_bank, config, process_fun) {
  parallel_env <- initialize_parallel_env(config, "batch_processing")
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel batch processing
      results <- future.apply::future_lapply(participants, function(participant) {
        process_fun(participant, item_bank, config)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("item_bank", "config", "process_fun"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, participants, function(participant) {
        process_fun(participant, item_bank, config)
      })
    } else {
      # Sequential processing
      results <- lapply(participants, function(participant) {
        process_fun(participant, item_bank, config)
      })
    }
    
    return(results)
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Parallel Data Export
#'
#' Exports data in multiple formats in parallel.
#'
#' @param data Data to export
#' @param formats Vector of export formats ("csv", "json", "rds")
#' @param output_dir Output directory
#' @param config Study configuration
#' @return List of export results
#' @export
parallel_export <- function(data, formats = c("csv", "json", "rds"), output_dir = ".", config) {
  parallel_env <- initialize_parallel_env(config, "batch_processing")
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel export
      results <- future.apply::future_lapply(formats, function(format) {
        export_data_format(data, format, output_dir)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("data", "output_dir", "export_data_format"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, formats, function(format) {
        export_data_format(data, format, output_dir)
      })
    } else {
      # Sequential processing
      results <- lapply(formats, function(format) {
        export_data_format(data, format, output_dir)
      })
    }
    
    return(results)
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Export Data in Specific Format
#'
#' Helper function for parallel export.
#'
#' @param data Data to export
#' @param format Export format
#' @param output_dir Output directory
#' @return Export result
#' @export
export_data_format <- function(data, format, output_dir) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- file.path(output_dir, paste0("inrep_export_", timestamp, ".", format))
  
  tryCatch({
    switch(format,
      "csv" = {
        if (requireNamespace("readr", quietly = TRUE)) {
          readr::write_csv(data, filename)
        } else {
          write.csv(data, filename, row.names = FALSE)
        }
        list(format = "csv", file = filename, success = TRUE)
      },
      "json" = {
        if (requireNamespace("jsonlite", quietly = TRUE)) {
          jsonlite::write_json(data, filename, pretty = TRUE)
        } else {
          writeLines(jsonlite::toJSON(data, pretty = TRUE), filename)
        }
        list(format = "json", file = filename, success = TRUE)
      },
      "rds" = {
        saveRDS(data, filename)
        list(format = "rds", file = filename, success = TRUE)
      },
      {
        list(format = format, file = filename, success = FALSE, error = "Unknown format")
      }
    )
  }, error = function(e) {
    list(format = format, file = filename, success = FALSE, error = e$message)
  })
}

#' Performance Monitoring for Parallel Operations
#'
#' Monitors performance of parallel operations.
#'
#' @param operation_name Name of the operation
#' @param start_time Start time
#' @param end_time End time
#' @param n_items Number of items processed
#' @param n_workers Number of workers used
#' @return Performance metrics
#' @export
monitor_parallel_performance <- function(operation_name, start_time, end_time, n_items, n_workers) {
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
  items_per_second <- n_items / duration
  efficiency <- items_per_second / n_workers
  
  metrics <- list(
    operation = operation_name,
    duration = duration,
    n_items = n_items,
    n_workers = n_workers,
    items_per_second = items_per_second,
    efficiency = efficiency,
    timestamp = Sys.time()
  )
  
  # Log performance metrics
  if (requireNamespace("logr", quietly = TRUE)) {
    logr::log_print(sprintf("Parallel %s: %d items in %.3fs (%.1f items/sec, %.1f efficiency)", 
                           operation_name, n_items, duration, items_per_second, efficiency))
  }
  
  return(metrics)
}