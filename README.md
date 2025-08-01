


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

**inrep** provides a comprehensive framework for adaptive testing using Item Response Theory (IRT) models. The package offers web-based interfaces for test administration via Shiny, supports multiple IRT models through TAM integration, implements adaptive item selection algorithms, and includes comprehensive reporting capabilities with LLM integration for enhanced user assistance. It is designed for psychological assessments, educational testing, and survey research with large item pools.

<!-- Demo: See the package in action! -->
![inrep demo](man/figures/inrep_previewer.gif)

> **Demo:** The above video showcases the main functionalities of the inrep package, including adaptive test setup, Shiny-based administration, theme customization, LLM-powered assistance, and professional reporting. Watch to see how easy it is to configure, deploy, and analyze adaptive assessments with inrep.

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
- **Accessibility Options**: WCAG-compliant with colorblind-safe palettes, large text, dyslexia-friendly fonts, and high-contrast modes.

## Installation

### Development Version

```r
# Install from GitHub
devtools::install_github("selvastics/inrep")
````

<details>
<summary>💡 <strong style="color:#2a5db0">Set up instructions: Expand if R is not yet installed on your system</strong></summary>

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

### Basic Usage

```r
library(inrep)

data(bfi_items)

config <- create_study_config(
  name = "Personality Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 5,
  min_SEM = 0.3,
  demographics = c("Age", "Gender"),
  language = "en"
)

launch_study(config, bfi_items)
```

### Advanced Cognitive Assessment

```r
data(cognitive_items)

advanced_config <- create_study_config(
    name = "Cognitive Ability Assessment",
    model = "2PL", 
    estimation_method = "TAM",
    max_items = 20,
    min_items = 10,
    min_SEM = 0.25,
    criteria = "MI",
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
    accessibility_enhanced = TRUE
)

launch_study(
    config = advanced_config,
    item_bank = cognitive_items,
    accessibility = TRUE,
    admin_dashboard_hook = function(session_data) {
        cat("Participant ID:", session_data$participant_id, "\n")
        cat("Progress:", session_data$progress, "%\n")
        cat("Current theta:", round(session_data$theta, 3), "\n")
        cat("Standard error:", round(session_data$se, 3), "\n")
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

## Configuration Options

* IRT Models: 1PL, 2PL, 3PL, GRM
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

## Acknowledgments

I thank Alla Sawatzky and Kathrin Schütz for their early endorsement of this project and their insightful guidance during its conceptualization.

---

**Author:** Clievins Selva
**Affiliation:** University of Hildesheim
**Contact:** [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)

