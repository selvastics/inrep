# Create cognitive_items dataset for advanced examples
# Generate a comprehensive cognitive assessment item bank

# Set seed for reproducibility
set.seed(42)

# Create cognitive items with 2PL parameters
cognitive_items <- data.frame(
  item_id = paste0("COG_", sprintf("%03d", 1:50)),
  content = paste("Cognitive Item", 1:50),
  domain = rep(c("Verbal_Reasoning", "Numerical_Reasoning", "Spatial_Reasoning", 
                 "Working_Memory", "Processing_Speed"), each = 10),
  difficulty = round(rnorm(50, 0, 1.2), 3),
  discrimination = round(runif(50, 0.8, 2.5), 3),
  stringsAsFactors = FALSE
)

# Add some realistic cognitive item content
cognitive_items$content[1:10] <- c(
  "Complete the analogy: Cat is to Kitten as Dog is to ___",
  "Which word does not belong: Apple, Orange, Banana, Carrot",
  "If all roses are flowers and some flowers are red, then:",
  "What comes next in the sequence: 2, 4, 8, 16, ___",
  "Arrange these words to form a sentence: quickly/ran/the/dog",
  "Which of these is a synonym for 'abundant'?",
  "If A>B and B>C, then A_C (fill in: >, <, =)",
  "How many words can you make from the letters in 'PSYCHOLOGY'?",
  "What is the opposite of 'construct'?",
  "Complete: 'Beginning' is to 'End' as 'Alpha' is to ___"
)

cognitive_items$content[11:20] <- c(
  "If 3x + 7 = 22, what is the value of x?",
  "A train travels 120 km in 2 hours. What is its speed?",
  "What is 15% of 240?",
  "If a rectangle has length 8 and width 5, what is its area?",
  "Solve: (12 + 8) ÷ 4 × 3",
  "A shop offers 20% discount. If an item costs $50, what do you pay?",
  "What is the next number: 1, 1, 2, 3, 5, 8, ___",
  "If you buy 3 items at $2.50 each, how much change from $10?",
  "What is 2/3 of 150?",
  "A circle has radius 5. What is its circumference? (π ≈ 3.14)"
)

cognitive_items$content[21:30] <- c(
  "Which shape comes next in the pattern? [geometric sequence]",
  "How many cubes are in this 3D structure?",
  "Which piece completes the puzzle?",
  "Rotate this shape 90° clockwise. What does it look like?",
  "Which of these shapes is the odd one out?",
  "If you unfold this cube, which pattern would you see?",
  "Which direction should this arrow point to complete the pattern?",
  "How many triangles can you count in this figure?",
  "Which shape is missing from this matrix?",
  "What 3D object would this 2D pattern create when folded?"
)

cognitive_items$content[31:40] <- c(
  "Remember these numbers: 7, 3, 9, 1, 5. Now recall them backwards.",
  "Listen to this sequence and repeat: A, F, K, C, H",
  "Which of these words was in the previous list?",
  "Recall the positions of these colored dots after 3 seconds.",
  "How many items were in the list you just saw?",
  "Which number appeared twice in the sequence?",
  "Reconstruct this pattern from memory.",
  "What was the third word in the sentence you just read?",
  "Which color appeared in position 2 of the sequence?",
  "How many consonants were in the word list?"
)

cognitive_items$content[41:50] <- c(
  "Count the number of red circles as quickly as possible.",
  "Press space when you see a target letter 'X'.",
  "How quickly can you identify all the differences?",
  "Respond as fast as possible when the screen changes color.",
  "Count backwards from 100 by 7s as quickly as possible.",
  "How fast can you name all these colors?",
  "Identify the target shape among distractors quickly.",
  "Press the correct key for each symbol as fast as possible.",
  "How quickly can you sort these items by category?",
  "Respond to targets while ignoring distractors."
)

# Save as RDA file
save(cognitive_items, file = "data/cognitive_items.rda")

cat("Created cognitive_items dataset with", nrow(cognitive_items), "items\n")
cat("Domains:", unique(cognitive_items$domain), "\n")
cat("Difficulty range:", range(cognitive_items$difficulty), "\n") 
cat("Discrimination range:", range(cognitive_items$discrimination), "\n")
