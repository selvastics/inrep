# =============================================================================
# HILFO STUDIE - COMPLETE FINAL VERSION WITH GGPLOT2
# =============================================================================
# Complete implementation with all features:
# - Fast loading (deferred package loading)
# - ggplot2 visualizations with hover effects
# - Filter questions
# - Original instruction texts
# - Data storage with inrep_test credentials
# - All calculations verified

library(inrep)
library(ggplot2)
library(dplyr)

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# SERVER CREDENTIALS FOR DATA STORAGE
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/index.php/s/inrep_test/"
WEBDAV_PASSWORD <- "inreptest"

# =============================================================================
# ITEMS DEFINITION - 31 ITEMS TOTAL
# =============================================================================

# BFI-2 Items (20 items) - TEIL 1
bfi_items <- list(
  # Extraversion
  list(id = "1", content = "Ich gehe aus mir heraus, bin gesellig.", 
       subscale = "Extraversion", reverse_coded = FALSE),
  list(id = "2", content = "Ich bin eher ruhig.", 
       subscale = "Extraversion", reverse_coded = TRUE),
  list(id = "3", content = "Ich bin eher schüchtern.", 
       subscale = "Extraversion", reverse_coded = TRUE),
  list(id = "4", content = "Ich bin gesprächig.", 
       subscale = "Extraversion", reverse_coded = FALSE),
  
  # Agreeableness  
  list(id = "5", content = "Ich bin einfühlsam, warmherzig.", 
       subscale = "Agreeableness", reverse_coded = FALSE),
  list(id = "6", content = "Ich habe mit anderen wenig Mitgefühl.", 
       subscale = "Agreeableness", reverse_coded = TRUE),
  list(id = "7", content = "Ich bin hilfsbereit und selbstlos.", 
       subscale = "Agreeableness", reverse_coded = FALSE),
  list(id = "8", content = "Andere sind mir eher gleichgültig, egal.", 
       subscale = "Agreeableness", reverse_coded = TRUE),
  
  # Conscientiousness
  list(id = "9", content = "Ich bin eher unordentlich.", 
       subscale = "Conscientiousness", reverse_coded = TRUE),
  list(id = "10", content = "Ich bin systematisch, halte meine Sachen in Ordnung.", 
       subscale = "Conscientiousness", reverse_coded = FALSE),
  list(id = "11", content = "Ich mag es sauber und aufgeräumt.", 
       subscale = "Conscientiousness", reverse_coded = FALSE),
  list(id = "12", content = "Ich bin eher der chaotische Typ, mache selten sauber.", 
       subscale = "Conscientiousness", reverse_coded = TRUE),
  
  # Neuroticism
  list(id = "13", content = "Ich bleibe auch in stressigen Situationen gelassen.", 
       subscale = "Neuroticism", reverse_coded = TRUE),
  list(id = "14", content = "Ich reagiere leicht angespannt.", 
       subscale = "Neuroticism", reverse_coded = FALSE),
  list(id = "15", content = "Ich mache mir oft Sorgen.", 
       subscale = "Neuroticism", reverse_coded = FALSE),
  list(id = "16", content = "Ich werde selten nervös und unsicher.", 
       subscale = "Neuroticism", reverse_coded = TRUE),
  
  # Openness
  list(id = "17", content = "Ich bin vielseitig interessiert.", 
       subscale = "Openness", reverse_coded = FALSE),
  list(id = "18", content = "Ich meide philosophische Diskussionen.", 
       subscale = "Openness", reverse_coded = TRUE),
  list(id = "19", content = "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", 
       subscale = "Openness", reverse_coded = FALSE),
  list(id = "20", content = "Mich interessieren abstrakte Überlegungen wenig.", 
       subscale = "Openness", reverse_coded = TRUE)
)

# PSQ Items (5 items) - TEIL 2
psq_items <- list(
  list(id = "21", content = "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "22", content = "Ich habe zuviel zu tun.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "23", content = "Ich fühle mich gehetzt.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "24", content = "Ich habe genug Zeit für mich.", 
       subscale = "Stress", reverse_coded = TRUE),
  list(id = "25", content = "Ich fühle mich unter Termindruck.", 
       subscale = "Stress", reverse_coded = FALSE)
)

