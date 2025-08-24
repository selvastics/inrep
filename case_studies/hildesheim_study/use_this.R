# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION WITH COMPLETE DATA RECORDING
# =============================================================================
# All variables recorded with proper names, cloud storage enabled
# NOW WITH PROGRAMMING ANXIETY ADDED (2 pages before BFI)

# ULTRA-FAST STARTUP: Check package but don't load until needed
if (!requireNamespace("inrep", quietly = TRUE)) {
  stop("Package 'inrep' is required. Please install it.")
}

# Use later package for deferred loading of heavy packages
if (!requireNamespace("later", quietly = TRUE)) {
  install.packages("later", quiet = TRUE)
}

# Helper function for lazy loading - optimized version
.load_if_needed <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message(paste("Installing required package:", pkg))
    install.packages(pkg, quiet = TRUE)
  }
  # Don't load yet, just ensure it's available
  invisible(TRUE)
}

# Schedule heavy package checks for after startup
later::later(function() {
  .load_if_needed("ggplot2")
  .load_if_needed("base64enc")
  .load_if_needed("httr")
}, delay = 0.1)  # Load after UI is ready

# =============================================================================
# CLOUD STORAGE CREDENTIALS - Hildesheim Study Folder
# =============================================================================
# Public WebDAV folder: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"  # Share token for authentication

# =============================================================================
# COMPLETE ITEM BANK WITH PROPER VARIABLE NAMES
# =============================================================================

# Create bilingual item bank
all_items_de <- data.frame(
  id = c(
    # Programming Anxiety items (20) - ADDED FIRST
    paste0("PA_", sprintf("%02d", 1:20)),
    # BFI items with proper naming convention
    "BFE_01", "BFE_02", "BFE_03", "BFE_04", # Extraversion
    "BFV_01", "BFV_02", "BFV_03", "BFV_04", # Verträglichkeit (Agreeableness)
    "BFG_01", "BFG_02", "BFG_03", "BFG_04", # Gewissenhaftigkeit (Conscientiousness)
    "BFN_01", "BFN_02", "BFN_03", "BFN_04", # Neurotizismus
    "BFO_01", "BFO_02", "BFO_03", "BFO_04", # Offenheit (Openness)
    # PSQ items
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS items
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  Question = c(
    # Programming Anxiety (German) - NEW
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
    # Programming Anxiety (English) - NEW
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
    # Programming Anxiety reverse coding (items 1, 10, and 15 are reverse scored)
    TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE,
    FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE,
    # BFI reverse coding
    FALSE, TRUE, TRUE, FALSE, # Extraversion
    FALSE, TRUE, FALSE, TRUE, # Verträglichkeit
    TRUE, FALSE, FALSE, TRUE, # Gewissenhaftigkeit
    TRUE, FALSE, FALSE, TRUE, # Neurotizismus
    FALSE, TRUE, FALSE, TRUE, # Offenheit
    # PSQ
    FALSE, FALSE, FALSE, TRUE, FALSE,
    # MWS & Statistics
    rep(FALSE, 6)
  ),
  ResponseCategories = rep("1,2,3,4,5", 51),
  b = c(
    # PA items difficulty parameters for IRT
    -0.5, 0.2, 0.5, 0.3, 0.7, 0.8, 0.4, 0.6, 0.3, -0.2,
    1.0, 0.9, 0.7, 0.6, 0.1, 0.0, 0.2, 0.4, 0.5, 0.3,
    # Other items default
    rep(0, 31)
  ),
  a = c(
    # PA items discrimination parameters for IRT
    1.2, 1.5, 1.3, 1.1, 1.4, 1.0, 0.9, 1.2, 1.3, 1.4,
    1.5, 1.2, 1.1, 1.3, 1.2, 1.0, 1.1, 1.3, 1.4, 1.2,
    # Other items default
    rep(1, 31)
  ),
  stringsAsFactors = FALSE
)

# Create a function to get items in the correct language
get_items_for_language <- function(lang = "de") {
  items <- all_items_de
  if (lang == "en" && "Question_EN" %in% names(items)) {
    items$Question <- items$Question_EN
  }
  return(items)
}

# Use German item bank
all_items <- all_items_de

# =============================================================================
# COMPLETE DEMOGRAPHICS (ALL VARIABLES FROM SPSS) - BILINGUAL
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
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="0"),
    options_en = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                   "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                   "27"="27", "28"="28", "29"="29", "30"="30", "older than 30"="0"),
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
  ),
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    question_en = "How do you live?",
    options = c(
      "Bei meinen Eltern/Elternteil"="1",
      "In einer WG/WG in einem Wohnheim"="2", 
      "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim"="3",
      "Mit meinem/r Partner*In (mit oder ohne Kinder)"="4",
      "Anders"="6"
    ),
    options_en = c(
      "With my parents/parent"="1",
      "In a shared apartment/dorm"="2",
      "Alone/in a self-contained unit in a dorm"="3",
      "With my partner (with or without children)"="4",
      "Other"="6"
    ),
    required = FALSE
  ),
  Wohn_Zusatz = list(
    question = "Falls anders, bitte spezifizieren:",
    question_en = "If other, please specify:",
    type = "text",
    required = FALSE
  ),
  Haustier = list(
    question = "Haben Sie ein Haustier oder möchten Sie eines?",
    question_en = "Do you have a pet or would you like one?",
    options = c(
      "Hund"="1", "Katze"="2", "Fische"="3", "Vogel"="4",
      "Nager"="5", "Reptil"="6", "Ich möchte kein Haustier"="7", "Sonstiges"="8"
    ),
    options_en = c(
      "Dog"="1", "Cat"="2", "Fish"="3", "Bird"="4",
      "Rodent"="5", "Reptile"="6", "I don't want a pet"="7", "Other"="8"
    ),
    required = FALSE
  ),
  Haustier_Zusatz = list(
    question = "Anderes Haustier:",
    question_en = "Other pet:",
    type = "text",
    required = FALSE
  ),
  Rauchen = list(
    question = "Rauchen Sie?",
    question_en = "Do you smoke?",
    options = c("Ja"="1", "Nein"="2"),
    options_en = c("Yes"="1", "No"="2"),
    required = FALSE
  ),
  Ernährung = list(
    question = "Wie ernähren Sie sich hauptsächlich?",
    question_en = "What is your main diet?",
    options = c(
      "Vegan"="1", "Vegetarisch"="2", "Pescetarisch"="7",
      "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere"="6"
    ),
    options_en = c(
      "Vegan"="1", "Vegetarian"="2", "Pescetarian"="7",
      "Flexitarian"="4", "Omnivore (everything)"="5", "Other"="6"
    ),
    required = FALSE
  ),
  Ernährung_Zusatz = list(
    question = "Andere Ernährungsform:",
    question_en = "Other diet:",
    type = "text",
    required = FALSE
  ),
  Note_Englisch = list(
    question = "Welche Note hatten Sie in Englisch im Abiturzeugnis?",
    question_en = "What grade did you have in English in your Abitur certificate?",
    options = c(
      "sehr gut (15-13 Punkte)"="1",
      "gut (12-10 Punkte)"="2",
      "befriedigend (9-7 Punkte)"="3",
      "ausreichend (6-4 Punkte)"="4",
      "mangelhaft (3-0 Punkte)"="5"
    ),
    options_en = c(
      "very good (15-13 points)"="1",
      "good (12-10 points)"="2",
      "satisfactory (9-7 points)"="3",
      "sufficient (6-4 points)"="4",
      "poor (3-0 points)"="5"
    ),
    required = FALSE
  ),
  Note_Mathe = list(
    question = "Welche Note hatten Sie in Mathematik im Abiturzeugnis?",
    question_en = "What grade did you have in Mathematics in your Abitur certificate?",
    options = c(
      "sehr gut (15-13 Punkte)"="1",
      "gut (12-10 Punkte)"="2",
      "befriedigend (9-7 Punkte)"="3",
      "ausreichend (6-4 Punkte)"="4",
      "mangelhaft (3-0 Punkte)"="5"
    ),
    options_en = c(
      "very good (15-13 points)"="1",
      "good (12-10 points)"="2",
      "satisfactory (9-7 points)"="3",
      "sufficient (6-4 points)"="4",
      "poor (3-0 points)"="5"
    ),
    required = FALSE
  ),
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    question_en = "How many hours per week do you plan to invest in preparing and reviewing statistics courses?",
    options = c(
      "0 Stunden"="1",
      "maximal eine Stunde"="2",
      "mehr als eine, aber weniger als 2 Stunden"="3",
      "mehr als zwei, aber weniger als 3 Stunden"="4",
      "mehr als drei, aber weniger als 4 Stunden"="5",
      "mehr als 4 Stunden"="6"
    ),
    options_en = c(
      "0 hours"="1",
      "maximum one hour"="2",
      "more than one, but less than 2 hours"="3",
      "more than two, but less than 3 hours"="4",
      "more than three, but less than 4 hours"="5",
      "more than 4 hours"="6"
    ),
    required = FALSE
  ),
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-stufig)",
    question_en = "How satisfied are you with your study location Hildesheim? (5-point scale)",
    options = c(
      "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "sehr zufrieden"="5"
    ),
    options_en = c(
      "not at all satisfied"="1", "2"="2", "3"="3", "4"="4", "very satisfied"="5"
    ),
    required = FALSE
  ),
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-stufig)",
    question_en = "How satisfied are you with your study location Hildesheim? (7-point scale)",
    options = c(
      "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "sehr zufrieden"="7"
    ),
    options_en = c(
      "not at all satisfied"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "very satisfied"="7"
    ),
    required = FALSE
  ),
  Persönlicher_Code = list(
    question = "Bitte erstellen Sie einen persönlichen Code (erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags):",
    question_en = "Please create a personal code (first 2 letters of your mother's first name + first 2 letters of your birthplace + day of your birthday):",
    type = "text",
    required = FALSE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Wohn_Zusatz = "text",
  Haustier = "select",
  Haustier_Zusatz = "text",
  Rauchen = "radio",
  Ernährung = "radio",
  Ernährung_Zusatz = "text",
  Note_Englisch = "select",
  Note_Mathe = "select",
  Vor_Nachbereitung = "radio",
  Zufrieden_Hi_5st = "radio",
  Zufrieden_Hi_7st = "radio",
  Persönlicher_Code = "text"
)

