# Rater-Participant Design Case Study

## Overview

This case study demonstrates a sophisticated rater-participant design where multiple raters evaluate participants, with comprehensive linking, reporting, and inter-rater reliability analysis.

## Key Features

### 🔗 **Rater-Participant Linking**
- **Multiple Raters per Participant**: Each participant is evaluated by 2-3 trained raters
- **Balanced Assignments**: Automated assignment system ensures fair distribution
- **Quality Monitoring**: Track rater performance and agreement rates

### 📊 **Inter-Rater Reliability Analysis**
- **ICC Calculations**: Intraclass Correlation Coefficients for single and multiple raters
- **Agreement Tracking**: Monitor consistency across raters
- **Quality Metrics**: Reliability scores and agreement rates for each rater

### 🎯 **Comprehensive Assessment**
- **5 Performance Dimensions**: Communication, Problem-Solving, Technical, Professional, Overall
- **25 Evaluation Items**: Carefully calibrated IRT parameters for GRM model
- **Adaptive Testing**: 15-20 items with SEM < 0.25

### 📈 **Advanced Reporting**
- **Multi-Rater Comparison**: Side-by-side analysis of rater assessments
- **Agreement Analysis**: Identify areas of consensus and disagreement
- **Recommendations**: Personalized feedback based on rater consensus
- **Export Capabilities**: Multiple format support for further analysis

## Study Configuration

```r
rater_participant_config <- create_study_config(
  name = "Inter-Rater Reliability Assessment",
  study_key = "rater_participant_2025",
  model = "GRM",
  max_items = 20,
  min_items = 15,
  min_SEM = 0.25,
  rater_design = TRUE,
  max_raters_per_participant = 3,
  rater_agreement_threshold = 0.7
)
```

## Rater Management System

### Rater Profiles
- **5 Trained Raters**: Expert, Trained, and Novice levels
- **Specialization Areas**: Communication, Problem-Solving, Technical, Professional
- **Quality Metrics**: Reliability scores, agreement rates, last calibration dates

### Rater Types
1. **Expert Raters** (Dr. Smith, Prof. Johnson)
   - 12+ years experience
   - Advanced training level
   - High reliability scores (0.89-0.92)

2. **Trained Raters** (Dr. Williams, Prof. Brown)
   - 6-8 years experience
   - Intermediate training level
   - Good reliability scores (0.82-0.85)

3. **Novice Raters** (Dr. Davis)
   - 2 years experience
   - Basic training level
   - Developing reliability (0.78)

## Assessment Dimensions

### 1. **Communication Skills** (5 items)
- Clear and effective communication
- Appropriate language and terminology
- Constructive feedback provision
- Active listening and response
- Professional communication style

### 2. **Problem-Solving Skills** (5 items)
- Issue identification and analysis
- Logical and creative solutions
- Alternative approach evaluation
- Solution implementation
- Monitoring and adjustment

### 3. **Technical Competence** (5 items)
- Technical knowledge and skills
- Appropriate concept application
- Tool and resource utilization
- Technology awareness
- Technical problem-solving

### 4. **Professional Behavior** (5 items)
- Professional standards maintenance
- Initiative and responsibility
- Team effectiveness
- Time and resource management
- Ethical behavior

### 5. **Overall Performance** (5 items)
- Performance expectation meeting
- Consistent quality maintenance
- Continuous improvement
- Team contribution
- Overall rating

## Usage Instructions

### 1. **Launch the Study**
```r
# Launch with default settings
study_results <- launch_rater_participant_study()

# Customize participant and rater numbers
study_results <- launch_rater_participant_study(
  n_participants = 50,
  n_raters_per_participant = 4
)
```

### 2. **Generate Reports**
```r
# Generate comprehensive report for a participant
report <- generate_rater_participant_report(
  participant_id = 1,
  ratings_data = ratings,
  rater_profiles = rater_profiles,
  assignments = assignments
)
```

### 3. **Analyze Inter-Rater Reliability**
```r
# Calculate reliability metrics
reliability <- calculate_inter_rater_reliability(ratings_data)
```

## Data Structure

### Participant-Rater Assignments
```r
assignments <- data.frame(
  Participant_ID = rep(1:30, each = 3),
  Rater_ID = c("R001", "R002", "R003", ...),
  Assignment_Date = Sys.Date(),
  Status = "Assigned",
  Completion_Date = NA,
  Quality_Score = NA,
  Agreement_Score = NA
)
```

### Rater Profiles
```r
rater_profiles <- data.frame(
  Rater_ID = c("R001", "R002", "R003", "R004", "R005"),
  Rater_Name = c("Dr. Smith", "Prof. Johnson", ...),
  Rater_Type = c("Expert", "Expert", "Trained", ...),
  Experience_Years = c(15, 12, 8, 6, 2),
  Reliability_Score = c(0.92, 0.89, 0.85, 0.82, 0.78),
  Agreement_Rate = c(0.88, 0.85, 0.82, 0.79, 0.75)
)
```

## Output and Reporting

### Comprehensive Reports Include:
- **Executive Summary**: Overall performance and key findings
- **Dimension Analysis**: Detailed scores across all performance areas
- **Rater Comparison**: Side-by-side analysis of multiple rater assessments
- **Reliability Metrics**: ICC values and agreement rates
- **Recommendations**: Personalized feedback and improvement suggestions
- **Risk Assessment**: Areas requiring attention or intervention

### Export Formats:
- **PDF Reports**: Professional presentation format
- **HTML Dashboards**: Interactive web-based reports
- **CSV Data**: Raw data for statistical analysis
- **R Objects**: R-native format for further processing

## Quality Assurance

### Rater Training and Calibration
- **Regular Calibration**: Monthly calibration sessions
- **Quality Monitoring**: Continuous tracking of reliability scores
- **Performance Feedback**: Regular feedback to maintain standards

### Agreement Thresholds
- **High Agreement**: > 0.8 (Excellent consistency)
- **Good Agreement**: 0.7-0.8 (Acceptable consistency)
- **Low Agreement**: < 0.7 (Requires attention)

## Applications

### Research Applications
- **Inter-rater reliability studies**
- **Performance assessment validation**
- **Rater training effectiveness research**
- **Assessment quality improvement**

### Educational Applications
- **Student performance evaluation**
- **Faculty assessment training**
- **Program accreditation support**
- **Quality assurance systems**

### Organizational Applications
- **Employee performance evaluation**
- **360-degree feedback systems**
- **Competency assessment**
- **Professional development tracking**

## Technical Requirements

### Required Packages
- `inrep`: Core assessment functionality
- `dplyr`: Data manipulation
- `ggplot2`: Visualization
- `knitr`: Report generation
- `kableExtra`: Enhanced tables

### System Requirements
- R version 4.0.0 or higher
- Sufficient memory for large datasets
- Internet connection for cloud storage (optional)

## Support and Documentation

For additional support or questions about this case study:
- Review the main study setup file: `study_setup.R`
- Check the `inrep` package documentation
- Consult the comprehensive reporting functions

## Version History

- **v1.0** (2025-01-20): Initial release with comprehensive rater-participant design
- Full inter-rater reliability analysis
- Advanced reporting and dashboard capabilities
- Quality assurance and monitoring systems