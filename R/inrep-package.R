#' inrep: Instant Reports for Adaptive Assessments
#'
#' @description
#' \strong{inrep} is an R package for psychological assessment. 
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{\strong{inrep-studio}} provides a Shiny interface to simplify the creation of inrep surveys, as no code needs to be written to configure the study.
#' Functionalities of this package include prompt assistance, session management, and 
#' psychometric capabilities. Built with modern R development practices 
#' and best practices for external consultation, it provides researchers and 
#' practitioners with a secure and user-friendly platform for creating, 
#' deploying, and analyzing psychological assessments.
#'
#' @section Key Features:
#'
#' \strong{Session Management}
#' \itemize{
#'   \item Data Persistence: Automatic saving and recovery of participant responses and session state
#'   \item Keep-Alive Mechanisms: Prevents session timeouts during long assessments
#'   \item Error Recovery: Graceful handling of network issues and system interruptions
#'   \item Secure Data Handling: Built-in security measures for sensitive participant data
#' }
#'
#' \strong{Psychometric Capabilities}
#' \itemize{
#'   \item Multiple IRT Models: Support for GRM, PCM, and other item response theory models
#'   \item Adaptive Testing: Item selection and ability estimation
#'   \item Item Bank Optimization: Tools for improving item quality and measurement precision
#'   \item Validation: Built-in psychometric validation and quality assessment
#' }
#'
#' \strong{User Experience}
#' \itemize{
#'   \item Responsive Design: Works seamlessly across desktop, tablet, and mobile devices
#'   \item Accessibility First: WCAG 2.1 AA compliance and inclusive design principles
#'   \item Intuitive Interface: Clean, modern UI that reduces participant anxiety and improves completion rates
#'   \item Real-Time Feedback: Immediate progress indicators and support throughout the assessment
#' }
#'
#' @section Consultation Assistance:
#'
#' The package includes a basic consultation assistance system that implements 
#' best practices for prompt generation:
#'
#' \itemize{
#'   \item \code{enable_llm_assistance()}: Enable and configure the consultation assistance system
#' }
#'
#' @section Robust Session Management:
#'
#' Built-in robust session handling ensures data integrity and participant experience:
#'
#' \itemize{
#'   \item \code{session_save}: Enable session persistence and recovery
#'   \item \code{resume_session()}: Resume interrupted assessment sessions seamlessly
#' }
#'
#' @section Core Assessment Functions:
#'
#' \itemize{
#'   \item \code{launch_study()}: Launch interactive adaptive assessments with full LLM assistance
#'   \item \code{create_study_config()}: Create comprehensive study configurations
#'   \item \code{estimate_ability()}: Advanced ability estimation with multiple algorithms
#'   \item \code{select_next_item()}: Intelligent item selection for adaptive testing
#'   \item \code{validate_item_bank()}: Comprehensive item bank validation and quality assessment
#' }
#'
#' @section Case Studies and Examples:
#'
#' The package includes case studies demonstrating practical applications:
#'
#' \itemize{
#'   \item \code{enable_llm_assistance()}: Enable and configure the consultation assistance system
#' }
#'
#' @section Quick Start:
#'
#' \preformatted{
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
#' }
#'
#' @section Advanced Usage:
#'
#' \preformatted{
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
#' }
#'
#' @section Configuration:
#'
#' \preformatted{
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
#' }
#'
#' @section Architecture:
#'
#' The package is built with a modular architecture that separates concerns and ensures maintainability:
#'
#' \preformatted{
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
#' }
#'
#' @section Data:
#'
#' Built-in datasets for testing and development:
#'
#' \itemize{
#'   \item \code{bfi_items}: Big Five Inventory personality assessment items
#'   \item \code{math_items}: Mathematics assessment items for cognitive testing
#'   \item \code{cognitive_items}: Cognitive ability assessment items
#'   \item \code{rcq_old_items}: RCQ resilience and coping items (30 items, original version)
#'   \item \code{rcqL_old_items}: RCQL long-form resilience and coping items (68 items)
#'   \item \code{rcq_items}: Copy of rcq_old_items for user customization
#'   \item \code{rcqL_items}: Copy of rcqL_old_items for user customization
#' }
#'
#' @section Quality Assurance:
#'
#' \itemize{
#'   \item Comprehensive testing with testthat
#'   \item R-CMD-check compliance
#'   \item CRAN submission ready
#'   \item Professional code quality standards
#' }
#'
#' @section Contributing:
#'
#' We welcome contributions! Please see our Contributing Guidelines for details on:
#' \itemize{
#'   \item Code style and standards
#'   \item Testing requirements
#'   \item Pull request process
#'   \item Issue reporting
#' }
#'
#' @section Support:
#'
#' \itemize{
#'   \item \strong{GitHub Issues}: \url{https://github.com/selvastics/inrep/issues}
#'   \item \strong{Discussions}: \url{https://github.com/selvastics/inrep/discussions}
#'   \item \strong{Documentation}: \url{https://selvastics.github.io/inrep/}
#' }
#'
#' @section License:
#'
#' This project is licensed under a custom License (Non-Commercial use only) - see the LICENSE file for details.

#' @author Clievins Selva <selva@uni-hildesheim.de>
#' @keywords package
#' @seealso
#' \code{\link{enable_llm_assistance}}, \code{\link{launch_study}}, 
#' \code{\link{create_study_config}}, \code{\link{estimate_ability}}, 
#' \code{\link{validate_item_bank}}
#'
#' @keywords internal
"_PACKAGE"
