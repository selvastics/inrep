# inrep: Instant Reports for Adaptive Assessments

[![R-CMD-check](https://github.com/selvastics/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/selvastics/inrep/actions)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.16682020.svg)](https://doi.org/10.5281/zenodo.16682020)

## Overview

**inrep** is a comprehensive, production-ready framework for adaptive testing using Item Response Theory (IRT) models. Designed for psychological assessments, educational testing, and survey research, inrep provides a complete solution from study design to result analysis with enterprise-grade features.

### Key Features

- **Multiple IRT Models**: Full support for 1PL, 2PL, 3PL, and Graded Response Model (GRM)
- **TAM Integration**: All psychometric computations performed by the validated TAM package
- **Web-based Interface**: Modern Shiny applications with responsive design and accessibility compliance
- **Adaptive Testing**: Sophisticated item selection algorithms (Maximum Information, Weighted, Random)
- **Real-time Monitoring**: Live progress tracking, ability estimation, and quality control
- **Cloud Integration**: Automatic backup to WebDAV-compatible storage systems
- **Multilingual Support**: Interface available in English, German, Spanish, and French
- **Professional Reporting**: Multiple export formats with detailed analytics and visualizations
- **Session Management**: Robust session handling with resume capabilities
- **Accessibility Compliance**: WCAG 2.1 compliant with screen reader support

## Quick Start

### Installation

```r
# Install from GitHub (development version)
devtools::install_github("selvastics/inrep")

# Load the package
library(inrep)
```

### Basic Example

```r
# Load built-in personality assessment data
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

# Launch the adaptive assessment
launch_study(config, bfi_items)
```

### Advanced Example

```r
# Advanced cognitive assessment with full features
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

# Launch with cloud backup and monitoring
launch_study(
  config = advanced_config,
  item_bank = cognitive_items,
  webdav_url = "https://your-institution.edu/webdav/studies/",
  password = Sys.getenv("WEBDAV_PASSWORD"),
  accessibility = TRUE,
  admin_dashboard_hook = function(session_data) {
    cat("Participant ID:", session_data$participant_id, "\n")
    cat("Progress:", session_data$progress, "%\n")
    cat("Current theta:", round(session_data$theta, 3), "\n")
    cat("Standard error:", round(session_data$se, 3), "\n")
  }
)
```

## Core Functions

### Study Configuration
- `create_study_config()`: Configure adaptive testing studies with comprehensive options
- `validate_item_bank()`: Validate item banks for TAM compatibility
- `simulate_item_bank()`: Generate simulated item banks for testing

### Assessment Execution
- `launch_study()`: Launch interactive adaptive assessments
- `estimate_ability()`: TAM-based ability estimation
- `select_next_item()`: Adaptive item selection algorithms

### Advanced Features
- `enable_llm_assistance()`: LLM-powered study configuration and optimization
- `scrape_website_ui()`: Extract themes from institutional websites
- `launch_theme_editor()`: Interactive theme customization

### Utility Functions
- `inrep_code()`: Generate standalone R scripts for deployment
- `resume_session()`: Resume interrupted assessment sessions
- `validate_response_mapping()`: Validate response data structure

## Documentation

### Vignettes
- `vignette("getting-started", package = "inrep")`: Complete beginner's guide
- `vignette("psychological-study-example", package = "inrep")`: Real-world example
- `vignette("advanced-examples", package = "inrep")`: Advanced usage patterns
- `vignette("complete-tam-examples", package = "inrep")`: TAM integration examples

### Function Documentation
All functions include comprehensive documentation with examples, parameter descriptions, and usage guidelines.

## Data

### Built-in Datasets
- `bfi_items`: Big Five Inventory personality assessment items with validated parameters
- `math_items`: Mathematics assessment items for cognitive testing
- `cognitive_items`: Cognitive ability assessment items

### Data Structure
Item banks follow TAM package specifications with required columns varying by IRT model:

```r
# Example item bank structure for GRM
head(bfi_items)
#   Question    a    b1    b2    b3    b4 ResponseCategories
# 1 "I am..." 1.2 -2.1 -0.8  0.5  1.8              "1,2,3,4,5"
# 2 "I tend..." 0.9 -1.5 -0.3  0.8  2.1              "1,2,3,4,5"
```

## Configuration Options

### IRT Models
- **1PL/Rasch**: Equal discrimination parameters
- **2PL**: Variable discrimination parameters
- **3PL**: Includes guessing parameters
- **GRM**: Graded response model for polytomous items

### Stopping Rules
- Minimum standard error threshold
- Maximum/minimum item counts
- Custom stopping functions

### Item Selection Criteria
- Maximum Information (MI)
- Weighted Information
- Random selection
- Maximum Fisher Information (MFI)

### Themes and Languages
- Built-in themes: Professional, Light, Midnight, Sunset, Forest, Ocean, Berry
- Custom theme support with CSS variables
- Multilingual interface (EN, DE, ES, FR)

## Quality Assurance

### Validation
- Comprehensive item bank validation
- Response pattern analysis
- Real-time quality monitoring
- Automatic flagging of suspicious responses

### Performance
- Parallel computation support
- Caching for item information calculations
- Memory management optimizations
- Scalability for large-scale deployments

### Security
- Secure session management
- Data encryption for cloud storage
- GDPR/DSGVO compliance
- Audit trail logging

## Deployment

### Local Deployment
```r
# Generate standalone script
inrep_code(
  launch_study(config, item_bank),
  output_file = "my_assessment.R",
  auto_run = TRUE
)
```

### Cloud Deployment
```r
# Deploy with cloud backup
launch_study(
  config, 
  item_bank,
  webdav_url = "https://your-cloud-storage.com/studies/",
  password = Sys.getenv("WEBDAV_PASSWORD")
)
```

### Enterprise Integration
- WebDAV-compatible cloud storage
- REST API support for external systems
- Database integration capabilities
- Load balancing support

## Contributing

We welcome contributions! Please see `CONTRIBUTING.md` for guidelines.

### Development Setup
```r
# Clone the repository
git clone https://github.com/selvastics/inrep.git
cd inrep

# Install dependencies
devtools::install_deps()

# Run tests
devtools::test()

# Build documentation
devtools::document()
```

## Support

- **GitHub Issues**: [https://github.com/selvastics/inrep/issues](https://github.com/selvastics/inrep/issues)
- **Email**: [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)
- **Documentation**: [https://selvastics.github.io/inrep/](https://selvastics.github.io/inrep/)

## Citation

```r
citation("inrep")
```

## License

MIT License - see `LICENSE` file for details.

## Acknowledgments

Special thanks to Alla Sawatzky and Kathrin Schütz for their early endorsement and guidance during the conceptualization phase.

---

**Author:** Clievins Selva  
**Affiliation:** University of Hildesheim  
**Contact:** [selva@uni-hildesheim.de](mailto:selva@uni-hildesheim.de)

