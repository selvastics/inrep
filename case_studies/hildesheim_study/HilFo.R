# =============================================================================
# HilFo - Hildesheim Research Methods Survey
# =============================================================================
#
# Questionnaire for the statistics seminars in the psychology bachelor program
# (Hildesheim), built with inrep::launch_study(). Non-adaptive: 29 Likert
# items plus demographics and two sliders, bilingual (de/en).
#
# Page flow (custom_page_flow, 16 pages)
#   1      Welcome, consent, language switcher
#   2-5    Demographics (age, gender, living situation, pets, smoking,
#          diet, Abitur grades)
#   6-10   Big Five (BFI, 20 items) and stress (PSQ, 5 items)
#   11     Study skills (MWS, 4 items)
#   12     Statistics sliders (0-100)
#   13     Prep/review time, satisfaction
#   14     Personal code
#   15     "Would you like to see your results?" -> data is saved here
#   16     Results page (create_hilfo_report) or thank-you page
#
# Data storage
#   On leaving page 15, build_hilfo_record() builds one row with all
#   variables (fixed column order, missing answers = NA). save_to_cloud()
#   writes it locally first (study_data/hilfo_results/), then uploads it via
#   WebDAV (with retries). read_hilfo_data.R reads these files back in.
#
# Configuration
#   HILFO_WEBDAV_SHARE_TOKEN, HILFO_WEBDAV_PASSWORD  WebDAV credentials. Set
#     both in ~/.Renviron (usethis::edit_r_environ() opens the file), then
#     restart R. Without them, data is only saved locally.
#   options(hilfo.debug = TRUE)                     verbose console output
# =============================================================================

library(inrep)
library(shiny)
library(shinyjs)
library(ggplot2)
library(httr)
library(base64enc)

# Only prints when options(hilfo.debug = TRUE) is set
hilfo_log <- function(...) {
  if (isTRUE(getOption("hilfo.debug", FALSE))) message("[HilFo] ", ...)
}

# Normalizes empty answers (NULL, NA, "") to NA; multi-select answers join with ";"
as_record_value <- function(x) {
  if (is.null(x) || length(x) == 0) return(NA)
  x <- x[!is.na(x) & nzchar(trimws(as.character(x)))]
  if (length(x) == 0) return(NA)
  if (length(x) > 1) return(paste(x, collapse = ";"))
  x
}

# =============================================================================
# SCORING HELPERS
# =============================================================================

# Dummy variables (0/1) for multi-select answers, e.g. Haustier_Hund, Haustier_Katze
create_dummy_variables <- function(response_values, all_options, prefix) {
  response_values <- if (is.null(response_values)) character(0) else as.character(response_values)
  dummy_vars <- list()
  for (opt_name in names(all_options)) {
    dummy_vars[[paste0(prefix, "_", opt_name)]] <- as.integer(as.character(all_options[[opt_name]]) %in% response_values)
  }
  dummy_vars
}

# Scale scores (with reverse-coding, matching the report and read_hilfo_data.R)
# responses: 29 Likert answers (1-5) in item bank order
score_hilfo_scales <- function(responses) {
  responses <- suppressWarnings(as.numeric(responses))
  responses <- c(responses, rep(NA, max(0, 29 - length(responses))))[1:29]
  rev_items <- c(2, 3, 6, 8, 9, 12, 13, 16, 18, 20, 24)
  responses[rev_items] <- 6 - responses[rev_items]
  m <- function(x) if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
  list(
    BFI_Extraversion = m(responses[1:4]),
    BFI_Vertraeglichkeit = m(responses[5:8]),
    BFI_Gewissenhaftigkeit = m(responses[9:12]),
    BFI_Neurotizismus = m(responses[13:16]),
    BFI_Offenheit = m(responses[17:20]),
    PSQ_Stress = m(responses[21:25]),
    MWS_StudySkills = m(responses[26:29])
  )
}

