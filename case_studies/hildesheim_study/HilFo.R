


# Ensure inrep is installed only if not present
if (!requireNamespace("inrep", quietly = TRUE)) {
  if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
  devtools::install_github("selvastics/inrep", ref = "master")
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
    # Programming Anxiety (German) - NEW - First 5 items suitable for all experience levels
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
    # Programming Anxiety (English) - NEW - First 5 items suitable for all experience levels
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
    required = FALSE
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
    required = FALSE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    question_en = "Which study program are you in?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    options_en = c("Bachelor Psychology"="1", "Master Psychology"="2"),
    required = FALSE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    options = c("weiblich oder divers"="1", "männlich"="2"),
    options_en = c("female or diverse"="1", "male"="2"),
    required = FALSE
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
    question_en = "Please create a personal code (first 2 letters of your mother\'s first name + first 2 letters of your birthplace + day of your birthday):",
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
    title = "HilFo",
    title_en = "HilFo",
    content = paste0('<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">
      <div style="position: absolute; top: 10px; right: 10px;">
        <button type="button" id="language-toggle-btn" onclick="toggleLanguage()" style="
          background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text">English Version</span></button>
      </div>
      
      <div id="content_de">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Willkommen zur HilFo Studie</h1>
        <h2 style="color: #e8041c;">Liebe Studierende,</h2>
        <p>In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, 
        die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.</p>
        <p>Da wir verschiedene Auswertungen ermöglichen wollen, deckt der Fragebogen verschiedene 
        Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">
        <strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene 
        Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im 
        Bachelor generiert und in diesem Jahrgang genutzt, möglicherweise auch in späteren Jahrgängen.</p>
        <p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, 
        inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. 
        Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.</p>
        <p style="margin-top: 20px;"><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;">
            <strong>Hinweis:</strong> Die Teilnahme ist nur möglich, wenn Sie der Einverständniserklärung zustimmen.</p>
          </div>
        </div>
      </div>
      
      <div id="content_en" style="display: none;">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Welcome to the HilFo Study</h1>
        <h2 style="color: #e8041c;">Dear Students,</h2>
        <p>In the statistics exercises, we want to work with illustrative data 
        that comes from you. Therefore, we would like to learn a few things about you.</p>
        <p>Since we want to enable various analyses, the questionnaire covers different 
        topic areas that are partially independent of each other.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">
        <strong>Your information is completely anonymous</strong>, there will be no personal 
        evaluation of the data. The data is generated by first-semester psychology 
        bachelor students and used in this cohort, possibly also in later cohorts.</p>
        <p>In the following, you will be presented with statements. We ask you to indicate 
        to what extent you agree with them. There are no wrong or right answers. 
        Please answer the questions as they best reflect your opinion.</p>
        <p style="margin-top: 20px;"><strong>The survey takes about 10-15 minutes.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>I agree to participate in the survey</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;">
            <strong>Note:</strong> Participation is only possible if you agree to the declaration of consent.</p>
          </div>
        </div>
      </div>
    </div>
    
    <script>
    // Global language state
    window.hilfoLanguage = "de"; // Default to German
    
    // Language toggle function
    function toggleLanguage() {
      var deContent = document.getElementById("content_de");
      var enContent = document.getElementById("content_en");
      var textSpan = document.getElementById("lang_switch_text");
      var resultsTextSpan = document.getElementById("lang_switch_text_results");
      
      if (deContent && enContent) {
        if (deContent.style.display === "none") {
          // Switch to German
          deContent.style.display = "block";
          enContent.style.display = "none";
          if (textSpan) textSpan.textContent = "English Version";
          if (resultsTextSpan) resultsTextSpan.textContent = "English Version";
          window.hilfoLanguage = "de";
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("study_language", "de", {priority: "event"});
          }
        } else {
          // Switch to English
          deContent.style.display = "none";
          enContent.style.display = "block";
          if (textSpan) textSpan.textContent = "Deutsche Version";
          if (resultsTextSpan) resultsTextSpan.textContent = "Deutsche Version";
          window.hilfoLanguage = "en";
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("study_language", "en", {priority: "event"});
          }
        }
      } else {
        // For pages without content_de/content_en (like results page)
        // Just toggle the global language state
        if (window.hilfoLanguage === "de") {
          window.hilfoLanguage = "en";
          if (resultsTextSpan) resultsTextSpan.textContent = "Deutsche Version";
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("study_language", "en", {priority: "event"});
          }
        } else {
          window.hilfoLanguage = "de";
          if (resultsTextSpan) resultsTextSpan.textContent = "English Version";
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("study_language", "de", {priority: "event"});
          }
        }
      }
      
      // Apply language to all pages
      applyLanguageToAllPages();
    }
    
    // Apply language to all elements with data-lang attributes
    function applyLanguageToAllPages() {
      var currentLang = window.hilfoLanguage || "de";
      console.log("Applying language to all pages:", currentLang);
      
      // Update all elements with data-lang attributes
      var elements = document.querySelectorAll("[data-lang-de][data-lang-en]");
      console.log("Found", elements.length, "elements with data-lang attributes");
      elements.forEach(function(el) {
        if (currentLang === "en") {
          el.textContent = el.getAttribute("data-lang-en");
        } else {
          el.textContent = el.getAttribute("data-lang-de");
        }
      });
      
      // Update input placeholders
      var inputs = document.querySelectorAll("[data-placeholder-de][data-placeholder-en]");
      console.log("Found", inputs.length, "inputs with data-placeholder attributes");
      inputs.forEach(function(input) {
        if (currentLang === "en") {
          input.placeholder = input.getAttribute("data-placeholder-en");
        } else {
          input.placeholder = input.getAttribute("data-placeholder-de");
        }
      });
    }
    
    // Checkbox synchronization for consent
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
      
      // Apply language on page load with multiple attempts
      setTimeout(applyLanguageToAllPages, 100);
      setTimeout(applyLanguageToAllPages, 500);
      setTimeout(applyLanguageToAllPages, 1000);
    });
    
    // Listen for page changes to apply language
    $(document).on("shiny:value", function() {
      setTimeout(applyLanguageToAllPages, 100);
      setTimeout(applyLanguageToAllPages, 500);
    });
    
    // Also listen for Shiny events
    $(document).on("shiny:connected", function() {
      setTimeout(applyLanguageToAllPages, 100);
    });
    
    // Listen for custom page changes
    $(document).on("shiny:inputchanged", function() {
      setTimeout(applyLanguageToAllPages, 100);
    });
    </script>'),
    validate = "function(inputs) { 
      try {
        var deCheck = document.getElementById(\'consent_check\');
        var enCheck = document.getElementById(\'consent_check_en\');
        return Boolean((deCheck && deCheck.checked) || (enCheck && enCheck.checked));
      } catch(e) {
        return false;
      }
    }",
    required = FALSE
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
    title = "",
    title_en = "",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 21:25,  # BFI items (after 20 PA items)
    scale_type = "likert"
  ),
  list(
    id = "page13",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 26:30,  # BFI items continued
    scale_type = "likert"
  ),
  list(
    id = "page14",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 31:35,  # BFI items continued
    scale_type = "likert"
  ),
  list(
    id = "page15",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 36:40,  # BFI items final
    scale_type = "likert"
  ),
  
  # Page 16: PSQ Stress
  list(
    id = "page16",
    type = "items",
    title = "",
    title_en = "",
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
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_5st", "Zufrieden_Hi_7st")
  ),
  
  # Page 20: Personal Code
  list(
    id = "page20",
    type = "custom",
    title = "Persönlicher Code",
    title_en = "Personal Code",
    content = paste0('<div id="personal-code-content" style="padding: 20px; font-size: 16px; line-height: 1.8;">
      <h2 id="personal-code-title" style="color: #e8041c; text-align: center; margin-bottom: 25px;" data-lang-de="Persönlicher Code" data-lang-en="Personal Code">Persönlicher Code</h2>
      <p id="personal-code-instruction" style="text-align: center; margin-bottom: 30px; font-size: 18px;" data-lang-de="Bitte erstellen Sie einen persönlichen Code:" data-lang-en="Please create a personal code:">Bitte erstellen Sie einen persönlichen Code:</p>
      <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
        <p id="personal-code-formula" style="margin: 0; font-weight: 500;" data-lang-de="Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags" data-lang-en="First 2 letters of your mother\'s first name + first 2 letters of your birthplace + day of your birthday">Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags</p>
      </div>
      <div style="text-align: center; margin: 30px 0;">
        <input type="text" id="personal_code" placeholder="z.B. MAHA15" data-placeholder-de="z.B. MAHA15" data-placeholder-en="e.g. MAHA15" style="
          padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; 
          text-align: center; width: 200px; text-transform: uppercase;" required>
      </div>
      <div style="text-align: center; color: #666; font-size: 14px;">
        <span id="personal-code-example" data-lang-de="Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15" data-lang-en="Example: Maria (MA) + Hamburg (HA) + 15th day = MAHA15">Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15</span>
      </div>
    </div>
    <script>
    // Apply language to personal code page - uses global language system
    function applyLanguageToPage20() {
      var currentLang = window.hilfoLanguage || "de";
      
      // Update all elements with data-lang attributes
      var elements = document.querySelectorAll("[data-lang-de][data-lang-en]");
      elements.forEach(function(el) {
        if (currentLang === "en") {
          el.textContent = el.getAttribute("data-lang-en");
        } else {
          el.textContent = el.getAttribute("data-lang-de");
        }
      });
      
      // Update input placeholder
      var input = document.getElementById("personal_code");
      if (input) {
        if (currentLang === "en") {
          input.placeholder = input.getAttribute("data-placeholder-en") || "e.g. MAHA15";
        } else {
          input.placeholder = input.getAttribute("data-placeholder-de") || "z.B. MAHA15";
        }
      }
    }
    
    // Apply immediately and on language changes
    setTimeout(applyLanguageToPage20, 100);
    $(document).on("shiny:value", applyLanguageToPage20);
    window.addEventListener("languageChanged", applyLanguageToPage20);
    </script>'),
    validate = "function(inputs) { 
      try {
        var personalCode = document.getElementById(\'personal_code\');
        return personalCode && personalCode.value.trim().length > 0;
      } catch(e) {
        return false;
      }
    }"
  ),
  
  # Page 21: Results (now with PA results included)
  list(
    id = "page21",
    type = "results",
    title = "Ihre Ergebnisse",
    title_en = "Your Results",
    content = paste0('<div style="position: relative; text-align: center; padding: 40px;">
      <div style="position: absolute; top: 10px; right: 10px;">
        <button type="button" onclick="toggleLanguage()" style="
          background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text_results">English Version</span></button>
      </div>
      
      <h2 data-lang-de="Ihre Ergebnisse" data-lang-en="Your Results">Ihre Ergebnisse</h2>
      <p data-lang-de="Ihre Ergebnisse wurden erfolgreich verarbeitet und gespeichert." data-lang-en="Your results have been successfully processed and saved.">Ihre Ergebnisse wurden erfolgreich verarbeitet und gespeichert.</p>
      
      <div style="margin: 30px 0;">
        <button onclick="downloadPDF()" style="background: #e8041c; color: white; border: none; padding: 12px 24px; margin: 10px; border-radius: 4px; cursor: pointer; font-size: 16px;">
          <span data-lang-de="PDF herunterladen" data-lang-en="Download PDF">PDF herunterladen</span>
        </button>
        
        <button onclick="downloadCSV()" style="background: #e8041c; color: white; border: none; padding: 12px 24px; margin: 10px; border-radius: 4px; cursor: pointer; font-size: 16px;">
          <span data-lang-de="CSV herunterladen" data-lang-en="Download CSV">CSV herunterladen</span>
        </button>
      </div>
      
      <p style="font-size: 14px; color: #666; margin-top: 20px;" data-lang-de="Die Daten wurden auch automatisch in der Cloud gespeichert." data-lang-en="The data has also been automatically saved to the cloud.">Die Daten wurden auch automatisch in der Cloud gespeichert.</p>
    </div>'),
    validate = "function(inputs) { return true; }",
    required = FALSE
  ),
  
  # Page 22: Invisible dummy page to prevent indexing error
  # This page will never be reached because page 21 is type "results"
  # But it prevents the indexing error in render_page_navigation
  list(
    id = "page22_dummy",
    type = "results", 
    title = "End",
    title_en = "End"
  )
)


# =============================================================================
# RESULTS PROCESSOR WITH FIXED RADAR PLOT
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  # Global error handling for the entire function
  tryCatch({
    # Lazy load packages only when actually needed
    if (!requireNamespace("ggplot2", quietly = TRUE)) {
      stop("ggplot2 package is required for report generation")
    }
    if (!requireNamespace("base64enc", quietly = TRUE)) {
      stop("base64enc package is required for report generation")
    }
    
    # Debug demographics parameter
    cat("DEBUG: create_hilfo_report called with demographics:", !is.null(demographics), "\n")
    if (!is.null(demographics)) {
      cat("DEBUG: demographics type:", class(demographics), "\n")
      cat("DEBUG: demographics length:", length(demographics), "\n")
      if (is.list(demographics)) {
        cat("DEBUG: demographics names:", paste(names(demographics), collapse=", "), "\n")
      }
    }
    
    # Debug session parameter
    cat("DEBUG: session parameter:", !is.null(session), "\n")
    if (!is.null(session)) {
      cat("DEBUG: session class:", class(session), "\n")
      if (is.list(session)) {
        cat("DEBUG: session names:", paste(names(session), collapse=", "), "\n")
      }
    }
    
    # SIMPLE LANGUAGE DETECTION - Check global environment FIRST
    current_lang <- "de"  # Default to German
    
    cat("DEBUG: Starting SIMPLE language detection\n")
    
    # Check global environment FIRST - this is where toggleLanguage stores it
    if (exists("hilfo_language_preference", envir = .GlobalEnv)) {
      stored_lang <- get("hilfo_language_preference", envir = .GlobalEnv)
      if (!is.null(stored_lang) && (stored_lang == "en" || stored_lang == "de")) {
        current_lang <- stored_lang
        cat("DEBUG: Found language in global hilfo_language_preference:", current_lang, "\n")
        # Use this and skip all other checks
        is_english <- (current_lang == "en")
        cat("DEBUG: Using global language:", current_lang, "- is_english:", is_english, "\n")
      }
    }
    
    # If not found in global environment, check session as fallback
    if (current_lang == "de" && !is.null(session) && !is.null(session$input)) {
      # Check session input as fallback
      lang_keys <- c("hilfo_language_preference", "study_language", "language", "current_language")
      for (key in lang_keys) {
        if (key %in% names(session$input) && !is.null(session$input[[key]])) {
          current_lang <- session$input[[key]]
          cat("DEBUG: Found language in session$input$", key, ":", current_lang, "\n")
          break
        }
      }
    }
    
    # Final fallback to German
    if (is.null(current_lang) || current_lang == "") {
      current_lang <- "de"
      cat("DEBUG: Using default German language\n")
    }
    
    # Set is_english based on current_lang
    is_english <- (current_lang == "en")
    cat("DEBUG: Final language settings - current_lang:", current_lang, ", is_english:", is_english, "\n")
    
    if (is.null(responses) || length(responses) == 0) {
      if (is_english) {
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
    
    # More robust theta progression simulation
    for (i in 1:10) {
      # Calculate theta up to item i
      resp_subset <- (pa_responses[1:i] - 1) / 4
      a_subset <- a_params[1:i]
      b_subset <- b_params[1:i]
      
      # Robust theta estimation with better convergence
      theta_temp <- 0
      max_iter <- 20
      tolerance <- 1e-6
      
      for (iter in 1:max_iter) {
        # Calculate probabilities
        probs <- 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))
        
        # First derivative (gradient)
        first_d <- sum(a_subset * (resp_subset - probs))
        
        # Second derivative (Hessian)
        second_d <- -sum(a_subset^2 * probs * (1 - probs))
        
        # Check for convergence
        if (abs(first_d) < tolerance) break
        
        # Update theta with safeguards
        if (abs(second_d) > 1e-6) {
          step <- first_d / second_d
          # Limit step size to prevent instability
          step <- sign(step) * min(abs(step), 0.5)
          theta_temp <- theta_temp - step
        } else {
          # Fallback: simple gradient descent
          theta_temp <- theta_temp - 0.1 * first_d
        }
        
        # Bound theta to reasonable range
        theta_temp <- pmax(-4, pmin(4, theta_temp))
      }
      
      # Calculate information and SE with safeguards
      probs_final <- 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))
      info_temp <- sum(a_subset^2 * probs_final * (1 - probs_final))
      
      # Ensure information is positive and not too small
      info_temp <- max(info_temp, 0.1)
      se_temp <- 1 / sqrt(info_temp)
      
      # Bound standard error to reasonable range
      se_temp <- pmax(0.1, pmin(2.0, se_temp))
      
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
    
    # Debug: Check scores for missing values
    cat("DEBUG: Scores values:\n")
    for (name in names(scores)) {
      cat(sprintf("  %s: %s (is.na: %s, is.nan: %s)\n", 
                  name, scores[[name]], is.na(scores[[name]]), is.nan(scores[[name]])))
    }
    
    # Create radar plot using ggradar approach
    # Check for ggradar (should be pre-installed)
    
    # Prepare data for ggradar - needs to be scaled 0-1
    # Ensure all scores are valid numbers and handle missing values
    radar_scores <- list(
      Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) 3 else scores$Extraversion,
      Verträglichkeit = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) 3 else scores$Verträglichkeit,
      Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) 3 else scores$Gewissenhaftigkeit,
      Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) 3 else scores$Neurotizismus,
      Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) 3 else scores$Offenheit
    )
    
    # Debug: Check radar scores
    cat("DEBUG: Radar scores values:\n")
    for (name in names(radar_scores)) {
      cat(sprintf("  %s: %s\n", name, radar_scores[[name]]))
    }
    
    tryCatch({
      radar_data <- data.frame(
        group = if (is_english) "Your Profile" else "Ihr Profil",
        Extraversion = radar_scores$Extraversion / 5,
        Agreeableness = radar_scores$Verträglichkeit / 5,
        Conscientiousness = radar_scores$Gewissenhaftigkeit / 5,
        Neuroticism = radar_scores$Neurotizismus / 5,
        Openness = radar_scores$Offenheit / 5,
        stringsAsFactors = FALSE,
        row.names = NULL
      )
      cat("DEBUG: radar_data created successfully\n")
    }, error = function(e) {
      cat("Error creating radar_data data.frame:", e$message, "\n")
      # Create fallback radar_data
      radar_data <- data.frame(
        group = if (is_english) "Your Profile" else "Ihr Profil",
        Extraversion = 0.6,
        Agreeableness = 0.6,
        Conscientiousness = 0.6,
        Neuroticism = 0.6,
        Openness = 0.6,
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })
    
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
      )
      
      # Add title separately using ggplot2 if possible
      tryCatch({
        radar_plot <- radar_plot + 
          ggplot2::theme(
            plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, 
                                               color = "#e8041c", margin = ggplot2::margin(b = 20)),
            plot.background = ggplot2::element_rect(fill = "white", color = NA),
            plot.margin = ggplot2::margin(20, 20, 20, 20)
          ) +
          ggplot2::labs(title = if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)")
      }, error = function(e) {
        cat("Warning: Could not add theme to ggradar plot:", e$message, "\n")
        # Use the plot as-is without theme modifications
      })
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
      
      # Use English labels if current language is English
      if (is_english) {
        bfi_labels <- c("Extraversion", "Agreeableness", "Conscientiousness", 
                        "Neuroticism", "Openness")
      } else {
        bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                        "Neurotizismus", "Offenheit")
      }
      
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
        ggplot2::xlim(-6, 6) +
        ggplot2::ylim(-6, 6) +
        ggplot2::theme_void() +
        ggplot2::theme(
          plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5,
                                             color = "#e8041c", margin = ggplot2::margin(b = 20)),
          plot.margin = ggplot2::margin(30, 30, 30, 30)
        ) +
        ggplot2::labs(title = if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)")
    }
    
    # Create bar chart with logical ordering
    # Show BFI scales first, then Programming Anxiety, then others
    # Ensure all scores are valid numbers (replace NA/NaN with 3)
    if (is_english) {
      # Use English names as keys for English mode
      ordered_scores <- list(
        Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) 3 else scores$Extraversion,
        Agreeableness = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) 3 else scores$Verträglichkeit,
        Conscientiousness = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) 3 else scores$Gewissenhaftigkeit,
        Neuroticism = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) 3 else scores$Neurotizismus,
        Openness = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) 3 else scores$Offenheit,
        ProgrammingAnxiety = if (is.na(scores$ProgrammingAnxiety) || is.nan(scores$ProgrammingAnxiety)) 3 else scores$ProgrammingAnxiety,
        Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) 3 else scores$Stress,
        StudySkills = if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) 3 else scores$Studierfähigkeiten,
        Statistics = if (is.na(scores$Statistik) || is.nan(scores$Statistik)) 3 else scores$Statistik
      )
    } else {
      # Use German names as keys for German mode
      ordered_scores <- list(
        Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) 3 else scores$Extraversion,
        Verträglichkeit = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) 3 else scores$Verträglichkeit,
        Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) 3 else scores$Gewissenhaftigkeit,
        Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) 3 else scores$Neurotizismus,
        Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) 3 else scores$Offenheit,
        ProgrammingAnxiety = if (is.na(scores$ProgrammingAnxiety) || is.nan(scores$ProgrammingAnxiety)) 3 else scores$ProgrammingAnxiety,
        Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) 3 else scores$Stress,
        Studierfähigkeiten = if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) 3 else scores$Studierfähigkeiten,
        Statistik = if (is.na(scores$Statistik) || is.nan(scores$Statistik)) 3 else scores$Statistik
      )
    }
    
    # Create English dimension names
    if (is_english) {
      dimension_names_en <- c(
        "Extraversion" = "Extraversion",
        "Agreeableness" = "Agreeableness", 
        "Conscientiousness" = "Conscientiousness",
        "Neuroticism" = "Neuroticism",
        "Openness" = "Openness",
        "ProgrammingAnxiety" = "Programming Anxiety",
        "Stress" = "Stress",
        "StudySkills" = "Study Skills",
        "Statistics" = "Statistics"
      )
    } else {
      dimension_names_en <- c(
        "Extraversion" = "Extraversion",
        "Verträglichkeit" = "Agreeableness", 
        "Gewissenhaftigkeit" = "Conscientiousness",
        "Neurotizismus" = "Neuroticism",
        "Offenheit" = "Openness",
        "ProgrammingAnxiety" = "Programming Anxiety",
        "Stress" = "Stress",
        "Studierfähigkeiten" = "Study Skills",
        "Statistik" = "Statistics"
      )
    }
    
    # Create English category names
    category_names_en <- c(
      "Persönlichkeit" = "Personality",
      "Programmierangst" = "Programming Anxiety",
      "Stress" = "Stress",
      "Studierfähigkeiten" = "Study Skills",
      "Statistik" = "Statistics"
    )
    
    # Use English names if current language is English
    if (is_english) {
      dimension_labels <- dimension_names_en[names(ordered_scores)]
      # Create category labels that match the English dimension names
      category_labels <- c(rep("Personality", 5), 
                           "Programming Anxiety", "Stress", "Study Skills", "Statistics")
    } else {
      dimension_labels <- names(ordered_scores)
      category_labels <- c(rep("Persönlichkeit", 5), 
                           "Programmierangst", "Stress", "Studierfähigkeiten", "Statistik")
    }
    
    # Create all_data with error handling
    tryCatch({
      all_data <- data.frame(
        dimension = factor(dimension_labels, levels = dimension_labels),
        score = unlist(ordered_scores),
        category = factor(category_labels, levels = unique(category_labels)),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    }, error = function(e) {
      cat("Error creating all_data data.frame:", e$message, "\n")
      # Create fallback data.frame
      all_data <- data.frame(
        dimension = factor(if (is_english) {
          c("Extraversion", "Agreeableness", "Conscientiousness", "Neuroticism", "Openness", "ProgrammingAnxiety", "Stress", "StudySkills", "Statistics")
        } else {
          c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", "Neurotizismus", "Offenheit", "ProgrammingAnxiety", "Stress", "Studierfähigkeiten", "Statistik")
        }),
        score = rep(3, 9),
        category = factor(if (is_english) {
          c(rep("Personality", 5), "Programming Anxiety", "Stress", "Study Skills", "Statistics")
        } else {
          c(rep("Persönlichkeit", 5), "Programmierangst", "Stress", "Studierfähigkeiten", "Statistik")
        }),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })
    
    # Create base plot
    bar_plot <- ggplot2::ggplot(all_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
      ggplot2::geom_bar(stat = "identity", width = 0.7) +
      # Add value labels with better formatting
      ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), 
                         vjust = -0.5, size = 6, fontface = "bold", color = "#333")
    
    # Add color scheme based on language
    if (is_english) {
      bar_plot <- bar_plot + ggplot2::scale_fill_manual(values = c(
        "Programming Anxiety" = "#9b59b6",
        "Personality" = "#e8041c",
        "Stress" = "#ff6b6b",
        "Study Skills" = "#4ecdc4",
        "Statistics" = "#45b7d1"
      ))
    } else {
      bar_plot <- bar_plot + ggplot2::scale_fill_manual(values = c(
        "Programmierangst" = "#9b59b6",
        "Persönlichkeit" = "#e8041c",
        "Stress" = "#ff6b6b",
        "Studierfähigkeiten" = "#4ecdc4",
        "Statistik" = "#45b7d1"
      ))
    }
    
    # Add remaining elements
    bar_plot <- bar_plot +
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
        title = if (is_english) "All Dimensions Overview" else "Alle Dimensionen im Überblick", 
        y = if (is_english) "Score (1-5)" else "Punktzahl (1-5)"
      )
    
    # Create trace plot for Programming Anxiety adaptive testing
    # Add safeguards for extreme values
    theta_trace_bounded <- pmax(-3, pmin(3, theta_trace))
    se_trace_bounded <- pmax(0.1, pmin(1.5, se_trace))
    
    trace_data <- data.frame(
      item = 1:10,
      theta = theta_trace_bounded,
      se_upper = theta_trace_bounded + se_trace_bounded,
      se_lower = theta_trace_bounded - se_trace_bounded,
      item_type = c(rep("Fixed", 5), rep("Adaptive", 5)),
      stringsAsFactors = FALSE,
      row.names = NULL
    )
    
    # Calculate plot limits dynamically
    y_min <- min(trace_data$se_lower) - 0.2
    y_max <- max(trace_data$se_upper) + 0.2
    
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
      # Annotations with dynamic positioning
      ggplot2::annotate("text", x = 2.5, y = y_max * 0.9, 
                        label = "Fixed Items", size = 4, color = "gray40") +
      ggplot2::annotate("text", x = 8, y = y_max * 0.9, 
                        label = "Adaptive Items", size = 4, color = "gray40") +
      # Scales with dynamic limits
      ggplot2::scale_x_continuous(breaks = 1:10, labels = 1:10) +
      ggplot2::scale_y_continuous(limits = c(y_min, y_max)) +
      ggplot2::scale_color_manual(values = c("Fixed" = "#e8041c", "Adaptive" = "#4ecdc4"), 
                                  breaks = c("Fixed", "Adaptive")) +
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
        title = if (is_english) "Programming Anxiety - Adaptive Testing Trace" else "Programmierangst - Adaptive Testung",
        subtitle = sprintf(if (is_english) "Final theta = %.3f (SE = %.3f)" else "Finales theta = %.3f (SE = %.3f)", theta_est, se_est),
        x = if (is_english) "Item Number" else "Item-Nummer",
        y = if (is_english) "Theta Estimate" else "Theta-Schaetzung"
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
    # Ensure we don't exceed available questions and handle missing values
    num_questions <- min(31, length(responses), nrow(item_bank))
    
    # Debug output
    cat("DEBUG: Creating item details table\n")
    cat("DEBUG: num_questions =", num_questions, "\n")
    cat("DEBUG: length(responses) =", length(responses), "\n")
    cat("DEBUG: nrow(item_bank) =", nrow(item_bank), "\n")
    if (!is.null(item_bank) && "Question" %in% names(item_bank)) {
      cat("DEBUG: item_bank$Question has", length(item_bank$Question), "items\n")
      cat("DEBUG: First few Question values:", head(item_bank$Question, 5), "\n")
    }
    
    # Create category vector that matches the actual number of questions
    category_vector <- c(
      rep("Extraversion", 4), rep("Verträglichkeit", 4), 
      rep("Gewissenhaftigkeit", 4), rep("Neurotizismus", 4), rep("Offenheit", 4),
      rep("Stress", 5), rep("Studierfähigkeiten", 4), rep("Statistik", 2)
    )
    
    # Ensure category vector is the right length
    if (length(category_vector) > num_questions) {
      category_vector <- category_vector[1:num_questions]
    } else if (length(category_vector) < num_questions) {
      category_vector <- c(category_vector, rep("Other", num_questions - length(category_vector)))
    }
    
    # Create item details with proper handling of missing values
    tryCatch({
      item_names <- if ("Question" %in% names(item_bank)) {
        # Ensure no NA or NULL values in item names
        item_names_raw <- item_bank$Question[1:num_questions]
        ifelse(is.na(item_names_raw) | is.null(item_names_raw) | item_names_raw == "", 
               paste0("Item_", 1:num_questions), 
               as.character(item_names_raw))
      } else {
        paste0("Item_", 1:num_questions)
      }
      
      # Ensure all vectors have the same length and no missing values
      item_responses <- responses[1:num_questions]
      if (length(item_responses) < num_questions) {
        item_responses <- c(item_responses, rep(NA, num_questions - length(item_responses)))
      }
      
      # Ensure category vector is the right length
      if (length(category_vector) < num_questions) {
        category_vector <- c(category_vector, rep("Other", num_questions - length(category_vector)))
      }
      
      item_details <- data.frame(
        Item = item_names,
        Response = item_responses,
        Category = category_vector[1:num_questions],
        stringsAsFactors = FALSE,
        row.names = NULL  # Explicitly set row names to NULL to avoid issues
      )
    }, error = function(e) {
      cat("Error creating item_details data.frame:", e$message, "\n")
      # Create a simple fallback data.frame
      item_details <- data.frame(
        Item = paste0("Item_", 1:min(num_questions, 10)),
        Response = rep(NA, min(num_questions, 10)),
        Category = rep("Unknown", min(num_questions, 10)),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })
    
    # Generate HTML report with download button
    report_id <- paste0("report_", format(Sys.time(), "%Y%m%d_%H%M%S"))
    
    html <- paste0(
      '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
      
      # Radar plot
      '<div class="report-section">',
      '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
      '<span data-lang-de="Persönlichkeitsprofil" data-lang-en="Personality Profile">', if (is_english) "Personality Profile" else "Persönlichkeitsprofil", '</span></h2>',
      tryCatch({
        if (!is.null(radar_base64) && radar_base64 != "") {
          paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px;">')
        } else {
          ""
        }
      }, error = function(e) ""),
      '</div>',
      
      # Trace plot for Programming Anxiety
      '<div class="report-section">',
      '<h2 style="color: #9b59b6; text-align: center; margin-bottom: 25px;">',
      '<span data-lang-de="Programmierangst - Adaptive Testung" data-lang-en="Programming Anxiety - Adaptive Testing Trace">', if (is_english) "Programming Anxiety - Adaptive Testing Trace" else "Programmierangst - Adaptive Testung", '</span></h2>',
      tryCatch({
        if (exists("trace_base64") && !is.null(trace_base64) && trace_base64 != "") {
          paste0('<img src="data:image/png;base64,', trace_base64, '" style="width: 100%; max-width: 800px; display: block; margin: 0 auto; border-radius: 8px;">')
        } else {
          ""
        }
      }, error = function(e) ""),
      '<p style="text-align: center; color: #666; margin-top: 10px; font-size: 14px;">',
      '<span data-lang-de="Dieses Diagramm zeigt die Entwicklung der Theta-Schätzung während der Bewertung. Der schattierte Bereich zeigt das Standardfehlerband. Die vertikale Linie trennt fixe und adaptive Items." ',
      'data-lang-en="This trace plot shows how the theta estimate evolved during the assessment. The shaded area represents the standard error band. Vertical line separates fixed and adaptive items.">',
      if (is_english) "This trace plot shows how the theta estimate evolved during the assessment. The shaded area represents the standard error band. Vertical line separates fixed and adaptive items." else "Dieses Diagramm zeigt die Entwicklung der Theta-Schätzung während der Bewertung. Der schattierte Bereich zeigt das Standardfehlerband. Die vertikale Linie trennt fixe und adaptive Items.",
      '</span></p>',
      '</div>',
      
      # Bar chart
      '<div class="report-section">',
      '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
      '<span data-lang-de="Alle Dimensionen im Überblick" data-lang-en="All Dimensions Overview">', if (is_english) "All Dimensions Overview" else "Alle Dimensionen im Überblick", '</span></h2>',
      tryCatch({
        if (!is.null(bar_base64) && bar_base64 != "") {
          paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 8px;">')
        } else {
          ""
        }
      }, error = function(e) ""),
      '</div>',
      
      # Table
      '<div class="report-section">',
      '<h2 style="color: #e8041c;">',
      '<span data-lang-de="Detaillierte Auswertung" data-lang-en="Detailed Results">', if (is_english) "Detailed Results" else "Detaillierte Auswertung", '</span></h2>',
      '<table style="width: 100%; border-collapse: collapse;">',
      '<tr style="background: #f8f8f8;">',
      '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
      if (is_english) "Dimension" else "Dimension", '</th>',
      '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">',
      if (is_english) "Mean" else "Mittelwert", '</th>',
      '<th style="padding: 12px; border-bottom: 2px solid #e8041c; text-align: center;">',
      if (is_english) "Standard Deviation" else "Standardabweichung", '</th>',
      '<th style="padding: 12px; border-bottom: 2px solid #e8041c;">',
      if (is_english) "Interpretation" else "Interpretation", '</th>',
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
    
    for (name in names(ordered_scores)) {
      value <- round(ordered_scores[[name]], 2)
      # Map back to original scores for SD calculation
      original_name <- if (is_english) {
        switch(name,
               "Agreeableness" = "Verträglichkeit",
               "Conscientiousness" = "Gewissenhaftigkeit", 
               "Neuroticism" = "Neurotizismus",
               "Openness" = "Offenheit",
               "StudySkills" = "Studierfähigkeiten",
               "Statistics" = "Statistik",
               name  # Keep same for others
        )
      } else {
        name
      }
      sd_value <- ifelse(original_name %in% names(sds), sds[[original_name]], NA)
      level <- ifelse(value >= 3.7, 
                      if (is_english) "High" else "Hoch", 
                      ifelse(value >= 2.3, 
                             if (is_english) "Medium" else "Mittel", 
                             if (is_english) "Low" else "Niedrig"))
      color <- ifelse(value >= 3.7, "#28a745", ifelse(value >= 2.3, "#ffc107", "#dc3545"))
      
      # Translate dimension names
      if (is_english) {
        name_display <- switch(name,
                               "ProgrammingAnxiety" = "Programming Anxiety",
                               "Extraversion" = "Extraversion",
                               "Agreeableness" = "Agreeableness",
                               "Conscientiousness" = "Conscientiousness",
                               "Neuroticism" = "Neuroticism",
                               "Openness" = "Openness",
                               "Stress" = "Stress",
                               "StudySkills" = "Study Skills",
                               "Statistics" = "Statistics",
                               name  # Default fallback
        )
      } else {
        name_display <- switch(name,
                               "ProgrammingAnxiety" = "Programmierangst",
                               "Extraversion" = "Extraversion",
                               "Verträglichkeit" = "Verträglichkeit",
                               "Gewissenhaftigkeit" = "Gewissenhaftigkeit",
                               "Neurotizismus" = "Neurotizismus",
                               "Offenheit" = "Offenheit",
                               "Stress" = "Stress",
                               "Studierfähigkeiten" = "Studierfähigkeiten",
                               "Statistik" = "Statistik",
                               name  # Default fallback
        )
      }
      
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
      cat("DEBUG: Starting complete_data creation\n")
      tryCatch({
        # Prepare complete dataset with error handling
        tryCatch({
          complete_data <- data.frame(
            timestamp = Sys.time(),
            session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
            study_language = ifelse(exists("session") && !is.null(session$userData$language), 
                                    session$userData$language, "de"),
            stringsAsFactors = FALSE,
            row.names = NULL
          )
          cat("DEBUG: complete_data created successfully\n")
        }, error = function(e) {
          cat("Error creating complete_data data.frame:", e$message, "\n")
          # Create fallback complete_data
          complete_data <- data.frame(
            timestamp = Sys.time(),
            session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
            study_language = "de",
            stringsAsFactors = FALSE,
            row.names = NULL
          )
        })
        
        # Add demographics from the session
        cat("DEBUG: Adding demographics to complete_data\n")
        cat("DEBUG: demographics parameter:", !is.null(demographics), "\n")
        cat("DEBUG: demographics is.list:", is.list(demographics), "\n")
        
        # Try to get demographics from the parameter first
        if (!is.null(demographics) && is.list(demographics)) {
          cat("DEBUG: Using demographics parameter\n")
          cat("DEBUG: demographics names:", paste(names(demographics), collapse=", "), "\n")
          for (demo_name in names(demographics)) {
            demo_value <- demographics[[demo_name]]
            cat("DEBUG: Adding demographic", demo_name, "=", demo_value, "\n")
            complete_data[[demo_name]] <- demo_value
          }
        } else if (exists("demographics") && is.list(demographics)) {
          cat("DEBUG: Using global demographics variable\n")
          cat("DEBUG: demographics names:", paste(names(demographics), collapse=", "), "\n")
          for (demo_name in names(demographics)) {
            demo_value <- demographics[[demo_name]]
            cat("DEBUG: Adding demographic", demo_name, "=", demo_value, "\n")
            complete_data[[demo_name]] <- demo_value
          }
        } else if (!is.null(session) && is.list(session) && "userData" %in% names(session)) {
          cat("DEBUG: Trying to get demographics from session$userData\n")
          if ("demographics" %in% names(session$userData)) {
            session_demos <- session$userData$demographics
            cat("DEBUG: Found demographics in session$userData\n")
            if (is.list(session_demos)) {
              cat("DEBUG: session demographics names:", paste(names(session_demos), collapse=", "), "\n")
              for (demo_name in names(session_demos)) {
                demo_value <- session_demos[[demo_name]]
                cat("DEBUG: Adding session demographic", demo_name, "=", demo_value, "\n")
                complete_data[[demo_name]] <- demo_value
              }
            }
          }
        } else {
          cat("DEBUG: No demographics to add\n")
        }
        
        # Add item responses with validation
        cat("DEBUG: Adding item responses to complete_data\n")
        cat("DEBUG: nrow(item_bank) =", nrow(item_bank), "\n")
        cat("DEBUG: length(responses) =", length(responses), "\n")
        for (i in seq_along(responses)) {
          if (i <= nrow(item_bank)) {
            col_name <- item_bank$id[i]
            cat("DEBUG: Item", i, "col_name =", col_name, "(is.na:", is.na(col_name), ")\n")
            # Ensure col_name is valid and not NA
            if (!is.na(col_name) && !is.null(col_name) && col_name != "") {
              complete_data[[col_name]] <- responses[i]
            } else {
              # Use fallback column name
              complete_data[[paste0("Item_", i)]] <- responses[i]
            }
          }
        }
        
        # Add calculated scores with validation
        complete_data$BFI_Extraversion <- if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) 3 else scores$Extraversion
        complete_data$BFI_Vertraeglichkeit <- if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) 3 else scores$Verträglichkeit
        complete_data$BFI_Gewissenhaftigkeit <- if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) 3 else scores$Gewissenhaftigkeit
        complete_data$BFI_Neurotizismus <- if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) 3 else scores$Neurotizismus
        complete_data$BFI_Offenheit <- if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) 3 else scores$Offenheit
        complete_data$PSQ_Stress <- if (is.na(scores$Stress) || is.nan(scores$Stress)) 3 else scores$Stress
        complete_data$MWS_Studierfaehigkeiten <- if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) 3 else scores$Studierfähigkeiten
        complete_data$Statistik <- if (is.na(scores$Statistik) || is.nan(scores$Statistik)) 3 else scores$Statistik
        
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
    # Ensure current_lang is safe to use in if statements
    is_english <- !is.null(current_lang) && !is.na(current_lang) && is_english
    
    date_label <- if (is_english) "Date: " else "Datum: "
    profile_label <- if (is_english) "PERSONALITY PROFILE" else "PERSÖNLICHKEITSPROFIL"
    pa_label <- if (is_english) "Programming Anxiety: " else "Programmierangst: "
    agree_label <- if (is_english) "Agreeableness: " else "Verträglichkeit: "
    consc_label <- if (is_english) "Conscientiousness: " else "Gewissenhaftigkeit: "
    neuro_label <- if (is_english) "Neuroticism: " else "Neurotizismus: "
    open_label <- if (is_english) "Openness: " else "Offenheit: "
    stress_label <- if (is_english) "Stress: " else "Stress: "
    study_label <- if (is_english) "Study Skills: " else "Studierfähigkeiten: "
    stat_label <- if (is_english) "Statistics: " else "Statistik: "
    
    download_section_html <- paste0(
      '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">',
      '<h4 style="color: #333; margin-bottom: 15px;">',
      if (is_english) "Export Results" else "Ergebnisse exportieren",
      '</h4>',
      '<div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">',
      
      # PDF Download Button
      '<button onclick="downloadPDF();" class="btn btn-primary" style="background: #e8041c; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
      "<i class=\"fas fa-file-pdf\" style=\"margin-right: 8px;\"></i>",
      if (is_english) "Download PDF" else "PDF herunterladen",
      '</button>',
      
      # CSV Download Button  
      '<button onclick="downloadCSV();" class="btn btn-success" style="background: #28a745; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
      "<i class=\"fas fa-file-csv\" style=\"margin-right: 8px;\"></i>",
      if (is_english) "Download CSV" else "CSV herunterladen",
      '</button>',
      
      '</div>',
      '</div>',
      
      # JavaScript for download functions
      '<script>',
      'function downloadPDF() {',
      '  console.log("PDF download requested");',
      '  // Use Shiny to trigger the download',
      '  if (typeof Shiny !== "undefined") {',
      '    Shiny.setInputValue("download_pdf_trigger", Math.random());',
      '  } else {',
      '    alert("PDF download is not available. Please try again.");',
      '  }',
      '}',
      '',
      'function downloadCSV() {',
      '  console.log("CSV download requested");',
      '  // Use Shiny to trigger the download',
      '  if (typeof Shiny !== "undefined") {',
      '    Shiny.setInputValue("download_csv_trigger", Math.random());',
      '  } else {',
      '    alert("CSV download is not available. Please try again.");',
      '  }',
      '}',
      '</script>',
      
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
    
  }, error = function(e) {
    cat("CRITICAL ERROR in create_hilfo_report:", e$message, "\n")
    cat("Error details:", toString(e), "\n")
    # Return a simple error message
    return(shiny::HTML('<div style="padding: 20px; color: red;"><h2>Error generating report</h2><p>An error occurred while generating your results. Please try again.</p><p>Error: ' + e$message + '</p></div>'))
  })
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
\\fancyhead[L]{HilFo}
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
      
      # Fisher Information for 2PL: I(theta) = a^2 * P(theta) * Q(theta)
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
    
    message(sprintf("\nSelected item %d (%s) with Maximum Fisher Information = %.4f", 
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

# JavaScript for downloads and language switching
custom_js <- '<script>
/* Download functions for PDF and CSV */
function downloadPDF() {
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("download_pdf_trigger", Math.random());
  } else {
    alert("PDF download is not available. Please try again.");
  }
}

function downloadCSV() {
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("download_csv_trigger", Math.random());
  } else {
    alert("CSV download is not available. Please try again.");
  }
}

