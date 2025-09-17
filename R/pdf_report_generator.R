# File: pdf_report_generator.R

#' Generate PDF Report for inrep Studies
#'
#' Creates comprehensive PDF reports with images, charts, and detailed analysis
#' for inrep study results.
#'
#' @param study_data List containing study results and participant data
#' @param study_config Study configuration object
#' @param output_file Path to output PDF file
#' @param include_images Logical indicating whether to include generated plots
#' @param language Language for report ("en" or "de")
#' @return Path to generated PDF file
#' @export
generate_inrep_pdf_report <- function(study_data, study_config, output_file, 
                                    include_images = TRUE, language = "en") {
  
  # Check required packages
  required_packages <- c("rmarkdown", "knitr", "ggplot2", "DT", "plotly")
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  
  if (length(missing_packages) > 0) {
    stop("Missing required packages for PDF generation: ", paste(missing_packages, collapse = ", "))
  }
  
  # Create temporary directory for report generation
  temp_dir <- tempdir()
  report_dir <- file.path(temp_dir, "inrep_report")
  dir.create(report_dir, showWarnings = FALSE)
  
  # Generate plots if requested
  plot_files <- list()
  if (include_images) {
    plot_files <- generate_report_plots(study_data, study_config, report_dir)
  }
  
  # Create R Markdown content
  rmd_content <- create_rmd_content(study_data, study_config, plot_files, language)
  
  # Write R Markdown file
  rmd_file <- file.path(report_dir, "report.Rmd")
  writeLines(rmd_content, rmd_file)
  
  # Create CSS file for styling
  css_file <- file.path(report_dir, "report.css")
  writeLines(create_report_css(), css_file)
  
  # Render PDF
  tryCatch({
    rmarkdown::render(
      input = rmd_file,
      output_file = output_file,
      output_format = "pdf_document",
      output_options = list(
        toc = TRUE,
        toc_depth = 2,
        number_sections = TRUE,
        fig_width = 8,
        fig_height = 6,
        css = css_file
      ),
      quiet = TRUE
    )
    
    # Clean up temporary files
    unlink(report_dir, recursive = TRUE)
    
    return(output_file)
    
  }, error = function(e) {
    # Clean up on error
    unlink(report_dir, recursive = TRUE)
    stop("PDF generation failed: ", e$message)
  })
}

#' Generate Plots for PDF Report
#'
#' @param study_data Study data
#' @param study_config Study configuration
#' @param output_dir Output directory for plots
#' @return List of plot file paths
#' @export
generate_report_plots <- function(study_data, study_config, output_dir) {
  plots <- list()
  
  # Extract data
  responses <- study_data$responses %||% numeric(0)
  theta_history <- study_data$theta_history %||% numeric(0)
  demographics <- study_data$demographics %||% list()
  
  # 1. Theta progression plot (if adaptive)
  if (length(theta_history) > 1) {
    theta_plot <- create_theta_progression_plot(theta_history)
    theta_file <- file.path(output_dir, "theta_progression.png")
    ggsave(theta_file, theta_plot, width = 8, height = 6, dpi = 300)
    plots$theta_progression <- theta_file
  }
  
  # 2. Response pattern plot
  if (length(responses) > 0) {
    response_plot <- create_response_pattern_plot(responses)
    response_file <- file.path(output_dir, "response_pattern.png")
    ggsave(response_file, response_plot, width = 8, height = 6, dpi = 300)
    plots$response_pattern <- response_file
  }
  
  # 3. Personality radar plot (if BFI data available)
  if (any(grepl("BFI_", names(study_data)))) {
    radar_plot <- create_personality_radar_plot(study_data)
    radar_file <- file.path(output_dir, "personality_radar.png")
    ggsave(radar_file, radar_plot, width = 8, height = 8, dpi = 300)
    plots$personality_radar <- radar_file
  }
  
  # 4. Programming anxiety plot (if available)
  if (any(grepl("ProgrammingAnxiety|PA", names(study_data)))) {
    anxiety_plot <- create_anxiety_plot(study_data)
    anxiety_file <- file.path(output_dir, "programming_anxiety.png")
    ggsave(anxiety_file, anxiety_plot, width = 8, height = 6, dpi = 300)
    plots$programming_anxiety <- anxiety_file
  }
  
  return(plots)
}

