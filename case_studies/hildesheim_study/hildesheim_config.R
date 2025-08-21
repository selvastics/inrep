# HILDESHEIM STUDY - CONFIGURATION MODULE
# Item bank and demographic configurations

# Create item dataframe helper
create_item_dataframe <- function(items_list) {
  data.frame(
    id = sapply(items_list, `[[`, "id"),
    Question = sapply(items_list, `[[`, "content"),
    subscale = sapply(items_list, `[[`, "subscale"),
    reverse_coded = sapply(items_list, `[[`, "reverse_coded"),
    ResponseCategories = "1,2,3,4,5",
    b = NA,
    a = 1,
    stringsAsFactors = FALSE
  )
}

# Teil 1: BFI-2 Items (Persönlichkeit)
bfi_items <- list(
  list(id="BFE_01", content="Ich gehe aus mir heraus, bin gesellig.", subscale="Extraversion", reverse_coded=FALSE),
  list(id="BFV_01", content="Ich bin einfühlsam, warmherzig.", subscale="Agreeableness", reverse_coded=FALSE),
  list(id="BFG_01", content="Ich bin eher unordentlich.", subscale="Conscientiousness", reverse_coded=TRUE),
  list(id="BFN_01", content="Ich bleibe auch in stressigen Situationen gelassen.", subscale="Neuroticism", reverse_coded=TRUE),
  list(id="BFO_01", content="Ich bin vielseitig interessiert.", subscale="Openness", reverse_coded=FALSE),
  
  list(id="BFE_02", content="Ich bin eher ruhig.", subscale="Extraversion", reverse_coded=TRUE),
  list(id="BFV_02", content="Ich habe mit anderen wenig Mitgefühl.", subscale="Agreeableness", reverse_coded=TRUE),
  list(id="BFG_02", content="Ich bin systematisch, halte meine Sachen in Ordnung.", subscale="Conscientiousness", reverse_coded=FALSE),
  list(id="BFN_02", content="Ich reagiere leicht angespannt.", subscale="Neuroticism", reverse_coded=FALSE),
  list(id="BFO_02", content="Ich meide philosophische Diskussionen.", subscale="Openness", reverse_coded=TRUE),
  
  list(id="BFE_03", content="Ich bin eher schüchtern.", subscale="Extraversion", reverse_coded=TRUE),
  list(id="BFV_03", content="Ich bin hilfsbereit und selbstlos.", subscale="Agreeableness", reverse_coded=FALSE),
  list(id="BFG_03", content="Ich mag es sauber und aufgeräumt.", subscale="Conscientiousness", reverse_coded=FALSE),
  list(id="BFN_03", content="Ich mache mir oft Sorgen.", subscale="Neuroticism", reverse_coded=FALSE),
  list(id="BFO_03", content="Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.", subscale="Openness", reverse_coded=FALSE),
  
  list(id="BFE_04", content="Ich bin gesprächig.", subscale="Extraversion", reverse_coded=FALSE),
  list(id="BFV_04", content="Andere sind mir eher gleichgültig, egal.", subscale="Agreeableness", reverse_coded=TRUE),
  list(id="BFG_04", content="Ich bin eher der chaotische Typ, mache selten sauber.", subscale="Conscientiousness", reverse_coded=TRUE),
  list(id="BFN_04", content="Ich werde selten nervös und unsicher.", subscale="Neuroticism", reverse_coded=TRUE),
  list(id="BFO_04", content="Mich interessieren abstrakte Überlegungen wenig.", subscale="Openness", reverse_coded=TRUE)
)

# Teil 2: PSQ Items (Stress)
psq_items <- list(
  list(id="PSQ_02", content="Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_04", content="Ich habe zuviel zu tun.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_16", content="Ich fühle mich gehetzt.", subscale="Stress", reverse_coded=FALSE),
  list(id="PSQ_29", content="Ich habe genug Zeit für mich.", subscale="Stress", reverse_coded=TRUE),
  list(id="PSQ_30", content="Ich fühle mich unter Termindruck.", subscale="Stress", reverse_coded=FALSE)
)

# Teil 3: MWS Items (Studierfähigkeiten) + Statistics
mws_items <- list(
  list(id="MWS_1_KK", content="mit dem sozialen Klima im Studiengang zurechtzukommen (z.B. Konkurrenz aushalten)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_10_KK", content="Teamarbeit zu organisieren (z.B. Lerngruppen finden)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_17_KK", content="Kontakte zu Mitstudierenden zu knüpfen (z.B. für Lerngruppen, Freizeit)", subscale="StudySkills", reverse_coded=FALSE),
  list(id="MWS_21_KK", content="im Team zusammen zu arbeiten (z.B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)", subscale="StudySkills", reverse_coded=FALSE)
)

statistics_items <- list(
  list(id="Statistik_gutfolgen", content="Bislang konnte ich den Inhalten der Statistikveranstaltungen gut folgen.", subscale="Statistics", reverse_coded=FALSE),
  list(id="Statistik_selbstwirksam", content="Ich bin in der Lage, Statistik zu erlernen.", subscale="Statistics", reverse_coded=FALSE)
)

# Combine all items
all_items <- rbind(
  create_item_dataframe(bfi_items),
  create_item_dataframe(psq_items),
  create_item_dataframe(mws_items),
  create_item_dataframe(statistics_items)
)

