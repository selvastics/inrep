#' Later Package Utility Functions for inrep
#'
#' This file contains utility functions that leverage the 'later' package
#' for asynchronous operations, background processing, and event loop management
#' throughout the inrep package.
#'
#' @name later_utils
#' @keywords internal
NULL

#' Execute Function with Later Package Integration
#'
#' A wrapper function that provides standardized later execution with error handling
#' and logging capabilities.
#'
#' @param func A function or formula to execute later (see rlang::as_function())
#' @param delay Number of seconds to delay execution (default: 0 for immediate)
#' @param loop Event loop handle (defaults to current_loop())
#' @param error_handler Function to handle errors (optional)
#' @param log_prefix Prefix for log messages (default: "LATER")
#'
#' @return A cancellation function
#' @export
#'
#' @examples
#' \dontrun{
#' # Execute immediately in background
#' inrep_later(function() cat("Hello from background\n"))
#' 
#' # Execute with delay
#' inrep_later(~print("Delayed execution"), delay = 2)
#' 
#' # Execute with error handling
#' inrep_later(
#'   function() stop("Test error"), 
#'   error_handler = function(e) cat("Error caught:", e$message, "\n")
#' )
#' }
inrep_later <- function(func, delay = 0, loop = current_loop(), 
                        error_handler = NULL, log_prefix = "LATER") {
  
  # Convert function using rlang if needed
  func <- rlang::as_function(func)
  
  # Wrap function with error handling and logging
  wrapped_func <- function() {
    if (!is.null(log_prefix)) {
      cat(sprintf("%s: Executing function\n", log_prefix))
    }
    
    tryCatch({
      func()
    }, error = function(e) {
      if (!is.null(error_handler)) {
        error_handler(e)
      } else {
        warning(sprintf("%s: Error in later execution: %s", log_prefix, e$message))
      }
    })
  }
  
  # Schedule with later
  later(wrapped_func, delay = delay, loop = loop)
}

#' Create and Manage Private Event Loop
#'
#' Creates a private event loop with automatic cleanup and management.
#'
#' @param parent Parent event loop (defaults to current_loop())
#' @param auto_cleanup Whether to automatically destroy loop when done
#'
#' @return List with loop handle and management functions
#' @export
#'
#' @examples
#' \dontrun{
#' # Create managed private loop
#' loop_manager <- create_managed_loop()
#' 
#' # Use the loop
#' inrep_later(~cat("Private loop execution\n"), loop = loop_manager$loop)
#' loop_manager$run_now()
#' 
#' # Cleanup when done
#' loop_manager$cleanup()
#' }
create_managed_loop <- function(parent = current_loop(), auto_cleanup = TRUE) {
  
  # Create the loop
  loop <- create_loop(parent = parent)
  
  # Track if loop exists
  loop_exists <- TRUE
  
  # Management functions
  list(
    loop = loop,
    
    run_now = function(timeoutSecs = 0L, all = TRUE) {
      if (loop_exists && exists_loop(loop)) {
        run_now(timeoutSecs = timeoutSecs, all = all, loop = loop)
      } else {
        warning("Loop no longer exists")
        FALSE
      }
    },
    
    exists = function() {
      loop_exists && exists_loop(loop)
    },
    
    cleanup = function() {
      if (loop_exists && exists_loop(loop)) {
        destroy_loop(loop)
        loop_exists <<- FALSE
        TRUE
      } else {
        FALSE
      }
    },
    
    # Auto-cleanup on garbage collection if enabled
    finalize = if (auto_cleanup) {
      reg.finalizer(environment(), function(e) {
        if (loop_exists && exists_loop(loop)) {
          destroy_loop(loop)
        }
      }, onexit = TRUE)
    } else NULL
  )
}