#' Create R Markdown Content
#'
#' @param study_data Study data
#' @param study_config Study configuration
#' @param plot_files List of plot file paths
#' @param language Report language
#' @return R Markdown content as character vector
#' @export
create_rmd_content <- function(study_data, study_config, plot_files, language = "en") {
  
  # Language settings
  is_english <- language == "en"
  
  # Extract data
  study_name <- study_config$name %||% "inrep Study"
  responses <- study_data$responses %||% numeric(0)
  theta_estimate <- study_data$theta_estimate %||% 0
  theta_se <- study_data$theta_se %||% 1
  demographics <- study_data$demographics %||% list()
  
  # Create content
  content <- c(
    "---",
    paste0("title: '", study_name, " - ", ifelse(is_english, "Results Report", "Ergebnisbericht"), "'"),
    paste0("author: '", ifelse(is_english, "inrep Assessment System", "inrep Bewertungssystem"), "'"),
    paste0("date: '`r format(Sys.Date(), \"", ifelse(is_english, "%B %d, %Y", "%d. %B %Y"), "\")`'"),
    "output:",
    "  pdf_document:",
    "    toc: true",
    "    toc_depth: 2",
    "    number_sections: true",
    "    fig_width: 8",
    "    fig_height: 6",
    "    css: report.css",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)",
    "library(ggplot2)",
    "library(DT)",
    "```",
    "",
    ifelse(is_english, "# Executive Summary", "# Zusammenfassung"),
    "",
    ifelse(is_english, 
           "This report presents the results of your participation in the inrep assessment study. The assessment utilized advanced psychometric methods to provide accurate and reliable measurements of your abilities and characteristics.",
           "Dieser Bericht präsentiert die Ergebnisse Ihrer Teilnahme an der inrep-Bewertungsstudie. Die Bewertung nutzte fortgeschrittene psychometrische Methoden, um genaue und zuverlässige Messungen Ihrer Fähigkeiten und Eigenschaften zu liefern."),
    "",
    "## " %+% ifelse(is_english, "Assessment Details", "Bewertungsdetails"),
    "",
    "- **" %+% ifelse(is_english, "Study Name", "Studienname") %+% ":** " %+% study_name,
    "- **" %+% ifelse(is_english, "Date", "Datum") %+% ":** `r format(Sys.Date(), \"%Y-%m-%d\")`",
    "- **" %+% ifelse(is_english, "Items Administered", "Verwaltete Items") %+% ":** " %+% length(responses),
    "- **" %+% ifelse(is_english, "Ability Estimate (θ)", "Fähigkeitsschätzung (θ)") %+% ":** " %+% sprintf("%.3f", theta_estimate),
    "- **" %+% ifelse(is_english, "Standard Error", "Standardfehler") %+% ":** " %+% sprintf("%.3f", theta_se),
    ""
  )
  
  # Add plots section
  if (length(plot_files) > 0) {
    content <- c(content,
      "",
      "## " %+% ifelse(is_english, "Visualizations", "Visualisierungen"),
      ""
    )
    
    # Add each plot
    for (plot_name in names(plot_files)) {
      plot_file <- plot_files[[plot_name]]
      if (file.exists(plot_file)) {
        content <- c(content,
          "",
          "### " %+% get_plot_title(plot_name, is_english),
          "",
          "```{r " %+% plot_name %+% ", fig.cap='" %+% get_plot_caption(plot_name, is_english) %+% "'}",
          "knitr::include_graphics('" %+% basename(plot_file) %+% "')",
          "```",
          ""
        )
      }
    }
  }
  
  # Add results section
  content <- c(content,
    "",
    "## " %+% ifelse(is_english, "Detailed Results", "Detaillierte Ergebnisse"),
    "",
    "### " %+% ifelse(is_english, "Ability Estimation", "Fähigkeitsschätzung"),
    "",
    "Your estimated ability level is **" %+% sprintf("%.3f", theta_estimate) %+% "** with a standard error of **" %+% sprintf("%.3f", theta_se) %+% "**.",
    "",
    ifelse(is_english,
           "This estimate is based on your responses to " %+% length(responses) %+% " items using advanced Item Response Theory (IRT) methods.",
           "Diese Schätzung basiert auf Ihren Antworten zu " %+% length(responses) %+% " Items unter Verwendung fortgeschrittener Item-Response-Theory (IRT) Methoden."),
    ""
  )
  
  # Add personality results if available
  if (any(grepl("BFI_", names(study_data)))) {
    content <- c(content,
      "",
      "### " %+% ifelse(is_english, "Personality Profile (Big Five)", "Persönlichkeitsprofil (Big Five)"),
      "",
      ifelse(is_english,
             "Your personality profile based on the Big Five personality dimensions:",
             "Ihr Persönlichkeitsprofil basierend auf den Big Five Persönlichkeitsdimensionen:"),
      ""
    )
    
    # Add personality scores
    bfi_scores <- extract_bfi_scores(study_data)
    for (trait in names(bfi_scores)) {
      score <- bfi_scores[[trait]]
      content <- c(content,
        "- **" %+% get_trait_name(trait, is_english) %+% ":** " %+% sprintf("%.2f", score) %+% " (" %+% get_score_interpretation(score, trait, is_english) %+% ")"
      )
    }
    content <- c(content, "")
  }
  
  # Add programming anxiety if available
  if (any(grepl("ProgrammingAnxiety|PA", names(study_data)))) {
    content <- c(content,
      "",
      "### " %+% ifelse(is_english, "Programming Anxiety", "Programmierangst"),
      "",
      ifelse(is_english,
             "Your programming anxiety level and related factors:",
             "Ihr Programmierangstniveau und verwandte Faktoren:"),
      ""
    )
    
    # Add anxiety scores
    anxiety_scores <- extract_anxiety_scores(study_data)
    for (factor in names(anxiety_scores)) {
      score <- anxiety_scores[[factor]]
      content <- c(content,
        "- **" %+% get_anxiety_factor_name(factor, is_english) %+% ":** " %+% sprintf("%.2f", score)
      )
    }
    content <- c(content, "")
  }
  
  # Add recommendations
  content <- c(content,
    "",
    "## " %+% ifelse(is_english, "Recommendations", "Empfehlungen"),
    "",
    ifelse(is_english,
           "Based on your assessment results, we recommend:",
           "Basierend auf Ihren Bewertungsergebnissen empfehlen wir:"),
    "",
    generate_recommendations(study_data, is_english),
    ""
  )
  
  # Add technical details
  content <- c(content,
    "",
    "## " %+% ifelse(is_english, "Technical Information", "Technische Informationen"),
    "",
    ifelse(is_english,
           "This report was generated using the inrep (Instant Reports) package for adaptive psychological assessments. The assessment utilized Item Response Theory (IRT) methods for ability estimation and item selection.",
           "Dieser Bericht wurde mit dem inrep (Instant Reports) Paket für adaptive psychologische Bewertungen erstellt. Die Bewertung nutzte Item-Response-Theory (IRT) Methoden für Fähigkeitsschätzung und Itemauswahl."),
    "",
    "---",
    "",
    ifelse(is_english,
           "*Thank you for participating in this study!*",
           "*Vielen Dank für Ihre Teilnahme an dieser Studie!*")
  )
  
  return(content)
}

