# Ensure inrep is installed
#Note this is still under active development

library(inrep)
library(shiny)
library(ggplot2)
library(broom)
library(emmeans)
library(ggthemes)
library(DT)
library(shinycssloaders)
library(patchwork)
library(markdown)
library(shinyjs)

# =============================================================================
# RCQ STUDY - RESILIENCE AND COPING QUESTIONNAIRE
# =============================================================================
# Complete item bank with scoring for resilience, coping, and related constructs
# German language implementation with full data recording

# Token handling from URL
attach_finish_early_observer <- function(session) {
    if (is.null(session)) return(invisible(NULL))
    tryCatch({
        session$onFlushed(function() {
            shiny::observeEvent(session$input$finish_early, {
                tryCatch({
                    shiny::stopApp()
                }, error = function(e) {
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
# CLOUD STORAGE CONFIGURATION
# =============================================================================
WEBDAV_URL <- "https://sync.academiccloud.de/public.php/webdav/"
WEBDAV_PASSWORD <- "inreptest"
WEBDAV_SHARE_TOKEN <- "Y51QPXzJVLWSAcb"

# =============================================================================
# COMPLETE ITEM BANK - RCQ ITEMS
# =============================================================================

rcq_items <- data.frame(
    id = c(
        # RCQ_01: Resilient Coping (15 items)
        "RCQ_01_01", "RCQ_01_02", "RCQ_01_03", "RCQ_01_04", "RCQ_01_05",
        "RCQ_01_06", "RCQ_01_07", "RCQ_01_08", "RCQ_01_09", "RCQ_01_10",
        "RCQ_01_11", "RCQ_01_12", "RCQ_01_13", "RCQ_01_14", "RCQ_01_15",
        # RCQ_02: Resilient Coping (15 items)
        "RCQ_02_01", "RCQ_02_02", "RCQ_02_03", "RCQ_02_04", "RCQ_02_05",
        "RCQ_02_06", "RCQ_02_07", "RCQ_02_08", "RCQ_02_09", "RCQ_02_10",
        "RCQ_02_11", "RCQ_02_12", "RCQ_02_13", "RCQ_02_14", "RCQ_02_15",
        # BFI: Big Five Personality (30 items)
        "BFI_01", "BFI_02", "BFI_03", "BFI_04", "BFI_05", "BFI_06",
        "BFI_07", "BFI_08", "BFI_09", "BFI_10", "BFI_11", "BFI_12",
        "BFI_13", "BFI_14", "BFI_15", "BFI_16", "BFI_17", "BFI_18",
        "BFI_19", "BFI_20", "BFI_21", "BFI_22", "BFI_23", "BFI_24",
        "BFI_25", "BFI_26", "BFI_27", "BFI_28", "BFI_29", "BFI_30",
        # Political Self-Efficacy (10 items)
        "PSE_01", "PSE_02", "PSE_03", "PSE_04", "PSE_05",
        "PSE_06", "PSE_07", "PSE_08", "PSE_09", "PSE_10",
        # Work and Organizational Climate (8 items)
        "WOC_01", "WOC_02", "WOC_03", "WOC_04", "WOC_05",
        "WOC_06", "WOC_07", "WOC_08",
        # Brief COPE (28 items)
        "BC_01", "BC_02", "BC_03", "BC_04", "BC_05", "BC_06", "BC_07",
        "BC_08", "BC_09", "BC_10", "BC_11", "BC_12", "BC_13", "BC_14",
        "BC_15", "BC_16", "BC_17", "BC_18", "BC_19", "BC_20", "BC_21",
        "BC_22", "BC_23", "BC_24", "BC_25", "BC_26", "BC_27", "BC_28",
        # Mindfulness (14 items)
        "MF_01", "MF_02", "MF_03", "MF_04", "MF_05", "MF_06", "MF_07",
        "MF_08", "MF_09", "MF_10", "MF_11", "MF_12", "MF_13", "MF_14",
        # Life Satisfaction (5 items)
        "LS_01", "LS_02", "LS_03", "LS_04", "LS_05",
        # BRSC: Brief Resilient Coping Scale (4 items)
        "BRSC_01", "BRSC_02", "BRSC_03", "BRSC_04",
        # Self-Efficacy (10 items)
        "SE_01", "SE_02", "SE_03", "SE_04", "SE_05",
        "SE_06", "SE_07", "SE_08", "SE_09", "SE_10",
        # Procrastination (9 items)
        "PC_01", "PC_02", "PC_03", "PC_04", "PC_05",
        "PC_06", "PC_07", "PC_08", "PC_09",
        # MCCS: Making Meaning (9 items)
        "MC_01", "MC_02", "MC_03", "MC_04", "MC_05",
        "MC_06", "MC_07", "MC_08", "MC_09",
        # RS-11: Resilience (11 items)
        "RS_01", "RS_02", "RS_03", "RS_04", "RS_05", "RS_06", "RS_07",
        "RS_08", "RS_09", "RS_10", "RS_11",
        # RSA: Resilience Scale for Adults (33 items)
        "RSA_01", "RSA_02", "RSA_03", "RSA_04", "RSA_05", "RSA_06",
        "RSA_07", "RSA_08", "RSA_09", "RSA_10", "RSA_11", "RSA_12",
        "RSA_13", "RSA_14", "RSA_15", "RSA_16", "RSA_17", "RSA_18",
        "RSA_19", "RSA_20", "RSA_21", "RSA_22", "RSA_23", "RSA_24",
        "RSA_25", "RSA_26", "RSA_27", "RSA_28", "RSA_29", "RSA_30",
        "RSA_31", "RSA_32", "RSA_33",
        # RCQL: Long RCQ Items (68 items total: 15+15+15+15+8)
        "RCQL_01_01", "RCQL_01_02", "RCQL_01_03", "RCQL_01_04", "RCQL_01_05",
        "RCQL_01_06", "RCQL_01_07", "RCQL_01_08", "RCQL_01_09", "RCQL_01_10",
        "RCQL_01_11", "RCQL_01_12", "RCQL_01_13", "RCQL_01_14", "RCQL_01_15",
        "RCQL_02_01", "RCQL_02_02", "RCQL_02_03", "RCQL_02_04", "RCQL_02_05",
        "RCQL_02_06", "RCQL_02_07", "RCQL_02_08", "RCQL_02_09", "RCQL_02_10",
        "RCQL_02_11", "RCQL_02_12", "RCQL_02_13", "RCQL_02_14", "RCQL_02_15",
        "RCQL_03_01", "RCQL_03_02", "RCQL_03_03", "RCQL_03_04", "RCQL_03_05",
        "RCQL_03_06", "RCQL_03_07", "RCQL_03_08", "RCQL_03_09", "RCQL_03_10",
        "RCQL_03_11", "RCQL_03_12", "RCQL_03_13", "RCQL_03_14", "RCQL_03_15",
        "RCQL_04_01", "RCQL_04_02", "RCQL_04_03", "RCQL_04_04", "RCQL_04_05",
        "RCQL_04_06", "RCQL_04_07", "RCQL_04_08", "RCQL_04_09", "RCQL_04_10",
        "RCQL_04_11", "RCQL_04_12", "RCQL_04_13", "RCQL_04_14", "RCQL_04_15",
        "RCQL_05_01", "RCQL_05_02", "RCQL_05_03", "RCQL_05_04", "RCQL_05_05",
        "RCQL_05_06", "RCQL_05_07", "RCQL_05_08", "RCQL_05_09", "RCQL_05_10",
        "RCQL_05_11", "RCQL_05_12", "RCQL_05_13", "RCQL_05_14", "RCQL_05_15",
        "RCQL_05_16", "RCQL_05_17", "RCQL_05_18", "RCQL_05_19", "RCQL_05_20"
    ),
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
        "Auch in schwierigen Zeiten finde ich eine Lösung.",
        # BFI (30 items)
        "Ich bin eher ruhig.", "Ich bin einfühlsam, warmherzig.", "Ich bin eher unordentlich.",
        "Ich mache mir oft Sorgen.", "Ich kann mich für Kunst, Musik und Literatur begeistern.",
        "Ich neige dazu, die Führung zu übernehmen.", "Ich bin manchmal unhöflich und schroff.",
        "Ich neige dazu, Aufgaben vor mir her zu schieben.", "Ich bin oft deprimiert, niedergeschlagen.",
        "Mich interessieren abstrakte Überlegungen wenig.", "Ich bin voller Energie und Tatendrang.",
        "Ich schenke anderen leicht Vertrauen, glaube an das Gute im Menschen.",
        "Ich bin verlässlich, auf mich kann man zählen.", "Ich bin ausgeglichen, nicht leicht aus der Ruhe zu bringen.",
        "Ich bin originell, entwickle neue Ideen.", "Ich gehe aus mir heraus, bin gesellig.",
        "Andere sind mir eher gleichgültig, egal.", "Ich mag es sauber und aufgeräumt.",
        "Ich bleibe auch in stressigen Situationen gelassen.", "Ich bin nicht sonderlich kunstinteressiert.",
        "In einer Gruppe lasse ich lieber anderen die Entscheidung.",
        "Ich begegne anderen mit Respekt.", "Ich bleibe an einer Aufgabe dran, bis sie erledigt ist.",
        "Ich bin selbstsicher, mit mir zufrieden.", "Es macht mir Spaß, gründlich über komplexe Dinge nachzudenken und sie zu verstehen.",
        "Ich bin weniger aktiv und unternehmungslustig als andere.",
        "Ich neige dazu, andere zu kritisieren.", "Ich bin manchmal ziemlich nachlässig.",
        "Ich kann launisch sein, habe schwankende Stimmungen.",
        "Ich bin nicht besonders einfallsreich.",
        # PSE (10 items)
        "Ich fühle mich in der Lage, meine eigene politische Meinung offen zu bekunden.",
        "Ich fühle mich in der Lage, mich zu vergewissern, dass Politiker ihre Wahlversprechen halten.",
        "Ich fühle mich in der Lage, Werbung für politische Bewegungen zu machen.",
        "Ich fühle mich in der Lage, persönlichen Kontakt mit Politikern aufzunehmen.",
        "Ich fühle mich in der Lage, die Wahl von Führungspersonen zu beeinflussen.",
        "Ich fühle mich in der Lage, eine Öffentlichkeitskampagne durchzuführen.",
        "Ich fühle mich in der Lage, aktiv Wahlwerbung zu machen.",
        "Ich fühle mich in der Lage, andere zu mobilisieren.",
        "Ich fühle mich in der Lage, Geld für eine politische Bewegung zu sammeln.",
        "Ich fühle mich in der Lage, politische Vertreter kritisch zu überwachen.",
        # WOC (8 items)
        "In der Regel gehe ich gerne zur Arbeit.",
        "Die für meine Arbeit bedeutsamen Zusammenhänge verstehe ich.",
        "Wofür ich arbeite, macht aus meiner Sicht Sinn.",
        "Die Anforderungen an mich sind mir klar.",
        "Die Arbeit wirkt auf mein sonstiges Leben bereichernd.",
        "Bezüglich der notwendigen Qualifikationen bin ich auf dem Laufenden.",
        "Meine Persönlichkeit und meine beruflichen Möglichkeiten passen zusammen.",
        "Die Belastungen können gut bewältigt werden.",
        # Brief COPE (28 items)
        "Ich habe mich mit Arbeit oder anderen Sachen beschäftigt, um auf andere Gedanken zu kommen.",
        "Ich habe mich darauf konzentriert, etwas an meiner Situation zu verändern.",
        "Ich habe mir eingeredet, daß das alles nicht wahr ist.",
        "Ich habe Alkohol oder andere Mittel zu mir genommen, um mich besser zu fühlen.",
        "Ich habe aufmunternde Unterstützung von anderen erhalten.",
        "Ich habe es aufgegeben, mich damit zu beschäftigen.",
        "Ich habe aktiv gehandelt, um die Situation zu verbessern.",
        "Ich wollte einfach nicht glauben, daß mir das passiert.",
        "Ich habe meinen Gefühlen freien Lauf gelassen.",
        "Ich habe andere Menschen um Hilfe und Rat gebeten.",
        "Um das durchzustehen, habe ich mich mit Alkohol oder anderen Mitteln besänftigt.",
        "Ich habe versucht, die Dinge von einer positiveren Seite zu betrachten.",
        "Ich habe mich selbst kritisiert und mir Vorwürfe gemacht.",
        "Ich habe versucht, mir einen Plan zu überlegen, was ich tun kann.",
        "Jemand hat mich getröstet und mir Verständnis entgegengebracht.",
        "Ich habe versucht, die Situation in den Griff zu kriegen.",
        "Ich habe versucht, etwas Gutes in dem zu finden, was mir passiert ist.",
        "Ich habe Witze darüber gemacht.",
        "Ich habe etwas unternommen, um mich abzulenken.",
        "Ich habe mich damit abgefunden, daß es passiert ist.",
        "Ich habe offen gezeigt, wie schlecht ich mich fühle.",
        "Ich habe versucht, Halt in meinem Glauben zu finden.",
        "Ich habe versucht, von anderen Menschen Rat oder Hilfe einzuholen.",
        "Ich habe gelernt, damit zu leben.",
        "Ich habe mir viele Gedanken darüber gemacht, was hier das Richtige wäre.",
        "Ich habe mir für die Dinge, die mir widerfahren sind, selbst die Schuld gegeben.",
        "Ich habe gebetet oder meditiert.",
        "Ich habe alles mit Humor genommen.",
        # Mindfulness (14 items)
        "Ich bin offen für die Erfahrung des Augenblicks.",
        "Ich spüre in meinen Körper hinein, sei es beim Kochen, Putzen, Essen, Reden.",
        "Wenn ich merke, dass ich abwesend war, kehre ich sanft zur Erfahrung des Augenblicks zurück.",
        "Ich kann mich selbst wertschätzen.",
        "Ich achte auf die Motive meiner Handlungen.",
        "Ich sehe meine Fehler und Schwierigkeiten, ohne mich zu verurteilen.",
        "Ich bin in Kontakt mit meinen Erfahrungen, hier und jetzt.",
        "Ich nehme unangenehme Erfahrungen an.",
        "Ich bin mir selbst gegenüber freundlich, wenn Dinge schief laufen.",
        "Ich beobachte meine Gefühle, ohne mich in ihnen zu verlieren.",
        "In schwierigen Situationen kann ich inne halten.",
        "Ich erlebe Momente innerer Ruhe und Gelassenheit.",
        "Ich bin ungeduldig mit mir und meinen Mitmenschen.",
        "Ich kann darüber lächeln, wenn ich sehe, wie ich mir manchmal das Leben schwer mache.",
        # Life Satisfaction (5 items)
        "In den meisten Bereichen entspricht mein Leben meinen Idealvorstellungen.",
        "Meine Lebensbedingungen sind ausgezeichnet.",
        "Ich bin mit meinem Leben zufrieden.",
        "Bisher habe ich die wesentlichen Dinge erreicht, die ich mir für mein Leben wünsche.",
        "Wenn ich mein Leben noch einmal leben könnte, würde ich kaum etwas ändern.",
        # BRSC: Brief Resilient Coping Scale (4 items)
        "Ich suche kreative Wege, um schwierige Situationen zu ändern.",
        "Unabhängig davon, was mir passiert, kann ich meine Reaktion darauf kontrollieren.",
        "Ich glaube, ich kann in positiver Weise durch den Umgang mit schwierigen Situationen wachsen.",
        "Ich suche aktiv nach Wegen, die Verluste, die ich in meinem Leben erfahren habe, zu ersetzen.",
        # Self-Efficacy (10 items)
        "Wenn sich Widerstände auftun, finde ich Mittel und Wege, mich durchzusetzen.",
        "Die Lösung schwieriger Probleme gelingt mir immer, wenn ich mich darum bemühe.",
        "Es bereitet mir keine Schwierigkeiten, meine Absichten und Ziele zu verwirklichen.",
        "In unerwarteten Situationen weiß ich immer, wie ich mich verhalten soll.",
        "Auch bei überraschenden Ereignissen glaube ich, dass ich gut mit ihnen zurechtkommen kann.",
        "Schwierigkeiten sehe ich gelassen entgegen, weil ich meinen Fähigkeiten immer vertrauen kann.",
        "Was auch immer passiert, ich werde schon klarkommen.",
        "Für jedes Problem kann ich eine Lösung finden.",
        "Wenn eine neue Sache auf mich zukommt, weiß ich, wie ich damit umgehen kann.",
        "Wenn ein Problem auftaucht, kann ich es aus eigener Kraft meistern.",
        # Procrastination (9 items)
        "Ich ertappe mich häufig dabei, Aufgaben zu erledigen, die ich eigentlich schon vor Tagen tun wollte.",
        "Ich erledige Aufgaben immer erst kurz vor dem Abgabetermin.",
        "Selbst kleine Sachen, bei denen man sich nur hinsetzen und sie erledigen müsste, bleiben häufig für Tage liegen.",
        "Bei der Vorbereitung auf einen Abgabetermin vergeude ich häufig meine Zeit mit anderen Dingen.",
        "Normalerweise fange ich mit einer Arbeitsaufgabe gleich an, wenn ich sie bekommen habe.",
        "Ich bin häufig mit Aufgaben früher fertig als nötig.",
        "Normalerweise erledige ich am Tag alle Dinge, die ich geplant hatte.",
        "Ich sage dauernd: 'Das mache ich morgen'.",
        "Im Allgemeinen erledige ich alles, was ich machen wollte, bevor ich mich am Abend hinsetze.",
        # Making Meaning (9 items)
        "Ich hoffe auf das Beste.",
        "Ich habe einen persönlichen Sinn in der aktuellen Situation gefunden.",
        "Ich tue jeden Tag etwas Produktives.",
        "Ich helfe anderen während dieser Zeit.",
        "Ich tue noch immer das, was am Wichtigsten in meinem Leben ist.",
        "Ich habe Vertrauen, dass etwas Gutes aus der aktuellen Situation hervorkommen wird.",
        "Ich nutze diese Situation, um meinen geliebten Menschen näher zu kommen.",
        "Ich bin dankbar für mein Leben, so wie es ist.",
        "Ich werde aus dieser Situation stärker hervorgehen, als ich es vorher war.",
        # RS-11 (11 items)
        "Wenn ich Pläne habe, verfolge ich sie auch.",
        "Normalerweise schaffe ich alles irgendwie.",
        "Es ist mir wichtig, an vielen Dingen interessiert zu bleiben.",
        "Ich mag mich.",
        "Ich kann mehrere Dinge gleichzeitig bewältigen.",
        "Ich bin entschlossen.",
        "Ich behalte an vielen Dingen Interesse.",
        "Ich finde öfter etwas, worüber ich lachen kann.",
        "Normalerweise kann ich eine Situation aus mehreren Perspektiven betrachten.",
        "Ich kann mich auch überwinden, Dinge zu tun, die ich eigentlich nicht machen will.",
        "In mir steckt genügend Energie, um alles zu machen, was ich machen muss.",
        # RSA (33 items)
        "Wenn etwas Unvorhersehbares passiert, bin ich oft verunsichert / finde ich immer eine Lösung",
        "Meine Pläne für die Zukunft sind schwer umsetzbar / möglicherweise umsetzbar",
        "Ich genieße es, mit anderen Personen zusammen zu sein / alleine zu sein",
        "Was meine Familie wichtig hält, unterscheidet sich von meinen Vorstellungen / deckt sich mit meinen Vorstellungen",
        "Persönliche Themen kann ich mit niemanden besprechen / Freunden besprechen",
        "Ich bin in Bestform, wenn ich ein erstrebenswertes Ziel habe / einen Tag nach dem anderen angehen kann",
        "Meine persönlichen Probleme weiß ich zu lösen / kann ich nicht lösen",
        "Ich empfinde meine Zukunftsaussichten als sehr vielversprechend / unsicher",
        "Mich in sozialen Situationen flexibel zu verhalten, ist mir nicht wichtig / ist mir wirklich wichtig",
        "Ich fühle mich zusammen mit meiner Familie sehr glücklich / sehr unglücklich",
        "Menschen, die mich ermutigen können, sind nahe Freunde / niemand",
        "Wenn ich neue Dinge beginne, plane ich kaum / bevorzuge einen Plan",
        "Meine Beurteilungen und Entscheidungen zweifle ich oft an / vertraue ich",
        "Von meinen Zielen weiß ich, wie ich sie erreiche / bin ich unsicher",
        "Neue Freundschaften schließen fällt mir leicht / fällt mir schwer",
        "Charakteristisch für meine Familie ist fehlender Zusammenhalt / guter Zusammenhalt",
        "Die Bindungen zwischen meinen Freunden sind schwach / stark",
        "Ich bin gut darin, meine Zeit zu organisieren / zu vergeuden",
        "Der Glaube an mich selbst bringt mich durch schwierige Zeiten / hilft mir kaum",
        "Meine Ziele für die Zukunft sind unklar / gut durchdacht",
        "Neue Leute kennenlernen ist schwer / kann ich gut",
        "In schwierigen Zeiten sind die Zukunftserwartungen meiner Familie positiv / düster",
        "Wenn ein Familienangehöriger eine Krise erlebt, werde ich sofort informiert / dauert es eine Weile",
        "Regeln und Routine fehlen in meinem Alltag / sind Teil meines Alltags",
        "In schwierigen Zeiten habe ich die Tendenz, alles düster zu sehen / etwas Gutes zu finden",
        "Wenn ich mit anderen zusammen bin, lache ich leicht / lache ich selten",
        "Meine Familienangehörigen geben sich untereinander keinen Rückhalt / verhalten sich untereinander loyal",
        "Unterstützt werde ich von Freunden / niemandem",
        "Für Geschehnisse, die ich nicht beeinflussen kann, schaffe ich es, mich abzufinden / sind eine ständige Ursache für Sorgen",
        "Geeignete Themen für Konversation zu finden fällt mir schwer / leicht",
        "In meiner Familie mögen wir es, Dinge zusammen zu machen / alleine zu machen",
        "Wenn nötig, habe ich niemanden, der mir hilft / immer jemanden",
        "Meine nahen Freunde schätzen meine persönlichen Eigenschaften / schätzen sie nicht",
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
        "Ich schäme mich, nach Hilfe durch andere bei Problemen mit meinem Körper zu fragen.",
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
        "Ich fühle mich dazu berufen, alle meine persönlichen Ziele zu erreichen.",
        # Additional RCQL items (12 items) - Placeholders to be revised by user
        "In herausfordernden Zeiten bleibe ich meinen Zielen treu.",
        "Ich finde Wege, auch aus schwierigen Situationen gestärkt hervorzugehen.",
        "Meine Resilienz hilft mir, Rückschläge zu überwinden.",
        "Ich nutze meine Erfahrungen, um mich weiterzuentwickeln.",
        "Auch unter Druck bewahre ich einen klaren Kopf.",
        "Ich vertraue auf meine Fähigkeit, Probleme zu lösen.",
        "Schwierige Situationen sehe ich als Chance zum Wachsen.",
        "Ich bin überzeugt, dass ich meine Ziele erreichen kann.",
        "Meine innere Stärke trägt mich durch herausfordernde Phasen.",
        "Ich bleibe optimistisch, auch wenn die Dinge schwierig werden.",
        "Meine Copingstrategien helfen mir, mit Stress umzugehen.",
        "Ich bin zuversichtlich in Bezug auf meine Zukunft."
    ),
    ResponseCategories = rep("1,2,3,4,5,6,7", 281),
    b = rep(0, 281),
    a = rep(1, 281),
    stringsAsFactors = FALSE
)

# =============================================================================
# RCQ OLD ITEMS - 30 ITEMS (SIMILAR TO MATH AND BFI STRUCTURE)
# =============================================================================

rcq_old_items <- data.frame(
    id = c(
        # RCQ_01: Resilient Coping (15 items)
        "RCQ_01_01", "RCQ_01_02", "RCQ_01_03", "RCQ_01_04", "RCQ_01_05",
        "RCQ_01_06", "RCQ_01_07", "RCQ_01_08", "RCQ_01_09", "RCQ_01_10",
        "RCQ_01_11", "RCQ_01_12", "RCQ_01_13", "RCQ_01_14", "RCQ_01_15",
        # RCQ_02: Resilient Coping (15 items)
        "RCQ_02_01", "RCQ_02_02", "RCQ_02_03", "RCQ_02_04", "RCQ_02_05",
        "RCQ_02_06", "RCQ_02_07", "RCQ_02_08", "RCQ_02_09", "RCQ_02_10",
        "RCQ_02_11", "RCQ_02_12", "RCQ_02_13", "RCQ_02_14", "RCQ_02_15"
    ),
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
    b = rep(0, 30),
    a = rep(1, 30),
    stringsAsFactors = FALSE
)

# =============================================================================
# RCQL OLD ITEMS - 68 ITEMS (LONGER VERSION)
# =============================================================================

rcqL_old_items <- data.frame(
    id = c(
        # RCQL: Long RCQ Items (68 items total: 15+15+15+15+8)
        "RCQL_01_01", "RCQL_01_02", "RCQL_01_03", "RCQL_01_04", "RCQL_01_05",
        "RCQL_01_06", "RCQL_01_07", "RCQL_01_08", "RCQL_01_09", "RCQL_01_10",
        "RCQL_01_11", "RCQL_01_12", "RCQL_01_13", "RCQL_01_14", "RCQL_01_15",
        "RCQL_02_01", "RCQL_02_02", "RCQL_02_03", "RCQL_02_04", "RCQL_02_05",
        "RCQL_02_06", "RCQL_02_07", "RCQL_02_08", "RCQL_02_09", "RCQL_02_10",
        "RCQL_02_11", "RCQL_02_12", "RCQL_02_13", "RCQL_02_14", "RCQL_02_15",
        "RCQL_03_01", "RCQL_03_02", "RCQL_03_03", "RCQL_03_04", "RCQL_03_05",
        "RCQL_03_06", "RCQL_03_07", "RCQL_03_08", "RCQL_03_09", "RCQL_03_10",
        "RCQL_03_11", "RCQL_03_12", "RCQL_03_13", "RCQL_03_14", "RCQL_03_15",
        "RCQL_04_01", "RCQL_04_02", "RCQL_04_03", "RCQL_04_04", "RCQL_04_05",
        "RCQL_04_06", "RCQL_04_07", "RCQL_04_08", "RCQL_04_09", "RCQL_04_10",
        "RCQL_04_11", "RCQL_04_12", "RCQL_04_13", "RCQL_04_14", "RCQL_04_15",
        "RCQL_05_01", "RCQL_05_02", "RCQL_05_03", "RCQL_05_04", "RCQL_05_05",
        "RCQL_05_06", "RCQL_05_07", "RCQL_05_08"
    ),
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
    b = rep(0, 68),
    a = rep(1, 68),
    stringsAsFactors = FALSE
)

# Note: rcq_items is already defined above with all 281 items
# rcq_old_items (30 items) and rcqL_old_items (68 items) are separate datasets
# These are exported from the inrep package and can be used independently

# =============================================================================
# DEMOGRAPHICS CONFIGURATION
# =============================================================================

demographic_configs <- list(
    alter = list(
        question = "Geben Sie bitte Ihr Alter in Jahren an.",
        type = "text",
        required = FALSE
    ),
    geschlecht = list(
        question = "Welchem Geschlecht fühlen Sie sich zugehörig?",
        options = c("Männlich" = "1", "Weiblich" = "2", "Divers" = "3", "Keine Angabe" = "4"),
        required = FALSE
    ),
    bildungsabschluss = list(
        question = "Bitte geben Sie Ihren höchsten Bildungsabschluss an.",
        options = c("Hauptschulabschluss" = "1", "Mittlere Reife" = "2", "Fachabitur" = "3",
                    "Abitur" = "4", "Bachelor" = "5", "Master" = "6", "Sonstiges" = "7"),
        required = FALSE
    ),
    familienstand = list(
        question = "Bitte geben Sie Ihren derzeitigen Familienstand an.",
        options = c("Ledig" = "1", "In Beziehung" = "2", "Verheiratet" = "3",
                    "Geschieden" = "4", "Verwitwet" = "5"),
        required = FALSE
    ),
    taetigkeit = list(
        question = "Welcher Tätigkeit gehen Sie aktuell nach?",
        options = c("Vollzeit erwerbstätig" = "1", "Teilzeit erwerbstätig" = "2",
                    "Student:in" = "3", "Arbeitssuchend" = "4", "Sonstiges" = "5"),
        required = FALSE
    ),
    alleinlebend = list(
        question = "Leben Sie aktuell allein?",
        options = c("Ja" = "1", "Nein" = "2"),
        required = FALSE
    ),
    religiositeit = list(
        question = "Wie oft sind Sie in den letzten 6 Monaten einem spirituellen Glauben nachgegangen?",
        options = c("0-mal" = "0", "1-mal" = "1", "2-mal" = "2", "3-mal" = "3", "mehr als 3-mal" = "4"),
        required = FALSE
    ),
    psychotherapie = list(
        question = "Haben Sie sich schon psychotherapeutische Unterstützung gesucht?",
        options = c("Ja, schon gesucht" = "1", "Ja, überlegt" = "2", "Nein" = "3"),
        required = FALSE
    )
)

input_types <- list(
    alter = "text",
    geschlecht = "radio",
    bildungsabschluss = "select",
    familienstand = "radio",
    taetigkeit = "radio",
    alleinlebend = "radio",
    religiositeit = "radio",
    psychotherapie = "radio"
)

# =============================================================================
# CUSTOM PAGE FLOW
# =============================================================================

custom_page_flow <- list(
    list(
        id = "page1",
        type = "custom",
        title = "RCQ Studie",
        content = '<div style="padding: 20px; font-size: 16px; line-height: 1.8;">
            <h1 style="color: #2c3e50; text-align: center; margin-bottom: 30px;">Willkommen zur RCQ Studie</h1>
            <h2 style="color: #2c3e50;">Liebe Teilnehmende,</h2>
            <p>vielen Dank für Ihr Interesse an unserer Studie zum Thema Resilienz und Coping.</p>
            <p>Die Studie dauert etwa 20-30 Minuten und umfasst mehrere Seiten mit Aussagen zum Thema Resilienz und Bewältigung von Herausforderungen.</p>
            <p>Bitte beachten Sie: Es gibt keine Rückwärtsnavigation. Sie können Ihre Angaben nicht zwischenspeichern. Nehmen Sie sich daher ausreichend Zeit.</p>
            <p>Es gibt keine richtigen oder falschen Antworten. Bitte antworten Sie so ehrlich und spontan wie möglich.</p>
            <p><strong>Die Daten werden anonymisiert erhoben.</strong></p>
            <p style="background: #ecf0f1; padding: 15px; border-left: 4px solid #3498db; margin-top: 20px;">
            Ihre Teilnahme ist völlig freiwillig und Sie können die Umfrage jederzeit beenden.</p>
            <hr style="margin: 30px 0;">
            <p><strong>Kontakt:</strong><br>
            Clievins Selva<br>
            E-Mail: selva@uni-hildesheim.de</p>
        </div>',
        required = FALSE
    ),
    
    list(
        id = "page2",
        type = "items",
        title = "Resilientes Coping - Teil 1",
        instructions = "Bitte geben Sie an, inwieweit Sie den folgenden Aussagen zustimmen.",
        item_indices = 1:15,
        scale_type = "likert"
    ),
    
    list(
        id = "page3",
        type = "items", 
        title = "Resilientes Coping - Teil 2",
        instructions = "Bitte geben Sie an, inwieweit Sie den folgenden Aussagen zustimmen.",
        item_indices = 16:30,
        scale_type = "likert"
    ),
    
    list(
        id = "page4",
        type = "items",
        title = "Persönlichkeit",
        instructions = "Bitte bewerten Sie die folgenden Aussagen.",
        item_indices = 31:60,
        scale_type = "likert"
    ),
    
    list(
        id = "page5",
        type = "items",
        title = "Politische Selbstwirksamkeit und Arbeitsklima",
        instructions = "Bitte beantworten Sie die folgenden Fragen.",
        item_indices = 61:80,
        scale_type = "likert"
    ),
    
    list(
        id = "page6",
        type = "items",
        title = "Bewältigung und Achtsamkeit",
        instructions = "Bitte bewerten Sie die folgenden Aussagen.",
        item_indices = 81:100,
        scale_type = "likert"
    ),
    
    list(
        id = "page7",
        type = "demographics",
        title = "Soziodemographische Angaben",
        demographics = names(demographic_configs)
    ),
    
    list(
        id = "page8",
        type = "results",
        title = "Ihre Ergebnisse",
        results_processor = "create_rcq_report"
    )
)

# =============================================================================
# RESULTS PROCESSOR - COMPREHENSIVE RCQ REPORT
# =============================================================================

create_rcq_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
    tryCatch({
        
        if (is.null(responses) || !is.vector(responses) || length(responses) == 0) {
            return(shiny::HTML("<p>Keine Antworten zur Auswertung verfügbar.</p>"))
        }
        
        # Ensure we have enough responses
        if (length(responses) < 100) {
            responses <- c(responses, rep(NA, 100 - length(responses)))
        }
        responses <- as.numeric(responses)
        
        # =============================================================================
        # RCQ SUBSCALES CALCULATION (Items 1-30)
        # =============================================================================
        
        # RCQ_01: Goal-oriented behavior and future planning (items 2, 5, reverse 1, 13)
        rcq_goal_oriented <- mean(c(
            responses[2], responses[5], 
            8 - responses[1], 8 - responses[13]
        ), na.rm = TRUE)
        
        # RCQ_01: Adaptive coping with anxiety (items 3, 6, reverse 7)
        rcq_anxiety_coping <- mean(c(
            responses[3], responses[6],
            8 - responses[7]
        ), na.rm = TRUE)
        
        # RCQ_01: Reappraisal/Meaning-making (items 4, 12)
        rcq_reappraisal <- mean(c(responses[4], responses[12]), na.rm = TRUE)
        
        # RCQ_01: Wishful thinking (reverse item 8)
        rcq_wishful_thinking <- 8 - responses[8]
        
        # RCQ_01: Family support (item 9)
        rcq_family_support_1 <- responses[9]
        
        # RCQ_01: Giving up quickly (reverse items 10, 13)
        rcq_giving_up <- mean(c(8 - responses[10], 8 - responses[13]), na.rm = TRUE)
        
        # RCQ_01: Humor (items 11 reverse, 14)
        rcq_humor_1 <- mean(c(8 - responses[11], responses[14]), na.rm = TRUE)
        
        # RCQ_01: Physical activity for pain management (item 15)
        rcq_physical_activity_1 <- responses[15]
        
        # RCQ_02: Family support (items 16, 27)
        rcq_family_support_2 <- mean(c(responses[16], responses[27]), na.rm = TRUE)
        
        # RCQ_02: Growth mindset (item 17)
        rcq_growth_mindset <- responses[17]
        
        # RCQ_02: Resource mobilization (item 18)
        rcq_resource_mobilization <- responses[18]
        
        # RCQ_02: Physical activity (items 19, 29)
        rcq_physical_activity_2 <- mean(c(responses[19], responses[29]), na.rm = TRUE)
        
        # RCQ_02: Guilt about past (reverse item 20)
        rcq_past_guilt <- 8 - responses[20]
        
        # RCQ_02: Future confidence (item 21)
        rcq_future_confidence <- responses[21]
        
        # RCQ_02: Optimism in uncertainty (item 22)
        rcq_optimism <- responses[22]
        
        # RCQ_02: Humor in adversity (item 23, 28)
        rcq_humor_2 <- mean(c(responses[23], responses[28]), na.rm = TRUE)
        
        # RCQ_02: Meaning-making (item 24)
        rcq_meaning_making <- responses[24]
        
        # RCQ_02: Sociability (item 25)
        rcq_sociability <- responses[25]
        
        # RCQ_02: Family loyalty (item 26)
        rcq_family_loyalty <- responses[26]
        
        # RCQ_02: Solution-oriented (item 30)
        rcq_solution_oriented <- responses[30]
        
        # Overall RCQ Composite Score
        rcq_total <- mean(c(
            rcq_goal_oriented, rcq_anxiety_coping, rcq_reappraisal,
            rcq_family_support_1, rcq_giving_up, rcq_humor_1,
            rcq_physical_activity_1, rcq_family_support_2,
            rcq_growth_mindset, rcq_resource_mobilization,
            rcq_physical_activity_2, rcq_future_confidence,
            rcq_optimism, rcq_humor_2, rcq_meaning_making,
            rcq_sociability, rcq_family_loyalty, rcq_solution_oriented
        ), na.rm = TRUE)
        
        # =============================================================================
        # BIG FIVE PERSONALITY (Items 31-60)
        # =============================================================================
        
        # Extraversion: 1R, 6, 11, 16, 21R, 26R
        bfi_extraversion <- mean(c(
            8 - responses[31], responses[36], responses[41],
            responses[46], 8 - responses[51], 8 - responses[56]
        ), na.rm = TRUE)
        
        # Agreeableness: 2, 7R, 12, 17R, 22, 27R
        bfi_agreeableness <- mean(c(
            responses[32], 8 - responses[37], responses[42],
            8 - responses[47], responses[52], 8 - responses[57]
        ), na.rm = TRUE)
        
        # Conscientiousness: 3R, 8R, 13, 18, 23, 28R
        bfi_conscientiousness <- mean(c(
            8 - responses[33], 8 - responses[38], responses[43],
            responses[48], responses[53], 8 - responses[58]
        ), na.rm = TRUE)
        
        # Neuroticism: 4, 9, 14R, 19R, 24, 29
        bfi_neuroticism <- mean(c(
            responses[34], responses[39], 8 - responses[44],
            8 - responses[49], responses[54], responses[59]
        ), na.rm = TRUE)
        
        # Openness: 5, 10R, 15, 20R, 25, 30R
        bfi_openness <- mean(c(
            responses[35], 8 - responses[40], responses[45],
            8 - responses[50], responses[55], 8 - responses[60]
        ), na.rm = TRUE)
        
        # =============================================================================
        # POLITICAL SELF-EFFICACY (Items 61-70)
        # =============================================================================
        pse_score <- mean(responses[61:70], na.rm = TRUE)
        
        # =============================================================================
        # WORK AND ORGANIZATIONAL CLIMATE (Items 71-78)
        # =============================================================================
        woc_score <- mean(responses[71:78], na.rm = TRUE)
        
        # =============================================================================
        # BRIEF COPE SUBSCALES (Items 79-106, but we only have up to 100)
        # =============================================================================
        # Since we only have items 79-100, we calculate what we can (22 items)
        
        # Active Coping: items 2, 7 (positions 80, 85)
        cope_active <- mean(c(responses[80], responses[85]), na.rm = TRUE)
        
        # Planning: items 14, 25 (positions 92, 103 - but 103 is beyond 100)
        cope_planning <- responses[92]
        
        # Positive Reframing: items 12, 17 (positions 90, 95)
        cope_reframing <- mean(c(responses[90], responses[95]), na.rm = TRUE)
        
        # Acceptance: items 20, 24 (positions 98, 102 - but 102 is beyond 100)
        cope_acceptance <- responses[98]
        
        # Humor: items 18, 28 (positions 96, 106 - but 106 is beyond 100)
        cope_humor <- responses[96]
        
        # Support seeking: items 5, 10, 15, 23 (positions 83, 88, 93, 101 - but 101 is beyond 100)
        cope_support <- mean(c(responses[83], responses[88], responses[93]), na.rm = TRUE)
        
        # Denial: items 3, 8 (positions 81, 86)
        cope_denial <- mean(c(responses[81], responses[86]), na.rm = TRUE)
        
        # Venting: items 9, 21 (positions 87, 99)
        cope_venting <- mean(c(responses[87], responses[99]), na.rm = TRUE)
        
        # Self-blame: items 13, 26 (positions 91, 104 - but 104 is beyond 100)
        cope_self_blame <- responses[91]
        
        # Substance use: items 4, 11 (positions 82, 89)
        cope_substance <- mean(c(responses[82], responses[89]), na.rm = TRUE)
        
        # Behavioral disengagement: items 6, 16 (positions 84, 94)
        cope_disengagement <- mean(c(responses[84], responses[94]), na.rm = TRUE)
        
        # Self-distraction: items 1, 19 (positions 79, 97)
        cope_distraction <- mean(c(responses[79], responses[97]), na.rm = TRUE)
        
        # Religion: items 22, 27 (positions 100, 105 - but 105 is beyond 100)
        cope_religion <- responses[100]
        
        # Overall coping score
        cope_total <- mean(c(
            cope_active, cope_planning, cope_reframing, cope_acceptance,
            cope_humor, cope_support, cope_distraction
        ), na.rm = TRUE)
        
        # =============================================================================
        # PREPARE COMPREHENSIVE SCORES
        # =============================================================================
        
        all_scores <- list(
            # RCQ Subscales
            "RCQ: Zielorientierung" = round(rcq_goal_oriented, 2),
            "RCQ: Angstbewältigung" = round(rcq_anxiety_coping, 2),
            "RCQ: Neubewertung" = round(rcq_reappraisal, 2),
            "RCQ: Familiäre Unterstützung" = round(mean(c(rcq_family_support_1, rcq_family_support_2), na.rm = TRUE), 2),
            "RCQ: Humor" = round(mean(c(rcq_humor_1, rcq_humor_2), na.rm = TRUE), 2),
            "RCQ: Körperliche Aktivität" = round(mean(c(rcq_physical_activity_1, rcq_physical_activity_2), na.rm = TRUE), 2),
            "RCQ: Optimismus" = round(rcq_optimism, 2),
            "RCQ: Lösungsorientierung" = round(rcq_solution_oriented, 2),
            "RCQ Gesamt" = round(rcq_total, 2),
            
            # Big Five
            "Extraversion" = round(bfi_extraversion, 2),
            "Verträglichkeit" = round(bfi_agreeableness, 2),
            "Gewissenhaftigkeit" = round(bfi_conscientiousness, 2),
            "Neurotizismus" = round(bfi_neuroticism, 2),
            "Offenheit" = round(bfi_openness, 2),
            
            # Other constructs
            "Politische Selbstwirksamkeit" = round(pse_score, 2),
            "Arbeitsklima" = round(woc_score, 2),
            
            # Coping subscales
            "Coping: Aktiv" = round(cope_active, 2),
            "Coping: Planung" = round(cope_planning, 2),
            "Coping: Positive Umdeutung" = round(cope_reframing, 2),
            "Coping: Akzeptanz" = round(cope_acceptance, 2),
            "Coping: Humor" = round(cope_humor, 2),
            "Coping: Unterstützung suchen" = round(cope_support, 2),
            "Coping: Verleugnung" = round(cope_denial, 2),
            "Coping: Gefühle äußern" = round(cope_venting, 2),
            "Coping: Selbstvorwürfe" = round(cope_self_blame, 2),
            "Coping: Substanzgebrauch" = round(cope_substance, 2),
            "Coping: Verhaltensrückzug" = round(cope_disengagement, 2),
            "Coping: Ablenkung" = round(cope_distraction, 2),
            "Coping: Religion" = round(cope_religion, 2),
            "Coping Gesamt" = round(cope_total, 2)
        )
        
        # =============================================================================
        # CREATE VISUALIZATIONS
        # =============================================================================
        
        # RCQ Subscales chart (simple bar chart)
        rcq_chart_data <- data.frame(
            dimension = c("Zielorientierung", "Angstbewältigung", "Neubewertung", 
                         "Familie", "Humor", "Aktivität", "Optimismus", "Lösungen"),
            score = c(rcq_goal_oriented, rcq_anxiety_coping, rcq_reappraisal,
                     mean(c(rcq_family_support_1, rcq_family_support_2), na.rm = TRUE),
                     mean(c(rcq_humor_1, rcq_humor_2), na.rm = TRUE),
                     mean(c(rcq_physical_activity_1, rcq_physical_activity_2), na.rm = TRUE),
                     rcq_optimism, rcq_solution_oriented),
            stringsAsFactors = FALSE
        )
        
        rcq_plot <- ggplot2::ggplot(rcq_chart_data, ggplot2::aes(x = dimension, y = score)) +
            ggplot2::geom_bar(stat = "identity", fill = "#2c3e50", width = 0.7) +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), vjust = -0.5, size = 4, fontface = "bold") +
            ggplot2::scale_y_continuous(limits = c(0, 7.5), breaks = seq(0, 7, 1)) +
            ggplot2::theme_minimal(base_size = 12) +
            ggplot2::theme(
                axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
                axis.text.y = ggplot2::element_text(size = 11),
                axis.title.y = ggplot2::element_text(size = 12, face = "bold"),
                plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5, margin = ggplot2::margin(b = 15)),
                panel.grid.major.x = ggplot2::element_blank(),
                panel.grid.minor = ggplot2::element_blank()
            ) +
            ggplot2::labs(title = "RCQ Resilienz-Dimensionen", x = "", y = "Score (1-7)")
        
        # Big Five RADAR CHART (like HilFo)
        radar_scores <- list(
            Extraversion = bfi_extraversion,
            Verträglichkeit = bfi_agreeableness,
            Gewissenhaftigkeit = bfi_conscientiousness,
            Neurotizismus = bfi_neuroticism,
            Offenheit = bfi_openness
        )
        
        # Create radar plot manually (similar to HilFo fallback approach)
        n_vars <- 5
        angles <- seq(0, 2*pi, length.out = n_vars + 1)[-(n_vars + 1)]
        
        bfi_scores_vec <- c(bfi_extraversion, bfi_agreeableness, bfi_conscientiousness,
                           bfi_neuroticism, bfi_openness)
        bfi_labels <- c("Extraversion", "Verträglichkeit", "Gewissenhaftigkeit", 
                       "Neurotizismus", "Offenheit")
        
        # Normalize to 0-5 scale and calculate positions
        x_pos <- (bfi_scores_vec / 7 * 5) * cos(angles - pi/2)
        y_pos <- (bfi_scores_vec / 7 * 5) * sin(angles - pi/2)
        
        plot_data <- data.frame(
            x = c(x_pos, x_pos[1]),
            y = c(y_pos, y_pos[1]),
            label = c(bfi_labels, ""),
            score = c(bfi_scores_vec, bfi_scores_vec[1])
        )
        
        # Grid lines data
        grid_data <- expand.grid(
            r = seq(1, 5, 1),
            angle = seq(0, 2*pi, length.out = 100)
        )
        grid_data$x <- grid_data$r * cos(grid_data$angle)
        grid_data$y <- grid_data$r * sin(grid_data$angle)
        
        # Create radar plot
        bfi_radar_plot <- ggplot2::ggplot() +
            ggplot2::geom_path(data = grid_data, ggplot2::aes(x = x, y = y, group = r),
                              color = "gray85", linewidth = 0.3) +
            ggplot2::geom_segment(data = data.frame(angle = angles),
                                 ggplot2::aes(x = 0, y = 0,
                                            xend = 5 * cos(angle - pi/2),
                                            yend = 5 * sin(angle - pi/2)),
                                 color = "gray85", linewidth = 0.3) +
            ggplot2::geom_polygon(data = plot_data, ggplot2::aes(x = x, y = y),
                                 fill = "#2c3e50", alpha = 0.3) +
            ggplot2::geom_path(data = plot_data, ggplot2::aes(x = x, y = y),
                              color = "#2c3e50", linewidth = 1.5) +
            ggplot2::geom_point(data = plot_data[1:5,], ggplot2::aes(x = x, y = y),
                               color = "#2c3e50", size = 4) +
            ggplot2::geom_text(data = plot_data[1:5,],
                              ggplot2::aes(x = x * 1.35, y = y * 1.35, label = label),
                              size = 4.5, fontface = "bold") +
            ggplot2::geom_text(data = plot_data[1:5,],
                              ggplot2::aes(x = x * 1.12, y = y * 1.12, label = sprintf("%.2f", score)),
                              size = 3.5, color = "#2c3e50", fontface = "bold") +
            ggplot2::coord_equal() +
            ggplot2::xlim(-7, 7) + ggplot2::ylim(-7, 7) +
            ggplot2::theme_void() +
            ggplot2::theme(
                plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5,
                                                  margin = ggplot2::margin(b = 15)),
                plot.margin = ggplot2::margin(20, 20, 20, 20)
            ) +
            ggplot2::labs(title = "Big Five Persönlichkeitsprofil")
        
        # Coping strategies chart (simple, clean)
        cope_chart_data <- data.frame(
            dimension = c("Aktiv", "Planung", "Umdeutung", "Akzeptanz", "Humor", 
                         "Support", "Ablenkung"),
            score = c(cope_active, cope_planning, cope_reframing, cope_acceptance,
                     cope_humor, cope_support, cope_distraction),
            stringsAsFactors = FALSE
        )
        
        cope_plot <- ggplot2::ggplot(cope_chart_data, ggplot2::aes(x = dimension, y = score)) +
            ggplot2::geom_bar(stat = "identity", fill = "#7f8c8d", width = 0.7) +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), vjust = -0.5, size = 4, fontface = "bold") +
            ggplot2::scale_y_continuous(limits = c(0, 7.5), breaks = seq(0, 7, 1)) +
            ggplot2::theme_minimal(base_size = 12) +
            ggplot2::theme(
                axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 10, face = "bold"),
                axis.text.y = ggplot2::element_text(size = 11),
                axis.title.y = ggplot2::element_text(size = 12, face = "bold"),
                plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5, margin = ggplot2::margin(b = 15)),
                panel.grid.major.x = ggplot2::element_blank(),
                panel.grid.minor = ggplot2::element_blank()
            ) +
            ggplot2::labs(title = "Bewältigungsstrategien (Brief COPE)", x = "", y = "Score (1-4)")
        
        # Save plots
        rcq_file <- tempfile(fileext = ".png")
        bfi_radar_file <- tempfile(fileext = ".png")
        cope_file <- tempfile(fileext = ".png")
        
        suppressMessages({
            ggplot2::ggsave(rcq_file, rcq_plot, width = 11, height = 6, dpi = 150, bg = "white")
            ggplot2::ggsave(bfi_radar_file, bfi_radar_plot, width = 9, height = 9, dpi = 150, bg = "white")
            ggplot2::ggsave(cope_file, cope_plot, width = 11, height = 6, dpi = 150, bg = "white")
        })
        
        rcq_base64 <- ""
        bfi_radar_base64 <- ""
        cope_base64 <- ""
        
        if (requireNamespace("base64enc", quietly = TRUE)) {
            rcq_base64 <- base64enc::base64encode(rcq_file)
            bfi_radar_base64 <- base64enc::base64encode(bfi_radar_file)
            cope_base64 <- base64enc::base64encode(cope_file)
        }
        
        unlink(c(rcq_file, bfi_radar_file, cope_file))
        
        # =============================================================================
        # GENERATE HTML REPORT
        # =============================================================================
        
        html <- paste0(
            '<style>',
            '.page-title, .study-title, h1:first-child { display: none !important; }',
            '</style>',
            '<div id="report-content" style="padding: 20px; max-width: 1100px; margin: 0 auto; font-family: Arial, sans-serif;">',
            '<h1 style="color: #2c3e50; text-align: center; margin-bottom: 40px; font-size: 26px; font-weight: bold;">',
            'Ihre RCQ Studienergebnisse</h1>',
            
            # RCQ Section
            '<div style="background: #ffffff; padding: 25px; margin-bottom: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">',
            '<h2 style="color: #2c3e50; margin-bottom: 20px; font-size: 20px; font-weight: bold; border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">',
            'Resilienz und Coping (RCQ)</h2>',
            if (rcq_base64 != "") paste0('<img src="data:image/png;base64,', rcq_base64, 
                                        '" style="width: 100%; max-width: 950px; display: block; margin: 15px auto;">') else "",
            '<div style="text-align: center; padding: 15px; background: #f8f9fa; margin-top: 15px; border-radius: 4px;">',
            '<span style="font-size: 14px; color: #7f8c8d; font-weight: bold;">RCQ GESAMTSCORE</span><br>',
            '<span style="font-size: 28px; font-weight: bold; color: #2c3e50;">', round(rcq_total, 2), '</span>',
            '<span style="font-size: 16px; color: #7f8c8d;"> / 7.00</span>',
            '</div>',
            '</div>',
            
            # Big Five Section with RADAR
            '<div style="background: #ffffff; padding: 25px; margin-bottom: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">',
            '<h2 style="color: #2c3e50; margin-bottom: 20px; font-size: 20px; font-weight: bold; border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">',
            'Persönlichkeit (Big Five)</h2>',
            if (bfi_radar_base64 != "") paste0('<img src="data:image/png;base64,', bfi_radar_base64, 
                                        '" style="width: 100%; max-width: 750px; display: block; margin: 15px auto;">') else "",
            '</div>',
            
            # Coping Section
            '<div style="background: #ffffff; padding: 25px; margin-bottom: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">',
            '<h2 style="color: #2c3e50; margin-bottom: 20px; font-size: 20px; font-weight: bold; border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">',
            'Bewältigungsstrategien (Brief COPE)</h2>',
            if (cope_base64 != "") paste0('<img src="data:image/png;base64,', cope_base64, 
                                        '" style="width: 100%; max-width: 950px; display: block; margin: 15px auto;">') else "",
            '<div style="text-align: center; padding: 15px; background: #f8f9fa; margin-top: 15px; border-radius: 4px;">',
            '<span style="font-size: 14px; color: #7f8c8d; font-weight: bold;">COPING GESAMTSCORE</span><br>',
            '<span style="font-size: 28px; font-weight: bold; color: #2c3e50;">', round(cope_total, 2), '</span>',
            '<span style="font-size: 16px; color: #7f8c8d;"> / 4.00</span>',
            '</div>',
            '</div>',
            
            # Additional Scores Section
            '<div style="background: #ffffff; padding: 25px; margin-bottom: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">',
            '<h2 style="color: #2c3e50; margin-bottom: 20px; font-size: 20px; font-weight: bold; border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">',
            'Weitere Dimensionen</h2>',
            '<div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-top: 20px;">',
            '<div style="text-align: center; padding: 20px; background: #f8f9fa; border-radius: 4px;">',
            '<span style="font-size: 13px; color: #7f8c8d; font-weight: bold;">POLITISCHE SELBSTWIRKSAMKEIT</span><br>',
            '<span style="font-size: 24px; font-weight: bold; color: #2c3e50;">', round(pse_score, 2), '</span>',
            '<span style="font-size: 14px; color: #7f8c8d;"> / 7.00</span>',
            '</div>',
            '<div style="text-align: center; padding: 20px; background: #f8f9fa; border-radius: 4px;">',
            '<span style="font-size: 13px; color: #7f8c8d; font-weight: bold;">ARBEITSKLIMA</span><br>',
            '<span style="font-size: 24px; font-weight: bold; color: #2c3e50;">', round(woc_score, 2), '</span>',
            '<span style="font-size: 14px; color: #7f8c8d;"> / 6.00</span>',
            '</div>',
            '</div>',
            '</div>',
            
            # Detailed Scores Table
            '<div style="background: #ffffff; padding: 25px; margin-bottom: 25px; border: 1px solid #e0e0e0; border-radius: 6px;">',
            '<h2 style="color: #2c3e50; margin-bottom: 20px; font-size: 20px; font-weight: bold; border-bottom: 2px solid #2c3e50; padding-bottom: 10px;">',
            'Alle Dimensionen im Detail</h2>',
            '<table style="width: 100%; border-collapse: collapse; margin-top: 15px;">',
            '<thead>',
            '<tr style="background: #2c3e50; color: white;">',
            '<th style="padding: 14px; text-align: left; font-size: 14px; font-weight: bold;">Dimension</th>',
            '<th style="padding: 14px; text-align: center; font-size: 14px; font-weight: bold;">Score</th>',
            '</tr>',
            '</thead>',
            '<tbody>'
        )
        
        # Add all scores to table (without interpretation column)
        for (i in seq_along(all_scores)) {
            name <- names(all_scores)[i]
            value <- all_scores[[i]]
            
            row_color <- if (i %% 2 == 0) "#f8f9fa" else "white"
            
            html <- paste0(html,
                '<tr style="background: ', row_color, '; border-bottom: 1px solid #e0e0e0;">',
                '<td style="padding: 12px; font-size: 14px;">', name, '</td>',
                '<td style="padding: 12px; text-align: center; font-size: 16px; font-weight: bold; color: #2c3e50;">', 
                value, '</td>',
                '</tr>'
            )
        }
        
        html <- paste0(html,
            '</tbody>',
            '</table>',
            '</div>',
            
            # Download Section (PDF & CSV)
            '<div class="download-section" style="background: #f8f9fa; padding: 20px; border-radius: 4px; margin: 20px 0; border: 1px solid #e0e0e0;">',
            '<h4 style="color: #2c3e50; margin-bottom: 15px; text-align: center; font-size: 18px; font-weight: bold;">',
            'Ergebnisse exportieren',
            '</h4>',
            '<div style="display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">',
            
            # PDF Download Button
            '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_pdf_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download nicht verfügbar\'); }" class="btn btn-primary" style="background: #2c3e50; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
            '<i class="fas fa-file-pdf" style="margin-right: 8px;"></i>',
            'PDF herunterladen',
            '</button>',
            
            # CSV Download Button  
            '<button onclick="if(typeof Shiny !== \'undefined\') { Shiny.setInputValue(\'download_csv_trigger\', Math.random(), {priority: \'event\'}); } else { alert(\'Download nicht verfügbar\'); }" class="btn btn-success" style="background: #7f8c8d; border: none; color: white; padding: 12px 24px; border-radius: 6px; cursor: pointer; font-size: 16px; font-weight: 500; transition: all 0.2s ease; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">',
            '<i class="fas fa-file-csv" style="margin-right: 8px;"></i>',
            'CSV herunterladen',
            '</button>',
            
            '</div>',
            '</div>',
            
            # Print styles
            '<style>',
            '@media print {',
            '  .download-section { display: none !important; }',
            '  body { font-size: 11pt; }',
            '  .report-section { page-break-inside: avoid; }',
            '  h2 { color: #2c3e50 !important; -webkit-print-color-adjust: exact; }',
            '}',
            '</style>',
            
            # Footer
            '<div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 4px; text-align: center; border: 1px solid #e0e0e0;">',
            '<p style="color: #7f8c8d; font-size: 13px; margin: 0; line-height: 1.6;">',
            'Vielen Dank für Ihre Teilnahme an der RCQ Studie!<br>',
            'Diese Ergebnisse dienen zu Forschungszwecken und stellen keine klinische Diagnose dar.',
            '</p>',
            '</div>',
            
            '</div>'
        )
        
        return(shiny::HTML(html))
        
    }, error = function(e) {
        cat("ERROR in create_rcq_report:", e$message, "\n")
        cat("Traceback:", paste(deparse(sys.calls()), collapse = "\n"), "\n")
        return(shiny::HTML(paste0(
            '<div style="padding: 20px; color: red;">',
            '<h2>Fehler beim Erstellen der Ergebnisse</h2>',
            '<p>Ein Fehler ist aufgetreten: ', e$message, '</p>',
            '</div>'
        )))
    })
}

