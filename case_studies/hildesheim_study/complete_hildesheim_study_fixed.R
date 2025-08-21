# =============================================================================
# HILDESHEIM PSYCHOLOGIE STUDIE 2025 - COMPLETE IMPLEMENTATION
# =============================================================================
# This script implements the Hildesheim Psychology Study using the inrep package
# with proper integration and all required functionality.

# Load required libraries
library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)
library(DT)

# =============================================================================
# WEBDAV CONFIGURATION
# =============================================================================
webdav_url <- "https://sync.academiccloud.de/index.php/s/YourSharedFolder/"
password <- Sys.getenv("WEBDAV_PASSWORD")
if (password == "") password <- "your_password_here"

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS - EXACT HILDESHEIM SPECIFICATION
# =============================================================================
demographic_configs <- list(
    # 1. Consent (Einverständnis) - Position 1
    Einverständnis = list(
        question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
        options = c("1" = "Ich bin mit der Teilnahme an der Befragung einverstanden"),
        required = TRUE,
        page = 1,
        position = 1
    ),
    
    # 2. Age (Alter_VPN) - Position 2
    Alter_VPN = list(
        question = "Wie alt sind Sie?",
        options = c("17" = "17", "18" = "18", "19" = "19", "20" = "20", "21" = "21",
                    "22" = "22", "23" = "23", "24" = "24", "25" = "25", "26" = "26",
                    "27" = "27", "28" = "28", "29" = "29", "30" = "30", "0" = "älter als 30"),
        required = TRUE,
        page = 2,
        position = 2
    ),
    
    # 3. Study Program (Studiengang) - Position 3
    Studiengang = list(
        question = "In welchem Studiengang befinden Sie sich?",
        options = c("1" = "Bachelor Psychologie", "2" = "Master Psychologie"),
        required = TRUE,
        page = 2,
        position = 3
    ),
    
    # 4. Gender (Geschlecht) - Position 4
    Geschlecht = list(
        question = "Welches Geschlecht haben Sie?",
        options = c("1" = "weiblich", "2" = "männlich", "3" = "divers"),
        required = TRUE,
        page = 2,
        position = 4
    ),
    
    # 5. Living Situation (Wohnstatus) - Position 5
    Wohnstatus = list(
        question = "Wie wohnen Sie?",
        options = c("1" = "Bei meinen Eltern/Elternteil", 
                    "2" = "In einer WG/WG in einem Wohnheim",
                    "3" = "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim",
                    "4" = "Mit meinem/r Partner*In (mit oder ohne Kinder)", 
                    "6" = "Anders:"),
        required = TRUE,
        page = 2,
        position = 5
    ),
    
    # 6. Living Additional (Wohn_Zusatz) - Position 6
    Wohn_Zusatz = list(
        question = "Falls 'Anders', bitte spezifizieren:",
        options = NULL,  # Text field
        required = FALSE,
        page = 2,
        position = 6
    ),
    
    # 7. Pet (Haustier) - Position 7
    Haustier = list(
        question = "Welches Haustier würden Sie gerne halten?",
        options = c("1" = "Hund", "2" = "Katze", "3" = "Fische", "4" = "Vogel",
                    "5" = "Nager", "6" = "Reptil", "7" = "Ich möchte kein Haustier.", 
                    "8" = "Sonstiges:"),
        required = TRUE,
        page = 2,
        position = 7
    ),
    
    # 8. Pet Additional (Haustier_Zusatz) - Position 8
    Haustier_Zusatz = list(
        question = "Falls 'Sonstiges', bitte spezifizieren:",
        options = NULL,  # Text field
        required = FALSE,
        page = 2,
        position = 8
    ),
    
    # 9. Smoking (Rauchen) - Position 9
    Rauchen = list(
        question = "Rauchen Sie regelmäßig?",
        options = c("1" = "Ja", "2" = "Nein"),
        required = TRUE,
        page = 2,
        position = 9
    ),
    
    # 10. Diet (Ernährung) - Position 10
    Ernährung = list(
        question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
        options = c("1" = "Vegan", "2" = "Vegetarisch", "7" = "Pescetarisch",
                    "4" = "Flexitarisch", "5" = "Omnivor (alles)", "6" = "Andere:"),
        required = TRUE,
        page = 2,
        position = 10
    ),
    
    # 11. Diet Additional (Ernährung_Zusatz) - Position 11
    Ernährung_Zusatz = list(
        question = "Falls 'Andere', bitte spezifizieren:",
        options = NULL,  # Text field
        required = FALSE,
        page = 2,
        position = 11
    ),
    
    # 12. English Grade (Note_Englisch) - Position 12
    Note_Englisch = list(
        question = "Was war Ihre letzte Schulnote im Fach Englisch?",
        options = c("1" = "sehr gut (15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                    "3" = "befriedigend (9-7 Punkte)", "4" = "ausreichend (6-4 Punkte)",
                    "5" = "mangelhaft (3-0 Punkte)"),
        required = TRUE,
        page = 3,
        position = 12
    ),
    
    # 13. Math Grade (Note_Mathe) - Position 13
    Note_Mathe = list(
        question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
        options = c("1" = "sehr gut (15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                    "3" = "befriedigend (9-7 Punkte)", "4" = "ausreichend (6-4 Punkte)",
                    "5" = "mangelhaft (3-0 Punkte)"),
        required = TRUE,
        page = 3,
        position = 13
    ),
    
    # 14. Study Preparation (Vor_Nachbereitung) - Position 45
    Vor_Nachbereitung = list(
        question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
        options = c("1" = "0 Stunden", "2" = "maximal eine Stunde",
                    "3" = "mehr als eine, aber weniger als 2 Stunden",
                    "4" = "mehr als zwei, aber weniger als 3 Stunden",
                    "5" = "mehr als drei, aber weniger als 4 Stunden",
                    "6" = "mehr als 4 Stunden"),
        required = TRUE,
        page = 7,
        position = 45
    ),
    
    # 15. Satisfaction Hildesheim 5-point (Zufrieden_Hi_5st) - Position 46
    Zufrieden_Hi_5st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
        options = c("1" = "gar nicht zufrieden", "2" = "eher nicht zufrieden", 
                    "3" = "teils-teils", "4" = "eher zufrieden", "5" = "sehr zufrieden"),
        required = TRUE,
        page = 8,
        position = 46
    ),
    
    # 16. Satisfaction Hildesheim 7-point (Zufrieden_Hi_7st) - Position 47
    Zufrieden_Hi_7st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
        options = c("1" = "gar nicht zufrieden", "2" = "sehr unzufrieden", 
                    "3" = "unzufrieden", "4" = "teils-teils", 
                    "5" = "zufrieden", "6" = "sehr zufrieden", "7" = "extrem zufrieden"),
        required = TRUE,
        page = 8,
        position = 47
    ),
    
    # 17. Personal Code (Persönlicher_Code) - Position 48
    Persönlicher_Code = list(
        question = paste0("Bitte erstellen Sie einen persönlichen Code:\n",
                         "1. Erster Buchstabe Ihres Geburtsorts\n",
                         "2. Erster Buchstabe des Rufnamens Ihrer Mutter\n",
                         "3. Tag Ihres Geburtsdatums (z.B. 07)\n",
                         "4. Letzte zwei Ziffern Ihrer Matrikelnummer"),
        options = NULL,  # Text field
        required = TRUE,
        page = 9,
        position = 48
    )
)

