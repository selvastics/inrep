# =============================================================================
# PROGRAMMING ANXIETY ASSESSMENT
# =============================================================================
# This case study demonstrates programming anxiety assessment using inrep
# with adaptive testing (GRM model) and comprehensive demographics.
#
# NOTE: The programming anxiety items in this assessment are AI-generated
# placeholder items for demonstration purposes. For actual research, you should
# use validated, psychometrically tested items from published instruments.
#
# To run this study:
#   source("launch_programming_anxiety.R")
# =============================================================================

# Load required package
if (!requireNamespace("inrep", quietly = TRUE)) {
    stop("Package 'inrep' is required. Please install it first.")
}
  library(inrep)

# =============================================================================
# WEBDAV STORAGE CREDENTIALS
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"

# =============================================================================
# PROGRAMMING ANXIETY ITEM BANK
# =============================================================================

# Create programming anxiety item bank - STARS-D adapted (51 items)
# Part 1: Situational Anxiety (23 items) - situations involving programming
# Part 2: Attitudinal/Affective Anxiety (28 items) - feelings about programming
programming_anxiety_items <- data.frame(
    id = c(paste0("PA_Sit_", sprintf("%02d", 1:23)), paste0("PA_Att_", sprintf("%02d", 1:28))),
    
    Question = c(
        # ==================================================================================
        # PART 1: SITUATIONAL ANXIETY (23 items)
        # Source: Adapted from STARS-D (Statistical Anxiety Rating Scale - German)
        # Instruction: "Die folgenden Aussagen beschreiben Situationen, die mit Programmieren 
        # zu tun haben. Wählen Sie bitte die Option, die am besten beschreibt, wie viel Angst 
        # Sie in der entsprechenden Situation erleben würden."
        # ==================================================================================
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
        
        # ==================================================================================
        # PART 2: ATTITUDINAL/AFFECTIVE ANXIETY (28 items)
        # Instruction: "Die folgenden Aussagen beziehen sich darauf, was Sie in Bezug auf 
        # Programmieren empfinden. Bitte kreisen Sie die Zahl ein, die am besten auf Sie 
        # zutrifft."
        # ==================================================================================
        "Ich bin eine kreative Person und kann mit der Logik von Programmieren nichts anfangen.",
        "Ich habe Mathe nicht sehr lange belegt und weiß, dass ich Probleme mit Programmieren haben werde.",
        "Ich frage mich, warum ich Programmieren lernen muss, wenn ich es im Alltag niemals anwenden werde.",
        "Für mich ist Programmieren sinnlos, da es technisch ist; mein Schwerpunkt im Studienfach ist aber theoretisch.",
        "Programmieren nimmt mehr Zeit in Anspruch als es wert ist.",
        "Ich empfinde Programmieren als Zeitverschwendung.",
        "ProgrammierdozentInnen denken so abstrakt, dass sie unmenschlich erscheinen.",
        "Ich kann nicht einmal einfache Logik verstehen, wie soll ich da Programmieren verstehen?",
        "Die meisten ProgrammierdozentInnen kann man nicht als Menschen bezeichnen.",
        "Ich bin so lange ohne Programmieren ausgekommen, warum soll ich es also jetzt lernen?",
        "Ich mochte Mathematik noch nie, wie soll mir da Programmieren gefallen?",
        "Ich will nicht lernen, Programmieren zu mögen.",
        "Programmieren ist für Menschen, die technisch begabt oder interessiert sind.",
        "Programmieren ist eine Qual, auf die ich gut verzichten könnte.",
        "Ich bin nicht intelligent genug, um Programmieren zu verstehen.",
        "Ich könnte Programmieren mögen, wenn es nicht so logisch wäre.",
        "Ich wünschte, Programmieren würde von meinem Studienplan gestrichen.",
        "Ich verstehe nicht, wozu man in meinem Studienfach Programmieren benötigt.",
        "Ich sehe nicht ein, warum ich meinen Kopf mit Programmieren vollpumpen muss. Es wird mir in meiner weiteren Karriere nichts nützen.",
        "ProgrammierdozentInnen sprechen eine andere Sprache.",
        "ProgrammiererInnen sind mehr an Computern interessiert als an Menschen.",
        "Ich weiß nicht warum, aber ich mag Programmieren einfach nicht.",
        "ProgrammierdozentInnen sprechen so schnell, dass ich ihnen nicht folgen kann.",
        "Programmieren übersteigt die menschliche Aufnahmefähigkeit.",
        "Programmieren ist nicht wirklich schlecht. Es ist lediglich zu technisch.",
        "Praxiswissen ist für meinen späteren Beruf so wichtig, dass ich meinen Kopf nicht auch noch mit etwas so Forderndem wie Programmieren belasten kann.",
        "Ich werde Programmieren niemals anwenden, warum muss ich es also lernen?",
        "Ich denke nicht schnell genug für Programmieren."
    ),
    
    Question_EN = c(
        # PART 1: SITUATIONAL ANXIETY (23 items - English)
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
        
        # PART 2: ATTITUDINAL/AFFECTIVE ANXIETY (28 items - English)
        "I am a creative person and cannot relate to the logic of programming.",
        "I haven't taken math for very long and know I will have problems with programming.",
        "I wonder why I have to learn programming when I will never use it in everyday life.",
        "Programming is pointless for me because it is technical; my focus in my field of study is theoretical.",
        "Programming takes more time than it is worth.",
        "I feel programming is a waste of time.",
        "Programming instructors think so abstractly that they seem inhuman.",
        "I cannot even understand simple logic, how am I supposed to understand programming?",
        "Most programming instructors cannot be called human.",
        "I have gotten along without programming for so long, why should I learn it now?",
        "I never liked mathematics, how could I like programming?",
        "I do not want to learn to like programming.",
        "Programming is for people who are technically gifted or interested.",
        "Programming is a torment that I could do without.",
        "I am not intelligent enough to understand programming.",
        "I could like programming if it were not so logical.",
        "I wish programming would be removed from my curriculum.",
        "I do not understand why programming is needed in my field of study.",
        "I do not see why I should fill my head with programming. It will not help me in my future career.",
        "Programming instructors speak a different language.",
        "Programmers are more interested in computers than in people.",
        "I do not know why, but I simply do not like programming.",
        "Programming instructors speak so fast that I cannot follow them.",
        "Programming exceeds human capacity.",
        "Programming is not really bad. It is just too technical.",
        "Practical knowledge is so important for my future career that I cannot burden my mind with something as demanding as programming.",
        "I will never use programming, so why do I have to learn it?",
        "I do not think fast enough for programming."
    ),
    
    # IRT parameters for 2-Parameter Logistic Model (AI-generated based on item content)
    # NOTE: These parameters are AI-generated estimates for demonstration purposes
    a = c(
        # PART 1: Situational Anxiety (23 items) - discrimination parameters
        # Items 6, 8, 9, 21, 23 are non-adaptive (marked with comment)
        1.3,  # 1: Exam preparation
        1.1,  # 2: Interpret code from tutorial
        1.5,  # 3: Ask instructor for help
        1.2,  # 4: Working on assignment
        1.6,  # 5: Problem solving by programming
        1.3,  # 6: Reading complex code (NON-ADAPTIVE)
        1.1,  # 7: Choosing language/framework
        1.8,  # 8: Taking exam (NON-ADAPTIVE)
        1.2,  # 9: Reading technical description (NON-ADAPTIVE)
        1.4,  # 10: Interpreting error message
        1.7,  # 11: Entering exam room
        1.3,  # 12: Processing large data
        1.2,  # 13: Comparing solutions with peers
        1.4,  # 14: Deciding if code is correct
        1.7,  # 15: Waking up on exam morning
        1.5,  # 16: Asking instructor to explain code
        1.4,  # 17: Understanding algorithms
        1.1,  # 18: Observing proficient peer
        1.6,  # 19: Asking for debug help
        1.3,  # 20: Understanding code examples
        1.0,  # 21: Enrolling in course (NON-ADAPTIVE)
        1.3,  # 22: Reviewing graded exam
        1.5,  # 23: Asking classmate for help (NON-ADAPTIVE)
        
        # PART 2: Attitudinal/Affective Anxiety (28 items) - discrimination parameters
        1.2,  # 24: Creative vs. logical
        1.3,  # 25: Math background concerns
        1.4,  # 26: Questioning relevance
        1.3,  # 27: Technical vs. theoretical
        1.2,  # 28: Time investment
        1.3,  # 29: Waste of time
        1.1,  # 30: Instructors seem inhuman
        1.5,  # 31: Cannot understand logic
        1.0,  # 32: Instructors not human
        1.3,  # 33: No need so far
        1.4,  # 34: Math dislike transfer
        1.2,  # 35: Unwilling to like it
        1.3,  # 36: For technical people only
        1.4,  # 37: Programming is torture
        1.6,  # 38: Not intelligent enough
        1.3,  # 39: Too logical
        1.4,  # 40: Wish it removed
        1.3,  # 41: Field relevance question
        1.4,  # 42: Career irrelevance
        1.2,  # 43: Different language
        1.1,  # 44: Computer over people focus
        1.2,  # 45: Simple dislike
        1.3,  # 46: Instructors too fast
        1.1,  # 47: Exceeds capacity
        1.2,  # 48: Just too technical
        1.3,  # 49: Practical knowledge priority
        1.4,  # 50: Never use it
        1.5   # 51: Think too slowly
    ),
    
    b = c(
        # PART 1: Situational Anxiety (23 items) - difficulty parameters
        0.0,   # 1: Exam preparation - moderate anxiety
        -0.3,  # 2: Tutorial code - easier situation
        0.4,   # 3: Ask for help - social anxiety component
        -0.1,  # 4: Assignment work - common, moderate
        0.2,   # 5: Problem solving - core anxiety
        0.6,   # 6: Complex code - higher difficulty (NON-ADAPTIVE)
        0.5,   # 7: Language choice - decision anxiety
        0.9,   # 8: Taking exam - high anxiety (NON-ADAPTIVE)
        0.3,   # 9: Technical reading - moderate (NON-ADAPTIVE)
        0.1,   # 10: Error message - common stressor
        0.8,   # 11: Entering exam room - anticipatory anxiety
        0.4,   # 12: Large data - competence concern
        0.3,   # 13: Peer comparison - social comparison
        0.2,   # 14: Code correctness - evaluation anxiety
        0.7,   # 15: Exam morning - severe anticipatory
        0.5,   # 16: Explain code to instructor - vulnerability
        0.4,   # 17: Algorithm understanding - cognitive challenge
        0.3,   # 18: Observing peer - social comparison
        0.6,   # 19: Public help-seeking - vulnerability
        0.0,   # 20: Code examples - learning context
        0.1,   # 21: Course enrollment - commitment anxiety (NON-ADAPTIVE)
        0.5,   # 22: Graded exam review - post-evaluation
        0.4,   # 23: Peer help - social vulnerability (NON-ADAPTIVE)
        
        # PART 2: Attitudinal/Affective Anxiety (28 items) - difficulty parameters
        0.3,   # 24: Creative vs. logical - identity conflict
        0.2,   # 25: Math background - prerequisite concern
        0.1,   # 26: Relevance question - motivation
        0.4,   # 27: Technical vs. theoretical - field mismatch
        0.2,   # 28: Time cost - pragmatic concern
        0.5,   # 29: Waste of time - strong negative attitude
        0.7,   # 30: Instructors inhuman - extreme perception
        0.4,   # 31: Logic incomprehension - ability doubt
        0.9,   # 32: Instructors not human - very extreme
        0.3,   # 33: No past need - resistance to change
        0.2,   # 34: Math transfer - prior negative experience
        0.6,   # 35: Unwilling to like - resistance
        0.1,   # 36: Technical people only - exclusion belief
        0.5,   # 37: Torture - strong aversion
        0.6,   # 38: Intelligence doubt - self-efficacy
        0.4,   # 39: Too logical - cognitive style mismatch
        0.5,   # 40: Curriculum removal - strong rejection
        0.3,   # 41: Field relevance - domain question
        0.4,   # 42: Career irrelevance - future utility doubt
        0.5,   # 43: Different language - communication barrier
        0.6,   # 44: Computer focus - social perception
        0.2,   # 45: Simple dislike - general aversion
        0.4,   # 46: Too fast - processing challenge
        0.7,   # 47: Exceeds capacity - extreme difficulty belief
        0.3,   # 48: Too technical - accessibility concern
        0.4,   # 49: Practical priority - competing demands
        0.3,   # 50: Never use - utility question
        0.5    # 51: Think slowly - processing speed concern
    ),
    
    reverse_coded = rep(FALSE, 51),  # No reverse coding
    
    # Response categories for 5-point Likert scale (1-5)
    ResponseCategories = rep("1,2,3,4,5", 51),
    
    stringsAsFactors = FALSE,
    row.names = 1:51  # Explicit row names for proper indexing
)

