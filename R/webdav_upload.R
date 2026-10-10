#' Upload a file to a WebDAV server
#'
#' @description
#' Writes one file (a data frame, text or raw bytes) to a WebDAV folder. This
#' is the single upload routine inrep uses for cloud storage; studies can call
#' it directly for their own result files.
#'
#' It works with any server that accepts HTTP \code{PUT} (Nextcloud, ownCloud,
#' Seafile, Apache/nginx WebDAV, institutional storage, ...). Public
#' Nextcloud/ownCloud share links get special handling, because the address
#' a browser shows for a share is not the address that accepts uploads.
#'
#' @param content What to upload: a data frame (written as UTF-8 CSV), a
#'   character vector (lines of text, written as UTF-8), or a raw vector
#'   (sent unchanged).
#' @param filename File name to create in the target folder, e.g.
#'   \code{"results_2026.csv"}. It is URL-encoded for you.
#' @param url Where to upload. One of
#'   \itemize{
#'     \item a Nextcloud/ownCloud \strong{share link}, as copied from the
#'       browser: \code{https://host/s/<token>} or
#'       \code{https://host/index.php/s/<token>} (also with a sub-path such as
#'       \code{https://host/nextcloud/index.php/s/<token>});
#'     \item a Nextcloud/ownCloud \strong{public WebDAV address}:
#'       \code{https://host/public.php/webdav/} (give the token in
#'       \code{share_token}) or \code{https://host/public.php/dav/files/<token>/};
#'     \item any other \strong{WebDAV folder URL}, e.g. a personal Nextcloud
#'       folder \code{https://host/remote.php/dav/files/<user>/<folder>/}
#'       (give \code{user} and \code{password}).
#'   }
#'   Several URLs may be given; they are tried in order until one works. Use
#'   this when the same share may live on one of several hosts.
#' @param password Password: the share password for a password-protected
#'   public share, otherwise the account (or app) password. \code{NULL} or
#'   \code{""} for no password.
#' @param share_token Token of a public share (the part after \code{/s/} in
#'   the share link). Only needed with a bare \code{.../public.php/webdav/}
#'   URL; share links and \code{.../public.php/dav/files/<token>/} URLs
#'   contain it already.
#' @param user User name for a plain WebDAV folder. Ignored for public shares.
#' @param content_type MIME type sent with the file. Guessed from the file
#'   name when \code{NULL}.
#' @param attempts How often to retry an address after a network error or a
#'   server error (5xx). Other answers (401, 403, 404, 409, ...) move on to
#'   the next address straight away.
#' @param timeout Seconds to wait for each request.
#' @param verbose Print one line per attempt.
#'
#' @details
#' \strong{Public shares.} For a share token \code{T} on base address
#' \code{B} (scheme, host and any sub-path before \code{/index.php} or
#' \code{/s/}) these addresses are tried in order:
#' \enumerate{
#'   \item \code{B/public.php/dav/files/T/<file>} with the token as user
#'     name and the share password as password (Nextcloud 29 and later;
#'     confirmed on academiccloud). This is the only address that works for
#'     \emph{upload-only} shares ("File drop" / "Dateiablage").
#'   \item The same address with user \code{anonymous} (what the Nextcloud
#'     web page itself sends; some servers expect it).
#'   \item \code{B/public.php/webdav/<file>} with the token as user name: the
#'     older endpoint (Nextcloud up to 28, ownCloud). Upload-only shares
#'     answer 409 "Files cannot be created in non-existent collections" here,
#'     because the share cannot be read.
#' }
#' A sub-folder after the token in a \code{public.php} URL is kept.
#'
#' \strong{Other WebDAV servers.} The file is \code{PUT} to
#' \code{url/<file>}, with HTTP Basic authentication when a \code{user} or
#' \code{password} is given. The folder must already exist.
#'
#' \strong{Credentials.} Do not write passwords into scripts that are shared
#' or pushed to a repository. Read them from environment variables, e.g.
#' \code{Sys.getenv("MY_WEBDAV_PASSWORD")}, set in \code{~/.Renviron}.
#'
#' @return \code{TRUE} if the file was stored, \code{FALSE} otherwise. The
#'   attribute \code{"uploaded_to"} holds the address that worked, and
#'   \code{"attempts"} a data frame with every address tried, the user kind,
#'   the HTTP status and the server's message.
#'
#' @examples
#' \dontrun{
#' results <- data.frame(id = 1, score = 3.5)
#'
#' # Nextcloud/ownCloud public share (link as shown in the browser)
#' webdav_upload(results, "results_001.csv",
#'               url = "https://cloud.example.org/index.php/s/AbCdEf123",
#'               password = Sys.getenv("STUDY_SHARE_PASSWORD"))
#'
#' # Same share, reachable on either of two hosts
#' webdav_upload(results, "results_001.csv",
#'               url = c("https://uni-hildesheim.files.academiccloud.de/s/AbCdEf123",
#'                       "https://sync.academiccloud.de/s/AbCdEf123"),
#'               password = Sys.getenv("STUDY_SHARE_PASSWORD"))
#'
#' # Personal Nextcloud folder (use an app password)
#' webdav_upload(results, "results_001.csv",
#'               url = "https://cloud.example.org/remote.php/dav/files/jdoe/study/",
#'               user = "jdoe", password = Sys.getenv("NEXTCLOUD_APP_PASSWORD"))
#'
#' # Any other WebDAV server
#' webdav_upload("hello", "test.txt", url = "https://dav.example.org/data/",
#'               user = "me", password = Sys.getenv("DAV_PASSWORD"))
#' }
#'
#' @seealso \code{\link{save_session_to_cloud}}, \code{\link{launch_study}}
#' @export
webdav_upload <- function(content, filename, url, password = NULL,
                          share_token = NULL, user = NULL,
                          content_type = NULL, attempts = 2, timeout = 30,
                          verbose = TRUE) {
  if (!requireNamespace("httr", quietly = TRUE)) {
    stop("webdav_upload() needs the 'httr' package")
  }
  stopifnot(is.character(filename), length(filename) == 1, nzchar(filename))
  stopifnot(is.character(url), length(url) >= 1)
  say <- function(...) if (isTRUE(verbose)) message("[inrep WebDAV] ", ...)

  body <- .webdav_body(content)
  if (is.null(content_type)) content_type <- .webdav_content_type(filename)
  password <- if (is.null(password)) "" else as.character(password)

  targets <- do.call(c, lapply(url, .webdav_targets, filename = filename,
                               share_token = share_token, user = user))
  log <- data.frame(url = character(0), user = character(0), status = integer(0),
                    message = character(0), stringsAsFactors = FALSE)

  unreachable <- character(0)  # hosts that never answered: skip their other addresses
  for (target in targets) {
    host <- sub("^(https?://[^/]+).*$", "\\1", target$url)
    if (host %in% unreachable) next
    for (attempt in seq_len(max(1, attempts))) {
      use_auth <- nzchar(target$user) || nzchar(password)
      response <- tryCatch(
        httr::PUT(
          url = target$url,
          body = body,
          httr::content_type(content_type),
          # Stops Nextcloud from answering with a browser login prompt
          httr::add_headers(`X-Requested-With` = "XMLHttpRequest"),
          if (use_auth) httr::authenticate(target$user, password, type = "basic"),
          httr::timeout(timeout)
        ),
        error = function(e) e
      )
      user_kind <- .webdav_user_kind(target)
      if (inherits(response, "error")) {
        log[nrow(log) + 1, ] <- list(target$url, user_kind, NA_integer_, conditionMessage(response))
        say(target$url, " (", user_kind, "): ", conditionMessage(response))
        if (attempt < attempts) { Sys.sleep(attempt); next }
        unreachable <- c(unreachable, host)
        next
      }
      status <- httr::status_code(response)
      reason <- .webdav_reason(response)
      log[nrow(log) + 1, ] <- list(target$url, user_kind, status, reason)
      if (status >= 200 && status < 300) {
        say("uploaded ", filename, " to ", target$url, " (", user_kind, ")")
        return(structure(TRUE, uploaded_to = target$url, attempts = log))
      }
      say(target$url, " (", user_kind, "): HTTP ", status, .webdav_status_hint(status),
          if (nzchar(reason)) paste0(" - server: ", reason) else "")
      if (status < 500) break  # wrong address or login for this target: try the next one
      if (attempt < attempts) Sys.sleep(attempt)
    }
  }
  say("upload of ", filename, " failed on every address")
  structure(FALSE, uploaded_to = NA_character_, attempts = log)
}

