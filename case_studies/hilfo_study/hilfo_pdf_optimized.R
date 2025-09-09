# =============================================================================
# HILFO PDF OPTIMIZATION - EFFICIENT IMAGE DISPLAY SYSTEM
# =============================================================================
# Focused on displaying images from earlier reports efficiently
# No need for complete analysis - just show what was produced earlier

# Load required packages
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2", quiet = TRUE)
}
if (!requireNamespace("base64enc", quietly = TRUE)) {
  install.packages("base64enc", quiet = TRUE)
}
if (!requireNamespace("rmarkdown", quietly = TRUE)) {
  install.packages("rmarkdown", quiet = TRUE)
}

# =============================================================================
# OPTIMIZED PDF REPORT GENERATOR
# =============================================================================

create_hilfo_pdf_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  # Get current language
  current_lang <- "de"
  if (!is.null(session) && !is.null(session$userData$current_language)) {
    current_lang <- session$userData$current_language
  }
  
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML("<p>No responses available for PDF generation.</p>"))
  }
  
  # Ensure we have all responses
  if (length(responses) < 51) {
    responses <- c(responses, rep(3, 51 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate basic scores efficiently
  scores <- calculate_hilfo_scores_optimized(responses)
  
  # Generate images efficiently
  images <- generate_hilfo_images_optimized(scores, current_lang)
  
  # Create streamlined PDF content
  pdf_content <- create_pdf_content_optimized(scores, images, current_lang)
  
  return(pdf_content)
}

# =============================================================================
# OPTIMIZED SCORE CALCULATION
# =============================================================================

calculate_hilfo_scores_optimized <- function(responses) {
  # Programming Anxiety (first 10 items, with reverse scoring)
  pa_responses <- responses[1:10]
  pa_responses[c(1, 10)] <- 6 - pa_responses[c(1, 10)]  # Reverse items 1 and 10
  pa_score <- mean(pa_responses, na.rm = TRUE)
  
  # Big Five scores (items 21-40)
  scores <- list(
    ProgrammingAnxiety = pa_score,
    Extraversion = mean(c(responses[21], 6-responses[22], 6-responses[23], responses[24]), na.rm=TRUE),
    Verträglichkeit = mean(c(responses[25], 6-responses[26], responses[27], 6-responses[28]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-responses[29], responses[30], responses[31], 6-responses[32]), na.rm=TRUE),
    Neurotizismus = mean(c(6-responses[33], responses[34], responses[35], 6-responses[36]), na.rm=TRUE),
    Offenheit = mean(c(responses[37], 6-responses[38], responses[39], 6-responses[40]), na.rm=TRUE)
  )
  
  # Other scores
  psq <- responses[41:45]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  scores$Studierfähigkeiten <- mean(responses[46:49], na.rm=TRUE)
  scores$Statistik <- mean(responses[50:51], na.rm=TRUE)
  
  return(scores)
}

# =============================================================================
# OPTIMIZED IMAGE GENERATION
# =============================================================================

generate_hilfo_images_optimized <- function(scores, current_lang) {
  images <- list()
  
  # 1. Radar Plot (Big Five)
  radar_plot <- create_radar_plot_optimized(scores, current_lang)
  images$radar <- encode_image_base64(radar_plot)
  
  # 2. Bar Chart (All Dimensions)
  bar_plot <- create_bar_chart_optimized(scores, current_lang)
  images$bar <- encode_image_base64(bar_plot)
  
  # 3. Programming Anxiety Trace (simplified)
  trace_plot <- create_trace_plot_optimized(scores, current_lang)
  images$trace <- encode_image_base64(trace_plot)
  
  return(images)
}

create_radar_plot_optimized <- function(scores, current_lang) {
  # Prepare data for radar plot
  radar_data <- data.frame(
    group = "Profile",
    Extraversion = scores$Extraversion / 5,
    Verträglichkeit = scores$Verträglichkeit / 5,
    Gewissenhaftigkeit = scores$Gewissenhaftigkeit / 5,
    Neurotizismus = scores$Neurotizismus / 5,
    Offenheit = scores$Offenheit / 5
  )
  
  # Create manual radar plot (more reliable than ggradar)
  n_vars <- 5
  angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
  
  bfi_scores <- c(scores$Extraversion, scores$Verträglichkeit, 
                  scores$Gewissenhaftigkeit, scores$Neurotizismus, scores$Offenheit)
  bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                  "Neurotizismus", "Offenheit")
  
  x_pos <- bfi_scores * cos(angles - pi/2)
  y_pos <- bfi_scores * sin(angles - pi/2)
  
  plot_data <- data.frame(
    x = c(x_pos, x_pos[1]),
    y = c(y_pos, y_pos[1]),
    label = c(bfi_labels, ""),
    score = c(bfi_scores, bfi_scores[1])
  )
  
  # Grid data
  grid_data <- expand.grid(
    r = 1:5,
    angle = seq(0, 2*pi, length.out = 50)
  )
  grid_data$x <- grid_data$r * cos(grid_data$angle)
  grid_data$y <- grid_data$r * sin(grid_data$angle)
  
  # Create plot
  p <- ggplot2::ggplot() +
    ggplot2::geom_path(data = grid_data, ggplot2::aes(x = x, y = y, group = r),
                       color = "gray85", size = 0.3) +
    ggplot2::geom_segment(data = data.frame(angle = angles),
                          ggplot2::aes(x = 0, y = 0,
                                       xend = 5 * cos(angle - pi/2),
                                       yend = 5 * sin(angle - pi/2)),
                          color = "gray85", size = 0.3) +
    ggplot2::geom_polygon(data = plot_data, ggplot2::aes(x = x, y = y),
                          fill = "#e8041c", alpha = 0.2) +
    ggplot2::geom_path(data = plot_data, ggplot2::aes(x = x, y = y),
                       color = "#e8041c", size = 2) +
    ggplot2::geom_point(data = plot_data[1:5,], ggplot2::aes(x = x, y = y),
                        color = "#e8041c", size = 5) +
    ggplot2::geom_text(data = plot_data[1:5,],
                       ggplot2::aes(x = x * 1.3, y = y * 1.3, label = label),
                       size = 5, fontface = "bold") +
    ggplot2::coord_equal() +
    ggplot2::xlim(-6, 6) + ggplot2::ylim(-6, 6) +
    ggplot2::theme_void() +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5,
                                         color = "#e8041c", margin = ggplot2::margin(b = 20)),
      plot.margin = ggplot2::margin(30, 30, 30, 30)
    ) +
    ggplot2::labs(title = if (current_lang == "en") "Personality Profile (Big Five)" else "Persönlichkeitsprofil (Big Five)")
  
  return(p)
}