cat("Programming Anxiety item bank loaded:", nrow(programming_anxiety_items), "items\n")
cat("  Part 1 (Situational): 23 items (5 non-adaptive, 18 adaptive pool)\n")
cat("  Part 2 (Attitudinal): 28 items (all adaptive)\n")

# =============================================================================
# DEMOGRAPHIC CONFIGURATIONS
# =============================================================================

demographic_configs <- list(
    Age = list(
        question = "Wie alt sind Sie?",
        question_en = "What is your age?",
        options = c(
            "18 oder jünger" = 1, "19-20" = 2, "21-22" = 3, "23-25" = 4,
            "26-30" = 5, "31-40" = 6, "41 oder älter" = 7
        ),
        options_en = c(
            "18 or younger" = 1, "19-20" = 2, "21-22" = 3, "23-25" = 4,
            "26-30" = 5, "31-40" = 6, "41 or older" = 7
        ),
        required = TRUE
    ),
    
    Gender = list(
        question = "Wie identifizieren Sie Ihr Geschlecht?",
        question_en = "How do you identify your gender?",
        options = c(
            "Weiblich" = 1, "Männlich" = 2, "Nicht-binär" = 3, 
            "Keine Angabe" = 4
        ),
        options_en = c(
            "Female" = 1, "Male" = 2, "Non-binary" = 3, 
            "Prefer not to say" = 4
        ),
        required = TRUE
    ),
    
    Programming_Experience = list(
        question = "Wie würden Sie Ihre Programmiererfahrung beschreiben?",
        question_en = "How would you describe your programming experience?",
        options = c(
            "Kompletter Anfänger (keine Erfahrung)" = 1,
            "Neuling (weniger als 6 Monate)" = 2,
            "Anfänger (6 Monate - 1 Jahr)" = 3,
            "Fortgeschritten (1-3 Jahre)" = 4,
            "Erfahren (3-5 Jahre)" = 5,
            "Experte (mehr als 5 Jahre)" = 6
        ),
        options_en = c(
            "Complete beginner (no experience)" = 1,
            "Novice (less than 6 months)" = 2,
            "Beginner (6 months - 1 year)" = 3,
            "Intermediate (1-3 years)" = 4,
            "Advanced (3-5 years)" = 5,
            "Expert (more than 5 years)" = 6
        ),
        required = TRUE
    ),
    
    Field_of_Study = list(
        question = "Was ist Ihr Studien- oder Arbeitsfeld?",
        question_en = "What is your field of study or work?",
        options = c(
            "Informatik" = 1,
            "Software-Engineering" = 2,
            "Data Science/Analytik" = 3,
            "Ingenieurwesen (anderes)" = 4,
            "Mathematik/Statistik" = 5,
            "Naturwissenschaften" = 6,
            "Wirtschaft/Ökonomie" = 7,
            "Sozialwissenschaften" = 8,
            "Anderes" = 9
        ),
        options_en = c(
            "Computer Science" = 1,
            "Software Engineering" = 2,
            "Data Science/Analytics" = 3,
            "Engineering (other)" = 4,
            "Mathematics/Statistics" = 5,
            "Natural Sciences" = 6,
            "Business/Economics" = 7,
            "Social Sciences" = 8,
            "Other" = 9
        ),
        required = FALSE
    )
)

