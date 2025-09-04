# Variable Definitions - Hildesheim University Study
# =================================================

## Complete Variable Dictionary

This document provides comprehensive definitions for all variables collected in the University of Hildesheim psychology assessment study.

### Demographics Variables

#### Einverständnis (Consent)
- **Type**: Numeric (Binary)
- **Values**: 1 = "Ich bin mit der Teilnahme an der Befragung einverstanden"
- **Description**: Informed consent for study participation
- **Required**: Yes

#### Alter_VPN (Age of Participant)
- **Type**: Numeric (Categorical)
- **Values**: 
  - 0 = "älter als 30" (older than 30)
  - 1 = "18 Jahre oder jünger" (18 years or younger)
  - 2 = "19 Jahre" (19 years)
  - 3 = "20 Jahre" (20 years)
  - 4 = "21 Jahre" (21 years)
  - 5 = "22 Jahre" (22 years)
  - 6 = "23 Jahre" (23 years)
  - 7 = "24 Jahre" (24 years)
  - 8 = "25 Jahre" (25 years)
  - 9 = "26-30 Jahre" (26-30 years)
- **Description**: Age category of participant
- **Required**: Yes

#### Studiengang (Study Program)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "Bachelor Psychologie" (Bachelor Psychology)
  - 2 = "Master Psychologie" (Master Psychology)
  - 3 = "Anderer Studiengang" (Other study program)
- **Description**: Current study program enrollment
- **Required**: Yes

#### Geschlecht (Gender)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "weiblich oder divers" (female or diverse)
  - 2 = "männlich" (male)
  - 3 = "anderes" (other)
  - 4 = "keine Angabe" (no response)
- **Description**: Gender identity of participant
- **Note**: n = 4 diverse persons included in first group
- **Required**: Yes

#### Wohnstatus (Living Situation)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "Bei meinen Eltern/Elternteil" (With parents)
  - 2 = "Wohngemeinschaft/WG" (Shared apartment)
  - 3 = "Studentenwohnheim" (Student dormitory)
  - 4 = "Eigene Wohnung/Haus" (Own apartment/house)
  - 5 = "Mit Partner/in zusammen" (With partner)
  - 6 = "Anderes" (Other)
- **Description**: Current living arrangement
- **Required**: Yes

#### Wohn_Zusatz (Additional Living Information)
- **Type**: String (Text)
- **Length**: 83 characters maximum
- **Description**: Additional specification if "Other" selected for living situation
- **Required**: No (conditional on Wohnstatus = 6)

#### Haustier (Preferred Pet)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "Hund" (Dog)
  - 2 = "Katze" (Cat)
  - 3 = "Kleintier (Hamster, Kaninchen, etc.)" (Small animal)
  - 4 = "Fisch/Aquarium" (Fish/Aquarium)
  - 5 = "Vogel" (Bird)
  - 6 = "Exotisches Tier" (Exotic animal)
  - 7 = "Kein Haustier gewünscht" (No pet desired)
  - 8 = "Anderes" (Other)
- **Description**: Preferred or owned pet type
- **Required**: Yes

#### Haustier_Zusatz (Other Pet)
- **Type**: String (Text)
- **Length**: 3 characters maximum
- **Description**: Specification if "Other" selected for pet preference
- **Required**: No (conditional on Haustier = 8)

#### Rauchen (Smoking Status)
- **Type**: Numeric (Binary)
- **Values**:
  - 1 = "Ja" (Yes)
  - 2 = "Nein" (No)
- **Description**: Regular smoking behavior
- **Required**: Yes

#### Ernährung (Diet Type)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "Vegan" (Vegan)
  - 2 = "Vegetarisch" (Vegetarian)
  - 3 = "Mischkost/Omnivor" (Mixed diet/Omnivore)
  - 4 = "Pescetarisch (Fisch, aber kein Fleisch)" (Pescetarian)
  - 5 = "Andere spezielle Ernährung" (Other special diet)
- **Description**: Dietary preferences and restrictions
- **Required**: Yes

#### Ernährung_Zusatz (Other Diet)
- **Type**: String (Text)
- **Length**: 10 characters maximum
- **Description**: Specification if "Other" selected for diet type
- **Required**: No (conditional on Ernährung = 5)

