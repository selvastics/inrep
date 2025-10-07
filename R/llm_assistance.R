#' Generate LLM Customization Prompt
#'
#' @description
#' Generates a prompt with your current configuration and inrep package context.
#' Copy the output to an LLM (ChatGPT, Claude, etc.) to get customized R code.
#'
#' @param config Study configuration from \code{\link{create_study_config}}.
#'   If NULL, generates general context.
#' @param focus Focus area: "stopping_rules", "selection", "estimation", "general".
#' @param item_bank Optional item bank for additional context.
#'
#' @return Invisibly returns prompt text.
#' @export
#'
#' @examples
#' \dontrun{
#' config <- create_study_config(
#'   name = "My Study",
#'   model = "GRM",
#'   min_items = 5,
#'   max_items = 20,
#'   min_SEM = 0.3
#' )
#' generate_llm_prompt(config, focus = "general")
#' }
generate_llm_prompt <- function(config = NULL, focus = "general", item_bank = NULL) {
  
  valid_focus <- c("stopping_rules", "selection", "estimation", "general")
  if (!focus %in% valid_focus) {
    stop("Invalid focus. Must be one of: ", paste(valid_focus, collapse = ", "))
  }
  
  if (is.null(config)) {
    prompt <- build_general_prompt()
  } else {
    prompt <- switch(focus,
      "stopping_rules" = build_stopping_rules_prompt(config, item_bank),
      "selection" = build_selection_prompt(config, item_bank),
      "estimation" = build_estimation_prompt(config, item_bank),
      "general" = build_general_customization_prompt(config, item_bank)
    )
  }
  
  cat("\n", strrep("=", 80), "\n", sep = "")
  cat("COPY THIS PROMPT TO YOUR LLM (ChatGPT, Claude, etc.)\n")
  cat(strrep("=", 80), "\n\n", sep = "")
  cat(prompt)
  cat("\n\n", strrep("=", 80), "\n\n", sep = "")
  
  invisible(prompt)
}


