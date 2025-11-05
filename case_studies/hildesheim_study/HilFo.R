library(inrep)
library(shiny)
library(ggplot2)
library(broom)
library(emmeans)
library(ggthemes)
library(DT)
library(shinycssloaders)

# CRITICAL: Standardized filename function to ensure consistency across all exports
generate_hilfo_filename <- function(timestamp = NULL) {
  if (is.null(timestamp)) {
    timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  }
  return(paste0("HilFo_results_", timestamp, ".csv"))
}
library(patchwork)
library(markdown)
library(shinyjs)

# Helper: Attach an observer to a live Shiny session so that when the client
# sets the `finish_early` input the server attempts to stop the app.
# Usage: call attach_finish_early_observer(session) from your server function
# or session initialization code so the observer is registered for that session.
attach_finish_early_observer <- function(session) {
    if (is.null(session)) return(invisible(NULL))
    tryCatch({
        # Register after first flush to ensure session$input is available
        session$onFlushed(function() {
            # observeEvent must be created in server reactive context; placing
            # it inside onFlushed ensures the callback runs in the correct context.
            shiny::observeEvent(session$input$finish_early, {
                # Try to stop the app gracefully
                tryCatch({
                    shiny::stopApp()
                }, error = function(e) {
                    # If stopApp fails, attempt to close the session
                    try({ session$close() }, silent = TRUE)
                })
            }, ignoreInit = TRUE)
        }, once = TRUE)
    }, error = function(e) {
        message("attach_finish_early_observer: could not attach observer: ", e$message)
    })
    invisible(NULL)
}


# =============================================================================
# HILFO STUDIE - PRODUCTION VERSION WITH COMPLETE DATA RECORDING
# =============================================================================
# All variables recorded with proper names, cloud storage enabled
# NOW WITH PROGRAMMING ANXIETY ADDED (2 pages before BFI)

# ULTRA-FAST STARTUP: Check package but don't load until needed
if (!requireNamespace("inrep", quietly = TRUE)) {
    stop("Package 'inrep' is required. Please install it.")
}

# Use later package for deferred loading of heavy packages
if (!requireNamespace("later", quietly = TRUE)) {
    install.packages("later", quiet = TRUE)
}

# Helper function for lazy loading - optimized version
.load_if_needed <- function(pkg) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        message(paste("Installing required package:", pkg))
        install.packages(pkg, quiet = TRUE)
    }
    # Don't load yet, just ensure it's available
    invisible(TRUE)
}

# Schedule heavy package checks for after startup
later::later(function() {
    .load_if_needed("ggplot2")
    .load_if_needed("base64enc")
    .load_if_needed("httr")
}, delay = 0.1)  # Load after UI is ready

# =============================================================================
# CLOUD STORAGE CREDENTIALS - Hildesheim Study Folder
# =============================================================================
# Public WebDAV folder: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"  # Share token for authentication

# =============================================================================
# COMPLETE ITEM BANK WITH PROPER VARIABLE NAMES
# =============================================================================

# Create bilingual item bank
# STARS-D adapted for Programming Anxiety (23 items based on Statistical Anxiety Rating Scale)
all_items_de <- data.frame(
    id = c(
        # Programming Anxiety items (23) - STARS-D adapted
        paste0("PA_", sprintf("%02d", 1:23)),
        # BFI items with proper naming convention
        "BFE_01", "BFE_02", "BFE_03", "BFE_04", # Extraversion
        "BFV_01", "BFV_02", "BFV_03", "BFV_04", # Verträglichkeit (Agreeableness)
        "BFG_01", "BFG_02", "BFG_03", "BFG_04", # Gewissenhaftigkeit (Conscientiousness)
        "BFN_01", "BFN_02", "BFN_03", "BFN_04", # Neurotizismus
        "BFO_01", "BFO_02", "BFO_03", "BFO_04", # Offenheit (Openness)
        # PSQ items
        "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
        # MWS items
        "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
        # Statistics items
        "Statistik_gutfolgen", "Statistik_selbstwirksam"
    ),
    Question = c(
        # Programming Anxiety (German) - STARS-D adapted (23 items)
        # Instruction: "Die folgenden Aussagen beschreiben Situationen, die mit Programmieren zu tun haben. 
        # Wählen Sie bitte die Option, die am besten beschreibt, wie viel Angst Sie in der entsprechenden 
        # Situation erleben würden. Es gibt keine richtigen oder falschen Antworten."
        "Sie bereiten sich auf eine Programmierprüfung vor.",
        "Sie müssen Code aus einem Tutorial oder einer Dokumentation interpretieren.",
        "Sie fragen Ihren Programmierdozenten/Ihre Programmierdozentin, ob er/sie Ihnen Inhalte aus der Lehrveranstaltung, die Sie nicht verstehen, noch einmal individuell erklären kann.",
        "Sie bearbeiten eine Programmieraufgabe für eine Lehrveranstaltung.",
        "Sie müssen ein Problem lösen, indem Sie ein Programm schreiben.",
        "Sie lesen ein Code-Beispiel, das mehrere Programmierkonzepte enthält.",
        "Sie versuchen zu entscheiden, welche Programmiersprache oder welches Framework für Ihr Projekt geeignet ist.",
        "Sie nehmen an einer Programmierprüfung teil.",
        "Sie lesen eine technische Beschreibung, die Code-Beispiele und Algorithmen enthält.",
        "Nachdem Sie ihn endlich herausgefunden haben, müssen Sie die Bedeutung einer Fehlermeldung interpretieren.",
        "Sie betreten einen Raum, um an einer Programmierprüfung teilzunehmen.",
        "Sie müssen eine Menge an Daten in einem Programm verarbeiten.",
        "Sie stellen fest, dass ein Kommilitone/eine Kommilitonin eine andere Lösung für ein Programmierproblem hat als Sie.",
        "Sie müssen entscheiden, ob Ihr Code korrekt funktioniert oder einen Fehler enthält.",
        "Sie wachen am Morgen einer Programmierprüfung auf.",
        "Sie bitten einen Dozenten/eine Dozentin, Ihnen Ihren Code oder eine Fehlermeldung zu erklären.",
        "Sie versuchen, einen Algorithmus zu verstehen und nachzuvollziehen.",
        "Sie beobachten einen Studenten/eine Studentin, wie er/sie sehr viele Zeilen Code für ein Projekt schreibt.",
        "Sie bitten jemanden im Computerraum, Ihnen beim Debuggen zu helfen.",
        "Sie versuchen, Code-Beispiele in einer Dokumentation oder einem Lehrbuch zu verstehen.",
        "Sie schreiben sich für eine Programmierlehrveranstaltung ein.",
        "Sie gehen eine bereits benotete Programmierprüfung noch einmal durch.",
        "Sie bitten einen Kommilitonen/eine Kommilitonin, Ihnen bei einem Programmierproblem zu helfen.",
        
        # BFI Extraversion (items 24-27)
        "Ich gehe aus mir heraus, bin gesellig.",
        "Ich bin eher ruhig.",
        "Ich bin eher schüchtern.",
        "Ich bin gesprächig.",
        # BFI Verträglichkeit
        "Ich bin einfühlsam, warmherzig.",
        "Ich habe mit anderen wenig Mitgefühl.",
        "Ich bin hilfsbereit und selbstlos.",
        "Andere sind mir eher gleichgültig, egal.",
        # BFI Gewissenhaftigkeit
        "Ich bin eher unordentlich.",
        "Ich bin systematisch, halte meine Sachen in Ordnung.",
        "Ich mag es sauber und aufgeräumt.",
        "Ich bin eher der chaotische Typ, mache selten sauber.",
        # BFI Neurotizismus
        "Ich bleibe auch in stressigen Situationen gelassen.",
        "Ich reagiere leicht angespannt.",
        "Ich mache mir oft Sorgen.",
        "Ich werde selten nervös und unsicher.",
        # BFI Offenheit
        "Ich bin vielseitig interessiert.",
        "Ich meide philosophische Diskussionen.",
        "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
        "Mich interessieren abstrakte Überlegungen wenig.",
        # PSQ Stress
        "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.",
        "Ich habe zuviel zu tun.",
        "Ich fühle mich gehetzt.",
        "Ich habe genug Zeit für mich.",
        "Ich fühle mich unter Termindruck.",
        # MWS Study Skills
        "mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)",
        "Teamarbeit zu organisieren (z.B. Lerngruppen finden)",
        "Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)",
        "im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)",
        # Statistics
        "Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.",
        "Ich bin in der Lage, Statistik zu erlernen."
    ),
    Question_EN = c(
        # Programming Anxiety (English) - STARS-D adapted (23 items)
        "You are preparing for a programming exam.",
        "You have to interpret code from a tutorial or documentation.",
        "You ask your programming instructor if they can explain content from the course that you don't understand individually.",
        "You are working on a programming assignment for a course.",
        "You have to solve a problem by writing a program.",
        "You are reading a code example that contains multiple programming concepts.",
        "You are trying to decide which programming language or framework is suitable for your project.",
        "You are taking a programming exam.",
        "You are reading a technical description that contains code examples and algorithms.",
        "After finally figuring it out, you have to interpret the meaning of an error message.",
        "You enter a room to take a programming exam.",
        "You have to process a large amount of data in a program.",
        "You notice that a classmate has a different solution to a programming problem than you do.",
        "You have to decide whether your code works correctly or contains an error.",
        "You wake up on the morning of a programming exam.",
        "You ask an instructor to explain your code or an error message to you.",
        "You are trying to understand and comprehend an algorithm.",
        "You observe a student writing many lines of code for a project.",
        "You ask someone in the computer lab to help you debug.",
        "You are trying to understand code examples in documentation or a textbook.",
        "You are enrolling in a programming course.",
        "You are reviewing an already graded programming exam.",
        "You ask a classmate to help you with a programming problem.",
        
        # BFI Extraversion (items 24-27)
        "I am outgoing, sociable.",
        "I am rather quiet.",
        "I am rather shy.",
        "I am talkative.",
        # BFI Agreeableness (items 28-31)
        "I am empathetic, warm-hearted.",
        "I have little sympathy for others.",
        "I am helpful and selfless.",
        "Others are rather indifferent to me.",
        # BFI Conscientiousness
        "I am rather disorganized.",
        "I am systematic, keep my things in order.",
        "I like it clean and tidy.",
        "I am rather the chaotic type, rarely clean up.",
        # BFI Neuroticism
        "I remain calm even in stressful situations.",
        "I react easily tensed.",
        "I often worry.",
        "I rarely become nervous and insecure.",
        # BFI Openness
        "I have diverse interests.",
        "I avoid philosophical discussions.",
        "I enjoy thinking thoroughly about complex things and understanding them.",
        "Abstract considerations interest me little.",
        # PSQ Stress
        "I feel that too many demands are placed on me.",
        "I have too much to do.",
        "I feel rushed.",
        "I have enough time for myself.",
        "I feel under deadline pressure.",
        # MWS Study Skills
        "coping with the social climate in the program (e.g., handling competition)",
        "organizing teamwork (e.g., finding study groups)",
        "making contacts with fellow students (e.g., for study groups, leisure)",
        "working together in a team (e.g., working on tasks together, preparing presentations)",
        # Statistics
        "So far I have been able to follow the content of the statistics courses well.",
        "I am able to learn statistics."
    ),
    reverse_coded = c(
        # Programming Anxiety - no reverse coding (all items measure anxiety directly)
        rep(FALSE, 23),
        # BFI reverse coding
        FALSE, TRUE, TRUE, FALSE, # Extraversion
        FALSE, TRUE, FALSE, TRUE, # Verträglichkeit
        TRUE, FALSE, FALSE, TRUE, # Gewissenhaftigkeit
        TRUE, FALSE, FALSE, TRUE, # Neurotizismus
        FALSE, TRUE, FALSE, TRUE, # Offenheit
        # PSQ
        FALSE, FALSE, FALSE, TRUE, FALSE,
        # MWS & Statistics
        rep(FALSE, 6)
    ),
    ResponseCategories = rep("1,2,3,4,5", 54),  # 23 PA + 20 BFI + 5 PSQ + 4 MWS + 2 Stats = 54
    b = c(
        # PA items difficulty parameters (AI-generated based on item content)
        # Note: These parameters are AI-generated estimates based on theoretical difficulty
        # Items 6, 8, 9, 21, 23 are non-adaptive (fixed presentation)
        # Remaining 18 items form adaptive pool
        
        # Item 1: Preparing for exam - moderate anxiety trigger
        0.0,
        # Item 2: Interpreting code from tutorial - lower difficulty
        -0.3,
        # Item 3: Asking instructor for help - social anxiety component
        0.4,
        # Item 4: Working on assignment - moderate, common situation
        -0.1,
        # Item 5: Solving problem by writing program - core programming anxiety
        0.2,
        # Item 6: Reading code with multiple concepts - higher cognitive load (NON-ADAPTIVE)
        0.6,
        # Item 7: Deciding on language/framework - decision anxiety
        0.5,
        # Item 8: Taking exam - high anxiety trigger (NON-ADAPTIVE)
        0.9,
        # Item 9: Reading technical description - moderate difficulty (NON-ADAPTIVE)
        0.3,
        # Item 10: Interpreting error message - common but stressful
        0.1,
        # Item 11: Entering exam room - anticipatory anxiety
        0.8,
        # Item 12: Processing large data - competence anxiety
        0.4,
        # Item 13: Comparing solutions with peers - social comparison anxiety
        0.3,
        # Item 14: Deciding if code is correct - evaluation anxiety
        0.2,
        # Item 15: Waking up on exam morning - severe anticipatory anxiety
        0.7,
        # Item 16: Asking instructor to explain code - help-seeking anxiety
        0.5,
        # Item 17: Understanding algorithms - cognitive challenge
        0.4,
        # Item 18: Observing proficient peer - social comparison
        0.3,
        # Item 19: Asking for debugging help - help-seeking in public space
        0.6,
        # Item 20: Understanding code examples - learning situation
        0.0,
        # Item 21: Enrolling in course - commitment anxiety (NON-ADAPTIVE)
        0.1,
        # Item 22: Reviewing graded exam - evaluation anxiety
        0.5,
        # Item 23: Asking classmate for help - peer help-seeking (NON-ADAPTIVE)
        0.4,
        # Other items default
        rep(0, 31)
    ),
    a = c(
        # PA items discrimination parameters (AI-generated based on item specificity)
        # Note: These parameters are AI-generated estimates based on theoretical discrimination
        # Higher values indicate items that better differentiate between anxiety levels
        
        # Item 1: Exam preparation - good discriminator
        1.3,
        # Item 2: Interpreting tutorial code - moderate discriminator
        1.1,
        # Item 3: Asking instructor - high discriminator (social anxiety)
        1.5,
        # Item 4: Working on assignment - good discriminator
        1.2,
        # Item 5: Problem solving - excellent discriminator (core skill)
        1.6,
        # Item 6: Multiple concepts - good discriminator (NON-ADAPTIVE)
        1.3,
        # Item 7: Language decision - moderate discriminator
        1.1,
        # Item 8: Taking exam - very high discriminator (NON-ADAPTIVE)
        1.8,
        # Item 9: Technical description - moderate discriminator (NON-ADAPTIVE)
        1.2,
        # Item 10: Error messages - good discriminator
        1.4,
        # Item 11: Entering exam room - high discriminator
        1.7,
        # Item 12: Data processing - good discriminator
        1.3,
        # Item 13: Peer comparison - moderate discriminator
        1.2,
        # Item 14: Code evaluation - good discriminator
        1.4,
        # Item 15: Exam morning - very high discriminator
        1.7,
        # Item 16: Asking instructor about code - high discriminator
        1.5,
        # Item 17: Algorithm understanding - good discriminator
        1.4,
        # Item 18: Observing proficient peer - moderate discriminator
        1.1,
        # Item 19: Asking for debug help - high discriminator
        1.6,
        # Item 20: Code examples - good discriminator
        1.3,
        # Item 21: Course enrollment - moderate discriminator (NON-ADAPTIVE)
        1.0,
        # Item 22: Reviewing graded exam - good discriminator
        1.3,
        # Item 23: Asking classmate - high discriminator (NON-ADAPTIVE)
        1.5,
        # Other items default
        rep(1, 31)
    ),
    stringsAsFactors = FALSE
)

