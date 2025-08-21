# =============================================================================
# HilFo STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE
# =============================================================================
# Complete working version with all fixes applied
# - Demographics show text instead of numbers
# - Instructions on first page
# - Demographics split over multiple pages (TODO: needs package update)
# - BFI profile and plots in results
# =============================================================================

library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS
# =============================================================================

demographic_configs <- list(
    # Page 1: Consent
    Einverständnis = list(
        question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
        options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
        required = TRUE
    ),
    
    # Page 2: Basic Demographics
    Alter_VPN = list(
        question = "Wie alt sind Sie?",
        options = c("17" = "17", "18" = "18", "19" = "19", "20" = "20", "21" = "21",
                   "22" = "22", "23" = "23", "24" = "24", "25" = "25", "26" = "26",
                   "27" = "27", "28" = "28", "29" = "29", "30" = "30", 
                   "älter als 30" = "30+"),
        required = TRUE
    ),
    
    Studiengang = list(
        question = "In welchem Studiengang befinden Sie sich?",
        options = c("Bachelor Psychologie" = "bachelor", 
                   "Master Psychologie" = "master"),
        required = TRUE
    ),
    
    Geschlecht = list(
        question = "Welches Geschlecht haben Sie?",
        options = c("weiblich" = "w", "männlich" = "m", "divers" = "d"),
        required = TRUE
    ),
    
    # Page 3: Living situation
    Wohnstatus = list(
        question = "Wie wohnen Sie?",
        options = c("Bei meinen Eltern/Elternteil" = "eltern",
                   "In einer WG/WG in einem Wohnheim" = "wg",
                   "Alleine/in abgeschlossener Wohneinheit" = "alleine",
                   "Mit meinem/r Partner*In" = "partner",
                   "Anders:" = "anders"),
        required = TRUE
    ),
    
    Wohn_Zusatz = list(
        question = "Falls 'Anders', bitte spezifizieren:",
        options = NULL,
        required = FALSE
    ),
    
    # Page 4: Lifestyle
    Haustier = list(
        question = "Welches Haustier würden Sie gerne halten?",
        options = c("Hund" = "hund", "Katze" = "katze", "Fische" = "fische", 
                   "Vogel" = "vogel", "Nager" = "nager", "Reptil" = "reptil", 
                   "Ich möchte kein Haustier" = "kein", "Sonstiges:" = "andere"),
        required = TRUE
    ),
    
    Haustier_Zusatz = list(
        question = "Falls 'Sonstiges', bitte spezifizieren:",
        options = NULL,
        required = FALSE
    ),
    
    Rauchen = list(
        question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
        options = c("Ja" = "ja", "Nein" = "nein"),
        required = TRUE
    ),
    
    Ernährung = list(
        question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
        options = c("Vegan" = "vegan", "Vegetarisch" = "veg", 
                   "Pescetarisch" = "pesc", "Flexitarisch" = "flex",
                   "Omnivor (alles)" = "omni", "Andere:" = "andere"),
        required = TRUE
    ),
    
    Ernährung_Zusatz = list(
        question = "Falls 'Andere', bitte spezifizieren:",
        options = NULL,
        required = FALSE
    ),
    
    # Page 5: Education
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
    
    # Page 6: Study planning
    Vor_Nachbereitung = list(
        question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
        options = c("0 Stunden" = "0", 
                   "maximal eine Stunde" = "1",
                   "1-2 Stunden" = "1-2",
                   "2-3 Stunden" = "2-3",
                   "3-4 Stunden" = "3-4",
                   "mehr als 4 Stunden" = "4+"),
        required = TRUE
    ),
    
    # Page 7: Satisfaction
    Zufrieden_Hi_5st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
        options = c("gar nicht zufrieden" = "1", 
                   "wenig zufrieden" = "2",
                   "teils zufrieden" = "3", 
                   "ziemlich zufrieden" = "4",
                   "sehr zufrieden" = "5"),
        required = TRUE
    ),
    
    Zufrieden_Hi_7st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
        options = c("gar nicht zufrieden" = "1", 
                   "sehr unzufrieden" = "2",
                   "unzufrieden" = "3", 
                   "teils zufrieden" = "4",
                   "zufrieden" = "5", 
                   "sehr zufrieden" = "6",
                   "extrem zufrieden" = "7"),
        required = TRUE
    ),
    
    # Page 8: Personal code
    Persönlicher_Code = list(
        question = paste0(
            "Persönlicher Code für Folgebefragung:\n",
            "1. Erster Buchstabe Ihres Geburtsorts\n",
            "2. Erster Buchstabe des Rufnamens Ihrer Mutter\n",
            "3. Tag Ihres Geburtsdatums (zweistellig)\n",
            "4. Letzte zwei Ziffern Ihrer Matrikelnummer"
        ),
        options = NULL,
        required = TRUE
    )
)

