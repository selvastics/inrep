# Example: fixed-form questionnaire with reverse-coded items and a custom
# report. The eight items are made up for this demo; each "construct" below
# has a single item, so the construct scores are single item responses.

library(inrep)

# Item bank ----
advanced_psychological_items <- data.frame(
  item_id = 1:8,
  
  Question = c(
    "I feel confident in my ability to write effective unit tests using testthat.",
    "Using devtools for package testing increases my cognitive load significantly.",  # REVERSE
    "Interpreting covr's code coverage reports is intuitive and supports my testing strategy.",
    "Testing R packages reduces my stress when preparing for a package release.",
    "I am motivated to incorporate regular testing into my R development workflow.",
    "The documentation for testthat is difficult to navigate and understand.",  # REVERSE
    "I feel satisfied with the feedback provided by covr when testing my R packages.",
    "Using automated testing tools like testthat makes me feel less competent as a developer."  # REVERSE
  ),
  
  explanation = c(
    "Self-efficacy in testing correlates with higher code quality and fewer errors.",
    "High cognitive load can hinder efficient integration of testing tools.",
    "Intuitive reports enable targeted improvements in test coverage.",
    "Effective testing mitigates anxiety about introducing bugs.",
    "Motivation to test regularly enhances code reliability.",
    "Clear documentation is critical for effective tool use.",
    "Satisfaction with feedback influences tool adoption and testing frequency.",
    "Perceived competence affects willingness to adopt testing practices."
  ),
  
  reverse_coded = c(FALSE, TRUE, FALSE, FALSE, FALSE, TRUE, FALSE, TRUE),
  
  construct = c(
    "Self-Efficacy", "Cognitive Load", "Usability", "Stress Reduction",
    "Motivation", "Documentation", "Satisfaction", "Competence"
  ),
  
  # GRM parameters: invented placeholders, not used in a fixed-form study
  a = c(1.9, 1.7, 1.5, 1.8, 2.0, 1.6, 1.4, 1.7),
  b1 = c(-2.2, -1.9, -2.1, -1.8, -2.3, -2.0, -1.7, -1.9),
  b2 = c(-0.9, -0.7, -0.8, -0.6, -1.0, -0.9, -0.5, -0.7),
  b3 = c(0.3, 0.1, 0.2, 0.0, 0.4, 0.3, 0.1, 0.2),
  b4 = c(1.2, 1.0, 1.1, 0.9, 1.3, 1.2, 1.0, 1.1),
  
  ResponseCategories = rep("1,2,3,4,5", 8),
  
  stringsAsFactors = FALSE
)

# Demographics ----
enhanced_demographics <- list(
  age_range = list(
    question = "What is your age range?",
    options = c("18-24", "25-34", "35-44", "45-54", "55+"),
    required = FALSE
  ),
  
  r_experience = list(
    question = "How many years have you been developing R packages?",
    options = c("Less than 1 year", "1-3 years", "3-5 years", "5+ years"),
    required = FALSE
  ),
  
  developer_role = list(
    question = "What is your primary role in R development?",
    options = c("Data Scientist", "Software Developer", "Researcher/Academic", "Student", "Other"),
    required = FALSE
  )
)

