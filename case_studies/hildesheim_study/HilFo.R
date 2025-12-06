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
attach_finish_early_observer <- function(session) {
  if (is.null(session)) return(invisible(NULL))
  tryCatch({
    session$onFlushed(function() {
      shiny::observeEvent(session$input$finish_early, {
        tryCatch({
          shiny::stopApp()
        }, error = function(e) {
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

if (!requireNamespace("inrep", quietly = TRUE)) {
  stop("Package 'inrep' is required. Please install it.")
}

# ============================================================================
# HELPER FUNCTION: Create dummy variables for multiple choice responses
# ============================================================================
create_dummy_variables <- function(response_values, all_options, prefix) {
  dummy_vars <- list()
  
  if (is.null(response_values) || length(response_values) == 0 || all(is.na(response_values))) {
    for (opt_name in names(all_options)) {
      dummy_vars[[paste0(prefix, "_", opt_name)]] <- 0L
    }
    return(dummy_vars)
  }
  
  response_values <- as.character(response_values)
  
  for (opt_name in names(all_options)) {
    opt_value <- as.character(all_options[[opt_name]])
    dummy_vars[[paste0(prefix, "_", opt_name)]] <- as.integer(opt_value %in% response_values)
  }
  
  return(dummy_vars)
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
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
# For safety, read credentials from environment variables. If not set, upload will be attempted
# anonymously which works for truly public shares. Do NOT keep secrets in the script.
WEBDAV_PASSWORD <- Sys.getenv("HILFO_WEBDAV_PASSWORD", unset = "inreptest")
WEBDAV_SHARE_TOKEN <- Sys.getenv("HILFO_WEBDAV_SHARE_TOKEN", unset = "Y51QPXzJVLWSAcb")

# =============================================================================
# Upload nach WebDAV
# =============================================================================
save_to_cloud <- function(data, filename) {
  csv_text <- paste(capture.output(write.csv(data, row.names = FALSE)), collapse = "\n")
  
  webdav_url_converted <- gsub("index.php/s/([^/]+).*", "public.php/webdav/", WEBDAV_URL)
  full_url <- paste0(webdav_url_converted, filename)
  
  # Minimal debug output to avoid leaking credentials
  message("\n=== WebDAV Upload Debug (credentials masked) ===")
  message("Original URL: ", WEBDAV_URL)
  message("Converted URL: ", webdav_url_converted)
  message("Full upload URL: ", full_url)
  message("Filename: ", filename)
  message("Share token set: ", if (nzchar(WEBDAV_SHARE_TOKEN)) "YES" else "NO")
  message("===========================\n")
  
  tryCatch({
    # Build PUT args dynamically - only include authentication when credentials are provided
    args <- list(
      url = full_url,
      body = csv_text,
      httr::content_type("text/csv"),
      encode = "raw"
    )
    if (nzchar(WEBDAV_SHARE_TOKEN) || nzchar(WEBDAV_PASSWORD)) {
      args <- c(
        args,
        list(
          httr::authenticate(
            user = WEBDAV_SHARE_TOKEN,
            password = WEBDAV_PASSWORD,
            type = "basic"
          )
        )
      )
    }

    response <- do.call(httr::PUT, args)
    
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

all_items_de <- data.frame(
  id = c(
    "BFE_01", "BFE_02", "BFE_03", "BFE_04",
    "BFV_01", "BFV_02", "BFV_03", "BFV_04",
    "BFG_01", "BFG_02", "BFG_03", "BFG_04",
    "BFN_01", "BFN_02", "BFN_03", "BFN_04",
    "BFO_01", "BFO_02", "BFO_03", "BFO_04",
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK"
  ),
  Question = c(
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
    "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
    "Ich habe zuviel zu tun.",
    "Ich fühle mich gehetzt.",
    "Ich habe genug Zeit für mich.",
    "Ich fühle mich unter Termindruck.",
    "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
    "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
    "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
    "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)"
  ),
  ResponseCategories = rep("1,2,3,4,5", 29),
  b = rep(0, 29),
  a = rep(1, 29),
  stringsAsFactors = FALSE
)

get_items_for_language <- function(lang = "de") {
  items <- all_items_de
  if (lang == "en" && "Question_EN" %in% names(items)) {
    items$Question <- items$Question_EN
  }
  return(items)
}

all_items <- all_items_de

# =============================================================================
# Vollständige demografische Sektion
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
      "Anders"="other"
    ),
    options_en = c(
      "With my parents/parent"="1",
      "In a shared apartment/dorm"="2",
      "Alone/in a self-contained unit in a dorm"="3",
      "With my partner (with or without children)"="4",
      "Other"="other"
    ),
    allow_other_text = TRUE,
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
      "Sonstiges"="other"
    ),
    options_en = c(
      "Dog"="1",
      "Cat"="2",
      "Fish"="3",
      "Bird"="4",
      "Rodent"="5",
      "Reptile"="6",
      "I don't want a pet"="7",
      "Other"="other"
    ),
    allow_other_text = TRUE,
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
      "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere"="other"
    ),
    options_en = c(
      "Vegan"="1", "Vegetarian"="2", "Pescetarian"="7",
      "Flexitarian"="4", "Omnivore (everything)"="5", "Other"="other"
    ),
    allow_other_text = TRUE,
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
    question = "Bitte erstellen Sie einen persönlichen Code",
    question_en = "Please create a personal code",
    type = "text",
    required = FALSE,
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
  ),
  Statistik_gutfolgen = list(
    question = "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
    question_en = "So far I have been able to follow the content of the statistics courses well.",
    type = "slider",
    min = 0,
    max = 100,
    step = 1,
    default = NULL,
    label_min = "stimme gar nicht zu",
    label_min_en = "strongly disagree",
    label_max = "stimme voll zu",
    label_max_en = "strongly agree",
    required = FALSE
  ),
  Statistik_selbstwirksam = list(
    question = "Ich bin in der Lage, Statistik zu erlernen.",
    question_en = "I am able to learn statistics.",
    type = "slider",
    min = 0,
    max = 100,
    step = 1,
    default = NULL,
    label_min = "stimme gar nicht zu",
    label_min_en = "strongly disagree",
    label_max = "stimme voll zu",
    label_max_en = "strongly agree",
    required = FALSE
  )
)

input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Haustier = "checkbox",
  Rauchen = "radio",
  Ernährung = "radio",
  Note_Englisch = "select",
  Note_Mathe = "select",
  Vor_Nachbereitung = "radio",
  Zufrieden_Hi_7st = "radio",
  Persönlicher_Code = "text",
  show_personal_results = "radio",
  Statistik_gutfolgen = "slider",
  Statistik_selbstwirksam = "slider"
)

# =============================================================================
# Ablauf der Seiten im HilFo-Fragebogen
# =============================================================================

custom_page_flow <- list(
  list(
    id = "page1",
    type = "custom",
    title = "HilFo",
    content = '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">
        <button type="button" id="language-toggle-btn" onclick="toggleLanguage()" style="background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text">English Version</span></button>
        <div id="de-content">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">Willkommen zur HilFo Studie</h1>
        <h2 style="color: #e8041c;">Liebe Studierende,</h2>
        <p>In den Seminaren zu den statistischen Verfahren wollen wir mit Daten arbeiten, die von Ihnen selbst stammen. Deswegen bitten wir Sie an der nachfolgenden Befragung teilzunehmen.</p>
        <p>Da wir die Anwendung verschiedene Auswertungsverfahren ermöglichen wollen, deckt der Fragebogen verschiedene Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;"><strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im Bachelor generiert und in diesem Jahrgang, möglicherweise auch in späteren Jahrgängen genutzt.</p>
        <p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.</p>
        <p style="margin-top: 20px;"><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;"><strong>Hinweis:</strong> Die Teilnahme ist nur möglich, wenn Sie der Einverständniserklärung zustimmen.</p>
          </div>
        </div>
        </div>
        <div id="en-content" style="display: none;">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">Welcome to the HilFo Study</h1>
        <h2 style="color: #e8041c;">Dear Students,</h2>
        <p>In the seminars on statistical procedures, we want to work with data that comes from you. Therefore, we ask you to participate in the following survey.</p>
        <p>Since we want to enable the application of various analysis procedures, the questionnaire covers different topic areas that are partially independent of each other.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;"><strong>Your information is completely anonymous</strong>, there will be no personal evaluation of the data. The data is generated by first-semester psychology bachelor students and used in this cohort, possibly also in later cohorts.</p>
        <p>In the following, you will be presented with statements. We ask you to indicate to what extent you agree with them. There are no wrong or right answers. Please answer the questions as they best reflect your opinion.</p>
        <p style="margin-top: 20px;"><strong>The survey takes about 10-15 minutes.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>I agree to participate in the survey</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;"><strong>Note:</strong> Participation is only possible if you agree to the declaration of consent.</p>
          </div>
        </div>
        </div>
    </div>
    <script>
    function toggleLanguage() {
      var deContent = document.getElementById("de-content");
      var enContent = document.getElementById("en-content");
      var textSpan = document.getElementById("lang_switch_text");
      var deCheck = document.getElementById("consent_check");
      var enCheck = document.getElementById("consent_check_en");
      try {
        var prevLang = sessionStorage.getItem("hilfo_global_language") || sessionStorage.getItem("current_language");
        if (deContent.style.display === "none") {
          deContent.style.display = "block";
          enContent.style.display = "none";
          if (textSpan) textSpan.textContent = "English Version";
          sessionStorage.setItem("hilfo_global_language", "de");
          sessionStorage.setItem("global_language_preference", "de");
          if (typeof Shiny !== "undefined" && prevLang !== "de") {
            Shiny.setInputValue("store_language_globally", "de", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "de");
          sessionStorage.setItem("current_language", "de");
          sessionStorage.setItem("hilfo_language_preference", "de");
        } else {
          deContent.style.display = "none";
          enContent.style.display = "block";
          if (textSpan) textSpan.textContent = "Deutsche Version";
          sessionStorage.setItem("hilfo_global_language", "en");
          sessionStorage.setItem("global_language_preference", "en");
          if (typeof Shiny !== "undefined" && prevLang !== "en") {
            Shiny.setInputValue("store_language_globally", "en", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "en");
          sessionStorage.setItem("current_language", "en");
          sessionStorage.setItem("hilfo_language_preference", "en");
        }
      } catch (e) {
  console.warn("toggleLanguage error", e && e.message);
      }
      
      if (deContent.style.display === "none") {
        enCheck.checked = deCheck.checked;
      } else {
        deCheck.checked = enCheck.checked;
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
    
    document.addEventListener("DOMContentLoaded", function() {
      var savedLang = sessionStorage.getItem("hilfo_global_language") || 
                     sessionStorage.getItem("global_language_preference") || 
                     sessionStorage.getItem("current_language") || "de";
    });
    </script>',
    validate = "function(inputs) { 
        var deCheck = document.getElementById('consent_check');
        var enCheck = document.getElementById('consent_check_en');
        if ((deCheck && deCheck.checked) || (enCheck && enCheck.checked)) {
          return true;
        }
        return false;
    }",
    required = FALSE
  ),
  
  list(
    id = "page2",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Alter_VPN", "Geschlecht")
  ),
  
  list(
    id = "page3",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Wohnstatus"),
    custom_css = '
      .other-text-wrapper {
        margin-bottom: 20px;
      }
      .other-text-label {
        margin-top: 15px !important;
      }
      .other-text-input {
        margin-top: 15px !important;
        padding: 10px !important;
        border: 1px solid #ced4da !important;
        border-radius: 6px !important;
        font-size: 15px !important;
        width: 100% !important;
        max-width: 500px !important;
        background: #ffffff !important;
      }
      .other-text-input:focus {
        outline: none !important;
        border-color: #e8041c !important;
        box-shadow: 0 0 0 3px rgba(232, 4, 28, 0.15) !important;
      }
      .other-text-input::placeholder {
        font-weight: 600 !important;
        color: #333 !important;
        margin-top: 10px !important;
        display: block !important;
      }
    ',
    completion_handler = function(session, rv, inputs, config) {
      if (!is.list(rv$demo_data)) {
        rv$demo_data <- as.list(rv$demo_data)
      }
      
      if (!is.null(inputs$demo_Wohnstatus_other) && inputs$demo_Wohnstatus_other != "") {
        rv$demo_data$Wohn_Zusatz <- inputs$demo_Wohnstatus_other
        rv$demo_data$demo_Wohnstatus_other <- inputs$demo_Wohnstatus_other
      }
    }
  ),
  
  list(
    id = "page4",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Haustier", "Rauchen", "Ernährung"),
    custom_css = '
      .other-text-wrapper {
        margin-bottom: 20px;
      }
      .other-text-label {
        margin-top: 15px !important;
      }
      .other-text-input {
        margin-top: 15px !important;
        padding: 10px !important;
        border: 1px solid #ced4da !important;
        border-radius: 6px !important;
        font-size: 15px !important;
        width: 100% !important;
        max-width: 500px !important;
        background: #ffffff !important;
      }
      .other-text-input:focus {
        outline: none !important;
        border-color: #e8041c !important;
        box-shadow: 0 0 0 3px rgba(232, 4, 28, 0.15) !important;
      }
      .checkbox-option {
        margin-bottom: 10px;
      }
    ',
    completion_handler = function(session, rv, inputs, config) {
      if (!is.list(rv$demo_data)) {
        rv$demo_data <- as.list(rv$demo_data)
      }
      
      if (!is.null(inputs$demo_Haustier_other) && inputs$demo_Haustier_other != "") {
        rv$demo_data$Haustier_Zusatz <- inputs$demo_Haustier_other
        rv$demo_data$demo_Haustier_other <- inputs$demo_Haustier_other
      }
      if (!is.null(inputs$demo_Ernährung_other) && inputs$demo_Ernährung_other != "") {
        rv$demo_data$Ernährung_Zusatz <- inputs$demo_Ernährung_other
        rv$demo_data$demo_Ernährung_other <- inputs$demo_Ernährung_other
      }
    }
  ),
  
  list(
    id = "page5",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Note_Englisch", "Note_Mathe")
  ),
  
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
  
  list(
    id = "page7",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 6:10,
    scale_type = "likert", 
    required = FALSE
  ),
  
  list(
    id = "page8",
    type = "items",
    title = "",
    title_en = "",
    item_indices = 11:15,
    scale_type = "likert",
    required = FALSE
  ),
  
  list(
    id = "page9", 
    type = "items",
    title = "",
    title_en = "",
    item_indices = 16:20,
    scale_type = "likert",
    required = FALSE
  ),
  
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
  
  list(
    id = "page12",
    type = "demographics",
    title = "",
    title_en = "",
    description = "Bewegen Sie den Regler, um Ihre Zustimmung anzugeben (0% = stimme gar nicht zu, 100% = stimme voll zu).",
    description_en = "Move the slider to indicate your agreement (0% = strongly disagree, 100% = strongly agree).",
    demographics = c("Statistik_gutfolgen", "Statistik_selbstwirksam"),
    completion_handler = function(session, rv, inputs, config) {
      cat("\n=== PAGE 12 COMPLETION HANDLER ===\n")
      
      stat1_value <- suppressWarnings(as.numeric(inputs$demo_Statistik_gutfolgen))
      stat2_value <- suppressWarnings(as.numeric(inputs$demo_Statistik_selbstwirksam))
      
      cat("Raw slider values: stat1=", stat1_value, " stat2=", stat2_value, "\n")
      
      if (!is.na(stat1_value)) {
        rv$demo_data$Statistik_gutfolgen <- stat1_value
      }
      if (!is.na(stat2_value)) {
        rv$demo_data$Statistik_selbstwirksam <- stat2_value
      }
      
      cat(">>> Statistik_gutfolgen saved:", stat1_value, "\n")
      cat(">>> Statistik_selbstwirksam saved:", stat2_value, "\n")
    },
    custom_css = '
      .slider-description {
        font-size: 15px;
        color: #666;
        margin-bottom: 35px;
        text-align: center;
      }
      .demographic-field {
        margin: 0 auto 50px auto;
        padding: 25px;
        background: white;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        max-width: 650px;
      }
      .demographic-field label {
        font-size: 16px;
        font-weight: 600;
        color: #333;
        margin-bottom: 30px;
        display: block;
        text-align: center;
      }
      .irs-hidden-input {
        display: none !important;
      }
      .irs {
        height: 90px !important;
        margin: 30px 0 !important;
        position: relative !important;
        touch-action: pan-x !important;
      }
      .irs-line {
        position: absolute !important;
        top: 50% !important;
        left: 0 !important;
        right: 0 !important;
        height: 12px !important;
        background: #e0e0e0 !important;
        border-radius: 6px !important;
        border: none !important;
        transform: translateY(-50%) !important;
        cursor: pointer !important;
        z-index: 1 !important;
      }
      .irs-bar {
        position: absolute !important;
        top: 50% !important;
        left: 0 !important;
        right: auto !important;
        height: 12px !important;
        transform: translateY(-50%) !important;
        transform-origin: left center !important;
        border-radius: 6px !important;
        border: none !important;
        background: linear-gradient(to right, #ffcdd2 0%, #e8041c 100%) !important;
        pointer-events: auto !important;
        z-index: 2 !important;
      }
      .irs-bar-edge {
        pointer-events: auto !important;
      }
      .irs-handle {
        position: absolute !important;
        width: 140px !important;
        height: 140px !important;
        top: 50% !important;
        transform: translate(-50%, -50%) !important;
        transform-origin: center center !important;
        background: #ffffff !important;
        border: 6px solid #e8041c !important;
        box-shadow: 0 10px 26px rgba(232, 4, 28, 0.35) !important;
        border-radius: 50% !important;
        cursor: grab !important;
        z-index: 100 !important;
        touch-action: pan-x !important;
        pointer-events: auto !important;
      }
      .irs-handle::after {
        content: "" !important;
        display: none !important;
      }
      .irs-from, .irs-to {
        display: none !important;
      }
      .irs-min, .irs-max {
        padding: 5px 0 !important;
        font-size: 13px !important;
        color: #666 !important;
      }
      .irs-grid {
        padding-left: 0 !important;
        padding-right: 0 !important;
      }
      .irs-grid-pol {
        left: 0 !important;
        right: 0 !important;
        width: 100% !important;
      }
      .irs-handle:hover {
        box-shadow: 0 8px 20px rgba(232, 4, 28, 0.55) !important;
      }
      .irs-handle:active {
        cursor: grabbing !important;
        box-shadow: 0 4px 12px rgba(232, 4, 28, 0.5) !important;
      }
      .irs-single {
        position: absolute !important;
        left: 0 !important;
        top: 0 !important;
        width: 140px !important;
        height: 140px !important;
        display: flex !important;
        align-items: center !important;
        justify-content: center !important;
        font-size: 34px !important;
        font-weight: 700 !important;
        color: #e8041c !important;
        background: transparent !important;
        border: none !important;
        padding: 0 !important;
        z-index: 102 !important;
        line-height: 1 !important;
        white-space: nowrap !important;
        text-align: center !important;
        pointer-events: none !important;
        visibility: visible !important;
        opacity: 1 !important;
      }
      @media (max-width: 768px) {
        .demographic-field {
          padding: 20px 15px;
        }
        .inrep-slider-wrapper .irs-handle,
        .demographic-field .irs-handle,
        .irs-handle {
          width: 125px !important;
          height: 125px !important;
        }
        .inrep-slider-wrapper .irs-single,
        .demographic-field .irs-single,
        .irs-single {
          font-size: 28px !important;
        }
        .irs {
          height: 120px !important;
        }
        .inrep-slider-wrapper .irs-line,
        .inrep-slider-wrapper .irs-bar,
        .demographic-field .irs-line,
        .demographic-field .irs-bar,
        .irs-line,
        .irs-bar {
          height: 14px !important;
        }
      }
      @media (pointer: coarse) {
        .inrep-slider-wrapper .irs-handle,
        .demographic-field .irs-handle,
        .irs-handle {
          width: 155px !important;
          height: 155px !important;
        }
        .inrep-slider-wrapper .irs-single,
        .demographic-field .irs-single,
        .irs-single {
          font-size: 32px !important;
        }
        .irs {
          height: 130px !important;
        }
        .inrep-slider-wrapper .irs-line,
        .inrep-slider-wrapper .irs-bar,
        .demographic-field .irs-line,
        .demographic-field .irs-bar,
        .irs-line,
        .irs-bar {
          height: 14px !important;
        }
      }
    ',
    custom_js = '
      var sliderTouched = {};
      var sliderInitialized = {};
      
      console.log("INIT: JavaScript code running - will block Statistik slider initial sends");
      
      var blockSliderAttempts = 0;
      var maxBlockAttempts = 10; // reduce attempts to avoid long-running loops
      var blockSent = {};
      var blockStart = Date.now();
      
      var blockSliderInitial = function() {
        blockSliderAttempts++;
        console.log("BLOCK ATTEMPT " + blockSliderAttempts + ": Looking for demo_Statistik inputs...");

        $("input[id*=demo_Statistik]").each(function() {
          var id = $(this).attr("id");
          if (!sliderTouched[id]) {
            var oldVal = $(this).val();
            $(this).val("");
            console.log("CLEARED " + id + ": was " + oldVal + ", now empty");

            // Only notify Shiny once per input to avoid flooding the server
            if (Shiny && Shiny.setInputValue && !blockSent[id]) {
              try {
                Shiny.setInputValue(id, null);
                blockSent[id] = true;
                console.log("NOTIFIED SHINY ONCE: " + id + " set to null");
              } catch (e) {
                console.warn("Failed to set input to null for", id, e && e.message);
              }
            }
          }
        });

        // Stop attempts after maxBlockAttempts or after 5 seconds
        if (blockSliderAttempts < maxBlockAttempts && (Date.now() - blockStart) < 5000) {
          setTimeout(blockSliderInitial, 100);
        } else {
          console.log("blockSliderInitial finished after", blockSliderAttempts, "attempts");
        }
      };

      blockSliderInitial();
      
      var observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.addedNodes.length) {
            mutation.addedNodes.forEach(function(node) {
              if (node.nodeType === 1) {
                var $node = $(node);
                if ($node.hasClass("js-range-slider") || $node.find(".js-range-slider").length) {
                  var $input = $node.hasClass("js-range-slider") ? $node : $node.find(".js-range-slider");
                  $input.each(function() {
                    var id = $(this).attr("id");
                    if (id && id.indexOf("Statistik") !== -1) {
                      $(this).val("");
                      console.log("CLEARED: Initial value for " + id + " cleared before Shiny binding");
                    }
                  });
                }
              }
            });
          }
        });
      });
      
      observer.observe(document.body, {childList: true, subtree: true});
      // Disconnect the observer after a short timeout to avoid long-running mutation loops
      setTimeout(function() {
        try {
          observer.disconnect();
          console.log("MutationObserver disconnected after timeout to prevent loops");
        } catch (e) {
          console.warn("Failed to disconnect observer:", e && e.message);
        }
      }, 5000);
      
      function updateSliderDisplay(sliderId, $container) {
        var $singleElement = $container.find(".irs-single");
        
        if ($singleElement.length === 0) {
          console.warn("No .irs-single found for " + sliderId);
          return;
        }
        
        if (sliderTouched[sliderId]) {
          var value = parseInt($container.find(".irs-input").val() || 50, 10);
          $singleElement.text(value + "%");
          console.log("Display updated: " + sliderId + " = " + value + "%");
        } else {
          $singleElement.text("%");
          console.log("Display updated: " + sliderId + " = % (not touched)");
        }
        
        var $handle = $container.find(".irs-handle");
        if ($handle.length > 0) {
          try {
            var handleRect = $handle[0].getBoundingClientRect();
            var containerRect = $container[0].getBoundingClientRect();
            var valueLeft = handleRect.left - containerRect.left + (handleRect.width / 2);
            var valueTop = handleRect.top - containerRect.top + (handleRect.height / 2);
            var singleHalfWidth = $singleElement.outerWidth() / 2 || 0;
            var singleHalfHeight = $singleElement.outerHeight() / 2 || 0;
            valueLeft = valueLeft - singleHalfWidth;
            valueTop = valueTop - singleHalfHeight;
            $singleElement.each(function() {
              this.style.setProperty("left", valueLeft + "px", "important");
              this.style.setProperty("top", valueTop + "px", "important");
            });
          } catch (e) {
            console.warn("Failed to align value with handle for", sliderId, e && e.message);
          }
        }
      }
      
      function ensureSliderInitialized() {
        $(".js-range-slider").each(function() {
          var $input = $(this);
          var sliderId = $input.attr("id");
          
          if (!sliderId || sliderId.indexOf("Statistik") === -1) return;
          
          if (sliderInitialized[sliderId]) return;
          sliderInitialized[sliderId] = true;
          
          var instance = $input.data("ionRangeSlider");
          if (!instance) return;
          
          var currentVal = parseInt($input.val(), 10);
          if (isNaN(currentVal)) {
            currentVal = parseInt($input.attr("data-default"), 10);
          }
          if (isNaN(currentVal)) {
            currentVal = 50;
          }
          
          var $container = $("#" + sliderId).closest(".irs");
          
          sliderTouched[sliderId] = false;
          $input.val("");
          
          instance.update({
            min: 0,
            max: 100,
            from: currentVal,
            disable: false,
            hide_min_max: true,
            hide_from_to: false,
            force_edges: false,
            prettify: function(num) {
              return "";
            },
            onStart: function(data) {
              sliderTouched[sliderId] = true;
              $container.data("touched", true);
              $container.data("was-touched", "true");
              updateSliderDisplay(sliderId, $container);
              var touchedFlagId = sliderId.replace("demo_", "") + "_touched";
              console.log(">>> ATTEMPTING Shiny.setInputValue(" + touchedFlagId + ", true)");
              Shiny.setInputValue(touchedFlagId, true);
              console.log(">>> SUCCESS: Shiny.setInputValue called for Flag: " + touchedFlagId);
              console.log("SLIDER TOUCHED (onStart): " + sliderId + " - Flag: " + touchedFlagId);
            },
            onChange: function(data) {
              sliderTouched[sliderId] = true;
              $container.data("touched", true);
              $container.data("was-touched", "true");
              
              var $singleElement = $container.find(".irs-single");
              if ($singleElement.length > 0) {
                $singleElement.text(data.from + "%");
                console.log("DIRECT UPDATE: " + sliderId + " display set to " + data.from + "%");
              }
              
              updateSliderDisplay(sliderId, $container);
              
              var touchedFlagId = sliderId.replace("demo_", "") + "_touched";
              Shiny.setInputValue(touchedFlagId, true);
              console.log("Slider " + sliderId + " changed to " + data.from + " (touched) - Flag: " + touchedFlagId);
              Shiny.setInputValue(sliderId, data.from);
              $container.find(".irs-bar").css("left", "0px");
            },
            onFinish: function(data) {
              console.log("Slider " + sliderId + " finished at " + data.from + " (touched: " + sliderTouched[sliderId] + ")");
              $container.find(".irs-bar").css("left", "0px");
            }
          });
          
          setTimeout(function() {
            var $singleElement = $container.find(".irs-single");
            if ($singleElement.length > 0) {
              $singleElement.text("%");
              updateSliderDisplay(sliderId, $container);
              console.log("SUCCESS: Initial display set to % for " + sliderId);
            } else {
              console.warn("Could not find .irs-single for " + sliderId);
            }
          }, 300);
          
          console.log("Slider " + sliderId + " initialized - NOT sending initial value to Shiny");
          
          $container.find(".irs-line").off("click").on("click", function(e) {
            var $line = $(this);
            var offset = $line.offset();
            var clickX = e.pageX - offset.left;
            var lineWidth = $line.width();
            var newValue = Math.round((clickX / lineWidth) * 100);
            newValue = Math.max(0, Math.min(100, newValue));
            
            instance.update({ from: newValue });
            Shiny.setInputValue(sliderId, newValue);
            $container.find(".irs-bar").css("left", "0px");
          });
          
          $container.find(".irs-bar").off("click").on("click", function(e) {
            var $line = $container.find(".irs-line");
            var offset = $line.offset();
            var clickX = e.pageX - offset.left;
            var lineWidth = $line.width();
            var newValue = Math.round((clickX / lineWidth) * 100);
            newValue = Math.max(0, Math.min(100, newValue));
            
            instance.update({ from: newValue });
            Shiny.setInputValue(sliderId, newValue);
            $container.find(".irs-bar").css("left", "0px");
          });
          
          $container.find(".irs-line, .irs-bar, .irs-handle").css({
            "pointer-events": "auto",
            "cursor": "pointer"
          });
          
          var $bar = $container.find(".irs-bar");
          $bar.css({
            "left": "0px"
          });
          
          if (instance.result.disabled) {
            console.log("WARNING: Slider was disabled! Force enabling...");
            instance.update({ disable: false });
          }
          
          var $handle = $container.find(".irs-handle");
          $handle.css({
            "pointer-events": "auto",
            "cursor": "grab",
            "user-select": "none",
            "-webkit-user-drag": "none",
            "touch-action": "pan-x"
          });
          
          $handle.off("mousedown touchstart");
          $container.find(".irs-line").css("pointer-events", "auto");
          $input.prop("disabled", false);
          $input.prop("readonly", false);
          
          var handlePos = $handle.offset();
          if (handlePos) {
            var elemAtPos = document.elementFromPoint(handlePos.left + 45, handlePos.top + 45);
            console.log("Element at handle position:", elemAtPos ? elemAtPos.className : "none");
          }
          
          console.log("Slider " + sliderId + " initialized:");
          console.log("  Value:", currentVal);
          console.log("  Disabled:", instance.result.disabled);
          console.log("  Handle left:", $handle.css("left"));
          console.log("  Bar left:", $bar.css("left"));
          console.log("  Bar width:", $bar.css("width"));
          console.log("  Handle pointer-events:", $handle.css("pointer-events"));
          console.log("  Input disabled:", $input.prop("disabled"));
          
          $handle.on("mousedown", function(e) {
            console.log("✓ Handle mousedown detected on", sliderId);
          });
          
          $container.find(".irs-line").on("mousedown", function(e) {
            console.log("✓ Track mousedown detected");
          });
        });
      }
      
      setTimeout(ensureSliderInitialized, 100);
      setTimeout(ensureSliderInitialized, 400);
      setTimeout(ensureSliderInitialized, 1200);
      
      $(document).on("shiny:value", function(ev) {
        if (ev.name && ev.name.indexOf("Statistik") !== -1) {
          setTimeout(function() {
            ensureSliderInitialized();
          }, 100);
        }
      });
      
      $(window).on("resize.hilfoSlider", function() {
        Object.keys(sliderInitialized).forEach(function(sliderId) {
          if (sliderInitialized[sliderId]) {
            var $container = $("#" + sliderId).closest(".irs");
            if ($container.length) {
              updateSliderDisplay(sliderId, $container);
            }
          }
        });
      });
    '
  ),
  
  list(
    id = "page13",
    type = "demographics",
    title = "",
    title_en = "",
    demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_7st")
  ),
  
  list(
    id = "page14",
    type = "demographics", 
    title = "Persönlicher Code",
    title_en = "Personal Code",
    demographics = c("Persönlicher_Code")
  ),
  
  list(
    id = "page14a_preresults",
    type = "demographics",
    title = "Fast geschafft",
    title_en = "Almost done",
    demographics = c("show_personal_results"),
    completion_handler = function(session, rv, inputs, config) {
      cat("\n=== PAGE 15 (page14a_preresults) COMPLETION HANDLER TRIGGERED ===\n")
      
      if (is.null(rv$session_id) || is.na(rv$session_id)) {
        if (!is.null(session$token)) {
          rv$session_id <- session$token
        } else if (!is.null(session$userData$session_id)) {
          rv$session_id <- session$userData$session_id
        } else {
          rv$session_id <- paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S"))
        }
      }
      
      data <- data.frame(
        session_id = rv$session_id,
        timestamp = as.character(Sys.time()),
        stringsAsFactors = FALSE
      )
      
      demo_data <- rv$demo_data
      if (!is.null(demo_data) && is.list(demo_data)) {
        data$Einverständnis <- demo_data$Einverständnis
        data$Alter_VPN <- demo_data$Alter_VPN
        data$Geschlecht <- demo_data$Geschlecht
        data$Wohnstatus <- demo_data$Wohnstatus
        data$Wohn_Zusatz <- demo_data$Wohn_Zusatz
        
        haustier_response <- demo_data$Haustier
        haustier_dummies <- create_dummy_variables(
          response_values = haustier_response,
          all_options = c(
            "Hund" = "1",
            "Katze" = "2",
            "Fisch" = "3",
            "Vogel" = "4",
            "Nager" = "5",
            "Reptil" = "6",
            "Ich_moechte_kein_Haustier" = "7"
          ),
          prefix = "Haustier"
        )
        for (dummy_name in names(haustier_dummies)) {
          data[[dummy_name]] <- haustier_dummies[[dummy_name]]
        }
        data$Haustier_Zusatz <- demo_data$Haustier_Zusatz
        data$Rauchen <- demo_data$Rauchen
        data$Ernährung <- demo_data$Ernährung
        data$Ernährung_Zusatz <- demo_data$Ernährung_Zusatz
        data$Note_Englisch <- demo_data$Note_Englisch
        data$Note_Mathe <- demo_data$Note_Mathe
        
        stat1_raw <- suppressWarnings(as.numeric(demo_data$Statistik_gutfolgen))
        stat2_raw <- suppressWarnings(as.numeric(demo_data$Statistik_selbstwirksam))
        
        cat("FINAL FILTER AT UPLOAD: stat1 =", stat1_raw, "stat2 =", stat2_raw, "\n")
        
        data$Statistik_gutfolgen <- stat1_raw
        data$Statistik_selbstwirksam <- stat2_raw
        
        data$Statistik_gutfolgen_scaled <- if (!is.na(stat1_raw)) (stat1_raw / 100) * 4 + 1 else NA
        data$Statistik_selbstwirksam_scaled <- if (!is.na(stat2_raw)) (stat2_raw / 100) * 4 + 1 else NA
        
        data$Vor_Nachbereitung <- demo_data$Vor_Nachbereitung
        data$Zufrieden_Hi_7st <- demo_data$Zufrieden_Hi_7st
        data$Persönlicher_Code <- demo_data$Persönlicher_Code
        data$show_personal_results <- demo_data$show_personal_results
      }
      
      responses <- rv$responses
      if (is.null(responses)) responses <- rep(NA, 29)
      if (length(responses) < 29) responses <- c(responses, rep(NA, 29 - length(responses)))
      
      item_ids <- c(
        "BFE_01", "BFE_02", "BFE_03", "BFE_04",
        "BFV_01", "BFV_02", "BFV_03", "BFV_04",
        "BFG_01", "BFG_02", "BFG_03", "BFG_04",
        "BFN_01", "BFN_02", "BFN_03", "BFN_04",
        "BFO_01", "BFO_02", "BFO_03", "BFO_04",
        "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
        "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK"
      )
      
      for (i in 1:29) {
        data[[item_ids[i]]] <- responses[i]
      }
      
      if (length(responses) >= 29) {
        data$BFI_Extraversion <- mean(responses[1:4], na.rm = TRUE)
        data$BFI_Vertraeglichkeit <- mean(responses[5:8], na.rm = TRUE)
        data$BFI_Gewissenhaftigkeit <- mean(responses[9:12], na.rm = TRUE)
        data$BFI_Neurotizismus <- mean(responses[13:16], na.rm = TRUE)
        data$BFI_Offenheit <- mean(responses[17:20], na.rm = TRUE)
        
        data$PSQ_Stress <- mean(responses[21:25], na.rm = TRUE)
        
        data$MWS_StudySkills <- mean(responses[26:29], na.rm = TRUE)
        
        stat_vals <- c(data$Statistik_gutfolgen_scaled, data$Statistik_selbstwirksam_scaled)
        data$Statistics_Confidence <- mean(stat_vals, na.rm = TRUE)
      }
      
      timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
      filename <- paste0("HilFo_results_", timestamp, "_", rv$session_id, ".csv")
      
      cat("DEBUG: Calling save_to_cloud with filename:", filename, "\n")
      
      upload_success <- save_to_cloud(data, filename)
      
      if (upload_success) {
        cat("=== PAGE 15 UPLOAD SUCCESS ===\n\n")
        rv$immediate_upload_completed <- TRUE
        rv$skip_results_upload <- TRUE
        rv$csv_uploaded <- TRUE
        rv$data_uploaded_to_cloud <- TRUE
        if (!is.null(session$userData)) {
          session$userData$skip_results_upload <- TRUE
          session$userData$csv_uploaded <- TRUE
          session$userData$data_uploaded_to_cloud <- TRUE
          cat("DEBUG: Set all upload flags to TRUE in session$userData and rv\n")
        }
      } else {
        cat("=== PAGE 15 UPLOAD FAILED ===\n\n")
      }
    }
  ),
  
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
    
    cat("\n=== SKIPPING UPLOAD (already done by completion handler) ===\n")
    skip_upload <- TRUE
    
    current_lang <- "de"
    is_english <- FALSE
    
    if (!is.null(session) && !is.null(session$input) && !is.null(session$input$language)) {
      current_lang <- session$input$language
      cat("DEBUG: Using language from session$input$language:", current_lang, "\n")
    }
    
    is_english <- (current_lang == "en")
    cat("DEBUG: is_english =", is_english, "\n")
    
    if (is.null(responses) || !is.vector(responses) || length(responses) == 0) {
      if (is_english) {
        return(shiny::HTML("<p>No responses available for evaluation.</p>"))
      } else {
        return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
      }
    }
    
    user_wants_no_results <- FALSE
    
    try({
      show_pref <- NULL
      
      if (!is.null(demographics)) {
        if (is.list(demographics) && !is.null(demographics$show_personal_results)) {
          show_pref <- demographics$show_personal_results
        } else if (is.vector(demographics) && "show_personal_results" %in% names(demographics)) {
          show_pref <- demographics[["show_personal_results"]]
        }
      } else if (!is.null(session) && !is.null(session$input) && !is.null(session$input$show_personal_results)) {
        show_pref <- session$input$show_personal_results
      } else if (!is.null(session) && !is.null(session$userData) && !is.null(session$userData$show_personal_results)) {
        show_pref <- session$userData$show_personal_results
      }
      
      if (!is.null(show_pref) && nzchar(as.character(show_pref))) {
        sp <- tolower(as.character(show_pref))
        if (sp %in% c("no", "n", "false", "0")) {
          user_wants_no_results <- TRUE
        }
      }
    }, silent = TRUE)
    
    if (is.null(responses) || length(responses) < 29) {
      if (is.null(responses)) {
        responses <- rep(NA, 29)
      } else {
        responses <- c(responses, rep(NA, 29 - length(responses)))
      }
    }
    responses <- as.numeric(responses)
    
    try({
      non_na_count <- sum(!is.na(responses))
      cat("DEBUG: responses non-NA count before session recovery:", non_na_count, "\n")
      
      if (!is.null(session) && !is.null(session$input) && non_na_count < 5 && !is.null(item_bank)) {
        item_ids <- NULL
        if (is.data.frame(item_bank) && "id" %in% names(item_bank)) {
          item_ids <- as.character(item_bank$id)
        } else if (is.vector(item_bank) && length(item_bank) >= length(responses)) {
          item_ids <- as.character(item_bank)
        }
        
        if (!is.null(item_ids)) {
          L <- min(length(item_ids), length(responses))
          recovered <- 0
          for (i in seq_len(L)) {
            if (is.na(responses[i])) {
              input_name <- item_ids[i]
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
    
    safe_mean <- function(items, min_items = 2) {
      valid_count <- sum(!is.na(items))
      if (valid_count >= min_items) {
        return(mean(items, na.rm = TRUE))
      } else {
        return(NA)
      }
    }
    
    scores <- list(
      Extraversion = safe_mean(c(responses[1], 6-responses[2], 6-responses[3], responses[4])),
      Vertraeglichkeit = safe_mean(c(responses[5], 6-responses[6], responses[7], 6-responses[8])),
      Gewissenhaftigkeit = safe_mean(c(6-responses[9], responses[10], responses[11], 6-responses[12])),
      Neurotizismus = safe_mean(c(6-responses[13], responses[14], responses[15], 6-responses[16])),
      Offenheit = safe_mean(c(responses[17], 6-responses[18], responses[19], 6-responses[20]))
    )
    
    scores$Stress <- safe_mean(c(responses[21:23], 6-responses[24], responses[25]), min_items = 3)
    
    scores$Studierfaehigkeiten <- safe_mean(responses[26:29], min_items = 2)
    
    stat_vals <- c()
    if (!is.null(demographics) && length(demographics) > 0) {
      if ("Statistik_gutfolgen" %in% names(demographics)) {
        val <- as.numeric(demographics["Statistik_gutfolgen"])
        if (!is.na(val)) {
          stat_vals <- c(stat_vals, ((val - 1) / 99) * 4 + 1)
        }
      }
      if ("Statistik_selbstwirksam" %in% names(demographics)) {
        val <- as.numeric(demographics["Statistik_selbstwirksam"])
        if (!is.na(val)) {
          stat_vals <- c(stat_vals, ((val - 1) / 99) * 4 + 1)
        }
      }
    }
    scores$Statistik <- if (length(stat_vals) > 0) mean(stat_vals, na.rm = TRUE) else NA
    
    radar_scores <- list(
      Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
      Verträglichkeit = if (is.na(scores$Vertraeglichkeit) || is.nan(scores$Vertraeglichkeit)) NA else scores$Vertraeglichkeit,
      Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
      Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
      Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit
    )
    
    tryCatch({
      if (is_english) {
        radar_data <- data.frame(
          group = "Your Profile",
          Extraversion = radar_scores$Extraversion / 5,
          Agreeableness = radar_scores$Verträglichkeit / 5,
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
          Verträglichkeit = radar_scores$Verträglichkeit / 5,
          Gewissenhaftigkeit = radar_scores$Gewissenhaftigkeit / 5,
          Neurotizismus = radar_scores$Neurotizismus / 5,
          Offenheit = radar_scores$Offenheit / 5,
          stringsAsFactors = FALSE,
          row.names = NULL
        )
      }
    }, error = function(e) {
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
    
    radar_title <- if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)"
    
    non_na_count <- sum(!is.na(unlist(radar_scores)))
    skip_radar_plot <- non_na_count < 3
    
    if (skip_radar_plot) {
      radar_plot <- NULL
    } else {
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
    
    if (is_english) {
      dimension_labels <- dimension_names_en[names(ordered_scores)]
      category_labels <- c(rep("Personality", 5), "Stress", "Study Skills", "Statistics")
    } else {
      dimension_labels <- dimension_names_en[names(ordered_scores)]
      category_labels <- c(rep("Persönlichkeit", 5), "Stress", "Studierfähigkeiten", "Statistik")
    }
    
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
    
    bar_title <- if (is_english) "All Dimensions Overview" else "Alle Dimensionen im Überblick"
    bar_y_label <- if (is_english) "Score (1-5)" else "Punktzahl (1-5)"
    
    bar_plot <- bar_plot + ggplot2::labs(title = bar_title, y = bar_y_label)
    
    radar_file <- NULL
    bar_file <- tempfile(fileext = ".png")
    
    suppressMessages({
      if (!is.null(radar_plot)) {
        radar_file <- tempfile(fileext = ".png")
        ggplot2::ggsave(radar_file, radar_plot, width = 10, height = 9, dpi = 150, bg = "white")
      }
      ggplot2::ggsave(bar_file, bar_plot, width = 12, height = 7, dpi = 150, bg = "white")
    })
    
    radar_base64 <- ""
    bar_base64 <- ""
    if (requireNamespace("base64enc", quietly = TRUE)) {
      if (!is.null(radar_file)) {
        radar_base64 <- base64enc::base64encode(radar_file)
      }
      bar_base64 <- base64enc::base64encode(bar_file)
    }
    
    files_to_unlink <- c(bar_file)
    if (!is.null(radar_file)) files_to_unlink <- c(files_to_unlink, radar_file)
    unlink(files_to_unlink)
    
    html <- paste0(
      '<style>',
      '.page-title, .study-title, h1:first-child, .results-title { display: none !important; }',
      '</style>',
      '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
      
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
    
    sds <- list()
    
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
      if (length(valid_items) >= 2) {
        sd_val <- sd(valid_items, na.rm = TRUE)
        sds[[dim_name]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
      } else {
        sds[[dim_name]] <- NA
      }
    }
    
    psq_items <- c(responses[21:23], 6-responses[24], responses[25])
    valid_psq <- psq_items[!is.na(psq_items)]
    if (length(valid_psq) >= 2) {
      sd_val <- sd(valid_psq, na.rm = TRUE)
      sds[["Stress"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Stress"]] <- NA
    }
    
    mws_items <- responses[26:29]
    valid_mws <- mws_items[!is.na(mws_items)]
    if (length(valid_mws) >= 2) {
      sd_val <- sd(valid_mws, na.rm = TRUE)
      sds[["Studierfaehigkeiten"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Studierfaehigkeiten"]] <- NA
    }
    
    stat_items <- responses[30:31]
    valid_stat <- stat_items[!is.na(stat_items)]
    if (length(valid_stat) >= 2) {
      sd_val <- sd(valid_stat, na.rm = TRUE)
      sds[["Statistik"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
    } else {
      sds[["Statistik"]] <- NA
    }
    
    dimension_data <- if (is_english) {
      list(
        "Extraversion" = list(label = "Extraversion", score_key = "Extraversion", sd_key = "Extraversion"),
        "Vertraeglichkeit" = list(label = "Agreeableness", score_key = "Vertraeglichkeit", sd_key = "Vertraeglichkeit"), 
        "Gewissenhaftigkeit" = list(label = "Conscientiousness", score_key = "Gewissenhaftigkeit", sd_key = "Gewissenhaftigkeit"),
        "Neurotizismus" = list(label = "Neuroticism", score_key = "Neurotizismus", sd_key = "Neurotizismus"),
        "Offenheit" = list(label = "Openness", score_key = "Offenheit", sd_key = "Offenheit"),
        "Stress" = list(label = "Stress", score_key = "Stress", sd_key = "Stress"),
        "Studierfaehigkeiten" = list(label = "Study Skills", score_key = "Studierfaehigkeiten", sd_key = "Studierfaehigkeiten"),
        "Statistik" = list(label = "Statistics", score_key = "Statistik", sd_key = "Statistik")
      )
    } else {
      list(
        "Extraversion" = list(label = "Extraversion", score_key = "Extraversion", sd_key = "Extraversion"),
        "Vertraeglichkeit" = list(label = "Verträglichkeit", score_key = "Vertraeglichkeit", sd_key = "Vertraeglichkeit"), 
        "Gewissenhaftigkeit" = list(label = "Gewissenhaftigkeit", score_key = "Gewissenhaftigkeit", sd_key = "Gewissenhaftigkeit"),
        "Neurotizismus" = list(label = "Neurotizismus", score_key = "Neurotizismus", sd_key = "Neurotizismus"),
        "Offenheit" = list(label = "Offenheit", score_key = "Offenheit", sd_key = "Offenheit"),
        "Stress" = list(label = "Stress", score_key = "Stress", sd_key = "Stress"),
        "Studierfaehigkeiten" = list(label = "Studierfähigkeiten", score_key = "Studierfaehigkeiten", sd_key = "Studierfaehigkeiten"),
        "Statistik" = list(label = "Statistik", score_key = "Statistik", sd_key = "Statistik")
      )
    }
    
    for (dim_info in dimension_data) {
      value <- if (dim_info$score_key %in% names(scores) && !is.na(scores[[dim_info$score_key]])) {
        sprintf("%.2f", scores[[dim_info$score_key]])
      } else {
        "-"
      }
      
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
    
    html <- paste0(html, '</div>')
    
    if (user_wants_no_results) {
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
# CSV-Auswertung
# =============================================================================

process_hilfo_csv <- function(csv_data, responses, demographics, item_bank) {
  cat("DEBUG: process_hilfo_csv called with", length(responses), "responses\n")
  
  tryCatch({
    if (is.null(responses) || length(responses) == 0) {
      cat("WARNING: No responses provided to process_hilfo_csv\n")
      return(csv_data)
    }
    
    if (length(responses) < 31) {
      responses <- c(responses, rep(NA, 31 - length(responses)))
    }
    
    if (length(responses) >= 20) {
      csv_data$BFI_Extraversion <- mean(responses[1:4], na.rm = TRUE)
      csv_data$BFI_Agreeableness <- mean(responses[5:8], na.rm = TRUE)
      csv_data$BFI_Conscientiousness <- mean(responses[9:12], na.rm = TRUE)
      csv_data$BFI_Neuroticism <- mean(responses[13:16], na.rm = TRUE)
      csv_data$BFI_Openness <- mean(responses[17:20], na.rm = TRUE)
    }
    
    if (length(responses) >= 25) {
      csv_data$PSQ_Stress <- mean(responses[21:25], na.rm = TRUE)
    }
    
    if (length(responses) >= 29) {
      csv_data$MWS_StudySkills <- mean(responses[26:29], na.rm = TRUE)
    }
    
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
# Studienkonfiguration
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
  name = "HilFo - Hildesheimer Forschungsmethoden",
  study_key = session_uuid,
  theme = "hildesheim",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types,
  model = "2PL",
  adaptive = FALSE,
  max_items = 29,
  min_items = 29,
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
  debug_mode = TRUE
)