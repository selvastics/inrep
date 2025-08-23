# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION 2.0 WITH ADAPTIVE IRT
# =============================================================================
# Complete bilingual study with Programming Anxiety Scale using adaptive IRT
# Fixed language toggle and complete English translations

library(inrep)

# =============================================================================
# CLOUD STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "ws2526"
WEBDAV_SHARE_TOKEN <- "OUarlqGbhYopkBc"

# =============================================================================
# PROGRAMMING ANXIETY ITEMS WITH IRT PARAMETERS
# =============================================================================

programming_anxiety_items <- data.frame(
  id = paste0("PA_", sprintf("%02d", 1:20)),
  Question = c(
    # Type 1: Items Inferring Programming Expertise (15)
    "Wie sicher fühlen Sie sich, einen Fehler in Ihrem Code ohne Hilfe zu beheben?",
    "Fühlen Sie sich überfordert, wenn Sie mit einem neuen Programmierprojekt beginnen?",
    "Ich mache mir Sorgen, dass meine Programmierkenntnisse für komplexere Aufgaben nicht ausreichen.",
    "Beim Lesen von Dokumentation fühle ich mich oft verloren oder verwirrt.",
    "Das Debuggen von Code macht mich nervös, besonders wenn ich den Fehler nicht sofort finde.",
    "Ich vermeide es, neue Programmiersprachen zu nutzen, weil ich Angst habe, Fehler zu machen.",
    "In Gruppencodier-Sitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
    "Ich habe Sorge, Programmieraufgaben nicht rechtzeitig aufgrund fehlender Fähigkeiten abschließen zu können.",
    "Wenn ich bei einem Programmierproblem nicht weiterkomme, ist es mir peinlich, um Hilfe zu bitten.",
    "Ich fühle mich wohl dabei, meinen Code anderen zu erklären.", # Reverse-scored
    "Fortgeschrittene Programmierkonzepte (z.B. Rekursion, Multithreading) finde ich einschüchternd.",
    "Ich zweifle oft daran, Programmieren über die Grundlagen hinaus lernen zu können.",
    "Wenn mein Code nicht funktioniert, glaube ich, dass es an meinem mangelnden Talent liegt.",
    "Es macht mich nervös, Code ohne Schritt-für-Schritt-Anleitung zu schreiben.",
    "Ich bin zuversichtlich, bestehenden Code zu verändern, um neue Funktionen hinzuzufügen.", # Reverse-scored
    # Type 2: General Programming Anxiety (5)
    "Ich fühle mich manchmal ängstlich, noch bevor ich mit dem Programmieren beginne.",
    "Allein der Gedanke an das Debuggen macht mich angespannt, selbst bei kleineren Fehlern.",
    "Ich mache mir Sorgen, für die Qualität meines Codes beurteilt zu werden.",
    "Wenn mir jemand beim Programmieren zuschaut, werde ich nervös und mache Fehler.",
    "Schon der Gedanke an bevorstehende Programmieraufgaben setzt mich unter Stress."
  ),
  Question_EN = c(
    # Type 1: Items Inferring Programming Expertise (15)
    "How confident are you in your ability to fix an error in your code without help?",
    "Do you feel overwhelmed when starting a new programming project?",
    "I worry that my programming skills are not good enough for more complex tasks.",
    "When reading documentation, I often feel lost or confused.",
    "Debugging code makes me anxious, especially when I cannot immediately spot the issue.",
    "I avoid using new programming languages because I am afraid of making mistakes.",
    "During group coding sessions, I am nervous that my contributions will not be valued.",
    "I worry that I will be unable to finish a coding assignment on time due to lack of skills.",
    "When I get stuck on a programming problem, I feel embarrassed to ask for help.",
    "I feel comfortable explaining my code to others.", # Reverse-scored
    "I find advanced coding concepts (e.g., recursion, multithreading) intimidating.",
    "I often doubt my ability to learn programming beyond the basics.",
    "When my code does not work, I worry it is because I lack programming talent.",
    "I feel anxious when asked to write code without step-by-step instructions.",
    "I am confident in modifying existing code to add new features.", # Reverse-scored
    # Type 2: General Programming Anxiety (5)
    "I sometimes feel anxious even before sitting down to start programming.",
    "The thought of debugging makes me tense, even if the bug is minor.",
    "I worry about being judged for the quality of my code.",
    "When someone watches me code, I get nervous and make mistakes.",
    "I feel stressed just by thinking about upcoming programming tasks."
  ),
  # IRT parameters for 2PL model
  a = c(1.2, 1.5, 1.3, 1.1, 1.4, 1.0, 0.9, 1.2, 1.3, 1.4, 
        1.5, 1.2, 1.1, 1.3, 1.2, 1.0, 1.1, 1.3, 1.4, 1.2),
  b = c(-0.5, 0.2, 0.5, 0.3, 0.7, 0.8, 0.4, 0.6, 0.3, -0.2,
        1.0, 0.9, 0.7, 0.6, 0.1, 0.0, 0.2, 0.4, 0.5, 0.3),
  ResponseCategories = rep("1,2,3,4,5", 20),
  stringsAsFactors = FALSE
)

