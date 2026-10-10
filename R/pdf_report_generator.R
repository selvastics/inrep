# File: pdf_report_generator.R

#' Generate PDF Report for inrep Studies
#'
#' Writes an R Markdown file with the study name, number of items, the ability
#' estimate and its standard error (if present in \code{study_data}), optional
#' plots and Big Five or programming-anxiety scores found in \code{study_data},
#' and renders it to PDF with \code{rmarkdown::render()} (a LaTeX installation
#' is required).
#'
#' @param study_data List containing study results and participant data, e.g.
#'   \code{responses}, \code{theta_history}, \code{theta_estimate},
#'   \code{theta_se}, and scores named \code{BFI_*}.
#' @param study_config Study configuration object
#' @param output_file Path to output PDF file
#' @param include_images Logical indicating whether to include generated plots
#' @param language Language for report ("en" or "de")
#' @return Path to generated PDF file
#' @export
generate_inrep_pdf_report <- function(study_data, study_config, output_file,
                                    include_images = TRUE, language = "en") {

  required_packages <- c("rmarkdown", "knitr", "ggplot2")
  missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
  
  if (length(missing_packages) > 0) {
    stop("Missing required packages for PDF generation: ", paste(missing_packages, collapse = ", "))
  }
  
  # render() resolves a relative output_file against the Rmd's directory, which
  # is deleted below, so make the path absolute first.
  output_file <- file.path(normalizePath(dirname(output_file), mustWork = FALSE),
                           basename(output_file))

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
  
  # pdf_document() has no css argument, so no stylesheet is passed.
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
        fig_height = 6
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
    ggplot2::ggsave(theta_file, theta_plot, width = 8, height = 6, dpi = 300)
    plots$theta_progression <- theta_file
  }
  
  # 2. Response pattern plot
  if (length(responses) > 0) {
    response_plot <- create_response_pattern_plot(responses)
    response_file <- file.path(output_dir, "response_pattern.png")
    ggplot2::ggsave(response_file, response_plot, width = 8, height = 6, dpi = 300)
    plots$response_pattern <- response_file
  }
  
  # 3. Personality radar plot (if BFI data available)
  if (any(grepl("BFI_", names(study_data)))) {
    radar_plot <- create_personality_radar_plot(study_data)
    radar_file <- file.path(output_dir, "personality_radar.png")
    ggplot2::ggsave(radar_file, radar_plot, width = 8, height = 8, dpi = 300)
    plots$personality_radar <- radar_file
  }
  
  # 4. Programming anxiety plot (if available)
  if (any(grepl("ProgrammingAnxiety|PA", names(study_data)))) {
    anxiety_plot <- create_anxiety_plot(study_data)
    anxiety_file <- file.path(output_dir, "programming_anxiety.png")
    ggplot2::ggsave(anxiety_file, anxiety_plot, width = 8, height = 6, dpi = 300)
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
  # No default values: the ability lines are only written when an estimate exists
  theta_estimate <- study_data$theta_estimate
  theta_se <- study_data$theta_se
  has_theta <- is.numeric(theta_estimate) && length(theta_estimate) == 1 && is.finite(theta_estimate)
  has_se <- is.numeric(theta_se) && length(theta_se) == 1 && is.finite(theta_se)

  content <- c(
    "---",
    paste0("title: '", study_name, " - ", ifelse(is_english, "Results Report", "Ergebnisbericht"), "'"),
    "author: 'inrep'",
    paste0("date: '`r format(Sys.Date(), \"", ifelse(is_english, "%B %d, %Y", "%d. %B %Y"), "\")`'"),
    "output:",
    "  pdf_document:",
    "    toc: true",
    "    toc_depth: 2",
    "    number_sections: true",
    "    fig_width: 8",
    "    fig_height: 6",
    "---",
    "",
    "```{r setup, include=FALSE}",
    "knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)",
    "```",
    "",
    ifelse(is_english, "# Summary", "# Zusammenfassung"),
    "",
    ifelse(is_english,
           "This report summarises your results in this study.",
           "Dieser Bericht fasst Ihre Ergebnisse in dieser Studie zusammen."),
    "",
    "## " %+% ifelse(is_english, "Details", "Details"),
    "",
    "- **" %+% ifelse(is_english, "Study Name", "Studienname") %+% ":** " %+% study_name,
    "- **" %+% ifelse(is_english, "Date", "Datum") %+% ":** `r format(Sys.Date(), \"%Y-%m-%d\")`",
    "- **" %+% ifelse(is_english, "Items Administered", "Vorgelegte Items") %+% ":** " %+% length(responses),
    if (has_theta) "- **" %+% ifelse(is_english, "Ability Estimate (\u03B8)", "F\u00E4higkeitssch\u00E4tzung (\u03B8)") %+% ":** " %+% sprintf("%.3f", theta_estimate),
    if (has_theta && has_se) "- **" %+% ifelse(is_english, "Standard Error", "Standardfehler") %+% ":** " %+% sprintf("%.3f", theta_se),
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
  
  if (has_theta) {
    content <- c(content,
      "",
      "## " %+% ifelse(is_english, "Ability Estimate", "F\u00E4higkeitssch\u00E4tzung"),
      "",
      ifelse(is_english,
             "The estimate is based on your responses to " %+% length(responses) %+% " items and was computed with an item response theory model whose item parameters were fixed in advance.",
             "Die Sch\u00E4tzung beruht auf Ihren Antworten zu " %+% length(responses) %+% " Items und wurde mit einem Item-Response-Modell mit vorab festgelegten Itemparametern berechnet."),
      ""
    )
  }
  
  # Add personality results if available
  if (any(grepl("BFI_", names(study_data)))) {
    content <- c(content,
      "",
      "### " %+% ifelse(is_english, "Personality Profile (Big Five)", "Pers\u00F6nlichkeitsprofil (Big Five)"),
      "",
      ifelse(is_english,
             "Your personality profile based on the Big Five personality dimensions:",
             "Ihr Pers\u00F6nlichkeitsprofil basierend auf den Big Five Pers\u00F6nlichkeitsdimensionen:"),
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
  
  content <- c(content,
    "",
    "## " %+% ifelse(is_english, "Technical Information", "Technische Informationen"),
    "",
    ifelse(is_english,
           "This report was generated with the R package inrep.",
           "Dieser Bericht wurde mit dem R-Paket inrep erstellt."),
    "",
    "---",
    "",
    ifelse(is_english,
           "*Thank you for participating in this study!*",
           "*Vielen Dank f\u00FCr Ihre Teilnahme an dieser Studie!*")
  )
  
  return(content)
}

#' Create Report CSS
#'
#' Returns a stylesheet for HTML output. It is not used by
#' \code{\link{generate_inrep_pdf_report}}, since PDF output ignores CSS.
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
    theta_progression = ifelse(is_english, "Ability Progression", "F\u00E4higkeitsentwicklung"),
    response_pattern = ifelse(is_english, "Response Pattern", "Antwortmuster"),
    personality_radar = ifelse(is_english, "Personality Profile", "Pers\u00F6nlichkeitsprofil"),
    programming_anxiety = ifelse(is_english, "Programming Anxiety", "Programmierangst")
  )
  return(titles[[plot_name]] %||% plot_name)
}

get_plot_caption <- function(plot_name, is_english) {
  captions <- list(
    theta_progression = ifelse(is_english, "Development of ability estimate during assessment", "Entwicklung der F\u00E4higkeitssch\u00E4tzung w\u00E4hrend der Bewertung"),
    response_pattern = ifelse(is_english, "Pattern of responses across items", "Antwortmuster \u00FCber die Items"),
    personality_radar = ifelse(is_english, "Personality profile across Big Five dimensions", "Pers\u00F6nlichkeitsprofil \u00FCber Big Five Dimensionen"),
    programming_anxiety = ifelse(is_english, "Programming anxiety and related factors", "Programmierangst und verwandte Faktoren")
  )
  return(captions[[plot_name]] %||% "")
}

get_trait_name <- function(trait, is_english) {
  names <- list(
    BFI_Extraversion = ifelse(is_english, "Extraversion", "Extraversion"),
    BFI_Agreeableness = ifelse(is_english, "Agreeableness", "Vertr\u00E4glichkeit"),
    BFI_Conscientiousness = ifelse(is_english, "Conscientiousness", "Gewissenhaftigkeit"),
    BFI_Neuroticism = ifelse(is_english, "Neuroticism", "Neurotizismus"),
    BFI_Openness = ifelse(is_english, "Openness", "Offenheit")
  )
  return(names[[trait]] %||% trait)
}

# Fixed cut-offs on a 1-5 mean score, not norms: the labels describe the
# position on the response scale only.
get_score_interpretation <- function(score, trait, is_english) {
  if (score < 2.5) {
    return(ifelse(is_english, "below 2.5 on the 1-5 scale", "unter 2,5 auf der Skala 1-5"))
  } else if (score > 3.5) {
    return(ifelse(is_english, "above 3.5 on the 1-5 scale", "\u00fcber 3,5 auf der Skala 1-5"))
  } else {
    return(ifelse(is_english, "between 2.5 and 3.5 on the 1-5 scale", "zwischen 2,5 und 3,5 auf der Skala 1-5"))
  }
}

get_anxiety_factor_name <- function(factor, is_english) {
  names <- list(
    ProgrammingAnxiety = ifelse(is_english, "Programming Anxiety", "Programmierangst"),
    PSQ_Stress = ifelse(is_english, "Stress", "Stress"),
    MWS_Studierfaehigkeiten = ifelse(is_english, "Study Skills", "Studierf\u00E4higkeiten"),
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

# Plot creation functions
create_theta_progression_plot <- function(theta_history) {
  if (length(theta_history) < 2) return(NULL)
  
  df <- data.frame(
    Item = 1:length(theta_history),
    Theta = theta_history
  )
  
  ggplot2::ggplot(df, ggplot2::aes(x = Item, y = Theta)) +
    ggplot2::geom_line(color = "#3498db", linewidth = 1) +
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
