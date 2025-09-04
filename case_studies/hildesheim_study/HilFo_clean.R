# =============================================================================
# HILFO STUDY - CLEAN VERSION USING INREP CAPABILITIES PROPERLY
# =============================================================================

# Load required packages
suppressPackageStartupMessages({
  library(shiny)
  library(inrep)
  library(jsonlite)
})

# Define the %||% operator for null coalescing
`%||%` <- function(x, y) if (is.null(x)) y else x

# WebDAV configuration
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"

# =============================================================================
# BILINGUAL ITEM BANK - PROPERLY STRUCTURED FOR INREP
# =============================================================================
all_items_de <- data.frame(
  id = paste0("Item_", sprintf("%02d", 1:51)),
  Question = c(
    # Programming Anxiety items (1-20) - German
    "Ich fühle mich unsicher, wenn ich programmieren muss.",
    "Ich vermeide es, neue Programmiersprachen zu lernen.",
    "Ich habe Angst davor, Fehler beim Programmieren zu machen.",
    "Ich fühle mich überfordert, wenn ich komplexe Programmieraufgaben sehe.",
    "Ich bin besorgt, dass ich nicht gut genug programmieren kann.",
    "Ich vermeide es, neue Programmiersprachen zu verwenden, weil ich Angst vor Fehlern habe.",
    "Während Gruppencodingsitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
    "Ich mache mir Sorgen, dass ich eine Programmieraufgabe nicht rechtzeitig fertigstellen kann.",
    "Wenn ich bei einem Programmierproblem feststecke, schäme ich mich, um Hilfe zu bitten.",
    "Ich fühle mich unwohl, wenn ich Code vor anderen präsentieren muss.",
    "Ich vermeide es, an Programmierprojekten teilzunehmen.",
    "Ich fühle mich gestresst, wenn ich programmieren muss.",
    "Ich habe Angst davor, dass andere meinen Code beurteilen.",
    "Ich vermeide es, komplexe Programmieraufgaben zu übernehmen.",
    "Ich fühle mich unsicher, wenn ich Code erklären muss.",
    "Ich habe Angst davor, dass mein Code nicht funktioniert.",
    "Ich vermeide es, an Programmierwettbewerben teilzunehmen.",
    "Ich fühle mich überfordert, wenn ich neue Programmierkonzepte lernen muss.",
    "Ich habe Angst davor, dass ich Programmierfehler nicht beheben kann.",
    "Ich vermeide es, Code zu schreiben, der von anderen gesehen wird.",
    
    # Big Five items (21-40) - German
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin einfühlsam, warmherzig.",
    "Ich bin eher unordentlich.",
    "Ich bleibe auch in stressigen Situationen gelassen.",
    "Ich bin vielseitig interessiert.",
    "Ich bin eher ruhig.",
    "Ich habe mit anderen wenig Mitgefühl.",
    "Ich bin systematisch, halte meine Sachen in Ordnung.",
    "Ich reagiere leicht angespannt.",
    "Ich meide philosophische Diskussionen.",
    "Ich bin eher schüchtern.",
    "Ich bin hilfsbereit und selbstlos.",
    "Ich mag es sauber und aufgeräumt.",
    "Ich mache mir oft Sorgen.",
    "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken.",
    "Ich bin gesprächig.",
    "Andere sind mir eher gleichgültig.",
    "Ich bin eher der chaotische Typ.",
    "Ich werde selten nervös und unsicher.",
    "Mich interessieren abstrakte Überlegungen wenig.",
    
    # Stress items (41-45) - German
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    
    # Study skills items (46-49) - German
    "Mit dem sozialen Klima im Studiengang zurechtzukommen.",
    "Teamarbeit zu organisieren.",
    "Kontakte zu Mitstudierenden zu knüpfen.",
    "Im Team zusammen zu arbeiten.",
    
    # Statistics items (50-51) - German
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  Question_EN = c(
    # Programming Anxiety items (1-20) - English
    "I feel insecure when I have to program.",
    "I avoid learning new programming languages.",
    "I am afraid of making mistakes when programming.",
    "I feel overwhelmed when I see complex programming tasks.",
    "I am worried that I am not good enough at programming.",
    "I avoid using new programming languages because I am afraid of making mistakes.",
    "During group coding sessions, I am nervous that my contributions will not be valued.",
    "I worry that I will be unable to finish a programming assignment on time.",
    "When I get stuck on a programming problem, I feel embarrassed to ask for help.",
    "I feel uncomfortable when I have to present code to others.",
    "I avoid participating in programming projects.",
    "I feel stressed when I have to program.",
    "I am afraid that others will judge my code.",
    "I avoid taking on complex programming tasks.",
    "I feel insecure when I have to explain code.",
    "I am afraid that my code won't work.",
    "I avoid participating in programming competitions.",
    "I feel overwhelmed when I have to learn new programming concepts.",
    "I am afraid that I won't be able to fix programming errors.",
    "I avoid writing code that will be seen by others.",
    
    # Big Five items (21-40) - English
    "I am outgoing, sociable.",
    "I am sympathetic, warm-hearted.",
    "I am rather disorganized.",
    "I remain calm even in stressful situations.",
    "I am interested in many things.",
    "I am rather quiet.",
    "I have little sympathy for others.",
    "I am systematic, keep my things in order.",
    "I react easily with tension.",
    "I avoid philosophical discussions.",
    "I am rather shy.",
    "I am helpful and selfless.",
    "I like things clean and tidy.",
    "I often worry.",
    "I enjoy thinking thoroughly about complex things.",
    "I am talkative.",
    "Others are rather indifferent to me.",
    "I am rather the chaotic type.",
    "I rarely get nervous and insecure.",
    "I have little interest in abstract considerations.",
    
    # Stress items (41-45) - English
    "I feel that too many demands are being made on me.",
    "I have too much to do.",
    "I feel rushed.",
    "I have enough time for myself.",
    "I feel under time pressure.",
    
    # Study skills items (46-49) - English
    "Coping with the social climate in the degree program.",
    "Organizing teamwork.",
    "Making contacts with fellow students.",
    "Working together in a team.",
    
    # Statistics items (50-51) - English
    "So far I have been able to follow the content of the statistics courses well.",
    "I am able to learn statistics."
  ),
  # Response options for 5-point Likert scale
  Option1 = "stimme überhaupt nicht zu",
  Option2 = "stimme nicht zu",
  Option3 = "weder noch",
  Option4 = "stimme eher zu",
  Option5 = "stimme voll und ganz zu",
  stringsAsFactors = FALSE
)

# Set default item bank
all_items <- all_items_de

# =============================================================================
# DEMOGRAPHICS CONFIGURATION - PROPERLY STRUCTURED FOR INREP
# =============================================================================
demographic_configs <- list(
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    question_en = "How old are you?",
    type = "numeric",
    required = TRUE,
    validation_message = "Bitte geben Sie Ihr Alter an.",
    validation_message_en = "Please enter your age."
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    question_en = "What degree program are you in?",
    type = "select",
    options = c("Bachelor Psychologie", "Master Psychologie"),
    options_en = c("Bachelor Psychology", "Master Psychology"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    type = "select",
    options = c("weiblich", "männlich", "divers"),
    options_en = c("female", "male", "diverse"),
    required = TRUE
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    question_en = "How do you live?",
    type = "select",
    options = c("Bei meinen Eltern/Elternteil", "In einer WG/WG in einem Wohnheim", "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim", "Mit meinem/r Partner*In", "Anders"),
    options_en = c("With my parents/parent", "In a shared apartment/dormitory", "Alone/in a separate unit in a dormitory", "With my partner", "Other"),
    required = TRUE
  ),
  Haustier = list(
    question = "Welches Haustier würden Sie gerne halten?",
    question_en = "Which pet would you like to have?",
    type = "select",
    options = c("Hund", "Katze", "Fische", "Vogel", "Nager", "Reptil", "Ich möchte kein Haustier", "Sonstiges"),
    options_en = c("Dog", "Cat", "Fish", "Bird", "Rodent", "Reptile", "I don't want a pet", "Other"),
    required = TRUE
  ),
  Rauchen = list(
    question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
    question_en = "Do you regularly smoke cigarettes, vapes or shisha?",
    type = "select",
    options = c("Ja", "Nein"),
    options_en = c("Yes", "No"),
    required = TRUE
  ),
  Ernährung = list(
    question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
    question_en = "Which type of diet do you identify with most?",
    type = "select",
    options = c("Vegan", "Vegetarisch", "Pescetarisch", "Flexitarisch", "Omnivor (alles)", "Andere"),
    options_en = c("Vegan", "Vegetarian", "Pescetarian", "Flexitarian", "Omnivore (everything)", "Other"),
    required = TRUE
  ),
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    question_en = "How many hours per week do you plan to invest in preparing for and following up on statistics courses?",
    type = "select",
    options = c("0 Stunden", "maximal eine Stunde", "mehr als eine, aber weniger als 2 Stunden", "mehr als zwei, aber weniger als 3 Stunden", "mehr als drei, aber weniger als 4 Stunden", "mehr als 4 Stunden"),
    options_en = c("0 hours", "maximum one hour", "more than one, but less than 2 hours", "more than two, but less than 3 hours", "more than three, but less than 4 hours", "more than 4 hours"),
    required = TRUE
  ),
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
    question_en = "How satisfied are you with your study location Hildesheim? (5-point scale)",
    type = "select",
    options = c("gar nicht zufrieden", "eher nicht zufrieden", "teils-teils", "eher zufrieden", "sehr zufrieden"),
    options_en = c("not at all satisfied", "rather not satisfied", "neither nor", "rather satisfied", "very satisfied"),
    required = TRUE
  ),
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
    question_en = "How satisfied are you with your study location Hildesheim? (7-point scale)",
    type = "select",
    options = c("gar nicht zufrieden", "eher nicht zufrieden", "etwas zufrieden", "teils-teils", "ziemlich zufrieden", "sehr zufrieden", "extrem zufrieden"),
    options_en = c("not at all satisfied", "rather not satisfied", "somewhat satisfied", "neither nor", "quite satisfied", "very satisfied", "extremely satisfied"),
    required = TRUE
  )
)

