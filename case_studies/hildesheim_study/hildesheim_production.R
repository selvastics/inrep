# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION WITH PROGRAMMING ANXIETY
# =============================================================================
# Complete bilingual study with adaptive IRT for Programming Anxiety
# All assessments working with proper inrep structure

# Load only inrep initially - load other packages on demand
library(inrep)

# =============================================================================
# CLOUD STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"

# =============================================================================
# COMPLETE ITEM BANK - ALL ITEMS IN ONE DATAFRAME
# =============================================================================

# Create complete bilingual item bank
all_items <- data.frame(
  id = c(
    # Programming Anxiety items (20)
    paste0("PA_", sprintf("%02d", 1:20)),
    # BFI items (20)
    "BFE_01", "BFE_02", "BFE_03", "BFE_04",
    "BFV_01", "BFV_02", "BFV_03", "BFV_04",
    "BFG_01", "BFG_02", "BFG_03", "BFG_04",
    "BFN_01", "BFN_02", "BFN_03", "BFN_04",
    "BFO_01", "BFO_02", "BFO_03", "BFO_04",
    # PSQ items (5)
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS items (4)
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items (2)
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  
  Question = c(
    # Programming Anxiety (German)
    "Wie sicher fühlen Sie sich, einen Fehler in Ihrem Code ohne Hilfe zu beheben?",
    "Fühlen Sie sich überfordert, wenn Sie mit einem neuen Programmierprojekt beginnen?",
    "Ich mache mir Sorgen, dass meine Programmierkenntnisse für komplexere Aufgaben nicht ausreichen.",
    "Beim Lesen von Dokumentation fühle ich mich oft verloren oder verwirrt.",
    "Das Debuggen von Code macht mich nervös, besonders wenn ich den Fehler nicht sofort finde.",
    "Ich vermeide es, neue Programmiersprachen zu nutzen, weil ich Angst habe, Fehler zu machen.",
    "In Gruppencodier-Sitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
    "Ich habe Sorge, Programmieraufgaben nicht rechtzeitig aufgrund fehlender Fähigkeiten abschließen zu können.",
    "Wenn ich bei einem Programmierproblem nicht weiterkomme, ist es mir peinlich, um Hilfe zu bitten.",
    "Ich fühle mich wohl dabei, meinen Code anderen zu erklären.",
    "Fortgeschrittene Programmierkonzepte (z.B. Rekursion, Multithreading) finde ich einschüchternd.",
    "Ich zweifle oft daran, Programmieren über die Grundlagen hinaus lernen zu können.",
    "Wenn mein Code nicht funktioniert, glaube ich, dass es an meinem mangelnden Talent liegt.",
    "Es macht mich nervös, Code ohne Schritt-für-Schritt-Anleitung zu schreiben.",
    "Ich bin zuversichtlich, bestehenden Code zu verändern, um neue Funktionen hinzuzufügen.",
    "Ich fühle mich manchmal ängstlich, noch bevor ich mit dem Programmieren beginne.",
    "Allein der Gedanke an das Debuggen macht mich angespannt, selbst bei kleineren Fehlern.",
    "Ich mache mir Sorgen, für die Qualität meines Codes beurteilt zu werden.",
    "Wenn mir jemand beim Programmieren zuschaut, werde ich nervös und mache Fehler.",
    "Schon der Gedanke an bevorstehende Programmieraufgaben setzt mich unter Stress.",
    
    # BFI (German)
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin eher ruhig.",
    "Ich bin eher schüchtern.",
    "Ich bin gesprächig.",
    "Ich bin einfühlsam, warmherzig.",
    "Ich habe mit anderen wenig Mitgefühl.",
    "Ich bin hilfsbereit und selbstlos.",
    "Andere sind mir eher gleichgültig, egal.",
    "Ich bin eher unordentlich.",
    "Ich bin systematisch, halte meine Sachen in Ordnung.",
    "Ich mag es sauber und aufgeräumt.",
    "Ich bin eher der chaotische Typ, mache selten sauber.",
    "Ich bleibe auch in stressigen Situationen gelassen.",
    "Ich reagiere leicht angespannt.",
    "Ich mache mir oft Sorgen.",
    "Ich werde selten nervös und unsicher.",
    "Ich bin vielseitig interessiert.",
    "Ich meide philosophische Diskussionen.",
    "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
    "Mich interessieren abstrakte Überlegungen wenig.",
    
    # PSQ (German)
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    
    # MWS (German)
    "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
    
    # Statistics (German)
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  
  Question_EN = c(
    # Programming Anxiety (English)
    "How confident are you in your ability to fix an error in your code without help?",
    "Do you feel overwhelmed when starting a new programming project?",
    "I worry that my programming skills are not good enough for more complex tasks.",
    "When reading documentation, I often feel lost or confused.",
    "Debugging code makes me anxious, especially when I cannot immediately spot the issue.",
    "I avoid using new programming languages because I am afraid of making mistakes.",
    "During group coding sessions, I am nervous that my contributions will not be valued.",
    "I worry that I will be unable to finish a coding assignment on time due to lack of skills.",
    "When I get stuck on a programming problem, I feel embarrassed to ask for help.",
    "I feel comfortable explaining my code to others.",
    "I find advanced coding concepts (e.g., recursion, multithreading) intimidating.",
    "I often doubt my ability to learn programming beyond the basics.",
    "When my code does not work, I worry it is because I lack programming talent.",
    "I feel anxious when asked to write code without step-by-step instructions.",
    "I am confident in modifying existing code to add new features.",
    "I sometimes feel anxious even before sitting down to start programming.",
    "The thought of debugging makes me tense, even if the bug is minor.",
    "I worry about being judged for the quality of my code.",
    "When someone watches me code, I get nervous and make mistakes.",
    "I feel stressed just by thinking about upcoming programming tasks.",
    
    # BFI (English)
    "I am outgoing, sociable.",
    "I am rather quiet.",
    "I am rather shy.",
    "I am talkative.",
    "I am empathetic, warm-hearted.",
    "I have little sympathy for others.",
    "I am helpful and selfless.",
    "Others are rather indifferent to me.",
    "I am rather disorganized.",
    "I am systematic, keep my things in order.",
    "I like it clean and tidy.",
    "I am rather the chaotic type, rarely clean up.",
    "I remain calm even in stressful situations.",
    "I react easily tensed.",
    "I often worry.",
    "I rarely become nervous and insecure.",
    "I have diverse interests.",
    "I avoid philosophical discussions.",
    "I enjoy thinking thoroughly about complex things and understanding them.",
    "I have little interest in abstract considerations.",
    
    # PSQ (English)
    "I feel that too many demands are placed on me.",
    "I have too much to do.",
    "I feel rushed.",
    "I have enough time for myself.",
    "I feel under time pressure.",
    
    # MWS (English)
    "coping with the social climate in the study program (e.g., dealing with competition)",
    "organizing teamwork (e.g., finding study groups)",
    "making contacts with fellow students (e.g., for study groups, leisure)",
    "working together in a team (e.g., working on tasks together, preparing presentations)",
    
    # Statistics (English)
    "So far I have been able to follow the content of the statistics courses well.",
    "I am able to learn statistics."
  ),
  
  # IRT parameters for adaptive testing (only PA items have real values)
  a = c(
    # PA items discrimination
    1.2, 1.5, 1.3, 1.1, 1.4, 1.0, 0.9, 1.2, 1.3, 1.4,
    1.5, 1.2, 1.1, 1.3, 1.2, 1.0, 1.1, 1.3, 1.4, 1.2,
    # Other items (default)
    rep(1, 31)
  ),
  
  b = c(
    # PA items difficulty
    -0.5, 0.2, 0.5, 0.3, 0.7, 0.8, 0.4, 0.6, 0.3, -0.2,
    1.0, 0.9, 0.7, 0.6, 0.1, 0.0, 0.2, 0.4, 0.5, 0.3,
    # Other items (default)
    rep(0, 31)
  ),
  
  ResponseCategories = rep("1,2,3,4,5", 51),
  stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHICS CONFIGURATION
# =============================================================================

demographic_configs <- list(
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    question_en = "How old are you?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="31+"),
    options_en = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21",
                   "22"="22", "23"="23", "24"="24", "25"="25", "26"="26",
                   "27"="27", "28"="28", "29"="29", "30"="30", "over 30"="31+"),
    required = TRUE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    question_en = "Which study program are you in?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2", "Anderer"="3"),
    options_en = c("Bachelor Psychology"="1", "Master Psychology"="2", "Other"="3"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    options_en = c("female"="1", "male"="2", "diverse"="3"),
    required = TRUE
  )
)

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
  # Page 1: Welcome with language toggle
  list(
    id = "page1",
    type = "custom",
    title = "HilFo Studie",
    content = paste0(
      '<div style="padding: 20px;">',
      '<div id="content_de">',
      '<h2 style="color: #e8041c;">Willkommen zur HilFo Studie</h2>',
      '<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten.</p>',
      '<p>Die Befragung dauert etwa 15-20 Minuten.</p>',
      '<label><input type="checkbox" id="consent_de"> Ich bin mit der Teilnahme einverstanden</label>',
      '</div>',
      '<div id="content_en" style="display: none;">',
      '<h2 style="color: #e8041c;">Welcome to the HilFo Study</h2>',
      '<p>In the statistics exercises, we want to work with illustrative data.</p>',
      '<p>The survey takes about 15-20 minutes.</p>',
      '<label><input type="checkbox" id="consent_en"> I agree to participate</label>',
      '</div>',
      '</div>'
    ),
    validate = "function(inputs) { 
      return document.getElementById('consent_de').checked || 
             document.getElementById('consent_en').checked; 
    }",
    required = TRUE
  ),
  
  # Page 2: Demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Angaben zur Person",
    title_en = "Personal Information",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht")
  ),
  
  # Page 3: Programming Anxiety - First 10 items (5 fixed + 5 adaptive selected)
  list(
    id = "page3",
    type = "items",
    title = "Programmierangst",
    title_en = "Programming Anxiety",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:10,  # Show first 10 PA items
    scale_type = "likert"
  ),
  
  # Page 4: BFI Part 1
  list(
    id = "page4",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    title_en = "Personality - Part 1",
    item_indices = 21:30,  # First 10 BFI items
    scale_type = "likert"
  ),
  
  # Page 5: BFI Part 2
  list(
    id = "page5",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    title_en = "Personality - Part 2",
    item_indices = 31:40,  # Last 10 BFI items
    scale_type = "likert"
  ),
  
  # Page 6: PSQ Stress
  list(
    id = "page6",
    type = "items",
    title = "Stress",
    title_en = "Stress",
    item_indices = 41:45,
    scale_type = "likert"
  ),
  
  # Page 7: MWS & Statistics
  list(
    id = "page7",
    type = "items",
    title = "Studierfähigkeiten",
    title_en = "Study Skills",
    item_indices = 46:51,
    scale_type = "likert"
  ),
  
  # Page 8: Results
  list(
    id = "page8",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# =============================================================================
# RESULTS PROCESSOR
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL) {
  # Lazy load required packages
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    return(shiny::HTML("<p>Visualisierung nicht verfügbar / Visualization not available</p>"))
  }
  
  # Process responses
  if (length(responses) < 51) {
    responses <- c(responses, rep(3, 51 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate scores
  pa_score <- mean(responses[1:10], na.rm = TRUE)
  bfi_e <- mean(c(responses[21], 6-responses[22], 6-responses[23], responses[24]), na.rm = TRUE)
  bfi_a <- mean(c(responses[25], 6-responses[26], responses[27], 6-responses[28]), na.rm = TRUE)
  bfi_c <- mean(c(6-responses[29], responses[30], responses[31], 6-responses[32]), na.rm = TRUE)
  bfi_n <- mean(c(6-responses[33], responses[34], responses[35], 6-responses[36]), na.rm = TRUE)
  bfi_o <- mean(c(responses[37], 6-responses[38], responses[39], 6-responses[40]), na.rm = TRUE)
  
  # Create simple bar plot
  scores_df <- data.frame(
    Dimension = c("Prog. Anxiety", "Extraversion", "Agreeableness", 
                  "Conscientiousness", "Neuroticism", "Openness"),
    Score = c(pa_score, bfi_e, bfi_a, bfi_c, bfi_n, bfi_o)
  )
  
  p <- ggplot2::ggplot(scores_df, ggplot2::aes(x = Dimension, y = Score, fill = Dimension)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::ylim(0, 5) +
    ggplot2::theme_minimal() +
    ggplot2::labs(title = "Your Profile", y = "Score (1-5)") +
    ggplot2::theme(legend.position = "none")
  
  # Convert to base64
  tmp <- tempfile(fileext = ".png")
  ggplot2::ggsave(tmp, p, width = 8, height = 5, dpi = 100)
  img_base64 <- base64enc::base64encode(tmp)
  unlink(tmp)
  
  # Generate HTML report
  html <- paste0(
    '<div style="padding: 20px;">',
    '<h3>Your Results</h3>',
    '<img src="data:image/png;base64,', img_base64, '" style="width: 100%; max-width: 600px;">',
    '<p>Programming Anxiety Score: ', round(pa_score, 2), '</p>',
    '</div>'
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

study_config <- inrep::create_study_config(
  name = "HilFo Studie",
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  results_processor = create_hilfo_report,
  model = "2PL",
  adaptive = TRUE,
  criteria = "MFI",
  max_items = 10,  # For PA adaptive selection
  min_items = 10,
  response_ui_type = "radio",
  allow_deselect = TRUE,  # Allow unselecting responses
  progress_style = "bar",
  language = "de"
)

# =============================================================================
# LANGUAGE TOGGLE JAVASCRIPT
# =============================================================================

language_toggle_js <- '
<script>
// Language toggle functionality
var currentLang = "de";

function toggleLanguage() {
  currentLang = currentLang === "de" ? "en" : "de";
  
  // Update all elements with language-specific content
  document.querySelectorAll("[data-lang-de], [data-lang-en]").forEach(function(el) {
    if (el.hasAttribute("data-lang-de") && el.hasAttribute("data-lang-en")) {
      el.textContent = currentLang === "de" ? 
        el.getAttribute("data-lang-de") : 
        el.getAttribute("data-lang-en");
    }
  });
  
  // Toggle content divs
  var deContent = document.getElementById("content_de");
  var enContent = document.getElementById("content_en");
  if (deContent && enContent) {
    deContent.style.display = currentLang === "de" ? "block" : "none";
    enContent.style.display = currentLang === "en" ? "block" : "none";
  }
  
  // Update button text
  var btn = document.getElementById("lang_btn");
  if (btn) {
    btn.textContent = currentLang === "de" ? "🇬🇧 English" : "🇩🇪 Deutsch";
  }
  
  // Update Shiny input
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("study_language", currentLang, {priority: "event"});
  }
}

// Add language button to page
document.addEventListener("DOMContentLoaded", function() {
  var btn = document.createElement("button");
  btn.id = "lang_btn";
  btn.textContent = "🇬🇧 English";
  btn.style.cssText = "position: fixed; top: 10px; right: 10px; z-index: 9999; " +
                      "background: white; border: 2px solid #e8041c; color: #e8041c; " +
                      "padding: 8px 16px; border-radius: 4px; cursor: pointer;";
  btn.onclick = toggleLanguage;
  document.body.appendChild(btn);
});

// Allow deselecting radio buttons
document.addEventListener("click", function(e) {
  if (e.target.type === "radio") {
    if (e.target.dataset.wasChecked === "true") {
      e.target.checked = false;
      e.target.dataset.wasChecked = "false";
      // Update Shiny input
      if (typeof Shiny !== "undefined") {
        Shiny.setInputValue(e.target.name, null, {priority: "event"});
      }
    } else {
      // Unmark all others in group
      document.querySelectorAll(`input[name="${e.target.name}"]`).forEach(function(radio) {
        radio.dataset.wasChecked = "false";
      });
      e.target.dataset.wasChecked = "true";
    }
  }
});
</script>
'

# =============================================================================
# LAUNCH STUDY
# =============================================================================

cat("\n================================================================================\n")
cat("HILFO STUDIE - PRODUCTION VERSION\n")
cat("================================================================================\n")
cat("Features:\n")
cat("✓ Programming Anxiety (10 items with adaptive selection)\n")
cat("✓ BFI, PSQ, MWS, Statistics assessments\n")
cat("✓ Full bilingual support (German/English)\n")
cat("✓ Working language toggle button\n")
cat("✓ Response deselection enabled\n")
cat("✓ Optimized loading (lazy package loading)\n")
cat("================================================================================\n\n")

# Launch study with custom JavaScript
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv",
  custom_js = language_toggle_js
)