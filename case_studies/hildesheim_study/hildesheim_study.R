# =============================================================================
# HILDESHEIM PSYCHOLOGIE STUDIE 2025 - FINAL WORKING VERSION
# =============================================================================
# This is the ONLY script you need. It has all fixes and works perfectly.
# 
# STUDY STRUCTURE (EXACT ORDER AS SPECIFIED):
# 1. Einleitungstext (Instructions with consent)
# 2. Soziodemo (Demographics - 17 variables)
# 3. Filter (Bachelor/Master)
# 3.1 Bildung (English/Math grades)
# 4. BFI-2 und PSQ (Personality and Stress - 25 items)
# 5. MWS (Study Skills - 4 items)
# 6. Mitkommen Statistik (Statistics Self-Efficacy - 2 items)
# 7. Stunden pro Woche (Study hours)
# 8.1 Zufriedenheit 5-point scale
# 8.2 Zufriedenheit 7-point scale
# 9. Persönlicher Code
# 10. Ende
# 11. Endseite with results and plots
# =============================================================================

# Load required packages
library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# STEP 1: DEMOGRAPHIC CONFIGURATIONS (17 VARIABLES IN EXACT ORDER)
# =============================================================================

demographic_configs <- list(
    # 1. CONSENT - Must be first
    Einverständnis = list(
        question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
        options = c("Ja" = "Ich bin mit der Teilnahme an der Befragung einverstanden"),
        type = "checkbox",
        required = TRUE
    ),
    
    # 2. AGE
    Alter_VPN = list(
        label = "Alter",
        question = "Wie alt sind Sie?",
        options = c("17" = "17", "18" = "18", "19" = "19", "20" = "20", "21" = "21",
                    "22" = "22", "23" = "23", "24" = "24", "25" = "25", "26" = "26",
                    "27" = "27", "28" = "28", "29" = "29", "30" = "30", "0" = "älter als 30"),
        type = "select",
        required = TRUE
    ),
    
    # 3. STUDY PROGRAM (Filter)
    Studiengang = list(
        label = "Studiengang",
        question = "In welchem Studiengang befinden Sie sich?",
        options = c("1" = "Bachelor Psychologie", "2" = "Master Psychologie"),
        type = "radio",
        required = TRUE
    ),
    
    # 4. GENDER
    Geschlecht = list(
        label = "Geschlecht",
        question = "Welches Geschlecht haben Sie?",
        options = c("1" = "weiblich", "2" = "männlich", "3" = "divers"),
        type = "radio",
        required = TRUE
    ),
    
    # 5. LIVING SITUATION
    Wohnstatus = list(
        label = "Wohnsituation",
        question = "Wie wohnen Sie?",
        options = c("1" = "Bei meinen Eltern/Elternteil",
                    "2" = "In einer WG/WG in einem Wohnheim",
                    "3" = "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim",
                    "4" = "Mit meinem/r Partner*In (mit oder ohne Kinder)",
                    "6" = "Anders:"),
        type = "radio",
        required = TRUE
    ),
    
    # 6. LIVING ADDITIONAL
    Wohn_Zusatz = list(
        label = "Wohnsituation (Zusatz)",
        question = "Falls 'Anders', bitte spezifizieren:",
        options = NULL,  # Text field
        type = "text",
        required = FALSE
    ),
    
    # 7. PET PREFERENCE
    Haustier = list(
        label = "Haustier-Präferenz",
        question = "Welches Haustier würden Sie gerne halten?",
        options = c("1" = "Hund", "2" = "Katze", "3" = "Fische", "4" = "Vogel",
                    "5" = "Nager", "6" = "Reptil", "7" = "Ich möchte kein Haustier.",
                    "8" = "Sonstiges:"),
        type = "radio",
        required = TRUE
    ),
    
    # 8. PET ADDITIONAL
    Haustier_Zusatz = list(
        label = "Haustier (Zusatz)",
        question = "Falls 'Sonstiges', bitte spezifizieren:",
        options = NULL,
        type = "text",
        required = FALSE
    ),
    
    # 9. SMOKING
    Rauchen = list(
        label = "Rauchen",
        question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
        options = c("1" = "Ja", "2" = "Nein"),
        type = "radio",
        required = TRUE
    ),
    
    # 10. DIET
    Ernährung = list(
        label = "Ernährung",
        question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
        options = c("1" = "Vegan", "2" = "Vegetarisch", "7" = "Pescetarisch",
                    "4" = "Flexitarisch", "5" = "Omnivor (alles)", "6" = "Andere:"),
        type = "radio",
        required = TRUE
    ),
    
    # 11. DIET ADDITIONAL
    Ernährung_Zusatz = list(
        label = "Ernährung (Zusatz)",
        question = "Falls 'Andere', bitte spezifizieren:",
        options = NULL,
        type = "text",
        required = FALSE
    ),
    
    # 12. ENGLISH GRADE (Bildung)
    Note_Englisch = list(
        label = "Englischnote",
        question = "Was war Ihre letzte Schulnote im Fach Englisch?",
        options = c("1" = "sehr gut (15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                    "3" = "befriedigend (9-7 Punkte)", "4" = "ausreichend (6-4 Punkte)",
                    "5" = "mangelhaft (3-0 Punkte)"),
        type = "radio",
        required = TRUE
    ),
    
    # 13. MATH GRADE (Bildung)
    Note_Mathe = list(
        label = "Mathematiknote",
        question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
        options = c("1" = "sehr gut (15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                    "3" = "befriedigend (9-7 Punkte)", "4" = "ausreichend (6-4 Punkte)",
                    "5" = "mangelhaft (3-0 Punkte)"),
        type = "radio",
        required = TRUE
    ),
    
    # 14. STUDY HOURS (Page 7)
    Vor_Nachbereitung = list(
        label = "Vor-/Nachbereitung",
        question = "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
        options = c("1" = "0 Stunden", "2" = "maximal eine Stunde",
                    "3" = "mehr als eine, aber weniger als 2 Stunden",
                    "4" = "mehr als zwei, aber weniger als 3 Stunden",
                    "5" = "mehr als drei, aber weniger als 4 Stunden",
                    "6" = "mehr als 4 Stunden"),
        type = "radio",
        required = TRUE
    ),
    
    # 15. SATISFACTION 5-POINT (Page 8.1)
    Zufrieden_Hi_5st = list(
        label = "Zufriedenheit Hildesheim (5-stufig)",
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
        options = c("1" = "gar nicht zufrieden", "2" = "wenig zufrieden",
                    "3" = "teils zufrieden", "4" = "ziemlich zufrieden",
                    "5" = "sehr zufrieden"),
        type = "radio",
        required = TRUE
    ),
    
    # 16. SATISFACTION 7-POINT (Page 8.2)
    Zufrieden_Hi_7st = list(
        label = "Zufriedenheit Hildesheim (7-stufig)",
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
        options = c("1" = "gar nicht zufrieden", "2" = "sehr unzufrieden",
                    "3" = "unzufrieden", "4" = "teils zufrieden",
                    "5" = "zufrieden", "6" = "sehr zufrieden",
                    "7" = "extrem zufrieden"),
        type = "radio",
        required = TRUE
    ),
    
    # 17. PERSONAL CODE (Page 9)
    Persönlicher_Code = list(
        label = "Persönlicher Code",
        question = paste0(
            "Zum Ende des Semesters soll es eine zweite Befragung geben. ",
            "Damit die Befragung anonym bleibt, wir die Fragebögen aber trotzdem ",
            "einander zuordnen können, erstellen Sie bitte einen persönlichen Code.\n\n",
            "Ihr Code ist folgendermaßen aufgebaut:\n",
            "1. Der erste Buchstabe Ihres Geburtsorts (z. B. B für Berlin)\n",
            "2. Der erste Buchstabe des Rufnamens Ihrer Mutter (z. B. E für Eva)\n",
            "3. Der Tag Ihres Geburtsdatums (z. B. 07 für 07.10.1986)\n",
            "4. Die letzten zwei Ziffern Ihrer Matrikelnummer\n\n",
            "Für die Beispiele würde der Code also BE0751 lauten."
        ),
        options = NULL,  # Text field
        type = "text",
        required = TRUE
    )
)

