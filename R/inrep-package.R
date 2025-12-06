#' inrep: Instant Reports for Adaptive Assessments
#'
#' @description
#' **inrep** is an R package for psychological assessment. 
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{\strong{inrep-studio}} provides a Shiny interface to simplify the creation of inrep surveys, as no code needs to be written to configure the study.
#' Functionalities of this package include, prompt assistance, session management, and 
#' psychometric capabilities. Built with modern R development practices 
#' and best practices for external consultation, it provides researchers and 
#' practitioners with a secure and user-friendly platform for creating, 
#' deploying, and analyzing psychological assessments.
#'
#' @section Key Features:
#'
#'
#' **Session Management**
#' - Data Persistence: Automatic saving and recovery of participant responses and session state
#' - Keep-Alive Mechanisms: Prevents session timeouts during long assessments
#' - Error Recovery: Graceful handling of network issues and system interruptions
#' - Secure Data Handling: Built-in security measures for sensitive participant data
#'
#' **Psychometric Capabilities**
#' - Multiple IRT Models: Support for GRM, PCM, and other item response theory models
#' - Adaptive Testing: Item selection and ability estimation
#' - Item Bank Optimization: Tools for improving item quality and measurement precision
#' - Validation: Built-in psychometric validation and quality assessment
#'
#' **User Experience**
#' - Responsive Design: Works seamlessly across desktop, tablet, and mobile devices
#' - Accessibility First: WCAG 2.1 AA compliance and inclusive design principles
#' - Intuitive Interface: Clean, modern UI that reduces participant anxiety and improves completion rates
#' - Real-Time Feedback: Immediate progress indicators and support throughout the assessment
#'
#' @section Consultation Assistance:
#'
#' The package includes a basic consultation assistance system that implements 
#' best practices for prompt generation:
#'
#' - **`enable_llm_assistance()`**: Enable and configure the consultation assistance system
#'
#' @section Robust Session Management:
#'
#' Built-in robust session handling ensures data integrity and participant experience:
#'
#' - **`session_save`**: Enable session persistence and recovery
#' - **`resume_session()`**: Resume interrupted assessment sessions seamlessly
#'
#' @section Core Assessment Functions:
#'
#' - **`launch_study()`**: Launch interactive adaptive assessments with full LLM assistance
#' - **`create_study_config()`**: Create comprehensive study configurations
#' - **`estimate_ability()`**: Advanced ability estimation with multiple algorithms
#' - **`select_next_item()`**: Intelligent item selection for adaptive testing
#' - **`validate_item_bank()`**: Comprehensive item bank validation and quality assessment
#'
#' @section Case Studies and Examples:
#'
#' The package includes case studies demonstrating the consultation assistance system:
#'
#' - **`enable_llm_assistance()`**: Enable and configure the consultation assistance system
#'
#' @section Quick Start:
#'
#' ```r
#' # Enable consultation assistance
#' enable_llm_assistance(
#'   enable = TRUE,
#'   enhanced_mode = TRUE,
#'   complexity_level = "intermediate"
#' )
#'
#' # Get LLM guidance for study design
#' enable_llm_assistance(enable = TRUE, enhanced_mode = TRUE)
#'
#' # Launch a study with robust session management
#' config <- create_study_config(name = "My Study", model = "GRM")
#' launch_study(config, bfi_items, session_save = TRUE)
#' ```
#'
#' @section Advanced Usage:
#'
#' ```r
#' # Enable consultation assistance with expert complexity
#' enable_llm_assistance(
#'   enable = TRUE,
#'   enhanced_mode = TRUE,
#'   complexity_level = "expert"
#' )
#'
#' # Create a comprehensive study configuration
#' config <- create_study_config(
#'   name = "Advanced Study",
#'   model = "GRM",
#'   max_items = 20,
#'   min_SEM = 0.25,
#'   session_save = TRUE,
#'   theme = "Professional"
#' )
#' ```
#'
#' @section Configuration:
#'
#' ```r
#' # Configure consultation assistance
#' enable_llm_assistance(
#'   enable = TRUE,
#'   enhanced_mode = TRUE,
#'   complexity_level = "expert"
#' )
#'
#' # Launch a study with robust session management
#' config <- create_study_config(
#'   name = "My Study", 
#'   model = "GRM",
#'   session_save = TRUE
#' )
#' ```
#'
#' @section Architecture:
#'
#' The package is built with a modular architecture that separates concerns and ensures maintainability:
#'
#' ```
#' inrep/
#' ├── R/                          # Core R functions
#' │   ├── enhanced_llm_assistance.R    # LLM assistance system
#' │   ├── robust_session_management.R  # Session handling
#' │   ├── robust_error_handling.R      # Error management
#' │   ├── item_selection.R             # Item selection algorithms
#' │   ├── estimate_ability.R           # Ability estimation
#' │   └── ...                         # Additional modules
#' ├── inst/                       # Package resources
#' │   ├── case_studies/           # Example implementations
#' │   └── examples/               # Usage examples
#' └── tests/                      # Comprehensive testing
#' ```
#'
#' @section Data:
#'
#' Built-in datasets for testing and development:
#'
#' - **`bfi_items`**: Big Five Inventory personality assessment items
#' - **`math_items`**: Mathematics assessment items for cognitive testing
#' - **`cognitive_items`**: Cognitive ability assessment items
#' - **`rcq_old_items`**: RCQ resilience and coping items (30 items, original version)
#' - **`rcqL_old_items`**: RCQL long-form resilience and coping items (68 items)
#' - **`rcq_items`**: Copy of rcq_old_items for user customization
#' - **`rcqL_items`**: Copy of rcqL_old_items for user customization
#'
#' @section Quality Assurance:
#'
#' - Comprehensive testing with testthat
#' - R-CMD-check compliance
#' - CRAN submission ready
#' - Professional code quality standards
#'
#' @section Contributing:
#'
#' We welcome contributions! Please see our Contributing Guidelines for details on:
#' - Code style and standards
#' - Testing requirements
#' - Pull request process
#' - Issue reporting
#'
#' @section Support:
#'
#' - **GitHub Issues**: [https://github.com/selvastics/inrep/issues](https://github.com/selvastics/inrep/issues)
#' - **Discussions**: [https://github.com/selvastics/inrep/discussions](https://github.com/selvastics/inrep/discussions)
#' - **Documentation**: [https://selvastics.github.io/inrep/](https://selvastics.github.io/inrep/)
#'
#' @section License:
#'
#' This project is licensed under the a custom License (Non-Commercial use only) - see the LICENSE file for details.

#' @author Clievins Selva <selva@uni-hildesheim.de>
#' @keywords package
#' @seealso
#' \code{\link{enable_llm_assistance}}, \code{\link{launch_study}}, 
#' \code{\link{create_study_config}}, \code{\link{estimate_ability}}, 
#' \code{\link{validate_item_bank}}
#'
#' @keywords internal
"_PACKAGE"
