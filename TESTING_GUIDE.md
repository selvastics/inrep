# inrep Package Testing Guide

## Quick Start Testing

### Prerequisites
Ensure you have R installed with the following packages:
```r
install.packages(c("shiny", "DT", "ggplot2", "dplyr", "shinyWidgets", "later", "httr", "jsonlite"))
# Optional: install.packages("ggradar") for enhanced radar plots
# Optional: install.packages("TAM") only if using adaptive mode
```

### Installation
```r
# Install from GitHub (if published)
# devtools::install_github("selvastics/inrep")

# Or load locally
setwd("/workspace")  # or your project directory
source("R/launch_study.R")
source("R/create_study_config.R")
source("R/custom_page_flow.R")
source("R/custom_page_flow_validation.R")
```

### Running the Hildesheim Study

```r
# Load the package
library(inrep)

# Source the Hildesheim study
source("case_studies/hildesheim_study/hildesheim_production.R")

# The study should launch automatically in your browser
```

## Testing Checklist

### 1. Performance Testing
- [ ] **First Page Load**: Should display immediately (under 200ms)
- [ ] **Console Output**: Should show "Immediate first page display" message
- [ ] **Package Loading**: TAM should NOT load unless adaptive mode is enabled
- [ ] **Deferred Loading**: Other packages should load after first page render

### 2. Data Collection (48 Variables)
Verify all variables are collected:

#### Demographics (17 variables)
- [ ] Einverständnis (Consent checkbox)
- [ ] Alter_VPN (Age)
- [ ] Studiengang (Study program)
- [ ] Geschlecht (Gender)
- [ ] Wohnstatus (Living situation)
- [ ] Wohn_Zusatz (Living additional text)
- [ ] Haustier (Pet preference)
- [ ] Haustier_Zusatz (Pet additional text)
- [ ] Rauchen (Smoking)
- [ ] Ernährung (Diet)
- [ ] Ernährung_Zusatz (Diet additional text)
- [ ] Note_Englisch (English grade)
- [ ] Note_Mathe (Math grade)
- [ ] Vor_Nachbereitung (Study preparation hours)
- [ ] Zufrieden_Hi_5st (5-point satisfaction)
- [ ] Zufrieden_Hi_7st (7-point satisfaction)
- [ ] Persönlicher_Code (Personal code)

#### Questionnaire Items (31 variables)
- [ ] BFE_01 to BFE_04 (Extraversion - 4 items)
- [ ] BFV_01 to BFV_04 (Agreeableness - 4 items)
- [ ] BFG_01 to BFG_04 (Conscientiousness - 4 items)
- [ ] BFN_01 to BFN_04 (Neuroticism - 4 items)
- [ ] BFO_01 to BFO_04 (Openness - 4 items)
- [ ] PSQ_02, PSQ_04, PSQ_16, PSQ_29, PSQ_30 (Stress - 5 items)
- [ ] MWS_1_KK, MWS_10_KK, MWS_17_KK, MWS_21_KK (Study skills - 4 items)
- [ ] Statistik_gutfolgen, Statistik_selbstwirksam (Statistics - 2 items)

### 3. User Interface
- [ ] **No Emojis**: Verify no emojis appear anywhere in the interface
- [ ] **Red Banner**: Check report header is solid #e8041c (no gradient)
- [ ] **Instructions Page**: First page shows instructions with integrated consent checkbox
- [ ] **Page Transitions**: Smooth transitions without blinking or jumping
- [ ] **No Page Refresh**: Navigation doesn't cause page to refresh or jump to top

### 4. Validation
- [ ] **Consent Required**: Cannot proceed without checking consent
- [ ] **Required Fields**: Required demographics show error if not filled
- [ ] **Checkbox Validation**: Checkbox never receives NA/NULL values
- [ ] **Error Messages**: All validation errors in German

### 5. Report Generation
- [ ] **Radar Plot**: Uses ggradar with light red fill and proper connections
- [ ] **Bar Charts**: All dimensions displayed with correct colors
- [ ] **Item Details**: Shows individual item responses, not just aggregates
- [ ] **Score Calculation**: Proper reverse coding for BFI items
- [ ] **All Visualizations**: Use ggplot2 (NOT plotly)

### 6. Download Functions
- [ ] **PDF Download**: Click "Als PDF speichern" - should save directly (no print dialog)
- [ ] **CSV Download**: Default inrep buttons work correctly
- [ ] **File Names**: Include timestamp and study identifier

### 7. Cloud Storage
- [ ] **Automatic Upload**: Data uploads to WebDAV after completion
- [ ] **Credentials**: Uses inrep_test / inreptest
- [ ] **URL**: Uploads to https://sync.academiccloud.de/remote.php/dav/files/inrep_test/
- [ ] **Format**: CSV with all 48 variables plus calculated scores

### 8. Console Output
Verify clean output without decorative symbols:
```
Expected output:
Immediate first page display
Deferred package loading
Working CSV/PDF downloads
Automatic cloud upload to inrep_test
```

## Common Issues and Solutions

### Issue: First page loads slowly
**Solution**: Check that `fast_mode = TRUE` in study_config and `defer_packages = TRUE`

### Issue: TAM package loads unnecessarily
**Solution**: Ensure `adaptive = FALSE` in study_config for non-adaptive studies

### Issue: Page jumps or refreshes
**Solution**: Session monitoring should be event-based, not timer-based

### Issue: PDF download not working
**Solution**: Check browser console for jsPDF errors, ensure library is loaded

### Issue: Checkbox validation fails
**Solution**: Validation should use `isTRUE()` to handle checkbox values properly

### Issue: Cloud upload fails
**Solution**: Check WebDAV URL format and credentials, ensure httr package is available

## Manual Testing Script

For comprehensive testing, run through this sequence:

1. Start the study
2. Verify immediate page load
3. Read instructions and check consent
4. Fill in all demographics (test both required and optional)
5. Complete all questionnaire items
6. Review the results page
7. Test PDF download
8. Test CSV download
9. Check cloud storage for uploaded file
10. Verify no visual glitches throughout

## Automated Testing (if available)

```r
# Run package tests
testthat::test_dir("tests/")

# Validate configuration
config <- create_study_config(
  name = "Test Study",
  fast_mode = TRUE,
  defer_packages = TRUE
)
validate_study_config(config)
```

## Performance Benchmarks

Expected performance metrics:
- First page render: < 200ms
- Package loading completion: < 2s
- Page transitions: < 100ms
- PDF generation: < 3s
- Cloud upload: < 5s (depends on connection)

## Support

For issues or questions about the inrep package:
- Check the package documentation
- Review CONTRIBUTING.md for development guidelines
- Consult README.md for general information