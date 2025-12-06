# Create math_items dataset for mathematics assessment
# Generate a comprehensive mathematics item bank

# Set seed for reproducibility
set.seed(123)

# Create mathematics items with GRM parameters (5-point scale)
math_items <- data.frame(
  item_id = paste0("MATH_", sprintf("%03d", 1:40)),
  
  # Mathematics questions across different domains
  Question = c(
    # Basic Arithmetic (1-10)
    "What is 15 + 28?",
    "Calculate 84 - 37",
    "What is 6 × 9?",
    "What is 144 ÷ 12?",
    "What is 25% of 80?",
    "If 3x = 15, what is x?",
    "What is 2³ (2 to the power of 3)?",
    "Calculate: (4 + 6) × 3",
    "What is the square root of 64?",
    "Round 47.8 to the nearest whole number",
    
    # Fractions and Decimals (11-20)
    "What is 1/2 + 1/4?",
    "Convert 0.75 to a fraction",
    "What is 2.5 × 4?",
    "Which is larger: 3/4 or 0.8?",
    "What is 5/6 - 1/3?",
    "Convert 3/5 to a decimal",
    "What is 1.2 + 0.35?",
    "What is 7/8 as a percentage?",
    "Calculate: 2.4 ÷ 0.6",
    "What is 40% as a fraction in lowest terms?",
    
    # Algebra (21-30)
    "If y = 2x + 3 and x = 5, what is y?",
    "Solve for x: 2x - 7 = 13",
    "What is the slope of the line y = 3x + 2?",
    "Simplify: 4x + 2x - x",
    "If f(x) = x² + 1, what is f(3)?",
    "Solve: x/4 = 12",
    "What is (x + 2)(x - 3) when expanded?",
    "If 2x + y = 10 and x = 3, what is y?",
    "What is the value of x² when x = -4?",
    "Simplify: (3x)²",
    
    # Geometry (31-40)
    "What is the area of a rectangle with length 8 and width 5?",
    "What is the circumference of a circle with radius 3? (Use π ≈ 3.14)",
    "What is the area of a triangle with base 6 and height 4?",
    "How many degrees in the interior angles of a triangle?",
    "What is the volume of a cube with side length 4?",
    "What is the area of a circle with radius 5? (Use π ≈ 3.14)",
    "What is the perimeter of a square with side length 7?",
    "If two angles of a triangle are 60° and 70°, what is the third angle?",
    "What is the length of the hypotenuse of a right triangle with legs 3 and 4?",
    "What is the area of a parallelogram with base 10 and height 6?"
  ),
  
  # Domain classification
  domain = c(
    rep("Basic_Arithmetic", 10),
    rep("Fractions_Decimals", 10), 
    rep("Algebra", 10),
    rep("Geometry", 10)
  ),
  
  # Difficulty levels
  difficulty_level = c(
    rep("Easy", 10),
    rep("Medium", 10),
    rep("Medium", 10),
    rep("Hard", 10)
  ),
  
  # IRT parameters for GRM model (5-point scale: 1=Very Difficult, 5=Very Easy)
  a = round(runif(40, 0.8, 2.2), 2),  # Discrimination parameters
  
  # Threshold parameters (b1 < b2 < b3 < b4)
  b1 = round(rnorm(40, -1.5, 0.4), 2),  # Threshold 1 (1|2)
  b2 = round(rnorm(40, -0.5, 0.4), 2),  # Threshold 2 (2|3)  
  b3 = round(rnorm(40, 0.5, 0.4), 2),   # Threshold 3 (3|4)
  b4 = round(rnorm(40, 1.5, 0.4), 2),   # Threshold 4 (4|5)
  
  # Response categories (5-point Likert scale)
  ResponseCategories = rep("1,2,3,4,5", 40),
  
  # Grade level appropriateness
  grade_level = c(
    rep("6-8", 10),   # Basic Arithmetic
    rep("7-9", 10),   # Fractions/Decimals
    rep("8-10", 10),  # Algebra
    rep("9-11", 10)   # Geometry
  ),
  
  stringsAsFactors = FALSE
)

# Ensure threshold ordering (b1 < b2 < b3 < b4)
for (i in 1:nrow(math_items)) {
  thresholds <- sort(c(math_items$b1[i], math_items$b2[i], math_items$b3[i], math_items$b4[i]))
  math_items$b1[i] <- thresholds[1]
  math_items$b2[i] <- thresholds[2] 
  math_items$b3[i] <- thresholds[3]
  math_items$b4[i] <- thresholds[4]
}

# Save to data directory
save(math_items, file = "../../data/math_items.rda")

cat("Math items dataset created successfully!\n")
cat("Items:", nrow(math_items), "\n")
cat("Columns:", names(math_items), "\n")
cat("Domains:", paste(unique(math_items$domain), collapse = ", "), "\n")
cat("Difficulty levels:", paste(unique(math_items$difficulty_level), collapse = ", "), "\n")
cat("Grade levels:", paste(unique(math_items$grade_level), collapse = ", "), "\n")
cat("\nUsage:\n")
cat("config <- create_study_config(\n")
cat("  name = 'Mathematics Assessment',\n")
cat("  model = 'GRM',\n")
cat("  max_items = 20,\n")
cat("  min_items = 10,\n")
cat("  criteria = 'MI',\n")
cat("  theme = 'Educational'\n")
cat(")\n")
cat("launch_study(config, math_items)\n")