#### Note_Englisch (English Grade)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "sehr gut (15-13 Punkte)" (Very good, 15-13 points)
  - 2 = "gut (12-10 Punkte)" (Good, 12-10 points)
  - 3 = "befriedigend (9-7 Punkte)" (Satisfactory, 9-7 points)
  - 4 = "ausreichend (6-4 Punkte)" (Sufficient, 6-4 points)
  - 5 = "mangelhaft (3-1 Punkte)" (Poor, 3-1 points)
  - 6 = "ungenügend (0 Punkte)" (Insufficient, 0 points)
  - 7 = "Englisch nicht belegt" (English not taken)
- **Description**: Final school grade in English
- **Required**: Yes

#### Note_Mathe (Mathematics Grade)
- **Type**: Numeric (Categorical)
- **Values**:
  - 1 = "sehr gut (15-13 Punkte)" (Very good, 15-13 points)
  - 2 = "gut (12-10 Punkte)" (Good, 12-10 points)
  - 3 = "befriedigend (9-7 Punkte)" (Satisfactory, 9-7 points)
  - 4 = "ausreichend (6-4 Punkte)" (Sufficient, 6-4 points)
  - 5 = "mangelhaft (3-1 Punkte)" (Poor, 3-1 points)
  - 6 = "ungenügend (0 Punkte)" (Insufficient, 0 points)
  - 7 = "Mathematik nicht belegt" (Mathematics not taken)
- **Description**: Final school grade in Mathematics
- **Required**: Yes

---

### Big Five Personality Inventory (BFI) Variables

All BFI items use a 5-point Likert scale:
1 = "Stimme überhaupt nicht zu" (Strongly disagree)
2 = "Stimme eher nicht zu" (Somewhat disagree)
3 = "Weder noch" (Neither agree nor disagree)
4 = "Stimme eher zu" (Somewhat agree)
5 = "Stimme voll und ganz zu" (Strongly agree)

#### Extraversion Dimension

**BFE_01**: "BIG FIVE-Extraversion: Ich gehe aus mir heraus, bin gesellig."
- *Translation*: I am outgoing, sociable
- *Reverse coded*: No

**BFE_02**: "BIG FIVE- Extraversion: Ich bin eher ruhig."
- *Translation*: I am rather quiet
- *Reverse coded*: Yes (BFE_02R)

**BFE_03**: "BIG FIVE- Extraversion: Ich bin eher schüchtern."
- *Translation*: I am rather shy
- *Reverse coded*: Yes (BFE_03R)

**BFE_04**: "BIG FIVE- Extraversion: Ich bin gesprächig."
- *Translation*: I am talkative
- *Reverse coded*: No

#### Agreeableness Dimension

**BFV_01**: "BIG FIVE- Verträglichkeit: Ich bin einfühlsam, warmherzig."
- *Translation*: I am empathetic, warm-hearted
- *Reverse coded*: No

**BFV_02**: "BIG FIVE-Verträglichkeit: Ich habe mit anderen wenig Mitgefühl."
- *Translation*: I have little sympathy for others
- *Reverse coded*: Yes (BFV_02R)

**BFV_03**: "BIG FIVE- Verträglichkeit: Ich bin hilfsbereit und selbstlos."
- *Translation*: I am helpful and selfless
- *Reverse coded*: No

**BFV_04**: "BIG FIVE-Verträglichkeit: Andere sind mir eher gleichgültig, egal."
- *Translation*: Others are rather indifferent to me
- *Reverse coded*: Yes (BFV_04R)

#### Conscientiousness Dimension

**BFG_01**: "BIG FIVE- Gewissenhaftigkeit: Ich bin eher unordentlich."
- *Translation*: I am rather disorganized
- *Reverse coded*: Yes (BFG_01R)

**BFG_02**: "BIG FIVE- Gewissenhaftigkeit: Ich bin systematisch, halte meine Sachen in Ordnung."
- *Translation*: I am systematic, keep my things in order
- *Reverse coded*: No

**BFG_03**: "BIG FIVE- Gewissenhaftigkeit: Ich mag es sauber und aufgeräumt."
- *Translation*: I like things clean and tidy
- *Reverse coded*: No

**BFG_04**: "BIG FIVE- Gewissenhaftigkeit: Ich bin eher der chaotische Typ, mache selten sauber."
- *Translation*: I am rather the chaotic type, rarely clean
- *Reverse coded*: Yes (BFG_04R)

#### Neuroticism Dimension

