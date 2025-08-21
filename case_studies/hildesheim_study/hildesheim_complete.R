# =============================================================================
# HILFO STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE
# COMPLETE VERSION WITH CUSTOM PAGE FLOW
# =============================================================================
# This is the final, complete implementation of the Hildesheim study
# with the exact 11-page structure as specified:
#
# Page 1: Einleitungstext with consent
# Page 2: Soziodemo (basic demographics)  
# Page 3: Filter (Bachelor/Master)
# Page 3.1: Bildung (grades)
# Page 4: BFI-2 und PSQ (split into multiple pages)
# Page 5: MWS
# Page 6: Mitkommen Statistik
# Page 7: Stunden pro Woche
# Page 8.1: Zufriedenheit 5-point
# Page 8.2: Zufriedenheit 7-point
# Page 9: Personal Code
# Page 10: Ende
# Page 11: Results with plots
# =============================================================================

library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# ITEM BANK PREPARATION
# =============================================================================

# Helper function to create items
create_item_dataframe <- function(items_list) {
  data.frame(
    id = sapply(items_list, `[[`, "id"),
    Question = sapply(items_list, `[[`, "content"),
    subscale = sapply(items_list, `[[`, "subscale"),
    reverse_coded = sapply(items_list, `[[`, "reverse_coded"),
    ResponseCategories = "1,2,3,4,5",
    b = NA,
    a = 1,
    stringsAsFactors = FALSE
  )
}

# BFI-2 Items (20 items, positions 14-33)
bfi_items <- list(
  list(id="BFE_01", content="Ich gehe aus mir heraus, bin gesellig.", subscale="Extraversion", reverse_coded=FALSE),
  list(id="BFV_01", content="Ich bin einfühlsam, warmherzig.", subscale="Agreeableness", reverse_coded=FALSE),
  list(id="BFG_01", content="Ich bin eher unordentlich.", subscale="Conscientiousness", reverse_coded=TRUE),
  list(id="BFN_01", content="Ich bleibe auch in stressigen Situationen gelassen.", subscale="Neuroticism", reverse_coded=TRUE),
  list(id="BFO_01", content="Ich bin vielseitig interessiert.", subscale="Openness", reverse_coded=FALSE),
  
  list(id="BFE_02", content="Ich bin eher ruhig.", subscale="Extraversion", reverse_coded=TRUE),
  list(id="BFV_02", content="Ich habe mit anderen wenig Mitgefühl.", subscale="Agreeableness", reverse_coded=TRUE),
  list(id="BFG_02", content="Ich bin systematisch, halte meine Sachen in Ordnung.", subscale="Conscientiousness", reverse_coded=FALSE),
  list(id="BFN_02", content="Ich reagiere leicht angespannt.", subscale="Neuroticism", reverse_coded=FALSE),
  list(id="BFO_02", content="Ich meide philosophische Diskussionen.", subscale="Openness", reverse_coded=TRUE),
  
  list(id="BFE_03", content="Ich bin eher schüchtern.", subscale="Extraversion", reverse_coded=TRUE),
  list(id="BFV_03", content="Ich bin hilfsbereit und selbstlos.", subscale="Agreeableness", reverse_coded=FALSE),
  list(id="BFG_03", content="Ich mag es sauber und aufgeräumt.", subscale="Conscientiousness", reverse_coded=FALSE),
  list(id="BFN_03", content="Ich mache mir oft Sorgen.", subscale="Neuroticism", reverse_coded=FALSE),
  list(id="BFO_03", content="Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", subscale="Openness", reverse_coded=FALSE),
  
  list(id="BFE_04", content="Ich bin gesprächig.", subscale="Extraversion", reverse_coded=FALSE),
  list(id="BFV_04", content="Andere sind mir eher gleichgültig, egal.", subscale="Agreeableness", reverse_coded=TRUE),
  list(id="BFG_04", content="Ich bin eher der chaotische Typ, mache selten sauber.", subscale="Conscientiousness", reverse_coded=TRUE),
  list(id="BFN_04", content="Ich werde selten nervös und unsicher.", subscale="Neuroticism", reverse_coded=TRUE),
  list(id="BFO_04", content="Mich interessieren abstrakte Überlegungen wenig.", subscale="Openness", reverse_coded=TRUE)
)

