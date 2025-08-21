# INREP PACKAGE MODIFICATIONS NEEDED FOR HILDESHEIM STUDY

## OVERVIEW
The current `inrep` package has a hardcoded flow that prevents the Hildesheim study from following the exact order: **Instructions → Demographics → Questionnaire**. This document outlines the specific changes needed in the package to support the exact 11-page structure.

## CURRENT PROBLEM
The `inrep` package ignores the `show_introduction`, `show_consent`, and `show_briefing` parameters and hardcodes the flow to start with demographics. The package needs to be modified to support custom phase sequences that match the exact Hildesheim questionnaire structure.

## EXACT HILDESHEIM STRUCTURE REQUIRED
The study must follow this exact 11-page order with correct variable positions:

1. **Einleitungstext** (Introduction/Instructions) - Consent and study information
2. **Soziodemo** (Demographics) - Age, study program, gender, living situation, pet, smoking, diet
3. **Filter** (Conditional section for Bachelor/Master students)
4. **Bildung** (Education: English/Math grades)
5. **BFI-2 und PSQ** (Personality and Stress items - 25 total items)
6. **MWS** (Study skills - 4 items)
7. **Mitkommen Statistik** (Statistics self-efficacy - 2 items)
8. **Stunden pro Woche** (Study hours planning - 6 options)
9. **Zufriedenheit Studienort** (Satisfaction with Hildesheim - 5-point scale)
10. **Zufriedenheit Studienort** (Satisfaction with Hildesheim - 7-point scale)
11. **Code** (Personal code generation)
12. **Ende** (End/Completion message)
13. **Endseite** (Final page with comprehensive reports)

### VARIABLE POSITIONS (CRITICAL)
**Demographics (Positions 1-13):**
- Position 1: Einverständnis (Consent)
- Position 2: Alter_VPN (Age)
- Position 3: Studiengang (Study Program)
- Position 4: Geschlecht (Gender)
- Position 5: Wohnstatus (Living Situation)
- Position 6: Wohn_Zusatz (Living Additional)
- Position 7: Haustier (Pet)
- Position 8: Haustier_Zusatz (Pet Additional)
- Position 9: Rauchen (Smoking)
- Position 10: Ernährung (Diet)
- Position 11: Ernährung_Zusatz (Diet Additional)
- Position 12: Note_Englisch (English Grade)
- Position 13: Note_Mathe (Math Grade)
- Position 45: Vor_Nachbereitung (Study Preparation)
- Position 46: Zufrieden_Hi_5st (Satisfaction 5-point)
- Position 47: Zufrieden_Hi_7st (Satisfaction 7-point)
- Position 48: Persönlicher_Code (Personal Code)

**Questionnaire Items (Positions 14-44):**
- Positions 14-33: BFI-2 Personality Items (20 items)
- Positions 34-38: PSQ Stress Items (5 items)
- Positions 39-42: MWS Study Skills Items (4 items)
- Positions 43-44: Statistics Self-Efficacy Items (2 items)

### MEASUREMENT LEVELS AND MISSING VALUES
- **Nominal variables**: Einverständnis, Studiengang, Geschlecht, Wohnstatus, Wohn_Zusatz, Haustier, Haustier_Zusatz, Rauchen, Ernährung, Ernährung_Zusatz, Persönlicher_Code
- **Ordinal variables**: Alter_VPN, Note_Englisch, Note_Mathe, Vor_Nachbereitung
- **Scale variables**: BFI-2 items, PSQ items, MWS items, Statistics items, Zufrieden_Hi_5st, Zufrieden_Hi_7st
- **Missing value code**: -77 (for most variables)

## COMPREHENSIVE REPORT GENERATION IMPLEMENTED

The Hildesheim study script now includes comprehensive report generation capabilities:

### Individual Level Reports
- **BFI-2 Radar Plot**: Radar chart showing all 5 personality dimensions (Extraversion, Agreeableness, Conscientiousness, Neuroticism, Openness)
- **PSQ Stress Plot**: Bar chart showing individual stress item scores and total stress level
- **MWS Study Skills Plot**: Bar chart showing study skills item scores and total study skills level
- **Statistics Confidence Plot**: Bar chart showing statistics self-efficacy item scores and total confidence level

### Population Level Reports
- **Aggregated Results**: Summary statistics across all participants
- **Demographic Breakdowns**: Analysis by age, study program, gender, etc.
- **Trend Analysis**: Longitudinal patterns and comparisons

### Technical Implementation
- **Score Calculation**: Proper reverse-coding for BFI-2 items based on established psychometric protocols
- **Visualization Engine**: Professional-grade plots using ggplot2 with consistent theming
- **Export Options**: Multiple formats (PDF, HTML, CSV, RDS) for research and reporting needs
- **Recommendations Engine**: Personalized feedback based on individual scores

## REQUIRED CHANGES

### 1. MODIFY R/launch_study.R

