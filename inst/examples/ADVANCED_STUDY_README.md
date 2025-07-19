# Advanced Psychological Study Case Study

This case study demonstrates how to replicate a sophisticated psychological research study using the inrep package. It recreates the enhanced "Psychological Study on R Package Testing Experience" with advanced features including reverse-coded items, construct analysis, and detailed statistical reporting.

## Features Replicated

### Original HTML Study Features
- **Enhanced Monochrome Theme**: Elegant black and white design with subtle animations
- **25-minute Timer**: With warning alerts in final 3 minutes
- **Progress Tracking**: Animated progress bar with percentage completion
- **8 Survey Questions**: Mix of regular and reverse-coded items
- **3 Demographics**: Age, R experience, and developer role
- **Statistical Analysis**: Response distribution, mean scores, construct analysis
- **Results Download**: Detailed report generation
- **Quality Control**: Minimum response requirements
- **Accessibility**: WCAG 2.1 AA compliance

### Enhanced inrep Features
- **IRT Modeling**: Graded Response Model for psychometric analysis
- **Construct Scoring**: Analysis by psychological constructs
- **Reverse Coding**: Automated handling of reverse-coded items
- **Advanced Validation**: Enhanced quality control and session management
- **Multiple Formats**: Flexible output options
- **Session Persistence**: Advanced session management with timeout

## File Contents

### Core Components

1. **Enhanced Item Bank** (`advanced_psychological_items`)
   - 8 Likert-scale items (3 reverse-coded)
   - Detailed explanations for each item
   - Construct categories (Self-Efficacy, Cognitive Load, etc.)
   - IRT parameters for psychometric modeling

2. **Demographics Configuration** (`enhanced_demographics`)
   - Age range selection
   - R package development experience
   - Primary developer role

3. **Study Configuration** (`enhanced_study_config`)
   - Academic-style instructions
   - Monochrome theme
   - 25-minute session timeout
   - Quality control settings

4. **Results Processing** (`process_advanced_results()`)
   - Automatic reverse coding
   - Construct score calculation
   - Statistical summary generation

## Usage Instructions

### Quick Start

```r
# Source the case study file
source("inst/examples/advanced_psychological_study_case_study.R")

# Launch with auto-start
launch_enhanced_study(auto_launch = TRUE)

# Or launch manually
launch_enhanced_study(auto_launch = FALSE)
```

### Manual Launch

```r
library(inrep)

# Load the configuration
source("inst/examples/advanced_psychological_study_case_study.R")

# Launch the study
launch_study(
  config = enhanced_study_config,
  item_bank = advanced_psychological_items,
  port = 3838,
  launch_browser = TRUE
)
```

### Demo Version

```r
# Create demo with sample responses
demo_results <- create_demo_version()

# View results structure
str(demo_results)
```

## Study Flow

1. **Welcome Screen**: Academic introduction with study details
2. **Informed Consent**: Ethical consent form with checkbox
3. **Demographics**: Three optional demographic questions
4. **Main Survey**: Eight Likert-scale questions with explanations
5. **Debriefing**: Academic debriefing with study purpose
6. **Results**: Detailed statistical report with download option

## Key Innovations

### Reverse Coding
Items 2, 6, and 8 are automatically reverse-coded during analysis:
- "Using devtools increases cognitive load" (reverse)
- "Testthat documentation is difficult" (reverse)
- "Testing tools make me feel less competent" (reverse)

### Construct Analysis
Questions are grouped into psychological constructs:
- Self-Efficacy
- Cognitive Load
- Usability
- Stress Reduction
- Motivation
- Documentation
- Satisfaction
- Competence

### Quality Control
- Minimum 50% response rate required
- Straight-lining detection
- Minimum time per question validation
- Session timeout with warnings

## Academic Features

### Research Ethics
- Detailed informed consent
- Voluntary participation emphasis
- Anonymity guarantees
- Contact information for inquiries

### Statistical Reporting
- Response rate calculation
- Mean Likert scores with standard deviation
- Response distribution visualization
- Construct-based analysis
- Individual item feedback with explanations

### Professional Presentation
- Academic writing style
- Proper citations and attributions
- Institutional affiliation (fictional)
- Peer-review publication intentions

## Technical Specifications

### Item Parameters
Each item includes:
- Discrimination parameters (a)
- Four threshold parameters (b1-b4)
- Response options (5-point Likert)
- Construct classification
- Reverse coding indicator

### Theme Integration
Uses the enhanced Monochrome theme with:
- Google Fonts (EB Garamond, Inter)
- Sophisticated CSS animations
- Academic color palette
- Responsive design
- Accessibility features

### Session Management
- 25-minute maximum duration
- Progress saving and restoration
- Timeout warnings
- Quality control validation

## Validation

The case study includes comprehensive validation:
- Item bank structure validation
- Theme loading verification
- Reverse coding confirmation
- Configuration completeness check

## Comparison with Original

| Feature | Original HTML | inrep Implementation |
|---------|---------------|----------------------|
| Theme | Custom CSS | Monochrome theme |
| Questions | 8 items | 8 items + IRT |
| Reverse coding | Manual | Automated |
| Timer | JavaScript | Server-side |
| Statistics | Basic | Advanced constructs |
| Quality control | Client-side | Server-side |
| Accessibility | Manual | Automated |

## Research Applications

This case study is suitable for:
- Software engineering psychology research
- Developer experience studies
- Tool usability assessments
- Psychometric method demonstrations
- Academic coursework examples
- Industry UX research

## Customization

The study can be easily customized by:
- Modifying item text and explanations
- Adjusting demographic questions
- Changing construct categories
- Updating IRT parameters
- Customizing the theme
- Modifying timer settings
- Adjusting quality control criteria

## Output and Results

Participants receive:
- Individual item responses with explanations
- Construct scores by category
- Statistical summary
- Response distribution visualization
- Personalized feedback and recommendations
- Downloadable detailed report

This case study demonstrates the full power of the inrep package for creating sophisticated psychological research studies with academic rigor and professional presentation.