# =============================================================================
# ITEM DEFINITIONS
# =============================================================================

create_item_dataframe <- function(items_list) {
    data.frame(
        id = sapply(items_list, `[[`, "id"),
        Question = sapply(items_list, `[[`, "content"),
        subscale = sapply(items_list, `[[`, "subscale"),
        reverse_coded = sapply(items_list, `[[`, "reverse_coded"),
        ResponseCategories = "1,2,3,4,5",
        b = NA,  # NA parameters OK for non-adaptive
        a = NA,
        stringsAsFactors = FALSE
    )
}

# BFI-2 Items (20)
bfi_items <- list(
    list(id="BFE_01", content="Ich gehe aus mir heraus, bin gesellig.",
         subscale="Extraversion", reverse_coded=FALSE),
    list(id="BFE_02", content="Ich bin eher ruhig.",
         subscale="Extraversion", reverse_coded=TRUE),
    list(id="BFE_03", content="Ich bin eher schüchtern.",
         subscale="Extraversion", reverse_coded=TRUE),
    list(id="BFE_04", content="Ich bin gesprächig.",
         subscale="Extraversion", reverse_coded=FALSE),
    
    list(id="BFV_01", content="Ich bin einfühlsam, warmherzig.",
         subscale="Agreeableness", reverse_coded=FALSE),
    list(id="BFV_02", content="Ich habe mit anderen wenig Mitgefühl.",
         subscale="Agreeableness", reverse_coded=TRUE),
    list(id="BFV_03", content="Ich bin hilfsbereit und selbstlos.",
         subscale="Agreeableness", reverse_coded=FALSE),
    list(id="BFV_04", content="Andere sind mir eher gleichgültig, egal.",
         subscale="Agreeableness", reverse_coded=TRUE),
    
    list(id="BFG_01", content="Ich bin eher unordentlich.",
         subscale="Conscientiousness", reverse_coded=TRUE),
    list(id="BFG_02", content="Ich bin systematisch, halte meine Sachen in Ordnung.",
         subscale="Conscientiousness", reverse_coded=FALSE),
    list(id="BFG_03", content="Ich mag es sauber und aufgeräumt.",
         subscale="Conscientiousness", reverse_coded=FALSE),
    list(id="BFG_04", content="Ich bin eher der chaotische Typ, mache selten sauber.",
         subscale="Conscientiousness", reverse_coded=TRUE),
    
    list(id="BFN_01", content="Ich bleibe auch in stressigen Situationen gelassen.",
         subscale="Neuroticism", reverse_coded=TRUE),
    list(id="BFN_02", content="Ich reagiere leicht angespannt.",
         subscale="Neuroticism", reverse_coded=FALSE),
    list(id="BFN_03", content="Ich mache mir oft Sorgen.",
         subscale="Neuroticism", reverse_coded=FALSE),
    list(id="BFN_04", content="Ich werde selten nervös und unsicher.",
         subscale="Neuroticism", reverse_coded=TRUE),
    
    list(id="BFO_01", content="Ich bin vielseitig interessiert.",
         subscale="Openness", reverse_coded=FALSE),
    list(id="BFO_02", content="Ich meide philosophische Diskussionen.",
         subscale="Openness", reverse_coded=TRUE),
    list(id="BFO_03", content="Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken.",
         subscale="Openness", reverse_coded=FALSE),
    list(id="BFO_04", content="Mich interessieren abstrakte Überlegungen wenig.",
         subscale="Openness", reverse_coded=TRUE)
)