# =============================================================================
# ITEM DEFINITIONS - BFI-2, PSQ, MWS, STATISTICS
# =============================================================================

# Helper function to create item dataframe
create_item_dataframe <- function(items_list) {
    items_df <- data.frame(
        id = sapply(items_list, function(x) x$id),
        Question = sapply(items_list, function(x) x$content),
        subscale = sapply(items_list, function(x) x$subscale),
        reverse_coded = sapply(items_list, function(x) x$reverse_coded),
        page = sapply(items_list, function(x) x$page),
        position = sapply(items_list, function(x) x$position),
        stringsAsFactors = FALSE
    )
    
    # Add response categories for GRM model
    items_df$ResponseCategories <- "1,2,3,4,5"
    
    # Add difficulty parameters (will be estimated by TAM)
    items_df$b <- 0
    
    return(items_df)
}

# BFI-2 Items (20 items) - Page 4, Positions 14-33
bfi_items <- list(
    # Extraversion
    list(id = "BFE_01", content = "Ich gehe aus mir heraus, bin gesellig.", 
         subscale = "Extraversion", reverse_coded = FALSE, page = 4, position = 14),
    list(id = "BFE_02", content = "Ich bin eher ruhig.", 
         subscale = "Extraversion", reverse_coded = TRUE, page = 4, position = 19),
    list(id = "BFE_03", content = "Ich bin eher schüchtern.", 
         subscale = "Extraversion", reverse_coded = TRUE, page = 4, position = 24),
    list(id = "BFE_04", content = "Ich bin gesprächig.", 
         subscale = "Extraversion", reverse_coded = FALSE, page = 4, position = 29),
    
    # Agreeableness
    list(id = "BFV_01", content = "Ich bin einfühlsam, warmherzig.", 
         subscale = "Agreeableness", reverse_coded = FALSE, page = 4, position = 15),
    list(id = "BFV_02", content = "Ich habe mit anderen wenig Mitgefühl.", 
         subscale = "Agreeableness", reverse_coded = TRUE, page = 4, position = 20),
    list(id = "BFV_03", content = "Ich bin hilfsbereit und selbstlos.", 
         subscale = "Agreeableness", reverse_coded = FALSE, page = 4, position = 25),
    list(id = "BFV_04", content = "Andere sind mir eher gleichgültig, egal.", 
         subscale = "Agreeableness", reverse_coded = TRUE, page = 4, position = 30),
    
    # Conscientiousness
    list(id = "BFG_01", content = "Ich bin eher unordentlich.", 
         subscale = "Conscientiousness", reverse_coded = TRUE, page = 4, position = 16),
    list(id = "BFG_02", content = "Ich bin systematisch, halte meine Sachen in Ordnung.", 
         subscale = "Conscientiousness", reverse_coded = FALSE, page = 4, position = 21),
    list(id = "BFG_03", content = "Ich mag es sauber und aufgeräumt.", 
         subscale = "Conscientiousness", reverse_coded = FALSE, page = 4, position = 26),
    list(id = "BFG_04", content = "Ich bin eher der chaotische Typ, mache selten sauber.", 
         subscale = "Conscientiousness", reverse_coded = TRUE, page = 4, position = 31),
    
    # Neuroticism
    list(id = "BFN_01", content = "Ich bleibe auch in stressigen Situationen gelassen.", 
         subscale = "Neuroticism", reverse_coded = TRUE, page = 4, position = 17),
    list(id = "BFN_02", content = "Ich reagiere leicht angespannt.", 
         subscale = "Neuroticism", reverse_coded = FALSE, page = 4, position = 22),
    list(id = "BFN_03", content = "Ich mache mir oft Sorgen.", 
         subscale = "Neuroticism", reverse_coded = FALSE, page = 4, position = 27),
    list(id = "BFN_04", content = "Ich werde selten nervös und unsicher.", 
         subscale = "Neuroticism", reverse_coded = TRUE, page = 4, position = 32),
    
    # Openness
    list(id = "BFO_01", content = "Ich bin vielseitig interessiert.", 
         subscale = "Openness", reverse_coded = FALSE, page = 4, position = 18),
    list(id = "BFO_02", content = "Ich meide philosophische Diskussionen.", 
         subscale = "Openness", reverse_coded = TRUE, page = 4, position = 23),
    list(id = "BFO_03", content = "Es macht mir Spaß gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", 
         subscale = "Openness", reverse_coded = FALSE, page = 4, position = 28),
    list(id = "BFO_04", content = "Mich interessieren abstrakte Überlegungen wenig.", 
         subscale = "Openness", reverse_coded = TRUE, page = 4, position = 33)
)