# Request body: data frames become UTF-8 CSV, text becomes UTF-8 lines.
.webdav_body <- function(content) {
  if (is.raw(content)) return(content)
  if (is.data.frame(content)) {
    tmp <- tempfile(fileext = ".csv")
    on.exit(unlink(tmp), add = TRUE)
    utils::write.csv(content, tmp, row.names = FALSE, na = "", fileEncoding = "UTF-8")
    return(readBin(tmp, "raw", file.info(tmp)$size))
  }
  if (is.character(content)) {
    return(charToRaw(enc2utf8(paste(content, collapse = "\n"))))
  }
  stop("content must be a data frame, a character vector or a raw vector")
}

.webdav_content_type <- function(filename) {
  ext <- tolower(tools::file_ext(filename))
  switch(ext,
    csv = "text/csv; charset=utf-8",
    json = "application/json; charset=utf-8",
    txt = "text/plain; charset=utf-8",
    rds = "application/octet-stream",
    pdf = "application/pdf",
    "application/octet-stream"
  )
}

# Turns one user-supplied URL into the list of (url, user) pairs to try.
.webdav_targets <- function(url, filename, share_token = NULL, user = NULL) {
  file <- utils::URLencode(filename, reserved = TRUE)
  # A share link copied while browsing a sub-folder carries it as ?path=/sub
  query_path <- regmatches(url, regexec("[?&]path=([^&#]*)", url))[[1]]
  query_path <- if (length(query_path)) gsub("^/+|/+$", "", utils::URLdecode(query_path[2])) else ""
  url <- sub("[?#].*$", "", url)
  join <- function(...) gsub("(?<!:)/{2,}", "/", paste(..., sep = "/"), perl = TRUE)

  share <- .webdav_parse_share(url)
  token <- share$token
  if (is.null(token) && share$kind == "public_webdav" && !is.null(share_token) && nzchar(share_token)) {
    token <- share_token
  }
  if (share$kind == "plain" || is.null(token) || !nzchar(token)) {
    # Bare public.php/webdav/ without a token is still tried as plain WebDAV
    # (anonymous public shares, or a token passed as `user`).
    u <- if (!is.null(user)) user else if (!is.null(share_token)) share_token else ""
    return(list(list(url = join(sub("/+$", "", url), file), user = u, token = NULL)))
  }
  base <- share$base
  sub_path <- if (nzchar(share$sub_path)) share$sub_path else
    paste(vapply(strsplit(query_path, "/")[[1]], utils::URLencode, "", reserved = TRUE), collapse = "/")
  list(
    list(url = join(base, "public.php/dav/files", token, sub_path, file), user = token, token = token),
    list(url = join(base, "public.php/dav/files", token, sub_path, file), user = "anonymous", token = token),
    list(url = join(base, "public.php/webdav", sub_path, file), user = token, token = token)
  )
}

