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
    "batch_processing" = min(8, max(1, cores - 1)),
    min(2, max(1, cores - 1))
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
    # Sequential computation
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
#' @noRd
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
  
  # Handle difficulty/threshold parameters
  if (config$model == "GRM") {
    b_cols <- grep("^b[0-9]+$", names(item_bank), value = TRUE)
    if (length(b_cols) == 0) return(0)
    b_thresholds <- as.numeric(item_bank[item_idx, b_cols])
    
    # Replace NA thresholds with defaults
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
    
    n_categories <- length(b_thresholds) + 1
    probs <- numeric(n_categories)
    probs[1] <- 1 / (1 + exp(a * (theta - b_thresholds[1])))
    for (k in 2:(n_categories - 1)) {
      probs[k] <- 1 / (1 + exp(a * (theta - b_thresholds[k - 1]))) -
        1 / (1 + exp(a * (theta - b_thresholds[k])))
    }
    probs[n_categories] <- 1 - 1 / (1 + exp(a * (theta - b_thresholds[n_categories - 1])))
    return(a^2 * sum(probs * (1 - probs), na.rm = TRUE))
  } else {
    # Dichotomous models
    b <- item_bank$b[item_idx] %||% 0
    if (is.na(b)) b <- 0
    
    c_param <- if (config$model == "3PL" && "c" %in% names(item_bank)) {
      c_val <- item_bank$c[item_idx]
      if (is.na(c_val)) 0.15 else c_val
    } else 0
    
    if (config$model == "3PL") {
      p <- c_param + (1 - c_param) / (1 + exp(-a * (theta - b)))
      q <- 1 - p
      return((a^2 * (p - c_param)^2 * q) / (p * (1 - c_param)^2))
    } else {
      p <- 1 / (1 + exp(-a * (theta - b)))
      return(a^2 * p * (1 - p))
    }
  }
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
#' @param formats Vector of export formats ("csv", "json", "rds", "pdf")
#' @param file_prefix Prefix for output files
#' @param config Study configuration
#' @return List of exported file paths
#' @export
parallel_data_export <- function(data, formats, file_prefix, config) {
  parallel_env <- initialize_parallel_env(config, "batch_processing")
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel export
      results <- future.apply::future_lapply(formats, function(format) {
        export_single_format(data, format, file_prefix, config)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("data", "file_prefix", "config", "export_single_format"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, formats, function(format) {
        export_single_format(data, format, file_prefix, config)
      })
    } else {
      # Sequential processing
      results <- lapply(formats, function(format) {
        export_single_format(data, format, file_prefix, config)
      })
    }
    
    return(unlist(results))
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Export Single Format
#'
#' Exports data in a single format (used in parallel processing).
#'
#' @param data Data to export
#' @param format Export format
#' @param file_prefix File prefix
#' @param config Study configuration
#' @return File path
#' @noRd
export_single_format <- function(data, format, file_prefix, config) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- paste0(file_prefix, "_", timestamp, ".", format)
  
  switch(format,
    "csv" = {
      write.csv(data, filename, row.names = FALSE)
      filename
    },
    "json" = {
      if (requireNamespace("jsonlite", quietly = TRUE)) {
        jsonlite::write_json(data, filename, pretty = TRUE)
        filename
      } else {
        warning("jsonlite package not available for JSON export")
        NULL
      }
    },
    "rds" = {
      saveRDS(data, filename)
      filename
    },
    "pdf" = {
      if (requireNamespace("rmarkdown", quietly = TRUE)) {
        # Create temporary Rmd file
        rmd_content <- create_pdf_report(data, config)
        temp_rmd <- tempfile(fileext = ".Rmd")
        writeLines(rmd_content, temp_rmd)
        
        # Render PDF
        rmarkdown::render(temp_rmd, output_file = filename, quiet = TRUE)
        unlink(temp_rmd)
        filename
      } else {
        warning("rmarkdown package not available for PDF export")
        NULL
      }
    },
    {
      warning(sprintf("Unknown export format: %s", format))
      NULL
    }
  )
}

#' Create PDF Report Content
#'
#' Creates R Markdown content for PDF export.
#'
#' @param data Data to include in report
#' @param config Study configuration
#' @return R Markdown content
#' @noRd
create_pdf_report <- function(data, config) {
  paste0(
    "---\n",
    "title: '", config$name, " - Study Results'\n",
    "author: 'inrep Package'\n",
    "date: '", Sys.Date(), "'\n",
    "output: pdf_document\n",
    "---\n\n",
    "# Study Results\n\n",
    "## Configuration\n",
    "- Study Name: ", config$name, "\n",
    "- Model: ", config$model, "\n",
    "- Items: ", config$min_items, " to ", config$max_items %||% "unlimited", "\n\n",
    "## Data Summary\n",
    "```{r}\n",
    "str(data)\n",
    "```\n\n",
    "## Results\n",
    "```{r}\n",
    "if (is.data.frame(data)) {\n",
    "  knitr::kable(head(data, 20))\n",
    "} else {\n",
    "  print(data)\n",
    "}\n",
    "```\n"
  )
}

#' Performance Monitoring
#'
#' Monitors parallel processing performance and provides optimization suggestions.
#'
#' @param task_name Name of the task being monitored
#' @param start_time Start time of the task
#' @param n_items Number of items processed
#' @param parallel_env Parallel processing environment
#' @return Performance metrics
#' @export
monitor_performance <- function(task_name, start_time, n_items, parallel_env) {
  end_time <- Sys.time()
  duration <- as.numeric(difftime(end_time, start_time, units = "secs"))
  
  metrics <- list(
    task = task_name,
    duration = duration,
    n_items = n_items,
    items_per_second = n_items / duration,
    parallel_method = parallel_env$method,
    n_workers = parallel_env$n_workers,
    efficiency = if (parallel_env$n_workers > 1) {
      (n_items / duration) / parallel_env$n_workers
    } else {
      n_items / duration
    }
  )
  
  # Log performance metrics
  if (getOption("inrep.verbose", TRUE)) {
    message(sprintf("Performance: %s completed in %.2f seconds (%.2f items/sec, %d workers)", 
                   task_name, duration, metrics$items_per_second, parallel_env$n_workers))
  }
  
  return(metrics)
}

#' Optimize Parallel Configuration
#'
#' Suggests optimal parallel processing configuration based on system resources.
#'
#' @param config Study configuration
#' @param item_bank_size Size of item bank
#' @param expected_participants Expected number of participants
#' @return Optimized configuration
#' @export
optimize_parallel_config <- function(config, item_bank_size, expected_participants) {
  cores <- tryCatch(parallel::detectCores(), error = function(e) 2)
  
  # Determine optimal parallel settings
  if (item_bank_size > 100 && expected_participants > 50) {
    # Large scale - enable all parallel features
    config$parallel_computation <- TRUE
    config$cache_enabled <- TRUE
    config$parallel_workers <- min(8, cores - 1)
    config$parallel_batch_size <- 50
  } else if (item_bank_size > 50 || expected_participants > 20) {
    # Medium scale - moderate parallel processing
    config$parallel_computation <- TRUE
    config$cache_enabled <- TRUE
    config$parallel_workers <- min(4, cores - 1)
    config$parallel_batch_size <- 25
  } else {
    # Small scale - minimal parallel processing
    config$parallel_computation <- FALSE
    config$cache_enabled <- TRUE
    config$parallel_workers <- 1
    config$parallel_batch_size <- 10
  }
  
  return(config)
}