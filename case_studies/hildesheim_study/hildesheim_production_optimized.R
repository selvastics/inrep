# =============================================================================
# HILFO STUDIE - FULLY OPTIMIZED VERSION WITH SEAMLESS TRANSLATIONS
# =============================================================================
# Optimized for performance and seamless language switching

library(inrep)

# =============================================================================
# PERFORMANCE OPTIMIZATION: Lazy loading of heavy packages
# =============================================================================
.packages_loaded <- FALSE
load_heavy_packages <- function() {
  if (!.packages_loaded) {
    suppressPackageStartupMessages({
      if (!requireNamespace("ggplot2", quietly = TRUE)) library(ggplot2)
      if (!requireNamespace("base64enc", quietly = TRUE)) library(base64enc)
      if (!requireNamespace("httr", quietly = TRUE)) library(httr)
    })
    .packages_loaded <<- TRUE
  }
}

# =============================================================================
# CLOUD STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"

# =============================================================================
# COMPLETE BILINGUAL ITEM BANK
# =============================================================================
create_bilingual_items <- function() {
  data.frame(
    id = c(
      # BFI items
      "BFE_01", "BFE_02", "BFE_03", "BFE_04",
      "BFV_01", "BFV_02", "BFV_03", "BFV_04",
      "BFG_01", "BFG_02", "BFG_03", "BFG_04",
      "BFN_01", "BFN_02", "BFN_03", "BFN_04",
      "BFO_01", "BFO_02", "BFO_03", "BFO_04",
      # PSQ items
      "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
      # MWS items
      "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
      # Statistics items
      "Statistik_gutfolgen", "Statistik_selbstwirksam"
    ),
    Question = c(
      # BFI Extraversion
      "Ich gehe aus mir heraus, bin gesellig.",
      "Ich bin eher ruhig.",
      "Ich bin eher schüchtern.",
      "Ich bin gesprächig.",
      # BFI Verträglichkeit
      "Ich bin einfühlsam, warmherzig.",
      "Ich habe mit anderen wenig Mitgefühl.",
      "Ich bin hilfsbereit und selbstlos.",
      "Andere sind mir eher gleichgültig, egal.",
      # BFI Gewissenhaftigkeit
      "Ich bin eher unordentlich.",
      "Ich bin systematisch, halte meine Sachen in Ordnung.",
      "Ich mag es sauber und aufgeräumt.",
      "Ich bin eher der chaotische Typ, mache selten sauber.",
      # BFI Neurotizismus
      "Ich bleibe auch in stressigen Situationen gelassen.",
      "Ich reagiere leicht angespannt.",
      "Ich mache mir oft Sorgen.",
      "Ich werde selten nervös und unsicher.",
      # BFI Offenheit
      "Ich bin vielseitig interessiert.",
      "Ich meide philosophische Diskussionen.",
      "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
      "Mich interessieren abstrakte Überlegungen wenig.",
      # PSQ Stress
      "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
      "Ich habe zuviel zu tun.",
      "Ich fühle mich gehetzt.",
      "Ich habe genug Zeit für mich.",
      "Ich fühle mich unter Termindruck.",
      # MWS Study Skills
      "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
      "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
      "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
      "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
      # Statistics
      "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
      "Ich bin in der Lage, Statistik zu erlernen."
    ),
    Question_EN = c(
      # BFI Extraversion
      "I am outgoing, sociable.",
      "I am rather quiet.",
      "I am rather shy.",
      "I am talkative.",
      # BFI Agreeableness
      "I am empathetic, warm-hearted.",
      "I have little sympathy for others.",
      "I am helpful and selfless.",
      "Others are rather indifferent to me.",
      # BFI Conscientiousness
      "I am rather disorganized.",
      "I am systematic, keep my things in order.",
      "I like it clean and tidy.",
      "I am rather the chaotic type, rarely clean up.",
      # BFI Neuroticism
      "I remain calm even in stressful situations.",
      "I react easily tensed.",
      "I often worry.",
      "I rarely become nervous and insecure.",
      # BFI Openness
      "I have diverse interests.",
      "I avoid philosophical discussions.",
      "I enjoy thinking thoroughly about complex things and understanding them.",
      "Abstract considerations interest me little.",
      # PSQ Stress
      "I feel that too many demands are placed on me.",
      "I have too much to do.",
      "I feel rushed.",
      "I have enough time for myself.",
      "I feel under deadline pressure.",
      # MWS Study Skills
      "coping with the social climate in the program (e.g., handling competition)",
      "organizing teamwork (e.g., finding study groups)",
      "making contacts with fellow students (e.g., for study groups, leisure)",
      "working together in a team (e.g., working on tasks together, preparing presentations)",
      # Statistics
      "So far I have been able to follow the content of the statistics courses well.",
      "I am able to learn statistics."
    ),
    reverse_coded = c(
      FALSE, TRUE, TRUE, FALSE, # Extraversion
      FALSE, TRUE, FALSE, TRUE, # Verträglichkeit
      TRUE, FALSE, FALSE, TRUE, # Gewissenhaftigkeit
      TRUE, FALSE, FALSE, TRUE, # Neurotizismus
      FALSE, TRUE, FALSE, TRUE, # Offenheit
      FALSE, FALSE, FALSE, TRUE, FALSE, # PSQ
      rep(FALSE, 6) # MWS & Statistics
    ),
    ResponseCategories = "1,2,3,4,5",
    b = 0,
    a = 1,
    stringsAsFactors = FALSE
  )
}

