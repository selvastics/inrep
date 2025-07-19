# inrep 1.0.0

## New Features

* Initial CRAN release of inrep package
* Comprehensive adaptive testing framework using Item Response Theory (IRT)
* Support for multiple IRT models: 1PL, 2PL, 3PL, and Graded Response Model (GRM)
* TAM integration for all psychometric computations
* Web-based interface using Shiny for test administration
* Adaptive item selection algorithms for efficient testing
* Multi-language support (English, German, Spanish, French)
* Customizable themes with accessibility compliance
* Session management with pause and resume capabilities
* Comprehensive reporting and data export functionality
* Validation tools for item banks and study configurations

## Data

* `bfi_items`: Big Five Inventory personality assessment items with validated parameters

## Documentation

* Complete function documentation with examples
* Comprehensive vignettes covering basic usage, customization, and research workflows
* Getting started guide for new users
* Professional package structure ready for CRAN submission

## Functions

### Core Assessment Functions
* `create_study_config()`: Configure adaptive testing studies
* `launch_study()`: Launch interactive assessments
* `estimate_ability()`: TAM-based ability estimation
* `select_next_item()`: Adaptive item selection algorithms

### Item Bank Management
* `validate_item_bank()`: Comprehensive item bank validation
* `initialize_unknown_parameters()`: Handle unknown parameters
* `detect_unknown_parameters()`: Analyze parameter patterns
* `create_unknown_parameter_template()`: Generate calibration templates

### Advanced Customization
* `create_advanced_study_config()`: Unlimited study customization
* `create_custom_page()`: Custom page templates
* `create_demographic_section()`: Advanced demographics
* `validate_advanced_config()`: Configuration validation

### Utility Functions
* `session_utils()`: Session management utilities
* `theme_functions()`: UI theme management
* `response_validation()`: Response validation systems

## Documentation

* Comprehensive function documentation with examples
* Four detailed vignettes covering package usage
* Professional README with installation and quick start
* Complete citation information for academic use

## Dependencies

* Core: TAM (>= 4.2-21), shiny (>= 1.7.0), DT, uuid, jsonlite
* Suggested: mirt (>= 1.35), testthat (>= 3.0.0), knitr, rmarkdown

## Compliance

* CRAN policy compliant
* Full R CMD check passing
* Comprehensive test coverage
* Cross-platform compatibility (Windows, Linux, macOS)
* Professional documentation standards