# PSQ Items (5 items) - Page 4, Positions 34-38
psq_items <- list(
    list(id = "PSQ_02", content = "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", 
         subscale = "Stress", reverse_coded = FALSE, page = 4, position = 34),
    list(id = "PSQ_04", content = "Ich habe zuviel zu tun.", 
         subscale = "Stress", reverse_coded = FALSE, page = 4, position = 35),
    list(id = "PSQ_16", content = "Ich fühle mich gehetzt.", 
         subscale = "Stress", reverse_coded = FALSE, page = 4, position = 36),
    list(id = "PSQ_29", content = "Ich habe genug Zeit für mich.", 
         subscale = "Stress", reverse_coded = TRUE, page = 4, position = 37),
    list(id = "PSQ_30", content = "Ich fühle mich unter Termindruck.", 
         subscale = "Stress", reverse_coded = FALSE, page = 4, position = 38)
)

# MWS Items (4 items) - Page 5, Positions 39-42
mws_items <- list(
    list(id = "MWS_1_KK", content = "Mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)", 
         subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 39),
    list(id = "MWS_10_KK", content = "Teamarbeit zu organisieren (z. B. Lerngruppen finden)", 
         subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 40),
    list(id = "MWS_17_KK", content = "Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)", 
         subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 41),
    list(id = "MWS_21_KK", content = "Im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", 
         subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 42)
)

