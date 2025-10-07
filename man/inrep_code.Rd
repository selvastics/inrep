\name{inrep_code}
\alias{inrep_code}
\title{Generate Standalone R Script for Assessment App}
\usage{
inrep_code(expr, output_file = NULL, auto_run = FALSE, console_ready = FALSE, minimal = FALSE)
}
\arguments{
\item{expr}{The launch_study() call expression}

\item{output_file}{Optional file path to save the script. If NULL, returns script as string.
Can be a filename (saves to current directory) or full path.}

\item{auto_run}{Logical. If TRUE, adds code to automatically run the assessment.
If FALSE (default), user must uncomment the launch line.}

\item{console_ready}{Logical. If TRUE, generates compact code for console copy-paste.
When TRUE, creates minimal executable code under R's 4094 character limit.}

\item{minimal}{Logical. If TRUE, generates only essential code for faster deployment.}
}
\value{
Character string containing the complete standalone R script, invisibly if 
  output_file is specified
}
\description{
Creates a completely self-contained R script that includes all inrep functionality
needed to run an assessment independently. This function extracts and packages
all dependencies, helper functions, data, and the complete Shiny app logic.
}
\details{
This function analyzes a \code{launch_study()} call and generates a standalone R script
that can be run independently of the inrep package. The generated script includes:

\itemize{
  \item All required library dependencies
  \item Complete function definitions from inrep
  \item Built-in datasets (bfi_items, cognitive_items, math_items)
  \item Theme system with CSS definitions
  \item Utility functions and operators
  \item Error handling and diagnostics
  \item Smart execution options (auto-run or manual)
  \item Console-ready formatting for easy deployment
}

The resulting script can be saved to a file and executed on any system with the
required R packages installed, making it perfect for:
\itemize{
  \item Sharing assessments with collaborators
  \item Deploying to systems without inrep package access
  \item Creating self-contained research instruments
  \item Educational and training purposes
  \item Long-term archival of assessment tools
  \item Quick console deployment for testing
}

\strong{Smart Features:}
\itemize{
  \item Automatic file naming and directory creation
  \item Auto-run mode for immediate deployment
  \item Console-ready formatting for copy-paste deployment
  \item Comprehensive error handling and validation
  \item User-friendly status messages and instructions
}

\strong{Dependencies:} The generated script requires the following packages:
\itemize{
  \item shiny - Web application framework
  \item TAM - IRT model estimation
  \item magrittr - Pipe operator
  \item jsonlite - JSON handling
  \item DT - Interactive tables
  \item ggplot2 - Plotting
  \item uuid - UUID generation (optional)
  \item logr - Logging (optional)
}

\strong{Data Requirements:} Make sure any referenced data objects (item banks,
configuration variables) are defined before running the generated script.
}
\examples{
\dontrun{
# Basic usage - returns script as string
library(inrep)
data(bfi_items)

config <- create_study_config(
  name = "Personality Assessment", 
  model = "GRM",
  max_items = 10,
  theme = "hildesheim"
)

# Method 1: Get script as string
script <- inrep_code(launch_study(config, bfi_items))
writeLines(script, "my_assessment.R")

# Method 2: Auto-save to file (easiest!)
inrep_code(launch_study(config, bfi_items), 
           output_file = "personality_test")  # .R added automatically

# Method 3: Save with auto-run enabled
inrep_code(launch_study(config, bfi_items),
           output_file = "C:/Projects/auto_launch_app.R",
           auto_run = TRUE)  # Will launch immediately when run!

# Method 4: Console-ready for copy-paste deployment  
script <- inrep_code(launch_study(config, bfi_items), 
                     console_ready = TRUE)
# Copy the output and paste directly into any R console

# Method 5: Cloud storage with all features
webdav_url <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
password <- "inreptest"

inrep_code(
  launch_study(config, bfi_items, 
               webdav_url = webdav_url, 
               password = password),
  output_file = "cloud_assessment.R",
  auto_run = TRUE,
  console_ready = TRUE
)

# Method 6: Quick deployment workflow
# Step 1: Generate script
inrep_code(launch_study(config, bfi_items), "quick_deploy", auto_run = TRUE)
# Step 2: Run it!
source("quick_deploy.R")

# Advanced example with custom study
advanced_config <- create_study_config(
  name = "Advanced Study",
  model = "2PL",
  max_items = 20,
  min_SEM = 0.25,
  demographics = c("Age", "Gender"),
  theme = "midnight",
  session_save = TRUE
)

# Deploy to specific folder with all options
inrep_code(
  launch_study(advanced_config, bfi_items, 
               study_key = "ADVANCED_2025",
               save_format = "json"),
  output_file = "~/Desktop/advanced_study.R",
  auto_run = TRUE,
  console_ready = TRUE
)
}
}
\seealso{
\code{\link{launch_study}} for running assessments,
\code{\link{create_study_config}} for configuration,
\code{\link{validate_item_bank}} for item bank validation
}
