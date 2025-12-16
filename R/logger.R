logger <- function(message, level = "INFO") {
  try(
    base::message(
      base::sprintf(
        "[%s] %s: %s",
        base::format(base::Sys.time(), "%Y-%m-%d %H:%M:%S"),
        level,
        message
      )
    ),
    silent = TRUE
  )

  invisible(NULL)
}