# Slider value, but only if it was actually moved (NA otherwise).
# Without this check, inrep would save the slider's starting position as if
# someone had answered.
slider_value <- function(demo_data, name) {
  d <- as.list(demo_data)
  if (!isTRUE(d[[paste0(name, "_touched")]])) return(NA_real_)
  x <- suppressWarnings(as.numeric(d[[name]]))
  if (length(x) == 0) NA_real_ else x[1]
}

# Slider 0-100 -> 1-5 (same formula in the report, the upload, and read_hilfo_data.R)
scale_slider <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  if (length(x) == 0 || is.na(x[1])) NA_real_ else (x[1] / 100) * 4 + 1
}

# =============================================================================
# WEBDAV EXPORT
# =============================================================================
# ADAPT THIS FOR YOUR OWN STUDY. The addresses below are HilFo's storage: a
# public Nextcloud share on academiccloud (Universität Hildesheim). Another
# study replaces WEBDAV_URLS with its own storage. inrep::webdav_upload()
# accepts any WebDAV server, for example
#   - a Nextcloud/ownCloud share link:  "https://cloud.example.org/index.php/s/<token>"
#   - a personal Nextcloud folder:      "https://cloud.example.org/remote.php/dav/files/<user>/<folder>/"
#     (then pass user = "<user>" and an app password)
#   - any other WebDAV folder URL:      "https://dav.example.org/path/"
# See ?inrep::webdav_upload for details.
#
# Credentials come from environment variables, never from this file (it is
# pushed to a public repository). Set them once in ~/.Renviron
# (usethis::edit_r_environ() opens it) and restart R, or for one session:
#   Sys.setenv(HILFO_WEBDAV_SHARE_TOKEN = "...", HILFO_WEBDAV_PASSWORD = "...")
# The token is the part after /s/ in the share link; the password is the
# share password.
WEBDAV_SHARE_TOKEN <- Sys.getenv("HILFO_WEBDAV_SHARE_TOKEN")
WEBDAV_PASSWORD <- Sys.getenv("HILFO_WEBDAV_PASSWORD")

# Only the server part ("https://host[:port]/") matters here. For a public
# share webdav_upload() builds the working address itself:
#   https://<host>/public.php/dav/files/<share token>/<file>
# with the token as user name and the share password as password (this is
# the address confirmed to work on academiccloud; the older
# public.php/webdav/ address answers 409 for upload-only shares).
# Another university: replace the host (and port, e.g. ":8443", if its
# server uses one) below; keep "/public.php/webdav/" or paste the share
# link "https://<host>/s/<token>" instead. Token and password stay in the
# environment variables above.
# academiccloud shares live on one of two hosts; the other one answers 401.
# webdav_upload() tries them in this order.
WEBDAV_URLS <- c("https://uni-hildesheim.files.academiccloud.de/public.php/webdav/",
                 "https://sync.academiccloud.de/public.php/webdav/")
LOCAL_RESULTS_DIR <- file.path("study_data", "hilfo_results")