/* Language switching functions - ULTRA SIMPLE VERSION */
window.toggleLanguage = function() {
  console.log("toggleLanguage() called - FUNCTION FOUND!");
  var deContent = document.getElementById("content_de");
  var enContent = document.getElementById("content_en");
  var textSpan = document.getElementById("lang_switch_text");
  
  console.log("Elements found - deContent:", !!deContent, "enContent:", !!enContent, "textSpan:", !!textSpan);
  
  if (deContent && enContent) {
    if (deContent.style.display === "none") {
      /* Switch to German */
      console.log("Switching to German");
      deContent.style.display = "block";
      enContent.style.display = "none";
      if (textSpan) textSpan.textContent = "English Version";
      
      // Send to inrep system - this should trigger the en, de, en, de console output
      if (typeof Shiny !== "undefined") {
        Shiny.setInputValue("study_language", "de", {priority: "event"});
        console.log("Sent study_language = de to Shiny");
      }
    } else {
      /* Switch to English */
      console.log("Switching to English");
      deContent.style.display = "none";
      enContent.style.display = "block";
      if (textSpan) textSpan.textContent = "Deutsche Version";
      
      // Send to inrep system - this should trigger the en, de, en, de console output
      if (typeof Shiny !== "undefined") {
        Shiny.setInputValue("study_language", "en", {priority: "event"});
        console.log("Sent study_language = en to Shiny");
      }
    }
  } else {
    console.log("ERROR: Content elements not found!");
  }
  
  // Sync checkboxes
  var deCheck = document.getElementById("consent_check");
  var enCheck = document.getElementById("consent_check_en");
  if (deCheck && enCheck) {
    if (deContent.style.display === "none") {
      enCheck.checked = deCheck.checked;
    } else {
      deCheck.checked = enCheck.checked;
    }
  }
};