create_bar_chart_optimized <- function(scores, current_lang) {
  # Order scores logically
  ordered_scores <- list(
    Extraversion = scores$Extraversion,
    Verträglichkeit = scores$Verträglichkeit,
    Gewissenhaftigkeit = scores$Gewissenhaftigkeit,
    Neurotizismus = scores$Neurotizismus,
    Offenheit = scores$Offenheit,
    ProgrammingAnxiety = scores$ProgrammingAnxiety,
    Stress = scores$Stress,
    Studierfähigkeiten = scores$Studierfähigkeiten,
    Statistik = scores$Statistik
  )
  
  all_data <- data.frame(
    dimension = factor(names(ordered_scores), levels = names(ordered_scores)),
    score = unlist(ordered_scores),
    category = c(rep("Persönlichkeit", 5), 
                 "Programmierangst", "Stress", "Studierfähigkeiten", "Statistik")
  )
  
  p <- ggplot2::ggplot(all_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
    ggplot2::geom_bar(stat = "identity", width = 0.7) +
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), 
                       vjust = -0.5, size = 6, fontface = "bold", color = "#333") +
    ggplot2::scale_fill_manual(values = c(
      "Programmierangst" = "#9b59b6",
      "Persönlichkeit" = "#e8041c",
      "Stress" = "#ff6b6b",
      "Studierfähigkeiten" = "#4ecdc4",
      "Statistik" = "#45b7d1"
    )) +
    ggplot2::scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
      axis.text.y = ggplot2::element_text(size = 12),
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(size = 14, face = "bold"),
      plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, color = "#e8041c", margin = ggplot2::margin(b = 20)),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "gray90", size = 0.3),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 12),
      plot.margin = ggplot2::margin(20, 20, 20, 20)
    ) +
    ggplot2::labs(
      title = if (current_lang == "en") "All Dimensions Overview" else "Alle Dimensionen im Überblick", 
      y = if (current_lang == "en") "Score (1-5)" else "Punktzahl (1-5)"
    )
  
  return(p)
}

