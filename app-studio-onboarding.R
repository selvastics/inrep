# =============================================================================
# inrep-studio-onboarding.R
# -----------------------------------------------------------------------------
# Lightweight Shiny app that walks a new user through 6 onboarding questions
# and hands back a ready-to-edit `create_study_config()` call that can be
# opened directly in inrep-studio for visual refinement.
#
# Two deployment modes:
#  1. Standalone  — run as a separate Shiny app (e.g. shinyapps.io).
#     "Open in studio" opens the studio URL in a new tab, passing the config
#     via URL hash: <STUDIO_URL>#inrep-onboarding=<URL-encoded JSON>.
#     The studio reads this hash on load and pre-fills its inputs.
#
#  2. Framed      — embedded as an <iframe> inside the studio app.
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

# Studio URL — override via INREP_STUDIO_URL env var for local dev.
# Points at the live inrep-studio deployment by default.
ONBOARDING_STUDIO_URL <- {
  env <- Sys.getenv("INREP_STUDIO_URL", "")
  if (nzchar(env)) env else "https://selvastics.shinyapps.io/inrep-studio/"
}

# -----------------------------------------------------------------------------
# i18n dictionary — kept inline so the file is single-source and droppable.
# Keys mirror those used by the iOS mock so copy stays consistent.
# -----------------------------------------------------------------------------
ONBOARDING_I18N <- list(
  en = list(
    tagline = "studio",
    intro   = "Answer six short questions. We'll generate your first inrep study, ready to open in the studio.",
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
    mode_adaptive   = "Adaptive — fewer items, personalised",
    mode_fixed      = "Fixed order — same items, same order",

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
    intro   = "Beantworte sechs kurze Fragen. Wir erzeugen daraus deine erste inrep-Studie.",
    start   = "Loslegen",
    skip    = "\u00dcberspringen \u2192 Mit Standards öffnen",
    footer  = "Aus dem inrep-Toolkit, Universität Hildesheim",

    q_lang_title    = "Sprache wählen",
    q_lang_sub      = "Jederzeit änderbar. Das Studio unterstützt Englisch, Deutsch, Spanisch und Französisch.",
    q_role_title    = "Erzähl uns von dir",
    q_role_sub      = "Daraus leiten wir passende Vorlagen ab.",
    q_role_name     = "Dein Name (optional)",
    q_role_role     = "Deine Rolle",
    role_researcher = "Forschend",
    role_lecturer   = "Lehrend",
    role_student    = "Studierend",
    role_other      = "Andere",
    q_role_inst     = "Einrichtung",

    q_dom_title     = "Was möchtest du erheben?",
    q_dom_sub       = "Wähle ein oder mehr. Wir laden passende Itembanks aus dem inrep-Paket.",
    dom_personality = "Persönlichkeit (BFI, 20 Items)",
    dom_cognitive   = "Kognitive Fähigkeit (adaptiv, IRT)",
    dom_math        = "Mathe-Reasoning (Graded Response)",
    dom_resilience  = "Resilienz & Coping (RCQ, 30/68 Items)",
    dom_custom      = "Eigene Itembank (CSV)",

    q_study_title   = "Erste Studie anlegen",
    q_study_sub     = "Im Studio kannst du alles feinjustieren.",
    q_study_name    = "Studienname",
    q_study_mode    = "Wie sollen Items ausgewählt werden?",
    mode_adaptive   = "Adaptiv — weniger Items, personalisiert",
    mode_fixed      = "Feste Reihenfolge — gleiche Items, gleiche Reihenfolge",

    q_part_title    = "Sprachen für Teilnehmende",
    q_part_sub      = "Welche Sprachen sehen Teilnehmende? Mehrfachauswahl möglich.",

    q_report_title  = "Ergebnisseite anzeigen?",
    q_report_sub    = "Sollen Teilnehmende am Ende eine persönliche Zusammenfassung sehen?",
    report_yes      = "Ja \u2014 Ergebnisse anzeigen",
    report_no       = "Nein \u2014 nach dem letzten Item beenden",

    review_title    = "Generierte Konfiguration",
    review_sub      = "Kopiere den R-Code oder klicke auf \u2018In inrep\u2011studio \u00f6ffnen\u2019 um den visuellen Editor mit diesen Einstellungen zu starten.",
    review_config   = "Generierter R-Code",
    review_preview  = "Teilnehmenden-Vorschau",
    review_open     = "In inrep\u2011studio öffnen \u2192",
    review_copy     = "R-Code kopieren",
    review_back     = "Zurück",

    cm_back         = "Zurück",
    cm_continue     = "Weiter",
    cm_step         = "Schritt %d von %d"
  ),
  es = list(
    tagline = "studio",
    intro   = "Responde seis preguntas cortas. Generaremos tu primer estudio inrep.",
    start   = "Empezar",
    skip    = "Saltar \u2192 Abrir con valores predeterminados",
    footer  = "Del kit de investigación inrep, Universidad de Hildesheim",

    q_lang_title    = "Elige tu idioma",
    q_lang_sub      = "Cámbialo cuando quieras. El studio admite inglés, alemán, español y francés.",
    q_role_title    = "Cuéntanos sobre ti",
    q_role_sub      = "Con esto sugerimos plantillas a tu medida.",
    q_role_name     = "Tu nombre (opcional)",
    q_role_role     = "Tu rol",
    role_researcher = "Investigador/a",
    role_lecturer   = "Docente",
    role_student    = "Estudiante",
    role_other      = "Otro",
    q_role_inst     = "Institución",

    q_dom_title     = "¿Qué quieres medir?",
    q_dom_sub       = "Elige uno o varios. Precargamos los bancos de ítems del paquete inrep.",
    dom_personality = "Personalidad (BFI, 20 ítems)",
    dom_cognitive   = "Habilidad cognitiva (adaptativo, TRI)",
    dom_math        = "Razonamiento matemático (respuesta graduada)",
    dom_resilience  = "Resiliencia y afrontamiento (RCQ, 30/68 ítems)",
    dom_custom      = "Banco propio (CSV)",

    q_study_title   = "Configura tu primer estudio",
    q_study_sub     = "Podrás afinarlo todo en el studio.",
    q_study_name    = "Nombre del estudio",
    q_study_mode    = "¿Cómo se eligen los ítems?",
    mode_adaptive   = "Adaptativo — menos ítems, personalizado",
    mode_fixed      = "Orden fijo — mismos ítems, mismo orden",

    q_part_title    = "Idiomas para participantes",
    q_part_sub      = "¿Qué idiomas verán los participantes? Selección múltiple permitida.",

    q_report_title  = "\u00bfMostrar página de resultados?",
    q_report_sub    = "\u00bfLos participantes verán un resumen personalizado al final del estudio?",
    report_yes      = "Sí \u2014 mostrar resumen de resultados",
    report_no       = "No \u2014 terminar tras el \u00faltimo ítem",

    review_title    = "Configuración generada",
    review_sub      = "Copia el código R o haz clic en \u2018Abrir en inrep\u2011studio\u2019 para iniciar el editor visual con esta configuración.",
    review_config   = "Código R generado",
    review_preview  = "Vista del participante",
    review_open     = "Abrir en inrep\u2011studio \u2192",
    review_copy     = "Copiar código R",
    review_back     = "Atrás",

    cm_back         = "Atrás",
    cm_continue     = "Continuar",
    cm_step         = "Paso %d de %d"
  ),
  fr = list(
    tagline = "studio",
    intro   = "Réponds à six questions courtes. On génère ta première étude inrep.",
    start   = "Commencer",
    skip    = "Passer \u2192 Ouvrir avec les réglages par défaut",
    footer  = "Issu de la boîte à outils inrep, Université de Hildesheim",

    q_lang_title    = "Choisis ta langue",
    q_lang_sub      = "Modifiable à tout moment. Le studio gère anglais, allemand, espagnol et français.",
    q_role_title    = "Parle-nous de toi",
    q_role_sub      = "Cela oriente les modèles proposés.",
    q_role_name     = "Ton nom (optionnel)",
    q_role_role     = "Ton rôle",
    role_researcher = "Chercheur·se",
    role_lecturer   = "Enseignant·e",
    role_student    = "Étudiant·e",
    role_other      = "Autre",
    q_role_inst     = "Établissement",

    q_dom_title     = "Que veux-tu mesurer ?",
    q_dom_sub       = "Choisis un ou plusieurs. On précharge les banques d'items du package inrep.",
    dom_personality = "Personnalité (BFI, 20 items)",
    dom_cognitive   = "Capacité cognitive (adaptatif, TRI)",
    dom_math        = "Raisonnement mathématique (réponse graduée)",
    dom_resilience  = "Résilience & coping (RCQ, 30/68 items)",
    dom_custom      = "Banque personnalisée (CSV)",

    q_study_title   = "Configure ta première étude",
    q_study_sub     = "Tout est affinable dans le studio.",
    q_study_name    = "Nom de l'étude",
    q_study_mode    = "Comment choisir les items ?",
    mode_adaptive   = "Adaptatif — moins d'items, personnalisé",
    mode_fixed      = "Ordre fixe — mêmes items, même ordre",

    q_part_title    = "Langues pour les participant·es",
    q_part_sub      = "Quelles langues verront-ils ? Sélection multiple possible.",

    q_report_title  = "Afficher une page de résultats ?",
    q_report_sub    = "À la fin, les participant\u00b7es verront-ils un résumé personnalisé ?",
    report_yes      = "Oui \u2014 afficher un résumé des résultats",
    report_no       = "Non \u2014 terminer après le dernier item",

    review_title    = "Configuration générée",
    review_sub      = "Copie le code R ou clique sur \u2018Ouvrir dans inrep\u2011studio\u2019 pour lancer l\u2019éditeur visuel avec ces réglages.",
    review_config   = "Code R généré",
    review_preview  = "Aperçu participant",
    review_open     = "Ouvrir dans inrep\u2011studio \u2192",
    review_copy     = "Copier le code R",
    review_back     = "Retour",

    cm_back         = "Retour",
    cm_continue     = "Continuer",
    cm_step         = "Étape %d sur %d"
  )
)

