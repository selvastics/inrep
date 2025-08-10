#' @title Enhanced Performance Optimization Module
#' @description Provides comprehensive performance improvements including caching, memory management,
#' query optimization, and concurrent user handling for the inrep package.
#' @details This module implements performance optimizations to handle large-scale
#' assessments with thousands of concurrent users and large item banks. It includes
#' caching strategies, memory management, and efficient data processing.
#' @name enhanced_performance
#' @docType data
NULL

# Global performance state
.performance_state <- new.env()
.performance_state$cache <- new.env()
.performance_state$memory_monitor <- list()
.performance_state$query_cache <- new.env()
.performance_state$concurrent_users <- 0

#' Initialize Performance Optimization
#' 
#' @param enable_caching Enable result caching
#' @param enable_memory_management Enable automatic memory management
#' @param enable_query_optimization Enable query result caching
#' @param max_cache_size Maximum cache size in MB
#' @param max_concurrent_users Maximum concurrent users
#' @return List with performance configuration
#' @export
initialize_performance_optimization <- function(
  enable_caching = TRUE,
  enable_memory_management = TRUE,
  enable_query_optimization = TRUE,
  max_cache_size = 500,  # MB
  max_concurrent_users = 1000
) {
  .performance_state$enable_caching <- enable_caching
  .performance_state$enable_memory_management <- enable_memory_management
  .performance_state$enable_query_optimization <- enable_query_optimization
  .performance_state$max_cache_size <- max_cache_size * 1024 * 1024  # Convert to bytes
  .performance_state$max_concurrent_users <- max_concurrent_users
  
  # Start memory monitoring
  if (enable_memory_management) {
    start_memory_monitoring()
  }
  
  # Initialize cache cleanup
  if (enable_caching) {
    schedule_cache_cleanup()
  }
  
  return(list(
    caching = enable_caching,
    memory_management = enable_memory_management,
    query_optimization = enable_query_optimization,
    max_cache_size = max_cache_size,
    max_concurrent_users = max_concurrent_users
  ))
}

#' Cache Computation Result
#' 
#' Caches expensive computation results
#' 
#' @param key Cache key
#' @param value Value to cache
#' @param ttl Time to live in seconds (default: 3600)
#' @return Logical indicating success
#' @export
cache_result <- function(key, value, ttl = 3600) {
  if (!.performance_state$enable_caching) return(FALSE)
  
  # Check cache size before adding
  if (check_cache_size() > .performance_state$max_cache_size) {
    evict_old_cache_entries()
  }
  
  .performance_state$cache[[key]] <- list(
    value = value,
    created = Sys.time(),
    expires = Sys.time() + ttl,
    hits = 0,
    size = object.size(value)
  )
  
  return(TRUE)
}

#' Get Cached Result
#' 
#' Retrieves a cached result if available and valid
#' 
#' @param key Cache key
#' @return Cached value or NULL
#' @export
get_cached_result <- function(key) {
  if (!.performance_state$enable_caching) return(NULL)
  
  if (!(key %in% names(.performance_state$cache))) return(NULL)
  
  cache_entry <- .performance_state$cache[[key]]
  
  # Check expiration
  if (Sys.time() > cache_entry$expires) {
    rm(list = key, envir = .performance_state$cache)
    return(NULL)
  }
  
  # Update hit count
  .performance_state$cache[[key]]$hits <- cache_entry$hits + 1
  
  return(cache_entry$value)
}

#' Memoized Function Wrapper
#' 
#' Creates a memoized version of a function for performance
#' 
#' @param fn Function to memoize
#' @param cache_key_fn Function to generate cache key from arguments
#' @return Memoized function
#' @export
memoize_function <- function(fn, cache_key_fn = NULL) {
  if (is.null(cache_key_fn)) {
    cache_key_fn <- function(...) {
      digest::digest(list(...))
    }
  }
  
  function(...) {
    key <- cache_key_fn(...)
    
    # Check cache
    cached <- get_cached_result(key)
    if (!is.null(cached)) {
      return(cached)
    }
    
    # Compute result
    result <- fn(...)
    
    # Cache result
    cache_result(key, result)
    
    return(result)
  }
}

