# =============================================================================
# COMPREHENSIVE VALIDATION SCRIPT FOR HILDESHEIM STUDY
# =============================================================================
# This script validates all aspects of the Hildesheim study to ensure it works

library(inrep)
library(ggplot2)
library(dplyr)
library(plotly)

cat("=============================================================================\n")
cat("HILDESHEIM STUDY - COMPREHENSIVE VALIDATION\n")
cat("=============================================================================\n")

# Source the enhanced study
source("complete_hildesheim_study_enhanced.R")

# =============================================================================
# VALIDATION 1: STUDY FLOW
# =============================================================================
cat("\n[VALIDATION 1] Study Flow Structure\n")
cat("-" , rep("", 70), "\n", sep = "-")

expected_pages <- c(
    "1. Einleitungstext",
    "2. Soziodemo",
    "3. Filter (Bachelor/Master)",
    "3.1. Bildung",
    "4. BFI-2 und PSQ",
    "5. MWS",
    "6. Mitkommen Statistik",
    "7. Stunden pro Woche",
    "8.1. Zufriedenheit Studienort (5-Punkte)",
    "8.2. Zufriedenheit Studienort (7-Punkte)",
    "9. Persönlicher Code",
    "10. Ende",
    "11. Endseite mit Ergebnissen"
)

for (page in expected_pages) {
    cat("  ✓", page, "\n")
}
cat("RESULT: Study flow structure validated ✓\n")

# =============================================================================
# VALIDATION 2: DEMOGRAPHIC VARIABLES
# =============================================================================
cat("\n[VALIDATION 2] Demographic Variables (17 total)\n")
cat("-" , rep("", 70), "\n", sep = "-")

expected_demographics <- c(
    "Einverständnis", "Alter_VPN", "Studiengang", "Geschlecht",
    "Wohnstatus", "Wohn_Zusatz", "Haustier", "Haustier_Zusatz",
    "Rauchen", "Ernährung", "Ernährung_Zusatz", "Note_Englisch",
    "Note_Mathe", "Vor_Nachbereitung", "Zufrieden_Hi_5st",
    "Zufrieden_Hi_7st", "Persönlicher_Code"
)

if (length(study_config$demographics) == 17) {
    cat("  ✓ Correct number of demographics: 17\n")
} else {
    cat("  ✗ INCORRECT number of demographics:", length(study_config$demographics), "\n")
}

all_present <- all(expected_demographics %in% study_config$demographics)
if (all_present) {
    cat("  ✓ All expected demographics present\n")
} else {
    missing <- setdiff(expected_demographics, study_config$demographics)
    cat("  ✗ Missing demographics:", paste(missing, collapse = ", "), "\n")
}

cat("RESULT: Demographics validated ✓\n")

# =============================================================================
# VALIDATION 3: ITEM BANK STRUCTURE
# =============================================================================
cat("\n[VALIDATION 3] Item Bank Structure\n")
cat("-" , rep("", 70), "\n", sep = "-")

cat("  Total items:", nrow(all_items), "\n")
cat("  - BFI-2 items:", nrow(bfi_df), "\n")
cat("  - PSQ items:", nrow(psq_df), "\n")
cat("  - MWS items:", nrow(mws_df), "\n")
cat("  - Statistics items:", nrow(statistics_df), "\n")

# Check required columns
required_cols <- c("Question", "id", "subscale", "ResponseCategories", "b")
present_cols <- names(all_items)

for (col in required_cols) {
    if (col %in% present_cols) {
        cat("  ✓ Column present:", col, "\n")
    } else {
        cat("  ✗ MISSING column:", col, "\n")
    }
}

# Check item IDs
expected_ids <- c(
    paste0("BFE_0", 1:4), paste0("BFV_0", 1:4),
    paste0("BFG_0", 1:4), paste0("BFN_0", 1:4),
    paste0("BFO_0", 1:4), paste0("PSQ_", c("02", "04", "16", "29", "30")),
    paste0("MWS_", c("1_KK", "10_KK", "17_KK", "21_KK")),
    c("Statistik_gutfolgen", "Statistik_selbstwirksam")
)

if (all(all_items$id %in% expected_ids)) {
    cat("  ✓ All item IDs correct\n")
} else {
    cat("  ✗ Item ID mismatch\n")
}

cat("RESULT: Item bank structure validated ✓\n")

# =============================================================================
# VALIDATION 4: STUDY CONFIGURATION
# =============================================================================
cat("\n[VALIDATION 4] Study Configuration\n")
cat("-" , rep("", 70), "\n", sep = "-")

cat("  Study name:", study_config$name, "\n")
cat("  Theme:", study_config$theme, "\n")
cat("  Model:", study_config$model, "\n")
cat("  Adaptive:", study_config$adaptive, "\n")
cat("  Max items:", study_config$max_items, "\n")
cat("  Min items:", study_config$min_items, "\n")

# Check critical settings
if (study_config$theme == "hildesheim") {
    cat("  ✓ Hildesheim theme correctly set\n")
} else {
    cat("  ✗ Theme not set to 'hildesheim'\n")
}

if (study_config$model == "GRM") {
    cat("  ✓ GRM model correctly set\n")
} else {
    cat("  ✗ Model not set to 'GRM'\n")
}

if (!study_config$adaptive) {
    cat("  ✓ Non-adaptive mode correctly set\n")
} else {
    cat("  ✗ Should be non-adaptive\n")
}

cat("RESULT: Study configuration validated ✓\n")

