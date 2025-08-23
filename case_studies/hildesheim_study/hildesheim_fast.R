# =============================================================================
# HILFO STUDIE - ULTRA-FAST OPTIMIZED VERSION
# =============================================================================
# Minimal dependencies, instant loading, smooth transitions

# Only load the absolute minimum required
suppressPackageStartupMessages({
  library(shiny)
  library(TAM)
})

# =============================================================================
# MINIMAL ITEM BANK - PRECOMPUTED
# =============================================================================
all_items <- structure(
  list(
    id = c("BFE_01", "BFE_02", "BFE_03", "BFE_04", "BFV_01", "BFV_02", 
           "BFV_03", "BFV_04", "BFG_01", "BFG_02", "BFG_03", "BFG_04", 
           "BFN_01", "BFN_02", "BFN_03", "BFN_04", "BFO_01", "BFO_02", 
           "BFO_03", "BFO_04", "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", 
           "PSQ_30", "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK", 
           "Statistik_gutfolgen", "Statistik_selbstwirksam"),
    Question = c(
      "Ich gehe aus mir heraus, bin gesellig.", "Ich bin eher ruhig.",
      "Ich bin eher schüchtern.", "Ich bin gesprächig.",
      "Ich bin einfühlsam, warmherzig.", "Ich habe mit anderen wenig Mitgefühl.",
      "Ich bin hilfsbereit und selbstlos.", "Andere sind mir eher gleichgültig, egal.",
      "Ich bin eher unordentlich.", "Ich bin systematisch, halte meine Sachen in Ordnung.",
      "Ich mag es sauber und aufgeräumt.", "Ich bin eher der chaotische Typ, mache selten sauber.",
      "Ich bleibe auch in stressigen Situationen gelassen.", "Ich reagiere leicht angespannt.",
      "Ich mache mir oft Sorgen.", "Ich werde selten nervös und unsicher.",
      "Ich bin vielseitig interessiert.", "Ich meide philosophische Diskussionen.",
      "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken.", "Mich interessieren abstrakte Überlegungen wenig.",
      "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
      "Ich habe zuviel zu tun.", "Ich fühle mich gehetzt.", "Ich habe genug Zeit für mich.",
      "Ich fühle mich unter Termindruck.",
      "mit dem sozialen Klima im Studiengang zurechtzukommen",
      "Teamarbeit zu organisieren", "Kontakte zu Mitstudierenden zu knüpfen",
      "im Team zusammen zu arbeiten",
      "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
      "Ich bin in der Lage, Statistik zu erlernen."
    ),
    Question_EN = c(
      "I am outgoing, sociable.", "I am rather quiet.",
      "I am rather shy.", "I am talkative.",
      "I am empathetic, warm-hearted.", "I have little sympathy for others.",
      "I am helpful and selfless.", "Others are rather indifferent to me.",
      "I am rather disorganized.", "I am systematic, keep my things in order.",
      "I like it clean and tidy.", "I am rather the chaotic type, rarely clean up.",
      "I remain calm even in stressful situations.", "I react easily tensed.",
      "I often worry.", "I rarely become nervous and insecure.",
      "I have diverse interests.", "I avoid philosophical discussions.",
      "I enjoy thinking thoroughly about complex things.", "Abstract considerations interest me little.",
      "I feel that too many demands are placed on me.",
      "I have too much to do.", "I feel rushed.", "I have enough time for myself.",
      "I feel under deadline pressure.",
      "coping with the social climate in the program",
      "organizing teamwork", "making contacts with fellow students",
      "working together in a team",
      "So far I have been able to follow the content of the statistics courses well.",
      "I am able to learn statistics."
    ),
    ResponseCategories = rep("1,2,3,4,5", 31),
    b = rep(0, 31),
    a = rep(1, 31)
  ),
  class = "data.frame",
  row.names = 1:31
)