#' Optimize Large Item Bank Operations
#' 
#' Optimizes operations on large item banks using indexing and chunking
#' 
#' @param item_bank Item bank data frame
#' @param operation Operation to perform
#' @param chunk_size Size of chunks for processing
#' @return Optimized item bank or result
#' @export
optimize_item_bank_operation <- function(item_bank, operation, chunk_size = 1000) {
  n_items <- nrow(item_bank)
  
  if (n_items <= chunk_size) {
    # Small enough to process directly
    return(operation(item_bank))
  }
  
  # Process in chunks
  n_chunks <- ceiling(n_items / chunk_size)
  results <- vector("list", n_chunks)
  
  for (i in seq_len(n_chunks)) {
    start_idx <- (i - 1) * chunk_size + 1
    end_idx <- min(i * chunk_size, n_items)
    
    chunk <- item_bank[start_idx:end_idx, , drop = FALSE]
    results[[i]] <- operation(chunk)
    
    # Allow garbage collection between chunks
    if (i %% 10 == 0) {
      gc(verbose = FALSE)
    }
  }
  
  # Combine results
  do.call(rbind, results)
}

#' Memory-Efficient Data Frame Operations
#' 
#' Performs memory-efficient operations on large data frames
#' 
#' @param df Data frame
#' @param columns Columns to select (NULL for all)
#' @param filter_fn Optional filter function
#' @return Processed data frame
#' @export
efficient_df_operation <- function(df, columns = NULL, filter_fn = NULL) {
  # Use data.table for efficiency if available
  if (requireNamespace("data.table", quietly = TRUE)) {
    dt <- data.table::as.data.table(df)
    
    if (!is.null(columns)) {
      dt <- dt[, .SD, .SDcols = columns]
    }
    
    if (!is.null(filter_fn)) {
      dt <- dt[filter_fn(dt)]
    }
    
    return(as.data.frame(dt))
  }
  
  # Fallback to base R with optimization
  if (!is.null(columns)) {
    df <- df[, columns, drop = FALSE]
  }
  
  if (!is.null(filter_fn)) {
    df <- df[filter_fn(df), , drop = FALSE]
  }
  
  return(df)
}

#' Start Memory Monitoring
#' 
#' Starts monitoring memory usage and triggers cleanup when needed
start_memory_monitoring <- function() {
  .performance_state$memory_monitor$active <- TRUE
  .performance_state$memory_monitor$threshold <- 0.8  # 80% memory usage
  
  # Check memory periodically
  observe({
    if (!.performance_state$memory_monitor$active) return()
    
    invalidateLater(30000)  # Check every 30 seconds
    
    mem_usage <- get_memory_usage()
    
    if (mem_usage$percent > .performance_state$memory_monitor$threshold) {
      trigger_memory_cleanup()
    }
  })
}

#' Get Memory Usage
#' 
#' Gets current memory usage statistics
#' 
#' @return List with memory usage information
#' @export
get_memory_usage <- function() {
  gc_info <- gc(verbose = FALSE)
  
  used_mb <- sum(gc_info[, "used"]) / (1024^2)
  max_mb <- sum(gc_info[, "max used"]) / (1024^2)
  
  # Get system memory if possible
  total_system <- as.numeric(system("awk '/MemTotal/ {print $2}' /proc/meminfo", 
                                    intern = TRUE, ignore.stderr = TRUE)) / 1024
  
  list(
    used_mb = used_mb,
    max_mb = max_mb,
    total_system_mb = if (length(total_system) > 0) total_system else NA,
    percent = if (length(total_system) > 0) used_mb / total_system else NA
  )
}