#' Create Report CSS
#'
#' @return CSS content as character vector
#' @export
create_report_css <- function() {
  return(c(
    "body {",
    "  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;",
    "  line-height: 1.6;",
    "  color: #333;",
    "}",
    "",
    "h1, h2, h3, h4, h5, h6 {",
    "  color: #2c3e50;",
    "  margin-top: 1.5em;",
    "  margin-bottom: 0.5em;",
    "}",
    "",
    "h1 {",
    "  border-bottom: 3px solid #3498db;",
    "  padding-bottom: 10px;",
    "}",
    "",
    "h2 {",
    "  border-bottom: 2px solid #ecf0f1;",
    "  padding-bottom: 5px;",
    "}",
    "",
    "table {",
    "  border-collapse: collapse;",
    "  width: 100%;",
    "  margin: 1em 0;",
    "}",
    "",
    "th, td {",
    "  border: 1px solid #ddd;",
    "  padding: 8px;",
    "  text-align: left;",
    "}",
    "",
    "th {",
    "  background-color: #f2f2f2;",
    "  font-weight: bold;",
    "}",
    "",
    ".highlight {",
    "  background-color: #fff3cd;",
    "  border: 1px solid #ffeaa7;",
    "  padding: 10px;",
    "  border-radius: 4px;",
    "  margin: 10px 0;",
    "}",
    "",
    "img {",
    "  max-width: 100%;",
    "  height: auto;",
    "  display: block;",
    "  margin: 0 auto;",
    "}"
  ))
}