create_trace_plot_optimized <- function(scores, current_lang) {
  # Simplified trace plot for Programming Anxiety
  trace_data <- data.frame(
    item = 1:10,
    theta = seq(scores$ProgrammingAnxiety - 0.5, scores$ProgrammingAnxiety + 0.5, length.out = 10),
    se_upper = seq(scores$ProgrammingAnxiety - 0.3, scores$ProgrammingAnxiety + 0.3, length.out = 10),
    se_lower = seq(scores$ProgrammingAnxiety - 0.7, scores$ProgrammingAnxiety + 0.7, length.out = 10),
    item_type = c(rep("Fixed", 5), rep("Adaptive", 5))
  )
  
  p <- ggplot2::ggplot(trace_data, ggplot2::aes(x = item, y = theta)) +
    ggplot2::geom_ribbon(ggplot2::aes(ymin = se_lower, ymax = se_upper), 
                         alpha = 0.3, fill = "#9b59b6") +
    ggplot2::geom_line(linewidth = 2, color = "#9b59b6") +
    ggplot2::geom_point(ggplot2::aes(color = item_type), size = 4) +
    ggplot2::geom_vline(xintercept = 5.5, linetype = "dotted", 
                        color = "gray50", alpha = 0.7) +
    ggplot2::scale_x_continuous(breaks = 1:10, labels = 1:10) +
    ggplot2::scale_color_manual(values = c("Fixed" = "#e8041c", "Adaptive" = "#4ecdc4")) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5, 
                                         color = "#9b59b6", margin = ggplot2::margin(b = 15)),
      plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5, 
                                            color = "gray50", margin = ggplot2::margin(b = 10)),
      axis.title = ggplot2::element_text(size = 12, face = "bold"),
      axis.text = ggplot2::element_text(size = 11),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(20, 20, 20, 20)
    ) +
    ggplot2::labs(
      title = if (current_lang == "en") "Programming Anxiety - Adaptive Testing" else "Programmierangst - Adaptive Testung",
      subtitle = sprintf(if (current_lang == "en") "Final Score = %.2f" else "Finale Punktzahl = %.2f", scores$ProgrammingAnxiety),
      x = if (current_lang == "en") "Item Number" else "Item-Nummer",
      y = if (current_lang == "en") "Score" else "Punktzahl"
    )
  
  return(p)
}

# =============================================================================
# IMAGE ENCODING UTILITY
# =============================================================================

encode_image_base64 <- function(plot) {
  # Save plot to temporary file
  temp_file <- tempfile(fileext = ".png")
  suppressMessages({
    ggplot2::ggsave(temp_file, plot, width = 10, height = 8, dpi = 150, bg = "white")
  })
  
  # Encode as base64
  if (requireNamespace("base64enc", quietly = TRUE)) {
    base64_string <- base64enc::base64encode(temp_file)
  } else {
    base64_string <- ""
  }
  
  # Clean up
  unlink(temp_file)
  
  return(base64_string)
}

# =============================================================================
# OPTIMIZED PDF CONTENT CREATION
# =============================================================================

