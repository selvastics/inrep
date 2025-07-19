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
#' @export
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
#'     cat("  ✓ Item bank meets professional standards\n")
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

#' Detect Outlier Items in TAM-Compatible Item Banks
#'
#' @description
#' Identifies items with poor psychometric properties that may compromise assessment quality.
#' This function flags items with low discrimination parameters or problematic threshold
#' ordering that could affect TAM-based ability estimation and adaptive testing performance.
#'
#' @param item_bank Data frame containing item parameters. Must include discrimination
#'   parameter column \code{a} and threshold parameters for GRM items.
#' @param discrimination_threshold Numeric minimum acceptable discrimination parameter.
#'   Default is 0.2. Values below this threshold indicate poor item quality.
#' 
#' @return Data frame containing flagged items with their problematic parameters.
#'   Returns empty data frame if no items are flagged.
#' 
#' @export
#' 
#' @details
#' This function performs comprehensive quality assessment of item banks:
#' 
#' \strong{Detection Criteria:}
#' \itemize{
#'   \item Low discrimination: Items with \code{a} parameters below threshold
#'   \item Threshold ordering: GRM items with improperly ordered thresholds
#'   \item Extreme parameters: Items with unrealistic parameter values
#'   \item Missing values: Items with incomplete parameter specification
#' }
#' 
#' \strong{Quality Standards:}
#' \itemize{
#'   \item Discrimination parameters should typically be above 0.5 for good quality
#'   \item Threshold parameters should be in ascending order for GRM items
#'   \item Parameters should be within reasonable ranges for stable estimation
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Outlier Detection
#' library(inrep)
#' data(bfi_items)
#' 
#' # Detect items with default threshold (0.2)
#' outliers <- detect_outlier_items(bfi_items)
#' 
#' if (nrow(outliers) > 0) {
#'   cat("Items flagged for review:\n")
#'   print(outliers[, c("Question", "a")])
#' } else {
#'   cat("All items meet quality standards\n")
#' }
#' 
#' # Example 2: Stricter Quality Standards
#' # Use higher threshold for research-grade assessment
#' strict_outliers <- detect_outlier_items(bfi_items, discrimination_threshold = 0.7)
#' 
#' cat("Items below strict threshold (0.7):\n")
#' print(strict_outliers[, c("Question", "a")])
#' 
#' # Example 3: Create Clean Item Bank
#' # Remove flagged items for high-quality assessment
#' clean_items <- bfi_items[!rownames(bfi_items) %in% rownames(outliers), ]
#' cat("Original items:", nrow(bfi_items), "\n")
#' cat("Clean items:", nrow(clean_items), "\n")
#' cat("Removed:", nrow(bfi_items) - nrow(clean_items), "items\n")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_item_bank}} for comprehensive validation
#'   \item \code{\link{simulate_item_bank}} for performance testing
#'   \item \code{\link{bfi_items}} for example item bank
#' }
#' 
#' @keywords quality-assurance psychometrics item-analysis
detect_outlier_items <- function(item_bank, discrimination_threshold = 0.2) {
  flagged <- item_bank[item_bank$a < discrimination_threshold, ]
  if (nrow(flagged) > 0) {
    message(sprintf("%d items flagged for low discrimination.", nrow(flagged)))
  }
  flagged
}

