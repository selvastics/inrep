#' RCQ Items Data - Resilience and Coping Questionnaire Item Banks
#'
#' @description
#' Comprehensive item banks for resilience and coping assessments in German language.
#' Contains multiple versions of RCQ items for different assessment needs, all calibrated
#' for use with Item Response Theory (IRT) models, particularly the Graded Response Model (GRM).
#'
#' @format Multiple data frames with varying dimensions:
#' \describe{
#'   \item{\code{rcq_old_items}}{Data frame with 30 rows and 6 columns - Original RCQ items (RCQ_01 + RCQ_02)}
#'   \item{\code{rcqL_old_items}}{Data frame with 68 rows and 6 columns - Long version RCQL items}
#'   \item{\code{rcq_items}}{Data frame with 30 rows and 6 columns - Copy of rcq_old_items (for user revision)}
#'   \item{\code{rcqL_items}}{Data frame with 68 rows and 6 columns - Copy of rcqL_old_items (for user revision)}
#' }
#'
#' @details
#' Each data frame contains the following columns:
#' \describe{
#'   \item{\code{Question}}{Character. The assessment question in German}
#'   \item{\code{ResponseCategories}}{Character. Response scale (1-7 for RCQ items)}
#'   \item{\code{a}}{Numeric. Discrimination parameter for GRM model}
#'   \item{\code{b1}}{Numeric. First threshold parameter (1|2 boundary)}
#'   \item{\code{b2}}{Numeric. Second threshold parameter (2|3 boundary)}
#'   \item{\code{b3}}{Numeric. Third threshold parameter (3|4 boundary)}
#'   \item{\code{b4}}{Numeric. Fourth threshold parameter (4|5 boundary)}
#' }
#'
#' @source
#' Based on resilience and coping research literature, adapted for German-speaking populations.
#' NOTE: Items properties are not yet calibrated for accurate measurement in adaptive testing contexts.
#'
#' @keywords datasets resilience coping German IRT GRM
#' @name rcq_items_data
#' @usage data(rcq_old_items); data(rcqL_old_items); data(rcq_items); data(rcqL_items)
#'
#' @examples
#' \dontrun{
#' # Load the item banks
#' data(rcq_old_items)
#' data(rcqL_old_items)
#'
#' # Examine structure
#' str(rcq_old_items)
#' head(rcq_old_items, 3)
#'
#' # Check calibration quality
#' summary(rcq_old_items$a)
#' hist(rcq_old_items$a, main = "Distribution of Discrimination Parameters")
#'
#' # Validate for GRM model
#' validation <- validate_item_bank(rcq_old_items, model = "GRM")
#' cat("RCQ items valid for GRM:", validation, "\n")
#'
#' # Create assessment configuration
#' rcq_config <- create_study_config(
#'   name = "RCQ - Resilienz und Coping Fragebogen",
#'   model = "GRM",
#'   max_items = 20,
#'   min_items = 10,
#'   demographics = c("alter", "geschlecht", "bildung"),
#'   language = "de",
#'   theme = "light"
#' )
#'
#' # Launch assessment (requires Shiny environment)
#' # launch_study(rcq_config, item_bank = rcq_old_items)
#' }
NULL

#' @rdname rcq_items_data
#' @format Data frame with 30 rows and 6 columns
"rcq_old_items"

#' @rdname rcq_items_data
#' @format Data frame with 68 rows and 6 columns
"rcqL_old_items"

#' @rdname rcq_items_data
#' @format Data frame with 30 rows and 6 columns
"rcq_items"

#' @rdname rcq_items_data
#' @format Data frame with 68 rows and 6 columns
"rcqL_items"



