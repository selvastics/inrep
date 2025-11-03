# =============================================================================
# MINA STUDY - SIMPLE VERSION - BASIC DATA STORAGE (NO COMPREHENSIVE DATASET)
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
# ITEM BANK - DIGITAL STRESS (DS1-DS15) + RESILIENCE/COPING (RCQ1-RCQ)
# Non-adaptive, uniform 1–7 Likert scale
# =============================================================================
likert7_labels <- c(
    "1 = stimme gar nicht zu",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7 = stimme voll zu"
)

ds_items <- c(
    "Ich fühle mich durch ständige Online-Kommunikation gestresst.",
    "Ich habe das Gefühl, ständig erreichbar sein zu müssen.",
    "Die Vielzahl digitaler Nachrichten überfordert mich.",
    "Ich bin häufig abgelenkt durch Benachrichtigungen auf meinem Smartphone.",
    "Es fällt mir schwer, den Überblick über digitale Informationen zu behalten.",
    "Ich habe das Gefühl, mein digitales Leben nicht vollständig kontrollieren zu können.",
    "Ich kann schlecht abschalten, wenn mein Handy in der Nähe ist.",
    "Wenn ich nicht online bin, habe ich Angst, etwas Wichtiges zu verpassen.",
    "Ich fühle mich gestresst, weil ich auf vielen Plattformen gleichzeitig aktiv bin.",
    "Die ständige Informationsflut im Internet überfordert mich.",
    "Es stresst mich, permanent neue Nachrichten zu erhalten.",
    "Ich empfinde digitale Unterbrechungen (z. B. Mails, Push-Nachrichten) als belastend.",
    "Es fällt mir schwer, digitale Geräte für längere Zeit auszuschalten.",
    "Ich habe das Gefühl, zu viel Zeit mit digitalen Medien zu verbringen.",
    "Ich fühle mich überfordert durch die Vielzahl an digitalen Verpflichtungen."
)

rcq_items <- c(
    "Dinge, die mich früher aufgeregt haben, kann ich heute so annehmen.",
    "Sollte die Unterstützung durch andere nicht zum gewünschten Erfolg führen, ziehe ich aktiv weitere Ressourcen zur Problembewältigung hinzu.",
    "Wenn sich etwas schwieriger gestaltet als gedacht, gebe ich auf.",
    "Mit der Zeit nehmen meine Bemühungen ab, mit meinen Problemen klarzukommen.",
    "Wenn mir nicht auf Anhieb geholfen wird, gebe ich mit der Sache auf.",
    "Um meine Ängste zu überwinden, mache ich mir dafür notwendige Verhaltensweisen und Fähigkeiten bewusst und setze diese um.",
    "Ängste, die entlang meines Weges aufkommen, entmutigen mich nicht, sondern motivieren mich dabei meine Ziele zu erreichen.",
    "Ich versuche, körperliche Schmerzen (z.B. im Rücken, in Gelenken) mit sportlicher Betätigung zu reduzieren.",
    "Meine Familie steht hinter mir, auch dann, wenn ich mich falsch verhalte.",
    "Ich kann mich auf die Unterstützung meiner Familie verlassen.",
    "In meiner Familie unterstützen wir uns gegenseitig.",
    "Ich habe konkrete Ziele und entsprechend plane ich meine Zukunft.",
    "Ich stelle aktiv die Weichen (z.B. Praktika, Sparmaßnahmen) für meine späteren Zukunftsziele.",
    "Ich bin fest davon überzeugt, dass ich meine Pläne für die Zukunft umsetzen werde.",
    "Auch in einer schwierigen Lebensphase versuche ich, Dinge mit Humor zu nehmen.",
    "Ich verliere meinen Sinn für Humor, wenn ich mich in einer belastenden Situation befinde.",
    "Wenn es angebracht ist, kann ich auch über ernste Themen lachen.",
    "Ich versuche aktiv, in den negativen Erlebnissen in meinem Leben einen positiven Wert zu finden.",
    "Selbst in einer hoffnungslosen Situation kann ich eine tieferliegende Bedeutung finden.",
    "In unbekannten Situationen bleibe ich zuversichtlich und sage mir „Es wird schon gutgehen“.",
    "Ich gehe mehr als einmal in der Woche einer sportlichen Aktivität nach (z.B. Joggen, Gewichte heben).",
    "In den letzten 6 Monaten habe ich mich regelmäßig sportlich betätigt.",
    "Ich sehe Hindernisse als eine Chance, zu wachsen.",
    "Auch wenn ich jemanden zu Unrecht beschuldige, fällt es mir schwer, mich zu entschuldigen.",
    "Ich spreche ungern über meine Vergangenheit, da ich mich für diese schuldig fühle.",
    "Auch in schwierigen Zeiten finde ich eine Lösung.",
    "Mir ist wichtig, dass ich mich mit Freunden austauschen kann, wenn ich mich unwohl fühle oder Schmerzen habe.",
    "In meinem Freundeskreis bringen wir uns gegenseitig zum Lachen, auch in schwierigen Situationen.",
    "Ich genieße es, meine Zeit mit anderen Menschen zu verbringen.",
    "Ich denke  <br>über Wunder (z.B. Lottogewinn, Spontanheilung)  <br>nach, welche meine Probleme lösen werden."
)