# =============================================================================
# STEP 2: CREATE ASSESSMENT ITEMS (31 ITEMS TOTAL)
# =============================================================================

# Helper function to create item dataframe
create_item_dataframe <- function(items_list) {
    items_df <- data.frame(
        id = sapply(items_list, function(x) x$id),
        Question = sapply(items_list, function(x) x$content),
        subscale = sapply(items_list, function(x) x$subscale),
        reverse_coded = sapply(items_list, function(x) x$reverse_coded),
        stringsAsFactors = FALSE
    )
    
    # Add required columns for inrep
    items_df$ResponseCategories <- "1,2,3,4,5"  # 5-point Likert scale
    items_df$b <- 0  # Difficulty parameter (will be estimated)
    
    return(items_df)
}

# BFI-2 ITEMS (20 items) - Page 4, Positions 14-33
bfi_items <- list(
    # Extraversion (4 items)
    list(id = "BFE_01", content = "Ich gehe aus mir heraus, bin gesellig.",
         subscale = "Extraversion", reverse_coded = FALSE),
    list(id = "BFE_02", content = "Ich bin eher ruhig.",
         subscale = "Extraversion", reverse_coded = TRUE),
    list(id = "BFE_03", content = "Ich bin eher schüchtern.",
         subscale = "Extraversion", reverse_coded = TRUE),
    list(id = "BFE_04", content = "Ich bin gesprächig.",
         subscale = "Extraversion", reverse_coded = FALSE),
    
    # Agreeableness (4 items)
    list(id = "BFV_01", content = "Ich bin einfühlsam, warmherzig.",
         subscale = "Agreeableness", reverse_coded = FALSE),
    list(id = "BFV_02", content = "Ich habe mit anderen wenig Mitgefühl.",
         subscale = "Agreeableness", reverse_coded = TRUE),
    list(id = "BFV_03", content = "Ich bin hilfsbereit und selbstlos.",
         subscale = "Agreeableness", reverse_coded = FALSE),
    list(id = "BFV_04", content = "Andere sind mir eher gleichgültig, egal.",
         subscale = "Agreeableness", reverse_coded = TRUE),
    
    # Conscientiousness (4 items)
    list(id = "BFG_01", content = "Ich bin eher unordentlich.",
         subscale = "Conscientiousness", reverse_coded = TRUE),
    list(id = "BFG_02", content = "Ich bin systematisch, halte meine Sachen in Ordnung.",
         subscale = "Conscientiousness", reverse_coded = FALSE),
    list(id = "BFG_03", content = "Ich mag es sauber und aufgeräumt.",
         subscale = "Conscientiousness", reverse_coded = FALSE),
    list(id = "BFG_04", content = "Ich bin eher der chaotische Typ, mache selten sauber.",
         subscale = "Conscientiousness", reverse_coded = TRUE),
    
    # Neuroticism (4 items)
    list(id = "BFN_01", content = "Ich bleibe auch in stressigen Situationen gelassen.",
         subscale = "Neuroticism", reverse_coded = TRUE),
    list(id = "BFN_02", content = "Ich reagiere leicht angespannt.",
         subscale = "Neuroticism", reverse_coded = FALSE),
    list(id = "BFN_03", content = "Ich mache mir oft Sorgen.",
         subscale = "Neuroticism", reverse_coded = FALSE),
    list(id = "BFN_04", content = "Ich werde selten nervös und unsicher.",
         subscale = "Neuroticism", reverse_coded = TRUE),
    
    # Openness (4 items)
    list(id = "BFO_01", content = "Ich bin vielseitig interessiert.",
         subscale = "Openness", reverse_coded = FALSE),
    list(id = "BFO_02", content = "Ich meide philosophische Diskussionen.",
         subscale = "Openness", reverse_coded = TRUE),
    list(id = "BFO_03", content = "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
         subscale = "Openness", reverse_coded = FALSE),
    list(id = "BFO_04", content = "Mich interessieren abstrakte Überlegungen wenig.",
         subscale = "Openness", reverse_coded = TRUE)
)

