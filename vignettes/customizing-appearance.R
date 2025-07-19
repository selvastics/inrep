## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.width = 8,
  fig.height = 6
)
library(inrep)


## ----builtin_themes-----------------------------------------------------------
# Explore available themes
available_themes <- get_builtin_themes()
cat("Available built-in themes:\n")
print(available_themes)


## ----theme_usage, eval=FALSE--------------------------------------------------
# # Modern professional theme
# config_modern <- create_study_config(
#   name = "Modern Assessment",
#   theme = "modern",
#   model = "2PL"
# )
# 
# # Academic institution theme
# config_academic <- create_study_config(
#   name = "University Research Study",
#   theme = "academic",
#   model = "2PL"
# )
# 
# # Healthcare/clinical theme
# config_clinical <- create_study_config(
#   name = "Clinical Assessment",
#   theme = "healthcare",
#   model = "GRM"
# )
# 
# # Minimalist theme for focus
# config_minimal <- create_study_config(
#   name = "Focus Assessment",
#   theme = "minimal",
#   model = "2PL"
# )
# 
# launch_study(config_modern, bfi_items)


## ----color_customization, eval=FALSE------------------------------------------
# # Custom color scheme
# custom_colors <- create_study_config(
#   name = "Brand Colors Assessment",
#   theme = "modern",
#   custom_ui_pre = list(
#     # Primary brand colors
#     primary_color = "#1E3A8A",      # Deep blue
#     secondary_color = "#F59E0B",     # Amber
#     success_color = "#10B981",       # Emerald
#     warning_color = "#F59E0B",       # Amber
#     danger_color = "#EF4444",        # Red
# 
#     # Background and text
#     background_color = "#F8FAFC",    # Light gray
#     text_color = "#1F2937",          # Dark gray
# 
#     # UI elements
#     button_color = "#1E3A8A",
#     button_hover_color = "#1E40AF",
#     card_background = "#FFFFFF",
#     border_color = "#E5E7EB"
#   )
# )


## ----typography, eval=FALSE---------------------------------------------------
# # Custom fonts and typography
# typography_config <- create_study_config(
#   name = "Typography Showcase",
#   theme = "modern",
#   custom_ui_pre = list(
#     # Font families
#     header_font = "'Roboto Slab', serif",
#     body_font = "'Open Sans', sans-serif",
# 
#     # Font sizes
#     title_size = "2.5rem",
#     header_size = "1.8rem",
#     body_size = "1.1rem",
#     small_size = "0.9rem",
# 
#     # Font weights
#     title_weight = "700",
#     header_weight = "600",
#     body_weight = "400",
# 
#     # Line height for readability
#     line_height = "1.6"
#   )
# )


## ----layout_customization, eval=FALSE-----------------------------------------
# # Custom layout configuration
# layout_config <- create_study_config(
#   name = "Custom Layout",
#   theme = "modern",
#   custom_ui_pre = list(
#     # Container settings
#     max_width = "900px",             # Responsive max width
#     container_padding = "2rem",      # Internal spacing
# 
#     # Card and section spacing
#     card_padding = "2rem",
#     section_margin = "1.5rem",
#     element_spacing = "1rem",
# 
#     # Border radius for modern look
#     border_radius = "12px",
#     button_radius = "8px",
# 
#     # Shadows for depth
#     card_shadow = "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
#     button_shadow = "0 2px 4px -1px rgba(0, 0, 0, 0.1)"
#   )
# )