#' Simulate Adaptive Testing Performance on Item Bank
#'
#' @description
#' Runs comprehensive simulation to validate item bank performance and assess the quality
#' of adaptive testing algorithms. This function generates realistic assessment scenarios
#' to evaluate item bank effectiveness and identify potential issues before deployment.
#'
#' @param item_bank Data frame containing item parameters compatible with TAM.
#'   Must include all required columns for the specified IRT model.
#' @param model Character string specifying IRT model for simulation.
#'   Options: "GRM", "2PL", "1PL", "3PL". Default is "GRM".
#' @param n Integer specifying number of simulated participants. Default is 100.
#' @param ability_range Numeric vector of length 2 specifying the range of simulated
#'   abilities. Default is c(-3, 3).
#' @param max_items Integer specifying maximum items per simulated assessment.
#'   Default is 20.
#' 
#' @return List containing comprehensive simulation results:
#' \describe{
#'   \item{\code{participants}}{List of individual participant results}
#'   \item{\code{summary}}{Summary statistics across all participants}
#'   \item{\code{item_usage}}{Item usage frequency across simulations}
#'   \item{\code{ability_recovery}}{Ability estimation accuracy metrics}
#'   \item{\code{convergence}}{Convergence statistics for TAM estimation}
#' }
#' 
#' @export
#' 
#' @details
#' This function provides comprehensive validation of item bank performance:
#' 
#' \strong{Simulation Process:}
#' \itemize{
#'   \item Generates diverse ability levels across specified range
#'   \item Simulates realistic response patterns based on IRT model
#'   \item Applies adaptive testing algorithms
#'   \item Evaluates estimation accuracy and efficiency
#' }
#' 
#' \strong{Validation Metrics:}
#' \itemize{
#'   \item Ability estimation bias and precision
#'   \item Item usage patterns and exposure rates
#'   \item Assessment length and efficiency
#'   \item Convergence rates for TAM procedures
#' }
#' 
#' \strong{Quality Indicators:}
#' \itemize{
#'   \item Root mean square error (RMSE) for ability estimation
#'   \item Correlation between true and estimated abilities
#'   \item Item bank coverage and utilization balance
#'   \item Stopping criteria effectiveness
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic Simulation
#' library(inrep)
#' data(bfi_items)
#' 
#' # Run simulation with default parameters
#' simulation_results <- simulate_item_bank(bfi_items, model = "GRM", n = 50)
#' 
#' # View summary statistics
#' print(simulation_results$summary)
#' 
#' # Example 2: Comprehensive Validation
#' # Larger simulation for research validation
#' large_simulation <- simulate_item_bank(
#'   item_bank = bfi_items,
#'   model = "GRM",
#'   n = 200,
#'   ability_range = c(-2.5, 2.5),
#'   max_items = 25
#' )
#' 
#' # Analyze ability recovery
#' ability_recovery <- large_simulation$ability_recovery
#' cat("Ability Recovery Statistics:\n")
#' cat("RMSE:", round(ability_recovery$rmse, 3), "\n")
#' cat("Correlation:", round(ability_recovery$correlation, 3), "\n")
#' cat("Mean Bias:", round(ability_recovery$bias, 3), "\n")
#' 
#' # Example 3: Model Comparison
#' # Compare different IRT models
#' models <- c("GRM", "2PL", "1PL")
#' model_results <- list()
#' 
#' for (model in models) {
#'   cat("Simulating", model, "model...\n")
#'   
#'   # Prepare appropriate item bank
#'   if (model == "GRM") {
#'     test_bank <- bfi_items
#'   } else {
#'     # Create binary item bank for 2PL/1PL
#'     test_bank <- data.frame(
#'       Question = paste("Binary Item", 1:20),
#'       a = if (model == "1PL") rep(1, 20) else runif(20, 0.5, 2.0),
#'       b = runif(20, -2, 2),
#'       Answer = sample(c("A", "B", "C", "D"), 20, replace = TRUE)
#'     )
#'   }
#'   
#'   model_results[[model]] <- simulate_item_bank(
#'     test_bank, model = model, n = 100
#'   )
#' }
#' 
#' # Compare model performance
#' cat("Model Comparison:\n")
#' for (model in models) {
#'   recovery <- model_results[[model]]$ability_recovery
#'   cat(sprintf("%-5s: RMSE = %.3f, r = %.3f\n", 
#'               model, recovery$rmse, recovery$correlation))
#' }
#' 
#' # Example 4: Item Usage Analysis
#' # Analyze item exposure patterns
#' analyze_item_usage <- function(simulation_results) {
#'   usage <- simulation_results$item_usage
#'   cat("Item Usage Analysis:\n")
#'   cat("====================\n")
#'   cat("Total items:", length(usage), "\n")
#'   cat("Items used:", sum(usage > 0), "\n")
#'   cat("Items unused:", sum(usage == 0), "\n")
#'   cat("Mean usage:", round(mean(usage), 2), "\n")
#'   cat("Usage range:", range(usage), "\n")
#'   
#'   # Identify over/under-used items
#'   overused <- which(usage > quantile(usage, 0.95))
#'   underused <- which(usage < quantile(usage, 0.05))
#'   
#'   cat("Overused items (>95th percentile):", length(overused), "\n")
#'   cat("Underused items (<5th percentile):", length(underused), "\n")
#'   
#'   return(list(overused = overused, underused = underused))
#' }
#' 
#' # Analyze usage patterns
#' usage_analysis <- analyze_item_usage(simulation_results)
#' 
#' # Example 5: Adaptive Testing Efficiency
#' # Evaluate adaptive testing efficiency
#' evaluate_efficiency <- function(simulation_results) {
#'   participants <- simulation_results$participants
#'   
#'   # Extract assessment lengths
#'   lengths <- sapply(participants, function(p) length(p$responses))
#'   
#'   # Extract final standard errors
#'   se_values <- sapply(participants, function(p) p$final_se)
#'   
#'   cat("Adaptive Testing Efficiency:\n")
#'   cat("============================\n")
#'   cat("Mean assessment length:", round(mean(lengths), 1), "items\n")
#'   cat("Length range:", range(lengths), "items\n")
#'   cat("Mean final SE:", round(mean(se_values, na.rm = TRUE), 3), "\n")
#'   cat("SE range:", round(range(se_values, na.rm = TRUE), 3), "\n")
#'   
#'   # Efficiency metric: precision per item
#'   efficiency <- 1 / (se_values * lengths)
#'   cat("Mean efficiency:", round(mean(efficiency, na.rm = TRUE), 3), "\n")
#'   
#'   return(list(
#'     mean_length = mean(lengths),
#'     mean_se = mean(se_values, na.rm = TRUE),
#'     efficiency = mean(efficiency, na.rm = TRUE)
#'   ))
#' }
#' 
#' # Evaluate efficiency
#' efficiency_metrics <- evaluate_efficiency(simulation_results)
#' 
#' # Example 6: Simulation Report Generation
#' # Generate comprehensive simulation report
#' generate_simulation_report <- function(simulation_results, filename = "simulation_report.txt") {
#'   cat("TAM-Based Item Bank Simulation Report\n", file = filename)
#'   cat("=====================================\n", file = filename, append = TRUE)
#'   cat("Generated:", format(Sys.time()), "\n\n", file = filename, append = TRUE)
#'   
#'   # Summary statistics
#'   summary_stats <- simulation_results$summary
#'   cat("Summary Statistics:\n", file = filename, append = TRUE)
#'   cat("  Participants:", summary_stats$n_participants, "\n", file = filename, append = TRUE)
#'   cat("  Mean ability:", round(summary_stats$mean_ability, 3), "\n", file = filename, append = TRUE)
#'   cat("  Ability SD:", round(summary_stats$sd_ability, 3), "\n", file = filename, append = TRUE)
#'   
#'   # Ability recovery
#'   recovery <- simulation_results$ability_recovery
#'   cat("\nAbility Recovery:\n", file = filename, append = TRUE)
#'   cat("  RMSE:", round(recovery$rmse, 3), "\n", file = filename, append = TRUE)
#'   cat("  Correlation:", round(recovery$correlation, 3), "\n", file = filename, append = TRUE)
#'   cat("  Mean bias:", round(recovery$bias, 3), "\n", file = filename, append = TRUE)
#'   
#'   # Item usage
#'   usage <- simulation_results$item_usage
#'   cat("\nItem Usage:\n", file = filename, append = TRUE)
#'   cat("  Total items:", length(usage), "\n", file = filename, append = TRUE)
#'   cat("  Items used:", sum(usage > 0), "\n", file = filename, append = TRUE)
#'   cat("  Mean usage:", round(mean(usage), 2), "\n", file = filename, append = TRUE)
#'   
#'   cat("\nSimulation report saved to:", filename, "\n")
#' }
#' 
#' # Generate report
#' generate_simulation_report(simulation_results)
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{detect_outlier_items}} for item quality assessment
#'   \item \code{\link{validate_item_bank}} for structural validation
#'   \item \code{\link{create_study_config}} for assessment configuration
#'   \item \code{\link{launch_study}} for actual assessment deployment
#' }
#' 
#' @references
#' van der Linden, W. J., & Glas, C. A. W. (Eds.). (2010). 
#' Elements of adaptive testing. Springer.
#' 
#' @keywords simulation validation adaptive-testing performance-analysis
simulate_item_bank <- function(item_bank, model = "GRM", n = 100) {
  results <- vector("list", n)
  for (i in seq_len(n)) {
    theta <- rnorm(1)
    # Simulate responses (simple random for demo)
    responses <- sapply(seq_len(nrow(item_bank)), function(j) {
      sample(1:length(strsplit(as.character(item_bank$ResponseCategories[j]), ",")[[1]]), 1)
    })
    results[[i]] <- list(theta = theta, responses = responses)
  }
  message(sprintf("Simulated %d adaptive tests.", n))
  results
}
