#  Multilingual Support for inrep Package
#
# Provides complete translations for all UI elements, messages, and content
# Supports: English (en), German (de), Spanish (es), French (fr)

# Complete language dictionary for all UI elements (internal use only)
LANGUAGE_DICTIONARY <- list(
  en = list(
    # Basic UI elements
    demo_title = "Demographic Information",
    provide_optional_demographics = "Provide optional demographic information",
    optional_demographics = "Optional demographic information",
    answer_questions_experiences = "Answer questions about your experiences, attitudes, and behaviors",
    complete_interactive_questionnaire = "Complete an interactive questionnaire",
    receive_personalized_feedback = "Receive personalized feedback about your responses",
    response_data_questionnaires = "Response data from questionnaires",
    technical_data = "Technical data (session duration, response times)",
    no_personal_identifiers = "No personal identifiers or contact information",
    during_study_you_will = "During this study, you will:",
    we_may_process_data = "We may process the following categories of data:",
    study_procedures = "Study Procedures",
    categories_of_data = "Categories of Data",
    article_9_gdpr = "Article 9(2)(a) GDPR: Explicit consent for special categories of data (if applicable)",
    article_6_gdpr = "Article 6(1)(a) GDPR: Your explicit consent",
    legitimate_interest = "Legitimate interest: Scientific research purposes",
    objection = "Objection: Object to processing based on legitimate interests",
    rectification = "Rectification: Correct inaccurate data",
    erasure = "Erasure: Request deletion of your data",
    portability = "Portability: Receive your data in a portable format",
    restriction = "Restriction: Limit processing of your data",
    access = "Access: Request information about your data",
    complaint = "Complaint: Lodge a complaint with supervisory authorities",
    welcome_text = "Please provide your demographic details to begin the assessment.",
    start_button = "Start Assessment",
    submit_button = "Submit",
    continue_button = "Continue",
    begin_button = "Begin Assessment",
    restart_button = "Restart",
    save_button = "Download Report",
    select_option = "Select...",
    
    # Results section
    results_title = "Assessment Results",
    proficiency = "Trait Score",
    precision = "Measurement Precision",
    items_administered = "Items Completed",
    recommendations = "Recommendations",
    assessment_complete = "Assessment Complete",
    analysis_completed = "Advanced psychometric analysis completed with domain-specific reporting",
    return_dashboard = "Return to Dashboard",
    view_backend = "View Analysis Backend",
    
    # Feedback messages
    feedback_correct = "Correct",
    feedback_incorrect = "Incorrect",
    timeout_message = "Session timed out. Please restart.",
    demo_error = "Please complete all required fields.",
    age_error = "Please enter a valid age (1-150).",
    
    # Consent section
    consent_title = "Research Study Consent",
    consent_welcome = "Welcome to the Cognitive Assessment Study. Please read the information below and provide your consent to participate.",
    consent_purpose_label = "Purpose:",
    consent_purpose_text = "This study investigates cognitive abilities using standardized assessment items. Your responses will be anonymized and used for research purposes only.",
    consent_privacy_label = "Data Privacy:",
    consent_privacy_text = "Data handling and storage are described in the study's data protection information.",
    consent_voluntary_label = "Voluntary Participation:",
    consent_voluntary_text = "You may withdraw at any time without penalty.",
    consent_checkbox_text = "I have read and understood the information above and consent to participate.",
    
    # Instructions section
    instructions_title = "Instructions",
    instructions_text = "Please read the instructions carefully before starting the assessment.",
    instructions_read_carefully = "Please read the instructions carefully before starting the assessment.",
    instructions_cognitive_tasks = "You will complete a series of cognitive tasks assessing memory, speed, and executive function.",
    instructions_answer_accurately = "Answer each question as accurately and quickly as possible.",
    instructions_progress_display = "Your progress will be displayed at the top of the screen.",
    instructions_no_right_wrong = "There are no right or wrong answers; please try your best.",
    instructions_click_begin = "Click 'Begin Assessment' when you are ready.",
    
    # Assessment section
    cognitive_assessment = "Cognitive Assessment",
    live_analysis_active = "Live Analysis Active",
    participant_id = "ID: %s",
    session_time = "12:34",
    question_progress = "Question %d of %d",
    completion_percentage = "%d%% Complete",
    difficulty_load_format = "Difficulty: %s | Load: %s",
    item_number = "Item %d",
    analysis_type_format = "Analysis: %s",
    loading_question = "Loading question...",
    preparing = "Preparing...",
    select_answer = "Select your answer:",
    
    # Demographics
    age_label = "Age",
    gender_label = "Gender",
    education_label = "Education",
    demographics_optional_info = "Please provide some optional information about yourself. All fields are optional and you may skip any questions you prefer not to answer.",
    demographics_provide_info = "Please provide information about %s",
    enter_age = "Enter your age",
    enter_field = "Enter %s",
    enter_details = "Enter details...",
    please_specify = "Please specify:",
    prefer_not_to_answer = "Prefer not to answer",
    please_select = "Please select...",
    gender_female = "Female",
    gender_male = "Male",
    gender_other = "Other",
    gender_prefer_not = "Prefer not to say",
    education_high_school = "High School",
    education_bachelor = "Bachelor's Degree",
    education_master = "Master's Degree",
    education_doctorate = "Doctorate",
    education_other = "Other",
    
    # Welcome section
    welcome_title = "Welcome to the Cognitive Assessment Study",
    welcome_description = "Your participation helps advance cognitive science. All data is confidential and used for academic research only.",
    participate_button = "Participate in Study",
    
    # Study flow headings
    study_overview = "Study Overview",
    what_to_expect = "What to Expect",
    important_notes = "Important Notes",
    research_details = "Research Details",
    risks_and_benefits = "Risks and Benefits",
    confidentiality = "Confidentiality",
    contact_information = "Contact Information",
    consent_to_participate = "Consent to Participate",
    data_use_and_storage = "Data Use and Storage",
    right_to_withdraw = "Right to Withdraw",
    data_controller = "Data Controller",
    legal_basis_for_processing = "Legal Basis for Processing",
    data_retention = "Data Retention",
    your_rights_under_gdpr = "Your Rights under GDPR",
    data_sharing = "Data Sharing",
    contact_for_data_protection = "Contact for Data Protection",
    study_purpose = "Study Purpose",
    research_methodology = "Research Methodology",
    research_implications = "Research Implications",
    next_steps = "Next Steps",
    additional_resources = "Additional Resources",
    support_and_concerns = "Support and Concerns",
    
    # Study flow labels
    voluntary_participation = "Voluntary Participation",
    data_protection = "Data Protection",
    technical_requirements = "Technical Requirements",
    principal_investigator = "Principal Investigator",
    institution = "Institution",
    study_purpose_label = "Study Purpose",
    publication = "Publication",
    risks = "Risks",
    benefits = "Benefits",
    research_team = "Research Team",
    ethics_committee = "Ethics Committee",
    address = "Address",
    email = "Email",
    data_protection_officer = "Data Protection Officer",
    supervisory_authority = "Supervisory Authority",
    
    # Hildesheim Study Specific Labels
    hildesheim_welcome_title = "Welcome to the HilFo Study",
    hildesheim_dear_students = "Dear Students,",
    hildesheim_intro_text = "In the statistical methods exercises, we want to work with illustrative data that comes from you. Therefore, we want to learn a few things about you.",
    hildesheim_survey_coverage = "Since we want to enable various analyses, the questionnaire covers different topic areas that are partially independent of each other.",
    hildesheim_anonymity = "Your information is of course anonymous; no personal evaluation of the data will take place.",
    hildesheim_data_usage = "The data is generated by first-semester psychology bachelor students and used in this year group, possibly also in later year groups.",
    hildesheim_statements = "In the following, statements will be presented to you. We ask you to indicate the extent to which you agree with them.",
    hildesheim_no_right_wrong = "There are no wrong or right answers. Please answer the questions as they best match your opinion.",
    hildesheim_duration = "The survey takes about 10-15 minutes.",
    hildesheim_consent_title = "Consent Declaration",
    hildesheim_consent_text = "I agree to participate in the survey",
    hildesheim_language_switch = "Deutsche Version"
  ),
  
  de = list(
    # Basic UI elements
    demo_title = "Demografische Informationen",
    provide_optional_demographics = "Optionale demografische Informationen bereitstellen",
    optional_demographics = "Optionale demografische Informationen",
    answer_questions_experiences = "Beantworten Sie Fragen zu Ihren Erfahrungen, Einstellungen und Verhaltensweisen",
    complete_interactive_questionnaire = "Vervollst\u00E4ndigen Sie einen interaktiven Fragebogen",
    receive_personalized_feedback = "Erhalten Sie personalisiertes Feedback zu Ihren Antworten",
    response_data_questionnaires = "Antwortdaten aus Frageb\u00F6gen",
    technical_data = "Technische Daten (Sitzungsdauer, Antwortzeiten)",
    no_personal_identifiers = "Keine pers\u00F6nlichen Identifikatoren oder Kontaktinformationen",
    during_study_you_will = "W\u00E4hrend dieser Studie werden Sie:",
    we_may_process_data = "Wir k\u00F6nnen die folgenden Datenkategorien verarbeiten:",
    study_procedures = "Studienverfahren",
    categories_of_data = "Datenkategorien",
    article_9_gdpr = "Artikel 9(2)(a) DSGVO: Ausdr\u00FCckliche Einwilligung f\u00FCr besondere Datenkategorien (falls zutreffend)",
    article_6_gdpr = "Artikel 6(1)(a) DSGVO: Ihre ausdr\u00FCckliche Einwilligung",
    legitimate_interest = "Berechtigtes Interesse: Wissenschaftliche Forschungszwecke",
    objection = "Widerspruch: Widersprechen Sie der Verarbeitung auf der Grundlage berechtigter Interessen",
    rectification = "Berichtigung: Ungenaue Daten korrigieren",
    erasure = "L\u00F6schung: L\u00F6schung Ihrer Daten beantragen",
    portability = "\u00DCbertragbarkeit: Ihre Daten in einem \u00FCbertragbaren Format erhalten",
    restriction = "Einschr\u00E4nkung: Verarbeitung Ihrer Daten einschr\u00E4nken",
    access = "Zugang: Informationen \u00FCber Ihre Daten anfordern",
    complaint = "Beschwerde: Beschwerde bei Aufsichtsbeh\u00F6rden einlegen",
    welcome_text = "Bitte geben Sie Ihre demografischen Daten ein, um die Bewertung zu beginnen.",
    start_button = "Bewertung beginnen",
    submit_button = "Absenden",
    continue_button = "Weiter",
    begin_button = "Bewertung beginnen",
    restart_button = "Neu starten",
    save_button = "Bericht herunterladen",
    select_option = "Ausw\u00E4hlen...",
    
    # Results section
    results_title = "Bewertungsergebnisse",
    proficiency = "Merkmalswert",
    precision = "Messgenauigkeit",
    items_administered = "Abgeschlossene Elemente",
    recommendations = "Empfehlungen",
    assessment_complete = "Bewertung abgeschlossen",
    analysis_completed = "Psychometrische Analyse abgeschlossen",
    return_dashboard = "Zum Dashboard zur\u00FCckkehren",
    view_backend = "Analyse-Backend anzeigen",
    
    # Feedback messages
    feedback_correct = "Korrekt",
    feedback_incorrect = "Falsch",
    timeout_message = "Sitzung abgelaufen. Bitte neu starten.",
    demo_error = "Bitte f\u00FCllen Sie alle erforderlichen Felder aus.",
    age_error = "Bitte geben Sie ein g\u00FCltiges Alter ein (1-150).",
    
    # Consent section
    consent_title = "Einverst\u00E4ndniserkl\u00E4rung zur Forschungsstudie",
    consent_welcome = "Willkommen zur kognitiven Bewertungsstudie. Bitte lesen Sie die folgenden Informationen und geben Sie Ihre Zustimmung zur Teilnahme.",
    consent_purpose_label = "Zweck:",
    consent_purpose_text = "Diese Studie untersucht kognitive F\u00E4higkeiten mit standardisierten Bewertungselementen. Ihre Antworten werden anonymisiert und nur zu Forschungszwecken verwendet.",
    consent_privacy_label = "Datenschutz:",
    consent_privacy_text = "Die Antworten werden gespeichert und gem\u00E4\u00DF den angegebenen Datenschutzinformationen verarbeitet.",
    consent_voluntary_label = "Freiwillige Teilnahme:",
    consent_voluntary_text = "Sie k\u00F6nnen jederzeit ohne Konsequenzen zur\u00FCcktreten.",
    consent_checkbox_text = "Ich habe die obigen Informationen gelesen und verstanden und stimme der Teilnahme zu.",
    
    # Instructions section
    instructions_title = "Anweisungen",
    instructions_text = "Bitte lesen Sie die Anweisungen sorgf\u00E4ltig durch, bevor Sie mit der Bewertung beginnen.",
    instructions_read_carefully = "Bitte lesen Sie die Anweisungen sorgf\u00E4ltig durch, bevor Sie mit der Bewertung beginnen.",
    instructions_cognitive_tasks = "Sie werden eine Reihe von kognitiven Aufgaben absolvieren, die Ged\u00E4chtnis, Geschwindigkeit und exekutive Funktionen bewerten.",
    instructions_answer_accurately = "Beantworten Sie jede Frage so genau und schnell wie m\u00F6glich.",
    instructions_progress_display = "Ihr Fortschritt wird oben auf dem Bildschirm angezeigt.",
    instructions_no_right_wrong = "Es gibt keine richtigen oder falschen Antworten; versuchen Sie Ihr Bestes.",
    instructions_click_begin = "Klicken Sie auf 'Bewertung beginnen', wenn Sie bereit sind.",
    
    # Assessment section
    cognitive_assessment = "Kognitive Bewertung",
    live_analysis_active = "Live-Analyse aktiv",
    participant_id = "ID: %s",
    session_time = "12:34",
    question_progress = "Frage %d von %d",
    completion_percentage = "%d%% abgeschlossen",
    difficulty_load_format = "Schwierigkeit: %s | Belastung: %s",
    item_number = "Element %d",
    analysis_type_format = "Analyse: %s",
    loading_question = "Frage wird geladen...",
    preparing = "Wird vorbereitet...",
    select_answer = "W\u00E4hlen Sie Ihre Antwort:",
    
    # Demographics
    age_label = "Alter",
    gender_label = "Geschlecht",
    education_label = "Bildung",
    demographics_optional_info = "Bitte geben Sie einige optionale Informationen \u00FCber sich selbst an. Alle Felder sind optional und Sie k\u00F6nnen alle Fragen \u00FCberspringen, die Sie lieber nicht beantworten m\u00F6chten.",
    demographics_provide_info = "Bitte geben Sie Informationen \u00FCber %s an",
    enter_age = "Geben Sie Ihr Alter ein",
    enter_field = "Geben Sie %s ein",
    enter_details = "Details eingeben...",
    please_specify = "Bitte spezifizieren:",
    prefer_not_to_answer = "Lieber nicht beantworten",
    please_select = "Bitte w\u00E4hlen...",
    gender_female = "Weiblich",
    gender_male = "M\u00E4nnlich",
    gender_other = "Andere",
    gender_prefer_not = "M\u00F6chte nicht sagen",
    education_high_school = "Abitur",
    education_bachelor = "Bachelor-Abschluss",
    education_master = "Master-Abschluss",
    education_doctorate = "Promotion",
    education_other = "Andere",
    
    # Welcome section
    welcome_title = "Willkommen zur kognitiven Bewertungsstudie",
    welcome_description = "Ihre Teilnahme hilft dabei, die kognitive Wissenschaft voranzubringen. Die Antworten werden f\u00FCr Forschungszwecke ausgewertet.",
    participate_button = "An der Studie teilnehmen",
    
    # Study flow headings
    study_overview = "Studien\u00FCbersicht",
    what_to_expect = "Was zu erwarten ist",
    important_notes = "Wichtige Hinweise",
    research_details = "Forschungsdetails",
    risks_and_benefits = "Risiken und Vorteile",
    confidentiality = "Vertraulichkeit",
    contact_information = "Kontaktinformationen",
    consent_to_participate = "Zustimmung zur Teilnahme",
    data_use_and_storage = "Datenverwendung und -speicherung",
    right_to_withdraw = "Recht auf R\u00FCckzug",
    data_controller = "Datenverantwortlicher",
    legal_basis_for_processing = "Rechtliche Grundlage f\u00FCr die Verarbeitung",
    data_retention = "Datenaufbewahrung",
    your_rights_under_gdpr = "Ihre Rechte nach DSGVO",
    data_sharing = "Datenweitergabe",
    contact_for_data_protection = "Kontakt f\u00FCr Datenschutz",
    study_purpose = "Studienzweck",
    research_methodology = "Forschungsmethodik",
    research_implications = "Forschungsimplikationen",
    next_steps = "N\u00E4chste Schritte",
    additional_resources = "Zus\u00E4tzliche Ressourcen",
    support_and_concerns = "Unterst\u00FCtzung und Bedenken",
    
    # Study flow labels
    voluntary_participation = "Freiwillige Teilnahme",
    data_protection = "Datenschutz",
    technical_requirements = "Technische Anforderungen",
    principal_investigator = "Hauptuntersucher",
    institution = "Institution",
    study_purpose_label = "Studienzweck",
    publication = "Ver\u00F6ffentlichung",
    risks = "Risiken",
    benefits = "Vorteile",
    research_team = "Forschungsteam",
    ethics_committee = "Ethikkommission",
    address = "Adresse",
    email = "E-Mail",
    data_protection_officer = "Datenschutzbeauftragter",
    supervisory_authority = "Aufsichtsbeh\u00F6rde",
    
         # Hildesheim Study Specific Labels
     hildesheim_welcome_title = "Willkommen zur HilFo Studie",
     hildesheim_dear_students = "Liebe Studierende,",
     hildesheim_intro_text = "In den \u00DCbungen zu den statistischen Verfahren wollen wir mit anschaulichen Daten arbeiten, die von Ihnen selbst stammen. Deswegen wollen wir ein paar Dinge von Ihnen erfahren.",
     hildesheim_survey_coverage = "Da wir verschiedene Auswertungen erm\u00F6glichen wollen, deckt der Fragebogen verschiedene Themenbereiche ab, die voneinander teilweise unabh\u00E4ngig sind.",
     hildesheim_anonymity = "Ihre Angaben sind dabei selbstverst\u00E4ndlich anonym, es wird keine personenbezogene Auswertung der Daten stattfinden.",
     hildesheim_data_usage = "Die Daten werden von den Erstsemestern Psychologie im Bachelor generiert und in diesem Jahrgang genutzt, m\u00F6glicherweise auch in sp\u00E4teren Jahrg\u00E4ngen.",
     hildesheim_statements = "Im Folgenden werden Ihnen dazu Aussagen pr\u00E4sentiert. Wir bitten Sie anzugeben, inwieweit Sie diesen zustimmen.",
     hildesheim_no_right_wrong = "Es gibt keine falschen oder richtigen Antworten. Bitte beantworten Sie die Fragen so, wie es Ihrer Meinung am ehesten entspricht.",
     hildesheim_duration = "Die Befragung dauert etwa 10-15 Minuten.",
     hildesheim_consent_title = "Einverst\u00E4ndniserkl\u00E4rung",
     hildesheim_consent_text = "Ich bin mit der Teilnahme an der Befragung einverstanden",
     hildesheim_language_switch = "English Version"
  ),
  
  es = list(
    # Basic UI elements
    demo_title = "Informaci\u00F3n Demogr\u00E1fica",
    provide_optional_demographics = "Proporcionar informaci\u00F3n demogr\u00E1fica opcional",
    optional_demographics = "Informaci\u00F3n demogr\u00E1fica opcional",
    answer_questions_experiences = "Responda preguntas sobre sus experiencias, actitudes y comportamientos",
    complete_interactive_questionnaire = "Complete un cuestionario interactivo",
    receive_personalized_feedback = "Reciba comentarios personalizados sobre sus respuestas",
    response_data_questionnaires = "Datos de respuesta de cuestionarios",
    technical_data = "Datos t\u00E9cnicos (duraci\u00F3n de sesi\u00F3n, tiempos de respuesta)",
    no_personal_identifiers = "Sin identificadores personales o informaci\u00F3n de contacto",
    during_study_you_will = "Durante este estudio, usted:",
    we_may_process_data = "Podemos procesar las siguientes categor\u00EDas de datos:",
    study_procedures = "Procedimientos del Estudio",
    categories_of_data = "Categor\u00EDas de Datos",
    article_9_gdpr = "Art\u00EDculo 9(2)(a) GDPR: Consentimiento expl\u00EDcito para categor\u00EDas especiales de datos (si aplica)",
    article_6_gdpr = "Art\u00EDculo 6(1)(a) GDPR: Su consentimiento expl\u00EDcito",
    legitimate_interest = "Inter\u00E9s leg\u00EDtimo: Prop\u00F3sitos de investigaci\u00F3n cient\u00EDfica",
    objection = "Objeci\u00F3n: Objetar al procesamiento basado en intereses leg\u00EDtimos",
    rectification = "Rectificaci\u00F3n: Corregir datos inexactos",
    erasure = "Borrado: Solicitar eliminaci\u00F3n de sus datos",
    portability = "Portabilidad: Recibir sus datos en formato portable",
    restriction = "Restricci\u00F3n: Limitar el procesamiento de sus datos",
    access = "Acceso: Solicitar informaci\u00F3n sobre sus datos",
    complaint = "Queja: Presentar una queja ante autoridades supervisoras",
    welcome_text = "Por favor, proporcione sus detalles demogr\u00E1ficos para comenzar la evaluaci\u00F3n.",
    start_button = "Comenzar Evaluaci\u00F3n",
    submit_button = "Enviar",
    continue_button = "Continuar",
    begin_button = "Comenzar Evaluaci\u00F3n",
    restart_button = "Reiniciar",
    save_button = "Descargar Reporte",
    select_option = "Seleccionar...",
    
    # Results section
    results_title = "Resultados de la Evaluaci\u00F3n",
    proficiency = "Puntuaci\u00F3n del Rasgo",
    precision = "Precisi\u00F3n de Medici\u00F3n",
    items_administered = "Elementos Completados",
    recommendations = "Recomendaciones",
    assessment_complete = "Evaluaci\u00F3n Completada",
    analysis_completed = "An\u00E1lisis psicom\u00E9trico avanzado completado con reportes espec\u00EDficos del dominio",
    return_dashboard = "Volver al Panel",
    view_backend = "Ver Backend de An\u00E1lisis",
    
    # Feedback messages
    feedback_correct = "Correcto",
    feedback_incorrect = "Incorrecto",
    timeout_message = "Sesi\u00F3n expirada. Por favor reinicie.",
    demo_error = "Por favor complete todos los campos requeridos.",
    age_error = "Por favor ingrese una edad v\u00E1lida (1-150).",
    
    # Consent section
    consent_title = "Consentimiento del Estudio de Investigaci\u00F3n",
    consent_welcome = "Bienvenido al Estudio de Evaluaci\u00F3n Cognitiva. Por favor lea la informaci\u00F3n a continuaci\u00F3n y proporcione su consentimiento para participar.",
    consent_purpose_label = "Prop\u00F3sito:",
    consent_purpose_text = "Este estudio investiga habilidades cognitivas usando elementos de evaluaci\u00F3n estandarizados. Sus respuestas ser\u00E1n anonimizadas y usadas solo para prop\u00F3sitos de investigaci\u00F3n.",
    consent_privacy_label = "Privacidad de Datos:",
    consent_privacy_text = "El tratamiento y almacenamiento de los datos se describen en la informaci\u00F3n de protecci\u00F3n de datos del estudio.",
    consent_voluntary_label = "Participaci\u00F3n Voluntaria:",
    consent_voluntary_text = "Puede retirarse en cualquier momento sin penalizaci\u00F3n.",
    consent_checkbox_text = "He le\u00EDdo y entendido la informaci\u00F3n anterior y consiento en participar.",
    
    # Instructions section
    instructions_title = "Instrucciones",
    instructions_text = "Por favor lea las instrucciones cuidadosamente antes de comenzar la evaluaci\u00F3n.",
    instructions_read_carefully = "Por favor lea las instrucciones cuidadosamente antes de comenzar la evaluaci\u00F3n.",
    instructions_cognitive_tasks = "Completar\u00E1 una serie de tareas cognitivas evaluando memoria, velocidad y funci\u00F3n ejecutiva.",
    instructions_answer_accurately = "Responda cada pregunta tan precisa y r\u00E1pidamente como sea posible.",
    instructions_progress_display = "Su progreso se mostrar\u00E1 en la parte superior de la pantalla.",
    instructions_no_right_wrong = "No hay respuestas correctas o incorrectas; por favor haga lo mejor posible.",
    instructions_click_begin = "Haga clic en 'Comenzar Evaluaci\u00F3n' cuando est\u00E9 listo.",
    
    # Assessment section
    cognitive_assessment = "Evaluaci\u00F3n Cognitiva",
    live_analysis_active = "An\u00E1lisis en Vivo Activo",
    participant_id = "ID: %s",
    session_time = "12:34",
    question_progress = "Pregunta %d de %d",
    completion_percentage = "%d%% Completado",
    difficulty_load_format = "Dificultad: %s | Carga: %s",
    item_number = "Elemento %d",
    analysis_type_format = "An\u00E1lisis: %s",
    loading_question = "Cargando pregunta...",
    preparing = "Preparando...",
    select_answer = "Seleccione su respuesta:",
    
    # Demographics
    age_label = "Edad",
    gender_label = "G\u00E9nero",
    education_label = "Educaci\u00F3n",
    demographics_optional_info = "Por favor, proporcione informaci\u00F3n opcional sobre usted mismo. Todos los campos son opcionales y puede omitir cualquier pregunta que prefiera no responder.",
    demographics_provide_info = "Por favor, proporcione informaci\u00F3n sobre %s",
    enter_age = "Ingrese su edad",
    enter_field = "Ingrese %s",
    enter_details = "Ingrese detalles...",
    please_specify = "Por favor, especifique:",
    prefer_not_to_answer = "Prefiero no responder",
    please_select = "Por favor, seleccione...",
    gender_female = "Femenino",
    gender_male = "Masculino",
    gender_other = "Otro",
    gender_prefer_not = "Prefiero no decir",
    education_high_school = "Escuela Secundaria",
    education_bachelor = "Licenciatura",
    education_master = "Maestr\u00EDa",
    education_doctorate = "Doctorado",
    education_other = "Otro",
    
    # Welcome section
    welcome_title = "Bienvenido al Estudio de Evaluaci\u00F3n Cognitiva",
    welcome_description = "Su participaci\u00F3n ayuda a avanzar en la ciencia cognitiva. Todos los datos son confidenciales y se usan solo para investigaci\u00F3n acad\u00E9mica.",
    participate_button = "Participar en el Estudio",
    
    # Study flow headings
    study_overview = "Resumen del Estudio",
    what_to_expect = "Qu\u00E9 Esperar",
    important_notes = "Notas Importantes",
    research_details = "Detalles de la Investigaci\u00F3n",
    risks_and_benefits = "Riesgos y Beneficios",
    confidentiality = "Confidencialidad",
    contact_information = "Informaci\u00F3n de Contacto",
    consent_to_participate = "Consentimiento para Participar",
    data_use_and_storage = "Uso y Almacenamiento de Datos",
    right_to_withdraw = "Derecho a Retirarse",
    data_controller = "Controlador de Datos",
    legal_basis_for_processing = "Base Legal para el Procesamiento",
    data_retention = "Retenci\u00F3n de Datos",
    your_rights_under_gdpr = "Sus Derechos bajo GDPR",
    data_sharing = "Compartir Datos",
    contact_for_data_protection = "Contacto para Protecci\u00F3n de Datos",
    study_purpose = "Prop\u00F3sito del Estudio",
    research_methodology = "Metodolog\u00EDa de la Investigaci\u00F3n",
    research_implications = "Implicaciones de la Investigaci\u00F3n",
    next_steps = "Pr\u00F3ximos Pasos",
    additional_resources = "Recursos Adicionales",
    support_and_concerns = "Apoyo y Preocupaciones",
    
    # Study flow labels
    voluntary_participation = "Participaci\u00F3n Voluntaria",
    data_protection = "Protecci\u00F3n de Datos",
    technical_requirements = "Requisitos T\u00E9cnicos",
    principal_investigator = "Investigador Principal",
    institution = "Instituci\u00F3n",
    study_purpose_label = "Prop\u00F3sito del Estudio",
    publication = "Publicaci\u00F3n",
    risks = "Riesgos",
    benefits = "Beneficios",
    research_team = "Equipo de Investigaci\u00F3n",
    ethics_committee = "Comit\u00E9 de \u00C9tica",
    address = "Direcci\u00F3n",
    email = "Correo Electr\u00F3nico",
    data_protection_officer = "Oficial de Protecci\u00F3n de Datos",
    supervisory_authority = "Autoridad Supervisora"
  ),
  
  fr = list(
    # Basic UI elements
    demo_title = "Informations D\u00E9mographiques",
    provide_optional_demographics = "Fournir des informations d\u00E9mographiques optionnelles",
    optional_demographics = "Informations d\u00E9mographiques optionnelles",
    answer_questions_experiences = "R\u00E9pondez \u00E0 des questions sur vos exp\u00E9riences, attitudes et comportements",
    complete_interactive_questionnaire = "Compl\u00E9tez un questionnaire interactif",
    receive_personalized_feedback = "Recevez des commentaires personnalis\u00E9s sur vos r\u00E9ponses",
    response_data_questionnaires = "Donn\u00E9es de r\u00E9ponse des questionnaires",
    technical_data = "Donn\u00E9es techniques (dur\u00E9e de session, temps de r\u00E9ponse)",
    no_personal_identifiers = "Aucun identifiant personnel ou information de contact",
    during_study_you_will = "Pendant cette \u00E9tude, vous :",
    we_may_process_data = "Nous pouvons traiter les cat\u00E9gories de donn\u00E9es suivantes :",
    study_procedures = "Proc\u00E9dures de l'\u00C9tude",
    categories_of_data = "Cat\u00E9gories de Donn\u00E9es",
    article_9_gdpr = "Article 9(2)(a) RGPD : Consentement explicite pour les cat\u00E9gories sp\u00E9ciales de donn\u00E9es (si applicable)",
    article_6_gdpr = "Article 6(1)(a) RGPD : Votre consentement explicite",
    legitimate_interest = "Int\u00E9r\u00EAt l\u00E9gitime : Fins de recherche scientifique",
    objection = "Opposition : S'opposer au traitement bas\u00E9 sur des int\u00E9r\u00EAts l\u00E9gitimes",
    rectification = "Rectification : Corriger des donn\u00E9es inexactes",
    erasure = "Effacement : Demander la suppression de vos donn\u00E9es",
    portability = "Portabilit\u00E9 : Recevoir vos donn\u00E9es dans un format portable",
    restriction = "Restriction : Limiter le traitement de vos donn\u00E9es",
    access = "Acc\u00E8s : Demander des informations sur vos donn\u00E9es",
    complaint = "Plainte : D\u00E9poser une plainte aupr\u00E8s des autorit\u00E9s de surveillance",
    welcome_text = "Veuillez fournir vos informations d\u00E9mographiques pour commencer l'\u00E9valuation.",
    start_button = "Commencer l'\u00C9valuation",
    submit_button = "Soumettre",
    continue_button = "Continuer",
    begin_button = "Commencer l'\u00C9valuation",
    restart_button = "Red\u00E9marrer",
    save_button = "T\u00E9l\u00E9charger le Rapport",
    select_option = "S\u00E9lectionner...",
    
    # Results section
    results_title = "R\u00E9sultats de l'\u00C9valuation",
    proficiency = "Score du Trait",
    precision = "Pr\u00E9cision de Mesure",
    items_administered = "\u00C9l\u00E9ments Termin\u00E9s",
    recommendations = "Recommandations",
    assessment_complete = "\u00C9valuation Termin\u00E9e",
    analysis_completed = "Analyse psychom\u00E9trique avanc\u00E9e termin\u00E9e avec rapports sp\u00E9cifiques au domaine",
    return_dashboard = "Retour au Tableau de Bord",
    view_backend = "Voir le Backend d'Analyse",
    
    # Feedback messages
    feedback_correct = "Correct",
    feedback_incorrect = "Incorrect",
    timeout_message = "Session expir\u00E9e. Veuillez red\u00E9marrer.",
    demo_error = "Veuillez remplir tous les champs requis.",
    age_error = "Veuillez entrer un \u00E2ge valide (1-150).",
    
    # Consent section
    consent_title = "Consentement \u00E0 l'\u00C9tude de Recherche",
    consent_welcome = "Bienvenue \u00E0 l'\u00C9tude d'\u00C9valuation Cognitive. Veuillez lire les informations ci-dessous et fournir votre consentement pour participer.",
    consent_purpose_label = "But :",
    consent_purpose_text = "Cette \u00E9tude examine les capacit\u00E9s cognitives en utilisant des \u00E9l\u00E9ments d'\u00E9valuation standardis\u00E9s. Vos r\u00E9ponses seront anonymis\u00E9es et utilis\u00E9es uniquement \u00E0 des fins de recherche.",
    consent_privacy_label = "Confidentialit\u00E9 des Donn\u00E9es :",
    consent_privacy_text = "Toutes les donn\u00E9es sont stock\u00E9es en toute s\u00E9curit\u00E9 et trait\u00E9es conform\u00E9ment aux directives institutionnelles et RGPD.",
    consent_voluntary_label = "Participation Volontaire :",
    consent_voluntary_text = "Vous pouvez vous retirer \u00E0 tout moment sans p\u00E9nalit\u00E9.",
    consent_checkbox_text = "J'ai lu et compris les informations ci-dessus et consens \u00E0 participer.",
    
    # Instructions section
    instructions_title = "Instructions",
    instructions_text = "Veuillez lire attentivement les instructions avant de commencer l'\u00E9valuation.",
    instructions_read_carefully = "Veuillez lire attentivement les instructions avant de commencer l'\u00E9valuation.",
    instructions_cognitive_tasks = "Vous effectuerez une s\u00E9rie de t\u00E2ches cognitives \u00E9valuant la m\u00E9moire, la vitesse et la fonction ex\u00E9cutive.",
    instructions_answer_accurately = "R\u00E9pondez \u00E0 chaque question aussi pr\u00E9cis\u00E9ment et rapidement que possible.",
    instructions_progress_display = "Votre progression sera affich\u00E9e en haut de l'\u00E9cran.",
    instructions_no_right_wrong = "Il n'y a pas de bonnes ou mauvaises r\u00E9ponses ; faites de votre mieux.",
    instructions_click_begin = "Cliquez sur 'Commencer l'\u00C9valuation' quand vous \u00EAtes pr\u00EAt.",
    
    # Assessment section
    cognitive_assessment = "\u00C9valuation Cognitive",
    live_analysis_active = "Analyse en Direct Active",
    participant_id = "ID : %s",
    session_time = "12:34",
    question_progress = "Question %d sur %d",
    completion_percentage = "%d%% Termin\u00E9",
    difficulty_load_format = "Difficult\u00E9 : %s | Charge : %s",
    item_number = "\u00C9l\u00E9ment %d",
    analysis_type_format = "Analyse : %s",
    loading_question = "Chargement de la question...",
    preparing = "Pr\u00E9paration...",
    select_answer = "S\u00E9lectionnez votre r\u00E9ponse :",
    
    # Demographics
    age_label = "\u00C2ge",
    gender_label = "Genre",
    education_label = "\u00C9ducation",
    demographics_optional_info = "Veuillez fournir quelques informations optionnelles sur vous-m\u00EAme. Tous les champs sont optionnels et vous pouvez ignorer toute question que vous pr\u00E9f\u00E9rez ne pas r\u00E9pondre.",
    demographics_provide_info = "Veuillez fournir des informations sur %s",
    enter_age = "Entrez votre \u00E2ge",
    enter_field = "Entrez %s",
    enter_details = "Entrez les d\u00E9tails...",
    please_specify = "Veuillez pr\u00E9ciser :",
    prefer_not_to_answer = "Pr\u00E9f\u00E8re ne pas r\u00E9pondre",
    please_select = "Veuillez s\u00E9lectionner...",
    gender_female = "Femme",
    gender_male = "Homme",
    gender_other = "Autre",
    gender_prefer_not = "Pr\u00E9f\u00E8re ne pas dire",
    education_high_school = "Lyc\u00E9e",
    education_bachelor = "Licence",
    education_master = "Master",
    education_doctorate = "Doctorat",
    education_other = "Autre",
    
    # Welcome section
    welcome_title = "Bienvenue \u00E0 l'\u00C9tude d'\u00C9valuation Cognitive",
    welcome_description = "Votre participation aide \u00E0 faire progresser la science cognitive. Toutes les donn\u00E9es sont confidentielles et utilis\u00E9es uniquement pour la recherche acad\u00E9mique.",
    participate_button = "Participer \u00E0 l'\u00C9tude",
    
    # Study flow headings
    study_overview = "Aper\u00E7u de l'\u00C9tude",
    what_to_expect = "\u00C0 Quoi S'attendre",
    important_notes = "Notes Importantes",
    research_details = "D\u00E9tails de la Recherche",
    risks_and_benefits = "Risques et Avantages",
    confidentiality = "Confidentialit\u00E9",
    contact_information = "Informations de Contact",
    consent_to_participate = "Consentement \u00E0 Participer",
    data_use_and_storage = "Utilisation et Stockage des Donn\u00E9es",
    right_to_withdraw = "Droit de Se Retirer",
    data_controller = "Responsable des Donn\u00E9es",
    legal_basis_for_processing = "Base L\u00E9gale du Traitement",
    data_retention = "Conservation des Donn\u00E9es",
    your_rights_under_gdpr = "Vos Droits selon le RGPD",
    data_sharing = "Partage de Donn\u00E9es",
    contact_for_data_protection = "Contact pour la Protection des Donn\u00E9es",
    study_purpose = "But de l'\u00C9tude",
    research_methodology = "M\u00E9thodologie de Recherche",
    research_implications = "Implications de la Recherche",
    next_steps = "Prochaines \u00C9tapes",
    additional_resources = "Ressources Suppl\u00E9mentaires",
    support_and_concerns = "Soutien et Pr\u00E9occupations",
    
    # Study flow labels
    voluntary_participation = "Participation Volontaire",
    data_protection = "Protection des Donn\u00E9es",
    technical_requirements = "Exigences Techniques",
    principal_investigator = "Chercheur Principal",
    institution = "Institution",
    study_purpose_label = "But de l'\u00C9tude",
    publication = "Publication",
    risks = "Risques",
    benefits = "Avantages",
    research_team = "\u00C9quipe de Recherche",
    ethics_committee = "Comit\u00E9 d'\u00C9thique",
    address = "Adresse",
    email = "E-mail",
    data_protection_officer = "D\u00E9l\u00E9gu\u00E9 \u00E0 la Protection des Donn\u00E9es",
    supervisory_authority = "Autorit\u00E9 de Surveillance"
  )
)

