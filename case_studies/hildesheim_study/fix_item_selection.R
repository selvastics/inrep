# =============================================================================
# FIX FOR ITEM SELECTION ISSUE IN HILDESHEIM STUDY
# =============================================================================
# This script patches the item selection initialization issue

# Function to properly initialize the first item when starting assessment
initialize_first_item <- function(rv, item_bank, config) {
    # Log the initialization attempt
    cat("Initializing first item for assessment...\n")
    
    # For non-adaptive mode, just select the first item
    if (!isTRUE(config$adaptive)) {
        available_items <- setdiff(1:nrow(item_bank), rv$administered)
        if (length(available_items) > 0) {
            first_item <- available_items[1]
            cat("Selected first item (non-adaptive):", first_item, "\n")
            return(first_item)
        }
    }
    
    # For adaptive mode, use the standard selection
    return(inrep::select_next_item(rv, item_bank, config))
}

# Wrapper function for launch_study that fixes the issue
launch_study_fixed <- function(config, item_bank, ...) {
    # Add a custom begin_test handler that properly initializes the first item
    original_results_processor <- config$results_processor
    
    # Create a wrapper that ensures item initialization
    config$assessment_initializer <- function(rv, item_bank, config) {
        # Initialize required reactive values if missing
        if (is.null(rv$administered)) rv$administered <- integer(0)
        if (is.null(rv$responses)) rv$responses <- numeric(0)
        if (is.null(rv$current_ability)) rv$current_ability <- 0
        if (is.null(rv$ability_se)) rv$ability_se <- 1
        if (is.null(rv$item_counter)) rv$item_counter <- 0
        if (is.null(rv$session_start)) rv$session_start <- Sys.time()
        
        # Select the first item
        rv$current_item <- initialize_first_item(rv, item_bank, config)
        
        if (is.null(rv$current_item)) {
            cat("WARNING: Failed to initialize first item\n")
            # Fallback to first item
            rv$current_item <- 1
        }
        
        cat("First item initialized:", rv$current_item, "\n")
        return(rv)
    }
    
    # Launch with the fixed configuration
    inrep::launch_study(config = config, item_bank = item_bank, ...)
}

cat("=============================================================================\n")
cat("ITEM SELECTION FIX LOADED\n")
cat("=============================================================================\n")
cat("Use launch_study_fixed() instead of inrep::launch_study() to fix the issue\n")
cat("=============================================================================\n")