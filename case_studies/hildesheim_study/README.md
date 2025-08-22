# HilFo Studie - Hildesheimer Forschungsmethoden Studie

## Overview
Complete implementation of the Hildesheim research methods study with 31 items across multiple psychological constructs.

## Features
- **31 Items Total**:
  - 20 BFI personality items (Big Five)
  - 5 PSQ stress items
  - 4 MWS study skills items
  - 2 Statistics self-efficacy items

- **Complete Demographics** (16 variables):
  - Consent, Age, Study program, Gender
  - Living situation, Pets, Smoking, Nutrition
  - English/Math grades, Study satisfaction
  - Personal code

- **Data Storage**:
  - Local CSV file with all 48+ variables
  - Cloud backup to WebDAV server
  - SPSS-compatible variable names

- **Visualizations**:
  - Radar plot for Big Five personality profile
  - Bar chart for all dimensions
  - Detailed score table with interpretations

## Usage

```r
source("case_studies/hildesheim_study/hildesheim_production.R")
```

## Data Output

### Variable Names (SPSS Compatible)
- Demographics: `Einverständnis`, `Alter_VPN`, `Studiengang`, etc.
- BFI Items: `BFE_01-04`, `BFV_01-04`, `BFG_01-04`, `BFN_01-04`, `BFO_01-04`
- PSQ Items: `PSQ_02`, `PSQ_04`, `PSQ_16`, `PSQ_29`, `PSQ_30`
- MWS Items: `MWS_1_KK`, `MWS_10_KK`, `MWS_17_KK`, `MWS_21_KK`
- Statistics: `Statistik_gutfolgen`, `Statistik_selbstwirksam`

### File Locations
- **Local**: `study_data/hilfo_[timestamp]/results.csv`
- **Cloud**: Automatically uploaded to configured WebDAV server

## Configuration

The study uses:
- Theme: `hildesheim` (red color scheme #e8041c)
- Language: German (`de`)
- Response type: Radio buttons with 5-point Likert scale
- Progress bar display
- Non-adaptive mode (all 31 items presented)

## Requirements
- R packages: `inrep`, `ggplot2`, `dplyr`, `base64enc`
- WebDAV credentials for cloud storage (optional)

## Authors
Developed for the Psychology Department at University of Hildesheim.