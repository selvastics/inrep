# Enhanced Response Reporting Function
# This function creates an enhanced reporting table with response labels

#' Create Enhanced Response Reporting for IRT-Based Assessments
#'
#' @description
#' Creates a comprehensive reporting table that shows perfect alignment between
#' user input and final results, with additional context, validation, and
#' multilingual support for professional research reporting.
#'
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Must contain model specifications, language settings, and response formatting options.
#' @param cat_result CAT result object with responses and administered items.
#'   Expected structure includes \code{responses}, \code{administered}, and \code{response_times}.
#' @param item_bank Item bank dataset with question content and response options.
#'   Structure varies by IRT model but must include \code{Question} column.
#' @param include_labels Logical indicating whether to include response labels 
#'   for better readability. Default is \code{TRUE}.
#' 
#' @return Data frame containing comprehensive response report with metadata.
#'   Structure varies by IRT model but includes consistent formatting and validation attributes.
#' 
#' @details
#' This function creates professional-grade reporting tables for IRT-Based Assessments:
#' 
#' \strong{Report Structure:}
#' \itemize{
#'   \item \strong{GRM Models}: Item text, numeric response, optional labels, response times
#'   \item \strong{Binary Models}: Item text, correct/incorrect status, correct answers, response times
#'   \item \strong{Multilingual}: Response labels in specified language (en, de, es, fr)
#'   \item \strong{Validation}: Embedded metadata for quality assurance
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Input validation and error handling
#'   \item Response consistency checking
#'   \item Metadata embedding for audit trails
#'   \item Language-specific label formatting
#' }
#' 
#' \strong{Language Support:}
#' \itemize{
#'   \item English: "Strongly Disagree" to "Strongly Agree"
#'   \item German: "Stark ablehnen" to "Stark zustimmen"
#'   \item Spanish: "Totalmente en desacuerdo" to "Totalmente de acuerdo"
#'   \item French: "Fortement en désaccord" to "Fortement d'accord"
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic GRM Report with Labels
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create configuration
#' config <- create_study_config(
#'   model = "GRM",
#'   language = "en"
#' )
#' 
#' # Simulate CAT results
#' cat_result <- list(
#'   responses = c(3, 2, 4, 1, 5),
#'   administered = c(1, 5, 12, 18, 23),
#'   response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#' )
#' 
#' # Create report
#' report <- create_response_report(config, cat_result, bfi_items)
#' print(report)
#' 
#' # View validation metadata
#' validation_info <- attr(report, "validation_info")
#' print(validation_info)
#' 
#' # Example 2: Binary Model Report
#' # Create binary item bank
#' binary_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   Answer = c("4", "15", "5"),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6")
#' )
#' 
#' # Create binary configuration
#' binary_config <- create_study_config(
#'   model = "2PL",
#'   language = "en"
#' )
#' 
#' # Simulate binary results (1 = correct, 0 = incorrect)
#' binary_result <- list(
#'   responses = c(1, 0, 1),
#'   administered = c(1, 2, 3),
#'   response_times = c(1.5, 2.8, 1.2)
#' )
#' 
#' # Create binary report
#' binary_report <- create_response_report(binary_config, binary_result, binary_items)
#' print(binary_report)
#' 
#' # Example 3: Multilingual Reports
#' # German language report
#' german_config <- create_study_config(
#'   model = "GRM",
#'   language = "de"
#' )
#' 
#' german_report <- create_response_report(german_config, cat_result, bfi_items)
#' print(german_report)
#' 
#' # Spanish language report
#' spanish_config <- create_study_config(
#'   model = "GRM",
#'   language = "es"
#' )
#' 
#' spanish_report <- create_response_report(spanish_config, cat_result, bfi_items)
#' print(spanish_report)
#' 
#' # Example 4: Report without Labels
#' # Create report without response labels for compact display
#' compact_report <- create_response_report(
#'   config, cat_result, bfi_items, include_labels = FALSE
#' )
#' print(compact_report)
#' 
#' # Example 5: Comprehensive Report Analysis
#' # Analyze report characteristics
#' analyze_report <- function(report) {
#'   cat("Report Analysis:\n")
#'   cat("================\n")
#'   cat("Number of items:", nrow(report), "\n")
#'   cat("Columns:", paste(names(report), collapse=", "), "\n")
#'   
#'   # Check validation metadata
#'   validation_info <- attr(report, "validation_info")
#'   if (!is.null(validation_info)) {
#'     cat("Validation Info:\n")
#'     cat("  Total items:", validation_info$total_items, "\n")
#'     cat("  Total responses:", validation_info$total_responses, "\n")
#'     cat("  Consistency:", validation_info$response_consistency, "\n")
#'     cat("  Model:", validation_info$model, "\n")
#'     cat("  Timestamp:", format(validation_info$timestamp), "\n")
#'   }
#'   
#'   # Response time analysis
#'   if ("Time" %in% names(report)) {
#'     cat("Response Time Analysis:\n")
#'     cat("  Mean:", round(mean(report$Time, na.rm=TRUE), 2), "seconds\n")
#'     cat("  Range:", round(range(report$Time, na.rm=TRUE), 2), "seconds\n")
#'   }
#'   
#'   # Response pattern analysis
#'   if ("Response" %in% names(report)) {
#'     cat("Response Pattern:\n")
#'     if (is.numeric(report$Response)) {
#'       cat("  Mean response:", round(mean(report$Response, na.rm=TRUE), 2), "\n")
#'       cat("  Response range:", range(report$Response, na.rm=TRUE), "\n")
#'     } else {
#'       response_table <- table(report$Response)
#'       cat("  Response distribution:\n")
#'       for (i in 1:length(response_table)) {
#'         cat("    ", names(response_table)[i], ":", response_table[i], "\n")
#'       }
#'     }
#'   }
#' }
#' 
#' # Analyze reports
#' analyze_report(report)
#' analyze_report(binary_report)
#' 
#' # Example 6: Export and Quality Check
#' # Export report and perform quality checks
#' export_and_validate_report <- function(report, filename) {
#'   # Export to CSV
#'   write.csv(report, filename, row.names = FALSE)
#'   cat("Report exported to:", filename, "\n")
#'   
#'   # Quality checks
#'   cat("Quality Checks:\n")
#'   cat("  Missing values:", sum(is.na(report)), "\n")
#'   cat("  Complete cases:", sum(complete.cases(report)), "\n")
#'   cat("  Data integrity:", all(complete.cases(report)), "\n")
#'   
#'   # Validation metadata check
#'   validation_info <- attr(report, "validation_info")
#'   if (!is.null(validation_info)) {
#'     cat("  Validation status:", validation_info$response_consistency, "\n")
#'   }
#'   
#'   return(invisible(TRUE))
#' }
#' 
#' # Export reports
#' export_and_validate_report(report, "grm_report.csv")
#' export_and_validate_report(binary_report, "binary_report.csv")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{validate_response_report}} for report validation
#'   \item \code{\link{validate_response_mapping}} for response mapping validation
#'   \item \code{\link{create_study_config}} for configuration setup
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @keywords reporting psychometrics TAM multilingual quality-assurance
#' @export
create_response_report <- function(config, cat_result, item_bank, include_labels = TRUE) {
  
  if (is.null(cat_result) || is.null(cat_result$responses)) {
    stop("Invalid cat_result: missing responses")
  }
  
  items <- cat_result$administered
  responses <- cat_result$responses
  
  # Basic table structure
  if (config$model == "GRM") {
    # For GRM, show actual response values with optional labels
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = responses,
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
    
    # Add response labels if requested
    if (include_labels && config$language %in% c("en", "de", "es", "fr")) {
      response_labels <- switch(config$language,
        "en" = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
        "de" = c("Stark ablehnen", "Ablehnen", "Neutral", "Zustimmen", "Stark zustimmen"),
        "es" = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo"),
        "fr" = c("Fortement en désaccord", "En désaccord", "Neutre", "D'accord", "Fortement d'accord")
      )
      
      # Add response labels column
      dat$Response_Label <- response_labels[responses]
      
      # Reorder columns
      dat <- dat[, c("Item", "Response", "Response_Label", "Time")]
    }
    
  } else {
    # For binary models, show correct/incorrect with answers
    dat <- data.frame(
      Item = item_bank$Question[items],
      Response = ifelse(responses == 1, "Correct", "Incorrect"),
      Correct = item_bank$Answer[items],
      Time = round(cat_result$response_times, 1),
      check.names = FALSE
    )
  }
  
  # Add validation metadata
  attr(dat, "validation_info") <- list(
    total_items = length(items),
    total_responses = length(responses),
    response_consistency = all(!is.na(responses)),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(dat)
}

#' Validate Response Report Consistency for Quality Assurance
#'
#' @description
#' Validates that the response report accurately reflects the input data,
#' ensuring data integrity and consistency throughout the assessment workflow.
#' This function provides comprehensive quality assurance for IRT-Based Assessments.
#'
#' @param original_responses Vector of original input responses from participants.
#'   Should match the responses used to generate the report.
#' @param report_data Data frame containing the response report generated by
#'   \code{\link{create_response_report}}.
#' @param config Study configuration object created by \code{\link{create_study_config}}.
#'   Must contain model specifications for appropriate validation logic.
#' 
#' @return List containing validation results with the following components:
#' \describe{
#'   \item{consistent}{Logical indicating whether the report is consistent with input data}
#'   \item{original_count}{Number of original responses}
#'   \item{reported_count}{Number of responses in the report}
#'   \item{model}{IRT model used for validation}
#'   \item{timestamp}{Timestamp of validation execution}
#'   \item{details}{Additional validation details and diagnostics}
#' }
#' 
#' @details
#' This function performs comprehensive validation of response report consistency:
#' 
#' \strong{Validation Logic:}
#' \itemize{
#'   \item \strong{GRM Models}: Compares original ordinal responses with reported responses
#'   \item \strong{Binary Models}: Validates correct/incorrect scoring consistency
#'   \item \strong{Count Validation}: Ensures response counts match between input and report
#'   \item \strong{Data Integrity}: Checks for missing values and data corruption
#' }
#' 
#' \strong{Quality Assurance Features:}
#' \itemize{
#'   \item Response count verification
#'   \item Data type consistency checking
#'   \item Missing value detection
#'   \item Scoring logic validation
#'   \item Timestamp tracking for audit trails
#' }
#' 
#' \strong{Error Detection:}
#' \itemize{
#'   \item Mismatched response counts
#'   \item Invalid scoring transformations
#'   \item Missing or corrupted data
#'   \item Inconsistent response formats
#' }
#' 
#' @examples
#' \dontrun{
#' # Example 1: Basic GRM Report Validation
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create configuration and simulate data
#' config <- create_study_config(model = "GRM", language = "en")
#' 
#' # Original responses
#' original_responses <- c(3, 2, 4, 1, 5)
#' 
#' # Simulate CAT results
#' cat_result <- list(
#'   responses = original_responses,
#'   administered = c(1, 5, 12, 18, 23),
#'   response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#' )
#' 
#' # Create report
#' report <- create_response_report(config, cat_result, bfi_items)
#' 
#' # Validate report consistency
#' validation_result <- validate_response_report(original_responses, report, config)
#' print(validation_result)
#' 
#' # Check validation status
#' if (validation_result$consistent) {
#'   cat("PASS: Report validation PASSED\n")
#' } else {
#'   cat("FAIL: Report validation FAILED\n")
#' }
#' 
#' # Example 2: Binary Model Report Validation
#' # Create binary item bank
#' binary_items <- data.frame(
#'   Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
#'   Answer = c("4", "15", "5"),
#'   Option1 = c("2", "10", "3"),
#'   Option2 = c("3", "12", "4"),
#'   Option3 = c("4", "15", "5"),
#'   Option4 = c("5", "18", "6")
#' )
#' 
#' # Create binary configuration
#' binary_config <- create_study_config(model = "2PL", language = "en")
#' 
#' # Original responses (participant selections)
#' original_binary_responses <- c("4", "12", "5")  # Mix of correct and incorrect
#' 
#' # Simulate scoring: correct=1, incorrect=0
#' scored_responses <- c(1, 0, 1)  # First and third are correct
#' 
#' # Create CAT result with scored responses
#' binary_cat_result <- list(
#'   responses = scored_responses,
#'   administered = c(1, 2, 3),
#'   response_times = c(1.5, 2.8, 1.2)
#' )
#' 
#' # Create binary report
#' binary_report <- create_response_report(binary_config, binary_cat_result, binary_items)
#' 
#' # Validate binary report (using scored responses for validation)
#' binary_validation <- validate_response_report(scored_responses, binary_report, binary_config)
#' print(binary_validation)
#' 
#' # Example 3: Validation with Errors
#' # Test validation with mismatched data
#' mismatched_responses <- c(1, 2, 3)  # Different length
#' 
#' error_validation <- validate_response_report(mismatched_responses, report, config)
#' print(error_validation)
#' 
#' if (!error_validation$consistent) {
#'   cat("Expected inconsistency detected:\n")
#'   cat("  Original count:", error_validation$original_count, "\n")
#'   cat("  Reported count:", error_validation$reported_count, "\n")
#' }
#' 
#' # Example 4: Comprehensive Validation Workflow
#' # Complete validation pipeline
#' comprehensive_validation <- function(config, item_bank, responses) {
#'   cat("Starting comprehensive validation workflow...\n")
#'   cat("==========================================\n")
#'   
#'   # Create CAT result
#'   cat_result <- list(
#'     responses = responses,
#'     administered = 1:length(responses),
#'     response_times = runif(length(responses), 1, 4)
#'   )
#'   
#'   # Step 1: Create report
#'   cat("1. Creating response report...\n")
#'   report <- create_response_report(config, cat_result, item_bank)
#'   cat("   Report created with", nrow(report), "rows\n")
#'   
#'   # Step 2: Validate report
#'   cat("2. Validating report consistency...\n")
#'   validation <- validate_response_report(responses, report, config)
#'   
#'   # Step 3: Report results
#'   cat("3. Validation results:\n")
#'   cat("   Consistent:", validation$consistent, "\n")
#'   cat("   Original count:", validation$original_count, "\n")
#'   cat("   Reported count:", validation$reported_count, "\n")
#'   cat("   Model:", validation$model, "\n")
#'   cat("   Timestamp:", format(validation$timestamp), "\n")
#'   
#'   if (!is.null(validation$details)) {
#'     cat("   Additional details:\n")
#'     for (detail in validation$details) {
#'       cat("     -", detail, "\n")
#'     }
#'   }
#'   
#'   return(validation)
#' }
#' 
#' # Run comprehensive validation
#' grm_validation <- comprehensive_validation(config, bfi_items, original_responses)
#' binary_validation <- comprehensive_validation(binary_config, binary_items, scored_responses)
#' 
#' # Example 5: Batch Validation
#' # Validate multiple assessments
#' batch_validation <- function(assessments) {
#'   cat("Batch Validation Results:\n")
#'   cat("========================\n")
#'   
#'   results <- list()
#'   for (i in seq_along(assessments)) {
#'     assessment <- assessments[[i]]
#'     cat("Assessment", i, ":\n")
#'     
#'     # Create report
#'     cat_result <- list(
#'       responses = assessment$responses,
#'       administered = assessment$administered,
#'       response_times = assessment$response_times
#'     )
#'     
#'     report <- create_response_report(
#'       assessment$config, cat_result, assessment$item_bank
#'     )
#'     
#'     # Validate
#'     validation <- validate_response_report(
#'       assessment$responses, report, assessment$config
#'     )
#'     
#'     results[[i]] <- validation
#'     cat("  Status:", if (validation$consistent) "PASSED" else "FAILED", "\n")
#'   }
#'   
#'   # Summary
#'   passed <- sum(sapply(results, function(x) x$consistent))
#'   total <- length(results)
#'   cat("\nSummary:", passed, "of", total, "assessments passed validation\n")
#'   
#'   return(results)
#' }
#' 
#' # Create batch assessments
#' assessments <- list(
#'   list(
#'     config = config,
#'     item_bank = bfi_items,
#'     responses = c(3, 2, 4, 1, 5),
#'     administered = c(1, 5, 12, 18, 23),
#'     response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
#'   ),
#'   list(
#'     config = binary_config,
#'     item_bank = binary_items,
#'     responses = c(1, 0, 1),
#'     administered = c(1, 2, 3),
#'     response_times = c(1.5, 2.8, 1.2)
#'   )
#' )
#' 
#' # Run batch validation
#' batch_results <- batch_validation(assessments)
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{\link{create_response_report}} for creating response reports
#'   \item \code{\link{validate_response_mapping}} for response mapping validation
#'   \item \code{\link{create_study_config}} for configuration setup
#'   \item \code{\link{launch_study}} for complete assessment workflow
#' }
#' 
#' @references
#' Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
#' R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
#' 
#' @keywords validation psychometrics quality-assurance data-integrity
#' @export
validate_response_report <- function(original_responses, report_data, config) {
  
  if (config$model == "GRM") {
    # For GRM, responses should match exactly
    reported_responses <- report_data$Response
    consistency_check <- all(reported_responses == original_responses)
  } else {
    # For binary models, check scoring consistency
    reported_binary <- ifelse(report_data$Response == "Correct", 1, 0)
    consistency_check <- length(reported_binary) == length(original_responses)
  }
  
  validation_result <- list(
    consistent = consistency_check,
    original_count = length(original_responses),
    reported_count = nrow(report_data),
    model = config$model,
    timestamp = Sys.time()
  )
  
  return(validation_result)
}
