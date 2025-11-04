# =============================================================================
# Hildesheim Study Data Read-In Script
# =============================================================================
# 
# This script reads CSV files from the study_data folder, processes the data,
# applies reverse coding, computes scale scores, adds variable and value labels,
# and exports the data to SPSS (.sav) and Excel (.xlsx) formats.
#
# FOLDER STRUCTURE:
#   The script should be in a folder, with a "study_data" subfolder containing CSV files:
#   
#   your_folder/
#     read_hilfo_data.R
#     study_data/
#       file1.csv
#       file2.csv
#       ...
#     output/          (created automatically)
#       file1.sav
#       file1.xlsx
#       ...
#
# USAGE:
#   1. Place your CSV files in a folder named "study_data" (in the same directory as this script)
#   2. Run: process_all_csv_files(input_dir = "study_data", output_dir = "output")
#   3. Find processed files in the "output" folder (or your specified output_dir)
#
# OUTPUT:
#   - Individual .sav and .xlsx files for each input CSV
#   - Combined .sav and .xlsx files (if multiple CSV files are processed)
#   - All files include variable labels, value labels, and computed scale scores
#
# SCALE COMPUTATIONS:
#   - BFI scales: Mean of 4 items each, with reverse coding applied
#   - PSQ_Stress: Mean of 5 items, with reverse coding for PSQ_29
#   - MWS_Studierfaehigkeiten: Mean of 4 items
#   - Statistik: Mean of 2 items
#
# REVERSE CODING:
#   Applied to items before computing scale scores:
#   - PA: items 1, 10, 15
#   - BFE: items 2, 3
#   - BFV: items 2, 4
#   - BFG: items 1, 4
#   - BFN: items 1, 4
#   - BFO: items 2, 4
#   - PSQ: item 4 (PSQ_29)
#
# Author: Generated for Hildesheim Study
# Date: 2025
# =============================================================================

# Load required libraries
# -----------------------------------------------------------------------------
required_packages <- c("rstudioapi","haven", "readr", "dplyr", "writexl", "labelled")

# Check and install missing packages
# Note: Missing packages are automatically installed if not present
missing_packages <- required_packages[!required_packages %in% installed.packages()[,"Package"]]
if(length(missing_packages) > 0) {
  install.packages(missing_packages, dependencies = TRUE)
}

# Load libraries
library(rstudioapi)
library(haven)
library(readr)
library(dplyr)
library(writexl)
library(labelled)

# Set working directory to the directory of the current script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# =============================================================================
# ITEM DEFINITIONS AND METADATA
# =============================================================================

# Item labels (German and English)
# -----------------------------------------------------------------------------
item_labels_de <- c(
  # Programming Anxiety (PA) items 1-20
  "Ich fühle mich unsicher, wenn ich programmieren soll.",
  "Der Gedanke, programmieren zu lernen, macht mich nervös.",
  "Ich habe Angst, beim Programmieren Fehler zu machen.",
  "Ich fühle mich überfordert, wenn ich an Programmieraufgaben denke.",
  "Ich bin besorgt, dass ich nicht gut genug programmieren kann.",
  "Ich vermeide es, neue Programmiersprachen zu nutzen, weil ich Angst habe, Fehler zu machen.",
  "In Gruppencodier-Sitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
  "Ich habe Sorge, Programmieraufgaben nicht rechtzeitig aufgrund fehlender Fähigkeiten abschließen zu können.",
  "Wenn ich bei einem Programmierproblem nicht weiterkomme, ist es mir peinlich, um Hilfe zu bitten.",
  "Ich fühle mich wohl dabei, meinen Code anderen zu erklären.",
  "Fortgeschrittene Programmierkonzepte (z.B. Rekursion, Multithreading) finde ich einschüchternd.",
  "Ich zweifle oft daran, Programmieren über die Grundlagen hinaus lernen zu können.",
  "Wenn mein Code nicht funktioniert, glaube ich, dass es an meinem mangelnden Talent liegt.",
  "Es macht mich nervös, Code ohne Schritt-für-Schritt-Anleitung zu schreiben.",
  "Ich bin zuversichtlich, bestehenden Code zu verändern, um neue Funktionen hinzuzufügen.",
  "Ich fühle mich manchmal ängstlich, noch bevor ich mit dem Programmieren beginne.",
  "Allein der Gedanke an das Debuggen macht mich angespannt, selbst bei kleineren Fehlern.",
  "Ich mache mir Sorgen, für die Qualität meines Codes beurteilt zu werden.",
  "Wenn mir jemand beim Programmieren zuschaut, werde ich nervös und mache Fehler.",
  "Schon der Gedanke an bevorstehende Programmieraufgaben setzt mich unter Stress.",
  
  # BFI Extraversion (BFE) items 21-24
  "Ich gehe aus mir heraus, bin gesellig.",
  "Ich bin eher ruhig.",
  "Ich bin eher schüchtern.",
  "Ich bin gesprächig.",
  
  # BFI Verträglichkeit (BFV) items 25-28
  "Ich bin einfühlsam, warmherzig.",
  "Ich habe mit anderen wenig Mitgefühl.",
  "Ich bin hilfsbereit und selbstlos.",
  "Andere sind mir eher gleichgültig, egal.",
  
  # BFI Gewissenhaftigkeit (BFG) items 29-32
  "Ich bin eher unordentlich.",
  "Ich bin systematisch, halte meine Sachen in Ordnung.",
  "Ich mag es sauber und aufgeräumt.",
  "Ich bin eher der chaotische Typ, mache selten sauber.",
  
  # BFI Neurotizismus (BFN) items 33-36
  "Ich bleibe auch in stressigen Situationen gelassen.",
  "Ich reagiere leicht angespannt.",
  "Ich mache mir oft Sorgen.",
  "Ich werde selten nervös und unsicher.",
  
  # BFI Offenheit (BFO) items 37-40
  "Ich bin vielseitig interessiert.",
  "Ich meide philosophische Diskussionen.",
  "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
  "Mich interessieren abstrakte Überlegungen wenig.",
  
  # PSQ Stress items 41-45
  "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
  "Ich habe zuviel zu tun.",
  "Ich fühle mich gehetzt.",
  "Ich habe genug Zeit für mich.",
  "Ich fühle mich unter Termindruck.",
  
  # MWS Study Skills items 46-49
  "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
  "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
  "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
  "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
  
  # Statistics items 50-51
  "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
  "Ich bin in der Lage, Statistik zu erlernen."
)

