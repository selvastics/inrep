# HILFO STUDY - COMPLETELY CLEAN VERSION
# No JavaScript conflicts, perfect language switching

# Load required packages
if (!requireNamespace("inrep", quietly = TRUE)) {
  if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
  devtools::install_github("selvastics/inrep", ref = "master")
}
library(inrep)

# Session UUID
session_uuid <- paste0("HILFO_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Cloud storage
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"

# Load the complete item bank from the backup
source("/workspace/case_studies/hildesheim_study/HilFo.R.backup", local = TRUE)

# The backup already has:
# - all_items_de with Question_EN column (bilingual item bank)
# - demographic_configs with question_en and options_en
# - custom_page_flow with all 22 pages
# - input_types configuration

# Launch with ONLY inrep's built-in bilingual support
cat("Launching HILFO Study with Clean Bilingual Support...\n")

inrep::launch_study(
  config = study_config,  # From the backup file
  item_bank = all_items_de,  # Bilingual item bank with Question_EN
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
)