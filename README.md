# inrep - Intelligent Reproducible Assessment Platform

## Overview

The `inrep` package provides a comprehensive framework for creating and deploying adaptive assessments using Item Response Theory (IRT) models.

## Installation

```r
# Install from GitHub
devtools::install_github("selvastics/inrep")

# Or install from local directory
devtools::install(".")
```

## Quick Start

```r
library(inrep)

# Load example data
data(bfi_items)

# Create configuration
config <- create_study_config(
  name = "My Assessment",
  model = "GRM",
  max_items = 10
)

# Launch assessment
launch_study(config, bfi_items)
```

## Features

- Adaptive testing with IRT models (1PL, 2PL, 3PL, GRM)
- Real-time ability estimation
- Session management and recovery
- Multiple themes and customization options
- Cloud storage support
- Multi-language support

## Documentation

For detailed documentation, see:
```r
?inrep
vignette('inrep')
```

## License

MIT License

## Authors

See AUTHORS file for contributor information.