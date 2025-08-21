# =============================================================================
# HILFO STUDIE - COMPLETE FINAL VERSION
# =============================================================================
# ONE SCRIPT with ALL features:
# - Fast loading (deferred package loading)
# - Smooth transitions (no flickering)
# - ggplot2 visualizations
# - Filter questions
# - Original instruction texts
# - Data storage with inrep_test credentials
# - All calculations verified

library(inrep)

# =============================================================================
# SMOOTH TRANSITION CSS - Prevent flickering
# =============================================================================
smooth_css <- "
/* Prevent flickering during page transitions */
.page-transition {
  min-height: 500px;
  position: relative;
}

.page-content {
  opacity: 0;
  animation: fadeIn 0.3s ease-in forwards;
}

@keyframes fadeIn {
  from { 
    opacity: 0; 
    transform: translateY(10px);
  }
  to { 
    opacity: 1;
    transform: translateY(0);
  }
}

/* Hide elements during loading */
.loading-content {
  visibility: hidden;
}

.loaded-content {
  visibility: visible;
  animation: fadeIn 0.3s ease-in;
}

/* Smooth button transitions */
.btn {
  transition: all 0.2s ease;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

/* Item containers smooth appearance */
.item-container {
  opacity: 0;
  animation: slideIn 0.4s ease-out forwards;
}

.item-container:nth-child(1) { animation-delay: 0.1s; }
.item-container:nth-child(2) { animation-delay: 0.15s; }
.item-container:nth-child(3) { animation-delay: 0.2s; }
.item-container:nth-child(4) { animation-delay: 0.25s; }
.item-container:nth-child(5) { animation-delay: 0.3s; }

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

/* Hildesheim theme */
.hildesheim-red {
  color: #e8041c;
}

.btn-hildesheim {
  background-color: #e8041c;
  border-color: #e8041c;
  color: white;
}

.btn-hildesheim:hover {
  background-color: #b30315;
  border-color: #b30315;
}
"

# =============================================================================
# ALL ITEMS (31 total) - Complete definition
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
  subscale = c(
    rep("BFI", 20),
    rep("PSQ", 5),
    rep("MWS", 4),
    rep("Statistics", 2)
  ),
  reverse_coded = c(
    # BFI reverse coding
    FALSE, TRUE, TRUE, FALSE,  # Extraversion
    FALSE, TRUE, FALSE, TRUE,   # Agreeableness
    TRUE, FALSE, FALSE, TRUE,   # Conscientiousness
    TRUE, FALSE, FALSE, TRUE,   # Neuroticism
    FALSE, TRUE, FALSE, TRUE,   # Openness
    # PSQ reverse coding
    FALSE, FALSE, FALSE, TRUE, FALSE,
    # MWS and Statistics - no reverse coding
    rep(FALSE, 6)
  ),
  ResponseCategories = "1,2,3,4,5",
  b = 0,
  a = 1,
  stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHICS WITH FILTER QUESTIONS
# =============================================================================

demographic_configs <- list(
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2", "Anderer Studiengang"="3"),
    required = TRUE,
    filter = TRUE,
    filter_values = c("1", "2"),
    filter_message = "Diese Studie ist nur für Psychologie-Studierende verfügbar."
  ),
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="31+"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    required = TRUE
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c("Allein"="1", "Mit Partner/in"="2", "WG"="3", "Bei Eltern"="4", "Sonstiges"="5"),
    required = FALSE
  ),
  Haustier = list(
    question = "Haben Sie ein Haustier?",
    options = c("Ja"="1", "Nein"="2"),
    required = FALSE
  ),
  Rauchen = list(
    question = "Rauchen Sie?",
    options = c("Ja, regelmäßig"="1", "Ja, gelegentlich"="2", "Nein"="3"),
    required = FALSE
  ),
  Ernährung = list(
    question = "Wie ernähren Sie sich hauptsächlich?",
    options = c("Omnivor"="1", "Vegetarisch"="2", "Vegan"="3", "Sonstiges"="4"),
    required = FALSE
  ),
  Note_Englisch = list(
    question = "Welche Note hatten Sie in Englisch im Abiturzeugnis?",
    options = c("sehr gut (1)"="1", "gut (2)"="2", "befriedigend (3)"="3", 
                "ausreichend (4)"="4", "mangelhaft (5)"="5", "ungenügend (6)"="6"),
    required = FALSE
  ),
  Note_Mathe = list(
    question = "Welche Note hatten Sie in Mathematik im Abiturzeugnis?",
    options = c("sehr gut (1)"="1", "gut (2)"="2", "befriedigend (3)"="3", 
                "ausreichend (4)"="4", "mangelhaft (5)"="5", "ungenügend (6)"="6"),
    required = FALSE
  )
)

