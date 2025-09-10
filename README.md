# inrep: Instant Reports for Adaptive Assessments

<table width="100%"><tr>
<td><h1>inrep: Instant Reports for Adaptive Assessments</h1></td>

<td align="right" width="160">
  <a href="https://github.com/selvastics/inrep">
    <img src="man/figures/inrep_logo.png" alt="inrep hex logo" height="130"/>
  </a>
</td>
</tr></table>

<!-- badges: start -->
[![R-CMD-check](https://github.com/selvastics/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/selvastics/inrep/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
 [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16682020.svg)](https://doi.org/10.5281/zenodo.16682020)
<!-- badges: end -->

## Overview

**inrep** provides a framework for adaptive testing using Item Response Theory (IRT) models. The package offers web-based interfaces for test administration via Shiny, supports multiple IRT models through TAM integration, implements adaptive item selection algorithms, and includes reporting capabilities. It is designed for psychological assessments, educational testing, and survey research with large item pools.

<!-- Demo: See the package in action! -->
![inrep demo](man/figures/inrep_previewer.gif)

> **Demo:** The above video showcases the main functionalities of the inrep package, including adaptive test setup, Shiny-based administration, theme customization, LLM-powered assistance, and professional reporting. Watch to see how easy it is to configure, deploy, and analyze adaptive assessments with inrep.

### Key Features

- **Adaptive & Non-Adaptive Testing**: Support for multiple IRT models (1PL, 2PL, 3PL, GRM) with item selection algorithms, plus fixed-order questionnaires
- **Web-based Interface**: Modern Shiny applications for test administration and data collection  
- **TAM Integration**: All psychometric computations performed using the validated TAM package  
- **Professional Survey Features**: 30+ question types, branching logic, randomization, piping, quota control, and participant management
- **Enhanced Security**: Input validation, rate limiting, CSRF protection, encryption, and audit logging
- **Multilingual Support**: Interface available in English, German, Spanish, and French with complete translations
- **10+ Beautiful Themes**: Including Light, Professional, Ocean, Forest, Midnight, Sunset, Hildesheim, and more
- **Reporting**: Multiple export formats (CSV, JSON, SPSS, PDF) with detailed analytics and visualizations  
- **Session Recovery**: Session handling with automatic save and crash recovery capabilities
- **Smart Argument Validation**: Fuzzy matching for typos, case-insensitive parameters, helpful error messages
- **Performance Optimized**: Caching, parallel processing, memory management for large-scale deployments
- **Accessibility Options**: WCAG-compliant with colorblind-safe palettes, large text, dyslexia-friendly fonts, and high-contrast modes
- **CRAN-Ready**: Clean code, documentation, full test coverage

## Installation

### Development Version

```r
# Install from GitHub (clean installation with dependency management)
devtools::install_github("selvastics/inrep", ref = "main", force = TRUE)

# Load the package
library(inrep)
```

**Note:** The package now includes proper dependency version specifications to ensure a clean installation experience without unnecessary update prompts.

<details>
<summary><strong style="color:#2a5db0">Set up instructions: Expand if R is not yet installed on your system</strong></summary>

<br>

### Step 1: Install R and RStudio

1. **Install R**: [https://cran.r-project.org](https://cran.r-project.org)  
2. **Install RStudio**: [https://posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop)

### Step 2: Install Required System Tools

- **Windows**: Install [Rtools](https://cran.r-project.org/bin/windows/Rtools/)  
- **macOS**: Open Terminal and run:

  ```bash
  xcode-select --install
  ```

### Step 3: Install the Required Packages

Open RStudio and copy-paste the following:

```r
# Install devtools (required to install from GitHub)
install.packages("devtools")

# Load the package
library(devtools)

# Install inrep from GitHub
devtools::install_github("selvastics/inrep")

# Load the installed package
library(inrep)
```

If you encounter any error during installation, make sure Rtools (on Windows) or Xcode (on macOS) was correctly installed and your R version is up to date.

</details>

### Dependencies

The package requires R ≥ 4.1.0 and integrates with the following packages:

* **shiny**
* **TAM**
* **ggplot2**

## Quick Start

### Adaptive Testing (IRT-based)

```r
library(inrep)
data(bfi_items)

# Adaptive assessment with item selection based on ability
config <- create_study_config(
  name = "Adaptive Personality Assessment",
  model = "GRM",           # Graded Response Model
  adaptive = TRUE,         # Enable adaptive testing (default)
  max_items = 15,
  min_items = 5,
  min_SEM = 0.3,          # Stop when precision reached
  demographics = c("Age", "Gender"),
  theme = "professional"
)

launch_study(config, bfi_items)
```

### Non-Adaptive Testing (Fixed questionnaire)

```r
# Traditional questionnaire with fixed item order
config_fixed <- create_study_config(
  name = "Personality Questionnaire",
  adaptive = FALSE,        # Disable adaptive testing
  max_items = 5,          # Show exactly 5 items in order
  theme = "hildesheim",   # University theme
  session_save = TRUE     # Enable recovery
)

launch_study(config_fixed, bfi_items)
```

### Advanced Cognitive Ability Study (2PL) — Fully Specified

```r
# Fully specified cognitive ability study (2PL) with custom item bank
library(inrep)

# Define a complete item bank with varied correct answers
cognitive_items <- data.frame(
  Question = c(
    "If A>B and B>C, then A_C (fill in: >, <, =)",
    "A train travels 120 km in 2 hours. What is its speed?",
    "Which number completes the pattern: 3, 6, 9, 12, __?",
    "Which shape comes next in the sequence?",
    "What is 15% of 80?",
    "Which word is a synonym of 'rapid'?",
    "If 2x + 5 = 19, what is x?",
    "Which fraction is equivalent to 3/4?",
    "Rotate the figure 90° clockwise. Which orientation matches?",
    "What is the median of 2, 7, 3, 9, 5?",
    "Which of the following is a prime number?",
    "Complete the analogy: Finger is to hand as leaf is to __"
  ),
  Option1 = c(">", "40 km/h", "14", "Pattern A", "10", "slow", "6", "6/8", "Image A", "3", "21", "tree"),
  Option2 = c("<", "50 km/h", "15", "Pattern B", "12", "swift", "7", "9/12", "Image B", "5", "22", "branch"),
  Option3 = c("=", "60 km/h", "16", "Pattern C", "15", "rapidly", "8", "12/16", "Image C", "7", "23", "plant"),
  Option4 = c("?", "70 km/h", "18", "Pattern D", "18", "quick", "9", "15/20", "Image D", "9", "24", "stem"),
  Answer  = c(">", "60 km/h", "15", "Pattern C", "12", "quick", "7", "9/12", "Image C", "5", "23", "tree"),
  domain  = c("Logic","Math","Math","Spatial","Math","Verbal","Math","Math","Spatial","Math","Math","Verbal"),
  a = c(1.25, 1.10, 0.95, 1.30, 1.05, 1.15, 1.20, 0.90, 1.35, 1.00, 1.40, 1.05),
  b = c(0.00, -0.50, -0.20, 0.80, -0.30, 0.10, 0.40, -0.10, 1.10, 0.00, 0.60, -0.15),
  stringsAsFactors = FALSE
)

# Optional: attach simple inline images to spatial items
if (!"Image" %in% names(cognitive_items)) cognitive_items$Image <- ""
spatial_rows <- which(cognitive_items$domain == "Spatial")
if (length(spatial_rows) > 0) {
  svg <- 'data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="220" height="120"><rect width="220" height="120" fill="%23f8fafc"/><g fill="%232c3e50"><rect x="20" y="30" width="40" height="40" rx="6"/><rect x="80" y="30" width="40" height="40" rx="6"/><rect x="140" y="30" width="40" height="40" rx="6"/></g></svg>'
  cognitive_items$Image[spatial_rows] <- svg
}

# Create a detailed configuration
advanced_config <- create_study_config(
  name = "Cognitive Ability Assessment",
  model = "2PL",
  estimation_method = "TAM",
  adaptive = TRUE,
  criteria = "MI",
  min_items = 10,
  max_items = 20,
  min_SEM = 0.25,
  theta_prior = c(0, 1),
  demographics = c("Age", "Gender", "Education", "Native_Language"),
  input_types = list(
    Age = "numeric",
    Gender = "select",
    Education = "select",
    Native_Language = "text"
  ),
  theme = "Professional",
  session_save = TRUE,
  parallel_computation = TRUE,
  cache_enabled = TRUE,
  accessibility_enhanced = TRUE,
  participant_report = list(
    show_theta_plot = TRUE,
    show_response_table = TRUE,
    show_recommendations = TRUE,
    use_enhanced_report = TRUE,
    show_item_difficulty_trend = TRUE,
    show_domain_breakdown = TRUE
  )
)

# Launch the study (opens a Shiny app)
launch_study(
  config = advanced_config,
  item_bank = cognitive_items,
  accessibility = TRUE,
  admin_dashboard_hook = function(session_data) {
    message("Participant ID:", session_data$participant_id)
    message("Progress:", round(session_data$progress, 1), "%")
    message("Current theta:", round(session_data$theta, 3))
    message("Standard error:", round(session_data$se, 3))
  }
)
```

## Theme Customization 

![inrep themes](man/figures/inrep_themes.png)

> **Themes:** `inrep` supports multiple default UI themes for customizing assessment components.  
> In addition to built-in options, users can extract CSS styles from institutional websites  
> or define fully custom themes through direct CSS editing.  
>  
> New themes are added incrementally. Contributions are welcome to share themes that can be made available to other users.

## Documentation

* `vignette("getting-started", package = "inrep")`
* `vignette("customizing-appearance", package = "inrep")`
* `vignette("research-workflows", package = "inrep")`

## Main Functions

* `launch_study()`
* `create_study_config()`
* `estimate_ability()`
* `select_next_item()`
* `validate_item_bank()`
* `scrape_website_ui()`
* `enable_llm_assistance()`

## Example Datasets

* `bfi_items`
* `math_items`

## Configuration

### Models (TAM)

* IRT Models: 1PL, 2PL, 3PL, GRM

Please cite the TAM package when using inrep's IRT functionality:

Robitzsch, A., Kiefer, T., & Wu, M. (2024). TAM: Test Analysis Modules. R package version 4.2-21. https://CRAN.R-project.org/package=TAM

### Configuration Options

* Stopping Rules
* Item Selection Criteria
* Themes and Languages
* Session Management
* LLM Integration

## Citation

```
Selva, C. (2025). inrep: Instant Reports for Adaptive Assessments.  
R package version 1.0.0. https://github.com/selvastics/inrep
```

## Contributing

See `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md` on GitHub.

## License

MIT License

## Support

* GitHub: [https://github.com/selvastics/inrep/issues](https://github.com/selvastics/inrep/issues)
* Email: [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)

**Author:** Clievins Selva
**Affiliation:** University of Hildesheim
**Contact:** [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)