# PSQ Items (5 items, positions 34-38)
psq_items <- list(
  list(id="PSQ_02", content="Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_04", content="Ich habe zuviel zu tun.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_16", content="Ich fühle mich gehetzt.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_29", content="Ich habe genug Zeit für mich.", subscale="Stress", reverse_coded=TRUE),
  list(id="PSQ_30", content="Ich fühle mich unter Termindruck.", subscale="Stress", reverse_coded=FALSE)
)

# MWS Items (4 items, positions 39-42)
mws_items <- list(
  list(id="MWS_1_KK", content="mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_10_KK", content="Teamarbeit zu organisieren (z.B. Lerngruppen finden)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_17_KK", content="Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_21_KK", content="im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", subscale="StudySkills", reverse_coded=FALSE)
)

# Statistics Items (2 items, positions 43-44)
statistics_items <- list(
  list(id="Statistik_gutfolgen", content="Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", subscale="Statistics", reverse_coded=FALSE),
  list(id="Statistik_selbstwirksam", content="Ich bin in der Lage, Statistik zu erlernen.", subscale="Statistics", reverse_coded=FALSE)
)

# Combine all items
all_items <- rbind(
  create_item_dataframe(bfi_items),
  create_item_dataframe(psq_items),
  create_item_dataframe(mws_items),
  create_item_dataframe(statistics_items)
)

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS
# =============================================================================

