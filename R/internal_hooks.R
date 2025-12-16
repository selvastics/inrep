validate_model <- function(model) {
  if (is.null(model) || !is.character(model) || length(model) != 1L || nchar(model) == 0L) {
    stop(
      "Invalid 'model'. Provide a single non-empty character string (e.g., 'GRM', '2PL').",
      call. = FALSE
    )
  }

  model <- toupper(trimws(model))
  allowed <- c("GRM", "GPCM", "PCM", "1PL", "2PL", "3PL")
  if (!model %in% allowed) {
    stop(
      sprintf(
        "Invalid 'model': %s. Supported values: %s",
        shQuote(model),
        paste(allowed, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  model
}

validate_theme <- function(theme) {
  if (is.null(theme)) {
    return(NULL)
  }

  if (is.list(theme)) {
    return(theme)
  }

  if (!is.character(theme) || length(theme) != 1L || nchar(trimws(theme)) == 0L) {
    stop(
      "Invalid 'theme'. Provide NULL, a non-empty single character string, or a theme configuration list.",
      call. = FALSE
    )
  }

  trimws(theme)
}

.inrep_get_logging_env <- function(session = NULL) {
  if (is.null(session) && shiny::isRunning()) {
    session <- shiny::getDefaultReactiveDomain()
  }
  if (is.null(session) || is.null(session$userData)) {
    return(NULL)
  }
  session$userData$logging_data %||% NULL
}

update_page_start_time <- function(page_id, session = NULL) {
  env <- .inrep_get_logging_env(session)
  if (is.null(env)) return(invisible(FALSE))
  env$current_page_id <- page_id
  env$current_page_start <- Sys.time()
  invisible(TRUE)
}

log_page_time <- function(page_id, time_spent_seconds, session = NULL) {
  env <- .inrep_get_logging_env(session)
  if (is.null(env)) return(invisible(FALSE))

  if (is.null(env$page_times)) env$page_times <- list()
  env$page_times[[length(env$page_times) + 1L]] <- list(
    page_id = page_id,
    time_spent_seconds = as.numeric(time_spent_seconds),
    timestamp = Sys.time()
  )
  invisible(TRUE)
}

log_action <- function(action_type, data = NULL, page_id = NULL, session = NULL) {
  env <- .inrep_get_logging_env(session)
  if (is.null(env)) return(invisible(FALSE))

  if (is.null(env$actions)) env$actions <- list()
  env$actions[[length(env$actions) + 1L]] <- list(
    action_type = action_type,
    page_id = page_id,
    data = data,
    timestamp = Sys.time()
  )
  invisible(TRUE)
}

initialize_comprehensive_dataset <- function(config, item_bank, study_key, session = NULL) {
  if (is.null(session) && shiny::isRunning()) {
    session <- shiny::getDefaultReactiveDomain()
  }
  if (is.null(session) || is.null(session$userData)) {
    return(NULL)
  }

  dataset <- data.frame(
    section = character(0),
    page_id = character(0),
    stage = character(0),
    current_page = integer(0),
    timestamp = as.POSIXct(character(0)),
    study_key = character(0),
    config_name = character(0),
    n_items = integer(0),
    data_json = character(0),
    stringsAsFactors = FALSE
  )

  attr(dataset, "meta") <- list(
    study_key = study_key,
    created_at = Sys.time(),
    config_name = config$name %||% NA_character_,
    n_items = if (!is.null(item_bank)) nrow(item_bank) else NA_integer_
  )

  session$userData$comprehensive_dataset <- dataset
  dataset
}

get_comprehensive_dataset <- function(session = NULL) {
  if (is.null(session) && shiny::isRunning()) {
    session <- shiny::getDefaultReactiveDomain()
  }
  if (is.null(session) || is.null(session$userData)) {
    return(NULL)
  }
  session$userData$comprehensive_dataset %||% NULL
}

update_comprehensive_dataset <- function(section, data, page_id = NULL, stage = NULL, current_page = NULL, session = NULL) {
  if (is.null(session) && shiny::isRunning()) {
    session <- shiny::getDefaultReactiveDomain()
  }
  if (is.null(session) || is.null(session$userData)) {
    return(invisible(FALSE))
  }

  ds <- session$userData$comprehensive_dataset %||% NULL
  if (is.null(ds)) {
    ds <- data.frame(
      section = character(0),
      page_id = character(0),
      stage = character(0),
      current_page = integer(0),
      timestamp = as.POSIXct(character(0)),
      study_key = character(0),
      config_name = character(0),
      n_items = integer(0),
      data_json = character(0),
      stringsAsFactors = FALSE
    )
  }

  meta <- attr(ds, "meta") %||% list()
  safe_json <- tryCatch(
    jsonlite::toJSON(data, auto_unbox = TRUE, null = "null"),
    error = function(e) jsonlite::toJSON(list(error = e$message), auto_unbox = TRUE)
  )

  ds <- rbind(
    ds,
    data.frame(
      section = as.character(section),
      page_id = as.character(page_id %||% NA_character_),
      stage = as.character(stage %||% NA_character_),
      current_page = as.integer(current_page %||% NA_integer_),
      timestamp = Sys.time(),
      study_key = as.character(meta$study_key %||% NA_character_),
      config_name = as.character(meta$config_name %||% NA_character_),
      n_items = as.integer(meta$n_items %||% NA_integer_),
      data_json = as.character(safe_json),
      stringsAsFactors = FALSE
    )
  )

  attr(ds, "meta") <- meta
  session$userData$comprehensive_dataset <- ds
  invisible(TRUE)
}

generate_hilfo_filename <- function(timestamp) {
  ts <- gsub("[^0-9A-Za-z_.-]", "_", as.character(timestamp))
  paste0("results_", ts, ".csv")
}

initialize_enhanced_recovery <- function(...) {
  invisible(FALSE)
}

initialize_enhanced_security <- function(...) {
  invisible(FALSE)
}
