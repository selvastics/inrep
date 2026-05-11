# =============================================================================
# inrep-studio-onboarding.R
# -----------------------------------------------------------------------------
# Lightweight Shiny app that walks a new user through 6 onboarding questions
# and hands back a ready-to-edit `create_study_config()` call that can be
# opened directly in inrep-studio for visual refinement.
#
# Two deployment modes:
#  1. Standalone  ÔÇö run as a separate Shiny app (e.g. shinyapps.io).
#     "Open in studio" opens the studio URL in a new tab, passing the config
#     via URL hash: <STUDIO_URL>#inrep-onboarding=<URL-encoded JSON>.
#     The studio reads this hash on load and pre-fills its inputs.
#
#  2. Framed      ÔÇö embedded as an <iframe> inside the studio app.
#     "Open in studio" uses window.parent.postMessage to hand the config
#     directly to the parent frame, which picks it up via an event listener
#     and calls Shiny.setInputValue('ob_hydrate', ...).
#
# In both cases the JSON payload is a studio-compatible config object with
# fields: study_name, adaptive, irt_model, primary_lang, plus _ob_* metadata.
#
# Studio URL (override via env var for local dev):
#   INREP_STUDIO_URL=http://127.0.0.1:4523
#
# Standalone:
#   source("app-studio-onboarding.R"); shiny::runApp(onboarding_app())
#
# Author: inrep team, University of Hildesheim
# Style:  elegant dark mode, single mint accent (oklch(0.85 0.13 170)),
#         multilingual (en / de / es / fr) with English default.
# =============================================================================

suppressWarnings(suppressPackageStartupMessages({
  library(shiny)
  library(htmltools)
  library(jsonlite)
}))

# Studio URL ÔÇö override via INREP_STUDIO_URL env var for local dev.
# Points at the live inrep-studio deployment by default.
ONBOARDING_STUDIO_URL <- {
  env <- Sys.getenv("INREP_STUDIO_URL", "")
  if (nzchar(env)) env else "https://selvastics.shinyapps.io/inrep-studio/"
}