#' @noRd
build_general_prompt <- function() {
  paste0(
    "I'm using the inrep R package for adaptive assessments (IRT-based, uses TAM).\n\n",
    
    "=== WHAT I WANT ===\n",
    "[Describe your customization goal here]\n\n",
    
    "=== THREE README EXAMPLES FROM inrep ===\n\n",
    
    "EXAMPLE 1 - Adaptive Personality Assessment:\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"Adaptive Personality Assessment\",\n",
    "  model = \"GRM\",           # Graded Response Model\n",
    "  adaptive = TRUE,         # Enable adaptive testing (default)\n",
    "  max_items = 15,\n",
    "  min_items = 5,\n",
    "  min_SEM = 0.3,          # Stop when precision reached\n",
    "  demographics = c(\"Age\", \"Gender\"),\n",
    "  theme = \"Professional\"\n",
    ")\n",
    "launch_study(config, bfi_items)\n",
    "```\n\n",
    
    "EXAMPLE 2 - Fixed Questionnaire:\n",
    "```r\n",
    "config_fixed <- create_study_config(\n",
    "  name = \"Personality Questionnaire\",\n",
    "  adaptive = FALSE,        # Disable adaptive testing\n",
    "  max_items = 5,          # Show exactly 5 items in order\n",
    "  theme = \"hildesheim\",   # University theme\n",
    "  session_save = TRUE     # Enable recovery\n",
    ")\n",
    "launch_study(config_fixed, bfi_items)\n",
    "```\n\n",
    
    "EXAMPLE 3 - Cognitive Ability Assessment (2PL, fully specified):\n",
    "```r\n",
    "advanced_config <- create_study_config(\n",
    "  name = \"Cognitive Ability Assessment\",\n",
    "  model = \"2PL\",\n",
    "  estimation_method = \"TAM\",\n",
    "  adaptive = TRUE,\n",
    "  criteria = \"MI\",\n",
    "  min_items = 8,\n",
    "  max_items = 15,\n",
    "  min_SEM = 0.35,\n",
    "  theta_prior = c(0, 1),\n",
    "  demographics = c(\"Age\", \"Gender\", \"Education\", \"Native_Language\"),\n",
    "  input_types = list(\n",
    "    Age = \"numeric\",\n",
    "    Gender = \"select\",\n",
    "    Education = \"select\",\n",
    "    Native_Language = \"text\"\n",
    "  ),\n",
    "  theme = \"Professional\",\n",
    "  session_save = TRUE,\n",
    "  parallel_computation = FALSE,  # Disable for stability with small banks\n",
    "  cache_enabled = FALSE           # Disable for stability\n",
    ")\n",
    "launch_study(advanced_config, cognitive_items)\n",
    "```\n\n",
    
    "=== create_study_config() PARAMETERS ===\n\n",
    
    "MODEL (IRT model for TAM):\n",
    "  \"GRM\"  = Graded Response Model (Likert scales: 1-2-3-4-5)\n",
    "  \"2PL\"  = 2-Parameter Logistic (binary: correct/incorrect)\n",
    "  \"1PL\"  = 1-Parameter/Rasch (equal discrimination)\n",
    "  \"3PL\"  = 3-Parameter (with guessing parameter)\n\n",
    
    "ADAPTIVE:\n",
    "  TRUE  = Items selected based on ability (needs a, b parameters in item bank)\n",
    "  FALSE = Fixed order questionnaire\n\n",
    
    "STOPPING RULES (adaptive only):\n",
    "  min_SEM     = Stops when SEM < this (lower = more precise, longer test)\n",
    "                Values: 0.20-0.25 (high), 0.30-0.35 (research), 0.40-0.50 (screening)\n",
    "  min_items   = Minimum items before stopping\n",
    "  max_items   = Maximum items (stops even if min_SEM not reached)\n\n",
    
    "SELECTION (adaptive only):\n",
    "  criteria = \"MI\"       Maximum Information (standard)\n",
    "  criteria = \"MFI\"      Maximum Fisher Information\n",
    "  criteria = \"WEIGHTED\" Weighted selection\n",
    "  criteria = \"RANDOM\"   Random\n\n",
    
    "ESTIMATION:\n",
    "  estimation_method = \"TAM\"   Uses TAM package EAP (default)\n",
    "  theta_prior = c(mean, sd)   Population distribution, e.g., c(0, 1)\n\n",
    
    "OTHER:\n",
    "  demographics        = c(\"Age\", \"Gender\", ...)\n",
    "  input_types        = list(Age = \"numeric\", Gender = \"select\", ...)\n",
    "  theme              = \"Professional\", \"hildesheim\", etc.\n",
    "  session_save       = TRUE/FALSE (enable recovery)\n",
    "  parallel_computation = TRUE/FALSE\n",
    "  cache_enabled      = TRUE/FALSE"
  )
}


#' @noRd
build_stopping_rules_prompt <- function(config, item_bank) {
  n_items <- if (!is.null(item_bank)) nrow(item_bank) else "unknown"
  
  paste0(
    "I'm using inrep (IRT adaptive testing with TAM) and need to adjust stopping rules.\n\n",
    
    "=== WHAT I WANT ===\n",
    "[Describe what you want to change about stopping rules]\n\n",
    
    "=== MY CURRENT CONFIGURATION ===\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"", config$name %||% "My Study", "\",\n",
    "  model = \"", config$model %||% "GRM", "\",\n",
    "  adaptive = ", if (isTRUE(config$adaptive)) "TRUE" else "FALSE", ",\n",
    "  min_items = ", config$min_items %||% 5, ",\n",
    "  max_items = ", config$max_items %||% 20, ",\n",
    "  min_SEM = ", config$min_SEM %||% 0.3, "\n",
    ")\n",
    "```\n",
    "Item bank: ", n_items, " items\n\n",
    
    "=== README STOPPING RULE EXAMPLES ===\n",
    "Example 1: min_items = 5, max_items = 15, min_SEM = 0.3\n",
    "Example 2: Fixed test (no stopping rules)\n",
    "Example 3: min_items = 8, max_items = 15, min_SEM = 0.35\n\n",
    
    "=== STOPPING RULE PARAMETERS ===\n",
    "min_SEM:\n",
    "  Test stops when SEM drops below this value\n",
    "  Lower = more precise BUT longer test\n",
    "  0.20-0.25 = High precision (clinical, certification)\n",
    "  0.30-0.35 = Research quality (typical)\n",
    "  0.40-0.50 = Screening\n\n",
    
    "min_items:\n",
    "  Minimum items before stopping rules apply\n",
    "  Ensures stable ability estimate\n",
    "  Typical: 5-10\n\n",
    
    "max_items:\n",
    "  Maximum items allowed\n",
    "  Test stops at max_items EVEN IF min_SEM not reached\n",
    "  Typical: 15-30"
  )
}