# Demographic configurations
demographic_configs <- list(
  Einverständnis = list(
    question = "Ich bin mit der Teilnahme an der Befragung einverstanden",
    options = c("Ich bin mit der Teilnahme einverstanden" = "ja"),
    required = TRUE
  ),
  
  Alter_VPN = list(
    question = "Wie alt sind Sie?\nBitte geben Sie Ihr Alter in Jahren an.",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", "22"="22", 
                "23"="23", "24"="24", "25"="25", "26"="26", "27"="27", "28"="28", 
                "29"="29", "30"="30", "älter als 30"="31+"),
    required = TRUE
  ),
  
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    required = TRUE
  ),
  
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich"="1", "männlich"="2", "divers"="3"),
    required = TRUE
  ),
  
  Wohnstatus = list(
    question = "Wie wohnen Sie?",
    options = c("Bei meinen Eltern/Elternteil"="1", "In einer WG/WG in einem Wohnheim"="2",
                "Alleine/in abgeschlossener Wohneinheit in einem Wohnheim"="3",
                "Mit meinem/r Partner*In (mit oder ohne Kinder)"="4", "Anders:"="6"),
    required = TRUE
  ),
  
  Wohn_Zusatz = list(question = "Falls 'Anders', bitte spezifizieren:", options = NULL, required = FALSE),
  
  Haustier = list(
    question = "Welches Haustier würden Sie gerne halten?",
    options = c("Hund"="1", "Katze"="2", "Fische"="3", "Vogel"="4", "Nager"="5", 
                "Reptil"="6", "Ich möchte kein Haustier."="7", "Sonstiges:"="8"),
    required = TRUE
  ),
  
  Haustier_Zusatz = list(question = "Falls 'Sonstiges', bitte spezifizieren:", options = NULL, required = FALSE),
  
  Rauchen = list(
    question = "Rauchen Sie regelmäßig Zigaretten, Vapes oder Shisha?",
    options = c("Ja"="1", "Nein"="2"),
    required = TRUE
  ),
  
  Ernährung = list(
    question = "Welchem Ernährungstyp ordnen Sie sich am ehesten zu?",
    options = c("Vegan"="1", "Vegetarisch"="2", "Pescetarisch"="7",
                "Flexitarisch"="4", "Omnivor (alles)"="5", "Andere:"="6"),
    required = TRUE
  ),
  
  Ernährung_Zusatz = list(question = "Falls 'Andere', bitte spezifizieren:", options = NULL, required = FALSE),
  
  Note_Englisch = list(
    question = "Was war Ihre letzte Schulnote im Fach Englisch?",
    options = c("sehr gut (15-13 Punkte)"="1", "gut (12-10 Punkte)"="2",
                "befriedigend (9-7 Punkte)"="3", "ausreichend (6-4 Punkte)"="4",
                "mangelhaft (3-0 Punkte)"="5"),
    required = TRUE
  ),
  
  Note_Mathe = list(
    question = "Was war Ihre letzte Schulnote im Fach Mathematik?",
    options = c("sehr gut (15-13 Punkte)"="1", "gut (12-10 Punkte)"="2",
                "befriedigend (9-7 Punkte)"="3", "ausreichend (6-4 Punkte)"="4",
                "mangelhaft (3-0 Punkte)"="5"),
    required = TRUE
  ),
  
  Vor_Nachbereitung = list(
    question = "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?",
    options = c("0 Stunden"="1", "maximal eine Stunde"="2",
                "mehr als eine, aber weniger als 2 Stunden"="3",
                "mehr als zwei, aber weniger als 3 Stunden"="4",
                "mehr als drei, aber weniger als 4 Stunden"="5",
                "mehr als 4 Stunden"="6"),
    required = TRUE
  ),
  
  Zufrieden_Hi_5st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
    options = c("gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "sehr zufrieden"="5"),
    required = TRUE
  ),
  
  Zufrieden_Hi_7st = list(
    question = "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim?",
    options = c("gar nicht zufrieden"="1", "2"="2", "3"="3", "4"="4", "5"="5", "6"="6", "sehr zufrieden"="7"),
    required = TRUE
  ),
  
  Persönlicher_Code = list(
    question = paste0(
      "Zum Ende des Semesters soll es eine zweite Befragung geben. ",
      "Damit die Befragung anonym bleibt, wir die Fragebögen aber trotzdem ",
      "einander zuordnen können, erstellen Sie bitte einen persönlichen Code.\n\n",
      "Ihr Code ist folgendermaßen aufgebaut:\n",
      "1. Der erste Buchstabe Ihres Geburtsorts (z.B. B für Berlin)\n",
      "2. Der erste Buchstabe des Rufnamens Ihrer Mutter (z.B. E für Eva)\n",
      "3. Der Tag Ihres Geburtsdatums (z.B. 07 für 07.10.1986)\n",
      "4. Die letzten zwei Ziffern Ihrer Matrikelnummer\n\n",
      "Für die Beispiele würde der Code also BE0751 lauten.\n\n",
      "Wie lautet Ihr Code?"
    ),
    options = NULL,
    required = TRUE
  )
)

# Input types
input_types <- list(
  Einverständnis = "checkbox",
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio",
  Wohnstatus = "radio",
  Wohn_Zusatz = "text",
  Haustier = "radio",
  Haustier_Zusatz = "text",
  Rauchen = "radio",
  Ernährung = "radio",
  Ernährung_Zusatz = "text",
  Note_Englisch = "radio",
  Note_Mathe = "radio",
  Vor_Nachbereitung = "radio",
  Zufrieden_Hi_5st = "radio",
  Zufrieden_Hi_7st = "radio",
  Persönlicher_Code = "text"
)