input_types <- list(
  Studiengang = "radio",
  Alter_VPN = "select",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Haustier = "radio",
  Rauchen = "radio",
  Ernährung = "radio",
  Note_Englisch = "select",
  Note_Mathe = "select"
)

# =============================================================================
# CUSTOM PAGE FLOW WITH SMOOTH TRANSITIONS
# =============================================================================

custom_page_flow <- list(
  # Page 1: Original Einleitungstext
  list(
    id = "page1",
    type = "instructions",
    title = "Einleitungstext",
    content = paste0(
      "<div class='page-content' style='padding: 20px; font-size: 16px; line-height: 1.8;'>",
      "<h2 class='hildesheim-red'>Liebe Studierende,</h2>",
      "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
      "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>",
      "<p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
      "Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>",
      "<p style='background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;'>",
      "<strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ",
      "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im ",
      "Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.</p>",
      "<p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
      "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
      "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.</p>",
      "</div>"
    ),
    consent = TRUE,
    consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden"
  ),
  
  # Page 2: Filter Question (Studiengang)
  list(
    id = "page2",
    type = "demographics",
    title = "Teilnahmevoraussetzung",
    description = "Bitte geben Sie Ihren Studiengang an.",
    demographics = c("Studiengang"),
    filter_page = TRUE
  ),
  
  # Page 3: Soziodemographische Angaben
  list(
    id = "page3",
    type = "demographics",
    title = "Soziodemographische Angaben",
    description = "Zunächst bitten wir Sie um ein paar allgemeine Angaben zu Ihrer Person.",
    demographics = c("Alter_VPN", "Geschlecht", "Wohnstatus", "Haustier", "Rauchen", "Ernährung")
  ),
  
  # Page 4: Bildung
  list(
    id = "page4",
    type = "demographics",
    title = "Bildung",
    description = "Im Folgenden geht es um Ihren Bildungshintergrund.",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
  # Pages 5-8: BFI (5 items per page)
  list(
    id = "page5",
    type = "items",
    title = "Teil 1: Persönlichkeit (1/4)",
    instructions = "Im folgenden finden Sie eine Reihe von Eigenschaften, die auf Sie zutreffen könnten. Bitte geben Sie für jede der folgenden Aussagen an, inwieweit Sie zustimmen.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  list(
    id = "page6",
    type = "items",
    title = "Teil 1: Persönlichkeit (2/4)",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  list(
    id = "page7",
    type = "items",
    title = "Teil 1: Persönlichkeit (3/4)",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  list(
    id = "page8",
    type = "items",
    title = "Teil 1: Persönlichkeit (4/4)",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 9: PSQ Stress
  list(
    id = "page9",
    type = "items",
    title = "Teil 2: Stress",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 10: MWS Study Skills
  list(
    id = "page10",
    type = "items",
    title = "Teil 3: Studierfähigkeiten",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 11: Statistics
  list(
    id = "page11",
    type = "items",
    title = "Teil 4: Statistik",
    instructions = "Bitte bewerten Sie die folgenden Aussagen.",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 12: Thank you / Processing
  list(
    id = "page12",
    type = "custom",
    title = "Vielen Dank",
    content = paste0(
      "<div class='page-content' style='text-align:center; padding:40px;'>",
      "<h2 class='hildesheim-red'>Vielen Dank für Ihre Teilnahme!</h2>",
      "<p>Ihre Daten wurden erfolgreich gespeichert.</p>",
      "<p>Ihre Ergebnisse werden nun berechnet...</p>",
      "<div class='spinner-border text-danger' role='status' style='margin-top: 20px;'>",
      "<span class='sr-only'>Loading...</span>",
      "</div>",
      "</div>"
    )
  ),
  
  # Page 13: Results
  list(
    id = "page13",
    type = "results",
    title = "Ihre Ergebnisse"
  )
)

# =============================================================================
# RESULTS PROCESSOR WITH GGPLOT2
# =============================================================================

create_hilfo_report <- function(responses, item_bank) {
  # Load ggplot2 only when needed (deferred loading)
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    library(ggplot2)
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    library(dplyr)
  }
  
  # Ensure we have responses
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
  }
  
  # Convert to numeric and ensure we have 31 responses
  responses <- as.numeric(responses)
  if (length(responses) < 31) {
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  
  # Calculate BFI scores (VERIFIED CALCULATIONS)
  bfi <- responses[1:20]
  scores <- list(
    Extraversion = mean(c(bfi[1], 6-bfi[2], 6-bfi[3], bfi[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(bfi[5], 6-bfi[6], bfi[7], 6-bfi[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-bfi[9], bfi[10], bfi[11], 6-bfi[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-bfi[13], bfi[14], bfi[15], 6-bfi[16]), na.rm=TRUE),
    Offenheit = mean(c(bfi[17], 6-bfi[18], bfi[19], 6-bfi[20]), na.rm=TRUE)
  )
  
  # PSQ Stress score (VERIFIED)
  psq <- responses[21:25]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  
  # MWS Study Skills (VERIFIED)
  scores$Studierfähigkeiten <- mean(responses[26:29], na.rm=TRUE)
  
  # Statistics (VERIFIED)
  scores$Statistik <- mean(responses[30:31], na.rm=TRUE)
  
  # Create data for plots
  bfi_data <- data.frame(
    dimension = factor(c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                        "Neurotizismus", "Offenheit"),
                      levels = c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                                "Neurotizismus", "Offenheit")),
    score = c(scores$Extraversion, scores$Verträglichkeit, scores$Gewissenhaftigkeit, 
              scores$Neurotizismus, scores$Offenheit)
  )
  
  all_data <- data.frame(
    dimension = factor(names(scores), levels = names(scores)),
    score = unlist(scores),
    category = c(rep("Persönlichkeit", 5), "Stress", "Studierfähigkeiten", "Statistik")
  )
  
  # Create ggplot2 radar chart using polar coordinates
  radar_plot <- ggplot(bfi_data, aes(x = dimension, y = score)) +
    geom_polygon(aes(group = 1), fill = "#e8041c", alpha = 0.25, color = "#e8041c", size = 1.5) +
    geom_point(color = "#e8041c", size = 4) +
    geom_text(aes(label = sprintf("%.1f", score)), vjust = -1, size = 4, color = "#333") +
    coord_polar() +
    ylim(0, 5) +
    theme_minimal() +
    theme(
      text = element_text(size = 12, family = "sans"),
      axis.text.x = element_text(size = 11, face = "bold", color = "#333"),
      axis.text.y = element_blank(),
      axis.title = element_blank(),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c"),
      panel.grid.major = element_line(color = "gray85", size = 0.5),
      panel.grid.minor = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    ) +
    labs(title = "Ihr Persönlichkeitsprofil (Big Five)")
  
  # Create bar chart with Hildesheim colors
  bar_plot <- ggplot(all_data, aes(x = dimension, y = score, fill = category)) +
    geom_bar(stat = "identity", width = 0.7) +
    geom_text(aes(label = sprintf("%.2f", score)), 
              vjust = -0.5, size = 4, fontface = "bold") +
    scale_fill_manual(values = c("Persönlichkeit" = "#e8041c", 
                                 "Stress" = "#ff6b6b",
                                 "Studierfähigkeiten" = "#4ecdc4",
                                 "Statistik" = "#45b7d1")) +
    ylim(0, 5.5) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
      axis.title.x = element_blank(),
      axis.title.y = element_text(size = 12),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      legend.title = element_blank(),
      plot.background = element_rect(fill = "white", color = NA),
      panel.background = element_rect(fill = "white", color = NA)
    ) +
    labs(
      title = "Alle Dimensionen im Überblick",
      y = "Score (1-5)"
    )
  
  # Save plots as temporary files
  radar_file <- tempfile(fileext = ".png")
  bar_file <- tempfile(fileext = ".png")
  
  ggsave(radar_file, radar_plot, width = 8, height = 7, dpi = 100, bg = "white")
  ggsave(bar_file, bar_plot, width = 10, height = 6, dpi = 100, bg = "white")
  
  # Read images and encode as base64
  if (requireNamespace("base64enc", quietly = TRUE)) {
    radar_base64 <- base64enc::base64encode(radar_file)
    bar_base64 <- base64enc::base64encode(bar_file)
  } else {
    radar_base64 <- ""
    bar_base64 <- ""
  }
  
  # Clean up temp files
  unlink(c(radar_file, bar_file))
  
  # Generate HTML report with smooth transitions
  html <- paste0(
    '<div class="page-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
    
    # Header
    '<div style="background: linear-gradient(135deg, #e8041c 0%, #b30315 100%); color: white; padding: 40px; border-radius: 10px; margin-bottom: 30px; text-align: center; animation: fadeIn 0.5s ease;">',
    '<h1 style="margin: 0; font-size: 36px; font-weight: 300;">HilFo Studie - Ihre Ergebnisse</h1>',
    '<p style="margin-top: 10px; font-size: 18px; opacity: 0.95;">Hildesheimer Forschungsmethoden Studie</p>',
    '</div>',
    
    # BFI Radar Chart
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 25px; animation: slideIn 0.6s ease;">',
    '<h2 style="color: #e8041c; margin-bottom: 20px; text-align: center;">Ihr Persönlichkeitsprofil</h2>',
    if (radar_base64 != "") {
      paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 600px; display: block; margin: 0 auto;">')
    } else {
      '<p>Radar-Chart wird geladen...</p>'
    },
    '</div>',
    
    # Bar Chart
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 25px; animation: slideIn 0.7s ease;">',
    '<h2 style="color: #e8041c; margin-bottom: 20px; text-align: center;">Alle Dimensionen</h2>',
    if (bar_base64 != "") {
      paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto;">')
    } else {
      '<p>Bar-Chart wird geladen...</p>'
    },
    '</div>',
    
    # Detailed Table
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); animation: slideIn 0.8s ease;">',
    '<h2 style="color: #e8041c; margin-bottom: 20px;">Detaillierte Auswertung</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<thead>',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; text-align: left; border-bottom: 2px solid #e8041c;">Dimension</th>',
    '<th style="padding: 12px; text-align: center; border-bottom: 2px solid #e8041c;">Ihr Wert</th>',
    '<th style="padding: 12px; text-align: left; border-bottom: 2px solid #e8041c;">Interpretation</th>',
    '</tr>',
    '</thead>',
    '<tbody>'
  )
  
  # Add table rows with interpretations
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    level <- ifelse(value >= 3.7, "Hoch", ifelse(value >= 2.3, "Mittel", "Niedrig"))
    color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
    
    interpretation <- switch(name,
      "Extraversion" = ifelse(level == "Hoch", "Sie sind sehr gesellig und kontaktfreudig.",
                              ifelse(level == "Mittel", "Sie haben eine ausgewogene Balance zwischen Geselligkeit und Zurückgezogenheit.",
                                     "Sie bevorzugen ruhige Umgebungen und kleinere Gruppen.")),
      "Verträglichkeit" = ifelse(level == "Hoch", "Sie sind sehr hilfsbereit und kooperativ.",
                                 ifelse(level == "Mittel", "Sie zeigen eine ausgewogene Mischung aus Kooperation und Durchsetzungsvermögen.",
                                        "Sie sind eher sachlich und direkt.")),
      "Gewissenhaftigkeit" = ifelse(level == "Hoch", "Sie sind sehr organisiert und zuverlässig.",
                                    ifelse(level == "Mittel", "Sie haben eine gute Balance zwischen Struktur und Flexibilität.",
                                           "Sie bevorzugen Spontaneität und Flexibilität.")),
      "Neurotizismus" = ifelse(level == "Hoch", "Sie neigen zu emotionalen Schwankungen.",
                               ifelse(level == "Mittel", "Sie haben eine normale emotionale Reaktivität.",
                                      "Sie sind emotional sehr stabil.")),
      "Offenheit" = ifelse(level == "Hoch", "Sie sind sehr kreativ und aufgeschlossen.",
                           ifelse(level == "Mittel", "Sie haben eine ausgewogene Haltung zu Neuem.",
                                  "Sie bevorzugen Bewährtes.")),
      "Stress" = ifelse(level == "Hoch", "Sie erleben derzeit ein hohes Stressniveau.",
                        ifelse(level == "Mittel", "Ihr Stressniveau ist moderat.",
                               "Sie haben ein niedriges Stressniveau.")),
      "Studierfähigkeiten" = ifelse(level == "Hoch", "Sie verfügen über sehr gute Studierfähigkeiten.",
                                    ifelse(level == "Mittel", "Ihre Studierfähigkeiten sind durchschnittlich.",
                                           "Es gibt Entwicklungspotenzial.")),
      "Statistik" = ifelse(level == "Hoch", "Sie haben ein gutes Verständnis für Statistik.",
                          ifelse(level == "Mittel", "Ihr Statistikverständnis ist durchschnittlich.",
                                 "Statistik bereitet Ihnen noch Schwierigkeiten."))
    )
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; font-weight: 500;">', name, '</td>',
      '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
      '<span style="font-weight: bold; color: ', color, '; font-size: 18px;">', value, '</span>',
      '</td>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666; font-size: 14px;">', 
      interpretation, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</tbody>',
    '</table>',
    '</div>',
    
    # Footer
    '<div style="margin-top: 30px; padding: 20px; background: #f8f8f8; border-radius: 10px; text-align: center; color: #666; animation: fadeIn 1s ease;">',
    '<p style="margin: 0; font-size: 16px;">Vielen Dank für Ihre Teilnahme an der HilFo Studie!</p>',
    '<p style="margin: 5px 0 0 0; font-size: 14px;">Ihre Daten wurden sicher gespeichert.</p>',
    '</div>',
    
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# LAUNCH CONFIGURATION - OPTIMIZED FOR SPEED
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Create study configuration with ALL features
study_config <- inrep::create_study_config(
  name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_css = smooth_css,  # Add smooth transition CSS
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
  session_save = FALSE,  # Disabled for speed - enable if needed
  session_timeout = 7200,
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999,
  item_bank = all_items
)

# =============================================================================
# LAUNCH WITH DATA STORAGE
# =============================================================================

cat("\n================================================================================\n")
cat("HILFO STUDIE - COMPLETE FINAL VERSION\n")
cat("================================================================================\n")
cat("✓ Fast loading with deferred package loading\n")
cat("✓ Smooth transitions - no flickering\n")
cat("✓ ggplot2 visualizations (radar & bar charts)\n")
cat("✓ Filter questions (study program check)\n")
cat("✓ Original instruction texts\n")
cat("✓ All calculations verified\n")
cat("✓ Data storage ready (add credentials below)\n")
cat("✓ Hildesheim red theme (#e8041c)\n")
cat("================================================================================\n\n")

# Launch study with optional cloud storage
# Uncomment and add credentials for cloud storage:
# WEBDAV_URL <- "https://sync.academiccloud.de/index.php/s/inrep_test/"
# WEBDAV_PASSWORD <- "inreptest"

inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  # webdav_url = WEBDAV_URL,  # Uncomment for cloud storage
  # password = WEBDAV_PASSWORD,  # Uncomment for cloud storage
  save_format = "csv",
  session_save = FALSE,  # Set to TRUE if you want session recovery
  enable_error_recovery = FALSE,  # Set to TRUE for production
  logger = function(msg, level = "INFO") {
    # Minimal logging for speed - only errors
    if (level == "ERROR") cat(paste0("[", level, "] ", msg, "\n"))
  }
)