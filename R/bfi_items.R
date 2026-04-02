#' Big Five Inventory Item Bank
#'
#' @description
#' A simulated example item bank with item text, response options, and GRM-style
#' item parameters. Used in \code{inrep} examples and vignettes.
#'
#' @format Data frame with 30 rows and 7 columns:
#' \describe{
#'   \item{\code{Question}}{Item text (character)}
#'   \item{\code{ResponseCategories}}{Comma-separated response categories (e.g., "1,2,3,4,5")}
#'   \item{\code{a}}{Discrimination parameter (numeric)}
#'   \item{\code{b1}}{Threshold parameter (numeric)}
#'   \item{\code{b2}}{Threshold parameter (numeric)}
#'   \item{\code{b3}}{Threshold parameter (numeric)}
#'   \item{\code{b4}}{Threshold parameter (numeric)}
#' }
#'
#' @source Simulated data for demonstration.
#'
#' @details
#' The parameters and item texts are provided for demonstration. For real studies,
#' use validated instruments with properly calibrated item parameters.
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' # Inspect structure and parameters
#' str(bfi_items)
#' summary(bfi_items$a)
#'
#' # Run adaptive assessment
#' config <- create_study_config(name = "BFI", model = "GRM", max_items = 15)
#' launch_study(config, bfi_items)
#' }
#'
#' @seealso \code{\link{validate_item_bank}}, \code{\link{create_study_config}},
#'   \code{\link{launch_study}}
#' @name bfi_items
#' @keywords datasets
NULL