**BFN_01**: "BIG FIVE- Neurotizismus: Ich bleibe auch in stressigen Situationen gelassen."
- *Translation*: I remain calm even in stressful situations
- *Reverse coded*: Yes (BFN_01R)

**BFN_02**: "BIG FIVE- Neurotizismus: Ich reagiere leicht angespannt."
- *Translation*: I react easily tense
- *Reverse coded*: No

**BFN_03**: "BIG FIVE- Neurotizismus: Ich mache mir oft Sorgen."
- *Translation*: I often worry
- *Reverse coded*: No

**BFN_04**: "BIG FIVE- Neurotizismus: Ich werde selten nervös und unsicher."
- *Translation*: I rarely become nervous and insecure
- *Reverse coded*: Yes (BFN_04R)

#### Openness Dimension

**BFO_01**: "BIG FIVE- Offenheit: Ich bin vielseitig interessiert."
- *Translation*: I am interested in many things
- *Reverse coded*: No

**BFO_02**: "BIG FIVE- Offenheit: Ich meide philosophische Diskussionen."
- *Translation*: I avoid philosophical discussions
- *Reverse coded*: Yes (BFO_02R)

**BFO_03**: "BIG FIVE- Offenheit: Es macht mir Spaß gründlich über komplexe Dinge nachzudenken und sie zu verstehen."
- *Translation*: I enjoy thinking thoroughly about complex things and understanding them
- *Reverse coded*: No

**BFO_04**: "BIG FIVE - Offenheit: Mich interessieren abstrakte Überlegungen wenig."
- *Translation*: Abstract considerations interest me little
- *Reverse coded*: Yes (BFO_04R)

---

### Perceived Stress Questionnaire (PSQ) Variables

All PSQ items use the same 5-point Likert scale as BFI items.

**PSQ_02**: "Ich habe das Gefühl, dass zu viele Forderungen an mich gestellt werden."
- *Translation*: I feel that too many demands are placed on me
- *Reverse coded*: No

**PSQ_04**: "Ich habe zuviel zu tun."
- *Translation*: I have too much to do
- *Reverse coded*: No

**PSQ_16**: "Ich fühle mich gehetzt."
- *Translation*: I feel rushed
- *Reverse coded*: No

**PSQ_29**: "Ich habe genug Zeit für mich."
- *Translation*: I have enough time for myself
- *Reverse coded*: Yes (PSQ_29R)

**PSQ_30**: "Ich fühle mich unter Termindruck."
- *Translation*: I feel under time pressure
- *Reverse coded*: No

---

### Academic Motivation Scale (MWS) Variables

MWS items use a difficulty scale:
1 = "sehr schwer" (very difficult)
2 = "schwer" (difficult)  
3 = "mittelmäßig" (moderate)
4 = "leicht" (easy)
5 = "sehr leicht" (very easy)

**MWS_1_KK**: "MWS Subskala Kontakt und Kooperation (soziale Dimension): mit dem sozialen Klima im Studiengang zurechtzukommen (z. B. Konkurrenz aushalten)"
- *Translation*: Getting along with the social climate in the study program (e.g., tolerating competition)

**MWS_10_KK**: "MWS Subskala Kontakt und Kooperation (soziale Dimension): Teamarbeit zu organisieren (z. B. Lerngruppen finden)"
- *Translation*: Organizing teamwork (e.g., finding study groups)

**MWS_17_KK**: "MWS Subskala Kontakt und Kooperation (soziale Dimension): Kontakte zu Mitstudierenden zu knüpfen (z. B. für Lerngruppen, Freizeit)"
- *Translation*: Making contact with fellow students (e.g., for study groups, leisure)

**MWS_21_KK**: "MWS Subskala Kontakt und Kooperation (soziale Dimension): im Team zusammen zu arbeiten (z. B. gemeinsam Aufgaben bearbeiten, Referate vorbereiten)"
- *Translation*: Working together in teams (e.g., working on tasks together, preparing presentations)

---

### Academic Self-Efficacy and Satisfaction Variables

**Statistik_gutfolgen**: "Zustimmung_Ich bin in der Lage, Statistik zu erlernen"
- *Translation*: Agreement_I am able to learn statistics
- *Scale*: 5-point Likert scale (same as BFI)

**Statistik_selbstwirksam**: "Ich bin davon überzeugt, dass ich Statistik erfolgreich erlernen kann"
- *Translation*: I am convinced that I can successfully learn statistics
- *Scale*: 5-point Likert scale (same as BFI)

