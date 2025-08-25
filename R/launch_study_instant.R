#' Launch Study with INSTANT first page display
#' 
#' This wrapper ensures the first page displays IMMEDIATELY with ZERO delay
#' Uses the later package for optimal performance
#' 
#' @export
launch_study_instant <- function(config, item_bank, ...) {
  # Override logger to be completely silent
  silent_logger <- function(...) {}
  
  # Force immediate UI mode with silent logging
  launch_study(
    config = config, 
    item_bank = item_bank, 
    immediate_ui = TRUE,
    logger = silent_logger,
    ...
  )
}