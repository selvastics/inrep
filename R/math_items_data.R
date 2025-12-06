#' Mathematics Assessment Item Bank for IRT-Based Testing
#'
#' @description
#' A comprehensive mathematics item bank containing 40 items across four mathematical
#' domains, calibrated using the Graded Response Model (GRM) for adaptive testing
#' in educational settings. This dataset provides a foundation for mathematics
#' assessment and demonstrates IRT applications in educational measurement.
#'
#' @format Data frame with 40 rows and 10 columns:
#' \describe{
#'   \item{\code{item_id}}{Character. Unique identifier for each item (MATH_001 to MATH_040)}
#'   \item{\code{Question}}{Character. Mathematics problem or question text}
#'   \item{\code{domain}}{Character. Mathematical domain classification:
#'     \itemize{
#'       \item Basic_Arithmetic - Addition, subtraction, multiplication, division
#'       \item Fractions_Decimals - Fraction and decimal operations
#'       \item Algebra - Linear equations, functions, simplification
#'       \item Geometry - Area, perimeter, volume calculations
#'     }
#'   }
#'   \item{\code{difficulty_level}}{Character. Subjective difficulty: Easy, Medium, Hard}
#'   \item{\code{a}}{Numeric. Discrimination parameter for GRM model (0.8 to 2.2)}
#'   \item{\code{b1}}{Numeric. First threshold parameter (1|2 boundary)}
#'   \item{\code{b2}}{Numeric. Second threshold parameter (2|3 boundary)}
#'   \item{\code{b3}}{Numeric. Third threshold parameter (3|4 boundary)}
#'   \item{\code{b4}}{Numeric. Fourth threshold parameter (4|5 boundary)}
#'   \item{\code{ResponseCategories}}{Character. Response scale "1,2,3,4,5"}
#'   \item{\code{grade_level}}{Character. Recommended grade level (6-8, 7-9, 8-10, 9-11)}
#' }
#' 
#' @source Simulated data based on common mathematics curriculum standards
#'   and psychometric principles for educational assessment.
#' 
#' @keywords dataset datasets mathematics education IRT GRM TAM
#' @docType data
#' @name math_items
#'
#' @details
#' This item bank represents typical mathematics assessment content suitable for
#' middle and high school students. The items are calibrated using the Graded
#' Response Model (GRM), making them compatible with TAM-based adaptive testing.
#' 
#' \strong{Mathematical Content Areas:}
#' \itemize{
#'   \item Items 1-10: Basic arithmetic operations and number sense
#'   \item Items 11-20: Fractions, decimals, and percentages
#'   \item Items 21-30: Algebraic thinking and linear equations
#'   \item Items 31-40: Geometric concepts and spatial reasoning
#' }
#' 
#' \strong{Psychometric Properties:}
#' \itemize{
#'   \item Discrimination parameters (a) optimized for educational assessment
#'   \item Threshold parameters properly ordered for valid GRM implementation
#'   \item 5-point response scale suitable for mathematics confidence ratings
#'   \item Coverage across multiple difficulty levels and grade ranges
#' }
#' 
#' \strong{Educational Applications:}
#' \itemize{
#'   \item Mathematics placement testing
#'   \item Adaptive skill assessment
#'   \item Progress monitoring in mathematics education
#'   \item Research on mathematical ability and learning
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Basic Data Exploration
#' library(inrep)
#' data(math_items)
#' 
#' # Examine item bank structure
#' str(math_items)
#' head(math_items, 3)
#' 
#' # Domain distribution
#' table(math_items$domain)
#' table(math_items$difficulty_level)
#' table(math_items$grade_level)
#' 
#' # Check discrimination parameters
#' summary(math_items$a)
#' hist(math_items$a, main = "Distribution of Discrimination Parameters")
#' 
#' # Example 2: Quality Assurance
#' # Validate item bank for GRM model
#' is_valid <- validate_item_bank(math_items, model = "GRM")
#' cat("Math items valid for GRM:", is_valid, "\n")
#' 
#' # Detect any problematic items
#' outliers <- detect_outlier_items(math_items, discrimination_threshold = 0.5)
#' if (nrow(outliers) > 0) {
#'   cat("Items flagged for review:\n")
#'   print(outliers[, c("Question", "a")])
#' }
#' 
#' # Example 3: Create Mathematics Assessment
#' # Configure adaptive mathematics test
#' math_config <- create_study_config(
#'   name = "Mathematics Skills Assessment",
#'   model = "GRM",
#'   max_items = 20,
#'   min_items = 8,
#'   min_SEM = 0.4,
#'   demographics = c("Grade", "School", "Previous_Math_Course"),
#'   language = "en",
#'   theme = "academic"
#' )
#' 
#' # Launch assessment (requires Shiny environment)
#' # launch_study(config = math_config, item_bank = math_items)
#' 
#' # Example 4: Domain-Specific Analysis
#' # Analyze items by mathematical domain
#' domain_analysis <- function(item_bank) {
#'   cat("Mathematics Item Bank Analysis\n")
#'   cat("==============================\n")
#'   
#'   for (domain in unique(item_bank$domain)) {
#'     domain_items <- item_bank[item_bank$domain == domain, ]
#'     cat("\n", domain, "Domain:\n")
#'     cat("  Items:", nrow(domain_items), "\n")
#'     cat("  Mean discrimination:", round(mean(domain_items$a), 3), "\n")
#'     cat("  Difficulty range (b1-b4):", 
#'         round(range(c(domain_items$b1, domain_items$b4)), 2), "\n")
#'   }
#' }
#' 
#' domain_analysis(math_items)
#' 
#' # Example 5: Grade-Level Appropriateness
#' # Check item distribution by grade level
#' grade_summary <- table(math_items$grade_level, math_items$difficulty_level)
#' print(grade_summary)
#' 
#' # Create grade-specific subset
#' middle_school_items <- math_items[math_items$grade_level %in% c("6-8", "7-9"), ]
#' cat("Middle school items:", nrow(middle_school_items), "\n")
#' }
#' 
#' @seealso
#' \itemize{
#'   \item \code{bfi_items} for personality assessment items (use \code{data(bfi_items)})
#'   \item \code{cognitive_items} for cognitive assessment items (use \code{data(cognitive_items)})
#'   \item \code{\link{create_study_config}} for assessment configuration
#'   \item \code{\link{launch_study}} for running mathematics assessments
#'   \item \code{\link{validate_item_bank}} for psychometric validation
#' }
#' 
#' @references
#' \itemize{
#'   \item Common Core State Standards Initiative. (2010). Common Core State Standards for Mathematics.
#'   \item Samejima, F. (1997). Graded response model. \emph{Handbook of modern item response theory}, 85-100.
#'   \item Embretson, S. E., & Reise, S. P. (2000). \emph{Item response theory for psychologists}. Lawrence Erlbaum.
#' }
NULL
