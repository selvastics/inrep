# =============================================================================
# HILDESHEIM PSYCHOLOGY STUDY 2025 - COMPLETE TUTORIAL VERSION
# =============================================================================
# This script demonstrates how to create a complete psychological study using
# the inrep package. Every section is thoroughly documented to serve as a
# learning resource for creating your own studies.
#
# WHAT YOU'LL LEARN:
# 1. How to structure demographic questions
# 2. How to create psychological assessment items
# 3. How to configure non-adaptive testing
# 4. How to create custom results with visualizations
# 5. How to handle common errors and issues
#
# STUDY OVERVIEW:
# - Name: Hildesheim Psychology Study 2025
# - Target: Psychology students at University of Hildesheim
# - Measures: Big Five personality, stress (PSQ), study skills (MWS), statistics self-efficacy
# - Items: 31 items across 4 scales
# - Demographics: 17 variables
# - Output: Interactive report with plots and recommendations
# =============================================================================

# -----------------------------------------------------------------------------
# STEP 1: LOAD REQUIRED PACKAGES
# -----------------------------------------------------------------------------
# The inrep package provides the assessment framework
# Additional packages are needed for visualizations and data manipulation

library(inrep)      # Core assessment package
library(ggplot2)    # For creating plots
library(dplyr)      # For data manipulation
library(plotly)     # For interactive plots
library(DT)         # For data tables

# Initialize logging to track what happens during the study
# This helps debug issues and monitor participant progress
inrep::initialize_logging()

cat("✓ Packages loaded and logging initialized\n")

# -----------------------------------------------------------------------------
# STEP 2: CONFIGURE DATA STORAGE (OPTIONAL)
# -----------------------------------------------------------------------------
# WebDAV allows saving data to cloud storage
# Set both to NULL to save locally only

webdav_url <- NULL  # Replace with your WebDAV URL if using cloud storage
password <- NULL    # Replace with your password if using cloud storage

# Example for cloud storage (uncomment to use):
# webdav_url <- "https://sync.academiccloud.de/index.php/s/YourFolder/"
# password <- "your_secure_password"

cat("✓ Storage configuration set (local mode)\n")

# -----------------------------------------------------------------------------
# STEP 3: CREATE DEMOGRAPHIC CONFIGURATIONS
# -----------------------------------------------------------------------------
# Demographics are questions asked before the main assessment
# Each demographic needs:
# - question: The text shown to participants
# - options: Response choices (NULL for text input)
# - required: Whether the field must be completed

cat("\n📋 Setting up demographic questions...\n")