# Saves one result row: locally first (backup copy), then uploads the same
# file with inrep::webdav_upload(). Returns list(cloud=, local=, attempted=) so
# the caller can tell apart: uploaded; saved locally without credentials
# configured; and a configured upload that failed (worth warning about).
save_to_cloud <- function(data, filename) {
  local_file <- file.path(LOCAL_RESULTS_DIR, filename)
  local_write_ok <- tryCatch({
    dir.create(LOCAL_RESULTS_DIR, recursive = TRUE, showWarnings = FALSE)
    utils::write.csv(data, local_file, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    hilfo_log("Lokale Kopie: ", local_file)
    TRUE
  }, error = function(e) {
    message("[HilFo] CRITICAL: Lokales Speichern fehlgeschlagen: ", e$message)
    FALSE
  })

  if (!nzchar(WEBDAV_SHARE_TOKEN) || !nzchar(WEBDAV_PASSWORD)) {
    message("[HilFo] HILFO_WEBDAV_SHARE_TOKEN / HILFO_WEBDAV_PASSWORD nicht gesetzt - kein Upload",
            if (local_write_ok) paste0(", Daten liegen lokal in ", local_file) else "")
    return(list(cloud = FALSE, local = local_write_ok, attempted = FALSE))
  }

  # Upload exactly the file that was saved locally (or the data itself if the
  # local copy failed).
  content <- if (local_write_ok) readBin(local_file, "raw", file.info(local_file)$size) else data
  uploaded <- tryCatch(
    inrep::webdav_upload(content, filename, url = WEBDAV_URLS,
                         password = WEBDAV_PASSWORD, share_token = WEBDAV_SHARE_TOKEN),
    error = function(e) {
      message("[HilFo] WebDAV-Upload Fehler: ", conditionMessage(e))
      FALSE
    }
  )
  if (isTRUE(uploaded)) {
    message("[HilFo] Hochgeladen: ", filename)
  } else if (local_write_ok) {
    message("[HilFo] Upload fehlgeschlagen, Daten liegen lokal in ", local_file)
  } else {
    message("[HilFo] CRITICAL: Upload fehlgeschlagen UND lokales Speichern fehlgeschlagen - Datensatz ist verloren: ", filename)
  }
  list(cloud = isTRUE(uploaded), local = local_write_ok, attempted = TRUE)
}

# Connection test without filling in the questionnaire. In the R console:
#   hilfo_upload_test()
# It uploads a one-line file "verbindungstest_<time>.csv" and prints which
# address worked. (Load the functions first by running the script up to here,
# or press Esc/Stop once the app has started; the functions stay defined.)
hilfo_upload_test <- function() {
  res <- save_to_cloud(data.frame(test = "inrep upload test", zeit = format(Sys.time())),
                       paste0("verbindungstest_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv"))
  if (isTRUE(res$cloud)) message("[HilFo] Verbindungstest OK.") else message("[HilFo] Verbindungstest fehlgeschlagen (siehe Meldungen oben).")
  invisible(res$cloud)
}

# =============================================================================
# ONE PARTICIPANT'S RECORD
# =============================================================================
HILFO_ITEM_IDS <- c(
  "BFE_01", "BFE_02", "BFE_03", "BFE_04",
  "BFV_01", "BFV_02", "BFV_03", "BFV_04",
  "BFG_01", "BFG_02", "BFG_03", "BFG_04",
  "BFN_01", "BFN_02", "BFN_03", "BFN_04",
  "BFO_01", "BFO_02", "BFO_03", "BFO_04",
  "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
  "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK"
)

HAUSTIER_OPTIONS <- c(
  "Hund" = "1", "Katze" = "2", "Fisch" = "3", "Vogel" = "4",
  "Nager" = "5", "Reptil" = "6", "Ich_moechte_kein_Haustier" = "7",
  "Sonstiges" = "other"
)

# One row with all variables. Every column is always present (NA when
# unanswered), so every uploaded file has the same structure.
build_hilfo_record <- function(session_id, demo_data, responses, language = "de") {
  d <- if (is.list(demo_data)) demo_data else as.list(demo_data)
  v <- function(name) as_record_value(d[[name]])

  record <- list(
    session_id = session_id,
    timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    study_language = language,
    "Einverständnis" = v("Einverständnis"),
    Alter_VPN = v("Alter_VPN"),
    Geschlecht = v("Geschlecht"),
    Wohnstatus = v("Wohnstatus"),
    Wohn_Zusatz = v("Wohn_Zusatz")
  )
  record <- c(record, create_dummy_variables(d$Haustier, HAUSTIER_OPTIONS, "Haustier"))
  record <- c(record, list(
    Haustier_Zusatz = v("Haustier_Zusatz"),
    Rauchen = v("Rauchen"),
    "Ernährung" = v("Ernährung"),
    "Ernährung_Zusatz" = v("Ernährung_Zusatz"),
    Note_Englisch = v("Note_Englisch"),
    Note_Mathe = v("Note_Mathe"),
    Statistik_gutfolgen = slider_value(d, "Statistik_gutfolgen"),
    Statistik_selbstwirksam = slider_value(d, "Statistik_selbstwirksam"),
    Statistik_gutfolgen_touched = isTRUE(d$Statistik_gutfolgen_touched),
    Statistik_selbstwirksam_touched = isTRUE(d$Statistik_selbstwirksam_touched),
    Statistik_gutfolgen_scaled = scale_slider(slider_value(d, "Statistik_gutfolgen")),
    Statistik_selbstwirksam_scaled = scale_slider(slider_value(d, "Statistik_selbstwirksam")),
    Vor_Nachbereitung = v("Vor_Nachbereitung"),
    Zufrieden_Hi_7st = v("Zufrieden_Hi_7st"),
    # Uppercased as shown in the input field, so codes are comparable across waves
    "Persönlicher_Code" = toupper(trimws(v("Persönlicher_Code"))),
    show_personal_results = v("show_personal_results")
  ))

  responses <- suppressWarnings(as.numeric(responses))
  responses <- c(responses, rep(NA, max(0, 29 - length(responses))))[1:29]
  record <- c(record, stats::setNames(as.list(responses), HILFO_ITEM_IDS))
  record <- c(record, score_hilfo_scales(responses))
  stat_scaled <- c(record$Statistik_gutfolgen_scaled, record$Statistik_selbstwirksam_scaled)
  record$Statistics_Confidence <- if (all(is.na(stat_scaled))) NA_real_ else mean(stat_scaled, na.rm = TRUE)

  as.data.frame(record, check.names = FALSE, stringsAsFactors = FALSE)
}

# =============================================================================
# ITEM BANK WITH CONSISTENT VARIABLE NAMES
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
  Question_EN = c(
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
    "Abstract considerations interest me little.",
    "I feel that too many demands are placed on me.",
    "I have too much to do.",
    "I feel rushed.",
    "I have enough time for myself.",
    "I feel under deadline pressure.",
    "coping with the social climate in the program (e.g., handling competition)",
    "organizing teamwork (e.g., finding study groups)",
    "making contacts with fellow students (e.g., for study groups, leisure)",
    "working together in a team (e.g., working on tasks together, preparing presentations)"
  ),
  reverse_coded = c(
    FALSE, TRUE, TRUE, FALSE,
    FALSE, TRUE, FALSE, TRUE,
    TRUE, FALSE, FALSE, TRUE,
    TRUE, FALSE, FALSE, TRUE,
    FALSE, TRUE, FALSE, TRUE,
    FALSE, FALSE, FALSE, TRUE, FALSE,
    rep(FALSE, 4)
  ),
  ResponseCategories = rep("1,2,3,4,5", 29),
  b = rep(0, 29),
  a = rep(1, 29),
  stringsAsFactors = FALSE
)

