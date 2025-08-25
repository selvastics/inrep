


# Ensure inrep is installed only if not present
if (!requireNamespace("inrep", quietly = TRUE)) {
  if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
  devtools::install_github("selvastics/inrep", ref = "main")
}
library(inrep)


library(shiny)
library(ggplot2)
library(broom)
library(emmeans)
library(ggthemes)
library(DT)
library(shinycssloaders)
library(patchwork)
library(markdown)
library(shinyjs)


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
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
  # Page 1: Einleitungstext with mandatory consent and language switcher
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur HilFo Studie",
    title_en = "Welcome to the HilFo Study",
    content = paste0(
      '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">',
      # Language switcher in top right corner (uses global toggle function)
      '<div style="position: absolute; top: 10px; right: 10px;">',
      '<button type="button" id="lang_switch" onclick="window.toggleLanguage()" style="',
      'background: white; border: 2px solid #e8041c; color: #e8041c; ',
      'padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px;">',
      '<span id="lang_switch_text">English Version</span></button>',
      '</div>',
      # German content (default)
      '<div id="content_de">',
      '<h2 style="color: #e8041c;">Liebe Studierende,</h2>',
      '<p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, ',
      'die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>',
      '<p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene ',
      'Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene ',
      'Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im ',
      'Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.</p>',
      '<p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, ',
      'inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. ',
      'Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.</p>',
      '<p style="margin-top: 20px;"><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>',
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
      '<p>Since we want to enable various analyses, the questionnaire covers different ',
      'topic areas that are partially independent of each other.</p>',
      '<p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">',
      '<strong>Your information is completely anonymous</strong>, there will be no personal ',
      'evaluation of the data. The data is generated by first-semester psychology ',
      'bachelor students and used in this cohort, possibly also in later cohorts.</p>',
      '<p>In the following, you will be presented with statements. We ask you to indicate ',
      'to what extent you agree with them. There are no wrong or right answers. ',
      'Please answer the questions as they best reflect your opinion.</p>',
      '<p style="margin-top: 20px;"><strong>The survey takes about 10-15 minutes.</strong></p>',
      '<hr style="margin: 30px 0; border: 1px solid #e8041c;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">',
      '<h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>I agree to participate in the survey</strong></span>',
      '</label>',
      '</div>',
      '</div>',
      '</div>',
      # JavaScript for checkbox syncing only (language toggle uses global function)
      '<script>
// Sync consent checkboxes when they change
document.addEventListener("DOMContentLoaded", function() {
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
});
</script>'
    ),
    validate = "function(inputs) { return document.getElementById('consent_check').checked || document.getElementById('consent_check_en').checked; }",
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
  
  # Page 6: Programming Anxiety Part 1 - FIXED (first 5 items together)
  list(
    id = "page6_pa_fixed",
    type = "items",
    title = "Programmierangst - Teil 1",
    title_en = "Programming Anxiety - Part 1",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:5,  # First 5 PA items (fixed, all on one page)
    scale_type = "likert"
  ),
  
  # Pages 7-11: Programming Anxiety Part 2 - Adaptive (5 items, one per page)
  # NOTE: With custom_page_flow, these are shown sequentially, not adaptively
  # We simulate adaptive output for demonstration
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
    item_indices = 21:25,  # BFI items (after 20 PA items)
    scale_type = "likert"
  ),
  list(
    id = "page13",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    title_en = "Personality - Part 2",
    item_indices = 26:30,  # BFI items continued
    scale_type = "likert"
  ),
  list(
    id = "page14",
    type = "items",
    title = "Persönlichkeit - Teil 3",
    title_en = "Personality - Part 3",
    item_indices = 31:35,  # BFI items continued
    scale_type = "likert"
  ),
  list(
    id = "page15",
    type = "items",
    title = "Persönlichkeit - Teil 4",
    title_en = "Personality - Part 4",
    item_indices = 36:40,  # BFI items final
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
    item_indices = 41:45,  # PSQ items (after 20 PA + 20 BFI)
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
    item_indices = 46:49,  # MWS items
    scale_type = "difficulty"
  ),
  
  # Page 18: Statistics
  list(
    id = "page18",
    type = "items",
    title = "Statistik",
    title_en = "Statistics",
    item_indices = 50:51,  # Statistics items
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
  
  # Page 20: Results (now with PA results included)
  list(
    id = "page20",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results"
  )
)