demographic_configs <- list(
  
  # CONSENT - Always should be first
  # This ensures participants agree to participate
  Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("1" = "Ich bin mit der Teilnahme an der Befragung einverstanden"),
    required = TRUE  # Must be checked to proceed
  ),
  
  # AGE - Using select dropdown with specific options
  # Note: Keys (like "0") can differ from display values
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c(
      "17" = "17",
      "18" = "18", 
      "19" = "19",
      "20" = "20",
      "21" = "21",
      "22" = "22",
      "23" = "23",
      "24" = "24",
      "25" = "25",
      "26" = "26",
      "27" = "27",
      "28" = "28",
      "29" = "29",
      "30" = "30",
      "0" = "älter als 30"  # Special code for 30+
    ),
    required = TRUE
  ),
  
  # STUDY PROGRAM - Radio buttons for two options
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c(
      "1" = "Bachelor Psychologie",
      "2" = "Master Psychologie"
    ),
    required = TRUE
  ),
  
  # GENDER - Including diverse option
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c(
      "1" = "weiblich",
      "2" = "männlich", 
      "3" = "divers"
    ),
    required = TRUE
  ),
  
  # LIVING SITUATION - Multiple options with "other"
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c(
      "1" = "Bei meinen Eltern/Elternteil",
      "2" = "In einer WG/WG in einem Wohnheim",
      "3" = "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim",
      "4" = "Mit meinem/r Partner*In (mit oder ohne Kinder)",
      "6" = "Anders:"  # Triggers additional text field
    ),
    required = TRUE
  ),
  
  # LIVING SITUATION ADDITIONAL - Text field for "other"
  # This appears only if "Anders:" is selected above
  Wohn_Zusatz = list(
    question = "Falls 'Anders', bitte spezifizieren:",
    options = NULL,  # NULL means text input field
    required = FALSE  # Optional field
  ),
  
  # PET PREFERENCE
  Haustier = list(
    question = "Welches Haustier würden Sie gerne halten?",
    options = c(
      "1" = "Hund",
      "2" = "Katze",
      "3" = "Fische",
      "4" = "Vogel",
      "5" = "Nager",
      "6" = "Reptil",
      "7" = "Ich möchte kein Haustier.",
      "8" = "Sonstiges:"
    ),
    required = TRUE
  ),
  
  # PET ADDITIONAL - Text field for "other"
  Haustier_Zusatz = list(
    question = "Falls 'Sonstiges', bitte spezifizieren:",
    options = NULL,
    required = FALSE
  ),
  
  # SMOKING - Simple yes/no
  Rauchen = list(
    question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
    options = c("1" = "Ja", "2" = "Nein"),
    required = TRUE
  ),
  
  # DIET TYPE
  Ernährung = list(
    question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
    options = c(
      "1" = "Vegan",
      "2" = "Vegetarisch",
      "7" = "Pescetarisch",  # Note: Non-sequential numbering is OK
      "4" = "Flexitarisch",
      "5" = "Omnivor (alles)",
      "6" = "Andere:"
    ),
    required = TRUE
  ),
  
  # DIET ADDITIONAL
  Ernährung_Zusatz = list(
    question = "Falls 'Andere', bitte spezifizieren:",
    options = NULL,
    required = FALSE
  ),
  
  # ENGLISH GRADE - Ordinal scale
  Note_Englisch = list(
    question = "Was war Ihre letzte Schulnote im Fach Englisch?",
    options = c(
      "1" = "sehr gut (15-13 Punkte)",
      "2" = "gut (12-10 Punkte)",
      "3" = "befriedigend (9-7 Punkte)",
      "4" = "ausreichend (6-4 Punkte)",
      "5" = "mangelhaft (3-0 Punkte)"
    ),
    required = TRUE
  ),
  
  # MATH GRADE - Same scale as English
  Note_Mathe = list(
    question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
    options = c(
      "1" = "sehr gut (15-13 Punkte)",
      "2" = "gut (12-10 Punkte)",
      "3" = "befriedigend (9-7 Punkte)",
      "4" = "ausreichend (6-4 Punkte)",
      "5" = "mangelhaft (3-0 Punkte)"
    ),
    required = TRUE
  ),
  
  # STUDY HOURS - Ordinal categories
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    options = c(
      "1" = "0 Stunden",
      "2" = "maximal eine Stunde",
      "3" = "mehr als eine, aber weniger als 2 Stunden",
      "4" = "mehr als zwei, aber weniger als 3 Stunden",
      "5" = "mehr als drei, aber weniger als 4 Stunden",
      "6" = "mehr als 4 Stunden"
    ),
    required = TRUE
  ),
  
  # SATISFACTION 5-POINT - First satisfaction measure
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
    options = c(
      "1" = "gar nicht zufrieden",
      "2" = "eher nicht zufrieden",
      "3" = "teils-teils",
      "4" = "eher zufrieden",
      "5" = "sehr zufrieden"
    ),
    required = TRUE
  ),
  
  # SATISFACTION 7-POINT - Second satisfaction measure (for comparison)
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
    options = c(
      "1" = "gar nicht zufrieden",
      "2" = "sehr unzufrieden",
      "3" = "unzufrieden",
      "4" = "teils-teils",
      "5" = "zufrieden",
      "6" = "sehr zufrieden",
      "7" = "extrem zufrieden"
    ),
    required = TRUE
  ),
  
  # PERSONAL CODE - For longitudinal tracking
  # Text field with specific instructions
  Persönlicher_Code = list(
    question = paste0(
      "Bitte erstellen Sie einen persönlichen Code für die Wiedererkennung:\n",
      "1. Erster Buchstabe Ihres Geburtsorts (z.B. B für Berlin)\n",
      "2. Erster Buchstabe des Rufnamens Ihrer Mutter (z.B. E für Eva)\n",
      "3. Tag Ihres Geburtsdatums (z.B. 07)\n",
      "4. Letzte zwei Ziffern Ihrer Matrikelnummer\n",
      "Beispiel: BE0751"
    ),
    options = NULL,  # Text input
    required = TRUE
  )
)

