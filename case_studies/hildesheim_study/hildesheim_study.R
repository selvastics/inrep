# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION
# =============================================================================
# Complete implementation that works smoothly with the original inrep package
# WITHOUT modifying core functionality

library(inrep)
library(ggplot2)
library(dplyr)

# =============================================================================
# ITEMS DEFINITION - 31 ITEMS TOTAL
# =============================================================================

all_items <- data.frame(
  id = as.character(1:31),
  Question = c(
    # BFI items 1-20
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin eher ruhig.",
    "Ich bin eher schüchtern.",
    "Ich bin gesprächig.",
    "Ich bin einfühlsam, warmherzig.",
    "Ich habe mit anderen wenig Mitgefühl.",
    "Ich bin hilfsbereit und selbstlos.",
    "Andere sind mir eher gleichgültig, egal.",
    "Ich bin eher unordentlich.",
    "Ich bin systematisch, halte meine Sachen in Ordnung.",
    "Ich mag es sauber und aufgeräumt.",
    "Ich bin eher der chaotische Typ, mache selten sauber.",
    "Ich bleibe auch in stressigen Situationen gelassen.",
    "Ich reagiere leicht angespannt.",
    "Ich mache mir oft Sorgen.",
    "Ich werde selten nervös und unsicher.",
    "Ich bin vielseitig interessiert.",
    "Ich meide philosophische Diskussionen.",
    "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
    "Mich interessieren abstrakte Überlegungen wenig.",
    # PSQ items 21-25
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    # MWS items 26-29
    "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
    # Statistics items 30-31
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  ResponseCategories = "1,2,3,4,5",
  b = 0,
  a = 1,
  stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHICS
# =============================================================================

demographic_configs <- list(
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2", "Anderer Studiengang"="3"),
    required = TRUE
  ),
  Alter = list(
    question = "Wie alt sind Sie?",
    options = as.character(17:35),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    required = TRUE
  )
)

input_types <- list(
  Studiengang = "radio",
  Alter = "select",
  Geschlecht = "radio"
)

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
  # Page 1: Welcome
  list(
    id = "page1",
    type = "instructions",
    title = "Willkommen zur HilFo Studie",
    content = paste0(
      "<div style='padding: 20px; line-height: 1.8;'>",
      "<h3 style='color: #e8041c;'>Liebe Studierende,</h3>",
      "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
      "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>",
      "<p style='background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;'>",
      "<strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ",
      "Auswertung der Daten stattfinden.</p>",
      "<p>Die Befragung dauert etwa 10-15 Minuten.</p>",
      "</div>"
    ),
    consent = TRUE,
    consent_text = "Ich bin mit der Teilnahme einverstanden"
  ),
  
  # Page 2: Demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Angaben zur Person",
    demographics = c("Studiengang", "Alter", "Geschlecht")
  ),
  
  # Pages 3-6: BFI (5 items per page for smooth loading)
  list(
    id = "page3",
    type = "items",
    title = "Persönlichkeit (Teil 1/4)",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  list(
    id = "page4",
    type = "items",
    title = "Persönlichkeit (Teil 2/4)",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  list(
    id = "page5",
    type = "items",
    title = "Persönlichkeit (Teil 3/4)",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  list(
    id = "page6",
    type = "items",
    title = "Persönlichkeit (Teil 4/4)",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: PSQ
  list(
    id = "page7",
    type = "items",
    title = "Stress",
    instructions = "Wie sehr treffen diese Aussagen auf Sie zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 8: MWS
  list(
    id = "page8",
    type = "items",
    title = "Studierfähigkeiten",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 9: Statistics
  list(
    id = "page9",
    type = "items",
    title = "Statistik",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 10: Results
  list(
    id = "page10",
    type = "results",
    title = "Ihre Ergebnisse"
  )
)

# =============================================================================
# RESULTS PROCESSOR WITH GGPLOT2
# =============================================================================

create_hilfo_report <- function(responses, item_bank) {
  # Ensure we have responses
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
  }
  
  # Pad responses if needed
  if (length(responses) < 31) {
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate scores
  bfi <- responses[1:20]
  scores <- list(
    Extraversion = mean(c(bfi[1], 6-bfi[2], 6-bfi[3], bfi[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(bfi[5], 6-bfi[6], bfi[7], 6-bfi[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-bfi[9], bfi[10], bfi[11], 6-bfi[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-bfi[13], bfi[14], bfi[15], 6-bfi[16]), na.rm=TRUE),
    Offenheit = mean(c(bfi[17], 6-bfi[18], bfi[19], 6-bfi[20]), na.rm=TRUE),
    Stress = mean(c(responses[21:23], 6-responses[24], responses[25]), na.rm=TRUE),
    Studierfähigkeiten = mean(responses[26:29], na.rm=TRUE),
    Statistik = mean(responses[30:31], na.rm=TRUE)
  )
  
  # Create simple bar visualization
  all_data <- data.frame(
    dimension = factor(names(scores), levels = names(scores)),
    score = unlist(scores)
  )
  
  # Create bar plot
  bar_plot <- ggplot(all_data, aes(x = dimension, y = score)) +
    geom_bar(stat = "identity", fill = "#e8041c", width = 0.7) +
    geom_text(aes(label = sprintf("%.2f", score)), vjust = -0.5, size = 4) +
    ylim(0, 5.5) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      axis.title.x = element_blank(),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c")
    ) +
    labs(title = "Ihre Ergebnisse", y = "Score (1-5)")
  
  # Save plot
  plot_file <- tempfile(fileext = ".png")
  ggsave(plot_file, bar_plot, width = 10, height = 6, dpi = 100, bg = "white")
  
  # Encode as base64
  plot_base64 <- ""
  if (file.exists(plot_file)) {
    if (requireNamespace("base64enc", quietly = TRUE)) {
      plot_base64 <- base64enc::base64encode(plot_file)
    }
    unlink(plot_file)
  }
  
  # Generate HTML report
  html <- paste0(
    '<div style="padding: 20px; max-width: 900px; margin: 0 auto;">',
    
    # Header
    '<div style="background: #e8041c; color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px;">',
    '<h1 style="margin: 0; text-align: center;">HilFo Studie - Ihre Ergebnisse</h1>',
    '</div>',
    
    # Chart
    if (plot_base64 != "") {
      paste0(
        '<div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px;">',
        '<img src="data:image/png;base64,', plot_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto;">',
        '</div>'
      )
    },
    
    # Table
    '<div style="background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">',
    '<h2 style="color: #e8041c;">Detaillierte Werte</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<tr style="background: #f5f5f5;">',
    '<th style="padding: 10px; text-align: left; border-bottom: 2px solid #e8041c;">Dimension</th>',
    '<th style="padding: 10px; text-align: center; border-bottom: 2px solid #e8041c;">Ihr Wert</th>',
    '<th style="padding: 10px; text-align: center; border-bottom: 2px solid #e8041c;">Bewertung</th>',
    '</tr>'
  )
  
  # Add table rows
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    level <- ifelse(value >= 3.5, "Hoch", ifelse(value >= 2.5, "Mittel", "Niedrig"))
    color <- ifelse(value >= 3.5, "#28a745", ifelse(value >= 2.5, "#ffc107", "#dc3545"))
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding: 10px; border-bottom: 1px solid #ddd;">', name, '</td>',
      '<td style="padding: 10px; text-align: center; border-bottom: 1px solid #ddd;">',
      '<strong style="color: ', color, ';">', value, '</strong>',
      '</td>',
      '<td style="padding: 10px; text-align: center; border-bottom: 1px solid #ddd; color: ', color, ';">', level, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</table>',
    '</div>',
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# LAUNCH STUDY - Using ORIGINAL smooth package functionality
# =============================================================================

# Create configuration
study_config <- inrep::create_study_config(
  name = "HilFo Studie",
  study_key = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "GRM",
  adaptive = FALSE,
  max_items = 31,
  min_items = 31,
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999  # Never start adaptive
)

# Launch study
cat("\n================================================================================\n")
cat("HILFO STUDIE - SMOOTH VERSION\n")
cat("================================================================================\n")
cat("Using original inrep package for smooth performance\n")
cat("================================================================================\n\n")

inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  save_format = "csv"
)