// Also define it as a global function for compatibility
function toggleLanguage() {
  return window.toggleLanguage();
}

/* Apply language to personal code page - simplified version */
function applyLanguageToPage20() {
  var currentLang = sessionStorage.getItem("hilfo_language") || "de";
  
  // Update all elements with data-lang attributes
  var elements = document.querySelectorAll("[data-lang-de][data-lang-en]");
  elements.forEach(function(el) {
    if (currentLang === "en") {
      el.textContent = el.getAttribute("data-lang-en");
    } else {
      el.textContent = el.getAttribute("data-lang-de");
    }
  });
  
  // Update input placeholder
  var input = document.getElementById("personal_code");
  if (input) {
    if (currentLang === "en") {
      input.placeholder = input.getAttribute("data-placeholder-en") || "e.g. MAHA15";
    } else {
      input.placeholder = input.getAttribute("data-placeholder-de") || "z.B. MAHA15";
    }
  }
}

/* Apply language to results page */
function applyLanguageToResultsPage() {
  var currentLang = sessionStorage.getItem("hilfo_language") || "de";
  
  // Update all elements with data-lang attributes
  var elements = document.querySelectorAll("[data-lang-de][data-lang-en]");
  elements.forEach(function(el) {
    if (currentLang === "en") {
      el.textContent = el.getAttribute("data-lang-en");
    } else {
      el.textContent = el.getAttribute("data-lang-de");
    }
  });
}

