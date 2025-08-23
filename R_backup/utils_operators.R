#' Null-coalescing Operator
#' 
#' Returns the left-hand side if not NULL, otherwise returns the right-hand side
#' 
#' @param lhs Left-hand side value
#' @param rhs Right-hand side value (default)
#' @return lhs if not NULL, otherwise rhs
#' @export
#' @examples
#' NULL %||% "default"  # Returns "default"
#' "value" %||% "default"  # Returns "value"
`%||%` <- function(lhs, rhs) {
  if (is.null(lhs)) rhs else lhs
}

#' String Repetition Operator
#' 
#' Repeats a string a specified number of times
#' 
#' @param string Character string to repeat
#' @param times Number of times to repeat
#' @return Character string repeated the specified number of times
#' @export
#' @examples
#' "=" %r% 50  # Returns "=================================================="
#' "-" %r% 10  # Returns "----------"
`%r%` <- function(string, times) {
  paste(rep(string, times), collapse = "")
}