demographic_configs <- list(
  Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
    required = TRUE
  ),
  
  Alter_VPN = list(
    question = "Wie alt sind Sie?\nBitte geben Sie Ihr Alter in Jahren an.",
    options = c("17" = "17", "18" = "18", "19" = "19", "20" = "20", "21" = "21",
                "22" = "22", "23" = "23", "24" = "24", "25" = "25", "26" = "26",
                "27" = "27", "28" = "28", "29" = "29", "30" = "30", 
                "älter als 30" = "31+"),
    required = TRUE
  ),
  
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie" = "1", "Master Psychologie" = "2"),
    required = TRUE
  ),
  
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich" = "1", "männlich" = "2", "divers" = "3"),
    required = TRUE
  ),
  
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c("Bei meinen Eltern/Elternteil" = "1",
                "In einer WG/WG in einem Wohnheim" = "2",
                "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim" = "3",
                "Mit meinem/r Partner*In (mit oder ohne Kinder)" = "4",
                "Anders:" = "6"),
    required = TRUE
  ),
  
  Wohn_Zusatz = list(
    question = "Falls 'Anders', bitte spezifizieren:",
    options = NULL,
    required = FALSE
  ),
  
  Haustier = list(
    question = "Welches Haustier würden Sie gerne halten?",
    options = c("Hund" = "1", "Katze" = "2", "Fische" = "3", 
                "Vogel" = "4", "Nager" = "5", "Reptil" = "6", 
                "Ich möchte kein Haustier." = "7", "Sonstiges:" = "8"),
    required = TRUE
  ),
  
  Haustier_Zusatz = list(
    question = "Falls 'Sonstiges', bitte spezifizieren:",
    options = NULL,
    required = FALSE
  ),
  
  Rauchen = list(
    question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
    options = c("Ja" = "1", "Nein" = "2"),
    required = TRUE
  ),
  
  Ernährung = list(
    question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
    options = c("Vegan" = "1", "Vegetarisch" = "2", "Pescetarisch" = "7",
                "Flexitarisch" = "4", "Omnivor (alles)" = "5", "Andere:" = "6"),
    required = TRUE
  ),
  
  Ernährung_Zusatz = list(
    question = "Falls 'Andere', bitte spezifizieren:",
    options = NULL,
    required = FALSE
  ),
  
  Note_Englisch = list(
    question = "Was war Ihre letzte Schulnote im Fach Englisch?",
    options = c("sehr gut (15-13 Punkte)" = "1", 
                "gut (12-10 Punkte)" = "2",
                "befriedigend (9-7 Punkte)" = "3", 
                "ausreichend (6-4 Punkte)" = "4",
                "mangelhaft (3-0 Punkte)" = "5"),
    required = TRUE
  ),
  
  Note_Mathe = list(
    question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
    options = c("sehr gut (15-13 Punkte)" = "1", 
                "gut (12-10 Punkte)" = "2",
                "befriedigend (9-7 Punkte)" = "3", 
                "ausreichend (6-4 Punkte)" = "4",
                "mangelhaft (3-0 Punkte)" = "5"),
    required = TRUE
  ),
  
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    options = c("0 Stunden" = "1", 
                "maximal eine Stunde" = "2",
                "mehr als eine, aber weniger als 2 Stunden" = "3",
                "mehr als zwei, aber weniger als 3 Stunden" = "4",
                "mehr als drei, aber weniger als 4 Stunden" = "5",
                "mehr als 4 Stunden" = "6"),
    required = TRUE
  ),
  
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
    options = c("gar nicht zufrieden" = "1", "2" = "2", "3" = "3", 
                "4" = "4", "sehr zufrieden" = "5"),
    required = TRUE
  ),
  
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
    options = c("gar nicht zufrieden" = "1", "2" = "2", "3" = "3", 
                "4" = "4", "5" = "5", "6" = "6", "sehr zufrieden" = "7"),
    required = TRUE
  ),
  
  Persönlicher_Code = list(
    question = paste0(
      "Zum Ende des Semesters soll es eine zweite Befragung geben. ",
      "Damit die Befragung anonym bleibt, wir die Fragebögen aber trotzdem ",
      "einander zuordnen können, erstellen Sie bitte einen persönlichen Code.\n\n",
      "Ihr Code ist folgendermaßen aufgebaut:\n",
      "1. Der erste Buchstabe Ihres Geburtsorts (z.B. B für Berlin)\n",
      "2. Der erste Buchstabe des Rufnamens Ihrer Mutter (z.B. E für Eva)\n",
      "3. Der Tag Ihres Geburtsdatums (z.B. 07 für 07.10.1986)\n",
      "4. Die letzten zwei Ziffern Ihrer Matrikelnummer\n\n",
      "Für die Beispiele würde der Code also BE0751 lauten.\n\n",
      "Wie lautet Ihr Code?"
    ),
    options = NULL,
    required = TRUE
  )
)

# =============================================================================
# CUSTOM PAGE FLOW DEFINITION
# =============================================================================

