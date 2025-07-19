## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)


## -----------------------------------------------------------------------------
library(inrep)

# View available themes
get_builtin_themes()


## -----------------------------------------------------------------------------
config_professional <- create_study_config(
  name = "Leadership Assessment",
  theme = "professional",
  colors = list(
    primary = "#2E5984",
    secondary = "#8EADC7",
    background = "#FFFFFF",
    text = "#333333"
  )
)


## -----------------------------------------------------------------------------
config_academic <- create_study_config(
  name = "Cognitive Research Study",
  theme = "academic",
  colors = list(
    primary = "#8B0000",
    secondary = "#CD853F",
    background = "#FFFEF7"
  )
)


## -----------------------------------------------------------------------------
config_modern <- create_study_config(
  name = "Innovation Assessment",
  theme = "modern",
  colors = list(
    primary = "#4A90E2",
    secondary = "#7ED321",
    accent = "#F5A623"
  )
)


## -----------------------------------------------------------------------------
# Scrape university website for theme
result <- scrape_website_ui("https://www.uni-hildesheim.de/")

# View extracted themes
for (i in seq_along(result$themes)) {
  theme <- result$themes[[i]]
  cat(sprintf("Theme %d: %s (Primary: %s)\\n", 
              i, theme$name, theme$primary_color))
}


## -----------------------------------------------------------------------------
# Use the first extracted theme
config_scraped <- create_study_config(
  name = "University Research Study",
  theme_config = result$themes[[1]]
)

# Launch with multiple theme options
launch_study(config_scraped, bfi_items, theme_options = result$themes)


## -----------------------------------------------------------------------------
# Scrape with specific targeting
result_advanced <- scrape_website_ui(
  url = "https://www.university.edu/",
  extract_options = list(
    target_elements = c("header", "navigation", "main"),
    include_fonts = TRUE,
    include_logos = TRUE,
    color_palette_size = 5
  )
)


## -----------------------------------------------------------------------------
custom_theme <- list(
  name = "Corporate Blue",
  primary_color = "#0066CC",
  secondary_color = "#99CCFF", 
  background_color = "#F8F9FA",
  text_color = "#212529",
  accent_color = "#FF6B35",
  
  fonts = list(
    heading = "Roboto Slab",
    body = "Open Sans",
    monospace = "Source Code Pro"
  ),
  
  styling = list(
    border_radius = "8px",
    box_shadow = "0 2px 4px rgba(0,0,0,0.1)",
    button_style = "solid",
    input_style = "outlined"
  )
)

config_custom <- create_study_config(
  name = "Custom Branded Assessment",
  theme_config = custom_theme
)


## -----------------------------------------------------------------------------
# University branding example
uni_theme <- list(
  name = "University of Excellence",
  primary_color = "#8B0000",        # University red
  secondary_color = "#FFD700",      # University gold
  background_color = "#FFFFFF",
  
  logo = list(
    url = "https://university.edu/logo.png",
    position = "header-left",
    max_height = "60px"
  ),
  
  fonts = list(
    heading = "Georgia",            # Serif for headings
    body = "Arial"                  # Sans-serif for body
  ),
  
  footer = list(
    text = "© 2025 University of Excellence",
    links = list(
      "Privacy Policy" = "https://university.edu/privacy",
      "Contact" = "mailto:research@university.edu"
    )
  )
)


