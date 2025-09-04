# =============================================================================
# UMA STUDY - NON-ADAPTIVE VERSION - NO IRT PARAMETERS NEEDED
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
# ITEM BANK - NON-ADAPTIVE VERSION (NO IRT PARAMETERS)
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
    
    # Abschnitt 2 (Items 11-20)
    "Ich habe genügend Zeit, alle von mir für sinnvoll erachteten Beratungsgespräche zu führen.",
    "Ich habe geeignete räumliche Bedingungen für Beratungsgespräche zur Verfügung.",
    "Ich habe die Möglichkeit, mich bei Bedarf mit Kolleg*innen zur Vorbereitung auf Beratungsgespräche auszutauschen.",
    "Ich habe die Möglichkeit, meine geführten Beratungsgespräche bei Bedarf mit Kolleg*innen zu reflektieren.",
    "Ich habe viele Positiv-Beispiele gelungener Beratungsgespräche meiner Kolleg*innen mitbekommen.",
    "Ich achte darauf, wie meine nonverbale Kommunikation (z.B. Mimik, Gestik) in Beratungsgesprächen wirkt.",
    "Ich achte darauf, meine Wortwahl sensibel an meinen Klienten anzupassen.",
    "Ich kann durch die Gestaltung des Gesprächssettings die Atmosphäre beeinflussen.",
    "Ich kann durch meine Vorbereitung (z.B. Unterlagen, Zeitplanung) die Qualität der Beratung beeinflussen.",
    "Ich kann in den Beratungsgesprächen immer geeignete Methoden einsetzen.",
    
    # Abschnitt 3 (Items 21-30)
    "Mir ist bewusst, inwiefern gelungene Beratung ein Zusammenspiel von beeinflussbaren und nicht beeinflussbaren Faktoren ist.",
    "Ich habe das Gefühl, meinen Einfluss realistisch einschätzen zu können.",
    "Ich akzeptiere Dinge, die ich nicht beeinflussen kann.",
    "Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit eine langfristige persönliche Lebensperspektive entwickeln konnten.",
    "Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit umsetzbare Ideen für erste Schritte nach dem Auszug haben.",
    "Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit zugängliche Ansprechstellen für mögliche Unterstützung kennengelernt haben.",
    "Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit Problemlösefähigkeiten verbessern konnten.",
    "Ich habe das Gefühl, dass ich die jungen Männer in den ersten Monaten nach dem Auszug gut begleiten kann.",
    "Ich habe das Gefühl, dass ich die jungen Männer im Stationären Wohnen ausreichend helfen kann.",
    "Ich habe das Gefühl, dass ich positiven Einfluss auf die Entwicklung der langfristigen persönlichen Lebensperspektive der UMA nehmen kann."
  ),
  # NON-ADAPTIVE: Use Option columns for 7-point scale
  Option1 = "stimme überhaupt nicht zu",
  Option2 = "stimme nicht zu", 
  Option3 = "stimme eher nicht zu",
  Option4 = "weder noch",
  Option5 = "stimme eher zu",
  Option6 = "stimme zu",
  Option7 = "stimme voll und ganz zu",
  # NON-ADAPTIVE: No Answer column needed for Likert scales
  stringsAsFactors = FALSE
)

# =============================================================================
# DEMOGRAPHICS CONFIGURATION
# =============================================================================
demographic_configs <- list(
  Teilnahme_Code = list(
    question = "Bitte geben Sie Ihren persönlichen Code ein:",
    type = "text",
    required = TRUE,
    validation_message = "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
  )
)

# =============================================================================
# INPUT TYPES
# =============================================================================
input_types <- list(
  Teilnahme_Code = "text"
)

