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
library(kableExtra)
library(httr)
library(later)

# Helper: Attach an observer to a live Shiny session so that when the client
# sets the `finish_early` input the server attempts to stop the app.
# Usage: call attach_finish_early_observer(session) from your server function
# or session initialization code so the observer is registered for that session.
attach_finish_early_observer <- function(session) {
  if (is.null(session)) return(invisible(NULL))
  tryCatch({
    # Register after first flush to ensure session$input is available
    session$onFlushed(function() {
      # observeEvent must be created in server reactive context; placing
      # it inside onFlushed ensures the callback runs in the correct context.
      shiny::observeEvent(session$input$finish_early, {
        # Try to stop the app gracefully
        tryCatch({
          shiny::stopApp()
        }, error = function(e) {
          # If stopApp fails, attempt to close the session
          try({ session$close() }, silent = TRUE)
        })
      }, ignoreInit = TRUE)
    }, once = TRUE)
  }, error = function(e) {
    message("attach_finish_early_observer: could not attach observer: ", e$message)
  })
  invisible(NULL)
}


# =============================================================================
# HilFo-Studie – fixe Version ohne Programming-Anxiety-Block
# =============================================================================
# Wir behalten die BFI-, PSQ-, MWS- und Statistik-Items bei und lassen alle Variablen sauber benennen.

# Check that inrep package is available
if (!requireNamespace("inrep", quietly = TRUE)) {
  stop("Package 'inrep' is required. Please install it.")
}

# Einheitlicher Dateiname für alle Exporte
generate_hilfo_filename <- function(timestamp = NULL) {
  if (is.null(timestamp)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  }
  return(paste0("HilFo_results_", timestamp, ".csv"))
}

# =============================================================================
# Zugangsdaten für den Hildesheim-WebDAV-Export
# =============================================================================
# Öffentlicher Nextcloud-Link im aktuellen Share-Format
WEBDAV_URL <- "https://sync.academiccloud.de/index.php/s/Y51QPXzJVLWSAcb"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"  # Share token for authentication

# =============================================================================
# Upload nach WebDAV (an Mina-Ansatz angelehnt)
# =============================================================================
save_to_cloud <- function(data, filename) {
  # Datenrahmen als CSV-Text vorbereiten
  csv_text <- paste(capture.output(write.csv(data, row.names = FALSE)), collapse = "\n")
  
  # Den freigegebenen Link auf den WebDAV-Endpunkt umschreiben
  webdav_url_converted <- gsub("index.php/s/([^/]+).*", "public.php/webdav/", WEBDAV_URL)
  full_url <- paste0(webdav_url_converted, filename)
  
  message("\n=== WebDAV Upload Debug ===")
  message("Original URL: ", WEBDAV_URL)
  message("Converted URL: ", webdav_url_converted)
  message("Full upload URL: ", full_url)
  message("Filename: ", filename)
  message("Share token: ", WEBDAV_SHARE_TOKEN)
  message("===========================\n")
  
  tryCatch({
    # Upload via httr::PUT mit Share-Token
    response <- httr::PUT(
      url = full_url,
      body = csv_text,
      httr::authenticate(user = WEBDAV_SHARE_TOKEN, password = WEBDAV_PASSWORD, type = "basic"),
      httr::content_type("text/csv"),
      encode = "raw"
    )
    
    if (httr::status_code(response) %in% c(200, 201, 204)) {
      message("✓ Data successfully uploaded to WebDAV: ", filename)
      return(TRUE)
    } else {
      message("✗ WebDAV upload failed with status ", httr::status_code(response))
      message("Response: ", httr::content(response, "text"))
      return(FALSE)
    }
  }, error = function(e) {
    message("✗ WebDAV upload error: ", e$message)
    return(FALSE)
  })
}

# =============================================================================
# Itembank mit konsistenten Variablennamen
# =============================================================================

