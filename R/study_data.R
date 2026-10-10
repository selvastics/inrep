#' Participant data files
#'
#' @description
#' With \code{launch_study(save_data = TRUE)}, inrep writes one CSV file per
#' participant when the participant reaches the results. \code{read_study_data()}
#' reads all files of a study into one data frame with one row per participant.
#'
#' @details
#' Each file has one row with these columns:
#' \describe{
#'   \item{\code{participant}}{The session ID inrep assigns.}
#'   \item{\code{study_key}}{The study key.}
#'   \item{\code{start}, \code{end}, \code{duration_sec}}{Start and end of the
#'     session and its length in seconds.}
#'   \item{\code{items_shown}}{The \code{id}s of the items shown, separated by
#'     \code{";"}, in the order they were shown. In a booklet design this
#'     identifies the booklet and the item positions.}
#'   \item{demographics}{One column per entry of \code{config$demographics}.}
#'   \item{\code{theta}, \code{se}}{Only in adaptive mode: the final estimate
#'     with the fixed item parameters.}
#'   \item{items}{One column per item of the bank, named by \code{id}, in bank
#'     order. Items not shown, or shown and not answered, are \code{NA}. The
#'     value is what inrep stored as the response: the category for rating
#'     scales, the position of the chosen option for
#'     \code{scale_type = "options"}, and the score in the built-in adaptive
#'     flow.}
#'   \item{\code{rt_<id>}}{Response time per item in seconds, where inrep
#'     records it (built-in adaptive flow).}
#' }
#'
#' The item columns can be passed to \code{TAM::tam.mml()} as they are. The
#' missing-by-design pattern is kept, and the background variables are in the
#' same data frame for conditioning or imputation models.
#'
#' Files are not encrypted. Where they are stored, and for how long, is the
#' researcher's responsibility.
#'
#' @param study_key The study key used in \code{launch_study()} or
#'   \code{create_study_config()}. Files are read from
#'   \code{study_data/<study_key>/participants/}.
#' @param dir Folder to read from instead, for example when
#'   \code{save_data} was given as a path.
#'
#' @return A data frame with one row per participant, ordered by
#'   \code{start}. Columns missing in some files (for example after a change
#'   of the item bank) are filled with \code{NA}.
#'
#' @examples
#' \dontrun{
#' launch_study(config, item_bank, save_data = TRUE)
#'
#' dat <- read_study_data("ICAR_booklets")
#' resp <- dat[, item_bank$id]
#' mod <- TAM::tam.mml(resp)
#' }
#'
#' @seealso \code{\link{launch_study}}
#' @export
read_study_data <- function(study_key = NULL, dir = NULL) {
  if (is.null(dir)) {
    if (is.null(study_key)) stop("Give either 'study_key' or 'dir'.", call. = FALSE)
    dir <- .inrep_participant_dir(study_key)
  }
  files <- list.files(dir, pattern = "\\.csv$", full.names = TRUE)
  if (length(files) == 0) {
    warning(sprintf("No participant files in '%s'.", dir), call. = FALSE)
    return(data.frame())
  }
  rows <- lapply(files, utils::read.csv, stringsAsFactors = FALSE,
                 check.names = FALSE, fileEncoding = "UTF-8")
  cols <- unique(unlist(lapply(rows, names)))
  rows <- lapply(rows, function(r) {
    r[setdiff(cols, names(r))] <- NA
    r[cols]
  })
  out <- do.call(rbind, rows)
  if ("start" %in% names(out)) out <- out[order(out$start), , drop = FALSE]
  rownames(out) <- NULL
  out
}

.inrep_participant_dir <- function(study_key) {
  file.path("study_data", study_key, "participants")
}

# One row per participant: responses mapped to item bank positions, items in
# the order shown, demographics, times. Written once per session.
.inrep_write_participant_file <- function(rv, item_bank, config, dir, study_key,
                                          items_shown = NULL) {
  res <- rv$cat_result
  if (is.null(res)) return(invisible(NULL))

  n <- nrow(item_bank)
  ids <- if (!is.null(item_bank$id)) as.character(item_bank$id) else paste0("item_", seq_len(n))

  resp <- rep(NA_real_, n)
  adm <- as.integer(res$administered %||% integer(0))
  val <- suppressWarnings(as.numeric(res$responses %||% numeric(0)))
  k <- min(length(adm), length(val))
  if (k > 0) {
    keep <- adm[seq_len(k)] >= 1 & adm[seq_len(k)] <= n
    resp[adm[seq_len(k)][keep]] <- val[seq_len(k)][keep]
  }

  # Order shown: items rendered on item pages, otherwise the administration
  # order of the built-in flow.
  shown <- as.integer(items_shown %||% integer(0))
  if (length(shown) == 0) shown <- as.integer(rv$administered %||% integer(0))
  shown <- shown[shown >= 1 & shown <= n]

  start <- rv$session_start_time %||% rv$session_start %||% Sys.time()
  end <- Sys.time()
  row <- list(
    participant = rv$unique_session_id %||% NA_character_,
    study_key = study_key,
    start = format(start, "%Y-%m-%d %H:%M:%S"),
    end = format(end, "%Y-%m-%d %H:%M:%S"),
    duration_sec = round(as.numeric(difftime(end, start, units = "secs")), 1),
    items_shown = paste(ids[shown], collapse = ";")
  )

  demo <- rv$demo_data %||% res$demo_data
  for (d in config$demographics %||% character(0)) {
    v <- demo[[d]]
    row[[d]] <- if (is.null(v) || length(v) == 0) NA else paste(as.character(v), collapse = ";")
  }

  if (isTRUE(config$adaptive)) {
    row$theta <- res$theta %||% NA
    row$se <- res$se %||% NA
  }

  row[ids] <- as.list(resp)

  rt <- suppressWarnings(as.numeric(res$response_times %||% numeric(0)))
  if (length(rt) > 0) {
    rt_full <- rep(NA_real_, n)
    k <- min(length(adm), length(rt))
    keep <- adm[seq_len(k)] >= 1 & adm[seq_len(k)] <= n
    rt_full[adm[seq_len(k)][keep]] <- round(rt[seq_len(k)][keep], 2)
    row[paste0("rt_", ids)] <- as.list(rt_full)
  }

  row <- lapply(row, function(v) if (is.null(v) || length(v) == 0) NA else v[1])
  if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)
  file <- file.path(dir, paste0(gsub("[^A-Za-z0-9_-]", "_", row$participant), ".csv"))
  utils::write.csv(as.data.frame(row, check.names = FALSE, stringsAsFactors = FALSE),
                   file, row.names = FALSE, fileEncoding = "UTF-8")
  invisible(file)
}