#' @noRd
build_selection_prompt <- function(config, item_bank) {
  n_items <- if (!is.null(item_bank)) nrow(item_bank) else "unknown"
  has_domains <- !is.null(item_bank) && "domain" %in% names(item_bank)
  n_domains <- if (has_domains) length(unique(item_bank$domain)) else 0
  
  paste0(
    "I'm using inrep (IRT adaptive testing with TAM) and need to adjust item selection.\n\n",
    
    "=== WHAT I WANT ===\n",
    "[Describe what you want to change about item selection]\n\n",
    
    "=== MY CURRENT CONFIGURATION ===\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"", config$name %||% "My Study", "\",\n",
    "  model = \"", config$model %||% "GRM", "\",\n",
    "  adaptive = ", if (isTRUE(config$adaptive)) "TRUE" else "FALSE", ",\n",
    "  criteria = \"", config$criteria %||% "MI", "\"\n",
    ")\n",
    "```\n",
    "Item bank: ", n_items, " items",
    if (has_domains) paste0(", ", n_domains, " domains") else "", "\n\n",
    
    "=== README SELECTION EXAMPLES ===\n",
    "Example 1: adaptive = TRUE (uses MI by default)\n",
    "Example 2: adaptive = FALSE (fixed order, no selection)\n",
    "Example 3: adaptive = TRUE, criteria = \"MI\"\n\n",
    
    "=== SELECTION PARAMETERS ===\n",
    "adaptive:\n",
    "  TRUE  = Items selected based on current ability estimate\n",
    "  FALSE = Fixed order presentation\n\n",
    
    "criteria (only when adaptive = TRUE):\n",
    "  \"MI\"      = Maximum Information (standard, recommended)\n",
    "  \"MFI\"     = Maximum Fisher Information\n",
    "  \"WEIGHTED\" = Weighted selection (for content balancing)\n",
    "  \"RANDOM\"   = Random selection"
  )
}


#' @noRd
build_estimation_prompt <- function(config, item_bank) {
  n_items <- if (!is.null(item_bank)) nrow(item_bank) else "unknown"
  
  paste0(
    "I'm using inrep (IRT adaptive testing with TAM) and need to adjust estimation.\n\n",
    
    "=== WHAT I WANT ===\n",
    "[Describe what you want to change about ability estimation]\n\n",
    
    "=== MY CURRENT CONFIGURATION ===\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"", config$name %||% "My Study", "\",\n",
    "  model = \"", config$model %||% "GRM", "\",\n",
    "  estimation_method = \"", config$estimation_method %||% "TAM", "\",\n",
    "  theta_prior = c(", paste(config$theta_prior %||% c(0, 1), collapse = ", "), ")\n",
    ")\n",
    "```\n",
    "Item bank: ", n_items, " items\n",
    "Test length: ", config$min_items %||% 5, "-", config$max_items %||% 20, " items\n\n",
    
    "=== README ESTIMATION EXAMPLES ===\n",
    "Example 1: Uses defaults (TAM EAP, theta_prior = c(0, 1))\n",
    "Example 2: Fixed test (estimation not critical)\n",
    "Example 3: estimation_method = \"TAM\", theta_prior = c(0, 1)\n\n",
    
    "=== ESTIMATION PARAMETERS ===\n",
    "estimation_method:\n",
    "  \"TAM\" = Uses TAM package EAP (Expected A Posteriori)\n",
    "          Bayesian method, works well with few items\n",
    "          Default and recommended\n\n",
    
    "theta_prior:\n",
    "  c(mean, sd) = Assumed population distribution\n",
    "  c(0, 1)     = Standard normal (typical)\n",
    "  Adjust for different populations:\n",
    "    c(0.5, 1)  = Higher ability population\n",
    "    c(-0.5, 1) = Lower ability population\n",
    "    c(0, 0.8)  = Less variable population"
  )
}


