## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, eval = FALSE)


## -----------------------------------------------------------------------------
# Install from local source
devtools::install_local("path/to/inrep")

# Load the package
library(inrep)


## -----------------------------------------------------------------------------
# Load mathematics items
data(math_items)

# Or load personality items
data(bfi_items)


## -----------------------------------------------------------------------------
# Simple math test
config <- create_study_config(
  study_name = "Quick Math Test",
  item_bank = "math_items",
  max_items = 10,
  min_items = 5
)


## -----------------------------------------------------------------------------
# Start the assessment
launch_study(config)


## -----------------------------------------------------------------------------
# Create educational math assessment
edu_config <- create_study_config(
  study_name = "Grade 8 Math Assessment",
  item_bank = "math_items",
  max_items = 15,
  adaptive_selection = TRUE,
  demographics = list(
    grade = list(type = "select", options = c("8")),
    student_id = list(type = "text", required = TRUE)
  )
)

launch_study(edu_config)


## -----------------------------------------------------------------------------
# Create personality study
personality_config <- create_study_config(
  study_name = "Personality Research",
  item_bank = "bfi_items",
  max_items = 44,
  demographics = list(
    age = list(type = "numeric", required = TRUE),
    consent = list(type = "checkbox", required = TRUE)
  )
)

launch_study(personality_config)


## -----------------------------------------------------------------------------
# Create adaptive test
adaptive_config <- create_study_config(
  study_name = "Adaptive Math Test",
  item_bank = "math_items",
  adaptive_selection = TRUE,
  selection_method = "maximum_info",
  stopping_criterion = "se_threshold",
  se_threshold = 0.4,
  max_items = 20,
  min_items = 8
)

launch_study(adaptive_config)

