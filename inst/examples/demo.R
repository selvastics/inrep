# Psychological Study on R Package Testing Experience
# Example implementation using inrep package with Monochrome theme

# Load the inrep package
library(inrep)

# Create the item bank for the psychological study
r_testing_items <- data.frame(
  item_id = 1:6,
  item_text = c(
    "I feel confident in my ability to write effective unit tests using testthat.",
    "Using devtools to manage and test R packages is intuitive and efficient.",
    "Interpreting code coverage reports from covr helps me improve my testing strategy.",
    "Testing R packages reduces my stress when preparing for a package release.",
    "I feel motivated to incorporate regular testing into my R package development process.",
    "The documentation for testthat is clear and supports my testing needs."
  ),
  explanation = c(
    "Confidence in testing skills can enhance code quality and reduce development errors.",
    "Ease of use in testing workflows impacts developer productivity and adoption.",
    "Clear coverage reports enable targeted improvements in test coverage.",
    "Effective testing can alleviate concerns about introducing bugs in production.",
    "Motivation to test regularly correlates with higher code reliability and quality.",
    "Clear documentation is critical for effective use of testing tools."
  ),
  # Graded Response Model parameters for Likert scales
  a = rep(1.5, 6),  # Discrimination parameter
  b1 = rep(-2, 6),  # Threshold 1 (Strongly Disagree -> Disagree)
  b2 = rep(-1, 6),  # Threshold 2 (Disagree -> Neutral)
  b3 = rep(0, 6),   # Threshold 3 (Neutral -> Agree)
  b4 = rep(1, 6),   # Threshold 4 (Agree -> Strongly Agree)
  response_options = I(rep(list(c(
    "Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"
  )), 6))
)

# Create demographic questions
demographic_questions <- list(
  age_range = list(
    question = "What is your age range?",
    options = c("18-24", "25-34", "35-44", "45-54", "55+"),
    required = FALSE
  ),
  r_experience = list(
    question = "How many years have you been using R for package development?",
    options = c("Less than 1 year", "1-3 years", "3-5 years", "5+ years"),
    required = FALSE
  )
)

# Create study configuration using the Monochrome theme
study_config <- create_study_config(
  name = "Psychological Study on R Package Testing Experience",

  # Use the elegant Monochrome theme
  theme = "Monochrome",

  # Study parameters
  study_key = "r_testing_psychology_2025",
  model = "GRM",  # Graded Response Model for Likert scales

  # Fixed questionnaire (not adaptive)
  adaptive = FALSE,
  max_items = 6,
  min_items = 6,

  # UI configuration
  response_ui_type = "radio",
  progress_style = "bar",

  # Session management (20-minute timer)
  session_save = TRUE,
  max_session_duration = 20,

  # Demographic configurations
  demographics = c("age_range", "r_experience"),
  input_types = list(
    age_range = "radio",
    r_experience = "radio"
  ),
  demographic_configs = demographic_questions,
  
  # Results processor function (following vignette patterns)
  results_processor = function(responses, item_bank, demographics = NULL, session = NULL) {
    tryCatch({
      if (is.null(responses) || length(responses) == 0) {
        return(shiny::HTML("<p>No responses available.</p>"))
      }

      # Calculate average score
      mean_score <- mean(responses, na.rm = TRUE)

      # Create simple plot (following vignette approach)
      plot_base64 <- ""
      tryCatch({
        if (requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("base64enc", quietly = TRUE)) {

          plot_data <- data.frame(
            Item = 1:length(responses),
            Score = responses
          )

          p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = Item, y = Score)) +
            ggplot2::geom_bar(stat = "identity", fill = "#2E8B57", alpha = 0.7) +
            ggplot2::labs(title = "Your Responses", x = "Item", y = "Score") +
            ggplot2::theme_minimal()

          temp_file <- tempfile(fileext = ".png")
          ggplot2::ggsave(temp_file, p, width = 8, height = 5, dpi = 150, bg = "white")
          plot_base64 <- base64enc::base64encode(temp_file)
          unlink(temp_file)
        }
      }, error = function(e) {
        message("Plot generation failed: ", e$message)
      })

      # Simple HTML report (following vignette style)
      html_report <- paste0(
        '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
        '<h1 style="color: #2E8B57; text-align: center;">Study Results</h1>',

        if (plot_base64 != "" && nchar(plot_base64) > 100) paste0(
          '<div style="margin: 30px 0;">',
          '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 20px auto;">',
          '</div>'
        ) else "",

        '<div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">',
        '<h2 style="color: #2E8B57;">Summary</h2>',
        '<p style="font-size: 18px;">Average Score: <strong>', round(mean_score, 2), '</strong></p>',
        '<p>Thank you for your participation!</p>',
        '</div>',

        '</div>'
      )

      return(shiny::HTML(html_report))

    }, error = function(e) {
      message("Error generating report: ", e$message)
      return(shiny::HTML('<div style="padding: 20px;"><h2>Error generating report</h2></div>'))
    })
  }
)

# Fix item bank structure to match current API
r_testing_items$Question <- r_testing_items$item_text
r_testing_items$ResponseCategories <- rep("1,2,3,4,5", 6)
r_testing_items <- r_testing_items[, c("Question", "a", "b1", "b2", "b3", "b4", "ResponseCategories")]
r_testing_items$stringsAsFactors <- FALSE

# Launch the study
launch_study(study_config, r_testing_items)