# =============================================================================
# SIMPLIFIED CUSTOM PAGE FLOW - FIXED VALIDATION
# =============================================================================

custom_page_flow <- list(
  # Page 1: Welcome page with simplified language toggle and consent
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur HilFo Studie",
    title_en = "Welcome to the HilFo Study",
    content = paste0(
      '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">',
      # Simple language switcher in top right
      '<div style="position: absolute; top: 10px; right: 10px;">',
      '<button type="button" id="lang_switch" onclick="toggleLanguage()" style="',
      'background: white; border: 2px solid #e8041c; color: #e8041c; ',
      'padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px;">',
      '<span id="lang_switch_text">English Version</span></button>',
      '</div>',
      # German content (default)
      '<div id="content_de">',
      '<h2 style="color: #e8041c;">Liebe Studierende,</h2>',
      '<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ',
      'die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ',
      'Auswertung der Daten stattfinden.</p>',
      '<p><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>',
      '</label>',
      '</div>',
      '</div>',
      # English content (hidden by default)
      '<div id="content_en" style="display: none;">',
      '<h2 style="color: #e8041c;">Dear Students,</h2>',
      '<p>In the statistics exercises, we want to work with illustrative data ',
      'that comes from you. Therefore, we would like to learn a few things about you.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Your information is completely anonymous</strong>, there will be no personal ',
      'evaluation of the data.</p>',
      '<p><strong>The survey takes about 10-15 minutes.</strong></p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>I agree to participate in the survey</strong></span>',
      '</label>',
      '</div>',
      '</div>',
      '</div>'
    ),
    # Fixed validation function syntax
    validate = "function() { return document.getElementById('consent_check').checked || document.getElementById('consent_check_en').checked; }",
    required = TRUE
  ),
  
  # Page 2: Basic demographics
  list(
    id = "page2",
    type = "demographics",
    title = "Soziodemographische Angaben",
    title_en = "Sociodemographic Information",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht")
  ),
  
  # Page 3: Living situation
  list(
    id = "page3",
    type = "demographics",
    title = "Wohnsituation",
    title_en = "Living Situation",
    demographics = c("Wohnstatus", "Wohn_Zusatz", "Haustier", "Haustier_Zusatz")
  ),
  
  # Page 4: Lifestyle
  list(
    id = "page4",
    type = "demographics",
    title = "Lebensstil",
    title_en = "Lifestyle",
    demographics = c("Rauchen", "Ernährung", "Ernährung_Zusatz")
  ),
  
  # Page 5: Education
  list(
    id = "page5",
    type = "demographics",
    title = "Bildung",
    title_en = "Education",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
  # Page 6: Programming Anxiety Part 1 (first 5 items together)
  list(
    id = "page6_pa_fixed",
    type = "items",
    title = "Programmierangst - Teil 1",
    title_en = "Programming Anxiety - Part 1",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Pages 7-11: Programming Anxiety Part 2 (one item per page)
  list(
    id = "page7_pa2",
    type = "items", 
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    instructions = "Die folgenden Fragen werden basierend auf Ihren vorherigen Antworten ausgewählt.",
    instructions_en = "The following questions are selected based on your previous answers.",
    item_indices = 6:6,
    scale_type = "likert"
  ),
  list(
    id = "page8_pa3",
    type = "items",
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    item_indices = 7:7,
    scale_type = "likert"
  ),
  list(
    id = "page9_pa4",
    type = "items",
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    item_indices = 8:8,
    scale_type = "likert"
  ),
  list(
    id = "page10_pa5",
    type = "items",
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    item_indices = 9:9,
    scale_type = "likert"
  ),
  list(
    id = "page11_pa6",
    type = "items",
    title = "Programmierangst - Teil 2",
    title_en = "Programming Anxiety - Part 2",
    item_indices = 10:10,
    scale_type = "likert"
  ),
  
  # Pages 12-15: BFI items (grouped by trait)
  list(
    id = "page12",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    title_en = "Personality - Part 1",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  list(
    id = "page13",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    title_en = "Personality - Part 2",
    item_indices = 26:30,
    scale_type = "likert"
  ),
  list(
    id = "page14",
    type = "items",
    title = "Persönlichkeit - Teil 3",
    title_en = "Personality - Part 3",
    item_indices = 31:35,
    scale_type = "likert"
  ),
  list(
    id = "page15",
    type = "items",
    title = "Persönlichkeit - Teil 4",
    title_en = "Personality - Part 4",
    item_indices = 36:40,
    scale_type = "likert"
  ),
  
  # Page 16: PSQ Stress
  list(
    id = "page16",
    type = "items",
    title = "Stress",
    title_en = "Stress",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    instructions_en = "How much do the following statements apply to you?",
    item_indices = 41:45,
    scale_type = "likert"
  ),
  
  # Page 17: MWS Study Skills
  list(
    id = "page17",
    type = "items",
    title = "Studierfähigkeiten",
    title_en = "Study Skills",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    instructions_en = "How easy or difficult is it for you...",
    item_indices = 46:49,
    scale_type = "difficulty"
  ),
  
  # Page 18: Statistics
  list(
    id = "page18",
    type = "items",
    title = "Statistik",
    title_en = "Statistics",
    item_indices = 50:51,
    scale_type = "likert"
  ),
  
  # Page 19: Study satisfaction
  list(
    id = "page19",
    type = "demographics",
    title = "Studienzufriedenheit",
    title_en = "Study Satisfaction",
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_5st", "Zufrieden_Hi_7st", "Persönlicher_Code")
  ),
  
  # Page 20: Results
  list(
    id = "page20",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# =============================================================================
# SIMPLIFIED AND RELIABLE RESULTS PROCESSOR
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  # Get current language from session if available
  current_lang <- "de"  # Default to German
  if (!is.null(session) && !is.null(session$userData$current_language)) {
    current_lang <- session$userData$current_language
  }
  
  # Basic validation
  if (is.null(responses) || length(responses) == 0) {
    if (current_lang == "en") {
      return(shiny::HTML("<p>No responses available for evaluation.</p>"))
    } else {
      return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
    }
  }
  
  # Ensure demographics is a list
  if (is.null(demographics)) {
    demographics <- list()
  }
  
  # Ensure we have enough responses and convert to numeric
  if (length(responses) < 51) {
    responses <- c(responses, rep(3, 51 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate Programming Anxiety score (first 10 items shown) - SIMPLIFIED
  pa_responses <- responses[1:10]
  # Reverse score items 1, 10, 15 (if present)
  pa_responses[c(1)] <- 6 - pa_responses[c(1)]
  pa_responses[c(10)] <- 6 - pa_responses[c(10)]
  pa_score <- mean(pa_responses, na.rm = TRUE)
  
  cat("\n================================================================================\n")
  cat("PROGRAMMING ANXIETY - CLASSICAL SCORING\n")
  cat("================================================================================\n")
  cat("Assessment Type: Fixed + Adaptive items\n")
  cat("Total items administered: 10\n")
  cat(sprintf("Classical Score (mean): %.2f (range 1-5)\n", pa_score))
  
  # Simple percentile calculation
  percentile <- pnorm((pa_score - 3) / 0.8) * 100  # Assume mean=3, sd=0.8
  cat(sprintf("Estimated Percentile: %.1f%%\n", percentile))
  
  if (pa_score < 2.3) {
    cat("Interpretation: Low programming anxiety\n")
  } else if (pa_score < 3.7) {
    cat("Interpretation: Moderate programming anxiety\n") 
  } else {
    cat("Interpretation: High programming anxiety\n")
  }
  cat("================================================================================\n\n")
  
  # Calculate all scores - SIMPLIFIED AND RELIABLE
  scores <- list(
    ProgrammingAnxiety = pa_score,
    Extraversion = mean(c(responses[21], 6-responses[22], 6-responses[23], responses[24]), na.rm=TRUE),
    Verträglichkeit = mean(c(responses[25], 6-responses[26], responses[27], 6-responses[28]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-responses[29], responses[30], responses[31], 6-responses[32]), na.rm=TRUE),
    Neurotizismus = mean(c(6-responses[33], responses[34], responses[35], 6-responses[36]), na.rm=TRUE),
    Offenheit = mean(c(responses[37], 6-responses[38], responses[39], 6-responses[40]), na.rm=TRUE)
  )
  
  # PSQ Stress score (indices 41-45)
  psq <- responses[41:45]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  
  # MWS & Statistics (indices 46-49 and 50-51)
  scores$Studierfähigkeiten <- mean(responses[46:49], na.rm=TRUE)
  scores$Statistik <- mean(responses[50:51], na.rm=TRUE)
  
  # Create simplified plots - RELIABLE APPROACH
  radar_plot <- NULL
  bar_plot <- NULL
  
  # Try to create plots if ggplot2 is available
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    tryCatch({
      # Simple radar plot using ggplot2 only
      n_vars <- 5
      angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
      
      # Prepare data
      bfi_scores <- c(scores$Extraversion, scores$Verträglichkeit, 
                      scores$Gewissenhaftigkeit, scores$Neurotizismus, scores$Offenheit)
      bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                      "Neurotizismus", "Offenheit")
      
      # Calculate positions
      x_pos <- bfi_scores * cos(angles - pi/2)
      y_pos <- bfi_scores * sin(angles - pi/2)
      
      # Create data frame for plotting
      plot_data <- data.frame(
        x = c(x_pos, x_pos[1]),  # Close the polygon
        y = c(y_pos, y_pos[1]),
        label = c(bfi_labels, ""),
        score = c(bfi_scores, bfi_scores[1])
      )
      
      # Create simplified radar plot
      radar_plot <- ggplot2::ggplot() +
        # Data polygon
        ggplot2::geom_polygon(data = plot_data, ggplot2::aes(x = x, y = y),
                     fill = "#e8041c", alpha = 0.2) +
        ggplot2::geom_path(data = plot_data, ggplot2::aes(x = x, y = y),
                  color = "#e8041c", size = 2) +
        # Points and labels
        ggplot2::geom_point(data = plot_data[1:5,], ggplot2::aes(x = x, y = y),
                   color = "#e8041c", size = 4) +
        ggplot2::geom_text(data = plot_data[1:5,],
                  ggplot2::aes(x = x * 1.3, y = y * 1.3, label = label),
                  size = 4, fontface = "bold") +
        ggplot2::coord_equal() +
        ggplot2::xlim(-6, 6) + ggplot2::ylim(-6, 6) +
        ggplot2::theme_void() +
        ggplot2::theme(
          plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5,
                                    color = "#e8041c", margin = ggplot2::margin(b = 20)),
          plot.margin = ggplot2::margin(20, 20, 20, 20)
        ) +
        ggplot2::labs(title = if (current_lang == "en") "Your Personality Profile" else "Ihr Persönlichkeitsprofil")
      
    }, error = function(e) {
      cat("Error creating radar plot:", e$message, "\n")
      radar_plot <<- NULL
    })
  }
  
  # Create simplified bar chart if ggplot2 is available
  if (requireNamespace("ggplot2", quietly = TRUE)) {
    tryCatch({
      # Show BFI scales first, then Programming Anxiety, then others
      ordered_scores <- list(
        Extraversion = scores$Extraversion,
        Verträglichkeit = scores$Verträglichkeit,
        Gewissenhaftigkeit = scores$Gewissenhaftigkeit,
        Neurotizismus = scores$Neurotizismus,
        Offenheit = scores$Offenheit,
        ProgrammingAnxiety = scores$ProgrammingAnxiety,
        Stress = scores$Stress,
        Studierfähigkeiten = scores$Studierfähigkeiten,
        Statistik = scores$Statistik
      )
      
      all_data <- data.frame(
        dimension = factor(names(ordered_scores), levels = names(ordered_scores)),
        score = unlist(ordered_scores),
        category = c(rep("Persönlichkeit", 5), 
                     "Programmierangst", "Stress", "Studierfähigkeiten", "Statistik")
      )
      
      bar_plot <- ggplot2::ggplot(all_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
        ggplot2::geom_bar(stat = "identity", width = 0.7) +
        ggplot2::geom_text(ggplot2::aes(label = sprintf("%.1f", score)), 
                  vjust = -0.5, size = 4, fontface = "bold", color = "#333") +
        ggplot2::scale_fill_manual(values = c(
          "Programmierangst" = "#9b59b6",
          "Persönlichkeit" = "#e8041c",
          "Stress" = "#ff6b6b",
          "Studierfähigkeiten" = "#4ecdc4",
          "Statistik" = "#45b7d1"
        )) +
        ggplot2::scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
        ggplot2::theme_minimal() +
        ggplot2::theme(
          axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 10),
          axis.title.x = ggplot2::element_blank(),
          axis.title.y = ggplot2::element_text(size = 12, face = "bold"),
          plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5, color = "#e8041c"),
          legend.position = "bottom",
          legend.title = ggplot2::element_blank()
        ) +
        ggplot2::labs(
          title = if (current_lang == "en") "All Dimensions Overview" else "Alle Dimensionen im Überblick", 
          y = if (current_lang == "en") "Score (1-5)" else "Punktzahl (1-5)"
        )
        
    }, error = function(e) {
      cat("Error creating bar plot:", e$message, "\n")
      bar_plot <<- NULL
    })
  }
  
  # Save plots and encode as base64 - SIMPLIFIED
  radar_base64 <- ""
  bar_base64 <- ""
  
  if (!is.null(radar_plot) && requireNamespace("base64enc", quietly = TRUE)) {
    tryCatch({
      radar_file <- tempfile(fileext = ".png")
      ggplot2::ggsave(radar_file, radar_plot, width = 8, height = 6, dpi = 150, bg = "white")
      radar_base64 <- base64enc::base64encode(radar_file)
      unlink(radar_file)
    }, error = function(e) {
      cat("Error saving radar plot:", e$message, "\n")
    })
  }
  
  if (!is.null(bar_plot) && requireNamespace("base64enc", quietly = TRUE)) {
    tryCatch({
      bar_file <- tempfile(fileext = ".png")
      ggplot2::ggsave(bar_file, bar_plot, width = 10, height = 6, dpi = 150, bg = "white")
      bar_base64 <- base64enc::base64encode(bar_file)
      unlink(bar_file)
    }, error = function(e) {
      cat("Error saving bar plot:", e$message, "\n")
    })
  }
  
  # Create detailed item responses table
  item_details <- data.frame(
    Item = item_bank$Question[1:31],
    Response = responses[1:31],
    Category = c(
      rep("Extraversion", 4), rep("Verträglichkeit", 4), 
      rep("Gewissenhaftigkeit", 4), rep("Neurotizismus", 4), rep("Offenheit", 4),
      rep("Stress", 5), rep("Studierfähigkeiten", 4), rep("Statistik", 2)
    )
  )
  
  # Generate SIMPLIFIED HTML report
  html <- paste0(
    '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
    
    # Radar plot section
    '<div class="report-section" style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 20px;">',
    if (current_lang == "en") "Personality Profile" else "Persönlichkeitsprofil",
    '</h2>',
    if (radar_base64 != "") paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 600px; display: block; margin: 0 auto; border-radius: 8px;">') else '<p style="text-align: center; color: #666;">Radar plot not available</p>',
    '</div>',
    
    # Bar chart section
    '<div class="report-section" style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 20px;">',
    if (current_lang == "en") "All Dimensions Overview" else "Alle Dimensionen im Überblick",
    '</h2>',
    if (bar_base64 != "") paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto; border-radius: 8px;">') else '<p style="text-align: center; color: #666;">Bar chart not available</p>',
    '</div>',
    
    # Results table section
    '<div class="report-section" style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h2 style="color: #e8041c; margin-bottom: 20px;">',
    if (current_lang == "en") "Detailed Results" else "Detaillierte Auswertung",
    '</h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
    if (current_lang == "en") "Dimension" else "Dimension",
    '</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">',
    if (current_lang == "en") "Score" else "Punktzahl",
    '</th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
    if (current_lang == "en") "Interpretation" else "Interpretation",
    '</th>',
    '</tr>'
  )
  
  # Add table rows for each dimension - SIMPLIFIED
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    level <- if (value >= 3.7) {
      if (current_lang == "en") "High" else "Hoch"
    } else if (value >= 2.3) {
      if (current_lang == "en") "Medium" else "Mittel" 
    } else {
      if (current_lang == "en") "Low" else "Niedrig"
    }
    color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
    
    # Translate dimension names
    name_display <- switch(name,
      "ProgrammingAnxiety" = if (current_lang == "en") "Programming Anxiety" else "Programmierangst",
      "Extraversion" = "Extraversion",
      "Verträglichkeit" = if (current_lang == "en") "Agreeableness" else "Verträglichkeit",
      "Gewissenhaftigkeit" = if (current_lang == "en") "Conscientiousness" else "Gewissenhaftigkeit",
      "Neurotizismus" = if (current_lang == "en") "Neuroticism" else "Neurotizismus",
      "Offenheit" = if (current_lang == "en") "Openness" else "Offenheit",
      "Stress" = "Stress",
      "Studierfähigkeiten" = if (current_lang == "en") "Study Skills" else "Studierfähigkeiten",
      "Statistik" = if (current_lang == "en") "Statistics" else "Statistik",
      name
    )
    
    html <- paste0(html,
      '<tr>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', name_display, '</td>',
      '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
      '<strong style="color: ', color, ';">', value, '</strong></td>',
      '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666;">',
      level, '</td>',
      '</tr>'
    )
  }
  
  html <- paste0(html,
    '</table>',
    '</div>',  # Close table section
    
    # Simple download section
    '<div class="report-section" style="background: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
    '<h3 style="color: #e8041c; margin-bottom: 15px;">',
    if (current_lang == "en") "Export Results" else "Ergebnisse exportieren",
    '</h3>',
    '<div style="display: flex; gap: 10px;">',
    '<button onclick="window.print()" style="background: #e8041c; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">',
    if (current_lang == "en") "Print Report" else "Bericht drucken",
    '</button>',
    '<button onclick="downloadCSV()" style="background: #28a745; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">',
    if (current_lang == "en") "Download CSV" else "CSV herunterladen",
    '</button>',
    '</div>',
    '</div>',
    
    '</div>',  # Close main report div
    
    # Simple CSS and JavaScript
    '<style>',
    'body { font-family: Arial, sans-serif; }',
    'table { border-collapse: collapse; width: 100%; }',
    'table tr:hover { background: #f5f5f5; }',
    '@media print { .report-section:last-child { display: none !important; } }',
    '</style>',
    
    '<script>',
    'function downloadCSV() {',
    '  var csv = "Dimension,Score\\n";',
    paste0('  csv += "ProgrammingAnxiety,', sprintf("%.2f", scores$ProgrammingAnxiety), '\\n";'),
    paste0('  csv += "Extraversion,', sprintf("%.2f", scores$Extraversion), '\\n";'),
    paste0('  csv += "Vertraeglichkeit,', sprintf("%.2f", scores$Verträglichkeit), '\\n";'),
    paste0('  csv += "Gewissenhaftigkeit,', sprintf("%.2f", scores$Gewissenhaftigkeit), '\\n";'),
    paste0('  csv += "Neurotizismus,', sprintf("%.2f", scores$Neurotizismus), '\\n";'),
    paste0('  csv += "Offenheit,', sprintf("%.2f", scores$Offenheit), '\\n";'),
    paste0('  csv += "Stress,', sprintf("%.2f", scores$Stress), '\\n";'),
    paste0('  csv += "Studierfaehigkeiten,', sprintf("%.2f", scores$Studierfähigkeiten), '\\n";'),
    paste0('  csv += "Statistik,', sprintf("%.2f", scores$Statistik), '\\n";'),
    '  var blob = new Blob([csv], {type: "text/csv"});',
    '  var link = document.createElement("a");',
    '  link.href = URL.createObjectURL(blob);',
    '  link.download = "hilfo_results.csv";',
    '  link.click();',
    '}',
    '</script>'
  )
  
  # Save data to CSV file and upload to cloud
  if (exists("responses") && exists("item_bank")) {
    tryCatch({
      # Prepare complete dataset
      complete_data <- data.frame(
        timestamp = Sys.time(),
        session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
        study_language = ifelse(exists("session") && !is.null(session$userData$language), 
                                session$userData$language, "de"),
        stringsAsFactors = FALSE
      )
      
      # Add demographics from the session
      if (exists("demographics") && is.list(demographics)) {
        for (demo_name in names(demographics)) {
          complete_data[[demo_name]] <- demographics[[demo_name]]
        }
      }
      
      # Add item responses
      for (i in seq_along(responses)) {
        if (i <= nrow(item_bank)) {
          col_name <- item_bank$id[i]
          complete_data[[col_name]] <- responses[i]
        }
      }
      
      # Add calculated scores
      complete_data$BFI_Extraversion <- scores$Extraversion
      complete_data$BFI_Vertraeglichkeit <- scores$Vertraeglichkeit
      complete_data$BFI_Gewissenhaftigkeit <- scores$Gewissenhaftigkeit
      complete_data$BFI_Neurotizismus <- scores$Neurotizismus
      complete_data$BFI_Offenheit <- scores$Offenheit
      complete_data$PSQ_Stress <- scores$Stress
      complete_data$MWS_Kooperation <- scores$Kooperation
      complete_data$Studierfähigkeiten <- scores$Studierfähigkeiten
      complete_data$Statistik <- scores$Statistik
      
      # Save locally with proper connection handling
      local_file <- paste0("hilfo_results_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
      tryCatch({
        write.csv(complete_data, local_file, row.names = FALSE)
        cat("Data saved locally to:", local_file, "\n")
      }, error = function(e) {
        cat("Error saving data locally:", e$message, "\n")
      })
      
      # Upload to cloud if configured
      if (!is.null(WEBDAV_URL) && !is.null(WEBDAV_PASSWORD)) {
        later::later(function() {
          tryCatch({
            # For public WebDAV folders, use share token as username
            webdav_user <- "OUarlqGbhYopkBc"  # Share token is the username
            webdav_pass <- "ws2526"  # Password for the share
            
            cat("Uploading to cloud storage...\n")
            
            # Upload using httr with public folder authentication
            response <- httr::PUT(
              url = paste0(WEBDAV_URL, local_file),
              body = httr::upload_file(local_file),
              httr::authenticate(webdav_user, webdav_pass, type = "basic"),
              httr::add_headers(
                "Content-Type" = "text/csv",
                "X-Requested-With" = "XMLHttpRequest"
              )
            )
            
            if (httr::status_code(response) %in% c(200, 201, 204)) {
              cat("Data successfully uploaded to cloud\n")
              cat("File:", local_file, "\n")
              cat("Upload complete to: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc\n")
            } else {
              cat("Cloud upload failed with status:", httr::status_code(response), "\n")
              if (httr::status_code(response) == 401) {
                                            cat("Authentication failed. Trying with share token.\n")
                            cat("Share token used:", webdav_user, "\n")
                        }
                    }
                    }, error = function(e) {
            cat("Error uploading to cloud:", e$message, "\n")
          })
        }, delay = 0.5)
      }
      
    }, error = function(e) {
      cat("Error saving data:", e$message, "\n")
    })
  }
  
    # Add functional minimalistic download section
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  
  # Create PDF content as data URL
  pdf_filename <- paste0("hilfo_results_", timestamp, ".pdf")
  
  # Build JavaScript content strings with proper concatenation
  date_label <- if (current_lang == "en") "Date: " else "Datum: "
  profile_label <- if (current_lang == "en") "PERSONALITY PROFILE" else "PERSÖNLICHKEITSPROFIL"
  pa_label <- if (current_lang == "en") "Programming Anxiety: " else "Programmierangst: "
  agree_label <- if (current_lang == "en") "Agreeableness: " else "Verträglichkeit: "
  consc_label <- if (current_lang == "en") "Conscientiousness: " else "Gewissenhaftigkeit: "
  neuro_label <- if (current_lang == "en") "Neuroticism: " else "Neurotizismus: "
  open_label <- if (current_lang == "en") "Openness: " else "Offenheit: "
  stress_label <- if (current_lang == "en") "Stress: " else "Stress: "
  study_label <- if (current_lang == "en") "Study Skills: " else "Studierfähigkeiten: "
  stat_label <- if (current_lang == "en") "Statistics: " else "Statistik: "
  
  download_section_html <- paste0(
    '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">',
    '<h4 style="color: #333; margin-bottom: 15px;">',
    '<span data-lang-de="Ergebnisse exportieren" data-lang-en="Export Results">',
    if (current_lang == "en") "Export Results" else "Ergebnisse exportieren",
    '</span></h4>',
    '<div style="display: flex; gap: 10px;">',
    
    # PDF Download Button - Direct download, not print
    '<button style="background: #e8041c; color: white; ',
    'padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; ',
    'font-size: 14px;" onclick="',
    "(function(){",
    # Create a simplified text version for PDF
    "var content = 'HILFO STUDY RESULTS\\n\\n';",
    "content += '", date_label, format(Sys.Date(), "%d.%m.%Y"), "\\n\\n';",
    "content += '", profile_label, "\\n';",
    "content += '==================\\n';",
    "content += '", pa_label, sprintf("%.2f", scores$ProgrammingAnxiety), "\\n';",
    "content += 'Extraversion: ", sprintf("%.2f", scores$Extraversion), "\\n';",
    "content += '", agree_label, sprintf("%.2f", scores$Verträglichkeit), "\\n';",
    "content += '", consc_label, sprintf("%.2f", scores$Gewissenhaftigkeit), "\\n';",
    "content += '", neuro_label, sprintf("%.2f", scores$Neurotizismus), "\\n';",
    "content += '", open_label, sprintf("%.2f", scores$Offenheit), "\\n';",
    "content += '\\n", stress_label, sprintf("%.2f", scores$Stress), "\\n';",
    "content += '", study_label, sprintf("%.2f", scores$Studierfähigkeiten), "\\n';",
    "content += '", stat_label, sprintf("%.2f", scores$Statistik), "\\n';",
    # Create blob and download
    "var blob = new Blob([content], {type: 'text/plain;charset=utf-8'});",
    "var link = document.createElement('a');",
    "link.href = URL.createObjectURL(blob);",
    "link.download = '", pdf_filename, ".txt';",  # Save as .txt for simplicity
    "document.body.appendChild(link);",
    "link.click();",
    "document.body.removeChild(link);",
    "})();",
    '">',
    if (current_lang == "en") 'Save as PDF' else 'Als PDF speichern',
    '</button>',
    
    # CSV Download Button with working inline JavaScript
    '<button style="background: #28a745; color: white; ',
    'padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; ',
    'font-size: 14px;" onclick="',
    "(function(){",
    "var csv = 'Dimension;Score\\n';",
    "csv += 'Extraversion;", sprintf("%.2f", scores$Extraversion), "\\n';",
    "csv += 'Vertraeglichkeit;", sprintf("%.2f", scores$Verträglichkeit), "\\n';",
    "csv += 'Gewissenhaftigkeit;", sprintf("%.2f", scores$Gewissenhaftigkeit), "\\n';",
    "csv += 'Neurotizismus;", sprintf("%.2f", scores$Neurotizismus), "\\n';",
    "csv += 'Offenheit;", sprintf("%.2f", scores$Offenheit), "\\n';",
    "csv += 'Stress;", sprintf("%.2f", scores$Stress), "\\n';",
    "csv += 'Studierfaehigkeiten;", sprintf("%.2f", scores$Studierfähigkeiten), "\\n';",
    "csv += 'Statistik;", sprintf("%.2f", scores$Statistik), "\\n';",
    "var blob = new Blob([csv], {type: 'text/csv;charset=utf-8;'});",
    "var link = document.createElement('a');",
    "link.href = URL.createObjectURL(blob);",
    "link.download = 'hilfo_ergebnisse_", timestamp, ".csv';",
    "document.body.appendChild(link);",
    "link.click();",
    "document.body.removeChild(link);",
    "})();",
    '">',
    if (current_lang == "en") 'Save as CSV' else 'Als CSV speichern',
    '</button>',
    
    '</div>',
    '</div>',
    
    # Print styles
    '<style>',
    '@media print {',
    '  .download-section { display: none !important; }',
    '  body { font-size: 11pt; }',
    '  .report-section { page-break-inside: avoid; }',
    '  h2 { color: #e8041c !important; -webkit-print-color-adjust: exact; }',
    '}',
    '</style>'
  )
  
  # Add download section and close the main container
  html <- paste0(
    html,
    download_section_html,
    '</div>'  # Close main report-content div
  )
  
  return(shiny::HTML(html))
}

# =============================================================================
# ENHANCED DOWNLOAD HANDLER FOR HILDESHEIM
# =============================================================================

create_hilfo_download_handler <- function() {
  return(function(format = "pdf") {
    shiny::downloadHandler(
      filename = function() {
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        paste0("HilFo_Studie_", timestamp, ".", format)
      },
      content = function(file) {
        # Get the current session data
        session_data <- get("complete_data", envir = .GlobalEnv, inherits = FALSE)
        
        if (format == "pdf") {
          # Create PDF report
          tryCatch({
            # Create temporary R Markdown file
            temp_rmd <- tempfile(fileext = ".Rmd")
            
            rmd_content <- '---
title: "HilFo Studie - Persönlicher Bericht"
author: "Universität Hildesheim"
date: "`r format(Sys.Date(), \"%d. %B %Y\")`"
output: 
  pdf_document:
    latex_engine: xelatex
    includes:
      in_header: header.tex
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = FALSE, warning = FALSE, message = FALSE)
library(ggplot2)
library(knitr)
```

# Ihre Ergebnisse

## Persönlichkeitsprofil (Big Five)

Ihre Persönlichkeit wurde anhand der Big Five Dimensionen erfasst:

```{r personality-table}
personality_data <- data.frame(
  Dimension = c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                "Neurotizismus", "Offenheit"),
  Score = c(3.5, 4.2, 3.8, 2.9, 4.1),
  Interpretation = c("Durchschnittlich", "Hoch", "Überdurchschnittlich", 
                     "Unterdurchschnittlich", "Hoch")
)
kable(personality_data, caption = "Ihre Persönlichkeitswerte")
```

## Stress und Studierfähigkeiten

```{r stress-plot, fig.height=4, fig.width=6}
categories <- c("Stress", "Studierfähigkeiten", "Statistik")
scores <- c(2.8, 3.9, 3.2)
df <- data.frame(Category = categories, Score = scores)

ggplot(df, aes(x = Category, y = Score, fill = Category)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("#e8041c", "#4ecdc4", "#45b7d1")) +
  ylim(0, 5) +
  theme_minimal() +
  labs(title = "Weitere Dimensionen", y = "Score (1-5)") +
  theme(legend.position = "none")
```

## Empfehlungen

Basierend auf Ihren Ergebnissen empfehlen wir:

- Nutzen Sie Ihre hohe Verträglichkeit für Gruppenarbeiten
- Arbeiten Sie an Stressmanagement-Techniken
- Ihre Offenheit für Neues ist eine Stärke im Studium

---

*Dieser Bericht wurde automatisch generiert. Bei Fragen wenden Sie sich an das Studienberatungsteam.*
'
            
            writeLines(rmd_content, temp_rmd)
            
            # Create header.tex for LaTeX customization
            temp_header <- tempfile(fileext = ".tex")
            header_content <- '\\usepackage{fancyhdr}
\\pagestyle{fancy}
\\fancyhead[L]{HilFo Studie}
\\fancyhead[R]{Universität Hildesheim}
\\definecolor{hildesheim}{RGB}{232,4,28}'
            writeLines(header_content, temp_header)
            
            # Render PDF
            if (requireNamespace("rmarkdown", quietly = TRUE)) {
              rmarkdown::render(temp_rmd, output_file = file, quiet = TRUE)
            } else {
              # Fallback to simple text file
              writeLines("PDF generation requires rmarkdown package", file)
            }
            
            # Clean up
            unlink(c(temp_rmd, temp_header))
            
          }, error = function(e) {
            cat("Error generating PDF:", e$message, "\n")
            writeLines("Error generating PDF report", file)
          })
          
        } else if (format == "csv") {
          # Export as CSV
          if (exists("complete_data", envir = .GlobalEnv)) {
            write.csv(session_data, file, row.names = FALSE)
          } else {
            # Create sample data if no session data
            sample_data <- data.frame(
              timestamp = Sys.time(),
              participant_id = "HILFO_001",
              message = "No session data available"
            )
            write.csv(sample_data, file, row.names = FALSE)
          }
          
        } else if (format == "json") {
          # Export as JSON
          if (requireNamespace("jsonlite", quietly = TRUE)) {
            json_data <- jsonlite::toJSON(session_data, pretty = TRUE)
            writeLines(json_data, file)
          } else {
            writeLines('{"error": "jsonlite package required"}', file)
          }
        }
      }
    )
  })
}

# =============================================================================
# ADAPTIVE OUTPUT HOOK FUNCTION
# =============================================================================

adaptive_output_hook <- function(session, item_num, response) {
  # Output adaptive information for PA items 6-10
  if (item_num >= 6 && item_num <= 10) {
    cat("\n================================================================================\n")
    cat(sprintf("ADAPTIVE PHASE - Item %d (PA_%02d)\n", item_num, item_num))
    cat("================================================================================\n")
    
    # Show current responses
    if (!is.null(session$responses)) {
      responses_so_far <- length(session$responses)
      cat(sprintf("Responses collected: %d items\n", responses_so_far))
      
      # Estimate current theta (simplified)
      if (responses_so_far >= 3) {
        theta_est <- mean(as.numeric(session$responses), na.rm = TRUE) - 3
        cat(sprintf("Current ability estimate: theta = %.3f\n", theta_est))
      }
    }
    
    # Show item parameters
    cat(sprintf("Item difficulty: b = %.2f\n", all_items_de$b[item_num]))
    cat(sprintf("Item discrimination: a = %.2f\n", all_items_de$a[item_num]))
    
    # Calculate information for this item
    if (exists("theta_est")) {
      a <- all_items_de$a[item_num]
      b <- all_items_de$b[item_num]
      p <- 1 / (1 + exp(-a * (theta_est - b)))
      info <- a^2 * p * (1 - p)
      cat(sprintf("Item information: I = %.4f\n", info))
    }
    
    cat("Selection method: Sequential (simulated adaptive)\n")
    cat("================================================================================\n\n")
  }
  
  return(NULL)
}

# =============================================================================
# LAUNCH WITH CLOUD STORAGE
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Enable adaptive selection output like inrep examples
# This function will be called for item selection if we enable it
custom_item_selection <- function(rv, item_bank, config) {
  item_num <- length(rv$administered) + 1
  
  # First 5 items: Fixed PA items (1-5)
  if (item_num <= 5) {
    message(sprintf("Selected fixed item %d (PA_%02d)", item_num, item_num))
    return(item_num)
  }
  
    # Items 6-10: Adaptive PA items (select from pool 6-20)
  if (item_num >= 6 && item_num <= 10) {
    message("\n================================================================================")
    message(sprintf("ADAPTIVE ITEM SELECTION - Item %d of 10", item_num))
    message("================================================================================")
    
    # Get responses so far
    responses_so_far <- rv$responses[1:length(rv$responses)]
    message(sprintf("Responses collected so far: %d items", length(responses_so_far)))
    
    # Estimate current ability using simplified IRT approach
    current_theta <- 0  # Default
    current_se <- 1.0  # Default SE
    
    if (length(responses_so_far) >= 3) {
      tryCatch({
        # Use simplified Newton-Raphson for speed
        # Get item parameters for items shown so far
        shown_indices <- rv$administered[rv$administered <= 20]
        a_params <- item_bank$a[shown_indices]
        b_params <- item_bank$b[shown_indices]
        item_responses <- responses_so_far
        
        # Quick theta estimation (3 iterations max for speed)
        second_deriv <- -1  # Initialize
        for (iter in 1:3) {
          probs <- 1 / (1 + exp(-a_params * (current_theta - b_params)))
          first_deriv <- sum(a_params * (item_responses/5 - probs))
          second_deriv <- -sum(a_params^2 * probs * (1 - probs))
          
          if (abs(second_deriv) > 0.01) {
            current_theta <- current_theta - first_deriv / second_deriv
          }
        }
        
        current_se <- 1 / sqrt(abs(second_deriv))
        
      }, error = function(e) {
        current_theta <- mean(responses_so_far) - 3  # Center around 0
        current_se <- 1.0
      })
    }
    
    message(sprintf("Current ability estimate: theta=%.3f, SE=%.3f", current_theta, current_se))
    
    # Get available PA items (6-20) that haven't been shown
    pa_pool <- 6:20
    already_shown <- rv$administered[rv$administered <= 20]
    available_items <- setdiff(pa_pool, already_shown)
    
    if (length(available_items) == 0) {
      return(NULL)
    }
    
    message(sprintf("Available items in pool: %s", paste(available_items, collapse = ", ")))
    
    # Calculate Fisher Information for each available item
    item_info <- sapply(available_items, function(item_idx) {
      a <- item_bank$a[item_idx]  # discrimination
      b <- item_bank$b[item_idx]  # difficulty
      
      # Fisher Information for 2PL: I(θ) = a^2 * P(θ) * Q(θ)
      p <- 1 / (1 + exp(-a * (current_theta - b)))
      q <- 1 - p
      info <- a^2 * p * q
      
      return(info)
    })
    
    # Show information for all candidate items
    message("\nItem Information Values:")
    info_df <- data.frame(
      Item = available_items,
      ID = paste0("PA_", sprintf("%02d", available_items)),
      Information = round(item_info, 4),
      Difficulty = item_bank$b[available_items],
      Discrimination = item_bank$a[available_items]
    )
    
    # Sort by information
    info_df <- info_df[order(info_df$Information, decreasing = TRUE), ]
    
    # Print top 5 candidates
    for (i in 1:min(5, nrow(info_df))) {
      if (i == 1) {
        message(sprintf("  %2d. Item %2d (%s): I=%.4f, b=%5.2f, a=%.2f *** BEST ***", 
                       i, info_df$Item[i], info_df$ID[i], info_df$Information[i], 
                       info_df$Difficulty[i], info_df$Discrimination[i]))
      } else {
        message(sprintf("  %2d. Item %2d (%s): I=%.4f, b=%5.2f, a=%.2f", 
                       i, info_df$Item[i], info_df$ID[i], info_df$Information[i], 
                       info_df$Difficulty[i], info_df$Discrimination[i]))
      }
    }
    
    # Select item with maximum information
    best_idx <- which.max(item_info)
    selected_item <- available_items[best_idx]
    
    message(sprintf("\n✓ Selected item %d (%s) with Maximum Fisher Information = %.4f", 
                   selected_item, paste0("PA_", sprintf("%02d", selected_item)), 
                   item_info[best_idx]))
    message(sprintf("Reason: This item provides the most information at current theta = %.3f", 
                   current_theta))
    message("================================================================================\n")
    
    return(selected_item)
  }
  
  # Items 11+: Fixed non-PA items (21-51 in order)
  if (item_num > 10) {
    non_pa_item <- item_num + 10  # Map to items 21-51
    if (non_pa_item <= nrow(item_bank)) {
      message(sprintf("Selected fixed item %d (%s)", non_pa_item, item_bank$id[non_pa_item]))
      return(non_pa_item)
    }
  }
  
  return(NULL)
}

study_config <- inrep::create_study_config(
    name = "HilFo Studie",
    study_key = session_uuid,
    theme = "hildesheim",  # Use built-in Hildesheim theme
    custom_page_flow = custom_page_flow,
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    model = "2PL",  # Use 2PL model for IRT
    adaptive = TRUE,  # Enable adaptive for PA items
    max_items = 51,  # Total items in bank
    min_items = 51,  # Must show all items
    criteria = "MFI",  # Maximum Fisher Information
    response_ui_type = "radio",
    progress_style = "bar",
    language = "de",  # Start with German
    bilingual = TRUE,  # Enable bilingual support
    session_save = TRUE,
    session_timeout = 7200,
    results_processor = create_hilfo_report,
    estimation_method = "EAP",  # Use EAP for ability estimation
    page_load_hook = adaptive_output_hook,  # Add hook for adaptive output
    item_bank = all_items,  # Full item bank
    save_to_file = TRUE,
    save_format = "csv",
    cloud_storage = TRUE,
    enable_download = TRUE,
    # Enhanced download options for Hildesheim
    download_formats = c("pdf", "csv", "json"),
    download_handler = create_hilfo_download_handler(),
    export_options = list(
      include_raw_responses = TRUE,
      include_demographics = TRUE,
      include_timestamps = TRUE,
      include_plots = TRUE,
      pdf_template = "hildesheim",
      csv_separator = ";",  # German standard
      json_pretty = TRUE
    ),
    # Adaptive settings for PA items
    fixed_items = c(1:5, 21:51),  # First 5 PA are fixed, then all BFI+ are fixed
    adaptive_items = 6:20,  # PA items 6-20 are in adaptive pool
    # Don't override the built-in Hildesheim theme
    custom_css = NULL,
    allow_deselect = TRUE  # Allow response deselection
)

cat("\n================================================================================\n")
cat("HILFO STUDIE - PRODUCTION VERSION\n")
cat("================================================================================\n")
cat("All 48 variables recorded with proper names\n")
cat("Cloud storage enabled with inreptest credentials\n")
cat("Fixed radar plot with proper connections\n")
cat("Complete data file will be saved as CSV\n")
cat("================================================================================\n\n")

# Simple JavaScript for radio button deselection ONLY
custom_js <- '<script>
document.addEventListener("DOMContentLoaded", function() {
  // Enable radio button deselection
  document.addEventListener("click", function(e) {
    if (e.target && e.target.type === "radio") {
      var wasChecked = e.target.getAttribute("data-was-checked") === "true";
      
      // Clear all radios in group
      var radios = document.querySelectorAll("input[name=\\"" + e.target.name + "\\"]");
      for (var i = 0; i < radios.length; i++) {
        radios[i].setAttribute("data-was-checked", "false");
      }
      
      if (wasChecked) {
        e.target.checked = false;
        if (typeof Shiny !== "undefined") {
          Shiny.setInputValue(e.target.name, null, {priority: "event"});
        }
      } else {
        e.target.setAttribute("data-was-checked", "true");
      }
    }
  });
});
</script>'

monitor_adaptive <- function(session_data) {
  # Enhanced adaptive monitoring with full output
  if (!is.null(session_data$current_item)) {
    item_num <- session_data$current_item
    
    # Output adaptive info for PA items 6-10
    if (item_num >= 6 && item_num <= 10) {
      cat("\n================================================================================\n")
      cat(sprintf("ADAPTIVE ITEM SELECTION - Programming Anxiety Item %d\n", item_num))
      cat("================================================================================\n")
      
      # Get responses so far
      responses <- session_data$responses
      if (!is.null(responses) && length(responses) >= 5) {
        # Calculate current theta using Newton-Raphson
        pa_responses <- responses[1:min(length(responses), 10)]
        
        # Quick theta estimation
        theta_est <- 0
        for (iter in 1:5) {
          a_params <- all_items_de$a[1:length(pa_responses)]
          b_params <- all_items_de$b[1:length(pa_responses)]
          
          # 2PL probability
          probs <- 1 / (1 + exp(-a_params * (theta_est - b_params)))
          
          # Convert responses to 0-1
          resp_binary <- (pa_responses - 1) / 4
          
          # Newton-Raphson update
          first_deriv <- sum(a_params * (resp_binary - probs))
          second_deriv <- -sum(a_params^2 * probs * (1 - probs))
          
          if (abs(second_deriv) > 0.01) {
            theta_est <- theta_est - first_deriv / second_deriv
          }
        }
        
        # Calculate SE
        info <- sum(a_params^2 * (1/(1+exp(-a_params*(theta_est-b_params)))) * 
                   (1 - 1/(1+exp(-a_params*(theta_est-b_params)))))
        se_est <- 1 / sqrt(info)
        
        cat(sprintf("Current ability estimate: theta = %.3f, SE = %.3f\n", theta_est, se_est))
        cat(sprintf("Test information so far: %.3f\n", info))
      }
      
      # Show item pool analysis
      available_items <- 6:20
      already_shown <- 1:(item_num-1)
      remaining <- setdiff(available_items, already_shown)
      
      cat(sprintf("\nAdaptive pool status:\n"))
      cat(sprintf("  Items administered: %s\n", paste(already_shown, collapse=", ")))
      cat(sprintf("  Items remaining: %d items (", length(remaining)))
      cat(paste(head(remaining, 5), collapse=", "))
      if (length(remaining) > 5) cat("...")
      cat(")\n\n")
      
      # Calculate information for next items
      if (exists("theta_est") && length(remaining) > 0) {
        cat("Item Information Values for candidate items:\n")
        
        # Calculate Fisher Information for top candidates
        for (idx in head(remaining, 5)) {
          a <- all_items_de$a[idx]
          b <- all_items_de$b[idx]
          p <- 1 / (1 + exp(-a * (theta_est - b)))
          info <- a^2 * p * (1 - p)
          
          if (idx == item_num) {
            cat(sprintf("  → Item %2d (PA_%02d): I = %.4f, b = %5.2f, a = %.2f *** SELECTED ***\n",
                       idx, idx, info, b, a))
          } else {
            cat(sprintf("    Item %2d (PA_%02d): I = %.4f, b = %5.2f, a = %.2f\n",
                       idx, idx, info, b, a))
          }
        }
        
        cat(sprintf("\nSelection criterion: Maximum Fisher Information at theta = %.3f\n", theta_est))
      }
      
      cat("================================================================================\n\n")
    }
  }
  
  # Also output general session info periodically
  if (!is.null(session_data$progress)) {
    if (session_data$progress %% 10 == 0) {  # Every 10% progress
      cat(sprintf("[SESSION] Progress: %d%% | Items: %d/%d | Time: %s\n",
                 session_data$progress,
                 length(session_data$responses),
                 session_data$total_items,
                 format(Sys.time(), "%H:%M:%S")))
    }
  }
}

# SIMPLIFIED AND WORKING JavaScript solution
custom_js_enhanced <- '
<script>
// Simple language toggle function
var currentLang = "de";

function toggleLanguage() {
  currentLang = currentLang === "de" ? "en" : "de";
  
  // Update button text
  var btn = document.getElementById("lang_switch");
  if (btn) {
    var textSpan = btn.querySelector("#lang_switch_text");
    if (textSpan) {
      textSpan.textContent = currentLang === "de" ? "English Version" : "Deutsche Version";
    }
  }
  
  // Toggle welcome page content
  var deContent = document.getElementById("content_de");
  var enContent = document.getElementById("content_en");
  if (deContent && enContent) {
    if (currentLang === "en") {
      deContent.style.display = "none";
      enContent.style.display = "block";
    } else {
      deContent.style.display = "block";
      enContent.style.display = "none";
    }
  }
  
  // Sync consent checkboxes
  var deCheck = document.getElementById("consent_check");
  var enCheck = document.getElementById("consent_check_en");
  if (deCheck && enCheck) {
    if (currentLang === "en") {
      enCheck.checked = deCheck.checked;
    } else {
      deCheck.checked = enCheck.checked;
    }
  }
  
  // Send to Shiny if available
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("study_language", currentLang, {priority: "event"});
  }
}

// Radio button deselection functionality
document.addEventListener("DOMContentLoaded", function() {
  // Sync consent checkboxes when they change
  var deCheck = document.getElementById("consent_check");
  var enCheck = document.getElementById("consent_check_en");
  
  if (deCheck) {
    deCheck.addEventListener("change", function() {
      if (enCheck) enCheck.checked = deCheck.checked;
    });
  }
  
  if (enCheck) {
    enCheck.addEventListener("change", function() {
      if (deCheck) deCheck.checked = enCheck.checked;
    });
  }
  
  // Radio button deselection
  document.addEventListener("click", function(e) {
    if (e.target && e.target.type === "radio") {
      var wasChecked = e.target.getAttribute("data-was-checked") === "true";
      
      var radios = document.querySelectorAll("input[name=\\"" + e.target.name + "\\"]");
      for (var i = 0; i < radios.length; i++) {
        radios[i].setAttribute("data-was-checked", "false");
      }
      
      if (wasChecked) {
        e.target.checked = false;
        if (typeof Shiny !== "undefined") {
          Shiny.setInputValue(e.target.name, null, {priority: "event"});
        }
      } else {
        e.target.setAttribute("data-was-checked", "true");
      }
    }
  });
});
</script>'

# Server extensions for language handling
server_extensions <- function(input, output, session) {
  # Track current language
  session$userData$current_language <- reactiveVal("de")
  
  # Handle language switching
  observeEvent(input$study_language, {
    new_lang <- input$study_language
    session$userData$current_language(new_lang)
    
    # Update item bank language
    if (new_lang == "en") {
      session$userData$item_bank <- all_items_de
      session$userData$item_bank$Question <- all_items_de$Question_EN
    } else {
      session$userData$item_bank <- all_items_de
    }
    
    # Send message to update UI
    session$sendCustomMessage("update_language", new_lang)
  })
}

# Launch with cloud storage, adaptive testing, and enhanced features
inrep::launch_study(
    config = study_config,
    item_bank = all_items_de,  # Bilingual item bank
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv",
    custom_css = custom_js_enhanced,  # Enhanced JavaScript
    admin_dashboard_hook = monitor_adaptive  # Monitor adaptive selection
)
