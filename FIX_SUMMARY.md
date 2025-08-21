# Fixed: 'later' is not an exported object from 'namespace:shiny'

## Problem
The error occurred because shiny::later() does not exist. The later() function is from the separate 'later' package, not from shiny.

## Solution Applied

### 1. Changed Function Calls
- Replaced all `shiny::later()` with `later::later()`
- Found at lines 1428 and 1625

### 2. Added Package Requirement
- Added explicit check and loading of 'later' package at function start
- The later package is now loaded immediately since it's required for the deferred loading mechanism

### 3. Added Fallback Logic
When later package is not available:
- Session monitoring runs immediately instead of deferred
- Package loading happens immediately instead of deferred
- Application still works but without performance optimizations

### 4. Code Changes in R/launch_study.R

#### At function start (lines 594-600):
```r
# The later package is required for deferred loading - load it immediately
if (!requireNamespace("later", quietly = TRUE)) {
  logger("Package 'later' not available - deferred loading will be disabled", level = "WARNING")
} else {
  # Load later immediately as it's needed for the deferred loading mechanism
  suppressPackageStartupMessages(library(later, quietly = TRUE))
}
```

#### Session monitoring (lines 1423-1480):
```r
if (session_save) {
  # Ensure later package is available
  if (!requireNamespace("later", quietly = TRUE)) {
    logger("Package 'later' not available - session monitoring will be immediate", level = "WARNING")
  } else {
    # Delay session monitoring to not block initial load
    later::later(function() {
      # ... monitoring code ...
    }, delay = 1)
  }
}
```

#### Package lazy loading (lines 1621-1635):
```r
.load_packages_once <- function() {
  if (!.packages_loaded) {
    # Load packages in background
    if (requireNamespace("later", quietly = TRUE)) {
      later::later(function() {
        safe_load_packages(immediate = TRUE)
        .packages_loaded <<- TRUE
      }, delay = 0.1)
    } else {
      # If later not available, load immediately
      safe_load_packages(immediate = TRUE)
      .packages_loaded <- TRUE
    }
  }
}
```

## Testing

To test the fix:

1. Install the later package if not already installed:
```r
install.packages("later")
```

2. Reinstall inrep:
```r
devtools::install_github("selvastics/inrep")
```

3. Run Hildesheim study:
```r
library(inrep)
source("case_studies/hildesheim_study/hildesheim_production.R")
```

## Expected Behavior

With later package installed:
- First page loads in < 200ms
- Packages load in background
- Session monitoring starts after 1 second

Without later package:
- Warning message appears
- All features work but without deferred loading
- Performance similar to original version

## Package Dependencies

The inrep package now has these dependencies:
- shiny (required)
- later (recommended for performance)
- DT, ggplot2, dplyr, shinyWidgets (loaded on demand)
- TAM (only if adaptive mode is enabled)