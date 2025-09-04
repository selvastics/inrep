## Lightweight stubs to ensure exports exist during package installation.
## These are only defined if a real implementation is not present, so they
## won't overwrite full implementations in other files.

#' Comprehensive dataset helpers (install-time safe stubs)
#'
#' Minimal implementations to satisfy package exports during development.
#' These store the dataset and logs in options() so installation and examples work.
#' Replace with full implementations when available.
#'
#' @param ... arguments forwarded to underlying storage
#' @return depends on function
#' @name comprehensive_stubs
NULL

if (!exists("initialize_comprehensive_dataset", mode = "function")) {
  #' @export
  initialize_comprehensive_dataset <- function(config = list(), item_bank = NULL, study_key = "default") {
    ds <- data.frame(study_key = study_key, session_id = paste0("sess_", Sys.time()), start_time = Sys.time(), stringsAsFactors = FALSE)
    options(inrep.comprehensive_dataset = ds)
    invisible(ds)
  }
}

if (!exists("update_comprehensive_dataset", mode = "function")) {
  #' @export
  update_comprehensive_dataset <- function(page_type, page_data, page_id = NULL, stage = NULL, current_page = NULL) {
    cur <- getOption("inrep.comprehensive_dataset", NULL)
    if (is.null(cur)) return(NULL)
    # attempt simple merge
    if (is.data.frame(cur) && is.list(page_data)) {
      for (nm in names(page_data)) {
        cur[[nm]] <- page_data[[nm]]
      }
    }
    options(inrep.comprehensive_dataset = cur)
    invisible(cur)
  }
}

if (!exists("get_comprehensive_dataset", mode = "function")) {
  #' @export
  get_comprehensive_dataset <- function() getOption("inrep.comprehensive_dataset", NULL)
}

if (!exists("export_comprehensive_dataset", mode = "function")) {
  #' @export
  export_comprehensive_dataset <- function(format = "csv", file_path = NULL) {
    ds <- getOption("inrep.comprehensive_dataset", NULL)
    if (is.null(ds)) return(NULL)
    if (is.null(file_path)) file_path <- tempfile(fileext = switch(format, csv = ".csv", json = ".json", rds = ".rds", ".dat"))
    if (format == "rds") saveRDS(ds, file_path) else if (format == "csv" && is.data.frame(ds)) utils::write.csv(ds, file_path, row.names = FALSE) else writeLines(jsonlite::toJSON(ds, pretty = TRUE, auto_unbox = TRUE), file_path)
    invisible(file_path)
  }
}

if (!exists("reset_comprehensive_dataset", mode = "function")) {
  #' @export
  reset_comprehensive_dataset <- function() { options(inrep.comprehensive_dataset = NULL); invisible(TRUE) }
}

if (!exists("get_dataset_summary", mode = "function")) {
  #' @export
  get_dataset_summary <- function() {
    ds <- getOption("inrep.comprehensive_dataset", NULL)
    if (is.null(ds)) return(list(initialized = FALSE))
    if (is.data.frame(ds)) return(list(initialized = TRUE, rows = nrow(ds), cols = ncol(ds)))
    list(initialized = TRUE, type = typeof(ds))
  }
}

if (!exists("log_action", mode = "function")) {
  #' @export
  log_action <- function(action_type, action_details = NULL, page_id = NULL) {
    logs <- getOption("inrep.action_log", list())
    logs <- append(logs, list(list(time = Sys.time(), action = action_type, details = action_details, page = page_id)))
    options(inrep.action_log = logs)
    invisible(TRUE)
  }
}

if (!exists("log_page_time", mode = "function")) {
  #' @export
  log_page_time <- function(page_id, time_spent_seconds) {
    page_times <- getOption("inrep.page_time_log", list())
    page_times[[as.character(page_id)]] <- time_spent_seconds
    options(inrep.page_time_log = page_times)
    invisible(TRUE)
  }
}

if (!exists("update_page_start_time", mode = "function")) {
  #' @export
  update_page_start_time <- function(page_id) {
    starts <- getOption("inrep.page_start_times", list())
    starts[[as.character(page_id)]] <- Sys.time()
    options(inrep.page_start_times = starts)
    invisible(TRUE)
  }
}