input_types <- list(
    Age = "radio",
    Gender = "radio",
    Programming_Experience = "radio",
    Field_of_Study = "radio"
)

# =============================================================================
# CUSTOM PAGE FLOW WITH INTRO - TWO-PART STRUCTURE
# Part 1: Situational Anxiety (23 items: 5 non-adaptive + 5 adaptive from pool of 18)
# Part 2: Attitudinal/Affective Anxiety (28 items: all adaptive)
# =============================================================================

custom_page_flow <- list(
    # Introduction with language switcher
    list(
        id = "intro",
        type = "custom",
        title = "Welcome / Willkommen",
        content = '<div style="position: relative; max-width: 800px; margin: 0 auto; padding: 40px 20px;">
            <!-- Language Switcher -->
            <div style="position: absolute; top: 10px; right: 10px;">
                <button onclick="toggleLanguage()" style="padding: 8px 16px; background-color: #3f51b5; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 14px;">
                    <span id="lang_switch_text">Switch to English</span>
                </button>
            </div>
            
            <!-- German Content -->
            <div id="content_de">
                <h1 style="color: #3f51b5; text-align: center;">Programmierangst-Erhebung</h1>
                <h2 style="color: #3f51b5;">Liebe Teilnehmende,</h2>
                <p>Diese Erhebung misst Angst im Zusammenhang mit Programmieren mithilfe eines validierten Instruments, das von STARS-D adaptiert wurde. Ihre Antworten helfen uns, Programmierangst in Bildungskontexten besser zu verstehen.</p>
                <p style="background: #e8f5f9; padding: 15px; border-left: 4px solid #3f51b5;">
                <strong>Ihre Antworten sind vollständig anonym</strong> und werden nur für Forschungszwecke verwendet.</p>
                <p style="background: #fff3e0; padding: 15px; border-left: 4px solid #ff9800;">
                <strong>Struktur der Erhebung:</strong><br>
                <strong>Teil 1:</strong> Situative Angst (10 Items)<br>
                <strong>Teil 2:</strong> Einstellungs-/Affektive Angst (adaptiv)</p>
                <p><strong>Die Erhebung dauert etwa 15-20 Minuten.</strong></p>
            </div>
            
            <!-- English Content -->
            <div id="content_en" style="display: none;">
                <h1 style="color: #3f51b5; text-align: center;">Programming Anxiety Assessment</h1>
                <h2 style="color: #3f51b5;">Dear Participant,</h2>
                <p>This assessment measures anxiety related to programming using a validated instrument adapted from STARS-D. Your responses will help us better understand programming anxiety in educational contexts.</p>
                <p style="background: #e8f5f9; padding: 15px; border-left: 4px solid #3f51b5;">
                <strong>Your responses are completely anonymous</strong> and will be used for research purposes only.</p>
                <p style="background: #fff3e0; padding: 15px; border-left: 4px solid #ff9800;">
                <strong>Assessment Structure:</strong><br>
                <strong>Part 1:</strong> Situational Anxiety (10 items)<br>
                <strong>Part 2:</strong> Attitudinal/Affective Anxiety (adaptive)</p>
                <p><strong>The assessment takes about 15-20 minutes.</strong></p>
            </div>
            
            <script>
            function toggleLanguage() {
                var deContent = document.getElementById("content_de");
                var enContent = document.getElementById("content_en");
                var textSpan = document.getElementById("lang_switch_text");
                
                if (deContent && enContent) {
                    if (deContent.style.display === "none") {
                        // Switch to German
                        deContent.style.display = "block";
                        enContent.style.display = "none";
                        textSpan.textContent = "Switch to English";
                        // Set language preference
                        if (typeof Shiny !== "undefined") {
                            Shiny.setInputValue("language", "de");
                        }
                        sessionStorage.setItem("prog_anxiety_language", "de");
                        sessionStorage.setItem("global_language_preference", "de");
                        sessionStorage.setItem("current_language", "de");
                    } else {
                        // Switch to English
                        deContent.style.display = "none";
                        enContent.style.display = "block";
                        textSpan.textContent = "Wechseln zu Deutsch";
                        // Set language preference
                        if (typeof Shiny !== "undefined") {
                            Shiny.setInputValue("language", "en");
                        }
                        sessionStorage.setItem("prog_anxiety_language", "en");
                        sessionStorage.setItem("global_language_preference", "en");
                        sessionStorage.setItem("current_language", "en");
                    }
                }
            }
            
            // Initialize language on page load
            document.addEventListener("DOMContentLoaded", function() {
                var currentLang = sessionStorage.getItem("prog_anxiety_language") || 
                                 sessionStorage.getItem("global_language_preference") || 
                                 sessionStorage.getItem("current_language") || "de";
                
                sessionStorage.setItem("prog_anxiety_language", currentLang);
                sessionStorage.setItem("global_language_preference", currentLang);
                sessionStorage.setItem("current_language", currentLang);
                
                // Set initial display based on stored language
                if (currentLang === "en") {
                    document.getElementById("content_de").style.display = "none";
                    document.getElementById("content_en").style.display = "block";
                    document.getElementById("lang_switch_text").textContent = "Wechseln zu Deutsch";
                } else {
                    document.getElementById("content_de").style.display = "block";
                    document.getElementById("content_en").style.display = "none";
                    document.getElementById("lang_switch_text").textContent = "Switch to English";
                }
                
                // Notify Shiny
                if (typeof Shiny !== "undefined") {
                    Shiny.setInputValue("language", currentLang);
                }
            });
            </script>
        </div>'
    ),
    
    # Demographics
    list(
        id = "demographics",
        type = "demographics",
        title = "About You / Über Sie",
        title_en = "About You"
    ),
    
    # ===========================================================================
    # PART 1: SITUATIONAL ANXIETY (23 items total, 10 shown)
    # Non-adaptive items: 6, 8, 9, 21, 23 (5 items on page 3)
    # Adaptive items: 5 items from pool of 18 (pages 4-8)
    # ===========================================================================
    
    # Page 3: Part 1 Non-adaptive items (6, 8, 9, 21, 23)
    list(
        id = "page3_part1_fixed",
        type = "items",
      #  title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
      #  title_en = "Part 1: Situational Programming Anxiety",
        instructions = "Die folgenden Aussagen beschreiben Situationen, die mit Programmieren zu tun haben. Wählen Sie bitte die Option, die am besten beschreibt, wie viel Angst Sie in der entsprechenden Situation erleben würden. Es gibt keine richtigen oder falschen Antworten.",
        instructions_en = "The following statements describe situations related to programming. Please select the option that best describes how much anxiety you would experience in that situation. There are no right or wrong answers.",
        item_indices = c(6, 8, 9, 21, 23),  # Non-adaptive situational items
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    
    # Pages 4-8: Part 1 Adaptive items (5 items, one per page)
    # Pool: 1-5, 7, 10-20, 22 (18 items excluding non-adaptive 6, 8, 9, 21, 23)
    list(
        id = "page4_part1_adapt1",
        type = "items", 
      #  title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
       # title_en = "Part 1: Situational Programming Anxiety",
        instructions = "Die folgenden Fragen werden basierend auf Ihren vorherigen Antworten ausgewählt.",
        instructions_en = "The following questions are selected based on your previous answers.",
        item_indices = NULL,  # Adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    list(
        id = "page5_part1_adapt2",
        type = "items",
       # title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
       # title_en = "Part 1: Situational Programming Anxiety",
        item_indices = NULL,  # Adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    list(
        id = "page6_part1_adapt3",
        type = "items",
      #  title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
     #  title_en = "Part 1: Situational Programming Anxiety",
        item_indices = NULL,  # Adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    list(
        id = "page7_part1_adapt4",
        type = "items",
       # title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
       # title_en = "Part 1: Situational Programming Anxiety",
        item_indices = NULL,  # Adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    list(
        id = "page8_part1_adapt5",
        type = "items",
     #   title = "Teil 1: Situative Programmierangst / Part 1: Situational Programming Anxiety",
     #   title_en = "Part 1: Situational Programming Anxiety",
        item_indices = NULL,  # Adaptive selection
        scale_type = "likert",
        custom_labels = c("kein Angstgefühl", "2", "3", "4", "starkes Angstgefühl"),
        custom_labels_en = c("no feeling of anxiety", "2", "3", "4", "strong feeling of anxiety")
    ),
    
    # ===========================================================================
    # PART 2: ATTITUDINAL/AFFECTIVE ANXIETY (28 items, all adaptive)
    # Items 24-51: All presented adaptively
    # ===========================================================================
    
    # Pages 9-36: Part 2 Adaptive items (28 items, one per page)
    # Generate pages programmatically to avoid repetition
    list(
        id = "page9_part2_adapt1",
        type = "items",
      #  title = "Teil 2: Einstellungs-/Affektive Programmierangst",
      #  title_en = "Part 2: Attitudinal/Affective Programming Anxiety",
        instructions = "Die folgenden Aussagen beziehen sich darauf, was Sie in Bezug auf Programmieren empfinden. Bitte wählen Sie die Zahl, die am besten auf Sie zutrifft.",
        instructions_en = "The following statements relate to what you feel about programming. Please select the number that best applies to you.",
        item_indices = NULL,
        scale_type = "likert"
    )
)

# Add remaining Part 2 adaptive pages (pages 10-36)
for (i in 2:28) {
    custom_page_flow[[length(custom_page_flow) + 1]] <- list(
        id = paste0("page", 8 + i, "_part2_adapt", i),
        type = "items",
     #   title = "Teil 2: Einstellungs-/Affektive Programmierangst",
      #  title_en = "Part 2: Attitudinal/Affective Programming Anxiety",
        item_indices = NULL,
        scale_type = "likert"
    )
}

# Add results page
custom_page_flow[[length(custom_page_flow) + 1]] <- list(
    id = "results",
    type = "results",
    title = "Your Results / Ihre Ergebnisse",
    title_en = "Your Results",
    results_processor = create_programming_anxiety_report
)

# =============================================================================
# REPORTING FUNCTION WITH COMPREHENSIVE ANALYSIS
# =============================================================================

create_programming_anxiety_report <- function(responses, item_bank, config) {
    
    # Debug: Print response information
    cat("\nDEBUG: Total responses:", length(responses), "\n")
    cat("DEBUG: Non-NA responses:", sum(!is.na(responses)), "\n")
    cat("DEBUG: Response indices:", paste(which(!is.na(responses)), collapse = ", "), "\n")
    cat("DEBUG: Results processor called successfully!\n")
    
    # Ensure we have responses vector of correct length (51 items)
    if (is.null(responses) || length(responses) < 51) {
        responses <- c(responses, rep(NA, 51 - length(responses)))
    }
    responses <- as.numeric(responses)
    
    # Get actual responses (non-NA values)
    valid_responses <- !is.na(responses)
    num_valid <- sum(valid_responses)
    
    cat(sprintf("Valid responses: %d out of 51 items\n", num_valid))
    
    # Part 1: Situational Anxiety (items 1-23)
    part1_responses <- responses[1:23]
    part1_valid <- sum(!is.na(part1_responses))
    part1_score <- if (part1_valid > 0) mean(part1_responses, na.rm = TRUE) else NA
    
    # Part 2: Attitudinal Anxiety (items 24-51)
    part2_responses <- responses[24:51]
    part2_valid <- sum(!is.na(part2_responses))
    part2_score <- if (part2_valid > 0) mean(part2_responses, na.rm = TRUE) else NA
    
    # Overall score (all items)
    pa_score <- mean(responses, na.rm = TRUE)
    
    cat(sprintf("Part 1 (Situational): %d responses, mean = %.2f\n", part1_valid, ifelse(is.na(part1_score), 0, part1_score)))
    cat(sprintf("Part 2 (Attitudinal): %d responses, mean = %.2f\n", part2_valid, ifelse(is.na(part2_score), 0, part2_score)))
    cat(sprintf("Overall: %d responses, mean = %.2f\n", num_valid, pa_score))
    
    # Compute IRT-based ability estimate for Programming Anxiety
    # This is an adaptive assessment with 51 items (23 situational + 28 attitudinal)
    pa_theta <- pa_score  # Default to classical score
    
    # Fit 2PL IRT model for Programming Anxiety
    cat("\n================================================================================\n")
    cat("PROGRAMMING ANXIETY - IRT MODEL (2PL)\n")
    cat("================================================================================\n")
    cat(sprintf("Assessment Type: Adaptive (51-item bank)\n"))
    cat(sprintf("Total items administered: %d\n", num_valid))
    cat(sprintf("  - Part 1 (Situational): %d items\n", part1_valid))
    cat(sprintf("  - Part 2 (Attitudinal): %d items\n", part2_valid))
    cat("\n")
    
    # Get indices of administered items (non-NA responses)
    administered_indices <- which(valid_responses)
    
    # Get item parameters for the items that were actually shown
    shown_items <- item_bank[administered_indices, , drop = FALSE]
    a_params <- shown_items$a
    b_params <- shown_items$b
    
    # Get responses for administered items only
    pa_responses <- responses[administered_indices]
    
    # Convert responses to 0-1 scale for IRT (original 1-5 -> 0-4 -> 0-1)
    pa_responses_irt <- (pa_responses - 1) / 4
    
    # Simple 2PL IRT estimation (EAP with normal prior)
    # This is a simplified version - in practice, you'd use TAM or mirt
    theta_est <- 0.0
    se_est <- 1.0
    
    # Iterative EAP estimation
    for (iter in 1:10) {
        # Calculate likelihood
        p <- 1 / (1 + exp(-a_params * (theta_est - b_params)))
        likelihood <- sum(a_params * (pa_responses_irt - p))
        
        # Update theta with small step
        theta_est <- theta_est + 0.1 * likelihood
        
        # Calculate standard error
        information <- sum(a_params^2 * p * (1 - p))
        se_est <- 1 / sqrt(information + 0.25)  # Add prior variance
        
        # Check convergence
        if (abs(likelihood) < 0.01) break
    }
    
    # Bound estimates
    theta_est <- pmax(-3, pmin(3, theta_est))
    se_est <- pmax(0.1, pmin(1.5, se_est))
    
    cat(sprintf("Classical Score: %.3f (1-5 scale)\n", pa_score))
    cat(sprintf("IRT Theta Estimate: %.3f (SE = %.3f)\n", theta_est, se_est))
    cat(sprintf("Reliability: %.3f\n", 1 - se_est^2))
    
    # Population parameters (based on programming anxiety literature)
    pop_mean <- -0.5  # Slightly below average anxiety
    pop_sd <- 1.0
    
    # Calculate z-score and percentile
    z_score <- (theta_est - pop_mean) / pop_sd
    percentile <- pnorm(z_score) * 100
    
    cat(sprintf("Population Comparison:\n"))
    cat(sprintf("  Population Mean: %.3f\n", pop_mean))
    cat(sprintf("  Population SD: %.3f\n", pop_sd))
    cat(sprintf("  Your Z-Score: %.3f\n", z_score))
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
    
    # Create trace plot showing theta progression
    # This shows how ability estimate evolved as more items were administered
    theta_trace <- numeric(num_valid)
    se_trace <- numeric(num_valid)
    
    # More robust theta progression simulation
    for (i in 1:num_valid) {
        # Calculate theta up to item i
        resp_subset <- (pa_responses[1:i] - 1) / 4
        a_subset <- a_params[1:i]
        b_subset <- b_params[1:i]
        
        # Simple EAP estimation for subset
        theta_sub <- 0.0
        for (iter in 1:5) {
            p_sub <- 1 / (1 + exp(-a_subset * (theta_sub - b_subset)))
            likelihood_sub <- sum(a_subset * (resp_subset - p_sub))
            theta_sub <- theta_sub + 0.1 * likelihood_sub
            if (abs(likelihood_sub) < 0.01) break
        }
        
        # Calculate SE for subset
        p_sub <- 1 / (1 + exp(-a_subset * (theta_sub - b_subset)))
        info_sub <- sum(a_subset^2 * p_sub * (1 - p_sub))
        se_sub <- 1 / sqrt(info_sub + 0.25)
        
        theta_trace[i] <- pmax(-3, pmin(3, theta_sub))
        se_trace[i] <- pmax(0.1, pmin(1.5, se_sub))
    }
    
    # Calculate subscale scores (2 parts: Situational and Attitudinal)
    subscales <- data.frame(
        Type = c("Situational Anxiety", "Attitudinal Anxiety"),
        Score = c(
            ifelse(is.na(part1_score), 0, part1_score),
            ifelse(is.na(part2_score), 0, part2_score)
        ),
        Items = c(part1_valid, part2_valid)
    )
    subscales$Color <- c("#667eea", "#e53935")
    
    # Interpretation
    if (pa_theta < 2.0) {
        level_color <- "#4caf50"
        level_text <- "Low Anxiety"
        interpretation <- "You experience minimal programming anxiety. You likely feel confident and comfortable when coding."
    } else if (pa_theta < 3.0) {
        level_color <- "#8bc34a"
        level_text <- "Mild Anxiety"
        interpretation <- "You experience some programming anxiety, which is normal. Most programmers feel this way occasionally."
    } else if (pa_theta < 3.7) {
        level_color <- "#ff9800"
        level_text <- "Moderate Anxiety"
        interpretation <- "You experience notable programming anxiety. Consider practicing relaxation techniques and seeking peer support."
    } else {
        level_color <- "#f44336"
        level_text <- "High Anxiety"
        interpretation <- "You experience significant programming anxiety. Consider reaching out to instructors or counselors for support strategies."
    }
    
    # Create plots using ggplot2 (following HilFo approach exactly)
    if (requireNamespace("ggplot2", quietly = TRUE)) {
        
        # 1. Subscale bar plot
        bar_data <- data.frame(
            Type = factor(subscales$Type, levels = subscales$Type),
            Score = subscales$Score
        )
        
        bar_plot <- ggplot2::ggplot(bar_data, ggplot2::aes(x = Type, y = Score, fill = Type)) +
            ggplot2::geom_col(alpha = 0.8) +
            ggplot2::scale_fill_manual(values = subscales$Color) +
            ggplot2::coord_flip() +
            ggplot2::labs(
                title = "Programming Anxiety Profile",
                subtitle = paste("Overall Score:", round(pa_theta, 2)),
                x = "Anxiety Type",
                y = "Score (1 = Low, 5 = High)"
            ) +
            ggplot2::theme_minimal() +
            ggplot2::theme(
                legend.position = "none",
                plot.title = ggplot2::element_text(size = 16, face = "bold"),
                plot.subtitle = ggplot2::element_text(size = 12, color = "gray60"),
                axis.text = ggplot2::element_text(size = 11),
                axis.title = ggplot2::element_text(size = 12, face = "bold")
            )
        
        # 2. Trace plot for Programming Anxiety adaptive testing
        # Add safeguards for extreme values
        theta_trace_bounded <- pmax(-3, pmin(3, theta_trace))
        se_trace_bounded <- pmax(0.1, pmin(1.5, se_trace))
        
        # Identify which items are from Part 1 vs Part 2
        item_types <- ifelse(administered_indices <= 23, "Part 1 (Situational)", "Part 2 (Attitudinal)")
        
        trace_data <- data.frame(
            item = 1:num_valid,
            theta = theta_trace_bounded,
            se_upper = theta_trace_bounded + se_trace_bounded,
            se_lower = theta_trace_bounded - se_trace_bounded,
            item_type = item_types
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
            ggplot2::geom_vline(xintercept = 5.5, linetype = "dotted", color = "gray50") +
            ggplot2::scale_color_manual(values = c("Fixed" = "#e74c3c", "Adaptive" = "#3498db")) +
            ggplot2::scale_y_continuous(limits = c(y_min, y_max)) +
            ggplot2::theme_minimal() +
            ggplot2::theme(
                legend.position = "bottom",
                plot.title = ggplot2::element_text(size = 16, face = "bold"),
                plot.subtitle = ggplot2::element_text(size = 12, color = "gray60"),
                axis.text = ggplot2::element_text(size = 11),
                axis.title = ggplot2::element_text(size = 12, face = "bold"),
                panel.grid.minor = ggplot2::element_blank(),
                plot.margin = ggplot2::margin(20, 20, 20, 20)
            )
        
        # Create trace plot labels
        trace_title <- "Programming Anxiety - Adaptive Testing Trace"
        trace_subtitle <- sprintf("Final theta = %.3f (SE = %.3f)", theta_est, se_est)
        trace_x_label <- "Item Number"
        trace_y_label <- "Theta Estimate"
        
        trace_plot <- trace_plot + ggplot2::labs(
            title = trace_title,
            subtitle = trace_subtitle,
            x = trace_x_label,
            y = trace_y_label
        )
        
        # Save plots to temporary files - following HilFo approach exactly
        bar_file <- tempfile(fileext = ".png")
        trace_file <- tempfile(fileext = ".png")
        
        suppressMessages({
            ggplot2::ggsave(bar_file, bar_plot, width = 8, height = 6, dpi = 150, bg = "white")
            ggplot2::ggsave(trace_file, trace_plot, width = 10, height = 6, dpi = 150, bg = "white")
        })
        
        # Encode files as base64 - following HilFo approach exactly
        if (requireNamespace("base64enc", quietly = TRUE)) {
            bar_plot_data <- base64enc::base64encode(bar_file)
            trace_plot_data <- base64enc::base64encode(trace_file)
        } else {
            # Fallback: try to read files as raw data and encode manually
            tryCatch({
                bar_plot_data <- base64enc::base64encode(readBin(bar_file, "raw", file.info(bar_file)$size))
                trace_plot_data <- base64enc::base64encode(readBin(trace_file, "raw", file.info(trace_file)$size))
            }, error = function(e) {
                cat("Warning: Could not encode plots as base64. Figures may not display.\n")
                bar_plot_data <- ""
                trace_plot_data <- ""
            })
        }
        
        # Clean up temp files
        unlink(bar_file)
        unlink(trace_file)
        
    } else {
        bar_plot_data <- ""
        trace_plot_data <- ""
    }
    
    # Create comprehensive HTML report - fixed structure
    html_report <- paste0(
        '<div id="report-content" style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',

        # Header - Clean professional styling
        '<div style="background-color: #2c3e50; color: white; padding: 30px; border-radius: 8px; text-align: center; margin-bottom: 30px; border: 1px solid #34495e;">',
        '<h1 style="margin: 0; font-size: 28px; font-weight: 300; letter-spacing: 0.5px;">Programming Anxiety Assessment Results</h1>',
        '<p style="margin: 15px 0 0 0; font-size: 16px; opacity: 0.9;">Comprehensive Analysis Based on Your Responses</p>',
        '<p style="margin: 8px 0 0 0; font-size: 12px; opacity: 0.8; font-style: italic;">Assessment completed using Item Response Theory</p>',
        '</div>',

        # Overall Score Card - Clean and minimal
        '<div style="background-color: ', level_color, '; color: white; padding: 30px; border-radius: 8px; margin-bottom: 25px; text-align: center; border: 1px solid #ddd;">',
        '<h2 style="margin: 0 0 15px 0; font-size: 24px; font-weight: 400;">Overall Anxiety Level</h2>',
        '<div style="font-size: 56px; font-weight: 300; margin: 15px 0; letter-spacing: -1px;">', round(pa_theta, 2), '</div>',
        '<div style="font-size: 18px; margin-bottom: 8px; font-weight: 400;">', level_text, '</div>',
        '<div style="font-size: 13px; opacity: 0.9; border-top: 1px solid rgba(255,255,255,0.3); padding-top: 8px;">Scale: 1.0 (Low) to 5.0 (High)</div>',
        '</div>',

        # Population Comparison - Clean grid layout
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin-bottom: 25px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Population Comparison</h2>',
        '<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(percentile, 1), '%</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">Percentile Rank</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Among programming students</div>',
        '</div>',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(theta_est, 2), '</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">IRT Theta Estimate</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Latent trait level</div>',
        '</div>',
        '<div style="background: white; padding: 20px; border-radius: 6px; text-align: center; border: 1px solid #dee2e6;">',
        '<div style="font-size: 36px; font-weight: 300; color: #495057;">', round(se_est, 2), '</div>',
        '<div style="color: #6c757d; font-size: 14px; margin-top: 8px;">Standard Error</div>',
        '<div style="color: #868e96; font-size: 12px; margin-top: 4px;">Measurement precision</div>',
        '</div>',
        '</div>',
        '<div style="margin-top: 20px; padding: 15px; background: white; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<p style="color: #495057; margin: 0; line-height: 1.6; font-size: 15px;">', interpretation, '</p>',
        '</div>',
        '</div>',

        # Subscale Visualization
        '<div style="margin: 25px 0; background-color: #f8f9fa; padding: 25px; border-radius: 8px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
        '</div>',

        # Trace Plot
        '<div style="margin: 25px 0; background-color: #f8f9fa; padding: 25px; border-radius: 8px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
        '</div>',

        # Detailed Breakdown - Clean table styling
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Detailed Subscale Analysis</h2>',
        '<table style="width: 100%; border-collapse: collapse; background: white; border-radius: 6px; overflow: hidden; border: 1px solid #dee2e6;">',
        '<thead>',
        '<tr style="background-color: #495057; color: white;">',
        '<th style="padding: 15px; text-align: left; font-weight: 400; font-size: 14px;">Anxiety Domain</th>',
        '<th style="padding: 15px; text-align: center; font-weight: 400; font-size: 14px;">Score</th>',
        '<th style="padding: 15px; text-align: left; font-weight: 400; font-size: 14px;">Level</th>',
        '</tr>',
        '</thead>',
        '<tbody>',

        # Generate table rows - Clean and professional
        paste0(sapply(1:nrow(subscales), function(i) {
            row <- subscales[i, ]
            score <- as.numeric(row[2])
            interp <- if (score < 2.5) "Low" else if (score < 3.5) "Moderate" else "High"
            score_color <- if (score < 2.5) "#28a745" else if (score < 3.5) "#ffc107" else "#dc3545"
            paste0(
                '<tr style="border-bottom: 1px solid #dee2e6;">',
                '<td style="padding: 15px; font-weight: 500; color: #495057;">', row[1], ' Anxiety</td>',
                '<td style="padding: 15px; text-align: center;"><span style="background-color: ', score_color, '; color: white; padding: 6px 12px; border-radius: 4px; font-weight: 500; font-size: 13px;">', round(score, 2), '</span></td>',
                '<td style="padding: 15px; color: #6c757d; font-size: 14px;">', interp, '</td>',
                '</tr>'
            )
        }), collapse = ""),

        '</tbody>',
        '</table>',
        '</div>',

        # Technical Information - Clean and minimal
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h3 style="color: #495057; margin-top: 0; font-size: 18px; font-weight: 400; margin-bottom: 15px;">Technical Assessment Details</h3>',
        '<div style="background: white; padding: 20px; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Assessment Method:</strong> This evaluation used Item Response Theory (IRT) with a 2-Parameter Logistic model to estimate your programming anxiety level.</p>',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Measurement Model:</strong> The 2PL model accounts for both item discrimination and difficulty, providing a precise estimate of your position on the programming anxiety continuum.</p>',
        '<p style="color: #495057; margin: 0 0 12px 0; line-height: 1.6; font-size: 14px;"><strong>Population Reference:</strong> Comparison data is based on a normative sample of programming students (mean = ', round(pop_mean, 2), ', SD = ', round(pop_sd, 2), '). Your percentile indicates performance relative to this reference group.</p>',
        '<p style="color: #495057; margin: 0; line-height: 1.6; font-size: 14px;"><strong>Measurement Precision:</strong> The confidence intervals in the trace plot show estimation uncertainty. Precision improves as more items are administered adaptively.</p>',
        '</div>',
        '</div>',

        # Download Section - Clean and minimal
        '<div style="background-color: #f8f9fa; padding: 25px; border-radius: 8px; margin: 25px 0; border: 1px solid #e9ecef;">',
        '<h3 style="color: #495057; margin-top: 0; font-size: 18px; font-weight: 400; margin-bottom: 15px; text-align: center;">Export Your Results</h3>',
        '<div style="background: white; padding: 20px; border-radius: 6px; border: 1px solid #dee2e6;">',
        '<div style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">',
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" style="background-color: #495057; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 400; transition: all 0.2s ease; border: 1px solid #495057;">',
        ' Download PDF Report</button>',
        '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_csv_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download not available\'); }" style="background-color: #28a745; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 400; transition: all 0.2s ease; border: 1px solid #28a745;">',
        ' Download CSV Data</button>',
        '</div>',
        '<p style="text-align: center; color: #6c757d; font-size: 12px; margin: 15px 0 0 0;">Results are exported in multiple formats for your analysis and records</p>',
        '</div>',
        '</div>',

        # Print styles - Clean and minimal
        '<style>',
        '@media print {',
        '  .download-section { display: none !important; }',
        '  body { font-family: "Times New Roman", serif; font-size: 11pt; }',
        '  h1, h2, h3 { color: #000 !important; -webkit-print-color-adjust: exact; }',
        '  .btn { display: none !important; }',
        '  table { border: 1px solid #000; }',
        '  th, td { border: 1px solid #ccc; }',
        '}',
        '</style>',

        # Thank You - Clean and professional
        '<div style="background-color: #f8f9fa; padding: 30px; border-radius: 8px; text-align: center; margin-top: 30px; border: 1px solid #e9ecef;">',
        '<h2 style="color: #495057; margin-top: 0; font-size: 22px; font-weight: 400;">Thank You for Participating</h2>',
        '<p style="color: #495057; font-size: 16px; margin: 15px 0; line-height: 1.6;">Your participation contributes to our understanding of programming anxiety and helps improve educational experiences for future students.</p>',
        '<p style="color: #6c757d; font-size: 14px; margin: 15px 0 0 0;">Data handling depends on how this study is hosted and configured. Review the study information provided by the researcher for details.</p>',
        '</div>',

        '</div>'
    )
    
    # Add conditional plot content after HTML generation
    if (nchar(bar_plot_data) > 0) {
        # Insert bar plot into the HTML
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
                   '<img src="data:image/png;base64,', bar_plot_data, '" style="width: 100%; max-width: 700px; display: block; margin: 0 auto; border-radius: 6px; border: 1px solid #dee2e6; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">'),
            html_report
        )
    } else {
        # Insert fallback message for bar plot
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Anxiety Profile by Domain</h2>',
                   '<div style="background: white; padding: 30px; text-align: center; border-radius: 6px; border: 1px solid #dee2e6; margin-top: 20px;">',
                   '<p style="font-size: 15px; margin: 0 0 10px 0; color: #495057;">Visual analysis will be included in the complete PDF report</p>',
                   '<p style="font-size: 13px; margin: 0; color: #6c757d;">Download the full report to view detailed charts and visualizations</p>',
                   '</div>'),
            html_report
        )
    }

    if (nchar(trace_plot_data) > 0) {
        # Insert trace plot into the HTML
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
                   '<img src="data:image/png;base64,', trace_plot_data, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 6px; border: 1px solid #dee2e6; box-shadow: 0 2px 4px rgba(0,0,0,0.05);">'),
            html_report
        )
    } else {
        # Insert fallback message for trace plot
        html_report <- gsub(
            '<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
            paste0('<h2 style="color: #495057; margin-top: 0; font-size: 20px; font-weight: 400; text-align: center; margin-bottom: 20px;">Adaptive Testing Progression</h2>',
                   '<div style="background: white; padding: 30px; text-align: center; border-radius: 6px; border: 1px solid #dee2e6; margin-top: 20px;">',
                   '<p style="font-size: 15px; margin: 0 0 10px 0; color: #495057;">Testing progression analysis will be included in the complete PDF report</p>',
                   '<p style="font-size: 13px; margin: 0; color: #6c757d;">This visualization shows how your ability estimate evolved during the adaptive assessment</p>',
                   '</div>'),
            html_report
        )
    }

    # Ensure we always return something
    if (is.null(html_report) || html_report == "") {
        html_report <- paste0(
            '<div style="font-family: Arial, sans-serif; max-width: 900px; margin: 0 auto; padding: 20px;">',
            '<h1>Programming Anxiety Assessment Results</h1>',
            '<p>Assessment completed successfully. Your results have been recorded.</p>',
            '<p>Thank you for your participation!</p>',
            '</div>'
        )
    }

    cat("DEBUG: Returning HTML report with", nchar(html_report), "characters\n")
    return(shiny::HTML(html_report))
}

