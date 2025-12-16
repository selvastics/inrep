# Internal package state (loaded early)

.inrep_env <- new.env(parent = emptyenv())

.inrep_get_env <- function() {
  .inrep_env
}

.inrep_get_logging_data <- function(session_id = NULL, create = TRUE) {
  env <- .inrep_get_env()
  if (is.null(env$logging_data)) {
    env$logging_data <- new.env(parent = emptyenv())
  }

  key <- session_id %||% "default"
  if (isTRUE(create) && is.null(env$logging_data[[key]])) {
    env$logging_data[[key]] <- new.env(parent = emptyenv())
  }

  env$logging_data[[key]]
}

.inrep_reset_logging_data <- function(session_id = NULL) {
  key <- session_id %||% "default"
  env <- .inrep_get_env()
  if (is.null(env$logging_data)) {
    env$logging_data <- new.env(parent = emptyenv())
  }
  env$logging_data[[key]] <- new.env(parent = emptyenv())
  env$logging_data[[key]]
}

.inrep_set_cleanup_hook <- function(fn) {
  if (!is.null(fn) && !is.function(fn)) {
    stop("cleanup hook must be a function or NULL")
  }
  .inrep_env$cleanup_on_exit <- fn
  invisible(fn)
}

.inrep_run_cleanup_hook <- function() {
  fn <- .inrep_env$cleanup_on_exit
  if (is.function(fn)) {
    fn()
  }
  invisible(NULL)
}