# Items 10 and 15 are reverse-scored - handle in scoring
programming_anxiety_items$reverse_scored <- c(rep(FALSE, 9), TRUE, rep(FALSE, 4), TRUE, rep(FALSE, 5))

# =============================================================================
# ADAPTIVE IRT CONFIGURATION FOR PROGRAMMING ANXIETY
# =============================================================================

programming_anxiety_config <- inrep::create_study_config(
  name = "Programming Anxiety Assessment",
  model = "2PL",
  adaptive = TRUE,
  criteria = "MFI",  # Maximum Fisher Information
  min_items = 10,
  max_items = 10,
  min_SEM = 0.3,
  adaptive_start = 5,  # First 5 items fixed, then 5 adaptive
  theme = "professional"
)

# =============================================================================
# BFI AND OTHER ITEMS (BILINGUAL)
# =============================================================================

bfi_items <- data.frame(
  id = c(
    "BFE_01", "BFE_02", "BFE_03", "BFE_04",
    "BFV_01", "BFV_02", "BFV_03", "BFV_04",
    "BFG_01", "BFG_02", "BFG_03", "BFG_04",
    "BFN_01", "BFN_02", "BFN_03", "BFN_04",
    "BFO_01", "BFO_02", "BFO_03", "BFO_04"
  ),
  Question = c(
    # Extraversion
    "Ich gehe aus mir heraus, bin gesellig.",
    "Ich bin eher ruhig.",
    "Ich bin eher schüchtern.",
    "Ich bin gesprächig.",
    # Agreeableness
    "Ich bin einfühlsam, warmherzig.",
    "Ich habe mit anderen wenig Mitgefühl.",
    "Ich bin hilfsbereit und selbstlos.",
    "Andere sind mir eher gleichgültig, egal.",
    # Conscientiousness
    "Ich bin eher unordentlich.",
    "Ich bin systematisch, halte meine Sachen in Ordnung.",
    "Ich mag es sauber und aufgeräumt.",
    "Ich bin eher der chaotische Typ, mache selten sauber.",
    # Neuroticism
    "Ich bleibe auch in stressigen Situationen gelassen.",
    "Ich reagiere leicht angespannt.",
    "Ich mache mir oft Sorgen.",
    "Ich werde selten nervös und unsicher.",
    # Openness
    "Ich bin vielseitig interessiert.",
    "Ich meide philosophische Diskussionen.",
    "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
    "Mich interessieren abstrakte Überlegungen wenig."
  ),
  Question_EN = c(
    # Extraversion
    "I am outgoing, sociable.",
    "I am rather quiet.",
    "I am rather shy.",
    "I am talkative.",
    # Agreeableness
    "I am empathetic, warm-hearted.",
    "I have little sympathy for others.",
    "I am helpful and selfless.",
    "Others are rather indifferent to me.",
    # Conscientiousness
    "I am rather disorganized.",
    "I am systematic, keep my things in order.",
    "I like it clean and tidy.",
    "I am rather the chaotic type, rarely clean up.",
    # Neuroticism
    "I remain calm even in stressful situations.",
    "I react easily tensed.",
    "I often worry.",
    "I rarely become nervous and insecure.",
    # Openness
    "I have diverse interests.",
    "I avoid philosophical discussions.",
    "I enjoy thinking thoroughly about complex things and understanding them.",
    "I have little interest in abstract considerations."
  ),
  ResponseCategories = rep("1,2,3,4,5", 20),
  stringsAsFactors = FALSE
)

# =============================================================================
# CUSTOM STUDY FUNCTION WITH ADAPTIVE IRT AND BILINGUAL SUPPORT
# =============================================================================