# Helper functions
`%+%` <- function(a, b) paste0(a, b)

get_plot_title <- function(plot_name, is_english) {
  titles <- list(
    theta_progression = ifelse(is_english, "Ability Progression", "Fähigkeitsentwicklung"),
    response_pattern = ifelse(is_english, "Response Pattern", "Antwortmuster"),
    personality_radar = ifelse(is_english, "Personality Profile", "Persönlichkeitsprofil"),
    programming_anxiety = ifelse(is_english, "Programming Anxiety", "Programmierangst")
  )
  return(titles[[plot_name]] %||% plot_name)
}

get_plot_caption <- function(plot_name, is_english) {
  captions <- list(
    theta_progression = ifelse(is_english, "Development of ability estimate during assessment", "Entwicklung der Fähigkeitsschätzung während der Bewertung"),
    response_pattern = ifelse(is_english, "Pattern of responses across items", "Antwortmuster über die Items"),
    personality_radar = ifelse(is_english, "Personality profile across Big Five dimensions", "Persönlichkeitsprofil über Big Five Dimensionen"),
    programming_anxiety = ifelse(is_english, "Programming anxiety and related factors", "Programmierangst und verwandte Faktoren")
  )
  return(captions[[plot_name]] %||% "")
}

get_trait_name <- function(trait, is_english) {
  names <- list(
    BFI_Extraversion = ifelse(is_english, "Extraversion", "Extraversion"),
    BFI_Agreeableness = ifelse(is_english, "Agreeableness", "Verträglichkeit"),
    BFI_Conscientiousness = ifelse(is_english, "Conscientiousness", "Gewissenhaftigkeit"),
    BFI_Neuroticism = ifelse(is_english, "Neuroticism", "Neurotizismus"),
    BFI_Openness = ifelse(is_english, "Openness", "Offenheit")
  )
  return(names[[trait]] %||% trait)
}

get_score_interpretation <- function(score, trait, is_english) {
  if (score < 2.5) {
    return(ifelse(is_english, "Low", "Niedrig"))
  } else if (score > 3.5) {
    return(ifelse(is_english, "High", "Hoch"))
  } else {
    return(ifelse(is_english, "Average", "Durchschnittlich"))
  }
}

get_anxiety_factor_name <- function(factor, is_english) {
  names <- list(
    ProgrammingAnxiety = ifelse(is_english, "Programming Anxiety", "Programmierangst"),
    PSQ_Stress = ifelse(is_english, "Stress", "Stress"),
    MWS_Studierfaehigkeiten = ifelse(is_english, "Study Skills", "Studierfähigkeiten"),
    Statistik = ifelse(is_english, "Statistics", "Statistik")
  )
  return(names[[factor]] %||% factor)
}

extract_bfi_scores <- function(study_data) {
  bfi_vars <- names(study_data)[grepl("BFI_", names(study_data))]
  scores <- list()
  for (var in bfi_vars) {
    scores[[var]] <- study_data[[var]] %||% 0
  }
  return(scores)
}