item_labels_en <- c(
  # Programming Anxiety (PA) items 1-20
  "I feel uncertain when I have to program.",
  "The thought of learning to program makes me nervous.",
  "I am afraid of making mistakes when programming.",
  "I feel overwhelmed when I think about programming tasks.",
  "I am worried that I am not good enough at programming.",
  "I avoid using new programming languages because I am afraid of making mistakes.",
  "During group coding sessions, I am nervous that my contributions will not be valued.",
  "I worry that I will be unable to finish a coding assignment on time due to lack of skills.",
  "When I get stuck on a programming problem, I feel embarrassed to ask for help.",
  "I feel comfortable explaining my code to others.",
  "I find advanced coding concepts (e.g., recursion, multithreading) intimidating.",
  "I often doubt my ability to learn programming beyond the basics.",
  "When my code does not work, I worry it is because I lack programming talent.",
  "I feel anxious when asked to write code without step-by-step instructions.",
  "I am confident in modifying existing code to add new features.",
  "I sometimes feel anxious even before sitting down to start programming.",
  "The thought of debugging makes me tense, even if the bug is minor.",
  "I worry about being judged for the quality of my code.",
  "When someone watches me code, I get nervous and make mistakes.",
  "I feel stressed just by thinking about upcoming programming tasks.",
  
  # BFI Extraversion (BFE) items 21-24
  "I am outgoing, sociable.",
  "I am rather quiet.",
  "I am rather shy.",
  "I am talkative.",
  
  # BFI Agreeableness (BFV) items 25-28
  "I am empathetic, warm-hearted.",
  "I have little sympathy for others.",
  "I am helpful and selfless.",
  "Others are rather indifferent to me.",
  
  # BFI Conscientiousness (BFG) items 29-32
  "I am rather disorganized.",
  "I am systematic, keep my things in order.",
  "I like it clean and tidy.",
  "I am rather the chaotic type, rarely clean up.",
  
  # BFI Neuroticism (BFN) items 33-36
  "I remain calm even in stressful situations.",
  "I react easily tensed.",
  "I often worry.",
  "I rarely become nervous and insecure.",
  
  # BFI Openness (BFO) items 37-40
  "I have diverse interests.",
  "I avoid philosophical discussions.",
  "I enjoy thinking thoroughly about complex things and understanding them.",
  "Abstract considerations interest me little.",
  
  # PSQ Stress items 41-45
  "I feel that too many demands are placed on me.",
  "I have too much to do.",
  "I feel rushed.",
  "I have enough time for myself.",
  "I feel under deadline pressure.",
  
  # MWS Study Skills items 46-49
  "coping with the social climate in the program (e.g., handling competition)",
  "organizing teamwork (e.g., finding study groups)",
  "making contacts with fellow students (e.g., for study groups, leisure)",
  "working together in a team (e.g., working on tasks together, preparing presentations)",
  
  # Statistics items 50-51
  "So far I have been able to follow the content of the statistics courses well.",
  "I am able to learn statistics."
)

# Reverse coding information
# -----------------------------------------------------------------------------
# TRUE means the item needs to be reverse coded (6 - value)
reverse_coded <- c(
  # PA items 1-20: items 1, 10, 15 are reverse coded
  TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,
  FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
  # BFE items 21-24: items 22, 23 are reverse coded
  FALSE, TRUE, TRUE, FALSE,
  # BFV items 25-28: items 26, 28 are reverse coded
  FALSE, TRUE, FALSE, TRUE,
  # BFG items 29-32: items 29, 32 are reverse coded
  TRUE, FALSE, FALSE, TRUE,
  # BFN items 33-36: items 33, 36 are reverse coded
  TRUE, FALSE, FALSE, TRUE,
  # BFO items 37-40: items 38, 40 are reverse coded
  FALSE, TRUE, FALSE, TRUE,
  # PSQ items 41-45: item 44 is reverse coded
  FALSE, FALSE, FALSE, TRUE, FALSE,
  # MWS items 46-49: no reverse coding
  FALSE, FALSE, FALSE, FALSE,
  # Statistics items 50-51: no reverse coding
  FALSE, FALSE
)