# -----------------------------------------------------------------------------
# i18n dictionary ÔÇö kept inline so the file is single-source and droppable.
# Keys mirror those used by the iOS mock so copy stays consistent.
# -----------------------------------------------------------------------------
ONBOARDING_I18N <- list(
  en = list(
    tagline = "studio",
    intro   = "Answer seven short questions. We'll generate your first inrep study, ready to open in the studio.",
    start   = "Start",
    skip    = "Skip \u2192 Open with defaults",
    footer  = "From the inrep research toolkit, University of Hildesheim",

    q_lang_title    = "Choose your language",
    q_lang_sub      = "You can change this anytime. The studio supports English, German, Spanish and French.",
    q_role_title    = "Tell us about you",
    q_role_sub      = "This shapes the templates we suggest.",
    q_role_name     = "Your name (optional)",
    q_role_role     = "Your role",
    role_researcher = "Researcher",
    role_lecturer   = "Lecturer",
    role_student    = "Student",
    role_other      = "Other",
    q_role_inst     = "Institution",

    q_dom_title     = "What will you measure?",
    q_dom_sub       = "Pick one or more. We will preload matching item banks from the inrep package.",
    dom_personality = "Personality (BFI, 20 items)",
    dom_cognitive   = "Cognitive ability (adaptive, IRT)",
    dom_math        = "Math reasoning (graded response)",
    dom_resilience  = "Resilience & coping (RCQ, 30/68 items)",
    dom_custom      = "Custom item bank (CSV)",

    q_study_title   = "Set up your first study",
    q_study_sub     = "You can refine everything in the studio.",
    q_study_name    = "Study name",
    q_study_mode    = "How should items be selected?",
    mode_adaptive   = "Adaptive ÔÇö fewer items, personalised",
    mode_fixed      = "Fixed order ÔÇö same items, same order",

    q_pages_title   = "How many item pages to start with?",
    q_pages_sub     = "Each page shows one item. You can add or remove pages later in the studio.",
    q_pages_label   = "Number of item pages",
    q_pages_tip     = "Tip: adaptive studies typically use 10ÔÇô20, fixed studies 5ÔÇô30.",

    q_part_title    = "Participant languages",
    q_part_sub      = "Which languages will participants see on screen? Multiple is fine.",

    q_report_title  = "Show a results page?",
    q_report_sub    = "At the end, should participants see a personalised results summary?",
    report_yes      = "Yes \u2014 show a results summary",
    report_no       = "No \u2014 end after the last item",

    review_title    = "Your generated configuration",
    review_sub      = "Copy the R code or click \u2018Open in inrep\u2011studio\u2019 to launch the visual editor with these settings pre-filled.",
    review_config   = "Generated R code",
    review_preview  = "Participant preview",
    review_open     = "Open in inrep\u2011studio \u2192",
    review_copy     = "Copy R code",
    review_back     = "Back",

    cm_back         = "Back",
    cm_continue     = "Continue",
    cm_step         = "Step %d of %d"
  ),
  de = list(
    tagline = "studio",
    intro   = "Beantworte sieben kurze Fragen. Wir erzeugen daraus deine erste inrep-Studie.",
    start   = "Loslegen",
    skip    = "\u00dcberspringen \u2192 Mit Standards ├Âffnen",
    footer  = "Aus dem inrep-Toolkit, Universit├ñt Hildesheim",

    q_lang_title    = "Sprache w├ñhlen",
    q_lang_sub      = "Jederzeit ├ñnderbar. Das Studio unterst├╝tzt Englisch, Deutsch, Spanisch und Franz├Âsisch.",
    q_role_title    = "Erz├ñhl uns von dir",
    q_role_sub      = "Daraus leiten wir passende Vorlagen ab.",
    q_role_name     = "Dein Name (optional)",
    q_role_role     = "Deine Rolle",
    role_researcher = "Forschend",
    role_lecturer   = "Lehrend",
    role_student    = "Studierend",
    role_other      = "Andere",
    q_role_inst     = "Einrichtung",

    q_dom_title     = "Was m├Âchtest du erheben?",
    q_dom_sub       = "W├ñhle ein oder mehr. Wir laden passende Itembanks aus dem inrep-Paket.",
    dom_personality = "Pers├Ânlichkeit (BFI, 20 Items)",
    dom_cognitive   = "Kognitive F├ñhigkeit (adaptiv, IRT)",
    dom_math        = "Mathe-Reasoning (Graded Response)",
    dom_resilience  = "Resilienz & Coping (RCQ, 30/68 Items)",
    dom_custom      = "Eigene Itembank (CSV)",

    q_study_title   = "Erste Studie anlegen",
    q_study_sub     = "Im Studio kannst du alles feinjustieren.",
    q_study_name    = "Studienname",
    q_study_mode    = "Wie sollen Items ausgew├ñhlt werden?",
    mode_adaptive   = "Adaptiv ÔÇö weniger Items, personalisiert",
    mode_fixed      = "Feste Reihenfolge ÔÇö gleiche Items, gleiche Reihenfolge",

    q_pages_title   = "Wie viele Item-Seiten m├Âchtest du starten?",
    q_pages_sub     = "Jede Seite zeigt ein Item. Du kannst Seiten sp├ñter im Studio hinzuf├╝gen oder entfernen.",
    q_pages_label   = "Anzahl Item-Seiten",
    q_pages_tip     = "Tipp: Adaptive Studien nutzen meist 10ÔÇô20, Fixe Studien 5ÔÇô30.",

    q_part_title    = "Sprachen f├╝r Teilnehmende",
    q_part_sub      = "Welche Sprachen sehen Teilnehmende? Mehrfachauswahl m├Âglich.",

    q_report_title  = "Ergebnisseite anzeigen?",
    q_report_sub    = "Sollen Teilnehmende am Ende eine pers├Ânliche Zusammenfassung sehen?",
    report_yes      = "Ja \u2014 Ergebnisse anzeigen",
    report_no       = "Nein \u2014 nach dem letzten Item beenden",

    review_title    = "Generierte Konfiguration",
    review_sub      = "Kopiere den R-Code oder klicke auf \u2018In inrep\u2011studio \u00f6ffnen\u2019 um den visuellen Editor mit diesen Einstellungen zu starten.",
    review_config   = "Generierter R-Code",
    review_preview  = "Teilnehmenden-Vorschau",
    review_open     = "In inrep\u2011studio ├Âffnen \u2192",
    review_copy     = "R-Code kopieren",
    review_back     = "Zur├╝ck",

    cm_back         = "Zur├╝ck",
    cm_continue     = "Weiter",
    cm_step         = "Schritt %d von %d"
  ),
  es = list(
    tagline = "studio",
    intro   = "Responde siete preguntas cortas. Generaremos tu primer estudio inrep.",
    start   = "Empezar",
    skip    = "Saltar \u2192 Abrir con valores predeterminados",
    footer  = "Del kit de investigaci├│n inrep, Universidad de Hildesheim",

    q_lang_title    = "Elige tu idioma",
    q_lang_sub      = "C├ímbialo cuando quieras. El studio admite ingl├®s, alem├ín, espa├▒ol y franc├®s.",
    q_role_title    = "Cu├®ntanos sobre ti",
    q_role_sub      = "Con esto sugerimos plantillas a tu medida.",
    q_role_name     = "Tu nombre (opcional)",
    q_role_role     = "Tu rol",
    role_researcher = "Investigador/a",
    role_lecturer   = "Docente",
    role_student    = "Estudiante",
    role_other      = "Otro",
    q_role_inst     = "Instituci├│n",

    q_dom_title     = "┬┐Qu├® quieres medir?",
    q_dom_sub       = "Elige uno o varios. Precargamos los bancos de ├¡tems del paquete inrep.",
    dom_personality = "Personalidad (BFI, 20 ├¡tems)",
    dom_cognitive   = "Habilidad cognitiva (adaptativo, TRI)",
    dom_math        = "Razonamiento matem├ítico (respuesta graduada)",
    dom_resilience  = "Resiliencia y afrontamiento (RCQ, 30/68 ├¡tems)",
    dom_custom      = "Banco propio (CSV)",

    q_study_title   = "Configura tu primer estudio",
    q_study_sub     = "Podr├ís afinarlo todo en el studio.",
    q_study_name    = "Nombre del estudio",
    q_study_mode    = "┬┐C├│mo se eligen los ├¡tems?",
    mode_adaptive   = "Adaptativo ÔÇö menos ├¡tems, personalizado",
    mode_fixed      = "Orden fijo ÔÇö mismos ├¡tems, mismo orden",

    q_pages_title   = "┬┐Cu├íntas p├íginas de ├¡tems quieres al inicio?",
    q_pages_sub     = "Cada p├ígina muestra un ├¡tem. Puedes a├▒adir o eliminar p├íginas en el studio.",
    q_pages_label   = "N├║mero de p├íginas de ├¡tems",
    q_pages_tip     = "Consejo: los estudios adaptativos usan 10ÔÇô20, los fijos 5ÔÇô30.",

    q_part_title    = "Idiomas para participantes",
    q_part_sub      = "┬┐Qu├® idiomas ver├ín los participantes? Selecci├│n m├║ltiple permitida.",

    q_report_title  = "\u00bfMostrar p├ígina de resultados?",
    q_report_sub    = "\u00bfLos participantes ver├ín un resumen personalizado al final del estudio?",
    report_yes      = "S├¡ \u2014 mostrar resumen de resultados",
    report_no       = "No \u2014 terminar tras el \u00faltimo ├¡tem",

    review_title    = "Configuraci├│n generada",
    review_sub      = "Copia el c├│digo R o haz clic en \u2018Abrir en inrep\u2011studio\u2019 para iniciar el editor visual con esta configuraci├│n.",
    review_config   = "C├│digo R generado",
    review_preview  = "Vista del participante",
    review_open     = "Abrir en inrep\u2011studio \u2192",
    review_copy     = "Copiar c├│digo R",
    review_back     = "Atr├ís",

    cm_back         = "Atr├ís",
    cm_continue     = "Continuar",
    cm_step         = "Paso %d de %d"
  ),
  fr = list(
    tagline = "studio",
    intro   = "R├®ponds ├á sept questions courtes. On g├®n├¿re ta premi├¿re ├®tude inrep.",
    start   = "Commencer",
    skip    = "Passer \u2192 Ouvrir avec les r├®glages par d├®faut",
    footer  = "Issu de la bo├«te ├á outils inrep, Universit├® de Hildesheim",

    q_lang_title    = "Choisis ta langue",
    q_lang_sub      = "Modifiable ├á tout moment. Le studio g├¿re anglais, allemand, espagnol et fran├ºais.",
    q_role_title    = "Parle-nous de toi",
    q_role_sub      = "Cela oriente les mod├¿les propos├®s.",
    q_role_name     = "Ton nom (optionnel)",
    q_role_role     = "Ton r├┤le",
    role_researcher = "Chercheur┬Àse",
    role_lecturer   = "Enseignant┬Àe",
    role_student    = "├ëtudiant┬Àe",
    role_other      = "Autre",
    q_role_inst     = "├ëtablissement",

    q_dom_title     = "Que veux-tu mesurer ?",
    q_dom_sub       = "Choisis un ou plusieurs. On pr├®charge les banques d'items du package inrep.",
    dom_personality = "Personnalit├® (BFI, 20 items)",
    dom_cognitive   = "Capacit├® cognitive (adaptatif, TRI)",
    dom_math        = "Raisonnement math├®matique (r├®ponse gradu├®e)",
    dom_resilience  = "R├®silience & coping (RCQ, 30/68 items)",
    dom_custom      = "Banque personnalis├®e (CSV)",

    q_study_title   = "Configure ta premi├¿re ├®tude",
    q_study_sub     = "Tout est affinable dans le studio.",
    q_study_name    = "Nom de l'├®tude",
    q_study_mode    = "Comment choisir les items ?",
    mode_adaptive   = "Adaptatif ÔÇö moins d'items, personnalis├®",
    mode_fixed      = "Ordre fixe ÔÇö m├¬mes items, m├¬me ordre",

    q_pages_title   = "Combien de pages d'items pour commencer ?",
    q_pages_sub     = "Chaque page affiche un item. Tu peux en ajouter ou supprimer plus tard dans le studio.",
    q_pages_label   = "Nombre de pages d'items",
    q_pages_tip     = "Conseil : les ├®tudes adaptatives utilisent 10ÔÇô20, les fixes 5ÔÇô30.",

    q_part_title    = "Langues pour les participant┬Àes",
    q_part_sub      = "Quelles langues verront-ils ? S├®lection multiple possible.",

    q_report_title  = "Afficher une page de r├®sultats ?",
    q_report_sub    = "├Ç la fin, les participant\u00b7es verront-ils un r├®sum├® personnalis├® ?",
    report_yes      = "Oui \u2014 afficher un r├®sum├® des r├®sultats",
    report_no       = "Non \u2014 terminer apr├¿s le dernier item",

    review_title    = "Configuration g├®n├®r├®e",
    review_sub      = "Copie le code R ou clique sur \u2018Ouvrir dans inrep\u2011studio\u2019 pour lancer l\u2019├®diteur visuel avec ces r├®glages.",
    review_config   = "Code R g├®n├®r├®",
    review_preview  = "Aper├ºu participant",
    review_open     = "Ouvrir dans inrep\u2011studio \u2192",
    review_copy     = "Copier le code R",
    review_back     = "Retour",

    cm_back         = "Retour",
    cm_continue     = "Continuer",
    cm_step         = "├ëtape %d sur %d"
  )
)

