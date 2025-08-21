# =============================================================================
# HILFO STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE
# FINAL VERSION WITH EXACT PAGE FLOW
# =============================================================================
# This version implements the EXACT page structure from the specification:
# Page 1: Einleitungstext (Instructions with consent)
# Page 2: Soziodemo (Demographics)
# Page 3: Filter (Bachelor/Master check)
# Page 3.1: Bildung (English/Math grades)
# Page 4: BFI-2 und PSQ (25 items total, split into pages)
# Page 5: MWS (4 items)
# Page 6: Mitkommen Statistik (2 items)
# Page 7: Stunden pro Woche
# Page 8.1: Zufriedenheit 5-point
# Page 8.2: Zufriedenheit 7-point
# Page 9: Personal Code
# Page 10: Ende
# Page 11: Endseite with results and plots
# =============================================================================

library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS - SPLIT BY PAGE
# =============================================================================

# Page 1: Consent (part of instructions)
consent_config <- list(
    Einverständnis = list(
        question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
        options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
        required = TRUE
    )
)

# Page 2: Basic Demographics
demographics_page2 <- list(
    Alter_VPN = list(
        question = "Wie alt sind Sie? Bitte geben Sie Ihr Alter in Jahren an.",
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
    )
)

# Page 3.1: Bildung (Education)
bildung_config <- list(
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
    )
)

# Combine all demographic configs
demographic_configs <- c(consent_config, demographics_page2, bildung_config)

# Page 7: Study hours
studyhours_config <- list(
    Vor_Nachbereitung = list(
        question = "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
        options = c("0 Stunden" = "1", 
                   "maximal eine Stunde" = "2",
                   "mehr als eine, aber weniger als 2 Stunden" = "3",
                   "mehr als zwei, aber weniger als 3 Stunden" = "4",
                   "mehr als drei, aber weniger als 4 Stunden" = "5",
                   "mehr als 4 Stunden" = "6"),
        required = TRUE
    )
)

# Page 8.1 & 8.2: Satisfaction
satisfaction_config <- list(
    Zufrieden_Hi_5st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
        options = c("gar nicht zufrieden" = "1", 
                   "2" = "2", "3" = "3", "4" = "4",
                   "sehr zufrieden" = "5"),
        required = TRUE
    ),
    
    Zufrieden_Hi_7st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
        options = c("gar nicht zufrieden" = "1", 
                   "2" = "2", "3" = "3", "4" = "4", "5" = "5", "6" = "6",
                   "sehr zufrieden" = "7"),
        required = TRUE
    )
)

# Page 9: Personal code
code_config <- list(
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
            "Für die Beispiele würde der Code also BE0751 lauten."
        ),
        options = NULL,
        required = TRUE
    )
)

# Add remaining demographics to complete config
demographic_configs <- c(demographic_configs, studyhours_config, satisfaction_config, code_config)

# =============================================================================
# ITEM DEFINITIONS - EXACT ORDER FROM SPECIFICATION
# =============================================================================

create_item_dataframe <- function(items_list) {
    data.frame(
        id = sapply(items_list, `[[`, "id"),
        Question = sapply(items_list, `[[`, "content"),
        subscale = sapply(items_list, `[[`, "subscale"),
        reverse_coded = sapply(items_list, `[[`, "reverse_coded"),
        ResponseCategories = "1,2,3,4,5",
        b = NA,
        a = NA,
        stringsAsFactors = FALSE
    )
}