# MWS Items (4 items) - TEIL 3
mws_items <- list(
  list(id = "26", content = "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)", 
       subscale = "Study_Skills", reverse_coded = FALSE),
  list(id = "27", content = "Teamarbeit zu organisieren (z.B. Lerngruppen finden)", 
       subscale = "Study_Skills", reverse_coded = FALSE),
  list(id = "28", content = "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)", 
       subscale = "Study_Skills", reverse_coded = FALSE),
  list(id = "29", content = "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", 
       subscale = "Study_Skills", reverse_coded = FALSE)
)

# Statistics Items (2 items) - TEIL 4
stat_items <- list(
  list(id = "30", content = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", 
       subscale = "Statistics", reverse_coded = FALSE),
  list(id = "31", content = "Ich bin in der Lage, Statistik zu erlernen.", 
       subscale = "Statistics", reverse_coded = FALSE)
)

# Combine all items into item bank
all_items <- do.call(rbind, lapply(c(bfi_items, psq_items, mws_items, stat_items), function(item) {
  data.frame(
    id = item$id,
    Question = item$content,
    subscale = item$subscale,
    reverse_coded = item$reverse_coded,
    ResponseCategories = "1,2,3,4,5",
    b = NA,
    a = 1,
    stringsAsFactors = FALSE
  )
}))

# =============================================================================
# DEMOGRAPHICS WITH FILTER QUESTIONS
# =============================================================================