# Statistics Items (2 items) - Page 6, Positions 43-44
statistics_items <- list(
    list(id = "Statistik_gutfolgen", content = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", 
         subscale = "Statistics", reverse_coded = FALSE, page = 6, position = 43),
    list(id = "Statistik_selbstwirksam", content = "Ich bin in der Lage, Statistik zu erlernen.", 
         subscale = "Statistics", reverse_coded = FALSE, page = 6, position = 44)
)

# Create complete item bank
bfi_df <- create_item_dataframe(bfi_items)
psq_df <- create_item_dataframe(psq_items)
mws_df <- create_item_dataframe(mws_items)
statistics_df <- create_item_dataframe(statistics_items)

# Combine all items in exact order
all_items <- rbind(bfi_df, psq_df, mws_df, statistics_df)

# =============================================================================
# RESULTS PROCESSOR FUNCTION - GENERATES HTML FOR SHINY APP
# =============================================================================
create_hildesheim_results <- function(responses, item_bank) {
    # This function returns HTML content that will be displayed in the Shiny app
    
    # Helper function to calculate scores
    calculate_scores <- function(responses, items_df) {
        scores <- list()
        
        # Extract responses for BFI items (first 20)
        if (length(responses) >= 20) {
            bfi_resp <- as.numeric(responses[1:20])
            
            # Calculate BFI dimension scores with reverse coding
            scores$extraversion <- mean(c(
                bfi_resp[1],           # BFE_01
                6 - bfi_resp[2],       # BFE_02 (reversed)
                6 - bfi_resp[3],       # BFE_03 (reversed)
                bfi_resp[4]            # BFE_04
            ), na.rm = TRUE)
            
            scores$agreeableness <- mean(c(
                bfi_resp[5],           # BFV_01
                6 - bfi_resp[6],       # BFV_02 (reversed)
                bfi_resp[7],           # BFV_03
                6 - bfi_resp[8]        # BFV_04 (reversed)
            ), na.rm = TRUE)
            
            scores$conscientiousness <- mean(c(
                6 - bfi_resp[9],       # BFG_01 (reversed)
                bfi_resp[10],          # BFG_02
                bfi_resp[11],          # BFG_03
                6 - bfi_resp[12]       # BFG_04 (reversed)
            ), na.rm = TRUE)
            
            scores$neuroticism <- mean(c(
                6 - bfi_resp[13],      # BFN_01 (reversed)
                bfi_resp[14],          # BFN_02
                bfi_resp[15],          # BFN_03
                6 - bfi_resp[16]       # BFN_04 (reversed)
            ), na.rm = TRUE)
            
            scores$openness <- mean(c(
                bfi_resp[17],          # BFO_01
                6 - bfi_resp[18],      # BFO_02 (reversed)
                bfi_resp[19],          # BFO_03
                6 - bfi_resp[20]       # BFO_04 (reversed)
            ), na.rm = TRUE)
        }
        
        # Extract PSQ stress score (items 21-25)
        if (length(responses) >= 25) {
            psq_resp <- as.numeric(responses[21:25])
            scores$stress <- mean(c(
                psq_resp[1],           # PSQ_02
                psq_resp[2],           # PSQ_04
                psq_resp[3],           # PSQ_16
                6 - psq_resp[4],       # PSQ_29 (reversed)
                psq_resp[5]            # PSQ_30
            ), na.rm = TRUE)
        }
        
        # Extract MWS study skills score (items 26-29)
        if (length(responses) >= 29) {
            mws_resp <- as.numeric(responses[26:29])
            scores$study_skills <- mean(mws_resp, na.rm = TRUE)
        }
        
        # Extract Statistics self-efficacy score (items 30-31)
        if (length(responses) >= 31) {
            stats_resp <- as.numeric(responses[30:31])
            scores$statistics <- mean(stats_resp, na.rm = TRUE)
        }
        
        return(scores)
    }
    
    # Calculate all scores
    scores <- calculate_scores(responses, item_bank)
    
    # Generate interpretation
    get_level <- function(score) {
        if (is.na(score)) return("Nicht berechnet")
        if (score >= 4) return("Hoch")
        if (score >= 3) return("Mittel")
        return("Niedrig")
    }
    
    # Create HTML content
    html_content <- paste0(
        '<div class="hildesheim-results" style="padding: 20px; font-family: Arial, sans-serif;">',
        '<h2 style="color: #003366; text-align: center;">Hildesheim Psychologie Studie 2025 - Ihre Ergebnisse</h2>',
        
        # Big Five Profile
        '<div style="background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 10px;">',
        '<h3 style="color: #003366;">Big Five Persönlichkeitsprofil</h3>',
        '<table style="width: 100%; border-collapse: collapse;">',
        '<tr style="background: #e0e0e0;">',
        '<th style="padding: 10px; text-align: left;">Dimension</th>',
        '<th style="padding: 10px; text-align: center;">Score</th>',
        '<th style="padding: 10px; text-align: center;">Ausprägung</th>',
        '<th style="padding: 10px; text-align: left;">Bedeutung</th>',
        '</tr>',
        
        '<tr>',
        '<td style="padding: 10px;"><strong>Extraversion</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$extraversion, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$extraversion), '</td>',
        '<td style="padding: 10px;">Geselligkeit, Energie, positive Emotionen</td>',
        '</tr>',
        
        '<tr style="background: #f9f9f9;">',
        '<td style="padding: 10px;"><strong>Verträglichkeit</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$agreeableness, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$agreeableness), '</td>',
        '<td style="padding: 10px;">Vertrauen, Kooperativität, Mitgefühl</td>',
        '</tr>',
        
        '<tr>',
        '<td style="padding: 10px;"><strong>Gewissenhaftigkeit</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$conscientiousness, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$conscientiousness), '</td>',
        '<td style="padding: 10px;">Ordnung, Pflichtbewusstsein, Selbstdisziplin</td>',
        '</tr>',
        
        '<tr style="background: #f9f9f9;">',
        '<td style="padding: 10px;"><strong>Neurotizismus</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$neuroticism, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$neuroticism), '</td>',
        '<td style="padding: 10px;">Emotionale Instabilität, Ängstlichkeit</td>',
        '</tr>',
        
        '<tr>',
        '<td style="padding: 10px;"><strong>Offenheit</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$openness, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$openness), '</td>',
        '<td style="padding: 10px;">Kreativität, Neugier, Aufgeschlossenheit</td>',
        '</tr>',
        '</table>',
        '</div>',
        
        # Other Measures
        '<div style="background: #f5f5f5; padding: 20px; margin: 20px 0; border-radius: 10px;">',
        '<h3 style="color: #003366;">Weitere Messwerte</h3>',
        '<table style="width: 100%; border-collapse: collapse;">',
        '<tr style="background: #e0e0e0;">',
        '<th style="padding: 10px; text-align: left;">Bereich</th>',
        '<th style="padding: 10px; text-align: center;">Score</th>',
        '<th style="padding: 10px; text-align: center;">Ausprägung</th>',
        '</tr>',
        
        '<tr>',
        '<td style="padding: 10px;"><strong>Stresslevel (PSQ)</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$stress, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$stress), '</td>',
        '</tr>',
        
        '<tr style="background: #f9f9f9;">',
        '<td style="padding: 10px;"><strong>Studierfähigkeiten (MWS)</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$study_skills, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$study_skills), '</td>',
        '</tr>',
        
        '<tr>',
        '<td style="padding: 10px;"><strong>Statistik-Selbstwirksamkeit</strong></td>',
        '<td style="padding: 10px; text-align: center;">', round(scores$statistics, 2), '</td>',
        '<td style="padding: 10px; text-align: center;">', get_level(scores$statistics), '</td>',
        '</tr>',
        '</table>',
        '</div>',
        
        # Recommendations
        '<div style="background: #e8f4fd; padding: 20px; margin: 20px 0; border-radius: 10px; border-left: 4px solid #0066cc;">',
        '<h3 style="color: #0066cc;">Empfehlungen basierend auf Ihren Ergebnissen</h3>',
        '<ul style="line-height: 1.8;">',
        if(scores$stress > 3.5) '<li>Ihr Stresslevel ist erhöht. Erwägen Sie Zeitmanagement-Strategien und Entspannungstechniken.</li>' else '',
        if(scores$study_skills < 3) '<li>Ihre Studierfähigkeiten könnten verbessert werden. Nutzen Sie Lerngruppen und Unterstützungsangebote.</li>' else '',
        if(scores$statistics < 3) '<li>Bei Statistik könnten Sie von zusätzlicher Unterstützung profitieren. Nutzen Sie Tutorien und Übungsgruppen.</li>' else '',
        if(scores$conscientiousness < 3) '<li>Arbeiten Sie an Ihrer Selbstorganisation. Erstellen Sie Lernpläne und setzen Sie sich klare Ziele.</li>' else '',
        if(scores$neuroticism > 3.5) '<li>Achten Sie auf Ihre emotionale Balance. Bei Bedarf nutzen Sie die psychologische Beratung der Universität.</li>' else '',
        if(all(scores$stress <= 3.5, scores$study_skills >= 3, scores$statistics >= 3)) '<li>Ihre Werte zeigen eine gute Ausgangslage für Ihr Studium. Behalten Sie Ihre Strategien bei!</li>' else '',
        '</ul>',
        '</div>',
        
        '<div style="text-align: center; margin-top: 30px; color: #666;">',
        '<p>Vielen Dank für Ihre Teilnahme an der Hildesheim Psychologie Studie 2025!</p>',
        '<p style="font-size: 0.9em;">Diese Ergebnisse dienen zu Forschungszwecken und ersetzen keine professionelle psychologische Beratung.</p>',
        '</div>',
        '</div>'
    )
    
    return(shiny::HTML(html_content))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================
session_uuid <- paste0("hildesheim_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
    name = "Hildesheim Psychologie Studie 2025",
    study_key = session_uuid,
    theme = "hildesheim",
    
    # Demographics - exact order as specified
    demographics = c("Einverständnis", "Alter_VPN", "Studiengang", "Geschlecht", 
                    "Wohnstatus", "Wohn_Zusatz", "Haustier", "Haustier_Zusatz", 
                    "Rauchen", "Ernährung", "Ernährung_Zusatz", "Note_Englisch", 
                    "Note_Mathe", "Vor_Nachbereitung", "Zufrieden_Hi_5st", 
                    "Zufrieden_Hi_7st", "Persönlicher_Code"),
    
    # Input types for demographics
    input_types = list(
        Einverständnis = "radio",
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
    
    # Study parameters
    model = "GRM",
    adaptive = FALSE,
    max_items = nrow(all_items),
    min_items = nrow(all_items),
    
    # UI configuration
    response_ui_type = "radio",
    progress_style = "bar",
    
    # Session management
    session_save = TRUE,
    session_timeout = 30,
    
    # Demographic configurations
    demographic_configs = demographic_configs,
    
    # Instructions
    instructions = list(
        welcome = "Willkommen zur Hildesheim Psychologie Studie 2025",
        
        purpose = paste0(
            "Liebe Studierende,\n\n",
            "In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
            "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.\n\n",
            "Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
            "Themenbereiche ab, die voneinander teilweise unabhängig sind."
        ),
        
        duration = "Die Studie dauert etwa 15-20 Minuten.",
        
        confidentiality = paste0(
            "Ihre Angaben sind dabei selbstverständlich anonym, es wird keine personenbezogene ",
            "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie ",
            "im Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen."
        ),
        
        consent_text = paste0(
            "Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
            "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
            "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht."
        ),
        
        contact = "Bei Fragen wenden Sie sich bitte an das Forschungsteam der Universität Hildesheim."
    ),
    
    # Results processor - returns HTML content for display in Shiny
    results_processor = create_hildesheim_results
)

# =============================================================================
# LAUNCH STUDY
# =============================================================================
cat("=============================================================================\n")
cat("HILDESHEIM PSYCHOLOGIE STUDIE 2025 - LAUNCHING\n")
cat("=============================================================================\n")
cat("Study Name:", study_config$name, "\n")
cat("Study Key:", study_config$study_key, "\n")
cat("Theme:", study_config$theme, "\n")
cat("Total Items:", nrow(all_items), "\n")
cat("Demographics:", length(study_config$demographics), "\n")
cat("Model:", study_config$model, "\n")
cat("Adaptive:", study_config$adaptive, "\n")
cat("\nQuestionnaire Structure:\n")
cat("1. BFI-2 Items:", nrow(bfi_df), "items\n")
cat("2. PSQ Items:", nrow(psq_df), "items\n")
cat("3. MWS Items:", nrow(mws_df), "items\n")
cat("4. Statistics Items:", nrow(statistics_df), "items\n")
cat("\nResults: HTML display with scores and recommendations\n")
cat("=============================================================================\n")

# Launch the study
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
    study_key = session_uuid
)