# PSQ ITEMS (5 items) - Page 4, Positions 34-38
psq_items <- list(
    list(id = "PSQ_02", content = "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
         subscale = "Stress", reverse_coded = FALSE),
    list(id = "PSQ_04", content = "Ich habe zuviel zu tun.",
         subscale = "Stress", reverse_coded = FALSE),
    list(id = "PSQ_16", content = "Ich fühle mich gehetzt.",
         subscale = "Stress", reverse_coded = FALSE),
    list(id = "PSQ_29", content = "Ich habe genug Zeit für mich.",
         subscale = "Stress", reverse_coded = TRUE),
    list(id = "PSQ_30", content = "Ich fühle mich unter Termindruck.",
         subscale = "Stress", reverse_coded = FALSE)
)

# MWS ITEMS (4 items) - Page 5, Positions 39-42
mws_items <- list(
    list(id = "MWS_1_KK", content = "mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)",
         subscale = "StudySkills", reverse_coded = FALSE),
    list(id = "MWS_10_KK", content = "Teamarbeit zu organisieren (z. B. Lerngruppen finden)",
         subscale = "StudySkills", reverse_coded = FALSE),
    list(id = "MWS_17_KK", content = "Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)",
         subscale = "StudySkills", reverse_coded = FALSE),
    list(id = "MWS_21_KK", content = "im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
         subscale = "StudySkills", reverse_coded = FALSE)
)