#' Execute Function with Temporary Loop
#'
#' Creates a temporary event loop, executes function, then cleans up.
#' This is a convenience wrapper around with_temp_loop with additional features.
#'
#' @param expr Expression to evaluate
#' @param timeout Maximum time to wait for completion (seconds)
#' @param error_handler Function to handle errors
#'
#' @return Result of expression evaluation
#' @export
#'
#' @examples
#' \dontrun{
#' # Execute with temporary loop
#' result <- inrep_with_temp_loop({
#'   later(~cat("Temp loop execution\n"))
#'   run_now()
#'   "completed"
#' })
#' }
inrep_with_temp_loop <- function(expr, timeout = 30, error_handler = NULL) {
  
  result <- NULL
  error_occurred <- FALSE
  
  tryCatch({
    # Use later's with_temp_loop with timeout protection
    result <- with_temp_loop({
      # Set up timeout if specified
      if (is.finite(timeout) && timeout > 0) {
        timeout_reached <- FALSE
        later(function() {
          timeout_reached <<- TRUE
        }, delay = timeout)
      }
      
      # Evaluate expression
      eval(substitute(expr), parent.frame())
    })
  }, error = function(e) {
    error_occurred <<- TRUE
    if (!is.null(error_handler)) {
      error_handler(e)
    } else {
      stop(e)
    }
  })
  
  result
}

#' Background Task Manager
#'
#' Manages multiple background tasks with progress tracking and coordination.
#'
#' @return A task manager object
#' @export
#'
#' @examples
#' \dontrun{
#' # Create task manager
#' tm <- create_task_manager()
#' 
#' # Add tasks
#' tm$add_task("task1", function() Sys.sleep(1))
#' tm$add_task("task2", function() Sys.sleep(2))
#' 
#' # Run all tasks
#' tm$run_all()
#' 
#' # Check status
#' tm$get_status()
#' }
create_task_manager <- function() {
  
  # Private state
  tasks <- list()
  task_status <- list()
  manager_loop <- create_managed_loop()
  
  list(
    add_task = function(task_id, func, delay = 0) {
      tasks[[task_id]] <<- list(
        func = rlang::as_function(func),
        delay = delay,
        added_at = Sys.time()
      )
      task_status[[task_id]] <<- "pending"
      invisible(task_id)
    },
    
    run_task = function(task_id) {
      if (!task_id %in% names(tasks)) {
        stop("Task not found: ", task_id)
      }
      
      task <- tasks[[task_id]]
      task_status[[task_id]] <<- "running"
      
      cancel_func <- inrep_later(
        function() {
          tryCatch({
            task$func()
            task_status[[task_id]] <<- "completed"
          }, error = function(e) {
            task_status[[task_id]] <<- "failed"
            warning("Task ", task_id, " failed: ", e$message)
          })
        },
        delay = task$delay,
        loop = manager_loop$loop,
        log_prefix = paste("TASK", task_id)
      )
      
      tasks[[task_id]]$cancel <<- cancel_func
      invisible(cancel_func)
    },
    
    run_all = function() {
      for (task_id in names(tasks)) {
        if (task_status[[task_id]] == "pending") {
          self$run_task(task_id)
        }
      }
      manager_loop$run_now()
    },
    
    get_status = function(task_id = NULL) {
      if (is.null(task_id)) {
        task_status
      } else {
        task_status[[task_id]]
      }
    },
    
    cancel_task = function(task_id) {
      if (task_id %in% names(tasks) && !is.null(tasks[[task_id]]$cancel)) {
        result <- tasks[[task_id]]$cancel()
        task_status[[task_id]] <<- "cancelled"
        result
      } else {
        FALSE
      }
    },
    
    cleanup = function() {
      # Cancel all running tasks
      for (task_id in names(tasks)) {
        if (task_status[[task_id]] == "running") {
          self$cancel_task(task_id)
        }
      }
      
      # Cleanup manager loop
      manager_loop$cleanup()
    },
    
    # Get reference to self for internal use
    self = environment()
  )
}

#' File Descriptor Monitoring Utilities
#'
#' Simplified interface for monitoring file descriptors with later_fd.
#'
#' @param readfds File descriptors to monitor for reading
#' @param writefds File descriptors to monitor for writing  
#' @param exceptfds File descriptors to monitor for exceptions
#' @param callback Function to call when ready (receives logical vector)
#' @param timeout Timeout in seconds (default: Inf)
#' @param loop Event loop to use
#'
#' @return Cancellation function
#' @export
#'
#' @examples
#' \dontrun{
#' # Monitor file descriptor for reading
#' cancel_func <- monitor_fd(
#'   readfds = c(0),  # stdin
#'   callback = function(ready) {
#'     if (ready[1]) cat("Input ready!\n")
#'   },
#'   timeout = 5
#' )
#' }
monitor_fd <- function(readfds = integer(), writefds = integer(), 
                       exceptfds = integer(), callback, timeout = Inf, 
                       loop = current_loop()) {
  
  # Validate callback
  callback <- rlang::as_function(callback)
  
  # Wrap callback with error handling
  safe_callback <- function(ready) {
    tryCatch({
      callback(ready)
    }, error = function(e) {
      warning("FD monitor callback error: ", e$message)
    })
  }
  
  # Use later_fd
  later_fd(
    func = safe_callback,
    readfds = readfds,
    writefds = writefds,
    exceptfds = exceptfds,
    timeout = timeout,
    loop = loop
  )
}

