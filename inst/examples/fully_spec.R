# Example: adaptive multiple-choice test with a 2PL model ----
# Every argument is set explicitly. The items and their a and b values are
# invented for illustration; they are not calibrated. Two items refer to
# figures ("Pattern A", "Image A") that this example does not include.
# The object name masks the cognitive_items data set of the package.
cognitive_items <- data.frame(
  Question = c(
    "If A>B and B>C, then A_C (fill in: >, <, =)",
    "A train travels 120 km in 2 hours. What is its speed?",
    "Which number completes the pattern: 3, 6, 9, 12, __?",
    "Which shape comes next in the sequence?",
    "What is 15% of 80?",
    "Which word is a synonym of 'rapid'?",
    "If 2x + 5 = 19, what is x?",
    "Which fraction is equivalent to 3/4?",
    "Rotate the figure 90° clockwise. Which orientation matches?",
    "What is the median of 2, 7, 3, 9, 5?",
    "Which of the following is a prime number?",
    "Complete the analogy: Finger is to hand as leaf is to __"
  ),
  Option1 = c(">", "40 km/h", "14", "Pattern A", "10", "slow", "6", "6/8", "Image A", "3", "21", "tree"),
  Option2 = c("<", "50 km/h", "15", "Pattern B", "12", "swift", "7", "9/12", "Image B", "5", "22", "branch"),
  Option3 = c("=", "60 km/h", "16", "Pattern C", "15", "rapidly", "8", "12/16", "Image C", "7", "23", "plant"),
  Option4 = c("?", "70 km/h", "18", "Pattern D", "18", "quick", "9", "15/20", "Image D", "9", "24", "stem"),
  Answer  = c(">", "60 km/h", "15", "Pattern C", "12", "quick", "7", "9/12", "Image C", "5", "23", "tree"),
  domain  = c("Logic","Math","Math","Spatial","Math","Verbal","Math","Math","Spatial","Math","Math","Verbal"),
  a = c(1.25, 1.10, 0.95, 1.30, 1.05, 1.15, 1.20, 0.90, 1.35, 1.00, 1.40, 1.05),
  b = c(0.00, -0.50, -0.20, 0.80, -0.30, 0.10, 0.40, -0.10, 1.10, 0.00, 0.60, -0.15),
  stringsAsFactors = FALSE
)

# Create a detailed configuration
advanced_config <- create_study_config(
  name = "Cognitive Ability Assessment",
  model = "2PL",
  estimation_method = "EAP", 
  adaptive = TRUE,
  criteria = "MI",
  min_items = 8,  
  max_items = 15,  
  min_SEM = 0.35,  
  theta_prior = c(0, 1),
  demographics = c("Age", "Gender", "Education", "Native_Language"),
  input_types = list(
    Age = "numeric",
    Gender = "select",
    Education = "select",
    Native_Language = "text"
  ),
  theme = "Professional",
  session_save = TRUE,
  parallel_computation = FALSE,
  cache_enabled = FALSE,
  # Elements of the built-in results page
  participant_report = list(
    show_theta_plot = TRUE,             # theta and SE after each item
    show_response_table = TRUE,
    show_item_difficulty_trend = TRUE,  # b of the administered items
    show_domain_breakdown = TRUE,
    show_recommendations = TRUE         # needs recommendation_fun; none is set here
  )
)

launch_study(
  config = advanced_config,
  item_bank = cognitive_items
)