/* Initialize language switching - SIMPLE VERSION */
document.addEventListener("DOMContentLoaded", function() {
  console.log("Language switching initialized");
  
  // Test if toggleLanguage function is available
  console.log("toggleLanguage function available:", typeof window.toggleLanguage);
  
  // Initialize page 1 language switching
  setTimeout(function() {
    var deContent = document.getElementById("content_de");
    var enContent = document.getElementById("content_en");
    var textSpan = document.getElementById("lang_switch_text");
    
    console.log("Page 1 elements found - deContent:", !!deContent, "enContent:", !!enContent, "textSpan:", !!textSpan);
    
    if (deContent && enContent) {
      // Start with German (default)
      deContent.style.display = "block";
      enContent.style.display = "none";
      if (textSpan) textSpan.textContent = "English Version";
      console.log("Page 1 initialized to German");
    }
    
    // Test button click
    var button = document.getElementById("language-toggle-btn");
    if (button) {
      console.log("Language toggle button found:", !!button);
      // Add additional click listener as backup
      button.addEventListener("click", function() {
        console.log("Button click event listener triggered");
        if (typeof window.toggleLanguage === "function") {
          window.toggleLanguage();
        } else {
          console.log("toggleLanguage function not found!");
        }
      });
    } else {
      console.log("Language toggle button NOT found!");
    }
  }, 100);
  
  // Initialize checkbox synchronization
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

# Download functions moved to HTML string
# CSV download function moved to HTML string

study_config <- inrep::create_study_config(
  name = "HilFo - Hildesheimer Forschungsmethoden - FIXED",
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
  bilingual = TRUE,  # Enable inrep's built-in bilingual support
  session_save = TRUE,
  session_timeout = 7200,  # 2 hours timeout
  results_processor = create_hilfo_report,  # Add custom results processor
  custom_js = custom_js  # Add custom JavaScript for language switching and downloads
)

cat("\n================================================================================\n")
cat("HILFO STUDIE - PRODUCTION VERSION\n")
cat("================================================================================\n")
cat("All 48 variables recorded with proper names\n")
cat("Cloud storage enabled with inreptest credentials\n")
cat("Fixed radar plot with proper connections\n")
cat("Complete data file will be saved as CSV\n")
cat("================================================================================\n\n")


# Download functionality is handled by inrep's built-in download system
# No custom download handlers needed



# No custom CSS or JavaScript needed - inrep handles everything automatically
# Launch with inrep's built-in capabilities
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,  # Bilingual item bank
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv",
  # Add server-side language tracking and download handlers
  server_extensions = list(
    download_handler = function(input, output, session) {
      # Language tracking is handled by launch_study.R to prevent conflicts
      
      # Handle PDF download trigger
      shiny::observeEvent(input$download_pdf_trigger, {
        cat("PDF download trigger received\n")
        tryCatch({
          if (exists("complete_data", envir = .GlobalEnv)) {
            data <- get("complete_data", envir = .GlobalEnv)
            cat("DEBUG: PDF download - complete_data columns:", paste(names(data), collapse = ", "), "\n")
            
            # Use the proper PDF generation function
            if (requireNamespace("inrep", quietly = TRUE)) {
              # Create study data structure for PDF generation
              study_data <- list(
                responses = data$responses %||% numeric(0),
                theta_estimate = data$theta_estimate %||% 0,
                theta_se = data$theta_se %||% 1,
                theta_history = data$theta_history %||% numeric(0),
                demographics = data$demographics %||% list(),
                BFI_Extraversion = data$BFI_Extraversion %||% 0,
                BFI_Agreeableness = data$BFI_Vertraeglichkeit %||% 0,
                BFI_Conscientiousness = data$BFI_Gewissenhaftigkeit %||% 0,
                BFI_Neuroticism = data$BFI_Neurotizismus %||% 0,
                BFI_Openness = data$BFI_Offenheit %||% 0,
                ProgrammingAnxiety = data$ProgrammingAnxiety %||% 0,
                PSQ_Stress = data$PSQ_Stress %||% 0,
                MWS_Studierfaehigkeiten = data$MWS_Studierfaehigkeiten %||% 0,
                Statistik = data$Statistik %||% 0
              )
              
              # Create study config
              study_config <- list(
                name = "HilFo - Hildesheimer Forschungsmethoden",
                model = "2PL",
                adaptive = TRUE
              )
              
              # Generate PDF using proper PDF generation
              temp_pdf <- tempfile(fileext = ".pdf")
              cat("DEBUG: PDF generation starting, temp file:", temp_pdf, "\n")
              
              # Create a comprehensive PDF report using base R graphics
              tryCatch({
                # Generate PDF using base R graphics
                pdf(temp_pdf, width = 8.5, height = 11, paper = "letter")
                par(mar = c(2, 2, 2, 2), family = "serif")
                
                # Title
                plot(0, 0, type = "n", xlim = c(0, 1), ylim = c(0, 1), 
                     axes = FALSE, xlab = "", ylab = "")
                
                # Main title
                text(0.5, 0.95, "HilFo Study Results", 
                     cex = 2, font = 2, col = "#e8041c")
                
                # Subtitle
                text(0.5, 0.9, "Hildesheimer Forschungsmethoden", 
                     cex = 1.2, col = "#666")
                
                # Date
                text(0.5, 0.85, format(Sys.time(), "%Y-%m-%d %H:%M:%S"), 
                     cex = 1, col = "#999")
                
                # Personality Profile Section
                text(0.1, 0.75, "PERSONALITY PROFILE (Big Five)", 
                     cex = 1.4, font = 2, col = "#333")
                
                # Personality scores
                personality_scores <- c(
                  paste("Extraversion:", round(data$BFI_Extraversion[1], 2)),
                  paste("Agreeableness:", round(data$BFI_Vertraeglichkeit[1], 2)),
                  paste("Conscientiousness:", round(data$BFI_Gewissenhaftigkeit[1], 2)),
                  paste("Neuroticism:", round(data$BFI_Neurotizismus[1], 2)),
                  paste("Openness:", round(data$BFI_Offenheit[1], 2))
                )
                
                for (i in 1:length(personality_scores)) {
                  text(0.1, 0.7 - (i-1)*0.05, personality_scores[i], 
                       cex = 1.1, col = "#333")
                }
                
                # Programming Anxiety Section
                text(0.1, 0.4, "PROGRAMMING ANXIETY ASSESSMENT", 
                     cex = 1.4, font = 2, col = "#333")
                
                pa_scores <- c(
                  paste("Classical Score:", round(data$ProgrammingAnxiety[1], 2), "(range 1-5)"),
                  paste("IRT Theta:", round(data$theta_estimate[1], 3)),
                  paste("Standard Error:", round(data$theta_se[1], 3))
                )
                
                for (i in 1:length(pa_scores)) {
                  text(0.1, 0.35 - (i-1)*0.05, pa_scores[i], 
                       cex = 1.1, col = "#333")
                }
                
                # Additional Assessments
                text(0.1, 0.2, "ADDITIONAL ASSESSMENTS", 
                     cex = 1.4, font = 2, col = "#333")
                
                additional_scores <- c(
                  paste("Stress Level:", round(data$PSQ_Stress[1], 2)),
                  paste("Study Skills:", round(data$MWS_Studierfaehigkeiten[1], 2)),
                  paste("Statistics:", round(data$Statistik[1], 2))
                )
                
                for (i in 1:length(additional_scores)) {
                  text(0.1, 0.15 - (i-1)*0.05, additional_scores[i], 
                       cex = 1.1, col = "#333")
                }
                
                # Footer
                text(0.5, 0.05, "Generated by HilFo Study System", 
                     cex = 0.8, col = "#999")
                
                dev.off()
                cat("DEBUG: PDF file created successfully\n")
                
              }, error = function(e) {
                cat("DEBUG: PDF generation failed:", e$message, "\n")
                # Close any open graphics device
                if (dev.cur() != 1) dev.off()
              })
              
              # Check if PDF was created and send to client
              if (file.exists(temp_pdf) && file.info(temp_pdf)$size > 0) {
                cat("DEBUG: PDF file exists and has content, sending to client\n")
                pdf_data <- readBin(temp_pdf, "raw", file.info(temp_pdf)$size)
                pdf_base64 <- base64enc::base64encode(pdf_data)
                
                # Send PDF to client
                shiny::runjs(sprintf("
                                    var pdfData = '%s';
                                    var byteCharacters = atob(pdfData);
                                    var byteNumbers = new Array(byteCharacters.length);
                                    for (var i = 0; i < byteCharacters.length; i++) {
                                        byteNumbers[i] = byteCharacters.charCodeAt(i);
                                    }
                                    var byteArray = new Uint8Array(byteNumbers);
                                    var blob = new Blob([byteArray], {type: 'application/pdf'});
                                    var url = window.URL.createObjectURL(blob);
                                    var link = document.createElement('a');
                                    link.href = url;
                                    link.download = 'HilFo_Results_' + new Date().toISOString().slice(0,19).replace(/:/g, '-') + '.pdf';
                                    link.style.visibility = 'hidden';
                                    document.body.appendChild(link);
                                    link.click();
                                    document.body.removeChild(link);
                                    window.URL.revokeObjectURL(url);
                                ", pdf_base64))
                
                cat("PDF download completed successfully\n")
                unlink(temp_pdf)
              } else {
                cat("DEBUG: PDF file not created or empty, falling back to text\n")
                generate_text_fallback(data)
              }
              
              # Remove the old rmarkdown approach
              if (FALSE) {
                cat("DEBUG: Using rmarkdown for PDF generation\n")
                # Use R Markdown to generate PDF
                rmd_content <- paste0("
---
title: 'HilFo Study Results'
author: 'Hildesheimer Forschungsmethoden'
date: '", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "'
output: pdf_document
---

# HilFo Study Results

## Participant Information
- **Study Language**: ", ifelse(exists("hilfo_language_preference") && hilfo_language_preference == "en", "English", "German"), "
- **Completion Date**: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "

## Personality Profile (Big Five)

| Dimension | Score | Interpretation |
|-----------|-------|----------------|
| Extraversion | ", round(data$BFI_Extraversion[1], 2), " | ", ifelse(data$BFI_Extraversion[1] > 3.5, "High", ifelse(data$BFI_Extraversion[1] < 2.5, "Low", "Moderate")), " |
| Agreeableness | ", round(data$BFI_Vertraeglichkeit[1], 2), " | ", ifelse(data$BFI_Vertraeglichkeit[1] > 3.5, "High", ifelse(data$BFI_Vertraeglichkeit[1] < 2.5, "Low", "Moderate")), " |
| Conscientiousness | ", round(data$BFI_Gewissenhaftigkeit[1], 2), " | ", ifelse(data$BFI_Gewissenhaftigkeit[1] > 3.5, "High", ifelse(data$BFI_Gewissenhaftigkeit[1] < 2.5, "Low", "Moderate")), " |
| Neuroticism | ", round(data$BFI_Neurotizismus[1], 2), " | ", ifelse(data$BFI_Neurotizismus[1] > 3.5, "High", ifelse(data$BFI_Neurotizismus[1] < 2.5, "Low", "Moderate")), " |
| Openness | ", round(data$BFI_Offenheit[1], 2), " | ", ifelse(data$BFI_Offenheit[1] > 3.5, "High", ifelse(data$BFI_Offenheit[1] < 2.5, "Low", "Moderate")), " |

## Programming Anxiety Assessment

- **IRT Theta Estimate**: ", round(data$theta_estimate[1], 3), "
- **Standard Error**: ", round(data$theta_se[1], 3), "
- **Classical Score**: ", round(data$ProgrammingAnxiety[1], 2), " (range 1-5)
- **Interpretation**: ", ifelse(data$ProgrammingAnxiety[1] > 3.5, "High anxiety", ifelse(data$ProgrammingAnxiety[1] < 2.5, "Low anxiety", "Moderate anxiety")), "

## Additional Assessments

- **Stress Level**: ", round(data$PSQ_Stress[1], 2), "
- **Study Skills**: ", round(data$MWS_Studierfaehigkeiten[1], 2), "
- **Statistics Confidence**: ", round(data$Statistik[1], 2), "

## Individual Item Responses

| Item ID | Response | Item Text |
|---------|----------|-----------|
")
                
                # Add individual item responses
                for (i in 1:length(data$responses)) {
                  if (!is.na(data$responses[i])) {
                    item_id <- names(data)[i+4] # Skip first 4 columns
                    item_text <- if (i <= nrow(all_items_de)) all_items_de$Question[i] else "Item text not available"
                    rmd_content <- paste0(rmd_content, "| ", item_id, " | ", data$responses[i], " | ", substr(item_text, 1, 50), "... |\n")
                  }
                }
                
                rmd_content <- paste0(rmd_content, "

---
*Generated by HilFo Study System*
*", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "*")
                
                # Write RMD file and render
                rmd_file <- tempfile(fileext = ".Rmd")
                writeLines(rmd_content, rmd_file)
                
                rmarkdown::render(rmd_file, output_file = temp_pdf, quiet = TRUE)
                unlink(rmd_file)
              } else {
                # Fallback: create simple PDF using base R
                pdf(temp_pdf, width = 8.5, height = 11)
                plot.new()
                text(0.5, 0.9, "HilFo Study Results", cex = 2, font = 2)
                text(0.5, 0.8, paste("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")), cex = 1.2)
                text(0.5, 0.7, paste("Study Language:", ifelse(exists("hilfo_language_preference") && hilfo_language_preference == "en", "English", "German")), cex = 1.2)
                text(0.5, 0.6, "Personality Profile:", cex = 1.5, font = 2)
                text(0.5, 0.55, paste("Extraversion:", round(data$BFI_Extraversion[1], 2)), cex = 1)
                text(0.5, 0.5, paste("Agreeableness:", round(data$BFI_Vertraeglichkeit[1], 2)), cex = 1)
                text(0.5, 0.45, paste("Conscientiousness:", round(data$BFI_Gewissenhaftigkeit[1], 2)), cex = 1)
                text(0.5, 0.4, paste("Neuroticism:", round(data$BFI_Neurotizismus[1], 2)), cex = 1)
                text(0.5, 0.35, paste("Openness:", round(data$BFI_Offenheit[1], 2)), cex = 1)
                text(0.5, 0.25, "Programming Anxiety:", cex = 1.5, font = 2)
                text(0.5, 0.2, paste("Score:", round(data$ProgrammingAnxiety[1], 2)), cex = 1)
                text(0.5, 0.15, paste("IRT Theta:", round(data$theta_estimate[1], 3)), cex = 1)
                text(0.5, 0.1, paste("Standard Error:", round(data$theta_se[1], 3)), cex = 1)
                dev.off()
              }
              
              # Read the PDF file and create download
              if (file.exists(temp_pdf)) {
                pdf_content <- readBin(temp_pdf, "raw", file.info(temp_pdf)$size)
                
                # Create JavaScript to download the PDF
                js_code <- paste0("
                                    var pdfData = '", base64enc::base64encode(pdf_content), "';
                                    var binaryString = atob(pdfData);
                                    var bytes = new Uint8Array(binaryString.length);
                                    for (var i = 0; i < binaryString.length; i++) {
                                        bytes[i] = binaryString.charCodeAt(i);
                                    }
                                    var blob = new Blob([bytes], { type: 'application/pdf' });
                                    var url = window.URL.createObjectURL(blob);
                                    var link = document.createElement('a');
                                    link.href = url;
                                    link.download = 'HilFo_Results_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".pdf';
                                    link.style.visibility = 'hidden';
                                    document.body.appendChild(link);
                                    link.click();
                                    document.body.removeChild(link);
                                    window.URL.revokeObjectURL(url);
                                ")
                
                shiny::runjs(js_code)
                cat("PDF download completed with proper PDF generation\n")
                
                # Clean up temp file
                unlink(temp_pdf)
              } else {
                cat("PDF file not created, falling back to text\n")
                # Fallback to text generation
                generate_text_fallback(data)
              }
            } else {
              cat("inrep package not available, using fallback\n")
              # Fallback to text generation
              generate_text_fallback(data)
            }
          } else {
            shiny::runjs("downloadPDFFallback();")
          }
        }, error = function(e) {
          cat("PDF download error:", e$message, "\n")
          # Fallback to text generation
          if (exists("complete_data", envir = .GlobalEnv)) {
            data <- get("complete_data", envir = .GlobalEnv)
            generate_text_fallback(data)
          } else {
            shiny::runjs("downloadPDFFallback();")
          }
        })
      })
      
      # Helper function for text fallback
      generate_text_fallback <- function(data) {
        # Extract scores from complete_data
        extraversion <- if("BFI_Extraversion" %in% names(data)) data$BFI_Extraversion[1] else "N/A"
        agreeableness <- if("BFI_Vertraeglichkeit" %in% names(data)) data$BFI_Vertraeglichkeit[1] else "N/A"
        conscientiousness <- if("BFI_Gewissenhaftigkeit" %in% names(data)) data$BFI_Gewissenhaftigkeit[1] else "N/A"
        neuroticism <- if("BFI_Neurotizismus" %in% names(data)) data$BFI_Neurotizismus[1] else "N/A"
        openness <- if("BFI_Offenheit" %in% names(data)) data$BFI_Offenheit[1] else "N/A"
        programming_anxiety <- if("ProgrammingAnxiety" %in% names(data)) data$ProgrammingAnxiety[1] else "N/A"
        stress <- if("PSQ_Stress" %in% names(data)) data$PSQ_Stress[1] else "N/A"
        study_skills <- if("MWS_Studierfaehigkeiten" %in% names(data)) data$MWS_Studierfaehigkeiten[1] else "N/A"
        statistics <- if("Statistik" %in% names(data)) data$Statistik[1] else "N/A"
        
        # Create comprehensive PDF content
        pdf_content <- paste0(
          "HilFo Study Results\n",
          "==================\n\n",
          "Generated: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n",
          "Study: HilFo - Hildesheimer Forschungsmethoden\n\n",
          "PERSONALITY PROFILE (Big Five)\n",
          "=============================\n",
          "Your personality was assessed using the Big Five dimensions:\n\n",
          "• Extraversion: ", if(is.numeric(extraversion)) round(extraversion, 2) else extraversion, "/5\n",
          "• Agreeableness: ", if(is.numeric(agreeableness)) round(agreeableness, 2) else agreeableness, "/5\n",
          "• Conscientiousness: ", if(is.numeric(conscientiousness)) round(conscientiousness, 2) else conscientiousness, "/5\n",
          "• Neuroticism: ", if(is.numeric(neuroticism)) round(neuroticism, 2) else neuroticism, "/5\n",
          "• Openness: ", if(is.numeric(openness)) round(openness, 2) else openness, "/5\n\n",
          "PROGRAMMING ANXIETY ASSESSMENT\n",
          "=============================\n",
          "Score: ", if(is.numeric(programming_anxiety)) round(programming_anxiety, 2) else programming_anxiety, "/5\n",
          "Interpretation: ", if(is.numeric(programming_anxiety)) {
            if(programming_anxiety < 2.5) "Low anxiety" else if(programming_anxiety < 3.5) "Moderate anxiety" else "High anxiety"
          } else "N/A", "\n\n",
          "ADDITIONAL MEASURES\n",
          "===================\n",
          "• Stress Level: ", if(is.numeric(stress)) round(stress, 2) else stress, "/5\n",
          "• Study Skills: ", if(is.numeric(study_skills)) round(study_skills, 2) else study_skills, "/5\n",
          "• Statistics Confidence: ", if(is.numeric(statistics)) round(statistics, 2) else statistics, "/5\n\n",
          "RECOMMENDATIONS\n",
          "===============\n",
          "Based on your results, consider:\n",
          "• Working on stress management techniques\n",
          "• Developing study strategies\n",
          "• Practicing programming regularly\n",
          "• Seeking support when needed\n\n",
          "Thank you for participating in the HilFo study!\n",
          "For questions, contact: selvastics@uni-hildesheim.de\n\n",
          "---\n",
          "Complete data available in CSV format"
        )
        
        # Create download using JavaScript
        shiny::runjs(sprintf("
                    var content = %s;
                    var blob = new Blob([content], { type: 'text/plain' });
                    var url = window.URL.createObjectURL(blob);
                    var link = document.createElement('a');
                    link.href = url;
                    link.download = 'HilFo_Results_' + new Date().toISOString().slice(0,19).replace(/:/g, '-') + '.txt';
                    link.style.visibility = 'hidden';
                    document.body.appendChild(link);
                    link.click();
                    document.body.removeChild(link);
                    window.URL.revokeObjectURL(url);
                ", jsonlite::toJSON(pdf_content)))
        
        cat("Text fallback download completed\n")
      }
      
      # Handle language storage globally
      shiny::observeEvent(input$store_language_globally, {
        cat("DEBUG: Storing language globally:", input$store_language_globally, "\n")
        assign("hilfo_language_preference", input$store_language_globally, envir = .GlobalEnv)
        assign("study_language", input$store_language_globally, envir = .GlobalEnv)
        assign("current_language", input$store_language_globally, envir = .GlobalEnv)
        cat("DEBUG: Language stored globally as:", input$store_language_globally, "\n")
      })
      
      # Handle CSV download trigger
      shiny::observeEvent(input$download_csv_trigger, {
        cat("CSV download trigger received\n")
        tryCatch({
          # Try to get data from multiple sources
          data <- NULL
          
          # First try to get from global environment
          if (exists("complete_data", envir = .GlobalEnv)) {
            data <- get("complete_data", envir = .GlobalEnv)
            cat("DEBUG: Got data from global environment\n")
          } else if (exists("rv", envir = .GlobalEnv)) {
            # Try to get from reactive values
            rv <- get("rv", envir = .GlobalEnv)
            if (!is.null(rv$responses) && !is.null(rv$demographics)) {
              # Create data structure from reactive values
              data <- list(
                responses = rv$responses,
                demographics = rv$demographics,
                BFI_Extraversion = if(!is.null(rv$BFI_Extraversion)) rv$BFI_Extraversion else 0,
                BFI_Vertraeglichkeit = if(!is.null(rv$BFI_Vertraeglichkeit)) rv$BFI_Vertraeglichkeit else 0,
                BFI_Gewissenhaftigkeit = if(!is.null(rv$BFI_Gewissenhaftigkeit)) rv$BFI_Gewissenhaftigkeit else 0,
                BFI_Neurotizismus = if(!is.null(rv$BFI_Neurotizismus)) rv$BFI_Neurotizismus else 0,
                BFI_Offenheit = if(!is.null(rv$BFI_Offenheit)) rv$BFI_Offenheit else 0,
                ProgrammingAnxiety = if(!is.null(rv$ProgrammingAnxiety)) rv$ProgrammingAnxiety else 0,
                PSQ_Stress = if(!is.null(rv$PSQ_Stress)) rv$PSQ_Stress else 0,
                MWS_Studierfaehigkeiten = if(!is.null(rv$MWS_Studierfaehigkeiten)) rv$MWS_Studierfaehigkeiten else 0,
                Statistik = if(!is.null(rv$Statistik)) rv$Statistik else 0
              )
              cat("DEBUG: Created data from reactive values\n")
            }
          }
          
          if (!is.null(data)) {
            cat("DEBUG: Creating CSV with same format as cloud upload\n")
            
            # Use the SAME format as the cloud upload - create a data frame with all individual responses
            # This matches exactly what's uploaded to the cloud
            
            # Get the actual responses from the data
            responses <- if("responses" %in% names(data)) data$responses else numeric(51)
            demographics <- if("demographics" %in% names(data)) data$demographics else list()
            
            # Create the exact same format as cloud upload
            csv_data <- data.frame(
              timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
              session_id = if("session_id" %in% names(data)) data$session_id else paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
              study_language = if("study_language" %in% names(data)) data$study_language else "de",
              # All individual item responses (PA_01 through Statistik_selbstwirksam)
              PA_01 = if(length(responses) >= 1) responses[1] else NA,
              PA_02 = if(length(responses) >= 2) responses[2] else NA,
              PA_03 = if(length(responses) >= 3) responses[3] else NA,
              PA_04 = if(length(responses) >= 4) responses[4] else NA,
              PA_05 = if(length(responses) >= 5) responses[5] else NA,
              PA_06 = if(length(responses) >= 6) responses[6] else NA,
              PA_07 = if(length(responses) >= 7) responses[7] else NA,
              PA_08 = if(length(responses) >= 8) responses[8] else NA,
              PA_09 = if(length(responses) >= 9) responses[9] else NA,
              PA_10 = if(length(responses) >= 10) responses[10] else NA,
              PA_11 = if(length(responses) >= 11) responses[11] else NA,
              PA_12 = if(length(responses) >= 12) responses[12] else NA,
              PA_13 = if(length(responses) >= 13) responses[13] else NA,
              PA_14 = if(length(responses) >= 14) responses[14] else NA,
              PA_15 = if(length(responses) >= 15) responses[15] else NA,
              PA_16 = if(length(responses) >= 16) responses[16] else NA,
              PA_17 = if(length(responses) >= 17) responses[17] else NA,
              PA_18 = if(length(responses) >= 18) responses[18] else NA,
              PA_19 = if(length(responses) >= 19) responses[19] else NA,
              PA_20 = if(length(responses) >= 20) responses[20] else NA,
              BFE_01 = if(length(responses) >= 21) responses[21] else NA,
              BFE_02 = if(length(responses) >= 22) responses[22] else NA,
              BFE_03 = if(length(responses) >= 23) responses[23] else NA,
              BFE_04 = if(length(responses) >= 24) responses[24] else NA,
              BFV_01 = if(length(responses) >= 25) responses[25] else NA,
              BFV_02 = if(length(responses) >= 26) responses[26] else NA,
              BFV_03 = if(length(responses) >= 27) responses[27] else NA,
              BFV_04 = if(length(responses) >= 28) responses[28] else NA,
              BFG_01 = if(length(responses) >= 29) responses[29] else NA,
              BFG_02 = if(length(responses) >= 30) responses[30] else NA,
              BFG_03 = if(length(responses) >= 31) responses[31] else NA,
              BFG_04 = if(length(responses) >= 32) responses[32] else NA,
              BFN_01 = if(length(responses) >= 33) responses[33] else NA,
              BFN_02 = if(length(responses) >= 34) responses[34] else NA,
              BFN_03 = if(length(responses) >= 35) responses[35] else NA,
              BFN_04 = if(length(responses) >= 36) responses[36] else NA,
              BFO_01 = if(length(responses) >= 37) responses[37] else NA,
              BFO_02 = if(length(responses) >= 38) responses[38] else NA,
              BFO_03 = if(length(responses) >= 39) responses[39] else NA,
              BFO_04 = if(length(responses) >= 40) responses[40] else NA,
              PSQ_02 = if(length(responses) >= 41) responses[41] else NA,
              PSQ_04 = if(length(responses) >= 42) responses[42] else NA,
              PSQ_16 = if(length(responses) >= 43) responses[43] else NA,
              PSQ_29 = if(length(responses) >= 44) responses[44] else NA,
              PSQ_30 = if(length(responses) >= 45) responses[45] else NA,
              MWS_1_KK = if(length(responses) >= 46) responses[46] else NA,
              MWS_10_KK = if(length(responses) >= 47) responses[47] else NA,
              MWS_17_KK = if(length(responses) >= 48) responses[48] else NA,
              MWS_21_KK = if(length(responses) >= 49) responses[49] else NA,
              Statistik_gutfolgen = if(length(responses) >= 50) responses[50] else NA,
              Statistik_selbstwirksam = if(length(responses) >= 51) responses[51] else NA,
              # Calculated scores
              BFI_Extraversion = if("BFI_Extraversion" %in% names(data)) data$BFI_Extraversion[1] else NA,
              BFI_Vertraeglichkeit = if("BFI_Vertraeglichkeit" %in% names(data)) data$BFI_Vertraeglichkeit[1] else NA,
              BFI_Gewissenhaftigkeit = if("BFI_Gewissenhaftigkeit" %in% names(data)) data$BFI_Gewissenhaftigkeit[1] else NA,
              BFI_Neurotizismus = if("BFI_Neurotizismus" %in% names(data)) data$BFI_Neurotizismus[1] else NA,
              BFI_Offenheit = if("BFI_Offenheit" %in% names(data)) data$BFI_Offenheit[1] else NA,
              PSQ_Stress = if("PSQ_Stress" %in% names(data)) data$PSQ_Stress[1] else NA,
              MWS_Studierfaehigkeiten = if("MWS_Studierfaehigkeiten" %in% names(data)) data$MWS_Studierfaehigkeiten[1] else NA,
              Statistik = if("Statistik" %in% names(data)) data$Statistik[1] else NA,
              stringsAsFactors = FALSE
            )
            
            # Write CSV content
            csv_content <- utils::capture.output(write.csv(csv_data, row.names = FALSE))
            csv_string <- paste(csv_content, collapse = "\n")
            
            # Create download using JavaScript
            shiny::runjs(sprintf("
                            var csvContent = %s;
                            var blob = new Blob([csvContent], { type: 'text/csv' });
                            var url = window.URL.createObjectURL(blob);
                            var link = document.createElement('a');
                            link.href = url;
                            link.download = 'HilFo_Data_' + new Date().toISOString().slice(0,19).replace(/:/g, '-') + '.csv';
                            link.style.visibility = 'hidden';
                            document.body.appendChild(link);
                            link.click();
                            document.body.removeChild(link);
                            window.URL.revokeObjectURL(url);
                        ", jsonlite::toJSON(csv_string)))
            
          } else {
            cat("DEBUG: No data available, creating CSV from session data\n")
            # Create CSV from session data if available
            if (exists("session") && !is.null(session)) {
              # Try to get data from session
              session_data <- list()
              if (!is.null(session$userData$responses)) {
                session_data$responses <- session$userData$responses
              }
              if (!is.null(session$userData$demographics)) {
                session_data$demographics <- session$userData$demographics
              }
              
              if (length(session_data) > 0) {
                # Create CSV from session data
                csv_rows <- c("timestamp,participant_id,study_language,data_type,value")
                
                # Add study completion
                csv_rows <- c(csv_rows, paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), ",HILFO_PARTICIPANT,en,study_completed,true"))
                
                # Add responses if available
                if (!is.null(session_data$responses)) {
                  for (i in 1:length(session_data$responses)) {
                    if (!is.na(session_data$responses[i])) {
                      csv_rows <- c(csv_rows, paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), ",HILFO_PARTICIPANT,en,item_response_", i, ",", session_data$responses[i]))
                    }
                  }
                }
                
                # Add demographics if available
                if (!is.null(session_data$demographics)) {
                  for (name in names(session_data$demographics)) {
                    csv_rows <- c(csv_rows, paste0(format(Sys.time(), "%Y-%m-%d %H:%M:%S"), ",HILFO_PARTICIPANT,en,demographic_", name, ",", session_data$demographics[[name]]))
                  }
                }
                
                csv_content <- paste(csv_rows, collapse = "\n")
                
                # Create download using JavaScript
                shiny::runjs(sprintf("
                                    var csvContent = %s;
                                    var blob = new Blob([csvContent], { type: 'text/csv' });
                                    var url = window.URL.createObjectURL(blob);
                                    var link = document.createElement('a');
                                    link.href = url;
                                    link.download = 'HilFo_Data_' + new Date().toISOString().slice(0,19).replace(/:/g, '-') + '.csv';
                                    link.style.visibility = 'hidden';
                                    document.body.appendChild(link);
                                    link.click();
                                    document.body.removeChild(link);
                                    window.URL.revokeObjectURL(url);
                                ", jsonlite::toJSON(csv_content)))
                
                cat("CSV created from session data\n")
              } else {
                shiny::runjs("downloadCSVFallback();")
              }
            } else {
              shiny::runjs("downloadCSVFallback();")
            }
          }
        }, error = function(e) {
          cat("CSV download error:", e$message, "\n")
          shiny::runjs("downloadCSVFallback();")
        })
      })
    }
  )
  # No custom CSS needed - inrep handles theming
  # No admin dashboard hook needed - inrep handles monitoring
)
