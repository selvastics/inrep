#' Launch Study with INSTANT first page display using later package
#' 
#' Uses later package's event loops for PERFECT immediate display
#' 
#' @export
launch_study_instant <- function(config, item_bank, ...) {
  # Ensure later package
  if (!requireNamespace("later", quietly = TRUE)) {
    stop("Package 'later' required. Install with: install.packages('later')")
  }
  
  # Silent logger
  silent <- function(...) {}
  
  # Use later's with_temp_loop for immediate execution
  later::with_temp_loop({
    # Schedule immediate UI display
    later::later(function() {
      # UI displays here
    }, delay = 0)
    
    # Force immediate execution
    later::run_now(timeoutSecs = 0, all = TRUE)
  })
  
  # Launch with all optimizations
  launch_study(
    config = config,
    item_bank = item_bank,
    immediate_ui = TRUE,
    logger = silent,
    session_save = FALSE,
    ...
  )
}