# Results processor ----
create_testing_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  tryCatch({
    if (is.null(responses) || length(responses) == 0) {
      return(shiny::HTML("<p>No responses available.</p>"))
    }
    
  # Reverse coding on the 1-5 scale
  reverse_indices <- which(advanced_psychological_items$reverse_coded)
  processed_responses <- responses
  
  for (i in reverse_indices) {
      if (i <= length(responses) && !is.na(responses[i])) {
      processed_responses[i] <- 6 - responses[i]
    }
  }
  
  # One item per construct, so each "score" is a single response
  constructs <- unique(advanced_psychological_items$construct)
  construct_scores <- list()
  
  for (construct in constructs) {
    construct_items <- which(advanced_psychological_items$construct == construct)
      if (all(construct_items <= length(processed_responses))) {
    construct_scores[[construct]] <- mean(processed_responses[construct_items], na.rm = TRUE)
  }
    }
    
    mean_score <- mean(processed_responses, na.rm = TRUE)
    
    plot_base64 <- ""
    tryCatch({
      if (requireNamespace("ggplot2", quietly = TRUE) && requireNamespace("base64enc", quietly = TRUE)) {
        
        plot_data <- data.frame(
          Construct = names(construct_scores),
          Score = unlist(construct_scores)
        )
        
        p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = reorder(Construct, Score), y = Score)) +
          ggplot2::geom_bar(stat = "identity", fill = "#2E8B57", alpha = 0.7) +
          ggplot2::geom_hline(yintercept = 3, linetype = "dashed", color = "gray50") +
          ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", Score)), hjust = -0.2, size = 4) +
          ggplot2::coord_flip() +
          ggplot2::ylim(1, 5.5) +
          ggplot2::labs(title = "Testing Experience Profile",
                       x = "Construct",
                       y = "Score (1-5)") +
          ggplot2::theme_minimal()
        
        temp_file <- tempfile(fileext = ".png")
        suppressMessages({
          ggplot2::ggsave(temp_file, p, width = 8, height = 6, dpi = 150, bg = "white")
        })
        
        plot_base64 <- base64enc::base64encode(temp_file)
        unlink(temp_file)
      }
    }, error = function(e) {
      message("Plot generation failed: ", e$message)
    })
    
    html_report <- paste0(
      '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
      '<h1 style="color: #2E8B57; text-align: center;">R Package Testing Experience Results</h1>',

      if (plot_base64 != "" && nchar(plot_base64) > 100) paste0(
        '<div style="margin: 30px 0;">',
        '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 20px auto;">',
        '</div>'
      ) else "",

      '<div style="background-color: #f5f5f5; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<h2 style="color: #2E8B57;">Your Scores</h2>',
      '<table style="width: 100%; border-collapse: collapse;">',
      '<tr style="background-color: #2E8B57; color: white;">',
      '<th style="padding: 12px; text-align: left;">Construct</th>',
      '<th style="padding: 12px; text-align: center;">Score</th>',
      '</tr>',

      paste0(sapply(names(construct_scores), function(construct) {
        score <- round(construct_scores[[construct]], 2)
        paste0(
          '<tr style="border-bottom: 1px solid #ddd;">',
          '<td style="padding: 12px;"><strong>', construct, '</strong></td>',
          '<td style="padding: 12px; text-align: center;"><span style="background-color:#2E8B57; color: white; padding: 4px 8px; border-radius: 4px;">', score, '</span></td>',
          '</tr>'
        )
      }), collapse = ''),

      '<tr style="background-color: #e8f5e9;">',
      '<td style="padding: 12px;"><strong>Overall Average</strong></td>',
      '<td style="padding: 12px; text-align: center;"><span style="background-color:#2E8B57; color: white; padding: 4px 8px; border-radius: 4px; font-weight: bold;">', round(mean_score, 2), '</span></td>',
      '</tr>',

      '</table>',
      '</div>',

      '<div style="margin-top: 30px;">',
      '<h2 style="color: #2E8B57;">Thank you for participating!</h2>',
      '<p>Your responses have been recorded. Scores range from 1 (low) to 5 (high); 3 is the midpoint of the scale.</p>',
      '</div>',

      '</div>'
    )
    
    return(shiny::HTML(html_report))
    
  }, error = function(e) {
    message("Error in create_testing_report: ", e$message)
    return(shiny::HTML('<div style="padding: 20px;"><h2>Error generating report</h2><p>An error occurred while generating your results.</p></div>'))
  })
}

# Configuration ----
enhanced_study_config <- create_study_config(
  name = "Psychological Study on R Package Testing Experience",
  study_key = "advanced_r_testing_psych_2025",
  
  theme = "Monochrome",
  
  demographics = c("age_range", "r_experience", "developer_role"),
  input_types = list(
    age_range = "select",
    r_experience = "select",
    developer_role = "select"
  ),
  
  model = "GRM",
  adaptive = FALSE,
  max_items = 8,
  min_items = 8,
  
  session_save = TRUE,
  max_session_duration = 25,  # minutes; only checked in select_next_item()

  response_ui_type = "radio",
  progress_style = "bar",

  # Used for the single-item pages of the default (non page-flow) layout
  response_validation_fun = function(response) {
    !is.null(response) && nzchar(as.character(response))
  },

  demographic_configs = enhanced_demographics,

  results_processor = create_testing_report
)

# Launch ----
launch_enhanced_study <- function() {
  launch_study(
    config = enhanced_study_config,
    item_bank = advanced_psychological_items,
    port = 3838
  )
}

# Preview of the report with made-up responses
create_demo_report <- function() {
  demo_responses <- c(4, 2, 4, 3, 5, 2, 4, 1)

  demo_html <- create_testing_report(
    responses = demo_responses,
    item_bank = advanced_psychological_items
  )

  return(demo_html)
}

