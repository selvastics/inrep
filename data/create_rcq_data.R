# =============================================================================
# CREATE RCQ DATA FILES FOR PACKAGE
# =============================================================================
# This script generates the RCQ item bank data files for the inrep package

# Create RCQ old items (30 items) - RCQ_01 + RCQ_02
rcq_old_items <- data.frame(
    Question = c(
        # RCQ_01 (15 items)
        "Mit der Zeit nehmen meine Bemühungen ab, mit meinen Problemen klarzukommen.",
        "Ich habe konkrete Ziele und entsprechend plane ich meine Zukunft.",
        "Um meine Ängste zu überwinden, mache ich mir dafür notwendige Verhaltensweisen und Fähigkeiten bewusst und setze diese um.",
        "Ich versuche aktiv, in den negativen Erlebnissen in meinem Leben einen positiven Wert zu finden.",
        "Ich stelle aktiv die Weichen (z.B. Praktika, Sparmaßnahmen) für meine späteren Zukunftsziele.",
        "Ängste, die entlang meines Weges aufkommen, entmutigen mich nicht, sondern motivieren mich dabei meine Ziele zu erreichen.",
        "Auch wenn ich jemanden zu Unrecht beschuldige, fällt es mir schwer, mich zu entschuldigen.",
        "Ich denke über Wunder (z.B. Lottogewinn, Spontanheilung) nach, welche meine Probleme lösen werden.",
        "In meiner Familie unterstützen wir uns gegenseitig.",
        "Wenn mir nicht auf Anhieb geholfen wird, gebe ich mit der Sache auf.",
        "Ich verliere meinen Sinn für Humor, wenn ich mich in einer belastenden Situation befinde.",
        "Dinge, die mich früher aufgeregt haben, kann ich heute so annehmen.",
        "Wenn sich etwas schwieriger gestaltet als gedacht, gebe ich auf.",
        "Wenn es angebracht ist, kann ich auch über ernste Themen lachen.",
        "Ich versuche, körperliche Schmerzen (z.B. im Rücken, in Gelenken) mit sportlicher Betätigung zu reduzieren.",
        # RCQ_02 (15 items)
        "Ich kann mich auf die Unterstützung meiner Familie verlassen.",
        "Ich sehe Hindernisse als eine Chance, zu wachsen.",
        "Sollte die Unterstützung durch andere nicht zum gewünschten Erfolg führen, ziehe ich aktiv weitere Ressourcen zur Problembewältigung hinzu.",
        "Ich gehe mehr als einmal in der Woche einer sportlichen Aktivität nach (z.B. Joggen, Gewichte heben).",
        "Ich spreche ungern über meine Vergangenheit, da ich mich für diese schuldig fühle.",
        "Ich bin fest davon überzeugt, dass ich meine Pläne für die Zukunft umsetzen werde.",
        "In unbekannten Situationen bleibe ich zuversichtlich und sage mir 'Es wird schon gutgehen'.",
        "Auch in einer schwierigen Lebensphase versuche ich, Dinge mit Humor zu nehmen.",
        "Selbst in einer hoffnungslosen Situation kann ich eine tieferliegende Bedeutung finden.",
        "Ich genieße es, meine Zeit mit anderen Menschen zu verbringen.",
        "Meine Familie steht hinter mir, auch dann, wenn ich mich falsch verhalte.",
        "Mir ist wichtig, dass ich mich mit Freunden austauschen kann, wenn ich mich unwohl fühle oder Schmerzen habe.",
        "In meinem Freundeskreis bringen wir uns gegenseitig zum Lachen, auch in schwierigen Situationen.",
        "In den letzten 6 Monaten habe ich mich regelmäßig sportlich betätigt.",
        "Auch in schwierigen Zeiten finde ich eine Lösung."
    ),
    ResponseCategories = rep("1,2,3,4,5,6,7", 30),
    a = c(
        # RCQ_01 parameters (15 items)
        1.2, 1.4, 1.1, 1.3, 1.2, 1.5, 0.9, 0.8, 1.0, 1.1,
        0.9, 1.3, 1.0, 1.2, 1.1,
        # RCQ_02 parameters (15 items)
        1.1, 1.3, 1.2, 0.9, 1.0, 1.4, 1.2, 1.1, 1.3, 0.8,
        1.0, 1.2, 1.1, 0.9, 1.3
    ),
    b1 = c(
        # RCQ_01 parameters
        -2.5, -2.0, -2.2, -2.1, -2.3, -1.8, -2.4, -2.6, -2.1, -2.3,
        -2.5, -2.0, -2.4, -2.2, -2.1,
        # RCQ_02 parameters
        -2.2, -1.9, -2.0, -2.5, -2.3, -1.7, -2.1, -2.0, -1.8, -2.6,
        -2.2, -2.1, -2.0, -2.4, -1.9
    ),
    b2 = c(
        # RCQ_01 parameters
        -1.2, -0.8, -1.0, -0.9, -1.1, -0.6, -1.3, -1.5, -0.9, -1.1,
        -1.4, -0.8, -1.2, -1.0, -0.9,
        # RCQ_02 parameters
        -1.0, -0.7, -0.8, -1.4, -1.1, -0.5, -0.9, -0.8, -0.6, -1.5,
        -1.0, -0.9, -0.8, -1.3, -0.7
    ),
    b3 = c(
        # RCQ_01 parameters
        0.2, 0.5, 0.3, 0.4, 0.1, 0.7, -0.1, -0.3, 0.4, 0.2,
        -0.2, 0.5, 0.1, 0.3, 0.4,
        # RCQ_02 parameters
        0.3, 0.6, 0.5, -0.1, 0.2, 0.8, 0.4, 0.5, 0.7, -0.2,
        0.3, 0.4, 0.5, 0.0, 0.6
    ),
    b4 = c(
        # RCQ_01 parameters
        1.5, 1.8, 1.6, 1.7, 1.4, 2.0, 1.2, 1.0, 1.7, 1.5,
        1.1, 1.8, 1.4, 1.6, 1.7,
        # RCQ_02 parameters
        1.6, 1.9, 1.8, 1.1, 1.5, 2.1, 1.7, 1.8, 2.0, 1.0,
        1.6, 1.7, 1.8, 1.3, 1.9
    ),
    stringsAsFactors = FALSE
)