ONBOARDING_LANG_LIST <- list(
  list(code = "en", native = "English",  name = "English"),
  list(code = "de", native = "Deutsch",  name = "German"),
  list(code = "es", native = "Español",  name = "Spanish"),
  list(code = "fr", native = "Français", name = "French")
)

# -----------------------------------------------------------------------------
# Sample item used for the participant preview. Localised per language so the
# user feels the multilingual story end-to-end on the very first preview.
# -----------------------------------------------------------------------------
ONBOARDING_PREVIEW_ITEM <- list(
  en = list(stem = "I see myself as someone who is talkative and outgoing.",
            anchors = c("Strongly disagree", "Disagree", "Neutral", "Agree", "Strongly agree")),
  de = list(stem = "Ich sehe mich selbst als jemanden, der gesprächig und gesellig ist.",
            anchors = c("Stimme gar nicht zu", "Stimme nicht zu", "Neutral", "Stimme zu", "Stimme voll zu")),
  es = list(stem = "Me veo como alguien hablador y extrovertido.",
            anchors = c("Totalmente en desacuerdo", "En desacuerdo", "Neutral", "De acuerdo", "Totalmente de acuerdo")),
  fr = list(stem = "Je me vois comme quelqu'un de bavard et extraverti.",
            anchors = c("Pas du tout d'accord", "Pas d'accord", "Neutre", "D'accord", "Tout à fait d'accord"))
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

# Map onboarding domain key → inrep item-bank object name.
ob_domain_to_bank <- function(dom) {
  switch(dom,
         personality = "bfi_items",
         cognitive   = "cognitive_items",
         math        = "math_items",
         resilience  = "rcq_items",
         custom      = "my_items"  # placeholder — user will swap in their CSV
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

  cfg_params <- c(
    sprintf("  name = %s",            ob_safe_quote(answers$study_name %||% "My first inrep study")),
    sprintf("  model = %s",           ob_safe_quote(model)),
    sprintf("  adaptive = %s",        if (adaptive) "TRUE" else "FALSE"),
    sprintf("  min_items = %s",       if (adaptive) "5" else "NULL"),
    sprintf("  max_items = %s",       if (adaptive) "15" else as.character(nrow_estimate(primary_dom))),
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
# UI atoms — written as raw HTML so the dark theme stays pixel-precise without
# fighting Bootstrap. Shiny still wires inputs via shiny::tags and JS bindings.
# -----------------------------------------------------------------------------
ob_css <- function() {
  tags$style(HTML("
    /* ── Light mode (default) — mirrors inrep-studio's clean professional look ── */
    :root {
      --bg: #F8FAFB; --surf: #FFFFFF; --surf2: #F1F4F7; --surf3: #E8EDF2;
      --bord: rgba(44,62,80,0.09); --bord-s: rgba(44,62,80,0.16);
      --text: #2C3E50; --text-2: rgba(44,62,80,0.68);
      --text-3: rgba(44,62,80,0.46); --text-4: rgba(44,62,80,0.28);
      --mint: #0BAD79; --mint-dim: rgba(11,173,121,0.10);
      --mint-bord: rgba(11,173,121,0.36); --ink: #FFFFFF;
      --sans: 'Geist', -apple-system, system-ui, sans-serif;
      --serif: 'Instrument Serif', 'Times New Roman', serif;
      --mono: 'JetBrains Mono', ui-monospace, monospace;
    }
    /* ── Dark mode override (activated via body.dark) ── */
    body.dark {
      --bg: #0B0B0F; --surf: #15151C; --surf2: #1B1B23; --surf3: #22222C;
      --bord: rgba(255,255,255,0.07); --bord-s: rgba(255,255,255,0.14);
      --text: #F2F2F5; --text-2: rgba(242,242,245,0.62);
      --text-3: rgba(242,242,245,0.40); --text-4: rgba(242,242,245,0.28);
      --mint: #6FE8C2; --mint-dim: rgba(111,232,194,0.14);
      --mint-bord: rgba(111,232,194,0.42); --ink: #0B0B0F;
    }
    html, body { margin:0; padding:0; background:var(--bg); color:var(--text);
      font-family:var(--sans); -webkit-font-smoothing:antialiased; }
    * { box-sizing: border-box; }

    .ob-shell { max-width: 560px; margin: 0 auto; padding: 24px 22px 48px; min-height: 100vh;
      display: flex; flex-direction: column; }
    .ob-top { display:flex; align-items:center; justify-content:space-between; margin-bottom: 28px; }
    .ob-back { width: 36px; height: 36px; border-radius: 18px; background: var(--surf2);
      border: 1px solid var(--bord); display: grid; place-items: center; cursor: pointer; color: var(--text); }
    .ob-back[disabled] { opacity: 0; pointer-events: none; }
    .ob-dots { display:flex; gap:4px; align-items:center; }
    .ob-dots span { display:block; width:6px; height:3px; border-radius:2px; background: var(--bord-s); transition: width .2s; }
    .ob-dots span.on { width: 18px; background: var(--mint); }
    .ob-lang-pill { display:inline-flex; align-items:center; gap:6px; padding:7px 11px 7px 9px;
      background: var(--surf2); border:1px solid var(--bord); border-radius:99px;
      color: var(--text-2); font: 500 12px/1 var(--sans); letter-spacing: .2px; }
    .ob-darkmode-btn { width: 32px; height: 32px; border-radius: 16px; background: var(--surf2);
      border: 1px solid var(--bord); display: grid; place-items: center; cursor: pointer;
      color: var(--text-2); font-size: 15px; line-height: 1; transition: background .12s; padding: 0; }
    .ob-darkmode-btn:hover { background: var(--surf3); }

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

    /* hero */
    .ob-hero-mark { font: italic 96px/.9 var(--serif); letter-spacing: -3px; color: var(--text); }
    .ob-hero-tag  { font: 400 22px/1 var(--sans); color: var(--mint); letter-spacing: -.4px; margin-top: 4px; }
    .ob-hero-bars { display: flex; align-items: flex-end; gap: 4px; height: 38px; margin: 38px 0 28px; }
    .ob-hero-bars span { display:block; width: 8px; border-radius: 2px; }
    .ob-bar-peak { background: var(--mint) !important; }
    .ob-bar-ramp { background: var(--mint); }
    .ob-bar-dim  { background: var(--bord-s); }

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
# pulling in Bootstrap radio components — keeps the visual exactly on-brand.
# The studio URL is injected as a JS constant so it works for local dev too.
ob_js <- function(studio_url = ONBOARDING_STUDIO_URL) {
  tags$script(HTML(sprintf("
    var INREP_STUDIO_URL = %s;

    // ── Dark mode toggle (persisted in localStorage) ──────────────────────────
    (function() {
      var saved = localStorage.getItem('ob-darkmode');
      if (saved === 'dark') {
        document.body.classList.add('dark');
        // Update icon once DOM is ready
        document.addEventListener('DOMContentLoaded', function() {
          var btn = document.getElementById('ob-dark-btn');
          if (btn) btn.textContent = '\\u2600';
        });
      }
    })();
    function obToggleDark() {
      var isDark = document.body.classList.toggle('dark');
      localStorage.setItem('ob-darkmode', isDark ? 'dark' : 'light');
      var btn = document.getElementById('ob-dark-btn');
      if (btn) btn.textContent = isDark ? '\\u2600' : '\\u263d';
    }

    function obSet(name, value) {
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
        _ob_report_page:   raw.report_page  || 'yes'
      };
    }

    // Hand off to studio:
    //   framed  → postMessage to parent frame
    //   standalone → open studio in new tab with URL hash payload
    function obOpenInStudio(rawPayload) {
      var payload = obBuildStudioPayload(rawPayload);
      // Try postMessage first (framed / same-origin)
      try {
        if (window.parent && window.parent !== window) {
          window.parent.postMessage(
            { type: 'inrep-studio:onboarding-complete', payload: payload }, '*');
          return;
        }
      } catch(e) {}
      // Standalone: open studio in new tab with hash-encoded payload
      var enc = encodeURIComponent(JSON.stringify(payload));
      window.open(INREP_STUDIO_URL + '#inrep-onboarding=' + enc, '_blank');
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
  # stroke is set via .ob-check-path CSS rule → adapts to --ink in both light and dark mode
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
# UI — single page, server toggles which step is visible via conditionalPanel
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
    step        = 0L,             # 0 = splash, 1..6 = questions, 7 = review
    ui_lang     = "en",
    name        = "",
    role        = "researcher",
    institution = "",
    domains     = c("personality"),
    study_name  = "",
    mode        = "adaptive",
    part_langs  = c("en"),
    report_page = "yes"
  )

  observeEvent(input$ui_lang,     { state$ui_lang     <- input$ui_lang },     ignoreInit = TRUE)
  observeEvent(input$role,        { state$role        <- input$role },        ignoreInit = TRUE)
  observeEvent(input$mode,        { state$mode        <- input$mode },        ignoreInit = TRUE)
  observeEvent(input$domains,     { state$domains     <- input$domains },     ignoreInit = TRUE)
  observeEvent(input$part_langs,  { state$part_langs  <- input$part_langs },  ignoreInit = TRUE)
  observeEvent(input$report_page, { state$report_page <- input$report_page }, ignoreInit = TRUE)
  observeEvent(input$name,        { state$name <- input$name %||% "" }, ignoreInit = TRUE)
  observeEvent(input$institution, { state$institution <- input$institution %||% "" }, ignoreInit = TRUE)
  observeEvent(input$study_name,  { state$study_name <- input$study_name %||% "" }, ignoreInit = TRUE)

  # ── nav
  observeEvent(input$ob_next,  { state$step <- min(state$step + 1L, 7L) })
  observeEvent(input$ob_back,  { state$step <- max(state$step - 1L, 0L) })
  observeEvent(input$ob_start, { state$step <- 1L })

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
        if (s > 0 && s < 7) HTML('<svg width="9" height="16" viewBox="0 0 9 16" fill="none"><path d="M8 1L1 8l7 7" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>') else "",
        `disabled` = if (s == 0 || s == 7) NA else NULL
      ),
      if (s >= 1 && s <= 6) ob_dots(s, total = 6) else tags$div(),
      tags$div(style = "display:flex;align-items:center;gap:8px;",
        tags$button(class = "ob-darkmode-btn", id = "ob-dark-btn",
          onclick = "obToggleDark()",
          HTML("\u263d")  # crescent moon = switch to dark
        ),
        tags$div(class = "ob-lang-pill",
          HTML('<svg width="13" height="13" viewBox="0 0 16 16" fill="none"><circle cx="8" cy="8" r="6.5" stroke="currentColor" stroke-width="1.2"/><path d="M1.5 8h13M8 1.5c2 2.2 2 10.8 0 13M8 1.5C6 3.7 6 12.3 8 14.5" stroke="currentColor" stroke-width="1.2"/></svg>'),
          toupper(state$ui_lang)
        )
      )
    )

    body <- switch(as.character(s),
      "0" = ob_step_splash(state, t),
      "1" = ob_step_lang(state, t),
      "2" = ob_step_role(state, t),
      "3" = ob_step_domains(state, t),
      "4" = ob_step_study(state, t),
      "5" = ob_step_part_langs(state, t),
      "6" = ob_step_report(state, t),
      "7" = ob_step_review(state, t)
    )

    tagList(top, body)
  })
}

# -----------------------------------------------------------------------------
# Steps
# -----------------------------------------------------------------------------
ob_step_splash <- function(state, t) {
  bars <- c(6,14,9,22,16,28,19,32,24,36,26,18,21,12,8)
  tagList(
    tags$div(class = "ob-body",
      tags$div(class = "ob-hero-mark", "inrep"),
      tags$div(class = "ob-hero-tag", t("tagline")),
      tags$div(class = "ob-hero-bars",
        lapply(seq_along(bars), function(i) {
          cls <- if (i == 8) "ob-bar-peak"
                 else if (i < 8) "ob-bar-ramp"
                 else "ob-bar-dim"
          op  <- if (i < 8) sprintf(";opacity:%.2f", 0.15 + i * 0.04) else ""
          tags$span(style = sprintf("height:%dpx%s", bars[i], op), class = cls)
        })
      ),
      tags$p(style = "font:400 17px/1.4 var(--sans);letter-spacing:-.2px;color:var(--text-2);max-width:420px;",
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
                   value = state$name, placeholder = "Dr. Selva, …",
                   oninput = "Shiny.setInputValue('name', this.value)"),
        tags$div(class = "ob-label", style = "margin-top:18px;", t("q_role_role")),
        role_grid,
        tags$div(class = "ob-label", style = "margin-top:18px;", t("q_role_inst")),
        tags$input(class = "ob-input", id = "institution", type = "text",
                   value = state$institution, placeholder = "Universit\u00e4t Hildesheim",
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
                   value = state$study_name, placeholder = "HilFo 2026",
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

ob_step_part_langs <- function(state, t) {
  cur <- state$part_langs %||% character()
  pills <- lapply(ONBOARDING_LANG_LIST, function(L) {
    sel <- L$code %in% cur
    tags$div(class = paste("ob-pill", if (sel) "sel" else ""),
      `data-ob-opt` = L$code,
      onclick = sprintf("obToggle('part_langs','%s')", L$code),
      if (sel) HTML('<svg width="11" height="11" viewBox="0 0 12 12"><path d="M2.5 6.2l2.4 2.4 4.6-5" stroke="#6FE8C2" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>'),
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

# Construct a shinyApp object — what runApp() expects, and what the host
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