# Item IDs
item_ids <- c(
  paste0("PA_", sprintf("%02d", 1:20)),
  "BFE_01", "BFE_02", "BFE_03", "BFE_04",
  "BFV_01", "BFV_02", "BFV_03", "BFV_04",
  "BFG_01", "BFG_02", "BFG_03", "BFG_04",
  "BFN_01", "BFN_02", "BFN_03", "BFN_04",
  "BFO_01", "BFO_02", "BFO_03", "BFO_04",
  "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
  "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
  "Statistik_gutfolgen", "Statistik_selbstwirksam"
)

# =============================================================================
# VALUE LABELS
# =============================================================================

# Likert scale labels (1-5)
# For haven::labelled/labelled_spss the labels vector values must match the data type (numeric codes),
# and the names are the human-readable labels.
likert_labels <- c(
  "1 - Trifft überhaupt nicht zu / Not at all" = 1,
  "2 - Trifft eher nicht zu / Rather not" = 2,
  "3 - Neutral / Neutral" = 3,
  "4 - Trifft eher zu / Rather yes" = 4,
  "5 - Trifft voll zu / Fully agree" = 5
)

# Study language labels (for character vector). Values must match the underlying values ("de","en").
# Names are the human-readable labels.
language_labels <- c(
  "German" = "de",
  "English" = "en"
)

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

# Function to reverse code items (6 - value)
# -----------------------------------------------------------------------------
reverse_code <- function(value, reverse = FALSE) {
  if (reverse && !is.na(value)) {
    return(6 - value)
  }
  return(value)
}

# Function to compute BFI scale scores
# -----------------------------------------------------------------------------
compute_bfi_scales <- function(data) {
  # BFI Extraversion: items 21-24 (BFE_01 to BFE_04)
  # Reverse code items 22 and 23 (BFE_02, BFE_03)
  bfe_items <- c(
    data$BFE_01,
    reverse_code(data$BFE_02, reverse = TRUE),
    reverse_code(data$BFE_03, reverse = TRUE),
    data$BFE_04
  )
  data$BFI_Extraversion <- rowMeans(cbind(
    data$BFE_01,
    reverse_code(data$BFE_02, reverse = TRUE),
    reverse_code(data$BFE_03, reverse = TRUE),
    data$BFE_04
  ), na.rm = TRUE)
  
  # BFI Verträglichkeit: items 25-28 (BFV_01 to BFV_04)
  # Reverse code items 26 and 28 (BFV_02, BFV_04)
  data$BFI_Vertraeglichkeit <- rowMeans(cbind(
    data$BFV_01,
    reverse_code(data$BFV_02, reverse = TRUE),
    data$BFV_03,
    reverse_code(data$BFV_04, reverse = TRUE)
  ), na.rm = TRUE)
  
  # BFI Gewissenhaftigkeit: items 29-32 (BFG_01 to BFG_04)
  # Reverse code items 29 and 32 (BFG_01, BFG_04)
  data$BFI_Gewissenhaftigkeit <- rowMeans(cbind(
    reverse_code(data$BFG_01, reverse = TRUE),
    data$BFG_02,
    data$BFG_03,
    reverse_code(data$BFG_04, reverse = TRUE)
  ), na.rm = TRUE)
  
  # BFI Neurotizismus: items 33-36 (BFN_01 to BFN_04)
  # Reverse code items 33 and 36 (BFN_01, BFN_04)
  data$BFI_Neurotizismus <- rowMeans(cbind(
    reverse_code(data$BFN_01, reverse = TRUE),
    data$BFN_02,
    data$BFN_03,
    reverse_code(data$BFN_04, reverse = TRUE)
  ), na.rm = TRUE)
  
  # BFI Offenheit: items 37-40 (BFO_01 to BFO_04)
  # Reverse code items 38 and 40 (BFO_02, BFO_04)
  data$BFI_Offenheit <- rowMeans(cbind(
    data$BFO_01,
    reverse_code(data$BFO_02, reverse = TRUE),
    data$BFO_03,
    reverse_code(data$BFO_04, reverse = TRUE)
  ), na.rm = TRUE)
  
  return(data)
}

