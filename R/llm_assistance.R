#' Generate Customization Prompt (Deprecated)
#'
#' @description
#' \strong{Deprecated.} Use
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{inrep-studio} instead
#' to configure studies interactively via a GUI.
#'
#' @param config Study configuration from \code{\link{create_study_config}}.
#'   If NULL, generates general context.
#' @param focus Focus area: \code{"stopping_rules"}, \code{"selection"},
#'   \code{"estimation"}, \code{"general"}.
#' @param item_bank Optional item bank for additional context.
#'
#' @return Invisibly returns \code{NULL}.
#' @export
#'
#' @examples
#' \dontrun{
#' # Deprecated - use inrep-studio instead:
#' # https://selvastics.shinyapps.io/inrep-studio/
#' generate_llm_prompt()
#' }
generate_llm_prompt <- function(config = NULL, focus = "general", item_bank = NULL) {
  .Deprecated(
    msg = paste0(
      "generate_llm_prompt() is deprecated.\n",
      "Use inrep-studio for interactive study configuration:\n",
      "  https://selvastics.shinyapps.io/inrep-studio/"
    )
  )
  invisible(NULL)
}


#' Enable LLM Prompt Generation (Deprecated)
#'
#' @description
#' \strong{Deprecated.} Use
#' \href{https://selvastics.shinyapps.io/inrep-studio/}{inrep-studio} instead
#' to configure studies interactively via a GUI.
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
    message(
      "enable_llm_assistance() is deprecated. ",
      "Use inrep-studio: https://selvastics.shinyapps.io/inrep-studio/"
    )
  }
  invisible(previous)
}


#' Get LLM Assistance Status (Deprecated)
#'
#' @description \strong{Deprecated.} Part of the LLM prompt generation workflow.
#' @return Logical.
#' @export
get_llm_assistance_settings <- function() {
  getOption("inrep.llm_assistance", FALSE)
}
