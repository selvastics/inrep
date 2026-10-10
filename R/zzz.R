#' Package Load/Unload Hooks
#' 
#' Handles package loading and unloading to prevent installation conflicts
#' 
#' @name zzz
#' @keywords internal
#' @importFrom graphics grid polygon
#' @importFrom utils globalVariables
NULL

utils::globalVariables(c(
  ".active_sessions", ".log_path", ".SD", ".webdav_config",
  "export_csv", "export_json", "export_r",
  "export_spss", "export_xlsx",
  "get_participant", "grid", "Item", "list_participants", "polygon",
  "print.inrep_config", "print.professional_survey", "remove_participant",
  "SE", "send_invitation", "send_reminder", "Theta", "update_participant"
  ,"Count", "Difficulty", "Domain", "Order", "Response", "score", "trait", "value"
))

# Package namespace environment is initialized in R/aaa_inrep_env.R

#' On Load Hook
#' 
#' Called when package is loaded
#' 
#' @param libname Library name
#' @param pkgname Package name
#' @keywords internal
.onLoad <- function(libname, pkgname) {
  .inrep_env$loaded <- TRUE
  .inrep_env$load_time <- Sys.time()

  register_s3_methods()

  # Set the default only when the user has not set the option already.
  if (is.null(getOption("inrep.verbose"))) {
    options(inrep.verbose = FALSE)
  }

  clean_temp_files()

  invisible(NULL)
}

#' On Attach Hook
#' 
#' Called when package is attached
#' 
#' @param libname Library name
#' @param pkgname Package name
#' @keywords internal
.onAttach <- function(libname, pkgname) {
  # Only show message if not in quiet mode and not during installation
  if (!isTRUE(getOption("inrep.quiet")) && 
      !isTRUE(getOption("inrep.installing"))) {
    packageStartupMessage(
      "inrep ", utils::packageVersion("inrep"), ". ",
      "Help: ?inrep, browseVignettes(\"inrep\")"
    )
  }
  
  invisible(NULL)
}

#' On Unload Hook
#' 
#' Called when package is unloaded
#' 
#' @param libpath Library path
#' @keywords internal
.onUnload <- function(libpath) {
  cleanup_package_state()
  clean_temp_files()
  
  invisible(NULL)
}

#' Clean Up Package State
#' 
#' Removes all package-related objects from memory
#' 
#' @keywords internal
cleanup_package_state <- function() {
  # State environments defined at the top level of the package namespace
  envs_to_clean <- c(
    ".session_state",
    ".error_handling_state"
  )
  ns <- environment(cleanup_package_state)

  for (env_name in envs_to_clean) {
    if (exists(env_name, envir = ns, inherits = FALSE)) {
      env <- get(env_name, envir = ns, inherits = FALSE)
      if (is.environment(env)) {
        rm(list = ls(env), envir = env)
      }
    }
  }
  
  cons <- showConnections()
  if (nrow(cons) > 0) {
    for (i in seq_len(nrow(cons))) {
      if (grepl("inrep", cons[i, "description"], ignore.case = TRUE)) {
        try(close(getConnection(as.integer(rownames(cons)[i]))), silent = TRUE)
      }
    }
  }
  
  if (is.environment(.inrep_env)) {
    rm(list = ls(.inrep_env), envir = .inrep_env)
  }
  
  invisible(NULL)
}

#' Clean Temporary Files
#' 
#' Removes temporary files created by the package
#' 
#' @keywords internal
clean_temp_files <- function() {
  temp_dir <- tempdir()
  # Regular expressions (list.files() does not take glob patterns)
  temp_patterns <- c(
    "^inrep_session_",
    "^inrep_cache_",
    "^inrep_backup_",
    "^inrep_export_"
  )
  
  for (pattern in temp_patterns) {
    files <- list.files(
      temp_dir,
      pattern = pattern,
      full.names = TRUE
    )
    
    if (length(files) > 0) {
      # Remove only files older than 24 hours
      for (file in files) {
        file_info <- file.info(file)
        if (!is.na(file_info$mtime)) {
          age_hours <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "hours"))
          if (age_hours > 24) {
            try(unlink(file, recursive = TRUE), silent = TRUE)
          }
        }
      }
    }
  }
  
  invisible(NULL)
}

#' Register S3 Methods
#' 
#' Registers any S3 methods for the package
#' 
#' @keywords internal
register_s3_methods <- function() {
  # Register print methods
  if (exists("print.professional_survey", mode = "function")) {
    registerS3method("print", "professional_survey", print.professional_survey)
  }
  
  if (exists("print.inrep_config", mode = "function")) {
    registerS3method("print", "inrep_config", print.inrep_config)
  }
  
  invisible(NULL)
}

#' Detach and unload inrep
#'
#' Detaches and unloads the package, for example before reinstalling it.
#' 
#' @param restart Whether to restart R session after detaching
#' @return Invisible NULL
#' @export
#' @examples
#' \dontrun{
#' # Before reinstalling
#' force_detach_inrep()
#' install.packages("inrep")
#' }
force_detach_inrep <- function(restart = FALSE) {
  pkg_name <- "inrep"
  
  # Check if package is loaded
  if (pkg_name %in% loadedNamespaces()) {
    # Try to detach if attached
    if (paste0("package:", pkg_name) %in% search()) {
      try(detach(paste0("package:", pkg_name), unload = TRUE, character.only = TRUE), silent = TRUE)
    }
    
    # Unload namespace
    try(unloadNamespace(pkg_name), silent = TRUE)
    
    # Force cleanup
    cleanup_package_state()
    clean_temp_files()
    
    message("Package 'inrep' has been detached and unloaded.")
    
    if (restart) {
      message("Please restart R to complete the cleanup.")
      if (interactive() && requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
        rstudioapi::restartSession()
      }
    }
  } else {
    message("Package 'inrep' is not currently loaded.")
  }
  
  invisible(NULL)
}

#' Reinstall inrep
#'
#' Detaches inrep, reinstalls it from the given source and attaches it again.
#' 
#' @param source Source of installation ("github", "local", "cran")
#' @param ... Additional arguments passed to installation function
#' @return Invisible NULL
#' @export
#' @examples
#' \dontrun{
#' # Reinstall from GitHub
#' reinstall_inrep("github")
#' 
#' # Reinstall from local source
#' reinstall_inrep("local", path = "~/inrep")
#' }
reinstall_inrep <- function(source = "github", ...) {
  # First detach the package
  force_detach_inrep(restart = FALSE)
  
  # Wait a moment for cleanup
  Sys.sleep(1)
  
  # Reinstall based on source
  switch(source,
    github = {
      if (!requireNamespace("remotes", quietly = TRUE)) {
        install.packages("remotes")
      }
      remotes::install_github("selvastics/inrep", ...)
    },
    local = {
      args <- list(...)
      path <- args$path %||% "."
      args$path <- NULL
      do.call(utils::install.packages,
              c(list(pkgs = path, repos = NULL, type = "source"), args))
    },
    cran = {
      install.packages("inrep", ...)
    },
    stop("Unknown source. Use 'github', 'local', or 'cran'")
  )
  
  # Reload the package
  library(inrep)
  
  message("Package 'inrep' has been reinstalled and loaded.")
  invisible(NULL)
}