# Recognises Nextcloud/ownCloud public share URLs.
# Returns kind ("share_link", "public_dav", "public_webdav", "plain"),
# base (everything before /index.php, /s/ or /public.php), token and sub_path.
.webdav_parse_share <- function(url) {
  m <- regmatches(url, regexec("^(https?://.+?)/(?:index\\.php/)?s/([A-Za-z0-9]+)/?$", url))[[1]]
  if (length(m)) return(list(kind = "share_link", base = m[2], token = m[3], sub_path = ""))
  m <- regmatches(url, regexec("^(https?://.+?)/public\\.php/dav/files/([A-Za-z0-9]+)/?(.*)$", url))[[1]]
  if (length(m)) return(list(kind = "public_dav", base = m[2], token = m[3], sub_path = sub("/+$", "", m[4])))
  m <- regmatches(url, regexec("^(https?://.+?)/public\\.php/webdav/?(.*)$", url))[[1]]
  if (length(m)) return(list(kind = "public_webdav", base = m[2], token = NULL, sub_path = sub("/+$", "", m[3])))
  list(kind = "plain", base = NULL, token = NULL, sub_path = "")
}

.webdav_user_kind <- function(target) {
  if (!is.null(target$token) && identical(target$user, target$token)) return("user = share token")
  if (identical(target$user, "anonymous")) return("user = anonymous")
  if (nzchar(target$user)) return("user given")
  "no user"
}

# Short reason from a WebDAV error body (SabreDAV puts it in <s:message>).
.webdav_reason <- function(response) {
  txt <- tryCatch(httr::content(response, "text", encoding = "UTF-8"), error = function(e) "")
  if (is.null(txt) || !nzchar(txt)) return("")
  msg <- regmatches(txt, regexec("<s:message>(.*?)</s:message>", txt))[[1]]
  out <- if (length(msg)) msg[2] else ""
  substr(trimws(out), 1, 200)
}

.webdav_status_hint <- function(status) {
  hint <- switch(as.character(status),
    "401" = "wrong user name or password for this address",
    "403" = "the share or account does not allow uploads",
    "404" = "address not found",
    "405" = "this address does not accept uploads",
    "409" = "target folder does not exist or cannot be read (upload-only share on the old endpoint?)",
    "423" = "file is locked",
    "507" = "storage is full",
    NULL
  )
  if (is.null(hint)) "" else paste0(" (", hint, ")")
}