cat("✓ Created", length(demographic_configs), "demographic configurations\n")

# -----------------------------------------------------------------------------
# STEP 4: CREATE ASSESSMENT ITEMS
# -----------------------------------------------------------------------------
# Items are the actual questions participants answer
# We'll create items for 4 different scales

cat("\n📊 Creating assessment items...\n")

# Helper function to create item dataframes
# This converts our item lists into the format inrep expects
create_item_dataframe <- function(items_list) {
  items_df <- data.frame(
    # Required columns for inrep:
    id = sapply(items_list, function(x) x$id),              # Unique identifier
    Question = sapply(items_list, function(x) x$content),   # Item text
    subscale = sapply(items_list, function(x) x$subscale),  # Which scale it belongs to
    reverse_coded = sapply(items_list, function(x) x$reverse_coded),  # Scoring direction
    stringsAsFactors = FALSE
  )
  
  # Add response categories for GRM (Graded Response Model)
  # This tells inrep that items have 5 response options
  items_df$ResponseCategories <- "1,2,3,4,5"
  
  # Add difficulty parameter (will be estimated by TAM package)
  items_df$b <- 0
  
  return(items_df)
}

# BIG FIVE PERSONALITY ITEMS (BFI-2)
# 20 items measuring 5 personality dimensions
# Each dimension has 4 items, some reverse-coded
bfi_items <- list(
  # EXTRAVERSION - Sociability and energy
  list(id = "BFE_01", content = "Ich gehe aus mir heraus, bin gesellig.", 
       subscale = "Extraversion", reverse_coded = FALSE),
  list(id = "BFE_02", content = "Ich bin eher ruhig.", 
       subscale = "Extraversion", reverse_coded = TRUE),  # Reversed!
  list(id = "BFE_03", content = "Ich bin eher schüchtern.", 
       subscale = "Extraversion", reverse_coded = TRUE),  # Reversed!
  list(id = "BFE_04", content = "Ich bin gesprächig.", 
       subscale = "Extraversion", reverse_coded = FALSE),
  
  # AGREEABLENESS - Cooperation and trust
  list(id = "BFV_01", content = "Ich bin einfühlsam, warmherzig.", 
       subscale = "Agreeableness", reverse_coded = FALSE),
  list(id = "BFV_02", content = "Ich habe mit anderen wenig Mitgefühl.", 
       subscale = "Agreeableness", reverse_coded = TRUE),  # Reversed!
  list(id = "BFV_03", content = "Ich bin hilfsbereit und selbstlos.", 
       subscale = "Agreeableness", reverse_coded = FALSE),
  list(id = "BFV_04", content = "Andere sind mir eher gleichgültig, egal.", 
       subscale = "Agreeableness", reverse_coded = TRUE),  # Reversed!
  
  # CONSCIENTIOUSNESS - Organization and diligence
  list(id = "BFG_01", content = "Ich bin eher unordentlich.", 
       subscale = "Conscientiousness", reverse_coded = TRUE),  # Reversed!
  list(id = "BFG_02", content = "Ich bin systematisch, halte meine Sachen in Ordnung.", 
       subscale = "Conscientiousness", reverse_coded = FALSE),
  list(id = "BFG_03", content = "Ich mag es sauber und aufgeräumt.", 
       subscale = "Conscientiousness", reverse_coded = FALSE),
  list(id = "BFG_04", content = "Ich bin eher der chaotische Typ, mache selten sauber.", 
       subscale = "Conscientiousness", reverse_coded = TRUE),  # Reversed!
  
  # NEUROTICISM - Emotional instability
  list(id = "BFN_01", content = "Ich bleibe auch in stressigen Situationen gelassen.", 
       subscale = "Neuroticism", reverse_coded = TRUE),  # Reversed!
  list(id = "BFN_02", content = "Ich reagiere leicht angespannt.", 
       subscale = "Neuroticism", reverse_coded = FALSE),
  list(id = "BFN_03", content = "Ich mache mir oft Sorgen.", 
       subscale = "Neuroticism", reverse_coded = FALSE),
  list(id = "BFN_04", content = "Ich werde selten nervös und unsicher.", 
       subscale = "Neuroticism", reverse_coded = TRUE),  # Reversed!
  
  # OPENNESS - Creativity and curiosity
  list(id = "BFO_01", content = "Ich bin vielseitig interessiert.", 
       subscale = "Openness", reverse_coded = FALSE),
  list(id = "BFO_02", content = "Ich meide philosophische Diskussionen.", 
       subscale = "Openness", reverse_coded = TRUE),  # Reversed!
  list(id = "BFO_03", content = "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", 
       subscale = "Openness", reverse_coded = FALSE),
  list(id = "BFO_04", content = "Mich interessieren abstrakte Überlegungen wenig.", 
       subscale = "Openness", reverse_coded = TRUE)  # Reversed!
)