#### Change 1: Initial Stage Control (Line ~1249)
**Current Code:**
```r
rv <- shiny::reactiveValues(
  demo_data = stats::setNames(base::rep(NA, base::length(config$demographics)), config$demographics),
  stage = "demographics",  # ← HARDCODED TO DEMOGRAPHICS
  # ... other reactive values
)
```

**Required Change:**
```r
rv <- shiny::reactiveValues(
  demo_data = stats::setNames(base::rep(NA, base::length(config$demographics)), config$demographics),
  stage = ifelse(config$start_with_instructions %||% FALSE, "instructions", "demographics"),
  # ... other reactive values
)
```

#### Change 2: Add Phase Order Configuration Support
**Add to create_study_config parameters:**
```r
start_with_instructions = FALSE,
phase_sequence = c("instructions", "demographics", "filter", "education", "assessment", "results"),
custom_page_flow = list(
  page_1 = "instructions",
  page_2 = "demographics", 
  page_3 = "filter",
  page_3_1 = "education",
  page_4 = "bfi_psq",
  page_5 = "mws",
  page_6 = "statistics",
  page_7 = "study_hours",
  page_8_1 = "satisfaction_5pt",
  page_8_2 = "satisfaction_7pt",
  page_9 = "personal_code",
  page_10 = "completion",
  page_11 = "final"
)
```

**Add to launch_study function:**
```r
# Respect phase sequence configuration
if (!is.null(config$phase_sequence) && length(config$phase_sequence) > 0) {
  rv$phase_sequence <- config$phase_sequence
  rv$current_phase_index <- 1
  rv$stage <- config$phase_sequence[1]
} else {
  # Default behavior
  rv$stage <- ifelse(config$start_with_instructions %||% FALSE, "instructions", "demographics")
}

# Initialize custom page flow
if (!is.null(config$custom_page_flow)) {
  rv$custom_page_flow <- config$custom_page_flow
  rv$current_page <- 1
  rv$current_subpage <- NULL
}
```

#### Change 3: Add Page-Based Navigation Logic
**Add new function for page transitions:**
```r
advance_to_next_page <- function(rv, config) {
  if (!is.null(rv$custom_page_flow)) {
    current_page <- rv$current_page
    next_page <- current_page + 1
    
    if (next_page <= length(rv$custom_page_flow)) {
      rv$current_page <- next_page
      rv$stage <- rv$custom_page_flow[[paste0("page_", next_page)]]
      return(TRUE)
    }
  }
  return(FALSE)
}

handle_subpage_navigation <- function(rv, config, subpage) {
  if (!is.null(rv$custom_page_flow)) {
    rv$current_subpage <- subpage
    rv$stage <- rv$custom_page_flow[[paste0("page_", rv$current_page, "_", subpage)]]
    return(TRUE)
  }
  return(FALSE)
}
```

#### Change 4: Modify Phase Transitions for Hildesheim Flow
**Update existing phase transitions:**
```r
# In demographics completion handler
shiny::observeEvent(input$start_test, {
  # ... existing code ...
  
  # Use new page-based navigation
  if (!advance_to_next_page(rv, config)) {
    rv$stage <- "filter"  # Go to filter page
  }
  
  # ... rest of existing code ...
})

# In filter completion handler
shiny::observeEvent(input$filter_continue, {
  # ... existing code ...
  
  # Navigate to education subpage
  handle_subpage_navigation(rv, config, "1")
  
  # ... rest of existing code ...
})

# In education completion handler
shiny::observeEvent(input$education_continue, {
  # ... existing code ...
  
  # Navigate to assessment (BFI-2 and PSQ)
  if (!advance_to_next_page(rv, config)) {
    rv$stage <- "assessment"
  }
  
  # ... rest of existing code ...
})
```

### 2. MODIFY R/complete_ui.R

#### Change 1: Add Page-Aware UI Rendering
**Modify the UI rendering to respect the current page:**
```r
# In the main UI function
shiny::div(class = "min-h-screen bg-white text-black flex items-center justify-center",
  shiny::div(class = "assessment-card max-w-lg w-full",
    # Use rv$current_page and rv$current_subpage for navigation
    shiny::conditionalPanel(
      condition = "input.current_page == 1",
      # Page 1: Instructions
      render_instructions_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 2",
      # Page 2: Demographics
      render_demographics_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 3 && input.current_subpage == null",
      # Page 3: Filter
      render_filter_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 3 && input.current_subpage == 1",
      # Page 3.1: Education
      render_education_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 4",
      # Page 4: BFI-2 and PSQ
      render_bfi_psq_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 5",
      # Page 5: MWS
      render_mws_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 6",
      # Page 6: Statistics
      render_statistics_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 7",
      # Page 7: Study Hours
      render_study_hours_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 8 && input.current_subpage == 1",
      # Page 8.1: Satisfaction 5-point
      render_satisfaction_5pt_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 8 && input.current_subpage == 2",
      # Page 8.2: Satisfaction 7-point
      render_satisfaction_7pt_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 9",
      # Page 9: Personal Code
      render_personal_code_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 10",
      # Page 10: Completion
      render_completion_page(rv, config)
    ),
    shiny::conditionalPanel(
      condition = "input.current_page == 11",
      # Page 11: Final
      render_final_page(rv, config)
    )
  )
)
```

