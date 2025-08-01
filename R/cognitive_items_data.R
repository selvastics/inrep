#' Cognitive Assessment Item Bank
#'
#' A comprehensive item bank for cognitive assessment containing 50 items
#' across five cognitive domains, calibrated using the 2PL IRT model.
#'
#' @format A data frame with 50 rows and 5 variables:
#' \describe{
#'   \item{item_id}{Character. Unique identifier for each item (COG_001 to COG_050)}
#'   \item{content}{Character. Item text/description for cognitive tasks}
#'   \item{domain}{Character. Cognitive domain classification:
#'     \itemize{
#'       \item Verbal_Reasoning - Language comprehension and analogies
#'       \item Numerical_Reasoning - Mathematical problem solving
#'       \item Spatial_Reasoning - Visual-spatial pattern recognition  
#'       \item Working_Memory - Short-term memory and manipulation
#'       \item Processing_Speed - Rapid cognitive processing tasks
#'     }
#'   }
#'   \item{difficulty}{Numeric. Item difficulty parameter (b) for 2PL model, 
#'     ranging from approximately -3.2 to 2.7}
#'   \item{discrimination}{Numeric. Item discrimination parameter (a) for 2PL model,
#'     ranging from approximately 0.8 to 2.4}
#' }
#'
#' @details
#' This dataset represents a typical cognitive assessment battery with items
#' designed to measure different aspects of cognitive ability. The items are
#' calibrated using the 2-Parameter Logistic (2PL) Item Response Theory model,
#' making them suitable for adaptive testing implementations.
#'
#' Each cognitive domain contains 10 items:
#' \itemize{
#'   \item Items 1-10: Verbal Reasoning tasks
#'   \item Items 11-20: Numerical Reasoning problems
#'   \item Items 21-30: Spatial Reasoning puzzles
#'   \item Items 31-40: Working Memory challenges
#'   \item Items 41-50: Processing Speed tasks
#' }
#'
#' The difficulty parameters are centered around 0 (mean = 0.04) with a 
#' standard deviation of approximately 1.2, providing good coverage across
#' the ability spectrum. Discrimination parameters range from 0.8 to 2.4,
#' indicating items with varying precision for ability estimation.
#'
#' @source
#' Simulated data based on typical cognitive assessment parameters found in
#' psychometric literature. Item content represents common cognitive task types
#' used in research and clinical practice.
#'
#' @examples
#' # Load the cognitive items dataset
#' data(cognitive_items)
#' 
#' # Examine the structure
#' str(cognitive_items)
#' 
#' # View available domains
#' table(cognitive_items$domain)
#' 
#' # Summary of item parameters
#' summary(cognitive_items[c("difficulty", "discrimination")])
#' 
#' # Create a study configuration for cognitive assessment
#' if (interactive()) {
#'   config <- create_study_config(
#'     name = "Cognitive Assessment",
#'     model = "2PL",
#'     max_items = 20,
#'     min_items = 10
#'   )
#'   
#'   # Launch study (requires Shiny environment)
#'   # launch_study(config, cognitive_items)
#' }
#'
#' @seealso 
#' \code{\link{bfi_items}} for personality assessment items,
#' \code{\link{create_study_config}} for study configuration,
#' \code{\link{launch_study}} for running assessments
"cognitive_items"
