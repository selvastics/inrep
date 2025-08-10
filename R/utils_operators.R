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