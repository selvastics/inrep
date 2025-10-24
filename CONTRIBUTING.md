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