# =============================================================================
# STUDY CONFIGURATION
# =============================================================================

session_uuid <- paste0("rcq_", format(Sys.time(), "%Y%m%d_%H%M%S"))

study_config <- inrep::create_study_config(
    name = "RCQ - Resilienz und Coping Fragebogen",
    study_key = session_uuid,
    theme = "light",
    custom_page_flow = custom_page_flow,
    demographics = names(demographic_configs),
    demographic_configs = demographic_configs,
    input_types = input_types,
    model = "GRM",
    adaptive = FALSE,
    max_items = 100,
    min_items = 100,
    criteria = "MFI",
    response_ui_type = "radio",
    progress_style = "bar",
    language = "de",
    session_save = TRUE,
    session_timeout = 3600,  # Session will timeout after 3600 seconds (1 hour)
    # NOTE: When session times out or study completes:
    # 1. Browser/tab will automatically close
    # 2. All data is saved before closing
    # 3. Shiny app is stopped with stopApp()
    # 4. R script terminates completely (if running in background)
    # This ensures no background R processes remain running
    results_processor = create_rcq_report
)

# Use only first 100 items from rcq_items for the study
#rcq_items_study <- rcq_items[1:100, ]
rcq_items_study <- rcq_items

# =============================================================================
# LAUNCH STUDY
# =============================================================================

inrep::launch_study(
    config = study_config,
    item_bank = rcq_items_study,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv",
    debug_mode = TRUE  # Enable debug mode: STRG+A = fill page, STRG+Q = auto-fill all
)
