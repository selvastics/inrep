#' Example Big Five Item Bank (Invented Parameters)
#'
#' @description
#' A 30-item example bank of self-description statements in the style of the
#' Big Five Inventory, with five response categories and graded response model
#' (GRM) parameters. The parameters were set by hand for demonstration; they
#' are not estimates from any sample. Used in \code{inrep} examples and
#' vignettes.
#'
#' @format Data frame with 30 rows and 7 columns:
#' \describe{
#'   \item{\code{Question}}{Item text (character)}
#'   \item{\code{ResponseCategories}}{Comma-separated response categories ("1,2,3,4,5")}
#'   \item{\code{a}}{Discrimination parameter (0.8 to 1.4)}
#'   \item{\code{b1}, \code{b2}, \code{b3}, \code{b4}}{Thresholds between
#'     categories 1|2, 2|3, 3|4 and 4|5 (about -2, -0.5, 0.5 and 2 for every item)}
#' }
#'
#' @source Invented for demonstration. Some statements resemble items of the
#'   BFI (John & Srivastava, 1999) or BFI-2 (Soto & John, 2017), others do not,
#'   and some are near-duplicates (for example "outgoing, sociable",
#'   "outgoing" and "sociable"). The set is not a published instrument.
#'
#' @details
#' The statements cover all five domains (extraversion, agreeableness,
#' conscientiousness, neuroticism, openness), and several are negatively keyed
#' (for example "reserved", "sometimes rude to others", "relaxed, handles
#' stress well"), yet all discriminations are positive and there is no domain
#' or keying column. A unidimensional adaptive test on this bank therefore does
#' not measure a meaningful trait; it only shows how the software works. For a
#' real study, use a validated instrument with item parameters calibrated on
#' suitable data, one scale per adaptive test.
#'
#' @references
#' John, O. P., & Srivastava, S. (1999). The Big Five trait taxonomy: History,
#'   measurement, and theoretical perspectives. In L. A. Pervin & O. P. John
#'   (Eds.), \emph{Handbook of personality: Theory and research} (2nd ed.,
#'   pp. 102--138). Guilford Press.
#'
#' Soto, C. J., & John, O. P. (2017). The next Big Five Inventory (BFI-2):
#'   Developing and assessing a hierarchical model with 15 facets to enhance
#'   bandwidth, fidelity, and predictive power. \emph{Journal of Personality and
#'   Social Psychology}, 113(1), 117--143.
#'
#' @examples
#' \dontrun{
#' library(inrep)
#' data(bfi_items)
#'
#' str(bfi_items)
#' summary(bfi_items$a)
#'
#' # Demonstration of the adaptive workflow (see Details)
#' config <- create_study_config(name = "BFI demo", model = "GRM", max_items = 15)
#' launch_study(config, bfi_items)
#' }
#'
#' @seealso \code{\link{validate_item_bank}}, \code{\link{create_study_config}},
#'   \code{\link{launch_study}}
#' @name bfi_items
#' @keywords datasets
NULL