## -----------------------------------------------------------------------------
config_css <- create_study_config(
  name = "Fully Custom Assessment",
  custom_css = "
    .assessment-container {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }
    
    .question-card {
      backdrop-filter: blur(10px);
      background: rgba(255, 255, 255, 0.9);
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    
    .btn-primary {
      background: linear-gradient(45deg, #667eea, #764ba2);
      border: none;
      transition: transform 0.2s;
    }
    
    .btn-primary:hover {
      transform: translateY(-2px);
    }
  "
)


## -----------------------------------------------------------------------------
# Multiple theme options
theme_light <- list(name = "Light", primary_color = "#007bff")
theme_dark <- list(name = "Dark", primary_color = "#343a40", 
                   background_color = "#212529", text_color = "#ffffff")
theme_high_contrast <- list(name = "High Contrast", 
                           primary_color = "#000000", 
                           background_color = "#ffffff")

config_multi <- create_study_config(
  name = "Accessible Assessment",
  theme_options = list(theme_light, theme_dark, theme_high_contrast),
  allow_theme_switching = TRUE
)


## -----------------------------------------------------------------------------
accessible_theme <- list(
  name = "High Contrast",
  primary_color = "#000000",
  secondary_color = "#FFFFFF", 
  background_color = "#FFFFFF",
  text_color = "#000000",
  
  accessibility = list(
    high_contrast = TRUE,
    large_fonts = TRUE,
    focus_indicators = "enhanced",
    screen_reader_optimized = TRUE
  )
)


## -----------------------------------------------------------------------------
config_accessible <- create_study_config(
  name = "Accessible Assessment",
  accessibility_features = list(
    font_size_options = c("small", "medium", "large", "extra-large"),
    default_font_size = "medium",
    dyslexia_friendly_font = TRUE
  )
)


## -----------------------------------------------------------------------------
responsive_config <- create_study_config(
  name = "Mobile-Friendly Assessment",
  responsive_design = list(
    mobile_optimized = TRUE,
    tablet_layout = "adaptive",
    desktop_layout = "full-width"
  ),
  
  mobile_settings = list(
    swipe_navigation = TRUE,
    touch_friendly_buttons = TRUE,
    auto_zoom_prevention = TRUE
  )
)


## -----------------------------------------------------------------------------
# Launch theme editor for testing
launch_theme_editor(
  themes = list(theme_light, theme_dark, custom_theme),
  sample_content = "assessment_preview"
)


## -----------------------------------------------------------------------------
# Test multiple themes with participants
config_ab_test <- create_study_config(
  name = "Theme Comparison Study",
  ab_test_themes = list(
    control = theme_light,
    treatment = theme_dark
  ),
  ab_test_ratio = 0.5  # 50/50 split
)


## -----------------------------------------------------------------------------
# Fortune 500 company assessment
corporate_config <- create_study_config(
  name = "Leadership Development Assessment",
  
  theme_config = list(
    name = "Corporate Excellence",
    primary_color = "#003366",      # Navy blue
    secondary_color = "#0066CC",    # Light blue
    accent_color = "#FF6600",       # Orange accent
    
    logo = list(
      url = "https://company.com/logo.svg",
      position = "header-center"
    ),
    
    branding = list(
      company_name = "ExampleCorp",
      tagline = "Excellence in Leadership",
      footer_text = "Confidential Assessment"
    )
  ),
  
  styling = list(
    professional_layout = TRUE,
    progress_indicator = "bar",
    question_numbering = "hidden"
  )
)


## -----------------------------------------------------------------------------
# University research study
research_config <- create_study_config(
  name = "Cognitive Psychology Research",
  
  theme_config = list(
    name = "Academic Research",
    primary_color = "#8B0000",
    background_color = "#FFFEF7",
    
    header = list(
      title = "Department of Psychology",
      subtitle = "Research Study Participation",
      institutional_logo = TRUE
    )
  ),
  
  research_features = list(
    participant_id_visible = FALSE,
    progress_hidden = TRUE,
    neutral_styling = TRUE
  )
)


## -----------------------------------------------------------------------------
# Healthcare/clinical setting
clinical_config <- create_study_config(
  name = "Patient Assessment Tool",
  
  theme_config = list(
    name = "Healthcare Professional",
    primary_color = "#0F4C81",      # Medical blue
    secondary_color = "#E8F4FD",    # Light blue
    
    clinical_styling = list(
      clean_interface = TRUE,
      minimal_distractions = TRUE,
      professional_fonts = TRUE
    )
  ),
  
  privacy_features = list(
    no_external_resources = TRUE,
    secure_styling = TRUE,
    hipaa_compliant = TRUE
  )
)


## -----------------------------------------------------------------------------
# Optimize for performance
optimized_config <- create_study_config(
  name = "High-Performance Assessment",
  
  performance_optimization = list(
    minimize_css = TRUE,
    lazy_load_images = TRUE,
    cache_fonts = TRUE,
    compress_assets = TRUE
  )
)