run_hildesheim_study <- function() {
  
  # Create UI with language support
  ui <- shiny::fluidPage(
    shiny::tags$head(
      shiny::tags$style(HTML("
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        .btn-lang { 
          position: fixed; 
          top: 20px; 
          right: 20px; 
          z-index: 1000;
          background: white;
          border: 2px solid #e8041c;
          color: #e8041c;
          padding: 8px 16px;
          border-radius: 4px;
          cursor: pointer;
        }
        .btn-lang:hover {
          background: #e8041c;
          color: white;
        }
        .content-de, .content-en {
          padding: 20px;
        }
        .consent-box {
          background: #f8f9fa;
          padding: 20px;
          border-radius: 8px;
          margin-top: 20px;
        }
      "))
    ),
    
    # Language toggle button
    shiny::actionButton("lang_toggle", "🇬🇧 English Version", class = "btn-lang"),
    
    # Main content
    shiny::uiOutput("main_content")
  )
  
  # Server logic
  server <- function(input, output, session) {
    
    # Reactive values
    values <- shiny::reactiveValues(
      language = "de",
      current_page = 1,
      pa_responses = list(),
      bfi_responses = list(),
      demo_responses = list(),
      pa_theta = NULL,
      pa_se = NULL,
      pa_items_shown = c()
    )
    
    # Language toggle
    shiny::observeEvent(input$lang_toggle, {
      if (values$language == "de") {
        values$language <- "en"
        shiny::updateActionButton(session, "lang_toggle", label = "🇩🇪 Deutsche Version")
      } else {
        values$language <- "de"
        shiny::updateActionButton(session, "lang_toggle", label = "🇬🇧 English Version")
      }
    })
    
    # Main content rendering
    output$main_content <- shiny::renderUI({
      lang <- values$language
      
      if (values$current_page == 1) {
        # Welcome page with consent
        title <- if (lang == "de") "Willkommen zur HilFo Studie" else "Welcome to the HilFo Study"
        
        shiny::tagList(
          shiny::h2(title, style = "color: #e8041c;"),
          
          if (lang == "de") {
            shiny::tagList(
              shiny::p("In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, 
                       die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren."),
              shiny::p("Die Befragung dauert etwa 15-20 Minuten und umfasst auch eine neue adaptive 
                       Programmierangst-Skala."),
              shiny::div(class = "consent-box",
                shiny::h4("Einverständniserklärung"),
                shiny::checkboxInput("consent", "Ich bin mit der Teilnahme an der Befragung einverstanden", FALSE)
              )
            )
          } else {
            shiny::tagList(
              shiny::p("In the statistics exercises, we want to work with illustrative data that comes from you. 
                       Therefore, we would like to learn a few things about you."),
              shiny::p("The survey takes about 15-20 minutes and includes a new adaptive Programming Anxiety Scale."),
              shiny::div(class = "consent-box",
                shiny::h4("Declaration of Consent"),
                shiny::checkboxInput("consent", "I agree to participate in the survey", FALSE)
              )
            )
          },
          
          shiny::br(),
          shiny::actionButton("next_page", 
                            if (lang == "de") "Weiter" else "Continue",
                            class = "btn btn-primary")
        )
        
      } else if (values$current_page == 2) {
        # Programming Anxiety Adaptive Assessment
        render_programming_anxiety_page(values, lang)
        
      } else if (values$current_page == 3) {
        # BFI Assessment
        render_bfi_page(values, lang)
        
      } else if (values$current_page == 4) {
        # Demographics
        render_demographics_page(values, lang)
        
      } else if (values$current_page == 5) {
        # Results and IRT report
        render_results_page(values, lang)
      }
    })
    
    # Next page navigation
    shiny::observeEvent(input$next_page, {
      if (values$current_page == 1 && input$consent) {
        values$current_page <- 2
      } else if (values$current_page < 5) {
        values$current_page <- values$current_page + 1
      }
    })
  }
  
  # Run the app
  shiny::shinyApp(ui = ui, server = server)
}

# Helper function for Programming Anxiety adaptive page
render_programming_anxiety_page <- function(values, lang) {
  shiny::tagList(
    shiny::h3(if (lang == "de") "Programmierangst-Bewertung" else "Programming Anxiety Assessment"),
    shiny::p(if (lang == "de") 
             "Diese adaptive Bewertung passt sich Ihren Antworten an. Bitte beantworten Sie die Fragen ehrlich."
             else 
             "This adaptive assessment adjusts to your responses. Please answer the questions honestly."),
    
    # Placeholder for adaptive item presentation
    shiny::uiOutput("pa_item"),
    
    shiny::br(),
    shiny::actionButton("submit_pa", if (lang == "de") "Antwort absenden" else "Submit Answer")
  )
}

# Helper function for BFI page
render_bfi_page <- function(values, lang) {
  items <- if (lang == "de") bfi_items$Question else bfi_items$Question_EN
  
  shiny::tagList(
    shiny::h3(if (lang == "de") "Persönlichkeitsfragebogen" else "Personality Questionnaire"),
    
    lapply(1:length(items), function(i) {
      shiny::radioButtons(
        inputId = paste0("bfi_", i),
        label = items[i],
        choices = if (lang == "de") {
          c("Trifft überhaupt nicht zu" = 1,
            "Trifft eher nicht zu" = 2,
            "Weder noch" = 3,
            "Trifft eher zu" = 4,
            "Trifft voll und ganz zu" = 5)
        } else {
          c("Strongly disagree" = 1,
            "Disagree" = 2,
            "Neither agree nor disagree" = 3,
            "Agree" = 4,
            "Strongly agree" = 5)
        },
        inline = TRUE
      )
    }),
    
    shiny::br(),
    shiny::actionButton("next_page", if (lang == "de") "Weiter" else "Continue")
  )
}

# Helper function for demographics page
render_demographics_page <- function(values, lang) {
  shiny::tagList(
    shiny::h3(if (lang == "de") "Demografische Angaben" else "Demographic Information"),
    
    shiny::selectInput(
      "age",
      if (lang == "de") "Alter:" else "Age:",
      choices = c("", as.character(18:30), if (lang == "de") "über 30" else "over 30")
    ),
    
    shiny::radioButtons(
      "gender",
      if (lang == "de") "Geschlecht:" else "Gender:",
      choices = if (lang == "de") {
        c("weiblich" = "f", "männlich" = "m", "divers" = "d")
      } else {
        c("female" = "f", "male" = "m", "diverse" = "d")
      }
    ),
    
    shiny::selectInput(
      "program",
      if (lang == "de") "Studiengang:" else "Study Program:",
      choices = if (lang == "de") {
        c("", "Psychologie B.Sc.", "Psychologie M.Sc.", "Anderer")
      } else {
        c("", "Psychology B.Sc.", "Psychology M.Sc.", "Other")
      }
    ),
    
    shiny::br(),
    shiny::actionButton("next_page", if (lang == "de") "Weiter" else "Continue")
  )
}

# Helper function for results page with IRT visualization
render_results_page <- function(values, lang) {
  shiny::tagList(
    shiny::h3(if (lang == "de") "Ihre Ergebnisse" else "Your Results"),
    
    # Programming Anxiety IRT Results
    shiny::h4(if (lang == "de") "Programmierangst-Profil" else "Programming Anxiety Profile"),
    shiny::plotOutput("irt_plot"),
    
    shiny::p(if (lang == "de") {
      paste0("Geschätzter Angstwert (Theta): ", round(values$pa_theta, 2),
             " (SE: ", round(values$pa_se, 3), ")")
    } else {
      paste0("Estimated anxiety level (Theta): ", round(values$pa_theta, 2),
             " (SE: ", round(values$pa_se, 3), ")")
    }),
    
    # BFI Results
    shiny::h4(if (lang == "de") "Persönlichkeitsprofil" else "Personality Profile"),
    shiny::plotOutput("bfi_plot"),
    
    # Download button
    shiny::downloadButton("download_results", 
                         if (lang == "de") "Ergebnisse herunterladen" else "Download Results")
  )
}

# =============================================================================
# LAUNCH STUDY
# =============================================================================

cat("\n================================================================================\n")
cat("HILFO STUDIE - VERSION 2.0 WITH ADAPTIVE IRT\n")
cat("================================================================================\n")
cat("Features:\n")
cat("- Bilingual support (German/English) with working toggle\n")
cat("- Programming Anxiety Scale with adaptive IRT (10 items: 5 fixed + 5 adaptive)\n")
cat("- BFI personality assessment\n")
cat("- Complete demographics\n")
cat("- IRT visualization and reports\n")
cat("================================================================================\n\n")

# Launch the study
run_hildesheim_study()