# PSQ Items (5)
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

# MWS Items (4)
mws_items <- list(
    list(id="MWS_1", content="mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_10", content="Teamarbeit zu organisieren (z. B. Lerngruppen finden)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_17", content="Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)",
         subscale="StudySkills", reverse_coded=FALSE),
    list(id="MWS_21", content="im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
         subscale="StudySkills", reverse_coded=FALSE)
)

# Statistics Items (2)
statistics_items <- list(
    list(id="Stat_1", content="Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
         subscale="Statistics", reverse_coded=FALSE),
    list(id="Stat_2", content="Ich bin in der Lage, Statistik zu erlernen.",
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
# ENHANCED RESULTS PROCESSOR WITH BFI PROFILE AND PLOTS
# =============================================================================

create_hildesheim_results <- function(responses, item_bank) {
    if (length(responses) < 31) {
        return(shiny::HTML("<p>Nicht genügend Antworten für Auswertung.</p>"))
    }
    
    # Calculate BFI scores
    bfi_r <- as.numeric(responses[1:20])
    scores <- list(
        extraversion = mean(c(bfi_r[1], 6-bfi_r[2], 6-bfi_r[3], bfi_r[4]), na.rm=TRUE),
        agreeableness = mean(c(bfi_r[5], 6-bfi_r[6], bfi_r[7], 6-bfi_r[8]), na.rm=TRUE),
        conscientiousness = mean(c(6-bfi_r[9], bfi_r[10], bfi_r[11], 6-bfi_r[12]), na.rm=TRUE),
        neuroticism = mean(c(6-bfi_r[13], bfi_r[14], bfi_r[15], 6-bfi_r[16]), na.rm=TRUE),
        openness = mean(c(bfi_r[17], 6-bfi_r[18], bfi_r[19], 6-bfi_r[20]), na.rm=TRUE)
    )
    
    # PSQ stress score
    psq_r <- as.numeric(responses[21:25])
    scores$stress <- mean(c(psq_r[1:3], 6-psq_r[4], psq_r[5]), na.rm=TRUE)
    
    # MWS and Statistics
    scores$study_skills <- mean(as.numeric(responses[26:29]), na.rm=TRUE)
    scores$statistics <- mean(as.numeric(responses[30:31]), na.rm=TRUE)
    
    # Create radar plot for BFI profile
    radar_plot_js <- paste0(
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
        '  line: {color: "rgb(0, 102, 204)", width: 2},',
        '  marker: {color: "rgb(0, 102, 204)", size: 8}',
        '}];',
        'var layout = {',
        '  polar: {',
        '    radialaxis: {',
        '      visible: true,',
        '      range: [1, 5]',
        '    }',
        '  },',
        '  title: "Big Five Persönlichkeitsprofil",',
        '  font: {size: 12}',
        '};',
        'Plotly.newPlot("bfiRadar", data, layout);',
        '</script>'
    )
    
    # Create bar chart for all scores
    bar_chart_js <- paste0(
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
        '    color: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9467bd", "#e377c2", "#7f7f7f", "#bcbd22"]',
        '  }',
        '}];',
        'var barLayout = {',
        '  title: "Ihre Scores im Überblick",',
        '  yaxis: {title: "Score", range: [1, 5]},',
        '  xaxis: {tickangle: -45}',
        '};',
        'Plotly.newPlot("scoreBar", barData, barLayout);',
        '</script>'
    )
    
    # Create HTML results with plots
    html <- paste0(
        '<div style="padding:20px; font-family:Arial, sans-serif;">',
        '<h2 style="color:#003366; text-align:center;">HilFo Studie - Ihre Ergebnisse</h2>',
        
        # BFI Profile Section
        '<div style="background:#f5f5f5; padding:20px; border-radius:10px; margin:20px 0;">',
        '<h3 style="color:#003366;">Big Five Persönlichkeitsprofil</h3>',
        radar_plot_js,
        '</div>',
        
        # Detailed Scores Table
        '<div style="background:#f5f5f5; padding:20px; border-radius:10px; margin:20px 0;">',
        '<h3 style="color:#003366;">Detaillierte Auswertung</h3>',
        '<table style="width:100%; border-collapse:collapse;">',
        '<tr style="background:#003366; color:white;">',
        '<th style="padding:10px;">Dimension</th>',
        '<th style="padding:10px;">Ihr Score</th>',
        '<th style="padding:10px;">Interpretation</th>',
        '</tr>',
        
        '<tr><td style="padding:8px; border:1px solid #ddd;">Extraversion</td>',
        '<td style="text-align:center; border:1px solid #ddd;">', round(scores$extraversion, 2), '</td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$extraversion >= 3.5, "Gesellig, energiegeladen", "Zurückhaltend, ruhig"), '</td></tr>',
        
        '<tr style="background:#f9f9f9;"><td style="padding:8px; border:1px solid #ddd;">Verträglichkeit</td>',
        '<td style="text-align:center; border:1px solid #ddd;">', round(scores$agreeableness, 2), '</td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$agreeableness >= 3.5, "Kooperativ, vertrauensvoll", "Wettbewerbsorientiert, skeptisch"), '</td></tr>',
        
        '<tr><td style="padding:8px; border:1px solid #ddd;">Gewissenhaftigkeit</td>',
        '<td style="text-align:center; border:1px solid #ddd;">', round(scores$conscientiousness, 2), '</td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$conscientiousness >= 3.5, "Organisiert, zuverlässig", "Flexibel, spontan"), '</td></tr>',
        
        '<tr style="background:#f9f9f9;"><td style="padding:8px; border:1px solid #ddd;">Neurotizismus</td>',
        '<td style="text-align:center; border:1px solid #ddd;">', round(scores$neuroticism, 2), '</td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$neuroticism >= 3.5, "Emotional sensibel", "Emotional stabil"), '</td></tr>',
        
        '<tr><td style="padding:8px; border:1px solid #ddd;">Offenheit</td>',
        '<td style="text-align:center; border:1px solid #ddd;">', round(scores$openness, 2), '</td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$openness >= 3.5, "Kreativ, neugierig", "Praktisch, konventionell"), '</td></tr>',
        
        '<tr style="background:#ffe6e6;"><td style="padding:8px; border:1px solid #ddd;"><strong>Stresslevel</strong></td>',
        '<td style="text-align:center; border:1px solid #ddd;"><strong>', round(scores$stress, 2), '</strong></td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$stress >= 3.5, "Erhöhtes Stressniveau", "Moderates Stressniveau"), '</td></tr>',
        
        '<tr style="background:#e6ffe6;"><td style="padding:8px; border:1px solid #ddd;"><strong>Studierfähigkeiten</strong></td>',
        '<td style="text-align:center; border:1px solid #ddd;"><strong>', round(scores$study_skills, 2), '</strong></td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$study_skills >= 3.5, "Gut ausgeprägt", "Entwicklungspotenzial vorhanden"), '</td></tr>',
        
        '<tr style="background:#e6f3ff;"><td style="padding:8px; border:1px solid #ddd;"><strong>Statistik-Kompetenz</strong></td>',
        '<td style="text-align:center; border:1px solid #ddd;"><strong>', round(scores$statistics, 2), '</strong></td>',
        '<td style="border:1px solid #ddd;">', 
        ifelse(scores$statistics >= 3.5, "Gutes Verständnis", "Unterstützung empfohlen"), '</td></tr>',
        
        '</table>',
        '</div>',
        
        # All Scores Bar Chart
        '<div style="background:#f5f5f5; padding:20px; border-radius:10px; margin:20px 0;">',
        '<h3 style="color:#003366;">Gesamtübersicht</h3>',
        bar_chart_js,
        '</div>',
        
        # Recommendations
        '<div style="background:#e8f4fd; padding:20px; border-radius:10px; margin:20px 0;">',
        '<h3 style="color:#003366;">Empfehlungen</h3>',
        '<ul style="line-height:1.8;">',
        if(scores$stress >= 3.5) '<li>Nutzen Sie Stressmanagement-Techniken und die psychologische Beratung der Universität.</li>' else '',
        if(scores$study_skills < 3) '<li>Erwägen Sie die Teilnahme an Lerngruppen und Soft-Skill-Workshops.</li>' else '',
        if(scores$statistics < 3) '<li>Die Statistik-Tutorien können Ihnen helfen, Ihr Verständnis zu vertiefen.</li>' else '',
        if(scores$neuroticism >= 4) '<li>Achten Sie auf Ihre Work-Life-Balance und nutzen Sie Entspannungstechniken.</li>' else '',
        '<li>Nutzen Sie Ihre Stärken bewusst für Ihren Studienerfolg.</li>',
        '</ul>',
        '</div>',
        
        '<p style="text-align:center; margin-top:30px; font-size:18px; color:#003366;">',
        '<strong>Vielen Dank für Ihre Teilnahme an der HilFo Studie!</strong></p>',
        '</div>'
    )
    
    return(shiny::HTML(html))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
    # Basic info
    name = "HilFo Studie - Hildesheimer Forschungsmethoden Studie",
    study_key = session_uuid,
    theme = "hildesheim",
    
    # Demographics
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
    
    # Session settings
    session_save = TRUE,
    session_timeout = 30,
    
    # Provide configurations
    demographic_configs = demographic_configs,
    
    # German instructions
    instructions = list(
        welcome = "Willkommen zur HilFo Studie",
        purpose = paste0(
            "<h3>Liebe Studierende,</h3>",
            "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen ",
            "Daten arbeiten, die von Ihnen selbst stammen.</p>",
            "<p>Der Fragebogen deckt verschiedene Themenbereiche ab:</p>",
            "<ul>",
            "<li>Persönlichkeit (Big Five)</li>",
            "<li>Stresserleben</li>",
            "<li>Studierfähigkeiten</li>",
            "<li>Statistik-Selbstwirksamkeit</li>",
            "</ul>",
            "<p><strong>Ihre Angaben sind selbstverständlich anonym.</strong></p>"
        ),
        duration = "Dauer: etwa 15-20 Minuten",
        structure = paste0(
            "<h4>Ablauf:</h4>",
            "<ol>",
            "<li>Einverständniserklärung</li>",
            "<li>Demografische Angaben</li>",
            "<li>Persönlichkeitsfragebogen</li>",
            "<li>Weitere Fragebögen</li>",
            "<li>Persönliche Auswertung mit Grafiken</li>",
            "</ol>"
        )
    ),
    
    # Show instructions first
    show_introduction = TRUE,
    show_consent = FALSE,
    
    # Results processor with plots
    results_processor = create_hildesheim_results,
    
    # Non-adaptive settings
    criteria = "RANDOM",
    fixed_items = 1:31,
    adaptive_start = 999
)

# =============================================================================
# LAUNCH
# =============================================================================

cat("\n=============================================================================\n")
cat("HilFo STUDIE - HILDESHEIMER FORSCHUNGSMETHODEN STUDIE\n")
cat("=============================================================================\n")
cat("✓ Items: ", nrow(all_items), "\n")
cat("✓ Demographics: ", length(study_config$demographics), "\n")
cat("✓ Instructions: German\n")
cat("✓ Results: BFI profile with plots\n")
cat("=============================================================================\n\n")

# Launch the study
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    save_format = "csv",
    study_key = session_uuid
)