# Create bilingual item bank
all_items_de <- data.frame(
  id = c(
    # BFI-Items in der gewohnten Benennung
    "BFE_01", "BFE_02", "BFE_03", "BFE_04", # Extraversion
    "BFV_01", "BFV_02", "BFV_03", "BFV_04", # Verträglichkeit (Agreeableness)
    "BFG_01", "BFG_02", "BFG_03", "BFG_04", # Gewissenhaftigkeit (Conscientiousness)
    "BFN_01", "BFN_02", "BFN_03", "BFN_04", # Neurotizismus
    "BFO_01", "BFO_02", "BFO_03", "BFO_04", # Offenheit (Openness)
    # PSQ-Items
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS-Items
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  Question = c(
    # BFI Extraversion (Items 1–4)
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
    # MWS Kontakt/Kooperation
    "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
    # Statistik-Selbstwirksamkeit
    "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    "Ich bin in der Lage, Statistik zu erlernen."
  ),
  Question_EN = c(
    # BFI Extraversion (items 1-4)
    "I am outgoing, sociable.",
    "I am rather quiet.",
    "I am rather shy.",
    "I am talkative.",
    # BFI Agreeableness (items 28-31)
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
  ResponseCategories = rep("1,2,3,4,5", 31),  # 20 BFI + 5 PSQ + 4 MWS + 2 Stats = 31
  b = c(
    # IRT difficulty parameters
    rep(0, 31)  # BFI, PSQ, MWS, Statistics items
  ),
  a = c(
    # IRT discrimination parameters
    rep(1, 31)  # BFI, PSQ, MWS, Statistics items
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
# Vollständige demografische Sektion (zweisprachig, wie im SPSS-Export)
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
  
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    question_en = "What is your gender?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    options_en = c("female"="1", "male"="2", "diverse"="3"),
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
    question = "Welches Haustier würden Sie sich wünschen oder haben Sie bereits?",
    question_en = "Which pet would you like to have or do you already have?",
    options = c(
      "Hund"="1",
      "Katze"="2",
      "Fisch"="3",
      "Vogel"="4",
      "Nager"="5",
      "Reptil"="6",
      "Ich möchte kein Haustier"="7",
      "Sonstiges"="8"
    ),
    options_en = c(
      "Dog"="1",
      "Cat"="2",
      "Fish"="3",
      "Bird"="4",
      "Rodent"="5",
      "Reptile"="6",
      "I don't want a pet"="7",
      "Other"="8"
    ),
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
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
    question_en = "How satisfied are you with your study location Hildesheim?",
    options = c(
      "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "sehr zufrieden"="7"
    ),
    options_en = c(
      "not at all satisfied"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "very satisfied"="7"
    ),
    required = FALSE
  ),
  Persönlicher_Code = list(
    question = "Bitte erstellen Sie einen persönlichen Code (erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags). Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15",
    question_en = "Please create a personal code (first 2 letters of your mother's first name + first 2 letters of your birthplace + day of your birthday). Example: Maria (MA) + Hamburg (HA) + 15th day = MAHA15",
    type = "text",
    required = FALSE,
    # Kontrollfeld, damit wir im Test sehen, ob das HTML korrekt geladen wird
    html_content_debug = "This field should have HTML content!",
    # Eigenständiges HTML mit Sprachumschalter, damit wir keinen zweiten Header pflegen müssen
    html_content = '<div id="personal-code-container" style="padding: 20px; font-size: 16px; line-height: 1.8;">
          <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">Bitte erstellen Sie einen persönlichen Code:</p>
          <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
            <p style="margin: 0; font-weight: 500;">Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags</p>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <input type="text" id="Persönlicher_Code" name="Persönlicher_Code" placeholder="z.B. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
          </div>
          <div style="text-align: center; color: #666; font-size: 14px;">Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15</div>
        </div>',
    html_content_en = '<div id="personal-code-container" style="padding: 20px; font-size: 16px; line-height: 1.8;">
          <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">Please create a personal code:</p>
          <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
            <p style="margin: 0; font-weight: 500;">First 2 letters of your mothers first name + first 2 letters of your birthplace + day of your birthday</p>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <input type="text" id="Persönlicher_Code" name="Persönlicher_Code" placeholder="e.g. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
          </div>
          <div style="text-align: center; color: #666; font-size: 14px;">Example: Maria (MA) + Hamburg (HA) + 15th day = MAHA15</div>
        </div>'
  ),
  show_personal_results = list(
    question = "Möchten Sie Ihre persönlichen Ergebnisse dieser Erhebung sehen?",
    question_en = "Would you like to see your personal results from this assessment?",
    options = c("Ja, zeigen Sie mir meine persönlichen Ergebnisse" = "yes", "Nein, ich möchte meine persönlichen Ergebnisse nicht sehen" = "no"),
    options_en = c("Yes, show me my personal results" = "yes", "No, I do not want to see my personal results" = "no"),
    required = TRUE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Wohn_Zusatz = "text",
  Haustier = "radio",
  Rauchen = "radio",
  Ernährung = "radio",
  Ernährung_Zusatz = "text",
  Note_Englisch = "select",
  Note_Mathe = "select",
  Vor_Nachbereitung = "radio",
  Zufrieden_Hi_7st = "radio",
  Persönlicher_Code = "text",
  show_personal_results = "radio"
)



# =============================================================================
# Ablauf der Seiten im HilFo-Fragebogen
# =============================================================================

custom_page_flow <- list(
  # Seite 1: Begrüßung mit Pflicht-Einverständnis und Sprachumschalter
  list(
    id = "page1",
    type = "custom",
    title = "HilFo",
    content = '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">
      <div class="hildesheim-logo"></div>
      <div style="position: absolute; top: 10px; right: 10px;">
        <button type="button" id="language-toggle-btn" onclick="toggleLanguage()" style="
          background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text">English Version</span></button>
      </div>
      
      <div id="content_de">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Willkommen zur HilFo Studie</h1>
        <h2 style="color: #e8041c;">Liebe Studierende,</h2>
        <p>In den Seminaren zu den statistischen Verfahren wollen wir mit Daten arbeiten, 
        die von Ihnen selbst stammen. Deswegen bitten wir Sie an der nachfolgenden Befragung teilzunehmen.</p>
        <p>Da wir die Anwendung verschiedene Auswertungsverfahren ermöglichen wollen, deckt der Fragebogen verschiedene 
        Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">
        <strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene 
        Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im 
        Bachelor generiert und in diesem Jahrgang, möglicherweise auch in späteren Jahrgängen genutzt.</p>
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
        <p>In the seminars on statistical procedures, we want to work with data 
        that comes from you. Therefore, we ask you to participate in the following survey.</p>
        <p>Since we want to enable the application of various analysis procedures, the questionnaire covers different 
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
    function toggleLanguage() {
      var deContent = document.getElementById("content_de");
      var enContent = document.getElementById("content_en");
      var textSpan = document.getElementById("lang_switch_text");
      
      if (deContent && enContent) {
        if (deContent.style.display === "none") {
          /* Switch to German */
          deContent.style.display = "block";
          enContent.style.display = "none";
          if (textSpan) textSpan.textContent = "English Version";
          
          /* Send German language to global system - CONSISTENT STORAGE */
          sessionStorage.setItem("hilfo_global_language", "de");
          sessionStorage.setItem("global_language_preference", "de");
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("store_language_globally", "de", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "de");
          sessionStorage.setItem("current_language", "de");
          sessionStorage.setItem("hilfo_language_preference", "de");
        } else {
          /* Switch to English */
          deContent.style.display = "none";
          enContent.style.display = "block";
          if (textSpan) textSpan.textContent = "Deutsche Version";
          
          /* Send English language to global system - CONSISTENT STORAGE */
          sessionStorage.setItem("hilfo_global_language", "en");
          sessionStorage.setItem("global_language_preference", "en");
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("store_language_globally", "en", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "en");
          sessionStorage.setItem("current_language", "en");
          sessionStorage.setItem("hilfo_language_preference", "en");
        }
      }
      
      var deCheck = document.getElementById("consent_check");
      var enCheck = document.getElementById("consent_check_en");
      if (deCheck && enCheck) {
        if (deContent.style.display === "none") {
          enCheck.checked = deCheck.checked;
        } else {
          deCheck.checked = enCheck.checked;
        }
      }
    }
    
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
    
    // Sprache beim Laden setzen, damit alle Seiten synchron bleiben
    document.addEventListener("DOMContentLoaded", function() {
      // Unified language detection for entire study
      var currentLang = sessionStorage.getItem("hilfo_language_preference") || 
                       sessionStorage.getItem("global_language_preference") || 
                       sessionStorage.getItem("current_language") || "de";
      
      // Ensure all language keys are consistent
      sessionStorage.setItem("hilfo_language_preference", currentLang);
      sessionStorage.setItem("global_language_preference", currentLang);
      sessionStorage.setItem("current_language", currentLang);
      sessionStorage.setItem("hilfo_language", currentLang);
      
      console.log("Language initialized to:", currentLang);
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
  
  # Seite 2: Basisdemografie
  list(
    id = "page2",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Alter_VPN", "Geschlecht")
  ),
  
  # Seite 3: Wohnsituation
  list(
    id = "page3",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Wohnstatus", "Wohn_Zusatz")
  ),
  
  # Seite 4: Lebensstil
  list(
    id = "page4",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Rauchen", "Ernährung", "Ernährung_Zusatz")
  ),
  
  # Seite 5: Bildung
  list(
    id = "page5",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
  # Seiten 6–12: BFI, PSQ, MWS und Statistik (über die regulären Itemseiten zweisprachig ausgespielt)
  # Seite 6: BFI Persönlichkeitsitems (Gruppe 1)
  list(
    id = "page6",
    type = "items",
    title = "",
    title_en = "",
    instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
    instructions_en = "Please indicate to what extent the following statements apply to you.",
    item_indices = 1:5,
    scale_type = "likert",
    required = FALSE
  ),
  # Seite 7: BFI Persönlichkeitsitems (Gruppe 2) 
  list(
    id = "page7",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 6:10,
    scale_type = "likert", 
    required = FALSE
  ),
  # Seite 8: BFI Persönlichkeitsitems (Gruppe 3)
  list(
    id = "page8",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 11:15,
    scale_type = "likert",
    required = FALSE
  ),
  # Seite 9: BFI Persönlichkeitsitems (Gruppe 4)
  list(
    id = "page9", 
    type = "items",
    title = "",
    title_en = "",
    item_indices = 16:20,
    scale_type = "likert",
    required = FALSE
  ),
  # Seite 10: PSQ-Stress
  list(
    id = "page10",
    type = "items", 
    title = "",
    title_en = "",
    instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
    instructions_en = "How much do the following statements apply to you?",
    item_indices = 21:25,
    scale_type = "likert",
    required = FALSE
  ),
  # Seite 11: MWS Kontakt und Kooperation
  list(
    id = "page11",
    type = "items",
    title = "",
    title_en = "",
    instructions = "Wie leicht oder schwer fällt es Ihnen...",
    instructions_en = "How easy or difficult is it for you...",
    item_indices = 26:29,
    scale_type = "difficulty",
    required = FALSE
  ),
  # Seite 12: Statistik  
  list(
    id = "page12",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 30:31,
    scale_type = "likert",
    required = FALSE
  ),
  
  # Seite 13: Zufriedenheit und Zeiteinsatz
  list(
    id = "page13",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_7st")
  ),
  
  # Seite 14: Persönlicher Code (als demografisches Feld, damit die Sprachumschaltung klappt)
  list(
    id = "page14",
    type = "demographics", 
    title = "Persönlicher Code",
    title_en = "Personal Code",
    demographics = c("Persönlicher_Code")
  ),
  
  # Page 14a: Abfrage direkt vor der Ergebnisanzeige; hier lösen wir den Upload aus
  list(
    id = "page14a_preresults",
    type = "demographics",
    title = "Die Erhebung ist beendet",
    title_en = "Assessment complete",
    demographics = c("show_personal_results"),
    completion_handler = function(session, rv, inputs, config) {
      # Upload zur Nextcloud bevor wir die Ergebnisse zeigen
      cat("\n=== PAGE 15 (page14a_preresults) COMPLETION HANDLER TRIGGERED ===\n")
      
      # Build data object (similar to Mina study pattern)
      data <- data.frame(
        session_id = rv$session_id %||% "unknown",
        timestamp = as.character(Sys.time()),
        stringsAsFactors = FALSE
      )
      
      # Add responses (31 items total: BFI 1-20, PSQ 21-25, MWS 26-29, Stats 30-31)
      responses <- rv$responses
      if (is.null(responses)) responses <- rep(NA, 31)
      if (length(responses) < 31) responses <- c(responses, rep(NA, 31 - length(responses)))
      
      for (i in 1:31) {
        data[[paste0("item_", i)]] <- responses[i]
      }
      
      # Add demographic data
      demo_data <- rv$demo_data
      if (!is.null(demo_data) && is.list(demo_data)) {
        data$Age <- demo_data$Age %||% NA
        data$Gender <- demo_data$Gender %||% NA
        data$Studiengang <- demo_data$Studiengang %||% NA
        data$Hochschulsemester <- demo_data$Hochschulsemester %||% NA
        data$Vor_Nachbereitung <- demo_data$Vor_Nachbereitung %||% NA
        data$Zufrieden_Hi_7st <- demo_data$Zufrieden_Hi_7st %||% NA
        data$Persönlicher_Code <- demo_data$`Persönlicher_Code` %||% NA
        data$show_personal_results <- demo_data$show_personal_results %||% NA
      }
      
      # Call save_to_cloud function
      timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
      filename <- paste0("HilFo_results_", timestamp, "_", rv$session_id %||% "unknown", ".csv")
      
      cat("DEBUG: Calling save_to_cloud with filename:", filename, "\n")
      upload_success <- save_to_cloud(data, filename)
      
      if (upload_success) {
        cat("=== PAGE 15 UPLOAD SUCCESS ===\n\n")
        rv$immediate_upload_completed <- TRUE
      } else {
        cat("=== PAGE 15 UPLOAD FAILED ===\n\n")
      }
    }
  ),
  
  # Page 15: Results
  list(
    id = "page15",
    type = "results",
    title = "",
    title_en = "",
    results_processor = "create_hilfo_report",
    submit_data = TRUE,
    pass_demographics = TRUE,
    include_demographics = TRUE,
    save_demographics = TRUE
  )
)

# =============================================================================
# Auswertungsfunktion mit statischem Radarplot
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  tryCatch({
    cat("DEBUG: create_hilfo_report called with", length(responses), "responses\n")
    
    # Upload zur Nextcloud gleich zu Beginn der Ergebnisanzeige
    cat("\n=== TRIGGERING IMMEDIATE WebDAV UPLOAD FROM RESULTS PAGE ===\n")
    tryCatch({
      # Get session_id from multiple possible sources
      session_id <- "unknown"
      
      # Try session$userData first (might be set by framework)
      if (!is.null(session) && !is.null(session$userData)) {
        if (!is.null(session$userData$session_id)) {
          session_id <- session$userData$session_id
          cat("DEBUG: Got session_id from session$userData$session_id:", session_id, "\n")
        } else if (!is.null(session$userData$unique_session_id)) {
          session_id <- session$userData$unique_session_id
          cat("DEBUG: Got session_id from session$userData$unique_session_id:", session_id, "\n")
        }
      }
      
      # Try session$token
      if (session_id == "unknown" && !is.null(session) && !is.null(session$token)) {
        session_id <- session$token
        cat("DEBUG: Got session_id from session$token:", session_id, "\n")
      }
      
      # Try demographics (might contain session info)
      if (session_id == "unknown" && !is.null(demographics)) {
        if (is.list(demographics) && !is.null(demographics$session_id)) {
          session_id <- demographics$session_id
          cat("DEBUG: Got session_id from demographics$session_id:", session_id, "\n")
        }
      }
      
      # Generate timestamp-based fallback
      if (session_id == "unknown") {
        session_id <- paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S"))
        cat("DEBUG: Using generated session_id:", session_id, "\n")
      }
      
      cat("DEBUG: Final session_id for upload:", session_id, "\n")
      
      # Build data object matching framework CSV structure
      data <- data.frame(
        session_id = session_id,
        timestamp = as.character(Sys.time()),
        stringsAsFactors = FALSE
      )
      
      # Add demographics with proper names
      if (!is.null(demographics) && length(demographics) > 0) {
        for (demo_name in names(demographics)) {
          data[[demo_name]] <- demographics[[demo_name]]
        }
      }
      
      # Add item responses using item IDs from item_bank (NOT item_1, item_2, etc)
      upload_responses <- responses
      if (is.null(upload_responses)) upload_responses <- rep(NA, 31)
      if (length(upload_responses) < 31) upload_responses <- c(upload_responses, rep(NA, 31 - length(upload_responses)))
      
      # Use item IDs as column names (matching framework export)
      if (!is.null(item_bank) && nrow(item_bank) >= 31) {
        for (i in 1:31) {
          item_id <- as.character(item_bank$id[i])
          data[[item_id]] <- upload_responses[i]
        }
      } else {
        # Fallback if item_bank not available
        for (i in 1:31) {
          data[[paste0("item_", i)]] <- upload_responses[i]
        }
      }
      
      # Add calculated scores (matching csv_processor output)
      if (length(upload_responses) >= 20) {
        data$BFI_Extraversion <- mean(upload_responses[1:4], na.rm = TRUE)
        data$BFI_Vertraeglichkeit <- mean(upload_responses[5:8], na.rm = TRUE)
        data$BFI_Gewissenhaftigkeit <- mean(upload_responses[9:12], na.rm = TRUE)
        data$BFI_Neurotizismus <- mean(upload_responses[13:16], na.rm = TRUE)
        data$BFI_Offenheit <- mean(upload_responses[17:20], na.rm = TRUE)
      }
      if (length(upload_responses) >= 25) {
        data$PSQ_Stress <- mean(upload_responses[21:25], na.rm = TRUE)
      }
      if (length(upload_responses) >= 29) {
        data$MWS_StudySkills <- mean(upload_responses[26:29], na.rm = TRUE)
      }
      if (length(upload_responses) >= 31) {
        data$Statistics_Confidence <- mean(upload_responses[30:31], na.rm = TRUE)
      }
      
      # Upload to cloud with proper filename
      timestamp_str <- format(Sys.time(), "%Y%m%d_%H%M%S")
      filename <- paste0("HilFo_results_", timestamp_str, "_", session_id, ".csv")
      
      cat("DEBUG: Session ID:", session_id, "\n")
      cat("DEBUG: Calling save_to_cloud from results processor\n")
      upload_success <- save_to_cloud(data, filename)
      
      if (upload_success) {
        cat("=== RESULTS PAGE UPLOAD SUCCESS ===\n\n")
      } else {
        cat("=== RESULTS PAGE UPLOAD FAILED ===\n\n")
      }
    }, error = function(e) {
      cat("ERROR: Results page upload failed:", e$message, "\n")
    })
    # Abschluss des Upload-Blocks
    
    # Language detection
    current_lang <- "de"  # Default to German
    is_english <- FALSE
    
    # Falls die Session einen Sprachwechsel mitliefert, nutzen wir diesen zuerst
    if (!is.null(session) && !is.null(session$input) && !is.null(session$input$language)) {
      current_lang <- session$input$language
      cat("DEBUG: Using language from session$input$language:", current_lang, "\n")
    }
    
    # Create is_english variable AFTER all language detection
    is_english <- (current_lang == "en")
    cat("DEBUG: is_english =", is_english, "\n")
    
    if (is.null(responses) || !is.vector(responses) || length(responses) == 0) {
      if (is_english) {
        return(shiny::HTML("<p>No responses available for evaluation.</p>"))
      } else {
        return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
      }
    }
    
    # Flag vorbereiten, falls Teilnehmende explizit keine Ergebnisanzeige wünschen
    user_wants_no_results <- FALSE
    
    # Honor participant preference for showing personal results
    try({
      show_pref <- NULL
      
      # First check demographics parameter (most reliable)
      if (!is.null(demographics)) {
        if (is.list(demographics) && !is.null(demographics$show_personal_results)) {
          show_pref <- demographics$show_personal_results
        } else if (is.vector(demographics) && "show_personal_results" %in% names(demographics)) {
          show_pref <- demographics[["show_personal_results"]]  # Use [[ instead of $
        }
      }
      # Fallback to session input
      else if (!is.null(session) && !is.null(session$input) && !is.null(session$input$show_personal_results)) {
        show_pref <- session$input$show_personal_results
      } 
      # Fallback to session userData
      else if (!is.null(session) && !is.null(session$userData) && !is.null(session$userData$show_personal_results)) {
        show_pref <- session$userData$show_personal_results
      }
      
      if (!is.null(show_pref) && nzchar(as.character(show_pref))) {
        sp <- tolower(as.character(show_pref))
        if (sp %in% c("no", "n", "false", "0")) {
          user_wants_no_results <- TRUE
        }
      }
    }, silent = TRUE)
    
    # Ensure we have all 31 item responses (20 BFI + 5 PSQ + 4 MWS + 2 Stats - PA removed)
    if (is.null(responses) || length(responses) < 31) {
      if (is.null(responses)) {
        responses <- rep(NA, 31)
      } else {
        responses <- c(responses, rep(NA, 31 - length(responses)))
      }
    }
    responses <- as.numeric(responses)

    # ---- Robustness: try to recover missing inputs from session$input ----
    # Sometimes Shiny navigation or dynamic UI can cause the stored `responses`
    # vector to be incomplete/mostly NA when this report is generated. As a
    # fallback, if very few responses are present we try to read values
    # directly from session$input using the item ids from the provided
    # `item_bank` (preserves indices). This won't override already present
    # responses but helps recover values that were not written into the
    # responses vector by the framework in some edge cases.
    try({
      non_na_count <- sum(!is.na(responses))
      cat("DEBUG: responses non-NA count before session recovery:", non_na_count, "\n")

      # Only attempt recovery when most responses are missing (heuristic)
      if (!is.null(session) && !is.null(session$input) && non_na_count < 5 && !is.null(item_bank)) {
        # item_bank may be a data.frame with an 'id' column or character vector
        item_ids <- NULL
        if (is.data.frame(item_bank) && "id" %in% names(item_bank)) {
          item_ids <- as.character(item_bank$id)
        } else if (is.vector(item_bank) && length(item_bank) >= length(responses)) {
          # If item_bank is pre-built list of ids, try using it directly
          item_ids <- as.character(item_bank)
        }

        if (!is.null(item_ids)) {
          # Ensure item_ids length matches expected responses length
          L <- min(length(item_ids), length(responses))
          recovered <- 0
          for (i in seq_len(L)) {
            if (is.na(responses[i])) {
              input_name <- item_ids[i]
              # Safe lookup in session$input
              val <- NULL
              try({ val <- session$input[[input_name]] }, silent = TRUE)
              if (!is.null(val) && nzchar(as.character(val))) {
                num_val <- suppressWarnings(as.numeric(val))
                if (!is.na(num_val)) {
                  responses[i] <- num_val
                  recovered <- recovered + 1
                  cat("DEBUG: Recovered response for idx", i, "item_id", input_name, "value", num_val, "\n")
                }
              }
            }
          }
          cat("DEBUG: Recovered", recovered, "responses from session$input\n")
        }
      }
    }, silent = TRUE)
    
    # Calculate BFI scores - PROPER GROUPING BY TRAIT (now starting at index 1 after PA removal)
    # Items are ordered: E1, E2, E3, E4, V1, V2, V3, V4, G1, G2, G3, G4, N1, N2, N3, N4, O1, O2, O3, O4
    
    # Helper function: calculate mean only if enough items present
    safe_mean <- function(items, min_items = 2) {
      valid_count <- sum(!is.na(items))
      if (valid_count >= min_items) {
        return(mean(items, na.rm = TRUE))
      } else {
        return(NA)
      }
    }
    
    # BFI scores with proper reverse coding
    scores <- list(
      Extraversion = safe_mean(c(responses[1], 6-responses[2], 6-responses[3], responses[4])),
      Vertraeglichkeit = safe_mean(c(responses[5], 6-responses[6], responses[7], 6-responses[8])),
      Gewissenhaftigkeit = safe_mean(c(6-responses[9], responses[10], responses[11], 6-responses[12])),
      Neurotizismus = safe_mean(c(6-responses[13], responses[14], responses[15], 6-responses[16])),
      Offenheit = safe_mean(c(responses[17], 6-responses[18], responses[19], 6-responses[20]))
    )
    
    # PSQ Stress score (now at indices 21-25) - need at least 3 out of 5 items
    # Item 4 (index 24) is reverse coded: "I have enough time for myself"
    scores$Stress <- safe_mean(c(responses[21:23], 6-responses[24], responses[25]), min_items = 3)
    
    # MWS Studierfähigkeiten (Indices 26–29), ohne Umpolung
    scores$Studierfaehigkeiten <- safe_mean(responses[26:29], min_items = 2)
    
    # Statistik-Items (Indices 30–31), keine Umpolung
    scores$Statistik <- safe_mean(responses[30:31], min_items = 1)
    
    # Radarplot via ggradar; Score-Namen müssen konsistent bleiben
    radar_scores <- list(
      Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
      Verträglichkeit = if (is.na(scores$Vertraeglichkeit) || is.nan(scores$Vertraeglichkeit)) NA else scores$Vertraeglichkeit,
      Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
      Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
      Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit
    )
    
    tryCatch({
      # Use German or English column names based on language
      if (is_english) {
        radar_data <- data.frame(
          group = "Your Profile",
          Extraversion = radar_scores$Extraversion / 5,
          Agreeableness = radar_scores$`Verträglichkeit` / 5,
          Conscientiousness = radar_scores$Gewissenhaftigkeit / 5,
          Neuroticism = radar_scores$Neurotizismus / 5,
          Openness = radar_scores$Offenheit / 5,
          stringsAsFactors = FALSE,
          row.names = NULL
        )
      } else {
        radar_data <- data.frame(
          group = "Ihr Profil",
          Extraversion = radar_scores$Extraversion / 5,
          Verträglichkeit = radar_scores$`Verträglichkeit` / 5,
          Gewissenhaftigkeit = radar_scores$Gewissenhaftigkeit / 5,
          Neurotizismus = radar_scores$Neurotizismus / 5,
          Offenheit = radar_scores$Offenheit / 5,
          stringsAsFactors = FALSE,
          row.names = NULL
        )
      }
    }, error = function(e) {
      # Create fallback radar_data
      if (is_english) {
        radar_data <- data.frame(
          group = "Your Profile",
          Extraversion = 0.6, Agreeableness = 0.6, Conscientiousness = 0.6,
          Neuroticism = 0.6, Openness = 0.6,
          stringsAsFactors = FALSE, row.names = NULL
        )
      } else {
        radar_data <- data.frame(
          group = "Ihr Profil",
          Extraversion = 0.6, Verträglichkeit = 0.6, Gewissenhaftigkeit = 0.6,
          Neurotizismus = 0.6, Offenheit = 0.6,
          stringsAsFactors = FALSE, row.names = NULL
        )
      }
    })
    
    # Create title based on language
    radar_title <- if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)"
    
    # Check if we have enough valid data for radar plot
    non_na_count <- sum(!is.na(unlist(radar_scores)))
    skip_radar_plot <- non_na_count < 3
    
    if (skip_radar_plot) {
      radar_plot <- NULL
    } else {
      # Create radar plot with ggradar
      if (requireNamespace("ggradar", quietly = TRUE)) {
        radar_data_plot <- radar_data
        na_cols <- sapply(radar_data_plot[-1], function(x) is.na(x) || is.nan(x))
        cols_to_keep <- c(TRUE, !na_cols)
        radar_data_plot <- radar_data_plot[, cols_to_keep, drop = FALSE]
        
        if (ncol(radar_data_plot) >= 4) {
          radar_plot <- ggradar::ggradar(
            radar_data_plot,
            values.radar = c("1", "3", "5"),
            grid.min = 0, grid.mid = 0.6, grid.max = 1,
            grid.label.size = 5, axis.label.size = 5,
            group.point.size = 4, group.line.width = 1.5,
            background.circle.colour = "white",
            gridline.min.colour = "gray90",
            gridline.mid.colour = "gray80",
            gridline.max.colour = "gray70",
            group.colours = c("#e8041c"),
            plot.extent.x.sf = 1.3, plot.extent.y.sf = 1.2,
            legend.position = "none"
          ) +
            ggplot2::theme(
              plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, 
                                                 color = "#e8041c", margin = ggplot2::margin(b = 20)),
              plot.background = ggplot2::element_rect(fill = "white", color = NA),
              plot.margin = ggplot2::margin(20, 20, 20, 20)
            ) +
            ggplot2::labs(title = radar_title)
        } else {
          radar_plot <- NULL
        }
      } else {
        radar_plot <- NULL
      }
    }
    
    # Balkendiagramm mit passender Reihenfolge; Score-Namen konsequent halten
    if (is_english) {
      ordered_scores <- list(
        Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
        Agreeableness = if (is.na(scores$Vertraeglichkeit) || is.nan(scores$Vertraeglichkeit)) NA else scores$Vertraeglichkeit,
        Conscientiousness = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
        Neuroticism = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
        Openness = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit,
        Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) NA else scores$Stress,
        StudySkills = if (is.na(scores$Studierfaehigkeiten) || is.nan(scores$Studierfaehigkeiten)) NA else scores$Studierfaehigkeiten,
        Statistics = if (is.na(scores$Statistik) || is.nan(scores$Statistik)) NA else scores$Statistik
      )
    } else {
      ordered_scores <- list(
        Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
        Verträglichkeit = if (is.na(scores$Vertraeglichkeit) || is.nan(scores$Vertraeglichkeit)) NA else scores$Vertraeglichkeit,
        Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
        Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
        Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit,
        Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) NA else scores$Stress,
        Studierfähigkeiten = if (is.na(scores$Studierfaehigkeiten) || is.nan(scores$Studierfaehigkeiten)) NA else scores$Studierfaehigkeiten,
        Statistik = if (is.na(scores$Statistik) || is.nan(scores$Statistik)) NA else scores$Statistik
      )
    }
    
    # Create dimension names and bar chart
    if (is_english) {
      dimension_names_en <- c(
        "Extraversion" = "Extraversion",
        "Agreeableness" = "Agreeableness", 
        "Conscientiousness" = "Conscientiousness",
        "Neuroticism" = "Neuroticism",
        "Openness" = "Openness",
        "Stress" = "Stress",
        "StudySkills" = "Study Skills",
        "Statistics" = "Statistics"
      )
    } else {
      dimension_names_en <- c(
        "Extraversion" = "Extraversion",
        "Verträglichkeit" = "Verträglichkeit", 
        "Gewissenhaftigkeit" = "Gewissenhaftigkeit",
        "Neurotizismus" = "Neurotizismus",
        "Offenheit" = "Offenheit",
        "Stress" = "Stress",
        "Studierfähigkeiten" = "Studierfähigkeiten",
        "Statistik" = "Statistik"
      )
    }
    
    # Use English names if current language is English
    if (is_english) {
      dimension_labels <- dimension_names_en[names(ordered_scores)]
      category_labels <- c(rep("Personality", 5), "Stress", "Study Skills", "Statistics")
    } else {
      dimension_labels <- dimension_names_en[names(ordered_scores)]
      category_labels <- c(rep("Persönlichkeit", 5), "Stress", "Studierfähigkeiten", "Statistik")
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
      all_data <- all_data[!is.na(all_data$score), ]
    }, error = function(e) {
      all_data <- data.frame(
        dimension = factor("Extraversion"),
        score = 3,
        category = factor(if (is_english) "Personality" else "Persönlichkeit"),
        stringsAsFactors = FALSE,
        row.names = NULL
      )
    })
    
    # Create color scale based on language
    if (is_english) {
      color_scale <- ggplot2::scale_fill_manual(values = c(
        "Personality" = "#e8041c",
        "Stress" = "#ff6b6b",
        "Study Skills" = "#4ecdc4",
        "Statistics" = "#9b59b6"
      ))
    } else {
      color_scale <- ggplot2::scale_fill_manual(values = c(
        "Persönlichkeit" = "#e8041c",
        "Stress" = "#ff6b6b",
        "Studierfähigkeiten" = "#4ecdc4",
        "Statistik" = "#9b59b6"
      ))
    }
    
    bar_plot <- ggplot2::ggplot(all_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
      ggplot2::geom_bar(stat = "identity", width = 0.7) +
      ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), 
                         vjust = -0.5, size = 6, fontface = "bold", color = "#333") +
      color_scale +
      ggplot2::scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
      ggplot2::theme_minimal(base_size = 14) +
      ggplot2::theme(
        axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 12, face = "bold"),
        axis.text.y = ggplot2::element_text(size = 12),
        axis.title.x = ggplot2::element_blank(),
        axis.title.y = ggplot2::element_text(size = 14, face = "bold"),
        plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, color = "#e8041c", margin = ggplot2::margin(b = 20)),
        panel.grid.major.x = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        panel.grid.major.y = ggplot2::element_line(color = "gray90", linewidth = 0.3),
        legend.position = "bottom",
        legend.title = ggplot2::element_blank(),
        legend.text = ggplot2::element_text(size = 12),
        plot.margin = ggplot2::margin(20, 20, 20, 20)
      )
    
    # Create bar plot labels
    bar_title <- if (is_english) "All Dimensions Overview" else "Alle Dimensionen im Überblick"
    bar_y_label <- if (is_english) "Score (1-5)" else "Punktzahl (1-5)"
    
    bar_plot <- bar_plot + ggplot2::labs(title = bar_title, y = bar_y_label)
    
    # Save plots
    radar_file <- NULL
    bar_file <- tempfile(fileext = ".png")
    
    suppressMessages({
      if (!is.null(radar_plot)) {
        radar_file <- tempfile(fileext = ".png")
        ggplot2::ggsave(radar_file, radar_plot, width = 10, height = 9, dpi = 150, bg = "white")
      }
      ggplot2::ggsave(bar_file, bar_plot, width = 12, height = 7, dpi = 150, bg = "white")
    })
    
    # Encode as base64
    radar_base64 <- ""
    bar_base64 <- ""
    if (requireNamespace("base64enc", quietly = TRUE)) {
      if (!is.null(radar_file)) {
        radar_base64 <- base64enc::base64encode(radar_file)
      }
      bar_base64 <- base64enc::base64encode(bar_file)
    }
    
    # Clean up temp files
    files_to_unlink <- c(bar_file)
    if (!is.null(radar_file)) files_to_unlink <- c(files_to_unlink, radar_file)
    unlink(files_to_unlink)
    
    # Generate HTML report with download button
    html <- paste0(
      '<style>',
      '.page-title, .study-title, h1:first-child, .results-title { display: none !important; }',
      '</style>',
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
      '</tr>'
    )
    
    # Standardabweichungen je Dimension (gleich benannte Einträge wie in den Scores)
    sds <- list()
    
    # BFI dimensions - each has 4 items (with reverse scoring applied)
    bfi_dims <- list(
      Extraversion = c(responses[1], 6-responses[2], 6-responses[3], responses[4]),
      Vertraeglichkeit = c(responses[5], 6-responses[6], responses[7], 6-responses[8]),
      Gewissenhaftigkeit = c(6-responses[9], responses[10], responses[11], 6-responses[12]),
      Neurotizismus = c(6-responses[13], responses[14], responses[15], 6-responses[16]),
      Offenheit = c(responses[17], 6-responses[18], responses[19], 6-responses[20])
    )
    
    for (dim_name in names(bfi_dims)) {
      items_for_sd <- bfi_dims[[dim_name]]
      valid_items <- items_for_sd[!is.na(items_for_sd)]
      if (length(valid_items) >= 2) {  # Need at least 2 items for SD
        sd_val <- sd(valid_items, na.rm = TRUE)
        sds[[dim_name]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
      } else {
        sds[[dim_name]] <- NA
      }
    }
    
    # PSQ Stress - 5 items (with reverse scoring for item 4)
    psq_items <- c(responses[21:23], 6-responses[24], responses[25])
    valid_psq <- psq_items[!is.na(psq_items)]
    if (length(valid_psq) >= 2) {
      sd_val <- sd(valid_psq, na.rm = TRUE)
      sds[["Stress"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Stress"]] <- NA
    }
    
    # MWS Studierfähigkeiten – 4 Items (26–29), ohne Umpolung
    mws_items <- responses[26:29]
    valid_mws <- mws_items[!is.na(mws_items)]
    if (length(valid_mws) >= 2) {
      sd_val <- sd(valid_mws, na.rm = TRUE)
      sds[["Studierfaehigkeiten"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Studierfaehigkeiten"]] <- NA
    }
    
    # Statistik - 2 items (items 30-31)
    stat_items <- responses[30:31]
    valid_stat <- stat_items[!is.na(stat_items)]
    if (length(valid_stat) >= 2) {
      sd_val <- sd(valid_stat, na.rm = TRUE)
      sds[["Statistik"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Statistik"]] <- NA
    }
    
    # Werte in die Tabelle schreiben; Namen müssen zu den Score-Schlüsseln passen
    dimension_data <- list(
      "Extraversion" = list(label = "Extraversion", score_key = "Extraversion", sd_key = "Extraversion"),
      "Vertraeglichkeit" = list(label = "Verträglichkeit", score_key = "Vertraeglichkeit", sd_key = "Vertraeglichkeit"), 
      "Gewissenhaftigkeit" = list(label = "Gewissenhaftigkeit", score_key = "Gewissenhaftigkeit", sd_key = "Gewissenhaftigkeit"),
      "Neurotizismus" = list(label = "Neurotizismus", score_key = "Neurotizismus", sd_key = "Neurotizismus"),
      "Offenheit" = list(label = "Offenheit", score_key = "Offenheit", sd_key = "Offenheit"),
      "Stress" = list(label = "Stress", score_key = "Stress", sd_key = "Stress"),
      "Studierfaehigkeiten" = list(label = "Studierfähigkeiten", score_key = "Studierfaehigkeiten", sd_key = "Studierfaehigkeiten"),
      "Statistik" = list(label = "Statistik", score_key = "Statistik", sd_key = "Statistik")
    )
    
    for (dim_info in dimension_data) {
      # Get mean value
      value <- if (dim_info$score_key %in% names(scores) && !is.na(scores[[dim_info$score_key]])) {
        sprintf("%.2f", scores[[dim_info$score_key]])
      } else {
        "-"
      }
      
      # Get SD value
      sd_value <- if (dim_info$sd_key %in% names(sds) && !is.na(sds[[dim_info$sd_key]])) {
        sds[[dim_info$sd_key]]
      } else {
        "-"
      }
      
      html <- paste0(html,
        '<tr><td style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', 
        dim_info$label, 
        '</td><td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
        '<strong>', value, '</strong></td>',
        '<td style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
        ifelse(is.na(sd_value) || sd_value == "-", "-", as.character(sd_value)), '</td></tr>'
      )
    }
    
    html <- paste0(html, '</table></div>')
    
    # Close main report container
    html <- paste0(html, '</div>')
    
    # Note: WebDAV upload will be handled automatically by the inrep framework after results processor completes
    
    # Check user preference for no results (already handled above)
    if (user_wants_no_results) {
      # Note: WebDAV upload will be handled automatically by the inrep framework
      
      if (is_english) {
        return(shiny::HTML('<div style="padding: 40px; text-align: center; color: #666;"><h2>Assessment Complete</h2><p>Thank you for your participation. Your data has been saved.</p></div>'))
      } else {
        return(shiny::HTML('<div style="padding: 40px; text-align: center; color: #666;"><h2>Vielen Dank für Ihre Teilnahme!</h2><p>Ihre Daten wurden erfolgreich gespeichert.</p></div>'))
      }
    }
    
    return(shiny::HTML(html))
    
  }, error = function(e) {
    cat("ERROR in create_hilfo_report:", e$message, "\n")
    return(shiny::HTML('<div style="padding: 20px; color: red;"><h2>Fehler beim Generieren des Berichts</h2><p>Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.</p></div>'))
  })
}

# =============================================================================
# CSV-Auswertung ohne Programming-Anxiety-Anteil
# =============================================================================

process_hilfo_csv <- function(csv_data, responses, demographics, item_bank) {
  cat("DEBUG: process_hilfo_csv called with", length(responses), "responses\n")
  
  tryCatch({
    # Simplified CSV processing - no PA items, just BFI, PSQ, MWS, Statistics
    if (is.null(responses) || length(responses) == 0) {
      cat("WARNING: No responses provided to process_hilfo_csv\n")
      return(csv_data)
    }
    
    # Ensure we have enough responses for all items (31 total)
    if (length(responses) < 31) {
      responses <- c(responses, rep(NA, 31 - length(responses)))
    }
    
    # Calculate BFI scores (items 1-20)
    if (length(responses) >= 20) {
      # Extraversion (items 1-4)
      csv_data$BFI_Extraversion <- mean(responses[1:4], na.rm = TRUE)
      # Agreeableness (items 5-8)
      csv_data$BFI_Agreeableness <- mean(responses[5:8], na.rm = TRUE)
      # Conscientiousness (items 9-12)
      csv_data$BFI_Conscientiousness <- mean(responses[9:12], na.rm = TRUE)
      # Neuroticism (items 13-16)
      csv_data$BFI_Neuroticism <- mean(responses[13:16], na.rm = TRUE)
      # Openness (items 17-20)
      csv_data$BFI_Openness <- mean(responses[17:20], na.rm = TRUE)
    }
    
    # Calculate PSQ Stress (items 21-25)
    if (length(responses) >= 25) {
      csv_data$PSQ_Stress <- mean(responses[21:25], na.rm = TRUE)
    }
    
    # Calculate MWS Study Skills (items 26-29)
    if (length(responses) >= 29) {
      csv_data$MWS_StudySkills <- mean(responses[26:29], na.rm = TRUE)
    }
    
    # Calculate Statistics Confidence (items 30-31)
    if (length(responses) >= 31) {
      csv_data$Statistics_Confidence <- mean(responses[30:31], na.rm = TRUE)
    }
    
    cat("DEBUG: Successfully processed CSV data\n")
    return(csv_data)
    
  }, error = function(e) {
    cat("ERROR in process_hilfo_csv:", e$message, "\n")
    return(csv_data)
  })
}

# =============================================================================
# Studienkonfiguration für die feste (nicht-adaptive) Version
# =============================================================================

# Globale Session-Referenzen sind bereinigt; ab hier folgt nur noch die Studienkonfiguration.

# Session-Kennung für die aktuelle HilFo-Ausspielung
session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# =============================================================================

# Der Programming-Anxiety-Teil ist entfernt, wir laufen mit einer festen Liste von 31 Items.

# =============================================================================
# CSV-Auswertung: HilFo-spezifische Kennwerte ergänzen
# =============================================================================
process_hilfo_csv <- function(csv_data, responses, demographics, item_bank) {
  cat("DEBUG: process_hilfo_csv called with", length(responses), "responses\n")
  
  # Calculate BFI scores (items 1-20)
  if (length(responses) >= 20) {
    # Extraversion (items 1-4)
    csv_data$BFI_Extraversion <- mean(responses[1:4], na.rm = TRUE)
    # Verträglichkeit (items 5-8)  
    csv_data$BFI_Vertraeglichkeit <- mean(responses[5:8], na.rm = TRUE)
    # Gewissenhaftigkeit (items 9-12)
    csv_data$BFI_Gewissenhaftigkeit <- mean(responses[9:12], na.rm = TRUE)
    # Neurotizismus (items 13-16)
    csv_data$BFI_Neurotizismus <- mean(responses[13:16], na.rm = TRUE)
    # Offenheit (items 17-20)
    csv_data$BFI_Offenheit <- mean(responses[17:20], na.rm = TRUE)
  }
  
  # Calculate PSQ Stress (items 21-25)
  if (length(responses) >= 25) {
    csv_data$PSQ_Stress <- mean(responses[21:25], na.rm = TRUE)
  }
  
  # Calculate MWS Study Skills (items 26-29)
  if (length(responses) >= 29) {
    csv_data$MWS_StudySkills <- mean(responses[26:29], na.rm = TRUE)
  }
  
  # Calculate Statistics Confidence (items 30-31)
  if (length(responses) >= 31) {
    csv_data$Statistics_Confidence <- mean(responses[30:31], na.rm = TRUE)
  }
  
  cat("DEBUG: Successfully processed CSV data\n")
  return(csv_data)
}

# =============================================================================
# Konfiguration an das Framework übergeben
# =============================================================================

study_config <- inrep::create_study_config(
  name = "HilFo - Hildesheimer Forschungsmethoden",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "2PL",
  adaptive = FALSE,  # Simplified study - no adaptive testing
  max_items = 31,  # 20 BFI + 5 PSQ + 4 MWS + 2 Stats (PA items removed)
  min_items = 31,
  criteria = "MFI",
  response_ui_type = "radio",
  progress_style = "bar",
  language = "de",
  bilingual = TRUE,
  session_save = TRUE,
  session_timeout = 7200,
  results_processor = create_hilfo_report,
  csv_processor = process_hilfo_csv
)

# Studie starten
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,
  webdav_url = WEBDAV_URL,
  password = WEBDAV_PASSWORD,
  save_format = "csv",
  debug_mode = TRUE  # Enable debug mode: STRG+A = fill page, STRG+Q = auto-fill all
)
