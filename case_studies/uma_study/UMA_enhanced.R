# =============================================================================
# UMA STUDY - ENHANCED VERSION WITH HILFO LOGIC
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
# BILINGUAL ITEM BANK - GERMAN AND ENGLISH
# =============================================================================
all_items_de <- data.frame(
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
    "…eine langfristige persönliche Lebensperspektive entwickeln konnten.",
    "…umsetzbare Ideen für erste Schritte nach dem Auszug haben.",
    "…zugängliche Ansprechstellen für mögliche Unterstützung kennengelernt haben.",
    "…Problemlösefähigkeiten verbessern konnten.",
    "Ich habe das Gefühl, dass ich die jungen Männer in den ersten Monaten nach dem Auszug gut begleiten kann.",
    "Ich habe das Gefühl, dass ich die jungen Männer im Stationären Wohnen ausreichend helfen kann.",
    "Ich habe das Gefühl, dass ich positiven Einfluss auf die Entwicklung der langfristigen persönlichen Lebensperspektive der UMA nehmen kann."
  ),
  Question_EN = c(
    # Section 1 (Items 1-10)
    "I can estimate how much time I should plan for a counseling session.",
    "I can estimate how often counseling sessions are useful.",
    "I have a clear idea of which spatial conditions are suitable for counseling.",
    "I can estimate what influences my non-verbal communication (e.g., facial expressions, gestures) can have on counseling sessions.",
    "I have an overview of how I can influence factors for successful counseling.",
    "I am aware of how exchange with colleagues helps me in preparing counseling sessions.",
    "I am aware of how exchange with colleagues helps me in reflecting on counseling sessions.",
    "I am aware of how previous experiences of the young men can influence counseling sessions.",
    "I am aware of how my own stress level can influence counseling sessions.",
    "I am aware of how cultural & linguistic backgrounds can shape interactions.",
    
    # Section 2 (Items 11-20)
    "I have enough time to conduct all counseling sessions that I consider useful.",
    "I have suitable spatial conditions for counseling sessions available.",
    "I have the opportunity to exchange with colleagues for preparing counseling sessions when needed.",
    "I have the opportunity to reflect on my conducted counseling sessions with colleagues when needed.",
    "I have seen many positive examples of successful counseling sessions from my colleagues.",
    "I pay attention to how my non-verbal communication (e.g., facial expressions, gestures) works in counseling sessions.",
    "I pay attention to adapting my choice of words sensitively to my clients.",
    "I can influence the atmosphere through the design of the conversation setting.",
    "I can influence the quality of counseling through my preparation (e.g., materials, time planning).",
    "I can always use appropriate methods in counseling sessions.",
    
    # Section 3 (Items 21-30)
    "I am aware of how successful counseling is an interplay of influenceable and non-influenceable factors.",
    "I feel that I can realistically assess my influence.",
    "I accept things that I cannot influence.",
    "…were able to develop a long-term personal life perspective.",
    "…have implementable ideas for first steps after moving out.",
    "…have learned about accessible contact points for possible support.",
    "…were able to improve problem-solving skills.",
    "I feel that I can accompany the young men well in the first months after moving out.",
    "I feel that I can adequately help the young men in residential care.",
    "I feel that I can positively influence the development of the long-term personal life perspective of UMA."
  ),
  # 7-point scale options
  Option1 = "stimme überhaupt nicht zu",
  Option2 = "stimme nicht zu", 
  Option3 = "stimme eher nicht zu",
  Option4 = "weder noch",
  Option5 = "stimme eher zu",
  Option6 = "stimme zu",
  Option7 = "stimme voll und ganz zu",
  stringsAsFactors = FALSE
)

# Set default item bank
all_items <- all_items_de

