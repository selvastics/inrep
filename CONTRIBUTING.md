# Contributing to inrep

Thank you for your interest in contributing to the **inrep** package! This document provides guidelines and information for contributors who want to help improve this intelligent psychological assessment platform.

## How to Contribute

We welcome contributions from researchers, developers, and users in the psychological assessment community. There are many ways to contribute:

### Report Issues
- **Bug reports**: Help us identify and fix problems
- **Feature requests**: Suggest new capabilities or improvements
- **Documentation issues**: Report unclear or missing documentation
- **Performance problems**: Identify areas for optimization

### Code Contributions
- **Bug fixes**: Resolve identified issues
- **New features**: Implement requested capabilities
- **Performance improvements**: Optimize existing code
- **Testing**: Add or improve test coverage
- **Documentation**: Enhance guides and examples

### Documentation & Examples
- **Case studies**: Create new examples showing package capabilities
- **Tutorials**: Write guides for specific use cases
- **API documentation**: Improve function documentation
- **Best practices**: Share optimal usage patterns

### Testing & Quality Assurance
- **Test coverage**: Ensure comprehensive testing of new features
- **R-CMD-check**: Verify CRAN compliance
- **Cross-platform testing**: Test on different operating systems
- **Performance testing**: Validate scalability and efficiency

## Getting Started

### Prerequisites
- **R** (version 4.0.0 or higher)
- **RStudio** (recommended) or another R IDE
- **Git** for version control
- **GitHub account** for collaboration

### Development Setup

1. **Fork the repository**
   ```bash
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/inrep.git
   cd inrep
   
   # Add upstream remote
   git remote add upstream https://github.com/original-username/inrep.git
   ```

2. **Install development dependencies**
   ```r
   # Install required packages
   install.packages(c("devtools", "testthat", "roxygen2", "knitr", "rmarkdown"))
   
   # Install package dependencies
   devtools::install_deps()
   ```

3. **Build and test the package**
   ```r
   # Load the package
   devtools::load_all()
   
   # Run tests
   devtools::test()
   
   # Check package
   devtools::check()
   ```

##  Contribution Guidelines

### Code Standards

#### R Code Style
- **Follow tidyverse style guide**: Use `styler::style_pkg()` for consistent formatting
- **Function naming**: Use descriptive names in snake_case (e.g., `generate_enhanced_prompt`)
- **Variable naming**: Use clear, descriptive names
- **Line length**: Keep lines under 80 characters when possible
- **Indentation**: Use 2 spaces for indentation

#### Documentation Standards
- **Roxygen2**: All functions must have complete documentation
- **Examples**: Include working examples for all exported functions
- **Parameter descriptions**: Clearly document all parameters and return values
- **Use cases**: Explain when and how to use each function

#### Function Design
- **Single responsibility**: Each function should do one thing well
- **Error handling**: Include proper error checking and user-friendly messages
- **Input validation**: Validate all inputs with clear error messages
- **Return values**: Use consistent return value structures

### Testing Requirements

#### Test Coverage
- **Minimum 90% coverage**: All new functions must have comprehensive tests
- **Test files**: Create test files in `tests/testthat/` following naming conventions
- **Test scenarios**: Include positive cases, edge cases, and error conditions
- **Integration tests**: Test complete workflows and function interactions

#### Test Structure
```r
# Example test structure
test_that("function_name works correctly", {
  # Setup
  test_data <- create_test_data()
  
  # Test normal operation
  result <- function_name(test_data)
  expect_equal(length(result), 3)
  expect_true(is.list(result))
  
  # Test error conditions
  expect_error(function_name(NULL), "Input cannot be NULL")
  expect_error(function_name("invalid"), "Input must be numeric")
})
```

#### R-CMD-Check Compliance
- **All checks must pass**: No errors, warnings, or notes
- **CRAN compliance**: Follow CRAN policies strictly
- **Cross-platform**: Test on Windows, macOS, and Linux
- **Dependencies**: Minimize and document package dependencies

### Documentation Standards