# Function to set SPSS-specific attributes and produce SPSS syntax for measures
# -----------------------------------------------------------------------------
# Ensures SPSS-friendly formats and prepares a .sps syntax to set measurement levels
apply_spss_attributes <- function(data) {
  # Set SPSS display/format attributes that SPSS understands via haven
  for (col in names(data)) {
    x <- data[[col]]
    # Variable label already handled elsewhere; here we ensure formats/classes
    if (col %in% item_ids) {
      # Items: ensure labelled_spss with Likert value labels and numeric format
      if (is.numeric(x)) {
        # keep any existing var label
        existing_var_label <- var_label(x)
        x <- haven::labelled_spss(x, labels = likert_labels)
        attr(x, "format.spss") <- "F8.0"
        if (!is.null(existing_var_label)) var_label(x) <- existing_var_label
      }
    } else if (col %in% c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit",
                           "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress",
                           "MWS_Studierfaehigkeiten", "Statistik")) {
      # Scale scores: continuous numeric
      if (is.numeric(x)) {
        attr(x, "format.spss") <- "F8.2"
      }
    } else if (col %in% c("timestamp", "session_id")) {
      # Keep as character; set reasonable string format width
      if (is.character(x)) {
        maxw <- max(nchar(x[!is.na(x)]), 8)
        attr(x, "format.spss") <- paste0("A", min(max(8, maxw), 255))
      }
    } else if (col == "study_language") {
      # Language: labelled string is not supported; keep character with labels recorded via codebook
      # For SPSS, we'll set measurement to NOMINAL via syntax file
      if (is.character(x)) {
        maxw <- max(nchar(x[!is.na(x)]), 2)
        attr(x, "format.spss") <- paste0("A", min(max(2, maxw), 16))
      }
    }
    data[[col]] <- x
  }
  return(data)
}

# Function to generate SPSS syntax to set measurement levels and ensure labels
# -----------------------------------------------------------------------------
write_sps_syntax <- function(data, sps_path) {
  # Build lists by type
  items <- intersect(item_ids, names(data))
  scales <- intersect(c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit",
                        "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress",
                        "MWS_Studierfaehigkeiten", "Statistik"), names(data))
  nominals <- intersect(c("study_language"), names(data))

  lines <- c(
    "* Set measurement levels (SPSS).",
    if (length(items)) paste0("VARIABLE LEVEL ", paste(items, collapse = " "), " (ORDINAL).") else NULL,
    if (length(scales)) paste0("VARIABLE LEVEL ", paste(scales, collapse = " "), " (SCALE).") else NULL,
    if (length(nominals)) paste0("VARIABLE LEVEL ", paste(nominals, collapse = " "), " (NOMINAL).") else NULL,
    "EXECUTE."
  )
  lines <- lines[!sapply(lines, is.null)]
  writeLines(lines, sps_path)
}

# Function to compute PSQ Stress score
# -----------------------------------------------------------------------------
compute_psq_stress <- function(data) {
  # PSQ Stress: items 41-45 (PSQ_02, PSQ_04, PSQ_16, PSQ_29, PSQ_30)
  # Reverse code item 44 (PSQ_29)
  data$PSQ_Stress <- rowMeans(cbind(
    data$PSQ_02,
    data$PSQ_04,
    data$PSQ_16,
    reverse_code(data$PSQ_29, reverse = TRUE),
    data$PSQ_30
  ), na.rm = TRUE)
  
  return(data)
}

# Function to compute MWS Study Skills score
# -----------------------------------------------------------------------------
compute_mws_studierfaehigkeiten <- function(data) {
  # MWS Studierfähigkeiten: items 46-49 (MWS_1_KK, MWS_10_KK, MWS_17_KK, MWS_21_KK)
  # No reverse coding needed
  data$MWS_Studierfaehigkeiten <- rowMeans(cbind(
    data$MWS_1_KK,
    data$MWS_10_KK,
    data$MWS_17_KK,
    data$MWS_21_KK
  ), na.rm = TRUE)
  
  return(data)
}

# Function to compute Statistics score
# -----------------------------------------------------------------------------
compute_statistik <- function(data) {
  # Statistics: items 50-51 (Statistik_gutfolgen, Statistik_selbstwirksam)
  # No reverse coding needed
  data$Statistik <- rowMeans(cbind(
    data$Statistik_gutfolgen,
    data$Statistik_selbstwirksam
  ), na.rm = TRUE)
  
  return(data)
}