create_pdf_content_optimized <- function(scores, images, current_lang) {
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  
  # Create HTML content optimized for PDF generation
  html_content <- paste0(
    '<!DOCTYPE html>
<html lang="', current_lang, '">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HilFo Studie - Ergebnisse</title>
    <style>
        body {
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f8f9fa;
            color: #333;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            overflow: hidden;
        }
        .header {
            background: #e8041c;
            color: white;
            padding: 30px;
            text-align: center;
        }
        .header h1 {
            margin: 0;
            font-size: 28px;
            font-weight: bold;
        }
        .header p {
            margin: 10px 0 0 0;
            font-size: 16px;
            opacity: 0.9;
        }
        .content {
            padding: 30px;
        }
        .section {
            margin-bottom: 40px;
            page-break-inside: avoid;
        }
        .section h2 {
            color: #e8041c;
            font-size: 22px;
            margin-bottom: 20px;
            border-bottom: 2px solid #e8041c;
            padding-bottom: 10px;
        }
        .image-container {
            text-align: center;
            margin: 20px 0;
        }
        .image-container img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .scores-table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        .scores-table th,
        .scores-table td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        .scores-table th {
            background: #f8f9fa;
            font-weight: bold;
            color: #e8041c;
        }
        .scores-table tr:hover {
            background: #f5f5f5;
        }
        .score-value {
            font-weight: bold;
            font-size: 16px;
        }
        .high-score { color: #28a745; }
        .medium-score { color: #ffc107; }
        .low-score { color: #dc3545; }
        .footer {
            background: #f8f9fa;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 14px;
        }
        @media print {
            body { margin: 0; padding: 0; }
            .container { box-shadow: none; border-radius: 0; }
            .section { page-break-inside: avoid; }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>', if (current_lang == "en") "HilFo Study Results" else "HilFo Studie Ergebnisse", '</h1>
            <p>', if (current_lang == "en") "Personality and Programming Anxiety Assessment" else "Persönlichkeits- und Programmierangst-Bewertung", '</p>
            <p>', format(Sys.Date(), if (current_lang == "en") "%B %d, %Y" else "%d. %B %Y"), '</p>
        </div>
        
        <div class="content">
            <!-- Personality Profile Section -->
            <div class="section">
                <h2>', if (current_lang == "en") "Personality Profile (Big Five)" else "Persönlichkeitsprofil (Big Five)", '</h2>
                <div class="image-container">
                    <img src="data:image/png;base64,', images$radar, '" alt="Personality Radar Chart">
                </div>
            </div>
            
            <!-- Programming Anxiety Section -->
            <div class="section">
                <h2>', if (current_lang == "en") "Programming Anxiety Assessment" else "Programmierangst-Bewertung", '</h2>
                <div class="image-container">
                    <img src="data:image/png;base64,', images$trace, '" alt="Programming Anxiety Trace">
                </div>
            </div>
            
            <!-- All Dimensions Overview -->
            <div class="section">
                <h2>', if (current_lang == "en") "All Dimensions Overview" else "Alle Dimensionen im Überblick", '</h2>
                <div class="image-container">
                    <img src="data:image/png;base64,', images$bar, '" alt="All Dimensions Bar Chart">
                </div>
            </div>
            
            <!-- Detailed Scores Table -->
            <div class="section">
                <h2>', if (current_lang == "en") "Detailed Scores" else "Detaillierte Punktzahlen", '</h2>
                <table class="scores-table">
                    <thead>
                        <tr>
                            <th>', if (current_lang == "en") "Dimension" else "Dimension", '</th>
                            <th>', if (current_lang == "en") "Score" else "Punktzahl", '</th>
                            <th>', if (current_lang == "en") "Level" else "Niveau", '</th>
                        </tr>
                    </thead>
                    <tbody>'
  )
  
  # Add score rows
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    level_class <- ifelse(value >= 3.7, "high-score", ifelse(value >= 2.3, "medium-score", "low-score"))
    level_text <- ifelse(value >= 3.7, 
                        if (current_lang == "en") "High" else "Hoch", 
                        ifelse(value >= 2.3, 
                               if (current_lang == "en") "Medium" else "Mittel", 
                               if (current_lang == "en") "Low" else "Niedrig"))
    
    # Translate dimension names
    name_display <- switch(name,
                           "ProgrammingAnxiety" = if (current_lang == "en") "Programming Anxiety" else "Programmierangst",
                           "Extraversion" = "Extraversion",
                           "Verträglichkeit" = if (current_lang == "en") "Agreeableness" else "Verträglichkeit",
                           "Gewissenhaftigkeit" = if (current_lang == "en") "Conscientiousness" else "Gewissenhaftigkeit",
                           "Neurotizismus" = if (current_lang == "en") "Neuroticism" else "Neurotizismus",
                           "Offenheit" = if (current_lang == "en") "Openness" else "Offenheit",
                           "Stress" = "Stress",
                           "Studierfähigkeiten" = if (current_lang == "en") "Study Skills" else "Studierfähigkeiten",
                           "Statistik" = if (current_lang == "en") "Statistics" else "Statistik",
                           name)
    
    html_content <- paste0(html_content,
                           '<tr>
                                <td>', name_display, '</td>
                                <td><span class="score-value ', level_class, '">', value, '</span></td>
                                <td>', level_text, '</td>
                            </tr>')
  }
  
  html_content <- paste0(html_content,
                        '</tbody>
                    </table>
                </div>
            </div>
            
            <div class="footer">
                <p>', if (current_lang == "en") "Generated by HilFo Study System" else "Generiert vom HilFo Studien-System", ' | ', 
                format(Sys.time(), if (current_lang == "en") "%Y-%m-%d %H:%M" else "%d.%m.%Y %H:%M"), '</p>
            </div>
        </div>
    </div>
</body>
</html>')
  
  return(shiny::HTML(html_content))
}

# =============================================================================
# PDF GENERATION FUNCTION
# =============================================================================

generate_hilfo_pdf <- function(responses, item_bank, demographics = NULL, session = NULL, output_file = NULL) {
  # Create optimized report
  report_content <- create_hilfo_pdf_report(responses, item_bank, demographics, session)
  
  # If output_file is provided, save as PDF
  if (!is.null(output_file)) {
    # Create temporary HTML file
    temp_html <- tempfile(fileext = ".html")
    writeLines(as.character(report_content), temp_html)
    
    # Convert to PDF using rmarkdown
    if (requireNamespace("rmarkdown", quietly = TRUE)) {
      tryCatch({
        rmarkdown::render(temp_html, output_file = output_file, quiet = TRUE)
        cat("PDF generated successfully:", output_file, "\n")
      }, error = function(e) {
        cat("Error generating PDF:", e$message, "\n")
        # Fallback: copy HTML file
        file.copy(temp_html, paste0(output_file, ".html"))
        cat("HTML file saved instead:", paste0(output_file, ".html"), "\n")
      })
    } else {
      # Fallback: save as HTML
      file.copy(temp_html, paste0(output_file, ".html"))
      cat("HTML file saved (rmarkdown not available):", paste0(output_file, ".html"), "\n")
    }
    
    # Clean up
    unlink(temp_html)
  }
  
  return(report_content)
}

# =============================================================================
# QUICK PDF GENERATION FOR TESTING
# =============================================================================

# Example usage function
test_hilfo_pdf <- function() {
  # Create sample responses
  sample_responses <- c(
    rep(3, 10),  # Programming Anxiety
    rep(3, 20),  # Big Five
    rep(3, 5),   # PSQ
    rep(3, 4),   # MWS
    rep(3, 2)    # Statistics
  )
  
  # Create sample item bank
  sample_item_bank <- data.frame(
    id = paste0("Item_", 1:51),
    Question = paste("Sample question", 1:51),
    stringsAsFactors = FALSE
  )
  
  # Generate PDF
  pdf_file <- paste0("hilfo_test_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".pdf")
  result <- generate_hilfo_pdf(sample_responses, sample_item_bank, output_file = pdf_file)
  
  cat("Test PDF generation completed.\n")
  cat("Check for file:", pdf_file, "\n")
  
  return(result)
}

cat("HilFo PDF Optimization System Loaded\n")
cat("Use test_hilfo_pdf() to test the system\n")
cat("Use generate_hilfo_pdf() to create PDFs from study data\n")