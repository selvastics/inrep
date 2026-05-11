# =============================================================================
# inrep-studio-onboarding.R
# -----------------------------------------------------------------------------
# Lightweight Shiny app that walks a new user through 7 onboarding questions
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
# Style:  light mode only, single mint accent (#5b21b6 purple),
#         multilingual (en / de / es / fr / fa) with English default.
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
    intro   = "Answer seven short questions. We'll generate your first inrep study, ready to open in the studio.",
    start   = "Start",
    skip    = "Skip \u2192 Open with defaults",
    footer  = "From the inrep research toolkit, University of Hildesheim",

    q_lang_title    = "Choose your language",
    q_lang_sub      = "You can change this anytime. The studio supports English, German, Spanish, French and Farsi.",
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
    dom_custom      = "Upload CSV in inrep studio",

    q_study_title   = "Set up your first study",
    q_study_sub     = "You can refine everything in the studio.",
    q_study_name    = "Study name",
    q_study_mode    = "How should items be selected?",
    mode_adaptive   = "Adaptive — fewer items, personalised",
    mode_fixed      = "Fixed order — same items, same order",

    q_pages_title   = "How many item pages to start with?",
    q_pages_sub     = "Each page shows one item. You can add or remove pages later in the studio.",
    q_pages_label   = "Number of item pages",
    q_pages_tip     = "",

    q_part_title    = "Participant languages",
    q_part_sub      = "Which languages will participants see on screen? Multiple is fine.",

    q_report_title  = "Show a results page?",
    q_report_sub    = "At the end, should participants see a personalised results summary?",
    report_yes      = "Yes \u2014 show a results summary",
    report_no       = "No \u2014 end after the last item",

    review_title       = "Your generated configuration",
    review_sub         = "Your first inrep study is ready. Open it in the studio, or copy the R code.",
    review_hint_studio = "In the studio: click the Preview tab (bottom-left corner) to see the participant view.",
    review_hint_r      = "In R: paste the code into your R console.",
    review_config      = "Generated R code",
    review_open        = "Open in inrep\u2011studio \u2192",
    review_copy        = "Copy R code",
    review_back        = "Back",
    review_restart     = "Start over",

    cm_back         = "Back",
    cm_continue     = "Continue",
    cm_step         = "Step %d of %d"
  ),
  de = list(
    tagline = "studio",
    intro   = "Beantworte sieben kurze Fragen. Wir erzeugen daraus deine erste inrep-Studie.",
    start   = "Loslegen",
    skip    = "\u00dcberspringen \u2192 Mit Standards öffnen",
    footer  = "Aus dem inrep-Toolkit, Universität Hildesheim",

    q_lang_title    = "Sprache wählen",
    q_lang_sub      = "Jederzeit änderbar. Das Studio unterstützt Englisch, Deutsch, Spanisch, Französisch und Farsi.",
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
    dom_custom      = "CSV in inrep studio hochladen",

    q_study_title   = "Erste Studie anlegen",
    q_study_sub     = "Im Studio kannst du alles feinjustieren.",
    q_study_name    = "Studienname",
    q_study_mode    = "Wie sollen Items ausgewählt werden?",
    mode_adaptive   = "Adaptiv — weniger Items, personalisiert",
    mode_fixed      = "Feste Reihenfolge — gleiche Items, gleiche Reihenfolge",

    q_pages_title   = "Wie viele Item-Seiten möchtest du starten?",
    q_pages_sub     = "Jede Seite zeigt ein Item. Du kannst Seiten später im Studio hinzufügen oder entfernen.",
    q_pages_label   = "Anzahl Item-Seiten",
    q_pages_tip     = "",

    q_part_title    = "Sprachen für Teilnehmende",
    q_part_sub      = "Welche Sprachen sehen Teilnehmende? Mehrfachauswahl möglich.",

    q_report_title  = "Ergebnisseite anzeigen?",
    q_report_sub    = "Sollen Teilnehmende am Ende eine persönliche Zusammenfassung sehen?",
    report_yes      = "Ja \u2014 Ergebnisse anzeigen",
    report_no       = "Nein \u2014 nach dem letzten Item beenden",

    review_title       = "Generierte Konfiguration",
    review_sub         = "Deine erste inrep-Studie ist bereit. Öffne sie im Studio — oder kopiere den R-Code.",
    review_hint_studio = "Im Studio: klicke auf den Vorschau-Tab (unten links) für die Teilnehmenden-Ansicht.",
    review_hint_r      = "In R: füge den Code in deine R-Konsole ein.",
    review_config      = "Generierter R-Code",
    review_open        = "In inrep‑studio öffnen →",
    review_copy        = "R-Code kopieren",
    review_back        = "Zurück",
    review_restart     = "Von vorne beginnen",

    cm_back         = "Zurück",
    cm_continue     = "Weiter",
    cm_step         = "Schritt %d von %d"
  ),
  es = list(
    tagline = "studio",
    intro   = "Responde siete preguntas cortas. Generaremos tu primer estudio inrep.",
    start   = "Empezar",
    skip    = "Saltar \u2192 Abrir con valores predeterminados",
    footer  = "Del kit de investigación inrep, Universidad de Hildesheim",

    q_lang_title    = "Elige tu idioma",
    q_lang_sub      = "Cámbialo cuando quieras. El studio admite inglés, alemán, español, francés y farsi.",
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
    dom_custom      = "Subir CSV en inrep studio",

    q_study_title   = "Configura tu primer estudio",
    q_study_sub     = "Podrás afinarlo todo en el studio.",
    q_study_name    = "Nombre del estudio",
    q_study_mode    = "¿Cómo se eligen los ítems?",
    mode_adaptive   = "Adaptativo — menos ítems, personalizado",
    mode_fixed      = "Orden fijo — mismos ítems, mismo orden",

    q_pages_title   = "¿Cuántas páginas de ítems quieres al inicio?",
    q_pages_sub     = "Cada página muestra un ítem. Puedes añadir o eliminar páginas en el studio.",
    q_pages_label   = "Número de páginas de ítems",
    q_pages_tip     = "",

    q_part_title    = "Idiomas para participantes",
    q_part_sub      = "¿Qué idiomas verán los participantes? Selección múltiple permitida.",

    q_report_title  = "\u00bfMostrar página de resultados?",
    q_report_sub    = "\u00bfLos participantes verán un resumen personalizado al final del estudio?",
    report_yes      = "Sí \u2014 mostrar resumen de resultados",
    report_no       = "No \u2014 terminar tras el \u00faltimo ítem",

    review_title       = "Configuración generada",
    review_sub         = "Tu primer estudio inrep está listo. Ábrelo en el studio o copia el código R.",
    review_hint_studio = "En el studio: haz clic en la pestaña Vista previa (abajo a la izquierda).",
    review_hint_r      = "En R: pega el código en tu consola de R.",
    review_config      = "Código R generado",
    review_open        = "Abrir en inrep‑studio →",
    review_copy        = "Copiar código R",
    review_back        = "Atrás",
    review_restart     = "Empezar de nuevo",

    cm_back         = "Atrás",
    cm_continue     = "Continuar",
    cm_step         = "Paso %d de %d"
  ),
  fr = list(
    tagline = "studio",
    intro   = "Réponds à sept questions courtes. On génère ta première étude inrep.",
    start   = "Commencer",
    skip    = "Passer \u2192 Ouvrir avec les réglages par défaut",
    footer  = "Issu de la boîte à outils inrep, Université de Hildesheim",

    q_lang_title    = "Choisis ta langue",
    q_lang_sub      = "Modifiable à tout moment. Le studio gère anglais, allemand, espagnol, français et farsi.",
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
    dom_custom      = "Importer un CSV dans inrep studio",

    q_study_title   = "Configure ta première étude",
    q_study_sub     = "Tout est affinable dans le studio.",
    q_study_name    = "Nom de l'étude",
    q_study_mode    = "Comment choisir les items ?",
    mode_adaptive   = "Adaptatif — moins d'items, personnalisé",
    mode_fixed      = "Ordre fixe — mêmes items, même ordre",

    q_pages_title   = "Combien de pages d'items pour commencer ?",
    q_pages_sub     = "Chaque page affiche un item. Tu peux en ajouter ou supprimer plus tard dans le studio.",
    q_pages_label   = "Nombre de pages d'items",
    q_pages_tip     = "",

    q_part_title    = "Langues pour les participant·es",
    q_part_sub      = "Quelles langues verront-ils ? Sélection multiple possible.",

    q_report_title  = "Afficher une page de résultats ?",
    q_report_sub    = "À la fin, les participant\u00b7es verront-ils un résumé personnalisé ?",
    report_yes      = "Oui \u2014 afficher un résumé des résultats",
    report_no       = "Non \u2014 terminer après le dernier item",

    review_title       = "Configuration générée",
    review_sub         = "Ta première étude inrep est prête. Ouvre-la dans le studio ou copie le code R.",
    review_hint_studio = "Dans le studio : clique sur l'onglet Aperçu (en bas à gauche) pour voir la vue participant·e.",
    review_hint_r      = "En R : colle le code dans ta console R.",
    review_config      = "Code R généré",
    review_open        = "Ouvrir dans inrep‑studio →",
    review_copy        = "Copier le code R",
    review_back        = "Retour",
    review_restart     = "Recommencer",

    cm_back         = "Retour",
    cm_continue     = "Continuer",
    cm_step         = "Étape %d sur %d"
  ),
  fa = list(
    tagline = "studio",
    intro   = "\u0628\u0647 \u0647\u0641\u062a \u0633\u0648\u0627\u0644 \u06a9\u0648\u062a\u0627\u0647 \u067e\u0627\u0633\u062e \u062f\u0647\u06cc\u062f. \u0645\u0627 \u0627\u0648\u0644\u06cc\u0646 \u0645\u0637\u0627\u0644\u0639\u0647 inrep \u0634\u0645\u0627 \u0631\u0627 \u0622\u0645\u0627\u062f\u0647 \u0645\u06cc\u200c\u06a9\u0646\u06cc\u0645.",
    start   = "\u0634\u0631\u0648\u0639",
    skip    = "\u0631\u062f \u06a9\u0631\u062f\u0646 \u2190 \u0628\u0627\u0632 \u06a9\u0631\u062f\u0646 \u0628\u0627 \u067e\u06cc\u0634\u200c\u0641\u0631\u0636\u200c\u0647\u0627",
    footer  = "\u0627\u0632 \u062c\u0639\u0628\u0647\u200c\u0627\u0628\u0632\u0627\u0631 \u062a\u062d\u0642\u06cc\u0642\u0627\u062a\u06cc inrep\u060c \u062f\u0627\u0646\u0634\u06af\u0627\u0647 \u0647\u06cc\u0644\u062f\u0633\u0647\u0627\u06cc\u0645",

    q_lang_title    = "\u0632\u0628\u0627\u0646 \u062e\u0648\u062f \u0631\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u06a9\u0646\u06cc\u062f",
    q_lang_sub      = "\u062f\u0631 \u0647\u0631 \u0632\u0645\u0627\u0646 \u0642\u0627\u0628\u0644 \u062a\u063a\u06cc\u06cc\u0631 \u0627\u0633\u062a. \u0627\u0633\u062a\u0648\u062f\u06cc\u0648 \u0627\u0632 \u0627\u0646\u06af\u0644\u06cc\u0633\u06cc\u060c \u0622\u0644\u0645\u0627\u0646\u06cc\u060c \u0627\u0633\u067e\u0627\u0646\u06cc\u0627\u06cc\u06cc\u060c \u0641\u0631\u0627\u0646\u0633\u0648\u06cc \u0648 \u0641\u0627\u0631\u0633\u06cc \u067e\u0634\u062a\u06cc\u0628\u0627\u0646\u06cc \u0645\u06cc\u200c\u06a9\u0646\u062f.",
    q_role_title    = "\u062f\u0631\u0628\u0627\u0631\u0647 \u062e\u0648\u062f \u0628\u0647 \u0645\u0627 \u0628\u06af\u0648\u06cc\u06cc\u062f",
    q_role_sub      = "\u0627\u06cc\u0646 \u0627\u0637\u0644\u0627\u0639\u0627\u062a \u0628\u0647 \u0645\u0627 \u06a9\u0645\u06a9 \u0645\u06cc\u200c\u06a9\u0646\u062f \u062a\u0627 \u0642\u0627\u0644\u0628\u200c\u0647\u0627\u06cc \u0645\u0646\u0627\u0633\u0628 \u0631\u0627 \u067e\u06cc\u0634\u0646\u0647\u0627\u062f \u062f\u0647\u06cc\u0645.",
    q_role_name     = "\u0646\u0627\u0645 \u0634\u0645\u0627 (\u0627\u062e\u062a\u06cc\u0627\u0631\u06cc)",
    q_role_role     = "\u0646\u0642\u0634 \u0634\u0645\u0627",
    role_researcher = "\u0645\u062d\u0642\u0642",
    role_lecturer   = "\u0645\u062f\u0631\u0633",
    role_student    = "\u062f\u0627\u0646\u0634\u062c\u0648",
    role_other      = "\u0633\u0627\u06cc\u0631",
    q_role_inst     = "\u0645\u0624\u0633\u0633\u0647",

    q_dom_title     = "\u0686\u0647 \u0686\u06cc\u0632\u06cc \u0631\u0627 \u0645\u06cc\u200c\u062e\u0648\u0627\u0647\u06cc\u062f \u0627\u0646\u062f\u0627\u0632\u0647\u200c\u06af\u06cc\u0631\u06cc \u06a9\u0646\u06cc\u062f\u061f",
    q_dom_sub       = "\u06cc\u06a9 \u06cc\u0627 \u0686\u0646\u062f \u0645\u0648\u0631\u062f \u0631\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u06a9\u0646\u06cc\u062f. \u0628\u0627\u0646\u06a9\u200c\u0647\u0627\u06cc \u06af\u0648\u06cc\u0647 \u0645\u0631\u062a\u0628\u0637 \u0627\u0632 \u0628\u0633\u062a\u0647 inrep \u0628\u0627\u0631\u06af\u0630\u0627\u0631\u06cc \u0645\u06cc\u200c\u0634\u0648\u0646\u062f.",
    dom_personality = "\u0634\u062e\u0635\u06cc\u062a (BFI\u060c \u06f2\u06f0 \u06af\u0648\u06cc\u0647)",
    dom_cognitive   = "\u062a\u0648\u0627\u0646\u0627\u06cc\u06cc \u0634\u0646\u0627\u062e\u062a\u06cc (\u062a\u0637\u0628\u06cc\u0642\u06cc\u060c IRT)",
    dom_math        = "\u0627\u0633\u062a\u062f\u0644\u0627\u0644 \u0631\u06cc\u0627\u0636\u06cc (\u067e\u0627\u0633\u062e \u062a\u062f\u0631\u06cc\u062c\u06cc)",
    dom_resilience  = "\u062a\u0627\u0628\u200c\u0622\u0648\u0631\u06cc \u0648 \u0645\u0642\u0627\u0628\u0644\u0647 (RCQ\u060c \u06f3\u06f0/\u06f6\u06f8 \u06af\u0648\u06cc\u0647)",
    dom_custom      = "\u0628\u0627\u0631\u06af\u0630\u0627\u0631\u06cc CSV \u062f\u0631 inrep studio",

    q_study_title   = "\u0627\u0648\u0644\u06cc\u0646 \u0645\u0637\u0627\u0644\u0639\u0647 \u062e\u0648\u062f \u0631\u0627 \u062a\u0646\u0638\u06cc\u0645 \u06a9\u0646\u06cc\u062f",
    q_study_sub     = "\u0647\u0645\u0647 \u0686\u06cc\u0632 \u0631\u0627 \u0645\u06cc\u200c\u062a\u0648\u0627\u0646\u06cc\u062f \u062f\u0631 \u0627\u0633\u062a\u0648\u062f\u06cc\u0648 \u062a\u0646\u0638\u06cc\u0645 \u06a9\u0646\u06cc\u062f.",
    q_study_name    = "\u0646\u0627\u0645 \u0645\u0637\u0627\u0644\u0639\u0647",
    q_study_mode    = "\u0686\u06af\u0648\u0646\u0647 \u06af\u0648\u06cc\u0647\u200c\u0647\u0627 \u0627\u0646\u062a\u062e\u0627\u0628 \u0634\u0648\u0646\u062f\u061f",
    mode_adaptive   = "\u062a\u0637\u0628\u06cc\u0642\u06cc \u2014 \u06af\u0648\u06cc\u0647\u200c\u0647\u0627\u06cc \u06a9\u0645\u062a\u0631\u060c \u0634\u062e\u0635\u06cc\u200c\u0633\u0627\u0632\u06cc \u0634\u062f\u0647",
    mode_fixed      = "\u062a\u0631\u062a\u06cc\u0628 \u062b\u0627\u0628\u062a \u2014 \u0647\u0645\u0627\u0646 \u06af\u0648\u06cc\u0647\u200c\u0647\u0627\u060c \u0647\u0645\u0627\u0646 \u062a\u0631\u062a\u06cc\u0628",

    q_pages_title   = "\u062a\u0639\u062f\u0627\u062f \u0635\u0641\u062d\u0627\u062a \u06af\u0648\u06cc\u0647 \u062f\u0631 \u0627\u0628\u062a\u062f\u0627\u061f",
    q_pages_sub     = "\u0647\u0631 \u0635\u0641\u062d\u0647 \u06cc\u06a9 \u06af\u0648\u06cc\u0647 \u0646\u0634\u0627\u0646 \u0645\u06cc\u200c\u062f\u0647\u062f. \u0628\u0639\u062f\u0627\u064b \u0645\u06cc\u200c\u062a\u0648\u0627\u0646\u06cc\u062f \u0635\u0641\u062d\u0627\u062a \u0631\u0627 \u062f\u0631 \u0627\u0633\u062a\u0648\u062f\u06cc\u0648 \u0627\u0636\u0627\u0641\u0647 \u06cc\u0627 \u062d\u0630\u0641 \u06a9\u0646\u06cc\u062f.",
    q_pages_label   = "\u062a\u0639\u062f\u0627\u062f \u0635\u0641\u062d\u0627\u062a \u06af\u0648\u06cc\u0647",
    q_pages_tip     = "",

    q_part_title    = "\u0632\u0628\u0627\u0646\u200c\u0647\u0627\u06cc \u0634\u0631\u06a9\u062a\u200c\u06a9\u0646\u0646\u062f\u06af\u0627\u0646",
    q_part_sub      = "\u0634\u0631\u06a9\u062a\u200c\u06a9\u0646\u0646\u062f\u06af\u0627\u0646 \u0686\u0647 \u0632\u0628\u0627\u0646\u200c\u0647\u0627\u06cc\u06cc \u0631\u0627 \u0631\u0648\u06cc \u0635\u0641\u062d\u0647 \u0645\u06cc\u200c\u0628\u06cc\u0646\u0646\u062f\u061f \u0627\u0646\u062a\u062e\u0627\u0628 \u0686\u0646\u062f\u062a\u0627\u06cc\u06cc \u0645\u062c\u0627\u0632 \u0627\u0633\u062a.",

    q_report_title  = "\u0622\u06cc\u0627 \u0635\u0641\u062d\u0647 \u0646\u062a\u0627\u06cc\u062c \u0646\u0634\u0627\u0646 \u062f\u0627\u062f\u0647 \u0634\u0648\u062f\u061f",
    q_report_sub    = "\u062f\u0631 \u067e\u0627\u06cc\u0627\u0646\u060c \u0622\u06cc\u0627 \u0634\u0631\u06a9\u062a\u200c\u06a9\u0646\u0646\u062f\u06af\u0627\u0646 \u062e\u0644\u0627\u0635\u0647 \u0634\u062e\u0635\u06cc\u200c\u0633\u0627\u0632\u06cc\u200c\u0634\u062f\u0647 \u0645\u06cc\u200c\u0628\u06cc\u0646\u0646\u062f\u061f",
    report_yes      = "\u0628\u0644\u0647 \u2014 \u0646\u0645\u0627\u06cc\u0634 \u062e\u0644\u0627\u0635\u0647 \u0646\u062a\u0627\u06cc\u062c",
    report_no       = "\u062e\u06cc\u0631 \u2014 \u067e\u0627\u06cc\u0627\u0646 \u067e\u0633 \u0627\u0632 \u0622\u062e\u0631\u06cc\u0646 \u06af\u0648\u06cc\u0647",

    review_title       = "\u067e\u06cc\u06a9\u0631\u0628\u0646\u062f\u06cc \u062a\u0648\u0644\u06cc\u062f \u0634\u062f\u0647",
    review_sub         = "\u0627\u0648\u0644\u06cc\u0646 \u0645\u0637\u0627\u0644\u0639\u0647 inrep \u0634\u0645\u0627 \u0622\u0645\u0627\u062f\u0647 \u0627\u0633\u062a. \u0622\u0646 \u0631\u0627 \u062f\u0631 \u0627\u0633\u062a\u0648\u062f\u06cc\u0648 \u0628\u0627\u0632 \u06a9\u0646\u06cc\u062f \u06cc\u0627 \u06a9\u062f R \u0631\u0627 \u06a9\u067e\u06cc \u06a9\u0646\u06cc\u062f.",
    review_hint_studio = "\u062f\u0631 \u0627\u0633\u062a\u0648\u062f\u06cc\u0648: \u0631\u0648\u06cc \u0628\u0631\u06af\u0647 \u067e\u06cc\u0634\u200c\u0646\u0645\u0627\u06cc\u0634 (\u067e\u0627\u06cc\u06cc\u0646 \u0633\u0645\u062a \u0686\u067e) \u06a9\u0644\u06cc\u06a9 \u06a9\u0646\u06cc\u062f \u062a\u0627 \u0646\u0645\u0627\u06cc \u0634\u0631\u06a9\u062a\u200c\u06a9\u0646\u0646\u062f\u0647 \u0631\u0627 \u0628\u0628\u06cc\u0646\u06cc\u062f.",
    review_hint_r      = "\u062f\u0631 R: \u06a9\u062f \u0631\u0627 \u062f\u0631 \u06a9\u0646\u0633\u0648\u0644 R \u062e\u0648\u062f \u062c\u0627\u06cc\u06af\u0630\u0627\u0631\u06cc \u06a9\u0646\u06cc\u062f.",
    review_config      = "\u06a9\u062f R \u062a\u0648\u0644\u06cc\u062f \u0634\u062f\u0647",
    review_open        = "\u0628\u0627\u0632 \u06a9\u0631\u062f\u0646 \u062f\u0631 inrep\u2011studio \u2190",
    review_copy        = "\u06a9\u067e\u06cc \u06a9\u062f R",
    review_back        = "\u0628\u0627\u0632\u06af\u0634\u062a",
    review_restart     = "\u0634\u0631\u0648\u0639 \u0645\u062c\u062f\u062f",

    cm_back         = "\u0628\u0627\u0632\u06af\u0634\u062a",
    cm_continue     = "\u0627\u062f\u0627\u0645\u0647",
    cm_step         = "\u0645\u0631\u062d\u0644\u0647 %d \u0627\u0632 %d"
  )
)

