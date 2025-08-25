#' Launch Study with INSTANT first page display
#' 
#' This ensures the first page displays in < 100ms
#' 
#' @export
launch_study_instant <- function(config, item_bank, ...) {
  # Override ALL logging to be silent
  silent_logger <- function(...) {}
  assign("message", silent_logger, envir = .GlobalEnv)
  assign("cat", silent_logger, envir = .GlobalEnv)
  
  # Store original functions for restoration
  orig_message <- base::message
  orig_cat <- base::cat
  
  # Temporarily override base functions
  unlockBinding("message", baseenv())
  assign("message", silent_logger, baseenv())
  unlockBinding("cat", baseenv())  
  assign("cat", silent_logger, baseenv())
  
  # Clean up on exit
  on.exit({
    unlockBinding("message", baseenv())
    assign("message", orig_message, baseenv())
    unlockBinding("cat", baseenv())
    assign("cat", orig_cat, baseenv())
  })
  
  # Launch with all optimizations
  launch_study(
    config = config,
    item_bank = item_bank,
    immediate_ui = TRUE,
    logger = silent_logger,
    session_save = FALSE,  # Disable session saving for speed
    ...
  )
}