# PERCEIVED STRESS QUESTIONNAIRE (PSQ) ITEMS
# 5 items measuring subjective stress experience
psq_items <- list(
  list(id = "PSQ_02", content = "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "PSQ_04", content = "Ich habe zuviel zu tun.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "PSQ_16", content = "Ich fühle mich gehetzt.", 
       subscale = "Stress", reverse_coded = FALSE),
  list(id = "PSQ_29", content = "Ich habe genug Zeit für mich.", 
       subscale = "Stress", reverse_coded = TRUE),  # Reversed!
  list(id = "PSQ_30", content = "Ich fühle mich unter Termindruck.", 
       subscale = "Stress", reverse_coded = FALSE)
)

# STUDY SKILLS (MWS) ITEMS
# 4 items measuring social and organizational study skills
mws_items <- list(
  list(id = "MWS_1_KK", 
       content = "Mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)", 
       subscale = "StudySkills", reverse_coded = FALSE),
  list(id = "MWS_10_KK", 
       content = "Teamarbeit zu organisieren (z. B. Lerngruppen finden)", 
       subscale = "StudySkills", reverse_coded = FALSE),
  list(id = "MWS_17_KK", 
       content = "Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)", 
       subscale = "StudySkills", reverse_coded = FALSE),
  list(id = "MWS_21_KK", 
       content = "Im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", 
       subscale = "StudySkills", reverse_coded = FALSE)
)

# STATISTICS SELF-EFFICACY ITEMS
# 2 items measuring confidence in statistics learning
statistics_items <- list(
  list(id = "Statistik_gutfolgen", 
       content = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", 
       subscale = "Statistics", reverse_coded = FALSE),
  list(id = "Statistik_selbstwirksam", 
       content = "Ich bin in der Lage, Statistik zu erlernen.", 
       subscale = "Statistics", reverse_coded = FALSE)
)

# Convert all items to dataframes
bfi_df <- create_item_dataframe(bfi_items)
psq_df <- create_item_dataframe(psq_items)
mws_df <- create_item_dataframe(mws_items)
statistics_df <- create_item_dataframe(statistics_items)

# Combine all items in the EXACT order they should appear
# This order is important for the study flow
all_items <- rbind(bfi_df, psq_df, mws_df, statistics_df)

cat("✓ Created", nrow(all_items), "assessment items:\n")
cat("  - BFI-2:", nrow(bfi_df), "items\n")
cat("  - PSQ:", nrow(psq_df), "items\n")
cat("  - MWS:", nrow(mws_df), "items\n")
cat("  - Statistics:", nrow(statistics_df), "items\n")

# -----------------------------------------------------------------------------
# STEP 5: CREATE RESULTS PROCESSOR FUNCTION
# -----------------------------------------------------------------------------
# This function generates the report shown to participants after completion
# It calculates scores and creates visualizations

