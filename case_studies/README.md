# inrep Case Studies

This folder contains comprehensive case studies demonstrating the use of the inrep package for various psychological and educational research scenarios. Each case study is designed to be fully functional and ready for deployment.

## Case Study Categories

### Psychology Research Studies
- **Personality Assessment**: Big Five Inventory (BFI) adaptive testing
- **Clinical Psychology**: Depression screening and assessment
- **Cognitive Psychology**: Working memory and attention tasks
- **Social Psychology**: Attitude and belief measurement
- **Developmental Psychology**: Age-appropriate cognitive assessments

### Educational Research Studies
- **Mathematics Assessment**: Adaptive math proficiency testing
- **Language Learning**: Vocabulary and grammar assessment
- **Science Education**: Conceptual understanding measurement
- **Academic Skills**: Reading comprehension and writing assessment

### LMU-Level Research Studies
- **University Student Assessment**: Academic performance evaluation
- **Research Methodology**: Experimental design and data collection
- **Cross-Cultural Studies**: International student assessments
- **Longitudinal Research**: Repeated measures and tracking studies

## Case Study Structure

Each case study includes:
- **Study Configuration**: Complete setup with appropriate parameters
- **Item Bank**: Validated items with psychometric properties
- **Data Collection**: Demographics and response tracking
- **Analysis Scripts**: R scripts for data analysis and reporting
- **Documentation**: Detailed study description and methodology
- **Results Template**: Pre-configured reporting and visualization

## Usage Instructions

1. **Load the case study**: `source("case_studies/[study_name]/study_setup.R")`
2. **Review configuration**: Examine the study parameters and modify as needed
3. **Launch the study**: Run the launch command to start data collection
4. **Analyze results**: Use the provided analysis scripts for data processing
5. **Generate reports**: Create comprehensive reports and visualizations

## Case Study Index

### Psychology Studies
- [Big Five Personality Assessment](big_five_personality/README.md) - Comprehensive personality assessment using adaptive BFI
- [Depression Screening Study](depression_screening/README.md) - Clinical depression screening with crisis intervention
- [Working Memory Assessment](working_memory/README.md) - Cognitive working memory testing
- [Social Attitudes Survey](social_attitudes/README.md) - Social psychology attitude measurement
- [Cognitive Development Study](cognitive_development/README.md) - Developmental cognitive assessment

### Educational Studies
- [Mathematics Proficiency](mathematics_proficiency/README.md) - Adaptive math assessment
- [Language Learning Assessment](language_learning/README.md) - Language acquisition measurement
- [Science Concept Understanding](science_concepts/README.md) - Science education assessment
- [Academic Skills Evaluation](academic_skills/README.md) - General academic skills testing

### LMU Research Studies
- [University Student Assessment](university_student/README.md) - Comprehensive university student evaluation
- [Research Methodology Study](research_methodology/README.md) - Experimental design and methodology
- [Cross-Cultural Comparison](cross_cultural/README.md) - International student assessments
- [Longitudinal Research Design](longitudinal_study/README.md) - Repeated measures studies

## Comprehensive Case Studies

### 1. Big Five Personality Assessment
**Location**: `case_studies/big_five_personality/`

**Description**: A comprehensive adaptive Big Five Inventory (BFI) personality assessment designed for psychological research. This case study demonstrates:

- **44 validated items** across five personality dimensions
- **IRT modeling** using Graded Response Model (GRM)
- **Adaptive testing** with maximum information selection
- **Comprehensive reporting** with personality profiles
- **Quality monitoring** and response validation
- **Accessibility features** for diverse populations

**Key Features**:
- Real-time adaptation based on responses
- Psychometric validation with reliability > 0.8
- Professional interface with modern design
- Comprehensive analysis and visualization
- Export capabilities for research data

**Usage**:
```r
# Load the study
source("case_studies/big_five_personality/study_setup.R")

# Launch the assessment
launch_bfi_study()

# Analyze results
analyze_bfi_results(results_data)
```

### 2. Depression Screening Study
**Location**: `case_studies/depression_screening/`