#' Get Next Operation Timing
#'
#' Enhanced wrapper around next_op_secs with additional information.
#'
#' @param loop Event loop to check
#' @param format Return format: "seconds", "milliseconds", or "formatted"
#'
#' @return Time information in requested format
#' @export
#'
#' @examples
#' \dontrun{
#' # Schedule something
#' later(~cat("Hello\n"), delay = 5)
#' 
#' # Check timing
#' get_next_operation_time()  # seconds
#' get_next_operation_time(format = "formatted")  # human readable
#' }
get_next_operation_time <- function(loop = current_loop(), format = "seconds") {
  
  secs <- next_op_secs(loop = loop)
  
  switch(format,
    "seconds" = secs,
    "milliseconds" = secs * 1000,
    "formatted" = {
      if (is.infinite(secs)) {
        "No operations scheduled"
      } else if (secs <= 0) {
        "Operations ready now"
      } else if (secs < 60) {
        sprintf("%.2f seconds", secs)
      } else if (secs < 3600) {
        sprintf("%.1f minutes", secs / 60)
      } else {
        sprintf("%.1f hours", secs / 3600)
      }
    },
    stop("Invalid format: ", format)
  )
}

#' Batch Execute Functions with Later
#'
#' Execute multiple functions in sequence or parallel using later.
#'
#' @param funcs List of functions to execute
#' @param mode Execution mode: "sequence" or "parallel"
#' @param delay_between Delay between sequential executions (ignored for parallel)
#' @param loop Event loop to use
#' @param progress_callback Optional progress callback function
#'
#' @return List of cancellation functions
#' @export
#'
#' @examples
#' \dontrun{
#' # Sequential execution
#' batch_later(
#'   list(
#'     function() cat("Step 1\n"),
#'     function() cat("Step 2\n"),
#'     function() cat("Step 3\n")
#'   ),
#'   mode = "sequence",
#'   delay_between = 1
#' )
#' 
#' # Parallel execution
#' batch_later(
#'   list(
#'     function() Sys.sleep(1),
#'     function() Sys.sleep(1),
#'     function() Sys.sleep(1)
#'   ),
#'   mode = "parallel"
#' )
#' }
batch_later <- function(funcs, mode = "sequence", delay_between = 0, 
                        loop = current_loop(), progress_callback = NULL) {
  
  # Validate inputs
  if (!is.list(funcs)) stop("funcs must be a list")
  if (!mode %in% c("sequence", "parallel")) stop("mode must be 'sequence' or 'parallel'")
  
  # Convert functions
  funcs <- lapply(funcs, rlang::as_function)
  n_funcs <- length(funcs)
  
  # Progress tracking
  completed <- 0
  
  update_progress <- function() {
    completed <<- completed + 1
    if (!is.null(progress_callback)) {
      progress_callback(completed, n_funcs)
    }
  }
  
  # Cancellation functions
  cancel_funcs <- list()
  
  if (mode == "sequence") {
    # Sequential execution with delays
    for (i in seq_along(funcs)) {
      delay <- (i - 1) * delay_between
      
      cancel_funcs[[i]] <- inrep_later(
        function() {
          funcs[[i]]()
          update_progress()
        },
        delay = delay,
        loop = loop,
        log_prefix = sprintf("BATCH[%d/%d]", i, n_funcs)
      )
    }
  } else {
    # Parallel execution (all start immediately)
    for (i in seq_along(funcs)) {
      cancel_funcs[[i]] <- inrep_later(
        function() {
          funcs[[i]]()
          update_progress()
        },
        delay = 0,
        loop = loop,
        log_prefix = sprintf("PARALLEL[%d/%d]", i, n_funcs)
      )
    }
  }
  
  cancel_funcs
}