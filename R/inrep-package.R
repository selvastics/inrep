#' inrep: Instant Reports for Adaptive Assessments
#'
#' @description
#' \strong{inrep} is an R package for building and running assessments with a web UI via
#' \pkg{shiny}. It provides helpers to define study configuration, run fixed or adaptive
#' workflows, render pages (instructions, demographics, items, results), and export results.
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{\strong{inrep-studio}} is a separate
#' Shiny app that can generate \strong{inrep} configuration code.
#'
#' @section Capabilities:
#' \itemize{
#'   \item Study configuration and UI: \code{create_study_config()}, \code{launch_study()}
#'   \item Fixed and adaptive workflows: \code{estimate_ability()}, \code{select_next_item()}
#'   \item Item bank checks: \code{validate_item_bank()}
#'   \item Optional session persistence: \code{session_save}, \code{resume_session()}
#' }
#'
#' @section Interactive Configuration (inrep-studio):
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{inrep-studio} is an interactive
#' Shiny app for building study configurations via a GUI. It generates ready-to-run
#' \code{inrep} R code. This replaces the earlier LLM prompt generation workflow
#' (\code{enable_llm_assistance()} and \code{generate_llm_prompt()}), which is now
#' soft-deprecated.
#'
#' @section Core Assessment Functions:
#'
#' \itemize{
#'   \item \code{launch_study()}: Run an assessment
#'   \item \code{create_study_config()}: Create a study configuration
#'   \item \code{estimate_ability()}: Ability estimation
#'   \item \code{select_next_item()}: Item selection
#'   \item \code{validate_item_bank()}: Item bank checks
#' }
#'
#' @section Quick Start:
#'
#' \preformatted{
#' # Launch a study
#' config <- create_study_config(name = "My Study", model = "GRM")
#' launch_study(config, bfi_items, session_save = TRUE)
#' }
#' @section Data:
#'
#' Built-in example item banks:
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
#' @section Support:
#'
#' \itemize{
#'   \item \strong{GitHub Issues}: \url{https://github.com/selvastics/inrep/issues}
#'   \item \strong{Repository}: \url{https://github.com/selvastics/inrep}
#' }
#'
#' @section License:
#'
#' This project is licensed under the MIT License.

#' @author Clievins Selva <selva@uni-hildesheim.de>
#' @keywords package
#' @seealso
#' \code{\link{launch_study}}, \code{\link{create_study_config}},
#' \code{\link{estimate_ability}}, \code{\link{validate_item_bank}}
#' @importFrom shiny HTML radioButtons req sliderInput textInput
#' @importFrom stats dnorm na.omit rnorm runif sd setNames
#' @importFrom utils install.packages str tail write.csv
#'
#' @keywords internal
"_PACKAGE"