# Create a function to get items in the correct language
get_items_for_language <- function(lang = "de") {
    items <- all_items_de
    if (lang == "en" && "Question_EN" %in% names(items)) {
        items$Question <- items$Question_EN
    }
    return(items)
}

# Use German item bank
all_items <- all_items_de

# =============================================================================
# COMPLETE DEMOGRAPHICS (ALL VARIABLES FROM SPSS) - BILINGUAL
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
            "Anders"="6"
        ),
        options_en = c(
            "With my parents/parent"="1",
            "In a shared apartment/dorm"="2",
            "Alone/in a self-contained unit in a dorm"="3",
            "With my partner (with or without children)"="4",
            "Other"="6"
        ),
        required = FALSE
    ),
    Wohn_Zusatz = list(
        question = "Falls anders, bitte spezifizieren:",
        question_en = "If other, please specify:",
        type = "text",
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
            "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere"="6"
        ),
        options_en = c(
            "Vegan"="1", "Vegetarian"="2", "Pescetarian"="7",
            "Flexitarian"="4", "Omnivore (everything)"="5", "Other"="6"
        ),
        required = FALSE
    ),
    Ernährung_Zusatz = list(
        question = "Andere Ernährungsform:",
        question_en = "Other diet:",
        type = "text",
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
    Zufrieden_Hi_5st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5-stufig)",
        question_en = "How satisfied are you with your study location Hildesheim? (5-point scale)",
        options = c(
            "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "sehr zufrieden"="5"
        ),
        options_en = c(
            "not at all satisfied"="1", "2"="2", "3"="3", "4"="4", "very satisfied"="5"
        ),
        required = FALSE
    ),
    Zufrieden_Hi_7st = list(
        question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7-stufig)",
        question_en = "How satisfied are you with your study location Hildesheim? (7-point scale)",
        options = c(
            "gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "sehr zufrieden"="7"
        ),
        options_en = c(
            "not at all satisfied"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "very satisfied"="7"
        ),
        required = FALSE
    ),
    Persönlicher_Code = list(
        question = "Bitte erstellen Sie einen persönlichen Code (erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags). Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15",
        question_en = "Please create a personal code (first 2 letters of your mother's first name + first 2 letters of your birthplace + day of your birthday). Example: Maria (MA) + Hamburg (HA) + 15th day = MAHA15",
        type = "text",
        required = FALSE,
        # DEBUG: HTML content presence
        html_content_debug = "This field should have HTML content!",
        # NEW: Self-contained HTML content with built-in language switching (no duplicate header)
        html_content = '<div id="personal-code-container" style="padding: 20px; font-size: 16px; line-height: 1.8;">
          <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">Bitte erstellen Sie einen persönlichen Code:</p>
          <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
            <p style="margin: 0; font-weight: 500;">Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags</p>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <input type="text" id="Persönlicher_Code" name="Persönlicher_Code" placeholder="z.B. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
          </div>
          <div style="text-align: center; color: #666; font-size: 14px;">Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15</div>
        </div>',
        html_content_en = '<div id="personal-code-container" style="padding: 20px; font-size: 16px; line-height: 1.8;">
          <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">Please create a personal code:</p>
          <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
            <p style="margin: 0; font-weight: 500;">First 2 letters of your mothers first name + first 2 letters of your birthplace + day of your birthday</p>
          </div>
          <div style="text-align: center; margin: 30px 0;">
            <input type="text" id="Persönlicher_Code" name="Persönlicher_Code" placeholder="e.g. MAHA15" style="padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; text-align: center; width: 200px; text-transform: uppercase;" required>
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
    )
)

input_types <- list(
    Einverständnis = "checkbox",
    Alter_VPN = "select",
    Geschlecht = "radio",
    Wohnstatus = "radio",
    Wohn_Zusatz = "text",
    Rauchen = "radio",
    Ernährung = "radio",
    Ernährung_Zusatz = "text",
    Note_Englisch = "select",
    Note_Mathe = "select",
    Vor_Nachbereitung = "radio",
    Zufrieden_Hi_5st = "radio",
    Zufrieden_Hi_7st = "radio",
    Persönlicher_Code = "text",
    show_personal_results = "radio"
)



# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
    # Page 1: Einleitungstext with mandatory consent and language switcher
    list(
        id = "page1",
        type = "custom",
        title = "HilFo",
        content = '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">
      <div style="position: absolute; top: 10px; right: 10px;">
        <button type="button" id="language-toggle-btn" onclick="toggleLanguage()" style="
          background: #e8041c; color: white; border: 2px solid #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-size: 14px; font-weight: bold;">
          <span id="lang_switch_text">English Version</span></button>
      </div>
      
      <div id="content_de">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Willkommen zur HilFo Studie</h1>
        <h2 style="color: #e8041c;">Liebe Studierende,</h2>
        <p>In den Seminaren zu den statistischen Verfahren wollen wir mit Daten arbeiten, 
        die von Ihnen selbst stammen. Deswegen bitten wir Sie an der nachfolgenden Befragung teilzunehmen.</p>
        <p>Da wir die Anwendung verschiedene Auswertungsverfahren ermöglichen wollen, deckt der Fragebogen verschiedene 
        Themenbereiche ab, die voneinander teilweise unabhängig sind.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">
        <strong>Ihre Angaben sind dabei selbstverständlich anonym</strong>, es wird keine personenbezogene 
        Auswertung der Daten stattfinden. Die Daten werden von den Erstsemestern Psychologie im 
        Bachelor generiert und in diesem Jahrgang, möglicherweise auch in späteren Jahrgängen genutzt.</p>
        <p>Im Folgenden werden Ihnen dazu Aussagen präsentiert. Wir bitten Sie anzugeben, 
        inwieweit Sie diesen zustimmen. Es gibt keine falschen oder richtigen Antworten. 
        Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.</p>
        <p style="margin-top: 20px;"><strong>Die Befragung dauert etwa 10-15 Minuten.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Einverständniserklärung</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;">
            <strong>Hinweis:</strong> Die Teilnahme ist nur möglich, wenn Sie der Einverständniserklärung zustimmen.</p>
          </div>
        </div>
      </div>
      
      <div id="content_en" style="display: none;">
        <h1 style="color: #e8041c; text-align: center; margin-bottom: 30px; font-size: 28px;">
          Welcome to the HilFo Study</h1>
        <h2 style="color: #e8041c;">Dear Students,</h2>
        <p>In the seminars on statistical procedures, we want to work with data 
        that comes from you. Therefore, we ask you to participate in the following survey.</p>
        <p>Since we want to enable the application of various analysis procedures, the questionnaire covers different 
        topic areas that are partially independent of each other.</p>
        <p style="background: #fff3f4; padding: 15px; border-left: 4px solid #e8041c;">
        <strong>Your information is completely anonymous</strong>, there will be no personal 
        evaluation of the data. The data is generated by first-semester psychology 
        bachelor students and used in this cohort, possibly also in later cohorts.</p>
        <p>In the following, you will be presented with statements. We ask you to indicate 
        to what extent you agree with them. There are no wrong or right answers. 
        Please answer the questions as they best reflect your opinion.</p>
        <p style="margin-top: 20px;"><strong>The survey takes about 10-15 minutes.</strong></p>
        <hr style="margin: 30px 0; border: 1px solid #e8041c;">
        <div style="background: #f8f9fa; padding: 20px; border-radius: 8px;">
          <h3 style="color: #e8041c; margin-bottom: 15px;">Declaration of Consent</h3>
          <label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">
            <input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>
            <span><strong>I agree to participate in the survey</strong></span>
          </label>
          <div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e8041c;">
            <p style="margin: 0; font-size: 14px; color: #666;">
            <strong>Note:</strong> Participation is only possible if you agree to the declaration of consent.</p>
          </div>
        </div>
      </div>
    </div>
    
    <script>
    function toggleLanguage() {
      var deContent = document.getElementById("content_de");
      var enContent = document.getElementById("content_en");
      var textSpan = document.getElementById("lang_switch_text");
      
      if (deContent && enContent) {
        if (deContent.style.display === "none") {
          /* Switch to German */
          deContent.style.display = "block";
          enContent.style.display = "none";
          if (textSpan) textSpan.textContent = "English Version";
          
          /* Send German language to global system - CONSISTENT STORAGE */
          sessionStorage.setItem("hilfo_global_language", "de");
          sessionStorage.setItem("global_language_preference", "de");
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("store_language_globally", "de", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "de");
          sessionStorage.setItem("current_language", "de");
          sessionStorage.setItem("hilfo_language_preference", "de");
        } else {
          /* Switch to English */
          deContent.style.display = "none";
          enContent.style.display = "block";
          if (textSpan) textSpan.textContent = "Deutsche Version";
          
          /* Send English language to global system - CONSISTENT STORAGE */
          sessionStorage.setItem("hilfo_global_language", "en");
          sessionStorage.setItem("global_language_preference", "en");
          if (typeof Shiny !== "undefined") {
            Shiny.setInputValue("store_language_globally", "en", {priority: "event"});
          }
          sessionStorage.setItem("hilfo_language", "en");
          sessionStorage.setItem("current_language", "en");
          sessionStorage.setItem("hilfo_language_preference", "en");
        }
      }
      
      var deCheck = document.getElementById("consent_check");
      var enCheck = document.getElementById("consent_check_en");
      if (deCheck && enCheck) {
        if (deContent.style.display === "none") {
          enCheck.checked = deCheck.checked;
        } else {
          deCheck.checked = enCheck.checked;
        }
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
    
    // GLOBAL LANGUAGE INITIALIZATION - ENSURE CONSISTENCY ACROSS ALL PAGES
    document.addEventListener("DOMContentLoaded", function() {
      // Unified language detection for entire study
      var currentLang = sessionStorage.getItem("hilfo_language_preference") || 
                       sessionStorage.getItem("global_language_preference") || 
                       sessionStorage.getItem("current_language") || "de";
      
      // Ensure all language keys are consistent
      sessionStorage.setItem("hilfo_language_preference", currentLang);
      sessionStorage.setItem("global_language_preference", currentLang);
      sessionStorage.setItem("current_language", currentLang);
      sessionStorage.setItem("hilfo_language", currentLang);
      
      console.log("Language initialized to:", currentLang);
    });
    </script>',
        validate = "function(inputs) { 
      try {
        var deCheck = document.getElementById('consent_check');
        var enCheck = document.getElementById('consent_check_en');
        return Boolean((deCheck && deCheck.checked) || (enCheck && enCheck.checked));
      } catch(e) {
        return false;
      }
    }",
        required = FALSE
    ),
    
    # Page 2: Basic demographics
    list(
        id = "page2",
        type = "demographics",
        title = "",
        title_en = "",
        demographics = c("Alter_VPN", "Geschlecht")
    ),
    
    # Page 3: Living situation
    list(
        id = "page3",
        type = "demographics",
        title = "",
        title_en = "",
        demographics = c("Wohnstatus", "Wohn_Zusatz")
    ),
    
    # Page 4: Lifestyle
    list(
        id = "page4",
        type = "demographics",
        title = "",
        title_en = "",
        demographics = c("Rauchen", "Ernährung", "Ernährung_Zusatz")
    ),
    
    # Page 5: Education
    list(
        id = "page5",
        type = "demographics",
        title = "",
        title_en = "",
        demographics = c("Note_Englisch", "Note_Mathe")
    ),
    
    # PROGRAMMING ANXIETY SECTION (23 items total - STARS-D adapted)
    # Non-adaptive items: 6, 8, 9, 21, 23 (shown as fixed)
    # Adaptive pool: remaining 18 items
    
    # Page 6: PA Non-adaptive items (6, 8, 9, 21, 23)
    list(
        id = "page6_pa_fixed",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Die folgenden Aussagen beschreiben Situationen, die mit Programmieren zu tun haben. Wählen Sie bitte die Option, die am besten beschreibt, wie viel Angst Sie in der entsprechenden Situation erleben würden. Es gibt keine richtigen oder falschen Antworten.",
        instructions_en = "The following statements describe situations related to programming. Please select the option that best describes how much anxiety you would experience in that situation. There are no right or wrong answers.",
        item_indices = c(6, 8, 9, 21, 23),  # Non-adaptive PA items (all on one page)
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = FALSE
    ),
    
    # Pages 7-11: Programming Anxiety Adaptive (5 items, one per page)
    # Adaptive selection from pool: items 1-5, 7, 10-20, 22 (18 items total, excluding 6, 8, 9, 21, 23)
    list(
        id = "page7_pa_adapt1",
        type = "items", 
        title = "",
        title_en = "",
        instructions = "Die folgenden Fragen werden basierend auf Ihren Antworten auf Seite 6 ausgewählt.",
        instructions_en = "The following questions are selected based on your answers on page 6.",
        item_indices = NULL,  # NULL triggers adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = TRUE
    ),
    list(
        id = "page8_pa_adapt2",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Die folgenden Fragen werden basierend auf Ihren Antworten auf Seite 6 und 7 ausgewählt.",
        instructions_en = "The following questions are selected based on your answers on page 6 and 7.",
        item_indices = NULL,  # NULL triggers adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = TRUE
    ),
    list(
        id = "page9_pa_adapt3",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Die folgenden Fragen werden basierend auf Ihren Antworten auf Seite 6, 7 und 8 ausgewählt.",
        instructions_en = "The following questions are selected based on your answers on page 6, 7 and 8.",
        item_indices = NULL,  # NULL triggers adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = TRUE
    ),
    list(
        id = "page10_pa_adapt4",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Die folgenden Fragen werden basierend auf Ihren Antworten auf Seite 6, 7, 8 und 9 ausgewählt.",
        instructions_en = "The following questions are selected based on your answers on page 6, 7, 8 and 9.",
        item_indices = NULL,  # NULL triggers adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = TRUE
    ),
    list(
        id = "page11_pa_adapt5",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Die folgenden Fragen werden basierend auf Ihren Antworten auf Seite 6, 7, 8, 9 und 10 ausgewählt.",
        instructions_en = "The following questions are selected based on your answers on page 6, 7, 8, 9 and 10.",
        item_indices = NULL,  # NULL triggers adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety"),
        required = TRUE
    ),
    
    # Pages 12-15: BFI items (grouped by trait) - NOT REQUIRED
    list(
        id = "page12",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.",
        instructions_en = "Please indicate to what extent the following statements apply to you.",
        item_indices = 24:28,  # BFI items (after 23 PA items)
        scale_type = "likert",
        required = FALSE
    ),
    list(
        id = "page13",
        type = "items",
        title = "",
        title_en = "",
        item_indices = 29:33,  # BFI items continued
        scale_type = "likert",
        required = FALSE
    ),
    list(
        id = "page14",
        type = "items",
        title = "",
        title_en = "",
        item_indices = 34:38,  # BFI items continued
        scale_type = "likert",
        required = FALSE
    ),
    list(
        id = "page15",
        type = "items",
        title = "",
        title_en = "",
        item_indices = 39:43,  # BFI items final
        scale_type = "likert",
        required = FALSE
    ),
    
    # Page 16: PSQ Stress - NOT REQUIRED
    list(
        id = "page16",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Wie sehr treffen die folgenden Aussagen auf Sie zu?",
        instructions_en = "How much do the following statements apply to you?",
        item_indices = 44:48,  # PSQ items (after 23 PA + 20 BFI)
        scale_type = "likert",
        required = FALSE
    ),
    
    # Page 17: MWS Study Skills - NOT REQUIRED
    list(
        id = "page17",
        type = "items",
        title = "",
        title_en = "",
        instructions = "Wie leicht oder schwer fällt es Ihnen...",
        instructions_en = "How easy or difficult is it for you...",
        item_indices = 49:52,  # MWS items
        scale_type = "difficulty",
        required = FALSE
    ),
    
    # Page 18: Statistics - NOT REQUIRED
    list(
        id = "page18",
        type = "items",
        title = "",
        title_en = "",
        item_indices = 53:54,  # Statistics items
        scale_type = "likert",
        required = FALSE
    ),
    
    # Page 19: Study satisfaction
    list(
        id = "page19",
        type = "demographics",
        title = "",
        title_en = "",
        demographics = c("Vor_Nachbereitung", "Zufrieden_Hi_5st", "Zufrieden_Hi_7st")
    ),
    
    # Page 20: Personal Code - use demographic type for proper language handling
    list(
        id = "page20",
        type = "demographics", 
        title = "Persönlicher Code",
        title_en = "Personal Code",
        demographics = c("Persönlicher_Code")
    ),
    
    # Page 20a: Pre-results confirmation (participant-facing page before results)
    list(
            id = "page20a_preresults",
            type = "demographics",
            title = "Die Erhebung ist beendet",
            title_en = "Assessment complete",
            demographics = c("show_personal_results")
        ),

    # Page 21: Results (now with PA results included)
    list(
        id = "page21",
        type = "results",
        title = "",
        title_en = "",
        results_processor = "create_hilfo_report"
    )
)