## ----custom_css, eval=FALSE---------------------------------------------------
# # Define custom CSS
# custom_css <- "
# /* Custom header styling */
# .assessment-header {
#   background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
#   color: white;
#   padding: 2rem;
#   text-align: center;
#   border-radius: 12px;
#   margin-bottom: 2rem;
#   box-shadow: 0 8px 32px rgba(0,0,0,0.1);
# }
# 
# .assessment-title {
#   font-size: 2.5rem;
#   font-weight: 700;
#   margin-bottom: 0.5rem;
# }
# 
# .assessment-subtitle {
#   font-size: 1.2rem;
#   opacity: 0.9;
# }
# 
# /* Custom question styling */
# .question-card {
#   background: white;
#   border-radius: 16px;
#   padding: 2.5rem;
#   margin: 2rem 0;
#   box-shadow: 0 10px 30px rgba(0,0,0,0.1);
#   border: 1px solid #e2e8f0;
#   transition: all 0.3s ease;
# }
# 
# .question-card:hover {
#   transform: translateY(-2px);
#   box-shadow: 0 15px 35px rgba(0,0,0,0.15);
# }
# 
# .question-text {
#   font-size: 1.3rem;
#   line-height: 1.6;
#   color: #2d3748;
#   margin-bottom: 2rem;
# }
# 
# /* Custom radio buttons */
# .custom-radio {
#   display: flex;
#   align-items: center;
#   padding: 1rem;
#   margin: 0.5rem 0;
#   border: 2px solid #e2e8f0;
#   border-radius: 8px;
#   cursor: pointer;
#   transition: all 0.2s ease;
# }
# 
# .custom-radio:hover {
#   border-color: #667eea;
#   background-color: #f7fafc;
# }
# 
# .custom-radio input[type='radio'] {
#   margin-right: 1rem;
#   transform: scale(1.2);
# }
# 
# /* Progress indicator */
# .progress-container {
#   background: #f1f5f9;
#   height: 8px;
#   border-radius: 4px;
#   overflow: hidden;
#   margin: 1rem 0;
# }
# 
# .progress-bar {
#   background: linear-gradient(90deg, #667eea, #764ba2);
#   height: 100%;
#   transition: width 0.3s ease;
#   border-radius: 4px;
# }
# 
# /* Responsive design */
# @media (max-width: 768px) {
#   .assessment-header {
#     padding: 1.5rem;
#   }
# 
#   .assessment-title {
#     font-size: 2rem;
#   }
# 
#   .question-card {
#     padding: 1.5rem;
#     margin: 1rem 0;
#   }
# }
# "
# 
# # Apply custom CSS
# css_config <- create_study_config(
#   name = "Custom Styled Assessment",
#   theme = "custom",
#   custom_ui_pre = list(
#     custom_css = custom_css
#   )
# )


## ----interactive_elements, eval=FALSE-----------------------------------------
# # Add interactive feedback and animations
# interactive_config <- create_study_config(
#   name = "Interactive Assessment",
#   theme = "modern",
#   custom_ui_pre = list(
#     # Enable animations
#     enable_animations = TRUE,
# 
#     # Custom JavaScript for interactions
#     custom_js = "
#     // Smooth transitions for question changes
#     $(document).ready(function() {
#       $('.question-container').hide().fadeIn(800);
# 
#       // Add click animations to buttons
#       $('.btn').on('click', function() {
#         $(this).addClass('clicked');
#         setTimeout(() => {
#           $(this).removeClass('clicked');
#         }, 200);
#       });
# 
#       // Progress bar animation
#       function updateProgress(percentage) {
#         $('.progress-bar').animate({
#           width: percentage + '%'
#         }, 500);
#       }
# 
#       // Shake animation for invalid inputs
#       function shakeElement(element) {
#         $(element).addClass('shake');
#         setTimeout(() => {
#           $(element).removeClass('shake');
#         }, 600);
#       }
#     });
# 
#     /* CSS for animations */
#     .clicked {
#       transform: scale(0.95);
#       transition: transform 0.1s ease;
#     }
# 
#     .shake {
#       animation: shake 0.6s ease-in-out;
#     }
# 
#     @keyframes shake {
#       0%, 100% { transform: translateX(0); }
#       25% { transform: translateX(-5px); }
#       75% { transform: translateX(5px); }
#     }
#     "
#   )
# )


## ----accessibility, eval=FALSE------------------------------------------------
# # Comprehensive accessibility configuration
# accessible_config <- create_study_config(
#   name = "Accessible Assessment",
#   theme = "accessible",
#   custom_ui_pre = list(
#     # High contrast colors for visual impairments
#     high_contrast = TRUE,
#     primary_color = "#000080",       # Dark blue
#     background_color = "#FFFFFF",    # Pure white
#     text_color = "#000000",          # Pure black
# 
#     # Larger fonts for readability
#     base_font_size = "18px",
#     button_font_size = "16px",
# 
#     # Enhanced focus indicators
#     focus_color = "#FF6600",         # High-visibility orange
#     focus_width = "3px",
# 
#     # Screen reader support
#     aria_labels = TRUE,
# 
#     # Keyboard navigation
#     keyboard_navigation = TRUE,
# 
#     # Reduced motion for users with vestibular disorders
#     respect_reduced_motion = TRUE
#   )
# )


