# =============================================================================
# EXAMPLE: Fixing UMA Study 7-Point Scale Issue
# =============================================================================

# This example shows how to fix the ResponseCategories mismatch in the UMA study
# and demonstrates the new flexible response label system.

library(inrep)

# =============================================================================
# PROBLEM: UMA Study has ResponseCategories = "1,2,3,4,5" but uses 7-point scale
# =============================================================================

# Original UMA item bank (problematic)
uma_items_original <- data.frame(
    id = paste0("Item_", sprintf("%02d", 1:5)),
    Question = c(
        "Ich kann gut einschätzen, wie viel Zeit ich für ein Beratungsgespräch mit den UMA einplanen sollte.",
        "Ich kann gut einschätzen, wie häufig Beratungsgespräche mit den UMA sinnvoll sind.",
        "Ich habe eine klare Vorstellung davon, welche räumlichen Bedingungen für Beratungen mit den UMA geeignet sind.",
        "Ich kann einschätzen, welche Einflüsse meine nonverbale Kommunikation auf Beratungsgespräche haben kann.",
        "Ich habe einen Überblick darüber, was ich beeinflussen kann und was nicht."
    ),
    ResponseCategories = "1,2,3,4,5",  # ❌ PROBLEM: Only 5 points but study uses 7-point scale
    b = rep(0, 5),
    a = rep(1, 5),
    stringsAsFactors = FALSE
)

# =============================================================================
# SOLUTION 1: Use the new helper functions
# =============================================================================

# Fix the ResponseCategories to match the 7-point scale
uma_items_fixed <- update_item_bank_scale(uma_items_original, 7)
print("Fixed ResponseCategories:")
print(uma_items_fixed$ResponseCategories[1])

# =============================================================================
# SOLUTION 2: Manual fix
# =============================================================================

# Or manually set the ResponseCategories
uma_items_manual <- uma_items_original
uma_items_manual$ResponseCategories <- generate_response_categories(7)
print("Manual fix ResponseCategories:")
print(uma_items_manual$ResponseCategories[1])

# =============================================================================
# DEMONSTRATION: New Response Label System
# =============================================================================

# Test different scale sizes
cat("\n=== RESPONSE LABEL DEMONSTRATIONS ===\n")

# 7-point scale (German)
cat("\n7-Point Scale (German):\n")
choices_7 <- 1:7
labels_7 <- get_response_labels("likert", choices_7, "de")
for (i in 1:7) {
    cat(sprintf("%d: %s\n", choices_7[i], labels_7[i]))
}

# 10-point scale (English)
cat("\n10-Point Scale (English):\n")
choices_10 <- 1:10
labels_10 <- get_response_labels("likert", choices_10, "en")
for (i in 1:10) {
    cat(sprintf("%d: %s\n", choices_10[i], labels_10[i]))
}

# 20-point scale (German)
cat("\n20-Point Scale (German):\n")
choices_20 <- 1:20
labels_20 <- get_response_labels("likert", choices_20, "de")
for (i in c(1, 5, 10, 15, 20)) {
    cat(sprintf("%d: %s\n", choices_20[i], labels_20[i]))
}

# =============================================================================
# DEMONSTRATION: Different Scale Types
# =============================================================================

cat("\n=== DIFFERENT SCALE TYPES ===\n")

# Difficulty scale (7-point)
cat("\n7-Point Difficulty Scale (German):\n")
labels_difficulty <- get_response_labels("difficulty", 1:7, "de")
for (i in 1:7) {
    cat(sprintf("%d: %s\n", i, labels_difficulty[i]))
}

# Frequency scale (5-point)
cat("\n5-Point Frequency Scale (English):\n")
labels_frequency <- get_response_labels("frequency", 1:5, "en")
for (i in 1:5) {
    cat(sprintf("%d: %s\n", i, labels_frequency[i]))
}

# =============================================================================
# DEMONSTRATION: Custom Labels
# =============================================================================

cat("\n=== CUSTOM LABELS ===\n")

# Custom labels for a 7-point scale
custom_labels <- c("Sehr schlecht", "Schlecht", "Eher schlecht", "Neutral", 
                   "Eher gut", "Gut", "Sehr gut")
labels_custom <- get_response_labels("likert", 1:7, "de", custom_labels)
for (i in 1:7) {
    cat(sprintf("%d: %s\n", i, labels_custom[i]))
}

# =============================================================================
# COMPLETE UMA STUDY FIX
# =============================================================================

cat("\n=== COMPLETE UMA STUDY FIX ===\n")

# Create a complete UMA item bank with proper 7-point scale
uma_items_complete <- data.frame(
    id = paste0("Item_", sprintf("%02d", 1:30)),
    Question = c(
        # Sample questions (shortened for example)
        "Ich kann gut einschätzen, wie viel Zeit ich für ein Beratungsgespräch mit den UMA einplanen sollte.",
        "Ich kann gut einschätzen, wie häufig Beratungsgespräche mit den UMA sinnvoll sind.",
        "Ich habe eine klare Vorstellung davon, welche räumlichen Bedingungen für Beratungen mit den UMA geeignet sind.",
        "Ich kann einschätzen, welche Einflüsse meine nonverbale Kommunikation auf Beratungsgespräche haben kann.",
        "Ich habe einen Überblick darüber, was ich beeinflussen kann und was nicht."
    ),
    ResponseCategories = generate_response_categories(7),  # ✅ FIXED: Proper 7-point scale
    b = rep(0, 5),
    a = rep(1, 5),
    stringsAsFactors = FALSE
)

# Verify the fix
cat("UMA Study ResponseCategories (FIXED):\n")
print(uma_items_complete$ResponseCategories[1])

# Test the labels that will be used
cat("\nLabels that will be displayed in the UMA study:\n")
uma_labels <- get_response_labels("likert", 1:7, "de")
for (i in 1:7) {
    cat(sprintf("%d: %s\n", i, uma_labels[i]))
}

cat("\n✅ UMA Study is now ready with proper 7-point scale!\n")