#### Function Documentation
```r
#' Generate Enhanced LLM Prompt
#'
#' @description
#' Creates context-aware, complexity-scaled prompts for psychological assessment tasks
#' using Claude 4 best practices for prompt engineering.
#'
#' @param task_type Character string specifying the task type. Must be one of:
#'   "study_design", "item_bank_optimization", "ability_estimation", "ui_optimization",
#'   "analysis_planning", or "deployment_strategy".
#' @param context List containing task-specific context information.
#' @param complexity_level Character string specifying the desired complexity level.
#'   Options: "basic", "intermediate", "advanced", "expert".
#' @param include_reasoning Logical indicating whether to include reasoning chains.
#' @param output_structure Character string specifying the desired output structure.
#'   Options: "simple", "structured", "detailed", "comprehensive".
#'
#' @return Character string containing the generated enhanced prompt.
#'
#' @examples
#' \dontrun{
#' # Generate a study design prompt
#' prompt <- generate_enhanced_prompt(
#'   task_type = "study_design",
#'   context = list(
#'     study_type = "personality_assessment",
#'     population = "university students",
#'     sample_size = 300
#'   ),
#'   complexity_level = "intermediate"
#' )
#' }
#'
#' @export
```

#### Case Studies and Examples
- **Real-world scenarios**: Use realistic assessment contexts
- **Step-by-step guidance**: Provide clear progression through examples
- **Best practices**: Demonstrate optimal usage patterns
- **Troubleshooting**: Include common issues and solutions

##  Contribution Workflow

### 1. Issue Discussion
- **Search existing issues**: Check if your concern is already reported
- **Create new issue**: Use appropriate issue template
- **Provide details**: Include reproducible examples and context
- **Discuss solutions**: Engage with maintainers and community

### 2. Development Process
- **Create feature branch**: Use descriptive branch names
- **Make focused changes**: Keep commits small and focused
- **Test thoroughly**: Ensure all tests pass locally
- **Update documentation**: Include documentation for new features

### 3. Pull Request Process
- **Create PR**: Use the pull request template
- **Describe changes**: Clearly explain what and why
- **Link issues**: Reference related issues and discussions
- **Request review**: Ask for feedback from maintainers

### 4. Review and Merge
- **Code review**: Address feedback and suggestions
- **Final testing**: Ensure all checks pass
- **Documentation**: Update relevant documentation
- **Merge**: Maintainers will merge approved changes

## Architecture Guidelines