cat("\n📈 Setting up results processor...\n")

create_hildesheim_results <- function(responses, item_bank) {
  # This function is called by inrep when the assessment is complete
  # Parameters:
  #   responses: Vector of participant responses (numbers 1-5)
  #   item_bank: The items dataframe we created
  
  # Calculate scores for each scale
  calculate_scores <- function(responses, items_df) {
    scores <- list()
    
    # Extract BFI responses (first 20 items)
    if (length(responses) >= 20) {
      bfi_resp <- as.numeric(responses[1:20])
      
      # Calculate each Big Five dimension
      # Note: Reverse-coded items are subtracted from 6
      scores$extraversion <- mean(c(
        bfi_resp[1],           # BFE_01 (normal)
        6 - bfi_resp[2],       # BFE_02 (reversed)
        6 - bfi_resp[3],       # BFE_03 (reversed)
        bfi_resp[4]            # BFE_04 (normal)
      ), na.rm = TRUE)
      
      scores$agreeableness <- mean(c(
        bfi_resp[5],           # BFV_01 (normal)
        6 - bfi_resp[6],       # BFV_02 (reversed)
        bfi_resp[7],           # BFV_03 (normal)
        6 - bfi_resp[8]        # BFV_04 (reversed)
      ), na.rm = TRUE)
      
      scores$conscientiousness <- mean(c(
        6 - bfi_resp[9],       # BFG_01 (reversed)
        bfi_resp[10],          # BFG_02 (normal)
        bfi_resp[11],          # BFG_03 (normal)
        6 - bfi_resp[12]       # BFG_04 (reversed)
      ), na.rm = TRUE)
      
      scores$neuroticism <- mean(c(
        6 - bfi_resp[13],      # BFN_01 (reversed)
        bfi_resp[14],          # BFN_02 (normal)
        bfi_resp[15],          # BFN_03 (normal)
        6 - bfi_resp[16]       # BFN_04 (reversed)
      ), na.rm = TRUE)
      
      scores$openness <- mean(c(
        bfi_resp[17],          # BFO_01 (normal)
        6 - bfi_resp[18],      # BFO_02 (reversed)
        bfi_resp[19],          # BFO_03 (normal)
        6 - bfi_resp[20]       # BFO_04 (reversed)
      ), na.rm = TRUE)
    }
    
    # Extract PSQ stress score (items 21-25)
    if (length(responses) >= 25) {
      psq_resp <- as.numeric(responses[21:25])
      scores$stress <- mean(c(
        psq_resp[1],           # PSQ_02 (normal)
        psq_resp[2],           # PSQ_04 (normal)
        psq_resp[3],           # PSQ_16 (normal)
        6 - psq_resp[4],       # PSQ_29 (reversed)
        psq_resp[5]            # PSQ_30 (normal)
      ), na.rm = TRUE)
    }
    
    # Extract MWS study skills (items 26-29)
    if (length(responses) >= 29) {
      mws_resp <- as.numeric(responses[26:29])
      scores$study_skills <- mean(mws_resp, na.rm = TRUE)
    }
    
    # Extract Statistics self-efficacy (items 30-31)
    if (length(responses) >= 31) {
      stats_resp <- as.numeric(responses[30:31])
      scores$statistics <- mean(stats_resp, na.rm = TRUE)
    }
    
    return(scores)
  }
  
  # Calculate all scores
  scores <- calculate_scores(responses, item_bank)
  
  # Helper function to interpret scores
  get_level <- function(score) {
    if (is.na(score)) return("Nicht berechnet")
    if (score >= 4) return("Hoch")
    if (score >= 3) return("Mittel")
    return("Niedrig")
  }
  
  # Create HTML report with inline CSS for styling
  html_content <- paste0(
    '<div style="padding: 20px; font-family: Arial, sans-serif;">',
    '<h2 style="color: #003366; text-align: center;">Ihre Ergebnisse</h2>',
    
    # Results table
    '<table style="width: 100%; border-collapse: collapse; margin: 20px 0;">',
    '<tr style="background: #003366; color: white;">',
    '<th style="padding: 10px;">Bereich</th>',
    '<th style="padding: 10px;">Score</th>',
    '<th style="padding: 10px;">Bewertung</th>',
    '</tr>',
    
    # Big Five scores
    '<tr><td style="padding: 8px;"><strong>Extraversion</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$extraversion, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$extraversion), '</td></tr>',
    
    '<tr style="background: #f5f5f5;"><td style="padding: 8px;"><strong>Verträglichkeit</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$agreeableness, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$agreeableness), '</td></tr>',
    
    '<tr><td style="padding: 8px;"><strong>Gewissenhaftigkeit</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$conscientiousness, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$conscientiousness), '</td></tr>',
    
    '<tr style="background: #f5f5f5;"><td style="padding: 8px;"><strong>Neurotizismus</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$neuroticism, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$neuroticism), '</td></tr>',
    
    '<tr><td style="padding: 8px;"><strong>Offenheit</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$openness, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$openness), '</td></tr>',
    
    # Other measures
    '<tr style="background: #e8f4fd;"><td style="padding: 8px;"><strong>Stresslevel</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$stress, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$stress), '</td></tr>',
    
    '<tr style="background: #e8fde8;"><td style="padding: 8px;"><strong>Studierfähigkeiten</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$study_skills, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$study_skills), '</td></tr>',
    
    '<tr style="background: #fdf4e8;"><td style="padding: 8px;"><strong>Statistik-Kompetenz</strong></td>',
    '<td style="padding: 8px; text-align: center;">', round(scores$statistics, 2), '</td>',
    '<td style="padding: 8px; text-align: center;">', get_level(scores$statistics), '</td></tr>',
    
    '</table>',
    
    # Recommendations
    '<h3 style="color: #003366;">Empfehlungen</h3>',
    '<ul>',
    if(scores$stress > 3.5) '<li>Ihr Stresslevel ist erhöht. Nutzen Sie Entspannungstechniken.</li>' else '',
    if(scores$study_skills < 3) '<li>Erwägen Sie, sich Lerngruppen anzuschließen.</li>' else '',
    if(scores$statistics < 3) '<li>Nutzen Sie zusätzliche Statistik-Tutorien.</li>' else '',
    '</ul>',
    
    '<p style="text-align: center; margin-top: 30px;">',
    'Vielen Dank für Ihre Teilnahme!',
    '</p>',
    '</div>'
  )
  
  # Return HTML content that will be displayed by inrep
  return(shiny::HTML(html_content))
}