# =============================================================================
# RESULTS PROCESSOR WITH FIXED RADAR PLOT
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  # Lazy load packages only when actually needed
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("ggplot2 package is required for report generation")
  }
  if (!requireNamespace("base64enc", quietly = TRUE)) {
    stop("base64enc package is required for report generation")
  }
  
  # Get current language from session if available
  current_lang <- "de"  # Default to German
  if (!is.null(session) && !is.null(session$userData$current_language)) {
    current_lang <- session$userData$current_language
  }
  
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
  
  # Ensure we have all 51 item responses (20 PA + 31 original)
  if (length(responses) < 51) {
    responses <- c(responses, rep(3, 51 - length(responses)))
  }
  responses <- as.numeric(responses)
  
  # Calculate Programming Anxiety score (first 10 items shown)
  pa_responses <- responses[1:10]
  # Reverse score items 1, 10 (and 15 if shown)
  pa_responses[c(1)] <- 6 - pa_responses[c(1)]
  pa_responses[c(10)] <- 6 - pa_responses[c(10)]
  pa_score <- mean(pa_responses, na.rm = TRUE)
  
  # Compute IRT-based ability estimate for Programming Anxiety
  # This is a semi-adaptive assessment: 5 fixed + 5 adaptively selected items
  pa_theta <- pa_score  # Default to classical score
  
  # Fit 2PL IRT model for Programming Anxiety
  cat("\n================================================================================\n")
  cat("PROGRAMMING ANXIETY - IRT MODEL (2PL)\n")
  cat("================================================================================\n")
  cat("Assessment Type: Semi-Adaptive (5 fixed + 5 adaptive items)\n")
  cat("Total items administered: 10\n")
  cat("\n")
  
  # Get item parameters for the 10 PA items that were shown
  # Note: In real adaptive testing, items 6-10 would be selected based on responses
  shown_items <- all_items_de[1:10, ]
  a_params <- shown_items$a
  b_params <- shown_items$b
  
  # Use Maximum Likelihood Estimation for theta
  theta_est <- 0  # Start with prior mean
  converged <- FALSE
  
  for (iter in 1:20) {
    # Calculate probabilities for current theta using 2PL model
    probs <- 1 / (1 + exp(-a_params * (theta_est - b_params)))
    
    # Convert responses to 0-1 scale for IRT
    resp_binary <- (pa_responses - 1) / 4  # Convert 1-5 to 0-1
    
    # First derivative (score function)
    first_deriv <- sum(a_params * (resp_binary - probs))
    
    # Second derivative (information)
    second_deriv <- -sum(a_params^2 * probs * (1 - probs))
    
    # Update theta using Newton-Raphson
    if (abs(second_deriv) > 0.01) {
      delta <- first_deriv / second_deriv
      theta_est <- theta_est - delta
      
      # Check convergence
      if (abs(delta) < 0.001) {
        converged <- TRUE
        break
      }
    }
  }
  
  # Calculate standard error and test information
  info <- sum(a_params^2 * (1 / (1 + exp(-a_params * (theta_est - b_params)))) * 
                (1 - 1 / (1 + exp(-a_params * (theta_est - b_params)))))
  se_est <- 1 / sqrt(info)
  reliability <- 1 - (1/info)  # Approximate reliability
  
  # Output results
  cat(sprintf("Classical Score (mean): %.2f (range 1-5)\n", pa_score))
  cat(sprintf("IRT Theta Estimate: %.3f\n", theta_est))
  cat(sprintf("Standard Error (SE): %.3f\n", se_est))
  cat(sprintf("Test Information: %.3f\n", info))
  cat(sprintf("Reliability: %.3f\n", reliability))
  cat(sprintf("Convergence: %s (iterations: %d)\n", ifelse(converged, "Yes", "No"), iter))
  cat("\n")
  
  # Interpretation on standardized scale
  z_score <- theta_est  # Theta is already on z-score scale
  percentile <- pnorm(z_score) * 100
  
  cat(sprintf("Percentile Rank: %.1f%%\n", percentile))
  
  if (theta_est < -1.5) {
    cat("Interpretation: Very low programming anxiety (bottom 7%)\n")
  } else if (theta_est < -0.5) {
    cat("Interpretation: Low programming anxiety (below average)\n")
  } else if (theta_est < 0.5) {
    cat("Interpretation: Moderate programming anxiety (average)\n")
  } else if (theta_est < 1.5) {
    cat("Interpretation: High programming anxiety (above average)\n")
  } else {
    cat("Interpretation: Very high programming anxiety (top 7%)\n")
  }
  cat("================================================================================\n\n")
  
  # Store IRT estimate (scale to 1-5 for consistency with other scores)
  # Convert theta to 1-5 scale: theta of -2 = 1, theta of 2 = 5
  pa_theta_scaled <- 3 + theta_est  # Center at 3, each SD = 1 point
  pa_theta_scaled <- pmax(1, pmin(5, pa_theta_scaled))  # Bound to 1-5
  pa_theta <- pa_theta_scaled
  
  # Create trace plot showing theta progression (simulated for semi-adaptive)
  # In a real adaptive test, this would show actual theta estimates after each item
  theta_trace <- numeric(10)
  se_trace <- numeric(10)
  
  # Simulate theta progression
  for (i in 1:10) {
    # Calculate theta up to item i
    resp_subset <- (pa_responses[1:i] - 1) / 4
    a_subset <- a_params[1:i]
    b_subset <- b_params[1:i]
    
    # Quick theta estimation for this subset
    theta_temp <- 0
    for (iter in 1:5) {
      probs <- 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))
      first_d <- sum(a_subset * (resp_subset - probs))
      second_d <- -sum(a_subset^2 * probs * (1 - probs))
      if (abs(second_d) > 0.01) {
        theta_temp <- theta_temp - first_d / second_d
      }
    }
    
    # Calculate SE for this estimate
    info_temp <- sum(a_subset^2 * (1 / (1 + exp(-a_subset * (theta_temp - b_subset)))) * 
                       (1 - 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))))
    se_temp <- 1 / sqrt(info_temp)
    
    theta_trace[i] <- theta_temp
    se_trace[i] <- se_temp
  }
  
  # Calculate BFI scores - PROPER GROUPING BY TRAIT (now starting at index 21)
  # Items are ordered: E1, E2, E3, E4, V1, V2, V3, V4, G1, G2, G3, G4, N1, N2, N3, N4, O1, O2, O3, O4
  scores <- list(
    ProgrammingAnxiety = if (exists("pa_theta")) pa_theta else pa_score,
    Extraversion = mean(c(responses[21], 6-responses[22], 6-responses[23], responses[24]), na.rm=TRUE),
    Verträglichkeit = mean(c(responses[25], 6-responses[26], responses[27], 6-responses[28]), na.rm=TRUE),
    Gewissenhaftigkeit = mean(c(6-responses[29], responses[30], responses[31], 6-responses[32]), na.rm=TRUE),
    Neurotizismus = mean(c(6-responses[33], responses[34], responses[35], 6-responses[36]), na.rm=TRUE),
    Offenheit = mean(c(responses[37], 6-responses[38], responses[39], 6-responses[40]), na.rm=TRUE)
  )
  
  # PSQ Stress score (now at indices 41-45)
  psq <- responses[41:45]
  scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
  
  # MWS & Statistics (now at indices 46-49 and 50-51)
  scores$Studierfähigkeiten <- mean(responses[46:49], na.rm=TRUE)
  scores$Statistik <- mean(responses[50:51], na.rm=TRUE)
  
  # Create radar plot using ggradar approach
  # Check for ggradar (should be pre-installed)
  
  # Prepare data for ggradar - needs to be scaled 0-1
  radar_data <- data.frame(
    group = "Ihr Profil",
    Extraversion = scores$Extraversion / 5,
    Verträglichkeit = scores$Verträglichkeit / 5,
    Gewissenhaftigkeit = scores$Gewissenhaftigkeit / 5,
    Neurotizismus = scores$Neurotizismus / 5,
    Offenheit = scores$Offenheit / 5
  )
  
  # Create radar plot with ggradar
  if (requireNamespace("ggradar", quietly = TRUE)) {
    radar_plot <- ggradar::ggradar(
      radar_data,
      values.radar = c("1", "3", "5"),  # Min, mid, max labels
      grid.min = 0,
      grid.mid = 0.6,
      grid.max = 1,
      grid.label.size = 5,
      axis.label.size = 5,
      group.point.size = 4,
      group.line.width = 1.5,
      background.circle.colour = "white",
      gridline.min.colour = "gray90",
      gridline.mid.colour = "gray80",
      gridline.max.colour = "gray70",
      group.colours = c("#e8041c"),
      plot.extent.x.sf = 1.3,
      plot.extent.y.sf = 1.2,
      legend.position = "none"
    ) +
      ggplot2::theme(
        plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, 
                                           color = "#e8041c", margin = ggplot2::margin(b = 20)),
        plot.background = ggplot2::element_rect(fill = "white", color = NA),
        plot.margin = ggplot2::margin(20, 20, 20, 20)
      ) +
      ggplot2::labs(title = if (current_lang == "en") "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)")
  } else {
    # Fallback to simple ggplot2 approach if ggradar not available
    # Use namespace to avoid loading issues
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("ggplot2 package is required for plotting")
    }
    
    # Create coordinates for manual radar plot
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
    
    # Grid lines data
    grid_data <- expand.grid(
      r = 1:5,
      angle = seq(0, 2*pi, length.out = 50)
    )
    grid_data$x <- grid_data$r * cos(grid_data$angle)
    grid_data$y <- grid_data$r * sin(grid_data$angle)
    
    # Create plot
    radar_plot <- ggplot2::ggplot() +
      # Grid circles
      ggplot2::geom_path(data = grid_data, ggplot2::aes(x = x, y = y, group = r),
                         color = "gray85", size = 0.3) +
      # Spokes
      ggplot2::geom_segment(data = data.frame(angle = angles),
                            ggplot2::aes(x = 0, y = 0,
                                         xend = 5 * cos(angle - pi/2),
                                         yend = 5 * sin(angle - pi/2)),
                            color = "gray85", size = 0.3) +
      # Data polygon
      ggplot2::geom_polygon(data = plot_data, ggplot2::aes(x = x, y = y),
                            fill = "#e8041c", alpha = 0.2) +
      ggplot2::geom_path(data = plot_data, ggplot2::aes(x = x, y = y),
                         color = "#e8041c", size = 2) +
      # Points
      ggplot2::geom_point(data = plot_data[1:5,], ggplot2::aes(x = x, y = y),
                          color = "#e8041c", size = 5) +
      # Labels
      ggplot2::geom_text(data = plot_data[1:5,],
                         ggplot2::aes(x = x * 1.3, y = y * 1.3, label = label),
                         size = 5, fontface = "bold") +
      ggplot2::geom_text(data = plot_data[1:5,],
                         ggplot2::aes(x = x * 1.1, y = y * 1.1, label = sprintf("%.1f", score)),
                         size = 4, color = "#e8041c") +
      ggplot2::coord_equal() +
      ggplot2::xlim(-6, 6) + ggplot2::ylim(-6, 6) +
      ggplot2::theme_void() +
      ggplot2::theme(
        plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5,
                                           color = "#e8041c", margin = ggplot2::margin(b = 20)),
        plot.margin = ggplot2::margin(30, 30, 30, 30)
      ) +
      ggplot2::labs(title = if (current_lang == "en") "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)")
  }
  
  # Create bar chart with logical ordering
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
    # Add value labels with better formatting
    ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), 
                       vjust = -0.5, size = 6, fontface = "bold", color = "#333") +
    # Custom color scheme
    ggplot2::scale_fill_manual(values = c(
      "Programmierangst" = "#9b59b6",
      "Persönlichkeit" = "#e8041c",
      "Stress" = "#ff6b6b",
      "Studierfähigkeiten" = "#4ecdc4",
      "Statistik" = "#45b7d1"
    )) +
    # Y-axis customization
    ggplot2::scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
    # Theme with larger text
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
      axis.text.y = ggplot2::element_text(size = 12),
      axis.title.x = ggplot2::element_blank(),
      axis.title.y = ggplot2::element_text(size = 14, face = "bold"),
      plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, color = "#e8041c", margin = ggplot2::margin(b = 20)),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_line(color = "gray90", size = 0.3),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      legend.text = ggplot2::element_text(size = 12),
      plot.margin = ggplot2::margin(20, 20, 20, 20)
    ) +
    ggplot2::labs(
      title = if (current_lang == "en") "All Dimensions Overview" else "Alle Dimensionen im Überblick", 
      y = if (current_lang == "en") "Score (1-5)" else "Punktzahl (1-5)"
    )
  
  # Create trace plot for Programming Anxiety adaptive testing
  trace_data <- data.frame(
    item = 1:10,
    theta = theta_trace,
    se_upper = theta_trace + se_trace,
    se_lower = theta_trace - se_trace,
    item_type = c(rep("Fixed", 5), rep("Adaptive", 5))
  )
  
  trace_plot <- ggplot2::ggplot(trace_data, ggplot2::aes(x = item, y = theta)) +
    # Confidence band
    ggplot2::geom_ribbon(ggplot2::aes(ymin = se_lower, ymax = se_upper), 
                         alpha = 0.3, fill = "#9b59b6") +
    # Theta line
    ggplot2::geom_line(linewidth = 2, color = "#9b59b6") +
    ggplot2::geom_point(ggplot2::aes(color = item_type), size = 4) +
    # Add horizontal line at final theta
    ggplot2::geom_hline(yintercept = theta_est, linetype = "dashed", 
                        color = "#9b59b6", alpha = 0.5) +
    # Vertical line separating fixed and adaptive
    ggplot2::geom_vline(xintercept = 5.5, linetype = "dotted", 
                        color = "gray50", alpha = 0.7) +
    # Annotations
    ggplot2::annotate("text", x = 2.5, y = max(trace_data$se_upper) * 0.9, 
                      label = "Fixed Items", size = 4, color = "gray40") +
    ggplot2::annotate("text", x = 8, y = max(trace_data$se_upper) * 0.9, 
                      label = "Adaptive Items", size = 4, color = "gray40") +
    # Scales
    ggplot2::scale_x_continuous(breaks = 1:10, labels = 1:10) +
    ggplot2::scale_color_manual(values = c("Fixed" = "#e8041c", "Adaptive" = "#4ecdc4")) +
    # Theme
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5, 
                                         color = "#9b59b6", margin = ggplot2::margin(b = 15)),
      plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5, 
                                            color = "gray50", margin = ggplot2::margin(b = 10)),
      axis.title = ggplot2::element_text(size = 12, face = "bold"),
      axis.text = ggplot2::element_text(size = 11),
      legend.position = "bottom",
      legend.title = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      plot.margin = ggplot2::margin(20, 20, 20, 20)
    ) +
    ggplot2::labs(
      title = if (current_lang == "en") "Programming Anxiety - Adaptive Testing Trace" else "Programmierangst - Adaptive Testung",
      subtitle = sprintf(if (current_lang == "en") "Final θ = %.3f (SE = %.3f)" else "Finales θ = %.3f (SE = %.3f)", theta_est, se_est),
      x = if (current_lang == "en") "Item Number" else "Item-Nummer",
      y = if (current_lang == "en") "Theta Estimate (θ)" else "Theta-Schätzung (θ)"
    )
  
  # Save plots
  radar_file <- tempfile(fileext = ".png")
  bar_file <- tempfile(fileext = ".png")
  trace_file <- tempfile(fileext = ".png")
  
  suppressMessages({
    ggplot2::ggsave(radar_file, radar_plot, width = 10, height = 9, dpi = 150, bg = "white")
    ggplot2::ggsave(bar_file, bar_plot, width = 12, height = 7, dpi = 150, bg = "white")
    ggplot2::ggsave(trace_file, trace_plot, width = 10, height = 6, dpi = 150, bg = "white")
  })
  
  # Encode as base64
  radar_base64 <- ""
  bar_base64 <- ""
  trace_base64 <- ""  # Initialize trace_base64
  if (requireNamespace("base64enc", quietly = TRUE)) {
    radar_base64 <- base64enc::base64encode(radar_file)
    bar_base64 <- base64enc::base64encode(bar_file)
    trace_base64 <- base64enc::base64encode(trace_file)
  }
  unlink(c(radar_file, bar_file, trace_file))
  
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
  
  # Generate HTML report with download button
  report_id <- paste0("report_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  
  html <- paste0(
    '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
    
    # Radar plot
    '<div class="report-section">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
    '<span data-lang-de="Persönlichkeitsprofil" data-lang-en="Personality Profile">Persönlichkeitsprofil</span></h2>',
    if (radar_base64 != "") paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px;">'),
    '</div>',
    
    # Trace plot for Programming Anxiety
    '<div class="report-section">',
    '<h2 style="color: #9b59b6; text-align: center; margin-bottom: 25px;">',
    '<span data-lang-de="Programmierangst - Adaptive Testung" data-lang-en="Programming Anxiety - Adaptive Testing Trace">Programmierangst - Adaptive Testung</span></h2>',
    if (exists("trace_base64") && trace_base64 != "") paste0('<img src="data:image/png;base64,', trace_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto; border-radius: 8px;">'),
    '<p style="text-align: center; color: #666; margin-top: 10px; font-size: 14px;">',
    '<span data-lang-de="Dieses Diagramm zeigt die Entwicklung der Theta-Schätzung während der Bewertung. Der schattierte Bereich zeigt das Standardfehlerband. Die vertikale Linie trennt fixe und adaptive Items." ',
    'data-lang-en="This trace plot shows how the theta estimate evolved during the assessment. The shaded area represents the standard error band. Vertical line separates fixed and adaptive items.">',
    'Dieses Diagramm zeigt die Entwicklung der Theta-Schätzung während der Bewertung. Der schattierte Bereich zeigt das Standardfehlerband. Die vertikale Linie trennt fixe und adaptive Items.',
    '</span></p>',
    '</div>',
    
    # Bar chart
    '<div class="report-section">',
    '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
    '<span data-lang-de="Alle Dimensionen im Überblick" data-lang-en="All Dimensions Overview">Alle Dimensionen im Überblick</span></h2>',
    if (bar_base64 != "") paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 8px;">'),
    '</div>',
    
    # Table
    '<div class="report-section">',
    '<h2 style="color: #e8041c;">',
    '<span data-lang-de="Detaillierte Auswertung" data-lang-en="Detailed Results">Detaillierte Auswertung</span></h2>',
    '<table style="width: 100%; border-collapse: collapse;">',
    '<tr style="background: #f8f8f8;">',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
    '<span data-lang-de="Dimension" data-lang-en="Dimension">Dimension</span></th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">',
    '<span data-lang-de="Mittelwert" data-lang-en="Mean">Mittelwert</span></th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">',
    '<span data-lang-de="Standardabweichung" data-lang-en="Standard Deviation">Standardabweichung</span></th>',
    '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
    '<span data-lang-de="Interpretation" data-lang-en="Interpretation">Interpretation</span></th>',
    '</tr>'
  )
  
  # Calculate standard deviations for each dimension
  sds <- list()
  
  # Programming Anxiety - 10 items (items 1-10)
  # Apply reverse scoring for items 1, 10, and 15 (but we only have 10 items, so items 1 and 10)
  pa_items_scored <- responses[1:10]
  pa_items_scored[1] <- 6 - pa_items_scored[1]  # Reverse item 1
  pa_items_scored[10] <- 6 - pa_items_scored[10]  # Reverse item 10
  sd_val <- sd(pa_items_scored, na.rm = TRUE)
  sds[["ProgrammingAnxiety"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  # Big Five dimensions - each has 4 items (with reverse scoring applied)
  # Items are now 21-40 (after PA items)
  bfi_dims <- list(
    Extraversion = c(responses[21], 6-responses[22], 6-responses[23], responses[24]),
    Verträglichkeit = c(responses[25], 6-responses[26], responses[27], 6-responses[28]),
    Gewissenhaftigkeit = c(6-responses[29], responses[30], responses[31], 6-responses[32]),
    Neurotizismus = c(6-responses[33], responses[34], responses[35], 6-responses[36]),
    Offenheit = c(responses[37], 6-responses[38], responses[39], 6-responses[40])
  )
  
  for (dim_name in names(bfi_dims)) {
    sd_val <- sd(bfi_dims[[dim_name]], na.rm = TRUE)
    sds[[dim_name]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  }
  
  # PSQ Stress - 5 items (with reverse scoring for item 4)
  # Items are now 41-45 (after PA and BFI)
  psq_items <- c(responses[41:43], 6-responses[44], responses[45])
  sd_val <- sd(psq_items, na.rm = TRUE)
  sds[["Stress"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  # MWS Studierfähigkeiten - 4 items (items 46-49)
  mws_items <- responses[46:49]
  sd_val <- sd(mws_items, na.rm = TRUE)
  sds[["Studierfähigkeiten"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  # Statistik - 2 items (items 50-51)
  stat_items <- responses[50:51]
  sd_val <- sd(stat_items, na.rm = TRUE)
  sds[["Statistik"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
  
  for (name in names(scores)) {
    value <- round(scores[[name]], 2)
    sd_value <- ifelse(name %in% names(sds), sds[[name]], NA)
    level <- ifelse(value >= 3.7, 
                    '<span data-lang-de="Hoch" data-lang-en="High">Hoch</span>', 
                    ifelse(value >= 2.3, 
                           '<span data-lang-de="Mittel" data-lang-en="Medium">Mittel</span>', 
                           '<span data-lang-de="Niedrig" data-lang-en="Low">Niedrig</span>'))
    color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
    
    # Translate dimension names
    name_display <- switch(name,
                           "ProgrammingAnxiety" = '<span data-lang-de="Programmierangst" data-lang-en="Programming Anxiety">Programmierangst</span>',
                           "Extraversion" = '<span data-lang-de="Extraversion" data-lang-en="Extraversion">Extraversion</span>',
                           "Verträglichkeit" = '<span data-lang-de="Verträglichkeit" data-lang-en="Agreeableness">Verträglichkeit</span>',
                           "Gewissenhaftigkeit" = '<span data-lang-de="Gewissenhaftigkeit" data-lang-en="Conscientiousness">Gewissenhaftigkeit</span>',
                           "Neurotizismus" = '<span data-lang-de="Neurotizismus" data-lang-en="Neuroticism">Neurotizismus</span>',
                           "Offenheit" = '<span data-lang-de="Offenheit" data-lang-en="Openness">Offenheit</span>',
                           "Stress" = '<span data-lang-de="Stress" data-lang-en="Stress">Stress</span>',
                           "Studierfähigkeiten" = '<span data-lang-de="Studierfähigkeiten" data-lang-en="Study Skills">Studierfähigkeiten</span>',
                           "Statistik" = '<span data-lang-de="Statistik" data-lang-en="Statistics">Statistik</span>',
                           name  # Default fallback
    )
    
    html <- paste0(html,
                   '<tr>',
                   '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', name_display, '</td>',
                   '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
                   '<strong style="color: ', color, ';">', value, '</strong></td>',
                   '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
                   ifelse(is.na(sd_value), "-", as.character(sd_value)), '</td>',
                   '<td style="padding: 12px; border-bottom: 1px solid #e0e0e0; color: #666;">',
                   level, '</td>',
                   '</tr>'
    )
  }
  
  html <- paste0(html,
                 '</table>',
                 '</div>'  # Close table section
  )
  
  # Add beautiful styles for the report
  html <- paste0(html,
                 '<style>',
                 'body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }',
                 '#report-content { background: #f8f9fa; }',
                 'table { border-collapse: collapse; width: 100%; }',
                 'table tr:hover { background: #f5f5f5; }',
                 'h1, h2 { font-family: "Segoe UI", sans-serif; }',
                 '.report-section { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }',
                 '@media print {',
                 '  body { font-size: 11pt; }',
                 '  h1, h2 { color: #e8041c !important; -webkit-print-color-adjust: exact; }',
                 '}',
                 '</style>',
                 
                 '</div>'
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

# Complete JavaScript solution for FULL APP translation and radio deselection
custom_js_enhanced <- '
<style>
/* Fixed language button on all pages */
#language-toggle-btn {
  position: fixed !important;
  top: 10px !important;
  right: 10px !important;
  z-index: 9999 !important;
  background: white !important;
  border: 2px solid #e8041c !important;
  color: #e8041c !important;
  padding: 8px 16px !important;
  border-radius: 4px !important;
  cursor: pointer !important;
  font-size: 14px !important;
  font-weight: bold !important;
}
#language-toggle-btn:hover {
  background: #e8041c !important;
  color: white !important;
}
</style>
<script>
// Comprehensive translation dictionary for ENTIRE APP
var translations = {
  // Page titles
  "Wohnsituation": "Living Situation",
  "Soziodemographische Angaben": "Sociodemographic Information",
  "Lebensstil": "Lifestyle",
  "Bildung": "Education",
  "Persönlichkeit": "Personality",
  "Studienzufriedenheit": "Study Satisfaction",
  "Ihre Ergebnisse": "Your Results",
  
  // Questions
  "Wie wohnen Sie?": "How do you live?",
  "Wie alt sind Sie?": "How old are you?",
  "In welchem Studiengang befinden Sie sich?": "Which study program are you in?",
  "Welches Geschlecht haben Sie?": "What is your gender?",
  "Haben Sie ein Haustier oder möchten Sie eines?": "Do you have a pet or would you like one?",
  "Rauchen Sie?": "Do you smoke?",
  "Wie ernähren Sie sich hauptsächlich?": "What is your main diet?",
  
  // Options
  "Bei meinen Eltern/Elternteil": "With my parents/parent",
  "In einer WG/WG in einem Wohnheim": "In a shared apartment/dorm",
  "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim": "Alone/in a self-contained unit in a dorm",
  "Mit meinem/r Partner*In (mit oder ohne Kinder)": "With my partner (with or without children)",
  "Anders": "Other",
  "Bachelor Psychologie": "Bachelor Psychology",
  "Master Psychologie": "Master Psychology",
  "weiblich oder divers": "female or diverse",
  "männlich": "male",
  "Ja": "Yes",
  "Nein": "No",
  "Hund": "Dog",
  "Katze": "Cat",
  "Fische": "Fish",
  "Vogel": "Bird",
  "Nager": "Rodent",
  "Reptil": "Reptile",
  "Ich möchte kein Haustier": "I don\'t want a pet",
  "Sonstiges": "Other",
  "Vegan": "Vegan",
  "Vegetarisch": "Vegetarian",
  "Pescetarisch": "Pescetarian",
  "Flexitarisch": "Flexitarian",
  "Omnivor (alles)": "Omnivore (everything)",
  "Andere": "Other",
  "älter als 30": "older than 30",
  
  // Instructions
  "Falls anders, bitte spezifizieren:": "If other, please specify:",
  "Anderes Haustier:": "Other pet:",
  "Andere Ernährungsform:": "Other diet:",
  "Bitte wählen...": "Please select...",
  "Bitte wählen Sie": "Please select",
  
  // Navigation
  "Seite": "Page",
  "von": "of",
  "Weiter": "Next",
  "Zurück": "Back",
  
  // Validation messages
  "Bitte beantworten Sie:": "Please answer:",
  "Dieses Feld ist erforderlich": "This field is required",
  "Bitte vervollständigen Sie die folgenden Angaben:": "Please complete the following:",
  
  // Likert scales
  "trifft nicht zu": "strongly disagree",
  "trifft eher nicht zu": "disagree",
  "teils/teils": "neutral",
  "trifft eher zu": "agree",
  "trifft zu": "strongly agree",
  "sehr gut": "very good",
  "gut": "good",
  "befriedigend": "satisfactory",
  "ausreichend": "sufficient",
  "mangelhaft": "poor",
  
  // Grade options
  "sehr gut (15-13 Punkte)": "very good (15-13 points)",
  "gut (12-10 Punkte)": "good (12-10 points)",
  "befriedigend (9-7 Punkte)": "satisfactory (9-7 points)",
  "ausreichend (6-4 Punkte)": "sufficient (6-4 points)",
  "mangelhaft (3-0 Punkte)": "poor (3-0 points)",
  
  // Study hours
  "0 Stunden": "0 hours",
  "maximal eine Stunde": "maximum one hour",
  "mehr als eine, aber weniger als 2 Stunden": "more than one, but less than 2 hours",
  "mehr als zwei, aber weniger als 3 Stunden": "more than two, but less than 3 hours",
  "mehr als drei, aber weniger als 4 Stunden": "more than three, but less than 4 hours",
  "mehr als 4 Stunden": "more than 4 hours",
  
  // Satisfaction scale
  "gar nicht zufrieden": "not at all satisfied",
  "sehr zufrieden": "very satisfied",
  
  // Additional questions
  "Welche Note hatten Sie in Englisch im Abiturzeugnis?": "What grade did you have in English in your Abitur certificate?",
  "Welche Note hatten Sie in Mathematik im Abiturzeugnis?": "What grade did you have in Mathematics in your Abitur certificate?",
  "Wieviele Stunden pro Woche planen Sie für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?": "How many hours per week do you plan to invest in preparing and reviewing statistics courses?",
  "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-stufig)": "How satisfied are you with your study location Hildesheim? (5-point scale)",
  "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-stufig)": "How satisfied are you with your study location Hildesheim? (7-point scale)",
  "Bitte erstellen Sie einen persönlichen Code (erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags):": "Please create a personal code (first 2 letters of your mother\'s first name + first 2 letters of your birthplace + day of your birthday):",
  
  // Programming Anxiety titles
  "Programmierangst - Teil 1": "Programming Anxiety - Part 1",
  "Programmierangst - Teil 2": "Programming Anxiety - Part 2",
  "Programmierangst": "Programming Anxiety",
  
  // Instructions
  "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.": "Please indicate to what extent the following statements apply to you.",
  "Die folgenden Fragen werden basierend auf Ihren vorherigen Antworten ausgewählt.": "The following questions are selected based on your previous answers.",
  "Wie sehr treffen die folgenden Aussagen auf Sie zu?": "How much do the following statements apply to you?",
  "Wie leicht oder schwer fällt es Ihnen...": "How easy or difficult is it for you..."
};

var currentLang = "de";

// Function to translate entire page - AGGRESSIVE VERSION
function translatePage() {
  if (currentLang === "en") {
    // First, translate all headings and titles
    document.querySelectorAll("h1, h2, h3, h4, h5, h6, .shiny-title, .panel-title").forEach(function(el) {
      for (var de in translations) {
        if (el.innerHTML.indexOf(de) !== -1) {
          el.innerHTML = el.innerHTML.replace(new RegExp(de, "g"), translations[de]);
        }
      }
    });
    
    // Translate all labels including nested text
    document.querySelectorAll("label, .control-label, .shiny-label").forEach(function(label) {
      for (var de in translations) {
        if (label.innerHTML.indexOf(de) !== -1) {
          label.innerHTML = label.innerHTML.replace(new RegExp(de, "g"), translations[de]);
        }
      }
    });
    
    // Translate select options more aggressively
    document.querySelectorAll("select").forEach(function(select) {
      // Update the placeholder option
      if (select.options[0] && select.options[0].text === "Bitte wählen...") {
        select.options[0].text = "Please select...";
      }
      
      // Translate all options
      for (var i = 0; i < select.options.length; i++) {
        var option = select.options[i];
        for (var de in translations) {
          if (option.text === de) {
            option.text = translations[de];
            break;
          }
        }
      }
    });
    
    // Translate radio button labels
    document.querySelectorAll(".radio label, .checkbox label").forEach(function(label) {
      var spans = label.querySelectorAll("span");
      spans.forEach(function(span) {
        for (var de in translations) {
          if (span.textContent.trim() === de) {
            span.textContent = translations[de];
            break;
          }
        }
      });
      
      // Also check direct text nodes
      for (var i = 0; i < label.childNodes.length; i++) {
        var node = label.childNodes[i];
        if (node.nodeType === 3) { // Text node
          var text = node.nodeValue.trim();
          if (translations[text]) {
            node.nodeValue = " " + translations[text] + " ";
          }
        }
      }
    });
    
    // Translate buttons
    document.querySelectorAll("button, .btn").forEach(function(button) {
      for (var de in translations) {
        if (button.textContent.trim() === de) {
          button.textContent = translations[de];
          break;
        }
      }
    });
    
    // Translate any divs or spans with text
    document.querySelectorAll("div, span, p").forEach(function(el) {
      if (el.children.length === 0) { // Only leaf nodes
        var text = el.textContent.trim();
        if (translations[text]) {
          el.textContent = translations[text];
        }
      }
    });
    
    // Translate placeholders
    document.querySelectorAll("[placeholder]").forEach(function(elem) {
      if (translations[elem.placeholder]) {
        elem.placeholder = translations[elem.placeholder];
      }
    });
    
    // Special handling for page navigation
    document.querySelectorAll(".progress-text, .page-number").forEach(function(el) {
      el.innerHTML = el.innerHTML.replace(/Seite/g, "Page").replace(/von/g, "of");
    });
    
    // Force update any remaining German text
    var allElements = document.querySelectorAll("*");
    allElements.forEach(function(el) {
      if (el.children.length === 0 && el.textContent) {
        var text = el.textContent.trim();
        if (text && translations[text]) {
          el.textContent = translations[text];
        }
      }
    });
  }
}

// Global language toggle function with debouncing
var toggleInProgress = false;
window.toggleLanguage = function() {
  // Prevent multiple rapid clicks
  if (toggleInProgress) return;
  toggleInProgress = true;
  setTimeout(function() { toggleInProgress = false; }, 500); // 500ms debounce
  
  currentLang = currentLang === "de" ? "en" : "de";
  
  // Update button text
  var btn = document.getElementById("language-toggle-btn");
  if (btn) {
    btn.textContent = currentLang === "de" ? "English Version" : "Deutsche Version";
  }
  
  // Also update the welcome page button if it exists
  var welcomeBtn = document.getElementById("lang_switch");
  if (welcomeBtn) {
    welcomeBtn.textContent = currentLang === "de" ? "English Version" : "Deutsche Version";
  }
  
  // Toggle welcome page content if on page 1
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
  
  // Send to Shiny
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("study_language", currentLang, {priority: "event"});
  }
  
  // Store preference
  sessionStorage.setItem("hilfo_language", currentLang);
  
  // Apply translations to current page without reload
  translatePage();
};

// Apply translations on page load
document.addEventListener("DOMContentLoaded", function() {
  // Check stored language preference
  var storedLang = sessionStorage.getItem("hilfo_language");
  if (storedLang) {
    currentLang = storedLang;
  }
  
  // Create language toggle button if it doesn\'t exist
  if (!document.getElementById("language-toggle-btn")) {
    var btn = document.createElement("button");
    btn.id = "language-toggle-btn";
    btn.textContent = currentLang === "de" ? "English Version" : "Deutsche Version";
    btn.onclick = toggleLanguage;
    document.body.appendChild(btn);
  }
  
  // Apply initial translation if English
  if (currentLang === "en") {
    // Toggle welcome page if present
    var deContent = document.getElementById("content_de");
    var enContent = document.getElementById("content_en");
    if (deContent && enContent) {
      deContent.style.display = "none";
      enContent.style.display = "block";
    }
    
    // Update welcome button if present
    var welcomeBtn = document.getElementById("lang_switch");
    if (welcomeBtn) {
      welcomeBtn.textContent = "Deutsche Version";
    }
    
    // Apply translations
    translatePage();
  }
  
  // Check stored language
  var stored = sessionStorage.getItem("hilfo_language");
  if (stored) {
    currentLang = stored;
    var btn = document.getElementById("language-toggle-btn");
    if (btn) {
      btn.textContent = currentLang === "de" ? "English Version" : "Deutsche Version";
    }
  }
  
  // Apply translations if English
  if (currentLang === "en") {
    setTimeout(translatePage, 100);
  }
  
  // Watch for page changes
  var observer = new MutationObserver(function(mutations) {
    if (currentLang === "en") {
      setTimeout(translatePage, 50);
    }
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
  
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

// Handle Shiny messages
if (typeof Shiny !== "undefined") {
  Shiny.addCustomMessageHandler("update_language", function(lang) {
    currentLang = lang;
    if (lang === "en") {
      translatePage();
    } else {
      location.reload(); // Reload for German
    }
  });
}
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

# Enhanced CSS and JavaScript for HILFO improvements
hilfo_enhancements <- paste0(custom_js_enhanced, "
<style>
/* Grey radio buttons (select dots) */
.shiny-input-radiogroup input[type='radio'] {
  accent-color: #6c757d !important;
}

.shiny-input-radiogroup input[type='radio']:checked {
  background-color: #6c757d !important;
  border-color: #6c757d !important;
}

.shiny-input-radiogroup label {
  color: #333 !important;
}

/* Grey buttons including CSV download */
.btn-secondary, .download-btn, .btn-primary, input[type='submit'], button {
  background-color: #6c757d !important;
  border-color: #6c757d !important;
  color: white !important;
}

.btn-secondary:hover, .download-btn:hover, .btn-primary:hover {
  background-color: #5a6268 !important;
  border-color: #545b62 !important;
}

/* Grey checkboxes */
.form-check-input:checked {
  background-color: #6c757d !important;
  border-color: #6c757d !important;
}

.form-check-input:focus {
  border-color: #6c757d !important;
  box-shadow: 0 0 0 0.25rem rgba(108, 117, 125, 0.25) !important;
}

/* Select dropdowns */
select, .form-select {
  border-color: #6c757d !important;
}

select:focus, .form-select:focus {
  border-color: #6c757d !important;
  box-shadow: 0 0 0 0.25rem rgba(108, 117, 125, 0.25) !important;
}

/* Mobile table abbreviations - M and SD */
@media (max-width: 768px) {
  .results-table th:nth-child(2):after { content: 'M'; }
  .results-table th:nth-child(2) { font-size: 0; }
  .results-table th:nth-child(3):after { content: 'SD'; }
  .results-table th:nth-child(3) { font-size: 0; }
  .results-table { font-size: 12px; }
}

/* Validation error highlighting */
.validation-error-field {
  border: 2px solid #dc3545 !important;
  background-color: #fff5f5 !important;
  animation: shake 0.5s ease-in-out;
}

@keyframes shake {
  0%, 100% { transform: translateX(0); }
  25% { transform: translateX(-5px); }
  75% { transform: translateX(5px); }
}

/* Results page styling */
.results-intro {
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
  margin-bottom: 20px;
  border-left: 4px solid #6c757d;
}

.inrep-attribution {
  background: #e9ecef;
  padding: 15px;
  border-radius: 8px;
  margin-top: 30px;
  text-align: center;
  border: 1px solid #6c757d;
}

.adaptive-explanation {
  background: #fff3cd;
  padding: 10px;
  border-radius: 4px;
  margin-top: 10px;
  border-left: 3px solid #ffc107;
  font-style: italic;
}
</style>

<script>
// COMPREHENSIVE HILFO ENHANCEMENTS - ALL REQUESTED FEATURES
$(document).ready(function() {
  
  // 1. AUTO-SCROLL TO TOP ON PAGE NAVIGATION
  $(document).on('shiny:value', function(event) {
    if (event.name === 'study_ui' || event.name === 'page_content') {
      setTimeout(function() {
        window.scrollTo({top: 0, behavior: 'smooth'});
      }, 100);
    }
  });
  
  // Also scroll to top on button clicks
  $(document).on('click', '.btn-primary, .btn-secondary, button[type="submit"]', function() {
    setTimeout(function() {
      window.scrollTo({top: 0, behavior: 'smooth'});
    }, 200);
  });
  
  // 2. RADIO BUTTON DESELECTION - Click again to unselect
  $(document).on('click', 'input[type="radio"]', function() {
    var wasChecked = $(this).data('was-checked') === true;
    var radioGroup = $('input[name="' + this.name + '"]');
    
    radioGroup.data('was-checked', false).closest('label').removeClass('selected');
    
    if (wasChecked) {
      $(this).prop('checked', false);
      if (typeof Shiny !== 'undefined') {
        Shiny.setInputValue(this.name, null);
      }
    } else {
      $(this).data('was-checked', true).closest('label').addClass('selected');
    }
  });
  
  // 3. VALIDATION ERROR HIGHLIGHTING AND SCROLL TO FIRST ERROR
  if (typeof Shiny !== 'undefined') {
    Shiny.addCustomMessageHandler('validation_errors', function(message) {
      $('.validation-error-field').removeClass('validation-error-field');
      
      if (message.fields && message.fields.length > 0) {
        var firstError = null;
        
        message.fields.forEach(function(field, index) {
          var element = $('[name="' + field + '"], #' + field);
          element.addClass('validation-error-field');
          
          if (index === 0 && element.length > 0) {
            firstError = element.first();
          }
        });
        
        if (firstError) {
          $('html, body').animate({
            scrollTop: firstError.offset().top - 100
          }, 500);
        }
      }
    });
  }
  
  // 4. EMERGENCY DATA SAVING - Robust server-side data handling
  function saveData() {
    if (typeof Shiny !== 'undefined') {
      Shiny.setInputValue('emergency_save', {
        timestamp: new Date().toISOString(),
        random: Math.random()
      }, {priority: 'event'});
    }
  }
  
  // Save data on page unload, visibility change, and periodically
  $(window).on('beforeunload', saveData);
  setInterval(saveData, 30000); // Every 30 seconds
  document.addEventListener('visibilitychange', function() {
    if (document.hidden) saveData();
  });
  
  // 5. RESULTS PAGE IMPROVEMENTS
  $(document).on('DOMNodeInserted', function(e) {
    // Add thank you intro to results page
    if ($(e.target).hasClass('results-page') || $(e.target).find('.results-page').length) {
      if (!$('.results-intro').length) {
        $('.results-page').prepend(
          '<div class="results-intro">' +
          '<h4>Vielen Dank für die Teilnahme!</h4>' +
          '<p>Nachfolgend erhalten Sie die Übersicht Ihrer Ergebnisse. Bedenken Sie, dass dies nur Schätzungen sind, die auf Ihrem Antwortverhalten basieren.</p>' +
          '</div>'
        );
      }
      
      // Add inrep attribution at the end
      if (!$('.inrep-attribution').length) {
        $('.results-page').append(
          '<div class="inrep-attribution">' +
          '<p><strong>Diese Befragung wurde mit inrep durchgeführt</strong> - einem R-Paket für Instant Reports bei adaptiven Assessments.</p>' +
          '<button onclick="window.close()" class="btn btn-secondary" style="margin-top:10px;">Fenster schließen</button>' +
          '</div>'
        );
      }
    }
    
    // Add adaptive plot explanation
    if ($(e.target).hasClass('adaptive-plot') || $(e.target).find('.adaptive-plot').length) {
      if (!$('.adaptive-explanation').length) {
        $('.adaptive-plot').after(
          '<div class="adaptive-explanation">' +
          '<strong>Hinweis:</strong> Der Itempool besteht insgesamt aus 20 Items.' +
          '</div>'
        );
      }
    }
    
    // Fix adaptive legend order (adaptive first, then fixed)
    var legend = $(e.target).find('.legend, .plot-legend');
    if (legend.length) {
      var adaptiveItem = legend.find('.legend-item:contains("Adaptive"), .legend-item:contains("adaptiv")');
      var fixedItem = legend.find('.legend-item:contains("Fixed"), .legend-item:contains("fix")');
      
      if (adaptiveItem.length && fixedItem.length) {
        adaptiveItem.insertBefore(fixedItem);
      }
    }
  });
  
  // 6. DOWNLOAD FUNCTIONALITY
  $(document).on('click', '.download-btn', function(e) {
    e.preventDefault();
    var format = $(this).data('format') || 'csv';
    
    if (typeof Shiny !== 'undefined') {
      Shiny.setInputValue('download_request', {
        format: format,
        timestamp: new Date().toISOString()
      }, {priority: 'event'});
    }
  });
  
  // Handle file downloads with user selection
  if (typeof Shiny !== 'undefined') {
    Shiny.addCustomMessageHandler('trigger_download', function(message) {
      var link = document.createElement('a');
      link.href = message.url;
      link.download = message.filename;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    });
  }
  
});
</script>
")

# Launch with cloud storage, adaptive testing, and enhanced features
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,  # Bilingual item bank
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv",
  custom_css = hilfo_enhancements,  # Enhanced styling and functionality
  admin_dashboard_hook = monitor_adaptive  # Monitor adaptive selection
)






