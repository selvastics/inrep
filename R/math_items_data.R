#' Mathematics Assessment Item Bank
#'
#' @description
#' A simulated 40-item mathematics bank across four domains (arithmetic,
#' fractions/decimals, algebra, geometry), calibrated for GRM.
#'
#' @format Data frame with 40 rows and 10 columns:
#' \describe{
#'   \item{\code{item_id}}{Unique identifier (MATH_001 to MATH_040)}
#'   \item{\code{Question}}{Problem text}
#'   \item{\code{domain}}{Basic_Arithmetic, Fractions_Decimals, Algebra, or Geometry}
#'   \item{\code{difficulty_level}}{Easy, Medium, or Hard}
#'   \item{\code{a}}{Discrimination parameter (0.8--2.2)}
#'   \item{\code{b1}, \code{b2}, \code{b3}, \code{b4}}{Threshold parameters}
#'   \item{\code{ResponseCategories}}{"1,2,3,4,5"}
#'   \item{\code{grade_level}}{Recommended grade range}
#' }
#'
#' @source Simulated data.
#'
#' @examples
#' \dontrun{
#' data(math_items)
#' str(math_items)
#' table(math_items$domain)
#'
#' config <- create_study_config(name = "Math Test", model = "GRM", max_items = 20)
#' launch_study(config, math_items)
#' }
#'
#' @seealso \code{\link{bfi_items}}, \code{\link{cognitive_items}},
#'   \code{\link{create_study_config}}
#' @name math_items
#' @keywords datasets
NULL