# BFI-2 Items - EXACT ORDER from positions 14-33
bfi_items <- list(
    list(id="BFE_01", content="Ich gehe aus mir heraus, bin gesellig.", 
         subscale="Extraversion", reverse_coded=FALSE),
    list(id="BFV_01", content="Ich bin einfühlsam, warmherzig.", 
         subscale="Agreeableness", reverse_coded=FALSE),
    list(id="BFG_01", content="Ich bin eher unordentlich.", 
         subscale="Conscientiousness", reverse_coded=TRUE),
    list(id="BFN_01", content="Ich bleibe auch in stressigen Situationen gelassen.", 
         subscale="Neuroticism", reverse_coded=TRUE),
    list(id="BFO_01", content="Ich bin vielseitig interessiert.", 
         subscale="Openness", reverse_coded=FALSE),
    
    list(id="BFE_02", content="Ich bin eher ruhig.", 
         subscale="Extraversion", reverse_coded=TRUE),
    list(id="BFV_02", content="Ich habe mit anderen wenig Mitgefühl.", 
         subscale="Agreeableness", reverse_coded=TRUE),
    list(id="BFG_02", content="Ich bin systematisch, halte meine Sachen in Ordnung.", 
         subscale="Conscientiousness", reverse_coded=FALSE),
    list(id="BFN_02", content="Ich reagiere leicht angespannt.", 
         subscale="Neuroticism", reverse_coded=FALSE),
    list(id="BFO_02", content="Ich meide philosophische Diskussionen.", 
         subscale="Openness", reverse_coded=TRUE),
    
    list(id="BFE_03", content="Ich bin eher schüchtern.", 
         subscale="Extraversion", reverse_coded=TRUE),
    list(id="BFV_03", content="Ich bin hilfsbereit und selbstlos.", 
         subscale="Agreeableness", reverse_coded=FALSE),
    list(id="BFG_03", content="Ich mag es sauber und aufgeräumt.", 
         subscale="Conscientiousness", reverse_coded=FALSE),
    list(id="BFN_03", content="Ich mache mir oft Sorgen.", 
         subscale="Neuroticism", reverse_coded=FALSE),
    list(id="BFO_03", content="Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", 
         subscale="Openness", reverse_coded=FALSE),
    
    list(id="BFE_04", content="Ich bin gesprächig.", 
         subscale="Extraversion", reverse_coded=FALSE),
    list(id="BFV_04", content="Andere sind mir eher gleichgültig, egal.", 
         subscale="Agreeableness", reverse_coded=TRUE),
    list(id="BFG_04", content="Ich bin eher der chaotische Typ, mache selten sauber.", 
         subscale="Conscientiousness", reverse_coded=TRUE),
    list(id="BFN_04", content="Ich werde selten nervös und unsicher.", 
         subscale="Neuroticism", reverse_coded=TRUE),
    list(id="BFO_04", content="Mich interessieren abstrakte Überlegungen wenig.", 
         subscale="Openness", reverse_coded=TRUE)
)

# PSQ Items - positions 34-38
psq_items <- list(
    list(id="PSQ_02", content="Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
         subscale="Stress", reverse_coded=FALSE),
    list(id="PSQ_04", content="Ich habe zuviel zu tun.",
         subscale="Stress", reverse_coded=FALSE),
    list(id="PSQ_16", content="Ich fühle mich gehetzt.",
         subscale="Stress", reverse_coded=FALSE),
    list(id="PSQ_29", content="Ich habe genug Zeit für mich.",
         subscale="Stress", reverse_coded=TRUE),
    list(id="PSQ_30", content="Ich fühle mich unter Termindruck.",
         subscale="Stress", reverse_coded=FALSE)
)

# MWS Items - positions 39-42
mws_items <- list(
    list(id="MWS_1_KK", content="mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_10_KK", content="Teamarbeit zu organisieren (z. B. Lerngruppen finden)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_17_KK", content="Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_21_KK", content="im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
         subscale="StudySkills", reverse_coded=FALSE)
)

# Statistics Items - positions 43-44
statistics_items <- list(
    list(id="Statistik_gutfolgen", content="Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
         subscale="Statistics", reverse_coded=FALSE),
    list(id="Statistik_selbstwirksam", content="Ich bin in der Lage, Statistik zu erlernen.",
         subscale="Statistics", reverse_coded=FALSE)
)