# Function to add variable labels
# -----------------------------------------------------------------------------
add_variable_labels <- function(data, language = "de") {
  
  # Choose labels based on language
  if (language == "en") {
    item_labels <- item_labels_en
  } else {
    item_labels <- item_labels_de
  }
  
  # Add labels to item variables
  for (i in seq_along(item_ids)) {
    if (item_ids[i] %in% names(data)) {
      var_label(data[[item_ids[i]]]) <- item_labels[i]
    }
  }
  
  # Add labels to scale scores (only if they exist in the data)
  if (language == "de") {
    if ("BFI_Extraversion" %in% names(data)) {
      var_label(data$BFI_Extraversion) <- "BFI Extraversion (Mittelwert der Items BFE_01 bis BFE_04)"
    }
    if ("BFI_Vertraeglichkeit" %in% names(data)) {
      var_label(data$BFI_Vertraeglichkeit) <- "BFI Verträglichkeit (Mittelwert der Items BFV_01 bis BFV_04)"
    }
    if ("BFI_Gewissenhaftigkeit" %in% names(data)) {
      var_label(data$BFI_Gewissenhaftigkeit) <- "BFI Gewissenhaftigkeit (Mittelwert der Items BFG_01 bis BFG_04)"
    }
    if ("BFI_Neurotizismus" %in% names(data)) {
      var_label(data$BFI_Neurotizismus) <- "BFI Neurotizismus (Mittelwert der Items BFN_01 bis BFN_04)"
    }
    if ("BFI_Offenheit" %in% names(data)) {
      var_label(data$BFI_Offenheit) <- "BFI Offenheit (Mittelwert der Items BFO_01 bis BFO_04)"
    }
    if ("PSQ_Stress" %in% names(data)) {
      var_label(data$PSQ_Stress) <- "PSQ Stress (Mittelwert der Items PSQ_02, PSQ_04, PSQ_16, PSQ_29, PSQ_30)"
    }
    if ("MWS_Studierfaehigkeiten" %in% names(data)) {
      var_label(data$MWS_Studierfaehigkeiten) <- "MWS Studierfähigkeiten (Mittelwert der Items MWS_1_KK, MWS_10_KK, MWS_17_KK, MWS_21_KK)"
    }
    if ("Statistik" %in% names(data)) {
      var_label(data$Statistik) <- "Statistik (Mittelwert der Items Statistik_gutfolgen, Statistik_selbstwirksam)"
    }
  } else {
    if ("BFI_Extraversion" %in% names(data)) {
      var_label(data$BFI_Extraversion) <- "BFI Extraversion (mean of items BFE_01 to BFE_04)"
    }
    if ("BFI_Vertraeglichkeit" %in% names(data)) {
      var_label(data$BFI_Vertraeglichkeit) <- "BFI Agreeableness (mean of items BFV_01 to BFV_04)"
    }
    if ("BFI_Gewissenhaftigkeit" %in% names(data)) {
      var_label(data$BFI_Gewissenhaftigkeit) <- "BFI Conscientiousness (mean of items BFG_01 to BFG_04)"
    }
    if ("BFI_Neurotizismus" %in% names(data)) {
      var_label(data$BFI_Neurotizismus) <- "BFI Neuroticism (mean of items BFN_01 to BFN_04)"
    }
    if ("BFI_Offenheit" %in% names(data)) {
      var_label(data$BFI_Offenheit) <- "BFI Openness (mean of items BFO_01 to BFO_04)"
    }
    if ("PSQ_Stress" %in% names(data)) {
      var_label(data$PSQ_Stress) <- "PSQ Stress (mean of items PSQ_02, PSQ_04, PSQ_16, PSQ_29, PSQ_30)"
    }
    if ("MWS_Studierfaehigkeiten" %in% names(data)) {
      var_label(data$MWS_Studierfaehigkeiten) <- "MWS Study Skills (mean of items MWS_1_KK, MWS_10_KK, MWS_17_KK, MWS_21_KK)"
    }
    if ("Statistik" %in% names(data)) {
      var_label(data$Statistik) <- "Statistics (mean of items Statistik_gutfolgen, Statistik_selbstwirksam)"
    }
  }
  
  # Add labels to other variables (only if they exist)
  if ("timestamp" %in% names(data)) {
    var_label(data$timestamp) <- "Timestamp of data collection"
  }
  if ("session_id" %in% names(data)) {
    var_label(data$session_id) <- "Unique session identifier"
  }
  if ("study_language" %in% names(data)) {
    var_label(data$study_language) <- "Language of the study (de = German, en = English)"
  }
  
  return(data)
}

# Function to add value labels
# -----------------------------------------------------------------------------
# Uses haven::labelled() to properly create labelled vectors
# Preserves variable labels when adding value labels
add_value_labels <- function(data) {
  
  # Ensure all item columns are numeric before adding labels
  # Convert any character columns that should be numeric
  for (item_id in item_ids) {
    if (item_id %in% names(data)) {
      # Convert to numeric if not already
      if (!is.numeric(data[[item_id]])) {
        data[[item_id]] <- suppressWarnings(as.numeric(as.character(data[[item_id]])))
      }
      # Only add labels if column is numeric
      if (is.numeric(data[[item_id]])) {
        tryCatch({
          # Get existing variable label BEFORE creating labelled vector
          existing_var_label <- var_label(data[[item_id]])
          
          # Use haven::labelled() to create properly labelled vector with value labels
          # This creates a labelled class that SPSS can understand
          data[[item_id]] <- haven::labelled(data[[item_id]], labels = likert_labels)
          
          # Restore variable label AFTER creating labelled vector (haven::labelled doesn't preserve it)
          if (!is.null(existing_var_label)) {
            var_label(data[[item_id]]) <- existing_var_label
          }
        }, error = function(e) {
          # If labelled() fails, preserve variable label on numeric vector
          if (!is.null(existing_var_label)) {
            var_label(data[[item_id]]) <- existing_var_label
          }
        })
      }
    }
  }
  
  # Scale scores are continuous variables, so we don't add value labels
  # But we ensure they keep their variable labels (already set in add_variable_labels)
  
  # Add value labels to study_language (character column)
  if ("study_language" %in% names(data)) {
    tryCatch({
      # Get existing variable label
      existing_var_label <- var_label(data$study_language)
      
      # For character columns, use labelled() with character labels
      data$study_language <- haven::labelled(data$study_language, labels = language_labels)
      
      # Restore variable label AFTER creating labelled vector
      if (!is.null(existing_var_label)) {
        var_label(data$study_language) <- existing_var_label
      }
    }, error = function(e) {
      # If it fails, preserve variable label on character vector
      if (!is.null(existing_var_label)) {
        var_label(data$study_language) <- existing_var_label
      }
    })
  }
  
  return(data)
}

