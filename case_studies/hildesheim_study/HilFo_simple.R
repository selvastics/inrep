# Minimal HilFo study without custom pages
library(inrep)

# Simple item bank
item_bank <- data.frame(
  id = c(
    # Programming Anxiety items (20)
    paste0("PA_", sprintf("%02d", 1:20)),
    # BFI items
    "BFE_01", "BFE_02", "BFE_03", "BFE_04", # Extraversion
    "BFV_01", "BFV_02", "BFV_03", "BFV_04", # Verträglichkeit
    "BFG_01", "BFG_02", "BFG_03", "BFG_04", # Gewissenhaftigkeit
    "BFN_01", "BFN_02", "BFN_03", "BFN_04", # Neurotizismus
    "BFO_01", "BFO_02", "BFO_03", "BFO_04", # Offenheit
    # PSQ items
    "PSQ_02", "PSQ_04", "PSQ_16", "PSQ_29", "PSQ_30",
    # MWS items
    "MWS_1_KK", "MWS_10_KK", "MWS_17_KK", "MWS_21_KK",
    # Statistics items
    "Statistik_gutfolgen", "Statistik_selbstwirksam"
  ),
  Question = c(
    # Programming Anxiety (German)
    "Ich fühle mich unsicher, wenn ich programmieren soll.",
    "Der Gedanke, programmieren zu lernen, macht mich nervös.",
    "Ich habe Angst, beim Programmieren Fehler zu machen.",
    "Ich fühle mich überfordert, wenn ich an Programmieraufgaben denke.",
    "Ich bin besorgt, dass ich nicht gut genug programmieren kann.",
    "Ich vermeide es, neue Programmiersprachen zu nutzen, weil ich Angst habe, Fehler zu machen.",
    "In Gruppencodier-Sitzungen bin ich nervös, dass meine Beiträge nicht geschätzt werden.",
    "Ich habe Sorge, Programmieraufgaben nicht rechtzeitig aufgrund fehlender Fähigkeiten abschließen zu können.",
    "Wenn ich bei einem Programmierproblem nicht weiterkomme, ist es mir peinlich, um Hilfe zu bitten.",
    "Ich fühle mich wohl dabei, meinen Code anderen zu erklären.",
    "Fortgeschrittene Programmierkonzepte (z.B. Rekursion, Multithreading) finde ich einschüchternd.",
    "Ich zweifle oft daran, Programmieren über die Grundlagen hinaus lernen zu können.",
    "Wenn mein Code nicht funktioniert, glaube ich, dass es an meinem mangelnden Talent liegt.",
    "Es macht mich nervös, Code ohne Schritt-für-Schritt-Anleitung zu schreiben.",
    "Ich bin zuversichtlich, bestehenden Code zu verändern, um neue Funktionen hinzuzufügen.",
    "Ich fühle mich manchmal ängstlich, noch bevor ich mit dem Programmieren beginne.",
    "Allein der Gedanke an das Debuggen macht mich angespannt, selbst bei kleineren Fehlern.",
    "Ich mache mir Sorgen, für die Qualität meines Codes beurteilt zu werden.",
    "Wenn mir jemand beim Programmieren zuschaut, werde ich nervös und mache Fehler.",
    "Schon der Gedanke an bevorstehende Programmieraufgaben setzt mich unter Stress.",
    
    # BFI Extraversion
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
  stringsAsFactors = FALSE
)

# Simple demographics
demographic_configs <- list(
  Alter_VPN = list(
    question = "Wie alt sind Sie?",
    options = c("17"="17", "18"="18", "19"="19", "20"="20", "21"="21", 
                "22"="22", "23"="23", "24"="24", "25"="25", "26"="26", 
                "27"="27", "28"="28", "29"="29", "30"="30", "älter als 30"="0"),
    required = FALSE
  ),
  Studiengang = list(
    question = "In welchem Studiengang befinden Sie sich?",
    options = c("Bachelor Psychologie"="1", "Master Psychologie"="2"),
    required = FALSE
  ),
  Geschlecht = list(
    question = "Welches Geschlecht haben Sie?",
    options = c("weiblich oder divers"="1", "männlich"="2"),
    required = FALSE
  )
)

input_types <- list(
  Alter_VPN = "select",
  Studiengang = "radio",
  Geschlecht = "radio"
)

# Simple page flow - NO CUSTOM PAGES
custom_page_flow <- list(
  # Page 1: Demographics
  list(
    id = "page1",
    type = "demographics",
    title = "Soziodemographische Angaben",
    demographics = c("Alter_VPN", "Studiengang", "Geschlecht")
  ),
  
  # Page 2: Programming Anxiety items 1-5
  list(
    id = "page2",
    type = "items",
    title = "Programmierangst - Teil 1",
    item_indices = 1:5,
    scale_type = "likert"
  ),
  
  # Page 3: Programming Anxiety items 6-10
  list(
    id = "page3",
    type = "items",
    title = "Programmierangst - Teil 2",
    item_indices = 6:10,
    scale_type = "likert"
  ),
  
  # Page 4: BFI items 1-10
  list(
    id = "page4",
    type = "items",
    title = "Persönlichkeit - Teil 1",
    item_indices = 21:30,
    scale_type = "likert"
  ),
  
  # Page 5: BFI items 11-20
  list(
    id = "page5",
    type = "items",
    title = "Persönlichkeit - Teil 2",
    item_indices = 31:40,
    scale_type = "likert"
  ),
  
  # Page 6: PSQ Stress
  list(
    id = "page6",
    type = "items",
    title = "Stress",
    item_indices = 41:45,
    scale_type = "likert"
  ),
  
  # Page 7: MWS Study Skills
  list(
    id = "page7",
    type = "items",
    title = "Studierfähigkeiten",
    item_indices = 46:49,
    scale_type = "likert"
  ),
  
  # Page 8: Statistics
  list(
    id = "page8",
    type = "items",
    title = "Statistik",
    item_indices = 50:51,
    scale_type = "likert"
  ),
  
  # Page 9: Results
  list(
    id = "page9",
    type = "results",
    title = "Ihre Ergebnisse"
  )
)

# Simple study config
study_config <- inrep::create_study_config(
  name = "HilFo Studie",
  study_key = "hilfo_test",
  custom_page_flow = custom_page_flow,
  demographics = names(demographic_configs),
  demographic_configs = demographic_configs,
  input_types = input_types
)

# Launch
inrep::launch_study(
  config = study_config,
  item_bank = item_bank
)