ONBOARDING_LANG_LIST <- list(
  list(code = "en", native = "English",   name = "English"),
  list(code = "de", native = "Deutsch",   name = "German"),
  list(code = "es", native = "Español",   name = "Spanish"),
  list(code = "fr", native = "Français",  name = "French"),
  list(code = "fa", native = "\u0641\u0627\u0631\u0633\u06cc", name = "Farsi")
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
            anchors = c("Pas du tout d'accord", "Pas d'accord", "Neutre", "D'accord", "Tout à fait d'accord")),
  fa = list(stem = "\u0645\u0646 \u062e\u0648\u062f\u0645 \u0631\u0627 \u0641\u0631\u062f\u06cc \u0645\u06cc\u200c\u0628\u06cc\u0646\u0645 \u06a9\u0647 \u0627\u062c\u062a\u0645\u0627\u0639\u06cc \u0648 \u0628\u0631\u0648\u0646\u06af\u0631\u0627 \u0647\u0633\u062a\u0645.",
            anchors = c("\u06a9\u0627\u0645\u0644\u0627\u064b \u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u062e\u0627\u0644\u0641\u0645", "\u062e\u0646\u062b\u06cc", "\u0645\u0648\u0627\u0641\u0642\u0645", "\u06a9\u0627\u0645\u0644\u0627\u064b \u0645\u0648\u0627\u0641\u0642\u0645"))
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

