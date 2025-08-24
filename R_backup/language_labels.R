#' Comprehensive Multilingual Support for inrep Package
#'
#' Provides complete translations for all UI elements, messages, and content
#' Supports: English (en), German (de), Spanish (es), French (fr)
#'
#' @export

# Complete language dictionary for all UI elements
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
    consent_privacy_text = "All data is stored securely and handled in accordance with institutional and GDPR guidelines.",
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
    supervisory_authority = "Supervisory Authority"
  ),
  
  de = list(
    # Basic UI elements
    demo_title = "Demografische Informationen",
    provide_optional_demographics = "Optionale demografische Informationen bereitstellen",
    optional_demographics = "Optionale demografische Informationen",
    answer_questions_experiences = "Beantworten Sie Fragen zu Ihren Erfahrungen, Einstellungen und Verhaltensweisen",
    complete_interactive_questionnaire = "Vervollständigen Sie einen interaktiven Fragebogen",
    receive_personalized_feedback = "Erhalten Sie personalisiertes Feedback zu Ihren Antworten",
    response_data_questionnaires = "Antwortdaten aus Fragebögen",
    technical_data = "Technische Daten (Sitzungsdauer, Antwortzeiten)",
    no_personal_identifiers = "Keine persönlichen Identifikatoren oder Kontaktinformationen",
    during_study_you_will = "Während dieser Studie werden Sie:",
    we_may_process_data = "Wir können die folgenden Datenkategorien verarbeiten:",
    study_procedures = "Studienverfahren",
    categories_of_data = "Datenkategorien",
    article_9_gdpr = "Artikel 9(2)(a) DSGVO: Ausdrückliche Einwilligung für besondere Datenkategorien (falls zutreffend)",
    article_6_gdpr = "Artikel 6(1)(a) DSGVO: Ihre ausdrückliche Einwilligung",
    legitimate_interest = "Berechtigtes Interesse: Wissenschaftliche Forschungszwecke",
    objection = "Widerspruch: Widersprechen Sie der Verarbeitung auf der Grundlage berechtigter Interessen",
    rectification = "Berichtigung: Ungenaue Daten korrigieren",
    erasure = "Löschung: Löschung Ihrer Daten beantragen",
    portability = "Übertragbarkeit: Ihre Daten in einem übertragbaren Format erhalten",
    restriction = "Einschränkung: Verarbeitung Ihrer Daten einschränken",
    access = "Zugang: Informationen über Ihre Daten anfordern",
    complaint = "Beschwerde: Beschwerde bei Aufsichtsbehörden einlegen",
    welcome_text = "Bitte geben Sie Ihre demografischen Daten ein, um die Bewertung zu beginnen.",
    start_button = "Bewertung beginnen",
    submit_button = "Absenden",
    continue_button = "Weiter",
    begin_button = "Bewertung beginnen",
    restart_button = "Neu starten",
    save_button = "Bericht herunterladen",
    select_option = "Auswählen...",
    
    # Results section
    results_title = "Bewertungsergebnisse",
    proficiency = "Merkmalswert",
    precision = "Messgenauigkeit",
    items_administered = "Abgeschlossene Elemente",
    recommendations = "Empfehlungen",
    assessment_complete = "Bewertung abgeschlossen",
    analysis_completed = "Erweiterte psychometrische Analyse mit domänenspezifischer Berichterstattung abgeschlossen",
    return_dashboard = "Zum Dashboard zurückkehren",
    view_backend = "Analyse-Backend anzeigen",
    
    # Feedback messages
    feedback_correct = "Korrekt",
    feedback_incorrect = "Falsch",
    timeout_message = "Sitzung abgelaufen. Bitte neu starten.",
    demo_error = "Bitte füllen Sie alle erforderlichen Felder aus.",
    age_error = "Bitte geben Sie ein gültiges Alter ein (1-150).",
    
    # Consent section
    consent_title = "Einverständniserklärung zur Forschungsstudie",
    consent_welcome = "Willkommen zur kognitiven Bewertungsstudie. Bitte lesen Sie die folgenden Informationen und geben Sie Ihre Zustimmung zur Teilnahme.",
    consent_purpose_label = "Zweck:",
    consent_purpose_text = "Diese Studie untersucht kognitive Fähigkeiten mit standardisierten Bewertungselementen. Ihre Antworten werden anonymisiert und nur zu Forschungszwecken verwendet.",
    consent_privacy_label = "Datenschutz:",
    consent_privacy_text = "Alle Daten werden sicher gespeichert und in Übereinstimmung mit institutionellen und DSGVO-Richtlinien behandelt.",
    consent_voluntary_label = "Freiwillige Teilnahme:",
    consent_voluntary_text = "Sie können jederzeit ohne Konsequenzen zurücktreten.",
    consent_checkbox_text = "Ich habe die obigen Informationen gelesen und verstanden und stimme der Teilnahme zu.",
    
    # Instructions section
    instructions_title = "Anweisungen",
    instructions_text = "Bitte lesen Sie die Anweisungen sorgfältig durch, bevor Sie mit der Bewertung beginnen.",
    instructions_read_carefully = "Bitte lesen Sie die Anweisungen sorgfältig durch, bevor Sie mit der Bewertung beginnen.",
    instructions_cognitive_tasks = "Sie werden eine Reihe von kognitiven Aufgaben absolvieren, die Gedächtnis, Geschwindigkeit und exekutive Funktionen bewerten.",
    instructions_answer_accurately = "Beantworten Sie jede Frage so genau und schnell wie möglich.",
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
    select_answer = "Wählen Sie Ihre Antwort:",
    
    # Demographics
    age_label = "Alter",
    gender_label = "Geschlecht",
    education_label = "Bildung",
    demographics_optional_info = "Bitte geben Sie einige optionale Informationen über sich selbst an. Alle Felder sind optional und Sie können alle Fragen überspringen, die Sie lieber nicht beantworten möchten.",
    demographics_provide_info = "Bitte geben Sie Informationen über %s an",
    enter_age = "Geben Sie Ihr Alter ein",
    enter_field = "Geben Sie %s ein",
    enter_details = "Details eingeben...",
    please_specify = "Bitte spezifizieren:",
    prefer_not_to_answer = "Lieber nicht beantworten",
    please_select = "Bitte wählen...",
    gender_female = "Weiblich",
    gender_male = "Männlich",
    gender_other = "Andere",
    gender_prefer_not = "Möchte nicht sagen",
    education_high_school = "Abitur",
    education_bachelor = "Bachelor-Abschluss",
    education_master = "Master-Abschluss",
    education_doctorate = "Promotion",
    education_other = "Andere",
    
    # Welcome section
    welcome_title = "Willkommen zur kognitiven Bewertungsstudie",
    welcome_description = "Ihre Teilnahme hilft dabei, die kognitive Wissenschaft voranzubringen. Alle Daten sind vertraulich und werden nur für akademische Forschung verwendet.",
    participate_button = "An der Studie teilnehmen",
    
    # Study flow headings
    study_overview = "Studienübersicht",
    what_to_expect = "Was zu erwarten ist",
    important_notes = "Wichtige Hinweise",
    research_details = "Forschungsdetails",
    risks_and_benefits = "Risiken und Vorteile",
    confidentiality = "Vertraulichkeit",
    contact_information = "Kontaktinformationen",
    consent_to_participate = "Zustimmung zur Teilnahme",
    data_use_and_storage = "Datenverwendung und -speicherung",
    right_to_withdraw = "Recht auf Rückzug",
    data_controller = "Datenverantwortlicher",
    legal_basis_for_processing = "Rechtliche Grundlage für die Verarbeitung",
    data_retention = "Datenaufbewahrung",
    your_rights_under_gdpr = "Ihre Rechte nach DSGVO",
    data_sharing = "Datenweitergabe",
    contact_for_data_protection = "Kontakt für Datenschutz",
    study_purpose = "Studienzweck",
    research_methodology = "Forschungsmethodik",
    research_implications = "Forschungsimplikationen",
    next_steps = "Nächste Schritte",
    additional_resources = "Zusätzliche Ressourcen",
    support_and_concerns = "Unterstützung und Bedenken",
    
    # Study flow labels
    voluntary_participation = "Freiwillige Teilnahme",
    data_protection = "Datenschutz",
    technical_requirements = "Technische Anforderungen",
    principal_investigator = "Hauptuntersucher",
    institution = "Institution",
    study_purpose_label = "Studienzweck",
    publication = "Veröffentlichung",
    risks = "Risiken",
    benefits = "Vorteile",
    research_team = "Forschungsteam",
    ethics_committee = "Ethikkommission",
    address = "Adresse",
    email = "E-Mail",
    data_protection_officer = "Datenschutzbeauftragter",
    supervisory_authority = "Aufsichtsbehörde"
  ),
  
  es = list(
    # Basic UI elements
    demo_title = "Información Demográfica",
    provide_optional_demographics = "Proporcionar información demográfica opcional",
    optional_demographics = "Información demográfica opcional",
    answer_questions_experiences = "Responda preguntas sobre sus experiencias, actitudes y comportamientos",
    complete_interactive_questionnaire = "Complete un cuestionario interactivo",
    receive_personalized_feedback = "Reciba comentarios personalizados sobre sus respuestas",
    response_data_questionnaires = "Datos de respuesta de cuestionarios",
    technical_data = "Datos técnicos (duración de sesión, tiempos de respuesta)",
    no_personal_identifiers = "Sin identificadores personales o información de contacto",
    during_study_you_will = "Durante este estudio, usted:",
    we_may_process_data = "Podemos procesar las siguientes categorías de datos:",
    study_procedures = "Procedimientos del Estudio",
    categories_of_data = "Categorías de Datos",
    article_9_gdpr = "Artículo 9(2)(a) GDPR: Consentimiento explícito para categorías especiales de datos (si aplica)",
    article_6_gdpr = "Artículo 6(1)(a) GDPR: Su consentimiento explícito",
    legitimate_interest = "Interés legítimo: Propósitos de investigación científica",
    objection = "Objeción: Objetar al procesamiento basado en intereses legítimos",
    rectification = "Rectificación: Corregir datos inexactos",
    erasure = "Borrado: Solicitar eliminación de sus datos",
    portability = "Portabilidad: Recibir sus datos en formato portable",
    restriction = "Restricción: Limitar el procesamiento de sus datos",
    access = "Acceso: Solicitar información sobre sus datos",
    complaint = "Queja: Presentar una queja ante autoridades supervisoras",
    welcome_text = "Por favor, proporcione sus detalles demográficos para comenzar la evaluación.",
    start_button = "Comenzar Evaluación",
    submit_button = "Enviar",
    continue_button = "Continuar",
    begin_button = "Comenzar Evaluación",
    restart_button = "Reiniciar",
    save_button = "Descargar Reporte",
    select_option = "Seleccionar...",
    
    # Results section
    results_title = "Resultados de la Evaluación",
    proficiency = "Puntuación del Rasgo",
    precision = "Precisión de Medición",
    items_administered = "Elementos Completados",
    recommendations = "Recomendaciones",
    assessment_complete = "Evaluación Completada",
    analysis_completed = "Análisis psicométrico avanzado completado con reportes específicos del dominio",
    return_dashboard = "Volver al Panel",
    view_backend = "Ver Backend de Análisis",
    
    # Feedback messages
    feedback_correct = "Correcto",
    feedback_incorrect = "Incorrecto",
    timeout_message = "Sesión expirada. Por favor reinicie.",
    demo_error = "Por favor complete todos los campos requeridos.",
    age_error = "Por favor ingrese una edad válida (1-150).",
    
    # Consent section
    consent_title = "Consentimiento del Estudio de Investigación",
    consent_welcome = "Bienvenido al Estudio de Evaluación Cognitiva. Por favor lea la información a continuación y proporcione su consentimiento para participar.",
    consent_purpose_label = "Propósito:",
    consent_purpose_text = "Este estudio investiga habilidades cognitivas usando elementos de evaluación estandarizados. Sus respuestas serán anonimizadas y usadas solo para propósitos de investigación.",
    consent_privacy_label = "Privacidad de Datos:",
    consent_privacy_text = "Todos los datos se almacenan de forma segura y se manejan de acuerdo con las pautas institucionales y GDPR.",
    consent_voluntary_label = "Participación Voluntaria:",
    consent_voluntary_text = "Puede retirarse en cualquier momento sin penalización.",
    consent_checkbox_text = "He leído y entendido la información anterior y consiento en participar.",
    
    # Instructions section
    instructions_title = "Instrucciones",
    instructions_text = "Por favor lea las instrucciones cuidadosamente antes de comenzar la evaluación.",
    instructions_read_carefully = "Por favor lea las instrucciones cuidadosamente antes de comenzar la evaluación.",
    instructions_cognitive_tasks = "Completará una serie de tareas cognitivas evaluando memoria, velocidad y función ejecutiva.",
    instructions_answer_accurately = "Responda cada pregunta tan precisa y rápidamente como sea posible.",
    instructions_progress_display = "Su progreso se mostrará en la parte superior de la pantalla.",
    instructions_no_right_wrong = "No hay respuestas correctas o incorrectas; por favor haga lo mejor posible.",
    instructions_click_begin = "Haga clic en 'Comenzar Evaluación' cuando esté listo.",
    
    # Assessment section
    cognitive_assessment = "Evaluación Cognitiva",
    live_analysis_active = "Análisis en Vivo Activo",
    participant_id = "ID: %s",
    session_time = "12:34",
    question_progress = "Pregunta %d de %d",
    completion_percentage = "%d%% Completado",
    difficulty_load_format = "Dificultad: %s | Carga: %s",
    item_number = "Elemento %d",
    analysis_type_format = "Análisis: %s",
    loading_question = "Cargando pregunta...",
    preparing = "Preparando...",
    select_answer = "Seleccione su respuesta:",
    
    # Demographics
    age_label = "Edad",
    gender_label = "Género",
    education_label = "Educación",
    demographics_optional_info = "Por favor, proporcione información opcional sobre usted mismo. Todos los campos son opcionales y puede omitir cualquier pregunta que prefiera no responder.",
    demographics_provide_info = "Por favor, proporcione información sobre %s",
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
    education_master = "Maestría",
    education_doctorate = "Doctorado",
    education_other = "Otro",
    
    # Welcome section
    welcome_title = "Bienvenido al Estudio de Evaluación Cognitiva",
    welcome_description = "Su participación ayuda a avanzar en la ciencia cognitiva. Todos los datos son confidenciales y se usan solo para investigación académica.",
    participate_button = "Participar en el Estudio",
    
    # Study flow headings
    study_overview = "Resumen del Estudio",
    what_to_expect = "Qué Esperar",
    important_notes = "Notas Importantes",
    research_details = "Detalles de la Investigación",
    risks_and_benefits = "Riesgos y Beneficios",
    confidentiality = "Confidencialidad",
    contact_information = "Información de Contacto",
    consent_to_participate = "Consentimiento para Participar",
    data_use_and_storage = "Uso y Almacenamiento de Datos",
    right_to_withdraw = "Derecho a Retirarse",
    data_controller = "Controlador de Datos",
    legal_basis_for_processing = "Base Legal para el Procesamiento",
    data_retention = "Retención de Datos",
    your_rights_under_gdpr = "Sus Derechos bajo GDPR",
    data_sharing = "Compartir Datos",
    contact_for_data_protection = "Contacto para Protección de Datos",
    study_purpose = "Propósito del Estudio",
    research_methodology = "Metodología de la Investigación",
    research_implications = "Implicaciones de la Investigación",
    next_steps = "Próximos Pasos",
    additional_resources = "Recursos Adicionales",
    support_and_concerns = "Apoyo y Preocupaciones",
    
    # Study flow labels
    voluntary_participation = "Participación Voluntaria",
    data_protection = "Protección de Datos",
    technical_requirements = "Requisitos Técnicos",
    principal_investigator = "Investigador Principal",
    institution = "Institución",
    study_purpose_label = "Propósito del Estudio",
    publication = "Publicación",
    risks = "Riesgos",
    benefits = "Beneficios",
    research_team = "Equipo de Investigación",
    ethics_committee = "Comité de Ética",
    address = "Dirección",
    email = "Correo Electrónico",
    data_protection_officer = "Oficial de Protección de Datos",
    supervisory_authority = "Autoridad Supervisora"
  ),
  
  fr = list(
    # Basic UI elements
    demo_title = "Informations Démographiques",
    provide_optional_demographics = "Fournir des informations démographiques optionnelles",
    optional_demographics = "Informations démographiques optionnelles",
    answer_questions_experiences = "Répondez à des questions sur vos expériences, attitudes et comportements",
    complete_interactive_questionnaire = "Complétez un questionnaire interactif",
    receive_personalized_feedback = "Recevez des commentaires personnalisés sur vos réponses",
    response_data_questionnaires = "Données de réponse des questionnaires",
    technical_data = "Données techniques (durée de session, temps de réponse)",
    no_personal_identifiers = "Aucun identifiant personnel ou information de contact",
    during_study_you_will = "Pendant cette étude, vous :",
    we_may_process_data = "Nous pouvons traiter les catégories de données suivantes :",
    study_procedures = "Procédures de l'Étude",
    categories_of_data = "Catégories de Données",
    article_9_gdpr = "Article 9(2)(a) RGPD : Consentement explicite pour les catégories spéciales de données (si applicable)",
    article_6_gdpr = "Article 6(1)(a) RGPD : Votre consentement explicite",
    legitimate_interest = "Intérêt légitime : Fins de recherche scientifique",
    objection = "Opposition : S'opposer au traitement basé sur des intérêts légitimes",
    rectification = "Rectification : Corriger des données inexactes",
    erasure = "Effacement : Demander la suppression de vos données",
    portability = "Portabilité : Recevoir vos données dans un format portable",
    restriction = "Restriction : Limiter le traitement de vos données",
    access = "Accès : Demander des informations sur vos données",
    complaint = "Plainte : Déposer une plainte auprès des autorités de surveillance",
    welcome_text = "Veuillez fournir vos informations démographiques pour commencer l'évaluation.",
    start_button = "Commencer l'Évaluation",
    submit_button = "Soumettre",
    continue_button = "Continuer",
    begin_button = "Commencer l'Évaluation",
    restart_button = "Redémarrer",
    save_button = "Télécharger le Rapport",
    select_option = "Sélectionner...",
    
    # Results section
    results_title = "Résultats de l'Évaluation",
    proficiency = "Score du Trait",
    precision = "Précision de Mesure",
    items_administered = "Éléments Terminés",
    recommendations = "Recommandations",
    assessment_complete = "Évaluation Terminée",
    analysis_completed = "Analyse psychométrique avancée terminée avec rapports spécifiques au domaine",
    return_dashboard = "Retour au Tableau de Bord",
    view_backend = "Voir le Backend d'Analyse",
    
    # Feedback messages
    feedback_correct = "Correct",
    feedback_incorrect = "Incorrect",
    timeout_message = "Session expirée. Veuillez redémarrer.",
    demo_error = "Veuillez remplir tous les champs requis.",
    age_error = "Veuillez entrer un âge valide (1-150).",
    
    # Consent section
    consent_title = "Consentement à l'Étude de Recherche",
    consent_welcome = "Bienvenue à l'Étude d'Évaluation Cognitive. Veuillez lire les informations ci-dessous et fournir votre consentement pour participer.",
    consent_purpose_label = "But :",
    consent_purpose_text = "Cette étude examine les capacités cognitives en utilisant des éléments d'évaluation standardisés. Vos réponses seront anonymisées et utilisées uniquement à des fins de recherche.",
    consent_privacy_label = "Confidentialité des Données :",
    consent_privacy_text = "Toutes les données sont stockées en toute sécurité et traitées conformément aux directives institutionnelles et RGPD.",
    consent_voluntary_label = "Participation Volontaire :",
    consent_voluntary_text = "Vous pouvez vous retirer à tout moment sans pénalité.",
    consent_checkbox_text = "J'ai lu et compris les informations ci-dessus et consens à participer.",
    
    # Instructions section
    instructions_title = "Instructions",
    instructions_text = "Veuillez lire attentivement les instructions avant de commencer l'évaluation.",
    instructions_read_carefully = "Veuillez lire attentivement les instructions avant de commencer l'évaluation.",
    instructions_cognitive_tasks = "Vous effectuerez une série de tâches cognitives évaluant la mémoire, la vitesse et la fonction exécutive.",
    instructions_answer_accurately = "Répondez à chaque question aussi précisément et rapidement que possible.",
    instructions_progress_display = "Votre progression sera affichée en haut de l'écran.",
    instructions_no_right_wrong = "Il n'y a pas de bonnes ou mauvaises réponses ; faites de votre mieux.",
    instructions_click_begin = "Cliquez sur 'Commencer l'Évaluation' quand vous êtes prêt.",
    
    # Assessment section
    cognitive_assessment = "Évaluation Cognitive",
    live_analysis_active = "Analyse en Direct Active",
    participant_id = "ID : %s",
    session_time = "12:34",
    question_progress = "Question %d sur %d",
    completion_percentage = "%d%% Terminé",
    difficulty_load_format = "Difficulté : %s | Charge : %s",
    item_number = "Élément %d",
    analysis_type_format = "Analyse : %s",
    loading_question = "Chargement de la question...",
    preparing = "Préparation...",
    select_answer = "Sélectionnez votre réponse :",
    
    # Demographics
    age_label = "Âge",
    gender_label = "Genre",
    education_label = "Éducation",
    demographics_optional_info = "Veuillez fournir quelques informations optionnelles sur vous-même. Tous les champs sont optionnels et vous pouvez ignorer toute question que vous préférez ne pas répondre.",
    demographics_provide_info = "Veuillez fournir des informations sur %s",
    enter_age = "Entrez votre âge",
    enter_field = "Entrez %s",
    enter_details = "Entrez les détails...",
    please_specify = "Veuillez préciser :",
    prefer_not_to_answer = "Préfère ne pas répondre",
    please_select = "Veuillez sélectionner...",
    gender_female = "Femme",
    gender_male = "Homme",
    gender_other = "Autre",
    gender_prefer_not = "Préfère ne pas dire",
    education_high_school = "Lycée",
    education_bachelor = "Licence",
    education_master = "Master",
    education_doctorate = "Doctorat",
    education_other = "Autre",
    
    # Welcome section
    welcome_title = "Bienvenue à l'Étude d'Évaluation Cognitive",
    welcome_description = "Votre participation aide à faire progresser la science cognitive. Toutes les données sont confidentielles et utilisées uniquement pour la recherche académique.",
    participate_button = "Participer à l'Étude",
    
    # Study flow headings
    study_overview = "Aperçu de l'Étude",
    what_to_expect = "À Quoi S'attendre",
    important_notes = "Notes Importantes",
    research_details = "Détails de la Recherche",
    risks_and_benefits = "Risques et Avantages",
    confidentiality = "Confidentialité",
    contact_information = "Informations de Contact",
    consent_to_participate = "Consentement à Participer",
    data_use_and_storage = "Utilisation et Stockage des Données",
    right_to_withdraw = "Droit de Se Retirer",
    data_controller = "Responsable des Données",
    legal_basis_for_processing = "Base Légale du Traitement",
    data_retention = "Conservation des Données",
    your_rights_under_gdpr = "Vos Droits selon le RGPD",
    data_sharing = "Partage de Données",
    contact_for_data_protection = "Contact pour la Protection des Données",
    study_purpose = "But de l'Étude",
    research_methodology = "Méthodologie de Recherche",
    research_implications = "Implications de la Recherche",
    next_steps = "Prochaines Étapes",
    additional_resources = "Ressources Supplémentaires",
    support_and_concerns = "Soutien et Préoccupations",
    
    # Study flow labels
    voluntary_participation = "Participation Volontaire",
    data_protection = "Protection des Données",
    technical_requirements = "Exigences Techniques",
    principal_investigator = "Chercheur Principal",
    institution = "Institution",
    study_purpose_label = "But de l'Étude",
    publication = "Publication",
    risks = "Risques",
    benefits = "Avantages",
    research_team = "Équipe de Recherche",
    ethics_committee = "Comité d'Éthique",
    address = "Adresse",
    email = "E-mail",
    data_protection_officer = "Délégué à la Protection des Données",
    supervisory_authority = "Autorité de Surveillance"
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
    es = "Español",
    fr = "Français"
  )
  return(language_names[[language_code]] %||% language_code)
}