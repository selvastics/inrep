# Hildesheim University Study Case Study

## Overview

This comprehensive case study implements a complete psychological assessment study for University of Hildesheim, featuring Big Five personality assessment, stress questionnaire (PSQ), academic motivation (MWS), and detailed demographic data collection. The study uses the official Hildesheim theme and cloud storage integration.

## Study Description

### Study Components
- **Demographics**: Comprehensive demographic data collection (13 variables)
- **Big Five Personality**: 20 BFI items across all five dimensions  
- **Perceived Stress Questionnaire (PSQ)**: 5 stress-related items
- **Academic Motivation Scale (MWS)**: 4 items on contact and cooperation
- **Academic Self-Efficacy**: Statistics learning and satisfaction measures
- **Study Behaviors**: Academic engagement and time investment

### Study Design
- **Adaptive Testing**: Items selected based on ability estimates
- **IRT Model**: Graded Response Model (GRM) for polytomous responses
- **Session Duration**: 20-30 minutes
- **Language Support**: German (primary) with English fallback
- **Theme**: Official University of Hildesheim branding

## Files Included

### Core Study Files
- `hildesheim_study_setup.R`: Complete study configuration and setup
- `hildesheim_items.R`: Comprehensive item bank with all measures
- `hildesheim_demographics.R`: Demographics configuration
- `hildesheim_launch.R`: Study launch script with cloud storage
- `hildesheim_analysis.R`: Data analysis and reporting script

### Documentation
- `README.md`: This file - comprehensive study documentation
- `study_variables.md`: Complete variable descriptions and coding
- `methodology.md`: Detailed methodology and psychometric properties

## Quick Start

### 1. Load the Study
```r
# Load the inrep package
library(inrep)

# Source the study setup
source("case_studies/hildesheim_study/hildesheim_study_setup.R")

# Load item bank
source("case_studies/hildesheim_study/hildesheim_items.R")
```

### 2. Launch the Study
```r
# Launch the Hildesheim study
source("case_studies/hildesheim_study/hildesheim_launch.R")
launch_hildesheim_study()
```

### 3. Analyze Results
```r
# Run analysis script
source("case_studies/hildesheim_study/hildesheim_analysis.R")
```

## Study Configuration

### Core Parameters
- **Model**: GRM (Graded Response Model)
- **Estimation Method**: TAM
- **Theme**: Hildesheim (Official university branding)
- **Language**: German (DE)
- **Session Management**: Automatic save/restore
- **Cloud Storage**: Academic Cloud WebDAV integration

### Demographics Collected
All variables from the original study:
- Einverständnis (Consent)
- Alter_VPN (Age)
- Studiengang (Study Program)
- Geschlecht (Gender)
- Wohnstatus (Living Situation)
- Haustier (Preferred Pet)
- Rauchen (Smoking)
- Ernährung (Diet)
- Note_Englisch (English Grade)
- Note_Mathe (Math Grade)
- Plus additional open-text fields

### Assessment Domains

#### Big Five Personality (BFI)
- **Extraversion** (BFE_01-04): 4 items measuring sociability and energy
- **Agreeableness** (BFV_01-04): 4 items measuring interpersonal orientation
- **Conscientiousness** (BFG_01-04): 4 items measuring organization and discipline
- **Neuroticism** (BFN_01-04): 4 items measuring emotional stability
- **Openness** (BFO_01-04): 4 items measuring intellectual curiosity

#### Perceived Stress Questionnaire (PSQ)
- **Time Pressure** (PSQ_02, PSQ_04, PSQ_16, PSQ_29, PSQ_30): 5 items measuring perceived time stress

#### Academic Motivation Scale (MWS)
- **Contact and Cooperation** (MWS_1_KK, MWS_10_KK, MWS_17_KK, MWS_21_KK): 4 items measuring social academic skills

#### Academic Self-Efficacy
- **Statistics Learning** (Statistik_gutfolgen, Statistik_selbstwirksam): 2 items on statistics confidence
- **Study Investment** (Vor_Nachbereitung): Time investment planning
- **Satisfaction** (Zufrieden_Hi_5st, Zufrieden_Hi_7st): Satisfaction with Hildesheim

### Response Scales
- **5-point Likert**: "Stimme überhaupt nicht zu" to "Stimme voll und ganz zu"
- **Specialized scales**: Custom response options for demographics and specific measures

## Advanced Features

### University Branding
- **Official Logo**: University of Hildesheim logo integration
- **Color Scheme**: Official university colors (#e8041c primary)
- **Typography**: Professional academic styling
- **Responsive Design**: Mobile and desktop compatibility

### Cloud Storage Integration
- **Academic Cloud**: Automatic data backup to sync.academiccloud.de
- **Secure Authentication**: Password-protected access
- **Study Key**: Unique identifier for data organization
- **JSON Format**: Structured data for analysis

### Quality Assurance
- **Response Time Monitoring**: Detection of rapid or slow responses
- **Pattern Analysis**: Identification of response sets
- **Completion Tracking**: Progress monitoring and recovery
- **Data Validation**: Real-time validation of responses

## Technical Specifications

### IRT Model Configuration
```r
model = "GRM"                    # Graded Response Model
min_items = 15                   # Minimum items administered
max_items = 35                   # Maximum items administered  
min_SEM = 0.3                    # Stopping criterion
selection_criteria = "MI"        # Maximum Information
```

### Cloud Storage Configuration
```r
webdav_url = "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
password = "inreptest"
study_key = "HILDESHEIM_2025"
```

## Data Output

### Collected Variables
The study collects exactly the variables specified in the original design:
- All demographic variables with proper coding
- All personality items with reverse scoring handled
- All stress and motivation items
- Academic measures and satisfaction ratings
- Complete response time data
- Session metadata

### Analysis Ready
- **CSV Export**: Ready for SPSS/R analysis
- **JSON Format**: For web-based analysis
- **TAM Compatible**: Direct integration with TAM package
- **Recoded Variables**: Automatically computed recoded variables

## Usage Example

```r
# Complete workflow
library(inrep)

# 1. Load study components
source("case_studies/hildesheim_study/hildesheim_study_setup.R")
source("case_studies/hildesheim_study/hildesheim_items.R")
source("case_studies/hildesheim_study/hildesheim_demographics.R")

# 2. Launch study
launch_hildesheim_study()

# 3. Access results (after completion)
results <- load_hildesheim_results()
analyze_hildesheim_data(results)
```

## License and Ethics

### Ethical Compliance
- **Informed Consent**: Comprehensive consent process
- **Data Protection**: GDPR compliant data handling
- **Anonymization**: No personally identifiable information stored
- **Withdrawal Rights**: Participants can withdraw at any time

### Academic Use
- **Research Purpose**: For academic research and statistical education
- **Data Sharing**: Aggregated data only for research purposes
- **Publication**: Results may be used in academic publications
- **Attribution**: University of Hildesheim study protocol

## Support

### Technical Support
- Check package documentation
- Review error logs
- Contact development team
- GitHub issue tracking

### Academic Support  
- Methodology consultation
- Statistical analysis support
- Integration assistance
- Custom modifications

## Version History

- **v1.0**: Initial implementation with complete variable set
- **v1.1**: Enhanced cloud storage and validation
- **v1.2**: Improved user interface and accessibility
- **v2.0**: Full psychometric validation and optimization

## References

- John, O. P., & Srivastava, S. (1999). The Big Five trait taxonomy
- Levenstein, S. et al. (1993). Development of the Perceived Stress Questionnaire
- Wild, K.-P. & Schiefele, U. (1994). Lernstrategien im Studium
- University of Hildesheim Academic Standards and Procedures