## ----mobile_design, eval=FALSE------------------------------------------------
# # Mobile-optimized configuration
# mobile_config <- create_study_config(
#   name = "Mobile-Friendly Assessment",
#   theme = "mobile",
#   custom_ui_pre = list(
#     # Touch-friendly button sizes
#     button_height = "60px",
#     button_font_size = "18px",
# 
#     # Larger tap targets
#     radio_button_size = "24px",
#     checkbox_size = "24px",
# 
#     # Simplified layout for small screens
#     single_column_layout = TRUE,
# 
#     # Optimized spacing
#     mobile_padding = "1rem",
#     mobile_margin = "0.75rem",
# 
#     # Fast loading
#     optimize_images = TRUE,
#     minimal_animations = TRUE,
# 
#     # Mobile-specific CSS
#     mobile_css = "
#     @media (max-width: 480px) {
#       .container {
#         padding: 0.5rem;
#       }
# 
#       .question-text {
#         font-size: 1.1rem;
#         line-height: 1.5;
#       }
# 
#       .answer-option {
#         padding: 1rem;
#         margin: 0.5rem 0;
#         font-size: 1rem;
#       }
# 
#       .navigation-buttons {
#         position: fixed;
#         bottom: 0;
#         left: 0;
#         right: 0;
#         background: white;
#         padding: 1rem;
#         border-top: 1px solid #e2e8f0;
#         box-shadow: 0 -2px 10px rgba(0,0,0,0.1);
#       }
#     }
#     "
#   )
# )


## ----branding, eval=FALSE-----------------------------------------------------
# # Complete brand identity integration
# corporate_config <- create_study_config(
#   name = "Corporate Assessment Portal",
#   theme = "corporate",
#   custom_ui_pre = list(
#     # Brand colors
#     brand_primary = "#003366",       # Corporate dark blue
#     brand_secondary = "#0066CC",     # Corporate light blue
#     brand_accent = "#FF6B35",        # Corporate orange
# 
#     # Logo integration
#     logo_url = "https://company.com/logo.png",
#     logo_height = "60px",
#     show_logo_header = TRUE,
#     show_logo_footer = TRUE,
# 
#     # Custom header with company branding
#     custom_header = "
#     <div class='corporate-header'>
#       <div class='logo-container'>
#         <img src='logo.png' alt='Company Logo' class='company-logo'>
#       </div>
#       <div class='header-content'>
#         <h1 class='corporate-title'>Employee Assessment Portal</h1>
#         <p class='corporate-subtitle'>Confidential Assessment - 2024</p>
#       </div>
#     </div>
#     ",
# 
#     # Custom footer
#     custom_footer = "
#     <div class='corporate-footer'>
#       <p>&copy; 2024 Company Name. All rights reserved.</p>
#       <p>For technical support, contact: support@company.com</p>
#     </div>
#     ",
# 
#     # Corporate styling
#     corporate_css = "
#     .corporate-header {
#       background: linear-gradient(135deg, #003366, #0066CC);
#       color: white;
#       padding: 2rem;
#       display: flex;
#       align-items: center;
#       box-shadow: 0 4px 12px rgba(0,0,0,0.15);
#     }
# 
#     .company-logo {
#       height: 60px;
#       margin-right: 2rem;
#     }
# 
#     .corporate-title {
#       font-size: 2rem;
#       margin: 0;
#       font-weight: 300;
#     }
# 
#     .corporate-subtitle {
#       margin: 0.5rem 0 0 0;
#       opacity: 0.9;
#     }
# 
#     .corporate-footer {
#       background: #f8f9fa;
#       padding: 2rem;
#       text-align: center;
#       border-top: 3px solid #003366;
#       margin-top: 3rem;
#     }
#     "
#   )
# )