# =============================================================================
# BILINGUAL DEMOGRAPHICS CONFIGURATION
# =============================================================================
demographic_configs <- list(
  Teilnahme_Code = list(
    question = "Bitte geben Sie Ihren persönlichen Code ein:",
    question_en = "Please enter your personal code:",
    type = "text",
    required = TRUE,
    validation_message = "Bitte vervollständigen Sie die folgenden Angaben:\nBitte beantworten Sie alle Fragen auf dieser Seite.",
    validation_message_en = "Please complete the following information:\nPlease answer all questions on this page."
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
# ENHANCED CUSTOM PAGE FLOW WITH HILFO LOGIC
# =============================================================================
custom_page_flow <- list(
  # Page 1: Welcome with mandatory consent and language switcher
  list(
    id = "page1",
    type = "custom",
    title = "Willkommen zur UMA Studie",
    title_en = "Welcome to the UMA Study",
    content = paste0(
      '<div style="position: relative; padding: 20px; font-size: 16px; line-height: 1.8;">',
      # Language switcher in top right corner
      '<div style="position: absolute; top: 10px; right: 10px;">',
      '<button type="button" id="lang_switch" class="btn-primary" onclick="window.toggleLanguage()" style="',
      'background: white; color: #2c3e50; border: 2px solid #2c3e50;">',
      '<span id="lang_switch_text">English Version</span></button>',
      '</div>',
      # German content (default)
      '<div id="content_de">',
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
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>Ich bin mit der Teilnahme an der Befragung einverstanden</strong></span>',
      '</label>',
      '<div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e74c3c;">',
      '<p style="margin: 0; font-size: 14px; color: #666;">',
      '<strong>Hinweis:</strong> Die Teilnahme ist nur möglich, wenn Sie der Einverständniserklärung zustimmen.</p>',
      '</div>',
      '</div>',
      '</div>',
      # English content (hidden by default)
      '<div id="content_en" style="display: none;">',
      '<h2 style="color: #2c3e50;">Welcome to the Survey on Counseling<br>Unaccompanied Minor Refugees (UMA)<br>at Akademie Klausenhof!</h2>',
      '<p>First, you will find the participation information and declaration of consent here. ',
      'Then follow several statements that you should classify on a scale according to your personal assessment.</p>',
      '<p>The survey aims to collect suggestions for the further development of supervision and possible improvements in counseling work with refugees.</p>',
      '<p style="background: #f0f8ff; padding: 15px; border-left: 4px solid #3498db;">',
      '<strong>The survey will consist of two parts:</strong> In addition to the current survey, another survey will be conducted after the completion of the five supervision units.</p>',
      '<p>Participation in the survey is voluntary. Non-participation would not lead to any disadvantages during supervision.</p>',
      '<p>To maintain anonymity as much as possible, you will not be asked for your name here, but will generate a code at the beginning that only you can identify. The re-entry of the code in the second survey serves so that I as the study creator can recognize how the baseline values have developed after supervision. No inference to a person will be made. All information will of course be treated confidentially.</p>',
      '<p>If you have questions, please contact <a href="mailto:ju002893@fh-muenster.de">ju002893@fh-muenster.de</a></p>',
      '<hr style="margin: 30px 0; border: 1px solid #ddd;">',
      '<div style="background: #f8f9fa; padding: 20px; border-radius: 8px; margin-bottom: 20px;">',
      '<h3 style="color: #2c3e50; margin-bottom: 15px;">Declaration of Consent</h3>',
      '<label style="display: flex; align-items: center; cursor: pointer; font-size: 16px;">',
      '<input type="checkbox" id="consent_check_en" style="margin-right: 10px; width: 20px; height: 20px;" required>',
      '<span><strong>I agree to participate in the survey</strong></span>',
      '</label>',
      '<div style="margin-top: 15px; padding: 10px; background: #fff3f4; border-left: 4px solid #e74c3c;">',
      '<p style="margin: 0; font-size: 14px; color: #666;">',
      '<strong>Note:</strong> Participation is only possible if you agree to the declaration of consent.</p>',
      '</div>',
      '</div>',
      '</div>',
      '</div>',
      # JavaScript for checkbox syncing and language toggle
      '<script>
// Sync consent checkboxes when they change
document.addEventListener("DOMContentLoaded", function() {
  var deCheck = document.getElementById("consent_check");
  var enCheck = document.getElementById("consent_check_en");
  
  if (deCheck && enCheck) {
    deCheck.addEventListener("change", function() {
      enCheck.checked = this.checked;
    });
    
    enCheck.addEventListener("change", function() {
      deCheck.checked = this.checked;
    });
  }
});
</script>'
    )
  ),
  
  # Page 2: Personal Code (separate page before items)
  list(
    id = "page2",
    type = "custom",
    title = "Persönlicher Code",
    title_en = "Personal Code",
    content = paste0(
      '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">',
      '<h2 style="color: #2c3e50; text-align: center; margin-bottom: 25px;">',
      '<span data-lang-de="Persönlicher Code" data-lang-en="Personal Code">Persönlicher Code</span></h2>',
      '<p style="text-align: center; margin-bottom: 30px; font-size: 18px;">',
      '<span data-lang-de="Bitte erstellen Sie einen persönlichen Code:" data-lang-en="Please create a personal code:">',
      'Bitte erstellen Sie einen persönlichen Code:</span></p>',
      '<div style="background: #f0f8ff; padding: 20px; border-left: 4px solid #3498db; margin: 20px 0;">',
      '<p style="margin: 0; font-weight: 500;">',
      '<span data-lang-de="Ersten Buchstaben des Vornamens deiner Mutter + Ersten Buchstaben des Vornamens deines Vaters + Geburtsmonat" data-lang-en="First letter of your mother\'s first name + First letter of your father\'s first name + Birth month">',
      'Ersten Buchstaben des Vornamens deiner Mutter + Ersten Buchstaben des Vornamens deines Vaters + Geburtsmonat</span></p>',
      '</div>',
      '<div style="text-align: center; margin: 30px 0;">',
      '<input type="text" id="personal_code" placeholder="z.B. KY09" style="',
      'padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; ',
      'text-align: center; width: 200px; text-transform: uppercase;" required>',
      '</div>',
      '<div style="text-align: center; color: #666; font-size: 14px;">',
      '<span data-lang-de="Beispiel: Karla (K) + Yusuf (Y) + September (09) = KY09" data-lang-en="Example: Karla (K) + Yusuf (Y) + September (09) = KY09">',
      'Beispiel: Karla (K) + Yusuf (Y) + September (09) = KY09</span></div>',
      '</div>',
      '<script>
      document.addEventListener("DOMContentLoaded", function() {
        var input = document.getElementById("personal_code");
        if (input) {
          input.addEventListener("input", function() {
            this.value = this.value.toUpperCase();
          });
          input.addEventListener("blur", function() {
            if (this.value.trim() !== "") {
              Shiny.setInputValue("Teilnahme_Code", this.value.trim(), {priority: "event"});
            }
          });
        }
      });
      </script>'
    )
  ),
  
  # Page 3: Section 1 intro and items 1-5
  list(
    id = "page3",
    type = "items",
    title = "Beratungsgespräche - Teil 1",
    title_en = "Counseling Sessions - Part 1",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der Unbegleiteten Minderjährigen Ausländer (UMA)'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of Unaccompanied Minor Refugees (UMA)'.",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 4: Items 6-10 (Section 1 continued)
  list(
    id = "page4",
    type = "items",
    title = "Beratungsgespräche - Teil 1 (Fortsetzung)",
    title_en = "Counseling Sessions - Part 1 (Continued)",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 5: Section 2 intro and items 11-15
  list(
    id = "page5",
    type = "items",
    title = "Beratungsgespräche - Teil 2",
    title_en = "Counseling Sessions - Part 2",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.",
    item_indices = 11:15,
    scale_type = "likert"
  ),
  
  # Page 6: Items 16-20 (Section 2 continued)
  list(
    id = "page6",
    type = "items",
    title = "Beratungsgespräche - Teil 2 (Fortsetzung)",
    title_en = "Counseling Sessions - Part 2 (Continued)",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.",
    item_indices = 16:20,
    scale_type = "likert"
  ),
  
  # Page 7: Section 3 intro and items 21-23
  list(
    id = "page7",
    type = "items",
    title = "Beratungsgespräche - Teil 3",
    title_en = "Counseling Sessions - Part 3",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.",
    item_indices = 21:23,
    scale_type = "likert"
  ),
  
  # Page 8: Items 24-27 (Special section with stem)
  list(
    id = "page8",
    type = "items",
    title = "Beratungsgespräche - Teil 3 (Fortsetzung)",
    title_en = "Counseling Sessions - Part 3 (Continued)",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.\n\n_Ich habe den Eindruck, dass die jungen Männer durch meine Beratungsarbeit…_",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.\n\n_I have the impression that the young men through my counseling work…_",
    item_indices = 24:27,
    scale_type = "likert"
  ),
  
  # Page 9: Items 28-30 (Final items)
  list(
    id = "page9",
    type = "items",
    title = "Beratungsgespräche - Abschluss",
    title_en = "Counseling Sessions - Conclusion",
    instructions = "Folgende Aussagen beziehen sich auf Beratungsgespräche zum Thema 'Langfristige persönliche Lebensperspektive der UMA'.",
    instructions_en = "The following statements refer to counseling sessions on the topic 'Long-term personal life perspective of UMA'.",
    item_indices = 28:30,
    scale_type = "likert"
  ),
  
  # Page 10: Results with auto-close
  list(
    id = "page10",
    type = "results",
    title = "Vielen Dank!",
    title_en = "Thank You!"
  )
)