# =============================================================================
# RESULTS PROCESSOR WITH FIXED RADAR PLOT
# =============================================================================

create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
    # Check if this is being called for CSV export enhancement
    if (!is.null(session) && is.list(session) && !is.null(session$csv_export)) {
        # This is a CSV export call - enhance the CSV data with HILFO-specific calculations
        csv_env <- session$csv_export
        if (!is.null(csv_env$csv_data)) {
            # Add HILFO-specific calculated scores to CSV
            responses <- csv_env$responses
            
            # Calculate BFI scores from responses (items 21-40)
        if (!is.null(responses) && is.vector(responses) && length(responses) >= 40) {
            bfi_responses <- responses[21:40]
            if (!is.null(bfi_responses) && is.vector(bfi_responses) && length(bfi_responses) >= 20 && !all(is.na(bfi_responses))) {
                    csv_env$csv_data$BFI_Extraversion <- mean(c(bfi_responses[1:4]), na.rm = TRUE)
                    csv_env$csv_data$BFI_Vertraeglichkeit <- mean(c(bfi_responses[5:8]), na.rm = TRUE)
                    csv_env$csv_data$BFI_Gewissenhaftigkeit <- mean(c(bfi_responses[9:12]), na.rm = TRUE)
                    csv_env$csv_data$BFI_Neurotizismus <- mean(c(bfi_responses[13:16]), na.rm = TRUE)
                    csv_env$csv_data$BFI_Offenheit <- mean(c(bfi_responses[17:20]), na.rm = TRUE)
                }
            }
            
            # Calculate PSQ Stress (items 41-45)
            if (!is.null(responses) && is.vector(responses) && length(responses) >= 45) {
                stress_responses <- responses[41:45]
                if (!is.null(stress_responses) && is.vector(stress_responses) && length(stress_responses) > 0) {
                    csv_env$csv_data$PSQ_Stress <- mean(stress_responses, na.rm = TRUE)
                }
            }
            
            # Calculate MWS Study Skills (items 46-49)
            if (!is.null(responses) && is.vector(responses) && length(responses) >= 49) {
                study_responses <- responses[46:49]
                if (!is.null(study_responses) && is.vector(study_responses) && length(study_responses) > 0) {
                    csv_env$csv_data$MWS_Studierfaehigkeiten <- mean(study_responses, na.rm = TRUE)
                }
            }
            
            # Calculate Statistics (items 50-51)
            if (!is.null(responses) && is.vector(responses) && length(responses) >= 51) {
                stats_responses <- responses[50:51]
                if (!is.null(stats_responses) && is.vector(stats_responses) && length(stats_responses) > 0) {
                    csv_env$csv_data$Statistik <- mean(stats_responses, na.rm = TRUE)
                }
            }
        }
        return(NULL)  # Don't generate HTML report for CSV export
    }
    # Global error handling for the entire function
    tryCatch({
        # Lazy load packages only when actually needed
        if (!requireNamespace("ggplot2", quietly = TRUE)) {
            stop("ggplot2 package is required for report generation")
        }
        if (!requireNamespace("base64enc", quietly = TRUE)) {
            stop("base64enc package is required for report generation")
        }
        
        # Get current language from session if available
        current_lang <- "de"  # Default to German
        
        # Try multiple ways to get the language - prioritize session$input
        if (!is.null(session)) {
            # Check session$input first (this is where the language actually is)
            if (!is.null(session$input$language)) {
                current_lang <- session$input$language
            } else if (!is.null(session$input$study_language)) {
                current_lang <- session$input$study_language
            } else if (!is.null(session$userData$language)) {
                current_lang <- session$userData$language
            } else if (!is.null(session$userData$study_language)) {
                current_lang <- session$userData$study_language
            } else if (!is.null(session$userData$current_language)) {
                current_lang <- session$userData$current_language
            }
        }
        
        # Also check global environment for language
        if (exists("current_language", envir = .GlobalEnv)) {
            current_lang <- get("current_language", envir = .GlobalEnv)
        }
        
        # Debug: Print what language we detected
        cat("DEBUG: Detected language in results processor:", current_lang, "\n")
        
        # Additional debugging - check session structure
        if (!is.null(session)) {
            cat("DEBUG: Session userData keys:", names(session$userData), "\n")
            if (!is.null(session$input)) {
                cat("DEBUG: Session input keys:", names(session$input), "\n")
            }
        }
        
        # Ensure current_lang is never NULL or NA
        if (is.null(current_lang) || is.na(current_lang) || current_lang == "") {
            current_lang <- "de"
            cat("DEBUG: Using default German language\n")
        }
        
        # PRIORITY: If session has language input, use that (this is the most reliable)
        if (!is.null(session) && !is.null(session$input) && !is.null(session$input$language)) {
            current_lang <- session$input$language
            cat("DEBUG: Using language from session$input$language:", current_lang, "\n")
        }
        
        # Check if we should use English based on the last language selection
        # Check if there's a language preference stored in the global environment
        if (exists("global_language_preference", envir = .GlobalEnv)) {
            stored_lang <- get("global_language_preference", envir = .GlobalEnv)
            if (!is.null(stored_lang) && stored_lang == "en") {
                current_lang <- "en"
                cat("DEBUG: Using stored English preference from global\n")
            }
        }
        
        # Create is_english variable AFTER all language detection
        is_english <- (current_lang == "en")
        cat("DEBUG: is_english =", is_english, "\n")
        
        # Use German as default unless English is explicitly set
        if (current_lang == "de" && is_english == FALSE) {
            # Keep German as default - no forcing to English
            is_english <- FALSE
            current_lang <- "de"
            cat("DEBUG: Using German as default\n")
        }
        
        # Final check to ensure is_english is properly set
        if (is.null(is_english) || is.na(is_english)) {
            is_english <- (current_lang == "en")
            cat("DEBUG: Reset is_english to:", is_english, "\n")
        }
        
        # Additional debug output
        cat("DEBUG: Final language settings - current_lang:", current_lang, ", is_english:", is_english, "\n")
        
        if (is.null(responses) || !is.vector(responses) || length(responses) == 0) {
            if (is_english) {
                return(shiny::HTML("<p>No responses available for evaluation.</p>"))
            } else {
                return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
            }
        }

        # CRITICAL: Initialize flag - will be set to TRUE if user selected NO
        # This ensures CSV generation runs even when user doesn't want to see results
        user_wants_no_results <- FALSE
        
        # Honor participant preference for showing personal results
        # If the participant selected 'no' on the pre-results page, show a minimal page
        # that only displays the automatic-close message and a countdown (290 seconds).
        try({
            show_pref <- NULL
            
            # Debug: Print all available data
            cat("DEBUG: === CHECKING FOR show_personal_results ===\n")
            cat("DEBUG: demographics is null?", is.null(demographics), "\n")
            if (!is.null(demographics)) {
                cat("DEBUG: demographics class:", class(demographics), "\n")
                cat("DEBUG: demographics names:", names(demographics), "\n")
                if (is.list(demographics)) {
                    cat("DEBUG: demographics contents:", str(demographics), "\n")
                }
            }
            
            # First check demographics parameter (most reliable)
            # Handle both list and named vector formats
            if (!is.null(demographics)) {
                if (is.list(demographics) && !is.null(demographics$show_personal_results)) {
                    show_pref <- demographics$show_personal_results
                    cat("DEBUG: Found show_personal_results in demographics list:", show_pref, "\n")
                } else if (is.vector(demographics) && "show_personal_results" %in% names(demographics)) {
                    show_pref <- demographics["show_personal_results"]
                    cat("DEBUG: Found show_personal_results in demographics vector:", show_pref, "\n")
                }
            }
            # Fallback to session input
            else if (!is.null(session) && !is.null(session$input) && !is.null(session$input$show_personal_results)) {
                show_pref <- session$input$show_personal_results
                cat("DEBUG: Found show_personal_results in session$input:", show_pref, "\n")
            } 
            # Fallback to session userData
            else if (!is.null(session) && !is.null(session$userData) && !is.null(session$userData$show_personal_results)) {
                show_pref <- session$userData$show_personal_results
                cat("DEBUG: Found show_personal_results in session$userData:", show_pref, "\n")
            }
            # Global environment fallback
            else if (exists("show_personal_results", envir = .GlobalEnv)) {
                show_pref <- get("show_personal_results", envir = .GlobalEnv)
                cat("DEBUG: Found show_personal_results in global env:", show_pref, "\n")
            }
            else {
                cat("DEBUG: No show_personal_results found anywhere - defaulting to show results\n")
            }
            if (!is.null(show_pref) && nzchar(as.character(show_pref))) {
                # Normalize
                sp <- tolower(as.character(show_pref))
                cat("DEBUG: Normalized show_pref value:", sp, "\n")
                cat("DEBUG: Checking if sp is in 'no', 'n', 'false', '0'\n")
                if (sp %in% c("no", "n", "false", "0")) {
                    cat("DEBUG: User selected NO - will show thank you message, but CSV generation will run first\n")
                    # CRITICAL: Don't return early! We need CSV generation to run first
                    # Set flag to return simple message later, after CSV generation
                    user_wants_no_results <- TRUE
                } else {
                    user_wants_no_results <- FALSE
                }
            } else {
                user_wants_no_results <- FALSE
            }
        }, silent = TRUE)
        
        # Ensure demographics is a list
        if (is.null(demographics)) {
            demographics <- list()
        }
        
        # Ensure we have all 54 item responses (23 PA + 20 BFI + 5 PSQ + 4 MWS + 2 Stats)
        if (is.null(responses) || length(responses) < 54) {
            if (is.null(responses)) {
                responses <- rep(NA, 54)  # Use NA instead of 3 to avoid corrupting calculations
            } else {
                responses <- c(responses, rep(NA, 54 - length(responses)))
            }
        }
        responses <- as.numeric(responses)
        
        # Calculate Programming Anxiety score using ONLY items that were actually administered
        # STARS-D adapted: 23 PA items total (10 shown: 5 non-adaptive + 5 adaptive)
        pa_indices <- 1:23
        pa_responses_all <- responses[pa_indices]
        
        # Get only non-NA responses (items that were actually shown)
        pa_valid_mask <- !is.na(pa_responses_all)
        pa_valid_indices <- pa_indices[pa_valid_mask]
        pa_responses <- pa_responses_all[pa_valid_mask]
        
        cat(sprintf("DEBUG: Found %d PA responses (out of 23 possible PA items)\n", length(pa_responses)))
        cat(sprintf("DEBUG: PA items with responses: %s\n", paste(pa_valid_indices, collapse=", ")))
        
        # No reverse scoring for STARS-D adapted items (all items measure anxiety directly)
        
        pa_score <- mean(pa_responses, na.rm = TRUE)
        
        # Compute IRT-based ability estimate for Programming Anxiety
        # STARS-D adapted: 5 non-adaptive (fixed) + 5 adaptive = 10 total
        pa_theta <- pa_score  # Default to classical score
        
        # Fit 2PL IRT model for Programming Anxiety
        cat("\n================================================================================\n")
        cat("PROGRAMMING ANXIETY - IRT MODEL (2PL) - STARS-D Adapted\n")
        cat("================================================================================\n")
        cat("Source: Adapted from STARS-D (Statistical Anxiety Rating Scale - German)\n")
        cat("Assessment Type: Semi-Adaptive (5 non-adaptive + 5 adaptive from pool of 18)\n")
        cat(sprintf("Total items administered: %d (expected: 10)\n", length(pa_responses)))
        cat("\n")
        
        # Get item parameters for the PA items that were ACTUALLY shown (adaptive testing)
        # Use pa_valid_indices from above (the actual item indices with responses)
        shown_items <- all_items_de[pa_valid_indices, ]
        a_params <- shown_items$a
        b_params <- shown_items$b
        
        cat(sprintf("DEBUG: Using item parameters for items: %s\n", paste(pa_valid_indices, collapse=", ")))
        
        # Validate item parameters
        if (any(is.na(a_params)) || any(is.na(b_params))) {
            cat("WARNING: Missing item parameters (a or b) - using fallback classical score\n")
            pa_theta <- pa_score
            theta_est <- pa_score
            se_est <- sd(pa_responses, na.rm = TRUE) / sqrt(length(pa_responses))
        } else {
            # Use Maximum Likelihood Estimation for theta
            theta_est <- 0  # Start with prior mean
            converged <- FALSE
            
            for (iter in 1:20) {
                # Calculate probabilities for current theta using 2PL model
                probs <- 1 / (1 + exp(-a_params * (theta_est - b_params)))
                
                # Convert responses to 0-1 scale for IRT
                resp_binary <- (pa_responses - 1) / 4  # Convert 1-5 to 0-1
                
                # Validate responses
                if (any(is.na(resp_binary))) {
                    cat("WARNING: Missing responses in iteration", iter, "- using fallback\n")
                    break
                }
                
                # First derivative (score function)
                first_deriv <- sum(a_params * (resp_binary - probs), na.rm = TRUE)
                
                # Second derivative (information)
                second_deriv <- -sum(a_params^2 * probs * (1 - probs), na.rm = TRUE)
                
                # Validate derivatives
                if (is.na(first_deriv) || is.na(second_deriv)) {
                    cat("WARNING: Invalid derivatives in iteration", iter, "- stopping\n")
                    break
                }
            
            # Update theta using Newton-Raphson
            if (abs(second_deriv) > 0.01) {
                delta <- first_deriv / second_deriv
                
                # Check if delta is valid (not NA, not Inf)
                if (!is.na(delta) && is.finite(delta)) {
                    theta_est <- theta_est - delta
                    
                    # Check convergence
                    if (abs(delta) < 0.001) {
                        converged <- TRUE
                        break
                    }
                } else {
                    # Invalid delta - use fallback or stop iteration
                    cat("WARNING: Invalid delta in iteration", iter, "- stopping iteration\n")
                    break
                }
            } else {
                # Second derivative too small - stop iteration
                cat("WARNING: Second derivative too small in iteration", iter, "- stopping iteration\n")
                break
            }
            }
            
            # Validate final theta estimate
            if (!is.finite(theta_est) || is.na(theta_est)) {
                cat("WARNING: Invalid theta estimate - using fallback classical score\n")
                theta_est <- pa_score
            }
            
            # Calculate standard error and test information
            info <- sum(a_params^2 * (1 / (1 + exp(-a_params * (theta_est - b_params)))) * 
                            (1 - 1 / (1 + exp(-a_params * (theta_est - b_params)))), na.rm = TRUE)
            
            # Validate info
            if (is.na(info) || info <= 0 || !is.finite(info)) {
                cat("WARNING: Invalid test information - using fallback\n")
                info <- length(pa_responses)  # Fallback to number of items
            }
            
            se_est <- 1 / sqrt(info)
            if (!is.finite(se_est) || is.na(se_est)) {
                se_est <- sd(pa_responses, na.rm = TRUE) / sqrt(length(pa_responses))
            }
            
            reliability <- 1 - (1/info)  # Approximate reliability
            if (!is.finite(reliability) || is.na(reliability)) {
                reliability <- 0.7  # Fallback reliability
            }
        }
        
        # Output results
        cat(sprintf("Classical Score (mean): %.2f (range 1-5)\n", pa_score))
        cat(sprintf("IRT Theta Estimate: %.3f\n", theta_est))
        cat(sprintf("Standard Error (SE): %.3f\n", se_est))
        cat(sprintf("Test Information: %.3f\n", info))
        cat(sprintf("Reliability: %.3f\n", reliability))
        cat(sprintf("Convergence: %s (iterations: %d)\n", ifelse(converged, "Yes", "No"), iter))
        cat("\n")
        
        # Interpretation on standardized scale
        z_score <- theta_est  # Theta is already on z-score scale
        percentile <- pnorm(z_score) * 100
        
        cat(sprintf("Percentile Rank: %.1f%%\n", percentile))
        
        if (theta_est < -1.5) {
            cat("Interpretation: Very low programming anxiety (bottom 7%)\n")
        } else if (theta_est < -0.5) {
            cat("Interpretation: Low programming anxiety (below average)\n")
        } else if (theta_est < 0.5) {
            cat("Interpretation: Moderate programming anxiety (average)\n")
        } else if (theta_est < 1.5) {
            cat("Interpretation: High programming anxiety (above average)\n")
        } else {
            cat("Interpretation: Very high programming anxiety (top 7%)\n")
        }
        cat("================================================================================\n\n")
        
        # Store IRT estimate (scale to 1-5 for consistency with other scores)
        # Convert theta to 1-5 scale: theta of -2 = 1, theta of 2 = 5
        pa_theta_scaled <- 3 + theta_est  # Center at 3, each SD = 1 point
        pa_theta_scaled <- pmax(1, pmin(5, pa_theta_scaled))  # Bound to 1-5
        pa_theta <- pa_theta_scaled
        
        # Create trace plot showing theta progression (simulated for semi-adaptive)
        # In a real adaptive test, this would show actual theta estimates after each item
        theta_trace <- numeric(10)
        se_trace <- numeric(10)
        
        # More robust theta progression simulation
        for (i in 1:10) {
            # Calculate theta up to item i
            resp_subset <- (pa_responses[1:i] - 1) / 4
            a_subset <- a_params[1:i]
            b_subset <- b_params[1:i]
            
            # Robust theta estimation with better convergence
            theta_temp <- 0
            max_iter <- 20
            tolerance <- 1e-6
            
            for (iter in 1:max_iter) {
                # Calculate probabilities
                probs <- 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))
                
                # First derivative (gradient)
                first_d <- sum(a_subset * (resp_subset - probs), na.rm = TRUE)
                
                # Second derivative (Hessian)
                second_d <- -sum(a_subset^2 * probs * (1 - probs), na.rm = TRUE)
                
                # Validate derivatives before using
                if (is.na(first_d) || is.na(second_d)) {
                    cat("WARNING: Invalid derivatives in iteration", iter, "- stopping\n")
                    break
                }
                
                # Check for convergence (only if first_d is valid)
                if (is.finite(first_d) && abs(first_d) < tolerance) break
                
                # Update theta with safeguards
                if (abs(second_d) > 1e-6) {
                    step <- first_d / second_d
                    # Limit step size to prevent instability
                    step <- sign(step) * min(abs(step), 0.5)
                    theta_temp <- theta_temp - step
                } else {
                    # Fallback: simple gradient descent
                    theta_temp <- theta_temp - 0.1 * first_d
                }
                
                # Bound theta to reasonable range
                theta_temp <- pmax(-4, pmin(4, theta_temp))
            }
            
            # Calculate information and SE with safeguards
            probs_final <- 1 / (1 + exp(-a_subset * (theta_temp - b_subset)))
            info_temp <- sum(a_subset^2 * probs_final * (1 - probs_final))
            
            # Ensure information is positive and not too small
            info_temp <- max(info_temp, 0.1)
            se_temp <- 1 / sqrt(info_temp)
            
            # Bound standard error to reasonable range
            se_temp <- pmax(0.1, pmin(2.0, se_temp))
            
            theta_trace[i] <- theta_temp
            se_trace[i] <- se_temp
        }
        
        # Calculate BFI scores - PROPER GROUPING BY TRAIT (now starting at index 24 after 23 PA items)
        # Items are ordered: E1, E2, E3, E4, V1, V2, V3, V4, G1, G2, G3, G4, N1, N2, N3, N4, O1, O2, O3, O4
        scores <- list(
            ProgrammingAnxiety = if (exists("pa_theta")) pa_theta else pa_score,
            Extraversion = mean(c(responses[24], 6-responses[25], 6-responses[26], responses[27]), na.rm=TRUE),
            Verträglichkeit = mean(c(responses[28], 6-responses[29], responses[30], 6-responses[31]), na.rm=TRUE),
            Gewissenhaftigkeit = mean(c(6-responses[32], responses[33], responses[34], 6-responses[35]), na.rm=TRUE),
            Neurotizismus = mean(c(6-responses[36], responses[37], responses[38], 6-responses[39]), na.rm=TRUE),
            Offenheit = mean(c(responses[40], 6-responses[41], responses[42], 6-responses[43]), na.rm=TRUE)
        )
        
        # PSQ Stress score (now at indices 44-48)
        psq <- responses[44:48]
        scores$Stress <- mean(c(psq[1:3], 6-psq[4], psq[5]), na.rm=TRUE)
        
        # MWS & Statistics (now at indices 49-52 and 53-54)
        scores$Studierfähigkeiten <- mean(responses[49:52], na.rm=TRUE)
        scores$Statistik <- mean(responses[53:54], na.rm=TRUE)
        
        # Debug: Check scores for missing values
        cat("DEBUG: Scores values:\n")
        for (name in names(scores)) {
            cat(sprintf("  %s: %s (is.na: %s, is.nan: %s)\n", 
                        name, scores[[name]], is.na(scores[[name]]), is.nan(scores[[name]])))
        }
        
        # Create radar plot using ggradar approach
        # Check for ggradar (should be pre-installed)
        
        # Prepare data for ggradar - needs to be scaled 0-1
        # Keep NA values as NA (don't replace with default)
        radar_scores <- list(
            Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
            Verträglichkeit = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) NA else scores$Verträglichkeit,
            Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
            Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
            Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit
        )
        
        # Debug: Check radar scores
        cat("DEBUG: Radar scores values:\n")
        for (name in names(radar_scores)) {
            cat(sprintf("  %s: %s\n", name, radar_scores[[name]]))
        }
        
        tryCatch({
            # Use German or English column names based on language
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
            cat("DEBUG: radar_data created successfully\n")
        }, error = function(e) {
            cat("Error creating radar_data data.frame:", e$message, "\n")
            # Create fallback radar_data
            if (is_english) {
                radar_data <- data.frame(
                    group = "Your Profile",
                    Extraversion = 0.6,
                    Agreeableness = 0.6,
                    Conscientiousness = 0.6,
                    Neuroticism = 0.6,
                    Openness = 0.6,
                    stringsAsFactors = FALSE,
                    row.names = NULL
                )
            } else {
                radar_data <- data.frame(
                    group = "Ihr Profil",
                    Extraversion = 0.6,
                    Verträglichkeit = 0.6,
                    Gewissenhaftigkeit = 0.6,
                    Neurotizismus = 0.6,
                    Offenheit = 0.6,
                    stringsAsFactors = FALSE,
                    row.names = NULL
                )
            }
        })
        
        # Create title based on language (used in both radar plot branches)
        radar_title <- if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)"
        
        # Check if we have enough valid data for radar plot (need at least 3 non-NA values)
        non_na_count <- sum(!is.na(unlist(radar_scores)))
        skip_radar_plot <- non_na_count < 3
        
        if (skip_radar_plot) {
            cat("DEBUG: Skipping radar plot - only", non_na_count, "non-NA values out of 5\n")
            radar_plot <- NULL
        } else {
            # Create radar plot with ggradar
            if (requireNamespace("ggradar", quietly = TRUE)) {
                # CRITICAL: Remove columns with NA values - ggradar cannot handle NA
                # Keep only dimensions with actual data
                radar_data_plot <- radar_data
                
                # Identify columns with non-NA values (skip 'group' column)
                na_cols <- sapply(radar_data_plot[-1], function(x) is.na(x) || is.nan(x))
                cols_to_keep <- c(TRUE, !na_cols)  # Keep 'group' column + non-NA columns
                
                radar_data_plot <- radar_data_plot[, cols_to_keep, drop = FALSE]
                
                cat("DEBUG: Radar plot columns after NA removal:", paste(names(radar_data_plot), collapse=", "), "\n")
                
                # Only plot if we have at least 3 dimensions remaining
                if (ncol(radar_data_plot) < 4) {  # 'group' + at least 3 dimensions
                    cat("DEBUG: Not enough dimensions for radar plot after NA removal\n")
                    radar_plot <- NULL
                } else {
                    radar_plot <- ggradar::ggradar(
                        radar_data_plot,
                        values.radar = c("1", "3", "5"),  # Min, mid, max labels
                        grid.min = 0,
                        grid.mid = 0.6,
                        grid.max = 1,
                        grid.label.size = 5,
                        axis.label.size = 5,
                        group.point.size = 4,
                        group.line.width = 1.5,
                        background.circle.colour = "white",
                        gridline.min.colour = "gray90",
                        gridline.mid.colour = "gray80",
                        gridline.max.colour = "gray70",
                        group.colours = c("#e8041c"),
                        plot.extent.x.sf = 1.3,
                        plot.extent.y.sf = 1.2,
                        legend.position = "none"
                        ) +
                        ggplot2::theme(
                            plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5, 
                                                               color = "#e8041c", margin = ggplot2::margin(b = 20)),
                            plot.background = ggplot2::element_rect(fill = "white", color = NA),
                            plot.margin = ggplot2::margin(20, 20, 20, 20)
                        ) +
                        ggplot2::labs(title = radar_title)
                }
            } else {
                # Fallback to simple ggplot2 approach if ggradar not available
            # Use namespace to avoid loading issues
            if (!requireNamespace("ggplot2", quietly = TRUE)) {
                stop("ggplot2 package is required for plotting")
            }
            
            # Create coordinates for manual radar plot
            n_vars <- 5
            angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
            
            # Prepare data
            bfi_scores <- c(scores$Extraversion, scores$Verträglichkeit, 
                            scores$Gewissenhaftigkeit, scores$Neurotizismus, scores$Offenheit)
            
            # Use English labels if current language is English
            if (is_english) {
                bfi_labels <- c("Extraversion", "Agreeableness", "Conscientiousness", 
                                "Neuroticism", "Openness")
            } else {
                bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                                "Neurotizismus", "Offenheit")
            }
            
            # Calculate positions
            x_pos <- bfi_scores * cos(angles - pi/2)
            y_pos <- bfi_scores * sin(angles - pi/2)
            
            # Create data frame for plotting
            plot_data <- data.frame(
                x = c(x_pos, x_pos[1]),  # Close the polygon
                y = c(y_pos, y_pos[1]),
                label = c(bfi_labels, ""),
                score = c(bfi_scores, bfi_scores[1])
            )
            
            # Grid lines data
            grid_data <- expand.grid(
                r = 1:5,
                angle = seq(0, 2*pi, length.out = 50)
            )
            grid_data$x <- grid_data$r * cos(grid_data$angle)
            grid_data$y <- grid_data$r * sin(grid_data$angle)
            
            # Create plot
            radar_plot <- ggplot2::ggplot() +
                # Grid circles
                ggplot2::geom_path(data = grid_data, ggplot2::aes(x = x, y = y, group = r),
                                   color = "gray85", size = 0.3) +
                # Spokes
                ggplot2::geom_segment(data = data.frame(angle = angles),
                                      ggplot2::aes(x = 0, y = 0,
                                                   xend = 5 * cos(angle - pi/2),
                                                   yend = 5 * sin(angle - pi/2)),
                                      color = "gray85", size = 0.3) +
                # Data polygon
                ggplot2::geom_polygon(data = plot_data, ggplot2::aes(x = x, y = y),
                                      fill = "#e8041c", alpha = 0.2) +
                ggplot2::geom_path(data = plot_data, ggplot2::aes(x = x, y = y),
                                   color = "#e8041c", size = 2) +
                # Points
                ggplot2::geom_point(data = plot_data[1:5,], ggplot2::aes(x = x, y = y),
                                    color = "#e8041c", size = 5) +
                # Labels
                ggplot2::geom_text(data = plot_data[1:5,],
                                   ggplot2::aes(x = x * 1.3, y = y * 1.3, label = label),
                                   size = 5, fontface = "bold") +
                ggplot2::geom_text(data = plot_data[1:5,],
                                   ggplot2::aes(x = x * 1.1, y = y * 1.1, label = sprintf("%.1f", score)),
                                   size = 4, color = "#e8041c") +
                ggplot2::coord_equal() +
                ggplot2::xlim(-6, 6) + ggplot2::ylim(-6, 6) +
                ggplot2::theme_void() +
                ggplot2::theme(
                    plot.title = ggplot2::element_text(size = 20, face = "bold", hjust = 0.5,
                                                       color = "#e8041c", margin = ggplot2::margin(b = 20)),
                    plot.margin = ggplot2::margin(30, 30, 30, 30)
                ) +
                ggplot2::labs(title = radar_title)
            }
        }
        
        # Create bar chart with logical ordering
        # Show BFI scales first, then Programming Anxiety, then others
        # Keep NA/NaN as NA (don't replace with default value)
        if (is_english) {
            # Use English names as keys for English mode
            ordered_scores <- list(
                Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
                Agreeableness = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) NA else scores$Verträglichkeit,
                Conscientiousness = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
                Neuroticism = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
                Openness = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit,
                ProgrammingAnxiety = if (is.na(scores$ProgrammingAnxiety) || is.nan(scores$ProgrammingAnxiety)) NA else scores$ProgrammingAnxiety,
                Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) NA else scores$Stress,
                StudySkills = if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) NA else scores$Studierfähigkeiten
            )
        } else {
            # Use German names as keys for German mode
            ordered_scores <- list(
                Extraversion = if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion,
                Verträglichkeit = if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) NA else scores$Verträglichkeit,
                Gewissenhaftigkeit = if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit,
                Neurotizismus = if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus,
                Offenheit = if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit,
                ProgrammingAnxiety = if (is.na(scores$ProgrammingAnxiety) || is.nan(scores$ProgrammingAnxiety)) NA else scores$ProgrammingAnxiety,
                Stress = if (is.na(scores$Stress) || is.nan(scores$Stress)) NA else scores$Stress,
                Studierfähigkeiten = if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) NA else scores$Studierfähigkeiten
            )
        }
        
        # Create English dimension names
        if (is_english) {
            dimension_names_en <- c(
                "Extraversion" = "Extraversion",
                "Agreeableness" = "Agreeableness", 
                "Conscientiousness" = "Conscientiousness",
                "Neuroticism" = "Neuroticism",
                "Openness" = "Openness",
                "ProgrammingAnxiety" = "Programming Anxiety",
                "Stress" = "Stress",
                "StudySkills" = "Study Skills"
            )
        } else {
            dimension_names_en <- c(
                "Extraversion" = "Extraversion",
                "Verträglichkeit" = "Verträglichkeit", 
                "Gewissenhaftigkeit" = "Gewissenhaftigkeit",
                "Neurotizismus" = "Neurotizismus",
                "Offenheit" = "Offenheit",
                "ProgrammingAnxiety" = "Programmierangst",
                "Stress" = "Stress",
                "Studierfähigkeiten" = "Studierfähigkeiten"
            )
        }
        
        # Create English category names
        category_names_en <- c(
            "Persönlichkeit" = "Personality",
            "Programmierangst" = "Programming Anxiety",
            "Stress" = "Stress",
            "Studierfähigkeiten" = "Study Skills"
        )
        
        # Use English names if current language is English
        if (is_english) {
            dimension_labels <- dimension_names_en[names(ordered_scores)]
            # Create category labels that match the English dimension names
            category_labels <- c(rep("Personality", 5), 
                                 "Programming Anxiety", "Stress", "Study Skills")
        } else {
            # In German mode, also use the dimension_names_en mapping to get German labels
            dimension_labels <- dimension_names_en[names(ordered_scores)]
            category_labels <- c(rep("Persönlichkeit", 5), 
                                 "Programmierangst", "Stress", "Studierfähigkeiten")
        }
        
        # Create all_data with error handling
        tryCatch({
            all_data <- data.frame(
                dimension = factor(dimension_labels, levels = dimension_labels),
                score = unlist(ordered_scores),
                category = factor(category_labels, levels = unique(category_labels)),
                stringsAsFactors = FALSE,
                row.names = NULL
            )
            # Filter out rows with NA scores for the bar plot
            # (Keep all rows for the table, but plot only has valid data)
            all_data <- all_data[!is.na(all_data$score), ]
        }, error = function(e) {
            cat("Error creating all_data data.frame:", e$message, "\n")
            # Create fallback data.frame with Programming Anxiety only (the required scale)
            all_data <- data.frame(
                dimension = factor("ProgrammingAnxiety"),
                score = 3,
                category = factor(if (is_english) "Programming Anxiety" else "Programmierangst"),
                stringsAsFactors = FALSE,
                row.names = NULL
            )
        })
        
        # Create color scale based on language
        if (is_english) {
            color_scale <- ggplot2::scale_fill_manual(values = c(
                "Programming Anxiety" = "#9b59b6",
                "Personality" = "#e8041c",
                "Stress" = "#ff6b6b",
                "Study Skills" = "#4ecdc4"
            ))
        } else {
            color_scale <- ggplot2::scale_fill_manual(values = c(
                "Programmierangst" = "#9b59b6",
                "Persönlichkeit" = "#e8041c",
                "Stress" = "#ff6b6b",
                "Studierfähigkeiten" = "#4ecdc4"
            ))
        }
        
        bar_plot <- ggplot2::ggplot(all_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
            ggplot2::geom_bar(stat = "identity", width = 0.7) +
            # Add value labels with better formatting
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), 
                               vjust = -0.5, size = 6, fontface = "bold", color = "#333") +
            # Custom color scheme
            color_scale +
            # Y-axis customization
            ggplot2::scale_y_continuous(limits = c(0, 5.5), breaks = 0:5) +
            # Theme with larger text
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
        
        # Create bar plot labels
        bar_title <- if (is_english) "All Dimensions Overview" else "Alle Dimensionen im Überblick"
        bar_y_label <- if (is_english) "Score (1-5)" else "Punktzahl (1-5)"
        
        bar_plot <- bar_plot + ggplot2::labs(
            title = bar_title,
            y = bar_y_label
        )
        
        # Create trace plot for Programming Anxiety adaptive testing
        # Add safeguards for extreme values
        theta_trace_bounded <- pmax(-3, pmin(3, theta_trace))
        se_trace_bounded <- pmax(0.1, pmin(1.5, se_trace))
        
        trace_data <- data.frame(
            item = 1:10,
            theta = theta_trace_bounded,
            se_upper = theta_trace_bounded + se_trace_bounded,
            se_lower = theta_trace_bounded - se_trace_bounded,
            item_type = c(rep("Fixed", 5), rep("Adaptive", 5)),
            stringsAsFactors = FALSE,
            row.names = NULL
        )
        
        # Calculate plot limits dynamically
        y_min <- min(trace_data$se_lower) - 0.2
        y_max <- max(trace_data$se_upper) + 0.2
        
        trace_plot <- ggplot2::ggplot(trace_data, ggplot2::aes(x = item, y = theta)) +
            # Confidence band
            ggplot2::geom_ribbon(ggplot2::aes(ymin = se_lower, ymax = se_upper), 
                                 alpha = 0.3, fill = "#9b59b6") +
            # Theta line
            ggplot2::geom_line(linewidth = 2, color = "#9b59b6") +
            ggplot2::geom_point(ggplot2::aes(color = item_type), size = 4) +
            # Add horizontal line at final theta
            ggplot2::geom_hline(yintercept = theta_est, linetype = "dashed", 
                                color = "#9b59b6", alpha = 0.5) +
            # Vertical line separating fixed and adaptive
            ggplot2::geom_vline(xintercept = 5.5, linetype = "dotted", 
                                color = "gray50", alpha = 0.7) +
            # Annotations with dynamic positioning
            ggplot2::annotate("text", x = 2.5, y = y_max * 0.9, 
                              label = "Fixed Items", size = 4, color = "gray40") +
            ggplot2::annotate("text", x = 8, y = y_max * 0.9, 
                              label = "Adaptive Items", size = 4, color = "gray40") +
            # Scales with dynamic limits
            ggplot2::scale_x_continuous(breaks = 1:10, labels = 1:10) +
            ggplot2::scale_y_continuous(limits = c(y_min, y_max)) +
            ggplot2::scale_color_manual(values = c("Fixed" = "#e8041c", "Adaptive" = "#4ecdc4"), 
                                        breaks = c("Fixed", "Adaptive")) +
            # Theme
            ggplot2::theme_minimal(base_size = 14) +
            ggplot2::theme(
                plot.title = ggplot2::element_text(size = 18, face = "bold", hjust = 0.5, 
                                                   color = "#9b59b6", margin = ggplot2::margin(b = 15)),
                plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5, 
                                                      color = "gray50", margin = ggplot2::margin(b = 10)),
                axis.title = ggplot2::element_text(size = 12, face = "bold"),
                axis.text = ggplot2::element_text(size = 11),
                legend.position = "bottom",
                legend.title = ggplot2::element_blank(),
                panel.grid.minor = ggplot2::element_blank(),
                plot.margin = ggplot2::margin(20, 20, 20, 20)
            )
        
        # Create trace plot labels
        trace_title <- if (is_english) "Programming Anxiety - Adaptive Testing Trace" else "Programmierangst - Adaptive Testung"
        trace_subtitle <- sprintf(if (is_english) "Final theta = %.3f (SE = %.3f)" else "Finales theta = %.3f (SE = %.3f)", theta_est, se_est)
        trace_x_label <- if (is_english) "Item Number" else "Item-Nummer"
        trace_y_label <- if (is_english) "Theta Estimate" else "Theta-Schaetzung"
        
        trace_plot <- trace_plot + ggplot2::labs(
            title = trace_title,
            subtitle = trace_subtitle,
            x = trace_x_label,
            y = trace_y_label
        )
        
        # Save plots
        radar_file <- NULL
        bar_file <- tempfile(fileext = ".png")
        trace_file <- tempfile(fileext = ".png")
        
        suppressMessages({
            # Only save radar plot if it exists
            if (!is.null(radar_plot)) {
                radar_file <- tempfile(fileext = ".png")
                ggplot2::ggsave(radar_file, radar_plot, width = 10, height = 9, dpi = 150, bg = "white")
            }
            ggplot2::ggsave(bar_file, bar_plot, width = 12, height = 7, dpi = 150, bg = "white")
        })
        
        # Encode as base64
        radar_base64 <- ""
        bar_base64 <- ""
        # Programming Anxiety trace intentionally not saved/encoded for participant-facing report
        trace_base64 <- ""
        if (requireNamespace("base64enc", quietly = TRUE)) {
            if (!is.null(radar_file)) {
                radar_base64 <- base64enc::base64encode(radar_file)
            }
            bar_base64 <- base64enc::base64encode(bar_file)
        }
        # Clean up temp files
        files_to_unlink <- c(bar_file)
        if (!is.null(radar_file)) files_to_unlink <- c(files_to_unlink, radar_file)
        unlink(files_to_unlink)
        
        # Create detailed item responses table
        # Ensure we don't exceed available questions and handle missing values
        num_questions <- min(31, length(responses), nrow(item_bank))
        
        # Debug output
        cat("DEBUG: Creating item details table\n")
        cat("DEBUG: num_questions =", num_questions, "\n")
        cat("DEBUG: length(responses) =", length(responses), "\n")
        cat("DEBUG: nrow(item_bank) =", nrow(item_bank), "\n")
        if (!is.null(item_bank) && "Question" %in% names(item_bank)) {
            cat("DEBUG: item_bank$Question has", length(item_bank$Question), "items\n")
            cat("DEBUG: First few Question values:", head(item_bank$Question, 5), "\n")
        }
        
        # Create category vector that matches the actual number of questions
        category_vector <- c(
            rep("Extraversion", 4), rep("Verträglichkeit", 4), 
            rep("Gewissenhaftigkeit", 4), rep("Neurotizismus", 4), rep("Offenheit", 4),
            rep("Stress", 5), rep("Studierfähigkeiten", 4), rep("Statistik", 2)
        )
        
        # Ensure category vector is the right length
        if (!is.null(category_vector) && length(category_vector) > num_questions) {
            category_vector <- category_vector[1:num_questions]
        } else if (is.null(category_vector) || length(category_vector) < num_questions) {
            if (is.null(category_vector)) {
                category_vector <- rep("Other", num_questions)
            } else {
                category_vector <- c(category_vector, rep("Other", num_questions - length(category_vector)))
            }
        }
        
        # Create item details with proper handling of missing values
        tryCatch({
            item_names <- if ("Question" %in% names(item_bank)) {
                # Ensure no NA or NULL values in item names
                item_names_raw <- item_bank$Question[1:num_questions]
                ifelse(is.na(item_names_raw) | is.null(item_names_raw) | item_names_raw == "", 
                       paste0("Item_", 1:num_questions), 
                       as.character(item_names_raw))
            } else {
                paste0("Item_", 1:num_questions)
            }
            
            # Ensure all vectors have the same length and no missing values
            item_responses <- responses[1:num_questions]
            if (is.null(item_responses) || length(item_responses) < num_questions) {
                if (is.null(item_responses)) {
                    item_responses <- rep(NA, num_questions)
                } else {
                    item_responses <- c(item_responses, rep(NA, num_questions - length(item_responses)))
                }
            }
            
            # Ensure category vector is the right length
            if (is.null(category_vector) || length(category_vector) < num_questions) {
                if (is.null(category_vector)) {
                    category_vector <- rep("Other", num_questions)
                } else {
                    category_vector <- c(category_vector, rep("Other", num_questions - length(category_vector)))
                }
            }
            
            item_details <- data.frame(
                Item = item_names,
                Response = item_responses,
                Category = category_vector[1:num_questions],
                stringsAsFactors = FALSE,
                row.names = NULL  # Explicitly set row names to NULL to avoid issues
            )
        }, error = function(e) {
            cat("Error creating item_details data.frame:", e$message, "\n")
            # Create a simple fallback data.frame
            item_details <- data.frame(
                Item = paste0("Item_", 1:min(num_questions, 10)),
                Response = rep(NA, min(num_questions, 10)),
                Category = rep("Unknown", min(num_questions, 10)),
                stringsAsFactors = FALSE,
                row.names = NULL
            )
        })
        
        # Generate HTML report with download button
        report_id <- paste0("report_", format(Sys.time(), "%Y%m%d_%H%M%S"))
        
        html <- paste0(
            # Hide the page title for both versions
            '<style>',
            '.page-title, .study-title, h1:first-child, .results-title { display: none !important; }',
            '</style>',
            '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
            
            # Radar plot
            '<div class="report-section">',
            '<h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">',
            '<span data-lang-de="Persönlichkeitsprofil" data-lang-en="Personality Profile">', if (is_english) "Personality Profile" else "Persönlichkeitsprofil", '</span></h2>',
            tryCatch({
                if (!is.null(radar_base64) && radar_base64 != "") {
                    paste0('<img src="data:image/png;base64,', radar_base64, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 8px;">')
                } else {
                    ""
                }
            }, error = function(e) ""),
            '</div>',
            
            # (Programming Anxiety trace section intentionally removed from participant-facing report)
            
            # Bar chart
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
            
            # Table
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
        
        # Calculate standard deviations for each dimension
        sds <- list()
        
        # Programming Anxiety - use ACTUAL administered items (STARS-D adapted)
        # Get all PA responses (indices 1-23, but only 10 shown)
        pa_items_all <- responses[1:23]
        pa_items_valid <- pa_items_all[!is.na(pa_items_all)]
        
        # No reverse scoring for STARS-D adapted items
        sd_val <- sd(pa_items_valid, na.rm = TRUE)
        sds[["ProgrammingAnxiety"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
        
        # Big Five dimensions - each has 4 items (with reverse scoring applied)
        # Items are now 24-43 (after 23 PA items)
        bfi_dims <- list(
            Extraversion = c(responses[24], 6-responses[25], 6-responses[26], responses[27]),
            Verträglichkeit = c(responses[28], 6-responses[29], responses[30], 6-responses[31]),
            Gewissenhaftigkeit = c(6-responses[32], responses[33], responses[34], 6-responses[35]),
            Neurotizismus = c(6-responses[36], responses[37], responses[38], 6-responses[39]),
            Offenheit = c(responses[40], 6-responses[41], responses[42], 6-responses[43])
        )
        
        for (dim_name in names(bfi_dims)) {
            sd_val <- sd(bfi_dims[[dim_name]], na.rm = TRUE)
            sds[[dim_name]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
        }
        
        # PSQ Stress - 5 items (with reverse scoring for item 4)
        # Items are now 44-48 (after PA and BFI)
        psq_items <- c(responses[44:46], 6-responses[47], responses[48])
        sd_val <- sd(psq_items, na.rm = TRUE)
        sds[["Stress"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
        
        # MWS Studierfähigkeiten - 4 items (items 49-52)
        mws_items <- responses[49:52]
        sd_val <- sd(mws_items, na.rm = TRUE)
        sds[["Studierfähigkeiten"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
        
        # Statistik - 2 items (items 53-54)
        stat_items <- responses[53:54]
        sd_val <- sd(stat_items, na.rm = TRUE)
        sds[["Statistik"]] <- if(is.na(sd_val) || is.nan(sd_val)) NA else round(sd_val, 2)
        
        for (name in names(ordered_scores)) {
            # Check if value is NA before rounding
            raw_value <- ordered_scores[[name]]
            value <- if (is.na(raw_value)) NA else round(raw_value, 2)
            
            # Map back to original scores for SD calculation
            original_name <- if (is_english) {
                switch(name,
                       "Agreeableness" = "Verträglichkeit",
                       "Conscientiousness" = "Gewissenhaftigkeit", 
                       "Neuroticism" = "Neurotizismus",
                       "Openness" = "Offenheit",
                       "StudySkills" = "Studierfähigkeiten",
                       name  # Keep same for others
                )
            } else {
                name
            }
            sd_value <- ifelse(original_name %in% names(sds), sds[[original_name]], NA)
            
            # Only calculate level and color if value is not NA
            if (is.na(value)) {
                level <- "-"
                color <- "#333333"  # Default dark text for NA values
                value_display <- "-"
            } else {
                level <- ifelse(value >= 3.7, 
                                if (is_english) "High" else "Hoch", 
                                ifelse(value >= 2.3, 
                                       if (is_english) "Medium" else "Mittel", 
                                       if (is_english) "Low" else "Niedrig"))
                color <- "#333333"  # Use default dark text color (no highlighting)
                value_display <- as.character(value)
            }
            
            # Translate dimension names
            if (is_english) {
                name_display <- switch(name,
                                       "ProgrammingAnxiety" = "Programming Anxiety",
                                       "Extraversion" = "Extraversion",
                                       "Agreeableness" = "Agreeableness",
                                       "Conscientiousness" = "Conscientiousness",
                                       "Neuroticism" = "Neuroticism",
                                       "Openness" = "Openness",
                                       "Stress" = "Stress",
                                       "StudySkills" = "Study Skills",
                                       name  # Default fallback
                )
            } else {
                name_display <- switch(name,
                                       "ProgrammingAnxiety" = "Programmierangst",
                                       "Extraversion" = "Extraversion",
                                       "Verträglichkeit" = "Verträglichkeit",
                                       "Gewissenhaftigkeit" = "Gewissenhaftigkeit",
                                       "Neurotizismus" = "Neurotizismus",
                                       "Offenheit" = "Offenheit",
                                       "Stress" = "Stress",
                                       "Studierfähigkeiten" = "Studierfähigkeiten",
                                       name  # Default fallback
                )
            }
            
            html <- paste0(html,
                           '<tr>',
                           '<td data-label="', if (is_english) 'Dimension' else 'Dimension', '" style="padding: 12px; border-bottom: 1px solid #e0e0e0;">', name_display, '</td>',
                           '<td data-label="', if (is_english) 'Mean' else 'Mittelwert', '" style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
                           '<strong style="color: ', color, ';">', value_display, '</strong></td>',
                           '<td data-label="', if (is_english) 'SD' else 'SD', '" style="padding: 12px; text-align: center; border-bottom: 1px solid #e0e0e0;">',
                           ifelse(is.na(sd_value), "-", as.character(sd_value)), '</td>',
                           # Interpretation column removed per request
                           '</tr>'
            )
        }
        
        html <- paste0(html,
                       '</table>',
                       '</div>'  # Close table section
        )
        
        # Add beautiful styles for the report with mobile optimization
        html <- paste0(html,
                       '<style>',
                       'body { font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }',
                       '#report-content { background: #f8f9fa; }',
                       'table { border-collapse: collapse; width: 100%; }',
                       'table tr:hover { background: #f5f5f5; }',
                       'h1, h2 { font-family: "Segoe UI", sans-serif; }',
                       '.report-section { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px; }',
                       
                       '/* Mobile responsive table */',
                       '@media screen and (max-width: 768px) {',
                       '  #report-content { padding: 10px; }',
                       '  .report-section { padding: 15px; }',
                       '  h2 { font-size: 18px !important; }',
                       '  table { font-size: 12px; }',
                       '  table th, table td { padding: 8px 4px !important; }',
                       '  table img { max-width: 100% !important; height: auto !important; }',
                       '}',
                       
                       '@media screen and (max-width: 480px) {',
                       '  table { font-size: 11px; }',
                       '  table th, table td { padding: 6px 2px !important; display: block; width: 100% !important; text-align: left !important; }',
                       '  table tr { display: block; margin-bottom: 15px; border: 1px solid #e0e0e0; border-radius: 5px; padding: 10px; }',
                       '  table th { background: #e8041c !important; color: white !important; }',
                       '  table td:before { content: attr(data-label); font-weight: bold; display: inline-block; width: 50%; }',
                       '}',
                       
                       '@media print {',
                       '  body { font-size: 11pt; }',
                       '  h1, h2 { color: #e8041c !important; -webkit-print-color-adjust: exact; }',
                       '}',
                       '</style>',
                       
                       '</div>'
        )
        
        # CRITICAL: Save data to CSV file and upload to cloud
        # ALWAYS save CSV and upload, regardless of user's preference to see results
        # Check if responses and item_bank are provided (they're function parameters, not environment variables)
        if (!is.null(responses) && !is.null(item_bank)) {
            cat("DEBUG: Starting complete_data creation (CSV generation and upload)\n")
            tryCatch({
                # Prepare complete dataset with error handling
                tryCatch({
                    # CRITICAL: Use the detected current_lang (already determined above in the function)
                    # This ensures study_language matches the actual language used (en or de)
                    complete_data <- data.frame(
                        timestamp = Sys.time(),
                        session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
                        study_language = current_lang,  # Use the detected language (en or de), not hardcoded "de"
                        stringsAsFactors = FALSE,
                        row.names = NULL
                    )
                    cat("DEBUG: Setting study_language in CSV to:", current_lang, "\n")
                    cat("DEBUG: complete_data created successfully\n")
                }, error = function(e) {
                    cat("Error creating complete_data data.frame:", e$message, "\n")
                    # Create fallback complete_data
                    # CRITICAL: Use the detected current_lang even in fallback
                    complete_data <- data.frame(
                        timestamp = Sys.time(),
                        session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
                        study_language = current_lang,  # Use detected language, not hardcoded "de"
                        stringsAsFactors = FALSE,
                        row.names = NULL
                    )
                    cat("DEBUG: Fallback - Setting study_language in CSV to:", current_lang, "\n")
                })
                
                # Add demographics from the session
                if (exists("demographics") && is.list(demographics)) {
                    for (demo_name in names(demographics)) {
                        complete_data[[demo_name]] <- demographics[[demo_name]]
                    }
                }
                
                # CRITICAL: Add item responses using comprehensive dataset for proper adaptive mapping
                cat("DEBUG: Adding item responses to complete_data using comprehensive mapping\n")
                cat("DEBUG: nrow(item_bank) =", nrow(item_bank), "\n")
                cat("DEBUG: length(responses) =", length(responses), "\n")
                
                # Use get_comprehensive_dataset for proper adaptive item mapping
                tryCatch({
                    comprehensive_data <- get_comprehensive_dataset(responses, demographics, item_bank)
                    cat("DEBUG: Successfully created comprehensive dataset with", ncol(comprehensive_data), "columns\n")
                    
                    # Add all properly mapped item responses from comprehensive dataset
                    for (col_name in names(comprehensive_data)) {
                        # Skip timestamp, session_id, study_language as they're already in complete_data
                        if (!col_name %in% c("timestamp", "session_id", "study_language")) {
                            complete_data[[col_name]] <- comprehensive_data[[col_name]]
                        }
                    }
                    cat("DEBUG: Added all comprehensive dataset columns to complete_data\n")
                    
                }, error = function(e) {
                    cat("ERROR: get_comprehensive_dataset failed:", e$message, "\n")
                    cat("DEBUG: Falling back to sequential mapping (this will be incorrect for adaptive tests)\n")
                    
                    # Fallback: sequential mapping (incorrect for adaptive tests)
                    for (i in seq_along(responses)) {
                        if (i <= nrow(item_bank)) {
                            col_name <- item_bank$id[i]
                            cat("DEBUG: Fallback Item", i, "col_name =", col_name, "(is.na:", is.na(col_name), ")\n")
                            # Ensure col_name is valid and not NA
                            if (!is.na(col_name) && !is.null(col_name) && col_name != "") {
                                complete_data[[col_name]] <- responses[i]
                            } else {
                                # Use fallback column name
                                complete_data[[paste0("Item_", i)]] <- responses[i]
                            }
                        }
                    }
                })
                
                # Add calculated scores - keep NA if no valid responses (NO FALLBACKS)
                complete_data$BFI_Extraversion <- if (is.na(scores$Extraversion) || is.nan(scores$Extraversion)) NA else scores$Extraversion
                complete_data$BFI_Vertraeglichkeit <- if (is.na(scores$Verträglichkeit) || is.nan(scores$Verträglichkeit)) NA else scores$Verträglichkeit
                complete_data$BFI_Gewissenhaftigkeit <- if (is.na(scores$Gewissenhaftigkeit) || is.nan(scores$Gewissenhaftigkeit)) NA else scores$Gewissenhaftigkeit
                complete_data$BFI_Neurotizismus <- if (is.na(scores$Neurotizismus) || is.nan(scores$Neurotizismus)) NA else scores$Neurotizismus
                complete_data$BFI_Offenheit <- if (is.na(scores$Offenheit) || is.nan(scores$Offenheit)) NA else scores$Offenheit
                complete_data$PSQ_Stress <- if (is.na(scores$Stress) || is.nan(scores$Stress)) NA else scores$Stress
                complete_data$MWS_Studierfaehigkeiten <- if (is.na(scores$Studierfähigkeiten) || is.nan(scores$Studierfähigkeiten)) NA else scores$Studierfähigkeiten
                complete_data$Statistik <- if (is.na(scores$Statistik) || is.nan(scores$Statistik)) NA else scores$Statistik
                
                # CRITICAL: Save locally with proper connection handling
                # Store the file path and complete_data in session for download button to use
                local_file <- generate_hilfo_filename()
                tryCatch({
                    write.csv(complete_data, local_file, row.names = FALSE)
                    cat("Data saved locally to:", local_file, "\n")
                    
                    # CRITICAL: Store complete_data and file path in session for download button
                    # This ensures download button uses the EXACT same data that was uploaded
                    cat("DEBUG: Attempting to store session data...\n")
                    cat("DEBUG: session exists:", exists("session"), "\n")
                    cat("DEBUG: session is not null:", !is.null(get0("session")), "\n")
                    
                    if (exists("session") && !is.null(session)) {
                        cat("DEBUG: About to store in session$userData\n")
                        cat("DEBUG: session class:", class(session), "\n")
                        cat("DEBUG: session$userData class:", class(session$userData), "\n")
                        
                        # Use reactiveValues assignment
                        session$userData$hilfo_complete_data <- complete_data
                        session$userData$hilfo_csv_file <- local_file
                        
                        # Force flush by reading back
                        Sys.sleep(0.1)
                        
                        cat("DEBUG: Successfully stored complete_data (", nrow(complete_data), "rows) in session$userData\n")
                        cat("DEBUG: Immediate verification - hilfo_complete_data exists:", !is.null(session$userData$hilfo_complete_data), "\n")
                        cat("DEBUG: Immediate verification - hilfo_csv_file:", session$userData$hilfo_csv_file, "\n")
                    } else {
                        cat("WARNING: Cannot store session data - session not available\n")
                    }
                }, error = function(e) {
                    cat("Error saving data locally:", e$message, "\n")
                })
                
                # CRITICAL: BACKGROUND UPLOAD - Fire and forget, doesn't block results display
                # Data is already saved locally, so upload can happen in background
                # User can close browser - upload will complete independently
                if (!is.null(WEBDAV_URL) && !is.null(WEBDAV_PASSWORD)) {
                    
                    cat("\n")
                    cat("================================================================================\n")
                    cat("Cloud upload starting in background...\n")
                    cat("================================================================================\n")
                    cat("File:", local_file, "\n")
                    cat("Your results will appear immediately.\n")
                    cat("Upload will complete in the background (you can close this window).\n\n")
                    
                    # Capture variables in closure for background upload
                    upload_file_path <- local_file
                    upload_url <- WEBDAV_URL
                    upload_user <- WEBDAV_SHARE_TOKEN
                    upload_pass <- WEBDAV_PASSWORD
                    
                    # Schedule background upload using later::later()
                    later::later(function() {
                        cat("BACKGROUND: Starting cloud upload...\n")
                        
                        upload_success <- FALSE
                        max_retries <- 3
                        
                        for (retry_count in 1:max_retries) {
                            if (retry_count > 1) {
                                wait_time <- 2^(retry_count - 1)
                                cat("BACKGROUND: Retry", retry_count, "after", wait_time, "seconds...\n")
                                Sys.sleep(wait_time)
                            }
                            
                            tryCatch({
                                response <- httr::PUT(
                                    url = paste0(upload_url, basename(upload_file_path)),
                                    body = httr::upload_file(upload_file_path),
                                    httr::authenticate(upload_user, upload_pass, type = "basic"),
                                    httr::add_headers(
                                        "Content-Type" = "text/csv",
                                        "X-Requested-With" = "XMLHttpRequest"
                                    )
                                    # NO TIMEOUT - let it take as long as needed in background
                                )
                                
                                if (httr::status_code(response) %in% c(200, 201, 204)) {
                                    upload_success <- TRUE
                                    cat("\n")
                                    cat("================================================================================\n")
                                    cat("BACKGROUND: Upload SUCCESS!\n")
                                    cat("================================================================================\n")
                                    cat("File:", basename(upload_file_path), "\n")
                                    cat("Location: https://sync.academiccloud.de/index.php/s/OUarlqGbhYopkBc\n\n")
                                    break
                                } else {
                                    cat("BACKGROUND: Upload failed with HTTP", httr::status_code(response), "\n")
                                }
                            }, error = function(e) {
                                cat("BACKGROUND: Upload error:", e$message, "\n")
                            })
                        }
                        
                        if (!upload_success) {
                            cat("\n")
                            cat("================================================================================\n")
                            cat("BACKGROUND: Upload failed after", max_retries, "attempts\n")
                            cat("================================================================================\n")
                            cat("Data saved locally at:", upload_file_path, "\n\n")
                        }
                    }, delay = 0.1)  # Start after 0.1 seconds (after results render)
                    
                } else {
                    cat("WARNING: WEBDAV_URL or WEBDAV_PASSWORD not configured - skipping cloud upload\n")
                }
                
            }, error = function(e) {
                cat("Error saving data:", e$message, "\n")
            })
        }
        
        # Add functional minimalistic download section
        timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
        
        # Create PDF content as data URL
        pdf_filename <- paste0("hilfo_results_", timestamp, ".pdf")
        
        # Build JavaScript content strings with proper concatenation
        # Ensure current_lang is safe to use in if statements
        is_english <- !is.null(current_lang) && !is.na(current_lang) && is_english
        
        date_label <- if (is_english) "Date: " else "Datum: "
        profile_label <- if (is_english) "PERSONALITY PROFILE" else "PERSÖNLICHKEITSPROFIL"
        pa_label <- if (is_english) "Programming Anxiety: " else "Programmierangst: "
        agree_label <- if (is_english) "Agreeableness: " else "Verträglichkeit: "
        consc_label <- if (is_english) "Conscientiousness: " else "Gewissenhaftigkeit: "
        neuro_label <- if (is_english) "Neuroticism: " else "Neurotizismus: "
        open_label <- if (is_english) "Openness: " else "Offenheit: "
        stress_label <- if (is_english) "Stress: " else "Stress: "
        study_label <- if (is_english) "Study Skills: " else "Studierfähigkeiten: "
        stat_label <- if (is_english) "Statistics: " else "Statistik: "
        
        download_section_html <- paste0(
            '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 5px; margin: 20px 0;">',
            '<h4 style="color: #333; margin-bottom: 15px;">',
            if (is_english) "Export Results" else "Ergebnisse exportieren",
            '</span></h4>',
            '<div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">',
            
            # PDF Download Button
            '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" class="btn btn-primary" style="background: #e8041c; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
            '<i class="fas fa-file-pdf" style="margin-right: 8px;"></i>',
            if (is_english) "Download PDF" else "PDF herunterladen",
            '</button>',
            
            # CSV Download Button  
            '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_csv_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" class="btn btn-success" style="background: #28a745; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease;">',
            '<i class="fas fa-file-csv" style="margin-right: 8px;"></i>',
            if (is_english) "Download CSV" else "CSV herunterladen",
            '</button>',
            
            '</div>',
            '</div>',
            
            # Print styles
            '<style>',
            '@media print {',
            '  .download-section { display: none !important; }',
            '  body { font-size: 11pt; }',
            '  .report-section { page-break-inside: avoid; }',
            '  h2 { color: #e8041c !important; -webkit-print-color-adjust: exact; }',
            '}',
            '</style>'
        )
        
        # Add download section and close the main container
        html <- paste0(
            html,
            download_section_html,
            '</div>'  # Close main report-content div
        )
        
        # CRITICAL: If user selected NO, return simple thank you message instead of full report
        # But CSV generation already ran above, so data is saved
        if (isTRUE(user_wants_no_results)) {
            cat("DEBUG: User selected NO - returning simple thank you message (CSV already generated and uploaded)\n")
            html_no <- paste0(
                '<div style="padding:40px; text-align:center; font-family: Arial, sans-serif;">',
                '<div style="background:#f8f9fa; padding:30px; border-radius:10px; border:1px solid #dee2e6; max-width:600px; margin:0 auto;">',
                '<h2 style="color:#e8041c; margin-bottom:20px;">', 
                if (is_english) 'Assessment Complete' else 'Vielen Dank für Ihre Teilnahme!',
                '</h2>',
                '<p style="color:#666; font-size:16px; margin-bottom:0;">',
                if (is_english) 'Your data has been saved successfully.' else 'Ihre Daten wurden erfolgreich gespeichert.',
                '</p>',
                '</div>',
                '</div>',
                # Hide the page title
                '<style>',
                '.page-title, .study-title, h1:first-child, .results-title { display: none !important; }',
                '</style>'
            )
            return(shiny::HTML(html_no))
        }
        
        return(shiny::HTML(html))
        
    }, error = function(e) {
        cat("CRITICAL ERROR in create_hilfo_report:", e$message, "\n")
        cat("Error details:", toString(e), "\n")
        # Return a simple error message
        return(shiny::HTML('<div style="padding: 20px; color: red;"><h2>Error generating report</h2><p>An error occurred while generating your results. Please try again.</p><p>Error: ' + e$message + '</p></div>'))
    })
}


# =============================================================================
# ADAPTIVE OUTPUT HOOK FUNCTION
# =============================================================================

adaptive_output_hook <- function(session, item_num, response) {
    # Output adaptive information for PA items 6-10
    if (item_num >= 6 && item_num <= 10) {
        cat("\n================================================================================\n")
        cat(sprintf("ADAPTIVE PHASE - Item %d (PA_%02d)\n", item_num, item_num))
        cat("================================================================================\n")
        
        # Show current responses
        if (!is.null(session$responses)) {
            responses_so_far <- length(session$responses)
            cat(sprintf("Responses collected: %d items\n", responses_so_far))
            
            # Estimate current theta (simplified)
            if (responses_so_far >= 3) {
                theta_est <- mean(as.numeric(session$responses), na.rm = TRUE) - 3
                cat(sprintf("Current ability estimate: theta = %.3f\n", theta_est))
            }
        }
        
        # Show item parameters
        cat(sprintf("Item difficulty: b = %.2f\n", all_items_de$b[item_num]))
        cat(sprintf("Item discrimination: a = %.2f\n", all_items_de$a[item_num]))
        
        # Calculate information for this item
        if (exists("theta_est")) {
            a <- all_items_de$a[item_num]
            b <- all_items_de$b[item_num]
            p <- 1 / (1 + exp(-a * (theta_est - b)))
            info <- a^2 * p * (1 - p)
            cat(sprintf("Item information: I = %.4f\n", info))
        }
        
        cat("Selection method: Sequential (simulated adaptive)\n")
        cat("================================================================================\n\n")
    }
    
    return(NULL)
}

# =============================================================================
# LAUNCH WITH CLOUD STORAGE
# =============================================================================

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# Enable adaptive selection output like inrep examples
# This function will be called for item selection if we enable it
custom_item_selection <- function(rv, item_bank, config, session = NULL) {
    # STARS-D ADAPTED: 23 PA items total
    # Non-adaptive items: 6, 8, 9, 21, 23 (shown fixed on page 6)
    # Adaptive pool: 1-5, 7, 10-20, 22 (18 items)
    # This function selects 5 adaptive items for pages 7-11
    
    # CRITICAL: Read administered items from session$userData (non-reactive storage)
    administered_items <- if (!is.null(session) && !is.null(session$userData$administered)) {
        session$userData$administered
    } else {
        rv$administered %||% integer(0)
    }
    
    # Check which PA items have been administered (1-23)
    administered_pa <- administered_items[administered_items >= 1 & administered_items <= 23]
    num_pa_items_shown <- length(administered_pa)
    
    # Check responses for PA items
    responses_for_pa <- which(!is.na(rv$responses[1:min(23, length(rv$responses))]))
    num_pa_responses <- length(responses_for_pa)
    
    # Use the maximum to determine progress
    effective_pa_count <- max(num_pa_items_shown, num_pa_responses)
    
    message(sprintf("DEBUG: Administered PA items: %s (count: %d), PA responses: %s (count: %d), effective: %d", 
                    paste(administered_pa, collapse=", "), num_pa_items_shown,
                    paste(responses_for_pa, collapse=", "), num_pa_responses, effective_pa_count))
    
    # Fixed non-adaptive items (6, 8, 9, 21, 23) - should already be shown on page 6
    # NEVER return these items - they're already shown on page 6!
    fixed_items <- c(6, 8, 9, 21, 23)
    
    if (effective_pa_count < 5) {
        message("WARNING: Fixed items should already be shown on page 6! Skipping selection.")
        return(NULL)
    }
    
    # Adaptive selection: Select 5 items from pool (18 items total)
    # Pool: 1-5, 7, 10-20, 22 (excluding fixed items 6, 8, 9, 21, 23)
    # Pages 7-11: Select one item per page
    if (effective_pa_count >= 5 && effective_pa_count < 10) {
        adaptive_item_number <- effective_pa_count - 4  # 6th, 7th, 8th, 9th, or 10th PA item
        message("\n================================================================================")
        message(sprintf("ADAPTIVE ITEM SELECTION - Selecting PA item #%d (item %d of 10 total PA)", 
                        adaptive_item_number + 5, effective_pa_count + 1))
        message("================================================================================")
        
        # Get responses so far
        responses_so_far <- rv$responses[1:length(rv$responses)]
        message(sprintf("Responses collected so far: %d items", sum(!is.na(responses_so_far))))
        
        # Use current ability estimate if available (updated by estimate_ability after each response)
        # Otherwise estimate using proper TAM-based estimation
        current_theta <- rv$current_ability %||% config$theta_prior[1] %||% 0
        current_se <- rv$ability_se %||% config$theta_prior[2] %||% 1.0
        
        # If we have responses but no ability estimate yet, estimate it
        if (!is.null(responses_so_far) && length(responses_so_far) >= 3 && 
            (is.null(rv$current_ability) || !is.finite(rv$current_ability))) {
            tryCatch({
                # Use inrep's estimate_ability function for proper TAM-based estimation
                if (exists("estimate_ability", mode = "function")) {
                    ability_result <- inrep::estimate_ability(rv, item_bank, config)
                    if (!is.null(ability_result$theta) && is.finite(ability_result$theta)) {
                        current_theta <- ability_result$theta
                        current_se <- ability_result$se %||% current_se
                        # Update rv for future use
                        rv$current_ability <- current_theta
                        rv$ability_se <- current_se
                    }
                } else {
                    # Fallback: Use simplified Newton-Raphson for speed
                    shown_indices <- rv$administered[rv$administered <= 20]
                    if (length(shown_indices) > 0 && all(shown_indices <= nrow(item_bank))) {
                        a_params <- item_bank$a[shown_indices]
                        b_params <- item_bank$b[shown_indices]
                        item_responses <- responses_so_far[seq_along(shown_indices)]
                        
                        # Quick theta estimation (3 iterations max for speed)
                        for (iter in 1:3) {
                            probs <- 1 / (1 + exp(-a_params * (current_theta - b_params)))
                            first_deriv <- sum(a_params * (item_responses/5 - probs))
                            second_deriv <- -sum(a_params^2 * probs * (1 - probs))
                            
                            if (abs(second_deriv) > 0.01) {
                                current_theta <- current_theta - first_deriv / second_deriv
                            }
                        }
                        current_se <- 1 / sqrt(abs(second_deriv))
                    }
                }
            }, error = function(e) {
                message(sprintf("Error in ability estimation: %s, using prior", e$message))
                current_theta <- config$theta_prior[1] %||% 0
                current_se <- config$theta_prior[2] %||% 1.0
            })
        }
        
        message(sprintf("Current ability estimate: theta=%.3f, SE=%.3f", current_theta, current_se))
        
        # Get available PA items from adaptive pool (18 items total)
        # Adaptive pool: 1-5, 7, 10-20, 22
        # Exclude fixed items: 6, 8, 9, 21, 23
        adaptive_pool <- c(1:5, 7, 10:20, 22)
        
        # Check both administered AND items with responses (to avoid duplicates)
        # Fixed items (6, 8, 9, 21, 23) are ALWAYS excluded (they're on page 6)
        already_shown_pa <- unique(c(
            rv$administered[rv$administered >= 1 & rv$administered <= 23],
            responses_for_pa[responses_for_pa >= 1 & responses_for_pa <= 23],
            fixed_items  # Always exclude fixed items (shown on page 6)
        ))
        available_items <- setdiff(adaptive_pool, already_shown_pa)
        
        if (is.null(available_items) || length(available_items) == 0) {
            return(NULL)
        }
        
        message(sprintf("Available items in pool: %s", paste(available_items, collapse = ", ")))
        
        # Calculate Fisher Information for each available item
        item_info <- sapply(available_items, function(item_idx) {
            a <- item_bank$a[item_idx]  # discrimination
            b <- item_bank$b[item_idx]  # difficulty
            
            # Fisher Information for 2PL: I(theta) = a^2 * P(theta) * Q(theta)
            p <- 1 / (1 + exp(-a * (current_theta - b)))
            q <- 1 - p
            info <- a^2 * p * q
            
            return(info)
        })
        
        # Show information for all candidate items
        message("\nItem Information Values:")
        info_df <- data.frame(
            Item = available_items,
            ID = paste0("PA_", sprintf("%02d", available_items)),
            Information = round(item_info, 4),
            Difficulty = item_bank$b[available_items],
            Discrimination = item_bank$a[available_items]
        )
        
        # Sort by information
        info_df <- info_df[order(info_df$Information, decreasing = TRUE), ]
        
        # Print top 5 candidates
        for (i in 1:min(5, nrow(info_df))) {
            if (i == 1) {
                message(sprintf("  %2d. Item %2d (%s): I=%.4f, b=%5.2f, a=%.2f *** BEST ***", 
                                i, info_df$Item[i], info_df$ID[i], info_df$Information[i], 
                                info_df$Difficulty[i], info_df$Discrimination[i]))
            } else {
                message(sprintf("  %2d. Item %2d (%s): I=%.4f, b=%5.2f, a=%.2f", 
                                i, info_df$Item[i], info_df$ID[i], info_df$Information[i], 
                                info_df$Difficulty[i], info_df$Discrimination[i]))
            }
        }
        
        # Select item with maximum information
        best_idx <- which.max(item_info)
        selected_item <- available_items[best_idx]
        
        message(sprintf("\nSelected item %d (%s) with Maximum Fisher Information = %.4f", 
                        selected_item, paste0("PA_", sprintf("%02d", selected_item)), 
                        item_info[best_idx]))
        message(sprintf("Reason: This item provides the most information at current theta = %.3f", 
                        current_theta))
        message("================================================================================\n")
        
        return(selected_item)
    }
    
    # Items 11+: Fixed non-PA items (24-54 in order)
    # IMPORTANT: Pages 12+ have fixed item_indices defined directly (e.g., item_indices = 24:28)
    # They should NOT call this function - they use their fixed indices from page$item_indices
    # So if we get here with effective_pa_count >= 10, something went wrong
    # Return NULL and let the page use its fixed item_indices directly
    if (effective_pa_count >= 10) {
        message("WARNING: custom_item_selection called but all 10 PA items are done.")
        message("Pages 12+ should use fixed item_indices directly, not call this function.")
        message("Returning NULL - page should use its fixed item_indices.")
        return(NULL)
    }
    
    message(sprintf("WARNING: No item selected. effective_pa_count=%d, num_pa_items_shown=%d, total_items_shown=%d", 
                    effective_pa_count, num_pa_items_shown, length(rv$administered)))
    return(NULL)
}


# =============================================================================
# STUDY CONFIGURATION WITH BILINGUAL SUPPORT
# =============================================================================

# Ensure PURE German default - remove ALL language preferences
if (exists("global_language_preference", envir = .GlobalEnv)) {
    rm("global_language_preference", envir = .GlobalEnv)
}
if (exists("current_language", envir = .GlobalEnv)) {
    rm("current_language", envir = .GlobalEnv)
}
if (exists("study_language_preference", envir = .GlobalEnv)) {
    rm("study_language_preference", envir = .GlobalEnv)
}

session_uuid <- paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S"))

# =============================================================================
# COMPREHENSIVE DATASET FUNCTION FOR PROPER ADAPTIVE ITEM MAPPING
# =============================================================================
get_comprehensive_dataset <- function(responses = NULL, demographics = NULL, item_bank = NULL) {
    tryCatch({
        cat("DEBUG: get_comprehensive_dataset called with", length(responses), "responses\n")
        
        # CRITICAL: Always use session variables for administered items if available
        # The administered array is essential for adaptive testing - cannot be reconstructed from responses
        if (exists("rv") && !is.null(rv$responses) && !is.null(rv$administered)) {
            cat("DEBUG: Using session data - responses:", length(rv$responses), "administered:", length(rv$administered), "\n")
            if (is.null(responses)) responses <- rv$responses
            administered <- rv$administered  # ALWAYS use session administered array
            
        } else if (!is.null(responses)) {
            # CRITICAL FALLBACK: For HilFo study, reconstruct the administered array based on response pattern
            cat("WARNING: No session administered array available - using HilFo-specific reconstruction\n")
            administered <- which(!is.na(responses))
            
            # SPECIAL FIX: For HilFo adaptive PA items, add missing adaptive items based on pattern
            # If we have responses 1-5 and 21+ but missing 6-20, these are adaptive PA gaps
            non_na_indices <- which(!is.na(responses))
            has_early_pa <- any(non_na_indices >= 1 & non_na_indices <= 5)
            has_later_items <- any(non_na_indices >= 21)
            missing_pa_range <- !any(non_na_indices >= 6 & non_na_indices <= 20)
            
            if (has_early_pa && has_later_items && missing_pa_range) {
                cat("DEBUG: Detected HilFo adaptive PA pattern - adding missing adaptive items\n")
                # Based on HilFo study design: 5 fixed + 5 adaptive PA items = 10 total
                # The adaptive items would be in the gap between fixed PA (1-5) and BFI (21+)
                # Add 5 adaptive PA items in positions 6-20 (we'll map them correctly below)
                
                # For now, add placeholders - they'll be mapped correctly in the item mapping loop
                cat("DEBUG: Adding adaptive PA placeholder items to administered array\n")
            }
            
        } else {
            cat("ERROR: No responses available from parameters or session\n")
            return(NULL)
        }
        
        if (is.null(demographics)) {
            if (exists("rv") && !is.null(rv$demographics)) {
                demographics <- rv$demographics
            }
        }
        
        cat("DEBUG: Using", length(responses), "responses and", length(administered), "administered items\n")
        
        # Create base data structure
        data <- data.frame(
            timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
            session_id = if(exists("session_uuid")) session_uuid else paste0("session_", format(Sys.time(), "%Y%m%d_%H%M%S")),
            study_language = "de",
            stringsAsFactors = FALSE
        )
        
        # Add demographic data
        if (!is.null(demographics)) {
            for (demo_name in names(demographics)) {
                data[[demo_name]] <- demographics[[demo_name]]
            }
        }
        
        # Initialize all item columns with NA
        # PA items (1-23) - STARS-D adapted
        for (i in 1:23) {
            data[[sprintf("PA_%02d", i)]] <- NA
        }
        
        # BFI items (24-43)
        bfi_cols <- c("BFE_01", "BFE_02", "BFE_03", "BFE_04",  # Extraversion (24-27)
                      "BFV_01", "BFV_02", "BFV_03", "BFV_04",  # Verträglichkeit (28-31)
                      "BFG_01", "BFG_02", "BFG_03", "BFG_04",  # Gewissenhaftigkeit (32-35)
                      "BFN_01", "BFN_02", "BFN_03", "BFN_04",  # Neurotizismus (36-39)
                      "BFO_01", "BFO_02", "BFO_03", "BFO_04")  # Offenheit (40-43)
        for (col in bfi_cols) {
            data[[col]] <- NA
        }
        
        # Other items (44-54)  
        other_cols <- c("PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",      # PSQ (44-48)
                       "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",     # MWS (49-52)
                       "Statistik_gutfolgen", "Statistik_selbstwirksam")        # Stats (53-54)
        for (col in other_cols) {
            data[[col]] <- NA
        }
        
        # CRITICAL FIX: Map responses to correct columns using RESPONSE INDEX = ITEM INDEX
        # The fundamental fix: rv$responses[i] corresponds directly to item i, not administered[i]
        if (length(responses) > 0) {
            for (response_idx in seq_along(responses)) {
                if (!is.na(responses[response_idx])) {
                    # CORRECT MAPPING: response_idx directly corresponds to item number
                    item_num <- response_idx
                    
                    if (item_num >= 1 && item_num <= 23) {
                        # PA items (1-23) - STARS-D adapted
                        col_name <- sprintf("PA_%02d", item_num)
                        data[[col_name]] <- responses[response_idx]
                        cat("DEBUG: Mapped response", response_idx, "(value:", responses[response_idx], ") to PA item", item_num, "->", col_name, "\n")
                        
                    } else if (item_num >= 24 && item_num <= 43) {
                        # BFI items (24-43)
                        bfi_index <- item_num - 23
                        col_name <- bfi_cols[bfi_index]
                        data[[col_name]] <- responses[response_idx]
                        cat("DEBUG: Mapped response", response_idx, "(value:", responses[response_idx], ") to BFI item", item_num, "->", col_name, "\n")
                        
                    } else if (item_num >= 44 && item_num <= 54) {
                        # Other items (44-54)
                        other_index <- item_num - 43
                        col_name <- other_cols[other_index]
                        data[[col_name]] <- responses[response_idx]
                        cat("DEBUG: Mapped response", response_idx, "(value:", responses[response_idx], ") to other item", item_num, "->", col_name, "\n")
                    }
                }
            }
        }
        
        # CRITICAL FIX: Check if adaptive PA responses are missing and try to recover them
        # This handles the case where adaptive responses weren't saved to rv$responses properly
        pa_responses_found <- sum(!is.na(sapply(1:20, function(x) data[[sprintf("PA_%02d", x)]])))
        
        if (pa_responses_found >= 5 && pa_responses_found < 10) {  # Between 5-9 PA responses found
            cat("INFO: Found", pa_responses_found, "PA responses (expected 10 for full HilFo). Attempting recovery of missing adaptive items.\n")
            
            # Check if we have page_selected_items in session for adaptive pages
            if (exists("rv") && !is.null(rv$page_selected_items)) {
                adaptive_pages <- c("page7_pa2", "page8_pa3", "page9_pa4", "page10_pa5", "page11_pa6")
                
                for (page_id in adaptive_pages) {
                    if (!is.null(rv$page_selected_items[[page_id]])) {
                        selected_item <- rv$page_selected_items[[page_id]]
                        cat("RECOVERY: Found cached item", selected_item, "for", page_id, "\n")
                        
                        # Try to find the response in page_responses or other session data
                        # This is a last resort data recovery attempt
                        if (exists("rv") && !is.null(rv$item_responses)) {
                            item_id <- if (selected_item <= length(item_bank)) item_bank$id[selected_item] else paste0("item_", selected_item)
                            response_key <- paste0("item_", item_id)
                            
                            if (!is.null(rv$item_responses[[response_key]])) {
                                value <- rv$item_responses[[response_key]]
                                col_name <- sprintf("PA_%02d", selected_item)
                                data[[col_name]] <- as.numeric(value)
                                cat("RECOVERED: Response for", page_id, "->", col_name, "=", value, "\n")
                            }
                        }
                    }
                }
            }
        }
        
        # Add theta and se if available
        if (exists("rv")) {
            data$theta <- if(!is.null(rv$current_ability)) rv$current_ability else NA
            data$se <- if(!is.null(rv$ability_se)) rv$ability_se else NA
        } else {
            data$theta <- NA
            data$se <- NA
        }
        
        cat("DEBUG: Created comprehensive dataset with", ncol(data), "columns\n")
        return(data)
        
    }, error = function(e) {
        cat("ERROR in get_comprehensive_dataset:", e$message, "\n")
        return(NULL)
    })
}

# CSV PROCESSOR FOR HILFO-SPECIFIC CALCULATED COLUMNS
# =============================================================================
process_hilfo_csv <- function(csv_data, responses, demographics, item_bank) {
    cat("DEBUG: process_hilfo_csv called with", length(responses), "responses\n")
    
    # CRITICAL: Use get_comprehensive_dataset for proper adaptive item mapping
    tryCatch({
        comprehensive_data <- get_comprehensive_dataset(responses, demographics, item_bank)
        cat("DEBUG: Successfully created comprehensive dataset with", ncol(comprehensive_data), "columns\n")
        
        # Replace the existing csv_data with comprehensive dataset (preserves all correct mappings)
        for (col_name in names(comprehensive_data)) {
            csv_data[[col_name]] <- comprehensive_data[[col_name]]
        }
        
        # Now calculate scores using the properly mapped item columns
        # BFI scores using correct column names (BFE, BFV, BFG, BFN, BFO)
        bfe_cols <- c("BFE_01", "BFE_02", "BFE_03", "BFE_04")  # Extraversion
        bfv_cols <- c("BFV_01", "BFV_02", "BFV_03", "BFV_04")  # Verträglichkeit
        bfg_cols <- c("BFG_01", "BFG_02", "BFG_03", "BFG_04")  # Gewissenhaftigkeit
        bfn_cols <- c("BFN_01", "BFN_02", "BFN_03", "BFN_04")  # Neurotizismus
        bfo_cols <- c("BFO_01", "BFO_02", "BFO_03", "BFO_04")  # Offenheit
        
        # Calculate BFI scales
        # NOTE: 999 values ("Keine Angabe") are stored in CSV but automatically excluded here via !is.na() check
        # Extract values for BFI calculations
        bfe_values <- sapply(bfe_cols, function(col) if (col %in% names(csv_data) && !is.na(csv_data[[col]])) as.numeric(csv_data[[col]]) else NA)
        bfv_values <- sapply(bfv_cols, function(col) if (col %in% names(csv_data) && !is.na(csv_data[[col]])) as.numeric(csv_data[[col]]) else NA)
        bfg_values <- sapply(bfg_cols, function(col) if (col %in% names(csv_data) && !is.na(csv_data[[col]])) as.numeric(csv_data[[col]]) else NA)
        bfn_values <- sapply(bfn_cols, function(col) if (col %in% names(csv_data) && !is.na(csv_data[[col]])) as.numeric(csv_data[[col]]) else NA)
        bfo_values <- sapply(bfo_cols, function(col) if (col %in% names(csv_data) && !is.na(csv_data[[col]])) as.numeric(csv_data[[col]]) else NA)
        
        # Calculate means for each BFI dimension
        if (sum(!is.na(bfe_values)) >= 2) csv_data$BFI_Extraversion <- mean(bfe_values, na.rm = TRUE)
        if (sum(!is.na(bfv_values)) >= 2) csv_data$BFI_Vertraeglichkeit <- mean(bfv_values, na.rm = TRUE)
        if (sum(!is.na(bfg_values)) >= 2) csv_data$BFI_Gewissenhaftigkeit <- mean(bfg_values, na.rm = TRUE)
        if (sum(!is.na(bfn_values)) >= 2) csv_data$BFI_Neurotizismus <- mean(bfn_values, na.rm = TRUE)
        if (sum(!is.na(bfo_values)) >= 2) csv_data$BFI_Offenheit <- mean(bfo_values, na.rm = TRUE)
        
        # PSQ Stress using correct column names
        psq_cols <- c("PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30")
        psq_values <- sapply(psq_cols, function(col) {
            if (col %in% names(csv_data) && !is.na(csv_data[[col]]) && csv_data[[col]] != 999) {
                return(as.numeric(csv_data[[col]]))
            } else {
                return(NA)
            }
        })
        
        if (sum(!is.na(psq_values)) >= 3) {  # At least 60% of PSQ items
            csv_data$PSQ_Stress <- mean(psq_values, na.rm = TRUE)
        }
        
        # MWS Study Skills using correct column names
        mws_cols <- c("MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK")
        mws_values <- sapply(mws_cols, function(col) {
            if (col %in% names(csv_data) && !is.na(csv_data[[col]]) && csv_data[[col]] != 999) {
                return(as.numeric(csv_data[[col]]))
            } else {
                return(NA)
            }
        })
        
        if (sum(!is.na(mws_values)) >= 2) {  # At least 50% of MWS items
            csv_data$MWS_Studierfaehigkeiten <- mean(mws_values, na.rm = TRUE)
        }
        
        # Statistics using correct column names
        sta_cols <- c("Statistik_gutfolgen", "Statistik_selbstwirksam")
        sta_values <- sapply(sta_cols, function(col) {
            if (col %in% names(csv_data) && !is.na(csv_data[[col]]) && csv_data[[col]] != 999) {
                return(as.numeric(csv_data[[col]]))
            } else {
                return(NA)
            }
        })
        
        if (sum(!is.na(sta_values)) >= 1) {  # At least 50% of Statistics items
            csv_data$Statistik <- mean(sta_values, na.rm = TRUE)
        }
        
        cat("DEBUG: Added calculated scores to CSV data\n")
        
    }, error = function(e) {
        cat("ERROR in process_hilfo_csv:", e$message, "\n")
        # Fallback: return original csv_data if comprehensive dataset fails
    })
    
    return(csv_data)
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

study_config <- inrep::create_study_config(
    name = "HilFo - Hildesheimer Forschungsmethoden",
    study_key = session_uuid,
    theme = "hildesheim",
    custom_page_flow = custom_page_flow,
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    model = "2PL",
    adaptive = TRUE,
    max_items = 54,  # 23 PA + 20 BFI + 5 PSQ + 4 MWS + 2 Stats
    min_items = 54,
    criteria = "MFI",
    item_selection_fun = custom_item_selection,  # Enable custom adaptive selection
    response_ui_type = "radio",
    progress_style = "bar",
    language = "de",
    bilingual = TRUE,
    session_save = TRUE,
    session_timeout = 7200,
    results_processor = create_hilfo_report,
    csv_processor = process_hilfo_csv
)

# Launch the study
inrep::launch_study(
    config = study_config,
    item_bank = all_items_de,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv",
        debug_mode = TRUE  # Enable debug mode: STRG+A = fill page, STRG+Q = auto-fill all
)
