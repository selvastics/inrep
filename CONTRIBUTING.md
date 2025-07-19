# Contributing to inrep

Thank you for your interest in contributing to `inrep`! We welcome contributions from the community.

## Types of Contributions

### Bug Reports
- Use the GitHub issue tracker to report bugs
- Include a minimal reproducible example
- Describe your system information (R version, OS, etc.)

### Feature Requests
- Describe the feature and its use case
- Explain how it would benefit users
- Consider if it fits with the package's scope

### Code Contributions
- Fork the repository
- Create a feature branch
- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Submit a pull request

## Development Setup

1. Fork and clone the repository
2. Install development dependencies:
   ```r
   devtools::install_dev_deps()
   ```
3. Run tests:
   ```r
   devtools::test()
   ```
4. Check the package:
   ```r
   devtools::check()
   ```

## Code Style

- Follow the existing code style in the package
- Use meaningful variable and function names
- Comment your code where necessary
- Follow R package development best practices

## Psychometric Considerations

Since this package deals with psychometric assessments:
- Ensure all statistical computations use TAM functions
- Validate new IRT functionality against established methods
- Consider ethical implications of assessment tools
- Document any assumptions or limitations

## Questions?

Feel free to open an issue for questions about contributing or contact the maintainer at selva@uni-hildesheim.de.