# =============================================================================
# FULL DEMOGRAPHICS SECTION
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
        <input type="text" id="demo_Persönlicher_Code" name="demo_Persönlicher_Code" placeholder="z.B. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
      </div>
      <div style="text-align: center; color: #666; font-size: 14px;">Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15</div>
    </div>',
    html_content_en = '<div id="personal-code-container" style="padding: 20px; font-size: 16px; line-height: 1.8;">
      <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">Please create a personal code:</p>
      <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
        <p style="margin: 0; font-weight: 500;">First 2 letters of your mothers first name + first 2 letters of your birthplace + day of your birthday</p>
      </div>
      <div style="text-align: center; margin: 30px 0;">
        <input type="text" id="demo_Persönlicher_Code" name="demo_Persönlicher_Code" placeholder="e.g. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
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
    # start_empty: no preset position; the handle appears where the participant
    # first clicks or taps, and an untouched slider is stored as missing.
    start_empty = TRUE,
    value_suffix = "%",
    hint = "Tippen oder klicken Sie auf die Linie, um Ihre Antwort zu setzen.",
    hint_en = "Tap or click on the line to set your answer.",
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
    # start_empty: no preset position; the handle appears where the participant
    # first clicks or taps, and an untouched slider is stored as missing.
    start_empty = TRUE,
    value_suffix = "%",
    hint = "Tippen oder klicken Sie auf die Linie, um Ihre Antwort zu setzen.",
    hint_en = "Tap or click on the line to set your answer.",
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
# PAGE FLOW FOR THE HILFO QUESTIONNAIRE
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
    required = FALSE,
    # The checkboxes are plain HTML elements; Shiny exposes them as
    # input$consent_check and input$consent_check_en
    completion_handler = function(session, rv, inputs, config) {
      consent <- isTRUE(inputs$consent_check) || isTRUE(inputs$consent_check_en)
      rv$demo_data$Einverständnis <- if (consent) 1 else NA
    }
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
    description = "Geben Sie auf der Linie an, wie sehr Sie zustimmen (0% = stimme gar nicht zu, 100% = stimme voll zu).",
    description_en = "Show on the line how much you agree (0% = strongly disagree, 100% = strongly agree).",
    demographics = c("Statistik_gutfolgen", "Statistik_selbstwirksam"),
    # inrep's start_empty slider sends demo_<name>_touched = TRUE on the first
    # click, tap, drag or arrow key. Only then does the value count
    # (see slider_value()).
    completion_handler = function(session, rv, inputs, config) {
      for (slider in c("Statistik_gutfolgen", "Statistik_selbstwirksam")) {
        touched <- isTRUE(inputs[[paste0("demo_", slider, "_touched")]])
        value <- suppressWarnings(as.numeric(inputs[[paste0("demo_", slider)]]))
        rv$demo_data[[slider]] <- if (touched && length(value) == 1) value else NA
        rv$demo_data[[paste0(slider, "_touched")]] <- touched
        hilfo_log(slider, " = ", rv$demo_data[[slider]], " (bewegt: ", touched, ")")
      }
    }
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
    # This is where the full record gets saved (locally + WebDAV),
    # regardless of whether the person wants to see their results.
    completion_handler = function(session, rv, inputs, config) {
      if (is.null(rv$session_id) || is.na(rv$session_id)) {
        rv$session_id <- if (!is.null(session$token)) session$token else paste0("SESS_", format(Sys.time(), "%Y%m%d_%H%M%S"))
      }

      # Wrapped in its own tryCatch so a thrown error here can't just get
      # swallowed by inrep's generic completion_handler error log and let
      # the participant reach the report page without us noticing the save
      # never happened.
      saved <- tryCatch({
        record <- build_hilfo_record(rv$session_id, rv$demo_data, rv$responses,
                                     language = if (is.null(rv$language)) "de" else rv$language)
        filename <- paste0("HilFo_results_", format(Sys.time(), "%Y%m%d_%H%M%S"), "_", rv$session_id, ".csv")
        save_to_cloud(record, filename)
      }, error = function(e) {
        message("[HilFo] CRITICAL: Speichern fehlgeschlagen: ", e$message)
        list(cloud = FALSE, local = FALSE, attempted = FALSE)
      })

      if (isTRUE(saved$cloud)) {
        # Tells inrep no extra JSON upload is needed
        rv$csv_uploaded <- TRUE
        rv$data_uploaded_to_cloud <- TRUE
      } else if (isTRUE(saved$attempted) || !isTRUE(saved$local)) {
        # Warn whenever an upload was actually attempted (credentials were
        # configured) and still failed - that's worth knowing about even
        # though the local copy is safe. The ONLY case that stays silent is
        # no credentials configured at all + local save worked, since that's
        # an intentional local-only run, not a failure.
        rv$hilfo_save_failed <- TRUE
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
# REPORT FUNCTION WITH STATIC RADAR PLOT
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL, rv = NULL) {
  tryCatch({
    # Data was already saved on page 15; this just builds the report.
    hilfo_log("create_hilfo_report: ", length(responses), " responses")
    
    current_lang <- "de"
    is_english <- FALSE
    
    # inrep keeps the participant's language in rv$language (set by the language toggle)
    lang_from_session <- if (!is.null(rv)) shiny::isolate(rv$language) else NULL
    if (is.null(lang_from_session) && !is.null(session)) {
      lang_from_session <- session$userData$language
      if (is.null(lang_from_session)) lang_from_session <- shiny::isolate(session$input$language)
    }
    if (!is.null(lang_from_session) && lang_from_session %in% c("de", "en")) {
      current_lang <- lang_from_session
    }
    
    is_english <- (current_lang == "en")
    
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
    
    # Statistics score = mean of the two sliders (only moved sliders count)
    demo_list <- if (is.null(demographics)) list() else as.list(demographics)
    stat_vals <- c(scale_slider(slider_value(demo_list, "Statistik_gutfolgen")),
                   scale_slider(slider_value(demo_list, "Statistik_selbstwirksam")))
    stat_vals <- stat_vals[!is.na(stat_vals)]
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
                         vjust = -0.5, size = 6, fontface = "bold", color = "#333333") +
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

      # Shown when save_to_cloud() either lost the record entirely, or a
      # configured WebDAV upload was actually attempted and rejected (wrong
      # credentials, network error). Skipping the upload because no
      # credentials were set at all - with a working local save - does NOT
      # set this; that's an intentional local-only run, not a failure.
      if (!is.null(rv) && isTRUE(shiny::isolate(rv$hilfo_save_failed))) paste0(
        '<div style="background: #fff3cd; border: 2px solid #e8041c; border-radius: 8px; padding: 15px; margin-bottom: 20px; text-align: center;">',
        if (is_english) {
          '<strong>Warning:</strong> we could not confirm your data was saved. Please contact the study team so your responses aren\'t lost.'
        } else {
          '<strong>Achtung:</strong> Ihre Daten konnten nicht gespeichert werden. Bitte melden Sie sich beim Studienteam, damit Ihre Antworten nicht verloren gehen.'
        },
        '</div>'
      ) else "",

      # Radar section only when the radar plot exists (it needs the optional ggradar package)
      if (!is.null(radar_base64) && radar_base64 != "") paste0(
        '<div class="report-section">',
        '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
        '<span data-lang-de="Persönlichkeitsprofil" data-lang-en="Personality Profile">', if (is_english) "Personality Profile" else "Persönlichkeitsprofil", '</span></h2>',
        '<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px;">',
        '</div>'
      ) else "",
      
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
    
    # Statistik comes from the two page-12 sliders, not from item responses
    valid_stat <- stat_vals[!is.na(stat_vals)]
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
    message("[HilFo] Fehler in create_hilfo_report: ", e$message)
    return(shiny::HTML('<div style="padding: 20px; color: red;"><h2>Fehler beim Generieren des Berichts</h2><p>Ein Fehler ist aufgetreten. Bitte versuchen Sie es erneut.</p></div>'))
  })
}

# =============================================================================
# STUDY CONFIGURATION
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
  results_processor = create_hilfo_report
)

# HilFo runs locally with one participant per launch, so the whole app
# (not just the session) should close once the participant is done or the
# window is closed.
options(inrep.stop_app_on_finish = TRUE)

# Start the study. debug_mode = TRUE shows the test bar (Ctrl+A fills the
# current page, Ctrl+Q fills everything through to the report) and has no
# place in live/production use.
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,
  # inrep's own session backup (JSON) goes to the same storage. Replace with
  # your own storage, or remove these three lines for local storage only.
  webdav_url = WEBDAV_URLS,
  password = WEBDAV_PASSWORD,
  webdav_share_token = WEBDAV_SHARE_TOKEN,
  save_format = "csv",
  debug_mode = FALSE
)