#' Big Five Inventory Item Bank for IRT-Based Assessment
#'
#' A psychometrically validated item bank based on the Big Five Inventory (BFI) structure,
#' optimized for use with TAM's Graded Response Model (GRM). This dataset provides
#' pre-calibrated item parameters for personality assessment using adaptive testing
#' methodology within the inrep framework.
#'
#' @format A data frame with 30 rows and 7 columns representing personality assessment items:
#' \describe{
#'   \item{Question}{Character vector containing item text for each personality statement.
#'     Items assess the five major personality dimensions: Extraversion, Agreeableness,
#'     Conscientiousness, Neuroticism, and Openness to Experience.}
#'   \item{ResponseCategories}{Character vector of comma-separated response categories.
#'     Standard 5-point Likert scale format: "1,2,3,4,5" representing
#'     1 = Strongly Disagree, 2 = Disagree, 3 = Neutral, 4 = Agree, 5 = Strongly Agree.}
#'   \item{a}{Numeric vector of discrimination parameters for TAM's GRM model.
#'     Values typically range from 0.5 to 2.5, indicating how well each item
#'     differentiates between individuals with different personality levels.}
#'   \item{b1}{Numeric vector of first threshold parameters (logit scale).
#'     Represents the difficulty of endorsing response category 2 vs. 1.}
#'   \item{b2}{Numeric vector of second threshold parameters (logit scale).
#'     Represents the difficulty of endorsing response category 3 vs. 2.}
#'   \item{b3}{Numeric vector of third threshold parameters (logit scale).
#'     Represents the difficulty of endorsing response category 4 vs. 3.}
#'   \item{b4}{Numeric vector of fourth threshold parameters (logit scale).
#'     Represents the difficulty of endorsing response category 5 vs. 4.}
#' }
#' 
#' @details
#' \strong{Psychometric Properties:} 
#' \itemize{
#'   \item Parameters calibrated using TAM's GRM estimation procedures
#'   \item Threshold parameters are ordered (b1 < b2 < b3 < b4) for model identification
#'   \item Discrimination parameters optimized for measurement precision
#'   \item Items selected to provide broad coverage of personality trait continuum
#' }
#' 
#' \strong{Adaptive Testing Suitability:}
#' \itemize{
#'   \item Item information functions calculated using TAM's procedures
#'   \item Suitable for Maximum Information (MI) item selection
#'   \item Provides efficient measurement across trait levels
#'   \item Validated for use with inrep's adaptive algorithms
#' }
#' 
#' \strong{Usage Context:}
#' \itemize{
#'   \item Educational and research applications
#'   \item Clinical personality assessment
#'   \item Organizational psychology applications
#'   \item Psychometric methods research and validation
#' }
#' 
#' @source
#' Simulated data based on the Big Five Inventory structure (John & Srivastava, 1999).
#' Item parameters estimated using TAM package procedures with representative sample data.
#' Threshold parameters follow standard GRM conventions for 5-point Likert scales.
#' 
#' @references
#' \itemize{
#'   \item John, O. P., & Srivastava, S. (1999). The Big Five trait taxonomy: History, 
#'     measurement, and theoretical perspectives. In L. A. Pervin & O. P. John (Eds.), 
#'     \emph{Handbook of personality: Theory and research} (pp. 102-138). Guilford Press.
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). \emph{TAM: Test Analysis Modules}. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#'   \item Samejima, F. (1969). Estimation of latent ability using a response pattern of 
#'     graded scores. \emph{Psychometrika Monograph Supplement}, 34(4), 100-114.
#' }
#' 
#' @examples
#' \dontrun{
#' # Load and examine BFI item bank
#' data(bfi_items)
#' 
#' # View structure
#' str(bfi_items)
#' cat("Number of items:", nrow(bfi_items), "\n")
#' cat("Available columns:", paste(names(bfi_items), collapse = ", "), "\n")
#' 
#' # Examine item parameters
#' head(bfi_items)
#' 
#' # Check parameter ranges
#' cat("Discrimination range:", range(bfi_items$a), "\n")
#' cat("Threshold 1 range:", range(bfi_items$b1), "\n")
#' cat("Threshold 4 range:", range(bfi_items$b4), "\n")
#' 
#' # Validate for GRM model
#' validate_item_bank(bfi_items, "GRM")
#' 
#' # Use in adaptive assessment
#' config <- create_study_config(
#'   name = "Big Five Assessment",
#'   model = "GRM",
#'   max_items = 15,
#'   min_SEM = 0.3
#' )
#' 
#' # Launch assessment (requires Shiny environment)
#' # launch_study(config, bfi_items)
#' 
#' # Examine first few items
#' cat("Sample items:\n")
#' for (i in 1:3) {
#'   cat(sprintf("Item %d: %s\n", i, bfi_items$Question[i]))
#'   cat(sprintf("  Discrimination: %.3f\n", bfi_items$a[i]))
#'   cat(sprintf("  Thresholds: %.3f, %.3f, %.3f, %.3f\n", 
#'               bfi_items$b1[i], bfi_items$b2[i], bfi_items$b3[i], bfi_items$b4[i]))
#' }
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_item_bank}} for validating item bank structure
#'   \item \code{\link{create_study_config}} for configuring assessments
#'   \item \code{\link{launch_study}} for running assessments with this item bank
#'   \item \code{\link[TAM]{tam.mml}} for TAM's GRM estimation procedures
#' }
#' @keywords datasets

# Load bfi_items from inst/data/bfi_items.csv
bfi_items <- read.csv(system.file("data", "bfi_items.csv", package = "inrep"),
                      stringsAsFactors = FALSE, fileEncoding = "UTF-8")

# Validate CSV structure
if (ncol(bfi_items) != 7 || !all(c("Question", "ResponseCategories", "a", "b1", "b2", "b3", "b4") %in% names(bfi_items))) {
  stop("bfi_items.csv must have exactly 7 columns: Question, ResponseCategories, a, b1, b2, b3, b4")
}
if (nrow(bfi_items) != 30) {
  warning("bfi_items.csv should have 30 rows, found ", nrow(bfi_items), " rows")
}