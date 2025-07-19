#' inrep: Instant Report for Adaptive Assessments
#'
#' @description
#' The \code{inrep} package provides a comprehensive workflow framework for adaptive
#' assessments that serves as a sophisticated wrapper around the TAM package for all
#' psychometric computations. \code{inrep} integrates TAM's validated Item Response
#' Theory implementations with modern interface technologies, LLM assistance capabilities,
#' and website theme scraping to create seamless research workflows from data collection 
#' through analysis and reporting.
#'
#' @details
#' \strong{Psychometric Foundation:} All statistical computations are performed exclusively by
#' the TAM package (Robitzsch et al., 2020), ensuring methodological rigor and reproducibility:
#' \itemize{
#'   \item IRT model fitting: Uses TAM's \code{\link[TAM]{tam.mml}} family of functions
#'   \item Ability estimation: Leverages TAM's \code{\link[TAM]{tam.wle}} and \code{\link[TAM]{tam.eap}} procedures
#'   \item Information calculations: Based on TAM's \code{\link[TAM]{IRT.informationCurves}} implementations
#'   \item Model diagnostics: Utilizes TAM's \code{\link[TAM]{tam.fit}} and diagnostic tools
#'   \item Parameter estimation: Employs TAM's maximum likelihood and Bayesian procedures
#' }
#' 
#' \strong{Framework Architecture:} \code{inrep} provides comprehensive integration capabilities:
#' \itemize{
#'   \item Workflow orchestration and session management
#'   \item Interactive Shiny-based assessment interfaces with modern UI components
#'   \item Real-time data collection with quality monitoring and validation
#'   \item Bidirectional integration between user interfaces and TAM functions
#'   \item LLM integration for enhanced user assistance and study configuration
#'   \item Website theme scraping for automatic institutional branding
#'   \item Enterprise-grade logging, audit trails, and result management
#'   \item Cloud storage integration with secure authentication
#'   \item Multi-format export capabilities (RDS, CSV, JSON, PDF)
#' }
#' 
#' \strong{Modular Design Philosophy:} The package operates on a clear separation of concerns:
#' \itemize{
#'   \item \strong{TAM}: Handles all psychometric modeling and statistical computations
#'   \item \strong{inrep Core}: Manages workflow, interfaces, and integration layer
#'   \item \strong{UI Modules}: Provide specialized interface components (themes, accessibility)
#'   \item \strong{Utility Modules}: Handle logging, validation, session management
#'   \item \strong{Integration Layer}: Coordinates all components under unified research philosophy
#' }
#' 
#' \strong{Supported IRT Models:} Through TAM integration:
#' \itemize{
#'   \item \strong{1PL/Rasch Model}: Equal discrimination parameters, TAM's \code{tam.mml}
#'   \item \strong{2PL Model}: Item-specific discrimination, TAM's \code{tam.mml.2pl}
#'   \item \strong{3PL Model}: Includes guessing parameters, TAM's \code{tam.mml.3pl}
#'   \item \strong{GRM}: Graded Response Model for polytomous items, TAM's \code{tam.mml}
#'   \item \strong{Multidimensional Extensions}: Advanced models via TAM's multidimensional capabilities
#' }
#' 
#' \strong{Key Features:}
#' \itemize{
#'   \item \strong{Adaptive Testing}: Maximum Information and alternative selection algorithms
#'   \item \strong{Real-time Estimation}: Continuous ability updates using TAM procedures
#'   \item \strong{Quality Monitoring}: Response pattern analysis and engagement tracking
#'   \item \strong{Multilingual Support}: Interface localization for international research
#'   \item \strong{Accessibility Compliance}: WCAG 2.1 AA standards with screen reader support
#'   \item \strong{Theme System}: Professional UI themes with customization capabilities
#'   \item \strong{Session Management}: Save/restore functionality for interrupted assessments
#'   \item \strong{Enterprise Features}: Security, audit logging, and scalability options
#' }
#' 
#' \strong{Research Applications:}
#' \itemize{
#'   \item Educational assessment and placement testing
#'   \item Clinical and personality assessment
#'   \item Organizational psychology and selection
#'   \item Psychometric research and validation studies
#'   \item Cross-cultural and multilingual studies
#'   \item Large-scale assessment programs
#' }
#' 
#' \strong{Technical Standards:}
#' \itemize{
#'   \item Follows Standards for Educational and Psychological Testing (AERA, APA, NCME, 2014)
#'   \item Implements International Test Commission Guidelines for Computer-Based Testing
#'   \item Supports institutional IRB requirements with built-in consent frameworks
#'   \item Provides GDPR-compliant data handling with participant privacy protection
#'   \item Maintains comprehensive audit trails for research integrity
#' }
#'
#' @section Getting Started:
#' \preformatted{
#' # Install required dependencies
#' install.packages(c("TAM", "shiny", "DT", "ggplot2", "logr"))
#' 
#' # Load sample data and create basic assessment
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create study configuration
#' config <- create_study_config(
#'   name = "Personality Assessment",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.3
#' )
#' 
#' # Launch assessment (requires Shiny environment)
#' launch_study(config, bfi_items)
#' }
#' 
#' @section Comprehensive Documentation:
#' For detailed usage examples and advanced features, see:
#' \itemize{
#'   \item \code{vignette("getting-started", package = "inrep")}
#'   \item \code{vignette("enhanced-features-comprehensive", package = "inrep")}
#'   \item \code{vignette("research-workflows", package = "inrep")}
#'   \item \code{vignette("clinical-assessment", package = "inrep")}
#'   \item \code{vignette("educational-assessment", package = "inrep")}
#' }
#' 
#' @references
#' \itemize{
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item Chang, W., Cheng, J., Allaire, J., Xie, Y., & McPherson, J. (2021). 
#'     \emph{shiny: Web Application Framework for R}. R package version 1.6.0. 
#'     \url{https://CRAN.R-project.org/package=shiny}
#'   \item American Educational Research Association, American Psychological Association, 
#'     & National Council on Measurement in Education. (2014). 
#'     \emph{Standards for educational and psychological testing}. American Educational Research Association.
#'   \item van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). 
#'     \emph{Elements of adaptive testing}. Springer.
#'   \item Embretson, S. E., & Reise, S. P. (2000). 
#'     \emph{Item response theory for psychologists}. Lawrence Erlbaum Associates.
#' }
#'
#' @author
#' inrep Development Team
#' 
#' Maintainer: Package Maintainer <maintainer@example.com>
#' 
#' @name inrep-package
#' @aliases inrep
#' @keywords internal
"_PACKAGE"