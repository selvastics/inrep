# inrep: Adaptive Testing with Item Response Theory

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/inrep)](https://CRAN.R-project.org/package=inrep)
[![R-CMD-check](https://github.com/selvastics/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/selvastics/inrep/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

## Overview

**inrep** provides a comprehensive framework for adaptive testing using Item Response Theory (IRT) models. The package offers web-based interfaces for test administration via Shiny, supports multiple IRT models through TAM integration, implements adaptive item selection algorithms, and includes comprehensive reporting capabilities. It is designed for psychological assessments, educational testing, and survey research with large item pools.

### Key Features

- **Adaptive Testing**: Support for multiple IRT models (1PL, 2PL, 3PL, GRM) with intelligent item selection algorithms
- **Web-based Interface**: Modern Shiny applications for test administration and data collection
- **TAM Integration**: All psychometric computations performed using the validated TAM package
- **Multilingual Support**: Interface available in English, German, Spanish, and French
- **Customizable Themes**: Professional appearance with accessibility compliance
- **Comprehensive Reporting**: Multiple export formats with detailed analytics and visualizations
- **Session Management**: Robust session handling with resume capabilities

## Installation

### From CRAN

```r
install.packages("inrep")
```

### Development Version

```r
# Install from GitHub
devtools::install_github("selvastics/inrep")
```

### Dependencies

The package requires R >= 4.1.0 and integrates with the following packages:

- **shiny**: Web application framework for interactive interfaces
- **TAM**: Test Analysis Modules for IRT model estimation
- **DT**: Interactive data tables for results display
- **ggplot2**: High-quality visualizations and reporting

## Quick Start

### Basic Usage

```r
library(inrep)

# Load sample item bank
data(bfi_items)

# Create study configuration
config <- create_study_config(
  name = "Personality Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 5,
  min_SEM = 0.3,
  demographics = c("Age", "Gender"),
  language = "en"
)

# Launch study interface
launch_study(config)
```

### Advanced Features

```r
# Custom item bank
my_items <- data.frame(
  item_id = paste0("Q", 1:20),
  content = c("Your questionnaire items..."),
  category = rep("scale1", 20)
)

# Enhanced configuration
config <- create_study_config(
  name = "Custom Assessment",
  item_bank = my_items,
  model = "2PL",
  adaptive = TRUE,
  theme = "modern",
  translations = list(en = "English", de = "German")
)

launch_study(config)
```

## Documentation

Comprehensive documentation is available through vignettes:

- `vignette("getting-started", package = "inrep")` - Basic usage and setup
- `vignette("customizing-appearance", package = "inrep")` - Themes and styling
- `vignette("research-workflows", package = "inrep")` - Advanced research applications

## Main Functions

- `launch_study()`: Start an adaptive testing session
- `create_study_config()`: Configure study parameters
- `estimate_ability()`: Estimate participant abilities using IRT
- `select_next_item()`: Adaptive item selection algorithms
- `validate_item_bank()`: Check item bank format and content

## Example Datasets

- **`bfi_items`**: Big Five Inventory personality assessment items
- Sample item banks for demonstration and testing purposes

## Citation

If you use inrep in your research, please cite:

```
Selva, C. (2025). inrep: Adaptive Testing with Item Response Theory. 
R package version 1.0.0. https://github.com/selvastics/inrep
```

## Contributing

We welcome contributions! Please see our contributing guidelines and code of conduct on GitHub.

## License

This package is licensed under the MIT License. See LICENSE file for details.

## Support

- GitHub Issues: https://github.com/selvastics/inrep/issues
- Email: selva@uni-hildesheim.de

---

**Author:** Clievins Selva  
**Affiliation:** University of Hildesheim, Department of Psychology  
**Contact:** selva@uni-hildesheim.de

```r
# Core dependencies
install.packages(c("TAM", "shiny", "DT", "dplyr", "jsonlite"))
```
- **Security & Performance**: Ethical web scraping with robust error handling

## Key Features

- **Adaptive Testing with IRT Models**: Supports multiple IRT models (1PL, 2PL, 3PL, GRM) for precise ability estimation
- **TAM Integration**: All psychometric computations performed by the robust TAM package
- **Website Theme Scraping**: Extract colors, fonts, and logos from institutional websites
- **Dynamic UI Generation**: Create branded, accessible interfaces automatically
- **Multiple Item Banks**: Includes BFI personality items and mathematics assessment items
- **Flexible Configuration**: Customizable stopping rules, item selection criteria, and adaptive parameters
- **Comprehensive Vignettes**: Detailed guides for different assessment scenarios
- **Clean Architecture**: Streamlined codebase with proper imports and error handling
- **GitHub Ready**: Professional package structure ready for publication

## Datasets

- **`bfi_items`**: Big Five Inventory personality assessment items
- **`math_items`**: Entry-level mathematics questions (arithmetic, algebra, geometry, statistics)
- Custom item bank support with flexible data structures

## Installation

Install the development version from GitHub:

```r
# Install from GitHub
devtools::install_github("selvastics/inrep")
```

Or install from a local copy:

```r
devtools::install_local("path/to/inrep", force = TRUE)
```

## Quick Start

### Basic Adaptive Testing
```r
library(inrep)

# Load sample item bank
data(bfi_items)

# Create study configuration
config <- create_study_config(
  name = "Personality Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 5,
  min_SEM = 0.3,
  demographics = c("Age", "Gender"),
  language = "en"
)

# Launch the adaptive test
launch_study(config, bfi_items)
```

### Professional Platform Deployment
```r
# Create complete deployment package for professional hosting
deployment <- launch_to_inrep_platform(
  study_config = config,
  item_bank = bfi_items,
  deployment_type = "inrep_platform",
  contact_info = list(
    researcher_name = "Dr. Your Name",
    institution = "Your University", 
    email = "your.email@university.edu",
    study_title = "Your Study Title",
    study_description = "Brief description of your study",
    expected_duration = "Study duration",
    expected_participants = 500
  )
)

# Contact selva@uni-hildesheim.de for professional hosting
# Use the generated contact template and deployment package
```

### Enhanced UI with Website Scraping
```r
# Scrape a website for theme inspiration
result <- scrape_website_ui("https://www.uni-hildesheim.de/")

# Preview extracted themes
for (i in seq_along(result$themes)) {
  theme <- result$themes[[i]]
  cat(sprintf("Theme %d: %s (%s)\n", i, theme$name, theme$primary_color))
}

# Create study with scraped theme
config <- create_study_config(
  title = "BFI Assessment",
  theme_config = result$themes[[1]]
)

# Launch with multiple theme options
launch_study(config, bfi_items, theme_options = result$themes)
```

### AI-Assisted Theme Customization
```r
# Get AI customization prompt
result <- scrape_website_ui("https://www.example.com/", verbose = TRUE)
# Copy the generated prompt to ChatGPT/Claude for theme optimization
```

This launches a Shiny application where participants can take the adaptive test. Results are automatically saved in the specified format.

## Configuration Options

The package offers extensive configuration options:

- **IRT Models**: 1PL (Rasch), 2PL, 3PL, GRM
- **Stopping Rules**: Minimum/maximum items, standard error thresholds
- **Item Selection**: Maximum Information, Random, Fixed sequences
- **Themes**: Light, Dark, Minimal, Academic, and more
- **Languages**: English, German, Spanish, French
- **Demographics**: Customizable demographic collection
- **Session Management**: Save/resume functionality

## Detailed Usage

For a comprehensive guide on using `inrep`, including advanced configuration options, cloud storage setup, LLM integration, and theme customization, please refer to the vignette:

```R
vignette("adaptive_testing", package = "inrep")
```

## Documentation

For detailed usage instructions and examples:

```r
# View package documentation
help(package = "inrep")

# View main functions
?create_study_config
?launch_study
?estimate_ability

# View vignettes
vignette("getting-started", package = "inrep")
vignette("customizing-appearance", package = "inrep")
vignette("research-workflows", package = "inrep")
```

## Contributing

This package is designed to be publication-ready and follows R package development best practices. All psychometric computations are performed by the TAM package, ensuring methodological rigor.

## License

MIT License - see LICENSE file for details.

## Citation

When using this package in academic work, please cite:

```
Selva, C. (2025). inrep: Adaptive Testing Framework for Item Response Theory. 
R package version 1.0.0. University of Hildesheim, Department of Psychology.
https://github.com/selvastics/inrep
```

## Contact

**Clievins Selva**  
University of Hildesheim, Department of Psychology  
Email: selva@uni-hildesheim.de  
GitHub: https://github.com/selvastics/inrep