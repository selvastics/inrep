# inrep: Intelligent Psychological Assessment Platform

[![R-CMD-check](https://github.com/your-username/inrep/workflows/R-CMD-check/badge.svg)](https://github.com/your-username/inrep/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Overview

**inrep** is a comprehensive R package that transforms psychological assessment development through intelligent LLM assistance, robust session management, and advanced psychometric capabilities. Built with modern R development practices and Claude 4 best practices for AI assistance, it provides researchers and practitioners with a powerful, secure, and user-friendly platform for creating, deploying, and analyzing psychological assessments.

## 🚀 Key Features

### 🤖 Enhanced LLM Assistance System
- **Claude 4 Best Practices Implementation**: Advanced prompt engineering following Anthropic's latest recommendations
- **Context-Aware Assistance**: Intelligent guidance that adapts to your specific assessment needs and constraints
- **Complexity Scaling**: Assistance that scales from basic to expert levels based on your expertise
- **Task-Specific Optimization**: Specialized prompts for study design, item bank optimization, ability estimation, UI design, analysis planning, and deployment strategy
- **Quick Assistance Functions**: Immediate guidance for common assessment tasks

### 🔒 Robust Session Management
- **Data Persistence**: Automatic saving and recovery of participant responses and session state
- **Keep-Alive Mechanisms**: Prevents session timeouts during long assessments
- **Error Recovery**: Graceful handling of network issues and system interruptions
- **Secure Data Handling**: Built-in security measures for sensitive participant data

### 📊 Advanced Psychometric Capabilities
- **Multiple IRT Models**: Support for GRM, PCM, and other item response theory models
- **Adaptive Testing**: Intelligent item selection and ability estimation
- **Item Bank Optimization**: Tools for improving item quality and measurement precision
- **Comprehensive Validation**: Built-in psychometric validation and quality assessment

### 🎯 User Experience Excellence
- **Responsive Design**: Works seamlessly across desktop, tablet, and mobile devices
- **Accessibility First**: WCAG 2.1 AA compliance and inclusive design principles
- **Intuitive Interface**: Clean, modern UI that reduces participant anxiety and improves completion rates
- **Real-Time Feedback**: Immediate progress indicators and support throughout the assessment

## 🏗️ Architecture

The package is built with a modular architecture that separates concerns and ensures maintainability:

```
inrep/
├── R/                          # Core R functions
│   ├── enhanced_llm_assistance.R    # LLM assistance system
│   ├── robust_session_management.R  # Session handling
│   ├── robust_error_handling.R      # Error management
│   ├── item_selection.R             # Item selection algorithms
│   ├── estimate_ability.R           # Ability estimation
│   └── ...                         # Additional modules
├── inst/                       # Package resources
│   ├── case_studies/           # Example implementations
│   └── examples/               # Usage examples
└── tests/                      # Comprehensive testing
```

## 📚 Case Studies

### 1. Programming Anxiety Assessment
A comprehensive case study demonstrating the enhanced LLM assistance system in action, showing how it guides every step of assessment development from study design to deployment.

**Key Features Demonstrated:**
- Study design optimization with LLM guidance
- Item bank quality improvement
- Ability estimation strategy optimization
- User interface optimization for anxiety reduction
- Analysis planning and deployment strategy

### 2. Enhanced LLM System Demonstration
A hands-on showcase of all enhanced LLM assistance capabilities, including:
- Context-aware prompt generation
- Complexity scaling from basic to expert
- Integration workflow demonstration
- Advanced features and system validation

## 🚀 Quick Start

### Installation

```r
# Install from GitHub
if (!require(devtools)) install.packages("devtools")
devtools::install_github("your-username/inrep")

# Load the package
library(inrep)
```

### Basic Usage

```r
# Enable enhanced LLM assistance
enable_llm_assistance(
  enable = TRUE,
  enhanced_mode = TRUE,
  complexity_level = "intermediate"
)

# Get LLM guidance for study design
study_prompt <- generate_enhanced_prompt(
  task_type = "study_design",
  context = list(
    study_type = "personality_assessment",
    population = "university students",
    sample_size = 300
  )
)

# Launch a study with robust session management
launch_study(
  study_config = "path/to/config.yaml",
  enable_robust_mode = TRUE,
  enable_llm_assistance = TRUE
)
```

### Advanced Usage

```r
# Run the complete enhanced LLM case study
run_enhanced_llm_case_study()

# Demonstrate the enhanced LLM system
demonstrate_enhanced_llm_system()

# Get quick assistance for specific tasks
quick_llm_assistance("study_config", list(study_type = "cognitive"))
quick_llm_assistance("validation", list(model = "GRM", items = 30))
quick_llm_assistance("ui", list(target_users = "mobile", accessibility = "required"))
```

## 🔧 Configuration

### LLM Assistance Settings

```r
# Configure enhanced LLM assistance
set_llm_assistance_settings(
  enhanced_mode = TRUE,
  complexity_level = "expert",  # basic, intermediate, advanced, expert
  output_format = "console",    # console, markdown, json
  prompt_types = "all",         # specific types or "all"
  verbose = TRUE
)

# View current settings
get_llm_assistance_settings()
```

### Robust Session Management

```r
# Configure robust session handling
set_robust_session_settings(
  auto_save_interval = 30,      # seconds
  keep_alive_interval = 60,     # seconds
  max_session_duration = 7200,  # seconds (2 hours)
  enable_error_recovery = TRUE
)
```

## 📖 Documentation

- **Package Documentation**: `?inrep` for overview, `?function_name` for specific functions
- **Case Studies**: See `inst/case_studies/` for comprehensive examples
- **Vignettes**: Detailed tutorials and best practices
- **API Reference**: Complete function documentation with examples

## 🧪 Testing

The package includes comprehensive testing to ensure reliability:

```r
# Run all tests
devtools::test()

# Run specific test files
devtools::test_file("tests/testthat/test-enhanced-llm-assistance.R")
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code style and standards
- Testing requirements
- Pull request process
- Issue reporting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Anthropic**: For Claude 4 best practices in prompt engineering
- **R Community**: For the excellent tools and packages that make this possible
- **Contributors**: All those who have helped improve and expand the package

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/inrep/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/inrep/discussions)
- **Documentation**: [Package Website](https://your-username.github.io/inrep/)

---

**Transform your psychological assessment development with intelligent AI assistance. Get started with inrep today!**

