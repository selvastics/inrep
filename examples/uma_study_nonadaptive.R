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
    "Ich kann einschätzen, welche Rolle meine eigene Haltung und Einstellung in der Beratung spielt.",
    "Ich habe eine klare Vorstellung davon, wie ich mit kulturellen Unterschieden in der Beratung umgehen kann.",
    "Ich kann einschätzen, welche Bedeutung Vertrauen und Beziehungsaufbau in der Beratung haben.",
    "Ich habe einen Überblick darüber, wie ich mit schwierigen Gesprächssituationen umgehen kann.",
    
    # Abschnitt 2 (Items 11-20)
    "Ich kann einschätzen, wie wichtig es ist, die individuellen Bedürfnisse der UMA zu verstehen.",
    "Ich habe eine klare Vorstellung davon, wie ich mit Traumata und belastenden Erfahrungen umgehen kann.",
    "Ich kann einschätzen, welche Rolle Sprache und Kommunikation in der Beratung spielen.",
    "Ich habe einen Überblick darüber, wie ich mit Unsicherheiten und Ängsten der UMA umgehen kann.",
    "Ich kann einschätzen, welche Bedeutung Bildung und Zukunftsperspektiven für die UMA haben.",
    "Ich habe eine klare Vorstellung davon, wie ich mit familiären Bindungen und Verlusten umgehen kann.",
    "Ich kann einschätzen, welche Rolle Religion und Spiritualität in der Beratung spielen können.",
    "Ich habe einen Überblick darüber, wie ich mit rechtlichen Fragen und Unsicherheiten umgehen kann.",
    "Ich kann einschätzen, welche Bedeutung soziale Kontakte und Freundschaften für die UMA haben.",
    "Ich habe eine klare Vorstellung davon, wie ich mit Rassismus und Diskriminierung umgehen kann.",
    
    # Abschnitt 3 (Items 21-30)
    "Ich kann einschätzen, wie wichtig es ist, die Stärken und Ressourcen der UMA zu erkennen.",
    "Ich habe eine klare Vorstellung davon, wie ich mit Rückfällen und Rückschlägen umgehen kann.",
    "Ich kann einschätzen, welche Rolle Motivation und Zielsetzung in der Beratung spielen.",
    "Ich habe einen Überblick darüber, wie ich mit Konflikten und Spannungen umgehen kann.",
    "Ich kann einschätzen, welche Bedeutung Selbstbestimmung und Eigenverantwortung für die UMA haben.",
    "Ich habe eine klare Vorstellung davon, wie ich mit Abhängigkeiten und Suchtverhalten umgehen kann.",
    "Ich kann einschätzen, welche Rolle Kreativität und kulturelle Ausdrucksformen in der Beratung spielen.",
    "Ich habe einen Überblick darüber, wie ich mit Einsamkeit und Isolation umgehen kann.",
    "Ich kann einschätzen, welche Bedeutung Hoffnung und Optimismus für die UMA haben.",
    "Ich habe eine klare Vorstellung davon, wie ich mit Abschied und Übergängen umgehen kann."
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
  
  # Page 2: Code Generation with input field
  list(
    id = "page2",
    type = "demographics",
    title = "",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h3 style="color: #2c3e50;">Generierung deines persönlichen Codes</h3>',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin: 20px 0;">',
      '<p><strong>Bitte erstelle deinen Code nach folgender Anleitung:</strong></p>',
      '<ul style="list-style-type: none; padding-left: 0;">',
      '<li style="margin: 10px 0;">Ersten Buchstaben des Vornamens deiner Mutter (z.B. Karla = K)</li>',
      '<li style="margin: 10px 0;">Ersten Buchstaben des Vornamens deines Vaters (z.B. Yusuf = Y)</li>',
      '<li style="margin: 10px 0;">Geburtsmonat (z.B. September = 09)</li>',
      '</ul>',
      '<p style="margin-top: 20px; font-weight: bold; color: #3498db;">Es entsteht ein Code</p>',
      '</div>',
      '</div>'
    ),
    demographics = c("Teilnahme_Code")
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
  
  # Page 4: Items 6-10
  list(
    id = "page4",
    type = "items",
    title = "",
    instructions = "Abschnitt 1 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
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
  
  # Page 6: Items 16-20
  list(
    id = "page6",
    type = "items",
    title = "",
    instructions = "Abschnitt 2 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Section 3 intro and items 21-25
  list(
    id = "page7",
    type = "items",
    title = "",
    instructions = "Abschnitt 3 von 3\n\nFolgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    item_indices = 21:25,
    scale_type = "likert"
  ),
  
  # Page 8: Items 26-30
  list(
    id = "page8",
    type = "items",
    title = "",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.\n\n    Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit...",
    item_indices = 26:30,
    scale_type = "likert"
  ),
  
  # Page 9: Thank you with data submission
  list(
    id = "page9",
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
  message("DEBUG: demographics = ", if(is.null(demographics)) "NULL" else paste(names(demographics), collapse=", "))
  message("DEBUG: rv$demo_data = ", if(is.null(rv$demo_data)) "NULL" else paste(names(rv$demo_data), collapse=", "))
  if (!is.null(rv$demo_data)) {
    message("DEBUG: rv$demo_data$Teilnahme_Code = ", rv$demo_data$Teilnahme_Code)
  }
  
  if (!is.null(demographics) && !is.null(demographics$Teilnahme_Code)) {
    participant_code <- demographics$Teilnahme_Code
    message("DEBUG: Got participant code from demographics: ", participant_code)
  } else if (!is.null(rv) && !is.null(rv$demo_data) && !is.null(rv$demo_data$Teilnahme_Code)) {
    participant_code <- rv$demo_data$Teilnahme_Code
    message("DEBUG: Got participant code from rv$demo_data: ", participant_code)
  } else if (!is.null(rv) && !is.null(rv$demo_Teilnahme_Code)) {
    participant_code <- rv$demo_Teilnahme_Code
    message("DEBUG: Got participant code from rv$demo_Teilnahme_Code: ", participant_code)
  } else {
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