#' RCQ Items: German Resilience and Coping Item Banks (Uncalibrated)
#'
#' @description
#' German items of the Resilience and Coping Questionnaire (RCQ), an
#' instrument under development (see \code{case_studies/rcq}). The item texts
#' are the content of these data sets. The columns \code{a} and \code{b1} to
#' \code{b4} are placeholders, not calibrated parameters: in \code{rcq_old_items}
#' they were set by hand, in \code{rcqL_old_items} they look like random draws.
#' Do not use them for adaptive testing or scoring.
#'
#' @format Four data frames, each with 7 columns:
#' \describe{
#'   \item{\code{rcq_old_items}}{30 rows: RCQ items (RCQ_01 and RCQ_02).}
#'   \item{\code{rcqL_old_items}}{68 rows: long version (RCQ-L).}
#'   \item{\code{rcq_items}}{30 rows: identical copy of \code{rcq_old_items}.}
#'   \item{\code{rcqL_items}}{68 rows: identical copy of \code{rcqL_old_items}.}
#' }
#'
#' @details
#' Columns:
#' \describe{
#'   \item{\code{Question}}{Item text in German}
#'   \item{\code{ResponseCategories}}{"1,2,3,4,5,6,7" (seven-point scale)}
#'   \item{\code{a}}{Placeholder discrimination value}
#'   \item{\code{b1}, \code{b2}, \code{b3}, \code{b4}}{Placeholder threshold values}
#' }
#' The items have seven response categories, but a graded response model for
#' seven categories needs six thresholds. With only \code{b1} to \code{b4},
#' \code{\link{estimate_ability}} treats the items as having five categories
#' and skips responses 6 and 7. The banks are therefore only suitable for
#' non-adaptive (fixed-form) administration.
#'
#' @source Item texts: RCQ development project (see \code{case_studies/rcq}).
#'   Parameter columns: placeholders.
#'
#' @keywords datasets
#' @name rcq_items_data
#' @docType data
#'
#' @examples
#' \dontrun{
#' data(rcq_old_items)
#' str(rcq_old_items)
#'
#' # Fixed-form administration
#' rcq_config <- create_study_config(
#'   name = "RCQ - Resilienz und Coping Fragebogen",
#'   adaptive = FALSE,
#'   max_items = 30,
#'   demographics = c("Alter", "Geschlecht"),
#'   language = "de"
#' )
#' # launch_study(rcq_config, item_bank = rcq_old_items)
#' }
NULL

#' @rdname rcq_items_data
#' @name rcq_old_items
#' @format Data frame with 30 rows and 7 columns
NULL

#' @rdname rcq_items_data
#' @name rcqL_old_items
#' @format Data frame with 68 rows and 7 columns
NULL

#' @rdname rcq_items_data
#' @name rcq_items
#' @format Data frame with 30 rows and 7 columns
NULL

#' @rdname rcq_items_data
#' @name rcqL_items
#' @format Data frame with 68 rows and 7 columns
NULL
