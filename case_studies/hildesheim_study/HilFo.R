# HILFO STUDY - MINIMAL WORKING VERSION WITH PERFECT LANGUAGE SWITCHING

# Load required packages
library(inrep)

# Session UUID for unique identification
session_uuid <- paste0("HILFO_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Cloud storage credentials
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"

# Create bilingual item bank (simplified for testing)
all_items_de <- data.frame(
  id = c(
    paste0("PA_", sprintf("%02d", 1:5)),  # Just 5 programming anxiety items for testing
    "BFE_01", "BFE_02", "BFE_03", "BFE_04", "BFE_05"  # Just 5 BFI items for testing
  ),
  Question = c(
    # Programming Anxiety (German)
    "Ich fühle mich unsicher, wenn ich programmieren soll.",
    "Der Gedanke, programmieren zu lernen, macht mich nervös.",
    "Ich habe Angst, beim Programmieren Fehler zu machen.",
    "Ich fühle mich überfordert, wenn ich an Programmieraufgaben denke.",
    "Ich bin besorgt, dass ich nicht gut genug programmieren kann.",
    # BFI Extraversion (German)
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin eher ruhig.",
    "Ich bin eher schüchtern.",
    "Ich bin gesprächig.",
    "Ich bin kontaktfreudig."
  ),
  Question_EN = c(
    # Programming Anxiety (English)
    "I feel uncertain when I have to program.",
    "The thought of learning to program makes me nervous.",
    "I am afraid of making mistakes when programming.",
    "I feel overwhelmed when I think about programming tasks.",
    "I am worried that I am not good enough at programming.",
    # BFI Extraversion (English)
    "I am outgoing, sociable.",
    "I am rather quiet.",
    "I am rather shy.",
    "I am talkative.",
    "I am sociable."
  ),
  a = rep(1.2, 10),  # Discrimination parameters
  b = seq(-1, 1, length.out = 10),  # Difficulty parameters
  stringsAsFactors = FALSE
)

# Simple demographics
demographic_configs <- list(
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    question_en = "How old are you?",
    options = c("18"="18", "19"="19", "20"="20", "21"="21", "22"="22", "älter"="23"),
    options_en = c("18"="18", "19"="19", "20"="20", "21"="21", "22"="22", "older"="23"),
    required = FALSE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    question_en = "Which study program are you in?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    options_en = c("Bachelor Psychology"="1", "Master Psychology"="2"),
    required = FALSE
  )
)

input_types <- list(
  Alter_VPN = "radio",
  Studiengang = "radio"
)