## ----internationalization, eval=FALSE-----------------------------------------
# # Multi-language configuration
# multilingual_config <- create_study_config(
#   name = "International Assessment",
#   language = "en",  # Default language
#   item_translations = list(
#     # English (default)
#     "en" = list(
#       start_button = "Begin Assessment",
#       next_button = "Next",
#       previous_button = "Previous",
#       submit_button = "Submit",
#       progress_text = "Progress: {current} of {total}",
#       completion_message = "Assessment completed successfully!"
#     ),
# 
#     # Spanish
#     "es" = list(
#       start_button = "Comenzar Evaluación",
#       next_button = "Siguiente",
#       previous_button = "Anterior",
#       submit_button = "Enviar",
#       progress_text = "Progreso: {current} de {total}",
#       completion_message = "¡Evaluación completada exitosamente!"
#     ),
# 
#     # French
#     "fr" = list(
#       start_button = "Commencer l'Évaluation",
#       next_button = "Suivant",
#       previous_button = "Précédent",
#       submit_button = "Soumettre",
#       progress_text = "Progrès: {current} sur {total}",
#       completion_message = "Évaluation terminée avec succès!"
#     ),
# 
#     # German
#     "de" = list(
#       start_button = "Bewertung Beginnen",
#       next_button = "Weiter",
#       previous_button = "Zurück",
#       submit_button = "Einreichen",
#       progress_text = "Fortschritt: {current} von {total}",
#       completion_message = "Bewertung erfolgreich abgeschlossen!"
#     )
#   )
# )


## ----rtl_support, eval=FALSE--------------------------------------------------
# # Right-to-left language support (Arabic, Hebrew, etc.)
# rtl_config <- create_study_config(
#   name = "Arabic Assessment",
#   language = "ar",
#   text_direction = "rtl",
#   custom_ui_pre = list(
#     # RTL-specific styling
#     rtl_css = "
#     .rtl-container {
#       direction: rtl;
#       text-align: right;
#     }
# 
#     .rtl-container .navigation-buttons {
#       flex-direction: row-reverse;
#     }
# 
#     .rtl-container .progress-container {
#       direction: ltr; /* Progress bars still go left-to-right */
#     }
# 
#     .rtl-container .question-number {
#       float: right;
#       margin-left: 0;
#       margin-right: 1rem;
#     }
#     ",
# 
#     # Arabic translations
#     arabic_translations = list(
#       start_button = "ابدأ التقييم",
#       next_button = "التالي",
#       previous_button = "السابق",
#       submit_button = "إرسال",
#       progress_text = "التقدم: {current} من {total}"
#     )
#   )
# )


## ----gamification, eval=FALSE-------------------------------------------------
# # Add gamification to increase engagement
# gamified_config <- create_study_config(
#   name = "Gamified Learning Assessment",
#   theme = "gamified",
#   custom_ui_pre = list(
#     # Enable gamification features
#     show_progress_badges = TRUE,
#     show_encouragement_messages = TRUE,
#     enable_streak_counter = TRUE,
# 
#     # Custom gamification elements
#     gamification_js = "
#     // Achievement system
#     const achievements = {
#       'first_answer': 'First Step!',
#       'streak_5': 'On Fire! 5 in a row',
#       'halfway': 'Halfway There!',
#       'speed_demon': 'Speed Demon!',
#       'perfectionist': 'Perfect Score!'
#     };
# 
#     // Progress celebrations
#     function showAchievement(type) {
#       const message = achievements[type];
#       if (message) {
#         showToast(message, 'success');
#         playSound('achievement');
#       }
#     }
# 
#     // Encouraging messages based on progress
#     const encouragementMessages = [
#       'Great start! Keep going!',
#       'You're doing wonderfully!',
#       'Excellent progress!',
#       'Almost there!',
#       'Outstanding work!'
#     ];
# 
#     function showEncouragement(progress) {
#       const index = Math.floor(progress / 20); // Every 20%
#       if (encouragementMessages[index]) {
#         setTimeout(() => {
#           showToast(encouragementMessages[index], 'info');
#         }, 1000);
#       }
#     }
#     ",
# 
#     # Gamification CSS
#     gamification_css = "
#     .achievement-badge {
#       background: linear-gradient(45deg, #FFD700, #FFA500);
#       color: white;
#       padding: 0.5rem 1rem;
#       border-radius: 20px;
#       font-weight: bold;
#       animation: bounce 0.5s ease-in-out;
#     }
# 
#     .streak-counter {
#       background: #28a745;
#       color: white;
#       padding: 0.3rem 0.8rem;
#       border-radius: 15px;
#       font-size: 0.9rem;
#       position: fixed;
#       top: 20px;
#       right: 20px;
#       z-index: 1000;
#     }
# 
#     @keyframes bounce {
#       0%, 100% { transform: scale(1); }
#       50% { transform: scale(1.1); }
#     }
#     "
#   )
# )


