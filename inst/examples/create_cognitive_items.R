# Create cognitive_items dataset for advanced examples
# Generate a comprehensive cognitive assessment item bank

# Set seed for reproducibility
set.seed(42)

# Create cognitive items with 2PL parameters for binary responses
cognitive_items <- data.frame(
  # Required columns for inrep 2PL model
  Question = c(
    "Complete the analogy: Cat is to Kitten as Dog is to ___",
    "Which word does not belong: Apple, Orange, Banana, Carrot",
    "If all roses are flowers and some flowers are red, then:",
    "What comes next in the sequence: 2, 4, 8, 16, ___",
    "Arrange these words to form a sentence: quickly/ran/the/dog",
    "Which of these is a synonym for 'abundant'?",
    "If A>B and B>C, then A_C (fill in: >, <, =)",
    "How many words can you make from the letters in 'PSYCHOLOGY'?",
    "What is the opposite of 'construct'?",
    "Complete: 'Beginning' is to 'End' as 'Alpha' is to ___",

    "If 3x + 7 = 22, what is the value of x?",
    "A train travels 120 km in 2 hours. What is its speed?",
    "What is 15% of 240?",
    "If a rectangle has length 8 and width 5, what is its area?",
    "Solve: (12 + 8) ÷ 4 × 3",
    "A shop offers 20% discount. If an item costs $50, what do you pay?",
    "What is the next number: 1, 1, 2, 3, 5, 8, ___",
    "If you buy 3 items at $2.50 each, how much change from $10?",
    "What is 2/3 of 150?",
    "A circle has radius 5. What is its circumference? (π ≈ 3.14)",

    "Which shape comes next in the pattern?",
    "How many cubes are in this 3D structure?",
    "Which piece completes the puzzle?",
    "Rotate this shape 90° clockwise. What does it look like?",
    "Which of these shapes is the odd one out?",
    "If a square has side length 4, what is its perimeter?",
    "What is the area of a triangle with base 6 and height 4?",
    "How many faces does a cube have?",
    "What is the volume of a rectangular prism (3×4×5)?",
    "Which angle is 90 degrees?",

    "Complete the series: A, C, E, G, ___",
    "If today is Monday, what day is it in 7 days?",
    "How many months have 31 days?",
    "What is the 5th letter of the alphabet?",
    "Count backwards: 10, 9, 8, 7, ___",
    "If 2 + 2 = 4, what is 2 × 2?",
    "What color is the sky on a clear day?",
    "How many fingers do you have on one hand?",
    "What is 1 + 1?",
    "Which is bigger: 5 or 3?",

    "What time is it if the clock shows 3:00?",
    "How many wheels does a car have?",
    "What do you call a baby dog?",
    "Which season comes after summer?",
    "How many colors are in a rainbow?",
    "What is the first letter of your name?",
    "How many legs does a chair have?",
    "What do you use to write?",
    "Which hand do you write with?",
    "How many eyes do you have?"
  ),

  # 2PL IRT parameters
  a = round(runif(50, 0.8, 2.5), 3),  # Discrimination parameters
  b = round(rnorm(50, 0, 1.2), 3),    # Difficulty parameters

  # Correct answers (for scoring)
  Answer = c(
    "Puppy", "Carrot", "Some roses are red", "32", "The dog ran quickly",
    "Plentiful", ">", "8", "Destroy", "Omega",
    "5", "60", "36", "40", "15", "40", "13", "2.5", "100", "78.5",
    "Circle", "8", "Corner piece", "Rotated shape", "Triangle",
    "16", "12", "6", "60", "Right angle",
    "I", "Monday", "7", "E", "6", "4", "Blue", "5", "2", "5",
    "3:00", "4", "Puppy", "Fall", "7", "A", "4", "Pen", "Right", "2"
  ),

  # Domain classification
  domain = rep(c("Verbal_Reasoning", "Numerical_Reasoning", "Spatial_Reasoning",
                 "Working_Memory", "Processing_Speed"), each = 10),

  # Difficulty levels
  difficulty_level = c(
    rep("Easy", 10), rep("Medium", 10), rep("Medium", 10),
    rep("Easy", 10), rep("Easy", 10)
  ),

  stringsAsFactors = FALSE
)

# Save to data directory
save(cognitive_items, file = "../../data/cognitive_items.rda")