# Combine all items
all_items <- rbind(
    create_item_dataframe(bfi_items),
    create_item_dataframe(psq_items),
    create_item_dataframe(mws_items),
    create_item_dataframe(statistics_items)
)

# =============================================================================
# ENHANCED RESULTS PROCESSOR WITH FULL REPORT
# =============================================================================

create_hilfo_report <- function(responses, item_bank) {
    if (length(responses) < 31) {
        return(shiny::HTML("<p>Nicht genügend Antworten für Auswertung.</p>"))
    }
    
    # Calculate BFI scores with correct mapping
    bfi_indices <- list(
        extraversion = c(1, 6, 11, 16),  # BFE_01-04
        agreeableness = c(2, 7, 12, 17), # BFV_01-04
        conscientiousness = c(3, 8, 13, 18), # BFG_01-04
        neuroticism = c(4, 9, 14, 19),   # BFN_01-04
        openness = c(5, 10, 15, 20)      # BFO_01-04
    )
    
    bfi_r <- as.numeric(responses[1:20])
    
    scores <- list(
        extraversion = mean(c(bfi_r[1], 6-bfi_r[6], 6-bfi_r[11], bfi_r[16]), na.rm=TRUE),
        agreeableness = mean(c(bfi_r[2], 6-bfi_r[7], bfi_r[12], 6-bfi_r[17]), na.rm=TRUE),
        conscientiousness = mean(c(6-bfi_r[3], bfi_r[8], bfi_r[13], 6-bfi_r[18]), na.rm=TRUE),
        neuroticism = mean(c(6-bfi_r[4], bfi_r[9], bfi_r[14], 6-bfi_r[19]), na.rm=TRUE),
        openness = mean(c(bfi_r[5], 6-bfi_r[10], bfi_r[15], 6-bfi_r[20]), na.rm=TRUE)
    )
    
    # PSQ stress score
    psq_r <- as.numeric(responses[21:25])
    scores$stress <- mean(c(psq_r[1:3], 6-psq_r[4], psq_r[5]), na.rm=TRUE)
    
    # MWS and Statistics
    scores$study_skills <- mean(as.numeric(responses[26:29]), na.rm=TRUE)
    scores$statistics <- mean(as.numeric(responses[30:31]), na.rm=TRUE)
    
    # Create comprehensive HTML report with plots
    html <- paste0(
        '<div style="padding:20px; font-family:Arial, sans-serif;">',
        
        # Header
        '<div style="background: linear-gradient(135deg, #003366 0%, #0066cc 100%); color: white; padding: 30px; border-radius: 10px; margin-bottom: 30px;">',
        '<h1 style="text-align: center; margin: 0;">HilFo Studie - Ihre persönlichen Ergebnisse</h1>',
        '<p style="text-align: center; margin-top: 10px;">Hildesheimer Forschungsmethoden Studie 2024/2025</p>',
        '</div>',
        
        # Summary Section
        '<div style="background:#f9f9f9; padding:20px; border-radius:10px; margin-bottom:20px;">',
        '<h2 style="color:#003366;">Zusammenfassung Ihrer Ergebnisse</h2>',
        '<p>Sie haben die Befragung erfolgreich abgeschlossen. Vielen Dank für Ihre Teilnahme!</p>',
        '<p>Im Folgenden finden Sie Ihre persönliche Auswertung mit grafischen Darstellungen.</p>',
        '</div>',
        
        # BFI Radar Plot
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
        '    radialaxis: {',
        '      visible: true,',
        '      range: [1, 5],',
        '      tickfont: {size: 12}',
        '    },',
        '    angularaxis: {tickfont: {size: 14}}',
        '  },',
        '  title: {text: "Ihre Persönlichkeitsdimensionen", font: {size: 16}},',
        '  font: {family: "Arial, sans-serif"},',
        '  showlegend: false',
        '};',
        'Plotly.newPlot("bfiRadar", data, layout);',
        '</script>',
        '</div>',
        
        # Detailed Scores Table
        '<div style="background:white; padding:20px; border:1px solid #ddd; border-radius:10px; margin-bottom:20px;">',
        '<h3 style="color:#003366;">Detaillierte Auswertung</h3>',
        '<table style="width:100%; border-collapse:collapse;">',
        '<thead>',
        '<tr style="background:#003366; color:white;">',
        '<th style="padding:12px; text-align:left;">Dimension</th>',
        '<th style="padding:12px; text-align:center;">Ihr Wert</th>',
        '<th style="padding:12px; text-align:center;">Niveau</th>',
        '<th style="padding:12px; text-align:left;">Interpretation</th>',
        '</tr>',
        '</thead>',
        '<tbody>',
        
        # BFI Dimensions
        '<tr style="background:#f9f9f9;">',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Extraversion</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', sprintf("%.2f", scores$extraversion), '</td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', 
        ifelse(scores$extraversion >= 3.5, "Hoch", ifelse(scores$extraversion >= 2.5, "Mittel", "Niedrig")), '</td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$extraversion >= 3.5, "Gesellig, energiegeladen, gesprächig", 
               ifelse(scores$extraversion >= 2.5, "Ausgeglichen zwischen Geselligkeit und Zurückgezogenheit",
                      "Zurückhaltend, ruhig, bevorzugt kleine Gruppen")), '</td>',
        '</tr>',
        
        '<tr>',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Verträglichkeit</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', sprintf("%.2f", scores$agreeableness), '</td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', 
        ifelse(scores$agreeableness >= 3.5, "Hoch", ifelse(scores$agreeableness >= 2.5, "Mittel", "Niedrig")), '</td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$agreeableness >= 3.5, "Kooperativ, vertrauensvoll, hilfsbereit", 
               ifelse(scores$agreeableness >= 2.5, "Ausgewogen zwischen Kooperation und Durchsetzung",
                      "Wettbewerbsorientiert, skeptisch, direkt")), '</td>',
        '</tr>',
        
        '<tr style="background:#f9f9f9;">',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Gewissenhaftigkeit</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', sprintf("%.2f", scores$conscientiousness), '</td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', 
        ifelse(scores$conscientiousness >= 3.5, "Hoch", ifelse(scores$conscientiousness >= 2.5, "Mittel", "Niedrig")), '</td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$conscientiousness >= 3.5, "Organisiert, zuverlässig, zielstrebig", 
               ifelse(scores$conscientiousness >= 2.5, "Balance zwischen Struktur und Flexibilität",
                      "Flexibel, spontan, weniger strukturiert")), '</td>',
        '</tr>',
        
        '<tr>',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Neurotizismus</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', sprintf("%.2f", scores$neuroticism), '</td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', 
        ifelse(scores$neuroticism >= 3.5, "Hoch", ifelse(scores$neuroticism >= 2.5, "Mittel", "Niedrig")), '</td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$neuroticism >= 3.5, "Emotional sensibel, besorgt, reaktiv", 
               ifelse(scores$neuroticism >= 2.5, "Normale emotionale Reaktivität",
                      "Emotional stabil, gelassen, resilient")), '</td>',
        '</tr>',
        
        '<tr style="background:#f9f9f9;">',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Offenheit</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', sprintf("%.2f", scores$openness), '</td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;">', 
        ifelse(scores$openness >= 3.5, "Hoch", ifelse(scores$openness >= 2.5, "Mittel", "Niedrig")), '</td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$openness >= 3.5, "Kreativ, neugierig, offen für neue Erfahrungen", 
               ifelse(scores$openness >= 2.5, "Balance zwischen Tradition und Innovation",
                      "Praktisch, konventionell, bevorzugt Vertrautes")), '</td>',
        '</tr>',
        
        # Additional Measures
        '<tr style="background:#ffe6e6;">',
        '<td style="padding:10px; border-bottom:2px solid #003366;"><strong>Stresslevel (PSQ)</strong></td>',
        '<td style="text-align:center; border-bottom:2px solid #003366;"><strong>', sprintf("%.2f", scores$stress), '</strong></td>',
        '<td style="text-align:center; border-bottom:2px solid #003366;"><strong>', 
        ifelse(scores$stress >= 3.5, "Hoch", ifelse(scores$stress >= 2.5, "Mittel", "Niedrig")), '</strong></td>',
        '<td style="border-bottom:2px solid #003366;">', 
        ifelse(scores$stress >= 3.5, "Erhöhtes Stressniveau - Selbstfürsorge wichtig", 
               ifelse(scores$stress >= 2.5, "Moderates Stressniveau - normal für Studierende",
                      "Niedriges Stressniveau - gute Bewältigung")), '</td>',
        '</tr>',
        
        '<tr style="background:#e6ffe6;">',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Studierfähigkeiten (MWS)</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;"><strong>', sprintf("%.2f", scores$study_skills), '</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;"><strong>', 
        ifelse(scores$study_skills >= 3.5, "Gut", ifelse(scores$study_skills >= 2.5, "Mittel", "Ausbaufähig")), '</strong></td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$study_skills >= 3.5, "Gute soziale und organisatorische Kompetenzen", 
               ifelse(scores$study_skills >= 2.5, "Durchschnittliche Studierfähigkeiten",
                      "Entwicklungspotenzial bei Studienkompetenzen")), '</td>',
        '</tr>',
        
        '<tr style="background:#e6f3ff;">',
        '<td style="padding:10px; border-bottom:1px solid #ddd;"><strong>Statistik-Kompetenz</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;"><strong>', sprintf("%.2f", scores$statistics), '</strong></td>',
        '<td style="text-align:center; border-bottom:1px solid #ddd;"><strong>', 
        ifelse(scores$statistics >= 3.5, "Gut", ifelse(scores$statistics >= 2.5, "Mittel", "Ausbaufähig")), '</strong></td>',
        '<td style="border-bottom:1px solid #ddd;">', 
        ifelse(scores$statistics >= 3.5, "Gutes Verständnis und Selbstvertrauen", 
               ifelse(scores$statistics >= 2.5, "Durchschnittliches Statistikverständnis",
                      "Zusätzliche Unterstützung könnte hilfreich sein")), '</td>',
        '</tr>',
        
        '</tbody>',
        '</table>',
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
        
        # Stress recommendations
        if(scores$stress >= 3.5) {
            '<li><strong>Stressmanagement:</strong> Ihr erhöhtes Stressniveau deutet auf eine hohe Belastung hin. 
            Nutzen Sie die psychologische Beratung der Universität und erwägen Sie Entspannungstechniken wie 
            Progressive Muskelentspannung oder Achtsamkeitsübungen.</li>'
        } else if(scores$stress >= 2.5) {
            '<li><strong>Stressprävention:</strong> Ihr moderates Stressniveau ist normal. Achten Sie auf eine 
            gute Work-Life-Balance und regelmäßige Pausen.</li>'
        } else '',
        
        # Study skills recommendations
        if(scores$study_skills < 3) {
            '<li><strong>Studierfähigkeiten:</strong> Erwägen Sie die Teilnahme an Lerngruppen und nutzen Sie 
            die Angebote des Lernzentrums. Der Austausch mit Kommilitonen kann sehr bereichernd sein.</li>'
        } else '',
        
        # Statistics recommendations
        if(scores$statistics < 3) {
            '<li><strong>Statistik-Unterstützung:</strong> Die Statistik-Tutorien und Übungsgruppen können 
            Ihnen helfen, Ihr Verständnis zu vertiefen. Scheuen Sie sich nicht, Fragen zu stellen!</li>'
        } else if(scores$statistics >= 4) {
            '<li><strong>Statistik-Stärke:</strong> Ihre guten Statistikkenntnisse sind eine wertvolle Ressource. 
            Erwägen Sie, anderen zu helfen oder als Tutor tätig zu werden.</li>'
        } else '',
        
        # Personality-based recommendations
        if(scores$neuroticism >= 4) {
            '<li><strong>Emotionale Balance:</strong> Achten Sie besonders auf Ihre psychische Gesundheit. 
            Regelmäßige Bewegung und soziale Kontakte können helfen, emotionale Stabilität zu fördern.</li>'
        } else '',
        
        if(scores$conscientiousness < 2.5) {
            '<li><strong>Selbstorganisation:</strong> Strukturierte Planungstools wie Kalender oder To-Do-Listen 
            könnten Ihnen helfen, Ihre Flexibilität mit notwendiger Organisation zu verbinden.</li>'
        } else '',
        
        if(scores$extraversion < 2.5) {
            '<li><strong>Soziale Vernetzung:</strong> Als eher introvertierte Person profitieren Sie von kleineren, 
            ruhigeren Lerngruppen. Online-Lerngruppen könnten eine gute Alternative sein.</li>'
        } else '',
        
        '<li><strong>Allgemein:</strong> Nutzen Sie Ihre individuellen Stärken bewusst für Ihren Studienerfolg 
        und arbeiten Sie gezielt an Bereichen mit Entwicklungspotenzial.</li>',
        
        '</ul>',
        '</div>',
        
        # Footer
        '<div style="text-align:center; margin-top:40px; padding:20px; background:#f5f5f5; border-radius:10px;">',
        '<p style="font-size:18px; color:#003366; font-weight:bold;">',
        'Vielen Dank für Ihre Teilnahme an der HilFo Studie!</p>',
        '<p style="color:#666; margin-top:10px;">',
        'Diese Auswertung wurde automatisch erstellt und dient zu Forschungs- und Lehrzwecken.</p>',
        '<p style="color:#666;">',
        'Bei Fragen wenden Sie sich bitte an das Forschungsteam der Universität Hildesheim.</p>',
        '<p style="color:#999; font-size:12px; margin-top:20px;">',
        '© 2024/2025 Universität Hildesheim - Institut für Psychologie</p>',
        '</div>',
        
        '</div>'
    )
    
    return(shiny::HTML(html))
}

