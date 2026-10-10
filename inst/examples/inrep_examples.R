# inrep examples ----
# Each example starts a Shiny app; run them one at a time. All item
# parameters in this file are invented or simulated, so the adaptive
# examples only show the mechanics and the scores carry no meaning.

library(inrep)

# Results processor shared by the examples: mean response and a bar chart.
# For the right/wrong test in Example 3 the mean is the proportion correct.

create_simple_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  tryCatch({
    if (is.null(responses) || length(responses) == 0) {
      return(shiny::HTML("<p>No responses available.</p>"))
    }

    mean_score <- mean(responses, na.rm = TRUE)

    plot_base64 <- ""
    if (requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("base64enc", quietly = TRUE)) {
      tryCatch({
        plot_data <- data.frame(
          Item = 1:length(responses),
          Score = responses
        )

        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = Item, y = Score)) +
          ggplot2::geom_bar(stat = "identity", fill = "#4A90E2", alpha = 0.7) +
          ggplot2::labs(title = "Your Responses", x = "Item", y = "Score") +
          ggplot2::theme_minimal()

        temp_file <- tempfile(fileext = ".png")
        ggplot2::ggsave(temp_file, p, width = 8, height = 5, dpi = 150, bg = "white")
        plot_base64 <- base64enc::base64encode(temp_file)
        unlink(temp_file)
      }, error = function(e) invisible(NULL))
    }

    html <- paste0(
      '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
      '<h1 style="color: #4A90E2; text-align: center;">Study Results</h1>',

      if (plot_base64 != "" && nchar(plot_base64) > 100) paste0(
        '<div style="margin: 30px 0;">',
        '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 20px auto;">',
        '</div>'
      ) else "",

      '<div style="background: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<h2 style="color: #4A90E2;">Summary</h2>',
      '<p style="font-size: 18px;">Average Score: <strong>', round(mean_score, 2), '</strong></p>',
      '<p>Thank you for your participation!</p>',
      '</div>',

      '</div>'
    )

    return(shiny::HTML(html))
  }, error = function(e) {
    return(shiny::HTML('<div style="padding: 20px;"><h2>Error generating report</h2></div>'))
  })
}

# Example 1: adaptive test with the GRM and bfi_items ----
config <- create_study_config(
  name = "A First Adaptive Test",
  model = "GRM",
  max_items = 10,
  min_items = 5,
  criteria = "MI",
  results_processor = create_simple_report
)

launch_study(config, bfi_items)

# Example 2: your own GRM item bank ----
# The a and b values are invented. The CAT treats the 20 items as one
# dimension, so the bank has no domain or reverse-coding columns: reverse-
# keyed items would need negative discriminations or recoding before
# calibration.
  work_personality_items <- data.frame(
    item_id = paste0("WORK_", sprintf("%03d", 1:20)),

    Question = c(
      "I prefer working in teams rather than alone.",
      "I enjoy taking on leadership responsibilities.",
      "I am comfortable with ambiguity and uncertainty.",
      "I pay close attention to details in my work.",
      "I am good at managing my time effectively.",
      "I enjoy learning new skills and technologies.",
      "I handle stress well in demanding situations.",
      "I am comfortable presenting ideas to others.",
      "I prefer structure and routine in my work.",
      "I am motivated by challenging goals.",
      "I enjoy helping and supporting my colleagues.",
      "I am comfortable with public speaking.",
      "I prefer working with data and numbers.",
      "I enjoy creative problem-solving.",
      "I am good at meeting deadlines.",
      "I prefer working independently.",
      "I am comfortable with change and adaptation.",
      "I enjoy mentoring and teaching others.",
      "I pay attention to quality in my work.",
      "I am good at organizing tasks and projects."
    ),

    a = c(1.2, 1.4, 1.1, 1.3, 1.5, 1.2, 1.4, 1.1, 1.3, 1.2,
          1.3, 1.1, 1.4, 1.2, 1.5, 1.1, 1.3, 1.2, 1.4, 1.1),

    # Thresholds for five categories
    b1 = c(-1.8, -1.5, -1.9, -1.6, -1.4, -1.7, -1.5, -1.8, -1.6, -1.7,
           -1.5, -1.9, -1.4, -1.8, -1.3, -1.9, -1.6, -1.7, -1.5, -1.8),
    b2 = c(-0.8, -0.5, -0.9, -0.6, -0.4, -0.7, -0.5, -0.8, -0.6, -0.7,
           -0.5, -0.9, -0.4, -0.8, -0.3, -0.9, -0.6, -0.7, -0.5, -0.8),
    b3 = c(0.2, 0.5, 0.1, 0.4, 0.6, 0.3, 0.5, 0.2, 0.4, 0.3,
           0.5, 0.1, 0.6, 0.2, 0.7, 0.1, 0.4, 0.3, 0.5, 0.2),
    b4 = c(1.2, 1.5, 1.1, 1.4, 1.6, 1.3, 1.5, 1.2, 1.4, 1.3,
           1.5, 1.1, 1.6, 1.2, 1.7, 1.1, 1.4, 1.3, 1.5, 1.2),

    ResponseCategories = rep("1,2,3,4,5", 20),

    stringsAsFactors = FALSE
  )

