# Contributing to inrep

**inrep** is a vibe coding project that grows as studies are run. Since one person can only run so many, I invite you to try it out, run your own study, and share your code. Fork it, remix it, or send feedback. Every contribution helps shape the package.

## How to Contribute

* **Issues**: Report bugs, suggest features, or point out unclear docs.
* **Code**: Fix bugs, add features, improve performance, write tests, or update docs.
* **Examples**: Share study setups, tutorials, or practical use cases.
* **Testing**: Run checks, validate across systems, and help spot edge cases.

## Setup

1. Fork and clone:

   ```bash
   git clone https://github.com/YOUR_USERNAME/inrep.git
   cd inrep
   git remote add upstream https://github.com/original-username/inrep.git
   ```
2. Install dependencies:

   ```r
   install.packages(c("devtools", "testthat", "roxygen2", "knitr", "rmarkdown"))
   devtools::install_deps()
   ```
3. Build and test:

   ```r
   devtools::load_all()
   devtools::test()
   devtools::check()
   ```

## Guidelines

* Follow tidyverse style.
* Document functions with roxygen2.
* Keep functions simple, tested, and clear.
* Add examples that work.
* Make pull requests small and focused.

## Contribution Workflow

1. Open or check an issue.
2. Create a branch and make changes.
3. Test locally.
4. Submit a pull request with a short description.

## Recognition

Contributors are credited in GitHub and docs. Big changes get highlighted in releases.

