#!/bin/bash

# CRAN Compliance Validation Script for inrep Package
# This script checks for common CRAN compliance issues

echo "========================================="
echo "CRAN Compliance Validation for inrep"
echo "========================================="
echo ""

# Check for emoji/icons in R files
echo "1. Checking for emoji/icons in R files..."
if grep -r "[\U0001F300-\U0001F9FF]" R/*.R 2>/dev/null; then
    echo "   WARNING: Emoji found in R files"
else
    echo "   PASS: No emoji in R files"
fi

# Check for emoji/icons in documentation
echo ""
echo "2. Checking for emoji/icons in documentation..."
if grep -r "[\U0001F300-\U0001F9FF]" man/*.Rd 2>/dev/null; then
    echo "   WARNING: Emoji found in documentation"
else
    echo "   PASS: No emoji in documentation"
fi

# Check for proper roxygen2 documentation
echo ""
echo "3. Checking for roxygen2 documentation..."
undocumented=0
for file in R/enhanced_*.R; do
    if [ -f "$file" ]; then
        if ! grep -q "^#' @" "$file"; then
            echo "   WARNING: $file may lack proper roxygen2 documentation"
            undocumented=$((undocumented + 1))
        fi
    fi
done
if [ $undocumented -eq 0 ]; then
    echo "   PASS: All enhanced files have roxygen2 documentation"
fi

# Check NAMESPACE for exports
echo ""
echo "4. Checking NAMESPACE for new exports..."
if grep -q "export(initialize_enhanced_recovery)" NAMESPACE && \
   grep -q "export(initialize_enhanced_security)" NAMESPACE && \
   grep -q "export(initialize_performance_optimization)" NAMESPACE; then
    echo "   PASS: New functions exported in NAMESPACE"
else
    echo "   WARNING: Some new functions may not be exported"
fi

# Check for console output in functions
echo ""
echo "5. Checking for inappropriate console output..."
console_output=0
for file in R/enhanced_*.R; do
    if [ -f "$file" ]; then
        if grep -q "^[^#]*cat(" "$file" || grep -q "^[^#]*print(" "$file"; then
            echo "   WARNING: $file contains direct console output"
            console_output=$((console_output + 1))
        fi
    fi
done
if [ $console_output -eq 0 ]; then
    echo "   PASS: No inappropriate console output"
fi

# Check for global variables
echo ""
echo "6. Checking for global variable assignments..."
if grep -r "<<-" R/*.R | grep -v "^#"; then
    echo "   WARNING: Global assignments (<<-) found"
else
    echo "   PASS: No problematic global assignments"
fi

# Check for proper error handling
echo ""
echo "7. Checking for proper error handling..."
if grep -q "tryCatch" R/enhanced_*.R && grep -q "error = function" R/enhanced_*.R; then
    echo "   PASS: Error handling implemented"
else
    echo "   WARNING: Consider adding more error handling"
fi

# Check for test coverage
echo ""
echo "8. Checking test coverage..."
if [ -f "tests/testthat/test-enhanced-features.R" ]; then
    test_count=$(grep -c "^test_that" tests/testthat/test-enhanced-features.R)
    echo "   PASS: Found $test_count tests for enhanced features"
else
    echo "   WARNING: No tests found for enhanced features"
fi

# Check DESCRIPTION file
echo ""
echo "9. Checking DESCRIPTION file..."
if grep -q "^Version:" DESCRIPTION && \
   grep -q "^License:" DESCRIPTION && \
   grep -q "^Description:" DESCRIPTION; then
    echo "   PASS: DESCRIPTION file appears complete"
else
    echo "   WARNING: DESCRIPTION file may be incomplete"
fi

# Check for non-ASCII characters
echo ""
echo "10. Checking for non-ASCII characters..."
non_ascii=0
for file in R/*.R; do
    if [ -f "$file" ]; then
        if file "$file" | grep -q "ASCII"; then
            :
        else
            echo "   WARNING: $file contains non-ASCII characters"
            non_ascii=$((non_ascii + 1))
        fi
    fi
done
if [ $non_ascii -eq 0 ]; then
    echo "   PASS: All R files are ASCII"
fi

echo ""
echo "========================================="
echo "Validation Complete"
echo "========================================="
echo ""
echo "Note: This is a basic check. Run 'R CMD check' for complete validation."
echo "To ensure full CRAN compliance:"
echo "  1. Run: R CMD build ."
echo "  2. Run: R CMD check inrep_*.tar.gz --as-cran"
echo "  3. Fix any NOTEs, WARNINGs, or ERRORs"
echo ""