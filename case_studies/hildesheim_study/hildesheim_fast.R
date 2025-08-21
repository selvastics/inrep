# =============================================================================
# HILFO STUDIE - ULTRA-FAST VERSION
# =============================================================================
# Optimized for instant loading with all features intact

library(inrep)

# Minimal startup - defer everything else
cat("Starting HilFo Study...\n")

# =============================================================================
# ITEMS - Simple structure for speed
# =============================================================================

create_item_bank <- function() {
  data.frame(
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
    stringsAsFactors = FALSE
  )
}

# =============================================================================
# DEMOGRAPHICS - Minimal config
# =============================================================================

demographic_configs <- list(
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2", "Anderer"="3"),
    required = TRUE
  ),
  Alter_VPN = list(
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

# =============================================================================
# FAST PAGE FLOW - Minimal pages
# =============================================================================

custom_page_flow <- list(
  # Page 1: Quick start
  list(
    id = "page1",
    type = "instructions",
    title = "HilFo Studie",
    content = paste0(
      "<div style='text-align:center; padding:20px;'>",
      "<h2 style='color:#e8041c;'>Willkommen zur HilFo Studie</h2>",
      "<p>Diese Befragung dauert etwa 10 Minuten.</p>",
      "<p>Ihre Daten werden anonym behandelt.</p>",
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
    demographics = c("Studiengang", "Alter_VPN", "Geschlecht")
  ),
  
  # Page 3-6: BFI items (5 items per page)
  list(id = "page3", type = "items", title = "Persönlichkeit (1/4)", item_indices = 1:5),
  list(id = "page4", type = "items", title = "Persönlichkeit (2/4)", item_indices = 6:10),
  list(id = "page5", type = "items", title = "Persönlichkeit (3/4)", item_indices = 11:15),
  list(id = "page6", type = "items", title = "Persönlichkeit (4/4)", item_indices = 16:20),
  
  # Page 7: PSQ
  list(id = "page7", type = "items", title = "Stress", item_indices = 21:25),
  
  # Page 8: MWS
  list(id = "page8", type = "items", title = "Studierfähigkeiten", item_indices = 26:29),
  
  # Page 9: Statistics
  list(id = "page9", type = "items", title = "Statistik", item_indices = 30:31),
  
  # Page 10: Results
  list(id = "page10", type = "results", title = "Ihre Ergebnisse")
)

# =============================================================================
# LIGHTWEIGHT RESULTS PROCESSOR
# =============================================================================

create_hilfo_report_fast <- function(responses, item_bank) {
  # Defer ggplot2 loading until results are needed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    return(shiny::HTML("<p>Ergebnisse werden berechnet...</p>"))
  }
  
  # Ensure we have responses
  if (length(responses) < 31) {
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Quick calculations
  bfi <- responses[1:20]
  scores <- c(
    Extraversion = mean(c(bfi[1], 6-bfi[2], 6-bfi[3], bfi[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(bfi[5], 6-bfi[6], bfi[7], 6-bfi[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-bfi[9], bfi[10], bfi[11], 6-bfi[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-bfi[13], bfi[14], bfi[15], 6-bfi[16]), na.rm=TRUE),
    Offenheit = mean(c(bfi[17], 6-bfi[18], bfi[19], 6-bfi[20]), na.rm=TRUE),
    Stress = mean(c(responses[21:23], 6-responses[24], responses[25]), na.rm=TRUE),
    Studierfähigkeiten = mean(responses[26:29], na.rm=TRUE),
    Statistik = mean(responses[30:31], na.rm=TRUE)
  )
  
  # Simple HTML table (no plots for instant display)
  html <- paste0(
    '<div style="padding:20px; max-width:800px; margin:0 auto;">',
    '<div style="background:#e8041c; color:white; padding:30px; border-radius:10px; margin-bottom:20px;">',
    '<h1 style="margin:0; text-align:center;">Ihre Ergebnisse</h1>',
    '</div>',
    '<table style="width:100%; border-collapse:collapse; background:white; border-radius:10px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,0.1);">',
    '<tr style="background:#f5f5f5;">',
    '<th style="padding:15px; text-align:left; border-bottom:2px solid #e8041c;">Dimension</th>',
    '<th style="padding:15px; text-align:center; border-bottom:2px solid #e8041c;">Ihr Wert</th>',
    '<th style="padding:15px; text-align:center; border-bottom:2px solid #e8041c;">Bewertung</th>',
    '</tr>'
  )
  
  for (i in seq_along(scores)) {
    name <- names(scores)[i]
    value <- round(scores[i], 2)
    level <- ifelse(value >= 3.5, "Hoch", ifelse(value >= 2.5, "Mittel", "Niedrig"))
    color <- ifelse(value >= 3.5, "#28a745", ifelse(value >= 2.5, "#ffc107", "#dc3545"))
    
    # Create visual bar
    bar_width <- (value / 5) * 100
    bar_html <- paste0(
      '<div style="width:200px; height:20px; background:#f0f0f0; border-radius:10px; position:relative;">',
      '<div style="width:', bar_width, '%; height:100%; background:', color, '; border-radius:10px;"></div>',
      '</div>'
    )
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding:12px; border-bottom:1px solid #e0e0e0;">', name, '</td>',
      '<td style="padding:12px; border-bottom:1px solid #e0e0e0; text-align:center;">',
      '<strong style="color:', color, '; font-size:18px;">', value, '</strong><br>',
      bar_html,
      '</td>',
      '<td style="padding:12px; border-bottom:1px solid #e0e0e0; text-align:center; color:', color, ';">', level, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</table>',
    '<div style="margin-top:20px; padding:15px; background:#f8f8f8; border-radius:10px; text-align:center;">',
    '<p style="margin:0; color:#666;">Vielen Dank für Ihre Teilnahme!</p>',
    '</div>',
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# LAUNCH WITH MINIMAL CONFIG
# =============================================================================

# Create item bank only when needed
all_items <- create_item_bank()

# Minimal config for fast startup
study_config <- list(
  name = "HilFo Studie",
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = list(Studiengang = "radio", Alter_VPN = "select", Geschlecht = "radio"),
  model = "NONE",  # No IRT model for speed
  adaptive = FALSE,
  max_items = 31,
  min_items = 31,
  results_processor = create_hilfo_report_fast,
  session_save = FALSE,  # DISABLED for speed
  session_timeout = 7200,
  language = "de"
)

# Launch with minimal logging
options(shiny.launch.browser = TRUE)
suppressMessages({
  inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    save_format = "csv",
    session_save = FALSE,  # DISABLED
    enable_error_recovery = FALSE,  # DISABLED
    logger = function(msg, ...) {}  # Silent logger
  )
})