#' Trigger Memory Cleanup
#' 
#' Triggers aggressive memory cleanup
trigger_memory_cleanup <- function() {
  message("Triggering memory cleanup...")
  
  # Clear expired cache entries
  evict_expired_cache()
  
  # Force garbage collection
  gc(verbose = FALSE, full = TRUE)
  
  # Clear temporary objects
  temp_objs <- ls(envir = .GlobalEnv, pattern = "^temp_|^tmp_")
  if (length(temp_objs) > 0) {
    rm(list = temp_objs, envir = .GlobalEnv)
  }
  
  # Log cleanup
  log_performance_event("MEMORY_CLEANUP", "Memory cleanup completed")
}

#' Check Cache Size
#' 
#' Checks total size of cached objects
#' 
#' @return Total cache size in bytes
check_cache_size <- function() {
  if (length(.performance_state$cache) == 0) return(0)
  
  total_size <- 0
  for (key in ls(.performance_state$cache)) {
    entry <- .performance_state$cache[[key]]
    if (!is.null(entry$size)) {
      total_size <- total_size + as.numeric(entry$size)
    }
  }
  
  return(total_size)
}

#' Evict Old Cache Entries
#' 
#' Evicts least recently used cache entries
evict_old_cache_entries <- function() {
  if (length(.performance_state$cache) == 0) return()
  
  # Get cache entries with metadata
  entries <- lapply(ls(.performance_state$cache), function(key) {
    entry <- .performance_state$cache[[key]]
    list(
      key = key,
      created = entry$created,
      hits = entry$hits,
      size = as.numeric(entry$size)
    )
  })
  
  # Sort by hits (LRU)
  entries <- entries[order(sapply(entries, function(x) x$hits))]
  
  # Remove bottom 25%
  n_remove <- ceiling(length(entries) * 0.25)
  for (i in seq_len(n_remove)) {
    rm(list = entries[[i]]$key, envir = .performance_state$cache)
  }
  
  log_performance_event("CACHE_EVICTION", 
                       paste("Evicted", n_remove, "cache entries"))
}

#' Evict Expired Cache
#' 
#' Removes expired cache entries
evict_expired_cache <- function() {
  if (length(.performance_state$cache) == 0) return()
  
  current_time <- Sys.time()
  expired_keys <- c()
  
  for (key in ls(.performance_state$cache)) {
    entry <- .performance_state$cache[[key]]
    if (current_time > entry$expires) {
      expired_keys <- c(expired_keys, key)
    }
  }
  
  if (length(expired_keys) > 0) {
    rm(list = expired_keys, envir = .performance_state$cache)
    log_performance_event("CACHE_EXPIRATION", 
                         paste("Removed", length(expired_keys), "expired entries"))
  }
}

#' Schedule Cache Cleanup
#' 
#' Schedules periodic cache cleanup
schedule_cache_cleanup <- function() {
  observe({
    invalidateLater(300000)  # Every 5 minutes
    evict_expired_cache()
  })
}

#' Optimize Query
#' 
#' Optimizes and caches database/data queries
#' 
#' @param query Query or operation
#' @param data Data to query
#' @param use_index Whether to use indexing
#' @return Query result
#' @export
optimize_query <- function(query, data, use_index = TRUE) {
  if (!.performance_state$enable_query_optimization) {
    return(query(data))
  }
  
  # Generate cache key
  cache_key <- digest::digest(list(query, dim(data)))
  
  # Check query cache
  if (cache_key %in% names(.performance_state$query_cache)) {
    cached <- .performance_state$query_cache[[cache_key]]
    if (Sys.time() < cached$expires) {
      return(cached$result)
    }
  }
  
  # Execute query with optimization
  if (use_index && nrow(data) > 10000) {
    # Create index for large datasets
    result <- with_index(data, query)
  } else {
    result <- query(data)
  }
  
  # Cache result
  .performance_state$query_cache[[cache_key]] <- list(
    result = result,
    expires = Sys.time() + 300  # 5 minute cache
  )
  
  return(result)
}

