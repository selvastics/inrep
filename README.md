<!--- DISCLAIMER BANNER START --->
<div align="center" style="background: #f8f9fa; border: 2px solid #d6d8db; border-radius: 12px; padding: 25px; margin: 40px 0; max-width: 900px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); font-family: Arial, sans-serif;">
  <h2 style="margin: 0 0 15px 0; color: #212529; font-weight: 800; text-transform: uppercase; letter-spacing: 1px;">
    Disclaimer
  </h2>
  <p style="margin: 0; font-size: 16px; line-height: 1.6; color: #343a40; text-align: left;">
    This project is best described as a vibe coding project. While the initial work was solely done by me, the upscaling of the project and exploration of advanced functionalities were done using several LLMs, which I synthesized. Although much of the code is functional, it is not yet fully polished. Several sections are under active development with minimal working examples implemented as placeholders. Continuous synthesis and refinement are ongoing.
  </p>
</div>
<!--- DISCLAIMER BANNER END --->


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
<!-- [![R-CMD-check](https://github.com/selvastics/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/selvastics/inrep/actions) -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
 [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16682020.svg)](https://doi.org/10.5281/zenodo.16682020)
<!-- badges: end -->

## Overview

**inrep** provides Shiny-based test administration, adaptive item selection, and reporting, with TAM integration for psychometric estimation. It supports adaptive and fixed questionnaires, session recovery, and export to common formats (CSV, JSON, SPSS, PDF). Themes and multilingual labels allow UI customization for different deployments.

<!-- Demo: See the package in action! -->
![inrep demo](man/figures/inrep_previewer.gif)

> **Demo:** The video shows adaptive setup, Shiny administration, UI customization, and reporting.

### Key features


- Adaptive and fixed testing; IRT models (1PL, 2PL, 3PL, GRM); stopping rules and item-selection criteria.
- Shiny-based administration; theme system; multilingual labels (EN, DE, ES, FR).
- TAM integration for IRT estimation in adaptive mode; reporting and validation tools; export to CSV/JSON/SPSS/PDF.
- Branching, randomization, piping, quotas, and participant management.
- Session recovery and logging; input validation and basic rate limiting; caching and parallel compute options; accessibility support.

## Installation

### Development Version

```r
# Install from GitHub (clean installation with dependency management)
devtools::install_github("selvastics/inrep", ref = "main", force = TRUE)

# Load the package
library(inrep)
```

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
  theme = "Professional"
)

# Launch the study
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

# Launch the study
launch_study(config_fixed, bfi_items)
```

### Example Cognitive Ability Study with 2PL IRT model — Fully Specified

```r


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

# Create a detailed configuration
advanced_config <- create_study_config(
  name = "Cognitive Ability Assessment",
  model = "2PL",
  estimation_method = "TAM", 
  adaptive = TRUE,
  criteria = "MI",
  min_items = 8,  
  max_items = 15,  
  min_SEM = 0.35,  
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
  parallel_computation = FALSE,  # Disable for stability with small item bank
  cache_enabled = FALSE,  # Disable for stability
  # Enable comprehensive reporting with multiple plots
  participant_report = list(
    show_theta_plot = TRUE,          # Ability progression plot
    show_response_table = TRUE,      # Detailed response table
    show_item_difficulty_trend = TRUE,  # Item difficulty vs ability plot
    show_domain_breakdown = TRUE,    # Domain performance breakdown
    show_recommendations = TRUE     # Performance recommendations
  )
)

# Launch the study
launch_study(
  config = advanced_config,
  item_bank = cognitive_items
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

* **Study management:** `launch_study()`, `create_study_config()`
* **IRT analysis:** `estimate_ability()`, `select_next_item()`, `validate_item_bank()`
* **Extensions:** `scrape_website_ui()`, `enable_llm_assistance()`

## Example Datasets

* `bfi_items`
* `math_items`
* `cognitive_items`

## Configuration

* Stopping Rules
* Item Selection Criteria
* Themes and Languages
* Session Management

## Contributing

See `CONTRIBUTING.md` on GitHub.

## License

MIT License

## Support

**Author:** Clievins Selva
**Affiliation:** University of Hildesheim
**Contact:** [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)