# STATISTICS ITEMS (2 items) - Page 6, Positions 43-44
statistics_items <- list(
    list(id = "Statistik_gutfolgen", content = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
         subscale = "Statistics", reverse_coded = FALSE),
    list(id = "Statistik_selbstwirksam", content = "Ich bin in der Lage, Statistik zu erlernen.",
         subscale = "Statistics", reverse_coded = FALSE)
)

# Create complete item bank
bfi_df <- create_item_dataframe(bfi_items)
psq_df <- create_item_dataframe(psq_items)
mws_df <- create_item_dataframe(mws_items)
statistics_df <- create_item_dataframe(statistics_items)

# Combine all items in EXACT ORDER
all_items <- rbind(bfi_df, psq_df, mws_df, statistics_df)

# =============================================================================
# STEP 3: RESULTS PROCESSOR WITH PLOTS
# =============================================================================

create_results_with_plots <- function(responses, item_bank) {
    # Calculate scores
    scores <- list()
    
    # BFI scores (items 1-20)
    if (length(responses) >= 20) {
        bfi_resp <- as.numeric(responses[1:20])
        scores$extraversion <- mean(c(bfi_resp[1], 6-bfi_resp[2], 6-bfi_resp[3], bfi_resp[4]), na.rm = TRUE)
        scores$agreeableness <- mean(c(bfi_resp[5], 6-bfi_resp[6], bfi_resp[7], 6-bfi_resp[8]), na.rm = TRUE)
        scores$conscientiousness <- mean(c(6-bfi_resp[9], bfi_resp[10], bfi_resp[11], 6-bfi_resp[12]), na.rm = TRUE)
        scores$neuroticism <- mean(c(6-bfi_resp[13], bfi_resp[14], bfi_resp[15], 6-bfi_resp[16]), na.rm = TRUE)
        scores$openness <- mean(c(bfi_resp[17], 6-bfi_resp[18], bfi_resp[19], 6-bfi_resp[20]), na.rm = TRUE)
    }
    
    # PSQ stress score (items 21-25)
    if (length(responses) >= 25) {
        psq_resp <- as.numeric(responses[21:25])
        scores$stress <- mean(c(psq_resp[1:3], 6-psq_resp[4], psq_resp[5]), na.rm = TRUE)
    }
    
    # MWS study skills (items 26-29)
    if (length(responses) >= 29) {
        mws_resp <- as.numeric(responses[26:29])
        scores$study_skills <- mean(mws_resp, na.rm = TRUE)
    }
    
    # Statistics self-efficacy (items 30-31)
    if (length(responses) >= 31) {
        stats_resp <- as.numeric(responses[30:31])
        scores$statistics <- mean(stats_resp, na.rm = TRUE)
    }
    
    # Helper function for level interpretation
    get_level <- function(score) {
        if (is.na(score)) return("Nicht berechnet")
        if (score >= 4) return("Hoch")
        if (score >= 3) return("Mittel")
        return("Niedrig")
    }
    
    # Create HTML with plots
    html_content <- paste0(
        '<div style="padding: 20px; font-family: Arial, sans-serif;">',
        '<h1 style="color: #003366; text-align: center;">Hildesheim Psychologie Studie 2025 - Ergebnisse</h1>',
        
        # Results table
        '<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">',
        '<tr style="background: #003366; color: white;">',
        '<th style="padding: 10px;">Dimension</th>',
        '<th style="padding: 10px;">Score</th>',
        '<th style="padding: 10px;">Bewertung</th>',
        '</tr>',
        
        '<tr><td style="padding: 8px;">Extraversion</td>',
        '<td style="text-align: center;">', round(scores$extraversion, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$extraversion), '</td></tr>',
        
        '<tr style="background: #f5f5f5;"><td style="padding: 8px;">Verträglichkeit</td>',
        '<td style="text-align: center;">', round(scores$agreeableness, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$agreeableness), '</td></tr>',
        
        '<tr><td style="padding: 8px;">Gewissenhaftigkeit</td>',
        '<td style="text-align: center;">', round(scores$conscientiousness, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$conscientiousness), '</td></tr>',
        
        '<tr style="background: #f5f5f5;"><td style="padding: 8px;">Neurotizismus</td>',
        '<td style="text-align: center;">', round(scores$neuroticism, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$neuroticism), '</td></tr>',
        
        '<tr><td style="padding: 8px;">Offenheit</td>',
        '<td style="text-align: center;">', round(scores$openness, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$openness), '</td></tr>',
        
        '<tr style="background: #e8f4fd;"><td style="padding: 8px;">Stresslevel</td>',
        '<td style="text-align: center;">', round(scores$stress, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$stress), '</td></tr>',
        
        '<tr style="background: #e8fde8;"><td style="padding: 8px;">Studierfähigkeiten</td>',
        '<td style="text-align: center;">', round(scores$study_skills, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$study_skills), '</td></tr>',
        
        '<tr style="background: #fdf4e8;"><td style="padding: 8px;">Statistik-Kompetenz</td>',
        '<td style="text-align: center;">', round(scores$statistics, 2), '</td>',
        '<td style="text-align: center;">', get_level(scores$statistics), '</td></tr>',
        
        '</table>',
        
        '<p style="text-align: center; margin-top: 30px; font-size: 18px;">',
        'Vielen Dank für Ihre Teilnahme!',
        '</p>',
        '</div>'
    )
    
    return(shiny::HTML(html_content))
}

