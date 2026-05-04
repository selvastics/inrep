#' Create a timestamped export filename
#'
#' Generates a standardised filename for exported data files, appending the
#' current timestamp to avoid overwriting previous exports.
#'
#' @param base Character. Name prefix for the file, e.g. `"study_results"`.
#' @param format Character. File extension without dot, e.g. `"csv"`, `"rds"`.
#'
#' @return A single character string with the composed filename.
#' @export
#' @examples
#' make_export_filename("pilot_study", "csv")
make_export_filename <- function(base = "inrep_export", format = "csv") {
  stamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
  paste0(base, "_", stamp, ".", format)
}
