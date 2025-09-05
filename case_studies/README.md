# inrep Case Studies - Enhanced Edition

## Overview

This directory contains **enhanced case studies** demonstrating the advanced capabilities of the `inrep` package for interactive assessment and reporting. Each case study has been carefully designed to highlight unique features and use cases, from basic functionality to cutting-edge features like plausible values, multi-rater designs, clinical assessments, and interactive dashboards.

## 🎯 **Quick Start**

Each case study now includes a dedicated launch script with demonstration functions:

```r
# Programming Anxiety - Advanced IRT Features
source("case_studies/programming_anxiety_assessment/launch_programming_anxiety.R")
launch_programming_anxiety_study()

# Big Five Personality - Multi-Dimensional Features  
source("case_studies/big_five_personality/launch_big_five.R")
launch_big_five_study()

# Depression Screening - Clinical Features
source("case_studies/depression_screening/launch_depression_screening.R")
launch_depression_screening_study()

# Rater-Participant Design - Multi-Rater Features
source("case_studies/rater_participant_design/launch_rater_participant.R")
launch_rater_participant_study()
```

## Available Case Studies

### 1. 🔗 **Rater-Participant Design** - Multi-Rater Assessment Features
**Location**: `rater_participant_design/`
**Launch**: `launch_rater_participant.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Multi-Rater Assessment** - Multiple raters evaluating participants with reliability analysis
- **Inter-Rater Reliability** - ICC calculations and agreement analysis
- **Advanced Sample Linking** - Bidirectional linking between participants and raters
- **Quality Assurance** - Agreement thresholds and rater calibration
- **Comprehensive Reporting** - Multi-rater comparisons and consensus analysis

**Key Capabilities**:
- 5 performance dimensions (Communication, Problem-Solving, Technical, Professional, Overall)
- 25 carefully calibrated evaluation items with IRT parameters
- 3+ raters per participant with intelligent assignment
- Automated participant-rater assignment system
- Advanced agreement analysis and consensus building

**Use Cases**:
- Performance evaluation studies
- Inter-rater reliability research
- Quality assurance systems
- Educational assessment programs
- Multi-rater consensus building

---

### 2. 🧠 **Programming Anxiety Assessment** - Advanced IRT Features
**Location**: `programming_anxiety_assessment/`
**Launch**: `launch_programming_anxiety.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Plausible Values Generation** - Multiple estimates for robust statistical inference
- **Advanced IRT Models** - Graded Response Model (GRM) with confidence intervals
- **Interactive Dashboard** - Real-time analytics and visualizations
- **Multi-dimensional Profiling** - 5 anxiety dimensions with detailed analysis
- **Risk Assessment** - Personalized recommendations and intervention strategies

**Key Capabilities**:
- 35 anxiety assessment items across 5 dimensions
- Plausible values with confidence intervals
- Interactive visualizations and dashboards
- Personalized recommendations and risk assessment
- Multiple export formats (PDF, HTML, CSV, RDS)

**Use Cases**:
- Programming anxiety research
- Student support programs
- Educational psychology studies
- Clinical anxiety assessment

---

### 3. 👥 **Big Five Personality Assessment** - Multi-Dimensional Features
**Location**: `big_five_personality/`
**Launch**: `launch_big_five.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Multi-dimensional Personality Model** - Five-factor model with trait-specific adaptation
- **Cross-cultural Validation** - Multiple language support and cultural adaptations
- **Comprehensive Profiling** - Radar plots, bar charts, and detailed trait analysis
- **Normative Comparisons** - Population norms and percentile rankings
- **Adaptive Testing** - Trait-specific item selection and stopping criteria

**Key Capabilities**:
- 20 personality items across 5 factors
- Cross-cultural validation and language support
- Comprehensive personality profiling with visualizations
- Normative comparisons and percentile rankings
- Adaptive testing with trait-specific item selection

**Use Cases**:
- Personality research
- Cross-cultural studies
- Educational assessment
- Clinical psychology
- Organizational psychology

---

### 4. 🏥 **Depression Screening Assessment** - Clinical Features
**Location**: `depression_screening/`
**Launch**: `launch_depression_screening.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Clinical Cutoffs & Severity Classification** - Automatic severity assessment
- **Risk Assessment & Intervention Recommendations** - Actionable clinical insights
- **Multiple Validated Instruments** - PHQ-9, CES-D, BDI-II, DASS-21 integration
- **Clinical Reporting** - Professional reports with actionable recommendations
- **Safety Protocols** - Crisis intervention and referral systems

**Key Capabilities**:
- Multiple validated depression instruments
- Clinical cutoffs and severity classification
- Risk assessment and intervention recommendations
- Safety protocols and crisis intervention
- Professional clinical reporting

**Use Cases**:
- Clinical psychology research
- Primary care screening
- Mental health assessment
- Crisis intervention
- Treatment planning

---

