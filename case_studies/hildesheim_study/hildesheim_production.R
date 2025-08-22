# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION WITH COMPLETE DATA RECORDING
# =============================================================================
# All variables recorded with proper names, cloud storage enabled

library(inrep)
# Don't load heavy packages at startup - load them only when needed

# =============================================================================
# CLOUD STORAGE CREDENTIALS - Hildesheim Study Folder
# =============================================================================
# Public WebDAV folder: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"  # Share token for authentication

# =============================================================================
# COMPLETE ITEM BANK WITH PROPER VARIABLE NAMES
# =============================================================================

all_items <- data.frame(
  id = c(
    # BFI items with proper naming convention
    "BFE_01", "BFE_02", "BFE_03", "BFE_04",  # Extraversion
    "BFV_01", "BFV_02", "BFV_03", "BFV_04",  # Verträglichkeit (Agreeableness)
    "BFG_01", "BFG_02", "BFG_03", "BFG_04",  # Gewissenhaftigkeit (Conscientiousness)
    "BFN_01", "BFN_02", "BFN_03", "BFN_04",  # Neurotizismus
    "BFO_01", "BFO_02", "BFO_03", "BFO_04",  # Offenheit (Openness)
    # PSQ items
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS items
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  Question = c(
    # BFI Extraversion
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin eher ruhig.",
    "Ich bin eher schüchtern.",
    "Ich bin gesprächig.",
    # BFI Verträglichkeit
    "Ich bin einfühlsam, warmherzig.",
    "Ich habe mit anderen wenig Mitgefühl.",
    "Ich bin hilfsbereit und selbstlos.",
    "Andere sind mir eher gleichgültig, egal.",
    # BFI Gewissenhaftigkeit
    "Ich bin eher unordentlich.",
    "Ich bin systematisch, halte meine Sachen in Ordnung.",
    "Ich mag es sauber und aufgeräumt.",
    "Ich bin eher der chaotische Typ, mache selten sauber.",
    # BFI Neurotizismus
    "Ich bleibe auch in stressigen Situationen gelassen.",
    "Ich reagiere leicht angespannt.",
    "Ich mache mir oft Sorgen.",
    "Ich werde selten nervös und unsicher.",
    # BFI Offenheit
    "Ich bin vielseitig interessiert.",
    "Ich meide philosophische Diskussionen.",
    "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
    "Mich interessieren abstrakte Überlegungen wenig.",
    # PSQ Stress
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    # MWS Study Skills
    "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
    # Statistics
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  reverse_coded = c(
    # BFI reverse coding
    FALSE, TRUE, TRUE, FALSE,  # Extraversion
    FALSE, TRUE, FALSE, TRUE,   # Verträglichkeit
    TRUE, FALSE, FALSE, TRUE,   # Gewissenhaftigkeit
    TRUE, FALSE, FALSE, TRUE,   # Neurotizismus
    FALSE, TRUE, FALSE, TRUE,   # Offenheit
    # PSQ
    FALSE, FALSE, FALSE, TRUE, FALSE,
    # MWS & Statistics
    rep(FALSE, 6)
  ),
  ResponseCategories = "1,2,3,4,5",
  b = 0,
  a = 1,
  stringsAsFactors = FALSE
)

# =============================================================================
# COMPLETE DEMOGRAPHICS (ALL VARIABLES FROM SPSS)
# =============================================================================

demographic_configs <- list(
  Einverständnis = list(
    question = "Einverständniserklärung",
    options = c("Ich bin mit der Teilnahme an der Befragung einverstanden" = "1"),
    required = TRUE
  ),
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="0"),
    required = TRUE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich oder divers"="1", "männlich"="2"),
    required = TRUE
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c(
      "Bei meinen Eltern/Elternteil"="1",
      "In einer WG/WG in einem Wohnheim"="2", 
      "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim"="3",
      "Mit meinem/r Partner*In (mit oder ohne Kinder)"="4",
      "Anders"="6"
    ),
    required = FALSE
  ),
  Wohn_Zusatz = list(
    question = "Falls anders, bitte spezifizieren:",
    type = "text",
    required = FALSE
  ),
  Haustier = list(
    question = "Haben Sie ein Haustier oder möchten Sie eines?",
    options = c(
      "Hund"="1", "Katze"="2", "Fische"="3", "Vogel"="4",
      "Nager"="5", "Reptil"="6", "Ich möchte kein Haustier"="7", "Sonstiges"="8"
    ),
    required = FALSE
  ),
  Haustier_Zusatz = list(
    question = "Anderes Haustier:",
    type = "text",
    required = FALSE
  ),
  Rauchen = list(
    question = "Rauchen Sie?",
    options = c("Ja"="1", "Nein"="2"),
    required = FALSE
  ),
  Ernährung = list(
    question = "Wie ernähren Sie sich hauptsächlich?",
    options = c(
      "Vegan"="1", "Vegetarisch"="2", "Pescetarisch"="7",
      "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere"="6"
    ),
    required = FALSE
  ),
  Ernährung_Zusatz = list(
    question = "Andere Ernährungsform:",
    type = "text",
    required = FALSE
  ),
  Note_Englisch = list(
    question = "Welche Note hatten Sie in Englisch im Abiturzeugnis?",
    options = c(
      "sehr gut (15-13 Punkte)"="1",
      "gut (12-10 Punkte)"="2",
      "befriedigend (9-7 Punkte)"="3",
      "ausreichend (6-4 Punkte)"="4",
      "mangelhaft (3-0 Punkte)"="5"
    ),
    required = FALSE
  ),
  Note_Mathe = list(
    question = "Welche Note hatten Sie in Mathematik im Abiturzeugnis?",
    options = c(
      "sehr gut (15-13 Punkte)"="1",
      "gut (12-10 Punkte)"="2",
      "befriedigend (9-7 Punkte)"="3",
      "ausreichend (6-4 Punkte)"="4",
      "mangelhaft (3-0 Punkte)"="5"
    ),
    required = FALSE
  ),
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    options = c(
      "0 Stunden"="1",
      "maximal eine Stunde"="2",
      "mehr als eine, aber weniger als 2 Stunden"="3",
      "mehr als zwei, aber weniger als 3 Stunden"="4",
      "mehr als drei, aber weniger als 4 Stunden"="5",
      "mehr als 4 Stunden"="6"
    ),
    required = FALSE
  ),
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-stufig)",
    options = c(
      "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "sehr zufrieden"="5"
    ),
    required = FALSE
  ),
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-stufig)",
    options = c(
      "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "sehr zufrieden"="7"
    ),
    required = FALSE
  ),
  Persönlicher_Code = list(
    question = "Bitte erstellen Sie einen persönlichen Code (erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags):",
    type = "text",
    required = FALSE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Wohn_Zusatz = "text",
  Haustier = "select",
  Haustier_Zusatz = "text",
  Rauchen = "radio",
  Ernährung = "radio",
  Ernährung_Zusatz = "text",
  Note_Englisch = "select",
  Note_Mathe = "select",
  Vor_Nachbereitung = "radio",
  Zufrieden_Hi_5st = "radio",
  Zufrieden_Hi_7st = "radio",
  Persönlicher_Code = "text"
)

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
  # Page 1: Einleitungstext with mandatory consent
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur HilFo Studie",
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
      "<p style='margin-top: 20px;'><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>",
      "<hr style='margin: 30px 0; border: 1px solid #e8041c;'>",
      "<div style='background: #f8f9fa; padding: 20px; border-radius: 8px;'>",
      "<h3 style='color: #e8041c; margin-bottom: 15px;'>Einverständniserklärung</h3>",
      "<label style='display: flex; align-items: center; cursor: pointer; font-size: 16px;'>",
      "<input type='checkbox' id='consent_check' style='margin-right: 10px; width: 20px; height: 20px;' required>",
      "<span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>",
      "</label>",
      "</div>",
      "</div>"
    ),
    validate = "function(inputs) { return document.getElementById('consent_check').checked; }",
    required = TRUE
  ),
  
  # Page 2: Basic demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemographische Angaben",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht")
  ),
  
  # Page 3: Living situation
  list(
    id = "page3",
    type = "demographics",
    title = "Wohnsituation",
    demographics = c("Wohnstatus", "Wohn_Zusatz", "Haustier", "Haustier_Zusatz")
  ),
  
  # Page 4: Lifestyle
  list(
    id = "page4",
    type = "demographics",
    title = "Lebensstil",
    demographics = c("Rauchen", "Ernährung", "Ernährung_Zusatz")
  ),
  
  # Page 5: Education
  list(
    id = "page5",
    type = "demographics",
    title = "Bildung",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
  # Pages 6-9: BFI items (grouped by trait)
  list(
    id = "page6",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    item_indices = 1:5,  # Mixed first items
    scale_type = "likert"
  ),
  list(
    id = "page7",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    item_indices = 6:10,  # Mixed second items
    scale_type = "likert"
  ),
  list(
    id = "page8",
    type = "items",
    title = "Persönlichkeit - Teil 3",
    item_indices = 11:15,  # Mixed third items
    scale_type = "likert"
  ),
  list(
    id = "page9",
    type = "items",
    title = "Persönlichkeit - Teil 4",
    item_indices = 16:20,  # Mixed fourth items
    scale_type = "likert"
  ),
  
  # Page 10: PSQ Stress
  list(
    id = "page10",
    type = "items",
    title = "Stress",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 11: MWS Study Skills
  list(
    id = "page11",
    type = "items",
    title = "Studierfähigkeiten",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 12: Statistics
  list(
    id = "page12",
    type = "items",
    title = "Statistik",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 13: Study satisfaction
  list(
    id = "page13",
    type = "demographics",
    title = "Studienzufriedenheit",
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_5st", "Zufrieden_Hi_7st", "Persönlicher_Code")
  ),
  
  # Page 14: Results
  list(
    id = "page14",
    type = "results",
    title = "Ihre Ergebnisse"
  )
)

# =============================================================================
# RESULTS PROCESSOR WITH FIXED RADAR PLOT
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL) {
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
  }
  
  # Ensure demographics is a list
  if (is.null(demographics)) {
    demographics <- list()
  }
  
  # Ensure we have all 31 item responses
  if (length(responses) < 31) {
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate BFI scores - PROPER GROUPING BY TRAIT
  # Items are ordered: E1, E2, E3, E4, V1, V2, V3, V4, G1, G2, G3, G4, N1, N2, N3, N4, O1, O2, O3, O4
  scores <- list(
    Extraversion = mean(c(responses[1], 6-responses[2], 6-responses[3], responses[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(responses[5], 6-responses[6], responses[7], 6-responses[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-responses[9], responses[10], responses[11], 6-responses[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-responses[13], responses[14], responses[15], 6-responses[16]), na.rm=TRUE),
    Offenheit = mean(c(responses[17], 6-responses[18], responses[19], 6-responses[20]), na.rm=TRUE)
  )
  
  # PSQ Stress score
  psq <- responses[21:25]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  
  # MWS & Statistics
  scores$Studierfähigkeiten <- mean(responses[26:29], na.rm=TRUE)
  scores$Statistik <- mean(responses[30:31], na.rm=TRUE)
  
  # Create radar plot using ggradar approach
  # Check for ggradar (should be pre-installed)
  
  # Prepare data for ggradar - needs to be scaled 0-1
  radar_data <- data.frame(
    group = "Ihr Profil",
    Extraversion = scores$Extraversion / 5,
    Verträglichkeit = scores$Verträglichkeit / 5,
    Gewissenhaftigkeit = scores$Gewissenhaftigkeit / 5,
    Neurotizismus = scores$Neurotizismus / 5,
    Offenheit = scores$Offenheit / 5
  )
  
  # Create radar plot with ggradar
  if (requireNamespace("ggradar", quietly = TRUE)) {
    radar_plot <- ggradar::ggradar(
      radar_data,
      values.radar = c("1", "3", "5"),  # Min, mid, max labels
      grid.min = 0,
      grid.mid = 0.6,
      grid.max = 1,
      grid.label.size = 5,
      axis.label.size = 5,
      group.point.size = 4,
      group.line.width = 1.5,
      background.circle.colour = "white",
      gridline.min.colour = "gray90",
      gridline.mid.colour = "gray80",
      gridline.max.colour = "gray70",
      group.colours = c("#e8041c"),
      plot.extent.x.sf = 1.3,
      plot.extent.y.sf = 1.2,
      legend.position = "none"
    ) +
    theme(
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5, 
                                color = "#e8041c", margin = margin(b = 20)),
      plot.background = element_rect(fill = "white", color = NA),
      plot.margin = margin(20, 20, 20, 20)
    ) +
    labs(title = "Ihr Persönlichkeitsprofil (Big Five)")
  } else {
    # Fallback to simple ggplot2 approach if ggradar not available
    library(ggplot2)
    
    # Create coordinates for manual radar plot
    n_vars <- 5
    angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
    
    # Prepare data
    bfi_scores <- c(scores$Extraversion, scores$Verträglichkeit, 
                    scores$Gewissenhaftigkeit, scores$Neurotizismus, scores$Offenheit)
    bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                    "Neurotizismus", "Offenheit")
    
    # Calculate positions
    x_pos <- bfi_scores * cos(angles - pi/2)
    y_pos <- bfi_scores * sin(angles - pi/2)
    
    # Create data frame for plotting
    plot_data <- data.frame(
      x = c(x_pos, x_pos[1]),  # Close the polygon
      y = c(y_pos, y_pos[1]),
      label = c(bfi_labels, ""),
      score = c(bfi_scores, bfi_scores[1])
    )
    
    # Grid lines data
    grid_data <- expand.grid(
      r = 1:5,
      angle = seq(0, 2*pi, length.out = 50)
    )
    grid_data$x <- grid_data$r * cos(grid_data$angle)
    grid_data$y <- grid_data$r * sin(grid_data$angle)
    
    # Create plot
    radar_plot <- ggplot() +
      # Grid circles
      geom_path(data = grid_data, aes(x = x, y = y, group = r),
                color = "gray85", size = 0.3) +
      # Spokes
      geom_segment(data = data.frame(angle = angles),
                   aes(x = 0, y = 0, 
                       xend = 5 * cos(angle - pi/2), 
                       yend = 5 * sin(angle - pi/2)),
                   color = "gray85", size = 0.3) +
      # Data polygon
      geom_polygon(data = plot_data, aes(x = x, y = y),
                   fill = "#e8041c", alpha = 0.2) +
      geom_path(data = plot_data, aes(x = x, y = y),
                color = "#e8041c", size = 2) +
      # Points
      geom_point(data = plot_data[1:5,], aes(x = x, y = y),
                 color = "#e8041c", size = 5) +
      # Labels
      geom_text(data = plot_data[1:5,], 
                aes(x = x * 1.3, y = y * 1.3, label = label),
                size = 5, fontface = "bold") +
      geom_text(data = plot_data[1:5,],
                aes(x = x * 1.1, y = y * 1.1, label = sprintf("%.1f", score)),
                size = 4, color = "#e8041c") +
      coord_equal() +
      xlim(-6, 6) + ylim(-6, 6) +
      theme_void() +
      theme(
        plot.title = element_text(size = 20, face = "bold", hjust = 0.5,
                                  color = "#e8041c", margin = margin(b = 20)),
        plot.margin = margin(30, 30, 30, 30)
      ) +
      labs(title = "Ihr Persönlichkeitsprofil (Big Five)")
  }
  
  # Create bar chart
  all_data <- data.frame(
    dimension = factor(names(scores), levels = names(scores)),
    score = unlist(scores),
    category = c(rep("Persönlichkeit", 5), "Stress", "Studierfähigkeiten", "Statistik")
  )
  
  bar_plot <- ggplot(all_data, aes(x = dimension, y = score, fill = category)) +
    geom_bar(stat = "identity", width = 0.7) +
    # Add value labels with better formatting
    geom_text(aes(label = sprintf("%.2f", score)), 
              vjust = -0.5, size = 6, fontface = "bold", color = "#333") +
    # Custom color scheme
    scale_fill_manual(values = c(
      "Persönlichkeit" = "#e8041c",
      "Stress" = "#ff6b6b",
      "Studierfähigkeiten" = "#4ecdc4",
      "Statistik" = "#45b7d1"
    )) +
    # Y-axis customization
    scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
    # Theme with larger text
    theme_minimal(base_size = 14) +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
      axis.text.y = element_text(size = 12),
      axis.title.x = element_blank(),
      axis.title.y = element_text(size = 14, face = "bold"),
      plot.title = element_text(size = 20, face = "bold", hjust = 0.5, color = "#e8041c", margin = margin(b = 20)),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_line(color = "gray90", size = 0.3),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(size = 12),
      plot.margin = margin(20, 20, 20, 20)
    ) +
    labs(title = "Alle Dimensionen im Überblick", y = "Score (1-5)")
  
  # Save plots
  radar_file <- tempfile(fileext = ".png")
  bar_file <- tempfile(fileext = ".png")
  
  suppressMessages({
    ggsave(radar_file, radar_plot, width = 10, height = 9, dpi = 150, bg = "white")
    ggsave(bar_file, bar_plot, width = 12, height = 7, dpi = 150, bg = "white")
  })
  
  # Encode as base64
  radar_base64 <- ""
  bar_base64 <- ""
  if (requireNamespace("base64enc", quietly = TRUE)) {
    radar_base64 <- base64enc::base64encode(radar_file)
    bar_base64 <- base64enc::base64encode(bar_file)
  }
  unlink(c(radar_file, bar_file))
  
  # Create detailed item responses table
  item_details <- data.frame(
    Item = item_bank$Question[1:31],
    Response = responses[1:31],
    Category = c(
      rep("Extraversion", 4), rep("Verträglichkeit", 4), 
      rep("Gewissenhaftigkeit", 4), rep("Neurotizismus", 4), rep("Offenheit", 4),
      rep("Stress", 5), rep("Studierfähigkeiten", 4), rep("Statistik", 2)
    )
  )
  
  # Generate HTML report with download button
  report_id <- paste0("report_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  
  html <- paste0(
    '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
    
    # Radar plot
    '<div class="report-section">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">Persönlichkeitsprofil</h2>',
    if (radar_base64 != "") paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px;">'),
    '</div>',
    
    # Bar chart
    '<div class="report-section">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">Alle Dimensionen im Überblick</h2>',
    if (bar_base64 != "") paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 8px;">'),
    '</div>',
    
    # Table
    '<div class="report-section">',
    '<h2 style="color: #e8041c;">Detaillierte Auswertung</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">Dimension</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">Mittelwert</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">Standardabweichung</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">Interpretation</th>',
    '</tr>'
  )
  
  # Calculate standard deviations for each dimension
  sds <- list()
  
  # Big Five dimensions - each has 4 items (with reverse scoring applied)
  # Items are in order: E1-E4 (1-4), V1-V4 (5-8), G1-G4 (9-12), N1-N4 (13-16), O1-O4 (17-20)
  bfi_dims <- list(
    Extraversion = c(responses[1], 6-responses[2], 6-responses[3], responses[4]),
    Verträglichkeit = c(responses[5], 6-responses[6], responses[7], 6-responses[8]),
    Gewissenhaftigkeit = c(6-responses[9], responses[10], responses[11], 6-responses[12]),
    Neurotizismus = c(6-responses[13], responses[14], responses[15], 6-responses[16]),
    Offenheit = c(responses[17], 6-responses[18], responses[19], 6-responses[20])
  )
  
  for (dim_name in names(bfi_dims)) {
    sd_val <- sd(bfi_dims[[dim_name]], na.rm = TRUE)
    sds[[dim_name]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  }
  
  # PSQ Stress - 5 items (with reverse scoring for item 4)
  psq_items <- c(responses[21:23], 6-responses[24], responses[25])
  sd_val <- sd(psq_items, na.rm = TRUE)
  sds[["Stress"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  # MWS Studierfähigkeiten - 4 items
  mws_items <- responses[26:29]
  sd_val <- sd(mws_items, na.rm = TRUE)
  sds[["Studierfähigkeiten"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  # Statistik - 2 items
  stat_items <- responses[30:31]
  sd_val <- sd(stat_items, na.rm = TRUE)
  sds[["Statistik"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    sd_value <- ifelse(name %in% names(sds), sds[[name]], NA)
    level <- ifelse(value >= 3.7, "Hoch", ifelse(value >= 2.3, "Mittel", "Niedrig"))
    color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', name, '</td>',
      '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
      '<strong style="color: ', color, ';">', value, '</strong></td>',
      '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
      ifelse(is.na(sd_value), "-", as.character(sd_value)), '</td>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666;">',
      level, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</table>',
    '</div>',

    
    # Add beautiful styles for the report
    '<style>',
    'body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }',
    '#report-content { background: #f8f9fa; }',
    'table { border-collapse: collapse; width: 100%; }',
    'table tr:hover { background: #f5f5f5; }',
    'h1, h2 { font-family: "Segoe UI", sans-serif; }',
    '.report-section { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }',
    '@media print {',
    '  body { font-size: 11pt; }',
    '  h1, h2 { color: #e8041c !important; -webkit-print-color-adjust: exact; }',
    '}',
    '</style>',
    
    '</div>'
  )
  
  # Save data to CSV file and upload to cloud
  if (exists("responses") && exists("item_bank")) {
    tryCatch({
      # Prepare complete dataset
      complete_data <- data.frame(
        timestamp = Sys.time(),
        session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
        stringsAsFactors = FALSE
      )
      
      # Add demographics from the session
      if (exists("demographics") && is.list(demographics)) {
        for (demo_name in names(demographics)) {
          complete_data[[demo_name]] <- demographics[[demo_name]]
        }
      }
      
      # Add item responses
      for (i in seq_along(responses)) {
        if (i <= nrow(item_bank)) {
          col_name <- item_bank$id[i]
          complete_data[[col_name]] <- responses[i]
        }
      }
      
      # Add calculated scores
      complete_data$BFI_Extraversion <- scores$Extraversion
      complete_data$BFI_Vertraeglichkeit <- scores$Vertraeglichkeit
      complete_data$BFI_Gewissenhaftigkeit <- scores$Gewissenhaftigkeit
      complete_data$BFI_Neurotizismus <- scores$Neurotizismus
      complete_data$BFI_Offenheit <- scores$Offenheit
      complete_data$PSQ_Stress <- scores$Stress
      complete_data$MWS_Kooperation <- scores$Kooperation
      complete_data$Studierfähigkeiten <- scores$Studierfähigkeiten
      complete_data$Statistik <- scores$Statistik
      
      # Save locally
      local_file <- paste0("hilfo_results_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
      write.csv(complete_data, local_file, row.names = FALSE)
      cat("Data saved locally to:", local_file, "\n")
      
      # Upload to cloud if configured
      if (!is.null(WEBDAV_URL) && !is.null(WEBDAV_PASSWORD)) {
        later::later(function() {
          tryCatch({
            # For public WebDAV folders, use share token as username
            webdav_user <- WEBDAV_SHARE_TOKEN
            
            cat("Uploading to cloud storage...\n")
            
            # Upload using httr with public folder authentication
            response <- httr::PUT(
              url = paste0(WEBDAV_URL, local_file),
              body = httr::upload_file(local_file),
              httr::authenticate(webdav_user, WEBDAV_PASSWORD, type = "basic"),
              httr::add_headers(
                "Content-Type" = "text/csv",
                "X-Requested-With" = "XMLHttpRequest"
              )
            )
            
            if (httr::status_code(response) %in% c(200, 201, 204)) {
              cat("Data successfully uploaded to cloud\n")
              cat("File:", local_file, "\n")
            } else {
              cat("Cloud upload failed with status:", httr::status_code(response), "\n")
              if (httr::status_code(response) == 401) {
                cat("Authentication failed. Check share token and password.\n")
                cat("Share token:", webdav_user, "\n")
                cat("Password: ws2526\n")
              }
          }, error = function(e) {
            cat("Error uploading to cloud:", e$message, "\n")
          })
        }, delay = 0.5)
      }
      
    }, error = function(e) {
      cat("Error saving data:", e$message, "\n")
    })
  }
  
  return(shiny::HTML(html))
}

# =============================================================================
# LAUNCH WITH CLOUD STORAGE
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  name = "HilFo Studie",
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
  session_timeout = 7200,
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999,
  item_bank = all_items,
  save_to_file = TRUE,
  save_format = "csv",
  cloud_storage = TRUE,
  enable_download = TRUE
)

cat("\n================================================================================\n")
cat("HILFO STUDIE - PRODUCTION VERSION\n")
cat("================================================================================\n")
cat("All 48 variables recorded with proper names\n")
cat("Cloud storage enabled with inreptest credentials\n")
cat("Fixed radar plot with proper connections\n")
cat("Complete data file will be saved as CSV\n")
cat("================================================================================\n\n")

# Launch with cloud storage
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
)
