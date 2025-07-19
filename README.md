# inrep: Instant Reports for Adaptive Assessments

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/inrep)](https://CRAN.R-project.org/package=inrep)
[![R-CMD-check](https://github.com/selvastics/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/selvastics/inrep/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
<!-- badges: end -->

## Overview

**inrep** provides a comprehensive framework for adaptive testing using Item Response Theory (IRT) models. The package offers web-based interfaces for test administration via Shiny, supports multiple IRT models through TAM integration, implements adaptive item selection algorithms, and includes comprehensive reporting capabilities with LLM integration for enhanced user assistance. It is designed for psychological assessments, educational testing, and survey research with large item pools.

### Key Features

- **Adaptive Testing**: Support for multiple IRT models (1PL, 2PL, 3PL, GRM) with sophisticated item selection algorithms
- **Web-based Interface**: Modern Shiny applications for test administration and data collection
- **TAM Integration**: All psychometric computations performed using the validated TAM package
- **LLM Integration**: Built-in support for LLM assistance in study configuration, deployment guidance, and optimization
- **Website Theme Scraping**: Extract colors, fonts, and logos from institutional websites for automatic branding
- **Multilingual Support**: Interface available in English, German, Spanish, and French
- **Customizable Themes**: Professional appearance with accessibility compliance
- **Comprehensive Reporting**: Multiple export formats with detailed analytics and visualizations
- **Session Management**: Robust session handling with resume capabilities

## Installation

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
launch_study(config, bfi_items)
```

### Advanced Features with Website Scraping

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
- `scrape_website_ui()`: Extract themes from websites for branding
- `enable_llm_assistance()`: Configure LLM integration for enhanced guidance

## Example Datasets

- **`bfi_items`**: Big Five Inventory personality assessment items
- **`math_items`**: Entry-level mathematics questions (arithmetic, algebra, geometry, statistics)
- Custom item bank support with flexible data structures

## Configuration Options

The package offers extensive configuration options:

- **IRT Models**: 1PL (Rasch), 2PL, 3PL, GRM
- **Stopping Rules**: Minimum/maximum items, standard error thresholds
- **Item Selection**: Maximum Information, Random, Fixed sequences
- **Themes**: Light, Dark, Minimal, Academic, and more
- **Languages**: English, German, Spanish, French
- **Demographics**: Customizable demographic collection
- **Session Management**: Save/resume functionality
- **LLM Integration**: Configurable assistance levels and prompt customization

## Citation

If you use inrep in your research, please cite:

```
Selva, C. (2025). inrep: Instant Reports for Adaptive Assessments. 
R package version 1.0.0. https://github.com/selvastics/inrep
```

## Contributing

We welcome contributions! Please see our contributing guidelines and code of conduct on GitHub.

## License

This package is licensed under the MIT License. See LICENSE file for details.

## Support

- GitHub Issues: https://github.com/selvastics/inrep/issues
- Email: selva@uni-hildesheim.de

## Acknowledgments

I am deeply grateful to Prof. Dr. Alla Sawatzky and Prof. Dr. Kathrin Schütz for their early endorsement of this project and their insightful guidance during its initial stages. Their contributions were pivotal in shaping both the conceptual foundation and the development trajectory of the inrep package.

---

**Author:** Clievins Selva  
**Affiliation:** University of Hildesheim, Department of Psychology  
**Contact:** selva@uni-hildesheim.de