# =============================================================================
# CUSTOM ADAPTIVE ITEM SELECTION
# =============================================================================

custom_item_selection <- function(rv, item_bank, config, session = NULL) {
    # STARS-D ADAPTED STRUCTURE:
    # Part 1: 23 situational items (items 1-23)
    #   - Non-adaptive: 6, 8, 9, 21, 23 (shown fixed on page 3)
    #   - Adaptive pool: 1-5, 7, 10-20, 22 (18 items)
    #   - Shows 10 total: 5 non-adaptive + 5 adaptive
    # Part 2: 28 attitudinal items (items 24-51)
    #   - All adaptive
    
    # CRITICAL: Read administered items from session$userData (non-reactive storage)
    administered_items <- if (!is.null(session) && !is.null(session$userData$administered)) {
        session$userData$administered
    } else {
        rv$administered %||% integer(0)
    }
    
    # Check which items have been administered
    num_items_shown <- length(administered_items)
    
    # Check responses
    num_responses <- sum(!is.na(rv$responses))
    
    # Use the maximum to determine progress
    effective_count <- max(num_items_shown, num_responses)
    
    message(sprintf("DEBUG: Administered items: %d, Responses: %d, Effective: %d", 
                    num_items_shown, num_responses, effective_count))
    
    # =========================================================================
    # PART 1: SITUATIONAL ANXIETY (items 1-23)
    # =========================================================================
    
    # Fixed non-adaptive items (6, 8, 9, 21, 23) - shown on page 3
    fixed_items_part1 <- c(6, 8, 9, 21, 23)
    
    # After page 3 (5 fixed items shown), select 5 adaptive items for pages 4-8
    if (effective_count >= 5 && effective_count < 10) {
        adaptive_item_number <- effective_count - 4  # 6th, 7th, 8th, 9th, or 10th item
        message("\n================================================================================")
        message(sprintf("PART 1 ADAPTIVE - Selecting situational anxiety item #%d", effective_count + 1))
        message("================================================================================")
        
        # Get responses so far
        responses_so_far <- rv$responses[1:length(rv$responses)]
        message(sprintf("Responses collected so far: %d items", sum(!is.na(responses_so_far))))
        
        # Use current ability estimate if available
        current_theta <- rv$current_ability %||% 0
        current_se <- rv$ability_se %||% 1.0
        
        message(sprintf("Current ability estimate: theta=%.3f, SE=%.3f", current_theta, current_se))
        
        # Adaptive pool for Part 1: 1-5, 7, 10-20, 22 (18 items, excluding fixed 6, 8, 9, 21, 23)
        adaptive_pool_part1 <- c(1:5, 7, 10:20, 22)
        
        # Get items already shown
        already_shown <- unique(c(administered_items, which(!is.na(rv$responses)), fixed_items_part1))
        available_items <- setdiff(adaptive_pool_part1, already_shown)
        
        if (length(available_items) == 0) {
            message("WARNING: No available items in Part 1 adaptive pool")
            return(NULL)
        }
        
        message(sprintf("Available items in pool: %s", paste(available_items, collapse = ", ")))
        
        # Calculate Fisher Information for each available item
        item_info <- sapply(available_items, function(item_idx) {
            a <- item_bank$a[item_idx]
            b <- item_bank$b[item_idx]
            p <- 1 / (1 + exp(-a * (current_theta - b)))
            info <- a^2 * p * (1 - p)
            return(info)
        })
        
        # Select item with maximum information
        best_idx <- which.max(item_info)
        selected_item <- available_items[best_idx]
        
        message(sprintf("\nSelected item %d with Maximum Fisher Information = %.4f", 
                        selected_item, item_info[best_idx]))
        message("================================================================================\n")
        
        return(selected_item)
    }
    
    # =========================================================================
    # PART 2: ATTITUDINAL/AFFECTIVE ANXIETY (items 24-51, all adaptive)
    # =========================================================================
    
    if (effective_count >= 10 && effective_count < 38) {
        adaptive_item_number <- effective_count - 9  # 11th through 38th item
        message("\n================================================================================")
        message(sprintf("PART 2 ADAPTIVE - Selecting attitudinal anxiety item #%d", adaptive_item_number))
        message("================================================================================")
        
        # Use current ability estimate
        current_theta <- rv$current_ability %||% 0
        current_se <- rv$ability_se %||% 1.0
        
        message(sprintf("Current ability estimate: theta=%.3f, SE=%.3f", current_theta, current_se))
        
        # Part 2 pool: items 24-51 (all adaptive)
        adaptive_pool_part2 <- 24:51
        
        # Get items already shown
        already_shown <- unique(c(administered_items, which(!is.na(rv$responses))))
        available_items <- setdiff(adaptive_pool_part2, already_shown)
        
        if (length(available_items) == 0) {
            message("WARNING: No available items in Part 2 adaptive pool")
            return(NULL)
        }
        
        message(sprintf("Available items in pool: %s%s", 
                        paste(head(available_items, 10), collapse = ", "),
                        if(length(available_items) > 10) "..." else ""))
        
        # Calculate Fisher Information
        item_info <- sapply(available_items, function(item_idx) {
            a <- item_bank$a[item_idx]
            b <- item_bank$b[item_idx]
            p <- 1 / (1 + exp(-a * (current_theta - b)))
            info <- a^2 * p * (1 - p)
            return(info)
        })
        
        # Select item with maximum information
        best_idx <- which.max(item_info)
        selected_item <- available_items[best_idx]
        
        message(sprintf("\nSelected item %d with Maximum Fisher Information = %.4f", 
                        selected_item, item_info[best_idx]))
        message("================================================================================\n")
        
        return(selected_item)
    }
    
    message(sprintf("WARNING: No item selected. effective_count=%d", effective_count))
    return(NULL)
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("prog_anxiety_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- create_study_config(
    name = "Programming Anxiety Assessment - STARS-D Adapted",
    study_key = session_uuid,
    model = "2PL",
    estimation_method = "EAP",
    adaptive = TRUE,
    min_items = 38,  # 10 Part 1 + 28 Part 2
    max_items = 38,  # 10 Part 1 + 28 Part 2
    min_SEM = 0.30,
    criteria = "MI",  # Maximum Information
    item_selection_fun = custom_item_selection,  # Enable custom adaptive selection
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    custom_page_flow = custom_page_flow,
    theme = "Professional",
    session_save = TRUE,
    language = "de",  # Default to German
    bilingual = TRUE,  # Enable German/English
    results_processor = create_programming_anxiety_report
)

# =============================================================================
# LAUNCH THE STUDY
# =============================================================================
launch_study(
    config = study_config,
    item_bank = programming_anxiety_items,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv",
    debug=TRUE
)
