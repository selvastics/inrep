# inrep Case Studies

## Overview

This directory contains comprehensive case studies demonstrating the capabilities of the `inrep` package for interactive assessment and reporting. Each case study showcases different aspects of the package, from basic functionality to advanced features like rater designs, plausible values, and interactive dashboards.

## Available Case Studies

### 1. **Rater-Participant Design** 📊
**Location**: `rater_participant_design/`

A sophisticated assessment system where multiple raters evaluate participants, featuring:
- **Inter-rater reliability analysis** with ICC calculations
- **Rater management system** with quality monitoring
- **Comprehensive reporting** with multi-rater comparisons
- **Quality assurance** with agreement thresholds and calibration

**Key Features**:
- 5 performance dimensions (Communication, Problem-Solving, Technical, Professional, Overall)
- 25 carefully calibrated evaluation items
- 5 trained raters with different expertise levels
- Automated participant-rater assignment system
- Advanced agreement analysis and recommendations

**Use Cases**:
- Performance evaluation studies
- Inter-rater reliability research
- Quality assurance systems
- Educational assessment programs

---

### 2. **Programming Anxiety Assessment** 🧠
**Location**: `programming_anxiety_assessment/`

A comprehensive assessment focused on Programming Anxiety with advanced analytics:
- **Plausible values generation** for robust statistical inference
- **Interactive dashboard** with real-time analytics
- **Multi-dimensional analysis** across 5 anxiety types
- **Export capabilities** in multiple formats

**Key Features**:
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

### 3. **Basic Assessment** 📝
**Location**: `basic_assessment/`

A foundational case study demonstrating core `inrep` functionality:
- **Basic adaptive testing** with IRT models
- **Standard reporting** and result analysis
- **Item bank management** and validation
- **Study configuration** and administration

**Key Features**:
- Simple adaptive testing setup
- Basic result reporting
- Item bank validation
- Study administration tools

**Use Cases**:
- Learning the basics of inrep
- Simple assessment needs
- Educational testing
- Research studies

---

### 4. **Advanced Analytics** 🔬
**Location**: `advanced_analytics/`

Advanced statistical analysis and reporting capabilities:
- **Complex IRT models** and parameter estimation
- **Advanced visualization** and charting
- **Statistical testing** and hypothesis testing
- **Data export** and integration tools

**Key Features**:
- Multiple IRT model support
- Advanced statistical analysis
- Comprehensive visualization options
- Data integration capabilities

**Use Cases**:
- Advanced research studies
- Complex statistical analysis
- Data science applications
- Academic research

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