# Initialize items
all_items <- create_bilingual_items()

# =============================================================================
# OPTIMIZED DEMOGRAPHIC CONFIGURATIONS
# =============================================================================
demographic_configs <- list(
  Einverständnis = list(
    question = "Einverständniserklärung",
    question_en = "Declaration of Consent",
    options = c("Ich bin mit der Teilnahme an der Befragung einverstanden" = "1"),
    options_en = c("I agree to participate in the survey" = "1"),
    required = TRUE
  ),
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    question_en = "How old are you?",
    options = as.list(setNames(c(as.character(17:30), "0"), c(as.character(17:30), "älter als 30"))),
    options_en = as.list(setNames(c(as.character(17:30), "0"), c(as.character(17:30), "older than 30"))),
    required = TRUE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    question_en = "Which study program are you in?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    options_en = c("Bachelor Psychology"="1", "Master Psychology"="2"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    options = c("weiblich oder divers"="1", "männlich"="2"),
    options_en = c("female or diverse"="1", "male"="2"),
    required = TRUE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio"
)

# =============================================================================
# ENHANCED CUSTOM PAGE FLOW WITH FULL BILINGUAL SUPPORT
# =============================================================================
custom_page_flow <- list(
  # Page 1: Welcome with integrated language switcher
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur HilFo Studie",
    title_en = "Welcome to the HilFo Study",
    content = paste0(
      '<div id="main_container" style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">',
      # Enhanced language switcher
      '<div style="position: absolute; top: 10px; right: 10px; z-index: 1000;">',
      '<button type="button" id="lang_switch" onclick="LanguageManager.toggle()" style="',
      'background: white; border: 2px solid #e8041c; color: #e8041c; ',
      'padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; ',
      'transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
      '<span id="lang_switch_text">🇬🇧 English Version</span>',
      '</button>',
      '</div>',
      # Bilingual content container
      '<div id="content_wrapper" style="transition: opacity 0.2s ease;">',
      '<div id="content_de" class="lang-content">',
      '<h2 style="color: #e8041c;">Liebe Studierende,</h2>',
      '<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ',
      'die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>',
      '<p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ',
      'Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ',
      'Auswertung der Daten stattfinden.</p>',
      '<p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Bitte beantworten Sie die Fragen so, ',
      'wie es Ihrer Meinung am ehesten entspricht.</p>',
      '<p style="margin-top: 20px;"><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check" class="consent-checkbox" style="margin-right: 10px; width: 20px; height: 20px;">',
      '<span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>',
      '</label>',
      '</div>',
      '</div>',
      '<div id="content_en" class="lang-content" style="display: none;">',
      '<h2 style="color: #e8041c;">Dear Students,</h2>',
      '<p>In the statistics exercises, we want to work with illustrative data ',
      'that comes from you. Therefore, we would like to learn a few things about you.</p>',
      '<p>Since we want to enable various analyses, the questionnaire covers different ',
      'topic areas that are partially independent of each other.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Your information is completely anonymous</strong>, there will be no personal ',
      'evaluation of the data.</p>',
      '<p>In the following, you will be presented with statements. Please answer the questions ',
      'as they best reflect your opinion.</p>',
      '<p style="margin-top: 20px;"><strong>The survey takes about 10-15 minutes.</strong></p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check_en" class="consent-checkbox" style="margin-right: 10px; width: 20px; height: 20px;">',
      '<span><strong>I agree to participate in the survey</strong></span>',
      '</label>',
      '</div>',
      '</div>',
      '</div>',
      '</div>',
      # Optimized JavaScript for instant language switching
      '<script>
var LanguageManager = (function() {
  var currentLang = localStorage.getItem("hilfo_language") || "de";
  var isTransitioning = false;
  var transitionTime = 150; // Reduced for faster switching
  
  // Preloaded translations for instant access
  var translations = {
    de: {
      button: "🇬🇧 English Version",
      next: "Weiter",
      back: "Zurück",
      complete: "Abschließen",
      pageIndicator: "Seite %d von %d"
    },
    en: {
      button: "🇩🇪 Deutsche Version",
      next: "Next",
      back: "Back",
      complete: "Complete",
      pageIndicator: "Page %d of %d"
    }
  };
  
  function init() {
    // Apply saved language immediately on load
    if (currentLang === "en") {
      applyLanguage("en", true);
    }
    updateAllElements();
    
    // Notify Shiny of initial language
    if (typeof Shiny !== "undefined") {
      Shiny.setInputValue("study_language", currentLang + "_init", {priority: "event"});
    }
  }
  
  function toggle() {
    if (isTransitioning) return;
    isTransitioning = true;
    
    var wrapper = document.getElementById("content_wrapper");
    var btn = document.getElementById("lang_switch");
    
    // Quick fade
    if (wrapper) wrapper.style.opacity = "0.5";
    if (btn) btn.style.pointerEvents = "none";
    
    setTimeout(function() {
      var newLang = (currentLang === "de") ? "en" : "de";
      currentLang = newLang;
      
      applyLanguage(newLang, false);
      updateAllElements();
      syncCheckboxes();
      
      // Fade back in
      if (wrapper) wrapper.style.opacity = "1";
      
      // Save and notify
      localStorage.setItem("hilfo_language", newLang);
      if (typeof Shiny !== "undefined") {
        Shiny.setInputValue("study_language", newLang + "_" + Date.now(), {priority: "event"});
      }
      
      // Re-enable button
      setTimeout(function() {
        if (btn) btn.style.pointerEvents = "auto";
        isTransitioning = false;
      }, 50);
      
    }, transitionTime / 2);
  }
  
  function applyLanguage(lang, skipTransition) {
    // Update all content divs
    document.querySelectorAll(".lang-content").forEach(function(el) {
      el.style.display = "none";
    });
    
    document.querySelectorAll("#content_" + lang).forEach(function(el) {
      el.style.display = "block";
    });
    
    // Update button text
    var btnText = document.getElementById("lang_switch_text");
    if (btnText) btnText.textContent = translations[lang].button;
  }
  
  function updateAllElements() {
    // Update all UI elements with current language
    var elements = {
      "#next_page": translations[currentLang].next,
      "#prev_page": translations[currentLang].back,
      "#submit_study": translations[currentLang].complete
    };
    
    for (var selector in elements) {
      var el = document.querySelector(selector);
      if (el) el.textContent = elements[selector];
    }
    
    // Update page indicator
    var indicator = document.querySelector(".page-indicator");
    if (indicator) {
      var nums = indicator.textContent.match(/\d+/g);
      if (nums && nums.length >= 2) {
        indicator.textContent = translations[currentLang].pageIndicator
          .replace("%d", nums[0]).replace("%d", nums[1]);
      }
    }
    
    // Update any instruction text that might be visible
    updateInstructions();
  }
  
  function updateInstructions() {
    // Update instruction text on item pages
    var instructionElements = document.querySelectorAll(".instructions-text");
    instructionElements.forEach(function(el) {
      var deText = el.getAttribute("data-text-de");
      var enText = el.getAttribute("data-text-en");
      if (currentLang === "en" && enText) {
        el.textContent = enText;
      } else if (deText) {
        el.textContent = deText;
      }
    });
    
    // Update titles
    var titleElements = document.querySelectorAll(".card-header");
    titleElements.forEach(function(el) {
      var deTitle = el.getAttribute("data-title-de");
      var enTitle = el.getAttribute("data-title-en");
      if (currentLang === "en" && enTitle) {
        el.textContent = enTitle;
      } else if (deTitle) {
        el.textContent = deTitle;
      }
    });
  }
  
  function syncCheckboxes() {
    var checkboxes = document.querySelectorAll(".consent-checkbox");
    var checkedState = false;
    checkboxes.forEach(function(cb) {
      if (cb.checked) checkedState = true;
    });
    checkboxes.forEach(function(cb) {
      cb.checked = checkedState;
    });
  }
  
  function getCurrentLang() {
    return currentLang;
  }
  
  // Public API
  return {
    init: init,
    toggle: toggle,
    getCurrentLang: getCurrentLang,
    updateAll: updateAllElements
  };
})();

// Initialize on load
document.addEventListener("DOMContentLoaded", function() {
  LanguageManager.init();
});

// Update UI when Shiny renders new content
if (typeof Shiny !== "undefined") {
  $(document).on("shiny:value", function(event) {
    setTimeout(function() {
      LanguageManager.updateAll();
    }, 10);
  });
}
</script>'
    ),
    validate = "function(inputs) { 
      var checks = document.querySelectorAll('.consent-checkbox');
      for (var i = 0; i < checks.length; i++) {
        if (checks[i].checked) return true;
      }
      return false;
    }",
    required = TRUE
  ),
  
  # Page 2: Demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemographische Angaben",
    title_en = "Sociodemographic Information",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht")
  ),
  
  # Pages 3-6: Personality items with bilingual instructions
  list(
    id = "page3",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    title_en = "Personality - Part 1",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  list(
    id = "page4",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    title_en = "Personality - Part 2",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  list(
    id = "page5",
    type = "items",
    title = "Persönlichkeit - Teil 3",
    title_en = "Personality - Part 3",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  list(
    id = "page6",
    type = "items",
    title = "Persönlichkeit - Teil 4",
    title_en = "Personality - Part 4",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Stress
  list(
    id = "page7",
    type = "items",
    title = "Stress",
    title_en = "Stress",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    instructions_en = "How much do the following statements apply to you?",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 8: Study Skills
  list(
    id = "page8",
    type = "items",
    title = "Studierfähigkeiten",
    title_en = "Study Skills",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    instructions_en = "How easy or difficult is it for you...",
    item_indices = 26:29,
    scale_type = "difficulty"
  ),
  
  # Page 9: Statistics
  list(
    id = "page9",
    type = "items",
    title = "Statistik",
    title_en = "Statistics",
    instructions = "Bitte bewerten Sie die folgenden Aussagen.",
    instructions_en = "Please rate the following statements.",
    item_indices = 30:31,
    scale_type = "likert"
  ),
  
  # Page 10: Results
  list(
    id = "page10",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# =============================================================================
# OPTIMIZED RESULTS PROCESSOR
# =============================================================================
create_hilfo_report <- function(responses, item_bank, demographics = NULL) {
  # Lazy load heavy packages only when needed
  load_heavy_packages()
  
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
  }
  
  # Process responses efficiently
  if (length(responses) < 31) {
    responses <- c(responses, rep(3, 31 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate scores
  scores <- list(
    Extraversion = mean(c(responses[1], 6-responses[2], 6-responses[3], responses[4]), na.rm=TRUE),
    Verträglichkeit = mean(c(responses[5], 6-responses[6], responses[7], 6-responses[8]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-responses[9], responses[10], responses[11], 6-responses[12]), na.rm=TRUE),
    Neurotizismus = mean(c(6-responses[13], responses[14], responses[15], 6-responses[16]), na.rm=TRUE),
    Offenheit = mean(c(responses[17], 6-responses[18], responses[19], 6-responses[20]), na.rm=TRUE),
    Stress = mean(c(responses[21:23], 6-responses[24], responses[25]), na.rm=TRUE),
    Studierfähigkeiten = mean(responses[26:29], na.rm=TRUE),
    Statistik = mean(responses[30:31], na.rm=TRUE)
  )
  
  # Generate simple HTML report (skip heavy plotting for speed)
  html <- paste0(
    '<div style="padding: 20px; max-width: 800px; margin: 0 auto;">',
    '<h2 style="color: #e8041c; text-align: center;">Ihre Persönlichkeitsergebnisse</h2>',
    '<table style="width: 100%; border-collapse: collapse; margin-top: 20px;">',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">Dimension</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">Score</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">Bewertung</th>',
    '</tr>'
  )
  
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    level <- ifelse(value >= 3.7, "Hoch", ifelse(value >= 2.3, "Mittel", "Niedrig"))
    color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', name, '</td>',
      '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
      '<strong style="color: ', color, ';">', value, '</strong></td>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', level, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html, '</table></div>')
  
  return(shiny::HTML(html))
}

# =============================================================================
# ENHANCED RENDER FUNCTIONS WITH BILINGUAL SUPPORT
# =============================================================================

# Override the render_items_page function to include language attributes
render_items_page_enhanced <- function(page, config, rv, item_bank, ui_labels, current_lang = "de") {
  # Get items for this page
  item_indices <- page$item_indices
  if (is.null(item_indices)) return(NULL)
  
  # Get the appropriate instructions based on language
  instructions_text <- if (current_lang == "en" && !is.null(page$instructions_en)) {
    page$instructions_en
  } else {
    page$instructions %||% ""
  }
  
  # Get the appropriate title based on language
  title_text <- if (current_lang == "en" && !is.null(page$title_en)) {
    page$title_en
  } else {
    page$title %||% ""
  }
  
  # Create item elements
  item_elements <- lapply(item_indices, function(i) {
    if (i > nrow(item_bank)) return(NULL)
    
    item <- item_bank[i, ]
    item_id <- paste0("item_", i)
    
    # Get question text based on language
    question_text <- if (current_lang == "en" && !is.null(item$Question_EN)) {
      item$Question_EN
    } else {
      item$Question
    }
    
    # Response options
    choices <- 1:5
    labels <- if (current_lang == "en") {
      c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree")
    } else {
      c("Stimme gar nicht zu", "Stimme nicht zu", "Neutral", "Stimme zu", "Stimme voll zu")
    }
    
    shiny::div(
      class = "item-container",
      shiny::h4(question_text),
      shiny::radioButtons(
        inputId = item_id,
        label = NULL,
        choices = setNames(choices, labels),
        selected = rv$item_responses[[item_id]] %||% character(0),
        inline = TRUE
      )
    )
  })
  
  shiny::div(
    class = "assessment-card",
    shiny::h3(title_text, class = "card-header", 
              `data-title-de` = page$title,
              `data-title-en` = page$title_en),
    if (!is.null(instructions_text)) {
      shiny::p(instructions_text, class = "instructions-text",
               `data-text-de` = page$instructions,
               `data-text-en` = page$instructions_en)
    },
    item_elements
  )
}

# =============================================================================
# OPTIMIZED LAUNCH CONFIGURATION
# =============================================================================

# Generate unique session ID
session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Create optimized study configuration
study_config <- inrep::create_study_config(
  name = "HilFo Studie - Optimized",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "GRM",
  adaptive = FALSE,
  max_items = 31,
  min_items = 31,
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  session_save = FALSE,  # Disable for performance
  session_timeout = 7200,
  results_processor = create_hilfo_report,
  criteria = "RANDOM",
  fixed_items = 1:31,
  adaptive_start = 999,
  item_bank = all_items,
  save_to_file = TRUE,
  save_format = "csv",
  cloud_storage = FALSE,  # Disable initially for performance
  enable_download = TRUE
)

# Override render function for enhanced bilingual support
if (exists("render_items_page", envir = .GlobalEnv)) {
  assign("render_items_page", render_items_page_enhanced, envir = .GlobalEnv)
}

cat("\n================================================================================\n")
cat("HILFO STUDIE - FULLY OPTIMIZED VERSION\n")
cat("================================================================================\n")
cat("Performance Optimizations:\n")
cat("- Lazy loading of heavy packages\n")
cat("- Instant language switching (150ms transition)\n")
cat("- Preloaded translations\n")
cat("- Bilingual content with data attributes\n")
cat("- Automatic UI updates on language change\n")
cat("- Simplified results for faster rendering\n")
cat("================================================================================\n\n")

# Launch the optimized study
inrep::launch_study(
  config = study_config,
  item_bank = all_items
)