config <- create_study_config(
  name = "Work Personality Assessment",
  model = "GRM",
  max_items = 10,
  min_items = 5,
  criteria = "MI",
  theme = "large-text",
  results_processor = create_simple_report
)

launch_study(config, work_personality_items)

# Example 3: multiple-choice test with the 2PL ----
# For 1PL/2PL/3PL items inrep shows the options in Option1 to Option4 and
# scores a response as correct when it equals Answer. The a and b values are
# fixed, invented numbers, not a calibration.
math_knowledge_items <- data.frame(
  item_id = paste0("MATH_", sprintf("%03d", 1:10)),
  Question = c(
    "What is 15 + 27?",
    "What is 7 x 9?",
    "What is 25% of 200?",
    "What is 1/2 + 1/4?",
    "Solve: 2x + 3 = 11",
    "If y = 2x + 1, what is y when x = 3?",
    "What is the area of a rectangle with length 8 and width 5?",
    "What is the sum of the angles of a triangle, in degrees?",
    "What is the square root of 144?",
    "What is 5! (5 factorial)?"
  ),
  Option1 = c("32", "56", "25", "3/4", "3", "6", "13", "90", "11", "25"),
  Option2 = c("42", "63", "50", "2/6", "4", "7", "26", "180", "12", "60"),
  Option3 = c("52", "72", "75", "1/8", "5", "8", "40", "270", "14", "120"),
  Option4 = c("44", "81", "100", "2/4", "7", "9", "45", "360", "72", "720"),
  Answer  = c("42", "63", "50", "3/4", "4", "7", "40", "180", "12", "120"),
  a = c(0.9, 1.1, 1.3, 1.2, 1.4, 1.0, 1.2, 0.8, 1.1, 1.5),
  b = c(-2.0, -1.5, -1.0, -0.5, 0.0, 0.2, 0.5, -0.8, 0.8, 1.5),
  domain = c("Arithmetic", "Arithmetic", "Arithmetic", "Fractions", "Algebra",
             "Algebra", "Geometry", "Geometry", "Arithmetic", "Arithmetic"),
  stringsAsFactors = FALSE
)

config <- create_study_config(
  name = "Math Knowledge Test",
  model = "2PL",
  max_items = 8,
  min_items = 5,
  criteria = "MI",
  theme = "Midnight",
  results_processor = create_simple_report
)

launch_study(config, math_knowledge_items)

# Example 4: Hildesheim theme and demographic questions ----
config <- create_study_config(
  name = "Big Five Personality Assessment",
  model = "GRM",
  max_items = 20,
  min_items = 10,
  criteria = "MI",
  theme = "Hildesheim",
  estimation_method = "EAP",
  results_processor = create_simple_report
)

# Demographic questions: question text, input type and options
demographic_configs <- list(
  Age = list(
    question = "What is your age?",
    type = "radio",
    options = c(
      "18 or younger" = 1, "19-20" = 2, "21-25" = 3,
      "26-30" = 4, "31-40" = 5, "41-50" = 6,
      "51-60" = 7, "61 or older" = 8
    ),
    required = TRUE
  ),

  Gender = list(
    question = "How do you identify your gender?",
    type = "radio",
    options = c(
      "Female" = 1, "Male" = 2, "Non-binary" = 3,
      "Other" = 4, "Prefer not to say" = 5
    ),
    required = TRUE
  )
)

config$demographics <- names(demographic_configs)
config$demographic_configs <- demographic_configs
config$input_types <- list(Age = "radio", Gender = "radio")

launch_study(config, bfi_items)

# Example 5: readability themes ----
# These themes change colours, fonts and spacing. They have not been tested
# against an accessibility standard.

# Dyslexia-friendly theme (cream background, OpenDyslexic font if installed)
config <- create_study_config(
  name = "Dyslexia-Friendly Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 8,
  criteria = "MI",
  theme = "Dyslexia-Friendly",
  estimation_method = "EAP",
  results_processor = create_simple_report
)

launch_study(config, bfi_items)

# High-contrast theme
config_hc <- create_study_config(
  name = "High Contrast Assessment",
  model = "GRM",
  max_items = 15,
  min_items = 8,
  criteria = "MI",
  theme = "High-Contrast",
  results_processor = create_simple_report
)

launch_study(config_hc, bfi_items)

# Note on missing item parameters ----
# validate_item_bank() accepts NA in a, b1, b2, ... and estimate_ability()
# then substitutes fixed default values without a warning. Scores based on
# such items are not meaningful; calibrate all items before an adaptive study.