cat("✓ Results processor function created\n")

# -----------------------------------------------------------------------------
# STEP 6: CREATE STUDY CONFIGURATION
# -----------------------------------------------------------------------------
# This brings everything together into a configuration object

cat("\n⚙️  Creating study configuration...\n")

# Generate unique session ID with timestamp
session_uuid <- paste0("hildesheim_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  # BASIC INFORMATION
  name = "Hildesheim Psychologie Studie 2025",
  study_key = session_uuid,
  
  # THEME - Use Hildesheim theme for university branding
  theme = "hildesheim",
  
  # DEMOGRAPHICS - List in the order they should appear
  demographics = c(
    "Einverständnis",      # 1. Consent
    "Alter_VPN",          # 2. Age
    "Studiengang",        # 3. Study program
    "Geschlecht",         # 4. Gender
    "Wohnstatus",         # 5. Living situation
    "Wohn_Zusatz",        # 6. Living additional
    "Haustier",           # 7. Pet preference
    "Haustier_Zusatz",    # 8. Pet additional
    "Rauchen",            # 9. Smoking
    "Ernährung",          # 10. Diet
    "Ernährung_Zusatz",   # 11. Diet additional
    "Note_Englisch",      # 12. English grade
    "Note_Mathe",         # 13. Math grade
    "Vor_Nachbereitung",  # 14. Study hours
    "Zufrieden_Hi_5st",   # 15. Satisfaction 5pt
    "Zufrieden_Hi_7st",   # 16. Satisfaction 7pt
    "Persönlicher_Code"   # 17. Personal code
  ),
  
  # INPUT TYPES - How each demographic is displayed
  input_types = list(
    Einverständnis = "radio",      # Radio button
    Alter_VPN = "select",          # Dropdown
    Studiengang = "radio",         # Radio buttons
    Geschlecht = "radio",          # Radio buttons
    Wohnstatus = "radio",          # Radio buttons
    Wohn_Zusatz = "text",          # Text field
    Haustier = "radio",            # Radio buttons
    Haustier_Zusatz = "text",      # Text field
    Rauchen = "radio",             # Radio buttons
    Ernährung = "radio",           # Radio buttons
    Ernährung_Zusatz = "text",     # Text field
    Note_Englisch = "radio",       # Radio buttons
    Note_Mathe = "radio",          # Radio buttons
    Vor_Nachbereitung = "radio",  # Radio buttons
    Zufrieden_Hi_5st = "radio",   # Radio buttons
    Zufrieden_Hi_7st = "radio",   # Radio buttons
    Persönlicher_Code = "text"    # Text field
  ),
  
  # ASSESSMENT CONFIGURATION
  model = "GRM",              # Graded Response Model for Likert scales
  adaptive = FALSE,           # Fixed order (not adaptive)
  max_items = nrow(all_items),  # Show all items
  min_items = nrow(all_items),  # Require all items
  
  # UI CONFIGURATION
  response_ui_type = "radio",  # Radio buttons for responses
  progress_style = "bar",      # Progress bar display
  
  # SESSION MANAGEMENT
  session_save = TRUE,         # Enable session recovery
  session_timeout = 30,        # 30 minute timeout
  
  # PROVIDE CONFIGURATIONS
  demographic_configs = demographic_configs,  # From Step 3
  
  # INSTRUCTIONS - Text shown to participants
  instructions = list(
    welcome = "Willkommen zur Hildesheim Psychologie Studie 2025",
    
    purpose = paste0(
      "Liebe Studierende,\n\n",
      "In den Übungen zu den statistischen Verfahren wollen wir mit ",
      "anschaulichen Daten arbeiten, die von Ihnen selbst stammen."
    ),
    
    duration = "Die Studie dauert etwa 15-20 Minuten.",
    
    confidentiality = "Ihre Angaben sind selbstverständlich anonym.",
    
    consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    
    contact = "Bei Fragen: forschung@uni-hildesheim.de"
  ),
  
  # RESULTS PROCESSOR - Function to generate report
  results_processor = create_hildesheim_results,
  
  # FIX FOR ITEM SELECTION ISSUE
  # This ensures the first item is properly initialized
  criteria = "RANDOM",           # Use random for non-adaptive
  fixed_items = 1:nrow(all_items)  # Specify item order
)