# =============================================================================
# INPUT TYPES - PROPERLY STRUCTURED FOR INREP
# =============================================================================
input_types <- list(
  Alter_VPN = "numeric",
  Studiengang = "select",
  Geschlecht = "select",
  Wohnstatus = "select",
  Haustier = "select",
  Rauchen = "select",
  Ernährung = "select",
  Vor_Nachbereitung = "select",
  Zufrieden_Hi_5st = "select",
  Zufrieden_Hi_7st = "select"
)

# Add input types for all items
for (i in 1:51) {
  input_types[[paste0("Item_", sprintf("%02d", i))]] <- "radio"
}

# =============================================================================
# CUSTOM PAGE FLOW - USING INREP'S BILINGUAL SYSTEM
# =============================================================================
custom_page_flow <- list(
  # Page 1: Welcome with consent
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur HilFo Studie",
    title_en = "Welcome to the HilFo Study",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h2 style="color: #e8041c;">Liebe Studierende,</h2>',
      '<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ',
      'die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>',
      '<p>Die Befragung dauert etwa 10-15 Minuten.</p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>',
      '</label>',
      '</div>',
      '</div>'
    )
  ),
  
  # Page 2: Demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemographische Angaben",
    title_en = "Sociodemographic Information",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht", "Wohnstatus", "Haustier", "Rauchen", "Ernährung")
  ),
  
  # Page 3: Programming Anxiety items 1-5
  list(
    id = "page3",
    type = "items",
    title = "Programmierangst - Teil 1",
    title_en = "Programming Anxiety - Part 1",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Einstellung zum Programmieren.",
    instructions_en = "Please answer the following questions about your attitude towards programming.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4: Programming Anxiety items 6-10
  list(
    id = "page4",
    type = "items",
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Einstellung zum Programmieren.",
    instructions_en = "Please answer the following questions about your attitude towards programming.",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 5: Programming Anxiety items 11-15
  list(
    id = "page5",
    type = "items",
    title = "Programmierangst - Teil 3",
    title_en = "Programming Anxiety - Part 3",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Einstellung zum Programmieren.",
    instructions_en = "Please answer the following questions about your attitude towards programming.",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 6: Programming Anxiety items 16-20
  list(
    id = "page6",
    type = "items",
    title = "Programmierangst - Teil 4",
    title_en = "Programming Anxiety - Part 4",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Einstellung zum Programmieren.",
    instructions_en = "Please answer the following questions about your attitude towards programming.",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Big Five items 21-30
  list(
    id = "page7",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    title_en = "Personality - Part 1",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Persönlichkeit.",
    instructions_en = "Please answer the following questions about your personality.",
    item_indices = 21:30,
    scale_type = "likert"
  ),
  
  # Page 8: Big Five items 31-40
  list(
    id = "page8",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    title_en = "Personality - Part 2",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrer Persönlichkeit.",
    instructions_en = "Please answer the following questions about your personality.",
    item_indices = 31:40,
    scale_type = "likert"
  ),
  
  # Page 9: Stress items 41-45
  list(
    id = "page9",
    type = "items",
    title = "Stress",
    title_en = "Stress",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihrem Stressempfinden.",
    instructions_en = "Please answer the following questions about your stress perception.",
    item_indices = 41:45,
    scale_type = "likert"
  ),
  
  # Page 10: Study skills items 46-49
  list(
    id = "page10",
    type = "items",
    title = "Studierfähigkeiten",
    title_en = "Study Skills",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihren Studierfähigkeiten.",
    instructions_en = "Please answer the following questions about your study skills.",
    item_indices = 46:49,
    scale_type = "likert"
  ),
  
  # Page 11: Statistics items 50-51
  list(
    id = "page11",
    type = "items",
    title = "Statistik",
    title_en = "Statistics",
    instructions = "Bitte beantworten Sie die folgenden Fragen zu Ihren Statistikkenntnissen.",
    instructions_en = "Please answer the following questions about your statistics knowledge.",
    item_indices = 50:51,
    scale_type = "likert"
  ),
  
  # Page 12: Final demographics
  list(
    id = "page12",
    type = "demographics",
    title = "Abschlussfragen",
    title_en = "Final Questions",
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_5st", "Zufrieden_Hi_7st")
  ),
  
  # Page 13: Results
  list(
    id = "page13",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# =============================================================================
# RESULTS PROCESSOR - USING INREP'S BUILT-IN SYSTEM
# =============================================================================
create_hilfo_report <- function(responses, item_bank, demographics = NULL, rv = NULL, input = NULL, ...) {
  # Get current language
  current_lang <- "de"  # Default to German
  if (!is.null(session) && !is.null(session$userData$current_language)) {
    current_lang <- session$userData$current_language
  }
  
  if (is.null(responses) || length(responses) == 0) {
    return(shiny::HTML('<div class="assessment-card"><h3>Keine Daten verfügbar</h3></div>'))
  }
  
  # Calculate scores
  pa_scores <- responses[1:20]
  bf_scores <- responses[21:40]
  stress_scores <- responses[41:45]
  study_scores <- responses[46:49]
  stat_scores <- responses[50:51]
  
  # Calculate means
  pa_mean <- mean(pa_scores, na.rm = TRUE)
  bf_mean <- mean(bf_scores, na.rm = TRUE)
  stress_mean <- mean(stress_scores, na.rm = TRUE)
  study_mean <- mean(study_scores, na.rm = TRUE)
  stat_mean <- mean(stat_scores, na.rm = TRUE)
  
  # Create results display
  results_html <- paste0(
    '<div class="assessment-card">',
    '<h2 style="color: #e8041c; text-align: center;">',
    if (current_lang == "en") "Your Results" else "Ihre Ergebnisse",
    '</h2>',
    '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">',
    '<h3 style="color: #333;">',
    if (current_lang == "en") "Personality Profile" else "Persönlichkeitsprofil",
    '</h3>',
    '<p><strong>',
    if (current_lang == "en") "Programming Anxiety: " else "Programmierangst: ",
    sprintf("%.2f", pa_mean),
    '</strong></p>',
    '<p><strong>',
    if (current_lang == "en") "Big Five: " else "Big Five: ",
    sprintf("%.2f", bf_mean),
    '</strong></p>',
    '<p><strong>',
    if (current_lang == "en") "Stress: " else "Stress: ",
    sprintf("%.2f", stress_mean),
    '</strong></p>',
    '<p><strong>',
    if (current_lang == "en") "Study Skills: " else "Studierfähigkeiten: ",
    sprintf("%.2f", study_mean),
    '</strong></p>',
    '<p><strong>',
    if (current_lang == "en") "Statistics: " else "Statistik: ",
    sprintf("%.2f", stat_mean),
    '</strong></p>',
    '</div>',
    '<p style="text-align: center; color: #666;">',
    if (current_lang == "en") "Thank you for your participation!" else "Vielen Dank für Ihre Teilnahme!",
    '</p>',
    '</div>'
  )
  
  return(shiny::HTML(results_html))
}

# =============================================================================
# STUDY CONFIGURATION - USING INREP'S BEST PRACTICES
# =============================================================================
study_config <- inrep::create_study_config(
  name = "HilFo Studie",
  study_key = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
  theme = "hildesheim",  # Use built-in Hildesheim theme
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "2PL",  # Use 2PL model for IRT
  adaptive = TRUE,  # Enable adaptive testing
  max_items = 51,  # Total items in bank
  min_items = 51,  # Must show all items
  criteria = "MFI",  # Maximum Fisher Information
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",  # Start with German
  bilingual = TRUE,  # Enable inrep's built-in bilingual support
  session_save = TRUE,
  session_timeout = 7200,
  results_processor = create_hilfo_report,
  estimation_method = "EAP",  # Use EAP for ability estimation
  save_format = "csv"  # Use inrep's built-in save format
)

# =============================================================================
# LAUNCH STUDY - USING INREP'S BUILT-IN CAPABILITIES
# =============================================================================
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,  # Bilingual item bank
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv"
  # No custom CSS needed - inrep handles theming
  # No server extensions needed - inrep handles language switching
  # No admin dashboard hook needed - inrep handles monitoring
)