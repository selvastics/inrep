var currentLang = "de";

// COMPLETE TRANSLATION DICTIONARY - EVERYTHING MUST BE TRANSLATED!
var translations = {
  // Welcome page
  "Willkommen zur HilFo Studie": "Welcome to the HilFo Study",
  "Liebe Studierende,": "Dear Students,",
  "Liebe Studierende": "Dear Students",
  
  // Navigation Buttons - ALL OF THEM
  "Weiter": "Next",
  "Zurück": "Back",
  "Absenden": "Submit",
  "Fertig": "Finish",
  "Speichern": "Save",
  "Abbrechen": "Cancel",
  "Bitte wählen...": "Please select...",
  "Bitte wählen": "Please select",
  
  // Progress indicators
  "Seite": "Page",
  " von ": " of ",
  "von": "of",
  
  // Page titles - ALL OF THEM
  "Soziodemographische Angaben": "Sociodemographic Information",
  "Wohnsituation": "Living Situation",
  "Lebensstil": "Lifestyle",
  "Bildung": "Education",
  "Programmierangst - Teil 1": "Programming Anxiety - Part 1",
  "Programmierangst - Teil 2": "Programming Anxiety - Part 2",
  "Programmierangst": "Programming Anxiety",
  "Persönlichkeit - Teil 1": "Personality - Part 1",
  "Persönlichkeit - Teil 2": "Personality - Part 2",
  "Persönlichkeit - Teil 3": "Personality - Part 3",
  "Persönlichkeit - Teil 4": "Personality - Part 4",
  "Stress": "Stress",
  "Studierfähigkeiten": "Study Skills",
  "Statistik": "Statistics",
  "Studienzufriedenheit": "Study Satisfaction",
  "Ihre Ergebnisse": "Your Results",
  
  // Demographics questions - ALL OF THEM
  "Wie alt sind Sie?": "How old are you?",
  "In welchem Studiengang befinden Sie sich?": "Which study program are you in?",
  "Welches Geschlecht haben Sie?": "What is your gender?",
  "Wie wohnen Sie?": "How do you live?",
  "Falls anders, bitte spezifizieren:": "If other, please specify:",
  "Haben Sie ein Haustier oder möchten Sie eines?": "Do you have a pet or would you like one?",
  "Anderes Haustier:": "Other pet:",
  "Rauchen Sie?": "Do you smoke?",
  "Wie ernähren Sie sich hauptsächlich?": "What is your main diet?",
  "Andere Ernährungsform:": "Other diet:",
  "Welche Note hatten Sie in Englisch im Abiturzeugnis?": "What grade did you have in English in your Abitur certificate?",
  "Welche Note hatten Sie in Mathematik im Abiturzeugnis?": "What grade did you have in Mathematics in your Abitur certificate?",
  
  // Demographics options
  "Bachelor Psychologie": "Bachelor Psychology",
  "Master Psychologie": "Master Psychology",
  "weiblich oder divers": "female or diverse",
  "männlich": "male",
  "Bei meinen Eltern/Elternteil": "With my parents/parent",
  "Ja": "Yes",
  "Nein": "No",
  
  // Validation messages - CRITICAL!
  "Please complete the following:": "Please complete the following:",
  "Bitte beantworten Sie:": "Please answer:",
  "Bitte beantworten Sie: Wie alt sind Sie?": "Please answer: How old are you?",
  
  // Instructions
  "Bitte geben Sie an, inwieweit die folgenden Aussagen auf Sie zutreffen.": "Please indicate to what extent the following statements apply to you.",
  
  // Likert scales
  "Stimme überhaupt nicht zu": "Strongly disagree",
  "Stimme nicht zu": "Disagree",
  "Neutral": "Neutral",
  "Stimme zu": "Agree",
  "Stimme voll zu": "Strongly agree"
};

