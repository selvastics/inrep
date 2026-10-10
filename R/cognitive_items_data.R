#' Example Cognitive Item Bank (Simulated 2PL Parameters)
#'
#' A 50-item example bank with five domain labels (verbal reasoning, numerical
#' reasoning, spatial reasoning, working memory, processing speed) and 2PL
#' parameters that are random draws, not calibrated values. The item texts
#' are informal examples: some refer to figures that are not included ("Which
#' shape comes next in the pattern?"), some have no single correct answer
#' ("What is the first letter of your name?"), and the domain labels are not
#' validated. The bank has no response options or answer key. It is meant for
#' trying out the software and the simulation functions only.
#'
#' @format Data frame with 50 rows and 5 columns:
#' \describe{
#'   \item{\code{item_id}}{Unique identifier (COG_001 to COG_050)}
#'   \item{\code{content}}{Item text}
#'   \item{\code{domain}}{Verbal_Reasoning, Numerical_Reasoning,
#'     Spatial_Reasoning, Working_Memory, or Processing_Speed}
#'   \item{\code{difficulty}}{Simulated difficulty parameter (b)}
#'   \item{\code{discrimination}}{Simulated discrimination parameter (a)}
#' }
#' The columns \code{content}, \code{difficulty} and \code{discrimination} are
#' read as \code{Question}, \code{b} and \code{a} by \code{\link{launch_study}},
#' \code{\link{select_next_item}} and \code{\link{estimate_ability}}.
#' \code{\link{validate_item_bank}} requires a \code{Question} column and
#' therefore rejects this bank as it is.
#'
#' @source Simulated. \code{inst/examples/create_cognitive_items.R} shows the
#'   kind of generating code, but it does not reproduce this data set (it
#'   creates different columns and parameter values).
#'
#' @examples
#' \dontrun{
#' data(cognitive_items)
#' str(cognitive_items)
#' table(cognitive_items$domain)
#'
#' config <- create_study_config(name = "2PL simulation", model = "2PL")
#' sim <- run_simulation(config, cognitive_items, n_sim = 100, cat_k = 15)
#' }
#'
#' @seealso \code{\link{bfi_items}}, \code{\link{run_simulation}}
#' @name cognitive_items
#' @keywords datasets
NULL