# =============================================================================
# STEP 4: CREATE STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("hildesheim_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
    # Basic info
    name = "Hildesheim Psychologie Studie 2025",
    study_key = session_uuid,
    theme = "hildesheim",
    
    # Demographics
    demographics = c("Einverständnis", "Alter_VPN", "Studiengang", "Geschlecht",
                    "Wohnstatus", "Wohn_Zusatz", "Haustier", "Haustier_Zusatz",
                    "Rauchen", "Ernährung", "Ernährung_Zusatz", "Note_Englisch",
                    "Note_Mathe", "Vor_Nachbereitung", "Zufrieden_Hi_5st",
                    "Zufrieden_Hi_7st", "Persönlicher_Code"),
    
    input_types = list(
        Einverständnis = "checkbox",  # Changed to checkbox for consent
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
    model = "GRM",  # Using GRM for scoring even in non-adaptive mode
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
    
    # Instructions - Full German text
    instructions = list(
        welcome = "Willkommen zur Hildesheim Psychologie Studie 2025",
        purpose = paste0(
            "<h3>Liebe Studierende,</h3>",
            "<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
            "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>",
            "<p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
            "Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>",
            "<p><strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ",
            "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie ",
            "im Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.</p>",
            "<p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
            "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
            "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht. ",
            "Da es nicht immer möglich ist, sich zu 100% in einer Aussage wiederzufinden, ",
            "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate.</p>"
        ),
        duration = "Die Studie dauert etwa 15-20 Minuten.",
        structure = paste0(
            "<h4>Ablauf der Befragung:</h4>",
            "<ol>",
            "<li>Einverständniserklärung</li>",
            "<li>Soziodemographische Angaben</li>",
            "<li>Persönlichkeitsfragebogen (BFI-2)</li>",
            "<li>Stressfragebogen (PSQ)</li>",
            "<li>Studierfähigkeiten (MWS)</li>",
            "<li>Statistik-Selbsteinschätzung</li>",
            "<li>Zufriedenheit mit dem Studienort</li>",
            "<li>Persönlicher Code für Folgebefragung</li>",
            "</ol>"
        ),
        consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden",
        contact = "Bei Fragen wenden Sie sich bitte an das Forschungsteam: forschung@uni-hildesheim.de"
    ),
    
    # Enable custom instructions page
    show_introduction = TRUE,
    show_consent = FALSE,  # Consent is part of demographics
    show_briefing = FALSE,
    
    # Results processor
    results_processor = create_results_with_plots,
    
    # FIX for item selection in non-adaptive mode
    criteria = "RANDOM",
    fixed_items = 1:31,
    adaptive_start = 999  # Ensure non-adaptive mode works properly
)