# Custom page flow with perfect page 1
custom_page_flow <- list(
  # Page 1: Perfect welcome page with bilingual content
  list(
    id = "page1",
    type = "custom",
    title = "HilFo",
    title_en = "HilFo",
    content = '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">
      <div style="position: absolute; top: 10px; right: 10px;">
        <button type="button" onclick="toggleLanguage()" style="
          background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text">English Version</span></button>
      </div>
      
      <div id="content_de">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Willkommen zur HilFo Studie</h1>
        <h2 style="color: #e8041c;">Liebe Studierende,</h2>
        <p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten.</p>
        <p><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <h3 style="color: #e8041c;">Einverständniserklärung</h3>
        <p style="margin-bottom: 20px;">
          <input type="checkbox" id="consent_check" style="margin-right: 10px; transform: scale(1.2);">
          <label for="consent_check">Ich bin mit der Teilnahme an der Befragung einverstanden</label>
        </p>
      </div>
      
      <div id="content_en" style="display: none;">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Welcome to the HilFo Study</h1>
        <h2 style="color: #e8041c;">Dear Students,</h2>
        <p>In the statistics exercises, we want to work with illustrative data.</p>
        <p><strong>The survey takes about 10-15 minutes.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <h3 style="color: #e8041c;">Declaration of Consent</h3>
        <p style="margin-bottom: 20px;">
          <input type="checkbox" id="consent_check_en" style="margin-right: 10px; transform: scale(1.2);">
          <label for="consent_check_en">I agree to participate in the survey</label>
        </p>
      </div>
    </div>
    
    <script>
    // Perfect Page 1 Language System (from working version)
    function toggleLanguage() {
      var deContent = document.getElementById("content_de");
      var enContent = document.getElementById("content_en");
      var textSpan = document.getElementById("lang_switch_text");
      
      if (deContent && enContent) {
        if (deContent.style.display === "none") {
          // Switch to German
          deContent.style.display = "block";
          enContent.style.display = "none";
          if (textSpan) textSpan.textContent = "English Version";
        } else {
          // Switch to English
          deContent.style.display = "none";
          enContent.style.display = "block";
          if (textSpan) textSpan.textContent = "Deutsche Version";
        }
        
        // Sync checkbox states
        var deCheck = document.getElementById("consent_check");
        var enCheck = document.getElementById("consent_check_en");
        if (deCheck && enCheck) {
          enCheck.checked = deCheck.checked;
          deCheck.checked = enCheck.checked;
        }
        
        // Notify inrep system
        var currentLang = (deContent.style.display === "none") ? "en" : "de";
        if (typeof Shiny !== "undefined" && Shiny.setInputValue) {
          Shiny.setInputValue("study_language", currentLang, {priority: "event"});
          Shiny.setInputValue("store_language_globally", currentLang, {priority: "event"});
        }
      }
    }
    
    // Initialize checkbox sync
    document.addEventListener("DOMContentLoaded", function() {
      var deCheck = document.getElementById("consent_check");
      var enCheck = document.getElementById("consent_check_en");
      
      if (deCheck && enCheck) {
        deCheck.addEventListener("change", function() {
          enCheck.checked = deCheck.checked;
        });
        enCheck.addEventListener("change", function() {
          deCheck.checked = enCheck.checked;
        });
      }
    });
    </script>',
    validate = "function(inputs) { 
      try {
        var deCheck = document.getElementById('consent_check');
        var enCheck = document.getElementById('consent_check_en');
        return Boolean((deCheck && deCheck.checked) || (enCheck && enCheck.checked));
      } catch(e) {
        return false;
      }
    }",
    required = FALSE
  ),
  
  # Page 2: Simple demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemographische Angaben",
    title_en = "Sociodemographic Information",
    demographics = c("Alter_VPN", "Studiengang")
  ),
  
  # Page 3: Programming Anxiety items
  list(
    id = "page3",
    type = "items",
    title = "Programmierangst",
    title_en = "Programming Anxiety",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4: BFI items
  list(
    id = "page4",
    type = "items",
    title = "Persönlichkeit",
    title_en = "Personality",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 5: Results
  list(
    id = "page5",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# Create study configuration
study_config <- inrep::create_study_config(
  name = "HilFo - Minimal Test Version",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "2PL",
  adaptive = FALSE,  # Non-adaptive for testing
  max_items = 10,
  min_items = 10,
  criteria = "MFI",
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  bilingual = TRUE,  # This is the key - enables inrep's built-in bilingual support
  custom_js = "
    // HILFO Assessment-Only Language System
    // Page 1 is left completely alone - only translate assessment pages
    console.log('HILFO Assessment Language System Loading...');
    
    // Question mappings for assessment pages only
    window.assessmentMappings = {
      'Ich fühle mich unsicher, wenn ich programmieren soll.': 'I feel uncertain when I have to program.',
      'Der Gedanke, programmieren zu lernen, macht mich nervös.': 'The thought of learning to program makes me nervous.',
      'Ich habe Angst, beim Programmieren Fehler zu machen.': 'I am afraid of making mistakes when programming.',
      'Ich fühle mich überfordert, wenn ich an Programmieraufgaben denke.': 'I feel overwhelmed when I think about programming tasks.',
      'Ich bin besorgt, dass ich nicht gut genug programmieren kann.': 'I am worried that I am not good enough at programming.',
      'Ich gehe aus mir heraus, bin gesellig.': 'I am outgoing, sociable.',
      'Ich bin eher ruhig.': 'I am rather quiet.',
      'Ich bin eher schüchtern.': 'I am rather shy.',
      'Ich bin gesprächig.': 'I am talkative.',
      'Ich bin kontaktfreudig.': 'I am sociable.',
      'Wie alt sind Sie?': 'How old are you?',
      'In welchem Studiengang befinden Sie sich?': 'Which study program are you in?',
      'Bachelor Psychologie': 'Bachelor Psychology',
      'Master Psychologie': 'Master Psychology',
      'Bitte wählen...': 'Please select...',
      'Stimme überhaupt nicht zu': 'Strongly disagree',
      'Stimme nicht zu': 'Disagree',
      'Weder noch': 'Neither agree nor disagree',
      'Stimme zu': 'Agree',
      'Stimme voll zu': 'Strongly agree',
      'Soziodemographische Angaben': 'Sociodemographic Information',
      'Programmierangst': 'Programming Anxiety',
      'Persönlichkeit': 'Personality',
      'Ihre Ergebnisse': 'Your Results'
    };
    
    // Track current language (starts with German)
    window.currentAssessmentLanguage = 'de';
    
    // Listen for language changes from page 1 ONLY
    document.addEventListener('DOMContentLoaded', function() {
      // Add language button to assessment pages only (not page 1)
      setTimeout(function() {
        var isPage1 = document.getElementById('content_de') && document.getElementById('content_en');
        if (!isPage1 && !document.querySelector('.assessment-lang-button')) {
          var btn = document.createElement('div');
          btn.className = 'assessment-lang-button';
          btn.style.cssText = 'position: fixed; top: 10px; right: 10px; z-index: 9999;';
          btn.innerHTML = '<button onclick=\"toggleAssessmentLanguage()\" style=\"background: #e8041c; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold;\"><span class=\"assessment-lang-text\">English Version</span></button>';
          document.body.appendChild(btn);
        }
      }, 200);
    });
    
    // Assessment language toggle (separate from page 1)
    window.toggleAssessmentLanguage = function() {
      // Only work on assessment pages, never on page 1
      var isPage1 = document.getElementById('content_de') && document.getElementById('content_en');
      if (isPage1) {
        console.log('Page 1 detected - assessment language toggle disabled');
        return;
      }
      
      // Toggle assessment language
      window.currentAssessmentLanguage = (window.currentAssessmentLanguage === 'de') ? 'en' : 'de';
      console.log('Assessment language switched to:', window.currentAssessmentLanguage);
      
      var isEnglish = (window.currentAssessmentLanguage === 'en');
      
      // Update button text
      var btn = document.querySelector('.assessment-lang-text');
      if (btn) {
        btn.textContent = isEnglish ? 'Deutsche Version' : 'English Version';
      }
      
      // Translate assessment content
      var selectors = ['h1', 'h2', 'h3', 'h4', 'label', 'span', 'p', 'option', 'div'];
      selectors.forEach(function(selector) {
        var elements = document.querySelectorAll(selector);
        elements.forEach(function(el) {
          var text = el.textContent.trim();
          if (text && window.assessmentMappings[text]) {
            if (isEnglish) {
              el.textContent = window.assessmentMappings[text];
              console.log('Assessment translated:', text, '->', window.assessmentMappings[text]);
            } else {
              // Reverse lookup for German
              for (var german in window.assessmentMappings) {
                if (window.assessmentMappings[german] === text) {
                  el.textContent = german;
                  console.log('Assessment translated back:', text, '->', german);
                  break;
                }
              }
            }
          }
        });
      });
      
      // Notify inrep system about language change
      if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
        Shiny.setInputValue('study_language', window.currentAssessmentLanguage, {priority: 'event'});
        Shiny.setInputValue('store_language_globally', window.currentAssessmentLanguage, {priority: 'event'});
      }
    };
    
    console.log('HILFO Assessment Language System Ready (Page 1 untouched)');
  ",
  session_save = TRUE,
  session_timeout = 7200
)

# Launch the study
cat("Launching HILFO Minimal Test Version...\n")
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,  # Bilingual item bank with Question_EN column
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
)