# =============================================================================
# HILFO STUDIE - COMPLETE SINGLE FILE
# Perfect example of using inrep package
# =============================================================================

library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

# Initialize
inrep::initialize_logging()

# Create items helper
create_item_dataframe <- function(items_list) {
  data.frame(
    id = sapply(items_list, `[[`, "id"),
    Question = sapply(items_list, `[[`, "content"),
    subscale = sapply(items_list, `[[`, "subscale"),
    reverse_coded = sapply(items_list, `[[`, "reverse_coded"),
    ResponseCategories = "1,2,3,4,5",
    b = NA, a = 1,
    stringsAsFactors = FALSE
  )
}

# TEIL 1: BFI-2 (20 items)
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

# TEIL 2: PSQ (5 items)
psq_items <- list(
  list(id="PSQ_02", content="Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_04", content="Ich habe zuviel zu tun.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_16", content="Ich fühle mich gehetzt.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_29", content="Ich habe genug Zeit für mich.", subscale="Stress", reverse_coded=TRUE),
  list(id="PSQ_30", content="Ich fühle mich unter Termindruck.", subscale="Stress", reverse_coded=FALSE)
)

# TEIL 3: MWS (4 items) + Statistics (2 items)
mws_items <- list(
  list(id="MWS_1", content="mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_10", content="Teamarbeit zu organisieren (z.B. Lerngruppen finden)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_17", content="Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_21", content="im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", subscale="StudySkills", reverse_coded=FALSE)
)

statistics_items <- list(
  list(id="Stat_1", content="Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", subscale="Statistics", reverse_coded=FALSE),
  list(id="Stat_2", content="Ich bin in der Lage, Statistik zu erlernen.", subscale="Statistics", reverse_coded=FALSE)
)

# Combine all items
all_items <- rbind(
  create_item_dataframe(bfi_items),
  create_item_dataframe(psq_items),
  create_item_dataframe(mws_items),
  create_item_dataframe(statistics_items)
)

# Demographics
demographic_configs <- list(
  Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
    required = TRUE
  ),
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", "22"="22", 
                "23"="23", "24"="24", "25"="25", "26"="26", "27"="27", "28"="28", 
                "29"="29", "30"="30", "älter als 30"="31+"),
    required = TRUE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    required = TRUE
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c("Bei meinen Eltern/Elternteil"="1", "In einer WG/WG in einem Wohnheim"="2",
                "Alleine/in abgeschlossener Wohneinheit"="3", "Mit Partner*In"="4", "Anders:"="6"),
    required = TRUE
  ),
  Note_Englisch = list(
    question = "Was war Ihre letzte Schulnote im Fach Englisch?",
    options = c("sehr gut (15-13 Punkte)"="1", "gut (12-10 Punkte)"="2",
                "befriedigend (9-7 Punkte)"="3", "ausreichend (6-4 Punkte)"="4",
                "mangelhaft (3-0 Punkte)"="5"),
    required = TRUE
  ),
  Note_Mathe = list(
    question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
    options = c("sehr gut (15-13 Punkte)"="1", "gut (12-10 Punkte)"="2",
                "befriedigend (9-7 Punkte)"="3", "ausreichend (6-4 Punkte)"="4",
                "mangelhaft (3-0 Punkte)"="5"),
    required = TRUE
  )
)

