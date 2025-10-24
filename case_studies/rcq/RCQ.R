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
# RESULTS PROCESSOR
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
        
        # Calculate main scores from first 100 items
        rcq_score <- mean(responses[1:30], na.rm = TRUE)
        bfi_neuroticism <- mean(c(responses[34], responses[39], responses[44], responses[49], responses[54], responses[59]), na.rm = TRUE)
        bfi_extraversion <- mean(c(responses[31], responses[36], responses[41], responses[46], responses[51], responses[56]), na.rm = TRUE)
        bfi_openness <- mean(c(responses[35], responses[40], responses[45], responses[50], responses[55], responses[60]), na.rm = TRUE)
        bfi_agreeableness <- mean(c(responses[32], responses[37], responses[42], responses[47], responses[52], responses[57]), na.rm = TRUE)
        bfi_conscientiousness <- mean(c(responses[33], responses[38], responses[43], responses[48], responses[53], responses[58]), na.rm = TRUE)
        
        pse_score <- mean(responses[61:70], na.rm = TRUE)
        woc_score <- mean(responses[71:78], na.rm = TRUE)
        cope_score <- mean(responses[79:100], na.rm = TRUE)
        
        # Prepare ordered scores
            ordered_scores <- list(
            ResiliencesCoping = round(rcq_score, 2),
            Neuroticism = round(bfi_neuroticism, 2),
            Extraversion = round(bfi_extraversion, 2),
            Openness = round(bfi_openness, 2),
            Agreeableness = round(bfi_agreeableness, 2),
            Conscientiousness = round(bfi_conscientiousness, 2),
            PoliticalSelfEfficacy = round(pse_score, 2),
            WorkClimate = round(woc_score, 2),
            Coping = round(cope_score, 2)
        )
        
        # Create bar chart
        chart_data <- data.frame(
            dimension = names(ordered_scores),
                score = unlist(ordered_scores),
            category = c("Coping", "Big Five", "Big Five", "Big Five", "Big Five", "Big Five",
                        "Work", "Work", "Coping"),
            stringsAsFactors = FALSE
        )
        
        bar_plot <- ggplot2::ggplot(chart_data, ggplot2::aes(x = dimension, y = score, fill = category)) +
            ggplot2::geom_bar(stat = "identity", width = 0.7) +
            ggplot2::geom_text(ggplot2::aes(label = sprintf("%.2f", score)), vjust = -0.5, size = 4) +
            ggplot2::scale_y_continuous(limits = c(0, 7)) +
            ggplot2::theme_minimal(base_size = 12) +
            ggplot2::theme(
                axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 10),
                plot.title = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5),
                legend.position = "bottom"
            ) +
            ggplot2::labs(title = "RCQ Studienergebnisse", y = "Score")
        
        bar_file <- tempfile(fileext = ".png")
        suppressMessages({
            ggplot2::ggsave(bar_file, bar_plot, width = 12, height = 6, dpi = 150, bg = "white")
        })
        
        bar_base64 <- ""
        if (requireNamespace("base64enc", quietly = TRUE)) {
            bar_base64 <- base64enc::base64encode(bar_file)
        }
        unlink(bar_file)
        
        # Generate HTML report
        html <- paste0(
            '<style>',
            '.page-title, .study-title, h1:first-child { display: none !important; }',
            '</style>',
            '<div id="report-content" style="padding: 20px; max-width: 1000px; margin: 0 auto;">',
            '<h2 style="color: #2c3e50; text-align: center; margin-bottom: 25px;">Ihre Ergebnisse</h2>',
            '<div class="report-section" style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 25px;">',
            if (bar_base64 != "") paste0('<img src="data:image/png;base64,', bar_base64, '" style="width: 100%; max-width: 900px; display: block; margin: 0 auto; border-radius: 8px;">') else "",
            '</div>',
            '<div class="report-section" style="background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);">',
            '<h3 style="color: #2c3e50;">Detaillierte Werte</h3>',
            '<table style="width: 100%; border-collapse: collapse;">',
            '<tr style="background: #f8f9fa;">',
            '<th style="padding: 12px; border-bottom: 2px solid #3498db; text-align: left;">Dimension</th>',
            '<th style="padding: 12px; border-bottom: 2px solid #3498db; text-align: center;">Score</th>',
            '</tr>'
        )
        
        for (name in names(ordered_scores)) {
            value <- ordered_scores[[name]]
            html <- paste0(html,
                '<tr style="border-bottom: 1px solid #e0e0e0;">',
                '<td style="padding: 12px;">', name, '</td>',
                '<td style="padding: 12px; text-align: center;"><strong>', value, '</strong></td>',
                           '</tr>'
            )
        }
        
        html <- paste0(html,
                       '</table>',
            '</div>',
                       '</div>'
        )
        
        return(shiny::HTML(html))
        
    }, error = function(e) {
        cat("ERROR in create_rcq_report:", e$message, "\n")
        return(shiny::HTML('<div style="padding: 20px; color: red;"><h2>Fehler beim Erstellen der Ergebnisse</h2><p>Ein Fehler ist aufgetreten.</p></div>'))
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
    session_timeout = 3600,
    results_processor = create_rcq_report
)

# Use only first 100 items from rcq_items for the study
rcq_items_study <- rcq_items[1:100, ]

# =============================================================================
# LAUNCH STUDY
# =============================================================================

inrep::launch_study(
    config = study_config,
    item_bank = rcq_items_study,
    webdav_url = WEBDAV_URL,
    password = WEBDAV_PASSWORD,
    save_format = "csv"
)