cat("✓ Study configuration complete\n")

# -----------------------------------------------------------------------------
# STEP 7: VALIDATE CONFIGURATION
# -----------------------------------------------------------------------------
# Check that everything is set up correctly

cat("\n✅ Validating configuration...\n")

# Use the validation function to check for issues
validation <- validate_study_config(study_config, all_items)

if (validation$valid) {
  cat("✓ Configuration is valid and ready to launch!\n")
} else {
  cat("❌ Configuration has issues:\n")
  for (error in validation$errors) {
    cat("  -", error, "\n")
  }
}

# -----------------------------------------------------------------------------
# STEP 8: LAUNCH THE STUDY
# -----------------------------------------------------------------------------

cat("\n🚀 Launching study...\n")
cat("=============================================================================\n")

# Launch the study with all our configurations
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  webdav_url = webdav_url,
  password = password,
  save_format = "csv",  # Save data as CSV
  study_key = session_uuid
)

# The study is now running in your browser!
# Participants will see:
# 1. Instructions
# 2. Demographics (17 questions)
# 3. Assessment (31 items)
# 4. Results with scores and recommendations

cat("\n✓ Study launched successfully!\n")
cat("The study is now running in your web browser.\n")
cat("Data will be saved to: data/", session_uuid, ".csv\n", sep = "")
cat("=============================================================================\n")