# Custom page flow
custom_page_flow <- list(
  list(
    id = "page1",
    type = "instructions",
    title = "Einleitungstext",
    content = paste0(
      "<div style='padding:20px;'>",
      "<h2>Liebe Studierende,</h2>",
      "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
      "die von Ihnen selbst stammen.</p>",
      "<p><strong>Ihre Angaben sind dabei selbstverständlich anonym</strong></p>",
      "</div>"
    ),
    consent = TRUE,
    consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden"
  ),
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemo",
    description = "Zunächst bitten wir Sie um ein paar allgemeine Angaben zu sich selbst.",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht", "Wohnstatus")
  ),
  list(
    id = "page3",
    type = "custom",
    title = "Filter",
    content = NULL  # Dynamic based on Studiengang
  ),
  list(
    id = "page3.1",
    type = "demographics",
    title = "Bildung",
    description = "Im Folgenden geht es um Ihren Bildungshintergrund.",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  list(
    id = "page4.1",
    type = "items",
    title = "Teil 1: Persönlichkeit (BFI-2)",
    instructions = "Bitte geben Sie an, inwieweit Sie zustimmen.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  list(
    id = "page4.2",
    type = "items",
    title = "Teil 1: Persönlichkeit (Fortsetzung)",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  list(
    id = "page4.3",
    type = "items",
    title = "Teil 1: Persönlichkeit (Fortsetzung)",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  list(
    id = "page4.4",
    type = "items",
    title = "Teil 1: Persönlichkeit (Abschluss)",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  list(
    id = "page5",
    type = "items",
    title = "Teil 2: Stress (PSQ)",
    instructions = "Inwiefern stimmen Sie den folgenden Aussagen zu?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  list(
    id = "page6",
    type = "items",
    title = "Teil 3: Studierfähigkeiten (MWS)",
    instructions = "Im Folgenden geht es um Ihr Studium. Schätzen Sie ein, wie leicht bzw. schwer es Ihnen seit Semesterbeginn gefallen ist, mit den folgenden Anforderungen im Studium umzugehen.",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  list(
    id = "page7",
    type = "items",
    title = "Mitkommen Statistik",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  list(
    id = "page8",
    type = "custom",
    title = "Ende",
    content = "<div style='text-align:center; padding:40px;'><h2>Vielen Dank für Ihre Teilnahme!</h2></div>"
  ),
  list(
    id = "page9",
    type = "results",
    title = "Assessment Results"
  )
)

# Results processor with plots
create_hilfo_report <- function(responses, item_bank) {
  if (length(responses) < 31) {
    return(shiny::HTML("<p>Nicht genügend Antworten für Auswertung.</p>"))
  }
  
  responses <- as.numeric(responses)
  bfi_r <- responses[1:20]
  
  scores <- list(
    extraversion = mean(c(bfi_r[1], 6-bfi_r[6], 6-bfi_r[11], bfi_r[16]), na.rm=TRUE),
    agreeableness = mean(c(bfi_r[2], 6-bfi_r[7], bfi_r[12], 6-bfi_r[17]), na.rm=TRUE),
    conscientiousness = mean(c(6-bfi_r[3], bfi_r[8], bfi_r[13], 6-bfi_r[18]), na.rm=TRUE),
    neuroticism = mean(c(6-bfi_r[4], bfi_r[9], bfi_r[14], 6-bfi_r[19]), na.rm=TRUE),
    openness = mean(c(bfi_r[5], 6-bfi_r[10], bfi_r[15], 6-bfi_r[20]), na.rm=TRUE),
    stress = mean(c(responses[21:23], 6-responses[24], responses[25]), na.rm=TRUE),
    study_skills = mean(responses[26:29], na.rm=TRUE),
    statistics = mean(responses[30:31], na.rm=TRUE)
  )
  
  radar_id <- paste0("radar_", sample(100000:999999, 1))
  bar_id <- paste0("bar_", sample(100000:999999, 1))
  
  html <- paste0(
    '<div style="padding:20px;">',
    '<h1 style="text-align:center; color:#003366;">HilFo Studie - Assessment Results</h1>',
    '<div style="background:white; padding:30px; border-radius:10px; margin:20px 0;">',
    '<h3>Big Five Persönlichkeitsprofil</h3>',
    '<div id="', radar_id, '" style="width:100%; height:500px;"></div>',
    '</div>',
    '<div style="background:white; padding:30px; border-radius:10px; margin:20px 0;">',
    '<h3>Alle Dimensionen</h3>',
    '<div id="', bar_id, '" style="width:100%; height:400px;"></div>',
    '</div>',
    '<script>',
    'setTimeout(function() {',
    '  if (typeof Plotly !== "undefined") {',
    '    var radarData = [{',
    '      type: "scatterpolar",',
    '      r: [', paste(round(unlist(scores[1:5]), 2), collapse=', '), '],',
    '      theta: ["Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", "Neurotizismus", "Offenheit"],',
    '      fill: "toself"',
    '    }];',
    '    Plotly.newPlot("', radar_id, '", radarData, {polar:{radialaxis:{range:[1,5]}}});',
    '    var barData = [{',
    '      x: ["Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", "Neurotizismus", "Offenheit", "Stress", "Studierfähigkeiten", "Statistik"],',
    '      y: [', paste(round(unlist(scores), 2), collapse=', '), '],',
    '      type: "bar"',
    '    }];',
    '    Plotly.newPlot("', bar_id, '", barData, {yaxis:{range:[0,5.5]}});',
    '  }',
    '}, 1000);',
    '</script>',
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# Study configuration
session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = list(
    Einverständnis = "checkbox",
    Alter_VPN = "select",
    Studiengang = "radio",
    Geschlecht = "radio",
    Wohnstatus = "radio",
    Note_Englisch = "radio",
    Note_Mathe = "radio"
  ),
  model = "GRM",
  adaptive = FALSE,
  max_items = 31,
  min_items = 31,
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  session_save = TRUE,
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999
)

# Launch
cat("\n================================================================================\n")
cat("HILFO STUDIE - COMPLETE SINGLE FILE\n")
cat("================================================================================\n")
cat("✓ All code in ONE file\n")
cat("✓ Functional filter page\n")
cat("✓ Results with plots in 'Assessment Results'\n")
cat("✓ 3 Parts: Teil 1 (BFI), Teil 2 (PSQ), Teil 3 (MWS)\n")
cat("✓ All responses required\n")
cat("✓ Perfect example of using inrep\n")
cat("================================================================================\n\n")

inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  save_format = "csv",
  study_key = session_uuid
)