custom_page_flow <- list(
  # Page 1: Einleitungstext with consent
  list(
    id = "page1",
    type = "instructions",
    title = "Einleitungstext",
    content = paste0(
      "<div style='padding: 20px;'>",
      "<p><strong>Liebe Studierende,</strong></p>",
      "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
      "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>",
      "<p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
      "Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>",
      "<p><strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ",
      "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im ",
      "Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.</p>",
      "<p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
      "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
      "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht. ",
      "Da es nicht immer möglich ist, sich zu 100% in einer Aussage wiederzufinden, ",
      "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate.</p>",
      "</div>"
    ),
    consent = TRUE,
    consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden"
  ),
  
  # Page 2: Soziodemo (basic demographics)
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemo",
    description = "Zunächst bitten wir Sie um ein paar allgemeine Angaben zu sich selbst.",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht", "Wohnstatus", "Wohn_Zusatz",
                    "Haustier", "Haustier_Zusatz", "Rauchen", "Ernährung", "Ernährung_Zusatz")
  ),
  
  # Page 3: Filter (Bachelor/Master check - simplified for now)
  list(
    id = "page3",
    type = "custom",
    title = "Filter",
    content = "<p>Basierend auf Ihrem Studiengang werden die folgenden Fragen angepasst.</p>"
  ),
  
  # Page 3.1: Bildung (grades)
  list(
    id = "page3.1",
    type = "demographics",
    title = "Bildung",
    description = "Im Folgenden geht es um Ihren Bildungshintergrund.",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
  # Page 4.1: BFI-2 items 1-5
  list(
    id = "page4.1",
    type = "items",
    title = "BFI-2 und PSQ",
    instructions = "Im folgenden finden Sie eine Reihe von Eigenschaften, die auf Sie zutreffen könnten. Bitte geben Sie für jede der folgenden Aussagen an, inwieweit Sie zustimmen.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4.2: BFI-2 items 6-10
  list(
    id = "page4.2",
    type = "items",
    title = "BFI-2 und PSQ (Fortsetzung)",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 4.3: BFI-2 items 11-15
  list(
    id = "page4.3",
    type = "items",
    title = "BFI-2 und PSQ (Fortsetzung)",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 4.4: BFI-2 items 16-20
  list(
    id = "page4.4",
    type = "items",
    title = "BFI-2 und PSQ (Fortsetzung)",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 4.5: PSQ items
  list(
    id = "page4.5",
    type = "items",
    title = "BFI-2 und PSQ (Abschluss)",
    instructions = "Inwiefern stimmen Sie den folgenden Aussagen zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 5: MWS
  list(
    id = "page5",
    type = "items",
    title = "MWS",
    instructions = "Im Folgenden geht es um Ihr Studium. Schätzen Sie ein, wie leicht bzw. schwer es Ihnen seit Semesterbeginn gefallen ist, mit den folgenden Anforderungen im Studium umzugehen.",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 6: Mitkommen Statistik
  list(
    id = "page6",
    type = "items",
    title = "Mitkommen Statistik",
    instructions = "Wie sehr stimmen Sie den folgenden Aussagen zu?",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 7: Stunden pro Woche
  list(
    id = "page7",
    type = "demographics",
    title = "Stunden pro Woche",
    demographics = c("Vor_Nachbereitung")
  ),
  
  # Page 8.1: Zufriedenheit 5-point
  list(
    id = "page8.1",
    type = "demographics",
    title = "Zufriedenheit Studienort",
    demographics = c("Zufrieden_Hi_5st")
  ),
  
  # Page 8.2: Zufriedenheit 7-point
  list(
    id = "page8.2",
    type = "demographics",
    title = "Zufriedenheit Studienort",
    demographics = c("Zufrieden_Hi_7st")
  ),
  
  # Page 9: Personal Code
  list(
    id = "page9",
    type = "demographics",
    title = "Code",
    demographics = c("Persönlicher_Code")
  ),
  
  # Page 10: Ende
  list(
    id = "page10",
    type = "custom",
    title = "Ende",
    content = paste0(
      "<div style='text-align: center; padding: 40px;'>",
      "<h3>Sie haben die Befragung erfolgreich abgeschlossen.</h3>",
      "<p style='font-size: 18px; margin-top: 20px;'>Vielen Dank für Ihre Teilnahme!</p>",
      "</div>"
    )
  ),
  
  # Page 11: Results/Endseite
  list(
    id = "page11",
    type = "results",
    title = "Endseite"
  )
)

# =============================================================================
# RESULTS PROCESSOR WITH FULL REPORT AND PLOTS
# =============================================================================

create_hilfo_report <- function(responses, item_bank) {
  if (length(responses) < 31) {
    return(shiny::HTML("<p>Nicht genügend Antworten für Auswertung.</p>"))
  }
  
  # Calculate BFI scores
  bfi_r <- as.numeric(responses[1:20])
  scores <- list(
    extraversion = mean(c(bfi_r[1], 6-bfi_r[6], 6-bfi_r[11], bfi_r[16]), na.rm=TRUE),
    agreeableness = mean(c(bfi_r[2], 6-bfi_r[7], bfi_r[12], 6-bfi_r[17]), na.rm=TRUE),
    conscientiousness = mean(c(6-bfi_r[3], bfi_r[8], bfi_r[13], 6-bfi_r[18]), na.rm=TRUE),
    neuroticism = mean(c(6-bfi_r[4], bfi_r[9], bfi_r[14], 6-bfi_r[19]), na.rm=TRUE),
    openness = mean(c(bfi_r[5], 6-bfi_r[10], bfi_r[15], 6-bfi_r[20]), na.rm=TRUE)
  )
  
  # PSQ and other scores
  psq_r <- as.numeric(responses[21:25])
  scores$stress <- mean(c(psq_r[1:3], 6-psq_r[4], psq_r[5]), na.rm=TRUE)
  scores$study_skills <- mean(as.numeric(responses[26:29]), na.rm=TRUE)
  scores$statistics <- mean(as.numeric(responses[30:31]), na.rm=TRUE)
  
  # Generate comprehensive HTML report
  html <- paste0(
    '<div style="padding:20px; font-family:Arial, sans-serif;">',
    
    # Header
    '<div style="background: linear-gradient(135deg, #003366 0%, #0066cc 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px;">',
    '<h1 style="text-align: center; margin: 0;">HilFo Studie - Ihre persönlichen Ergebnisse</h1>',
    '<p style="text-align: center; margin-top: 10px;">Hildesheimer Forschungsmethoden Studie 2024/2025</p>',
    '</div>',
    
    # BFI Profile Radar Chart
    '<div style="background:white; padding:20px; border:1px solid #ddd; border-radius:10px; margin-bottom:20px;">',
    '<h3 style="color:#003366;">Big Five Persönlichkeitsprofil</h3>',
    '<div id="bfiRadar" style="width:600px; height:500px; margin:20px auto;"></div>',
    '<script>',
    'var data = [{',
    '  type: "scatterpolar",',
    '  r: [', paste(round(c(scores$extraversion, scores$agreeableness, 
                          scores$conscientiousness, scores$neuroticism, 
                          scores$openness), 2), collapse=', '), '],',
    '  theta: ["Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", "Neurotizismus", "Offenheit"],',
    '  fill: "toself",',
    '  fillcolor: "rgba(0, 102, 204, 0.2)",',
    '  line: {color: "rgb(0, 102, 204)", width: 3},',
    '  marker: {color: "rgb(0, 102, 204)", size: 10},',
    '  name: "Ihr Profil"',
    '}];',
    'var layout = {',
    '  polar: {',
    '    radialaxis: {visible: true, range: [1, 5], tickfont: {size: 12}},',
    '    angularaxis: {tickfont: {size: 14}}',
    '  },',
    '  title: {text: "Ihre Persönlichkeitsdimensionen", font: {size: 16}},',
    '  font: {family: "Arial, sans-serif"},',
    '  showlegend: false',
    '};',
    'Plotly.newPlot("bfiRadar", data, layout);',
    '</script>',
    '</div>',
    
    # Bar Chart for All Scores
    '<div style="background:white; padding:20px; border:1px solid #ddd; border-radius:10px; margin-bottom:20px;">',
    '<h3 style="color:#003366;">Gesamtübersicht Ihrer Scores</h3>',
    '<div id="scoreBar" style="width:700px; height:400px; margin:20px auto;"></div>',
    '<script>',
    'var barData = [{',
    '  x: ["Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", ',
    '      "Neurotizismus", "Offenheit", "Stress", "Studierfähigkeiten", "Statistik"],',
    '  y: [', paste(round(c(scores$extraversion, scores$agreeableness,
                          scores$conscientiousness, scores$neuroticism,
                          scores$openness, scores$stress,
                          scores$study_skills, scores$statistics), 2), 
                   collapse=', '), '],',
    '  type: "bar",',
    '  marker: {',
    '    color: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#e377c2", "#7f7f7f", "#bcbd22"],',
    '    line: {color: "rgb(0,0,0)", width: 1}',
    '  }',
    '}];',
    'var barLayout = {',
    '  title: {text: "Alle Dimensionen im Überblick", font: {size: 16}},',
    '  yaxis: {title: "Score (1-5)", range: [1, 5]},',
    '  xaxis: {tickangle: -45},',
    '  font: {family: "Arial, sans-serif"}',
    '};',
    'Plotly.newPlot("scoreBar", barData, barLayout);',
    '</script>',
    '</div>',
    
    # Personalized Recommendations
    '<div style="background:#e8f4fd; padding:20px; border-radius:10px; border-left:5px solid #0066cc; margin-bottom:20px;">',
    '<h3 style="color:#0066cc;">Ihre personalisierten Empfehlungen</h3>',
    '<ul style="line-height:2; font-size:14px;">',
    
    if(scores$stress >= 3.5) {
      '<li><strong>Stressmanagement:</strong> Ihr erhöhtes Stressniveau deutet auf eine hohe Belastung hin. 
      Nutzen Sie die psychologische Beratung der Universität und erwägen Sie Entspannungstechniken.</li>'
    } else '',
    
    if(scores$study_skills < 3) {
      '<li><strong>Studierfähigkeiten:</strong> Erwägen Sie die Teilnahme an Lerngruppen und nutzen Sie 
      die Angebote des Lernzentrums.</li>'
    } else '',
    
    if(scores$statistics < 3) {
      '<li><strong>Statistik-Unterstützung:</strong> Die Statistik-Tutorien und Übungsgruppen können 
      Ihnen helfen, Ihr Verständnis zu vertiefen.</li>'
    } else '',
    
    '<li><strong>Allgemein:</strong> Nutzen Sie Ihre individuellen Stärken bewusst für Ihren Studienerfolg.</li>',
    '</ul>',
    '</div>',
    
    # Footer
    '<div style="text-align:center; margin-top:40px; padding:20px; background:#f5f5f5; border-radius:10px;">',
    '<p style="font-size:18px; color:#003366; font-weight:bold;">',
    'Vielen Dank für Ihre Teilnahme an der HilFo Studie!</p>',
    '<p style="color:#666;">© 2024/2025 Universität Hildesheim - Institut für Psychologie</p>',
    '</div>',
    
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
  study_key = session_uuid,
  theme = "hildesheim",
  
  # Enable custom page flow
  custom_page_flow = custom_page_flow,
  
  # Demographics
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  
  # Input types
  input_types = list(
    Einverständnis = "checkbox",
    Alter_VPN = "select",
    Studiengang = "radio",
    Geschlecht = "radio",
    Wohnstatus = "radio",
    Wohn_Zusatz = "text",
    Haustier = "radio",
    Haustier_Zusatz = "text",
    Rauchen = "radio",
    Ernährung = "radio",
    Ernährung_Zusatz = "text",
    Note_Englisch = "radio",
    Note_Mathe = "radio",
    Vor_Nachbereitung = "radio",
    Zufrieden_Hi_5st = "radio",
    Zufrieden_Hi_7st = "radio",
    Persönlicher_Code = "text"
  ),
  
  # Assessment settings
  model = "GRM",
  adaptive = FALSE,
  max_items = 31,
  min_items = 31,
  
  # UI settings
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  
  # Session settings
  session_save = TRUE,
  session_timeout = 30,
  
  # Results processor
  results_processor = create_hilfo_report,
  
  # Non-adaptive settings
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999
)

# =============================================================================
# LAUNCH STUDY
# =============================================================================

cat("\n")
cat("================================================================================\n")
cat("   HILFO STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE\n")
cat("================================================================================\n")
cat("✓ Study Name: HilFo Studie - Hildesheimer Forschungsmethoden Studie\n")
cat("✓ Total Items: 31 (BFI-2: 20, PSQ: 5, MWS: 4, Statistics: 2)\n")
cat("✓ Demographics: 17 variables across multiple pages\n")
cat("✓ Page Structure: 11 pages with progressive item display\n")
cat("✓ Items per page: 5 (for BFI/PSQ sections)\n")
cat("✓ Results: Full report with BFI radar plot, bar chart, and recommendations\n")
cat("✓ Language: German throughout\n")
cat("================================================================================\n\n")

# Launch the study
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  save_format = "csv",
  study_key = session_uuid
)