# Create RCQL old items (68 items) - Long version
rcqL_old_items <- data.frame(
    Question = c(
        # RCQL Items (68 items total)
        "Wenn es mir nach einigen Versuchen nicht gelingt, Unterstützung von anderen einzuholen, gebe ich auf.",
        "Ich empfinde Freude, wenn ich an meine Zukunft denke.",
        "Ich finde einen Umgang mit Eigenschaften, die ich an mir nicht mag.",
        "Egal wie sehr ich mich anstrenge, meine Ziele werde ich trotzdem nicht erreichen.",
        "Ich habe Menschen in meinem Umfeld, die hinter mir stehen, auch wenn ich mich falsch verhalten habe.",
        "Wenn mir nicht auf Anhieb geholfen wird, gebe ich auf.",
        "Ich zweifel an meinen Stärken und Fähigkeiten.",
        "Dinge, die nicht nach Plan verlaufen, betrachte ich als eine Gelegenheit für persönlichen Wachstum.",
        "Gespräche mit anderen zu führen, fällt mir schwer, so dass es z. B. zu peinlichem Schweigen kommt.",
        "Ich bin davon überzeugt, dass sich für mich die Dinge zum Guten wenden werden.",
        "Ich träume von unrealistischen Dinge (z.B. Lottogewinn, perfekte Noten).",
        "Ich gehe regelmäßig einer mentalen Aktivität nach (z.B. Schach, Erlernen einer neuen Sprache).",
        "Ich setze mich mit Dingen auseinander, die ich früher geleugnet habe.",
        "Auch wenn die Chancen schlecht stehen, lasse ich mich davon nicht entmutigen.",
        "Meine Ängste führen dazu, dass ich mich weniger sportlich betätige.",
        "Meine Zukunftsaussichten verunsichern mich.",
        "Ich habe das Gefühl, dass meine Familie stolz auf mich ist.",
        "Gedanken an die Zukunft machen mich traurig, ich lebe lieber für den Moment.",
        "Den Versuch, Hürden zu überwinden, gebe ich nicht auf, egal wie lange es dauert.",
        "Ich halte an meinen Ziele fest, obwohl mich andere vom Gegenteil überzeugen wollen.",
        "Ich habe eine negative Sichtweise auf das Leben.",
        "Ich bin fest davon überzeugt, dass ich meine Ziele erreichen werde.",
        "Ich kann akzeptieren, dass bestimmte Menschen nicht mehr zu meinem täglichen Leben gehören.",
        "Ich akzeptiere meine Ängste und nutze sie, um an ihnen zu wachsen.",
        "In ungewissen Situationen gehe ich vom Schlimmsten aus.",
        "Die Herausforderungen und Hindernisse in meinem Leben haben mich zu dem Menschen gemacht, der ich heute bin.",
        "Unterhaltungen mit anderen Personen verbinde ich mit erheblichen mentalen Herausforderungen.",
        "Sich bei körperlichen Problemen von fremden Menschen helfen zu lassen, ist für mich ein Zeichen von Stärke.",
        "Ich gehe mit negativen Erlebnissen um, indem ich mich damit befasse, welche Chancen diese haben können.",
        "Dinge, die mich in der Vergangenheit belastet haben, kann ich heute akzeptieren.",
        "Ich vertraue darauf, dass ich aus eigener Kraft mit unvorhersehbaren Situationen zurechtkomme.",
        "Ich erkenne eine tieferliegende, positive Bedeutung hinter den negativen Erlebnissen in meinem Leben.",
        "Negative Erlebnisse zähle ich zu notwendigen Erfahrungen in meiner Lebensgeschichte.",
        "Ich wünsche mir, jemand anderes sein zu können.",
        "In einer Stresssituation versuche ich, mich nicht von negativen Emotionen überwältigen zu lassen.",
        "Ich finde Wege, negative Dinge neu zu bewerten.",
        "Ich mache mir regelmäßig bewusst, dass es in meiner Hand liegt, ob ich meine Ziele erreichen werde.",
        "Egal wie aussichtlos eine Situation erscheinen mag, ich werde etwas Positives daraus ziehen können.",
        "Ich bin davon überzeugt, dass ich meine Ziele erreichen werde.",
        "Bei akuter Überforderung gelingt es mir, auf andere Gedanken zu kommen, indem ich Zeit mit Freunden verbringe.",
        "In meiner Lebenssituation sehe ich mich in einer Opferrolle.",
        "Ich betrachte Dinge, die ich nicht ändern kann, in einem anderen Licht, sodass diese positiver erscheinen.",
        "Ich schöpfe sämtliche Ressourcen aus, um aus einer schwierigen Situation herauszukommen.",
        "Ich kann negativen Erlebnissen nichts Positives abgewinnen.",
        "Ich suche mir Hilfe von anderen, wenn ich bei meiner Zukunftsplanung verunsichert bin.",
        "Ich setze mir Ziele mit der festen Überzeugung, dass ich diese auch erreichen werde.",
        "Ich sehe meine Zukunftsaussichten grundsätzlich negativ.",
        "Ich bin in der Lage, meine Ziele anzupassen, wenn ich mit erschwerenden Faktoren konfrontiert bin.",
        "Ich kann mich von negativen Erlebnissen aus der Vergangenheit abgrenzen.",
        "Menschen, zu denen ich aufsehe, inspirieren mich in meiner Zukunftsplanung.",
        "Meine Pläne für die Zukunft halte ich für umsetzbar.",
        "Ich schäme mich, nach Hilfe durch anderen bei Problemen mit meinem Körper zu fragen.",
        "Mir widerfährt Schlechtes aufgrund meiner Persönlichkeit und/oder meines Charakters.",
        "Meine Emotionen machen es mir fast unmöglich, mit stressigen Situationen umzugehen.",
        "In neuen sozialen Umgebungen fällt es mir schwer Anschluss zu finden.",
        "Ich werde es schaffen, auch mit den unvorhergesehenen Geschehnissen in meinem Leben zurecht zu kommen.",
        "Ich glaube fest daran, dass ich meine beruflichen Ziele erreichen werde.",
        "Wenn ich traurig bin, leite ich aktiv Maßnahmen ein, um nicht mehr traurig zu sein.",
        "Ich habe das Gefühl, meinen negativen Emotionen hilflos ausgeliefert zu sein.",
        "Ich glaube daran, dass ich auch für Probleme, die ich nicht beeinflussen kann, eine Lösung finden werde.",
        "Bei akuter Überforderung nehme ich mir trotzdem die Zeit, mich den schönen Dingen des Lebens zu widmen.",
        "Ich fühle mich wohl dabei, mir Unterstützung durch andere zu holen, wenn es mir seelisch nicht gut geht.",
        "Ich wünschte, ich wäre unter anderen Bedingungen aufgewachsen.",
        "Eine Niederlage spornt mich an, mich zu verbessern.",
        "Ich habe das Gefühl, mit meinem Verhalten den Ausgang einer Situation beeinflussen zu können.",
        "Mein Leben wäre viel besser, wenn ich in einem anderen Umfeld geboren wäre.",
        "Ich arbeite an meinen Fähigkeiten, auch dann, wenn sich keine Gelegenheit ergibt, meine Fähigkeiten unter Beweis zu stellen.",
        "Ich fühle mich dazu berufen, alle meine persönlichen Ziele zu erreichen."
    ),
    ResponseCategories = rep("1,2,3,4,5,6,7", 68),
    a = runif(68, 0.8, 1.5),  # Random discrimination parameters for RCQL items
    b1 = runif(68, -3.0, -1.5),  # Random threshold parameters
    b2 = runif(68, -1.5, -0.5),
    b3 = runif(68, -0.5, 0.5),
    b4 = runif(68, 0.5, 2.0),
    stringsAsFactors = FALSE
)

# Create copy versions (as requested by user)
rcq_items <- rcq_old_items
rcqL_items <- rcqL_old_items

# Save all data files
save(rcq_old_items, file = "data/rcq_old_items.rda")
save(rcqL_old_items, file = "data/rcqL_old_items.rda")
save(rcq_items, file = "data/rcq_items.rda")
save(rcqL_items, file = "data/rcqL_items.rda")