**Vor_Nachbereitung**: "Wieviele Stunden pro Woche planen Sie (ohne den Besuch der Veranstaltungen) für die Vor- und Nachbereitung der Statistikveranstaltungen zu investieren?"
- *Translation*: How many hours per week do you plan to invest (excluding attending classes) for preparation and follow-up of statistics courses?
- *Scale*: 7-point scale
  - 1 = "0 Stunden" (0 hours)
  - 2 = "1-2 Stunden" (1-2 hours)
  - 3 = "3-4 Stunden" (3-4 hours)
  - 4 = "5-6 Stunden" (5-6 hours)
  - 5 = "7-8 Stunden" (7-8 hours)
  - 6 = "9-10 Stunden" (9-10 hours)
  - 7 = "mehr als 10 Stunden" (more than 10 hours)

**Zufrieden_Hi_5st**: "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (5 Stufen)"
- *Translation*: How satisfied are you with your study location Hildesheim? (5 levels)
- *Scale*: 5-point satisfaction scale
  - 1 = "gar nicht zufrieden" (not satisfied at all)
  - 2 = "wenig zufrieden" (little satisfied)
  - 3 = "mittelmäßig zufrieden" (moderately satisfied)
  - 4 = "ziemlich zufrieden" (quite satisfied)
  - 5 = "sehr zufrieden" (very satisfied)

**Zufrieden_Hi_7st**: "Wie zufrieden sind Sie mit Ihrem Studienort Hildesheim? (7 Stufen)"
- *Translation*: How satisfied are you with your study location Hildesheim? (7 levels)
- *Scale*: 7-point satisfaction scale
  - 1 = "gar nicht zufrieden" (not satisfied at all)
  - 7 = "sehr zufrieden" (very satisfied)
  - (Intermediate levels 2-6 unlabeled)

**Persönlicher_Code**: "Code aus persönlichen Daten"
- *Translation*: Code from personal data
- *Type*: String (Text)
- *Length*: 8 characters
- *Description*: Personal code generated from demographic data for matching purposes
- *Note*: Automatically generated to maintain anonymity

---

### Recoded Variables (Generated During Analysis)

**Alter_VPN_rek**: Recoded age variable
- *Type*: Numeric (Continuous approximation)
- *Description*: Age categories converted to approximate numeric values for analysis

**BFE_02R**: Reverse coded BFE_02
**BFE_03R**: Reverse coded BFE_03
**BFV_02R**: Reverse coded BFV_02
**BFV_04R**: Reverse coded BFV_04
**BFG_01R**: Reverse coded BFG_01
**BFG_04R**: Reverse coded BFG_04
**BFN_01R**: Reverse coded BFN_01
**BFN_04R**: Reverse coded BFN_04
**BFO_02R**: Reverse coded BFO_02
**BFO_04R**: Reverse coded BFO_04
**PSQ_29R**: Reverse coded PSQ_29

*Note*: Reverse coding for 5-point scales calculated as: 6 - original_value

---

### Data Quality Variables (System Generated)

**Response_Time**: Time taken to respond to each item (seconds)
**Session_Duration**: Total session duration (minutes)
**Completion_Status**: Whether session was completed
**IP_Address**: Anonymized IP address for quality control
**Browser_Info**: Browser and device information
**Start_Time**: Session start timestamp
**End_Time**: Session end timestamp

---

### Analysis Variables (Computed)

**Extraversion_Score**: Mean of BFE items (reverse coded where applicable)
**Agreeableness_Score**: Mean of BFV items (reverse coded where applicable)
**Conscientiousness_Score**: Mean of BFG items (reverse coded where applicable)
**Neuroticism_Score**: Mean of BFN items (reverse coded where applicable)
**Openness_Score**: Mean of BFO items (reverse coded where applicable)
**Perceived_Stress_Score**: Mean of PSQ items (reverse coded where applicable)
**Academic_Motivation_Score**: Mean of MWS items
**Statistics_Self_Efficacy**: Mean of statistics items

---

## Data Collection Notes

- All data collected anonymously
- GDPR compliant data handling
- Cloud storage via Academic Cloud (sync.academiccloud.de)
- Study key: HILDESHEIM_2025
- Data format: JSON with structured metadata
- Quality checks: Response time monitoring, pattern detection
- Missing data: Handled via TAM multiple imputation where appropriate