**Description**: A clinical depression screening assessment with crisis intervention capabilities. This case study demonstrates:

- **60 clinical items** from validated instruments (PHQ-9, CES-D, BDI-II)
- **Clinical cutoffs** and severity classification
- **Crisis detection** and emergency procedures
- **HIPAA compliance** for clinical data
- **Professional reporting** with clinical recommendations

**Key Features**:
- Automatic risk assessment and alerts
- Crisis intervention resources
- Clinical validation with sensitivity > 0.85
- Secure data handling and privacy protection
- Comprehensive clinical reporting

**Usage**:
```r
# Load the study
source("case_studies/depression_screening/study_setup.R")

# Launch the assessment
launch_depression_study()

# Analyze results
analyze_depression_results(results_data)
```

### 3. University Student Assessment
**Location**: `case_studies/university_student/`

**Description**: A comprehensive university student assessment designed for LMU-level research. This case study demonstrates:

- **120 academic items** across six constructs
- **Academic integration** with course-specific assessments
- **Longitudinal tracking** capabilities
- **FERPA compliance** for academic data
- **Institutional reporting** and analytics

**Key Features**:
- Multi-dimensional academic assessment
- Course-specific and general measures
- Academic performance classification
- Intervention recommendations
- Institutional integration capabilities

**Usage**:
```r
# Load the study
source("case_studies/university_student/study_setup.R")

# Launch the assessment
launch_university_study()

# Analyze results
analyze_university_results(results_data)
```

## Case Study Development

### Creating New Case Studies

To create a new case study:

1. **Create directory structure**:
   ```bash
   mkdir -p case_studies/[study_name]
   ```

2. **Create required files**:
   - `README.md` - Comprehensive documentation
   - `study_setup.R` - Study configuration and setup
   - `[study_name]_items_enhanced.R` - Enhanced item bank
   - `analysis_script.R` - Data analysis functions
   - `results_template.Rmd` - Results reporting template

3. **Follow the template structure**:
   - Use consistent naming conventions
   - Include comprehensive documentation
   - Implement validation functions
   - Add error handling and quality checks
   - Include accessibility features

4. **Test thoroughly**:
   - Validate item banks
   - Test study configurations
   - Verify analysis functions
   - Check reporting capabilities

### Case Study Standards

All case studies should meet these standards:

- **Comprehensive Documentation**: Detailed README with usage instructions
- **Validated Item Banks**: Psychometrically sound items with IRT parameters
- **Quality Assurance**: Error handling, validation, and monitoring
- **Accessibility**: WCAG 2.1 compliance and mobile optimization
- **Security**: Data protection and privacy compliance
- **Reporting**: Comprehensive analysis and visualization capabilities

## Quality Assurance

### Validation Requirements

Each case study must include:

1. **Item Bank Validation**:
   - Required columns and data types
   - IRT parameter validation
   - Psychometric property checks
   - Content validity assessment

2. **Study Configuration Validation**:
   - Parameter range checks
   - Consistency validation
   - Error handling
   - Performance optimization

3. **Analysis Validation**:
   - Statistical method validation
   - Result accuracy checks
   - Report generation testing
   - Export functionality

### Testing Procedures

1. **Unit Testing**: Individual function testing
2. **Integration Testing**: End-to-end workflow testing
3. **User Testing**: Interface and usability testing
4. **Performance Testing**: Load and stress testing
5. **Security Testing**: Data protection and privacy testing

## Contributing

To add a new case study:

1. Create a new folder with the study name
2. Include all required components (config, items, scripts, docs)
3. Add a README.md with study description
4. Update this index
5. Test the study thoroughly before submission

## Support

For questions about case studies or to request new studies:

- Check the main package documentation
- Review existing case studies for examples
- Contact the development team
- Submit issues or feature requests on GitHub

## Version History

- **v1.0.0**: Initial release with basic case studies
- **v1.1.0**: Enhanced case studies with comprehensive features
- **v1.2.0**: Added clinical and academic case studies
- **v2.0.0**: Comprehensive redesign with production-ready case studies

## License

All case studies are provided under the MIT License. See the main package license for details.