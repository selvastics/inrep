# =============================================================================
# UMA STUDY -
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
# ITEM BANK -
# =============================================================================
all_items <- data.frame(
  id = paste0("Item_", sprintf("%02d", 1:30)),
  Question = c(
    # Abschnitt 1 (Items 1-10)
    "Ich kann einschätzen, wie viel Zeit ich für ein Beratungsgespräch einplanen sollte.",
    "Ich kann einschätzen, wie häufig Beratungsgespräche sinnvoll sind.",
    "Ich habe eine klare Vorstellung davon, welche räumlichen Bedingungen für die Beratungen geeignet sind.",
    "Ich kann einschätzen, welche Einflüsse meine nonverbale Kommunikation (z.B. Mimik, Gestik) auf Beratungsgespräche haben kann.",
    "Ich habe einen Überblick darüber, inwiefern ich Faktoren für das Gelingen von Beratung beeinflussen kann.",
    "Mir ist bewusst, inwiefern mir der Austausch mit Kolleg*innen bei der Vorbereitung von Beratungsgesprächen hilft.",
    "Mir ist bewusst, inwiefern mir der Austausch mit Kolleg*innen bei der Reflexion von Beratungsgesprächen hilft.",
    "Mir ist bewusst, inwiefern frühere Erfahrungen der jungen Männer Beratungsgespräche beeinflussen können.",
    "Mir ist bewusst, inwiefern mein eigenes Stresslevel Beratungsgespräche beeinflussen kann.",
    "Mir ist bewusst, inwiefern kulturelle & sprachliche Hintergründe die Interaktionen prägen können.",
    
    # Abschnitt 2 (Items 11-15)
    "Ich habe genügend Zeit, alle von mir für sinnvoll erachteten Beratungsgespräche zu führen.",
    "Ich habe geeignete räumliche Bedingungen für Beratungsgespräche zur Verfügung.",
    "Ich habe die Möglichkeit, mich bei Bedarf mit Kolleg*innen zur Vorbereitung auf Beratungsgespräche auszutauschen.",
    "Ich habe die Möglichkeit, meine geführten Beratungsgespräche bei Bedarf mit Kolleg*innen zu reflektieren.",
    "Ich habe viele Positiv-Beispiele gelungener Beratungsgespräche meiner Kolleg*innen mitbekommen.",
    
    # Abschnitt 2 (Items 16-20)
    "Ich achte darauf, wie meine nonverbale Kommunikation (z.B. Mimik, Gestik) in Beratungsgesprächen wirkt.",
    "Ich achte darauf, meine Wortwahl sensibel an meinen Klienten anzupassen.",
    "Ich kann durch die Gestaltung des Gesprächssettings die Atmosphäre beeinflussen.",
    "Ich kann durch meine Vorbereitung (z.B. Unterlagen, Zeitplanung) die Qualität der Beratung beeinflussen.",
    "Ich kann in den Beratungsgesprächen immer geeignete Methoden einsetzen.",
    
    # Abschnitt 3 (Items 21-23)
    "Mir ist bewusst, inwiefern gelungene Beratung ein Zusammenspiel von beeinflussbaren und nicht beeinflussbaren Faktoren ist.",
    "Ich habe das Gefühl, meinen Einfluss realistisch einschätzen zu können.",
    "Ich akzeptiere Dinge, die ich nicht beeinflussen kann.",
    
    # Abschnitt 3 (Items 24-27) - With stem
    "…eine langfristige persönliche Lebensperspektive entwickeln konnten.",
    "…umsetzbare Ideen für erste Schritte nach dem Auszug haben.",
    "…zugängliche Ansprechstellen für mögliche Unterstützung kennengelernt haben.",
    "…Problemlösefähigkeiten verbessern konnten.",
    
    # Abschnitt 4 (Items 28-30)
    "Ich habe das Gefühl, dass ich die jungen Männer in den ersten Monaten nach dem Auszug gut begleiten kann.",
    "Ich habe das Gefühl, dass ich den jungen Männer im Stationären Wohnen ausreichend helfen kann.",
    "Ich habe das Gefühl, dass ich positiven Einfluss auf die Entwicklung der langfristigen persönlichen Lebensperspektive der UMA nehmen kann."
  ),
  # : Use Option columns for 7-point scale
  Option1 = "stimme überhaupt nicht zu",
  Option2 = "stimme nicht zu",
  Option3 = "stimme eher nicht zu",
  Option4 = "weder noch",
  Option5 = "stimme eher zu",
  Option6 = "stimme zu",
  Option7 = "stimme voll und ganz zu",
  stringsAsFactors = FALSE
)
# =============================================================================
# DEMOGRAPHICS CONFIGURATION
# =============================================================================
demographic_configs <- list(
  Teilnahme_Code = list(
    question = "Bitte geben Sie Ihren persönlichen Code ein (wie bei der ersten Befragung):",
    type = "text",
    required = TRUE,
    validation_message = "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
  ),
  Feedback_Thema = list(
    question = "Bei welchem (Teil-)Thema in der Supervision konntest du am meisten für deine Arbeit mitnehmen?",
    type = "text",
    required = FALSE
  ),
  Feedback_Mehr = list(
    question = "Welches (Teil-)Thema hättest du dir gewünscht, in der Supervision mehr zu bearbeiten?",
    type = "text",
    required = FALSE
  ),
  Feedback_Organisation = list(
    question = "Welche Rückmeldung möchtest du zum organisatorischen Ablauf der Supervision geben?",
    type = "text",
    required = FALSE
  ),
  Feedback_Methodik = list(
    question = "Welche Rückmeldung möchtest du zum methodischen Vorgehen in der Supervision geben?",
    type = "text",
    required = FALSE
  )
)
# =============================================================================
# INPUT TYPES
# =============================================================================
input_types <- list(
  Teilnahme_Code = "text",
  Feedback_Thema = "text",
  Feedback_Mehr = "text",
  Feedback_Organisation = "text",
  Feedback_Methodik = "text"
)
# Add input types for all items
for (i in 1:30) {
  input_types[[paste0("Item_", sprintf("%02d", i))]] <- "radio"
}
# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================
custom_page_flow <- list(
  # Page 1: Welcome - Post-Supervision
  list(
    id = "page1",
    type = "custom",
    title = "",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h2 style="color: #2c3e50;">Herzlich Willkommen zur Befragung über die Beratung Unbegleiteter Minderjähriger Ausländer (UMA) in der Akademie Klausenhof nach Abschluss der fünf Supervisionssitzungen!</h2>',
      '<p>Zunächst findest du hier die Teilnahme-Info. Anschließend folgen mehrere Aussagen, zu denen du gebeten wirst, deine persönliche Einschätzung abzugeben.</p>',
      '<p>Mit der Befragung sollen Anregungen für die Evaluation der Supervision gegeben werden.</p>',
      '<p style="background: #f0f8ff; padding: 15px; border-left: 4px solid #3498db;">',
      '<strong>Vielen Dank noch einmal für die Teilnahme an der Befragung vor Beginn der Supervision!</strong></p>',
      '<p>Hier folgt nun Teil 2 der Befragung.</p>',
      '<p>Die Teilnahme an der Befragung ist freiwillig. Eine Teilnahme hilft mir sehr bei der Evaluation.</p>',
      '<p>Um Anonymität größtmöglich zu wahren, wirst du hier nicht nach deinem Namen gefragt, sondern generierst den gleichen Code wie bei der ersten Befragung, den nur du identifizieren kannst.</p>',
      '<p>Die erneute Eingabe ist für eine präzise Evaluation wichtig.</p>',
      '<p>Ein Rückschluss auf eine Person wird nicht stattfinden. Alle Angaben werden selbstverständlich vertraulich behandelt.</p>',
      '<p>Bei Fragen melde dich gerne unter <a href="mailto:ju002893@fh-muenster.de">ju002893@fh-muenster.de</a></p>',
      '<hr style="margin: 30px 0; border: 1px solid #ddd;">',
      '<p style="font-weight: bold; text-align: center; color: #2c3e50; font-size: 18px;">',
      'Mit dem Klick auf „Weiter" startet die Befragung.',
      '</p>',
      '</div>'
    )
  ),
  
  # Page 2: Code Input Page
  list(
    id = "page2",
    type = "custom",
    title = "",
    required = TRUE,
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h3 style="color: #2c3e50;">Teilnahme-Code</h3>',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<p><strong>Ersten Buchstaben des Vornamens deiner Mutter (z.B. Karla = K)</strong></p>',
      '<p><strong>Ersten Buchstaben des Vornamens deines Vaters (z.B. Yusuf = Y)</strong></p>',
      '<p><strong>Geburtsmonat (z.B. September = 09)</strong></p>',
      '<p style="margin-top: 20px; font-weight: bold; color: #3498db;">Es entsteht ein Code = KY09</p>',
      '</div>',
      '</div>'
    ),
    render_function = function(input, output, session, rv) {
      shiny::div(
        class = "assessment-card",
        style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
        shiny::h3("Teilnahme-Code", class = "card-header"),
        shiny::div(
          style = "padding: 20px; font-size: 16px; line-height: 1.8;",
          shiny::div(
            style = "background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;",
            shiny::p(shiny::strong("Ersten Buchstaben des Vornamens deiner Mutter (z.B. Karla = K)")),
            shiny::p(shiny::strong("Ersten Buchstaben des Vornamens deines Vaters (z.B. Yusuf = Y)")),
            shiny::p(shiny::strong("Geburtsmonat (z.B. September = 09)")),
            shiny::p(
              style = "margin-top: 20px; font-weight: bold; color: #3498db;",
              "Es entsteht ein Code = KY09"
            )
          ),
          shiny::div(
            style = "margin: 20px 0;",
            shiny::tags$label(
              `for` = "demo_Teilnahme_Code",
              style = "display: block; margin-bottom: 10px; font-weight: bold;",
              "Bitte geben Sie Ihren persönlichen Code ein (wie bei der ersten Befragung):"
            ),
            shiny::tags$input(
              type = "text",
              id = "demo_Teilnahme_Code",
              name = "demo_Teilnahme_Code",
              placeholder = "z.B. KY09",
              style = "width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 4px; font-size: 16px;"
            )
          )
        )
      )
    },
    completion_handler = function(input, rv) {
      if (!is.null(input$demo_Teilnahme_Code) && !is.null(rv)) {
        rv$demo_data <- list(Teilnahme_Code = input$demo_Teilnahme_Code)
        rv$demo_Teilnahme_Code <- input$demo_Teilnahme_Code
        rv$participant_code <- input$demo_Teilnahme_Code
        message("Saved demographic Teilnahme_Code: ", input$demo_Teilnahme_Code)
      }
    }
  ),
  
  # Page 3: Abschnitt 1 von 4 - Items 1-5
  list(
    id = "page3",
    type = "items",
    title = "Abschnitt 1 von 4",
    instructions = paste0(
      
      "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema ",
      "„Langfristige persönliche Lebensperspektive der Unbegleiteten Minderjährigen Ausländer (UMA).“"
    ),
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4: Abschnitt 1 - Items 6-10
  list(
    id = "page4",
    type = "items",
    title = "Abschnitt 1 von 4 (Fortsetzung)",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 5: Abschnitt 2 von 4 - Items 11-15
  list(
    id = "page5",
    type = "items",
    title = "Abschnitt 2 von 4",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 6: Abschnitt 2 - Items 16-20
  list(
    id = "page6",
    type = "items",
    title = "Abschnitt 2 von 4 (Fortsetzung)",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Abschnitt 3 von 4 - Items 21-23
  list(
    id = "page7",
    type = "items",
    title = "Abschnitt 3 von 4",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“",
    item_indices = 21:23,
    scale_type = "likert"
  ),
  
  # Page 8: Abschnitt 3 - Items 24-27 (with stem)
  list(
    id = "page8",
    type = "items",
    title = "Abschnitt 3 von 4 (Fortsetzung)",
    instructions = paste0(
      "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“\n\n",
      "Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit…"
    ),
    item_indices = 24:27,
    scale_type = "likert"
  ),
  
  # Page 9: Abschnitt 4 - Items 28-30
  list(
    id = "page9",
    type = "items",
    title = "Abschnitt 4 von 4",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema „Langfristige persönliche Lebensperspektive der UMA“",
    item_indices = 28:30,
    scale_type = "likert"
  ),
  
  # Page 10: Feedback - Open Feedback Questions
  list(
    id = "page10",
    type = "custom",
    title = "Feedback zur Supervision",
    content = "",
    render_function = function(input, output, session, rv) {
      shiny::div(
        class = "assessment-card",
        style = "margin: 0 auto !important;",
        shiny::h3("Feedback zur Supervision", class = "card-header"),
        shiny::div(
          style = "padding: 20px;",
          
          # Question 1
          shiny::div(
            style = "margin-bottom: 30px;",
            shiny::tags$label(
              `for` = "demo_Feedback_Thema",
              style = "display: block; margin-bottom: 10px; font-weight: bold;",
              "1. Bei welchem Teil-Thema in der Supervision konntest du am meisten für deine Arbeit mitnehmen?"
            ),
            shiny::tags$textarea(
              id = "demo_Feedback_Thema",
              name = "demo_Feedback_Thema",
              rows = "4",
              style = "width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 4px; font-size: 14px; font-family: inherit;"
            )
          ),
          
          # Question 2
          shiny::div(
            style = "margin-bottom: 30px;",
            shiny::tags$label(
              `for` = "demo_Feedback_Mehr",
              style = "display: block; margin-bottom: 10px; font-weight: bold;",
              "2. Welches (Teil-)Thema hättest du dir gewünscht, in der Supervision mehr zu bearbeiten?"
            ),
            shiny::tags$textarea(
              id = "demo_Feedback_Mehr",
              name = "demo_Feedback_Mehr",
              rows = "4",
              style = "width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 4px; font-size: 14px; font-family: inherit;"
            )
          ),
          
          # Question 3
          shiny::div(
            style = "margin-bottom: 30px;",
            shiny::tags$label(
              `for` = "demo_Feedback_Organisation",
              style = "display: block; margin-bottom: 10px; font-weight: bold;",
              "3. Welche Rückmeldung möchtest du zum organisatorischen Ablauf der Supervision geben?"
            ),
            shiny::tags$textarea(
              id = "demo_Feedback_Organisation",
              name = "demo_Feedback_Organisation",
              rows = "4",
              style = "width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 4px; font-size: 14px; font-family: inherit;"
            )
          ),
          
          # Question 4
          shiny::div(
            style = "margin-bottom: 30px;",
            shiny::tags$label(
              `for` = "demo_Feedback_Methodik",
              style = "display: block; margin-bottom: 10px; font-weight: bold;",
              "4. Welche Rückmeldung möchtest du zum methodischen Vorgehen in der Supervision geben?"
            ),
            shiny::tags$textarea(
              id = "demo_Feedback_Methodik",
              name = "demo_Feedback_Methodik",
              rows = "4",
              style = "width: 100%; padding: 12px; border: 2px solid #ddd; border-radius: 4px; font-size: 14px; font-family: inherit;"
            )
          )
        )
      )
    },
    completion_handler = function(input, rv) {
      if (!is.null(rv)) {
        if (is.null(rv$demo_data)) {
          rv$demo_data <- list()
        }
        rv$demo_data$Feedback_Thema <- input$demo_Feedback_Thema %||% ""
        rv$demo_data$Feedback_Mehr <- input$demo_Feedback_Mehr %||% ""
        rv$demo_data$Feedback_Organisation <- input$demo_Feedback_Organisation %||% ""
        rv$demo_data$Feedback_Methodik <- input$demo_Feedback_Methodik %||% ""
        message("Saved feedback data")
      }
    }
  ),
  
  # Page 11: Thank You / Results
  list(
    id = "page11",
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
  /* Horizontal boxes for 7 response options - RESPONSIVE FLEXBOX */
  .shiny-input-radiogroup .shiny-options-group {
    display: flex !important;
    flex-wrap: wrap !important;
    justify-content: center !important;
    gap: 8px !important;
    margin: 20px auto !important;
    width: 100% !important;
  }
 
  /* Radio buttons - smaller and left-aligned */
  input[type="radio"] {
    width: 16px !important;
    height: 16px !important;
    margin: 0 8px 0 0 !important;
    cursor: pointer !important;
    flex-shrink: 0 !important;
  }
 
  /* Box styling for labels - left-aligned with radio */
  .shiny-options-group label {
    display: flex !important;
    align-items: center !important;
    justify-content: flex-start !important;
    width: 100% !important;
    padding: 12px 16px !important;
    margin: 0 !important;
    border: 2px solid #e0e0e0 !important;
    border-radius: 8px !important;
    background: #fafafa !important;
    cursor: pointer !important;
    transition: all 0.2s ease !important;
    font-size: 14px !important;
    line-height: 1.4 !important;
    text-align: left !important;
  }
 
  /* Hover effect */
  .shiny-options-group label:hover {
    border-color: #3498db !important;
    background: #f0f8ff !important;
  }
 
  /* Selected state */
  .shiny-options-group input[type="radio"]:checked + label,
  .shiny-options-group label:has(input[type="radio"]:checked) {
    border-color: #3498db !important;
    background: #e3f2fd !important;
    color: #1976d2 !important;
    font-weight: 500 !important;
  }
 
  /* Textarea styling */
  textarea {
    font-family: inherit !important;
    resize: vertical !important;
  }
 
  /* Responsive design */
  @media (max-width: 768px) {
    .shiny-options-group {
      flex-direction: column !important;
    }
    .shiny-options-group label {
      width: 100% !important;
      margin-bottom: 8px !important;
    }
  }
</style>
'
# =============================================================================
# DATA SAVE FUNCTION
# =============================================================================
save_to_cloud <- function(data = NULL, filename = NULL, ...) {
  if (is.null(data) || is.null(filename)) {
    return(FALSE)
  }
  
  tryCatch({
    # Save locally first
    local_file <- file.path("data", filename)
    if (!dir.exists("data")) dir.create("data")
    write.csv(data, local_file, row.names = FALSE)
    
    # Upload to INREP WebDAV
    if (requireNamespace("httr", quietly = TRUE)) {
      library(httr)
      upload_url <- paste0(WEBDAV_URL, filename)
      
      response <- httr::PUT(
        url = upload_url,
        body = httr::upload_file(local_file),
        httr::authenticate(WEBDAV_SHARE_TOKEN, WEBDAV_PASSWORD, type = "basic"),
        httr::add_headers(
          "Content-Type" = "text/csv",
          "X-Requested-With" = "XMLHttpRequest"
        )
      )
      
      if (httr::status_code(response) %in% c(200, 201, 204)) {
        message("✓ Data successfully uploaded to INREP cloud!")
        message(" File: ", filename)
        message(" URL: ", upload_url)
      }
    }
    
    return(TRUE)
  }, error = function(e) {
    message("Error saving data: ", e$message)
    return(FALSE)
  })
}
# =============================================================================
# RESULTS PROCESSOR
# =============================================================================
create_uma_report <- function(responses, item_bank, demographics = NULL, rv = NULL, input = NULL, ...) {
  # Generate filename with timestamp
  timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  session_id <- paste0(sample(letters, 8), collapse = "")
  filename <- paste0("UMA_POST_", timestamp, "_", session_id, ".csv")
  
  # Get participant code
  participant_code <- NULL
  
  # Try different sources for participant code
  if (!is.null(demographics)) {
    if (is.list(demographics) && !is.null(demographics$Teilnahme_Code)) {
      participant_code <- demographics$Teilnahme_Code
    } else if (is.atomic(demographics) && length(demographics) > 0) {
      participant_code <- demographics[1]
    }
  }
  
  if (is.null(participant_code) && !is.null(rv)) {
    if (!is.null(rv$demo_data) && !is.null(rv$demo_data$Teilnahme_Code)) {
      participant_code <- rv$demo_data$Teilnahme_Code
    } else if (!is.null(rv$demo_Teilnahme_Code)) {
      participant_code <- rv$demo_Teilnahme_Code
    } else if (!is.null(rv$participant_code)) {
      participant_code <- rv$participant_code
    }
  }
  
  if (is.null(participant_code)) {
    participant_code <- "UNKNOWN"
  }
  
  # Get feedback data
  feedback_thema <- ""
  feedback_mehr <- ""
  feedback_organisation <- ""
  feedback_methodik <- ""
  
  if (!is.null(rv) && !is.null(rv$demo_data)) {
    feedback_thema <- rv$demo_data$Feedback_Thema %||% ""
    feedback_mehr <- rv$demo_data$Feedback_Mehr %||% ""
    feedback_organisation <- rv$demo_data$Feedback_Organisation %||% ""
    feedback_methodik <- rv$demo_data$Feedback_Methodik %||% ""
  }
  
  # Create comprehensive data frame
  data <- data.frame(
    # Study metadata
    session_id = session_id,
    timestamp = Sys.time(),
    study_name = "UMA Befragung - Post-Supervision",
    study_phase = "POST",
    
    # Participant information
    participant_code = participant_code,
    
    # Study completion info
    total_items = 30,
    items_completed = if(!is.null(responses)) length(responses) else 0,
    completion_rate = if(!is.null(responses)) round(length(responses) / 30 * 100, 2) else 0,
    
    # Feedback questions
    feedback_thema = feedback_thema,
    feedback_mehr = feedback_mehr,
    feedback_organisation = feedback_organisation,
    feedback_methodik = feedback_methodik,
    
    stringsAsFactors = FALSE
  )
  
  # Add all item responses
  if (!is.null(responses) && length(responses) > 0) {
    if (length(responses) < 30) {
      responses <- c(responses, rep(NA, 30 - length(responses)))
    } else if (length(responses) > 30) {
      responses <- responses[1:30]
    }
    
    for (i in 1:30) {
      item_name <- paste0("Item_", sprintf("%02d", i))
      data[[item_name]] <- responses[i]
    }
  } else {
    for (i in 1:30) {
      item_name <- paste0("Item_", sprintf("%02d", i))
      data[[item_name]] <- NA
    }
  }
  
  # Add response scale info
  data$response_scale <- "1=stimme überhaupt nicht zu, 2=stimme nicht zu, 3=stimme eher nicht zu, 4=weder noch, 5=stimme eher zu, 6=stimme zu, 7=stimme voll und ganz zu"
  
  # Save to cloud
  save_to_cloud(data, filename)
  
  # Return thank you message
  return(shiny::HTML(paste0(
    '<div style="padding: 40px; text-align: center;">',
    '<h2 style="color: #2c3e50;">Du hast es geschafft!</h2>',
    '<p style="font-size: 18px; margin: 30px 0;">Vielen Dank für deine Teilnahme!</p>',
    '<p style="font-size: 14px; color: #999;">(Du kannst die Seite nun schließen.)</p>',
    '</div>'
  )))
}
# =============================================================================
# VALIDATION FUNCTION
# =============================================================================
validate_page <- function(page_id, input, rv) {
  current_page_idx <- rv$current_page %||% 1
  current_page <- rv$config$custom_page_flow[[current_page_idx]]
  
  if (is.null(current_page)) {
    return(list(valid = TRUE))
  }
  
  # Check if this is a required custom page
  if (current_page$type == "custom" && isTRUE(current_page$required)) {
    if (page_id == "page2" || current_page$id == "page2") {
      code_value <- input$demo_Teilnahme_Code
      if (is.null(code_value) || trimws(code_value) == "") {
        return(list(
          valid = FALSE,
          message = "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
        ))
      }
    }
  }
  
  return(list(valid = TRUE))
}
# =============================================================================
# STUDY CONFIGURATION
# =============================================================================
study_config <- inrep::create_study_config(
  name = "UMA Befragung - Post-Supervision",
  theme = "inrep",
  custom_page_flow = custom_page_flow,
  demographics = c("Teilnahme_Code", "Feedback_Thema", "Feedback_Mehr", "Feedback_Organisation", "Feedback_Methodik"),
  demographic_configs = demographic_configs,
  input_types = input_types,
  results_processor = create_uma_report,
  validation_function = validate_page,
  
  # Study flow settings
  adaptive = FALSE,
  fixed_items = 1:30,
  response_ui_type = "radio",
  language = "de",
  
  # Data management settings
  log_data = FALSE,
  session_save = TRUE,
  cloud_storage = FALSE,
  
  # UI settings
  show_progress = TRUE,
  progress_style = "minimal",
  bilingual = FALSE,
  enable_audio = FALSE,
  
  # Performance settings
  initialize_immediately = TRUE
)
# =============================================================================
# LAUNCH STUDY
# =============================================================================
inrep::launch_study(
  config = study_config,
  item_bank = all_items,
  custom_css = custom_css,
  auto_close_time = 15,
  auto_close_time_unit = "seconds",
  disable_auto_close = FALSE
)