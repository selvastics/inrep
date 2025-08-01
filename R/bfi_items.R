#' Big Five Inventory Item Bank for IRT-Based Assessments
#'
#' @description
#' A professionally constructed item bank based on the Big Five Inventory (BFI) structure,
#' optimized for use with the Graded Response Model (GRM) in TAM-based adaptive assessments.
#' This dataset provides a comprehensive foundation for personality research and demonstrates
#' best practices for item bank construction in the \code{inrep} package.
#'
#' @format Data frame with 30 rows and 7 columns:
#' \describe{
#'   \item{\code{Question}}{Item text (character). Professional personality assessment items}
#'   \item{\code{ResponseCategories}}{Comma-separated response categories (e.g., "1,2,3,4,5")}
#'   \item{\code{a}}{Discrimination parameter (numeric). Controls item's ability to differentiate}
#'   \item{\code{b1}}{First threshold parameter (numeric). Boundary between categories 1-2}
#'   \item{\code{b2}}{Second threshold parameter (numeric). Boundary between categories 2-3}
#'   \item{\code{b3}}{Third threshold parameter (numeric). Boundary between categories 3-4}
#'   \item{\code{b4}}{Fourth threshold parameter (numeric). Boundary between categories 4-5}
#' }
#' 
#' @source Simulated data based on validated Big Five Inventory structure and
#'   psychometric research standards for personality assessment.
#' 
#' @keywords dataset datasets personality BFI TAM GRM
#' @name bfi_items
#' @usage data(bfi_items)
#'
#' @details
#' This item bank demonstrates professional standards for IRT-Based Assessments:
#' 
#' \strong{Psychometric Properties:}
#' \itemize{
#'   \item Discrimination parameters (a) range from 0.5 to 2.5 for optimal differentiation
#'   \item Threshold parameters (b1-b4) are properly ordered and scaled
#'   \item Response categories follow standard 5-point Likert format
#'   \item Items cover all Big Five personality domains comprehensively
#' }
#' 
#' \strong{TAM Compatibility:}
#' \itemize{
#'   \item Fully compatible with TAM's \code{\link[TAM]{tam.mml}} functions
#'   \item Proper GRM parameter structure for polytomous items
#'   \item Validated response category formatting
#'   \item Optimized for adaptive testing algorithms
#' }
#' 
#' \strong{Research Applications:}
#' \itemize{
#'   \item Personality assessment in clinical and research settings
#'   \item Adaptive testing algorithm development and validation
#'   \item Cross-cultural personality research
#'   \item Educational demonstrations of IRT principles
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Built-in outlier detection with \code{\link{detect_outlier_items}}
#'   \item Simulation capabilities with \code{\link{simulate_item_bank}}
#'   \item Metadata support for advanced item management
#'   \item Validation tools for research integrity
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic Data Exploration
#' library(inrep)
#' data(bfi_items)
#' 
#' # Examine item bank structure
#' str(bfi_items)
#' head(bfi_items, 3)
#' 
#' # Check discrimination parameters
#' summary(bfi_items$a)
#' hist(bfi_items$a, main = "Distribution of Discrimination Parameters")
#' 
#' # Examine threshold parameters
#' threshold_summary <- data.frame(
#'   b1 = summary(bfi_items$b1),
#'   b2 = summary(bfi_items$b2),
#'   b3 = summary(bfi_items$b3),
#'   b4 = summary(bfi_items$b4)
#' )
#' print(threshold_summary)
#' 
#' # Example 2: Quality Assurance and Validation
#' # Detect items with poor psychometric properties
#' outlier_items <- detect_outlier_items(bfi_items, discrimination_threshold = 0.3)
#' 
#' if (nrow(outlier_items) > 0) {
#'   cat("Items flagged for review:\n")
#'   print(outlier_items[, c("Question", "a")])
#' } else {
#'   cat("All items meet quality standards\n")
#' }
#' 
#' # Comprehensive item bank validation
#' validation_result <- validate_item_bank(bfi_items, model = "GRM")
#' cat("Item bank validation:", validation_result, "\n")
#' 
#' # Example 3: Adaptive Testing Simulation
#' # Simulate adaptive testing to validate item bank performance
#' simulation_results <- simulate_item_bank(
#'   item_bank = bfi_items,
#'   model = "GRM",
#'   n = 50  # 50 simulated participants
#' )
#' 
#' # Analyze simulation results
#' cat("Simulation completed with", length(simulation_results), "participants\n")
#' 
#' # Extract ability estimates
#' simulated_thetas <- sapply(simulation_results, function(x) x$theta)
#' cat("Simulated ability range:", round(range(simulated_thetas), 2), "\n")
#' 
#' # Response pattern analysis
#' response_lengths <- sapply(simulation_results, function(x) length(x$responses))
#' cat("Response pattern lengths:", range(response_lengths), "\n")
#' 
#' # Example 4: Create Assessment with BFI Items
#' # Create comprehensive personality assessment configuration
#' bfi_config <- create_study_config(
#'   name = "Big Five Personality Assessment",
#'   model = "GRM",
#'   max_items = 25,
#'   min_items = 10,
#'   min_SEM = 0.3,
#'   demographics = c("Age", "Gender", "Education"),
#'   language = "en",
#'   theme = "Professional"
#' )
#' 
#' # Launch full assessment
#' launch_study(config = bfi_config, item_bank = bfi_items)
#' 
#' # Example 5: Advanced Item Analysis
#' # Comprehensive item analysis and reporting
#' analyze_item_bank <- function(item_bank) {
#'   cat("Big Five Item Bank Analysis\n")
#'   cat("===========================\n")
#'   
#'   # Basic statistics
#'   cat("Total items:", nrow(item_bank), "\n")
#'   cat("Response categories:", unique(item_bank$ResponseCategories), "\n")
#'   
#'   # Discrimination analysis
#'   cat("\nDiscrimination Parameters:\n")
#'   cat("  Mean:", round(mean(item_bank$a), 3), "\n")
#'   cat("  Range:", round(range(item_bank$a), 3), "\n")
#'   cat("  SD:", round(sd(item_bank$a), 3), "\n")
#'   
#'   # Threshold analysis
#'   cat("\nThreshold Parameters:\n")
#'   for (i in 1:4) {
#'     b_col <- paste0("b", i)
#'     cat("  ", b_col, "mean:", round(mean(item_bank[[b_col]]), 3), "\n")
#'   }
#'   
#'   # Quality checks
#'   cat("\nQuality Checks:\n")
#'   low_disc <- sum(item_bank$a < 0.5)
#'   cat("  Low discrimination items (<0.5):", low_disc, "\n")
#'   
#'   high_disc <- sum(item_bank$a > 2.5)
#'   cat("  High discrimination items (>2.5):", high_disc, "\n")
#'   
#'   # Threshold ordering check
#'   threshold_issues <- 0
#'   for (i in 1:nrow(item_bank)) {
#'     thresholds <- c(item_bank$b1[i], item_bank$b2[i], item_bank$b3[i], item_bank$b4[i])
#'     if (any(diff(thresholds) <= 0)) {
#'       threshold_issues <- threshold_issues + 1
#'     }
#'   }
#'   cat("  Threshold ordering issues:", threshold_issues, "\n")
#'   
#'   # Overall assessment
#'   cat("\nOverall Assessment:\n")
#'   if (low_disc == 0 && high_disc < 3 && threshold_issues == 0) {
#'     cat("  [OK] Item bank meets professional standards\n")
#'   } else {
#'     cat("  ⚠ Item bank may need review\n")
#'   }
#' }
#' 
#' # Run comprehensive analysis
#' analyze_item_bank(bfi_items)
#' 
#' # Example 6: Cross-Cultural Adaptation
#' # Adapt item bank for cross-cultural research
#' adapt_bfi_for_culture <- function(item_bank, culture = "international") {
#'   cat("Adapting BFI for", culture, "context\n")
#'   
#'   # Example adaptations (would need cultural validation)
#'   adapted_items <- item_bank
#'   
#'   if (culture == "collectivist") {
#'     # Adjust items that may be culturally biased
#'     collectivist_adjustments <- c(
#'       "I see myself as someone who is reserved" = 
#'         "I see myself as someone who is thoughtful before speaking",
#'       "I see myself as someone who is outgoing, sociable" = 
#'         "I see myself as someone who enjoys group activities"
#'     )
#'     
#'     for (i in 1:nrow(adapted_items)) {
#'       current_question <- adapted_items$Question[i]
#'       if (current_question %in% names(collectivist_adjustments)) {
#'         adapted_items$Question[i] <- collectivist_adjustments[[current_question]]
#'         cat("  Adapted item", i, "\n")
#'       }
#'     }
#'   }
#'   
#'   cat("Cultural adaptation completed\n")
#'   return(adapted_items)
#' }
#' 
#' # Create culturally adapted version
#' adapted_bfi <- adapt_bfi_for_culture(bfi_items, "collectivist")
#' 
#' # Example 7: Export and Documentation
#' # Export item bank with comprehensive documentation
#' export_item_bank <- function(item_bank, filename = "bfi_items_export.csv") {
#'   # Add metadata columns
#'   documented_items <- item_bank
#'   documented_items$Domain <- rep(c("Extraversion", "Agreeableness", "Conscientiousness", 
#'                                    "Neuroticism", "Openness"), each = 6)
#'   documented_items$Difficulty <- rowMeans(documented_items[, c("b1", "b2", "b3", "b4")])
#'   documented_items$Quality <- ifelse(documented_items$a > 0.7, "High", "Moderate")
#'   
#'   # Export with documentation
#'   write.csv(documented_items, filename, row.names = FALSE)
#'   cat("Item bank exported to:", filename, "\n")
#'   
#'   # Create documentation file
#'   doc_filename <- gsub(".csv", "_documentation.txt", filename)
#'   cat("BFI Item Bank Documentation\n", file = doc_filename)
#'   cat("Generated:", Sys.time(), "\n", file = doc_filename, append = TRUE)
#'   cat("Total items:", nrow(item_bank), "\n", file = doc_filename, append = TRUE)
#'   cat("Model: GRM\n", file = doc_filename, append = TRUE)
#'   cat("Response scale: 1-5 (Strongly Disagree to Strongly Agree)\n", 
#'       file = doc_filename, append = TRUE)
#'   
#'   cat("Documentation created:", doc_filename, "\n")
#' }
#' 
#' # Export with full documentation
#' export_item_bank(bfi_items, "professional_bfi_items.csv")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{detect_outlier_items}} for quality assurance
#'   \item \code{\link{simulate_item_bank}} for validation testing
#'   \item \code{\link{validate_item_bank}} for TAM compatibility checking
#'   \item \code{\link{create_study_config}} for assessment configuration
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' \itemize{
#'   \item John, O. P., & Srivastava, S. (1999). The Big Five trait taxonomy: History, 
#'     measurement, and theoretical perspectives. \emph{Handbook of personality: Theory and research}, 
#'     2(1999), 102-138.
#'   \item Samejima, F. (1997). Graded response model. \emph{Handbook of modern item response theory}, 
#'     85-100.
#'   \item Robitzsch, A., Kiefer, T., & Wu, M. (2020). TAM: Test Analysis Modules. 
#'     R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
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
"bfi_items"
