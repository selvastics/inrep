# Debug script to check response collection

library(inrep)

# Load the Hildesheim study components
source("hildesheim_complete.R")

# Check the item bank structure
cat("\n=== ITEM BANK STRUCTURE ===\n")
cat("Total items:", nrow(all_items), "\n")
cat("Item IDs:\n")
print(all_items$id)

# Check the custom page flow
cat("\n=== PAGE FLOW ===\n")
for (i in seq_along(custom_page_flow)) {
  page <- custom_page_flow[[i]]
  cat(sprintf("Page %d: %s (type: %s)\n", i, page$title, page$type))
  if (page$type == "items" && !is.null(page$item_indices)) {
    cat("  Item indices:", paste(page$item_indices, collapse=", "), "\n")
    # Show which items are on this page
    for (idx in page$item_indices) {
      if (idx <= nrow(all_items)) {
        cat(sprintf("    Item %d: id=%s\n", idx, all_items$id[idx]))
      }
    }
  }
}

# Test the results processor with dummy data
cat("\n=== TESTING RESULTS PROCESSOR ===\n")
test_responses <- rep(3, 31)  # All middle responses
cat("Testing with", length(test_responses), "responses\n")
result <- create_hilfo_report(test_responses, all_items)
cat("Result generated:", !is.null(result), "\n")

cat("\n=== EXPECTED INPUT IDS ===\n")
cat("Items will have input IDs like:\n")
for (i in 1:5) {
  cat(sprintf("  item_%s\n", all_items$id[i]))
}

cat("\nDone!\n")