## ----adaptive_ui, eval=FALSE--------------------------------------------------
# # UI that adapts based on user performance
# adaptive_ui_config <- create_study_config(
#   name = "Performance-Adaptive Interface",
#   theme = "adaptive",
#   custom_ui_pre = list(
#     # Performance-based adaptations
#     adaptive_ui_js = "
#     // Monitor user performance and adapt interface
#     let consecutiveIncorrect = 0;
#     let responseTime = [];
# 
#     function adaptInterface(isCorrect, timeSpent) {
#       // Track consecutive incorrect answers
#       if (!isCorrect) {
#         consecutiveIncorrect++;
#       } else {
#         consecutiveIncorrect = 0;
#       }
# 
#       // Track response times
#       responseTime.push(timeSpent);
#       const avgTime = responseTime.reduce((a,b) => a+b) / responseTime.length;
# 
#       // Adapt based on performance
#       if (consecutiveIncorrect >= 3) {
#         // Show encouragement and hints
#         showSupportMessage();
#         enableHintMode();
#       }
# 
#       if (avgTime > 30000) { // Over 30 seconds average
#         // Simplify interface for slower readers
#         simplifyInterface();
#       }
# 
#       if (avgTime < 5000) { // Under 5 seconds average
#         // Add challenge elements for fast users
#         addChallengeElements();
#       }
#     }
# 
#     function showSupportMessage() {
#       $('#support-message').html(
#         '<div class=\"support-card\">' +
#         '<h4>Take Your Time</h4>' +
#         '<p>There\\'s no rush. Read each question carefully and choose the best answer.</p>' +
#         '</div>'
#       ).fadeIn();
#     }
# 
#     function simplifyInterface() {
#       // Increase font sizes
#       $('.question-text').css('font-size', '1.4rem');
#       $('.answer-option').css('font-size', '1.2rem');
# 
#       // Add more spacing
#       $('.question-container').css('line-height', '1.8');
# 
#       // Highlight current question
#       $('.current-question').addClass('highlight-mode');
#     }
#     "
#   )
# )


## ----theme_builder, eval=FALSE------------------------------------------------
# # Launch the interactive theme builder
# launch_theme_editor <- function() {
#   # This would open an interactive Shiny app for theme creation
#   cat("Launching Theme Builder...\n")
#   cat("This tool allows you to:\n")
#   cat("- Preview themes in real-time\n")
#   cat("- Adjust colors, fonts, and layouts\n")
#   cat("- Export custom CSS\n")
#   cat("- Save theme configurations\n")
# 
#   # The actual implementation would be a Shiny app
#   # shinyApp(ui = theme_builder_ui, server = theme_builder_server)
# }
# 
# # Export theme configuration
# export_theme <- function(theme_config, filename) {
#   # Save theme as JSON for reuse
#   jsonlite::write_json(theme_config, filename, pretty = TRUE)
#   cat("Theme exported to:", filename, "\n")
# }
# 
# # Load saved theme
# load_custom_theme <- function(filename) {
#   theme_config <- jsonlite::read_json(filename)
#   return(theme_config)
# }


## ----ux_mistakes, eval=FALSE--------------------------------------------------
# # DON'T: Overwhelming visual design
# bad_design <- create_study_config(
#   theme = "flashy",
#   custom_ui_pre = list(
#     # Too many colors
#     primary_color = "#FF0000",
#     secondary_color = "#00FF00",
#     accent_color = "#0000FF",
# 
#     # Distracting animations
#     enable_particle_effects = TRUE,
#     auto_play_music = TRUE,
# 
#     # Poor readability
#     text_color = "#CCCCCC",
#     background_color = "#333333"
#   )
# )
# 
# # DO: Clean, professional design
# good_design <- create_study_config(
#   theme = "professional",
#   custom_ui_pre = list(
#     # Harmonious color palette
#     primary_color = "#2563EB",     # Professional blue
#     secondary_color = "#64748B",    # Neutral gray
#     background_color = "#F8FAFC",   # Light background
#     text_color = "#1E293B",         # Dark text for contrast
# 
#     # Subtle, helpful animations
#     enable_smooth_transitions = TRUE,
# 
#     # Excellent readability
#     font_family = "'Inter', sans-serif",
#     line_height = "1.6",
#     font_size = "16px"
#   )
# )