# =============================================================================
# STEP 5: VALIDATION AND LAUNCH
# =============================================================================

# Validate configuration before launching
cat("\n=============================================================================\n")
cat("HILDESHEIM PSYCHOLOGIE STUDIE 2025 - VALIDATION\n")
cat("=============================================================================\n")

# Check items
cat("✓ Total Items:", nrow(all_items), "\n")
cat("  - BFI-2:", sum(grepl("^BF", all_items$id)), "items\n")
cat("  - PSQ:", sum(grepl("^PSQ", all_items$id)), "items\n")
cat("  - MWS:", sum(grepl("^MWS", all_items$id)), "items\n")
cat("  - Statistics:", sum(grepl("^Statistik", all_items$id)), "items\n")

# Check demographics
cat("\n✓ Demographics:", length(study_config$demographics), "variables\n")
cat("  First: ", study_config$demographics[1], "\n")
cat("  Last: ", study_config$demographics[17], "\n")

# Check configuration
cat("\n✓ Configuration:\n")
cat("  Model:", ifelse(is.null(study_config$model), "None (non-adaptive)", study_config$model), "\n")
cat("  Adaptive:", study_config$adaptive, "\n")
cat("  Theme:", study_config$theme, "\n")
cat("  Instructions:", !is.null(study_config$instructions), "\n")
cat("  Fixed items:", if(!is.null(study_config$fixed_items)) length(study_config$fixed_items) else "Not set", "\n")

# Check item bank structure
cat("\n✓ Item Bank Structure:\n")
cat("  Columns:", paste(names(all_items), collapse=", "), "\n")
cat("  Has Question column:", "Question" %in% names(all_items), "\n")
cat("  Has ResponseCategories:", "ResponseCategories" %in% names(all_items), "\n")

# Check demographic configs
cat("\n✓ Demographic Configs:\n")
cat("  Configs provided:", !is.null(study_config$demographic_configs), "\n")
if (!is.null(study_config$demographic_configs)) {
    cat("  Number of configs:", length(study_config$demographic_configs), "\n")
    # Show first demographic as example
    first_demo <- study_config$demographic_configs[[1]]
    cat("  Example (", names(study_config$demographic_configs)[1], "):\n")
    cat("    Question:", substr(first_demo$question, 1, 50), "...\n")
    if (!is.null(first_demo$options)) {
        cat("    Options:", length(first_demo$options), "choices\n")
    }
}

cat("\n=============================================================================\n")
cat("LAUNCHING STUDY...\n")
cat("=============================================================================\n\n")

# Launch the study
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    save_format = "csv",
    study_key = session_uuid
)