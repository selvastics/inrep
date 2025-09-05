# Absolute minimal test
library(inrep)

# Minimal item bank
item_bank <- data.frame(
  id = c("item1", "item2", "item3"),
  Question = c("Question 1", "Question 2", "Question 3"),
  stringsAsFactors = FALSE
)

# Minimal demographics
demographic_configs <- list(
  age = list(
    question = "How old are you?",
    options = c("18" = "18", "19" = "19", "20" = "20"),
    required = FALSE
  )
)

input_types <- list(
  age = "select"
)

# Minimal page flow - NO CUSTOM PAGES AT ALL
custom_page_flow <- list(
  list(
    id = "page1",
    type = "demographics",
    demographics = c("age")
  ),
  list(
    id = "page2",
    type = "items",
    item_indices = 1:3
  )
)

# Minimal study config
study_config <- inrep::create_study_config(
  name = "Test Study",
  study_key = "test123",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types
)

# Launch
inrep::launch_study(
  config = study_config,
  item_bank = item_bank
)