extract_anxiety_scores <- function(study_data) {
  anxiety_vars <- names(study_data)[grepl("ProgrammingAnxiety|PA|PSQ_|MWS_|Statistik", names(study_data))]
  scores <- list()
  for (var in anxiety_vars) {
    scores[[var]] <- study_data[[var]] %||% 0
  }
  return(scores)
}

generate_recommendations <- function(study_data, is_english) {
  recommendations <- c()
  
  # Add general recommendations based on data
  if (is_english) {
    recommendations <- c(recommendations,
      "- Continue developing your skills in areas of interest",
      "- Consider seeking additional support in areas where you feel less confident",
      "- Regular practice and feedback can help improve performance"
    )
  } else {
    recommendations <- c(recommendations,
      "- Entwickeln Sie weiterhin Ihre Fähigkeiten in Bereichen von Interesse",
      "- Erwägen Sie zusätzliche Unterstützung in Bereichen, in denen Sie sich weniger sicher fühlen",
      "- Regelmäßige Übung und Feedback können die Leistung verbessern"
    )
  }
  
  return(paste(recommendations, collapse = "\n"))
}

# Plot creation functions
create_theta_progression_plot <- function(theta_history) {
  if (length(theta_history) < 2) return(NULL)
  
  df <- data.frame(
    Item = 1:length(theta_history),
    Theta = theta_history
  )
  
  ggplot2::ggplot(df, ggplot2::aes(x = Item, y = Theta)) +
    ggplot2::geom_line(color = "#3498db", size = 1) +
    ggplot2::geom_point(color = "#2980b9", size = 2) +
    ggplot2::labs(
      title = "Ability Progression During Assessment",
      x = "Item Number",
      y = "Theta Estimate"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    )
}

create_response_pattern_plot <- function(responses) {
  if (length(responses) == 0) return(NULL)
  
  df <- data.frame(
    Item = 1:length(responses),
    Response = responses
  )
  
  ggplot2::ggplot(df, ggplot2::aes(x = Item, y = Response)) +
    ggplot2::geom_point(color = "#e74c3c", size = 3, alpha = 0.7) +
    ggplot2::geom_line(color = "#c0392b", alpha = 0.5) +
    ggplot2::labs(
      title = "Response Pattern Across Items",
      x = "Item Number",
      y = "Response Value"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10)
    )
}

create_personality_radar_plot <- function(study_data) {
  bfi_scores <- extract_bfi_scores(study_data)
  if (length(bfi_scores) == 0) return(NULL)
  
  # Create radar plot data
  traits <- c("Extraversion", "Agreeableness", "Conscientiousness", "Neuroticism", "Openness")
  values <- c(
    bfi_scores$BFI_Extraversion %||% 0,
    bfi_scores$BFI_Agreeableness %||% 0,
    bfi_scores$BFI_Conscientiousness %||% 0,
    bfi_scores$BFI_Neuroticism %||% 0,
    bfi_scores$BFI_Openness %||% 0
  )
  
  df <- data.frame(
    trait = factor(traits, levels = traits),
    value = values
  )
  
  ggplot2::ggplot(df, ggplot2::aes(x = trait, y = value)) +
    ggplot2::geom_col(fill = "#9b59b6", alpha = 0.7) +
    ggplot2::coord_polar() +
    ggplot2::labs(
      title = "Personality Profile (Big Five)",
      x = "",
      y = ""
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.text.x = ggplot2::element_text(size = 10),
      panel.grid = ggplot2::element_line(color = "grey90")
    )
}

create_anxiety_plot <- function(study_data) {
  anxiety_scores <- extract_anxiety_scores(study_data)
  if (length(anxiety_scores) == 0) return(NULL)
  
  df <- data.frame(
    factor = names(anxiety_scores),
    score = unlist(anxiety_scores)
  )
  
  ggplot2::ggplot(df, ggplot2::aes(x = factor, y = score)) +
    ggplot2::geom_col(fill = "#e67e22", alpha = 0.7) +
    ggplot2::labs(
      title = "Programming Anxiety and Related Factors",
      x = "Factor",
      y = "Score"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 14, face = "bold"),
      axis.title = ggplot2::element_text(size = 12),
      axis.text = ggplot2::element_text(size = 10),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )
}