#' Get Language Labels
#'
#' Retrieves all labels for a specific language
#'
#' @param language Language code (en, de, es, fr)
#' @return List of language labels
#' @export
get_language_labels <- function(language = "en") {
  if (!is_supported_language(language)) {
    warning(paste("Language '", language, "' not supported. Using English (en) as fallback."))
    language <- "en"
  }
  return(LANGUAGE_DICTIONARY[[language]])
}

#' Get Specific Label
#'
#' Retrieves a specific label for a given language
#'
#' @param label_key Label key to retrieve
#' @param language Language code (en, de, es, fr)
#' @param fallback Fallback value if label not found
#' @return Label text
#' @export
get_label <- function(label_key, language = "en", fallback = NULL) {
  labels <- get_language_labels(language)
  result <- labels[[label_key]]
  
  if (is.null(result)) {
    if (!is.null(fallback)) {
      return(fallback)
    }
    # Return English fallback if available
    en_labels <- LANGUAGE_DICTIONARY[["en"]]
    return(en_labels[[label_key]] %||% label_key)
  }
  
  return(result)
}

#' List Supported Languages
#'
#' @return Vector of supported language codes
#' @export
list_supported_languages <- function() {
  return(names(LANGUAGE_DICTIONARY))
}

#' Validate Language Code
#'
#' @param language Language code to validate
#' @return Logical indicating if language is supported
#' @export
is_supported_language <- function(language) {
  return(language %in% names(LANGUAGE_DICTIONARY))
}

#' Get Language Name
#'
#' @param language_code Language code (en, de, es, fr)
#' @return Full language name
#' @export
get_language_name <- function(language_code) {
  language_names <- list(
    en = "English",
    de = "Deutsch",
    es = "Espa\u00F1ol",
    fr = "Fran\u00E7ais"
  )
  return(language_names[[language_code]] %||% language_code)
}