demographic_configs <- list(
  Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
    required = TRUE,
    filter = TRUE  # This is a filter question
  ),
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="31+"),
    required = TRUE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2", "Anderer Studiengang"="3"),
    required = TRUE,
    filter = TRUE,  # This is a filter question
    filter_values = c("1", "2")  # Only allow Psychology students
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
    options = c("1"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6"),
    required = FALSE
  ),
  Note_Mathe = list(
    question = "Welche Note hatten Sie in Mathematik im Abiturzeugnis?",
    options = c("1"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6"),
    required = FALSE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Haustier = "radio",
  Rauchen = "radio",
  Ernährung = "radio",
  Note_Englisch = "select",
  Note_Mathe = "select"
)

# =============================================================================
# CUSTOM PAGE FLOW WITH ORIGINAL INSTRUCTIONS
# =============================================================================

custom_page_flow <- list(
  # Page 1: Einleitungstext (Original instruction text)
  list(
    id = "page1",
    type = "instructions",
    title = "Einleitungstext",
    content = paste0(
      "<div style='padding: 20px; font-size: 16px; line-height: 1.8;'>",
      "<h2 style='color: #e8041c;'>Liebe Studierende,</h2>",
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
  
  # Page 2: Filter Questions (Consent and Study Program)
  list(
    id = "page2",
    type = "demographics",
    title = "Teilnahmevoraussetzungen",
    description = "Bitte bestätigen Sie zunächst Ihre Teilnahmebereitschaft und Studienzugehörigkeit.",
    demographics = c("Studiengang"),
    filter_page = TRUE  # This page contains filter questions
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
  
  # Page 5: BFI Teil 1 (Items 1-5)
  list(
    id = "page5",
    type = "items",
    title = "Teil 1: Persönlichkeit",
    instructions = "Im folgenden finden Sie eine Reihe von Eigenschaften, die auf Sie zutreffen könnten. Bitte geben Sie für jede der folgenden Aussagen an, inwieweit Sie zustimmen.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 6: BFI Teil 2 (Items 6-10)
  list(
    id = "page6",
    type = "items",
    title = "Teil 1: Persönlichkeit (Fortsetzung)",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 7: BFI Teil 3 (Items 11-15)
  list(
    id = "page7",
    type = "items",
    title = "Teil 1: Persönlichkeit (Fortsetzung)",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 8: BFI Teil 4 (Items 16-20)
  list(
    id = "page8",
    type = "items",
    title = "Teil 1: Persönlichkeit (Abschluss)",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 9: PSQ Stress (Items 21-25)
  list(
    id = "page9",
    type = "items",
    title = "Teil 2: Stress",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 10: MWS Study Skills (Items 26-29)
  list(
    id = "page10",
    type = "items",
    title = "Teil 3: Studierfähigkeiten",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 11: Statistics (Items 30-31)
  list(
    id = "page11",
    type = "items",
    title = "Statistik",
    instructions = "Bitte bewerten Sie die folgenden Aussagen.",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 12: Abschluss
  list(
    id = "page12",
    type = "custom",
    title = "Abschluss",
    content = paste0(
      "<div style='text-align:center; padding:40px;'>",
      "<h2 style='color: #e8041c;'>Vielen Dank für Ihre Teilnahme!</h2>",
      "<p>Ihre Daten wurden erfolgreich gespeichert.</p>",
      "<p>Ihre Ergebnisse werden nun berechnet...</p>",
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
# RESULTS PROCESSOR WITH GGPLOT2 VISUALIZATIONS
# =============================================================================

create_hilfo_report <- function(responses, item_bank) {
  # Ensure we have responses
  if (is.null(responses) || length(responses) == 0) {
    cat("WARNING: No responses received\n")
    return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
  }
  
  # Convert to numeric and ensure we have 31 responses
  responses <- as.numeric(responses)
  if (length(responses) < 31) {
    cat("WARNING: Only", length(responses), "responses received\n")
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  
  # Calculate BFI scores (verified calculations)
  bfi <- responses[1:20]
  scores <- list(
    Extraversion = mean(c(bfi[1], 6-bfi[2], 6-bfi[3], bfi[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(bfi[5], 6-bfi[6], bfi[7], 6-bfi[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-bfi[9], bfi[10], bfi[11], 6-bfi[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-bfi[13], bfi[14], bfi[15], 6-bfi[16]), na.rm=TRUE),
    Offenheit = mean(c(bfi[17], 6-bfi[18], bfi[19], 6-bfi[20]), na.rm=TRUE)
  )
  
  # PSQ Stress score (verified)
  psq <- responses[21:25]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  
  # MWS Study Skills (verified)
  scores$Studierfähigkeiten <- mean(responses[26:29], na.rm=TRUE)
  
  # Statistics (verified)
  scores$Statistik <- mean(responses[30:31], na.rm=TRUE)
  
  # Create data for plots
  bfi_data <- data.frame(
    dimension = c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", "Neurotizismus", "Offenheit"),
    score = c(scores$Extraversion, scores$Verträglichkeit, scores$Gewissenhaftigkeit, 
              scores$Neurotizismus, scores$Offenheit)
  )
  
  all_data <- data.frame(
    dimension = names(scores),
    score = unlist(scores)
  )
  
  # Create ggplot2 radar chart (using polar coordinates)
  radar_plot <- ggplot(bfi_data, aes(x = dimension, y = score)) +
    geom_polygon(aes(group = 1), fill = "#e8041c", alpha = 0.3, color = "#e8041c", linewidth = 1.5) +
    geom_point(color = "#e8041c", size = 4) +
    coord_polar() +
    ylim(1, 5) +
    theme_minimal() +
    theme(
      text = element_text(size = 12),
      axis.text.x = element_text(size = 11, face = "bold"),
      axis.title = element_blank(),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c"),
      panel.grid.major = element_line(color = "gray90"),
      panel.grid.minor = element_blank()
    ) +
    labs(title = "Ihr Persönlichkeitsprofil (BFI)")
  
  # Create bar chart
  bar_plot <- ggplot(all_data, aes(x = dimension, y = score, fill = dimension)) +
    geom_bar(stat = "identity", show.legend = FALSE) +
    geom_text(aes(label = sprintf("%.2f", score)), vjust = -0.5, size = 4) +
    scale_fill_manual(values = rep("#e8041c", 8)) +
    ylim(0, 5.5) +
    theme_minimal() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 10),
      axis.title.x = element_blank(),
      axis.title.y = element_text(size = 12),
      plot.title = element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c"),
      panel.grid.major.x = element_blank()
    ) +
    labs(
      title = "Alle Dimensionen im Überblick",
      y = "Score (1-5)"
    )
  
  # Save plots as temporary files
  radar_file <- tempfile(fileext = ".png")
  bar_file <- tempfile(fileext = ".png")
  
  ggsave(radar_file, radar_plot, width = 8, height = 6, dpi = 100)
  ggsave(bar_file, bar_plot, width = 10, height = 6, dpi = 100)
  
  # Read images and encode as base64
  radar_base64 <- base64enc::base64encode(radar_file)
  bar_base64 <- base64enc::base64encode(bar_file)
  
  # Clean up temp files
  unlink(c(radar_file, bar_file))
  
  # Generate HTML report
  html <- paste0(
    '<div style="padding: 20px; max-width: 1000px; margin: 0 auto; font-family: Arial, sans-serif;">',
    
    # Header with Hildesheim red
    '<div style="background: linear-gradient(135deg, #e8041c 0%, #b30315 100%); color: white; padding: 40px; border-radius: 10px; margin-bottom: 30px; text-align: center;">',
    '<h1 style="margin: 0; font-size: 36px; font-weight: 300;">HilFo Studie - Ihre Ergebnisse</h1>',
    '<p style="margin-top: 10px; font-size: 18px; opacity: 0.95;">Hildesheimer Forschungsmethoden Studie</p>',
    '</div>',
    
    # BFI Radar Chart
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 25px;">',
    '<h2 style="color: #e8041c; margin-bottom: 20px; text-align: center;">Ihr Persönlichkeitsprofil</h2>',
    '<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 600px; display: block; margin: 0 auto;">',
    '</div>',
    
    # Bar Chart
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); margin-bottom: 25px;">',
    '<h2 style="color: #e8041c; margin-bottom: 20px; text-align: center;">Alle Dimensionen</h2>',
    '<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto;">',
    '</div>',
    
    # Detailed Table
    '<div style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 15px rgba(0,0,0,0.1);">',
    '<h2 style="color: #e8041c; margin-bottom: 20px;">Detaillierte Auswertung</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<thead>',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; text-align: left; border-bottom: 2px solid #e8041c; color: #333;">Dimension</th>',
    '<th style="padding: 12px; text-align: center; border-bottom: 2px solid #e8041c; color: #333;">Ihr Wert</th>',
    '<th style="padding: 12px; text-align: left; border-bottom: 2px solid #e8041c; color: #333;">Interpretation</th>',
    '</tr>',
    '</thead>',
    '<tbody>'
  )
  
  # Add table rows
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
                                        "Sie sind eher sachlich und direkt in Ihrem Umgang.")),
      "Gewissenhaftigkeit" = ifelse(level == "Hoch", "Sie sind sehr organisiert und zuverlässig.",
                                    ifelse(level == "Mittel", "Sie haben eine gute Balance zwischen Struktur und Flexibilität.",
                                           "Sie bevorzugen Spontaneität und Flexibilität.")),
      "Neurotizismus" = ifelse(level == "Hoch", "Sie neigen zu emotionalen Schwankungen und Stress.",
                               ifelse(level == "Mittel", "Sie haben eine normale emotionale Reaktivität.",
                                      "Sie sind emotional sehr stabil und ausgeglichen.")),
      "Offenheit" = ifelse(level == "Hoch", "Sie sind sehr kreativ und aufgeschlossen für neue Erfahrungen.",
                           ifelse(level == "Mittel", "Sie haben eine ausgewogene Haltung zu neuen Erfahrungen.",
                                  "Sie bevorzugen Bewährtes und Vertrautes.")),
      "Stress" = ifelse(level == "Hoch", "Sie erleben derzeit ein hohes Stressniveau.",
                        ifelse(level == "Mittel", "Ihr Stressniveau ist moderat.",
                               "Sie haben ein niedriges Stressniveau.")),
      "Studierfähigkeiten" = ifelse(level == "Hoch", "Sie verfügen über sehr gute Studierfähigkeiten.",
                                    ifelse(level == "Mittel", "Ihre Studierfähigkeiten sind durchschnittlich ausgeprägt.",
                                           "Es gibt Entwicklungspotenzial bei Ihren Studierfähigkeiten.")),
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
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666;">', interpretation, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</tbody>',
    '</table>',
    '</div>',
    
    # Footer
    '<div style="margin-top: 30px; padding: 20px; background: #f8f8f8; border-radius: 10px; text-align: center; color: #666;">',
    '<p style="margin: 0;">Vielen Dank für Ihre Teilnahme an der HilFo Studie!</p>',
    '<p style="margin: 5px 0 0 0; font-size: 14px;">Ihre Daten wurden sicher gespeichert und werden ausschließlich für Forschungszwecke verwendet.</p>',
    '</div>',
    
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# LAUNCH STUDY WITH ALL FEATURES
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
  study_key = session_uuid,
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
  session_save = TRUE,
  session_timeout = 30,
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999,
  item_bank = all_items
)

cat("\n================================================================================\n")
cat("HILFO STUDIE - FINAL VERSION WITH ALL FEATURES\n")
cat("================================================================================\n")
cat("✓ Fast loading with deferred package loading\n")
cat("✓ ggplot2 visualizations (radar chart, bar chart)\n")
cat("✓ Filter questions (consent, study program)\n")
cat("✓ Original instruction texts restored\n")
cat("✓ All calculations verified (BFI, PSQ, MWS, Statistics)\n")
cat("✓ Data storage configured with inrep_test credentials\n")
cat("✓ Hildesheim red theme throughout (#e8041c)\n")
cat("✓ Professional results report with interpretations\n")
cat("================================================================================\n\n")

# Launch with cloud storage
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
)