# Build the full studio-format generated script from onboarding answers.
ob_build_config_code <- function(answers) {
  doms          <- answers$domains %||% list("personality")
  primary_dom   <- if (is.list(doms)) doms[[1]] else doms[[1]]
  model         <- if (primary_dom %in% c("math", "cognitive")) "2PL" else "GRM"
  adaptive      <- isTRUE(identical(answers$mode, "adaptive"))
  langs         <- answers$part_langs %||% list(answers$ui_lang %||% "en")
  primary_lang  <- if (is.list(langs)) langs[[1]] else langs[[1]]
  show_debrief  <- !isTRUE(identical(answers$report_page, "no"))
  max_items_val <- as.integer(answers$max_items %||% (if (adaptive) 15L else 20L))
  study_name    <- answers$study_name %||% "My first inrep study"
  study_key     <- paste0("study_", format(Sys.Date(), "%Y%m%d"))
  min_items_val <- if (adaptive) 5L else max_items_val

  # \u2500\u2500 1. Header \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  hdr <- sprintf(paste0(
    "################################################################################\n",
    "# inrep Studio Generated Study Script\n",
    "# Generated: %s\n",
    "# Study: %s\n",
    "################################################################################\n"
  ), format(Sys.time(), "%Y-%m-%d %H:%M:%S"), study_name)

  # \u2500\u2500 2. Encoding / locale \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  enc <- paste0(
    "\n# =============================================================================\n",
    "# Encoding / locale defaults (best-effort)\n",
    "# =============================================================================\n",
    'options(encoding = "UTF-8")\n',
    'Sys.setenv(LANGUAGE = "en")\n',
    'try(suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8")), silent = TRUE)\n',
    'try(suppressWarnings(Sys.setlocale("LC_CTYPE", "English_United States.utf8")), silent = TRUE)\n',
    'try(suppressWarnings(Sys.setlocale("LC_MESSAGES", "English")), silent = TRUE)\n'
  )

  # \u2500\u2500 3. Package installation \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  tam_install <- if (adaptive)
    'install_if_missing("TAM")  # Required for adaptive testing\n' else
    "# TAM not required for non-adaptive studies\n"
  tam_load <- if (adaptive)
    "library(TAM)  # Required for adaptive testing\n" else
    "# TAM not required for non-adaptive studies\n"

  pkgs <- paste0(
    "\n# =============================================================================\n",
    "# Install Required Packages (if not already installed)\n",
    "# =============================================================================\n\n",
    "install_if_missing <- function(pkg, github_repo = NULL) {\n",
    "  if (!requireNamespace(pkg, quietly = TRUE)) {\n",
    "    if (!is.null(github_repo)) {\n",
    "      if (!requireNamespace(\"devtools\", quietly = TRUE)) install.packages(\"devtools\")\n",
    "      message(paste(\"Installing\", pkg, \"from GitHub...\"))\n",
    "      devtools::install_github(github_repo, force = TRUE)\n",
    "    } else {\n",
    "      message(paste(\"Installing\", pkg, \"from CRAN...\"))\n",
    "      install.packages(pkg)\n",
    "    }\n",
    "  }\n",
    "}\n\n",
    "install_if_missing(\"shiny\")\n",
    "install_if_missing(\"httr\")\n",
    "install_if_missing(\"zip\")\n",
    tam_install,
    "install_if_missing(\"inrep\", \"selvastics/inrep\")\n\n",
    "# =============================================================================\n",
    "# Load Required Packages\n",
    "# =============================================================================\n",
    "library(shiny)\n",
    "library(inrep)\n",
    "library(httr)\n",
    "library(zip)\n",
    tam_load
  )

  # \u2500\u2500 4. Item bank \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  items_code <- paste0(
    "\n\n# =============================================================================\n",
    "# Item Bank Definition\n",
    "# =============================================================================\n",
    "all_items <- data.frame(\n",
    '  id = c("BFE_01", "BFE_02", "BFE_03", "BFN_01", "BFN_02", "PSQ_01", "PSQ_02"),\n',
    '  Question = c("Ich gehe aus mir heraus, bin gesellig.",\n',
    '               "Ich bin eher ruhig und zurueckhaltend.",\n',
    '               "Ich bin begeisterungsfaehig und kann andere leicht mitreissen.",\n',
    '               "Ich bleibe auch in stressigen Situationen gelassen.",\n',
    '               "Ich werde leicht nervoees und unsicher.",\n',
    '               "Ich fuehle mich gehetzt und unter Zeitdruck.",\n',
    '               "Ich habe Schwierigkeiten, abzuschalten."),\n',
    '  Question_DE = c("Ich gehe aus mir heraus, bin gesellig.",\n',
    '                  "Ich bin eher ruhig und zurueckhaltend.",\n',
    '                  "Ich bin begeisterungsfaehig und kann andere leicht mitreissen.",\n',
    '                  "Ich bleibe auch in stressigen Situationen gelassen.",\n',
    '                  "Ich werde leicht nervoees und unsicher.",\n',
    '                  "Ich fuehle mich gehetzt und unter Zeitdruck.",\n',
    '                  "Ich habe Schwierigkeiten, abzuschalten."),\n',
    '  Question_EN = c("I am outgoing and sociable.",\n',
    '                  "I am rather quiet and reserved.",\n',
    '                  "I am enthusiastic and can easily inspire others.",\n',
    '                  "I remain calm even in stressful situations.",\n',
    '                  "I get nervous and insecure easily.",\n',
    '                  "I feel rushed and under time pressure.",\n',
    '                  "I have difficulty switching off."),\n',
    '  ResponseCategories = rep("1,2,3,4,5", 7),\n',
    "  a = c(1.2, 1.1, 1.3, 1.0, 0.9, 1.1, 1.2),\n",
    "  b = c(0.1, -0.2, 0.3, -0.1, 0.2, 0.4, 0.3),\n",
    "  stringsAsFactors = FALSE\n",
    ")\n\n",
    "if (all(c(\"a\", \"b\") %in% names(all_items)) &&\n",
    "    !all(c(\"b1\", \"b2\", \"b3\", \"b4\") %in% names(all_items))) {\n",
    "  all_items$b1 <- all_items$b - 1.5\n",
    "  all_items$b2 <- all_items$b - 0.5\n",
    "  all_items$b3 <- all_items$b + 0.5\n",
    "  all_items$b4 <- all_items$b + 1.5\n",
    "}\n\n",
    "get_items_for_language <- function(lang = \"", primary_lang, "\") {\n",
    "  items <- all_items\n",
    "  if (lang == \"en\" && \"Question_EN\" %in% names(items)) {\n",
    "    items$Question <- items$Question_EN\n",
    "  } else if (\"Question_DE\" %in% names(items)) {\n",
    "    items$Question <- items$Question_DE\n",
    "  }\n",
    "  return(items)\n",
    "}\n"
  )

  # \u2500\u2500 5. Demographics \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  demo_code <- paste0(
    "\n# =============================================================================\n",
    "# Demographic Field Configurations\n",
    "# =============================================================================\n",
    "demographic_configs <- list(\n",
    "  age = list(\n",
    '    question = "Age (in years)", question_en = "Age (in years)", required = TRUE\n',
    "  ),\n",
    "  gender = list(\n",
    '    question = "Gender", question_en = "Gender",\n',
    '    options = c("Male"="1", "Female"="2", "Diverse"="3", "Prefer not to say"="4"),\n',
    '    options_en = c("Male"="1", "Female"="2", "Diverse"="3", "Prefer not to say"="4"),\n',
    "    required = TRUE\n",
    "  ),\n",
    "  education = list(\n",
    '    question = "Highest Education Level", question_en = "Highest Education Level",\n',
    '    options = c("Secondary School"="1","High School"="2","A-levels"="3","Bachelor"="4","Master"="5","PhD"="6"),\n',
    '    options_en = c("Secondary School"="1","High School"="2","A-levels"="3","Bachelor"="4","Master"="5","PhD"="6"),\n',
    "    required = FALSE\n",
    "  )\n",
    ")\n\n",
    "input_types <- list(age = \"numeric\", gender = \"select\", education = \"select\")\n"
  )

  # \u2500\u2500 6. Page flow \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  # Build item pages based on max_items (3 items per page, up to max_items)
  n_item_pages <- max(1L, ceiling(max_items_val / 3L))
  item_page_entries <- vapply(seq_len(n_item_pages), function(i) {
    pid  <- if (i == 1L) "page3" else paste0("page_items_", i)
    ttl  <- if (i == 1L) "Questionnaire" else sprintf("Questionnaire %d", i)
    sprintf(paste0(
      "  list(\n",
      "    id = \"%s\", type = \"items\",\n",
      "    title = \"%s\", title_en = \"%s\",\n",
      "    item_indices = c(1, 2, 3), scale_type = \"likert\",\n",
      "    randomize = FALSE, required = FALSE\n",
      "  )"
    ), pid, ttl, ttl)
  }, character(1L))

  results_page_entry <- if (show_debrief) paste0(
    "  list(\n",
    "    id = \"page_results\", type = \"results\",\n",
    "    title = \"Your Results\", title_en = \"Your Results\",\n",
    "    show_radar_chart = TRUE, show_scale_scores = TRUE,\n",
    '    results_text_de = "Thank you for your participation!",\n',
    '    results_text_en = "Thank you for your participation!"\n',
    "  )"
  ) else NULL

  all_page_entries <- c(
    paste0(
      "  list(\n",
      "    id = \"page1\", type = \"custom\",\n",
      "    title = \"Welcome Page\", title_en = \"Welcome Page\",\n",
      '    content = "<h1>Welcome to the Study</h1><p>Thank you for participating in this scientific survey.</p>",\n',
      '    content_en = "<h1>Welcome to the Study</h1><p>Thank you for participating in this scientific survey.</p>",\n',
      "    required = FALSE\n",
      "  )"
    ),
    paste0(
      "  list(\n",
      "    id = \"page2\", type = \"demographics\",\n",
      "    title = \"Demographics\", title_en = \"Demographics\",\n",
      '    demographics = c("age", "gender", "education"), required = FALSE\n',
      "  )"
    ),
    item_page_entries,
    results_page_entry
  )
  all_page_entries <- all_page_entries[!vapply(all_page_entries, is.null, logical(1))]

  page_flow_code <- paste0(
    "\n# =============================================================================\n",
    "# Page Flow Definition\n",
    "# =============================================================================\n",
    "custom_page_flow <- list(\n",
    paste(all_page_entries, collapse = ",\n"),
    "\n)\n"
  )

  # \u2500\u2500 7. Theme / storage / config / launch \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  lang_arg <- if (length(langs) > 1) {
    paste0("c(", paste(vapply(langs, ob_safe_quote, character(1L)), collapse = ", "), ")")
  } else {
    ob_safe_quote(primary_lang)
  }

  tail_code <- paste0(
    "\n# =============================================================================\n",
    "# Color Customization Configuration\n",
    "# =============================================================================\n",
    "theme_config <- list(\n",
    '  primary_color = "#2C3E50",\n',
    '  accent_color  = "#3498DB",\n',
    '  text_color    = "#2C3E50",\n',
    "  element_colors = list()\n",
    ")\n\n",
    "# =============================================================================\n",
    "# Local File Storage Configuration\n",
    "# =============================================================================\n",
    'storage_config <- list(type = "local", path = "./data/", format = "csv")\n\n',
    "# =============================================================================\n",
    "# Study Configuration\n",
    "# =============================================================================\n",
    "study_config <- inrep::create_study_config(\n",
    "  name             = ", ob_safe_quote(study_name), ",\n",
    "  study_key        = ", ob_safe_quote(study_key), ",\n",
    '  theme            = "hildesheim",\n',
    "  custom_page_flow = custom_page_flow,\n",
    '  demographics     = c("age", "gender", "education"),\n',
    "  demographic_configs = demographic_configs,\n",
    "  input_types      = input_types,\n",
    "  language         = ", lang_arg, ",\n",
    "  model            = ", ob_safe_quote(model), ",\n",
    "  adaptive         = ", if (adaptive) "TRUE" else "FALSE", ",\n",
    if (adaptive) paste0('  estimation_method = "EAP",\n  criteria = "MI",\n  min_SEM = 0.3,\n') else "",
    '  response_ui_type = "radio",\n',
    '  response_layout  = "vertical",\n',
    '  progress_style   = "none",\n',
    "  session_save     = TRUE,\n",
    "  show_session_time = FALSE,\n",
    "  max_session_duration = 60,\n",
    "  max_response_time = 300,\n",
    "  min_items        = ", as.character(min_items_val), ",\n",
    "  max_items        = ", as.character(max_items_val), ",\n",
    '  report_formats   = c("rds", "csv", "json"),\n',
    "  cache_enabled    = TRUE,\n",
    "  parallel_computation = TRUE,\n",
    "  fast_item_selection  = TRUE,\n",
    "  feedback_enabled     = FALSE,\n",
    "  show_introduction = TRUE,\n",
    "  show_briefing     = TRUE,\n",
    "  show_consent      = TRUE,\n",
    "  show_gdpr_compliance = TRUE,\n",
    "  show_debriefing   = ", if (show_debrief) "TRUE" else "FALSE", ",\n",
    "  enable_back_navigation = TRUE\n",
    ")\n\n",
    "study_config$theme_config <- theme_config\n\n",
    "# =============================================================================\n",
    "# Launch the Study\n",
    "# =============================================================================\n",
    "inrep::launch_study(\n",
    "  config          = study_config,\n",
    "  item_bank       = all_items,\n",
    "  theme_config    = theme_config,\n",
    '  save_format     = "csv",\n',
    "  session_save    = TRUE,\n",
    "  debug_mode      = FALSE,\n",
    "  launch_browser  = TRUE\n",
    ")\n"
  )

  paste0(hdr, enc, pkgs, items_code, demo_code, page_flow_code, tail_code)
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
      --mint: #7c3aed; --mint-dim: rgba(124,58,237,0.10);
      --mint-bord: rgba(124,58,237,0.30); --ink: #FFFFFF;
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
    /* Override Bootstrap's btn-default color — must beat 1-class specificity */
    button.ob-btn.ob-btn-primary { color: var(--ink); transition: background 0.18s ease, color 0.18s ease, box-shadow 0.18s ease; }
    button.ob-btn.ob-btn-primary:hover, button.ob-btn.ob-btn-primary:focus-visible { background: var(--surf3); color: var(--text); box-shadow: none; }
    .ob-btn-ghost { background: transparent; color: var(--text); border: 1px solid var(--bord-s);
      font-weight: 500; font-size: 15px; transition: background 0.15s ease, color 0.15s ease; }

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

    /* Suppress Shiny's recalculating fade so steps don't flicker */
    .shiny-output-recalculating { opacity: 1 !important; transition: none !important; }

    /* RTL support for Farsi */
    .ob-rtl { direction: rtl; text-align: right; }
    .ob-rtl .ob-card { flex-direction: row-reverse; }
    .ob-rtl .ob-actions { flex-direction: row-reverse; }
    .ob-rtl .ob-pill { flex-direction: row-reverse; }
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
      // framed (cross-origin iframe): tell parent to dismiss the panel
      try {
        if (window.parent && window.parent !== window) {
          window.parent.postMessage({type: 'inrep-studio:close-onboarding'}, '*');
          return;
        }
      } catch(e) {}
      // inline router mode (embedded in studio page): navigate via Shiny input
      if (window.INREP_ROUTER_MODE && window.Shiny && Shiny.setInputValue) {
        Shiny.setInputValue('ob_navigate_to_studio', Math.random(), {priority: 'event'});
        return;
      }
      // standalone: navigate away
      window.location.replace(INREP_STUDIO_URL);
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
      }).catch(() => {});
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
    //   framed  → postMessage to parent frame
    //   standalone → open studio in new tab with URL hash payload
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

    // Receive current step from R and persist it so re-opening resumes in place.
    Shiny.addCustomMessageHandler('ob_step_changed', function(msg) {
      obMergeState({step: msg.step});
    });
  ", jsonlite::toJSON(studio_url, auto_unbox = TRUE))))
}