#' With Index Helper
#' 
#' Executes operation with temporary index
#' 
#' @param data Data frame
#' @param operation Operation to perform
#' @return Operation result
with_index <- function(data, operation) {
  # Create temporary index if beneficial
  if (requireNamespace("data.table", quietly = TRUE)) {
    dt <- data.table::as.data.table(data)
    data.table::setkey(dt, names(dt)[1])  # Index on first column
    result <- operation(dt)
    return(as.data.frame(result))
  }
  
  # Fallback to regular operation
  operation(data)
}

#' Handle Concurrent Users
#' 
#' Manages concurrent user limits and queueing
#' 
#' @param user_id User identifier
#' @param action Action to perform ("connect" or "disconnect")
#' @return List with status and queue position
#' @export
handle_concurrent_users <- function(user_id, action = "connect") {
  if (action == "connect") {
    .performance_state$concurrent_users <- .performance_state$concurrent_users + 1
    
    if (.performance_state$concurrent_users > .performance_state$max_concurrent_users) {
      # Add to queue
      queue_position <- .performance_state$concurrent_users - 
                       .performance_state$max_concurrent_users
      
      return(list(
        status = "queued",
        position = queue_position,
        estimated_wait = queue_position * 30  # seconds
      ))
    }
    
    return(list(
      status = "connected",
      concurrent_users = .performance_state$concurrent_users
    ))
    
  } else if (action == "disconnect") {
    .performance_state$concurrent_users <- max(0, .performance_state$concurrent_users - 1)
    
    return(list(
      status = "disconnected",
      concurrent_users = .performance_state$concurrent_users
    ))
  }
}

#' Batch Process Items
#' 
#' Processes items in optimized batches
#' 
#' @param items Items to process
#' @param process_fn Processing function
#' @param batch_size Batch size
#' @param parallel Whether to use parallel processing
#' @return Processed results
#' @export
batch_process_items <- function(items, process_fn, batch_size = 100, parallel = FALSE) {
  n_items <- length(items)
  n_batches <- ceiling(n_items / batch_size)
  
  if (parallel && requireNamespace("parallel", quietly = TRUE)) {
    # Use parallel processing
    cl <- parallel::makeCluster(min(4, parallel::detectCores() - 1))
    on.exit(parallel::stopCluster(cl))
    
    batches <- split(items, rep(1:n_batches, each = batch_size, length.out = n_items))
    results <- parallel::parLapply(cl, batches, process_fn)
    
  } else {
    # Sequential processing
    results <- vector("list", n_batches)
    
    for (i in seq_len(n_batches)) {
      start_idx <- (i - 1) * batch_size + 1
      end_idx <- min(i * batch_size, n_items)
      
      batch <- items[start_idx:end_idx]
      results[[i]] <- process_fn(batch)
    }
  }
  
  # Combine results
  unlist(results, recursive = FALSE)
}

#' Log Performance Event
#' 
#' Logs performance-related events
#' 
#' @param event_type Type of event
#' @param message Event message
log_performance_event <- function(event_type, message) {
  if (exists("log_session_event")) {
    log_session_event(paste0("PERFORMANCE_", event_type), message)
  }
}

#' Get Performance Status
#' 
#' Returns current performance system status
#' 
#' @return List with performance metrics
#' @export
get_performance_status <- function() {
  mem_usage <- get_memory_usage()
  
  list(
    caching_enabled = .performance_state$enable_caching,
    cache_entries = length(.performance_state$cache),
    cache_size_mb = check_cache_size() / (1024^2),
    memory_used_mb = mem_usage$used_mb,
    memory_percent = mem_usage$percent,
    concurrent_users = .performance_state$concurrent_users,
    max_concurrent_users = .performance_state$max_concurrent_users,
    query_cache_entries = length(.performance_state$query_cache)
  )
}

#' Clear Performance State
#' 
#' Clears performance state and caches
#' 
#' @export
clear_performance_state <- function() {
  rm(list = ls(.performance_state$cache), envir = .performance_state$cache)
  rm(list = ls(.performance_state$query_cache), envir = .performance_state$query_cache)
  .performance_state$concurrent_users <- 0
  gc(verbose = FALSE, full = TRUE)
  message("Performance state cleared")
}