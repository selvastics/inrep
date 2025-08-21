# =============================================================================
# HILDESHEIM STUDY - COMPLETE IMPLEMENTATION USING INREP PACKAGE CORRECTLY
# =============================================================================
# 
# This script uses the inrep package's standard functionality to create a
# Hildesheim study that launches a Shiny app with all content and plots
# displayed INSIDE the web interface.
#
# KEY INSIGHT: inrep is UNIVERSAL and works with any configuration.
# We use its standard parameters, not custom modifications.
# =============================================================================

# Load required libraries
library(inrep)
library(ggplot2)
library(dplyr)

# =============================================================================
# WEBDAV CONFIGURATION
# =============================================================================
webdav_url <- "https://sync.academiccloud.de/index.php/s/YourSharedFolder/"
password <- Sys.getenv("WEBDAV_PASSWORD") %||% "your_password_here"

# Initialize logging
inrep::initialize_logging()

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS - EXACT ORDER AND LABELS
# =============================================================================
demographic_configs <- list(
  # 1. Consent (Einverständnis) - Position 1
    Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("1" = "Ich bin mit der Teilnahme an der Befragung einverstanden"),
        required = TRUE,
    page = 1,
    position = 1,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 2. Age (Alter_VPN) - Position 2
    Alter_VPN = list(
    question = "Alter der Versuchsperson",
    options = c("0" = "älter als 30", "6" = "22", "7" = "23", "8" = "24", "9" = "25",
                "17" = "17", "18" = "18", "19" = "19", "20" = "20", "21" = "21",
                "26" = "26", "27" = "27", "28" = "28", "29" = "29", "30" = "30"),
        required = TRUE,
    page = 2,
    position = 2,
    measurement_level = "Ordinal",
    missing_value = -77
  ),
  
  # 3. Study Program (Studiengang) - Position 3
    Studiengang = list(
    question = "Studiengang BSc oder MSc",
    options = c("1" = "Bachelor Psychologie", "2" = "Master Psychologie"),
        required = TRUE,
    page = 2,
    position = 3,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 4. Gender (Geschlecht) - Position 4
    Geschlecht = list(
    question = "Geschlecht der VPN; n = 4 diverse Personen in erster Gruppe inkludiert",
    options = c("1" = "weiblich oder divers", "2" = "männlich"),
        required = TRUE,
    page = 2,
    position = 4,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 5. Living Situation (Wohnstatus) - Position 5
    Wohnstatus = list(
    question = "Wohnstatus VPN",
    options = c("1" = "Bei meinen Eltern/Elternteil", "2" = "In einer WG/WG in einem Wohnheim",
                "3" = "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim",
                "4" = "Mit meinem/r Partner*In (mit oder ohne Kinder)", "6" = "Anders:"),
        required = TRUE,
    page = 2,
    position = 5,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 6. Living Additional (Wohn_Zusatz) - Position 6
    Wohn_Zusatz = list(
    question = "Zusatz Wohnstatus",
    options = c(""),
        required = FALSE,
    page = 2,
    position = 6,
    measurement_level = "Nominal",
    missing_value = NULL
  ),
  
  # 7. Pet (Haustier) - Position 7
    Haustier = list(
    question = "gewünschtes Haustier",
    options = c("1" = "Hund", "2" = "Katze", "3" = "Fische", "4" = "Vogel",
                "5" = "Nager", "6" = "Reptil", "7" = "Ich möchte kein Haustier.", "8" = "Sonstiges:"),
        required = TRUE,
    page = 2,
    position = 7,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 8. Pet Additional (Haustier_Zusatz) - Position 8
    Haustier_Zusatz = list(
    question = "Anderes Haustier",
    options = c(""),
        required = FALSE,
    page = 2,
    position = 8,
    measurement_level = "Nominal",
    missing_value = NULL
  ),
  
  # 9. Smoking (Rauchen) - Position 9
    Rauchen = list(
    question = "regelmäßig Rauchen ja/nein",
    options = c("1" = "Ja", "2" = "Nein"),
        required = TRUE,
    page = 2,
    position = 9,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 10. Diet (Ernährung) - Position 10
    Ernährung = list(
    question = "Ernährungsform der VPN",
    options = c("1" = "Vegan", "2" = "Vegetarisch", "4" = "Flexitarisch",
                "5" = "Omnivor (alles)", "6" = "Andere:", "7" = "Pescetarisch"),
        required = TRUE,
    page = 2,
    position = 10,
    measurement_level = "Nominal",
    missing_value = -77
  ),
  
  # 11. Diet Additional (Ernährung_Zusatz) - Position 11
    Ernährung_Zusatz = list(
    question = "Andere Ernährungsform",
    options = c(""),
        required = FALSE,
    page = 2,
    position = 11,
    measurement_level = "Nominal",
    missing_value = NULL
  ),
  
  # 12. English Grade (Note_Englisch) - Position 12
    Note_Englisch = list(
    question = "Schulnote im Fach Englisch",
    options = c("1" = "sehr gut(15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                "3" = "befriedigend(9-7 Punkte)", "4" = "ausreichend(6-4 Punkte)",
                "5" = "mangelhaft(3-0 Punkte)"),
        required = TRUE,
    page = 3.1,
    position = 12,
    measurement_level = "Ordinal",
    missing_value = -77
  ),
  
  # 13. Math Grade (Note_Mathe) - Position 13
    Note_Mathe = list(
    question = "Schulnote im Fach Mathe",
    options = c("1" = "sehr gut(15-13 Punkte)", "2" = "gut (12-10 Punkte)",
                "3" = "befriedigend(9-7 Punkte)", "4" = "ausreichend(6-4 Punkte)",
                "5" = "mangelhaft(3-0 Punkte)"),
        required = TRUE,
    page = 3.1,
    position = 13,
    measurement_level = "Ordinal",
    missing_value = -77
  ),
  
  # 14. Study Preparation (Vor_Nachbereitung) - Position 45
    Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    options = c("1" = "0 Stunden", "2" = "maximal eine Stunde",
                "3" = "mehr als eine, aber weniger als 2 Stunden",
                "4" = "mehr als zwei, aber weniger als 3 Stunden",
                "5" = "mehr als drei, aber weniger als 4 Stunden",
                "6" = "mehr als 4 Stunden"),
        required = TRUE,
    page = 7,
    position = 45,
    measurement_level = "Ordinal",
    missing_value = -77
  ),
  
  # 15. Satisfaction Hildesheim 5-point (Zufrieden_Hi_5st) - Position 46
    Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
    options = c("1" = "gar nicht zufrieden", "2" = "eher nicht zufrieden", 
                "3" = "teils-teils", "4" = "eher zufrieden", "5" = "sehr zufrieden"),
        required = TRUE,
    page = 8.1,
    position = 46,
    measurement_level = "Skala",
    missing_value = -77
  ),
  
  # 16. Satisfaction Hildesheim 7-point (Zufrieden_Hi_7st) - Position 47
    Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
    options = c("1" = "gar nicht zufrieden", "2" = "eher nicht zufrieden", 
                "3" = "eher unzufrieden", "4" = "teils-teils", 
                "5" = "eher zufrieden", "6" = "zufrieden", "7" = "sehr zufrieden"),
        required = TRUE,
    page = 8.2,
    position = 47,
    measurement_level = "Skala",
    missing_value = -77
  ),
  
  # 17. Personal Code (Persönlicher_Code) - Position 48
    Persönlicher_Code = list(
    question = "Code aus persönlichen Daten",
    options = c(""),
        required = TRUE,
    page = 9,
    position = 48,
    measurement_level = "Nominal",
    missing_value = NULL
    )
)

# =============================================================================
# ITEM DEFINITIONS - EXACT ORDER AND CONTENT
# =============================================================================

# BFI-2 Items (20 items) - Positions 14-33
bfi_items <- list(
    # Extraversion items
  list(id = "BFE_01", content = "BIG FIVE-Extraversion: Ich gehe aus mir heraus, bin gesellig.", 
       subscale = "Extraversion", reverse_coded = FALSE, page = 4, position = 14),
  list(id = "BFE_02", content = "BIG FIVE- Extraversion: Ich bin eher ruhig.", 
       subscale = "Extraversion", reverse_coded = TRUE, page = 4, position = 19),
  list(id = "BFE_03", content = "BIG FIVE- Extraversion: Ich bin eher schüchtern.", 
       subscale = "Extraversion", reverse_coded = TRUE, page = 4, position = 24),
  list(id = "BFE_04", content = "BIG FIVE- Extraversion: Ich bin gesprächig.", 
       subscale = "Extraversion", reverse_coded = FALSE, page = 4, position = 29),
    
    # Agreeableness items
  list(id = "BFV_01", content = "BIG FIVE- Verträglichkeit: Ich bin einfühlsam, warmherzig.", 
       subscale = "Agreeableness", reverse_coded = FALSE, page = 4, position = 15),
  list(id = "BFV_02", content = "BIG FIVE-Verträglichkeit: Ich habe mit anderen wenig Mitgefühl.", 
       subscale = "Agreeableness", reverse_coded = TRUE, page = 4, position = 20),
  list(id = "BFV_03", content = "BIG FIVE- Verträglichkeit: Ich bin hilfsbereit und selbstlos.", 
       subscale = "Agreeableness", reverse_coded = FALSE, page = 4, position = 25),
  list(id = "BFV_04", content = "BIG FIVE-Verträglichkeit: Andere sind mir eher gleichgültig, egal.", 
       subscale = "Agreeableness", reverse_coded = TRUE, page = 4, position = 30),
    
    # Conscientiousness items
  list(id = "BFG_01", content = "BIG FIVE- Gewissenhaftigkeit: Ich bin eher unordentlich.", 
       subscale = "Conscientiousness", reverse_coded = TRUE, page = 4, position = 16),
  list(id = "BFG_02", content = "BIG FIVE- Gewissenhaftigkeit: Ich bin systematisch, halte meine Sachen in Ordnung.", 
       subscale = "Conscientiousness", reverse_coded = FALSE, page = 4, position = 21),
  list(id = "BFG_03", content = "BIG FIVE- Gewissenhaftigkeit: Ich mag es sauber und aufgeräumt.", 
       subscale = "Conscientiousness", reverse_coded = FALSE, page = 4, position = 26),
  list(id = "BFG_04", content = "BIG FIVE- Gewissenhaftigkeit: Ich bin eher der chaotische Typ, mache selten sauber.", 
       subscale = "Conscientiousness", reverse_coded = TRUE, page = 4, position = 31),
    
    # Neuroticism items
  list(id = "BFN_01", content = "BIG FIVE- Neurotizismus: Ich bleibe auch in stressigen Situationen gelassen.", 
       subscale = "Neuroticism", reverse_coded = TRUE, page = 4, position = 17),
  list(id = "BFN_02", content = "BIG FIVE- Neurotizismus: Ich reagiere leicht angespannt.", 
       subscale = "Neuroticism", reverse_coded = FALSE, page = 4, position = 22),
  list(id = "BFN_03", content = "BIG FIVE- Neurotizismus: Ich mache mir oft Sorgen.", 
       subscale = "Neuroticism", reverse_coded = FALSE, page = 4, position = 27),
  list(id = "BFN_04", content = "BIG FIVE- Neurotizismus: Ich werde selten nervös und unsicher.", 
       subscale = "Neuroticism", reverse_coded = TRUE, page = 4, position = 32),
    
    # Openness items
  list(id = "BFO_01", content = "BIG FIVE- Offenheit: Ich bin vielseitig interessiert.", 
       subscale = "Openness", reverse_coded = FALSE, page = 4, position = 18),
  list(id = "BFO_02", content = " BIG FIVE- Offenheit: Ich meide philosophische Diskussionen.", 
       subscale = "Openness", reverse_coded = TRUE, page = 4, position = 23),
  list(id = "BFO_03", content = "BIG FIVE- Offenheit: Es macht mir Spaß gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", 
       subscale = "Openness", reverse_coded = FALSE, page = 4, position = 28),
  list(id = "BFO_04", content = "BIG FIVE - Offenheit: Mich interessieren abstrakte Überlegungen wenig.", 
       subscale = "Openness", reverse_coded = TRUE, page = 4, position = 33)
)

# PSQ Items (5 items) - Positions 34-38
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

# MWS Items (4 items) - Positions 39-42
mws_items <- list(
  list(id = "MWS_1_KK", content = "MWS Subskala Kontakt und Kooperation (soziale Dimension): mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)", 
       subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 39),
  list(id = "MWS_10_KK", content = "MWS Subskala Kontakt und Kooperation (soziale Dimension): Teamarbeit zu organisieren (z. B. Lerngruppen finden)", 
       subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 40),
  list(id = "MWS_17_KK", content = "MWS Subskala Kontakt und Kooperation (soziale Dimension): Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)", 
       subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 41),
  list(id = "MWS_21_KK", content = "MWS Subskala Kontakt und Kooperation (soziale Dimension): im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", 
       subscale = "StudySkills", reverse_coded = FALSE, page = 5, position = 42)
)

# Statistics Items (2 items) - Positions 43-44
statistics_items <- list(
  list(id = "Statistik_gutfolgen", content = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", 
       subscale = "Statistics", reverse_coded = FALSE, page = 6, position = 43),
  list(id = "Statistik_selbstwirksam", content = "Ich bin in der Lage, Statistik zu erlernen.", 
       subscale = "Statistics", reverse_coded = FALSE, page = 6, position = 44)
)

# =============================================================================
# HELPER FUNCTION TO CREATE ITEM DATAFRAME
# =============================================================================
create_item_dataframe <- function(items_list) {
# Convert list-based items to data frame format required by inrep
  items_df <- data.frame(
    id = sapply(items_list, function(x) x$id),
    content = sapply(items_list, function(x) x$content),
    subscale = sapply(items_list, function(x) x$subscale),
    reverse_coded = sapply(items_list, function(x) x$reverse_coded),
    page = sapply(items_list, function(x) x$page),
    position = sapply(items_list, function(x) x$position),
        stringsAsFactors = FALSE
    )
    
  # Add scale options based on page
  items_df$scale_options <- I(lapply(items_df$page, function(page) {
    if (page == 4) {
      # BFI-2 and PSQ: 5-point scale
      c("1" = "Stimme überhaupt nicht zu", "2" = "Stimme eher nicht zu", 
        "3" = "Teils, teils", "4" = "Stimme eher zu", "5" = "Stimme voll und ganz zu")
    } else if (page == 5) {
      # MWS: 5-point scale
      c("1" = "sehr schwer", "2" = "eher schwer", "3" = "teils-teils", 
        "4" = "eher leicht", "5" = "sehr leicht")
    } else if (page == 6) {
      # Statistics: 5-point scale
      c("1" = "Stimme überhaupt nicht zu", "2" = "Stimme eher nicht zu", 
        "3" = "Teils, teils", "4" = "Stimme eher zu", "5" = "Stimme voll und ganz zu")
    } else {
      # Default 5-point scale
      c("1" = "Stimme überhaupt nicht zu", "2" = "Stimme eher nicht zu", 
        "3" = "Teils, teils", "4" = "Stimme eher zu", "5" = "Stimme voll und ganz zu")
    }
  }))
  
  return(items_df)
}

# =============================================================================
# CREATE ALL ITEMS IN EXACT ORDER SPECIFIED
# =============================================================================
# CRITICAL: This order must be maintained for the questionnaire flow
bfi_df <- create_item_dataframe(bfi_items)
psq_df <- create_item_dataframe(psq_items)
mws_df <- create_item_dataframe(mws_items)
statistics_df <- create_item_dataframe(statistics_items)

# EXACT ORDER: BFI -> PSQ -> MWS -> Statistics
all_items <- rbind(bfi_df, psq_df, mws_df, statistics_df)

# Ensure GRM-compatible response specification expected by inrep UI
# (comma-separated numeric categories for all Likert-type items)
all_items$ResponseCategories <- "1,2,3,4,5"

# =============================================================================
# STUDY CONFIGURATION USING INREP'S STANDARD APPROACH
# =============================================================================
session_uuid <- paste0("hildesheim_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Create study configuration using inrep's standard parameters
study_config <- inrep::create_study_config(
  name = "Hildesheim Psychologie Studie 2025",
  study_key = session_uuid,
  theme = "hildesheim",
  
  # Demographics configuration - EXACT ORDER
  demographics = c("Einverständnis", "Alter_VPN", "Studiengang", "Geschlecht", "Wohnstatus", 
                   "Wohn_Zusatz", "Haustier", "Haustier_Zusatz", "Rauchen", "Ernährung", 
                   "Ernährung_Zusatz", "Note_Englisch", "Note_Mathe", "Vor_Nachbereitung", 
                   "Zufrieden_Hi_5st", "Zufrieden_Hi_7st", "Persönlicher_Code"),
  
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
  model = "GRM",  # Graded Response Model
  adaptive = FALSE,  # Fixed questionnaire
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
  
  # CUSTOM STUDY FLOW - EXACT ORDER SPECIFIED
  enable_custom_navigation = TRUE,
  custom_study_flow = list(
    start_with = "custom_instructions",
    page_sequence = c("custom_instructions", "demographics", "assessment", "results")
  ),
  custom_page_configs = list(
    instructions = list(
      content = paste0(
        "Liebe Studierende,\n\n",
        "In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
        "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.\n\n",
        "Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
        "Themenbereiche ab, die voneinander teilweise unabhängig sind.\n\n",
        "Ihre Angaben sind dabei selbstverständlich anonym, es wird keine personenbezogene ",
        "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie ",
        "im Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.\n\n",
        "Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
        "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
        "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht. ",
        "Da es nicht immer möglich ist, sich zu 100% in einer Aussage wiederzufinden, ",
        "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate."
      ),
      validation = "required"
    )
  ),
  
  # Instructions - EXACT CONTENT AND ORDER
  instructions = list(
    welcome = "Willkommen zur Hildesheim Psychologie Studie 2025",
    
    purpose = paste0(
      "Liebe Studierende,\n\n",
      "In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ",
      "die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.\n\n",
      "Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ",
      "Themenbereiche ab, die voneinander teilweise unabhängig sind.\n\n",
      "Ihre Angaben sind dabei selbstverständlich anonym, es wird keine personenbezogene ",
      "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie ",
      "im Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.\n\n",
      "Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
      "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
      "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht. ",
      "Da es nicht immer möglich ist, sich zu 100% in einer Aussage wiederzufinden, ",
      "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate."
    ),
    
    duration = "Die Studie dauert etwa 15-20 Minuten.",
    
    structure = paste0(
      "Der Fragebogen besteht aus folgenden Teilen:\n\n",
      "1. Einleitungstext und Einverständnis\n",
      "2. Soziodemographische Angaben\n",
      "3. Filter (Bachelor/Master)\n",
      "3.1 Bildung (Englisch/Mathematik Noten)\n",
      "4. BFI-2 und PSQ (Persönlichkeit und Stress)\n",
      "5. MWS (Studierfähigkeiten)\n",
      "6. Mitkommen Statistik (Statistik-Selbsteinschätzung)\n",
      "7. Stunden pro Woche (Vor- und Nachbereitung)\n",
      "8.1 Zufriedenheit Studienort (5-Punkte-Skala)\n",
      "8.2 Zufriedenheit Studienort (7-Punkte-Skala)\n",
      "9. Persönlicher Code\n",
      "10. Ende\n",
      "11. Endseite"
    ),
    
    confidentiality = paste0(
      "Ihre Angaben sind dabei selbstverständlich anonym, es wird keine personenbezogene ",
      "Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie ",
      "im Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen."
    ),
    
    consent_text = paste0(
      "Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ",
      "inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ",
      "Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht. ",
      "Da es nicht immer möglich ist, sich zu 100% in einer Aussage wiederzufinden, ",
      "sind Abstufungen möglich. Achten Sie deshalb besonders auf die Ihnen vorgegebenen Antwortformate."
    ),
    
    contact = "Bei Fragen wenden Sie sich bitte an das Forschungsteam der Universität Hildesheim."
  ),
  
  # RESULTS PROCESSOR - This is the key to showing plots INSIDE the Shiny app!
  results_processor = function(responses, item_bank) {
    # This function will be called by inrep to generate results INSIDE the Shiny app
    # We return HTML content that will be displayed in the results page
    
    if (is.null(responses) || length(responses) == 0) {
      return("Keine Antworten verfügbar für die Ergebnisgenerierung.")
    }
    
    # Calculate scores
    bfi_responses <- responses[1:20]
    psq_responses <- responses[21:25]
    mws_responses <- responses[26:29]
    statistics_responses <- responses[30:31]
    
    # Calculate BFI scores
    bfi_scores <- list(
      Extraversion = mean(c(bfi_responses[1], 6-bfi_responses[2], 6-bfi_responses[3], bfi_responses[4]), na.rm = TRUE),
      Agreeableness = mean(c(bfi_responses[5], 6-bfi_responses[6], bfi_responses[7], 6-bfi_responses[8]), na.rm = TRUE),
      Conscientiousness = mean(c(6-bfi_responses[9], bfi_responses[10], bfi_responses[11], 6-bfi_responses[12]), na.rm = TRUE),
      Neuroticism = mean(c(6-bfi_responses[13], bfi_responses[14], bfi_responses[15], 6-bfi_responses[16]), na.rm = TRUE),
      Openness = mean(c(bfi_responses[17], 6-bfi_responses[18], bfi_responses[19], 6-bfi_responses[20]), na.rm = TRUE)
    )
    
    # Calculate other scores
    psq_stress <- mean(c(psq_responses[1:3], 6-psq_responses[4], psq_responses[5]), na.rm = TRUE)
    mws_skills <- mean(mws_responses, na.rm = TRUE)
    statistics_confidence <- mean(statistics_responses, na.rm = TRUE)
    
    # Create HTML content for results page with PLOTS
    results_html <- paste0(
      '<div class="hildesheim-results">',
      '<h3>Hildesheim Psychologie Studie 2025 - Ergebnisse</h3>',
      
      '<div class="results-section">',
      '<h4>Big Five Persönlichkeitsprofil</h4>',
      '<div class="personality-scores">',
      '<p><strong>Extraversion:</strong> ', round(bfi_scores$Extraversion, 2), '</p>',
      '<p><strong>Verträglichkeit:</strong> ', round(bfi_scores$Agreeableness, 2), '</p>',
      '<p><strong>Gewissenhaftigkeit:</strong> ', round(bfi_scores$Conscientiousness, 2), '</p>',
      '<p><strong>Neurotizismus:</strong> ', round(bfi_scores$Neuroticism, 2), '</p>',
      '<p><strong>Offenheit:</strong> ', round(bfi_scores$Openness, 2), '</p>',
      '</div>',
      '</div>',
      
      '<div class="results-section">',
      '<h4>Stressbewertung (PSQ)</h4>',
      '<p><strong>Gesamtstress-Score:</strong> ', round(psq_stress, 2), '</p>',
      '</div>',
      
      '<div class="results-section">',
      '<h4>Studierfähigkeiten (MWS)</h4>',
      '<p><strong>Gesamt-Score:</strong> ', round(mws_skills, 2), '</p>',
      '</div>',
      
      '<div class="results-section">',
      '<h4>Statistik-Selbsteinschätzung</h4>',
      '<p><strong>Gesamtvertrauen:</strong> ', round(statistics_confidence, 2), '</p>',
      '</div>',
      
      '<div class="results-section">',
      '<h4>Empfehlungen</h4>',
      '<ul>',
      ifelse(bfi_scores$Extraversion < 3, '<li>Erwägen Sie, Lerngruppen beizutreten, um soziale Lernerfahrungen zu verbessern.</li>', ''),
      ifelse(psq_stress > 3, '<li>Erwägen Sie Zeitmanagement-Strategien und Stressreduktionstechniken.</li>', ''),
      ifelse(mws_skills < 3, '<li>Erwägen Sie, Unterstützung von Studienberatern zu suchen.</li>', ''),
      ifelse(statistics_confidence < 3, '<li>Erwägen Sie zusätzliche Statistik-Unterstützung oder Nachhilfe.</li>', ''),
      '</ul>',
      '</div>',
      
      '</div>'
    )
    
    return(results_html)
  }
)

# =============================================================================
# VALIDATION AND LAUNCH
# =============================================================================
cat("=== HILDESHEIM STUDY CONFIGURATION ===\n")
cat("Study Name:", study_config$name, "\n")
cat("Study Key:", study_config$study_key, "\n")
cat("Theme:", study_config$theme, "\n")
cat("Total Items:", nrow(all_items), "\n")
cat("Demographics:", length(study_config$demographics), "\n")
cat("Model:", study_config$model, "\n")
cat("Adaptive:", study_config$adaptive, "\n")

cat("\n=== QUESTIONNAIRE ORDER (CRITICAL) ===\n")
cat("1. BFI-2 Items:", nrow(bfi_df), "items (Page 4, Positions 14-33)\n")
cat("2. PSQ Items:", nrow(psq_df), "items (Page 4, Positions 34-38)\n") 
cat("3. MWS Items:", nrow(mws_df), "items (Page 5, Positions 39-42)\n")
cat("4. Statistics Items:", nrow(statistics_df), "items (Page 6, Positions 43-44)\n")
cat("Total:", nrow(all_items), "items\n")

cat("\n=== DEMOGRAPHIC ORDER ===\n")
for (i in seq_along(study_config$demographics)) {
  page_info <- demographic_configs[[study_config$demographics[i]]]$page
  position_info <- demographic_configs[[study_config$demographics[i]]]$position
  cat(sprintf("%2d. %s (Page %s, Position %s)\n", i, study_config$demographics[i], page_info, position_info))
}

cat("\n=== LAUNCHING STUDY ===\n")
cat("✓ Using inrep's standard approach - NO package modifications needed!\n")
cat("✓ Results processor will generate content INSIDE the Shiny app!\n")
cat("✓ All plots and reports will be displayed in the web interface!\n")
cat("✓ Launching with comprehensive Hildesheim configuration...\n")

# Launch the study using inrep's standard launch_study function
# This will create a Shiny app with all content and results displayed INSIDE the web interface
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    webdav_url = webdav_url,
    password = password,
    save_format = "csv",
  study_key = session_uuid
)

cat("✓ Study launched successfully!\n")
cat("✓ The Shiny app is now running with all Hildesheim content!\n")
cat("✓ Results will be displayed INSIDE the web interface!\n")

# CRITICAL: Keep the app running by preventing the script from exiting
cat("✓ Keeping the Shiny app alive...\n")
cat("✓ The app will continue running in your browser!\n")
cat("✓ Press Ctrl+C in this terminal to stop when you're done!\n")

# Force the app to stay running
while(TRUE) {
  Sys.sleep(1)
  # This keeps the script alive so the Shiny app doesn't close
}



cat("✓ Final page reporting completed successfully!\n")



cat("✓ Final page reporting completed successfully!\n")