# Step bar with N filled dots.
ob_dots <- function(step, total = 7) {
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
    step        = 0L,             # 0 = splash, 1..7 = questions, 8 = review
    ui_lang     = "en",
    name        = "",
    role        = "researcher",
    institution = "",
    domains     = c("personality"),
    study_name  = "",
    mode        = "fixed",
    max_items   = 5L,
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
    # Resume at the step where the user left off (only if > 0 to avoid flash of splash on completion reset)
    if (!is.null(restored$step)) {
      s <- as.integer(restored$step)
      if (!is.na(s) && s > 0L && s <= 8L) {
        state$step <- s
        session$sendCustomMessage("ob_step_changed", list(step = s))
      }
    }
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

  # nav: each change is persisted to localStorage via ob_step_changed message
  observeEvent(input$ob_next, {
    state$step <- min(state$step + 1L, 8L)
    session$sendCustomMessage("ob_step_changed", list(step = state$step))
  })
  observeEvent(input$ob_back, {
    state$step <- max(state$step - 1L, 0L)
    session$sendCustomMessage("ob_step_changed", list(step = state$step))
  })
  observeEvent(input$ob_start, {
    state$step <- 1L
    session$sendCustomMessage("ob_step_changed", list(step = 1L))
  })
  observeEvent(input$ob_reset_step, {
    state$step <- 0L
    session$sendCustomMessage("ob_step_changed", list(step = 0L))
  }, ignoreInit = TRUE, ignoreNULL = TRUE)

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

    is_rtl <- isTRUE(state$ui_lang == "fa")
    if (is_rtl) {
      tags$div(class = "ob-rtl", top, body)
    } else {
      tagList(top, body)
    }
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
      # Skip: open studio with sensible defaults using the already-selected UI language
      tags$button(class = "ob-btn ob-btn-ghost",
        onclick = sprintf(
          "obOpenInStudio(%s)",
          jsonlite::toJSON(list(
            study_name  = "My inrep Study",
            mode        = "fixed",
            domains     = list("personality"),
            ui_lang     = state$ui_lang %||% "en",
            part_langs  = list(state$ui_lang %||% "en"),
            name        = state$name %||% "",
            institution = state$institution %||% "",
            role        = state$role %||% "researcher",
            max_items   = 5L,
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
        tags$div(class = "ob-mark", ob_check_svg()),
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
    list(k = "fixed",    title = t("mode_fixed")),
    list(k = "adaptive", title = t("mode_adaptive"))
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
  cur_val <- as.integer(isolate(state$max_items) %||% 5L)
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
          oninput = "Shiny.setInputValue('max_items', parseInt(this.value) || 5)"
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
      if (sel) HTML('<svg width="11" height="11" viewBox="0 0 12 12"><path d="M2.5 6.2l2.4 2.4 4.6-5" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round" stroke-linejoin="round"/></svg>'),
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
  answers <- list(
    ui_lang     = state$ui_lang,
    role        = state$role,
    name        = state$name,
    institution = state$institution,
    domains     = as.list(state$domains),
    study_name  = state$study_name %||% "My first inrep study",
    mode        = state$mode,
    max_items   = as.integer(state$max_items %||% 5L),
    part_langs  = as.list(state$part_langs),
    report_page = state$report_page %||% "yes"
  )
  r_code  <- ob_build_config_code(answers)
  payload <- jsonlite::toJSON(answers, auto_unbox = TRUE, null = "null")

  tagList(
    tags$div(class = "ob-body",
      tags$h1(class = "ob-h1", t("review_title")),
      tags$p(class = "ob-lede", t("review_sub")),

      # Primary action — full-width, prominent at top
      tags$div(style = "margin-top: 24px;",
        tags$button(
          class = "ob-btn ob-btn-primary",
          style = "width: 100%; height: 52px; font-size: 15px; justify-content: center;",
          onclick = sprintf("obOpenInStudio(%s)", payload),
          t("review_open")
        )
      ),

      # Instruction hints
      tags$div(
        style = paste0(
          "margin-top: 12px; padding: 14px 16px;",
          " background: var(--mint-dim); border: 1px solid var(--mint-bord);",
          " border-radius: 10px; font-size: 13px; line-height: 1.6; color: var(--text);"
        ),
        tags$div(
          style = "display: flex; gap: 8px; align-items: flex-start; margin-bottom: 6px;",
          tags$span(style = "flex-shrink:0; color: var(--mint); font-weight:600;", "→"),
          tags$span(t("review_hint_studio"))
        ),
        tags$div(
          style = "display: flex; gap: 8px; align-items: flex-start;",
          tags$span(style = "flex-shrink:0; color: var(--text-3);", "•"),
          tags$span(t("review_hint_r"))
        )
      ),

      # Secondary: generated R code
      tags$div(class = "ob-panel", style = "margin-top: 20px;",
        tags$div(style = "display:flex; align-items:center; justify-content:space-between; margin-bottom:10px;",
          tags$div(class = "ob-panel-title", style = "margin-bottom:0;", t("review_config")),
          tags$button(
            class = "ob-btn ob-btn-ghost", id = "ob-copy-btn",
            style = "height:34px; font-size:12px; padding:0 12px; flex-shrink:0;",
            onclick = "obCopy(document.getElementById('ob-code-block').textContent)",
            t("review_copy")
          )
        ),
        tags$pre(class = "ob-code", id = "ob-code-block", r_code)
      )
    ),
    tags$div(class = "ob-actions",
      tags$button(
        class = "ob-btn ob-btn-ghost",
        style = "font-size:13px; color:var(--text-3); flex:0; padding:0 14px;",
        onclick = "Shiny.setInputValue('ob_reset_step', Math.random(), {priority:'event'})",
        t("review_restart")
      ),
      tags$button(
        class = "ob-btn ob-btn-ghost",
        onclick = "Shiny.setInputValue('ob_back', Math.random())",
        t("review_back")
      )
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