// Function to translate everything
function translateEverything() {
  console.log("TRANSLATING EVERYTHING TO:", currentLang);
  
  // Translate all text nodes
  var allElements = document.querySelectorAll("*");
  for (var i = 0; i < allElements.length; i++) {
    var el = allElements[i];
    
    // Check text content
    if (el.childNodes && el.childNodes.length > 0) {
      for (var j = 0; j < el.childNodes.length; j++) {
        var node = el.childNodes[j];
        if (node.nodeType === 3) { // Text node
          var text = node.textContent;
          if (text && text.trim()) {
            var newText = text;
            
            if (currentLang === "en") {
              // Translate German to English
              for (var de in translations) {
                if (translations.hasOwnProperty(de)) {
                  if (newText.indexOf(de) !== -1) {
                    newText = newText.replace(new RegExp(de.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g"), translations[de]);
                  }
                }
              }
            } else {
              // Translate English to German
              for (var de in translations) {
                if (translations.hasOwnProperty(de)) {
                  var en = translations[de];
                  if (newText.indexOf(en) !== -1) {
                    newText = newText.replace(new RegExp(en.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"), "g"), de);
                  }
                }
              }
            }
            
            if (newText !== text) {
              node.textContent = newText;
            }
          }
        }
      }
    }
    
    // Also check value attribute
    if (el.value) {
      var val = el.value;
      if (currentLang === "en") {
        for (var de in translations) {
          if (translations.hasOwnProperty(de) && val === de) {
            el.value = translations[de];
            break;
          }
        }
      } else {
        for (var de in translations) {
          if (translations.hasOwnProperty(de) && val === translations[de]) {
            el.value = de;
            break;
          }
        }
      }
    }
  }
  
  // Update button
  var btn = document.getElementById("lang_toggle");
  if (btn) {
    btn.textContent = currentLang === "de" ? "English" : "Deutsch";
  }
}

// Toggle language function
function toggleLanguage() {
  currentLang = currentLang === "de" ? "en" : "de";
  console.log("Language switched to:", currentLang);
  
  // Save preference
  try {
    localStorage.setItem("hilfo_language", currentLang);
    sessionStorage.setItem("hilfo_language", currentLang);
  } catch(e) {}
  
  // Translate everything
  translateEverything();
  
  // Tell Shiny
  if (typeof Shiny !== "undefined") {
    Shiny.setInputValue("study_language", currentLang, {priority: "event"});
  }
}

// Initialize on page load
document.addEventListener("DOMContentLoaded", function() {
  // Check saved language
  try {
    var saved = localStorage.getItem("hilfo_language") || sessionStorage.getItem("hilfo_language");
    if (saved) currentLang = saved;
  } catch(e) {}
  
  // Create language button
  var langBtn = document.createElement("button");
  langBtn.id = "lang_toggle";
  langBtn.textContent = currentLang === "de" ? "English" : "Deutsch";
  langBtn.style.cssText = "position: fixed; top: 10px; right: 10px; z-index: 9999; background: white; border: 2px solid #e8041c; color: #e8041c; padding: 8px 16px; border-radius: 4px; cursor: pointer;";
  langBtn.onclick = toggleLanguage;
  document.body.appendChild(langBtn);
  
  // Apply saved language
  if (currentLang === "en") {
    setTimeout(translateEverything, 100);
  }
  
  // Watch for changes
  var observer = new MutationObserver(function() {
    if (currentLang === "en") {
      clearTimeout(window.updateTimeout);
      window.updateTimeout = setTimeout(translateEverything, 100);
    }
  });
  
  observer.observe(document.body, {
    childList: true,
    subtree: true
  });
  
  // Radio button deselection
  document.addEventListener("click", function(e) {
    if (e.target.type === "radio") {
      if (e.target.dataset.wasChecked === "true") {
        e.target.checked = false;
        e.target.dataset.wasChecked = "false";
        if (typeof Shiny !== "undefined") {
          Shiny.setInputValue(e.target.name, null, {priority: "event"});
        }
      } else {
        var radios = document.querySelectorAll("input[name='" + e.target.name + "']");
        for (var i = 0; i < radios.length; i++) {
          radios[i].dataset.wasChecked = "false";
        }
        e.target.dataset.wasChecked = "true";
      }
    }
  });
});