### 5. 🎓 **HILFO Study** - Production-Ready Assessment
**Location**: `hildesheim_study/`
**Launch**: `HilFo.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Production-Ready Implementation** - Real-world academic assessment
- **Bilingual Support** - German/English with seamless switching
- **Comprehensive Demographics** - Extensive demographic data collection
- **Advanced Analytics** - Multi-dimensional personality and anxiety profiling
- **Cloud Storage Integration** - Automatic data backup and management

**Key Capabilities**:
- Programming anxiety assessment (20 items)
- Big Five personality assessment (20 items)
- Stress and study skills assessment
- Comprehensive results reporting
- Cloud storage integration

**Use Cases**:
- Academic research studies
- Student assessment programs
- Longitudinal studies
- Cross-cultural research
- Production assessment systems

---

### 6. 📊 **UMA Study** - Modern UI and Auto-Close Features
**Location**: `uma_study/`
**Launch**: `uma_study_simple.R`

**🎯 UNIQUE FEATURES HIGHLIGHTED:**
- **Modern UI Design** - Hover effects and responsive design
- **Auto-Close Functionality** - Configurable timer with universal compatibility
- **Scroll-to-Top** - Enhanced navigation across all platforms
- **Session Isolation** - Complete data isolation and security
- **Simplified Assessment** - 30-item non-adaptive assessment

**Key Capabilities**:
- Modern UI with hover effects
- Auto-close timer (15 seconds)
- Universal scroll-to-top
- Complete session isolation
- 30-item assessment

**Use Cases**:
- Quick assessments
- Mobile-friendly studies
- Time-limited studies
- Modern UI demonstrations
- Cross-platform compatibility

## Getting Started

### Prerequisites
- R version 4.0.0 or higher
- `inrep` package installed and loaded
- Required dependencies (see individual case study READMEs)

### Quick Start
1. **Choose a case study** based on your needs
2. **Navigate to the case study directory**
3. **Read the README.md** for detailed instructions
4. **Run the study_setup.R** file to initialize
5. **Follow the usage examples** provided

### Example Workflow
```r
# Load the inrep package
library(inrep)

# Navigate to a case study
setwd("case_studies/programming_anxiety_assessment/")

# Source the setup file
source("study_setup.R")

# Launch the study
app <- launch_programming_anxiety_study()

# Analyze results
results <- analyze_programming_anxiety(responses)

# Create dashboard
dashboard <- create_anxiety_dashboard(results)
```

## Case Study Selection Guide

### For Beginners
- **Start with**: `basic_assessment/`
- **Focus on**: Core functionality and basic concepts
- **Goal**: Understand fundamental inrep operations

### For Researchers
- **Choose**: `rater_participant_design/` or `programming_anxiety_assessment/`
- **Focus on**: Advanced features and statistical rigor
- **Goal**: Implement sophisticated assessment designs

### For Educators
- **Consider**: `basic_assessment/` or `programming_anxiety_assessment/`
- **Focus on**: Practical implementation and student assessment
- **Goal**: Create effective learning assessments

### For Developers
- **Explore**: `advanced_analytics/` and custom modifications
- **Focus on**: Technical implementation and customization
- **Goal**: Build specialized assessment systems

## Customization and Extension

### Modifying Case Studies
Each case study is designed to be easily customizable:
- **Configuration files**: Modify study parameters
- **Item banks**: Add or modify assessment items
- **Analysis functions**: Customize reporting and analytics
- **Visualization**: Adapt charts and dashboards

### Creating New Case Studies
Use existing case studies as templates:
1. **Copy a similar case study** directory
2. **Modify the configuration** for your needs
3. **Adapt the item bank** to your domain
4. **Customize the analysis** functions
5. **Update documentation** and examples

### Best Practices
- **Document changes** thoroughly
- **Test modifications** before deployment
- **Maintain consistency** with inrep standards
- **Validate results** with known data
- **Update README files** with new information

## Support and Resources

### Documentation
- **Package Documentation**: `?inrep` and `help(package = "inrep")`
- **Case Study READMEs**: Detailed instructions for each study
- **Code Comments**: Inline documentation in R files
- **Examples**: Working code examples in each case study

### Getting Help
- **Package Issues**: Check the inrep GitHub repository
- **Case Study Questions**: Review the specific README files
- **R Community**: R-help mailing list and Stack Overflow
- **Package Maintainers**: Contact the inrep development team

### Contributing
- **Report Issues**: Submit bug reports and feature requests
- **Share Improvements**: Contribute enhanced case studies
- **Documentation**: Help improve README files and examples
- **Testing**: Validate case studies on different systems

## Version Information

- **inrep Package**: Version 1.0.0
- **Case Studies**: Version 1.0 (2025-01-20)
- **R Compatibility**: 4.0.0+
- **Last Updated**: January 20, 2025

## License and Citation

### Package License
The `inrep` package and case studies are provided under the appropriate license terms. Please check individual case study directories for specific licensing information.

### Citation
When using these case studies in research or publications, please cite:
- The `inrep` package
- The specific case study used
- Any relevant methodological references

### Acknowledgments
- **Case Study Developers**: The inrep development team
- **Research Community**: Contributors and testers
- **Educational Institutions**: Partners in validation and testing
- **Open Source Community**: R ecosystem contributors

---

## Quick Reference

| Case Study | Focus | Complexity | Key Feature |
|------------|-------|------------|-------------|
| Basic Assessment | Core functionality | Low | Adaptive testing basics |
| Rater-Participant | Multi-rater design | High | Inter-rater reliability |
| Programming Anxiety | Plausible values | Medium | Statistical robustness |
| Advanced Analytics | Complex analysis | High | Advanced IRT models |

For detailed information about each case study, navigate to the respective directory and read the README.md file.