ONBOARDING_LANG_LIST <- list(
  list(code = "en", native = "English",  name = "English"),
  list(code = "de", native = "Deutsch",  name = "German"),
  list(code = "es", native = "Espa├▒ol",  name = "Spanish"),
  list(code = "fr", native = "Fran├ºais", name = "French")
)

# -----------------------------------------------------------------------------
# Sample item used for the participant preview. Localised per language so the
# user feels the multilingual story end-to-end on the very first preview.
# -----------------------------------------------------------------------------
ONBOARDING_PREVIEW_ITEM <- list(
  en = list(stem = "I see myself as someone who is talkative and outgoing.",
            anchors = c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")),
  de = list(stem = "Ich sehe mich selbst als jemanden, der gespr├ñchig und gesellig ist.",
            anchors = c("Stimme gar nicht zu", "Stimme nicht zu", "Neutral", "Stimme zu", "Stimme voll zu")),
  es = list(stem = "Me veo como alguien hablador y extrovertido.",
            anchors = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo")),
  fr = list(stem = "Je me vois comme quelqu'un de bavard et extraverti.",
            anchors = c("Pas du tout d'accord", "Pas d'accord", "Neutre", "D'accord", "Tout ├á fait d'accord"))
)

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || (length(x) == 1 && (is.na(x) || x == ""))) y else x

ob_t <- function(lang, key) {
  pkt <- ONBOARDING_I18N[[lang]] %||% ONBOARDING_I18N$en
  pkt[[key]] %||% (ONBOARDING_I18N$en[[key]] %||% key)
}

ob_safe_quote <- function(x) {
  if (is.null(x)) return('""')
  x <- gsub("\\\\", "\\\\\\\\", as.character(x))
  x <- gsub('"', '\\\\"', x)
  paste0('"', x, '"')
}

# Map onboarding domain key ÔåÆ inrep item-bank object name.
ob_domain_to_bank <- function(dom) {
  switch(dom,
         personality = "bfi_items",
         cognitive   = "cognitive_items",
         math        = "math_items",
         resilience  = "rcq_items",
         custom      = "my_items"  # placeholder ÔÇö user will swap in their CSV
  )
}

# Build the create_study_config() + launch_study() snippet.
ob_build_config_code <- function(answers) {
  doms        <- answers$domains %||% list("personality")
  primary_dom <- if (is.list(doms)) doms[[1]] else doms[[1]]
  bank        <- ob_domain_to_bank(primary_dom)
  model       <- if (primary_dom %in% c("math", "cognitive")) "2PL" else "GRM"
  adaptive    <- isTRUE(identical(answers$mode, "adaptive"))
  langs       <- answers$part_langs %||% list(answers$ui_lang %||% "en")
  show_debrief <- !isTRUE(identical(answers$report_page, "no"))
  max_items_val <- as.integer(answers$max_items %||% (if (adaptive) 15L else nrow_estimate(primary_dom)))

  cfg_params <- c(
    sprintf("  name = %s",            ob_safe_quote(answers$study_name %||% "My first inrep study")),
    sprintf("  model = %s",           ob_safe_quote(model)),
    sprintf("  adaptive = %s",        if (adaptive) "TRUE" else "FALSE"),
    sprintf("  min_items = %s",       if (adaptive) "5" else "NULL"),
    sprintf("  max_items = %s",       as.character(max_items_val)),
    sprintf("  primary_lang = %s",    ob_safe_quote(langs[[1]])),
    if (length(langs) > 1) sprintf("  languages = %s",
      paste0("c(", paste(vapply(langs, ob_safe_quote, character(1)), collapse = ", "), ")")) else NULL,
    sprintf("  show_debriefing = %s", if (show_debrief) "TRUE" else "FALSE"),
    sprintf("  theme = %s",           ob_safe_quote("dark"))
  )
  cfg_params <- cfg_params[!vapply(cfg_params, is.null, logical(1))]

  adaptive_notes <- if (adaptive) c(
    "# Note: adaptive mode requires the TAM package and IRT item parameters (a, b) in your item bank.",
    "# Tune stopping rules (min_items, max_items, min_SEM) after a piloting run.",
    "# Item selection criterion: default is 'MEI'; alternatives: 'MI', 'MFI', 'RANDOM'.",
    ""
  ) else character(0)

  paste(c(
    "# ==================================================================",
    sprintf("# Generated by inrep-studio onboarding \u00b7 %s", format(Sys.time(), "%Y-%m-%d %H:%M")),
    "# Open in inrep-studio to add result scales, colours, and preview.",
    "# ==================================================================",
    "library(inrep)",
    "",
    adaptive_notes,
    "study_config <- inrep::create_study_config(",
    paste(cfg_params, collapse = ",\n"),
    ")",
    "",
    sprintf("inrep::launch_study(study_config, %s, session_save = TRUE)", bank)
  ), collapse = "\n")
}

nrow_estimate <- function(dom) {
  switch(dom, personality = 20L, cognitive = 30L, math = 25L, resilience = 30L, custom = 10L, 20L)
}

# -----------------------------------------------------------------------------
# UI atoms ÔÇö written as raw HTML so the dark theme stays pixel-precise without
# fighting Bootstrap. Shiny still wires inputs via shiny::tags and JS bindings.
# -----------------------------------------------------------------------------
ob_css <- function() {
  tags$style(HTML("
    /* ÔöÇÔöÇ Light mode (default) ÔÇö mirrors inrep-studio's clean professional look ÔöÇÔöÇ */
    :root {
      --bg: #F8FAFB; --surf: #FFFFFF; --surf2: #F1F4F7; --surf3: #E8EDF2;
      --bord: rgba(44,62,80,0.09); --bord-s: rgba(44,62,80,0.16);
      --text: #2C3E50; --text-2: rgba(44,62,80,0.68);
      --text-3: rgba(44,62,80,0.46); --text-4: rgba(44,62,80,0.28);
      --mint: #2c3e50; --mint-dim: rgba(44,62,80,0.10);
      --mint-bord: rgba(44,62,80,0.30); --ink: #FFFFFF;
      --sans: 'Geist', -apple-system, system-ui, sans-serif;
      --serif: 'Instrument Serif', 'Times New Roman', serif;
      --mono: 'JetBrains Mono', ui-monospace, monospace;
    }
    /* Onboarding is light mode only */
    html, body { margin:0; padding:0; background:var(--bg); color:var(--text);
      font-family:var(--sans); -webkit-font-smoothing:antialiased; }
    html, body { overflow-x: hidden; }
    * { box-sizing: border-box; }

    .ob-shell { max-width: 760px; margin: 0 auto; padding: 24px 22px 48px; min-height: 100vh;
      display: flex; flex-direction: column; }
    .ob-top { display:flex; align-items:center; justify-content:space-between; margin-bottom: 28px; }
    .ob-back { width: 36px; height: 36px; border-radius: 18px; background: var(--surf2);
      border: 1px solid var(--bord); display: grid; place-items: center; cursor: pointer; color: var(--text); }
    .ob-back[disabled] { opacity: 0; pointer-events: none; }
    .ob-dots { display:flex; gap:4px; align-items:center; }
    .ob-dots span { display:block; width:6px; height:3px; border-radius:2px; background: var(--bord-s); transition: width .2s; }
    .ob-dots span.on { width: 18px; background: var(--mint); }
    .ob-top-right { display:inline-flex; align-items:center; gap:8px; }
    .ob-lang-chip {
      height: 28px; min-width: 36px; padding: 0 10px;
      border-radius: 99px; border: 1px solid var(--bord);
      background: var(--surf2); color: var(--text-2);
      display: inline-flex; align-items: center; justify-content: center;
      font: 600 12px/1 var(--mono); letter-spacing: .3px;
    }
    .ob-close-btn {
      width: 28px; height: 28px; border-radius: 99px;
      border: 1px solid var(--bord); background: var(--surf2);
      color: var(--text-2); display: grid; place-items: center;
      cursor: pointer; font: 600 12px/1 var(--sans);
    }
    .ob-close-btn:hover { background: var(--surf3); color: var(--text); }
    .ob-lang-pill { display:none !important; }
    .ob-darkmode-btn { display: none !important; }

    .ob-h1 { font: 500 28px/1.12 var(--sans); letter-spacing: -0.6px; color: var(--text); margin: 0; }
    .ob-lede { font: 400 15px/1.45 var(--sans); color: var(--text-2); margin: 10px 0 0; letter-spacing: -0.1px; }
    .ob-label { font: 500 12px/1 var(--sans); color: var(--text-3); text-transform: uppercase;
      letter-spacing: .8px; margin-bottom: 8px; padding-left: 2px; }

    .ob-body { flex: 1; padding-top: 12px; }
    .ob-actions { padding-top: 24px; display: flex; gap: 10px; }

    .ob-btn { height: 54px; border-radius: 16px; border: none; cursor: pointer;
      font: 600 16px/1 var(--sans); letter-spacing: -0.1px; padding: 0 22px;
      display: inline-flex; align-items: center; justify-content: center; gap: 8px; }
    .ob-btn-primary { background: var(--mint); color: var(--ink); flex: 1; }
    .ob-btn-primary[disabled] { background: var(--mint-dim); color: var(--text-3); cursor: default; }
    .ob-btn-ghost { background: transparent; color: var(--text); border: 1px solid var(--bord-s);
      font-weight: 500; font-size: 15px; }

    .ob-card { background: var(--surf); border:1px solid var(--bord); border-radius: 14px; padding: 14px 16px;
      display: flex; align-items: center; gap: 14px; margin-bottom: 8px; cursor: pointer;
      transition: background .12s, border-color .12s; }
    .ob-card:hover { background: var(--surf2); }
    .ob-card.sel { background: var(--mint-dim); border-color: var(--mint-bord); }
    .ob-card .ob-card-title { font: 500 16px/1.15 var(--sans); color: var(--text); letter-spacing: -.2px; }
    .ob-card .ob-card-sub { font: 400 12px/1.2 var(--mono); color: var(--text-3); margin-top: 3px; letter-spacing: .1px; }
    .ob-card .ob-mark { width: 22px; height: 22px; border-radius: 11px; border: 1.5px solid var(--bord-s);
      display: grid; place-items: center; flex: 0 0 22px; }
    .ob-card .ob-mark.checkbox { border-radius: 6px; }
    .ob-card.sel .ob-mark { background: var(--mint); border-color: var(--mint); }
    .ob-card.sel .ob-mark svg { display: block; }
    .ob-card .ob-mark svg { display: none; }
    .ob-check-path { stroke: var(--ink); }
    .ob-flag { width: 40px; height: 40px; border-radius: 12px; background: var(--surf3);
      border: 1px solid var(--bord); display: grid; place-items: center;
      font: 600 12px/1 var(--mono); color: var(--text-2); letter-spacing: .5px; flex: 0 0 40px;
      text-transform: uppercase; }

    .ob-input { width: 100%; height: 54px; border-radius: 14px;
      background: var(--surf); border: 1px solid var(--bord); padding: 0 16px;
      color: var(--text); font: 500 16px/1 var(--sans); letter-spacing: -0.1px; }
    .ob-input:focus { outline: none; border-color: var(--mint-bord); box-shadow: 0 0 0 4px var(--mint-dim); }
    .ob-input::placeholder { color: var(--text-4); }

    .ob-grid2 { display:grid; grid-template-columns: 1fr 1fr; gap: 8px; }
    .ob-pill { padding: 9px 14px 9px 11px; border-radius: 99px; background: var(--surf);
      border:1px solid var(--bord); color: var(--text-2); font: 500 13px/1 var(--sans);
      display: inline-flex; align-items: center; gap: 8px; cursor: pointer; user-select: none; }
    .ob-pill.sel { background: var(--mint-dim); border-color: var(--mint-bord); color: var(--mint); }

    /* hero logo (studio isometric SVG) */
    .ob-hero-logo {
      width: 100%;
      display: flex;
      justify-content: center;
      overflow: hidden;
      line-height: 0;
      margin-bottom: -26px;
      flex-shrink: 0;
    }
    .ob-hero-logo svg {
      width: min(175vw, 760px) !important;
      height: auto !important;
      display: block;
      max-width: none;
      margin-bottom: -14px;
      vertical-align: top;
    }
    .ob-hero-brand { display: flex; align-items: baseline; gap: 0; margin-bottom: 2px; }
    .ob-hero-name { font: 800 32px/1 var(--sans); letter-spacing: -1px; color: var(--text); text-transform: lowercase; }
    .ob-hero-tag  { font: 400 22px/1 var(--sans); color: var(--text-2); letter-spacing: -.4px; }

    /* mobile */
@media (max-width: 600px) {
      .ob-shell {
        padding: 16px 14px 36px;
        overflow-x: hidden;
      }

      .ob-h1 {
        font-size: 23px;
      }

      .ob-hero-logo {
        width: 100%;
        display: flex;
        justify-content: center;
        overflow: hidden;
        margin-bottom: -10px;
      }

      .ob-hero-logo svg {
        width: min(175vw, 620px) !important;
        height: auto !important;
        display: block;
      }


      .ob-hero-name {
        font-size: 26px;
      }

      .ob-hero-tag {
        font-size: 18px;
      }

      .ob-grid2 {
        grid-template-columns: 1fr;
      }

      .ob-btn {
        height: 48px;
        font-size: 15px;
      }

      .ob-card {
        padding: 12px 14px;
      }

      .ob-card .ob-card-title {
        font-size: 14px;
      }
    }

    /* review */
    .ob-review { display: grid; grid-template-columns: 1fr; gap: 16px; }
    .ob-panel { background: var(--surf); border: 1px solid var(--bord); border-radius: 18px; padding: 18px; }
    .ob-panel-title { font: 500 12px/1 var(--sans); color: var(--text-3); text-transform: uppercase;
      letter-spacing: 1px; margin-bottom: 12px; }
    .ob-code { font: 400 12.5px/1.55 var(--mono); color: var(--text); white-space: pre;
      overflow: auto; background: var(--surf2); border: 1px solid var(--bord);
      border-radius: 12px; padding: 14px 16px; max-height: 420px; }
    .ob-footer { text-align: center; font: 400 11px/1.4 var(--mono);
      color: var(--text-4); letter-spacing: .2px; margin-top: 22px; }
  "))
}

ob_fonts <- function() {
  HTML('<link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Geist:wght@300;400;500;600;700&family=Instrument+Serif:ital@0;1&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">')
}

# JS bridge: lets simple <div>/<button> elements set Shiny inputs without
# pulling in Bootstrap radio components ÔÇö keeps the visual exactly on-brand.
# The studio URL is injected as a JS constant so it works for local dev too.
ob_js <- function(studio_url = ONBOARDING_STUDIO_URL) {
  tags$script(HTML(sprintf("
    var INREP_STUDIO_URL = %s;
    var INREP_ONBOARDING_STATE_KEY = 'inrep_onboarding_state_v1';

    function obReadSavedState() {
      try {
        var raw = localStorage.getItem(INREP_ONBOARDING_STATE_KEY);
        return raw ? JSON.parse(raw) : null;
      } catch(e) {
        return null;
      }
    }
    function obSaveState(stateObj) {
      try {
        localStorage.setItem(INREP_ONBOARDING_STATE_KEY, JSON.stringify(stateObj || {}));
      } catch(e) {}
    }
    function obMergeState(patch) {
      var cur = obReadSavedState() || {};
      for (var k in patch) {
        if (Object.prototype.hasOwnProperty.call(patch, k)) cur[k] = patch[k];
      }
      obSaveState(cur);
      return cur;
    }

    function obCloseOnboarding() {
      window.location.href = INREP_STUDIO_URL;
    }

    (function restoreOnLoad() {
      var saved = obReadSavedState();
      if (!saved) return;
      function sendRestore() {
        if (window.Shiny && Shiny.setInputValue) {
          Shiny.setInputValue('ob_restore_state', JSON.stringify(saved), {priority: 'event'});
        }
      }
      if (window.Shiny && Shiny.setInputValue) sendRestore();
      else document.addEventListener('shiny:sessioninitialized', sendRestore, {once: true});
    })();

    document.addEventListener('input', function(evt) {
      var t = evt && evt.target;
      if (!t || !t.id) return;
      if (t.id === 'name' || t.id === 'institution' || t.id === 'study_name') {
        var p = {}; p[t.id] = t.value || '';
        obMergeState(p);
      }
      if (t.id === 'max_items') {
        obMergeState({max_items: parseInt(t.value, 10) || 10});
      }
    });

    function obSet(name, value) {
      var p = {}; p[name] = value;
      obMergeState(p);
      if (window.Shiny && Shiny.setInputValue) {
        Shiny.setInputValue(name, value, {priority: 'event'});
      }
    }
    function obToggle(name, value) {
      const el = document.querySelector(`[data-ob-multi='${name}']`);
      if (!el) return obSet(name, [value]);
      let cur = JSON.parse(el.getAttribute('data-ob-val') || '[]');
      const i = cur.indexOf(value);
      if (i >= 0) cur.splice(i, 1); else cur.push(value);
      el.setAttribute('data-ob-val', JSON.stringify(cur));
      el.querySelectorAll('[data-ob-opt]').forEach(c => {
        c.classList.toggle('sel', cur.indexOf(c.getAttribute('data-ob-opt')) >= 0);
      });
      var p = {}; p[name] = cur;
      obMergeState(p);
      obSet(name, cur);
    }
    function obCopy(text) {
      navigator.clipboard.writeText(text).then(() => {
        const btn = document.getElementById('ob-copy-btn');
        if (btn) { const old = btn.textContent; btn.textContent = '\\u2713'; setTimeout(()=>btn.textContent=old, 1200); }
      });
    }

    // Build a studio-compatible config payload from raw onboarding answers.
    // Defensive array handling: toJSON(auto_unbox=TRUE) serialises length-1
    // R vectors as plain strings, so we normalise them back to arrays here.
    function obBuildStudioPayload(raw) {
      var rawDoms = raw.domains;
      var doms = Array.isArray(rawDoms) ? rawDoms
                 : (typeof rawDoms === 'string' && rawDoms.length > 0 ? [rawDoms] : ['personality']);
      var dom = doms.length > 0 ? doms[0] : 'personality';
      var irtModel = (['cognitive', 'math'].indexOf(dom) >= 0) ? '2PL' : 'GRM';
      var adaptive  = raw.mode === 'adaptive';
      var rawLangs  = raw.part_langs;
      var partLangs = Array.isArray(rawLangs) ? rawLangs
                      : (typeof rawLangs === 'string' && rawLangs.length > 0 ? [rawLangs] : []);
      var primaryLang = partLangs.length > 0 ? partLangs[0] : (raw.ui_lang || 'en');
      return {
        // Studio-native fields
        study_name:        raw.study_name || 'My inrep Study',
        adaptive:          adaptive,
        irt_model:         irtModel,
        primary_lang:      primaryLang,
        // Onboarding metadata (for welcome note in studio)
        _ob_name:          raw.name         || '',
        _ob_institution:   raw.institution  || '',
        _ob_role:          raw.role         || '',
        _ob_domains:       doms,
        _ob_part_langs:    partLangs,
        _ob_report_page:   raw.report_page  || 'yes',
        _ob_max_items:     raw.max_items    || 10,
        _ob_n_pages:       raw.max_items    || 10,
        _ob_ui_lang:       raw.ui_lang      || 'en'
      };
    }

    // Hand off to studio:
    //   framed  ÔåÆ postMessage to parent frame
    //   standalone ÔåÆ open studio in new tab with URL hash payload
    function obOpenInStudio(rawPayload) {
      obSaveState(rawPayload || {});
      var payload = obBuildStudioPayload(rawPayload);
      // Try postMessage first (framed / same-origin)
      try {
        if (window.parent && window.parent !== window) {
          window.parent.postMessage(
            { type: 'inrep-studio:onboarding-complete', payload: payload }, '*');
          return;
        }
      } catch(e) {}
      // Standalone: open studio in same tab with hash-encoded payload
      var enc = encodeURIComponent(JSON.stringify(payload));
      window.location.href = INREP_STUDIO_URL + '#inrep-onboarding=' + enc;
    }
  ", jsonlite::toJSON(studio_url, auto_unbox = TRUE))))
}

# Step bar with N filled dots.
ob_dots <- function(step, total = 6) {
  tags$div(class = "ob-dots",
    lapply(seq_len(total), function(i) tags$span(class = if (i <= step) "on" else ""))
  )
}

ob_check_svg <- function() {
  # stroke is set via .ob-check-path CSS rule ÔåÆ adapts to --ink in both light and dark mode
  HTML('<svg width="12" height="12" viewBox="0 0 12 12"><path d="M2.5 6.2l2.4 2.4 4.6-5" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round" class="ob-check-path"/></svg>')
}

# Single selectable card (radio-style).
ob_card_radio <- function(input_name, value, title, sub = NULL, selected = FALSE) {
  tags$div(
    class = paste("ob-card", if (selected) "sel" else ""),
    onclick = sprintf("obSet('%s', '%s')", input_name, value),
    `data-ob-opt` = value,
    tags$div(class = "ob-flag", substr(toupper(value), 1, 2)),
    tags$div(style = "flex:1;",
      tags$div(class = "ob-card-title", title),
      if (!is.null(sub)) tags$div(class = "ob-card-sub", sub)
    ),
    tags$div(class = "ob-mark", ob_check_svg())
  )
}

ob_card_check <- function(input_name, value, title, sub = NULL, selected = FALSE) {
  tags$div(
    class = paste("ob-card", if (selected) "sel" else ""),
    onclick = sprintf("obToggle('%s', '%s')", input_name, value),
    `data-ob-opt` = value,
    tags$div(style = "flex:1;",
      tags$div(class = "ob-card-title", title),
      if (!is.null(sub)) tags$div(class = "ob-card-sub", sub)
    ),
    tags$div(class = "ob-mark checkbox", ob_check_svg())
  )
}

# -----------------------------------------------------------------------------
# UI ÔÇö single page, server toggles which step is visible via conditionalPanel
# -----------------------------------------------------------------------------
onboarding_ui <- function() {
  tagList(
    ob_fonts(), ob_css(), ob_js(ONBOARDING_STUDIO_URL),
    tags$div(class = "ob-shell",
      uiOutput("ob_screen"),
      uiOutput("ob_footer")
    )
  )
}

# -----------------------------------------------------------------------------
# Server
# -----------------------------------------------------------------------------
onboarding_server <- function(input, output, session) {

  state <- reactiveValues(
    step        = 0L,             # 0 = splash, 1..7 = questions, 8 = review
    ui_lang     = "en",
    name        = "",
    role        = "researcher",
    institution = "",
    domains     = c("personality"),
    study_name  = "",
    mode        = "adaptive",
    max_items   = 10L,
    part_langs  = c("en"),
    report_page = "yes"
  )

  observeEvent(input$ui_lang,     { state$ui_lang     <- input$ui_lang },     ignoreInit = TRUE)
  observeEvent(input$role,        { state$role        <- input$role },        ignoreInit = TRUE)
  observeEvent(input$mode,        { state$mode        <- input$mode },        ignoreInit = TRUE)
  observeEvent(input$domains,     { state$domains     <- input$domains },     ignoreInit = TRUE)
  observeEvent(input$max_items,   { state$max_items   <- as.integer(input$max_items %||% 10L) }, ignoreInit = TRUE)
  observeEvent(input$part_langs,  { state$part_langs  <- input$part_langs },  ignoreInit = TRUE)
  observeEvent(input$report_page, { state$report_page <- input$report_page }, ignoreInit = TRUE)
  observeEvent(input$name,        { state$name <- input$name %||% "" }, ignoreInit = TRUE)
  observeEvent(input$institution, { state$institution <- input$institution %||% "" }, ignoreInit = TRUE)
  observeEvent(input$study_name,  { state$study_name <- input$study_name %||% "" }, ignoreInit = TRUE)

  observeEvent(input$ob_restore_state, {
    restored <- tryCatch(
      jsonlite::fromJSON(input$ob_restore_state, simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (is.null(restored)) return()

    state$ui_lang <- restored$ui_lang %||% state$ui_lang
    state$name <- restored$name %||% state$name
    state$role <- restored$role %||% state$role
    state$institution <- restored$institution %||% state$institution
    state$study_name <- restored$study_name %||% state$study_name
    state$mode <- restored$mode %||% state$mode
    state$max_items <- as.integer(restored$max_items %||% state$max_items)
    state$report_page <- restored$report_page %||% state$report_page

    if (!is.null(restored$domains)) {
      state$domains <- unlist(restored$domains, use.names = FALSE)
      if (length(state$domains) == 0) state$domains <- c("personality")
    }
    if (!is.null(restored$part_langs)) {
      state$part_langs <- unlist(restored$part_langs, use.names = FALSE)
      if (length(state$part_langs) == 0) state$part_langs <- c(state$ui_lang %||% "en")
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

  # ÔöÇÔöÇ nav
  observeEvent(input$ob_next,  { state$step <- min(state$step + 1L, 8L) })
  observeEvent(input$ob_back,  { state$step <- max(state$step - 1L, 0L) })
  observeEvent(input$ob_start, { state$step <- 1L })
  observeEvent(input$ob_reset_step, { state$step <- 0L }, ignoreInit = TRUE, ignoreNULL = TRUE)

  output$ob_footer <- renderUI({
    t <- function(k) ob_t(state$ui_lang, k)
    if (state$step == 0L) tags$div(class = "ob-footer", t("footer")) else NULL
  })

  output$ob_screen <- renderUI({
    t <- function(k) ob_t(state$ui_lang, k)
    s <- state$step

    # Top bar: back button + dot progress + dark-mode toggle + lang pill.
    top <- tags$div(class = "ob-top",
      tags$button(class = "ob-back", id = "ob_back_btn",
        onclick = "Shiny.setInputValue('ob_back', Math.random())",
        if (s > 0 && s < 8) HTML('<svg width="9" height="16" viewBox="0 0 9 16" fill="none"><path d="M8 1L1 8l7 7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>') else "",
        `disabled` = if (s == 0 || s == 8) NA else NULL
      ),
      if (s >= 1 && s <= 7) ob_dots(s, total = 7) else tags$div(),
      tags$div(class = "ob-top-right",
        tags$span(class = "ob-lang-chip", toupper(state$ui_lang %||% "en")),
        tags$button(class = "ob-close-btn", type = "button", onclick = "obCloseOnboarding()", "\u00d7")
      )
    )

    body <- switch(as.character(s),
      "0" = ob_step_splash(state, t),
      "1" = ob_step_lang(state, t),
      "2" = ob_step_role(state, t),
      "3" = ob_step_domains(state, t),
      "4" = ob_step_study(state, t),
      "5" = ob_step_pages(state, t),
      "6" = ob_step_part_langs(state, t),
      "7" = ob_step_report(state, t),
      "8" = ob_step_review(state, t)
    )

    tagList(top, body)
  })

  # Ensure outputs render even while the onboarding div is hidden (display:none)
  outputOptions(output, "ob_screen", suspendWhenHidden = FALSE)
  outputOptions(output, "ob_footer", suspendWhenHidden = FALSE)
}

# -----------------------------------------------------------------------------
# Steps
# -----------------------------------------------------------------------------
ob_step_splash <- function(state, t) {
  tagList(
    tags$div(class = "ob-body",
      tags$div(class = "ob-hero-logo",
        HTML('<svg viewBox="-60 -50 140 88" xmlns="http://www.w3.org/2000/svg" shape-rendering="geometricPrecision" style="width:90px;height:90px;">
  <defs>
    <linearGradient id="obActiveViolet" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#A78BFA" />
      <stop offset="100%" stop-color="#7C3AED" />
    </linearGradient>
    <filter id="obGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="0.4" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <g stroke="#1F2937" stroke-linejoin="round" stroke-linecap="round" stroke-width="1.0">
    <g transform="translate(-18, -10)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
    </g>
    <g transform="translate(18, -10)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
      <g transform="translate(22, 5)" stroke="#60A5FA" stroke-width="0.8" filter="url(#obGlow)">
        <line x1="1" y1="12" x2="1" y2="8" />
        <line x1="4" y1="12" x2="4" y2="2" />
        <line x1="7" y1="12" x2="7" y2="6" />
        <line x1="10" y1="12" x2="10" y2="3" />
      </g>
    </g>
    <g transform="translate(0, 0)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
      <g transform="translate(18, 8)" fill="none" filter="url(#obGlow)">
        <path d="M2 10 L5 2 L8 12" stroke="#94A3B8" stroke-width="0.6" opacity="0.4" />
        <path d="M8 12 L9 8 L10 11 L11 7 L12 9 L13 6 L14 8 L15 5" stroke="#BAE6FD" stroke-width="0.7" />
        <circle cx="15" cy="5" r="0.7" fill="#BAE6FD" stroke="none" />
      </g>
    </g>
    <g transform="translate(-36, 0)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="url(#obActiveViolet)"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#7C3AED"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#5B21B6"/>
    </g>
  </g>
</svg>')
      ),
      tags$div(class = "ob-hero-brand",
        tags$span(class = "ob-hero-name", "inrep"),
        tags$span(class = "ob-hero-tag", " Studio")
      ),
      tags$p(style = "font:400 17px/1.4 var(--sans);letter-spacing:-.2px;color:var(--text-2);max-width:420px;margin-top:18px;",
        t("intro"))
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_start", t("start"), class = "ob-btn ob-btn-primary"),
      # Skip: open studio directly with sensible defaults (no review step needed)
      tags$button(class = "ob-btn ob-btn-ghost",
        onclick = sprintf(
          "obOpenInStudio(%s)",
          jsonlite::toJSON(list(
            study_name  = "My inrep Study",
            mode        = "adaptive",
            domains     = list("personality"),
            ui_lang     = "en",
            part_langs  = list("en"),
            name        = "",
            institution = "",
            role        = "researcher",
            max_items   = 15L,
            report_page = "yes"
          ), auto_unbox = TRUE, null = "null")
        ),
        t("skip")
      )
    )
  )
}

ob_step_lang <- function(state, t) {
  cards <- lapply(ONBOARDING_LANG_LIST, function(L) {
    ob_card_radio("ui_lang", L$code, L$native, L$name, selected = identical(state$ui_lang, L$code))
  })
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_lang_title")),
      tags$p(class = "ob-lede", t("q_lang_sub")),
      tags$div(style = "margin-top:22px;", cards)
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_role <- function(state, t) {
  roles <- list(researcher = t("role_researcher"), lecturer = t("role_lecturer"),
                student    = t("role_student"),   other    = t("role_other"))
  role_grid <- tags$div(class = "ob-grid2",
    lapply(names(roles), function(k) {
      sel <- identical(state$role, k)
      tags$div(class = paste("ob-card", if (sel) "sel" else ""),
        style = "min-height: 50px;",
        onclick = sprintf("obSet('role', '%s')", k),
        tags$div(class = "ob-mark", style = "width:16px;height:16px;flex:0 0 16px;border-radius:8px;",
          tags$div(style = "width:6px;height:6px;border-radius:3px;background:#0B0B0F;",
            if (!sel) tagAppendAttributes(tags$div(), style = "display:none"))),
        tags$div(class = "ob-card-title", style = "font-size:15px;", roles[[k]])
      )
    })
  )

  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_role_title")),
      tags$p(class = "ob-lede", t("q_role_sub")),
      tags$div(style = "margin-top:24px;",
        tags$div(class = "ob-label", t("q_role_name")),
        tags$input(class = "ob-input", id = "name", type = "text",
                   value = isolate(state$name), placeholder = "Jane Doe",
                   oninput = "Shiny.setInputValue('name', this.value)"),
        tags$div(class = "ob-label", style = "margin-top:18px;", t("q_role_role")),
        role_grid,
        tags$div(class = "ob-label", style = "margin-top:18px;", t("q_role_inst")),
        tags$input(class = "ob-input", id = "institution", type = "text",
                   value = isolate(state$institution), placeholder = "Universit\u00e4t Hildesheim",
                   oninput = "Shiny.setInputValue('institution', this.value)")
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_domains <- function(state, t) {
  doms <- list(
    list(k = "personality", title = t("dom_personality"), sub = "bfi_items"),
    list(k = "cognitive",   title = t("dom_cognitive"),   sub = "cognitive_items"),
    list(k = "math",        title = t("dom_math"),        sub = "math_items"),
    list(k = "resilience",  title = t("dom_resilience"),  sub = "rcq_items / rcqL_items"),
    list(k = "custom",      title = t("dom_custom"),      sub = "your CSV")
  )
  cur <- state$domains %||% character()
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_dom_title")),
      tags$p(class = "ob-lede", t("q_dom_sub")),
      tags$div(`data-ob-multi` = "domains",
        `data-ob-val` = jsonlite::toJSON(cur, auto_unbox = FALSE),
        style = "margin-top:22px;",
        lapply(doms, function(d) ob_card_check("domains", d$k, d$title, d$sub, selected = d$k %in% cur))
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_study <- function(state, t) {
  modes <- list(
    list(k = "adaptive", title = t("mode_adaptive")),
    list(k = "fixed",    title = t("mode_fixed"))
  )
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_study_title")),
      tags$p(class = "ob-lede", t("q_study_sub")),
      tags$div(style = "margin-top:22px;",
        tags$div(class = "ob-label", t("q_study_name")),
        tags$input(class = "ob-input", id = "study_name", type = "text",
                   value = isolate(state$study_name), placeholder = "HilFo 2026",
                   oninput = "Shiny.setInputValue('study_name', this.value)"),
        tags$div(class = "ob-label", style = "margin-top:22px;", t("q_study_mode")),
        lapply(modes, function(m) {
          sel <- identical(state$mode, m$k)
          tags$div(class = paste("ob-card", if (sel) "sel" else ""),
            onclick = sprintf("obSet('mode','%s')", m$k),
            tags$div(style = "flex:1;",
              tags$div(class = "ob-card-title", m$title)
            ),
            tags$div(class = "ob-mark", ob_check_svg())
          )
        })
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_pages <- function(state, t) {
  cur_val <- as.integer(isolate(state$max_items) %||% 10L)
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_pages_title")),
      tags$p(class = "ob-lede", t("q_pages_sub")),
      tags$div(style = "margin-top: 28px;",
        tags$div(class = "ob-label", t("q_pages_label")),
        tags$input(
          class = "ob-input", id = "max_items", type = "number",
          value = cur_val, min = "1", max = "500",
          style = "max-width: 200px;",
          oninput = "Shiny.setInputValue('max_items', parseInt(this.value) || 10)"
        ),
        tags$p(style = "font: 400 12px/1.4 var(--mono); color: var(--text-3); margin-top: 8px;",
          t("q_pages_tip"))
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_part_langs <- function(state, t) {  cur <- state$part_langs %||% character()
  pills <- lapply(ONBOARDING_LANG_LIST, function(L) {
    sel <- L$code %in% cur
    tags$div(class = paste("ob-pill", if (sel) "sel" else ""),
      `data-ob-opt` = L$code,
      onclick = sprintf("obToggle('part_langs','%s')", L$code),
      if (sel) HTML('<svg width="11" height="11" viewBox="0 0 12 12"><path d="M2.5 6.2l2.4 2.4 4.6-5" stroke="#FFFFFF" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>'),
      L$native
    )
  })
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_part_title")),
      tags$p(class = "ob-lede", t("q_part_sub")),
      tags$div(`data-ob-multi` = "part_langs",
        `data-ob-val` = jsonlite::toJSON(cur, auto_unbox = FALSE),
        style = "margin-top:22px; display:flex; flex-wrap:wrap; gap:8px;",
        pills
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

# Step 6: results / report page
ob_step_report <- function(state, t) {
  choices <- list(
    list(k = "yes", title = t("report_yes")),
    list(k = "no",  title = t("report_no"))
  )
  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("q_report_title")),
      tags$p(class = "ob-lede", t("q_report_sub")),
      tags$div(style = "margin-top:22px;",
        lapply(choices, function(ch) {
          sel <- identical(state$report_page, ch$k)
          tags$div(class = paste("ob-card", if (sel) "sel" else ""),
            onclick = sprintf("obSet('report_page','%s')", ch$k),
            tags$div(style = "flex:1;",
              tags$div(class = "ob-card-title", ch$title)
            ),
            tags$div(class = "ob-mark", ob_check_svg())
          )
        })
      )
    ),
    tags$div(class = "ob-actions",
      actionButton("ob_next", t("cm_continue"), class = "ob-btn ob-btn-primary")
    )
  )
}

ob_step_review <- function(state, t) {
  # Use as.list() so length-1 vectors serialise as JSON arrays, not plain strings
  answers <- list(
    ui_lang     = state$ui_lang,
    role        = state$role,
    name        = state$name,
    institution = state$institution,
    domains     = as.list(state$domains),    # ensures ["personality"] not "personality"
    study_name  = state$study_name %||% "My first inrep study",
    mode        = state$mode,
    max_items   = as.integer(state$max_items %||% 10L),
    part_langs  = as.list(state$part_langs), # ensures ["en"] not "en"
    report_page = state$report_page %||% "yes"
  )
  r_code  <- ob_build_config_code(answers)
  payload <- jsonlite::toJSON(answers, auto_unbox = TRUE, null = "null")

  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("review_title")),
      tags$p(class = "ob-lede", t("review_sub")),
      tags$div(class = "ob-review", style = "margin-top: 24px;",
        tags$div(class = "ob-panel",
          tags$div(class = "ob-panel-title", t("review_config")),
          tags$pre(class = "ob-code", id = "ob-code-block", r_code),
          tags$div(style = "display:flex; gap:8px; margin-top:12px;",
            tags$button(class = "ob-btn ob-btn-ghost", id = "ob-copy-btn",
              style = "height:40px;font-size:13px;padding:0 14px;",
              onclick = "obCopy(document.getElementById('ob-code-block').textContent)",
              t("review_copy"))
          )
        )
      )
    ),
    tags$div(class = "ob-actions",
      tags$button(class = "ob-btn ob-btn-ghost",
        onclick = "Shiny.setInputValue('ob_back', Math.random())", t("review_back")),
      tags$button(class = "ob-btn ob-btn-primary",
        onclick = sprintf("obOpenInStudio(%s)", payload),
        t("review_open"))
    )
  )
}

# -----------------------------------------------------------------------------
# Entry points
# -----------------------------------------------------------------------------

# Construct a shinyApp object ÔÇö what runApp() expects, and what the host
# studio's router can return when the URL matches /onboarding.
onboarding_app <- function() {
  shiny::shinyApp(
    ui     = onboarding_ui(),
    server = onboarding_server,
    options = list(launch.browser = FALSE)
  )
}

# When the host studio mounts this on a sub-path, it can call
# `onboarding_attach(input, output, session)` from within its top-level
# server function instead of running a separate app. Both entry points share
# the same UI/server pair.
onboarding_attach <- function(input, output, session) {
  onboarding_server(input, output, session)
}

# Run standalone if sourced directly (e.g. for local testing).
if (sys.nframe() == 0L) {
  shiny::runApp(onboarding_app())
}
