# File: batch_processing.R

#' Batch Processing for Multiple Participants
#'
#' This file contains functions for processing multiple participants in parallel,
#' including batch ability estimation, item selection, and data export.

#' Process Multiple Participants in Batch
#'
#' Processes multiple participants simultaneously using parallel processing
#' for improved efficiency.
#'
#' @param participants List of participant data, each containing responses and demographics
#' @param item_bank Item bank data frame
#' @param config Study configuration object
#' @param parallel Logical indicating whether to use parallel processing
#' @return List containing results for each participant
#' @export
process_participants_batch <- function(participants, item_bank, config, parallel = TRUE) {
  if (length(participants) == 0) {
    warning("No participants provided for batch processing")
    return(list())
  }
  
  # Initialize parallel environment
  if (parallel && isTRUE(config$parallel_computation)) {
    parallel_env <- initialize_parallel_env(config, "batch_processing")
  } else {
    parallel_env <- list(method = "sequential", n_workers = 1, cleanup = function() NULL)
  }
  
  start_time <- Sys.time()
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel processing
      results <- future.apply::future_lapply(participants, function(participant) {
        process_single_participant(participant, item_bank, config)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("item_bank", "config", "process_single_participant"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, participants, function(participant) {
        process_single_participant(participant, item_bank, config)
      })
    } else {
      # Sequential processing
      results <- lapply(participants, function(participant) {
        process_single_participant(participant, item_bank, config)
      })
    }
    
    # Monitor performance
    if (getOption("inrep.verbose", TRUE)) {
      monitor_performance("batch_processing", start_time, length(participants), parallel_env)
    }
    
    return(results)
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Process Single Participant
#'
#' Processes a single participant's data (used in batch processing).
#'
#' @param participant Participant data containing responses and demographics
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @return Processed participant results
#' @noRd
process_single_participant <- function(participant, item_bank, config) {
  tryCatch({
    # Extract participant data
    responses <- participant$responses %||% participant$data %||% c()
    demographics <- participant$demographics %||% participant$demo %||% list()
    participant_id <- participant$id %||% participant$participant_id %||% "unknown"
    
    if (length(responses) == 0) {
      return(list(
        participant_id = participant_id,
        error = "No responses provided",
        theta = NA,
        se = NA
      ))
    }
    
    # Create reactive values object
    rv <- list(
      responses = responses,
      administered = participant$administered %||% seq_along(responses),
      current_ability = config$theta_prior[1] %||% 0,
      ability_se = config$theta_prior[2] %||% 1,
      demographics = demographics
    )
    
    # Estimate ability
    ability_result <- estimate_ability(rv, item_bank, config)
    
    # Calculate additional metrics
    n_items <- length(responses)
    response_time <- participant$response_time %||% NA
    session_duration <- participant$session_duration %||% NA
    
    # Generate recommendations if function is available
    recommendations <- if (is.function(config$recommendation_fun)) {
      tryCatch({
        config$recommendation_fun(ability_result$theta, demographics, responses)
      }, error = function(e) {
        c("Unable to generate recommendations")
      })
    } else {
      c("No recommendation function configured")
    }
    
    return(list(
      participant_id = participant_id,
      theta = ability_result$theta,
      se = ability_result$se,
      method = ability_result$method %||% config$estimation_method,
      n_items = n_items,
      response_time = response_time,
      session_duration = session_duration,
      demographics = demographics,
      recommendations = recommendations,
      convergence = ability_result$convergence %||% TRUE,
      reliability = ability_result$reliability %||% NA,
      processed_at = Sys.time()
    ))
    
  }, error = function(e) {
    return(list(
      participant_id = participant$id %||% "unknown",
      error = e$message,
      theta = NA,
      se = NA,
      processed_at = Sys.time()
    ))
  })
}

#' Batch Item Selection for Multiple Participants
#'
#' Performs item selection for multiple participants in parallel.
#'
#' @param participants List of participant states
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @param parallel Logical indicating whether to use parallel processing
#' @return List of selected items for each participant
#' @export
batch_item_selection <- function(participants, item_bank, config, parallel = TRUE) {
  if (length(participants) == 0) {
    warning("No participants provided for batch item selection")
    return(list())
  }
  
  # Initialize parallel environment
  if (parallel && isTRUE(config$parallel_computation)) {
    parallel_env <- initialize_parallel_env(config, "item_selection")
  } else {
    parallel_env <- list(method = "sequential", n_workers = 1, cleanup = function() NULL)
  }
  
  start_time <- Sys.time()
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel processing
      results <- future.apply::future_lapply(participants, function(participant) {
        select_next_item(participant, item_bank, config)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("item_bank", "config", "select_next_item"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, participants, function(participant) {
        select_next_item(participant, item_bank, config)
      })
    } else {
      # Sequential processing
      results <- lapply(participants, function(participant) {
        select_next_item(participant, item_bank, config)
      })
    }
    
    # Monitor performance
    if (getOption("inrep.verbose", TRUE)) {
      monitor_performance("batch_item_selection", start_time, length(participants), parallel_env)
    }
    
    return(results)
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Batch Data Export
#'
#' Exports data for multiple participants in parallel.
#'
#' @param results List of participant results
#' @param config Study configuration
#' @param formats Vector of export formats
#' @param output_dir Output directory for files
#' @param parallel Logical indicating whether to use parallel processing
#' @return List of exported file paths
#' @export
batch_data_export <- function(results, config, formats = c("csv", "json", "rds"), 
                             output_dir = ".", parallel = TRUE) {
  if (length(results) == 0) {
    warning("No results provided for batch export")
    return(list())
  }
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Prepare data for export
  export_data <- prepare_batch_export_data(results, config)
  
  # Initialize parallel environment
  if (parallel && isTRUE(config$parallel_computation)) {
    parallel_env <- initialize_parallel_env(config, "batch_processing")
  } else {
    parallel_env <- list(method = "sequential", n_workers = 1, cleanup = function() NULL)
  }
  
  start_time <- Sys.time()
  
  tryCatch({
    if (parallel_env$method == "future") {
      # Use future.apply for parallel export
      results <- future.apply::future_lapply(formats, function(format) {
        export_batch_format(export_data, format, output_dir, config)
      }, future.seed = TRUE)
    } else if (parallel_env$method == "parallel") {
      # Use base parallel processing
      parallel::clusterExport(parallel_env$cluster, 
                            c("export_data", "output_dir", "config", "export_batch_format"), 
                            envir = environment())
      results <- parallel::parLapply(parallel_env$cluster, formats, function(format) {
        export_batch_format(export_data, format, output_dir, config)
      })
    } else {
      # Sequential processing
      results <- lapply(formats, function(format) {
        export_batch_format(export_data, format, output_dir, config)
      })
    }
    
    # Monitor performance
    if (getOption("inrep.verbose", TRUE)) {
      monitor_performance("batch_export", start_time, length(formats), parallel_env)
    }
    
    return(unlist(results))
  }, finally = {
    parallel_env$cleanup()
  })
}

#' Prepare Batch Export Data
#'
#' Prepares data for batch export in various formats.
#'
#' @param results List of participant results
#' @param config Study configuration
#' @return Formatted data for export
#' @noRd
prepare_batch_export_data <- function(results, config) {
  # Extract basic information
  participant_ids <- sapply(results, function(x) x$participant_id %||% "unknown")
  thetas <- sapply(results, function(x) x$theta %||% NA)
  ses <- sapply(results, function(x) x$se %||% NA)
  methods <- sapply(results, function(x) x$method %||% "unknown")
  n_items <- sapply(results, function(x) x$n_items %||% NA)
  processed_at <- sapply(results, function(x) x$processed_at %||% Sys.time())
  
  # Create summary data frame
  summary_df <- data.frame(
    participant_id = participant_ids,
    theta = thetas,
    se = ses,
    method = methods,
    n_items = n_items,
    processed_at = processed_at,
    stringsAsFactors = FALSE
  )
  
  # Add demographic data if available
  demo_data <- extract_demographic_data(results)
  if (ncol(demo_data) > 1) {
    summary_df <- cbind(summary_df, demo_data[, -1, drop = FALSE])
  }
  
  # Create detailed results list
  detailed_results <- list(
    summary = summary_df,
    individual_results = results,
    study_config = config,
    export_metadata = list(
      export_time = Sys.time(),
      n_participants = length(results),
      package_version = if (requireNamespace("inrep", quietly = TRUE)) {
        utils::packageVersion("inrep")
      } else "unknown"
    )
  )
  
  return(detailed_results)
}

#' Extract Demographic Data
#'
#' Extracts demographic data from participant results.
#'
#' @param results List of participant results
#' @return Data frame with demographic information
#' @noRd
extract_demographic_data <- function(results) {
  # Find all unique demographic fields
  demo_fields <- unique(unlist(lapply(results, function(x) {
    if (is.list(x$demographics)) {
      names(x$demographics)
    } else {
      character(0)
    }
  })))
  
  if (length(demo_fields) == 0) {
    return(data.frame(participant_id = character(0)))
  }
  
  # Create demographic data frame
  demo_data <- data.frame(
    participant_id = sapply(results, function(x) x$participant_id %||% "unknown"),
    stringsAsFactors = FALSE
  )
  
  for (field in demo_fields) {
    demo_data[[field]] <- sapply(results, function(x) {
      if (is.list(x$demographics) && field %in% names(x$demographics)) {
        x$demographics[[field]]
      } else {
        NA
      }
    })
  }
  
  return(demo_data)
}

#' Export Batch Format
#'
#' Exports data in a specific format (used in parallel processing).
#'
#' @param data Data to export
#' @param format Export format
#' @param output_dir Output directory
#' @param config Study configuration
#' @return File path
#' @noRd
export_batch_format <- function(data, format, output_dir, config) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  filename <- file.path(output_dir, paste0("batch_results_", timestamp, ".", format))
  
  switch(format,
    "csv" = {
      write.csv(data$summary, filename, row.names = FALSE)
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
    "xlsx" = {
      if (requireNamespace("openxlsx", quietly = TRUE)) {
        wb <- openxlsx::createWorkbook()
        openxlsx::addWorksheet(wb, "Summary")
        openxlsx::writeData(wb, "Summary", data$summary)
        
        if (!is.null(data$individual_results)) {
          openxlsx::addWorksheet(wb, "Individual_Results")
          individual_df <- do.call(rbind, lapply(data$individual_results, function(x) {
            data.frame(
              participant_id = x$participant_id %||% "unknown",
              theta = x$theta %||% NA,
              se = x$se %||% NA,
              method = x$method %||% "unknown",
              n_items = x$n_items %||% NA,
              processed_at = x$processed_at %||% Sys.time(),
              stringsAsFactors = FALSE
            )
          }))
          openxlsx::writeData(wb, "Individual_Results", individual_df)
        }
        
        openxlsx::saveWorkbook(wb, filename, overwrite = TRUE)
        filename
      } else {
        warning("openxlsx package not available for Excel export")
        NULL
      }
    },
    {
      warning(sprintf("Unknown export format: %s", format))
      NULL
    }
  )
}

#' Performance Benchmarking
#'
#' Benchmarks parallel processing performance across different configurations.
#'
#' @param participants List of participant data
#' @param item_bank Item bank data frame
#' @param config Study configuration
#' @param n_workers Vector of worker counts to test
#' @return Benchmark results
#' @export
benchmark_parallel_performance <- function(participants, item_bank, config, n_workers = c(1, 2, 4, 8)) {
  if (!requireNamespace("parallel", quietly = TRUE)) {
    warning("Parallel package not available for benchmarking")
    return(NULL)
  }
  
  results <- list()
  
  for (n_worker in n_workers) {
    if (n_worker > parallel::detectCores()) {
      next  # Skip if more workers than cores
    }
    
    # Create test configuration
    test_config <- config
    test_config$parallel_computation <- TRUE
    test_config$parallel_workers <- n_worker
    
    # Benchmark processing time
    start_time <- Sys.time()
    tryCatch({
      test_results <- process_participants_batch(participants, item_bank, test_config, parallel = TRUE)
      end_time <- Sys.time()
      
      results[[as.character(n_worker)]] <- list(
        n_workers = n_worker,
        duration = as.numeric(difftime(end_time, start_time, units = "secs")),
        n_participants = length(participants),
        participants_per_second = length(participants) / as.numeric(difftime(end_time, start_time, units = "secs")),
        success = TRUE
      )
    }, error = function(e) {
      results[[as.character(n_worker)]] <- list(
        n_workers = n_worker,
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