all_items <- data.frame(
    id = c(paste0("DS", seq_along(ds_items)), paste0("RCQ", seq_along(rcq_items))),
    Question = c(ds_items, rcq_items),
    ResponseCategories = "1,2,3,4,5,6,7",
    stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHICS CONFIGURATION
# =============================================================================
demographic_configs <- list()

# =============================================================================
# INPUT TYPES
# =============================================================================
input_types <- list()

# Add input types for all Likert items (1–7)
for (i in seq_len(nrow(all_items))) {
    input_types[[all_items$id[i]]] <- "radio"
}

# Demographic inputs
input_types$Age <- "numeric"
input_types$Gender <- "select"
input_types$StudyProgram <- "text"
input_types$Semester <- "numeric"
input_types$ScreenTime <- "radio"   # 1–5 scale as specified
input_types$SocialMedia <- "radio"   # 1–5 scale as specified
input_types$consent_agree <- "checkbox"
input_types$open_O1 <- "textArea"

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================
custom_page_flow <- list(
    # Page 1: Welcome + Consent
    list(
        id = "page1",
        type = "custom",
        title = "",
        required = TRUE,
        required_fields = c("consent_agree"),
        render_function = function(input, output, session, rv) {
            shiny::div(
                class = "assessment-card",
                shiny::h3("Herzlich willkommen zu meiner Studie!", class = "card-header"),
                shiny::div(
                    style = "padding: 16px;",
                    shiny::p("Ziel der Umfrage ist es, zu untersuchen, wie Menschen mit digitalem Stress umgehen und welche Rolle Resilienz dabei spielt. Ihre Teilnahme ist freiwillig und anonym. Die Befragung dauert ca. 10 Minuten."),
                    shiny::div(style = "margin-top: 16px;",
                               shiny::checkboxInput("consent_agree", "Ich stimme den Teilnahmebedingungen zu und bestätige, dass meine Angaben anonym gespeichert werden dürfen.", value = FALSE)
                    )
                )
            )
        },
        completion_handler = function(input, rv) {
            rv$consent_agree <- isTRUE(input$consent_agree)
        }
    ),
    
    # Page 2: Demographics
    list(
        id = "page2",
        type = "custom",
        title = "",
        required = FALSE,
        render_function = function(input, output, session, rv) {
            shiny::div(
                class = "assessment-card",
                shiny::h3("Demografische Angaben", class = "card-header"),
                shiny::div(style = "padding: 16px;",
                           shiny::numericInput("demo_Age", "Bitte geben Sie Ihr Alter in Jahren an.", value = NA, min = 10, max = 120),
                           shiny::radioButtons(
                               "demo_Gender",
                               "Bitte geben Sie Ihr Geschlecht an.",
                               inline = FALSE,
                               choices = c("weiblich", "männlich", "divers", "keine Angabe"),
                               selected = character(0)
                           ),
                           shiny::textInput("demo_StudyProgram", "Bitte geben Sie Ihren Studiengang an.", value = ""),
                           shiny::numericInput("demo_Semester", "Bitte geben Sie Ihr aktuelles Semester an.", value = NA, min = 1, max = 60),
                           shiny::radioButtons("demo_ScreenTime", "Wie viele Stunden verbringen Sie durchschnittlich täglich am Bildschirm (Computer, Handy, Tablet)?", inline = FALSE,
                                               choices = setNames(1:5, c("unter 2h", "2–4h", "4–6h", "6–8h", "über 8h")), selected = character(0)),
                           shiny::radioButtons("demo_SocialMedia", "Wie häufig nutzen Sie soziale Medien?", inline = FALSE,
                                               choices = setNames(1:5, c("nie", "selten", "mehrmals pro Woche", "täglich", "mehrmals täglich")), selected = character(0))
                )
            )
        },
        completion_handler = function(input, rv) {
            rv$demo_data <- list(
                Age = input$demo_Age,
                Gender = input$demo_Gender,
                StudyProgram = input$demo_StudyProgram,
                Semester = input$demo_Semester,
                ScreenTime = input$demo_ScreenTime,
                SocialMedia = input$demo_SocialMedia
            )
        }
    ),
    
    # Page 3: DS1–DS15 (custom-rendered 7-point endpoints-only)
    list(
        id = "page3",
        type = "custom",
        title = "",
        required = FALSE,
        render_function = function(input, output, session, rv) {
            idx <- seq_along(ds_items)
      items_ui <- lapply(idx, function(i) {
                item_id <- all_items$id[i]
                item_text <- all_items$Question[i]
                shiny::div(style = "margin: 16px 0;",
          shiny::HTML(paste0('<p style="margin-bottom:10px;">', item_text, '</p>')),
                           shiny::radioButtons(
                               inputId = item_id,
                               label = NULL,
                               choices = setNames(1:7, c(
                                   "1 = stimme gar nicht zu", "2", "3", "4", "5", "6", "7 = stimme voll zu"
                               )),
                               selected = character(0), inline = FALSE
                           )
                )
            })
      shiny::div(class = "assessment-card",
        shiny::h3("", class = "card-header"),
        items_ui
      )
        },
        completion_handler = function(input, rv) {
            # Ensure response vector exists
            if (is.null(rv$responses) || length(rv$responses) != nrow(all_items)) {
                rv$responses <- rep(NA_real_, nrow(all_items))
            }
            # Map DS item inputs into rv$responses
            idx <- seq_along(ds_items)
            for (i in idx) {
                item_id <- all_items$id[i]
                val <- input[[item_id]]
                if (!is.null(val) && nzchar(as.character(val))) {
                    rv$responses[i] <- suppressWarnings(as.numeric(val))
                }
            }
        }
    ),
    
    # Page 4: RCQ1–RCQ29 (custom-rendered 7-point endpoints-only)
    list(
        id = "page4",
        type = "custom",
        title = "",
        required = FALSE,
        render_function = function(input, output, session, rv) {
            idx <- (length(ds_items)+1):(length(ds_items)+length(rcq_items))
      items_ui <- lapply(idx, function(i) {
                item_id <- all_items$id[i]
                item_text <- all_items$Question[i]
                shiny::div(style = "margin: 16px 0;",
          shiny::HTML(paste0('<p style="margin-bottom:10px;">', item_text, '</p>')),
                           shiny::radioButtons(
                               inputId = item_id,
                               label = NULL,
                               choices = setNames(1:7, c(
                                   "1 = stimme gar nicht zu", "2", "3", "4", "5", "6", "7 = stimme voll zu"
                               )),
                               selected = character(0), inline = FALSE
                           )
                )
            })
      shiny::div(class = "assessment-card",
        shiny::h3("", class = "card-header"),
        items_ui
      )
        },
        completion_handler = function(input, rv) {
            # Ensure response vector exists
            if (is.null(rv$responses) || length(rv$responses) != nrow(all_items)) {
                rv$responses <- rep(NA_real_, nrow(all_items))
            }
            # Map RCQ item inputs into rv$responses
            start_idx <- length(ds_items) + 1
            end_idx <- length(ds_items) + length(rcq_items)
            for (i in start_idx:end_idx) {
                item_id <- all_items$id[i]
                val <- input[[item_id]]
                if (!is.null(val) && nzchar(as.character(val))) {
                    rv$responses[i] <- suppressWarnings(as.numeric(val))
                }
            }
        }
    ),
    
    # Page 5: Open question O1
    list(
        id = "page5",
        type = "custom",
        title = "",
        required = FALSE,
        render_function = function(input, output, session, rv) {
            shiny::div(
                class = "assessment-card",
                shiny::h3("Offene Frage", class = "card-header"),
                shiny::div(style = "padding: 16px;",
                           shiny::textAreaInput("open_O1", "Welche Strategien helfen Ihnen persönlich, digitalen Stress im Alltag zu bewältigen?", value = "", rows = 5)
                )
            )
        },
        completion_handler = function(input, rv) {
            rv$open_O1 <- input$open_O1
        }
    ),
    
    # Page 6: Thank you + submission
    list(
        id = "page6",
        type = "results",
        title = "",
        submit_data = TRUE,
        pass_demographics = TRUE,
        include_demographics = TRUE,
        save_demographics = TRUE
    )
)

# =============================================================================
# CUSTOM CSS
# =============================================================================
custom_css <- '
<style>
  /* Horizontal boxes for 7 response options - UMA baseline */
  .shiny-input-radiogroup .shiny-options-group { display: flex !important; flex-wrap: wrap !important; justify-content: center !important; gap: 8px !important; margin: 20px auto !important; width: 100% !important; }
  input[type="radio"] { width: 16px !important; height: 16px !important; margin: 0 8px 0 0 !important; cursor: pointer !important; flex-shrink: 0 !important; }
  .shiny-options-group label { display: flex !important; align-items: center !important; justify-content: flex-start !important; width: 100% !important; padding: 12px 16px !important; margin: 0 !important; border: 2px solid #e0e0e0 !important; border-radius: 8px !important; background: #fafafa !important; cursor: pointer !important; transition: all 0.2s ease !important; font-size: 14px !important; line-height: 1.4 !important; text-align: left !important; }
  .shiny-options-group label:hover { border-color: #3498db !important; background: #f0f8ff !important; }
  .shiny-options-group input[type="radio"]:checked + label, .shiny-options-group label:has(input[type="radio"]:checked) { border-color: #3498db !important; background: #e3f2fd !important; color: #1976d2 !important; font-weight: 500 !important; }
  .assessment-card { max-width: 960px !important; margin: 0 auto 24px auto !important; padding: 20px !important; }
  .assessment-card .card-header { font-size: 20px !important; margin-bottom: 12px !important; }
  .assessment-card .shiny-input-container { max-width: 560px !important; margin: 0 auto 14px auto !important; }
  .assessment-card .control-label { font-weight: 600 !important; margin-bottom: 6px !important; }
  .assessment-card input[type="number"], .assessment-card input[type="text"], .assessment-card textarea { width: 100% !important; max-width: 560px !important; }
  @media (max-width: 768px) { .shiny-options-group { flex-direction: column !important; } .shiny-options-group label { width: 100% !important; margin-bottom: 8px !important; } .assessment-card { padding: 16px !important; } .assessment-card .card-header { font-size: 18px !important; } }
</style>
'

# =============================================================================
# DATA SAVE FUNCTION
# =============================================================================
save_to_cloud <- NULL

# =============================================================================
# RESULTS PROCESSOR - ENHANCED TO CAPTURE ALL DATA
# =============================================================================
create_mina_report <- function(responses, item_bank, demographics = NULL, rv = NULL, input = NULL, ...) {
    # Generate session id for display
    session_id <- paste0(sample(letters, 8), collapse = "")
    
    # Consent and demographics
    participant_code <- NULL
    
    # Debug: Log what we're receiving
    message("DEBUG: demographics type = ", class(demographics))
    message("DEBUG: demographics = ", if(is.null(demographics)) "NULL" else if(is.list(demographics)) paste(names(demographics), collapse=", ") else paste(demographics, collapse=", "))
    message("DEBUG: rv$demo_data = ", if(is.null(rv$demo_data)) "NULL" else paste(names(rv$demo_data), collapse=", "))
    if (!is.null(rv$demo_data)) {
        message("DEBUG: rv$demo_data$Teilnahme_Code = ", rv$demo_data$Teilnahme_Code)
    }
    message("DEBUG: rv$demo_Teilnahme_Code = ", if(is.null(rv$demo_Teilnahme_Code)) "NULL" else rv$demo_Teilnahme_Code)
    message("DEBUG: rv$participant_code = ", if(is.null(rv$participant_code)) "NULL" else rv$participant_code)
    message("DEBUG: rv keys = ", if(is.null(rv)) "NULL" else paste(names(rv), collapse=", "))
    
    # Handle demographics as either list or atomic vector
    if (!is.null(demographics)) {
        if (is.list(demographics) && !is.null(demographics$Teilnahme_Code)) {
            participant_code <- demographics$Teilnahme_Code
            message("DEBUG: Got participant code from demographics list: ", participant_code)
        } else if (is.atomic(demographics) && length(demographics) > 0 && !is.na(demographics[1])) {
            # If demographics is an atomic vector, it might be the participant code directly
            participant_code <- demographics[1]
            message("DEBUG: Got participant code from demographics vector: ", participant_code)
        }
    }
    
    # Fallback to rv$demo_data
    if (is.null(participant_code) && !is.null(rv) && !is.null(rv$demo_data) && !is.null(rv$demo_data$Teilnahme_Code)) {
        participant_code <- rv$demo_data$Teilnahme_Code
        message("DEBUG: Got participant code from rv$demo_data: ", participant_code)
    } else if (is.null(participant_code) && !is.null(rv) && !is.null(rv$demo_Teilnahme_Code)) {
        participant_code <- rv$demo_Teilnahme_Code
        message("DEBUG: Got participant code from rv$demo_Teilnahme_Code: ", participant_code)
    } else if (is.null(participant_code) && !is.null(rv) && !is.null(rv$participant_code)) {
        participant_code <- rv$participant_code
        message("DEBUG: Got participant code from rv$participant_code: ", participant_code)
    }
    
    # Additional fallback - try to get from global environment or session
    if (is.null(participant_code)) {
        # Try to get from session storage
        sess <- get0("session", ifnotfound = NULL)
        if (!is.null(sess)) {
            session_data <- sess$userData
            if (!is.null(session_data) && !is.null(session_data$demo_data) && !is.null(session_data$demo_data$Teilnahme_Code)) {
                participant_code <- session_data$demo_data$Teilnahme_Code
                message("DEBUG: Got participant code from session data: ", participant_code)
            }
        }
    }
    
    if (is.null(participant_code) || is.na(participant_code)) {
        participant_code <- NA
    }
    
    # Create comprehensive data frame with ALL data
    total_items <- if (!is.null(item_bank)) nrow(item_bank) else 0
    data <- data.frame(
        # Study metadata
        session_id = session_id,
        timestamp = Sys.time(),
        study_name = "Digitale Belastung & Resilienz",
        
        # Participant information
        participant_code = if(!is.null(participant_code) && !is.na(participant_code) && participant_code != "") participant_code else NA,
        
        # Study completion info
        total_items = total_items,
        items_completed = if(!is.null(responses)) length(responses) else 0,
        completion_rate = if(!is.null(responses) && total_items > 0) round(length(responses) / total_items * 100, 2) else 0,
        
        stringsAsFactors = FALSE
    )
    
    # DEBUG: Log response information
    message("DEBUG: responses length = ", if(is.null(responses)) "NULL" else length(responses))
    message("DEBUG: responses = ", if(is.null(responses)) "NULL" else paste(responses, collapse=", "))
    
    # If framework passed an NA-filled vector, rebuild from Shiny inputs
    if (!is.null(responses) && total_items > 0) {
        na_or_empty <- is.na(responses) | responses == ""
        if (all(na_or_empty, na.rm = TRUE) && !is.null(input)) {
            for (i in seq_len(total_items)) {
                val <- input[[item_bank$id[i]]]
                if (!is.null(val) && val != "") {
                    # Ensure numeric 1..7
                    suppressWarnings({ responses[i] <- as.numeric(val) })
                }
            }
            message("DEBUG: responses rebuilt from inputs = ", paste(responses, collapse=", "))
        }
    }
    
    # Add all item responses with proper column names (fallback to input[] for custom pages)
    if ((is.null(responses) || length(responses) == 0) && !is.null(input) && total_items > 0) {
        # Reconstruct from Shiny inputs using item ids
        responses <- vector("list", total_items)
        for (i in seq_len(total_items)) {
            responses[[i]] <- input[[item_bank$id[i]]]
        }
        responses <- unlist(responses, use.names = FALSE)
    }
    
    if (!is.null(responses) && length(responses) > 0 && total_items > 0) {
        if (length(responses) < total_items) {
            responses <- c(responses, rep(NA, total_items - length(responses)))
        } else if (length(responses) > total_items) {
            responses <- responses[1:total_items]
        }
        for (i in seq_len(total_items)) {
            item_name <- item_bank$id[i]
            data[[item_name]] <- responses[i]
        }
    } else if (total_items > 0) {
        for (i in seq_len(total_items)) {
            data[[item_bank$id[i]]] <- NA
        }
    }
    
    # Append consent, demographics and open question
    data$consent_agree <- if (!is.null(rv$consent_agree)) rv$consent_agree else NA
    if (!is.null(rv$demo_data)) {
        dd <- rv$demo_data
        data$Age <- dd$Age %||% NA
        data$Gender <- dd$Gender %||% NA
        data$StudyProgram <- dd$StudyProgram %||% NA
        data$Semester <- dd$Semester %||% NA
        data$ScreenTime <- dd$ScreenTime %||% NA
        data$SocialMedia <- dd$SocialMedia %||% NA
    }
    data$open_O1 <- rv$open_O1 %||% NA
    
    # Add response labels for reference
    data$response_scale <- "1 = stimme gar nicht zu … 7 = stimme voll zu"
    
    # Saving is handled by launch_study via WebDAV (configured at launch)
    
    # Return thank you message
  return(shiny::HTML(paste0(
    '<div style="padding: 40px; text-align: center;">',
    '<h2 style="color: #2c3e50; margin: 0 0 16px 0;">Vielen Dank für Ihre Teilnahme!</h2>',
    '<p style="font-size: 16px; color: #666; margin: 0 0 8px 0;">Ihre Angaben wurden erfolgreich gespeichert.</p>',
    '<p style="font-size: 14px; color: #999; margin: 8px 0 0 0;">(Sie können die Seite jetzt schließen.)</p>',
    '</div>'
  )))
}

# =============================================================================
# VALIDATION FUNCTION
# =============================================================================
validate_page <- function(page_id, input, rv) {
    # Get the current page configuration
    current_page_idx <- rv$current_page %||% 1
    current_page <- rv$config$custom_page_flow[[current_page_idx]]
    
    if (is.null(current_page)) {
        return(list(valid = TRUE))
    }
    
    # Check if this is a required custom page
    if (current_page$type == "custom" && isTRUE(current_page$required)) {
        # Page 1: Consent must be checked (robust handling of NULL/length 0)
        if (page_id == "page1" || current_page$id == "page1") {
            consent_val <- input$consent_agree
            if (is.null(consent_val) || !isTRUE(consent_val)) {
                return(list(valid = FALSE, message = "Bitte stimmen Sie den Teilnahmebedingungen zu, um fortzufahren."))
            }
        }
        # Page 2: Demographics required (age, gender, study, semester)
        if (page_id == "page2" || current_page$id == "page2") {
            age_val <- suppressWarnings(as.numeric(input$demo_Age))
            age_ok <- !is.null(age_val) && !is.na(age_val) && age_val >= 10 && age_val <= 120
            gender_val <- as.character(input$demo_Gender)
            gender_ok <- !is.null(gender_val) && length(gender_val) == 1 && nzchar(trimws(gender_val))
            study_val <- as.character(input$demo_StudyProgram)
            study_ok <- !is.null(study_val) && nzchar(trimws(study_val))
            sem_val <- suppressWarnings(as.numeric(input$demo_Semester))
            sem_ok <- !is.null(sem_val) && !is.na(sem_val) && sem_val >= 1 && sem_val <= 60
            if (!(isTRUE(age_ok) && isTRUE(gender_ok) && isTRUE(study_ok) && isTRUE(sem_ok))) {
                return(list(valid = FALSE, message = "Bitte vervollständigen bzw. korrigieren Sie die demografischen Angaben (gültige Werte)."))
            }
        }
    }
    
    return(list(valid = TRUE))
}

# =============================================================================
# STUDY CONFIGURATION - SIMPLE VERSION (NO COMPREHENSIVE DATASET)
# =============================================================================
study_config <- inrep::create_study_config(
    name = "Digitale Belastung & Resilienz",
    theme = "inrep",
    custom_page_flow = custom_page_flow,
    demographics = NULL,
    demographic_configs = demographic_configs,
    input_types = input_types,
    results_processor = create_mina_report,
    validation_function = validate_page,
    likert_points = 7,
    
    # Fixed-form (custom pages handle item rendering)
    adaptive = FALSE,
    response_ui_type = "radio",
    language = "de",
    
    # Session and UI
    session_save = TRUE,
    show_session_time = FALSE,
    show_progress = TRUE,
    progress_style = "minimal",
    bilingual = FALSE,
    enable_audio = FALSE,
    report_formats = c("csv", "json", "rds"),
    
    initialize_immediately = TRUE
)

# =============================================================================
# LAUNCH STUDY
# =============================================================================
inrep::launch_study(
    config = study_config,
    item_bank = all_items,
    custom_css = custom_css,
     auto_close_time = 30,           # 15 seconds
  auto_close_time_unit = "seconds", # Use seconds as unit
    save_format = "csv",
    webdav_url = "https://sync.academiccloud.de/index.php/s/p1XNKAOuq68JJJ3",
    password = "inreptest",
    debug_mode = TRUE
)