# Function to create codebook
# -----------------------------------------------------------------------------
# Creates a codebook data frame with variable names, labels, value labels, and types
create_codebook <- function(data, language = "de") {
  
  # Choose labels based on language
  if (language == "en") {
    item_labels <- item_labels_en
  } else {
    item_labels <- item_labels_de
  }
  
  codebook_list <- list()
  
  # Process all variables in the data
  for (var_name in names(data)) {
    var_info <- list(
      Variable = var_name,
      Label = "",
      Type = "",
      Values = "",
      Value_Labels = "",
      Reversed = "",
      Already_Reversed = ""
    )
    
    # Get variable label
    var_label_obj <- var_label(data[[var_name]])
    if (!is.null(var_label_obj) && !is.na(var_label_obj)) {
      var_info$Label <- as.character(var_label_obj)
    } else {
      # Try to find in item_labels
      if (var_name %in% item_ids) {
        idx <- which(item_ids == var_name)
        if (length(idx) > 0 && idx <= length(item_labels)) {
          var_info$Label <- item_labels[idx]
        }
      }
    }
    
    # Get variable type
    var_info$Type <- class(data[[var_name]])[1]
    if (inherits(data[[var_name]], "labelled")) {
      var_info$Type <- paste0("labelled ", class(data[[var_name]])[2])
    }
    
    # Get value labels if available
    val_labels_obj <- val_labels(data[[var_name]])
    if (!is.null(val_labels_obj) && length(val_labels_obj) > 0) {
      # Format value labels
      value_pairs <- paste0(names(val_labels_obj), " = ", val_labels_obj, collapse = "; ")
      var_info$Values <- paste(names(val_labels_obj), collapse = ", ")
      var_info$Value_Labels <- value_pairs
    } else {
      # For numeric variables, show range
      if (is.numeric(data[[var_name]])) {
        non_na <- data[[var_name]][!is.na(data[[var_name]])]
        if (length(non_na) > 0) {
          var_info$Values <- paste0(min(non_na, na.rm = TRUE), " to ", max(non_na, na.rm = TRUE))
        }
      }
    }
    
    # Determine reverse coding information
    # Check if this variable is an item that should be reverse coded
    if (var_name %in% item_ids) {
      idx <- which(item_ids == var_name)
      if (length(idx) > 0 && idx <= length(reverse_coded)) {
        # This item should be reverse coded for scale computation
        var_info$Reversed <- ifelse(reverse_coded[idx], "Yes", "No")
        # CSV stores raw values (not reversed), so items are never already reversed
        var_info$Already_Reversed <- "No"
      } else {
        var_info$Reversed <- "No"
        var_info$Already_Reversed <- "No"
      }
    } else if (var_name %in% c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit", 
                               "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress", 
                               "MWS_Studierfaehigkeiten", "Statistik")) {
      # Scale scores: computed with reverse coding, but not stored as reversed items
      var_info$Reversed <- "N/A (computed scale)"
      var_info$Already_Reversed <- "N/A (computed scale)"
    } else {
      # Other variables (timestamp, session_id, study_language)
      var_info$Reversed <- "No"
      var_info$Already_Reversed <- "No"
    }
    
    codebook_list[[length(codebook_list) + 1]] <- var_info
  }
  
  # Convert to data frame
  codebook <- do.call(rbind, lapply(codebook_list, function(x) {
    data.frame(
      Variable = x$Variable,
      Label = x$Label,
      Type = x$Type,
      Values = x$Values,
      Value_Labels = x$Value_Labels,
      Reversed = x$Reversed,
      Already_Reversed = x$Already_Reversed,
      stringsAsFactors = FALSE
    )
  }))
  
  return(codebook)
}

# =============================================================================
# MAIN PROCESSING FUNCTION
# =============================================================================

