# =============================================================================
# HILFO STUDY - CLEAN VERSION
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
# ITEM BANK WITH PROPER VARIABLE NAMES
# =============================================================================

# Create bilingual item bank
all_items_de <- data.frame(
  id = c(
    # Programming Anxiety items (20)
    paste0("PA_", sprintf("%02d", 1:20)),
    # BFI items with proper naming convention
    "BFE_01", "BFE_02", "BFE_03", "BFE_04", # Extraversion
    "BFV_01", "BFV_02", "BFV_03", "BFV_04", # Verträglichkeit (Agreeableness)
    "BFG_01", "BFG_02", "BFG_03", "BFG_04", # Gewissenhaftigkeit (Conscientiousness)
    "BFN_01", "BFN_02", "BFN_03", "BFN_04", # Neurotizismus (Neuroticism)
    "BFO_01", "BFO_02", "BFO_03", "BFO_04", # Offenheit (Openness)
    # PSQ stress items
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS study skills items
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  Question = c(
    # Programming Anxiety (German) - First 5 items suitable for all experience levels
    "Ich fühle mich unsicher, wenn ich programmieren soll.",
    "Der Gedanke, programmieren zu lernen, macht mich nervös.",
    "Ich habe Angst, beim Programmieren Fehler zu machen.",
    "Ich fühle mich überfordert, wenn ich an Programmieraufgaben denke.",
    "Ich bin besorgt, dass ich nicht gut genug programmieren kann.",
    "Ich vermeide es, neue Programmiersprachen zu nutzen, weil ich Angst habe, Fehler zu machen.",
    "In Gruppencodier-Sitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
    "Ich habe Sorge, Programmieraufgaben nicht rechtzeitig aufgrund fehlender Fähigkeiten abschließen zu können.",
    "Wenn ich bei einem Programmierproblem nicht weiterkomme, ist es mir peinlich, um Hilfe zu bitten.",
    "Ich fühle mich wohl dabei, meinen Code anderen zu erklären.",
    "Fortgeschrittene Programmierkonzepte (z.B. Rekursion, Multithreading) finde ich einschüchternd.",
    "Ich zweifle oft daran, Programmieren über die Grundlagen hinaus lernen zu können.",
    "Wenn mein Code nicht funktioniert, glaube ich, dass es an meinem mangelnden Talent liegt.",
    "Ich fühle mich ängstlich, wenn ich Code ohne Schritt-für-Schritt-Anweisungen schreiben soll.",
    "Ich bin zuversichtlich, bestehenden Code zu verändern, um neue Funktionen hinzuzufügen.",
    "Ich fühle mich manchmal ängstlich, noch bevor ich mit dem Programmieren beginne.",
    "Allein der Gedanke an das Debuggen macht mich angespannt, selbst bei kleineren Fehlern.",
    "Ich mache mir Sorgen, für die Qualität meines Codes beurteilt zu werden.",
    "Wenn mir jemand beim Programmieren zuschaut, werde ich nervös und mache Fehler.",
    "Schon der Gedanke an bevorstehende Programmieraufgaben setzt mich unter Stress.",
    
    # BFI Extraversion
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
    
    # PSQ stress items
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    
    # MWS study skills
    "Mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "Im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
    
    # Statistics
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  Question_EN = c(
    # Programming Anxiety (English) - First 5 items suitable for all experience levels
    "I feel uncertain when I have to program.",
    "The thought of learning to program makes me nervous.",
    "I am afraid of making mistakes when programming.",
    "I feel overwhelmed when I think about programming tasks.",
    "I am worried that I am not good enough at programming.",
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
    
    # BFI Extraversion
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
    "I like it clean and tidy.",
    "I often worry.",
    "I enjoy thinking thoroughly about complex things.",
    "I am talkative.",
    "Others are rather indifferent to me.",
    "I am rather the chaotic type.",
    "I rarely get nervous and insecure.",
    "I have little interest in abstract considerations.",
    
    # PSQ stress items
    "I feel that too many demands are being made on me.",
    "I have too much to do.",
    "I feel rushed.",
    "I have enough time for myself.",
    "I feel under time pressure.",
    
    # MWS study skills
    "coping with the social climate in the program (e.g., handling competition)",
    "organizing teamwork (e.g., finding study groups)",
    "making contacts with fellow students (e.g., for study groups, leisure)",
    "working together in a team (e.g., working on tasks together, preparing presentations)",
    
    # Statistics
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
# DEMOGRAPHICS CONFIGURATION
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
    question_en = "Which study program are you in?",
    type = "select",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    options_en = c("Bachelor Psychology"="1", "Master Psychology"="2"),
    required = TRUE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    type = "select",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    options_en = c("female"="1", "male"="2", "diverse"="3"),
    required = TRUE
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    question_en = "How do you live?",
    type = "select",
    options = c("Bei meinen Eltern/Elternteil"="1", "In einer WG/WG in einem Wohnheim"="2", "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim"="3", "Mit meinem/r Partner*In"="4", "Anders"="5"),
    options_en = c("With my parents/parent"="1", "In a shared apartment/dormitory"="2", "Alone/in a separate unit in a dormitory"="3", "With my partner"="4", "Other"="5"),
    required = TRUE
  ),
  Haustier = list(
    question = "Welches Haustier würden Sie gerne halten?",
    question_en = "Which pet would you like to have?",
    type = "select",
    options = c("Hund"="1", "Katze"="2", "Fische"="3", "Vogel"="4", "Nager"="5", "Reptil"="6", "Ich möchte kein Haustier"="7", "Sonstiges"="8"),
    options_en = c("Dog"="1", "Cat"="2", "Fish"="3", "Bird"="4", "Rodent"="5", "Reptile"="6", "I don't want a pet"="7", "Other"="8"),
    required = TRUE
  ),
  Rauchen = list(
    question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
    question_en = "Do you regularly smoke cigarettes, vapes or shisha?",
    type = "select",
    options = c("Ja"="1", "Nein"="2"),
    options_en = c("Yes"="1", "No"="2"),
    required = TRUE
  ),
  Ernährung = list(
    question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
    question_en = "Which type of diet do you identify with most?",
    type = "select",
    options = c("Vegan"="1", "Vegetarisch"="2", "Pescetarisch"="3", "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere"="6"),
    options_en = c("Vegan"="1", "Vegetarian"="2", "Pescetarian"="3", "Flexitarian"="4", "Omnivore (everything)"="5", "Other"="6"),
    required = TRUE
  ),
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    question_en = "How many hours per week do you plan to invest in preparing and reviewing statistics courses?",
    type = "select",
    options = c("0 Stunden"="1", "maximal eine Stunde"="2", "mehr als eine, aber weniger als 2 Stunden"="3", "mehr als zwei, aber weniger als 3 Stunden"="4", "mehr als drei, aber weniger als 4 Stunden"="5", "mehr als 4 Stunden"="6"),
    options_en = c("0 hours"="1", "maximum one hour"="2", "more than one, but less than 2 hours"="3", "more than two, but less than 3 hours"="4", "more than three, but less than 4 hours"="5", "more than 4 hours"="6"),
    required = TRUE
  ),
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-Punkte-Skala)",
    question_en = "How satisfied are you with your study location Hildesheim? (5-point scale)",
    type = "select",
    options = c("gar nicht zufrieden"="1", "eher nicht zufrieden"="2", "teils-teils"="3", "eher zufrieden"="4", "sehr zufrieden"="5"),
    options_en = c("not at all satisfied"="1", "rather not satisfied"="2", "neither nor"="3", "rather satisfied"="4", "very satisfied"="5"),
    required = TRUE
  ),
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-Punkte-Skala)",
    question_en = "How satisfied are you with your study location Hildesheim? (7-point scale)",
    type = "select",
    options = c("gar nicht zufrieden"="1", "eher nicht zufrieden"="2", "etwas zufrieden"="3", "teils-teils"="4", "ziemlich zufrieden"="5", "sehr zufrieden"="6", "extrem zufrieden"="7"),
    options_en = c("not at all satisfied"="1", "rather not satisfied"="2", "somewhat satisfied"="3", "neither nor"="4", "quite satisfied"="5", "very satisfied"="6", "extremely satisfied"="7"),
    required = TRUE
  )
)

# =============================================================================
# INPUT TYPES
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
# CUSTOM PAGE FLOW
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
# RESULTS PROCESSOR
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
# STUDY CONFIGURATION
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
# LAUNCH STUDY
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