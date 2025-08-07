# Enhanced inrep_code() Examples - Smart Standalone Script Generation
# =====================================================================

library(inrep)

# Load data
data(bfi_items)

# Create study configuration  
config <- create_study_config(
  name = "Enhanced Personality Assessment",
  model = "GRM",
  max_items = 10,
  min_SEM = 0.3,
  session_save = TRUE,
  theme = "hildesheim",
  demographics = c("Age", "Gender"),
  language = "en"
)

# Define WebDAV parameters (optional)
webdav_url <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
password <- "inreptest"

cat("🚀 ENHANCED INREP_CODE() EXAMPLES\n")
cat("=====================================\n\n")

# METHOD 1: Easiest - Auto-save with auto-run
cat("📁 METHOD 1: Auto-save with auto-run (EASIEST!)\n")
inrep_code(
  launch_study(config, bfi_items, webdav_url = webdav_url, password = password),
  output_file = "auto_launch_assessment",  # .R extension added automatically
  auto_run = TRUE  # Will launch immediately when script is run
)
cat("✅ File saved as 'auto_launch_assessment.R' - just run: source('auto_launch_assessment.R')\n\n")

# METHOD 2: Console-ready for copy-paste deployment
cat("📋 METHOD 2: Console-ready copy-paste deployment\n")
console_script <- inrep_code(
  launch_study(config, bfi_items),
  console_ready = TRUE
)
cat("✅ Console-optimized script generated!\n")
cat("📝 To deploy: Copy the 'console_script' variable and paste into any R console\n\n")

# METHOD 3: Save to specific directory with manual launch
cat("💾 METHOD 3: Save to specific directory (manual launch)\n")
inrep_code(
  launch_study(config, bfi_items),
  output_file = file.path(tempdir(), "manual_launch_assessment.R"),
  auto_run = FALSE  # User must uncomment launch line
)
cat("✅ File saved to temp directory - user must uncomment launch line\n\n")

# METHOD 4: All features combined
cat("🎯 METHOD 4: All features combined\n")
inrep_code(
  launch_study(config, bfi_items, 
               webdav_url = webdav_url, 
               password = password,
               study_key = "DEMO_2025",
               save_format = "json"),
  output_file = "comprehensive_assessment.R",
  auto_run = TRUE,
  console_ready = TRUE
)
cat("✅ Comprehensive script with all features enabled!\n\n")

# METHOD 5: Quick workflow demonstration
cat("⚡ METHOD 5: Quick deployment workflow\n")
# Step 1: Generate
inrep_code(
  launch_study(config, bfi_items),
  output_file = "quick_deploy",
  auto_run = TRUE
)
# Step 2: Could immediately run with source("quick_deploy.R")
cat("✅ Quick deployment ready - run with: source('quick_deploy.R')\n\n")

# METHOD 6: Multiple configurations for different purposes
cat("🔄 METHOD 6: Multiple deployment scenarios\n")

# For researchers (manual control)
researcher_config <- create_study_config(
  name = "Research Study", model = "2PL", max_items = 20, theme = "professional"
)
inrep_code(launch_study(researcher_config, bfi_items), 
           output_file = "research_study.R", auto_run = FALSE)

# For quick demos (auto-launch)
demo_config <- create_study_config(
  name = "Demo Study", model = "GRM", max_items = 5, theme = "sunset"
)
inrep_code(launch_study(demo_config, bfi_items), 
           output_file = "demo_study.R", auto_run = TRUE)

# For console deployment (copy-paste ready)
console_config <- create_study_config(
  name = "Console Study", model = "GRM", max_items = 8, theme = "midnight"
)
console_deployment <- inrep_code(launch_study(console_config, bfi_items), 
                                console_ready = TRUE)

cat("✅ Multiple scenarios generated!\n")
cat("   - research_study.R (manual launch)\n")
cat("   - demo_study.R (auto-launch)\n")
cat("   - console_deployment (copy-paste ready)\n\n")

# Summary
cat("📊 DEPLOYMENT SUMMARY\n")
cat("====================\n")
cat("✅ Enhanced inrep_code() features demonstrated:\n")
cat("   🎯 Smart file naming and auto-extension\n")
cat("   🚀 Auto-run mode for immediate deployment\n")
cat("   📋 Console-ready formatting for copy-paste\n")
cat("   💾 Automatic directory creation\n")
cat("   🛡️ Comprehensive error handling\n")
cat("   📖 User-friendly status messages\n")
cat("   🔧 Flexible deployment options\n\n")

cat("🎉 All methods work independently of the inrep package!\n")
cat("📤 Share any generated .R file with collaborators\n")
cat("🌐 Deploy on any R system with basic packages\n")
cat("⚡ Choose the method that fits your workflow best!\n")