### Package Structure
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
├── tests/                      # Comprehensive testing
├── vignettes/                  # Detailed tutorials
└── man/                        # Function documentation
```

### Module Design Principles
- **Separation of concerns**: Each module handles specific functionality
- **Clean interfaces**: Clear function signatures and return values
- **Dependency management**: Minimize inter-module dependencies
- **Extensibility**: Design for future enhancements

### Error Handling Strategy
- **User-friendly messages**: Clear, actionable error messages
- **Graceful degradation**: Provide fallback options when possible
- **Comprehensive logging**: Detailed logging for debugging
- **Recovery mechanisms**: Automatic recovery from common errors

## Testing Strategy

### Test Categories
- **Unit tests**: Test individual functions in isolation
- **Integration tests**: Test function interactions and workflows
- **Performance tests**: Validate scalability and efficiency
- **Error tests**: Ensure proper error handling and recovery

### Test Data
- **Synthetic data**: Create realistic test datasets
- **Edge cases**: Include boundary conditions and unusual inputs
- **Error conditions**: Test invalid inputs and failure scenarios
- **Performance scenarios**: Test with large datasets

### Continuous Integration
- **Automated testing**: All tests run on every commit
- **Multiple platforms**: Test on Windows, macOS, and Linux
- **R versions**: Test on multiple R versions
- **Dependency checks**: Verify package compatibility

## Documentation Strategy

### User Documentation
- **Getting started**: Quick start guide for new users
- **Tutorials**: Step-by-step examples for common tasks
- **Case studies**: Real-world application examples
- **Best practices**: Guidelines for optimal usage

### Developer Documentation
- **API reference**: Complete function documentation
- **Architecture guide**: Package structure and design principles
- **Contributing guide**: This document and related resources
- **Development setup**: Environment configuration instructions

### Maintenance
- **Regular updates**: Keep documentation current with code changes
- **User feedback**: Incorporate user suggestions and questions
- **Examples**: Maintain working, tested examples
- **Links**: Keep external links and references current

## Common Issues and Solutions

### R-CMD-Check Failures
- **Missing documentation**: Ensure all exported functions are documented
- **Import issues**: Check package dependencies and imports
- **Platform differences**: Test on multiple operating systems
- **CRAN policies**: Follow CRAN submission requirements

### Test Failures
- **Missing dependencies**: Install required testing packages
- **Environment issues**: Check R version and package versions
- **Platform differences**: Some tests may behave differently across platforms
- **Timing issues**: Some tests may be sensitive to system performance

### Build Issues
- **Package dependencies**: Ensure all required packages are installed
- **R version**: Check compatibility with your R version
- **System libraries**: Some packages require system-level dependencies
- **Permissions**: Ensure write access to package directory

## Getting Help

### Communication Channels
- **GitHub Issues**: For bug reports and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions and improvements
- **Email**: For sensitive or private communications

### Response Times
- **Critical issues**: We aim to respond within 24 hours
- **General questions**: We aim to respond within 3-5 days
- **Code reviews**: We aim to review within 1 week
- **Feature requests**: We evaluate and respond within 2 weeks

### Community Guidelines
- **Be respectful**: Treat all contributors with respect and courtesy
- **Be constructive**: Provide helpful, actionable feedback
- **Be patient**: Development takes time and careful consideration
- **Be collaborative**: Work together to improve the package

## Contribution Priorities

### High Priority
- **Bug fixes**: Critical issues affecting functionality
- **Security issues**: Vulnerabilities or data privacy concerns
- **CRAN compliance**: Issues preventing CRAN submission
- **Documentation gaps**: Missing or unclear documentation

### Medium Priority
- **Performance improvements**: Optimizations for better efficiency
- **New features**: Requested capabilities with clear use cases
- **Test coverage**: Improving test coverage and quality
- **User experience**: Interface and workflow improvements

### Low Priority
- **Nice-to-have features**: Enhancements without clear use cases
- **Cosmetic changes**: Visual improvements without functional impact
- **Experimental features**: New capabilities requiring significant development
- **Platform-specific optimizations**: Improvements for specific operating systems

## Recognition and Credits

### Contributor Recognition
- **Authors file**: Contributors are listed in package documentation
- **Release notes**: Significant contributions are acknowledged in NEWS
- **GitHub contributors**: All contributors appear in the GitHub contributors list
- **Citation**: Contributors can cite their contributions in academic work

### Contribution Types
- **Code contributions**: Functions, bug fixes, and improvements
- **Documentation**: Guides, examples, and API documentation
- **Testing**: Test development and quality assurance
- **Community support**: Helping other users and contributors

## Checklist for Contributors

Before submitting a contribution, please ensure:

- [ ] **Code follows style guidelines** and passes `styler::style_pkg()`
- [ ] **All functions are documented** with roxygen2 comments
- [ ] **Tests are comprehensive** and all pass locally
- [ ] **R-CMD-check passes** without errors, warnings, or notes
- [ ] **Documentation is updated** for any new features
- [ ] **Examples are working** and tested
- [ ] **Dependencies are minimal** and documented
- [ ] **Changes are focused** and address specific issues
- [ ] **Commit messages are clear** and descriptive
- [ ] **Pull request description** explains what and why

## Ready to Contribute?

Thank you for reading through these guidelines! We're excited to work with you to improve the **inrep** package. Here's how to get started:

1. **Fork the repository** and set up your development environment
2. **Choose an issue** to work on or create a new one
3. **Follow the guidelines** in this document
4. **Submit your contribution** and engage with the community

Your contributions help make **inrep** a better tool for psychological assessment research and practice. We appreciate your time and effort!

---

**Questions?** Feel free to open an issue or start a discussion on GitHub. We're here to help!
