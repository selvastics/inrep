#' Cognitive Assessment Item Bank
#'
#' A 50-item bank across five cognitive domains (verbal reasoning, numerical
#' reasoning, spatial reasoning, working memory, processing speed), calibrated
#' for the 2PL IRT model.
#'
#' @format Data frame with 50 rows and 5 columns:
#' \describe{
#'   \item{\code{item_id}}{Unique identifier (COG_001 to COG_050)}
#'   \item{\code{content}}{Item text}
#'   \item{\code{domain}}{Cognitive domain: Verbal_Reasoning, Numerical_Reasoning,
#'     Spatial_Reasoning, Working_Memory, or Processing_Speed}
#'   \item{\code{difficulty}}{Difficulty parameter (b) for 2PL model}
#'   \item{\code{discrimination}}{Discrimination parameter (a) for 2PL model}
#' }
#'
#' @source Simulated data.
#'
#' @examples
#' \dontrun{
#' data(cognitive_items)
#' str(cognitive_items)
#' table(cognitive_items$domain)
#'
#' config <- create_study_config(name = "Cognitive Test", model = "2PL", max_items = 20)
#' launch_study(config, cognitive_items)
#' }
#'
#' @seealso \code{\link{bfi_items}}, \code{\link{create_study_config}}
#' @name cognitive_items
#' @keywords datasets
NULL