# Add input types for all items
for (i in 1:30) {
  input_types[[paste0("Item_", sprintf("%02d", i))]] <- "radio"
}

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================
custom_page_flow <- list(
  # Page 1: Welcome with Simple Consent
  list(
    id = "page1", 
    type = "custom",
    title = "",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h2 style="color: #2c3e50;">Herzlich Willkommen zur Befragung über die Beratung<br>Unbegleiteter Minderjähriger Ausländer (UMA)<br>in der Akademie Klausenhof!</h2>',
      '<p>Zunächst findest du hier die Teilnahme-Info und die Einverständniserklärung. ',
      'Anschließend folgen mehrere Aussagen, die du auf einer Skala nach deiner persönlichen Einschätzung einordnen sollst.</p>',
      '<p>Mit der Befragung sollen Anregungen zur Weiterentwicklung der Supervision und möglichen Verbesserungen der Beratungsarbeit mit Geflüchteten gesammelt werden.</p>',
      '<p style="background: #f0f8ff; padding: 15px; border-left: 4px solid #3498db;">',
      '<strong>Die Befragung wird aus zwei Teilen bestehen:</strong> Neben der aktuellen Befragung wird nach Ablauf der fünf Supervisions-Einheiten eine weitere Befragung durchgeführt.</p>',
      '<p>Die Teilnahme an der Befragung ist freiwillig. Eine Nicht-Teilnahme würde zu keinerlei Nachteilen während der Supervision führen.</p>',
      '<p>Um Anonymität größtmöglich zu wahren, wirst du hier nicht nach deinem Namen gefragt, sondern generierst zu Beginn einen Code, den nur du identifizieren kannst. Die erneute Eingabe des Codes bei der zweiten Befragung dient dazu, dass ich als Studien-Ersteller erkennen kann, welche Ausgangswerte sich nach der Supervision wie entwickelt haben. Ein Rückschluss auf eine Person wird nicht stattfinden. Alle Angaben werden selbstverständlich vertraulich behandelt.</p>',
      '<p>Bei Fragen melde dich gerne unter <a href="mailto:ju002893@fh-muenster.de">ju002893@fh-muenster.de</a></p>',
      '<hr style="margin: 30px 0; border: 1px solid #ddd;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">',
      '<h3 style="color: #2c3e50; margin-bottom: 15px;">Einverständniserklärung</h3>',
      '<p style="color: #d9534f; font-weight: bold;">',
      '⚠️ WICHTIG: Durch das Klicken auf "Weiter" bestätigen Sie, dass Sie mit der Teilnahme an der Befragung einverstanden sind.',
      '</p>',
      '</div>',
      '</div>'
    )
  ),
  
  # Page 2: Custom Code Input Page
  list(
    id = "page2",
    type = "custom",
    title = "",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h3 style="color: #2c3e50;">Teilnahme-Code</h3>',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<p><strong>Bitte erstelle deinen Code nach folgender Anleitung:</strong></p>',
      '<ul style="list-style-type: none; padding-left: 0;">',
      '<li style="margin: 10px 0;">Ersten Buchstaben des Vornamens deiner Mutter (z.B. Karla = K)</li>',
      '<li style="margin: 10px 0;">Ersten Buchstaben des Vornamens deines Vaters (z.B. Yusuf = Y)</li>',
      '<li style="margin: 10px 0;">Geburtsmonat (z.B. September = 09)</li>',
      '</ul>',
      '<p style="margin-top: 20px; font-weight: bold; color: #3498db;">Es entsteht ein Code = KY09</p>',
      '</div>',
      '</div>'
    ),
    render_function = function(input, output, session, rv) {
      # Custom render function for page 2 - show code instructions and input field
      output$page_content <- renderUI({
        shiny::div(
          class = "assessment-card",
          style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
          shiny::h3("Teilnahme-Code", class = "card-header"),
          shiny::div(
            style = "padding: 20px; font-size: 16px; line-height: 1.8;",
            shiny::div(
              style = "background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;",
              shiny::p(shiny::strong("Bitte erstelle deinen Code nach folgender Anleitung:")),
              shiny::tags$ul(
                style = "list-style-type: none; padding-left: 0;",
                shiny::tags$li(style = "margin: 10px 0;", "Ersten Buchstaben des Vornamens deiner Mutter (z.B. Karla = K)"),
                shiny::tags$li(style = "margin: 10px 0;", "Ersten Buchstaben des Vornamens deines Vaters (z.B. Yusuf = Y)"),
                shiny::tags$li(style = "margin: 10px 0;", "Geburtsmonat (z.B. September = 09)")
              ),
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
                "Bitte geben Sie Ihren persönlichen Code ein:"
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
      })
    },
    completion_handler = function(input, rv) {
      # Store the participant code
      if (!is.null(input$demo_Teilnahme_Code) && !is.null(rv)) {
        rv$demo_data <- list(Teilnahme_Code = input$demo_Teilnahme_Code)
        message("Saved demographic Teilnahme_Code: ", input$demo_Teilnahme_Code)
      }
    }
  ),
  
  # Page 3: Section 1 intro and items 1-5
  list(
    id = "page3",
    type = "items",
    title = "",
    instructions = "Abschnitt 1 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der Unbegleiteten Minderjährigen Ausländer (UMA)'.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4: Items 6-10 (Section 1 continued)
  list(
    id = "page4",
    type = "items",
    title = "",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 5: Section 2 intro and items 11-15
  list(
    id = "page5",
    type = "items",
    title = "",
    instructions = "Abschnitt 2 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 6: Items 16-20 (Section 2 continued)
  list(
    id = "page6",
    type = "items",
    title = "",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Section 3 intro and items 21-23
  list(
    id = "page7",
    type = "items",
    title = "",
    instructions = "Abschnitt 3 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 21:23,
    scale_type = "likert"
  ),
  
  # Page 8: Items 24-27 (4.1-4.4) - Special section with stem
  list(
    id = "page8",
    type = "custom",
    title = "",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<p style="margin-bottom: 20px;">Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema "Langfristige persönliche Lebensperspektive der UMA".</p>',
      '<div style="background: #f0f8ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #3498db;">',
      '<p style="font-weight: bold; font-size: 18px; color: #2c3e50; margin: 0;">4. Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit…</p>',
      '</div>',
      '</div>'
    ),
    render_function = function(input, output, session, rv) {
      # Custom render function for page 8 - show items 4.1-4.4 with ... prefix
      output$page_content <- renderUI({
        items_to_render <- 24:27
        item_elements <- list()
        
        for (i in items_to_render) {
          item_id <- paste0("Item_", sprintf("%02d", i))
          item_text <- all_items$Question[i]
          
          # Remove the stem part and add 4.1, 4.2, 4.3, 4.4 prefix
          if (grepl("Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit ", item_text)) {
            item_text <- gsub("Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit ", "...", item_text)
          }
          
          # Add item numbering (4.1, 4.2, 4.3, 4.4)
          item_number <- paste0("4.", i - 23)
          
          # Create radio button group with proper Shiny elements
          item_elements[[length(item_elements) + 1]] <- shiny::div(
            class = "item-container",
            style = "margin: 20px 0; padding: 15px; border: 1px solid #e0e0e0; border-radius: 8px;",
            shiny::div(
              class = "item-text",
              style = "font-size: 16px; margin-bottom: 15px;",
              shiny::strong(item_number), " ", item_text
            ),
            shiny::div(
              class = "response-options",
              shiny::div(
                class = "shiny-options-group",
                shiny::radioButtons(
                  inputId = item_id,
                  label = NULL,
                  choices = list(
                    "1 - stimme überhaupt nicht zu" = 1,
                    "2 - stimme nicht zu" = 2,
                    "3 - stimme eher nicht zu" = 3,
                    "4 - weder noch" = 4,
                    "5 - stimme eher zu" = 5,
                    "6 - stimme zu" = 6,
                    "7 - stimme voll und ganz zu" = 7
                  ),
                  selected = character(0),
                  inline = FALSE
                )
              )
            )
          )
        }
        
        # Return with assessment-card frame
        shiny::div(
          class = "assessment-card",
          style = "margin: 0 auto !important; position: relative !important; left: auto !important; right: auto !important;",
          shiny::h3("", class = "card-header"), # Empty header
          shiny::div(
            style = "padding: 20px; font-size: 16px; line-height: 1.8;",
            shiny::p(
              style = "margin-bottom: 20px;",
              "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema \"Langfristige persönliche Lebensperspektive der UMA\"."
            ),
            shiny::div(
              style = "background: #f0f8ff; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #3498db;",
              shiny::p(
                style = "font-weight: bold; font-size: 18px; color: #2c3e50; margin: 0;",
                "4. Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit…"
              )
            ),
            item_elements
          )
        )
      })
    },
    completion_handler = function(input, rv) {
      # Store responses for items 24-27
      items_to_store <- 24:27
      for (i in items_to_store) {
        item_id <- paste0("Item_", sprintf("%02d", i))
        if (!is.null(input[[item_id]])) {
          if (!is.null(rv)) {
            rv[[paste0("item_", item_id)]] <- as.numeric(input[[item_id]])
          }
          message("Saved item response ", i, " (id: ", item_id, "): ", input[[item_id]])
        }
      }
    }
  ),
  
  # Page 9: Items 28-30 (Final items 5, 6, 7)
  list(
    id = "page9",
    type = "items",
    title = "",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 28:30,
    scale_type = "likert"
  ),
  
  # Page 10: Thank you with data submission
  list(
    id = "page10",
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
        message("  File: ", filename)
        message("  URL: ", upload_url)
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
  filename <- paste0("UMA_", timestamp, "_", session_id, ".csv")
  
  # Get participant code from inrep's built-in demographic storage
  participant_code <- NULL
  
  # Debug: Log what we're receiving
  message("DEBUG: demographics type = ", class(demographics))
  message("DEBUG: demographics = ", if(is.null(demographics)) "NULL" else if(is.list(demographics)) paste(names(demographics), collapse=", ") else paste(demographics, collapse=", "))
  message("DEBUG: rv$demo_data = ", if(is.null(rv$demo_data)) "NULL" else paste(names(rv$demo_data), collapse=", "))
  if (!is.null(rv$demo_data)) {
    message("DEBUG: rv$demo_data$Teilnahme_Code = ", rv$demo_data$Teilnahme_Code)
  }
  
  # Handle demographics as either list or atomic vector
  if (!is.null(demographics)) {
    if (is.list(demographics) && !is.null(demographics$Teilnahme_Code)) {
      participant_code <- demographics$Teilnahme_Code
      message("DEBUG: Got participant code from demographics list: ", participant_code)
    } else if (is.atomic(demographics) && length(demographics) > 0) {
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
  }
  
  if (is.null(participant_code)) {
    message("DEBUG: No participant code found!")
  }
  
  # Create data frame with participant code
  data <- data.frame(
    session_id = session_id,
    timestamp = Sys.time(),
    participant_code = if(!is.null(participant_code) && participant_code != "") participant_code else NA,
    stringsAsFactors = FALSE
  )
  
  # Add all item responses
  if (!is.null(responses) && length(responses) > 0) {
    for (i in 1:length(responses)) {
      data[[paste0("Item_", sprintf("%02d", i))]] <- responses[i]
    }
  }
  
  # Save to INREP cloud
  save_to_cloud(data, filename)
  
  # Return thank you message
  return(shiny::HTML(paste0(
    '<div style="padding: 40px; text-align: center;">',
    '<h2 style="color: #2c3e50;">Du hast es geschafft!</h2>',
    '<p style="font-size: 18px; margin: 30px 0;">Vielen Dank für deine Teilnahme!</p>',
    '<p style="font-size: 16px; color: #666;">Ihre Daten wurden erfolgreich gespeichert.</p>',
    '<p style="font-size: 14px; color: #999;">(Du kannst die Seite nun schließen.)</p>',
    '</div>'
  )))
}

# =============================================================================
# VALIDATION FUNCTION
# =============================================================================
validate_page <- function(page_id, input, rv) {
  if (page_id == "page2") {
    # Check code input
    code_value <- input$demo_Teilnahme_Code
    if (is.null(code_value) || trimws(code_value) == "") {
      return(list(
        valid = FALSE,
        message = "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite."
      ))
    }
  }
  
  return(list(valid = TRUE))
}

# =============================================================================
# STUDY CONFIGURATION - NON-ADAPTIVE VERSION
# =============================================================================
study_config <- inrep::create_study_config(
  name = "UMA Befragung",
  theme = "inrep",
  custom_page_flow = custom_page_flow,
  demographics = c("Teilnahme_Code"),
  demographic_configs = demographic_configs,
  input_types = input_types,
  results_processor = create_uma_report,
  validation_function = validate_page,
  
  # NON-ADAPTIVE: No model specification needed (defaults to non-adaptive)
  # model = "GRM",  # REMOVED - not needed for non-adaptive
  
  # CRITICAL: Enable comprehensive data management
  log_data = TRUE,  # Enable logging for testing center data
  
  # Study flow settings
  adaptive = FALSE,  # EXPLICITLY set to non-adaptive
  fixed_items = 1:30,
  response_ui_type = "radio",
  language = "de",
  
  # Data management settings
  session_save = TRUE,
  cloud_storage = FALSE,  # We handle this manually
  
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
  custom_css = custom_css
)