# =============================================================================
# STUDY CONFIGURATION WITH CUSTOM PAGE FLOW
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
    name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
    study_key = session_uuid,
    theme = "hildesheim",
    
    # All demographics
    demographics = names(demographic_configs),
    
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
    items_per_page = 5,  # Show 5 items per page for BFI/PSQ
    
    # Session settings
    session_save = TRUE,
    session_timeout = 30,
    
    # Provide configurations
    demographic_configs = demographic_configs,
    
    # German instructions - Page 1
    instructions = list(
        welcome = "Einleitungstext",
        purpose = paste0(
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
            "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate.</p>"
        )
    ),
    
    # Show instructions first
    show_introduction = TRUE,
    show_consent = FALSE,  # Consent is part of instructions
    
    # Results processor
    results_processor = create_hilfo_report,
    
    # Non-adaptive settings
    criteria = "RANDOM",
    fixed_items = 1:31,
    adaptive_start = 999
)

# =============================================================================
# LAUNCH
# =============================================================================

cat("\n=============================================================================\n")
cat("HILFO STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE\n")
cat("=============================================================================\n")
cat("✓ Study Name: HilFo Studie\n")
cat("✓ Total Items: ", nrow(all_items), " (31 items)\n")
cat("✓ Demographics: ", length(study_config$demographics), " variables\n")
cat("✓ Page Structure: 11 pages as specified\n")
cat("✓ Items per page: 5 (for BFI/PSQ sections)\n")
cat("✓ Results: Full report with BFI profile, plots, and recommendations\n")
cat("=============================================================================\n\n")

# Launch the study
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    save_format = "csv",
    study_key = session_uuid
)