#' @noRd
build_general_customization_prompt <- function(config, item_bank) {
  n_items <- if (!is.null(item_bank)) nrow(item_bank) else "unknown"
  has_domains <- !is.null(item_bank) && "domain" %in% names(item_bank)
  n_domains <- if (has_domains) length(unique(item_bank$domain)) else 0
  
  paste0(
    "I'm using inrep R package (IRT adaptive testing with TAM).\n\n",
    
    "=== WHAT I WANT ===\n",
    "[Describe what you want to customize]\n\n",
    
    "=== MY CURRENT CONFIGURATION ===\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"", config$name %||% "My Study", "\",\n",
    "  model = \"", config$model %||% "GRM", "\",\n",
    "  adaptive = ", if (isTRUE(config$adaptive)) "TRUE" else "FALSE", ",\n",
    "  min_items = ", config$min_items %||% 5, ",\n",
    "  max_items = ", config$max_items %||% 20, ",\n",
    "  min_SEM = ", config$min_SEM %||% 0.3, ",\n",
    "  criteria = \"", config$criteria %||% "MI", "\",\n",
    "  estimation_method = \"", config$estimation_method %||% "TAM", "\",\n",
    "  theta_prior = c(", paste(config$theta_prior %||% c(0, 1), collapse = ", "), "),\n",
    "  demographics = ", if (!is.null(config$demographics)) {
      paste0("c(\"", paste(config$demographics, collapse = "\", \""), "\")")
    } else {
      "NULL"
    }, ",\n",
    "  theme = \"", config$theme %||% "Professional", "\"\n",
    ")\n",
    "```\n",
    "Item bank: ", n_items, " items",
    if (has_domains) paste0(", ", n_domains, " domains") else "", "\n\n",
    
    "=== THREE README EXAMPLES ===\n\n",
    
    "EXAMPLE 1 - Adaptive Personality:\n",
    "```r\n",
    "config <- create_study_config(\n",
    "  name = \"Adaptive Personality Assessment\",\n",
    "  model = \"GRM\",\n",
    "  adaptive = TRUE,\n",
    "  max_items = 15,\n",
    "  min_items = 5,\n",
    "  min_SEM = 0.3,\n",
    "  demographics = c(\"Age\", \"Gender\"),\n",
    "  theme = \"Professional\"\n",
    ")\n",
    "launch_study(config, bfi_items)\n",
    "```\n\n",
    
    "EXAMPLE 2 - Fixed Questionnaire:\n",
    "```r\n",
    "config_fixed <- create_study_config(\n",
    "  name = \"Personality Questionnaire\",\n",
    "  adaptive = FALSE,\n",
    "  max_items = 5,\n",
    "  theme = \"hildesheim\",\n",
    "  session_save = TRUE\n",
    ")\n",
    "launch_study(config_fixed, bfi_items)\n",
    "```\n\n",
    
    "EXAMPLE 3 - Cognitive Assessment (2PL, fully specified):\n",
    "```r\n",
    "advanced_config <- create_study_config(\n",
    "  name = \"Cognitive Ability Assessment\",\n",
    "  model = \"2PL\",\n",
    "  estimation_method = \"TAM\",\n",
    "  adaptive = TRUE,\n",
    "  criteria = \"MI\",\n",
    "  min_items = 8,\n",
    "  max_items = 15,\n",
    "  min_SEM = 0.35,\n",
    "  theta_prior = c(0, 1),\n",
    "  demographics = c(\"Age\", \"Gender\", \"Education\", \"Native_Language\"),\n",
    "  input_types = list(\n",
    "    Age = \"numeric\",\n",
    "    Gender = \"select\",\n",
    "    Education = \"select\",\n",
    "    Native_Language = \"text\"\n",
    "  ),\n",
    "  theme = \"Professional\",\n",
    "  session_save = TRUE,\n",
    "  parallel_computation = FALSE,\n",
    "  cache_enabled = FALSE\n",
    ")\n",
    "launch_study(advanced_config, cognitive_items)\n",
    "```\n\n",
    
    "=== create_study_config() PARAMETERS ===\n\n",
    
    "MODEL (IRT models for TAM):\n",
    "  \"GRM\" = Graded Response Model (Likert: 1-2-3-4-5)\n",
    "          Needs: a (discrimination), b1, b2, b3, b4 (thresholds)\n",
    "  \"2PL\" = 2-Parameter Logistic (binary: correct/incorrect)\n",
    "          Needs: a (discrimination), b (difficulty)\n",
    "  \"1PL\" = 1-Parameter/Rasch (equal discrimination)\n",
    "          Needs: b (difficulty only)\n",
    "  \"3PL\" = 3-Parameter Logistic (with guessing)\n",
    "          Needs: a, b, c (guessing)\n\n",
    
    "ADAPTIVE:\n",
    "  TRUE  = Items selected based on ability (needs IRT parameters in item bank)\n",
    "  FALSE = Fixed order questionnaire (no IRT parameters needed)\n\n",
    
    "STOPPING RULES (adaptive only):\n",
    "  min_SEM   = Stop when SEM < this (lower = more precise, longer test)\n",
    "              0.20-0.25 (high precision), 0.30-0.35 (research), 0.40-0.50 (screening)\n",
    "  min_items = Minimum items before stopping (typical: 5-10)\n",
    "  max_items = Maximum items (stops even if min_SEM not reached)\n\n",
    
    "SELECTION (adaptive only):\n",
    "  criteria = \"MI\"       Maximum Information (standard)\n",
    "  criteria = \"MFI\"      Maximum Fisher Information\n",
    "  criteria = \"WEIGHTED\" Weighted (for content balancing)\n",
    "  criteria = \"RANDOM\"   Random\n\n",
    
    "ESTIMATION:\n",
    "  estimation_method = \"TAM\"   TAM package EAP (Bayesian, default)\n",
    "  theta_prior = c(mean, sd)   Population distribution\n",
    "                              c(0, 1) = standard normal\n",
    "                              Adjust: c(0.5, 1), c(-0.5, 1), c(0, 0.8)\n\n",
    
    "OTHER:\n",
    "  demographics         = c(\"Age\", \"Gender\", \"Education\", ...)\n",
    "  input_types         = list(Age = \"numeric\", Gender = \"select\", ...)\n",
    "  theme               = \"Professional\", \"hildesheim\", etc.\n",
    "  session_save        = TRUE/FALSE (enable recovery)\n",
    "  parallel_computation = TRUE/FALSE\n",
    "  cache_enabled       = TRUE/FALSE"
  )
}


#' Enable LLM Prompt Generation
#'
#' @param enable Logical. TRUE to enable, FALSE to disable.
#' @param verbose Logical. Display message.
#' @return Previous setting (invisible).
#' @export
enable_llm_assistance <- function(enable = TRUE, verbose = TRUE) {
  if (!is.logical(enable)) stop("enable must be TRUE or FALSE")
  previous <- getOption("inrep.llm_assistance", FALSE)
  options(inrep.llm_assistance = enable)
  if (verbose) {
    message(if (enable) "LLM prompts enabled" else "LLM prompts disabled")
  }
  invisible(previous)
}


#' Get LLM Assistance Status
#' @return Logical.
#' @export
get_llm_assistance_settings <- function() {
  getOption("inrep.llm_assistance", FALSE)
}
