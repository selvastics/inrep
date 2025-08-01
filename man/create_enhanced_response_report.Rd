% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/enhanced_reporting.R
\name{create_enhanced_response_report}
\alias{create_enhanced_response_report}
\title{Create Enhanced Response Reporting for IRT-Based Assessments}
\usage{
create_enhanced_response_report(
  config,
  cat_result,
  item_bank,
  include_labels = TRUE
)
}
\arguments{
\item{config}{Study configuration object created by \code{\link{create_study_config}}.
Must contain model specifications, language settings, and response formatting options.}

\item{cat_result}{CAT result object with responses and administered items.
Expected structure includes \code{responses}, \code{administered}, and \code{response_times}.}

\item{item_bank}{Item bank dataset with question content and response options.
Structure varies by IRT model but must include \code{Question} column.}

\item{include_labels}{Logical indicating whether to include response labels 
for better readability. Default is \code{TRUE}.}
}
\value{
Data frame containing comprehensive response report with metadata.
  Structure varies by IRT model but includes consistent formatting and validation attributes.
}
\description{
Creates a comprehensive reporting table that shows perfect alignment between
user input and final results, with additional context, validation, and
multilingual support for professional research reporting.
}
\details{
This function creates professional-grade reporting tables for IRT-Based Assessments:

\strong{Report Structure:}
\itemize{
  \item \strong{GRM Models}: Item text, numeric response, optional labels, response times
  \item \strong{Binary Models}: Item text, correct/incorrect status, correct answers, response times
  \item \strong{Multilingual}: Response labels in specified language (en, de, es, fr)
  \item \strong{Validation}: Embedded metadata for quality assurance
}

\strong{Quality Assurance Features:}
\itemize{
  \item Input validation and error handling
  \item Response consistency checking
  \item Metadata embedding for audit trails
  \item Language-specific label formatting
}

\strong{Language Support:}
\itemize{
  \item English: "Strongly Disagree" to "Strongly Agree"
  \item German: "Stark ablehnen" to "Stark zustimmen"
  \item Spanish: "Totalmente en desacuerdo" to "Totalmente de acuerdo"
  \item French: "Fortement en désaccord" to "Fortement d'accord"
}
}
\examples{
\dontrun{
# Example 1: Basic GRM Report with Labels
library(inrep)
data(bfi_items)

# Create configuration
config <- create_study_config(
  model = "GRM",
  language = "en"
)

# Simulate CAT results
cat_result <- list(
  responses = c(3, 2, 4, 1, 5),
  administered = c(1, 5, 12, 18, 23),
  response_times = c(2.3, 1.8, 3.2, 2.1, 2.7)
)

# Create enhanced report
report <- create_enhanced_response_report(config, cat_result, bfi_items)
print(report)

# View validation metadata
validation_info <- attr(report, "validation_info")
print(validation_info)

# Example 2: Binary Model Report
# Create binary item bank
binary_items <- data.frame(
  Question = c("What is 2+2?", "What is 5*3?", "What is 10/2?"),
  Answer = c("4", "15", "5"),
  Option1 = c("2", "10", "3"),
  Option2 = c("3", "12", "4"),
  Option3 = c("4", "15", "5"),
  Option4 = c("5", "18", "6")
)

# Create binary configuration
binary_config <- create_study_config(
  model = "2PL",
  language = "en"
)

# Simulate binary results (1 = correct, 0 = incorrect)
binary_result <- list(
  responses = c(1, 0, 1),
  administered = c(1, 2, 3),
  response_times = c(1.5, 2.8, 1.2)
)

# Create binary report
binary_report <- create_enhanced_response_report(binary_config, binary_result, binary_items)
print(binary_report)

# Example 3: Multilingual Reports
# German language report
german_config <- create_study_config(
  model = "GRM",
  language = "de"
)

german_report <- create_enhanced_response_report(german_config, cat_result, bfi_items)
print(german_report)

# Spanish language report
spanish_config <- create_study_config(
  model = "GRM",
  language = "es"
)

spanish_report <- create_enhanced_response_report(spanish_config, cat_result, bfi_items)
print(spanish_report)

# Example 4: Report without Labels
# Create report without response labels for compact display
compact_report <- create_enhanced_response_report(
  config, cat_result, bfi_items, include_labels = FALSE
)
print(compact_report)

# Example 5: Comprehensive Report Analysis
# Analyze report characteristics
analyze_report <- function(report) {
  cat("Report Analysis:\n")
  cat("================\n")
  cat("Number of items:", nrow(report), "\n")
  cat("Columns:", paste(names(report), collapse=", "), "\n")
  
  # Check validation metadata
  validation_info <- attr(report, "validation_info")
  if (!is.null(validation_info)) {
    cat("Validation Info:\n")
    cat("  Total items:", validation_info$total_items, "\n")
    cat("  Total responses:", validation_info$total_responses, "\n")
    cat("  Consistency:", validation_info$response_consistency, "\n")
    cat("  Model:", validation_info$model, "\n")
    cat("  Timestamp:", format(validation_info$timestamp), "\n")
  }
  
  # Response time analysis
  if ("Time" \%in\% names(report)) {
    cat("Response Time Analysis:\n")
    cat("  Mean:", round(mean(report$Time, na.rm=TRUE), 2), "seconds\n")
    cat("  Range:", round(range(report$Time, na.rm=TRUE), 2), "seconds\n")
  }
  
  # Response pattern analysis
  if ("Response" \%in\% names(report)) {
    cat("Response Pattern:\n")
    if (is.numeric(report$Response)) {
      cat("  Mean response:", round(mean(report$Response, na.rm=TRUE), 2), "\n")
      cat("  Response range:", range(report$Response, na.rm=TRUE), "\n")
    } else {
      response_table <- table(report$Response)
      cat("  Response distribution:\n")
      for (i in 1:length(response_table)) {
        cat("    ", names(response_table)[i], ":", response_table[i], "\n")
      }
    }
  }
}

# Analyze reports
analyze_report(report)
analyze_report(binary_report)

# Example 6: Export and Quality Check
# Export report and perform quality checks
export_and_validate_report <- function(report, filename) {
  # Export to CSV
  write.csv(report, filename, row.names = FALSE)
  cat("Report exported to:", filename, "\n")
  
  # Quality checks
  cat("Quality Checks:\n")
  cat("  Missing values:", sum(is.na(report)), "\n")
  cat("  Complete cases:", sum(complete.cases(report)), "\n")
  cat("  Data integrity:", all(complete.cases(report)), "\n")
  
  # Validation metadata check
  validation_info <- attr(report, "validation_info")
  if (!is.null(validation_info)) {
    cat("  Validation status:", validation_info$response_consistency, "\n")
  }
  
  return(invisible(TRUE))
}

# Export reports
export_and_validate_report(report, "grm_report.csv")
export_and_validate_report(binary_report, "binary_report.csv")
}

}
\references{
Robitzsch A, Kiefer T, Wu M (2024). TAM: Test Analysis Modules. R package version 4.2-21, https://CRAN.R-project.org/package=TAMst Analysis Modules. 
R package version 3.5-19. \url{https://CRAN.R-project.org/package=TAM}
}
\seealso{
\itemize{
  \item \code{\link{validate_response_report}} for report validation
  \item \code{\link{validate_response_mapping}} for response mapping validation
  \item \code{\link{create_study_config}} for configuration setup
  \item \code{\link{launch_study}} for complete assessment workflow
}
}
\keyword{TAM}
\keyword{multilingual}
\keyword{psychometrics}
\keyword{quality-assurance}
\keyword{reporting}