# Function to process a single CSV file
# -----------------------------------------------------------------------------
# Processes a single CSV file: reads data, applies reverse coding, computes scales,
# adds labels, and exports to SPSS (.sav) and Excel (.xlsx) formats
# Expected columns: timestamp, session_id, study_language, all item columns, and scale scores
process_csv_file <- function(file_path, output_dir = "output") {
  
  # Define all expected columns from the CSV format
  expected_character_cols <- c("timestamp", "session_id", "study_language")
  expected_scale_cols <- c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit", 
                           "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress", 
                           "MWS_Studierfaehigkeiten", "Statistik")
  all_expected_cols <- c(expected_character_cols, item_ids, expected_scale_cols)
  
  # Read CSV file - let readr guess types, suppress warnings about missing columns
  suppressWarnings({
    data_raw <- read_csv(file_path, 
                         locale = locale(encoding = "UTF-8"),
                         show_col_types = FALSE)
  })
  
  # Ensure all expected columns exist (create as NA if missing)
  n_rows <- nrow(data_raw)
  if (n_rows == 0) {
    n_rows <- 1
    data_raw <- data.frame(matrix(NA, nrow = 1, ncol = 1))
  }
  
  # Create data frame with all expected columns
  data <- data.frame(matrix(NA, nrow = n_rows, ncol = length(all_expected_cols)))
  names(data) <- all_expected_cols
  
  # Fill in data from CSV if columns exist
  for (col in all_expected_cols) {
    if (col %in% names(data_raw)) {
      data[[col]] <- data_raw[[col]]
    }
  }
  
  # Ensure character columns are character type
  # Note: Keep NA as NA (don't replace with empty string) for proper handling
  for (col in expected_character_cols) {
    if (col %in% names(data)) {
      data[[col]] <- as.character(data[[col]])
    }
  }
  
  # Ensure item and scale columns are numeric
  for (col in c(item_ids, expected_scale_cols)) {
    if (col %in% names(data)) {
      # Convert to numeric, handling character "NA" strings
      data[[col]] <- suppressWarnings(as.numeric(as.character(data[[col]])))
    }
  }
  
  # Determine language from first row (or default to German)
  # Note: study_language might be empty string if missing, so check both NA and empty
  if (nrow(data) > 0 && "study_language" %in% names(data)) {
    lang_val <- data$study_language[1]
    if (!is.na(lang_val) && lang_val != "" && !is.null(lang_val)) {
      lang <- lang_val
    } else {
      lang <- "de"
    }
  } else {
    lang <- "de"
  }
  
  # Recompute scale scores (to ensure accuracy)
  # Note: This applies reverse coding as per the scoring function in HilFo.R
  # The CSV export function may not apply reverse coding, but the correct
  # psychometric approach requires reverse coding for certain items.
  data <- compute_bfi_scales(data)
  data <- compute_psq_stress(data)
  data <- compute_mws_studierfaehigkeiten(data)
  data <- compute_statistik(data)
  
  # Ensure all numeric columns are actually numeric before adding labels
  # This is critical for value label assignment to work correctly
  for (col in c(item_ids, expected_scale_cols)) {
    if (col %in% names(data)) {
      if (!is.numeric(data[[col]])) {
        data[[col]] <- suppressWarnings(as.numeric(as.character(data[[col]])))
      }
    }
  }
  
  # Add variable labels
  data <- add_variable_labels(data, language = lang)
  
  # Add value labels (with error handling)
  data <- tryCatch({
    add_value_labels(data)
  }, error = function(e) {
    warning("Error adding value labels: ", e$message)
    data  # Return data without labels if assignment fails
  })
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Generate base filename (same as input file without extension)
  base_name <- tools::file_path_sans_ext(basename(file_path))
  
  # Apply SPSS-specific attributes
  data <- apply_spss_attributes(data)

  # Export to SPSS (.sav) format with labels and formats
  sav_file <- file.path(output_dir, paste0(base_name, ".sav"))
  write_sav(data, sav_file)
  
  # Export to Excel (.xlsx) with Data + Codebook
  xlsx_file <- file.path(output_dir, paste0(base_name, ".xlsx"))
  codebook <- create_codebook(data, language = lang)
  write_xlsx(list(Data = data, Codebook = codebook), xlsx_file)

  # Also write SPSS syntax to set measurement levels (ordinal/nominal/scale)
  sps_file <- file.path(output_dir, paste0(base_name, ".sps"))
  write_sps_syntax(data, sps_file)
  
  return(data)
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Main function to process all CSV files
# -----------------------------------------------------------------------------
# Processes all CSV files in the input directory and combines them into ONE SPSS and ONE Excel file:
# - Reads each CSV file
# - Applies reverse coding and computes scale scores
# - Adds variable and value labels
# - Combines all data into one dataset
# - Exports ONE combined .sav and ONE combined .xlsx file
# Errors are caught and processing continues for remaining files
process_all_csv_files <- function(input_dir = "study_data", output_dir = "output") {
  
  # Check if input directory exists
  if (!dir.exists(input_dir)) {
    stop("Input directory '", input_dir, "' does not exist. Please create it and place your CSV files there.")
  }
  
  # Find all CSV files in the input directory
  csv_files <- list.files(input_dir, pattern = "\\.csv$", full.names = TRUE, ignore.case = TRUE)
  
  if (length(csv_files) == 0) {
    stop("No CSV files found in '", input_dir, "' directory.")
  }
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Process each file and collect data (without exporting individual files)
  # Note: Errors are caught per file so processing can continue if one file fails
  all_data <- list()
  successful_files <- 0
  for (i in seq_along(csv_files)) {
    tryCatch({
      # Process file but don't export individual files
      # We'll use the same processing logic but skip the export step
      file_path <- csv_files[i]
      
      # Define all expected columns from the CSV format
      expected_character_cols <- c("timestamp", "session_id", "study_language")
      expected_scale_cols <- c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit", 
                               "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress", 
                               "MWS_Studierfaehigkeiten", "Statistik")
      all_expected_cols <- c(expected_character_cols, item_ids, expected_scale_cols)
      
      # Read CSV file - let readr guess types, suppress warnings about missing columns
      suppressWarnings({
        data_raw <- read_csv(file_path, 
                             locale = locale(encoding = "UTF-8"),
                             show_col_types = FALSE)
      })
      
      # Ensure all expected columns exist (create as NA if missing)
      n_rows <- nrow(data_raw)
      if (n_rows == 0) {
        n_rows <- 1
        data_raw <- data.frame(matrix(NA, nrow = 1, ncol = 1))
      }
      
      # Create data frame with all expected columns
      data <- data.frame(matrix(NA, nrow = n_rows, ncol = length(all_expected_cols)))
      names(data) <- all_expected_cols
      
      # Fill in data from CSV if columns exist
      for (col in all_expected_cols) {
        if (col %in% names(data_raw)) {
          data[[col]] <- data_raw[[col]]
        }
      }
      
      # Ensure character columns are character type
      for (col in expected_character_cols) {
        if (col %in% names(data)) {
          data[[col]] <- as.character(data[[col]])
        }
      }
      
      # Ensure item and scale columns are numeric
      for (col in c(item_ids, expected_scale_cols)) {
        if (col %in% names(data)) {
          data[[col]] <- suppressWarnings(as.numeric(as.character(data[[col]])))
        }
      }
      
      # Determine language from first row (or default to German)
      if (nrow(data) > 0 && "study_language" %in% names(data)) {
        lang_val <- data$study_language[1]
        if (!is.na(lang_val) && lang_val != "" && !is.null(lang_val)) {
          lang <- lang_val
        } else {
          lang <- "de"
        }
      } else {
        lang <- "de"
      }
      
      # Recompute scale scores (to ensure accuracy)
      data <- compute_bfi_scales(data)
      data <- compute_psq_stress(data)
      data <- compute_mws_studierfaehigkeiten(data)
      data <- compute_statistik(data)
      
      # Ensure all numeric columns are actually numeric before adding labels
      for (col in c(item_ids, expected_scale_cols)) {
        if (col %in% names(data)) {
          if (!is.numeric(data[[col]])) {
            data[[col]] <- suppressWarnings(as.numeric(as.character(data[[col]])))
          }
        }
      }
      
      # Store processed data (without labels yet - will add after combining)
      if (!is.null(data) && nrow(data) > 0) {
        all_data[[successful_files + 1]] <- data
        successful_files <- successful_files + 1
      }
    }, error = function(e) {
      # Error is silently caught - file processing continues
      warning("Failed to process file: ", basename(csv_files[i]), " - ", e$message)
    })
  }
  
  # Filter out any NULL entries
  all_data <- all_data[!sapply(all_data, is.null)]
  
  # Combine all data into one dataset
  if (length(all_data) > 0) {
    combined_data <- bind_rows(all_data)
    
    # Process combined data (using language from first row)
    if (nrow(combined_data) > 0) {
      # Determine language from first row (defaults to German if not specified)
      lang <- ifelse(!is.na(combined_data$study_language[1]) && combined_data$study_language[1] != "", 
                     combined_data$study_language[1], "de")
      
      # Ensure all numeric columns are actually numeric before adding labels
      # bind_rows might convert some columns to character if there are mixed types
      expected_scale_cols <- c("BFI_Extraversion", "BFI_Vertraeglichkeit", "BFI_Gewissenhaftigkeit", 
                               "BFI_Neurotizismus", "BFI_Offenheit", "PSQ_Stress", 
                               "MWS_Studierfaehigkeiten", "Statistik")
      for (col in c(item_ids, expected_scale_cols)) {
        if (col %in% names(combined_data)) {
          if (!is.numeric(combined_data[[col]])) {
            combined_data[[col]] <- suppressWarnings(as.numeric(as.character(combined_data[[col]])))
          }
        }
      }
      
      # Add variable and value labels to combined data
      combined_data <- add_variable_labels(combined_data, language = lang)
      
      # Add value labels with error handling
      combined_data <- tryCatch({
        add_value_labels(combined_data)
      }, error = function(e) {
        warning("Error adding value labels to combined data: ", e$message)
        combined_data  # Return data without labels if assignment fails
      })
      
      # Export ONE combined file to both formats
      combined_sav <- file.path(output_dir, "hilfo_combined.sav")
      combined_xlsx <- file.path(output_dir, "hilfo_combined.xlsx")
      
      # Apply SPSS-specific attributes and write SPSS file
      combined_data <- apply_spss_attributes(combined_data)
      write_sav(combined_data, combined_sav)
      
      # Create codebook for Excel
      codebook <- create_codebook(combined_data, language = lang)
      
      # Write Excel file with two sheets: data and codebook
      write_xlsx(
        list(
          Data = combined_data,
          Codebook = codebook
        ),
        combined_xlsx
      )

      # Write SPSS syntax for measurement levels
      combined_sps <- file.path(output_dir, "hilfo_combined.sps")
      write_sps_syntax(combined_data, combined_sps)
    }
  } else {
    stop("No data was successfully processed from any CSV files.")
  }
  
  return(all_data)
}

# =============================================================================
# RUN THE SCRIPT
# =============================================================================
# 
# Process all CSV files in study_data folder:
process_all_csv_files(input_dir = "study_data")
#
# Process a single CSV file:
#   process_csv_file("study_data/your_file.csv", output_dir = "output")
#
# Output files will be saved in the specified output_dir (default: "output")