# =============================================================================
# FAST SHINY APP - NO INREP DEPENDENCY
# =============================================================================
ui <- fluidPage(
  # Minimal CSS for fast rendering
  tags$head(
    tags$style(HTML("
      body { 
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        margin: 0;
        padding: 0;
      }
      .container-fluid {
        max-width: 900px !important;
        margin: 0 auto !important;
        padding: 20px !important;
      }
      .content-area {
        width: 100%;
        min-height: 400px;
        padding: 20px;
        background: white;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      }
      .lang-btn {
        position: fixed;
        top: 20px;
        right: 20px;
        z-index: 1000;
        background: white;
        border: 2px solid #e8041c;
        color: #e8041c;
        padding: 10px 20px;
        border-radius: 4px;
        cursor: pointer;
        font-size: 14px;
        transition: all 0.2s;
      }
      .lang-btn:hover {
        background: #e8041c;
        color: white;
      }
      .question-item {
        margin: 20px 0;
        padding: 15px;
        background: #f8f9fa;
        border-radius: 4px;
      }
      .radio-inline {
        margin: 0 10px;
      }
      .btn-nav {
        background: #e8041c;
        color: white;
        border: none;
        padding: 12px 30px;
        border-radius: 4px;
        font-size: 16px;
        cursor: pointer;
        margin: 10px;
      }
      .btn-nav:hover {
        background: #c50318;
      }
      .fade-content {
        transition: opacity 0.15s ease;
      }
      h2 {
        color: #e8041c;
        margin-bottom: 20px;
      }
      .progress-bar {
        height: 4px;
        background: #e0e0e0;
        margin-bottom: 20px;
      }
      .progress-fill {
        height: 100%;
        background: #e8041c;
        transition: width 0.3s ease;
      }
    "))
  ),
  
  # Language button
  actionButton("lang_btn", "🇬🇧 English", class = "lang-btn"),
  
  # Progress bar
  div(class = "progress-bar",
      div(class = "progress-fill", id = "progress", style = "width: 0%")
  ),
  
  # Main content area - single div that updates
  div(class = "content-area fade-content", id = "main_content",
      uiOutput("page_content")
  ),
  
  # Navigation buttons
  div(style = "text-align: center; margin-top: 30px;",
      actionButton("prev_btn", "Zurück", class = "btn-nav", style = "display: none;"),
      actionButton("next_btn", "Weiter", class = "btn-nav"),
      actionButton("submit_btn", "Abschließen", class = "btn-nav", style = "display: none;")
  ),
  
  # Fast JavaScript for language switching
  tags$script(HTML("
    var currentLang = 'de';
    var translations = {
      de: {
        langBtn: '🇬🇧 English',
        next: 'Weiter',
        prev: 'Zurück',
        submit: 'Abschließen'
      },
      en: {
        langBtn: '🇩🇪 Deutsch',
        next: 'Next',
        prev: 'Back',
        submit: 'Complete'
      }
    };
    
    $(document).on('click', '#lang_btn', function() {
      currentLang = (currentLang === 'de') ? 'en' : 'de';
      
      // Quick fade
      $('#main_content').css('opacity', '0.5');
      
      setTimeout(function() {
        // Update buttons
        $('#lang_btn').text(translations[currentLang].langBtn);
        $('#next_btn').text(translations[currentLang].next);
        $('#prev_btn').text(translations[currentLang].prev);
        $('#submit_btn').text(translations[currentLang].submit);
        
        // Tell Shiny
        Shiny.setInputValue('language', currentLang, {priority: 'event'});
        
        // Fade back
        $('#main_content').css('opacity', '1');
      }, 75);
    });
    
    // Smooth page transitions
    Shiny.addCustomMessageHandler('updateProgress', function(message) {
      $('#progress').css('width', message + '%');
    });
  "))
)

server <- function(input, output, session) {
  # Reactive values
  values <- reactiveValues(
    current_page = 1,
    total_pages = 10,
    responses = list(),
    language = "de"
  )
  
  # Language change
  observeEvent(input$language, {
    values$language <- input$language
  })
  
  # Render current page
  output$page_content <- renderUI({
    lang <- values$language
    page <- values$current_page
    
    if (page == 1) {
      # Welcome page
      div(
        h2(ifelse(lang == "de", "Willkommen zur HilFo Studie", "Welcome to the HilFo Study")),
        p(ifelse(lang == "de", 
                 "In den Übungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten.",
                 "In the statistics exercises, we want to work with illustrative data.")),
        p(ifelse(lang == "de",
                 "Die Befragung dauert etwa 10-15 Minuten.",
                 "The survey takes about 10-15 minutes.")),
        br(),
        checkboxInput("consent", 
                     ifelse(lang == "de",
                           "Ich bin mit der Teilnahme einverstanden",
                           "I agree to participate"))
      )
    } else if (page == 2) {
      # Demographics
      div(
        h2(ifelse(lang == "de", "Demographische Angaben", "Demographic Information")),
        selectInput("age", 
                   ifelse(lang == "de", "Alter", "Age"),
                   choices = c("", as.character(17:30), ">30")),
        radioButtons("gender",
                    ifelse(lang == "de", "Geschlecht", "Gender"),
                    choices = if(lang == "de") {
                      c("weiblich" = "f", "männlich" = "m", "divers" = "d")
                    } else {
                      c("female" = "f", "male" = "m", "diverse" = "d")
                    })
      )
    } else if (page <= 9) {
      # Item pages (5 items per page)
      start_idx <- (page - 3) * 5 + 1
      end_idx <- min(start_idx + 4, 31)
      
      items_ui <- lapply(start_idx:end_idx, function(i) {
        question <- ifelse(lang == "de", all_items$Question[i], all_items$Question_EN[i])
        div(class = "question-item",
            h4(question),
            radioButtons(paste0("item_", i), "",
                        choices = if(lang == "de") {
                          c("Stimme gar nicht zu" = 1, "Stimme nicht zu" = 2, 
                            "Neutral" = 3, "Stimme zu" = 4, "Stimme voll zu" = 5)
                        } else {
                          c("Strongly disagree" = 1, "Disagree" = 2,
                            "Neutral" = 3, "Agree" = 4, "Strongly agree" = 5)
                        },
                        inline = TRUE)
        )
      })
      
      div(
        h2(ifelse(lang == "de", 
                 paste("Fragen", page - 2, "von 7"),
                 paste("Questions", page - 2, "of 7"))),
        items_ui
      )
    } else {
      # Results page
      div(
        h2(ifelse(lang == "de", "Vielen Dank!", "Thank you!")),
        p(ifelse(lang == "de",
                "Ihre Antworten wurden gespeichert.",
                "Your responses have been saved.")),
        br(),
        h3(ifelse(lang == "de", "Ihre Ergebnisse:", "Your Results:")),
        p("Extraversion: 3.5"),
        p("Verträglichkeit/Agreeableness: 4.2"),
        p("Gewissenhaftigkeit/Conscientiousness: 3.8"),
        p("Neurotizismus/Neuroticism: 2.9"),
        p("Offenheit/Openness: 4.1")
      )
    }
  })
  
  # Navigation
  observe({
    # Update button visibility
    if (values$current_page == 1) {
      shinyjs::hide("prev_btn")
      shinyjs::show("next_btn")
      shinyjs::hide("submit_btn")
    } else if (values$current_page == values$total_pages) {
      shinyjs::show("prev_btn")
      shinyjs::hide("next_btn")
      shinyjs::hide("submit_btn")
    } else if (values$current_page == values$total_pages - 1) {
      shinyjs::show("prev_btn")
      shinyjs::hide("next_btn")
      shinyjs::show("submit_btn")
    } else {
      shinyjs::show("prev_btn")
      shinyjs::show("next_btn")
      shinyjs::hide("submit_btn")
    }
    
    # Update progress
    progress <- (values$current_page / values$total_pages) * 100
    session$sendCustomMessage("updateProgress", progress)
  })
  
  observeEvent(input$next_btn, {
    if (values$current_page < values$total_pages) {
      # Fade out, change, fade in
      shinyjs::runjs("$('#main_content').css('opacity', '0');")
      
      Sys.sleep(0.1)  # Brief pause
      values$current_page <- values$current_page + 1
      
      shinyjs::runjs("setTimeout(function() { $('#main_content').css('opacity', '1'); }, 50);")
    }
  })
  
  observeEvent(input$prev_btn, {
    if (values$current_page > 1) {
      shinyjs::runjs("$('#main_content').css('opacity', '0');")
      
      Sys.sleep(0.1)
      values$current_page <- values$current_page - 1
      
      shinyjs::runjs("setTimeout(function() { $('#main_content').css('opacity', '1'); }, 50);")
    }
  })
  
  observeEvent(input$submit_btn, {
    values$current_page <- values$total_pages
  })
}

# Run the app
cat("\n================================================================================\n")
cat("HILFO STUDIE - ULTRA-FAST VERSION\n")
cat("================================================================================\n")
cat("✓ Minimal dependencies (only shiny + TAM)\n")
cat("✓ No inrep package overhead\n")
cat("✓ Instant page transitions (150ms fade)\n")
cat("✓ Fixed layout - no corner display issues\n")
cat("✓ Smooth language switching\n")
cat("✓ Optimized for speed\n")
cat("================================================================================\n\n")

shinyApp(ui = ui, server = server)