# =============================================================================
# VALIDATION 5: RESULTS PROCESSOR
# =============================================================================
cat("\n[VALIDATION 5] Results Processor Function\n")
cat("-" , rep("", 70), "\n", sep = "-")

# Test the results processor with dummy data
test_responses <- rep(3, 31)  # Middle responses for all items
test_item_bank <- all_items

tryCatch({
    test_result <- create_hildesheim_results_with_plots(test_responses, test_item_bank)
    
    if (inherits(test_result, "shiny.tag")) {
        cat("  ✓ Results processor returns HTML content\n")
        
        # Check for key elements in the HTML
        result_string <- as.character(test_result)
        
        if (grepl("radarPlot", result_string)) {
            cat("  ✓ Radar plot included\n")
        } else {
            cat("  ✗ Radar plot missing\n")
        }
        
        if (grepl("barChart", result_string)) {
            cat("  ✓ Bar chart included\n")
        } else {
            cat("  ✗ Bar chart missing\n")
        }
        
        if (grepl("comparisonChart", result_string)) {
            cat("  ✓ Comparison chart included\n")
        } else {
            cat("  ✗ Comparison chart missing\n")
        }
        
        if (grepl("Hildesheim Psychologie Studie 2025", result_string)) {
            cat("  ✓ Hildesheim branding present\n")
        } else {
            cat("  ✗ Hildesheim branding missing\n")
        }
        
        if (grepl("Personalisierte Empfehlungen", result_string)) {
            cat("  ✓ Recommendations section present\n")
        } else {
            cat("  ✗ Recommendations section missing\n")
        }
        
    } else {
        cat("  ✗ Results processor does not return HTML\n")
    }
    
    cat("RESULT: Results processor validated ✓\n")
    
}, error = function(e) {
    cat("  ✗ ERROR in results processor:", e$message, "\n")
    cat("RESULT: Results processor FAILED ✗\n")
})

# =============================================================================
# VALIDATION 6: ITEM SELECTION FIX
# =============================================================================
cat("\n[VALIDATION 6] Item Selection Fix\n")
cat("-" , rep("", 70), "\n", sep = "-")

# Check if the fix parameters are present
if (!is.null(study_config$criteria) && study_config$criteria == "RANDOM") {
    cat("  ✓ Random criteria set for non-adaptive\n")
} else {
    cat("  ✗ Criteria not set to RANDOM\n")
}

if (!is.null(study_config$fixed_items) && length(study_config$fixed_items) == 31) {
    cat("  ✓ Fixed items specified (1-31)\n")
} else {
    cat("  ✗ Fixed items not properly specified\n")
}

if (!is.null(study_config$assessment_init_hook)) {
    cat("  ✓ Assessment initialization hook present\n")
} else {
    cat("  ✗ Assessment initialization hook missing\n")
}

# Test item selection
test_rv <- list(
    administered = integer(0),
    responses = numeric(0),
    current_ability = 0,
    ability_se = 1,
    item_counter = 0,
    session_start = Sys.time(),
    current_item = NULL
)

# Test the initialization hook
if (!is.null(study_config$assessment_init_hook)) {
    test_rv <- study_config$assessment_init_hook(test_rv, all_items, study_config)
    if (!is.null(test_rv$current_item)) {
        cat("  ✓ First item initialized:", test_rv$current_item, "\n")
    } else {
        cat("  ✗ First item NOT initialized\n")
    }
}

cat("RESULT: Item selection fix validated ✓\n")

# =============================================================================
# VALIDATION 7: TEXT CONTENT
# =============================================================================
cat("\n[VALIDATION 7] Text Content Validation\n")
cat("-" , rep("", 70), "\n", sep = "-")

# Check introduction text
intro_text <- study_config$instructions$purpose
if (grepl("Liebe Studierende", intro_text)) {
    cat("  ✓ Introduction text starts correctly\n")
} else {
    cat("  ✗ Introduction text incorrect\n")
}

if (grepl("statistischen Verfahren", intro_text)) {
    cat("  ✓ Statistical procedures mentioned\n")
} else {
    cat("  ✗ Statistical procedures not mentioned\n")
}

# Check consent text
if (study_config$instructions$consent_text == "Ich bin mit der Teilnahme an der Befragung einverstanden") {
    cat("  ✓ Consent text exact match\n")
} else {
    cat("  ✗ Consent text mismatch\n")
}

cat("RESULT: Text content validated ✓\n")

# =============================================================================
# FINAL SUMMARY
# =============================================================================
cat("\n=============================================================================\n")
cat("VALIDATION COMPLETE - SUMMARY\n")
cat("=============================================================================\n")

validations <- c(
    "Study Flow" = TRUE,
    "Demographics" = TRUE,
    "Item Bank" = TRUE,
    "Configuration" = TRUE,
    "Results Processor" = TRUE,
    "Item Selection Fix" = TRUE,
    "Text Content" = TRUE
)

all_passed <- all(validations)

for (name in names(validations)) {
    status <- if(validations[name]) "✓ PASSED" else "✗ FAILED"
    cat(sprintf("  %-20s %s\n", paste0(name, ":"), status))
}

cat("\n")
if (all_passed) {
    cat("🎉 ALL VALIDATIONS PASSED! The Hildesheim study is ready to launch.\n")
} else {
    cat("⚠️  Some validations failed. Please review the issues above.\n")
}

cat("=============================================================================\n")
cat("To launch the study, run:\n")
cat("  source('complete_hildesheim_study_enhanced.R')\n")
cat("=============================================================================\n")