#### Change 2: Add Page-Specific UI Functions
**Create specialized rendering functions for each page:**
```r
render_instructions_page <- function(rv, config) {
  # Render the exact Einleitungstext content
  shiny::div(
    class = "instructions-page",
    shiny::h2("Einleitungstext", class = "page-title"),
    shiny::div(
      class = "instructions-content",
      shiny::p("Liebe Studierende,"),
      shiny::p("In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, die von Ihnen selbst stammen..."),
      # ... rest of exact content
    ),
    shiny::div(
      class = "consent-section",
      shiny::radioButtons("consent", "Ich bin mit der Teilnahme an der Befragung einverstanden", 
                         choices = c("Ja", "Nein"), selected = character(0)),
      shiny::actionButton("consent_continue", "Weiter", class = "btn-primary")
    )
  )
}

render_demographics_page <- function(rv, config) {
  # Render all demographic questions in exact order
  shiny::div(
    class = "demographics-page",
    shiny::h2("Soziodemo", class = "page-title"),
    shiny::p("Zunächst bitten wir Sie um ein paar allgemeine Angaben zu sich selbst."),
    # ... render all demographic questions
  )
}

# ... similar functions for other pages
```

### 3. MODIFY R/create_study_config.R

#### Change 1: Add New Configuration Parameters
**Add to function signature:**
```r
create_study_config <- function(
  # ... existing parameters ...
  start_with_instructions = FALSE,
  phase_sequence = NULL,
  custom_page_flow = NULL,
  page_configs = NULL,
  # ... rest of existing parameters ...
) {
  # ... existing code ...
  
  # Validate custom page flow
  if (!is.null(custom_page_flow)) {
    valid_pages <- c("instructions", "demographics", "filter", "education", "bfi_psq", 
                     "mws", "statistics", "study_hours", "satisfaction_5pt", 
                     "satisfaction_7pt", "personal_code", "completion", "final")
    
    for (page_name in names(custom_page_flow)) {
      if (!custom_page_flow[[page_name]] %in% valid_pages) {
        stop("Invalid page type in custom_page_flow: ", custom_page_flow[[page_name]])
      }
    }
  }
  
  # ... existing code ...
  
  # Return configuration with new parameters
  list(
    # ... existing configuration ...
    start_with_instructions = start_with_instructions,
    phase_sequence = phase_sequence,
    custom_page_flow = custom_page_flow,
    page_configs = page_configs,
    # ... rest of existing configuration ...
  )
}
```

## IMPLEMENTATION PRIORITY

### HIGH PRIORITY (Required for Hildesheim Study)
1. **Page-Based Navigation** - Support exact 11-page structure
2. **Custom Page Flow** - Allow custom page sequences
3. **Page-Specific UI Rendering** - Render different content for each page
4. **Subpage Support** - Handle page 3.1 (education) and 8.1/8.2 (satisfaction scales)

### MEDIUM PRIORITY (Enhancement)
1. **Dynamic Page Transitions** - Support conditional page skipping
2. **Page Validation** - Ensure page sequences are valid
3. **Backward Compatibility** - Maintain existing behavior for studies without custom pages

### LOW PRIORITY (Future Enhancement)
1. **Page Templates** - Predefined page sequences for common study types
2. **Conditional Pages** - Skip pages based on participant responses
3. **Page Analytics** - Track time spent on each page

## TESTING REQUIREMENTS

### Unit Tests
- Test `custom_page_flow` parameter functionality
- Test page navigation logic
- Test subpage handling
- Test backward compatibility

### Integration Tests
- Test complete Hildesheim study flow with exact 11-page structure
- Test page transitions and navigation
- Test UI rendering for all pages and subpages

### User Acceptance Tests
- Verify Hildesheim study follows exact 11-page order
- Verify all demographic questions display with correct labels and options
- Verify questionnaire items appear in correct order: BFI-2 → PSQ → MWS → Statistics
- Verify satisfaction scales use correct point scales (5-point vs 7-point)
- Verify personal code generation works correctly

## BACKWARD COMPATIBILITY

All changes must maintain backward compatibility:
- Studies without `custom_page_flow` should work exactly as before
- Default behavior should remain: demographics → assessment → results
- Existing configuration parameters should continue to work

## DEPLOYMENT CONSIDERATIONS

1. **Version Bump** - Increment package version to reflect breaking changes
2. **Documentation Update** - Update all relevant documentation and examples
3. **Migration Guide** - Provide guidance for existing studies
4. **Testing Period** - Allow time for testing before production deployment

## CONCLUSION

These modifications will enable the `inrep` package to support the exact 11-page questionnaire structure required by the Hildesheim study while maintaining flexibility for other research needs. The changes are focused on page-based navigation and maintainable, ensuring the package remains robust and user-friendly for future studies.
