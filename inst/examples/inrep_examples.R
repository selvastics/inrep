# Purpose: Demonstrates various use cases of the inrep package for adaptive and non-adaptive psychological assessments.
# This script provides clear, self-contained examples that guide users from basic to advanced configurations.
# Each chunk launches a study and includes detailed explanations for educational purposes.

# Required packages
library(inrep)
library(uuid)
library(shiny)

# Example 1: Basic Adaptive Test with GRM
# Purpose: Introduce beginners to a simple adaptive test using the Graded Response Model (GRM).
#' @description A straightforward adaptive test with default settings, ideal for users new to the inrep package.
#' @details Uses the built-in bfi_items dataset to assess personality traits with a maximum of 10 items.
#' @example
#' # Load the package and data
#' library(inrep)
#' data(bfi_items)
#' 
#' # Create a basic configuration
#' config <- create_study_config(
#'   model = "GRM",          # Graded Response Model
#'   max_items = 10,         # Stop after 10 items
#'   adaptive = TRUE         # Enable adaptive item selection
#' )
#' 
#' # Launch the study
#' cat("Launching Example 1: Basic Adaptive Test with GRM\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, bfi_items)
#' 
#' # Alternatively, define a custom item bank
#' item_bank <- data.frame(
#'   Question = c("I am talkative.", "I am reserved.", "I am full of energy.", "I am quiet.", "I am outgoing."),
#'   a = c(1.2, 1.1, 1.3, 1.0, 1.2),
#'   b1 = c(-0.5, 0.5, -1.0, 1.0, -0.8),
#'   b2 = c(0.0, 1.0, -0.5, 1.5, -0.3),
#'   b3 = c(0.5, 1.5, 0.0, 2.0, 0.2),
#'   b4 = c(1.0, 2.0, 0.5, 2.5, 0.7),
#'   ResponseCategories = rep("1,2,3,4,5", 5)
#' )
#' 
#' # Launch with custom item bank
#' cat("Launching Example 1 (Custom Item Bank): Basic Adaptive Test with GRM\n")
#' cat("Access at: http://localhost:3838\n")
#' launch_study(config, item_bank)

# ...existing code for all other examples...
