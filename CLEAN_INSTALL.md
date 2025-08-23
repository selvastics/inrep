# Clean Installation Guide for increp

## Quick Install (Recommended)

For the cleanest installation experience with minimal warnings:

```r
# Download and run the clean installer
source("https://raw.githubusercontent.com/selvastics/inrep/main/clean_install.R")

# Install with clean mode
install_increp()  # Interactive mode
# OR
install_increp("main")  # Specific branch
```

## Manual Clean Install

If you prefer manual installation with suppressed warnings:

```r
# 1. Set quiet options
options(
  warn = -1,  # Suppress warnings
  inrep.quiet = TRUE,  # Quiet package loading
  inrep.installing = TRUE  # Installation mode
)

# 2. Install package
remotes::install_github(
  "selvastics/inrep",
  force = TRUE,
  quiet = TRUE,
  upgrade = "never",  # Don't upgrade dependencies
  build_vignettes = FALSE  # Skip for faster install
)

# 3. Reset options
options(warn = 0, inrep.quiet = FALSE, inrep.installing = FALSE)

# 4. Load package
library(inrep)
```

## Dealing with Common Issues

### 1. "Object 'bfi_items' is created by more than one data call"

This warning is harmless and relates to documentation. It doesn't affect functionality.

### 2. Empty directory warnings

The package build process automatically removes empty directories. This is normal.

### 3. Dependency updates

When prompted about updating dependencies, you can safely choose option 3 (None) unless you specifically need updates.

## Clean Uninstall

To completely remove the package before reinstalling:

```r
# Detach if loaded
if ("package:inrep" %in% search()) {
  detach("package:inrep", unload = TRUE)
}

# Remove package
remove.packages("inrep")

# Clear any cached data
rm(list = ls(pattern = "inrep", all.names = TRUE))
```

## Verification

After installation, verify everything works:

```r
# Load package quietly
library(inrep, quietly = TRUE)

# Check key functions
exists("launch_study")  # Should be TRUE
exists("create_study_config")  # Should be TRUE

# Run quick test
config <- create_study_config(
  name = "Test",
  model = "2PL",
  max_items = 10
)
```

## Installation Options

The clean installer supports various options:

```r
install_increp(
  branch = "main",     # Branch to install
  clean = TRUE,        # Clean before install
  verify = TRUE        # Verify after install
)
```

## Tips for Cleanest Experience

1. **Use remotes instead of devtools**: The `remotes` package is lighter and produces fewer messages
2. **Set quiet = TRUE**: Suppresses compilation messages
3. **Skip vignettes**: Use `build_vignettes = FALSE` for faster installation
4. **Don't upgrade dependencies**: Use `upgrade = "never"` to avoid unnecessary updates
5. **Use the clean installer script**: Automates all the above

## Support

If you encounter issues:
1. Try the clean uninstall procedure above
2. Restart R session
3. Run the clean installer
4. Check GitHub issues: https://github.com/selvastics/inrep/issues