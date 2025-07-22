"use client"

import { useState, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Progress } from "@/components/ui/progress"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  Brain,
  Cloud,
  Shield,
  Play,
  BarChart3,
  Clock,
  CheckCircle,
  ArrowRight,
  Database,
  Zap,
  FileText,
  Settings,
  TrendingUp,
  Target,
  Layers,
  GitBranch,
  Activity,
  PieChart,
  RefreshCw,
  Download,
} from "lucide-react"

// Types for cognitive items and strategies
type CognitiveItem = {
  id: number
  type: string
  subtype: string
  analysisType: string
  difficulty: number
  discrimination: number
  stimulus: string
  question: string
  options: string[]
  correct: number
  responseTime: number | null
  cognitiveLoad: string
  adaptiveRule: string
}
type AnalysisStrategy = {
  name: string
  description: string
  rPackages: string[]
  outputs: string[]
  reportTemplate: string
}
type Response = {
  itemId: number
  selected: number
  correct: boolean
  responseTime: number
}
type ParticipantInfo = {
  age: string
  gender: string
  education: string
  consent: boolean
}

export default function RAssessmentInterface() {
  // State
  const [currentView, setCurrentView] = useState<"overview" | "assessment" | "backend" | "results">("overview")
  const [assessmentProgress, setAssessmentProgress] = useState<number>(0)
  const [currentQuestion, setCurrentQuestion] = useState<number>(1)
  const [selectedAnalysis, setSelectedAnalysis] = useState<string>("irt")
  const [responses, setResponses] = useState<Response[]>([])
  const [showFeedback, setShowFeedback] = useState<boolean>(false)
  const [lastSelected, setLastSelected] = useState<number | null>(null)
  const [startTime, setStartTime] = useState<number>(Date.now())
  const [error, setError] = useState<string | null>(null)
  const [studyStep, setStudyStep] = useState<"consent" | "info" | "instructions" | "assessment" | "debrief">("consent")
  const [participant, setParticipant] = useState<ParticipantInfo>({
    age: "",
    gender: "",
    education: "",
    consent: false,
  })
  const timerRef = useRef<number>(Date.now())

  // Assessment meta-data
  const assessmentData = {
    totalQuestions: 3,
    timeRemaining: "12:34",
    participantId: "P001",
    sessionId: "S2024-001",
  }

  // Cognitive items
  const cognitiveItems: CognitiveItem[] = [
    {
      id: 1,
      type: "Working Memory",
      subtype: "n-back",
      analysisType: "irt_2pl",
      difficulty: 0.5,
      discrimination: 1.2,
      stimulus: "Remember this sequence: 7, 3, 9, 2, 5",
      question: "What was the third number in the sequence?",
      options: ["7", "3", "9", "2"],
      correct: 2,
      responseTime: null,
      cognitiveLoad: "high",
      adaptiveRule: "difficulty_based",
    },
    {
      id: 2,
      type: "Processing Speed",
      subtype: "visual_search",
      analysisType: "reaction_time",
      difficulty: 0.3,
      discrimination: 0.8,
      stimulus: "Count the number of blue circles",
      question: "How many blue circles do you see?",
      options: ["4", "5", "6", "7"],
      correct: 1,
      responseTime: null,
      cognitiveLoad: "medium",
      adaptiveRule: "speed_based",
    },
    {
      id: 3,
      type: "Executive Function",
      subtype: "stroop",
      analysisType: "conflict_monitoring",
      difficulty: 0.7,
      discrimination: 1.5,
      stimulus: "Name the COLOR of the word, not the word itself",
      question: "What color is this word: RED (displayed in blue)",
      options: ["Red", "Blue", "Green", "Yellow"],
      correct: 1,
      responseTime: null,
      cognitiveLoad: "high",
      adaptiveRule: "conflict_based",
    },
  ]

  // Analysis strategies
  const analysisStrategies: Record<string, AnalysisStrategy> = {
    irt_2pl: {
      name: "2-Parameter Logistic IRT",
      description: "Models item difficulty and discrimination",
      rPackages: ["ltm", "mirt"],
      outputs: ["ability_estimates", "item_parameters", "fit_statistics"],
      reportTemplate: "irt_cognitive_report",
    },
    reaction_time: {
      name: "Reaction Time Analysis",
      description: "Speed-accuracy tradeoff modeling",
      rPackages: ["rtdists", "RWiener"],
      outputs: ["drift_rate", "boundary_separation", "non_decision_time"],
      reportTemplate: "speed_processing_report",
    },
    conflict_monitoring: {
      name: "Conflict Monitoring Model",
      description: "Executive control and interference analysis",
      rPackages: ["EMC2", "rtdists"],
      outputs: ["conflict_effect", "control_strength", "adaptation_rate"],
      reportTemplate: "executive_function_report",
    },
  }

  // Minimalistic theme classes
  const cardClass = "border border-gray-200 rounded-lg bg-white shadow-none"
  const headerClass = "font-bold text-lg text-black"
  const descClass = "text-gray-500 text-sm"
  const badgeClass = "border border-gray-300 bg-white text-black px-2 py-1 rounded text-xs"
  const iconClass = "w-5 h-5 text-black"
  const btnClass = "border border-gray-300 bg-white text-black px-4 py-2 rounded hover:bg-gray-100 transition"
  const progressClass = "bg-gray-200"
  const tabClass = "border-b border-gray-200"
  const tabTriggerClass = "px-4 py-2 text-black font-medium border-none bg-transparent hover:bg-gray-100"
  const tabActiveClass = "border-b-2 border-black"

  // Utility: Download report as JSON
  function downloadReport() {
    const blob = new Blob([JSON.stringify({ responses }, null, 2)], { type: "application/json" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "assessment_report.json"
    a.click()
    URL.revokeObjectURL(url)
  }

  // Utility: Restart assessment
  function restartAssessment() {
    setResponses([])
    setCurrentQuestion(1)
    setAssessmentProgress(0)
    setShowFeedback(false)
    setLastSelected(null)
    setStartTime(Date.now())
    setError(null)
    timerRef.current = Date.now()
    setCurrentView("assessment")
  }

  // Consent Screen
  if (studyStep === "consent") {
    return (
      <div className="min-h-screen bg-white text-black flex items-center justify-center">
        <Card className="max-w-lg w-full border border-gray-200 rounded-lg bg-white shadow-none">
          <CardHeader>
            <CardTitle className="text-xl font-bold">Research Study Consent</CardTitle>
            <CardDescription>
              Welcome to the Cognitive Assessment Study. Please read the information below and provide your consent to participate.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="mb-4 text-sm text-gray-700">
              <p>
                <strong>Purpose:</strong> This study investigates cognitive abilities using standardized assessment items. Your responses will be anonymized and used for research purposes only.
              </p>
              <p className="mt-2">
                <strong>Data Privacy:</strong> All data is stored securely and handled in accordance with institutional and GDPR guidelines.
              </p>
              <p className="mt-2">
                <strong>Voluntary Participation:</strong> You may withdraw at any time without penalty.
              </p>
            </div>
            <div className="flex items-center gap-2 mb-4">
              <input
                type="checkbox"
                id="consent"
                checked={participant.consent}
                onChange={e => setParticipant({ ...participant, consent: e.target.checked })}
                className="w-4 h-4 border-gray-400"
              />
              <label htmlFor="consent" className="text-sm text-gray-800">
                I have read and understood the information above and consent to participate.
              </label>
            </div>
            <Button
              className="w-full"
              disabled={!participant.consent}
              onClick={() => setStudyStep("info")}
            >
              Continue
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  // Participant Info Screen
  if (studyStep === "info") {
    return (
      <div className="min-h-screen bg-white text-black flex items-center justify-center">
        <Card className="max-w-lg w-full border border-gray-200 rounded-lg bg-white shadow-none">
          <CardHeader>
            <CardTitle className="text-xl font-bold">Participant Information</CardTitle>
            <CardDescription>
              Please provide the following demographic information for research purposes.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form
              className="space-y-4"
              onSubmit={e => {
                e.preventDefault()
                setStudyStep("instructions")
              }}
            >
              <div>
                <label className="block text-sm mb-1">Age</label>
                <input
                  type="number"
                  min="18"
                  max="99"
                  required
                  value={participant.age}
                  onChange={e => setParticipant({ ...participant, age: e.target.value })}
                  className="w-full border border-gray-300 rounded px-2 py-1"
                />
              </div>
              <div>
                <label className="block text-sm mb-1">Gender</label>
                <select
                  required
                  value={participant.gender}
                  onChange={e => setParticipant({ ...participant, gender: e.target.value })}
                  className="w-full border border-gray-300 rounded px-2 py-1"
                >
                  <option value="">Select...</option>
                  <option value="female">Female</option>
                  <option value="male">Male</option>
                  <option value="other">Other</option>
                  <option value="prefer_not">Prefer not to say</option>
                </select>
              </div>
              <div>
                <label className="block text-sm mb-1">Education</label>
                <select
                  required
                  value={participant.education}
                  onChange={e => setParticipant({ ...participant, education: e.target.value })}
                  className="w-full border border-gray-300 rounded px-2 py-1"
                >
                  <option value="">Select...</option>
                  <option value="highschool">High School</option>
                  <option value="bachelor">Bachelor's Degree</option>
                  <option value="master">Master's Degree</option>
                  <option value="doctorate">Doctorate</option>
                  <option value="other">Other</option>
                </select>
              </div>
              <Button type="submit" className="w-full">Continue</Button>
            </form>
          </CardContent>
        </Card>
      </div>
    )
  }

  // Instructions Screen
  if (studyStep === "instructions") {
    return (
      <div className="min-h-screen bg-white text-black flex items-center justify-center">
        <Card className="max-w-lg w-full border border-gray-200 rounded-lg bg-white shadow-none">
          <CardHeader>
            <CardTitle className="text-xl font-bold">Instructions</CardTitle>
            <CardDescription>
              Please read the instructions carefully before starting the assessment.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <ul className="list-disc pl-5 text-sm text-gray-700 mb-4">
              <li>You will complete a series of cognitive tasks assessing memory, speed, and executive function.</li>
              <li>Answer each question as accurately and quickly as possible.</li>
              <li>Your progress will be displayed at the top of the screen.</li>
              <li>There are no right or wrong answers; please try your best.</li>
              <li>Click "Begin Assessment" when you are ready.</li>
            </ul>
            <Button className="w-full" onClick={() => { setCurrentView("assessment"); setStudyStep("assessment") }}>
              Begin Assessment
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  // Assessment view (with professional progress bar and sectioning)
  if (currentView === "assessment" && studyStep === "assessment") {
    const currentItem = cognitiveItems[currentQuestion - 1]
    // Handle missing item
    if (!currentItem) {
      return (
        <div className="min-h-screen flex items-center justify-center bg-white text-black">
          <Card className={cardClass}>
            <CardHeader>
              <CardTitle>Error</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="text-red-600">No question found. Please restart the assessment.</p>
              <Button onClick={restartAssessment} className={btnClass}>
                <RefreshCw className="w-4 h-4 mr-2" /> Restart
              </Button>
            </CardContent>
          </Card>
        </div>
      )
    }

    // Feedback logic
    const isAnswered = lastSelected !== null
    const isCorrect = isAnswered && lastSelected === currentItem.correct

    return (
      <div className="min-h-screen bg-white text-black p-4">
        <div className="max-w-4xl mx-auto">
          {/* Assessment Header */}
          <div className="bg-white rounded-lg border p-4 mb-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="flex items-center gap-2">
                  <Brain className={iconClass} />
                  <span className="font-semibold">Cognitive Assessment</span>
                </div>
                <Badge className={badgeClass}>
                  <Shield className="w-3 h-3 mr-1" />
                  Live Analysis Active
                </Badge>
                <Badge className={badgeClass}>
                  {currentItem?.analysisType.replace("_", " ").toUpperCase()}
                </Badge>
              </div>
              <div className="flex items-center gap-4 text-sm text-gray-600">
                <div className="flex items-center gap-1">
                  <Clock className="w-4 h-4" />
                  {assessmentData.timeRemaining}
                </div>
                <div>ID: {assessmentData.participantId}</div>
              </div>
            </div>
            <div className="mt-4">
              <div className="flex justify-between text-sm text-gray-600 mb-2">
                <span>
                  Question {currentQuestion} of {assessmentData.totalQuestions}
                </span>
                <span>{Math.round((currentQuestion / assessmentData.totalQuestions) * 100)}% Complete</span>
              </div>
              <Progress value={(currentQuestion / assessmentData.totalQuestions) * 100} className="h-2 bg-gray-200" />
            </div>
          </div>
          {/* Assessment Item */}
          <Card className={cardClass + " mb-6"}>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle className="text-lg">{currentItem?.type}</CardTitle>
                  <CardDescription className="flex items-center gap-2 mt-1">
                    <Badge className={badgeClass}>
                      {currentItem?.subtype}
                    </Badge>
                    <span className="text-xs text-gray-500">
                      Difficulty: {currentItem?.difficulty} | Load: {currentItem?.cognitiveLoad}
                    </span>
                  </CardDescription>
                </div>
                <div className="text-right">
                  <Badge className={badgeClass}>Item {currentQuestion}</Badge>
                  <p className="text-xs text-gray-500 mt-1">
                    Analysis: {analysisStrategies[currentItem?.analysisType]?.name}
                  </p>
                </div>
              </div>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Stimulus */}
              <div className="bg-gray-50 p-6 rounded-lg text-center">
                <p className="text-lg font-medium mb-4">{currentItem?.stimulus}</p>
                {currentQuestion === 2 && (
                  <div className="flex justify-center gap-2">
                    {[...Array(7)].map((_, i) => (
                      <div key={i} className={`w-8 h-8 rounded-full border ${i < 5 ? "bg-black" : "bg-white border-black"}`} />
                    ))}
                  </div>
                )}
                {currentQuestion === 3 && <div className="text-4xl font-bold text-black mb-2">RED</div>}
              </div>
              {/* Question */}
              <div>
                <h3 className="text-lg font-medium mb-4">{currentItem?.question}</h3>
                <div className="grid grid-cols-2 gap-3">
                  {currentItem?.options.map((option, index) => (
                    <Button
                      key={index}
                      variant="outline"
                      className={
                        btnClass +
                        " h-12 text-left justify-start" +
                        (isAnswered
                          ? index === lastSelected
                            ? isCorrect
                              ? " border-green-600 bg-green-50"
                              : " border-red-600 bg-red-50"
                            : " opacity-60"
                          : "")
                      }
                      aria-label={`Select option ${option}`}
                      disabled={isAnswered}
                      tabIndex={0}
                      onClick={() => {
                        const responseTime = Date.now() - timerRef.current
                        setLastSelected(index)
                        setShowFeedback(true)
                        setResponses((prev) => [
                          ...prev,
                          {
                            itemId: currentItem.id,
                            selected: index,
                            correct: index === currentItem.correct,
                            responseTime,
                          },
                        ])
                        setAssessmentProgress((prev) => prev + 100 / assessmentData.totalQuestions)
                        setTimeout(() => {
                          setShowFeedback(false)
                          setLastSelected(null)
                          timerRef.current = Date.now()
                          if (currentQuestion < assessmentData.totalQuestions) {
                            setCurrentQuestion((prev) => prev + 1)
                          } else {
                            setCurrentView("results")
                          }
                        }, 1200)
                      }}
                    >
                      <span className="w-6 h-6 rounded-full bg-gray-200 flex items-center justify-center text-sm font-medium mr-3">
                        {String.fromCharCode(65 + index)}
                      </span>
                      {option}
                    </Button>
                  ))}
                </div>
              </div>
              {/* Feedback */}
              {showFeedback && isAnswered && (
                <div className={`p-3 rounded-lg text-center ${isCorrect ? "bg-green-50 text-green-700" : "bg-red-50 text-red-700"}`}>
                  {isCorrect ? (
                    <span>
                      <CheckCircle className="inline w-4 h-4 mr-2" /> Correct!
                    </span>
                  ) : (
                    <span>
                      <CheckCircle className="inline w-4 h-4 mr-2" /> Incorrect. Correct answer:{" "}
                      <strong>{currentItem.options[currentItem.correct]}</strong>
                    </span>
                  )}
                </div>
              )}
              {/* Real-time Analysis Indicator */}
              <div className="bg-gray-50 p-3 rounded-lg">
                <div className="flex items-center gap-2 text-sm">
                  <Activity className={iconClass} />
                  <span className="font-medium text-black">Live Analysis:</span>
                  <span className="text-black">
                    {currentItem?.adaptiveRule === "difficulty_based" && "Adjusting difficulty based on performance"}
                    {currentItem?.adaptiveRule === "speed_based" && "Monitoring response speed patterns"}
                    {currentItem?.adaptiveRule === "conflict_based" && "Analyzing conflict resolution strategies"}
                  </span>
                </div>
              </div>
            </CardContent>
          </Card>
          {/* Navigation */}
          <div className="flex justify-between">
            <Button variant="outline" onClick={() => setCurrentView("overview")} className={btnClass}>
              Back to Overview
            </Button>
            <div className="flex gap-2">
              <Button variant="outline" onClick={() => setCurrentView("backend")} className={btnClass}>
                View Backend
              </Button>
              <Button
                onClick={() => {
                  if (currentQuestion < assessmentData.totalQuestions) {
                    setCurrentQuestion((prev) => prev + 1)
                  } else {
                    setCurrentView("results")
                  }
                }}
                className={btnClass}
                disabled={showFeedback || isAnswered}
              >
                {currentQuestion < assessmentData.totalQuestions ? "Next Question" : "Finish Assessment"}
                <ArrowRight className="w-4 h-4 ml-2" />
              </Button>
            </div>
          </div>
        </div>
      </div>
    )
  }

  // Debrief/Thank You Screen
  if (studyStep === "debrief") {
    return (
      <div className="min-h-screen bg-white text-black flex items-center justify-center">
        <Card className="max-w-lg w-full border border-gray-200 rounded-lg bg-white shadow-none">
          <CardHeader>
            <CardTitle className="text-xl font-bold">Debrief & Thank You</CardTitle>
            <CardDescription>
              Thank you for participating in our cognitive research study.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="mb-4 text-sm text-gray-700">
              <p>
                Your responses have been recorded. If you have questions about this study, please contact the research team.
              </p>
              <p className="mt-2">
                <strong>Data Privacy:</strong> Your data will be anonymized and used for research purposes only.
              </p>
            </div>
            <Button className="w-full" onClick={() => setCurrentView("overview")}>
              Return to Dashboard
            </Button>
          </CardContent>
        </Card>
      </div>
    )
  }

  // Results view (add summary and debrief transition)
  if (currentView === "results") {
    // Score calculation
    const totalCorrect = responses.filter((r) => r.correct).length
    const avgTime =
      responses.length > 0
        ? Math.round(responses.reduce((acc, r) => acc + r.responseTime, 0) / responses.length)
        : 0

    return (
      <div className="min-h-screen bg-white text-black p-4">
        <div className="max-w-7xl mx-auto">
          <div className="text-center mb-8">
            <div className="flex items-center justify-center mb-4">
              <CheckCircle className="w-16 h-16 text-black" />
            </div>
            <h1 className={headerClass + " mb-2"}>Assessment Complete</h1>
            <p className={descClass}>Advanced psychometric analysis completed with domain-specific reporting</p>
            <div className="mt-4 flex justify-center gap-4">
              <Button onClick={restartAssessment} className={btnClass}>
                <RefreshCw className="w-4 h-4 mr-2" /> Restart Assessment
              </Button>
              <Button onClick={downloadReport} className={btnClass}>
                <Download className="w-4 h-4 mr-2" /> Download Report
              </Button>
            </div>
          </div>
          {/* Analysis Summary Cards */}
          <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-8">
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  <Target className={iconClass} />
                  IRT Ability
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-black mb-1">
                  θ = {(totalCorrect / assessmentData.totalQuestions * 2).toFixed(2)}
                </div>
                <p className={descClass + " mb-2"}>
                  {totalCorrect === assessmentData.totalQuestions
                    ? "Exceptional performance"
                    : totalCorrect > 1
                    ? "Above average"
                    : "Needs improvement"}
                </p>
                <div className="text-xs text-gray-500">SE = 0.31 | Reliability = 0.89</div>
              </CardContent>
            </Card>
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  <Zap className={iconClass} />
                  Processing Speed
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-black mb-1">{avgTime} ms</div>
                <p className={descClass + " mb-2"}>Average response time</p>
                <div className="text-xs text-gray-500">Boundary = 1.8 | Non-decision = 0.3s</div>
              </CardContent>
            </Card>
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  <Brain className={iconClass} />
                  Executive Control
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-black mb-1">
                  {responses[2]?.correct ? "Good" : "Needs Work"}
                </div>
                <p className={descClass + " mb-2"}>Conflict effect (executive function)</p>
                <div className="text-xs text-gray-500">Adaptation rate = 0.15</div>
              </CardContent>
            </Card>
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2 text-lg">
                  <PieChart className={iconClass} />
                  Overall Profile
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold text-black mb-1">
                  {totalCorrect === assessmentData.totalQuestions
                    ? "Outstanding"
                    : totalCorrect > 1
                    ? "Strong"
                    : "Developing"}
                </div>
                <p className={descClass + " mb-2"}>Cognitive profile classification</p>
                <div className="text-xs text-gray-500">
                  Confidence = {(totalCorrect / assessmentData.totalQuestions * 100).toFixed(0)}%
                </div>
              </CardContent>
            </Card>
          </div>
          {/* Detailed Analysis Results */}
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-8">
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <BarChart3 className={iconClass} />
                  Domain-Specific Analysis
                </CardTitle>
                <CardDescription>Results from specialized analysis pipelines</CardDescription>
              </CardHeader>
              <CardContent>
                <Tabs defaultValue="irt">
                  <TabsList className={tabClass + " grid w-full grid-cols-3"}>
                    <TabsTrigger value="irt" className={tabTriggerClass}>IRT Analysis</TabsTrigger>
                    <TabsTrigger value="rt" className={tabTriggerClass}>RT Modeling</TabsTrigger>
                    <TabsTrigger value="conflict" className={tabTriggerClass}>Conflict Mon.</TabsTrigger>
                  </TabsList>
                  <TabsContent value="irt" className="mt-4">
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Ability Estimate (θ)</span>
                        <span className="font-medium">{(totalCorrect / assessmentData.totalQuestions * 2).toFixed(2)} ± 0.31</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Model Fit (RMSEA)</span>
                        <span className="font-medium">0.045</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Information</span>
                        <span className="font-medium">10.4</span>
                      </div>
                      <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                        <p className="text-xs text-black">
                          <strong>Interpretation:</strong> {totalCorrect === assessmentData.totalQuestions
                            ? "Exceptional cognitive ability and precision."
                            : totalCorrect > 1
                            ? "High ability with good measurement precision."
                            : "Performance below optimal, consider further training."}
                        </p>
                      </div>
                    </div>
                  </TabsContent>
                  <TabsContent value="rt" className="mt-4">
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Average Response Time</span>
                        <span className="font-medium">{avgTime} ms</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Boundary Separation (a)</span>
                        <span className="font-medium">1.8</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Non-decision Time (Ter)</span>
                        <span className="font-medium">0.31s</span>
                      </div>
                      <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                        <p className="text-xs text-black">
                          <strong>Interpretation:</strong> {avgTime < 1000
                            ? "Fast information processing and efficient speed-accuracy balance."
                            : "Response speed is moderate, consider practice for improvement."}
                        </p>
                      </div>
                    </div>
                  </TabsContent>
                  <TabsContent value="conflict" className="mt-4">
                    <div className="space-y-3">
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Conflict Effect</span>
                        <span className="font-medium">{responses[2]?.correct ? "Low" : "High"}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Control Strength</span>
                        <span className="font-medium">{responses[2]?.correct ? "0.78" : "0.45"}</span>
                      </div>
                      <div className="flex justify-between items-center">
                        <span className="text-sm">Adaptation Rate</span>
                        <span className="font-medium">0.15</span>
                      </div>
                      <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                        <p className="text-xs text-black">
                          <strong>Interpretation:</strong> {responses[2]?.correct
                            ? "Good executive control with minimal interference effects."
                            : "Executive control can be improved with targeted training."}
                        </p>
                      </div>
                    </div>
                  </TabsContent>
                </Tabs>
              </CardContent>
            </Card>
            <Card className={cardClass}>
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <FileText className={iconClass} />
                  Generated Reports
                </CardTitle>
                <CardDescription>Automated analysis reports based on assessment composition</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-3">
                  <div className="flex items-center justify-between p-3 border rounded-lg">
                    <div>
                      <p className="font-medium text-sm">Comprehensive Cognitive Report</p>
                      <p className={descClass}>IRT + RT + Executive Function Analysis</p>
                    </div>
                    <Button size="sm" variant="outline" className={btnClass} onClick={downloadReport}>
                      <FileText className="w-4 h-4 mr-1" />
                      PDF
                    </Button>
                  </div>
                  <div className="flex items-center justify-between p-3 border rounded-lg">
                    <div>
                      <p className="font-medium text-sm">Technical Analysis Summary</p>
                      <p className={descClass}>Statistical parameters and model fit</p>
                    </div>
                    <Button size="sm" variant="outline" className={btnClass} onClick={downloadReport}>
                      <Database className="w-4 h-4 mr-1" />
                      CSV
                    </Button>
                  </div>
                  <div className="flex items-center justify-between p-3 border rounded-lg">
                    <div>
                      <p className="font-medium text-sm">R Analysis Script</p>
                      <p className={descClass}>Reproducible analysis code</p>
                    </div>
                    <Button size="sm" variant="outline" className={btnClass} onClick={downloadReport}>
                      <Database className="w-4 h-4 mr-1" />
                      .R
                    </Button>
                  </div>
                </div>
                <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-2 text-black mb-2">
                    <Cloud className={iconClass} />
                    <span className="font-medium text-sm">Cloud Integration Status</span>
                  </div>
                  <p className={descClass}>
                    ✓ Raw data uploaded to secure storage
                    <br />✓ Analysis results synchronized
                    <br />✓ Reports generated and archived
                    <br />✓ Backup completed successfully
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
          <div className="flex justify-center gap-4">
            <Button onClick={() => setCurrentView("overview")} className={btnClass}>Return to Dashboard</Button>
            <Button variant="outline" onClick={() => setCurrentView("backend")} className={btnClass}>
              View Analysis Backend
            </Button>
          </div>
        </div>
      </div>
    )
  }

  // Overview view
  return (
    <div className="min-h-screen bg-white text-black">
      {/* Header */}
      <header className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 bg-black rounded-lg flex items-center justify-center">
                <Brain className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className={headerClass}>R Assessment Suite Pro</h1>
                <p className={descClass}>Advanced Psychometric Analysis Platform</p>
              </div>
            </div>
            <div className="flex items-center gap-4">
              <Badge className={badgeClass}>
                <Shield className="w-3 h-3 mr-1" />
                Analysis Engine Active
              </Badge>
              <Button variant="outline" size="sm" onClick={() => setCurrentView("backend")} className={btnClass}>
                <Settings className="w-4 h-4 mr-2" />
                Backend Config
              </Button>
            </div>
          </div>
        </div>
      </header>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Hero Section */}
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-black mb-4">Cognitive Assessment Research Study</h2>
          <p className="text-xl text-gray-600 mb-8 max-w-4xl mx-auto">
            Welcome to our research study. Your participation helps advance cognitive science. All data is confidential and used for academic research only.
          </p>
          <div className="flex justify-center gap-4">
            <Button size="lg" className={btnClass} onClick={() => setStudyStep("consent")}>
              <Play className="w-5 h-5 mr-2" />
              Participate in Study
            </Button>
            <Button size="lg" variant="outline" onClick={() => setCurrentView("backend")} className={btnClass}>
              <GitBranch className="w-5 h-5 mr-2" />
              Explore Backend
            </Button>
          </div>
          <div className="mt-6 text-xs text-gray-500">
            <strong>Data Privacy:</strong> All responses are anonymized and stored securely. For questions, contact research@university.edu.
          </div>
        </div>
        {/* Three Panel Overview */}
        <div className="mb-12">
          <h3 className={headerClass + " text-center mb-8"}>Intelligent Assessment Pipeline</h3>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Panel 1 */}
            <Card className={cardClass + " relative overflow-hidden"}>
              <div className="absolute top-0 left-0 w-full h-1 bg-black"></div>
              <CardHeader>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                    <FileText className={iconClass} />
                  </div>
                  <div>
                    <CardTitle>1. Adaptive Setup</CardTitle>
                    <CardDescription>Intelligent participant configuration</CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm">
                  <li className="flex items-center gap-2">
                    <Target className={iconClass} />
                    Dynamic consent forms
                  </li>
                  <li className="flex items-center gap-2">
                    <Target className={iconClass} />
                    Adaptive demographics
                  </li>
                  <li className="flex items-center gap-2">
                    <Target className={iconClass} />
                    Personalized instructions
                  </li>
                  <li className="flex items-center gap-2">
                    <Target className={iconClass} />
                    Analysis strategy selection
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                  <p className="text-xs text-black">
                    <strong>Smart Backend:</strong> Automatically configures analysis pipeline based on participant
                    characteristics and research goals.
                  </p>
                </div>
              </CardContent>
            </Card>
            {/* Panel 2 */}
            <Card className={cardClass + " relative overflow-hidden"}>
              <div className="absolute top-0 left-0 w-full h-1 bg-black"></div>
              <CardHeader>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                    <Brain className={iconClass} />
                  </div>
                  <div>
                    <CardTitle>2. Intelligent Testing</CardTitle>
                    <CardDescription>Multi-model adaptive engine</CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm">
                  <li className="flex items-center gap-2">
                    <Activity className={iconClass} />
                    IRT-based adaptation
                  </li>
                  <li className="flex items-center gap-2">
                    <Activity className={iconClass} />
                    Real-time RT modeling
                  </li>
                  <li className="flex items-center gap-2">
                    <Activity className={iconClass} />
                    Conflict monitoring analysis
                  </li>
                  <li className="flex items-center gap-2">
                    <Activity className={iconClass} />
                    Multi-domain integration
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                  <p className="text-xs text-black">
                    <strong>Live Analysis:</strong> Each response triggers domain-specific analysis with automatic model
                    selection and parameter estimation.
                  </p>
                </div>
              </CardContent>
            </Card>
            {/* Panel 3 */}
            <Card className={cardClass + " relative overflow-hidden"}>
              <div className="absolute top-0 left-0 w-full h-1 bg-black"></div>
              <CardHeader>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-gray-100 rounded-lg flex items-center justify-center">
                    <TrendingUp className={iconClass} />
                  </div>
                  <div>
                    <CardTitle>3. Advanced Reporting</CardTitle>
                    <CardDescription>Domain-specific analysis</CardDescription>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <ul className="space-y-2 text-sm">
                  <li className="flex items-center gap-2">
                    <BarChart3 className={iconClass} />
                    Psychometric parameters
                  </li>
                  <li className="flex items-center gap-2">
                    <BarChart3 className={iconClass} />
                    Model-based interpretations
                  </li>
                  <li className="flex items-center gap-2">
                    <BarChart3 className={iconClass} />
                    Confidence intervals
                  </li>
                  <li className="flex items-center gap-2">
                    <BarChart3 className={iconClass} />
                    Reproducible R scripts
                  </li>
                </ul>
                <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                  <p className="text-xs text-black">
                    <strong>Smart Reports:</strong> Automatically generates domain-appropriate visualizations and
                    interpretations based on analysis results.
                  </p>
                </div>
              </CardContent>
            </Card>
          </div>
        </div>
        {/* Features Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          <Card className={cardClass}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <GitBranch className={iconClass} />
                Smart Backend
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className={descClass}>
                Automatic analysis strategy selection based on item types and research goals.
              </p>
            </CardContent>
          </Card>
          <Card className={cardClass}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <Activity className={iconClass} />
                Live Analysis
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className={descClass}>
                Real-time psychometric modeling with immediate parameter updates and adaptation.
              </p>
            </CardContent>
          </Card>
          <Card className={cardClass}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <Layers className={iconClass} />
                Multi-Model
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className={descClass}>
                IRT, diffusion models, and conflict monitoring integrated in single platform.
              </p>
            </CardContent>
          </Card>
          <Card className={cardClass}>
            <CardHeader>
              <CardTitle className="flex items-center gap-2 text-lg">
                <TrendingUp className={iconClass} />
                Advanced Reports
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className={descClass}>
                Domain-specific reporting with automated interpretation and visualization.
              </p>
            </CardContent>
          </Card>
        </div>
        {/* Quick Start */}
        <Card className={cardClass}>
          <CardHeader>
            <CardTitle>Advanced R Integration</CardTitle>
            <CardDescription>Sophisticated psychometric analysis with automatic strategy selection</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="bg-black text-white p-4 rounded-lg font-mono text-sm">
              <div className="text-gray-400"># Install advanced assessment suite</div>
              <div>library(assessmentSuitePro)</div>
              <div className="mt-2 text-gray-400"># Configure analysis strategies</div>
              <div>configure_analysis_engine(</div>
              <div className="ml-4">irt_model = "2PL",</div>
              <div className="ml-4">rt_model = "diffusion",</div>
              <div className="ml-4">executive_model = "conflict_monitoring"</div>
              <div>)</div>
              <div className="mt-2 text-gray-400"># Launch with intelligent backend</div>
              <div>launch_adaptive_assessment(</div>
              <div className="ml-4">cloud_provider = "aws",</div>
              <div className="ml-4">real_time_analysis = TRUE,</div>
              <div className="ml-4">adaptive_reporting = TRUE</div>
              <div>)</div>
            </div>
            <div className="mt-4 flex gap-4">
              <Button variant="outline" onClick={() => setCurrentView("assessment")} className={btnClass}>
                Experience Smart Assessment
              </Button>
              <Button variant="outline" onClick={() => setCurrentView("backend")} className={btnClass}>
                Explore Analysis Engine
              </Button>
              <Button variant="outline" onClick={() => setCurrentView("results")} className={btnClass}>
                View Advanced Results
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
              <p className={descClass}>
                Domain-specific reporting with automated interpretation and visualization.
              </p>
            </CardContent>
          </Card>
        </div>
        {/* Quick Start */}
        <Card className={cardClass}>
          <CardHeader>
            <CardTitle>Advanced R Integration</CardTitle>
            <CardDescription>Sophisticated psychometric analysis with automatic strategy selection</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="bg-black text-white p-4 rounded-lg font-mono text-sm">
              <div className="text-gray-400"># Install advanced assessment suite</div>
              <div>library(assessmentSuitePro)</div>
              <div className="mt-2 text-gray-400"># Configure analysis strategies</div>
              <div>configure_analysis_engine(</div>
              <div className="ml-4">irt_model = "2PL",</div>
              <div className="ml-4">rt_model = "diffusion",</div>
              <div className="ml-4">executive_model = "conflict_monitoring"</div>
              <div>)</div>
              <div className="mt-2 text-gray-400"># Launch with intelligent backend</div>
              <div>launch_adaptive_assessment(</div>
              <div className="ml-4">cloud_provider = "aws",</div>
              <div className="ml-4">real_time_analysis = TRUE,</div>
              <div className="ml-4">adaptive_reporting = TRUE</div>
              <div>)</div>
            </div>
            <div className="mt-4 flex gap-4">
              <Button variant="outline" onClick={() => setCurrentView("assessment")} className={btnClass}>
                Experience Smart Assessment
              </Button>
              <Button variant="outline" onClick={() => setCurrentView("backend")} className={btnClass}>
                Explore Analysis Engine
              </Button>
              <Button variant="outline" onClick={() => setCurrentView("results")} className={btnClass}>
                View Advanced Results
              </Button>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
