#pushed at 2025-12-13---19-08
#update at 2026-05-02---12-00
#pushed at 2026-05-02---12-59
#update at 2026-05-06---12-40
#pushed at 2026-05-06---12-59
#update at 2026-05-06---16-33
#pushed at 2026-05-06---17-59
#update at 2026-05-11---13-33
#pushed at 2026-05-11---16-10
#fix: theme CSS path corrected for shinyapps.io deployment 2026-05-02
is_truthy_env <- function(x) {
  if (is.null(x) || length(x) == 0) x <- "" else x <- x[[1]]
  x <- tolower(trimws(as.character(x)))
  nzchar(x) && x %in% c("1", "true", "t", "yes", "y", "on")
}

# Studio debug mode (off by default; enable via env var INREP_STUDIO_DEBUG=1)
INREP_STUDIO_DEBUG <- is_truthy_env(Sys.getenv("INREP_STUDIO_DEBUG", ""))
options(inrep.debug = INREP_STUDIO_DEBUG)

# Prefer UTF-8 for strings/files where possible (Windows-safe best-effort)
options(encoding = "UTF-8")
try(suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8")), silent = TRUE)
try(suppressWarnings(Sys.setlocale("LC_CTYPE", "English_United States.utf8")), silent = TRUE)

# Force English runtime messages (avoid German OS locale leaking into UI/errors)
Sys.setenv(LANGUAGE = "en")
try(suppressWarnings(Sys.setlocale("LC_MESSAGES", "English_United States.1252")), silent = TRUE)
try(suppressWarnings(Sys.setlocale("LC_MESSAGES", "English")), silent = TRUE)
try(suppressWarnings(Sys.setlocale("LC_MESSAGES", "C")), silent = TRUE)

# Shiny error verbosity: detailed only in debug mode
if (isTRUE(INREP_STUDIO_DEBUG)) {
  options(shiny.fullstacktrace = TRUE)
  options(shiny.sanitize.errors = FALSE)
} else {
  options(shiny.fullstacktrace = FALSE)
  options(shiny.sanitize.errors = TRUE)
}

quiet_library <- function(pkg) {
  suppressWarnings(suppressPackageStartupMessages(library(pkg, character.only = TRUE)))
}

quiet_library("shiny")
quiet_library("bslib")
quiet_library("bsicons")
quiet_library("jsonlite")
quiet_library("htmltools")
quiet_library("base64enc")
quiet_library("shiny.router")

# Source onboarding helper functions.
# The guard `if (sys.nframe() == 0L)` at EOF prevents the standalone runApp()
# from firing when sourced from within this combined app.
source("app-studio-onboarding.R")

# Safe null coalescing that handles vectors properly
`%||%` <- function(x, y) {
  if (is.null(x)) return(y)
  if (length(x) == 0) return(y)
  if (length(x) == 1 && is.na(x)) return(y)
  if (length(x) == 1 && x == "") return(y)
  x
}

# helper: sanitize id strings for use in Shiny input names
sanitize_id <- function(x) {
  gsub('[^A-Za-z0-9]', '_', x)
}

# Safe string quoting for R code generation - handles NA, NULL, special chars
safe_quote <- function(x) {
  if (is.null(x) || length(x) == 0) return('""')
  if (is.na(x)) return('""')
  x <- as.character(x)
  # Escape backslashes first, then quotes
  x <- gsub("\\\\", "\\\\\\\\", x)
  x <- gsub('"', '\\\\"', x)
  x <- gsub("\n", "\\\\n", x)
  x <- gsub("\r", "", x)
  x <- gsub("\t", "\\\\t", x)
  paste0('"', x, '"')
}

# Safe numeric conversion - handles vectors properly
safe_numeric <- function(x, default = 0) {
  if (is.null(x) || length(x) == 0) return(default)
  # Handle vectors: replace NA values with default
  result <- suppressWarnings(as.numeric(x))
  result[is.na(result)] <- default
  return(result)
}

# Write text files as UTF-8 (reduces Windows locale/encoding surprises)
write_text_utf8 <- function(text, path) {
  con <- file(path, open = "w", encoding = "UTF-8")
  on.exit(close(con), add = TRUE)
  writeLines(enc2utf8(text), con = con, useBytes = TRUE)
}

# Auto-link item to results page's default scale
# When an item is added to any items page, auto-create/update a default scale on results page
# Pass items_df to skip items where exclude_from_report == TRUE
auto_link_item_to_results <- function(pgs, item_id, items_df = NULL) {
  # Skip items that have been excluded from the report
  if(!is.null(items_df) && "exclude_from_report" %in% names(items_df)) {
    row <- items_df[items_df$id == item_id, ]
    if(nrow(row) > 0 && isTRUE(row$exclude_from_report[1])) return(pgs)
  }
  # Find results page
  results_page_id <- NULL
  for(pid in names(pgs)) {
    if(isTRUE(pgs[[pid]]$type == "results")) {
      results_page_id <- pid
      break
    }
  }
  
  
  if(is.null(results_page_id)) return(pgs)  # No results page, nothing to do
  
  # Initialize report_metrics if needed
  if(is.null(pgs[[results_page_id]]$report_metrics)) {
    pgs[[results_page_id]]$report_metrics <- list()
  }
  
  # Try to find an existing scale that matches the item prefix
  item_prefix <- gsub("_.*$", "", item_id)
  found_scale <- FALSE
  
  for(i in seq_along(pgs[[results_page_id]]$report_metrics)) {
    m <- pgs[[results_page_id]]$report_metrics[[i]]
    # Check if scale name matches prefix
    if(tolower(m$name) == tolower(item_prefix)) {
      # Add item to this scale if not already there
      if(!(item_id %in% m$items)) {
        pgs[[results_page_id]]$report_metrics[[i]]$items <- c(m$items, item_id)
      }
      found_scale <- TRUE
      break
    }
  }
  
  # If no matching scale found, create a new one for this prefix
  if(!found_scale) {
    new_scale <- list(
      name = item_prefix,
      label = item_prefix,
      icon = "bar-chart",
      items = item_id,
      formula = "mean"
    )
    pgs[[results_page_id]]$report_metrics <- c(pgs[[results_page_id]]$report_metrics, list(new_scale))
  }
  
  return(pgs)
}

# ============================================================================
# Theme CSS Cache — loaded ONCE at app startup.
# Works for all launch modes:
#   - Users who installed inrep and call launch_studio() / runApp():
#       system.file("themes", package = "inrep") resolves to the package library.
#   - Hosted on shinyapps.io with inst/themes/ bundled:
#       getwd() + "inst/themes" resolves first and wins.
#   - Hosted on shinyapps.io without inst/themes/ (app.R only):
#       Falls back gracefully — warning fires once to server log, preview uses
#       hardcoded fallback colors from get_preview_theme_css().
# Either way, zero filesystem reads happen during a user session.
# ============================================================================
.studio_theme_cache <- local({
  env <- new.env(parent = emptyenv())
  
  candidate_dirs <- c(
    file.path(getwd(), "inst", "themes"),
    file.path(dirname(getwd()), "inst", "themes"),
    tryCatch(system.file("themes", package = "inrep"), error = function(e) "")
  )
  
  theme_dir <- ""
  for (d in candidate_dirs) {
    if (nzchar(d) && dir.exists(d)) { theme_dir <- d; break }
  }
  
  if (nzchar(theme_dir)) {
    css_files <- list.files(theme_dir, pattern = "\\.css$", full.names = TRUE)
    for (f in css_files) {
      key <- tools::file_path_sans_ext(basename(f))
      env[[key]] <- paste(readLines(f, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
    }
    if (isTRUE(INREP_STUDIO_DEBUG)) {
      message(sprintf("[inrep Studio] Loaded %d theme CSS files from: %s",
                      length(css_files), theme_dir))
    }
  } else {
    warning("inrep Studio: no theme CSS directory found. ",
            "Install the inrep package (devtools::install_github('selvastics/inrep')) ",
            "or bundle inst/themes/ with your deployment. ",
            "Preview will use fallback colors only.")
  }
  
  env
})

# Detect whether we're running on a hosted platform (shinyapps.io / Connect)
# vs. locally via a user's R session. Used for UI hints and behavior differences.
is_shinyapps <- function() {
  nzchar(Sys.getenv("SHINY_PORT", "")) ||
    nzchar(Sys.getenv("RSTUDIO_CONNECT_HOSTNAME", "")) ||
    nzchar(Sys.getenv("R_CONFIG_ACTIVE", ""))
}

normalize_inrep_theme_key <- function(theme_name) {
  if (is.null(theme_name) || !nzchar(theme_name)) return("professional")
  
  key <- tolower(as.character(theme_name))
  key <- trimws(key)
  
  # Studio historically used a few capitalized theme keys; map them to filenames.
  key <- switch(
    key,
    "professional" = "professional",
    "berry" = "berry",
    "forest" = "forest",
    "ocean" = "ocean",
    "sunset" = "sunset",
    "light" = "light",
    "midnight" = "midnight",
    "hildesheim" = "hildesheim",
    key
  )
  
  key
}

read_inrep_theme_css <- function(theme_key) {
  # Uses the startup cache — zero filesystem reads during a user session.
  # Cache was populated from: bundled inst/themes/ > installed package themes/.
  base_css  <- .studio_theme_cache[["base"]]  %||% ""
  theme_css <- .studio_theme_cache[[theme_key]] %||% ""
  if (!nzchar(base_css) && !nzchar(theme_css)) return(NULL)
  paste(base_css, theme_css, sep = "\n")
}

# Scope base.css + theme.css selectors to .study-preview so they don't leak into
# the Studio UI and so the preview accurately renders real inrep Shiny output.
scope_css_for_preview <- function(css_text, scope = ".study-preview") {
  if (is.null(css_text) || !nzchar(trimws(css_text))) return("")
  
  # 1. Strip @import (fonts may not load in preview, that's acceptable)
  css_text <- gsub("@import[^;]+;", "", css_text)
  
  # 2. Remove color-scheme (would flip Studio layout to dark)
  css_text <- gsub("color-scheme\\s*:[^;]+;", "", css_text)
  
  # 3. Strip @media / @keyframes / @supports blocks (preview is fixed-size)
  for (i in seq_len(4)) {
    css_text <- gsub(
      "@(?:media|keyframes|supports)[^{]*\\{(?:[^{}]*|\\{[^{}]*\\})*\\}",
      "", css_text, perl = TRUE
    )
  }
  
  # 4. Transform global selectors to scope
  css_text <- gsub(":root\\b", scope, css_text, perl = TRUE)
  css_text <- gsub("\\bhtml\\b", scope, css_text, perl = TRUE)
  css_text <- gsub("\\bbody\\b", scope, css_text, perl = TRUE)
  
  # 5. Prefix all remaining selectors at depth 0 with scope
  lines  <- strsplit(css_text, "\n", fixed = TRUE)[[1]]
  depth  <- 0L
  result <- character(length(lines))
  
  for (i in seq_along(lines)) {
    ln <- lines[[i]]
    tr <- trimws(ln)
    n_open  <- nchar(gsub("[^{]", "", tr))
    n_close <- nchar(gsub("[^}]", "", tr))
    
    if (depth == 0L && n_open > 0L && nzchar(tr) &&
        !startsWith(tr, "//") && !startsWith(tr, "/*") && !startsWith(tr, "*")) {
      sel_raw <- trimws(sub("\\{.*", "", tr))
      if (nzchar(sel_raw)) {
        parts <- trimws(strsplit(sel_raw, ",", fixed = TRUE)[[1]])
        parts <- parts[nzchar(parts)]
        new_parts <- vapply(parts, function(p) {
          if (p == scope ||
              startsWith(p, paste0(scope, " ")) ||
              startsWith(p, paste0(scope, "."))) return(p)
          paste(scope, p)
        }, character(1L))
        new_sel <- paste(new_parts, collapse = ", ")
        if (new_sel != sel_raw) {
          ln <- sub(sel_raw, new_sel, ln, fixed = TRUE)
        }
      }
    }
    depth    <- max(0L, depth + n_open - n_close)
    result[[i]] <- ln
  }
  paste(result, collapse = "\n")
}

extract_css_custom_property <- function(css, property_name, default = NULL) {
  if (is.null(css) || !nzchar(css) || is.null(property_name) || !nzchar(property_name)) return(default)
  # Match: --property-name: value;
  # Capture value up to the next semicolon.
  pattern <- paste0("\\b", gsub("([\\-])", "\\\\\\1", property_name), "\\s*:\\s*([^;]+);")
  m <- regexec(pattern, css, perl = TRUE)
  reg <- regmatches(css, m)
  if (length(reg) == 0 || length(reg[[1]]) < 2) return(default)
  val <- trimws(reg[[1]][2])
  if (!nzchar(val)) return(default)
  val
}

# Theme vars for preview (loaded from inrep/inst/themes/*.css)
get_preview_theme_css <- function(theme_name) {
  theme_key <- normalize_inrep_theme_key(theme_name)
  css <- read_inrep_theme_css(theme_key)
  
  # Fallback palette (ensures preview always works)
  fallback <- list(
    primary = "#2c3e50",
    secondary = "#34495e",
    accent = "#3498db",
    bg = "#ffffff",
    text = "#2c3e50",
    border = "#bdc3c7",
    card_bg = "#ffffff",
    card_shadow = "0 2px 8px rgba(44,62,80,0.1)",
    card_shadow_hover = "0 4px 16px rgba(44,62,80,0.15)",
    font_family = "'Inter', 'Segoe UI', -apple-system, BlinkMacSystemFont, sans-serif",
    border_radius = "8px",
    progress_fill = "#3498db",
    progress_track = "#e5e7eb"
  )
  
  if (is.null(css)) return(fallback)
  
  out <- fallback
  out$primary <- extract_css_custom_property(css, "--primary-color", out$primary)
  out$secondary <- extract_css_custom_property(css, "--secondary-color", out$secondary)
  out$accent <- extract_css_custom_property(css, "--accent-color", out$accent)
  out$bg <- extract_css_custom_property(css, "--background-color", out$bg)
  out$text <- extract_css_custom_property(css, "--text-color", out$text)
  out$border <- extract_css_custom_property(css, "--border-color", out$border)
  out$card_shadow   <- extract_css_custom_property(css, "--card-shadow",      out$card_shadow)
  out$font_family   <- extract_css_custom_property(css, "--font-family",      out$font_family)
  out$border_radius <- extract_css_custom_property(css, "--border-radius",    out$border_radius)
  out$progress_track <- extract_css_custom_property(css, "--progress-bg-color", out$progress_track)
  # Dark themes define a separate card background
  out$card_bg  <- extract_css_custom_property(css, "--background-card", out$card_bg)
  out$input_bg <- extract_css_custom_property(css, "--input-background", out$bg)
  # Progress fill follows the primary color (matches base.css .progress-bar-fill behavior)
  out$progress_fill <- out$primary
  out
}

make_svg_progress_ring <- function(
    pct,
    size_px = 48,
    stroke_width = 6,
    color = "#2c3e50",
    track = "#e5e7eb",
    center_fill = "#ffffff",
    text_color = "#111111"
) {
  pct <- suppressWarnings(as.numeric(pct))
  if (is.na(pct)) pct <- 0
  pct <- max(0, min(100, pct))
  
  # Keep everything in a viewBox for crisp rendering.
  vb <- 100
  r <- (vb / 2) - (stroke_width * (vb / size_px))
  cx <- vb / 2
  cy <- vb / 2
  c <- 2 * pi * r
  filled <- (pct / 100) * c
  dasharray <- sprintf("%.4f %.4f", filled, c - filled)
  
  tags$div(
    style = sprintf(
      "width:%dpx;height:%dpx;display:inline-flex;align-items:center;justify-content:center;",
      as.integer(size_px), as.integer(size_px)
    ),
    tags$svg(
      xmlns = "http://www.w3.org/2000/svg",
      width = as.character(size_px),
      height = as.character(size_px),
      viewBox = sprintf("0 0 %d %d", vb, vb),
      style = "display:block;",
      `shape-rendering` = "geometricPrecision",
      # Track
      tags$circle(
        cx = cx,
        cy = cy,
        r = r,
        fill = "none",
        stroke = track,
        `stroke-width` = stroke_width,
        `stroke-linecap` = "round"
      ),
      # Progress
      tags$circle(
        cx = cx,
        cy = cy,
        r = r,
        fill = "none",
        stroke = color,
        `stroke-width` = stroke_width,
        `stroke-linecap` = "round",
        `stroke-dasharray` = dasharray,
        transform = sprintf("rotate(-90 %s %s)", cx, cy)
      ),
      # Center fill
      tags$circle(
        cx = cx,
        cy = cy,
        r = r - (stroke_width * 0.9),
        fill = center_fill,
        stroke = "none"
      ),
      # Percent label
      tags$text(
        x = cx,
        y = cy + 2,
        `text-anchor` = "middle",
        `dominant-baseline` = "middle",
        fill = text_color,
        style = "font-weight:700;font-size:20px;",
        paste0(sprintf("%d", as.integer(round(pct))), "%")
      )
    )
  )
}

ui <- page_fluid(
  title = "inrep Studio",
  theme = bs_theme(version = 5, preset = "zephyr", primary = "#e8041c"),
  
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$script(HTML("
      // Root route = studio. Redirect legacy hash bookmarks to root.
      (function(){
        var h = window.location.hash;
        if (h === '#!/studio' || h === '#/studio' || h === '#!/onboarding' || h === '#/onboarding') {
          window.location.replace(window.location.href.split('#')[0]);
        }
      })();
    ")),
    tags$script(HTML("
      // Show/hide views without URL changes.
      Shiny.addCustomMessageHandler('showView', function(view) {
        var studio = document.getElementById('studio-main');
        var ob = document.getElementById('onboarding-view');
        if (studio) studio.style.display = (view === 'studio') ? '' : 'none';
        if (ob) ob.style.display = (view === 'onboarding') ? '' : 'none';
      });
    ")),
    tags$style(HTML("
      /* ===== GLOBAL RESET & VARS (inrep Brand Colors) ===== */
      :root {
        --studio-primary: #e8041c;
        --studio-secondary: #b80318;
        --studio-accent: #c0031a;
        --studio-dark: #2c3e50;
        --studio-gray: #7f8c8d;
        --studio-light: #ecf0f1;
        --studio-border: #bdc3c7;
        --studio-radius: 8px;
        --studio-shadow: 0 4px 20px rgba(44,62,80,0.12);
        --studio-transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
        --studio-transition-fast: all 0.15s cubic-bezier(0.4, 0, 0.2, 1);
        --studio-success: #27ae60;
        --studio-warning: #f39c12;
        --studio-danger: #e74c3c;
      }
      
      * { 
        box-sizing: border-box;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
      }

      html, body {
        overflow-x: hidden;
        overscroll-behavior-x: none;
      }
      
      /* Global button optimizations */
      button, .btn, input[type='button'], input[type='submit'] {
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        transform: translateZ(0);
        will-change: transform, background-color, box-shadow;
        backface-visibility: hidden;
      }
      
      button:hover, .btn:hover {
        transform: translateY(-1px);
      }
      
      button:active, .btn:active {
        transform: translateY(0);
        transition-duration: 0.1s;
      }
      
      /* Prevent layout shifts during load */
      .main-container,
      .col-left,
      .col-center,
      .col-right,
      .sidebar-header,
      .sidebar-footer,
      .preview-toolbar,
      .mobile-toggle,
      .mobile-properties-toggle {
        opacity: 0;
        animation: fadeInSmooth 0.4s cubic-bezier(0.4, 0, 0.2, 1) forwards;
      }
      
      .sidebar-header { animation-delay: 0.05s; }
      .sidebar-content { animation-delay: 0.1s; }
      .sidebar-footer { animation-delay: 0.15s; }
      .preview-toolbar { animation-delay: 0.1s; }
      .mobile-toggle { animation-delay: 0.2s; }
      .mobile-properties-toggle { animation-delay: 0.25s; }
      
      @keyframes fadeInSmooth {
        from {
          opacity: 0;
        }
        to {
          opacity: 1;
        }
      }
      
      /* Smooth scrollbars */
      html {
        scroll-behavior: smooth;
      }
      ::-webkit-scrollbar {
        width: 8px;
        height: 8px;
      }
      ::-webkit-scrollbar-track {
        background: var(--studio-light);
        border-radius: 4px;
      }
      ::-webkit-scrollbar-thumb {
        background: var(--studio-border);
        border-radius: 4px;
        transition: var(--studio-transition-fast);
      }
      ::-webkit-scrollbar-thumb:hover {
        background: var(--studio-gray);
      }
      * {
        scrollbar-width: thin;
        scrollbar-color: var(--studio-border) var(--studio-light);
      }
      body { 
        height: 100vh; 
        overflow-x: hidden;
        overflow-y: hidden;
        background: linear-gradient(135deg, #ecf0f1 0%, #bdc3c7 100%);
        font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }

      /* Real iPhone/Safari: keep the entire app inside safe areas and prevent 1–2px horizontal drift */
      @supports (padding: max(0px)) {
        @media (max-width: 520px) {
          body {
            padding-left: env(safe-area-inset-left);
            padding-right: env(safe-area-inset-right);
          }
        }
      }
      
      /* ===== MAIN 3-COLUMN LAYOUT ===== */
      .main-container { 
        height: 100vh; 
        min-height: 100vh;
        width: 100vw;
        max-width: 100vw;
        display: grid;
        grid-template-columns: 320px 1fr 360px;
        gap: 0;
        overflow-x: hidden;
      }

      @media (max-width: 520px) {
        .main-container {
          width: 100%;
          max-width: 100%;
          overflow-x: hidden;
        }
      }
      
      @media (max-width: 1600px) {
        .main-container { grid-template-columns: 300px 1fr 340px; }
      }
      @media (max-width: 1400px) {
        .main-container { grid-template-columns: 280px 1fr 320px; }
      }
      @media (max-width: 1200px) {
        .main-container { grid-template-columns: 1fr; position: relative; min-height: 100vh; width: 100%; max-width: 100%; }
        /* Force all panels to share the same grid cell so they overlap the preview instead of stacking */
        .col-center { grid-column: 1; grid-row: 1; position: relative; z-index: 0; }
        /* Slide-in behavior for BOTH panels on tablet widths */
        .col-left { 
          grid-column: 1; grid-row: 1;
          position: fixed; left: -100%; top: 0; z-index: 1300; 
          width: 88%; max-width: 320px; height: 100vh; height: 100dvh;
          transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 2px 0 20px rgba(0,0,0,0.3);
          background: #fff;
          display: flex; flex-direction: column;
          overflow: hidden;
        }
        .col-left.mobile-open { left: 0; z-index: 1301; }
        .col-left .sidebar-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        /* Keep right panel available for mobile/tablet slide-in */
        .col-right {
          grid-column: 1; grid-row: 1;
          display: flex !important; flex-direction: column;
          position: fixed;
          right: calc(-100% - 360px);
          top: 0;
          z-index: 1300;
          width: 88%;
          max-width: 360px;
          height: 100vh; height: 100dvh;
          transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: -2px 0 20px rgba(0,0,0,0.3);
          background: #ffffff !important;
          overflow: hidden;
          opacity: 1 !important;
        }
        .col-right .right-panel-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        .col-right.mobile-open { 
          right: 0;
          z-index: 1301;
          display: flex !important;
          background: #ffffff !important;
          opacity: 1 !important;
        }
      }
      @media (max-width: 900px) {
        .main-container { grid-template-columns: 1fr; }
      }
      @media (max-width: 768px) {
        body { overflow-y: auto; overflow-x: hidden; }
        .main-container { grid-template-columns: 1fr; min-height: 100vh; height: auto; width: 100%; max-width: 100%; overflow-x: hidden; position: relative; }
        .col-center { grid-column: 1; grid-row: 1; position: relative; z-index: 0; }
        .col-left { 
          grid-column: 1; grid-row: 1;
          position: fixed; left: -100%; top: 0; z-index: 1300; 
          width: 88%; max-width: 320px; height: 100vh; height: 100dvh;
          transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 2px 0 20px rgba(0,0,0,0.3);
          background: #fff;
          display: flex; flex-direction: column;
          overflow: hidden;
        }
        .col-left.mobile-open { left: 0; z-index: 1301; }
        .col-left .sidebar-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        .mobile-toggle { display: flex !important; }

        /* Right panel: slide in from right on small screens */
        .col-right {
          grid-column: 1; grid-row: 1;
          position: fixed;
          right: calc(-100% - 360px);
          top: 0;
          z-index: 1300;
          width: 88%;
          max-width: 360px;
          height: 100vh; height: 100dvh;
          display: flex !important;
          flex-direction: column;
          background: #ffffff !important;
          box-shadow: -2px 0 20px rgba(0,0,0,0.3);
          transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          overflow: hidden;
          opacity: 1 !important;
        }
        .col-right .right-panel-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        .col-right.mobile-open {
          right: 0;
          z-index: 1301;
          opacity: 1 !important;
          background: #ffffff !important;
        }
        .col-center {
          height: auto;
          min-height: 100vh;
          overflow: visible;
        }
      }
      @media (max-width: 1200px) {
        .mobile-properties-toggle { display: flex !important; }
      }
      @media (max-width: 480px) {
        body { overflow-y: auto; overflow-x: hidden; }
        .main-container { grid-template-columns: 1fr; height: auto; min-height: 100vh; width: 100%; max-width: 100%; overflow-x: hidden; position: relative; }
        .col-center { grid-column: 1; grid-row: 1; position: relative; z-index: 0; }
        .preview-frame-container { min-height: 70vh; }
        .col-left { 
          grid-column: 1; grid-row: 1;
          position: fixed; left: -100%; top: 0; z-index: 1300; 
          width: 88%; max-width: 320px; height: 100vh; height: 100dvh;
          transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          box-shadow: 2px 0 20px rgba(0,0,0,0.3);
          background: #fff;
          display: flex; flex-direction: column;
          overflow: hidden;
        }
        .col-left.mobile-open { left: 0; z-index: 1301; }
        .col-left .sidebar-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        .mobile-toggle { display: flex !important; }
        .col-right {
          grid-column: 1; grid-row: 1;
          position: fixed;
          right: calc(-100% - 360px);
          top: 0;
          z-index: 1300;
          width: 88%;
          max-width: 360px;
          height: 100vh; height: 100dvh;
          display: flex !important;
          flex-direction: column;
          background: #ffffff !important;
          box-shadow: -2px 0 20px rgba(0,0,0,0.3);
          transition: right 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          overflow: hidden;
          opacity: 1 !important;
        }
        .col-right .right-panel-content {
          flex: 1; overflow-y: auto;
          -webkit-overflow-scrolling: touch;
          touch-action: pan-y;
          overscroll-behavior: contain;
        }
        .col-right.mobile-open { 
          right: 0;
          z-index: 1301;
          background: #ffffff !important;
          opacity: 1 !important;
        }
        .preview-toolbar { 
          gap: 8px;
          padding: 10px;
        }
        .preview-toolbar-left, .preview-toolbar-right { 
          gap: 6px;
        }
        .mode-toggle-container {
          width: 100%;
          display: flex;
          justify-content: center;
          align-items: center;
          padding: 8px 0;
          gap: 8px;
        }
        .page-nav-container { 
          padding: 10px 6px;
          flex-wrap: nowrap;
          overflow-x: auto;
          -webkit-overflow-scrolling: touch;
          scrollbar-width: thin;
        }
        .page-nav-btn {
          min-width: 60px;
          font-size: 0.8rem;
          padding: 6px 10px;
        }
        .page-nav-item {
          flex-shrink: 0;
        }
      }
      
      /* Very small screens - ensure preview is visible and scaled */
      @media (max-width: 768px) {
        .col-center {
          padding: 10px;
          padding-top: 16px;
          height: auto;
          min-height: 100vh;
          overflow-y: auto;
          overflow-x: hidden;
          overscroll-behavior-x: none;
          touch-action: pan-y;
          scroll-behavior: smooth;
        }
        .preview-toolbar {
          padding: 8px 10px;
          gap: 8px;
        }
        .preview-toolbar-left {
          gap: 6px;
          align-items: center;
        }
        .preview-toolbar-right {
          gap: 8px;
          align-items: center;
          justify-content: flex-end;
        }
        body.edit-mode-active .edit-only-controls {
          display: flex !important;
          gap: 6px;
          align-items: center;
        }
        .mode-toggle-container {
          display: flex !important;
          gap: 6px;
          align-items: center;
          background: transparent;
          padding: 0;
          border-radius: 0;
        }
        .mode-badge {
          font-size: 0.7rem;
          padding: 4px 8px;
          letter-spacing: 0.2px;
          gap: 4px;
        }
        .preview-frame-container {
          padding: 8px;
        }
        
      }
      
      @media (max-width: 480px) {
        .col-center {
          padding: 8px;
          padding-top: 16px;
          overflow-y: auto;
          overflow-x: hidden;
          overscroll-behavior-x: none;
          touch-action: pan-y;
          scroll-behavior: smooth;
        }
        .preview-toolbar {
          padding: 6px 8px;
          margin-bottom: 4px;
          gap: 6px;
        }
        .preview-toolbar-left {
          gap: 6px;
          align-items: center;
        }
        .preview-toolbar-right {
          gap: 4px;
          align-items: center;
          justify-content: flex-end;
        }
        body.edit-mode-active .edit-only-controls {
          display: flex !important;
          gap: 4px;
          align-items: center;
          flex: 0 1 auto;
        }
        .mode-toggle-container {
          display: flex !important;
          gap: 4px;
          align-items: center;
          background: transparent;
          padding: 0;
          border-radius: 0;
        }
        .mode-badge {
          font-size: 0.65rem;
          padding: 3px 6px;
          letter-spacing: 0.2px;
          gap: 3px;
        }
        .page-nav-container { 
          padding: 4px 6px;
          margin-bottom: 4px;
        }
        .preview-content {
          padding: 12px !important;
        }
      }
      
      @media (max-width: 360px) {
        .col-center {
          padding: 8px;
          padding-top: 16px;
          overflow-x: hidden;
          overscroll-behavior-x: none;
          touch-action: pan-y;
          scroll-behavior: smooth;
        }
        .preview-toolbar {
          padding: 4px 6px;
          margin-bottom: 4px;
        }
        .page-nav-container {
          padding: 4px 6px;
          margin-bottom: 4px;
        }
        .preview-toolbar {
          padding: 6px 8px;
        }
      }
      
      .col-left { 
        background: #fff; 
        border-right: 1px solid var(--studio-border); 
        height: 100vh; 
        overflow-y: auto;
        overflow-x: hidden;
        padding: 0;
        display: flex;
        flex-direction: column;
        min-width: 0;
      }
      
      .col-center { 
        height: 100vh; 
        overflow: hidden;
        padding: 8px;
        padding-top: 8px;
        display: flex;
        flex-direction: column;
        align-items: stretch;
        justify-content: flex-start;
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        scroll-behavior: smooth;
      }
      
      /* On phone: ensure col-center doesn't add asymmetric padding */
      @media (max-width: 520px) {
        .col-center {
          padding-left: 0;
          padding-right: 0;
        }
      }
      
      @media (min-width: 1201px) {
        .col-right { 
          background: #ffffff !important; 
          border-left: 1px solid var(--studio-border); 
          height: 100vh; 
          /* Keep vertical layout clipped, but allow the resize handle to sit slightly outside the panel */
          overflow-y: hidden;
          overflow-x: visible;
          display: flex;
          flex-direction: column;
          opacity: 1 !important;
        }
      }
      
      /* ===== LEFT SIDEBAR ===== */
      .col-left {
        opacity: 1; /* Override fade-in for immediate visibility */
        animation: none !important;
      }
      
      .sidebar-header {
        padding: 16px 20px;
        border-bottom: 1px solid var(--studio-border);
        background: #f8f9fa;
        color: var(--studio-dark);
        min-height: 72px; /* Prevent layout shift */
        overflow-x: hidden;
      }
      .sidebar-header h4 { margin: 0; font-weight: 700; font-size: 1.15rem; }
      .sidebar-header small { opacity: 0.65; font-size: 0.8rem; color: var(--studio-gray); }
      
      .sidebar-content { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 16px; min-width: 0; }
      
      .sidebar-footer {
        padding: 16px 20px;
        border-top: 1px solid var(--studio-border);
        background: linear-gradient(180deg, #fafbfc 0%, #f8f9fa 100%);
        min-height: 80px; /* Prevent layout shift */
      }
      
      .sidebar-footer .btn {
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        transform: translateZ(0); /* Enable GPU acceleration */
        will-change: transform, box-shadow;
      }
      
      .sidebar-footer .btn:hover {
        transform: translateY(-1px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
      }
      
      .sidebar-footer .btn:active {
        transform: translateY(0);
        transition-duration: 0.1s;
      }
      
      /* Accordion styling */
      .accordion-button { 
        font-weight: 600; 
        font-size: 0.9rem; 
        padding: 14px 18px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        transform: translateZ(0);
        will-change: background-color, box-shadow;
      }
      .accordion-button:not(.collapsed) { 
        background: linear-gradient(135deg, #e8f4fc 0%, #f0f9ff 100%);
        box-shadow: inset 0 -2px 0 rgba(52,152,219,0.2);
      }
      .accordion-button:hover {
        background: #f0f9ff;
      }
      .accordion-body {
        padding: 18px;
        animation: accordionSlide 0.25s cubic-bezier(0.4, 0, 0.2, 1);
      }
      @keyframes accordionSlide {
        from { 
          opacity: 0; 
          transform: translateY(-4px);
        }
        to { 
          opacity: 1; 
          transform: translateY(0);
        }
      }
      .accordion-body { padding: 12px 16px; }
      .accordion-item { border-color: var(--studio-border); }
      
      /* ===== CENTER PREVIEW AREA ===== */
      /* Flex + absolute-positioned left column so the mode toggle is always
         geometrically centered in the toolbar regardless of edit controls. */
      .preview-toolbar {
        position: relative;
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 6px;
        padding: 4px;
        background: transparent;
        flex-shrink: 0;
        min-height: 40px;
      }
      
      .preview-toolbar-left { position: absolute; left: 4px; display: flex; gap: 6px; align-items: center; }
      .preview-toolbar-right { position: absolute; right: 4px; display: flex; gap: 12px; align-items: center; }
      .edit-only-controls { display: none !important; }
      
      /* Mobile: show Add Page button in toolbar and stack together with eye button */
      @media (max-width: 768px) {
        .preview-toolbar {
          gap: 8px;
        }
        .preview-toolbar-left {
          gap: 8px;
          align-items: center;
        }
        body.edit-mode-active .edit-only-controls {
          display: flex !important;
          gap: 8px;
          align-items: center;
        }
        .preview-toolbar-right {
          gap: 8px;
          align-items: center;
        }
        .mode-toggle-container {
          display: flex;
          gap: 6px;
          align-items: center;
        }
        #mode-eye-button {
          padding: 6px 10px;
          display: flex;
          align-items: center;
          gap: 4px;
        }
      }
      
      .mode-badge {
        padding: 6px 14px;
        border-radius: 20px;
        font-size: 0.75rem;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        white-space: nowrap;
        height: 32px;
        min-width: 92px;
        line-height: 1;
        box-sizing: border-box;
      }
      .mode-badge.edit-mode { background: #fee2e2; color: #991b1b; border: 2px solid #ef4444; }
      .mode-badge.preview-mode { background: #f1f5f9; color: #64748b; border: 2px solid #94a3b8; }
      
      @media (max-width: 480px) {
        .mode-badge {
          font-size: 0.65rem;
          padding: 4px 10px;
          letter-spacing: 0.3px;
        }
      }
      
      /* Mode toggle container — must be inline-flex so it only takes as much width as
         its content. The Shiny input_switch renders a .shiny-input-container with
         Bootstrap's default width:300px; without overriding that, the badge appears
         stuck to the left side of a 430px-wide centered container. */
      .mode-toggle-container {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 4px 8px;
        background: var(--studio-light);
        border-radius: 8px;
      }
      /* Kill the 300px default Shiny width so the container only wraps its content */
      .mode-toggle-container .shiny-input-container {
        width: auto !important;
        margin-bottom: 0;
        flex-shrink: 0;
      }
      .mode-toggle-container .form-switch {
        margin: 0;
        padding: 0;
        display: flex;
        align-items: center;
        /* No translateY hack — align-items:center on the parent handles vertical centering */
      }
      .mode-toggle-container .form-check-input {
        width: 40px;
        height: 20px;
        margin: 0;
        cursor: pointer;
      }
      
      /* ===== PAGE NAVIGATION ===== */
      .page-nav-container {
        width: 100%;
        max-width: 100%;
        background: white;
        border-radius: var(--studio-radius);
        box-shadow: var(--studio-shadow);
        padding: 6px 10px;
        margin-bottom: 6px;
        flex-shrink: 0;
      }
      .page-nav-scroll { 
        display: flex; 
        gap: 8px; 
        flex-wrap: wrap;
        justify-content: flex-start;
      }

      /* Phone: in Edit mode, show pages as a 2-column grid (2x2 for default 4 pages). */
      @media (max-width: 520px) {
        body.edit-mode-active .page-nav-scroll {
          display: grid;
          grid-template-columns: repeat(2, minmax(0, 1fr));
          gap: 8px;
        }
        body.edit-mode-active .page-nav-item {
          min-width: 0;
          max-width: none;
          width: 100%;
          padding: 10px 10px;
        }
        body.edit-mode-active .page-nav-title {
          font-size: 0.78rem;
        }
      }
      
      /* ===== PAGE NAV ITEMS - PROFESSIONAL SMOOTH DESIGN ===== */
      .page-nav-item {
        display: flex;
        align-items: center;
        gap: 8px;
        padding: 10px 14px;
        background: var(--studio-light);
        border: 2px solid transparent;
        border-radius: 10px;
        cursor: pointer;
        transition: background 0.15s ease, border-color 0.15s ease, box-shadow 0.15s ease, transform 0.15s ease;
        min-width: 120px;
        max-width: 180px;
        flex: 0 0 auto;
        position: relative;
        overflow: visible;
        user-select: none;
        -webkit-user-select: none;
      }
      /* Subtle glow on hover instead of sweep animation */
      .page-nav-item:hover { 
        background: white; 
        border-color: var(--studio-border);
        box-shadow: 0 4px 16px rgba(0,0,0,0.08);
      }
      .page-nav-item:active {
        transform: scale(0.98);
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
      }
      .page-nav-item.active { 
        background: white;
        border-color: var(--studio-primary); 
        box-shadow: 0 0 0 3px rgba(44, 62, 80, 0.15), 0 4px 12px rgba(0,0,0,0.08);
      }
      .page-nav-icon {
        width: 28px; height: 28px;
        border-radius: 6px;
        display: flex; align-items: center; justify-content: center;
        font-size: 0.85rem;
        flex-shrink: 0;
        transition: transform 0.15s ease;
      }
      .page-nav-item:hover .page-nav-icon {
        transform: scale(1.05);
      }
      .page-nav-icon.custom { background: #d5e8f7; color: #2980b9; }
      .page-nav-icon.demographics { background: #f5e6ce; color: #d35400; }
      .page-nav-icon.items { background: #d5f5e3; color: #27ae60; }
      .page-nav-icon.results { background: #fdebd0; color: #e67e22; }
      
      .page-nav-text { flex: 1; min-width: 0; overflow: hidden; }
      .page-nav-title { font-weight: 600; font-size: 0.8rem; color: var(--studio-dark); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
      .page-nav-type { font-size: 0.7rem; color: var(--studio-gray); text-transform: uppercase; }
      
      /* Page drag handle — always rendered so block width stays constant across modes.
         Visibility/interaction controlled by body class so no layout shift occurs. */
      .page-drag-handle {
        cursor: grab;
        padding: 2px 4px;
        color: var(--studio-gray);
        /* Hidden in preview mode — visibility:hidden preserves the space (no layout shift) */
        visibility: hidden;
        pointer-events: none;
        opacity: 0;
        transition: opacity 0.15s ease, color 0.15s ease;
        margin-right: 4px;
        flex-shrink: 0;
      }
      /* Show drag handle only in edit mode */
      body.edit-mode-active .page-drag-handle {
        visibility: visible;
        pointer-events: auto;
        opacity: 0.3;
      }
      body.edit-mode-active .page-nav-item:hover .page-drag-handle {
        opacity: 0.8;
        color: var(--studio-primary);
      }
      .page-drag-handle:active {
        cursor: grabbing;
        opacity: 1;
      }

      /* Page order badge — position:absolute so it never changes block dimensions.
         Hidden in preview mode via opacity so it fades out cleanly. */
      .page-order-badge {
        position: absolute;
        top: -8px;
        right: -8px;
        background: var(--studio-accent);
        color: white;
        width: 20px;
        height: 20px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.7rem;
        font-weight: 700;
        box-shadow: 0 2px 6px rgba(0,0,0,0.25);
        z-index: 10;
        border: 2px solid white;
        pointer-events: none;
        /* Hidden in preview mode */
        opacity: 0;
        transition: opacity 0.15s ease;
      }
      body.edit-mode-active .page-order-badge {
        opacity: 1;
      }
      
      /* Warning badge for page ordering issues */
      .page-warning-badge {
        position: absolute;
        top: -6px;
        left: -6px;
        background: #dc3545;
        color: white;
        width: 18px;
        height: 18px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.65rem;
        font-weight: 700;
        box-shadow: 0 2px 6px rgba(220,53,69,0.4);
        z-index: 11;
        border: 2px solid white;
        pointer-events: none;
        animation: pulse-warning 2s infinite;
      }
      
      @keyframes pulse-warning {
        0%, 100% { transform: scale(1); }
        50% { transform: scale(1.1); }
      }
      
      .page-nav-item.page-warning {
        border-color: #dc3545 !important;
        box-shadow: 0 0 0 2px rgba(220,53,69,0.2);
      }
      
      /* ===== DRAG-DROP STYLES - POLISHED SORTABLE ===== */
      .draggable-page {
        position: relative;
        transition: transform 0.2s cubic-bezier(0.2, 0, 0, 1);
      }
      
      /* Dragging state - ghost effect */
      .page-nav-item.dragging,
      .draggable-page.dragging .page-nav-item {
        opacity: 0.4;
        transform: scale(0.95);
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        border-color: var(--studio-accent) !important;
        background: white !important;
      }
      
      /* Drop indicator lines - clear visual feedback */
      .page-nav-item.drop-before::before {
        content: '';
        position: absolute;
        left: -6px;
        top: 0;
        bottom: 0;
        width: 4px;
        background: var(--studio-accent);
        border-radius: 2px;
        animation: dropIndicatorPulse 0.8s ease-in-out infinite;
      }
      .page-nav-item.drop-after::after {
        content: '';
        position: absolute;
        right: -6px;
        top: 0;
        bottom: 0;
        width: 4px;
        background: var(--studio-accent);
        border-radius: 2px;
        animation: dropIndicatorPulse 0.8s ease-in-out infinite;
      }
      
      @keyframes dropIndicatorPulse {
        0%, 100% { opacity: 1; transform: scaleY(0.9); }
        50% { opacity: 0.7; transform: scaleY(1); }
      }
      
      /* Drag over state */
      .page-nav-item.drag-over {
        background: rgba(52, 152, 219, 0.08) !important;
        border-color: var(--studio-accent) !important;
      }
      
      /* Pages container during drag */
      .page-nav.drag-active {
        background: rgba(52, 152, 219, 0.03);
        border-radius: 12px;
        padding: 8px;
        margin: -8px;
      }
      
      /* ===== PREVIEW FRAME ===== */
      /* Simple scroll container — does NOT use align-items:center because that
         would shrink the Shiny uiOutput wrapper to content-width, making
         width:100% on .study-preview resolve to a tiny size in the browser. */
      .preview-frame-container {
        width: 100%;
        flex: 1;
        overflow-y: auto;
        overflow-x: hidden;
        -webkit-overflow-scrolling: touch;
        overscroll-behavior-y: contain;
        padding: 16px;
      }
      /* Shiny wraps uiOutput in a div — ensure it fills the container */
      .preview-frame-container > div {
        width: 100%;
      }
      
      /* ===== STUDY PREVIEW ===== */
      /* Acts as the study body. Centered via margin:0 auto + max-width.
         !important beats scoped base.css which maps body{margin:0} onto
         .study-preview{margin:0} and would override margin:auto.
         outline renders on top of overflow:hidden parents (unlike box-shadow). */
      .study-preview {
        font-family: var(--preview-font-family, 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif);
        width: 100%;
        max-width: 860px;
        margin: 0 auto !important;
        display: flex;
        flex-direction: column;
        background: var(--preview-bg, #ffffff);
        color: var(--preview-text, #1a1a1a);
        line-height: 1.6;
        border-radius: 10px;
        overflow: hidden;
        outline: 1.5px solid rgba(0,0,0,0.12);
        box-shadow: 0 4px 24px rgba(0,0,0,0.10);
      }
      
      .study-preview-header {
        padding: 20px 32px;
        border-bottom: 2px solid var(--preview-border, #e5e7eb);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: linear-gradient(180deg, var(--preview-bg, #ffffff) 0%, color-mix(in srgb, var(--preview-bg, #ffffff) 95%, #000) 100%);
        box-shadow: var(--preview-shadow, 0 2px 8px rgba(0,0,0,0.04));
        position: sticky;
        top: 0;
        z-index: 5;
      }
      .study-preview-title {
        font-weight: 700;
        font-size: 1.25rem;
        color: var(--preview-text, #1a1a1a);
        letter-spacing: -0.02em;
        max-width: 60%;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
      .study-preview-progress {
        display: flex;
        align-items: center;
        gap: 12px;
        flex-shrink: 0;
      }
      .progress-bar-container {
        width: 140px;
        height: 8px;
        background: color-mix(in srgb, var(--preview-border, #e5e7eb) 60%, white);
        border-radius: 4px;
        overflow: hidden;
        box-shadow: inset 0 1px 2px rgba(0,0,0,0.05);
      }
      .progress-bar-fill {
        height: 100%;
        background: linear-gradient(90deg, var(--preview-primary, #2c3e50), color-mix(in srgb, var(--preview-primary, #2c3e50) 80%, #ffffff));
        border-radius: 4px;
        transition: width 0.4s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 0 0 1px rgba(255,255,255,0.3) inset;
      }
      .progress-text {
        font-size: 0.8rem;
        color: var(--preview-gray, #6b7280);
        font-weight: 600;
        letter-spacing: 0.5px;
      }

      /* Progress edit/add buttons in preview header */
      .preview-progress-add-btn, .preview-progress-edit-btn {
        background: transparent;
        border: 1.5px dashed var(--preview-border, #e5e7eb);
        color: var(--preview-gray, #9ca3af);
        border-radius: 6px;
        font-size: 0.75rem;
        padding: 4px 10px;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 4px;
        transition: border-color 0.15s, color 0.15s, background 0.15s;
      }
      .preview-progress-add-btn:hover, .preview-progress-edit-btn:hover {
        border-color: var(--preview-primary, #2c3e50);
        color: var(--preview-primary, #2c3e50);
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 6%, transparent);
        border-style: solid;
      }
      .preview-progress-edit-btn {
        border: none;
        padding: 4px 6px;
        font-size: 0.85rem;
      }
      
      .study-preview-content {
        flex: 1;
        padding: 48px 40px;
        overflow-y: auto;
        background: var(--preview-bg, #ffffff);
        min-height: 300px;
      }
      .study-preview-content::-webkit-scrollbar {
        width: 8px;
      }
      .study-preview-content::-webkit-scrollbar-track {
        background: transparent;
      }
      .study-preview-content::-webkit-scrollbar-thumb {
        background: var(--preview-border, #e5e7eb);
        border-radius: 4px;
      }
      .study-preview-content::-webkit-scrollbar-thumb:hover {
        background: var(--preview-gray, #9ca3af);
      }
      
      .study-preview-footer {
        padding: 20px 32px;
        border-top: 2px solid var(--preview-border, #e5e7eb);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: linear-gradient(0deg, color-mix(in srgb, var(--preview-bg, #ffffff) 95%, #000) 0%, var(--preview-bg, #ffffff) 100%);
        box-shadow: var(--preview-shadow, 0 -2px 8px rgba(0,0,0,0.04));
        position: sticky;
        bottom: 0;
        z-index: 5;
        gap: 12px;
        flex-wrap: wrap;
      }
      
      /* Studio-owned preview content area — class names intentionally NOT used by
         inrep theme CSS, so scoped theme rules never create a double-card effect. */
      .studio-preview-body {
        padding: 32px 40px;
        flex: 1;
      }
      .studio-preview-nav {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding-top: 24px;
        margin-top: 24px;
        border-top: 1px solid var(--preview-border, #e5e7eb);
      }
      .studio-nav-btn {
        padding: 10px 24px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.9rem;
        border: 2px solid var(--preview-primary, #2c3e50);
        background: white;
        color: var(--preview-primary, #2c3e50);
        cursor: pointer;
        transition: all 0.2s ease;
      }
      .studio-nav-btn-primary {
        background: var(--preview-primary, #2c3e50);
        color: white;
        border-color: var(--preview-primary, #2c3e50);
      }
      
      .preview-btn {
        padding: 12px 28px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.95rem;
        border: none;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        display: inline-flex;
        align-items: center;
        justify-content: center;
        min-width: 140px;
        white-space: nowrap;
      }
      .preview-btn-primary {
        background: linear-gradient(135deg, var(--preview-primary, #2c3e50), color-mix(in srgb, var(--preview-primary, #2c3e50) 80%, #000));
        color: white;
        box-shadow: 0 4px 12px color-mix(in srgb, var(--preview-primary, #2c3e50) 40%, transparent);
      }
      .preview-btn-primary:hover { 
        transform: translateY(-2px);
        box-shadow: 0 6px 16px color-mix(in srgb, var(--preview-primary, #2c3e50) 50%, transparent);
        filter: brightness(1.08);
      }
      .preview-btn-primary:active {
        transform: translateY(0);
        box-shadow: 0 2px 8px color-mix(in srgb, var(--preview-primary, #2c3e50) 30%, transparent);
      }
      .preview-btn-secondary {
        background: white;
        color: var(--preview-primary, #2c3e50);
        border: 2px solid var(--preview-primary, #2c3e50);
        opacity: 0.85;
      }
      .preview-btn-secondary:hover { 
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 5%, white);
        opacity: 1;
        transform: translateY(-2px);
      }
      .preview-btn-secondary:active {
        transform: translateY(0);
      }
      .preview-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
        transform: none !important;
      }
      
      /* Study content styles */
      .study-heading { 
        font-size: 1.6rem; 
        font-weight: 700; 
        color: var(--preview-primary, #2c3e50);
        margin: 0 0 24px 0;
        line-height: 1.3;
        letter-spacing: -0.02em;
      }
      .study-text {
        font-size: 1.05rem;
        line-height: 1.8;
        color: var(--preview-text, #2c3e50);
        margin: 0 0 16px 0;
      }
      .study-text:last-child {
        margin-bottom: 0;
      }
      .study-text p {
        margin: 0 0 12px 0;
      }
      .study-text p:last-child {
        margin-bottom: 0;
      }
      
      /* ===== EDIT MODE: Inline editing ===== */
      body.edit-mode-active .editable-content {
        cursor: text;
        position: relative;
        transition: outline 0.15s ease, box-shadow 0.15s ease;
        border-radius: 4px;
        /* No padding/margin change — prevents layout shift when switching modes */
      }
      body.edit-mode-active .editable-content:hover {
        background: color-mix(in srgb, var(--studio-accent) 8%, white);
        outline: 2px dashed var(--studio-accent);
      }
      body.edit-mode-active .editable-content:focus {
        background: white;
        outline: 2px solid var(--studio-accent);
        box-shadow: 0 0 0 4px color-mix(in srgb, var(--studio-accent) 15%, transparent), 0 2px 6px rgba(0,0,0,0.08);
      }
      body.edit-mode-active .editable-content.editable-active::after {
        content: '✎';
        position: absolute;
        right: 4px;
        top: 4px;
        font-size: 0.7rem;
        color: var(--studio-accent);
        opacity: 0;
        transition: opacity 0.2s;
        pointer-events: none;
      }
      body.edit-mode-active .editable-content:hover::after {
        opacity: 0.7;
      }
      
      /* Colorable elements in edit mode */
      body.edit-mode-active .colorable-element {
        cursor: pointer;
        position: relative;
        transition: all 0.2s ease;
      }
      body.edit-mode-active .colorable-element:hover {
        filter: brightness(0.95);
        outline: 2px dashed var(--studio-accent);
        outline-offset: 2px;
      }
      body.edit-mode-active .colorable-element::before {
        content: attr(data-color-hint);
        position: absolute;
        top: -20px;
        left: 50%;
        transform: translateX(-50%);
        background: var(--studio-dark);
        color: white;
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 0.7rem;
        white-space: nowrap;
        opacity: 0;
        pointer-events: none;
        transition: opacity 0.2s ease;
        z-index: 100;
      }
      body.edit-mode-active .colorable-element:hover::before {
        opacity: 1;
      }
      
      /* Rich Text Editor Toolbar */
      .rich-text-toolbar {
        display: none;
        position: sticky;
        top: 0;
        background: white;
        border: 1px solid var(--studio-border);
        border-radius: 8px;
        padding: 6px 10px;
        margin-bottom: 10px;
        gap: 4px;
        flex-wrap: wrap;
        z-index: 10;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }
      body.edit-mode-active .rich-text-toolbar {
        display: flex;
      }
      .rte-btn {
        width: 32px;
        height: 32px;
        border: 1px solid var(--studio-border);
        background: white;
        border-radius: 4px;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.85rem;
        color: var(--studio-dark);
        transition: all 0.15s ease;
      }
      .rte-btn:hover {
        background: var(--studio-light);
        border-color: var(--studio-accent);
      }
      .rte-btn.active {
        background: var(--studio-accent);
        color: white;
        border-color: var(--studio-accent);
      }
      .rte-separator {
        width: 1px;
        height: 24px;
        background: var(--studio-border);
        margin: 0 6px;
      }
      
      /* Rich text content styling */
      .rich-text-content {
        min-height: 150px;
        padding: 16px;
        border: 2px solid var(--studio-border);
        border-radius: 8px;
        background: white;
        line-height: 1.7;
      }
      .rich-text-content:focus {
        border-color: var(--studio-accent);
        outline: none;
      }
      .rich-text-content h1 { font-size: 1.8rem; font-weight: 700; margin: 0 0 16px 0; }
      .rich-text-content h2 { font-size: 1.4rem; font-weight: 600; margin: 0 0 12px 0; }
      .rich-text-content h3 { font-size: 1.2rem; font-weight: 600; margin: 0 0 10px 0; }
      .rich-text-content p { margin: 0 0 12px 0; }
      .rich-text-content ul, .rich-text-content ol { margin: 0 0 12px 0; padding-left: 24px; }
      .rich-text-content li { margin-bottom: 4px; }
      .rich-text-content blockquote {
        border-left: 4px solid var(--studio-accent);
        padding-left: 16px;
        margin: 16px 0;
        color: var(--studio-gray);
        font-style: italic;
      }
      
      /* PREVIEW MODE: No interactions */
      body.preview-mode-active .editable-content {
        cursor: default;
        pointer-events: none;
      }
      body.preview-mode-active .preview-item {
        cursor: default;
      }
      body.preview-mode-active .preview-item:hover {
        border-color: var(--preview-border, #bdc3c7);
        transform: none;
      }
      body.preview-mode-active .item-actions,
      body.preview-mode-active .drag-handle,
      body.preview-mode-active .page-add-btn,
      body.preview-mode-active .page-delete-btn,
      body.preview-mode-active .edit-only-controls {
        display: none !important;
      }
      /* Studio sidebars must stay usable even in Preview mode (especially on phone).
         Preview mode only disables inline editing inside the study preview. */
      body.preview-mode-active .repo-item {
        pointer-events: auto;
        opacity: 1;
      }
      body.preview-mode-active .draggable-item {
        cursor: default !important;
      }
      body.preview-mode-active .col-right {
        opacity: 1;
        pointer-events: auto;
      }

      /* Mobile slide-in panels: ALWAYS fully usable when open (override preview mode) */
      .col-left.mobile-open,
      .col-right.mobile-open {
        opacity: 1 !important;
        pointer-events: auto !important;
        background: #ffffff !important;
        background-color: #ffffff !important;
        /* iOS/Safari: ensure the panel is composited as an opaque top layer (no tint from the dim overlay) */
        isolation: isolate;
        filter: none !important;
        z-index: 1301 !important;
      }

      /* When a mobile panel is open, keep the panel itself visually bright (no gray header/footer tint). */
      .col-left.mobile-open .sidebar-header,
      .col-left.mobile-open .sidebar-footer {
        background: #ffffff !important;
      }
      .col-left.mobile-open .sidebar-content {
        background: #ffffff !important;
      }
      .col-left.mobile-open .sidebar-footer {
        background-image: none !important;
      }
      .col-right.mobile-open .right-panel-header {
        background: #ffffff !important;
      }
      .col-right.mobile-open .right-panel-content {
        background: #ffffff !important;
      }

      /* Higher specificity override for preview mode */
      body.preview-mode-active .col-left.mobile-open,
      body.preview-mode-active .col-right.mobile-open {
        opacity: 1 !important;
        pointer-events: auto !important;
        background: #ffffff !important;
      }

      /* Preview mode normally disables repository clicks; re-enable when panel is explicitly opened on mobile */
      body.preview-mode-active .col-right.mobile-open .repo-item {
        pointer-events: auto !important;
        opacity: 1 !important;
        cursor: pointer !important;
      }
      
      /* EDIT MODE: Show controls with hint */
      body.edit-mode-active .edit-only-controls {
        display: flex !important;
      }
      body.edit-mode-active .preview-item {
        cursor: pointer;
      }
      body.edit-mode-active .preview-item:hover {
        border-color: var(--studio-accent);
        box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.15);
      }
      .study-callout {
        background: linear-gradient(135deg, color-mix(in srgb, var(--preview-primary, #2c3e50) 6%, white), color-mix(in srgb, var(--preview-primary, #2c3e50) 3%, white));
        border-left: 5px solid var(--preview-primary, #2c3e50);
        border-radius: 8px;
        padding: 20px 24px;
        margin: 28px 0;
        color: var(--preview-text, #2c3e50);
        line-height: 1.7;
        box-shadow: 0 2px 8px color-mix(in srgb, var(--preview-primary, #2c3e50) 8%, transparent);
      }
      .study-callout p {
        margin: 0;
      }
      
      /* Item question styles */
      .preview-item {
        padding: 24px;
        margin-bottom: 20px;
        border: 2px solid var(--preview-border, #e5e7eb);
        border-radius: 12px;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        background: white;
        position: relative;
        overflow: hidden;
      }
      .preview-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        height: 3px;
        background: linear-gradient(90deg, var(--preview-primary, #2c3e50), transparent);
        opacity: 0;
        transition: opacity 0.2s ease;
      }
      .preview-item:hover {
        border-color: var(--preview-primary, #2c3e50);
        box-shadow: 0 4px 16px color-mix(in srgb, var(--preview-primary, #2c3e50) 15%, transparent);
        transform: translateY(-2px);
      }
      .preview-item:hover::before {
        opacity: 1;
      }
      .preview-item.selected { 
        border-color: var(--preview-primary, #2c3e50);
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 3%, white);
        box-shadow: 0 0 0 4px color-mix(in srgb, var(--preview-primary, #2c3e50) 10%, transparent);
      }
      .preview-item.selected::before {
        opacity: 1;
      }
      
      .preview-item-question {
        font-size: 1.1rem;
        font-weight: 600;
        color: var(--preview-text, #1a1a1a);
        margin: 0 0 20px 0;
        line-height: 1.6;
        letter-spacing: -0.01em;
      }
      
      .preview-scale {
        display: flex;
        justify-content: space-between;
        gap: 10px;
        padding: 12px 0 0 0;
        margin: 0;
      }
      .preview-scale-option {
        flex: 1;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 8px;
        min-width: 50px;
      }
      .preview-scale-radio {
        width: 28px;
        height: 28px;
        border: 3px solid var(--preview-border, #e5e7eb);
        border-radius: 50%;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        background: white;
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
      }
      .preview-scale-radio::after {
        content: '';
        width: 0;
        height: 0;
        border-radius: 50%;
        background: var(--preview-primary, #2c3e50);
        transition: all 0.2s ease;
      }
      .preview-scale-radio:hover {
        border-color: var(--preview-primary, #2c3e50);
        box-shadow: 0 0 0 2px color-mix(in srgb, var(--preview-primary, #2c3e50) 12%, transparent);
        transform: scale(1.12);
      }
      .preview-scale-label {
        font-size: 0.85rem;
        color: var(--preview-gray, #6b7280);
        font-weight: 500;
        text-align: center;
        line-height: 1.3;
      }
      .preview-scale-label--hidden {
        visibility: hidden;
      }
      .preview-scale-anchors {
        display: flex;
        justify-content: space-between;
        margin-top: 12px;
        padding: 8px 4px 0 4px;
        border-top: 1px solid var(--preview-border, #e5e7eb);
        font-size: 0.75rem;
      }
      .preview-scale-anchor {
        color: var(--preview-gray, #9ca3af);
        font-style: italic;
        max-width: 80px;
        text-align: center;
        line-height: 1.3;
      }
      .preview-scale-vertical {
        display: flex;
        flex-direction: column;
        gap: 8px;
        margin-top: 8px;
      }
      .preview-scale-vertical-option {
        display: flex;
        align-items: center;
        gap: 10px;
        padding: 8px 10px;
        border-radius: 8px;
        border: 1px solid var(--preview-border, #e5e7eb);
        background: color-mix(in srgb, var(--preview-bg, #ffffff) 94%, var(--preview-primary, #2c3e50));
      }
      
      /* Demographics form styles - PROFESSIONAL */
      .demo-field-preview {
        margin-bottom: 28px;
        animation: slideIn 0.3s ease;
      }
      @keyframes slideIn {
        from {
          opacity: 0;
          transform: translateY(-8px);
        }
        to {
          opacity: 1;
          transform: translateY(0);
        }
      }
      .demo-field-editable {
        padding: 16px;
        border: 2px solid var(--preview-border, #e5e7eb) !important;
        border-radius: 10px !important;
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 2%, white) !important;
        transition: all 0.2s ease;
      }
      .demo-field-editable:hover {
        border-color: var(--preview-primary, #2c3e50) !important;
        box-shadow: 0 0 0 3px color-mix(in srgb, var(--preview-primary, #2c3e50) 8%, transparent) !important;
      }
      .demo-label-preview {
        display: block;
        font-weight: 600;
        color: var(--preview-text, #2c3e50);
        margin-bottom: 12px;
        font-size: 0.95rem;
        letter-spacing: -0.01em;
      }
      .demo-label-preview .required {
        color: var(--studio-danger, #e74c3c);
        font-weight: 700;
      }
      .demo-input-preview {
        width: 100%;
        padding: 12px 16px;
        border: 2px solid var(--preview-border, #e5e7eb);
        border-radius: 8px;
        font-size: 1rem;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        background: white;
        color: var(--preview-text, #2c3e50);
        font-family: inherit;
      }
      .demo-input-preview::placeholder {
        color: var(--preview-gray, #9ca3af);
      }
      .demo-input-preview:hover {
        border-color: var(--preview-gray, #d1d5db);
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
      }
      .demo-input-preview:focus {
        outline: none;
        border-color: var(--preview-primary, #2c3e50);
        box-shadow: 0 0 0 4px color-mix(in srgb, var(--preview-primary, #2c3e50) 12%, transparent), 0 4px 12px rgba(0,0,0,0.08);
        transform: translateY(-1px);
      }
      .demo-input-preview:disabled {
        background: var(--preview-light, #f5f7fa);
        color: var(--preview-gray, #9ca3af);
        cursor: not-allowed;
      }
      
      /* Results preview - PROFESSIONAL ACADEMIC STYLE */
      .results-preview-container {
        padding: 0;
        animation: fadeIn 0.4s ease;
      }
      @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
      }
      .results-chart-placeholder {
        background: linear-gradient(135deg, var(--preview-light, #f5f7fa) 0%, color-mix(in srgb, var(--preview-light, #f5f7fa) 50%, white) 100%);
        border: 2px dashed var(--preview-border, #d1d5db);
        border-radius: 16px;
        padding: 80px 60px;
        margin: 40px 0;
        text-align: center;
        color: var(--preview-gray, #9ca3af);
      }
      .results-icon {
        font-size: 3.5rem;
        opacity: 0.3;
        margin-bottom: 16px;
      }
      .results-chart-title {
        font-size: 1.2rem;
        font-weight: 600;
        color: var(--preview-text, #2c3e50);
        margin-bottom: 8px;
      }
      .results-table-wrapper {
        margin: 40px 0;
        overflow-x: auto;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.08);
      }
      .results-table {
        width: 100%;
        border-collapse: collapse;
        font-size: 0.95rem;
      }
      .results-table thead {
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 8%, white);
        border-bottom: 3px solid var(--preview-primary, #2c3e50);
      }
      .results-table th {
        padding: 16px 20px;
        text-align: left;
        font-weight: 700;
        color: var(--preview-primary, #2c3e50);
        letter-spacing: 0.5px;
        font-size: 0.9rem;
      }
      .results-table tbody tr {
        border-bottom: 1px solid var(--preview-border, #e5e7eb);
        transition: background 0.2s ease;
      }
      .results-table tbody tr:hover {
        background: color-mix(in srgb, var(--preview-primary, #2c3e50) 3%, white);
      }
      .results-table tbody tr:last-child {
        border-bottom: none;
      }
      .results-table td {
        padding: 14px 20px;
        color: var(--preview-text, #2c3e50);
      }
      .results-table td:first-child {
        font-weight: 600;
        color: var(--preview-primary, #2c3e50);
      }
      .results-table .numeric {
        font-family: 'SF Mono', 'Courier New', monospace;
        text-align: right;
        color: var(--preview-gray, #6b7280);
        font-size: 0.9rem;
      }
      
      /* ===== RIGHT SIDEBAR ===== */
      .right-panel-header {
        padding: 16px 20px;
        border-bottom: 1px solid var(--studio-border);
        background: var(--studio-light);
      }
      .right-panel-header h6 { margin: 0; font-weight: 700; display: flex; align-items: center; gap: 8px; }
      
      .right-panel-content {
        flex: 1;
        overflow-y: auto;
        padding: 16px;
      }
      
      /* Item repository cards */
      .repo-item {
        background: white;
        border: 2px solid var(--studio-border);
        border-radius: 12px;
        padding: 16px;
        margin-bottom: 12px;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        position: relative;
        overflow: hidden;
      }
      .repo-item::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(52,152,219,0.05), transparent);
        transition: left 0.4s ease;
      }
      .repo-item:hover::before {
        left: 100%;
      }
      .repo-item:hover {
        border-color: var(--studio-accent);
        transform: translateX(4px);
        box-shadow: -4px 0 0 var(--studio-accent), 0 4px 12px rgba(52,152,219,0.15);
      }
      .repo-item:active {
        transform: translateX(2px);
      }
      .repo-item-id {
        font-weight: 700;
        font-size: 0.75rem;
        color: var(--studio-accent);
        margin-bottom: 4px;
        font-family: 'SF Mono', 'Consolas', monospace;
      }
      .repo-item-text { 
        color: var(--studio-gray); 
        font-size: 0.8rem; 
        line-height: 1.4;
      }
      
      /* ===== UTILITY CLASSES ===== */
      .b1{}.b2{}.b3{}.b4{} /* CSS structure balance */
      .btn-studio {
        padding: 10px 18px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 0.875rem;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        border: none;
        cursor: pointer;
        white-space: nowrap;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
      }
      
      /* Balance CSS structure: { */
      .btn-studio-primary {
        background: #ecf0f1;
        color: #2c3e50;
        border: 1px solid #bdc3c7;
        box-shadow: none;
      }
      .btn-studio-primary:hover { 
        background: #d5d8dc;
        border-color: #95a5a6;
        transform: translateY(-1px);
      }
      .btn-studio-primary:active {
        background: #bdc3c7;
        transform: translateY(0);
      }
      .btn-studio-outline {
        background: white;
        border: 2px solid var(--studio-border);
        color: var(--studio-dark);
      }
      .btn-studio-outline:hover { 
        background: var(--studio-light); 
        border-color: var(--studio-gray);
        transform: translateY(-1px);
      }
      .btn-studio-outline:active {
        transform: translateY(0);
      }
      @media (max-width: 480px) {
        .btn-studio {
          font-size: 0.8rem;
          padding: 8px 14px;
        }
      }
      
      /* Modal responsiveness */
      @media (max-width: 768px) {
        .modal-xl {
          max-width: 95% !important;
          margin: 1rem auto;
        }
        .modal-dialog {
          margin: 0.5rem;
        }
        .modal-body pre {
          font-size: 0.7rem !important;
          padding: 16px !important;
          line-height: 1.4 !important;
        }
        .modal-footer {
          flex-direction: column;
          gap: 8px;
        }
        .modal-footer > * {
          width: 100% !important;
        }
      }
      @media (max-width: 480px) {
        .modal-xl {
          max-width: 100% !important;
          margin: 0;
          height: 100vh;
        }
        .modal-content {
          border-radius: 0;
          height: 100vh;
        }
      }
      
      /* Form controls in sidebar */
      .form-control, .form-select {
        border-radius: 8px;
        border: 2px solid var(--studio-border);
        padding: 10px 14px;
        font-size: 0.9rem;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
      }
      .form-control:hover, .form-select:hover {
        border-color: var(--studio-gray);
      }
      .form-control:focus, .form-select:focus {
        border-color: var(--studio-accent);
        box-shadow: 0 0 0 4px rgba(52,152,219,0.12);
        outline: none;
        transform: translateY(-1px);
      }
      .form-label { 
        font-size: 0.875rem; 
        font-weight: 600; 
        color: var(--studio-dark); 
        margin-bottom: 8px;
        display: flex;
        align-items: center;
        gap: 6px;
      }
      
      .btn-xs { padding: 4px 8px; font-size: 0.75rem; border-radius: 4px; }
      
      /* ===== COMPACT FILE INPUT STYLING ===== */
      .form-group .shiny-input-container { margin-bottom: 0; }
      .btn-file { padding: 4px 8px; font-size: 0.75rem; }
      
      /* Hide the ugly text input from fileInput */
      .shiny-input-container:not(.shiny-input-container-inline) .input-group .form-control[type='text'] {
        display: none !important;
      }
      /* Style the file input button container */
      .shiny-input-container .input-group {
        flex-wrap: nowrap;
      }
      .shiny-input-container .input-group .input-group-btn,
      .shiny-input-container .input-group .btn-file {
        width: auto !important;
        border-radius: 6px !important;
      }
      /* Compact file button in right sidebar */
      .right-panel-header .shiny-input-container {
        width: auto !important;
        display: inline-flex !important;
      }
      .right-panel-header .input-group {
        width: auto !important;
      }
      .right-panel-header .btn-file {
        padding: 4px 10px;
        font-size: 0.7rem;
        background: #f8f9fa;
        border: 1px solid #dee2e6;
        color: #495057;
        border-radius: 4px !important;
        white-space: nowrap;
      }
      .right-panel-header .btn-file:hover {
        background: #e9ecef;
        border-color: #ced4da;
      }
      /* Sidebar footer file input */
      .sidebar-footer .shiny-input-container {
        flex: 1;
        min-width: 0;
      }
      .sidebar-footer .input-group {
        flex-wrap: nowrap;
      }
      .sidebar-footer .btn-file {
        padding: 6px 12px;
        font-size: 0.8rem;
        border-radius: 6px !important;
        background: var(--studio-accent);
        color: white;
        border: none;
      }
      .sidebar-footer .btn-file:hover {
        background: #2980b9;
      }
      
      /* ===== STUDIO HINT TOAST (bottom-right) ===== */
      #studio-hint-toast {
        position: fixed;
        bottom: 16px;
        right: 16px;
        z-index: 9999;
        background: rgba(30,41,59,0.93);
        color: white;
        padding: 10px 16px;
        border-radius: 10px;
        font-size: 0.82rem;
        display: flex;
        align-items: center;
        gap: 8px;
        opacity: 0;
        transition: opacity 0.25s ease;
        pointer-events: none;
        font-family: 'Inter', system-ui, sans-serif;
        box-shadow: 0 4px 16px rgba(0,0,0,0.18);
        max-width: 260px;
        line-height: 1.4;
      }

      /* ===== DRAG AND DROP SYSTEM ===== */
      .draggable-item {
        cursor: grab;
        user-select: none;
        transition: transform 0.15s ease, box-shadow 0.15s ease, opacity 0.15s ease;
      }
      .draggable-item:active { cursor: grabbing; }
      .draggable-item.dragging {
        opacity: 0.7;
        transform: scale(1.02) rotate(1deg);
        box-shadow: 0 8px 25px rgba(0,0,0,0.2);
        z-index: 1000;
      }
      .draggable-item.drag-over {
        border-color: var(--studio-accent) !important;
        background: rgba(52, 152, 219, 0.1) !important;
      }
      
      .drop-zone {
        transition: all 0.2s ease;
        min-height: 60px;
      }
      .drop-zone.drag-active {
        border: 2px dashed var(--studio-accent);
        background: rgba(52, 152, 219, 0.05);
        border-radius: 8px;
      }
      .drop-zone.drag-over {
        border-color: var(--studio-success);
        background: rgba(39, 174, 96, 0.1);
      }
      
      .drop-placeholder {
        height: 60px;
        border: 2px dashed var(--studio-accent);
        border-radius: 8px;
        margin: 8px 0;
        display: flex;
        align-items: center;
        justify-content: center;
        color: var(--studio-gray);
        font-size: 0.85rem;
        background: rgba(52, 152, 219, 0.05);
      }
      
      /* Sortable list styles */
      .sortable-ghost {
        opacity: 0.4;
        background: var(--studio-light);
      }
      .sortable-chosen {
        box-shadow: 0 8px 25px rgba(0,0,0,0.15);
      }
      .sortable-drag {
        opacity: 0;
      }
      
      /* Item handle for dragging */
      .drag-handle {
        cursor: grab;
        padding: 4px 8px;
        color: var(--studio-gray);
        opacity: 0.5;
        transition: opacity 0.15s ease;
      }
      .drag-handle:hover { opacity: 1; }
      .drag-handle:active { cursor: grabbing; }
      
      /* Preview item in edit mode - enhanced */
      .preview-item-editable {
        position: relative;
        cursor: pointer;
      }
      .preview-item-editable::before {
        content: '';
        position: absolute;
        top: -2px;
        left: -2px;
        right: -2px;
        bottom: -2px;
        border: 2px dashed transparent;
        border-radius: 12px;
        pointer-events: none;
        transition: border-color 0.2s ease;
      }
      .preview-item-editable:hover::before {
        border-color: var(--studio-accent);
      }
      
      .item-actions {
        position: absolute;
        top: 8px;
        right: 8px;
        display: flex;
        gap: 4px;
        opacity: 0;
        transition: opacity 0.2s ease;
      }
      .preview-item-editable:hover .item-actions {
        opacity: 1;
      }
      .item-action-btn {
        width: 28px;
        height: 28px;
        border-radius: 6px;
        border: 1px solid var(--preview-border, #e5e7eb);
        background: rgba(255,255,255,0.97);
        box-shadow: 0 2px 6px rgba(0,0,0,0.1);
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 0.8rem;
        color: var(--preview-text, #374151);
        transition: all 0.15s ease;
      }
      .item-action-btn svg {
        color: inherit;
        fill: currentColor;
      }
      .item-action-btn:hover {
        background: var(--studio-primary);
        color: white;
      }
      .item-action-btn.edit-btn:hover {
        background: var(--studio-accent);
      }
      .item-action-btn.delete:hover {
        background: var(--studio-danger);
      }
      .item-action-btn.move-up:hover,
      .item-action-btn.move-down:hover {
        background: var(--studio-accent);
      }
      
      /* Modal Enhancements */
      .modal-script-container {
        height: min(70vh, 600px);
        max-height: 80vh;
        overflow-y: auto;
        margin: -12px;
        border-radius: 8px;
        background: #1e293b;
      }
      .modal-script-code {
        background: #1e293b;
        color: #e2e8f0;
        padding: 24px;
        margin: 0;
        font-family: 'SF Mono', 'Consolas', 'Courier New', monospace;
        font-size: 0.85rem;
        line-height: 1.7;
        white-space: pre-wrap;
        word-break: break-word;
        border-radius: 8px;
      }
      @media (max-width: 768px) {
        .modal-dialog { max-width: 95vw !important; margin: 10px auto; }
        .modal-script-container { height: 60vh; max-height: 60vh; }
        .modal-script-code { padding: 16px; font-size: 0.75rem; line-height: 1.6; }
        .modal-footer { flex-wrap: wrap; gap: 8px !important; }
        .modal-footer button { flex: 1 1 auto; min-width: 120px; }
      }
      
      /* Mobile Toggle Buttons */
      .mobile-toggle, .mobile-properties-toggle {
        display: none;
        position: fixed;
        z-index: 1400;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--studio-primary) 0%, var(--studio-accent) 100%);
        color: white;
        border: none;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
        font-size: 1.05rem;
        bottom: 20px;
        transform: translateZ(0); /* GPU acceleration */
        will-change: transform, box-shadow;
        backface-visibility: hidden;
      }
      .mobile-toggle { left: 20px; }
      .mobile-properties-toggle { right: 20px; }

      /* Mobile/tablet layouts: ALWAYS show BOTH toggles (single orchestrated breakpoint) */
      @media (max-width: 1200px) {
        .mobile-toggle, .mobile-properties-toggle {
          display: flex !important;
        }
      }
      @media (max-width: 480px) {
        .mobile-toggle { left: 12px; bottom: 12px; }
        .mobile-properties-toggle { right: 12px; bottom: 12px; }
      }
      .mobile-toggle:hover, .mobile-properties-toggle:hover {
        transform: scale(1.08) translateZ(0);
        box-shadow: 0 6px 16px rgba(0,0,0,0.3);
      }
      .mobile-toggle:active, .mobile-properties-toggle:active {
        transform: scale(0.96) translateZ(0);
        transition-duration: 0.1s;
      }
      
      /* Mobile Overlay */
      .mobile-overlay {
        display: none;
        position: fixed;
        inset: 0;
        /* Keep this transparent; dimming is applied to the preview area only (see body.mobile-panel-open rules). */
        background: rgba(0,0,0,0);
        z-index: 1200;
        opacity: 0;
        transition: opacity 0.25s ease;
        pointer-events: none;
      }
      .mobile-overlay.active {
        display: block;
        opacity: 1;
        pointer-events: none;
      }

      /* Desktop and large screens: never show mobile overlay */
      @media (min-width: 1201px) {
        .mobile-overlay {
          display: none !important;
          opacity: 0 !important;
        }
        .mobile-toggle, .mobile-properties-toggle {
          display: none !important;
        }
      }

      /* Prevent background scroll when a mobile panel is open.
         position:fixed locks body in place. Do NOT use overflow:hidden
         as it blocks panel scrolling on iOS Safari. */
      body.mobile-panel-open {
        position: fixed;
        width: 100%;
      }

      /* Mobile/tablet: when a panel is open, dim ONLY the preview/background area.
         The open panel itself must remain fully bright. */
      @media (max-width: 1200px) {
        body.mobile-panel-open .col-center {
          position: relative;
          pointer-events: none;
        }
        body.mobile-panel-open .col-center::after {
          content: '';
          position: absolute;
          inset: 0;
          background: rgba(0,0,0,0.35);
          z-index: 50;
          pointer-events: none;
        }
      }
      
      /* Resizable panels */
      .resize-handle {
        position: absolute;
        background: transparent;
        z-index: 100;
        transition: background 0.2s ease;
      }
      .resize-handle:hover {
        background: var(--studio-accent);
      }
      .resize-handle-h {
        width: 6px;
        height: 100%;
        top: 0;
        cursor: col-resize;
      }
      .resize-handle-v {
        height: 6px;
        width: 100%;
        left: 0;
        cursor: row-resize;
      }
      @media (min-width: 1201px) {
        .col-left { position: relative; }
        .col-right { position: relative; }
      }
      .col-left .resize-handle { right: -3px; }
      .col-right .resize-handle { left: -3px; }
      
      /* Repository item - draggable */
      .repo-item.draggable-item {
        position: relative;
      }
      .repo-item .drag-handle {
        position: absolute;
        left: 4px;
        top: 50%;
        transform: translateY(-50%);
      }
      
      /* Page navigation - sortable */
      .page-nav-item.sortable-item {
        position: relative;
      }
      
      /* Smooth animations */
      @keyframes pulse-border {
        0%, 100% { border-color: var(--studio-accent); }
        50% { border-color: var(--studio-success); }
      }
      .drop-zone.drag-active {
        animation: pulse-border 1.5s ease infinite;
      }

      /* ── Onboarding hint widget (inside preview-toolbar-right, shifts with col-center) ── */
      .ob-hint-widget {
        display: flex; align-items: center; gap: 7px;
        background: var(--studio-dark); color: #fff;
        padding: 5px 12px 5px 10px; border-radius: 22px;
        font: 500 12px/1 'Inter', system-ui, sans-serif;
        cursor: pointer;
        box-shadow: 0 2px 10px rgba(44,62,80,0.20);
        transition: max-width 0.38s cubic-bezier(0.4,0,0.2,1),
                    padding 0.38s cubic-bezier(0.4,0,0.2,1),
                    box-shadow 0.2s ease;
        white-space: nowrap; max-width: 160px; overflow: hidden;
        border: none; text-decoration: none;
        animation: ob-hint-slide-in 0.45s cubic-bezier(0.4,0,0.2,1) forwards,
                   ob-hint-attention 1.6s ease-in-out 0.7s 3;
      }
      .ob-hint-widget:hover { background: #1a252f; box-shadow: 0 4px 16px rgba(44,62,80,0.28); }
      .ob-hint-widget.minimized { max-width: 34px; padding: 5px 9px; }
      .ob-hint-label {
        overflow: hidden; transition: max-width 0.38s ease, opacity 0.3s ease;
        max-width: 100px; opacity: 1; display: inline-block;
      }
      .ob-hint-widget.minimized .ob-hint-label { max-width: 0; opacity: 0; }
      @keyframes ob-hint-slide-in {
        from { opacity: 0; transform: translateX(12px); }
        to   { opacity: 1; transform: translateX(0); }
      }
      @keyframes ob-hint-attention {
        0%, 100% { box-shadow: 0 2px 10px rgba(44,62,80,0.20); }
        50% { box-shadow: 0 2px 22px rgba(124,58,237,0.55), 0 0 0 5px rgba(124,58,237,0.14); }
      }
      /* ── Preview language switch ── */
      .preview-toolbar-right { display: flex; align-items: center; gap: 8px; }
      .lang-switch-btn {
        display: inline-flex; align-items: center; gap: 5px;
        height: 28px; padding: 0 10px; border-radius: 14px;
        font: 600 11px/1 'Inter', system-ui, sans-serif; letter-spacing: .4px;
        cursor: pointer; border: 1.5px solid; transition: opacity 0.15s, box-shadow 0.15s;
        background: transparent; white-space: nowrap;
      }
      .lang-switch-btn:hover { opacity: 0.82; box-shadow: 0 2px 8px rgba(0,0,0,0.12); }
      .lang-switch-placeholder {
        display: inline-flex; align-items: center; gap: 5px;
        height: 28px; padding: 0 10px; border-radius: 14px;
        font: 500 11px/1 'Inter', system-ui, sans-serif; letter-spacing: .3px;
        color: var(--studio-gray); border: 1.5px dashed var(--studio-border);
        background: transparent; white-space: nowrap; cursor: default; opacity: 0.6;
      }
    "))
  ),
  
  # ── shiny.router: route "/" = studio (main app), route "onboarding" = wizard ─
  router_ui(
    route("/", tagList(
      div(id = "studio-main", class = "main-container",
          # ===== LEFT SIDEBAR =====
          div(class = "col-left",
              div(class = "sidebar-header",
                  div(class = "d-flex align-items-center gap-3",
                      # Custom logo SVG (isometric blocks with violet-purple active tile + analytics bars)
                      tags$div(style = "flex-shrink:0; width:90px; height:90px;",
                               HTML('<svg viewBox="-60 -50 140 120" xmlns="http://www.w3.org/2000/svg" shape-rendering="geometricPrecision" style="width:90px;height:90px;">
  <defs>
    <linearGradient id="activeViolet" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#A78BFA" />
      <stop offset="100%" stop-color="#7C3AED" />
    </linearGradient>
    <filter id="glow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="0.4" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <g stroke="#1F2937" stroke-linejoin="round" stroke-linecap="round" stroke-width="1.0">
    <g transform="translate(-18, -10)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
    </g>
    <g transform="translate(18, -10)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
      <g transform="translate(22, 5)" stroke="#60A5FA" stroke-width="0.8" filter="url(#glow)">
        <line x1="1" y1="12" x2="1" y2="8" />
        <line x1="4" y1="12" x2="4" y2="2" />
        <line x1="7" y1="12" x2="7" y2="6" />
        <line x1="10" y1="12" x2="10" y2="3" />
      </g>
    </g>
    <g transform="translate(0, 0)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="#4B5563"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#374151"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#1F2937"/>
      <g transform="translate(18, 8)" fill="none" filter="url(#glow)">
        <path d="M2 10 L5 2 L8 12" stroke="#94A3B8" stroke-width="0.6" opacity="0.4" />
        <path d="M8 12 L9 8 L10 11 L11 7 L12 9 L13 6 L14 8 L15 5" stroke="#BAE6FD" stroke-width="0.7" />
        <circle cx="15" cy="5" r="0.7" fill="#BAE6FD" stroke="none" />
      </g>
    </g>
    <g transform="translate(-36, 0)">
      <path d="M0 0 L18 -10 L36 0 L18 10 Z" fill="url(#activeViolet)"/>
      <path d="M0 0 v18 L18 28 v-18 Z" fill="#7C3AED"/>
      <path d="M18 10 v18 L36 18 v-18 Z" fill="#5B21B6"/>
    </g>
  </g>
</svg>')
                      ),
                      div(
                        h4(style = "margin: 0; line-height: 1.1;",
                           span("inrep", style = "text-transform: lowercase; font-weight: 800; color: var(--studio-dark);"),
                           span(" Studio", style = "font-weight: 400; color: var(--studio-gray);")
                        ),
                        tags$small(style = "color: var(--studio-gray); font-size: 0.7rem;", "inrep Study Configurator"),
                        div(
                          class = "d-flex align-items-center gap-3",
                          style = "margin-top: 4px; font-size: 0.75rem;",
                          tags$a(
                            href = "https://github.com/selvastics/inrep",
                            target = "_blank",
                            rel = "noopener noreferrer",
                            style = "color: var(--studio-gray); text-decoration: none;",
                            title = "Open inrep on GitHub",
                            bs_icon("github", class = "me-1"),
                            "GitHub"
                          ),
                          tags$a(
                            href = "https://www.researchgate.net/profile/Clievins-Selva/research",
                            target = "_blank",
                            rel = "noopener noreferrer",
                            style = "color: var(--studio-gray); text-decoration: none;",
                            title = "Open research profile",
                            bs_icon("journal-text", class = "me-1"),
                            "Research"
                          )
                        )
                      )
                  )
              ),
              div(class = "sidebar-content",
                  accordion(
                    open = FALSE, # closes the tap at first glance
                    accordion_panel("Study Configuration", value = "config",
                                    textInput("study_name", "Study Name", value = "My Assessment Study"),
                                    textInput("study_id", "Study ID", value = paste0("study_", format(Sys.Date(), "%Y%m%d"))),
                                    selectInput("primary_lang", "Primary Language", c("English" = "en", "German" = "de", "Spanish" = "es", "French" = "fr"), "en"),
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-bottom: 5px;",
                                        tags$label("Visual Theme", style = "margin: 0; font-weight: 500;"),
                                        tags$span(
                                          bs_icon("palette", class = "text-muted", style = "font-size: 0.9em;"),
                                          style = "cursor: help;",
                                          title = "Includes accessibility options (high-contrast, dyslexia-friendly, colorblind-safe). All themes are mobile-responsive."
                                        )
                                    ),
                                    selectInput("theme", NULL, 
                                                c(
                                                  "--- Built-in ---" = "hildesheim",
                                                  "Hildesheim" = "hildesheim",
                                                  "Professional" = "Professional",
                                                  "Berry" = "Berry",
                                                  "Forest" = "Forest",
                                                  "Light" = "Light",
                                                  "Midnight" = "Midnight",
                                                  "Monochrome" = "monochrome",
                                                  "Ocean" = "Ocean",
                                                  "Paper" = "paper",
                                                  "Sepia" = "sepia",
                                                  "Sunset" = "Sunset",
                                                  "Vibrant" = "vibrant",
                                                  "InRep" = "inrep",
                                                  "--- Accessibility ---" = "accessible-blue",
                                                  "Accessible Blue" = "accessible-blue",
                                                  "Colorblind Safe" = "colorblind-safe",
                                                  "Dark Blue" = "darkblue",
                                                  "Dark Mode" = "dark-mode",
                                                  "Dyslexia Friendly" = "dyslexia-friendly",
                                                  "High Contrast" = "high-contrast",
                                                  "Large Text" = "large-text",
                                                  "--- Brand / Developer ---" = "cal",
                                                  "Cal" = "cal",
                                                  "Claude" = "claude",
                                                  "Cohere" = "cohere",
                                                  "Cursor" = "cursor",
                                                  "ElevenLabs" = "elevenlabs",
                                                  "Expo" = "expo",
                                                  "Intercom" = "intercom",
                                                  "Linear" = "linear",
                                                  "Lovable" = "lovable",
                                                  "Minimax" = "minimax",
                                                  "Mistral" = "mistral",
                                                  "Notion" = "notion",
                                                  "Ollama" = "ollama",
                                                  "OpenCode" = "opencode",
                                                  "Raycast" = "raycast",
                                                  "Replicate" = "replicate",
                                                  "RunwayML" = "runwayml",
                                                  "Stripe" = "stripe",
                                                  "Superhuman" = "superhuman",
                                                  "Together AI" = "together",
                                                  "Vercel" = "vercel",
                                                  "VoltAgent" = "voltagent",
                                                  "Warp" = "warp",
                                                  "xAI" = "xai"
                                                ),
                                                selected = "hildesheim"),
                                    hr(),
                                    # Custom color overrides — hidden by default, collapsed like Adaptive Testing
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-bottom: 4px;",
                                        h6("Custom Color Overrides", class = "text-muted small mb-0", style = "margin: 0;"),
                                        tags$span(
                                          bs_icon("brush", class = "text-muted", style = "font-size: 0.8em;"),
                                          style = "cursor: help;",
                                          title = "Override the theme colors for your institution's branding. Always reflects the currently selected theme."
                                        )
                                    ),
                                    checkboxInput("show_color_overrides", "Customize colors", FALSE),
                                    conditionalPanel("input.show_color_overrides == true",
                                                     div(id = "color-overrides-container",
                                                         div(class = "d-flex gap-2 mb-2",
                                                             colourpicker::colourInput("primary_color_override", "Primary", value = "#e8041c", showColour = "background", allowTransparent = FALSE),
                                                             actionButton("reset_primary_color", "Reset", class = "btn-sm")
                                                         ),
                                                         div(class = "d-flex gap-2 mb-2",
                                                             colourpicker::colourInput("accent_color_override", "Accent", value = "#e8041c", showColour = "background", allowTransparent = FALSE),
                                                             actionButton("reset_accent_color", "Reset", class = "btn-sm")
                                                         ),
                                                         div(class = "d-flex gap-2 mb-2",
                                                             colourpicker::colourInput("text_color_override", "Text", value = "#2C2C2C", showColour = "background", allowTransparent = FALSE),
                                                             actionButton("reset_text_color", "Reset", class = "btn-sm")
                                                         ),
                                                         uiOutput("element_color_ui"),
                                                         actionButton("apply_colors_all_pages", "Apply to All Pages", class = "btn-primary w-100 mt-2"),
                                                         actionButton("reset_all_colors", "Reset to Theme", class = "btn-outline-secondary w-100 mt-1")
                                                     )
                                    )
                    ),
                    accordion_panel("Data Storage",
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-bottom: 8px;",
                                        tags$label("Storage Backend", style = "margin: 0; font-weight: 500;"),
                                        tags$span(
                                          bs_icon("info-circle", class = "text-muted"),
                                          style = "cursor: help;",
                                          title = "Choose where survey data is saved: WebDAV (cloud) or Local (your computer)."
                                        )
                                    ),
                                    selectInput("storage_backend", NULL, 
                                                c("Local Files" = "local", "WebDAV Cloud" = "webdav"), "local"),
                                    conditionalPanel("input.storage_backend == 'webdav'",
                                                     div(class = "alert alert-info small", style = "margin: 10px 0; padding: 10px;",
                                                         tags$strong(bs_icon("cloud-upload"), " WebDAV Cloud Storage"),
                                                         tags$p(style = "margin: 8px 0 4px 0;",
                                                                "Example: Academic Cloud (sync.academiccloud.de). ",
                                                                "Your institution may offer similar WebDAV services through Nextcloud, ownCloud, or research data repositories."
                                                         ),
                                                         tags$p(class = "text-muted", style = "margin: 4px 0 0 0; font-size: 0.85em;",
                                                                "Ask your IT department: 'Do you provide WebDAV storage for research data?'"
                                                         )
                                                     ),
                                                     div(style = "display: flex; align-items: center; gap: 8px;",
                                                         tags$label("WebDAV URL", style = "margin: 0;"),
                                                         tags$span(
                                                           bs_icon("question-circle", class = "text-muted", style = "font-size: 0.9em;"),
                                                           style = "cursor: help;",
                                                           title = "Example: https://sync.academiccloud.de/index.php/s/YourFolder/ - Your WebDAV endpoint URL."
                                                         )
                                                     ),
                                                     textInput("webdav_url", NULL, value = "", placeholder = "https://sync.academiccloud.de/..."),
                                                     textInput("webdav_username", "Username/Token", value = "", placeholder = "Share token or username"),
                                                     passwordInput("webdav_password", "Password", value = "", placeholder = "Access password")
                                    ),
                                    conditionalPanel("input.storage_backend == 'local'",
                                                     div(class = "alert alert-secondary small", style = "margin: 10px 0; padding: 10px;",
                                                         tags$strong(bs_icon("folder"), " Local File Storage"),
                                                         tags$p(style = "margin: 8px 0 0 0;",
                                                                "Saves to your computer. Good for testing. Use cloud storage for production to prevent data loss."
                                                         )
                                                     ),
                                                     textInput("local_save_path", "Save Directory", value = "./data/"),
                                                     selectInput("local_format", "Format", c("CSV" = "csv", "RDS" = "rds", "JSON" = "json"), "csv")
                                    )
                    ),
                    accordion_panel("Advanced",
                                    # ── Adaptive Testing (CAT) ──────────────────────
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-bottom: 4px;",
                                        h6("Adaptive Testing (CAT)", class = "text-muted small mb-0", style = "margin: 0;"),
                                        tags$span(
                                          bs_icon("question-circle", class = "text-info", style = "font-size: 0.9em;"),
                                          style = "cursor: help;",
                                          title = paste0("Computerised Adaptive Testing: items are selected dynamically based on the participant's ability estimate. ",
                                                         "Reaches the same precision as fixed tests with ~50% fewer items. Requires item IRT parameters (a, b) in the item bank. ",
                                                         "Uses the TAM package for ability estimation.")
                                        )
                                    ),
                                    checkboxInput("adaptive", "Enable Adaptive Testing", FALSE),
                                    conditionalPanel("input.adaptive == true",
                                                     div(class = "alert alert-info small py-2 px-3 mb-2",
                                                         bs_icon("info-circle"), " ",
                                                         "Set basic parameters here. Tune item-level IRT params in the ",
                                                         tags$strong("Properties panel"), " (right side) after selecting an item."
                                                     ),
                                                     div(style = "display: flex; align-items: center; gap: 8px;",
                                                         tags$label("IRT Model", style = "margin: 0;"),
                                                         tags$span(
                                                           bs_icon("graph-up", class = "text-success", style = "font-size: 0.9em;"),
                                                           style = "cursor: help;",
                                                           title = "1PL/Rasch: all items equal discrimination. 2PL: varying discrimination. 3PL: includes guessing (cognitive tests). GRM: polytomous Likert scales."
                                                         )
                                                     ),
                                                     selectInput("irt_model", NULL, 
                                                                 c("1PL (Rasch)" = "1PL", 
                                                                   "2PL (Two-Parameter)" = "2PL", 
                                                                   "3PL (Three-Parameter, with guessing)" = "3PL", 
                                                                   "GRM (Graded Response, Likert)" = "GRM"), "GRM"),
                                                     selectInput("estimation_method", "Ability Estimation",
                                                                 c("EAP (Expected A Posteriori)" = "EAP",
                                                                   "WLE (Weighted Likelihood)" = "WLE"), "EAP"),
                                                     selectInput("item_selection_criteria", "Item Selection Strategy",
                                                                 c("MI — Maximum Information" = "MI",
                                                                   "MFI — Maximum Fisher Information" = "MFI",
                                                                   "WEIGHTED — Content-Balanced" = "WEIGHTED",
                                                                   "RANDOM — Random (baseline)" = "RANDOM"), "MI"),
                                                     div(class = "row g-2",
                                                         div(class = "col-6",
                                                             numericInput("min_items", "Min Items", value = 5, min = 1, max = 100)
                                                         ),
                                                         div(class = "col-6",
                                                             numericInput("cat_se_threshold", "Stop SEM ≤", value = 0.3, step = 0.05, min = 0.1, max = 1.0)
                                                         )
                                                     ),
                                                     p(class = "small text-muted mt-n2", "Administer at least Min Items, then stop when SE of ability estimate ≤ Stop SEM.")
                                    ),
                                    conditionalPanel("input.adaptive == false",
                                                     numericInput("min_items_nonadaptive", "Min Items to Show", value = 5, min = 0, max = 100),
                                                     p(class = "small text-muted mt-n2", "Fixed questionnaire: items are shown in order from first to Max Items.")
                                    ),
                                    numericInput("max_items", "Max Items (0 = all)", value = 0, min = 0, max = 500),
                                    hr(),
                                    # ── Study Flow ────────────────────────────────────
                                    h6("Study Flow", class = "text-muted small"),
                                    checkboxInput("show_introduction", "Introduction Page", TRUE),
                                    checkboxInput("show_briefing", "Briefing Page", TRUE),
                                    checkboxInput("show_consent", "Consent Form", TRUE),
                                    checkboxInput("show_gdpr_compliance", "GDPR/DSGVO Page", TRUE),
                                    checkboxInput("show_debriefing", "Debriefing Page", TRUE),
                                    checkboxInput("enable_back_navigation", "Allow Back Navigation", TRUE),
                                    hr(),
                                    # ── Response & Progress ───────────────────────────
                                    h6("Response & Progress", class = "text-muted small"),
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-bottom: 5px;",
                                        tags$label("Response Input Type", style = "margin: 0; font-weight: 500; font-size: 0.9em;"),
                                        tags$span(
                                          bs_icon("ui-checks", class = "text-muted", style = "font-size: 0.85em;"),
                                          style = "cursor: help;",
                                          title = "Radio: Buttons. Slider: Visual scale. Dropdown: Compact list."
                                        )
                                    ),
                                    selectInput("response_ui_type", NULL,
                                                c("Radio Buttons" = "radio",
                                                  "Slider" = "slider",
                                                  "Dropdown" = "dropdown"), "radio"),
                                    selectInput("response_layout", "Response Layout (Default)",
                                                c("Vertical (like inrep)" = "vertical",
                                                  "Horizontal (all labels)" = "horizontal_all",
                                                  "Horizontal (endpoint labels only)" = "horizontal_endpoints"),
                                                "vertical"),
                                    # Progress style: hidden select (for Shiny reactivity) + visual card picker
                                    tags$label("Progress Indicator", class = "control-label", style = "margin-bottom: 6px; display: block;"),
                                    # Hidden selectInput — keeps Shiny input + config save/restore working
                                    div(style = "display: none;",
                                        selectInput("progress_style", NULL,
                                                    c("Disabled" = "none", "Bar" = "bar", "Circle" = "circle"),
                                                    "none")),
                                    # Visual card picker
                                    uiOutput("progress_style_picker"),
                                    div(style = "display: flex; align-items: center; gap: 8px; margin-top: 8px;",
                                        checkboxInput("feedback_enabled", "Immediate Feedback", FALSE, width = "auto"),
                                        tags$span(
                                          bs_icon("info-circle", class = "text-muted", style = "font-size: 0.85em;"),
                                          style = "cursor: help;",
                                          title = "Shows correct/incorrect feedback after each response. Mainly useful for cognitive/knowledge tests with right answers."
                                        )
                                    ),
                                    hr(),
                                    # ── Session Management ────────────────────────────
                                    h6("Session Management", class = "text-muted small"),
                                    checkboxInput("session_save", "Enable Session Recovery", TRUE),
                                    checkboxInput("show_session_time", "Show Session Timer", FALSE),
                                    numericInput("max_session_duration", "Max Session (minutes)", value = 60, min = 10, max = 240),
                                    numericInput("max_response_time", "Max Response Time (seconds)", value = 300, min = 30, max = 600),
                                    hr(),
                                    # ── Export ────────────────────────────────────────
                                    h6("Export Formats", class = "text-muted small"),
                                    checkboxGroupInput("report_formats", NULL,
                                                       choices = c("RDS" = "rds", "CSV" = "csv", "JSON" = "json", "PDF" = "pdf"),
                                                       selected = c("rds", "csv", "json"),
                                                       inline = TRUE),
                                    hr(),
                                    # ── Performance ────────────────────────────────────
                                    h6("Performance", class = "text-muted small"),
                                    checkboxInput("cache_enabled", "Cache Item Information", TRUE),
                                    checkboxInput("parallel_computation", "Parallel Processing", TRUE),
                                    checkboxInput("fast_item_selection", "Fast Item Selection", TRUE)
                    ),
                  )
              ),
              div(class = "sidebar-footer",
                  div(class = "d-flex gap-2 mb-2",
                      downloadButton("download_bundle", tagList(bs_icon("download"), " Bundle"), class = "btn-studio-primary flex-fill", icon = NULL),
                      tags$label(class = "btn btn-studio-outline flex-fill mb-0 d-flex align-items-center justify-content-center gap-1", 
                                 style = "cursor: pointer;",
                                 bs_icon("upload"), " Load",
                                 tags$input(type = "file", id = "upload_config_file", accept = ".json,.zip", style = "display: none;",
                                            onchange = "handleConfigUpload(this.files[0])")
                      )
                  ),
                  actionButton("preview_script", tagList(bs_icon("file-code"), " Preview R Script"), class = "btn-studio-outline w-100 btn-sm"),
                  div(class = "d-flex justify-content-center mt-2",
                      if (is_shinyapps()) {
                        tags$span(class = "badge text-bg-danger", style = "font-size:0.65rem; opacity:0.8;", "Production")
                      } else {
                        tags$span(class = "badge text-bg-secondary", style = "font-size:0.65rem; opacity:0.6;", "Local")
                      }
                  )
              )
          ),
          
          # ===== CENTER PREVIEW =====
          div(class = "col-center",
              # Toolbar: 3-column grid — Left=Add/Delete, Center=mode toggle, Right=empty
              div(class = "preview-toolbar",
                  # LEFT: Add Page + Delete buttons
                  div(class = "preview-toolbar-left",
                      div(class = "edit-only-controls",
                          actionButton("add_page_btn", tagList(bs_icon("plus-lg"), " Add"), class = "btn btn-dark btn-sm", title = "Add Page"),
                          actionButton("delete_page_btn", tagList(bs_icon("trash")), class = "btn btn-outline-danger btn-sm", title = "Delete Page")
                      )
                  ),
                  # CENTER: Mode toggle (always centered in the grid)
                  div(class = "mode-toggle-container",
                      div(class = "mode-badge preview-mode", id = "mode-indicator",
                          span(id = "mode-indicator-text", "Preview")),
                      input_switch("mode_switch", label = NULL, value = FALSE)
                  ),
                  # RIGHT: onboarding hint widget only (lang button lives in study preview header)
                  div(class = "preview-toolbar-right",
                      div(id = "ob-hint-widget", class = "ob-hint-widget",
                          onclick = "if(window.Shiny&&Shiny.setInputValue){Shiny.setInputValue('ob_navigate_back',Math.random(),{priority:'event'});Shiny.setInputValue('ob_reset_step',Math.random(),{priority:'event'});}",
                          title = "Return to onboarding",
                          tags$svg(
                            xmlns = "http://www.w3.org/2000/svg", width = "14", height = "14",
                            viewBox = "0 0 24 24", fill = "none", stroke = "currentColor",
                            `stroke-width` = "2", `stroke-linecap` = "round", `stroke-linejoin` = "round",
                            tags$path(d = "M22 2L11 13"),
                            tags$path(d = "M22 2L15 22l-4-9-9-4 20-7z")
                          ),
                          tags$span(class = "ob-hint-label", " Onboarding")
                      )
                  )
              ),
              
              # Page navigation
              div(class = "page-nav-container", 
                  div(class = "page-nav-scroll", uiOutput("page_navigation"))
              ),
              
              # Preview frame — direct content without device chrome
              div(class = "preview-frame-container",
                  uiOutput("page_content")
              )
          ),
          
          # ===== RIGHT SIDEBAR =====
          div(class = "col-right",
              # Item Repository
              div(style = "height: 50%; display: flex; flex-direction: column; border-bottom: 1px solid var(--studio-border);",
                  div(class = "right-panel-header",
                      div(class = "d-flex align-items-center justify-content-between mb-2",
                          h6(class = "mb-0", style = "display: flex; align-items: center; gap: 6px;", 
                             bs_icon("collection"), "Item Repository"),
                          div(class = "d-flex gap-1",
                              actionButton("add_item_btn", bs_icon("plus"), class = "btn-xs btn-outline-primary", title = "Create new item"),
                              tags$label(class = "btn btn-xs btn-outline-secondary mb-0", style = "cursor: pointer; display: inline-flex; align-items: center; gap: 4px;",
                                         bs_icon("upload"), "CSV",
                                         tags$input(type = "file", id = "upload_csv", accept = ".csv", style = "display: none;",
                                                    onchange = "Shiny.setInputValue('upload_csv', this.files[0] ? {name: this.files[0].name, size: this.files[0].size, type: this.files[0].type, datapath: URL.createObjectURL(this.files[0])} : null)")
                              ),
                              NULL
                          )
                      ),
                      tags$small(class = "text-muted", "Drag items to page")
                  ),
                  div(class = "right-panel-content", uiOutput("repository_ui"))
              ),
              
              # Properties Panel
              div(style = "height: 50%; display: flex; flex-direction: column;",
                  div(class = "right-panel-header", h6(bs_icon("sliders2"), "Properties")),
                  div(class = "right-panel-content", uiOutput("properties_ui"))
              )
          )
      ),
      
      # Mobile toggle buttons and overlay
      tags$button(
        class = "mobile-toggle",
        onclick = "toggleMobilePanel('left')",
        bs_icon("list")
      ),
      tags$button(
        class = "mobile-properties-toggle",
        onclick = "toggleMobilePanel('right')",
        bs_icon("sliders2")
      ),
      tags$div(class = "mobile-overlay"),
      
      # ── Onboarding handoff: receive config from inrep-studio-onboarding app ──
      # Two channels:
      #  (a) URL hash  — standalone apps: ?#inrep-onboarding=<JSON>
      #  (b) postMessage — framed/same-origin: { type: 'inrep-studio:onboarding-complete', payload }
      tags$script(HTML("
    (function() {
      // Channel (b): postMessage listener (framed onboarding iframe)
      window.addEventListener('message', function(evt) {
        if (evt.data && evt.data.type === 'inrep-studio:onboarding-complete') {
          try {
            if (window.Shiny && Shiny.setInputValue) {
              Shiny.setInputValue('ob_hydrate', JSON.stringify(evt.data.payload), {priority: 'event'});
            }
          } catch(e) { console.warn('inrep-studio: postMessage handler error', e); }
        }
      });

      // Channel (a): URL hash on load
      function readOnboardingHash() {
        var hash = window.location.hash || '';
        if (hash.indexOf('#inrep-onboarding=') === 0) {
          var enc = hash.slice('#inrep-onboarding='.length);
          try {
            var payload = JSON.parse(decodeURIComponent(enc));
            // Clear the hash so it doesn't re-hydrate on every reload
            history.replaceState(null, '', window.location.pathname + window.location.search);
            if (window.Shiny && Shiny.setInputValue) {
              Shiny.setInputValue('ob_hydrate', JSON.stringify(payload), {priority: 'event'});
            } else {
              // Shiny not ready yet — retry after session binds
              document.addEventListener('shiny:sessioninitialized', function() {
                Shiny.setInputValue('ob_hydrate', JSON.stringify(payload), {priority: 'event'});
              }, {once: true});
            }
          } catch(e) { console.warn('inrep-studio: could not parse onboarding hash', e); }
        }
      }

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', readOnboardingHash);
      } else {
        readOnboardingHash();
      }
    })();
  ")),
      
      # Comprehensive JavaScript for drag-drop, device switching, mobile panels, and mode
      tags$script(HTML("
    // ===== GLOBAL JS ERROR FORWARDING (debug) =====
    // Captures browser-side errors (often localized, e.g., German) and forwards them to R.
    (function(){
      function sendJsError(payload) {
        try {
          if (window.Shiny && Shiny.setInputValue) {
            Shiny.setInputValue('js_error', payload, {priority: 'event'});
          } else {
            console.error('JS error (Shiny not ready):', payload);
          }
        } catch (e) {
          console.error('Failed to forward JS error:', e);
        }
      }

      window.addEventListener('error', function(e) {
        sendJsError({
          type: 'error',
          message: String(e && e.message ? e.message : 'Unknown error'),
          filename: e && e.filename ? String(e.filename) : null,
          lineno: e && e.lineno ? e.lineno : null,
          colno: e && e.colno ? e.colno : null,
          stack: e && e.error && e.error.stack ? String(e.error.stack) : null,
          userAgent: navigator.userAgent
        });
      });

      window.addEventListener('unhandledrejection', function(e) {
        var reason = e && e.reason ? e.reason : null;
        sendJsError({
          type: 'unhandledrejection',
          message: reason ? String(reason.message || reason) : 'Unhandled promise rejection',
          stack: reason && reason.stack ? String(reason.stack) : null,
          userAgent: navigator.userAgent
        });
      });
    })();

    // ===== MOBILE PANELS (ORCHESTRATED, TOUCH-SAFE) =====
    (function(){
      const MOBILE_BREAKPOINT_PX = 1200;
      let resizeTimer = null;
      let isToggling = false;

      function isMobileLayout() {
        try {
          return window.matchMedia('(max-width: ' + MOBILE_BREAKPOINT_PX + 'px)').matches;
        } catch (e) {
          return window.innerWidth <= MOBILE_BREAKPOINT_PX;
        }
      }

      function getOverlay() {
        return document.querySelector('.mobile-overlay');
      }

      function getPanel(side) {
        return document.querySelector('.col-' + side);
      }

      function anyPanelOpen() {
        return Boolean(document.querySelector('.col-left.mobile-open, .col-right.mobile-open'));
      }

      function syncOverlayState() {
        const overlay = getOverlay();
        if (!overlay) return;

        const open = anyPanelOpen();
        overlay.classList.toggle('active', open);
        
        // Save/restore scroll position when locking body
        if (open && !document.body.classList.contains('mobile-panel-open')) {
          // Save scroll position before locking
          document.body.dataset.scrollY = window.scrollY || window.pageYOffset || 0;
          document.body.style.top = '-' + (window.scrollY || 0) + 'px';
          document.body.classList.add('mobile-panel-open');
        } else if (!open && document.body.classList.contains('mobile-panel-open')) {
          // Restore scroll position after unlocking
          document.body.classList.remove('mobile-panel-open');
          document.body.style.top = '';
          var savedY = parseInt(document.body.dataset.scrollY || '0', 10);
          window.scrollTo(0, savedY);
        }
      }

      // Expose as globals for inline onclick handlers
      window.closeMobilePanels = function closeMobilePanels() {
        const left = getPanel('left');
        const right = getPanel('right');
        if (left) left.classList.remove('mobile-open');
        if (right) right.classList.remove('mobile-open');
        syncOverlayState();
      };

      window.toggleMobilePanel = function toggleMobilePanel(side) {
        // Never allow mobile slide-in behavior on desktop layout.
        if (!isMobileLayout()) {
          window.closeMobilePanels();
          return;
        }

        // Guard: prevent rapid double toggles causing inconsistent overlay state.
        if (isToggling) return;
        isToggling = true;
        window.setTimeout(function(){ isToggling = false; }, 350);

        const panel = getPanel(side);
        const otherSide = side === 'left' ? 'right' : 'left';
        const otherPanel = getPanel(otherSide);
        if (!panel) {
          syncOverlayState();
          return;
        }

        if (otherPanel) otherPanel.classList.remove('mobile-open');

        const willOpen = !panel.classList.contains('mobile-open');
        panel.classList.toggle('mobile-open', willOpen);
        syncOverlayState();
      };

      function syncResponsiveState() {
        if (!isMobileLayout()) {
          window.closeMobilePanels();
        } else {
          syncOverlayState();
        }
      }

      function scheduleSync() {
        if (resizeTimer) window.clearTimeout(resizeTimer);
        resizeTimer = window.setTimeout(syncResponsiveState, 80);
      }

      function getPreviewScroller() {
        const candidates = [
          document.querySelector('.col-center'),
          document.querySelector('.preview-frame-container'),
          document.querySelector('.preview-device-screen')
        ].filter(Boolean);
        for (let i = 0; i < candidates.length; i++) {
          const el = candidates[i];
          if ((el.scrollHeight || 0) > (el.clientHeight || 0) + 2) return el;
        }
        return document.scrollingElement || document.documentElement;
      }

      // Scroll handoff: when user reaches the top/bottom of a slide-in panel, keep scrolling the preview.
      function bindScrollHandoff(panelEl) {
        if (!panelEl) return;
        if (panelEl.__inrepScrollHandoffBound) return;
        panelEl.__inrepScrollHandoffBound = true;

        // The actual scroll container is a child (.sidebar-content or .right-panel-content),
        // NOT the panel itself (which has overflow:hidden on mobile).
        function getScrollChild() {
          return panelEl.querySelector('.sidebar-content') ||
                 panelEl.querySelector('.right-panel-content') ||
                 panelEl;
        }

        let lastY = null;
        panelEl.addEventListener('touchstart', function(e) {
          if (!e || !e.touches || e.touches.length !== 1) return;
          lastY = e.touches[0].clientY;
        }, {passive: true});

        panelEl.addEventListener('touchmove', function(e) {
          if (!document.body.classList.contains('mobile-panel-open')) return;
          if (!isMobileLayout()) return;
          if (!e || !e.touches || e.touches.length !== 1) return;
          if (lastY === null) {
            lastY = e.touches[0].clientY;
            return;
          }

          const y = e.touches[0].clientY;
          const deltaY = y - lastY;
          lastY = y;

          const scroller = getScrollChild();
          const scrollTop = scroller.scrollTop;
          const maxScrollTop = Math.max(0, scroller.scrollHeight - scroller.clientHeight);
          const atTop = scrollTop <= 0;
          const atBottom = scrollTop >= (maxScrollTop - 1);

          // Finger moves down (deltaY > 0) => user trying to scroll up.
          // Finger moves up (deltaY < 0) => user trying to scroll down.
          if ((deltaY > 0 && atTop) || (deltaY < 0 && atBottom)) {
            const previewScroller = getPreviewScroller();
            if (previewScroller && previewScroller.scrollBy && previewScroller.scrollHeight > previewScroller.clientHeight + 2) {
              previewScroller.scrollBy({ top: -deltaY, left: 0, behavior: 'auto' });
              // Only preventDefault when preview is actually scrollable
              if (e.cancelable) e.preventDefault();
            }
          }
        }, {passive: false});
      }

      // Keep state stable across iOS URL bar show/hide + rotation.
      window.addEventListener('resize', scheduleSync);
      window.addEventListener('orientationchange', scheduleSync);
      if (window.visualViewport && window.visualViewport.addEventListener) {
        window.visualViewport.addEventListener('resize', scheduleSync);
      }

      // Deterministic outside-tap closer (capture phase).
      // This avoids iOS hit-testing/stacking quirks where the overlay may steal taps.
      function isInsideOpenPanelOrToggle(target) {
        if (!target || !target.closest) return false;
        if (target.closest('.col-left.mobile-open')) return true;
        if (target.closest('.col-right.mobile-open')) return true;
        if (target.closest('.mobile-toggle')) return true;
        if (target.closest('.mobile-properties-toggle')) return true;
        return false;
      }

      function outsideTapCloseHandler(e) {
        if (!isMobileLayout()) return;
        if (!anyPanelOpen()) return;

        // If tap starts inside the open panel (or on toggles), do nothing.
        if (isInsideOpenPanelOrToggle(e.target)) return;

        // Otherwise, prevent underlying taps (preview) and close.
        if (e && e.cancelable) e.preventDefault();
        window.closeMobilePanels();
      }

      document.addEventListener('pointerdown', outsideTapCloseHandler, true);
      document.addEventListener('touchstart', outsideTapCloseHandler, {capture: true, passive: false});

      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function(){
          bindScrollHandoff(getPanel('left'));
          bindScrollHandoff(getPanel('right'));
          syncResponsiveState();
        });
      } else {
        bindScrollHandoff(getPanel('left'));
        bindScrollHandoff(getPanel('right'));
        syncResponsiveState();
      }
    })();
    
    // Close panels on escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        closeMobilePanels();
      }
    });
    
    // ===== MODE HANDLING =====
    // Set initial mode on page load (Preview is default)
    $(document).ready(function() {
      document.body.classList.add('preview-mode-active');
      initInlineEditing();
    });
    
    // SVG icon definitions
    const pencilSVG = '<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" fill=\"currentColor\" class=\"bi bi-pencil\" viewBox=\"0 0 16 16\"><path d=\"M12.146.146a.5.5 0 0 1 .708 0l3 3a.5.5 0 0 1 0 .708l-10 10a.5.5 0 0 1-.168.11l-5 2a.5.5 0 0 1-.65-.65l2-5a.5.5 0 0 1 .11-.168zM11.207 2.5 13.5 4.793 14.793 3.5 12.5 1.207zm1.586 3L10.5 3.207 4 9.707V10h.5a.5.5 0 0 1 .5.5v.5h.5a.5.5 0 0 1 .5.5v.5h.293zm-9.761 5.175-.106.106-1.528 3.821 3.821-1.528.106-.106A.5.5 0 0 1 5 12.5V12h-.5a.5.5 0 0 1-.5-.5V11h-.5a.5.5 0 0 1-.468-.325\"/></svg>';
    const eyeSVG = '<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"12\" height=\"12\" fill=\"currentColor\" class=\"bi bi-eye\" viewBox=\"0 0 16 16\"><path d=\"M16 8s-3-5.5-8-5.5S0 8 0 8s3 5.5 8 5.5S16 8 16 8M1.173 8a13 13 0 0 1 1.66-2.043C4.12 4.668 5.88 3.5 8 3.5s3.879 1.168 5.168 2.457A13 13 0 0 1 14.828 8q-.086.13-.195.288c-.335.48-.83 1.12-1.465 1.755C11.879 11.332 10.119 12.5 8 12.5s-3.879-1.168-5.168-2.457A13 13 0 0 1 1.172 8z\"/><path d=\"M8 5.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5M4.5 8a3.5 3.5 0 1 1 7 0 3.5 3.5 0 0 1-7 0\"/></svg>';
    
    // ===== PREVIEW THEME CSS INJECTION =====
    // Injects scoped theme CSS into a <style> tag in <head>.
    // Queue pattern: if a message arrives before shiny:sessioninitialized
    // (possible on shinyapps.io with slow asset hydration), it is stored and
    // re-applied once the DOM is confirmed ready — eliminating the race condition
    // where the JS handler fires with content before the element exists.
    window.__inrepPendingThemeCss = null;
    Shiny.addCustomMessageHandler('updatePreviewThemeCss', function(msg) {
      var css = msg.css || '';
      var el = document.getElementById('preview-theme-css-tag');
      if (!el) {
        el = document.createElement('style');
        el.id = 'preview-theme-css-tag';
        document.head.appendChild(el);
      }
      el.textContent = css;
      // Store so the sessioninitialized handler can re-apply if needed
      window.__inrepPendingThemeCss = css;
    });
    $(document).on('shiny:sessioninitialized', function() {
      if (window.__inrepPendingThemeCss !== null) {
        var el = document.getElementById('preview-theme-css-tag');
        if (el) el.textContent = window.__inrepPendingThemeCss;
      }
    });

    // ===== PREVIEW INLINE STYLE (CSS variables) =====
    // Updates --preview-* CSS variables on the .study-preview div directly,
    // so color pickers and Studio chrome reflect the theme immediately.
    Shiny.addCustomMessageHandler('updatePreviewVars', function(msg) {
      var el = document.querySelector('.study-preview');
      if (!el) return;
      Object.entries(msg).forEach(function(kv) {
        el.style.setProperty(kv[0], kv[1]);
      });
    });

    Shiny.addCustomMessageHandler('updateMode', function(isEditMode) {
      const indicator = document.getElementById('mode-indicator');
      const indicatorText = document.getElementById('mode-indicator-text');
      
      if (isEditMode) {
        indicator.className = 'mode-badge edit-mode';
        if(indicatorText) indicatorText.innerHTML = pencilSVG + ' Edit';
        document.body.classList.add('edit-mode-active');
        document.body.classList.remove('preview-mode-active');
        enableInlineEditing();
      } else {
        indicator.className = 'mode-badge preview-mode';
        if(indicatorText) indicatorText.innerHTML = eyeSVG + ' Preview';
        document.body.classList.add('preview-mode-active');
        document.body.classList.remove('edit-mode-active');
        disableInlineEditing();
      }
    });
    
    
    
    // ===== INLINE EDITING SYSTEM =====
    function initInlineEditing() {
      // Watch for newly rendered editable content
      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          mutation.addedNodes.forEach(function(node) {
            if (node.nodeType === 1) {
              setupEditableElements(node);
            }
          });
        });
      });
      observer.observe(document.body, { childList: true, subtree: true });
    }
    
    function setupEditableElements(container) {
      if (!container.querySelectorAll) return;
      container.querySelectorAll('.editable-content').forEach(el => {
        if (!el.dataset.editableInitialized) {
          el.dataset.editableInitialized = 'true';
          el.addEventListener('blur', handleEditableBlur);
          el.addEventListener('keydown', handleEditableKeydown);
        }
      });
    }
    
    function enableInlineEditing() {
      document.querySelectorAll('.editable-content').forEach(el => {
        el.setAttribute('contenteditable', 'true');
        el.classList.add('editable-active');
      });
    }
    
    function disableInlineEditing() {
      document.querySelectorAll('.editable-content').forEach(el => {
        el.setAttribute('contenteditable', 'false');
        el.classList.remove('editable-active');
      });
    }
    
    function handleEditableBlur(e) {
      const el = e.target;
      const field = el.dataset.field;
      const pageId = el.dataset.pageId;
      const itemId = el.dataset.itemId;
      const isRichText = el.classList.contains('rich-text-content');
      
      // CRITICAL: Skip page titles (title/title_en) to prevent conflicts
      // Page titles should only be edited via properties panel
      if (field === 'title' || field === 'title_en') {
        return; // Don't save inline edits for titles
      }
      
      // For rich text, get innerHTML to preserve formatting
      // For plain text (items, titles), get innerText
      const newValue = isRichText ? el.innerHTML.trim() : el.innerText.trim();
      
      // Send to Shiny - include itemId if it's an item edit
      Shiny.setInputValue('inline_edit', {
        pageId: pageId || null,
        itemId: itemId || null,
        field: field,
        value: newValue,
        isHtml: isRichText
      }, {priority: 'event'});
    }
    
    function handleEditableKeydown(e) {
      // Ctrl+Enter or Escape to finish editing
      if (e.key === 'Escape' || (e.key === 'Enter' && e.ctrlKey)) {
        e.target.blur();
        e.preventDefault();
      }
      // Allow Enter to create paragraphs in rich text content
      // (don't block default behavior for rich text)
    }
    
    // ===== RICH TEXT EDITOR FUNCTIONS =====
    function formatText(command, value) {
      document.execCommand(command, false, value || null);
      // Re-focus the editable area
      const active = document.activeElement;
      if (active && active.classList.contains('rich-text-content')) {
        active.focus();
      }
    }
    
    function insertLink() {
      const url = prompt('Enter URL:', 'https://');
      if (url) {
        document.execCommand('createLink', false, url);
      }
    }
    
    function clearFormatting() {
      document.execCommand('removeFormat', false, null);
    }
    
    // Update toolbar button states based on current selection
    function updateToolbarState() {
      document.querySelectorAll('.rte-btn[data-command]').forEach(btn => {
        const cmd = btn.dataset.command;
        if (document.queryCommandState(cmd)) {
          btn.classList.add('active');
        } else {
          btn.classList.remove('active');
        }
      });
    }
    
    // Attach toolbar update to selection changes
    document.addEventListener('selectionchange', function() {
      const active = document.activeElement;
      if (active && active.classList.contains('rich-text-content')) {
        updateToolbarState();
      }
    });

    // Item actions (for edit mode)
    function moveItemUp(itemId) {
      Shiny.setInputValue('move_item_up', itemId, {priority: 'event'});
    }
    function moveItemDown(itemId) {
      Shiny.setInputValue('move_item_down', itemId, {priority: 'event'});
    }
    function removeItemFromPage(itemId) {
      Shiny.setInputValue('remove_item_from_page', itemId, {priority: 'event'});
    }
    function editItemInline(itemId) {
      Shiny.setInputValue('edit_item_inline', itemId, {priority: 'event'});
    }
    
    // ===== STUDIO HINT TOAST =====
    let _studioHintTimer = null;
    function showStudioHint(msg) {
      var el = document.getElementById('studio-hint-toast');
      if (!el) {
        el = document.createElement('div');
        el.id = 'studio-hint-toast';
        document.body.appendChild(el);
      }
      el.textContent = msg;
      el.style.opacity = '1';
      if (_studioHintTimer) clearTimeout(_studioHintTimer);
      _studioHintTimer = setTimeout(function() { el.style.opacity = '0'; }, 3200);
    }

    // ===== DRAG AND DROP SYSTEM =====
    let draggedItem = null;
    let dragSource = null;
    let dropTarget = null;
    
    // Initialize drag-drop after Shiny renders content
    $(document).on('shiny:value', function(e) {
      setTimeout(initDragDrop, 100);
    });
    
    function initDragDrop() {
      // Make repository items draggable
      document.querySelectorAll('.repo-item').forEach(item => {
        item.setAttribute('draggable', 'true');
        item.classList.add('draggable-item');
        
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
      });
      
      // Make preview items sortable (within items page)
      document.querySelectorAll('.preview-item').forEach(item => {
        item.setAttribute('draggable', 'true');
        item.classList.add('draggable-item', 'sortable-item');
        
        item.addEventListener('dragstart', handleDragStart);
        item.addEventListener('dragend', handleDragEnd);
        item.addEventListener('dragover', handleDragOver);
        item.addEventListener('drop', handleDrop);
        item.addEventListener('dragleave', handleDragLeave);
      });
      
      // Make preview content a drop zone
      const dropZone = document.querySelector('.study-preview-content');
      if (dropZone) {
        dropZone.classList.add('drop-zone');
        dropZone.addEventListener('dragover', handleDropZoneDragOver);
        dropZone.addEventListener('drop', handleDropZoneDrop);
        dropZone.addEventListener('dragleave', handleDropZoneDragLeave);
      }
      
      // Make page nav items sortable with improved handlers
      document.querySelectorAll('.page-nav-item').forEach(item => {
        item.setAttribute('draggable', 'true');
        item.classList.add('draggable-item', 'sortable-item');
        
        item.addEventListener('dragstart', handlePageDragStart);
        item.addEventListener('dragend', handlePageDragEnd);
        item.addEventListener('dragover', handlePageDragOver);
        item.addEventListener('drop', handlePageDrop);
        item.addEventListener('dragleave', function(e) {
          // Only clear if not entering a child element
          if (!e.relatedTarget || !this.contains(e.relatedTarget)) {
            this.classList.remove('drag-over', 'drop-before', 'drop-after');
          }
        });
      });
    }
    
    // ===== ITEM DRAG HANDLERS =====
    function handleDragStart(e) {
      draggedItem = this;
      dragSource = this.closest('.right-panel-content') ? 'repository' : 'preview';

      // Block item reordering when in preview mode — prompt user to switch to Edit mode
      if (dragSource === 'preview' && document.body.classList.contains('preview-mode-active')) {
        e.preventDefault();
        draggedItem = null;
        dragSource = null;
        showStudioHint('Switch to Edit mode to reorder items');
        return;
      }
      
      this.classList.add('dragging');
      e.dataTransfer.effectAllowed = 'move';
      e.dataTransfer.setData('text/plain', this.dataset.itemId || this.getAttribute('onclick')?.match(/'([^']+)'/)?.[1] || '');
      
      // Activate drop zones
      document.querySelectorAll('.drop-zone').forEach(zone => {
        zone.classList.add('drag-active');
      });
    }
    
    function handleDragEnd(e) {
      this.classList.remove('dragging');
      draggedItem = null;
      dragSource = null;
      
      // Deactivate drop zones
      document.querySelectorAll('.drop-zone, .drag-over, .drag-active').forEach(el => {
        el.classList.remove('drag-active', 'drag-over');
      });
      
      // Remove all placeholders
      document.querySelectorAll('.drop-placeholder').forEach(p => p.remove());
    }
    
    function handleDragOver(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      
      if (draggedItem && draggedItem !== this) {
        this.classList.add('drag-over');
        
        // Show position indicator
        const rect = this.getBoundingClientRect();
        const midY = rect.top + rect.height / 2;
        
        if (e.clientY < midY) {
          this.style.borderTopWidth = '3px';
          this.style.borderBottomWidth = '2px';
        } else {
          this.style.borderTopWidth = '2px';
          this.style.borderBottomWidth = '3px';
        }
      }
    }
    
    function handleDragLeave(e) {
      this.classList.remove('drag-over', 'drop-before', 'drop-after');
      this.style.borderTopWidth = '';
      this.style.borderBottomWidth = '';
    }
    
    function handleDrop(e) {
      e.preventDefault();
      e.stopPropagation();
      
      this.classList.remove('drag-over', 'drop-before', 'drop-after');
      this.style.borderTopWidth = '';
      this.style.borderBottomWidth = '';
      
      if (!draggedItem || draggedItem === this) return;
      
      const itemId = e.dataTransfer.getData('text/plain');
      const targetId = this.dataset.itemId || this.getAttribute('onclick')?.match(/'([^']+)'/)?.[1];
      
      if (dragSource === 'repository') {
        // Adding item from repository to preview
        Shiny.setInputValue('drop_item_on_item', {
          itemId: itemId,
          targetId: targetId,
          position: e.clientY < this.getBoundingClientRect().top + this.getBoundingClientRect().height / 2 ? 'before' : 'after'
        }, {priority: 'event'});
      } else {
        // Reordering items within preview
        Shiny.setInputValue('reorder_items', {
          itemId: itemId,
          targetId: targetId,
          position: e.clientY < this.getBoundingClientRect().top + this.getBoundingClientRect().height / 2 ? 'before' : 'after'
        }, {priority: 'event'});
      }
    }
    
    // ===== DROP ZONE HANDLERS =====
    function handleDropZoneDragOver(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      this.classList.add('drag-over');
    }
    
    function handleDropZoneDragLeave(e) {
      if (!e.relatedTarget || !this.contains(e.relatedTarget)) {
        this.classList.remove('drag-over');
      }
    }
    
    function handleDropZoneDrop(e) {
      e.preventDefault();
      this.classList.remove('drag-over', 'drag-active');
      
      const itemId = e.dataTransfer.getData('text/plain');
      if (itemId && dragSource === 'repository') {
        Shiny.setInputValue('drop_item_to_page', itemId, {priority: 'event'});
      }
    }
    
    // ===== PAGE NAV DRAG HANDLERS - PROFESSIONAL SORTABLE =====
    let pageDropPosition = null;
    
    function handlePageDragStart(e) {
      // Only allow dragging in edit mode
      if (document.body.classList.contains('preview-mode-active')) {
        e.preventDefault();
        return;
      }
      
      draggedItem = this;
      
      // Delay adding dragging class for smooth visual pickup
      requestAnimationFrame(() => {
        this.classList.add('dragging');
      });
      
      e.dataTransfer.effectAllowed = 'move';
      
      // Set a custom drag image for better visual
      const dragImage = this.cloneNode(true);
      dragImage.style.position = 'absolute';
      dragImage.style.top = '-1000px';
      dragImage.style.opacity = '0.9';
      dragImage.style.transform = 'scale(1.02)';
      dragImage.style.boxShadow = '0 8px 30px rgba(0,0,0,0.2)';
      document.body.appendChild(dragImage);
      e.dataTransfer.setDragImage(dragImage, dragImage.offsetWidth / 2, dragImage.offsetHeight / 2);
      setTimeout(() => document.body.removeChild(dragImage), 0);
      
      const pageId = this.dataset.pageId || this.getAttribute('onclick')?.match(/'([^']+)'/)?.[1] || '';
      e.dataTransfer.setData('text/plain', pageId);
      
      // Add drag-active to container
      const container = this.closest('.page-nav');
      if (container) container.classList.add('drag-active');
    }
    
    function handlePageDragEnd(e) {
      this.classList.remove('dragging');
      
      // Clean up all drag states
      document.querySelectorAll('.page-nav-item').forEach(item => {
        item.classList.remove('drag-over', 'drop-before', 'drop-after');
      });
      
      // Remove drag-active from container
      document.querySelectorAll('.page-nav').forEach(nav => {
        nav.classList.remove('drag-active');
      });
      
      draggedItem = null;
      pageDropPosition = null;
    }
    
    function handlePageDragOver(e) {
      e.preventDefault();
      e.dataTransfer.dropEffect = 'move';
      
      if (!draggedItem || draggedItem === this || !draggedItem.classList.contains('page-nav-item')) {
        return;
      }
      
      // Clear previous indicators on all items
      document.querySelectorAll('.page-nav-item').forEach(item => {
        if (item !== this) {
          item.classList.remove('drop-before', 'drop-after', 'drag-over');
        }
      });
      
      this.classList.add('drag-over');
      
      const rect = this.getBoundingClientRect();
      const midX = rect.left + rect.width / 2;
      
      // Use CSS classes for smooth drop indicators
      if (e.clientX < midX) {
        this.classList.add('drop-before');
        this.classList.remove('drop-after');
        pageDropPosition = 'before';
      } else {
        this.classList.add('drop-after');
        this.classList.remove('drop-before');
        pageDropPosition = 'after';
      }
    }
    
    function handlePageDrop(e) {
      e.preventDefault();
      
      // Clean up visual states
      this.classList.remove('drag-over', 'drop-before', 'drop-after');
      
      if (!draggedItem || draggedItem === this) return;
      
      const sourcePageId = e.dataTransfer.getData('text/plain');
      const targetPageId = this.dataset.pageId || this.getAttribute('onclick')?.match(/'([^']+)'/)?.[1] || '';
      
      const rect = this.getBoundingClientRect();
      const position = e.clientX < rect.left + rect.width / 2 ? 'before' : 'after';
      
      // Visual feedback - brief highlight
      this.style.transition = 'background 0.3s ease';
      this.style.background = 'rgba(52, 152, 219, 0.2)';
      setTimeout(() => {
        this.style.background = '';
        this.style.transition = '';
      }, 300);
      
      Shiny.setInputValue('reorder_pages', {
        sourceId: sourcePageId,
        targetId: targetPageId,
        position: position
      }, {priority: 'event'});
    }
    
    // ===== ITEM ACTION BUTTONS =====
    function moveItemUp(itemId) {
      Shiny.setInputValue('move_item_up', itemId, {priority: 'event'});
    }
    
    function moveItemDown(itemId) {
      Shiny.setInputValue('move_item_down', itemId, {priority: 'event'});
    }
    
    function removeItemFromPage(itemId) {
      Shiny.setInputValue('remove_item_from_page', itemId, {priority: 'event'});
    }
    
    // ===== RESIZABLE PANELS =====
    let isResizing = false;
    let currentResizer = null;
    let startX, startY, startWidth, startHeight;
    
    function initResizablePanels() {
      // Desktop only (mobile uses slide-in panels)
      if (window.innerWidth < 1201) return;

      // Left panel resize
      const leftPanel = document.querySelector('.col-left');
      if (leftPanel && !leftPanel.querySelector('.resize-handle')) {
        const resizer = document.createElement('div');
        resizer.className = 'resize-handle resize-handle-h';
        leftPanel.appendChild(resizer);
        
        resizer.addEventListener('mousedown', function(e) {
          isResizing = true;
          currentResizer = 'left';
          startX = e.clientX;
          startWidth = leftPanel.offsetWidth;
          document.body.style.cursor = 'col-resize';
          e.preventDefault();
        });
      }
      
      // Right panel resize
      const rightPanel = document.querySelector('.col-right');
      if (rightPanel && !rightPanel.querySelector('.resize-handle')) {
        const resizer = document.createElement('div');
        resizer.className = 'resize-handle resize-handle-h';
        rightPanel.appendChild(resizer);
        
        resizer.addEventListener('mousedown', function(e) {
          isResizing = true;
          currentResizer = 'right';
          startX = e.clientX;
          startWidth = rightPanel.offsetWidth;
          document.body.style.cursor = 'col-resize';
          e.preventDefault();
        });
      }
    }
    
    document.addEventListener('mousemove', function(e) {
      if (!isResizing) return;
      
      const container = document.querySelector('.main-container');
      const leftPanel = document.querySelector('.col-left');
      const rightPanel = document.querySelector('.col-right');
      
      if (currentResizer === 'left') {
        const newWidth = Math.max(200, Math.min(500, startWidth + (e.clientX - startX)));
        container.style.gridTemplateColumns = newWidth + 'px 1fr ' + (rightPanel ? rightPanel.offsetWidth + 'px' : '360px');
      } else if (currentResizer === 'right') {
        const newWidth = Math.max(250, Math.min(600, startWidth - (e.clientX - startX)));
        container.style.gridTemplateColumns = (leftPanel ? leftPanel.offsetWidth + 'px' : '320px') + ' 1fr ' + newWidth + 'px';
      }
    });
    
    document.addEventListener('mouseup', function() {
      if (isResizing) {
        isResizing = false;
        currentResizer = null;
        document.body.style.cursor = '';
      }
    });
    
    // Initialize on page load
    $(document).ready(function() {
      initResizablePanels();
      initDragDrop();
    });
    
    // ===== FILE UPLOAD HANDLERS =====
    // Handle CSV upload for items (using custom file input)
    document.addEventListener('change', function(e) {
      if (e.target.id === 'upload_csv' && e.target.files && e.target.files[0]) {
        const file = e.target.files[0];
        const reader = new FileReader();
        reader.onload = function(event) {
          Shiny.setInputValue('upload_csv_data', {
            name: file.name,
            content: event.target.result,
            type: file.type,
            size: file.size
          }, {priority: 'event'});
        };
        reader.readAsText(file);
        // Reset the input so same file can be uploaded again
        e.target.value = '';
      }
    });
    
    // Handle config/bundle upload
    function handleConfigUpload(file) {
      if (!file) return;
      
      const reader = new FileReader();
      reader.onload = function(event) {
        Shiny.setInputValue('upload_config_data', {
          name: file.name,
          content: file.name.endsWith('.json') ? event.target.result : null,
          type: file.type,
          size: file.size,
          isZip: file.name.endsWith('.zip')
        }, {priority: 'event'});
        
        // For zip files, we need to send the raw data differently
        if (file.name.endsWith('.zip')) {
          const zipReader = new FileReader();
          zipReader.onload = function(zipEvent) {
            // Convert to base64 for Shiny
            const base64 = btoa(String.fromCharCode(...new Uint8Array(zipEvent.target.result)));
            Shiny.setInputValue('upload_config_zip_data', base64, {priority: 'event'});
          };
          zipReader.readAsArrayBuffer(file);
        }
      };
      
      if (file.name.endsWith('.json')) {
        reader.readAsText(file);
      } else {
        reader.readAsArrayBuffer(file);
      }
      
      // Reset parent input
      const input = document.getElementById('upload_config_file');
      if (input) input.value = '';
    }
    
    // ===== COLOR PICKER SYSTEM =====
    // Add click-to-color functionality for elements in edit mode
    function initColorPicker() {
      const previewScreen = document.getElementById('preview-screen') || document.querySelector('.preview-device-screen');
      if (!previewScreen) return;
      
      // Delegate click handling for colorable elements
      previewScreen.addEventListener('click', function(e) {
        // Only in edit mode
        if (!document.body.classList.contains('edit-mode-active')) return;
        
        // CRITICAL: Don't intercept clicks on text inputs or contenteditable elements
        const isTextInput = e.target.matches('input[type=text], textarea, [contenteditable=true]') ||
                            e.target.closest('[contenteditable=true]');
        if (isTextInput) return;
        
        // Define all colorable element selectors
        const colorableSelectors = [
          '.preview-item',           // Item questions
          '.study-preview-title',    // Headings
          '.study-preview-progress', // Progress bars
          '.study-heading',          // Section headings
          '.demo-label-preview',     // Demographic labels
          '.results-table-row',      // Results table rows (NEW)
          '.results-scale-bar',      // Results progress bars (NEW)
          '.results-header-cell',    // Results table header (NEW)
          '.results-scale-name',     // Scale names in results (NEW)
          '.progress-bar-fill'       // Progress fill element (NEW)
        ];
        
        const item = e.target.closest(colorableSelectors.join(', '));
        
        if (!item) return;
        
        e.stopPropagation();
        
        // Get computed style based on element type
        const computedStyle = window.getComputedStyle(item);
        let currentColor = '#2c3e50';
        let changeType = 'text';
        let elementType = 'generic';
        
        // Determine element type and what color to get/change
        if (item.classList.contains('results-scale-bar') || item.querySelector('.progress-bar-fill')) {
          changeType = 'bar-fill';
          currentColor = computedStyle.backgroundColor || '#3498db';
          elementType = 'results-bar';
        } else if (item.classList.contains('results-table-row')) {
          changeType = 'row-accent';
          currentColor = computedStyle.borderColor || computedStyle.backgroundColor || '#e5e7eb';
          elementType = 'results-row';
        } else if (item.classList.contains('results-scale-name') || item.classList.contains('results-header-cell')) {
          changeType = 'results-header';
          currentColor = computedStyle.color || computedStyle.backgroundColor || '#374151';
          elementType = 'results-text';
        } else if (item.classList.contains('study-preview-progress') || item.querySelector('.progress-bar-fill')) {
          changeType = 'progress';
          currentColor = computedStyle.backgroundColor || '#3498db';
          elementType = 'progress-bar';
        } else if (item.classList.contains('preview-item')) {
          changeType = 'border';
          currentColor = computedStyle.borderColor || '#3498db';
          elementType = 'item';
        } else if (item.classList.contains('study-heading') || item.classList.contains('study-preview-title')) {
          changeType = 'text';
          currentColor = computedStyle.color || '#2c3e50';
          elementType = 'heading';
        } else {
          currentColor = computedStyle.color || '#2c3e50';
        }
        
        // Get element identifier - for results table, use scale index
        let elementId = item.id || item.dataset.pageId || 'default';
        const scaleIndex = item.dataset.scaleIndex;
        const scaleId = item.dataset.scaleId;
        
        // Send to Shiny for color picker
        Shiny.setInputValue('element_color_click', {
          elementType: elementType,
          currentColor: currentColor,
          changeType: changeType,
          elementId: elementId,
          scaleIndex: scaleIndex,
          scaleId: scaleId,
          className: item.className
        }, {priority: 'event'});
      });
    }
    
    // Call on page load
    $(document).ready(function() {
      initColorPicker();
    });

    // ===== SESSION KEEP-ALIVE =====
    // Sends a lightweight heartbeat every 55 seconds to prevent idle timeout.
    // shinyapps.io default timeout is 60s; local Shiny Server varies.
    (function() {
      var heartbeatInterval = null;
      var missedPings = 0;
      var maxMissed = 3;

      function sendHeartbeat() {
        if (typeof Shiny !== 'undefined' && Shiny.shinyapp && Shiny.shinyapp.$socket &&
            Shiny.shinyapp.$socket.readyState === WebSocket.OPEN) {
          Shiny.setInputValue('__keepalive_ping', Date.now(), {priority: 'event'});
          missedPings = 0;
          updateConnectionIndicator('connected');
        } else {
          missedPings++;
          if (missedPings >= maxMissed) {
            updateConnectionIndicator('disconnected');
          } else {
            updateConnectionIndicator('reconnecting');
          }
        }
      }

      function updateConnectionIndicator(status) {
        var el = document.getElementById('connection-status');
        if (!el) return;
        el.className = 'connection-indicator connection-' + status;
        var dot = el.querySelector('.conn-dot');
        var text = el.querySelector('.conn-text');
        if (status === 'connected') {
          if (dot) dot.style.background = '#22c55e';
          if (text) text.textContent = '';
          el.style.opacity = '0';
          el.style.pointerEvents = 'none';
        } else if (status === 'reconnecting') {
          if (dot) dot.style.background = '#f59e0b';
          if (text) text.textContent = 'Reconnecting...';
          el.style.opacity = '1';
          el.style.pointerEvents = 'auto';
        } else {
          if (dot) dot.style.background = '#ef4444';
          if (text) text.textContent = 'Disconnected — please reload';
          el.style.opacity = '1';
          el.style.pointerEvents = 'auto';
        }
      }

      heartbeatInterval = setInterval(sendHeartbeat, 55000);

      // Warn before leaving with unsaved changes
      window.addEventListener('beforeunload', function(e) {
        // Only warn if the user has made changes (pages or items exist beyond defaults)
        if (typeof Shiny !== 'undefined' && Shiny.shinyapp && Shiny.shinyapp.$socket &&
            Shiny.shinyapp.$socket.readyState === WebSocket.OPEN) {
          e.preventDefault();
          e.returnValue = '';
        }
      });

      // Monitor Shiny connection status changes
      $(document).on('shiny:disconnected', function() {
        updateConnectionIndicator('disconnected');
      });
      $(document).on('shiny:connected', function() {
        updateConnectionIndicator('connected');
        missedPings = 0;
      });
      $(document).on('shiny:reconnecting', function() {
        updateConnectionIndicator('reconnecting');
      });
    })();
  "))
      ,
      # Connection status indicator (hidden when connected)
      div(id = "connection-status", class = "connection-indicator connection-connected",
          style = "position: fixed; bottom: 16px; left: 50%; transform: translateX(-50%); z-index: 9999; background: rgba(0,0,0,0.85); color: white; padding: 8px 18px; border-radius: 24px; font-size: 0.85rem; display: flex; align-items: center; gap: 8px; opacity: 0; transition: opacity 0.3s ease; pointer-events: none; font-family: 'Inter', system-ui, sans-serif;",
          span(class = "conn-dot", style = "width: 10px; height: 10px; border-radius: 50%; background: #22c55e; display: inline-block; flex-shrink: 0;"),
          span(class = "conn-text", "")
      ),
      
      # ── Onboarding hint widget ───────────────────────────────────────────────
      # Appears top-right (next to edit-mode controls) on first landing in studio.
      # Shows "Onboarding" label for 5s then collapses to a small icon.
      # Click navigates back to the onboarding route.
      # (widget is rendered inside preview-toolbar-right; this script finds it by ID)
      tags$script(HTML("
    // Auto-minimize hint widget after 5s
    (function() {
      function minimize() {
        var w = document.getElementById('ob-hint-widget');
        if (w) w.classList.add('minimized');
      }
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() { setTimeout(minimize, 5000); });
      } else {
        setTimeout(minimize, 5000);
      }
    })();
  "))
      ,
      # ── Onboarding view (hidden by default; toggled via showView message) ──────
      div(id = "onboarding-view", style = "display:none;",
        onboarding_ui(),
        # Override obOpenInStudio to use Shiny inputs (no page navigation needed).
        tags$script(HTML("
      window.INREP_ROUTER_MODE = true;
      function obOpenInStudio(answers) {
        if (typeof obSaveState === 'function') {
          obSaveState(answers || {});
        }
        var payload = obBuildStudioPayload(answers);
        if (window.Shiny && Shiny.setInputValue) {
          Shiny.setInputValue('ob_hydrate', JSON.stringify(payload), {priority:'event'});
          Shiny.setInputValue('ob_navigate_to_studio', Math.random(), {priority:'event'});
        }
      }
    "))
      )  # close: div(id="onboarding-view")
    ))  # close: tagList — route("/")
  )   # close: router_ui(...)
)

# ---------------------------------------------------------------------------
# Helper: generate display labels for response categories
# Mirrors inrep::get_response_labels() / generate_likert_labels() so the
# studio preview matches what participants actually see when the study runs.
# ---------------------------------------------------------------------------
studio_response_labels <- function(scale_type, n_choices, language = "en") {
  if (!scale_type %in% c("likert", "frequency", "difficulty")) {
    return(as.character(seq_len(n_choices)))
  }
  if (scale_type == "frequency") {
    if (language == "de") {
      switch(as.character(n_choices),
             "4" = c("Nie", "Manchmal", "H\u00e4ufig", "Immer"),
             "5" = c("Nie", "Selten", "Manchmal", "H\u00e4ufig", "Immer"),
             as.character(seq_len(n_choices)))
    } else if (language == "fa") {
      switch(as.character(n_choices),
             "4" = c("\u0647\u0631\u06af\u0632", "\u06af\u0627\u0647\u06cc", "\u0627\u063a\u0644\u0628", "\u0647\u0645\u06cc\u0634\u0647"),
             "5" = c("\u0647\u0631\u06af\u0632", "\u0628\u0647 \u0646\u062f\u0631\u062a", "\u06af\u0627\u0647\u06cc", "\u0627\u063a\u0644\u0628", "\u0647\u0645\u06cc\u0634\u0647"),
             as.character(seq_len(n_choices)))
    } else {
      switch(as.character(n_choices),
             "4" = c("Never", "Sometimes", "Often", "Always"),
             "5" = c("Never", "Rarely", "Sometimes", "Often", "Always"),
             as.character(seq_len(n_choices)))
    }
  } else {
    # likert
    if (language == "de") {
      switch(as.character(n_choices),
             "2" = c("Nein", "Ja"),
             "3" = c("Stimme nicht zu", "Neutral", "Stimme zu"),
             "4" = c("Stimme nicht zu", "Stimme eher nicht zu", "Stimme eher zu", "Stimme zu"),
             "5" = c("Stimme \u00fcberhaupt nicht zu", "Stimme eher nicht zu", "Teils, teils",
                     "Stimme eher zu", "Stimme voll und ganz zu"),
             "6" = c("Stimme \u00fcberhaupt nicht zu", "Stimme nicht zu", "Stimme eher nicht zu",
                     "Stimme eher zu", "Stimme zu", "Stimme voll und ganz zu"),
             "7" = c("Stimme \u00fcberhaupt nicht zu", "Stimme nicht zu", "Stimme eher nicht zu",
                     "Weder noch", "Stimme eher zu", "Stimme zu", "Stimme voll und ganz zu"),
             as.character(seq_len(n_choices)))
    } else if (language == "fa") {
      switch(as.character(n_choices),
             "2" = c("\u062e\u06cc\u0631", "\u0628\u0644\u0647"),
             "3" = c("\u0645\u062e\u0627\u0644\u0641\u0645", "\u062e\u0646\u062b\u06cc", "\u0645\u0648\u0627\u0641\u0642\u0645"),
             "4" = c("\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u0648\u0627\u0641\u0642\u0645", "\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u0648\u0627\u0641\u0642\u0645"),
             "5" = c("\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u062e\u0627\u0644\u0641\u0645", "\u0646\u0647 \u0645\u0648\u0627\u0641\u0642 \u0646\u0647 \u0645\u062e\u0627\u0644\u0641",
                     "\u0645\u0648\u0627\u0641\u0642\u0645", "\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u0648\u0627\u0641\u0642\u0645"),
             "6" = c("\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u062e\u0627\u0644\u0641\u0645", "\u062a\u0627 \u062d\u062f\u06cc \u0645\u062e\u0627\u0644\u0641\u0645",
                     "\u062a\u0627 \u062d\u062f\u06cc \u0645\u0648\u0627\u0641\u0642\u0645", "\u0645\u0648\u0627\u0641\u0642\u0645", "\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u0648\u0627\u0641\u0642\u0645"),
             "7" = c("\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u062e\u0627\u0644\u0641\u0645", "\u0645\u062e\u0627\u0644\u0641\u0645", "\u062a\u0627 \u062d\u062f\u06cc \u0645\u062e\u0627\u0644\u0641\u0645",
                     "\u0646\u0647 \u0645\u0648\u0627\u0641\u0642 \u0646\u0647 \u0645\u062e\u0627\u0644\u0641", "\u062a\u0627 \u062d\u062f\u06cc \u0645\u0648\u0627\u0641\u0642\u0645", "\u0645\u0648\u0627\u0641\u0642\u0645", "\u0643\u0627\u0645\u0644\u0627\u064b \u0645\u0648\u0627\u0641\u0642\u0645"),
             as.character(seq_len(n_choices)))
    } else {
      switch(as.character(n_choices),
             "2" = c("No", "Yes"),
             "3" = c("Disagree", "Neutral", "Agree"),
             "4" = c("Disagree", "Somewhat Disagree", "Somewhat Agree", "Agree"),
             "5" = c("Strongly Disagree", "Disagree", "Neutral", "Agree", "Strongly Agree"),
             "6" = c("Strongly Disagree", "Disagree", "Somewhat Disagree",
                     "Somewhat Agree", "Agree", "Strongly Agree"),
             "7" = c("Strongly Disagree", "Disagree", "Somewhat Disagree",
                     "Neither Agree nor Disagree", "Somewhat Agree", "Agree", "Strongly Agree"),
             as.character(seq_len(n_choices)))
    }
  }
}

server <- function(input, output, session) {
  
  # \u2500\u2500 shiny.router \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500
  router_server()
  
  # \u2500\u2500 Onboarding server (sets up output$ob_screen, output$ob_footer, state) \u2500\u2500\u2500\u2500
  # All ob_* inputs/outputs live here; they coexist harmlessly with the studio.
  onboarding_attach(input, output, session)
  
  # Navigate to root (studio) when onboarding completes (set by overridden obOpenInStudio JS)
  observeEvent(input$ob_navigate_to_studio, {
    session$sendCustomMessage("showView", "studio")
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Navigate to onboarding route when the hint widget is clicked
  observeEvent(input$ob_navigate_back, {
    session$sendCustomMessage("showView", "onboarding")
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Note: session$allowReconnect("force") is intentionally NOT called.
  # It is silently no-op'd on shinyapps.io Free/Starter tiers. WebSocket loss
  # is treated as terminal; recovery relies on browser-side localStorage autosave.
  
  # ── Onboarding handoff ──────────────────────────────────────────────────────
  # Called when the onboarding app (standalone or framed) passes its config.
  # Maps onboarding answer fields to studio input IDs.
  restore_from_onboarding <- function(session, ob) {
    # ob$study_name → study_name input
    if (!is.null(ob$study_name) && nzchar(ob$study_name %||% ""))
      updateTextInput(session, "study_name", value = ob$study_name)
    
    # ob$adaptive (bool) or ob$mode ("adaptive"/"fixed") → adaptive checkbox
    is_adaptive <- if (!is.null(ob$adaptive)) isTRUE(ob$adaptive)
    else identical(ob$mode, "adaptive")
    updateCheckboxInput(session, "adaptive", value = is_adaptive)
    
    # ob$irt_model or inferred from ob$domains[1]
    irt_model <- ob$irt_model %||% {
      dom <- if (!is.null(ob$`_ob_domains`) && length(ob$`_ob_domains`) > 0)
        ob$`_ob_domains`[[1]]
      else if (!is.null(ob$domains) && length(ob$domains) > 0)
        ob$domains[[1]]
      else "personality"
      if (dom %in% c("cognitive", "math")) "2PL" else "GRM"
    }
    updateSelectInput(session, "irt_model", selected = irt_model)
    
    # Primary language + participant languages for preview lang switch
    part_langs_raw <- ob$`_ob_part_langs` %||% ob$part_langs %||% list()
    part_langs_vec <- unique(unlist(part_langs_raw))
    if (length(part_langs_vec) > 0) preview_langs(part_langs_vec)
    
    primary_lang <- ob$primary_lang %||% {
      if (length(part_langs_vec) > 0) part_langs_vec[[1]]
      else ob$ui_lang %||% ob$`_ob_ui_lang` %||% "en"
    }
    updateSelectInput(session, "primary_lang", selected = primary_lang)
    
    # Max items from onboarding
    ob_max <- ob$`_ob_max_items` %||% ob$max_items
    if (!is.null(ob_max) && !is.na(as.integer(ob_max)) && as.integer(ob_max) > 0)
      updateNumericInput(session, "max_items", value = as.integer(ob_max))
    
    # _ob_n_pages → number of item pages in pages() preview
    ob_n_pages_raw <- ob$`_ob_n_pages`
    if (!is.null(ob_n_pages_raw)) {
      ob_n_pages <- max(1L, as.integer(ob_n_pages_raw))
      pgs <- pages()
      is_item    <- vapply(pgs, function(p) isTRUE(p$type == "items"),   logical(1))
      is_results <- vapply(pgs, function(p) isTRUE(p$type == "results"), logical(1))
      item_pgs   <- pgs[is_item]
      results_pgs <- pgs[is_results]
      other_pgs  <- pgs[!is_item & !is_results]
      
      if (ob_n_pages > length(item_pgs)) {
        for (i in seq(length(item_pgs) + 1L, ob_n_pages)) {
          nid <- paste0("page_items_", i)
          item_pgs[[nid]] <- list(
            id = nid, type = "items",
            title = paste0("Questionnaire ", i),
            scale_type = "likert", items = character(0)
          )
        }
      } else if (ob_n_pages < length(item_pgs)) {
        item_pgs <- item_pgs[seq_len(ob_n_pages)]
      }
      pages(c(other_pgs, item_pgs, results_pgs))
    }
    
    # ob$_ob_report_page ("yes"/"no") → show_debriefing checkbox + pages() structure
    if (!is.null(ob$`_ob_report_page`)) {
      updateCheckboxInput(session, "show_debriefing",
                          value = !identical(ob$`_ob_report_page`, "no"))
      pgs <- pages()
      if (identical(ob$`_ob_report_page`, "no")) {
        pgs <- pgs[!sapply(pgs, function(p) isTRUE(p$type == "results"))]
        pages(pgs)
      } else if (!any(sapply(pgs, function(p) isTRUE(p$type == "results")))) {
        new_id <- paste0("page", length(pgs) + 1L)
        pgs[[new_id]] <- list(
          id = new_id, type = "results", title = "Your Results",
          show_radar_chart = TRUE, show_scale_scores = TRUE,
          results_text_de = "Thank you for your participation! Your responses have been successfully saved.",
          results_text_en = "Thank you for your participation! Your responses have been successfully saved.",
          report_metrics = list()
        )
        pages(pgs)
      }
    }
    
    # Welcome notification
    name_str <- ob$`_ob_name` %||% ob$name %||% ""
    greeting  <- if (nzchar(name_str)) paste0(", ", name_str) else ""
    showNotification(
      paste0("Welcome to inrep\u2011studio", greeting,
             "! Your study has been pre-configured from onboarding."),
      type = "message", duration = 8
    )
  }
  
  # Observe onboarding payload (both URL-hash and postMessage channels inject ob_hydrate)
  observeEvent(input$ob_hydrate, {
    ob_data <- tryCatch(
      jsonlite::fromJSON(input$ob_hydrate, simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (!is.null(ob_data)) restore_from_onboarding(session, ob_data)
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  
  
  # Cycle preview language when lang switch button clicked (2+ langs active)
  observeEvent(input$lang_switch_click, {
    langs <- preview_langs()
    if (length(langs) < 2) return()
    current   <- input$primary_lang %||% langs[[1]]
    idx       <- match(current, langs)
    next_lang <- langs[[if (is.na(idx) || idx >= length(langs)) 1L else idx + 1L]]
    updateSelectInput(session, "primary_lang", selected = next_lang)
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Show add-language modal when lang button clicked with only 1 language
  observeEvent(input$lang_add_click, {
    current  <- preview_langs()
    all_langs <- c("en" = "English", "de" = "German", "es" = "Spanish", "fr" = "French")
    available <- all_langs[!names(all_langs) %in% current]
    showModal(modalDialog(
      title = tagList(
        HTML('<svg width="14" height="14" viewBox="0 0 16 16" fill="none" style="margin-right:6px;vertical-align:middle;"><circle cx="8" cy="8" r="6.5" stroke="currentColor" stroke-width="1.3"/><path d="M1.5 8h13M8 1.5c2 2.2 2 10.8 0 13M8 1.5C6 3.7 6 12.3 8 14.5" stroke="currentColor" stroke-width="1.3"/></svg>'),
        "Add Participant Language"
      ),
      tags$p(class = "text-muted small mb-3",
             "Add a language to enable the in-preview language switcher."),
      div(class = "d-flex flex-column gap-2",
          lapply(seq_along(available), function(i) {
            code  <- names(available)[i]
            label <- available[[i]]
            actionButton(
              paste0("add_lang_btn_", code),
              tagList(tags$b(toupper(code)), " — ", label),
              class   = "btn btn-outline-secondary text-start",
              onclick = sprintf(
                "Shiny.setInputValue('add_lang_code','%s',{priority:'event'});$('.modal').modal('hide');",
                code)
            )
          })
      ),
      footer    = modalButton("Cancel"),
      easyClose = TRUE,
      size      = "s"
    ))
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Add new language to preview_langs() when user picks one from the modal
  observeEvent(input$add_lang_code, {
    req(input$add_lang_code)
    new_code <- input$add_lang_code
    current  <- preview_langs()
    if (!new_code %in% current) preview_langs(c(current, new_code))
    removeModal()
  }, ignoreInit = TRUE, ignoreNULL = TRUE)
  
  # Sync color pickers to the selected theme on session start (once, after flush).
  # NOTE: onFlushed callbacks are not reactive consumers in Shiny >= 1.7; any
  # reactive value access MUST be wrapped in isolate() to avoid the
  # "Can't access reactive value outside of reactive consumer" error.
  session$onFlushed(function() {
    cols <- get_preview_theme_css(isolate(input$theme) %||% "hildesheim")
    colourpicker::updateColourInput(session, "primary_color_override", value = cols$primary)
    colourpicker::updateColourInput(session, "accent_color_override",  value = cols$accent  %||% cols$primary)
    colourpicker::updateColourInput(session, "text_color_override",    value = cols$text)
  }, once = TRUE)
  
  items <- reactiveVal(data.frame(
    id = c("BFE_01", "BFE_02", "BFE_03", "BFN_01", "BFN_02", "PSQ_01", "PSQ_02"),
    Question_DE = c("Ich gehe aus mir heraus, bin gesellig.", "Ich bin eher ruhig und zurückhaltend.", 
                    "Ich bin begeisterungsfähig und kann andere leicht mitreißen.", 
                    "Ich bleibe auch in stressigen Situationen gelassen.", 
                    "Ich werde leicht nervös und unsicher.",
                    "Ich fühle mich gehetzt und unter Zeitdruck.", 
                    "Ich habe Schwierigkeiten, abzuschalten."),
    Question_EN = c("I am outgoing and sociable.", "I am rather quiet and reserved.", 
                    "I am enthusiastic and can easily inspire others.", 
                    "I remain calm even in stressful situations.",
                    "I get nervous and insecure easily.", 
                    "I feel rushed and under time pressure.", 
                    "I have difficulty switching off."),
    ResponseCategories = rep("1,2,3,4,5", 7),
    a = c(1.2, 1.1, 1.3, 1.0, 0.9, 1.1, 1.2),
    b = c(0.1, -0.2, 0.3, -0.1, 0.2, 0.4, 0.3),
    response_layout = rep("vertical", 7),
    stringsAsFactors = FALSE
  ))
  
  pages <- reactiveVal(list(
    "page1" = list(
      id = "page1", type = "custom", title = "Welcome Page",
      content_de = "<h1>Welcome to the Study</h1><p>Thank you for participating in this scientific survey.</p><p>Completion takes about 10-15 minutes. Please read each question carefully and answer spontaneously and honestly.</p><p><strong>Your data will be stored anonymously and used exclusively for research purposes.</strong></p>",
      content_en = "<h1>Welcome to the Study</h1><p>Thank you for participating in this scientific survey.</p><p>Completion takes about 10-15 minutes. Please read each question carefully and answer spontaneously and honestly.</p><p><strong>Your data will be stored anonymously and used exclusively for research purposes.</strong></p>",
      items = character(0)
    ),
    "page2" = list(
      id = "page2", type = "demographics", title = "Demographics",
      items = character(0),
      demo_fields = list(
        list(name = "age", label_de = "Age (in years)", label_en = "Age (in years)", type = "number", required = TRUE),
        list(name = "gender", label_de = "Gender", label_en = "Gender", type = "select", required = TRUE,
             options_de = c("Male", "Female", "Diverse", "Prefer not to say"),
             options_en = c("Male", "Female", "Diverse", "Prefer not to say")),
        list(name = "education", label_de = "Highest Education Level", label_en = "Highest Education Level", 
             type = "select", required = FALSE,
             options_de = c("Secondary School", "High School", "A-levels", "Bachelor", "Master", "PhD"),
             options_en = c("Secondary School", "High School", "A-levels", "Bachelor", "Master", "PhD"))
      )
    ),
    "page3" = list(
      id = "page3", type = "items", title = "Questionnaire",
      scale_type = "likert", items = c("BFE_01", "BFE_02", "BFE_03")
    ),
    "page4" = list(
      id = "page4", type = "results", title = "Your Results",
      show_radar_chart = TRUE,
      show_scale_scores = TRUE,
      results_text_de = "Thank you for your participation! Your responses have been successfully saved.",
      results_text_en = "Thank you for your participation! Your responses have been successfully saved.",
      report_metrics = list(
        list(
          name = "Extraversion",
          items = c("BFE_01", "BFE_02", "BFE_03"),
          expr = "mean(items_vec, na.rm = TRUE)"
        )
      )
    )
  ))
  
  current_page <- reactiveVal("page1")
  selected_item <- reactiveVal(NULL)
  preview_langs <- reactiveVal(c("en"))
  
  js_error_notified <- reactiveVal(FALSE)
  
  # Log forwarded browser-side JS errors (often localized) to the R console
  observeEvent(input$js_error, {
    if (!isTRUE(INREP_STUDIO_DEBUG)) return(NULL)
    
    info <- input$js_error
    msg <- info$message %||% "(no message)"
    typ <- info$type %||% "(no type)"
    cat("\n[JS ERROR] type=", typ, " message=", msg, "\n", sep = "")
    if (!is.null(info$filename)) cat("  file: ", info$filename, "\n", sep = "")
    if (!is.null(info$lineno) || !is.null(info$colno)) cat("  at: ", info$lineno, ":", info$colno, "\n", sep = "")
    if (!is.null(info$stack)) cat("  stack:\n", info$stack, "\n", sep = "")
    
    # Show only the first JS error to the user (avoid notification spam).
    if (!isTRUE(js_error_notified())) {
      js_error_notified(TRUE)
      loc <- NULL
      if (!is.null(info$filename) || !is.null(info$lineno)) {
        loc <- paste0(
          if (!is.null(info$filename)) as.character(info$filename) else "(inline)",
          if (!is.null(info$lineno)) paste0(":", info$lineno) else "",
          if (!is.null(info$colno)) paste0(":", info$colno) else ""
        )
      }
      details <- paste0(
        "Browser JavaScript error: ", msg,
        if (!is.null(loc)) paste0("\nLocation: ", loc) else ""
      )
      showNotification(details, type = "error", duration = 30)
    }
  }, ignoreInit = TRUE)
  
  # Update mode indicator when switch changes
  observeEvent(input$mode_switch, {
    session$sendCustomMessage("updateMode", isTRUE(input$mode_switch))
  })
  
  # Get theme colors for preview
  get_theme_colors <- reactive({
    theme <- input$theme %||% "hildesheim"
    get_preview_theme_css(theme)
  })
  
  # Color overrides - stores custom colors for individual elements and pages
  color_overrides <- reactiveVal(list(
    primary = NULL,      # global primary color override
    accent = NULL,       # global accent color override
    text = NULL,         # global text color override
    element_colors = list()  # element-specific colors: list(page_id = list(element_id = color))
  ))
  
  # Get effective theme colors (theme + overrides)
  get_effective_colors <- reactive({
    base_colors <- get_theme_colors()
    overrides <- color_overrides()
    curr_page <- current_page()
    
    # Apply global overrides if set
    if (!is.null(overrides$primary)) base_colors$primary <- overrides$primary
    if (!is.null(overrides$accent)) base_colors$accent <- overrides$accent
    if (!is.null(overrides$text)) base_colors$text <- overrides$text
    
    # Apply element-specific overrides for current page (including progress bar)
    if (!is.null(curr_page) && !is.null(overrides$element_colors[[curr_page]])) {
      page_colors <- overrides$element_colors[[curr_page]]
      # If progress color is overridden for this page, use it as primary
      if (!is.null(page_colors$progress)) {
        base_colors$primary <- page_colors$progress
      }
    }
    
    base_colors
  })
  
  # Handle color override inputs (debounced to avoid rapid re-renders during color dragging)
  # NOTE: No isolate/bounce needed — get_effective_colors() depends on color_overrides(),
  # and output$page_content depends on get_effective_colors(), so Shiny auto-re-renders.
  primary_color_d <- debounce(reactive(input$primary_color_override), 300)
  accent_color_d <- debounce(reactive(input$accent_color_override), 300)
  text_color_d <- debounce(reactive(input$text_color_override), 300)
  
  observeEvent(primary_color_d(), {
    ov <- color_overrides()
    ov$primary <- primary_color_d()
    color_overrides(ov)
  }, ignoreInit = TRUE)
  
  observeEvent(accent_color_d(), {
    ov <- color_overrides()
    ov$accent <- accent_color_d()
    color_overrides(ov)
  }, ignoreInit = TRUE)
  
  observeEvent(text_color_d(), {
    ov <- color_overrides()
    ov$text <- text_color_d()
    color_overrides(ov)
  }, ignoreInit = TRUE)
  
  # Reset individual colors to theme
  observeEvent(input$reset_primary_color, {
    ov <- color_overrides()
    ov$primary <- NULL
    color_overrides(ov)
    colourpicker::updateColourInput(session, "primary_color_override", value = get_theme_colors()$primary)
  })
  
  observeEvent(input$reset_accent_color, {
    ov <- color_overrides()
    ov$accent <- NULL
    color_overrides(ov)
    colourpicker::updateColourInput(session, "accent_color_override", value = get_theme_colors()$accent)
  })
  
  observeEvent(input$reset_text_color, {
    ov <- color_overrides()
    ov$text <- NULL
    color_overrides(ov)
    colourpicker::updateColourInput(session, "text_color_override", value = get_theme_colors()$text)
  })
  
  # Apply colors to all pages
  observeEvent(input$apply_colors_all_pages, {
    pgs <- pages()
    new_color_map <- list()
    
    # Replace all occurrences of old primary color with new one in all pages
    for (page_id in names(pgs)) {
      pg <- pgs[[page_id]]
      
      # Store element color overrides per page
      if (!page_id %in% names(new_color_map)) {
        new_color_map[[page_id]] <- list()
      }
    }
    
    # Update color overrides with the new mapping
    ov <- color_overrides()
    ov$element_colors <- new_color_map
    color_overrides(ov)
    
    showNotification("Colors applied to all pages", type = "message", duration = 3)
  })
  
  # Reset all colors to theme
  observeEvent(input$reset_all_colors, {
    color_overrides(list(
      primary = NULL,
      accent = NULL,
      text = NULL,
      element_colors = list()
    ))
    
    theme_cols <- get_theme_colors()
    colourpicker::updateColourInput(session, "primary_color_override", value = theme_cols$primary)
    colourpicker::updateColourInput(session, "accent_color_override", value = theme_cols$accent)
    colourpicker::updateColourInput(session, "text_color_override", value = theme_cols$text)
    
    showNotification("All colors reset to theme", type = "message", duration = 3)
  })
  
  output$page_navigation <- renderUI({
    pgs <- pages()
    curr <- current_page()
    is_edit <- isTRUE(input$mode_switch)  # Switch ON = Edit mode
    
    page_icons <- list(
      custom = bs_icon("file-text"),
      demographics = bs_icon("person-badge"),
      items = bs_icon("list-check"),
      results = bs_icon("graph-up")
    )
    
    # Check for page order issues
    page_types <- sapply(pgs, function(p) p$type)
    items_positions <- which(page_types == "items")
    results_positions <- which(page_types == "results")
    
    # Determine if results is before last items page
    results_before_items <- length(results_positions) > 0 && length(items_positions) > 0 &&
      min(results_positions) < max(items_positions)
    
    # Results not at end warning
    results_not_last <- length(results_positions) > 0 && max(results_positions) < length(pgs)
    
    tagList(lapply(seq_along(pgs), function(i) {
      pid <- names(pgs)[i]
      pg <- pgs[[pid]]
      page_title <- pg$title
      if(is.null(page_title) || page_title == "") page_title <- paste("Page", i)
      
      icon_class <- pg$type %||% "custom"
      
      # Check if this page has a warning
      has_warning <- FALSE
      warning_title <- ""
      if(pg$type == "results") {
        if(results_before_items) {
          has_warning <- TRUE
          warning_title <- "Results shown before all items - responses may be incomplete"
        } else if(results_not_last && i %in% results_positions) {
          has_warning <- TRUE
          warning_title <- "Results not at end - data after this page may not be saved"
        }
      }
      
      div(class = paste("page-nav-item", if(pid == curr) "active" else "", if(has_warning && is_edit) "has-warning" else ""),
          `data-page-id` = pid,
          onclick = sprintf("Shiny.setInputValue('nav_to_page', '%s', {priority: 'event'})", pid),
          # Drag handle — always rendered so block width is identical in both modes.
          # CSS shows/hides it via body.edit-mode-active.
          div(class = "page-drag-handle", bs_icon("grip-vertical")),
          div(class = paste("page-nav-icon", icon_class), page_icons[[icon_class]] %||% bs_icon("file")),
          div(class = "page-nav-text",
              div(class = "page-nav-title", page_title),
              div(class = "page-nav-type", pg$type)
          ),
          # Warning indicator — position:absolute, doesn't affect block size
          if(has_warning && is_edit) span(class = "page-warning-badge", title = warning_title, bs_icon("exclamation-triangle")),
          # Order badge — always rendered (position:absolute), CSS hides in preview mode
          span(class = "page-order-badge", i)
      )
    }))
  })
  
  observeEvent(input$nav_to_page, { 
    current_page(input$nav_to_page)
    selected_item(NULL)
  })
  
  # Progress style edit button clicked in preview header — open a modal to choose
  observeEvent(input$progress_style_add_click, {
    showModal(modalDialog(
      title = "Progress Indicator",
      tags$p(class = "text-muted small mb-3",
             "Choose how inrep shows participants their progress through the study."),
      div(class = "d-flex flex-column gap-3",
          actionButton("set_progress_none",   tagList(bs_icon("x-circle"),   " None (hidden)"),  class = "btn btn-outline-secondary text-start"),
          actionButton("set_progress_bar",    tagList(bs_icon("bar-chart-line"), " Progress bar"),    class = "btn btn-outline-primary text-start"),
          actionButton("set_progress_circle", tagList(bs_icon("circle-half"), " Progress ring"),  class = "btn btn-outline-primary text-start")
      ),
      footer = modalButton("Cancel"),
      size = "s", easyClose = TRUE
    ))
  }, ignoreInit = TRUE)
  
  observeEvent(input$set_progress_none, {
    updateSelectInput(session, "progress_style", selected = "none")
    removeModal()
  }, ignoreInit = TRUE)
  observeEvent(input$set_progress_bar, {
    updateSelectInput(session, "progress_style", selected = "bar")
    removeModal()
  }, ignoreInit = TRUE)
  observeEvent(input$set_progress_circle, {
    updateSelectInput(session, "progress_style", selected = "circle")
    removeModal()
  }, ignoreInit = TRUE)
  
  # When theme changes, update color pickers to show the new theme's defaults
  # and reset custom overrides so the preview immediately reflects the new theme.
  # NOTE: No bouncing needed — get_theme_colors() depends on input$theme,
  # and output$page_content depends on get_effective_colors() which depends on
  # get_theme_colors(). Shiny auto-invalidates the entire chain.
  observeEvent(input$theme, {
    theme_cols <- get_theme_colors()
    # Reset overrides so the new theme is shown cleanly
    color_overrides(list(
      primary = NULL,
      accent = NULL,
      text = NULL,
      element_colors = color_overrides()$element_colors  # preserve element colors
    ))
    # Defer color picker updates until after the current flush cycle so the
    # colourpicker JS bindings are guaranteed to be registered. On shinyapps.io
    # with high latency, firing immediately can drop the message.
    local({
      cols <- theme_cols
      session$onFlushed(function() {
        colourpicker::updateColourInput(session, "primary_color_override", value = cols$primary)
        colourpicker::updateColourInput(session, "accent_color_override",  value = cols$accent)
        colourpicker::updateColourInput(session, "text_color_override",    value = cols$text)
      }, once = TRUE)
    })
    
    # Push scoped CSS directly into <head> via JS — reliable on all platforms.
    # The JS handler queues any message that arrives before sessioninitialized.
    theme_key <- normalize_inrep_theme_key(input$theme %||% "hildesheim")
    raw_css <- read_inrep_theme_css(theme_key)
    scoped <- if (is.null(raw_css)) "" else scope_css_for_preview(raw_css)
    session$sendCustomMessage("updatePreviewThemeCss", list(css = scoped))
    
    # Also push --preview-* CSS variables directly onto .study-preview so the
    # Studio chrome (header background, nav button colors) updates immediately.
    session$sendCustomMessage("updatePreviewVars", list(
      "--preview-primary" = theme_cols$primary,
      "--preview-accent"  = theme_cols$accent %||% theme_cols$primary,
      "--preview-bg"      = theme_cols$bg,
      "--preview-text"    = theme_cols$text,
      "--preview-border"  = theme_cols$border,
      "--preview-shadow"  = theme_cols$card_shadow %||% "0 2px 8px rgba(0,0,0,0.04)",
      "--preview-font-family" = theme_cols$font_family %||% "'Inter', -apple-system, BlinkMacSystemFont, sans-serif"
    ))
  }, ignoreInit = FALSE)
  
  # NOTE: input$progress_style, input$response_ui_type, input$study_name,
  # and input$primary_lang are all read directly inside output$page_content's
  # renderUI, so Shiny automatically re-renders when they change.
  # No observeEvent bounce handlers needed.
  
  output$page_content <- renderUI({
    pgs <- pages()
    curr <- current_page()
    pg <- pgs[[curr]]
    theme_colors <- get_effective_colors()
    if(is.null(pg)) {
      return(div(class = "study-preview", style = "display: flex; align-items: center; justify-content: center; min-height: 400px;",
                 div(class = "text-center text-muted",
                     bs_icon("folder2-open", size = "3rem", class = "opacity-25 mb-3"),
                     p("No page selected", class = "mb-0")
                 )
      ))
    }
    
    is_edit <- isTRUE(input$mode_switch)  # Switch ON = Edit mode
    lang <- input$primary_lang %||% "en"
    study_name <- input$study_name %||% "Study"
    
    # Calculate progress
    page_idx <- which(names(pgs) == curr)
    total_pages <- length(pgs)
    progress_pct <- round((page_idx / total_pages) * 100)
    
    # Theme CSS variables (mapped from real inrep theme files)
    theme_style <- sprintf("
      --preview-primary: %s;
      --preview-accent: %s;
      --preview-bg: %s;
      --preview-text: %s;
      --preview-border: %s;
      --preview-shadow: %s;
      --preview-font-family: %s;
      --preview-gray: #666;
      --preview-light: #f5f5f5;
    ",
                           theme_colors$primary,
                           theme_colors$accent %||% theme_colors$primary,
                           theme_colors$bg,
                           theme_colors$text,
                           theme_colors$border,
                           theme_colors$card_shadow %||% "0 2px 8px rgba(0,0,0,0.04)",
                           theme_colors$font_family %||% "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
    )
    
    # Deployment-safe fallback: keep scoped theme CSS inside renderUI as well.
    # On slower hosted environments (e.g., shinyapps.io), JS head updates can race
    # with DOM replacement; this guarantees the new preview always receives CSS.
    scoped_css <- tryCatch({
      theme_key <- normalize_inrep_theme_key(input$theme %||% "hildesheim")
      raw_css <- read_inrep_theme_css(theme_key)
      if (is.null(raw_css)) "" else scope_css_for_preview(raw_css)
    }, error = function(e) "")
    
    # Build preview content based on page type
    preview_content <- if(pg$type == "custom") {
      # Get the page title and content
      page_title <- pg$title %||% ""
      content <- if(lang == "de") {
        pg$content_de %||% pg$content_en %||% ""
      } else {
        pg$content_en %||% pg$content_de %||% ""
      }
      
      # In edit mode, make content editable inline
      if(is_edit) {
        # Editable custom page with rich text toolbar
        div(
          # Editable title
          if(page_title != "") {
            h1(class = "study-heading editable-content",
               `data-field` = if(lang == "de") "title" else "title_en",
               `data-page-id` = curr,
               contenteditable = "true",
               page_title)
          },
          
          # Rich Text Toolbar (appears in edit mode)
          div(class = "rich-text-toolbar",
              # Text formatting
              tags$button(class = "rte-btn", type = "button", title = "Bold (Ctrl+B)",
                          `data-command` = "bold", onclick = "formatText('bold')",
                          tags$b("B")),
              tags$button(class = "rte-btn", type = "button", title = "Italic (Ctrl+I)",
                          `data-command` = "italic", onclick = "formatText('italic')",
                          tags$i("I")),
              tags$button(class = "rte-btn", type = "button", title = "Underline (Ctrl+U)",
                          `data-command` = "underline", onclick = "formatText('underline')",
                          tags$u("U")),
              tags$button(class = "rte-btn", type = "button", title = "Strikethrough",
                          `data-command` = "strikeThrough", onclick = "formatText('strikeThrough')",
                          tags$s("S")),
              
              # Separator
              
              span(class = "rte-separator"),
              # Headings
              tags$button(class = "rte-btn", type = "button", title = "Heading 1",
                          onclick = "formatText('formatBlock', '<h1>')",
                          "H1"),
              tags$button(class = "rte-btn", type = "button", title = "Heading 2",
                          onclick = "formatText('formatBlock', '<h2>')",
                          "H2"),
              # Link
              tags$button(class = "rte-btn", type = "button", title = "Insert Link",
                          onclick = "insertLink()",
                          bs_icon("link")),
              
              # Clear formatting
              tags$button(class = "rte-btn", type = "button", title = "Clear Formatting",
                          onclick = "clearFormatting()",
                          bs_icon("eraser"))
          ),
          
          # Editable content area with rich-text-content class
          div(class = "editable-content rich-text-content study-text",
              `data-field` = if(lang == "de") "content_de" else "content_en",
              `data-page-id` = curr,
              contenteditable = "true",
              if(content == "") {
                tags$span(style = "color: #999;", "Click here to add content. Use the toolbar above to format text.")
              } else {
                HTML(content)
              }
          )
        )
      } else {
        # Preview mode - static display
        if(content == "") {
          div(class = "text-center py-5", style = "color: #999;", 
              "No content configured for this page")
        } else {
          div(
            # Use real inrep classes: .card-header for title, .welcome-text for paragraphs
            if(page_title != "") h3(class = "card-header", page_title),
            HTML(gsub("<p>", "<p class='welcome-text'>", content))
          )
        }
      }
      
    } else if(pg$type == "demographics") {
      demo_fields <- pg$demo_fields
      if(is.null(demo_fields) || length(demo_fields) == 0) {
        div(class = "text-center py-5",
            bs_icon("person-plus", size = "2.5rem", class = "opacity-25 mb-3"),
            p(class = "text-muted", "No demographic fields configured"),
            if(is_edit) actionButton("add_demo_field", "Add Field", class = "btn btn-outline-primary btn-sm mt-2")
        )
      } else {
        div(
          h3(class = "card-header", style = "font-size: 1.5rem;",
             if(lang == "de") "Demografische Angaben" else "Demographic Information"),
          lapply(seq_along(demo_fields), function(field_idx) {
            field <- demo_fields[[field_idx]]
            field_name <- field$name %||% paste0("field_", field_idx)
            label_text <- if(lang == "de") field$label_de else field$label_en
            if(is.null(label_text) || label_text == "") label_text <- field_name
            
            # In edit mode, make labels editable
            if(is_edit) {
              div(class = "demo-field-preview demo-field-editable",
                  `data-field-idx` = field_idx,
                  `data-field-name` = field_name,
                  style = "position: relative; border: 1px dashed #ccc; padding: 10px; border-radius: 4px; margin-bottom: 12px;",
                  tags$label(class = "demo-label-preview editable-content",
                             `data-field` = "label_text",
                             `data-field-idx` = field_idx,
                             `data-page-id` = curr,
                             `data-lang` = lang,
                             contenteditable = "true",
                             onblur = sprintf("Shiny.setInputValue('edit_demo_field', {fieldIdx: %d, field: 'label_text', lang: '%s', value: this.innerText}, {priority: 'event'})", field_idx, lang),
                             style = "cursor: text; padding: 4px; border-bottom: 1px solid #2563eb;",
                             label_text,
                             if(isTRUE(field$required)) span(class = "required", " *") else NULL
                  ),
                  div(class = "mt-2",
                      if(field$type == "number") {
                        tags$input(type = "number", class = "demo-input-preview form-control", 
                                   placeholder = if(lang == "de") "Bitte eingeben..." else "Please enter...",
                                   style = "background: var(--preview-light);")
                      } else if(field$type == "select") {
                        options_list <- if(lang == "de") field$options_de else field$options_en
                        if(is.null(options_list)) options_list <- c("Option 1", "Option 2")
                        tags$select(class = "demo-input-preview form-control",
                                    style = "background: var(--preview-light);",
                                    tags$option(value = "", if(lang == "de") "Bitte auswählen..." else "Please select..."),
                                    lapply(options_list, function(opt) tags$option(opt))
                        )
                      } else {
                        tags$input(type = "text", class = "demo-input-preview form-control",
                                   placeholder = if(lang == "de") "Bitte eingeben..." else "Please enter...",
                                   style = "background: var(--preview-light);")
                      }
                  ),
                  # Edit/Delete buttons
                  div(class = "mt-2",
                      style = "display: flex; gap: 8px; font-size: 0.85rem;",
                      tags$button(class = "btn btn-sm btn-outline-primary",
                                  onclick = sprintf("event.stopPropagation(); Shiny.setInputValue('edit_demo_field_settings', {fieldIdx: %d}, {priority: 'event'})", field_idx),
                                  bs_icon("gear"), " Settings"),
                      tags$button(class = "btn btn-sm btn-outline-danger",
                                  onclick = sprintf("event.stopPropagation(); Shiny.setInputValue('delete_demo_field', {fieldIdx: %d}, {priority: 'event'})", field_idx),
                                  bs_icon("trash"), " Delete")
                  )
              )
            } else {
              # Preview mode — use real inrep .form-group / .input-label / .form-control classes
              div(class = "form-group",
                  tags$label(class = "input-label",
                             label_text,
                             if(isTRUE(field$required)) span(class = "required", " *") else NULL
                  ),
                  if(field$type == "number") {
                    tags$input(type = "number", class = "form-control",
                               placeholder = if(lang == "de") "Bitte eingeben..." else "Please enter...")
                  } else if(field$type == "select") {
                    options_list <- if(lang == "de") field$options_de else field$options_en
                    if(is.null(options_list)) options_list <- c("Option 1", "Option 2")
                    tags$select(class = "form-control",
                                tags$option(value = "", if(lang == "de") "Bitte auswählen..." else "Please select..."),
                                lapply(options_list, function(opt) tags$option(opt))
                    )
                  } else {
                    tags$input(type = "text", class = "form-control",
                               placeholder = if(lang == "de") "Bitte eingeben..." else "Please enter...")
                  }
              )
            }
          })
        )
      }
      
      
    } else if(pg$type == "items") {
      itb <- items()
      page_items <- pg$items
      
      if(is.null(page_items) || length(page_items) == 0) {
        div(class = "text-center py-5",
            bs_icon("list-ul", size = "2.5rem", class = "opacity-25 mb-3"),
            p(class = "text-muted", "No items on this page"),
            p(class = "small text-muted", "Click items in the repository to add them →")
        )
      } else {
        scale_type <- pg$scale_type %||% "likert"
        
        tagList(
          if(!is.null(pg$instructions) && pg$instructions != "") {
            div(class = "study-callout mb-4",
                HTML(if(lang == "de") pg$instructions else (pg$instructions_en %||% pg$instructions))
            )
          },
          lapply(page_items, function(iid) {
            item_row <- itb[itb$id == iid, , drop = FALSE]
            if(nrow(item_row) == 0) {
              return(div(class = "preview-item", style = "border-color: #f87171;",
                         p(class = "text-danger small mb-0", paste("Item", iid, "not found in repository"))))
            }
            
            # Detect if this item is currently selected and being edited in the Properties
            # panel. If so, use live input values so the preview updates in real-time.
            sel_item <- selected_item()
            is_selected <- !is.null(sel_item) && sel_item == iid
            
            question_text <- if(is_selected && !is.null(input$edit_item_q_de)) {
              if(lang == "de") {
                live <- input$edit_item_q_de
                if(!is.null(live) && nzchar(live)) live else (input$edit_item_q_en %||% iid)
              } else {
                live <- input$edit_item_q_en
                if(!is.null(live) && nzchar(live)) live else (input$edit_item_q_de %||% iid)
              }
            } else if(lang == "de") {
              item_row$Question_DE %||% item_row$Question_EN %||% item_row$Question %||% iid
            } else {
              item_row$Question_EN %||% item_row$Question_DE %||% item_row$Question %||% iid
            }
            if(is.na(question_text) || question_text == "") question_text <- iid
            
            resp_raw <- if(is_selected && !is.null(input$edit_item_resp)) {
              input$edit_item_resp
            } else {
              as.character(item_row$ResponseCategories %||% "1,2,3,4,5")
            }
            if(is.na(resp_raw) || !nzchar(resp_raw)) resp_raw <- "1,2,3,4,5"
            resp_cats <- trimws(strsplit(resp_raw, ",")[[1]])
            # Generate proper display labels matching what inrep shows to participants
            resp_labels <- studio_response_labels(scale_type, length(resp_cats), lang)
            
            # Calculate item position for move buttons
            item_pos <- which(page_items == iid)
            is_first <- item_pos == 1
            is_last <- item_pos == length(page_items)
            
            div(class = paste("preview-item", if(is_selected) "selected" else "", if(is_edit) "preview-item-editable" else ""),
                `data-item-id` = iid,
                onclick = if(is_edit) sprintf("Shiny.setInputValue('edit_item', '%s', {priority: 'event'})", iid) else "",
                style = if(is_edit) "cursor: pointer; position: relative;" else "",
                
                # Action buttons (visible in edit mode on hover)
                if(is_edit) {
                  div(class = "item-actions",
                      tags$button(class = "item-action-btn edit-btn", 
                                  onclick = sprintf("event.stopPropagation(); editItemInline('%s')", iid),
                                  title = "Edit item details", bs_icon("pencil")),
                      if(!is_first) tags$button(class = "item-action-btn move-up", 
                                                onclick = sprintf("event.stopPropagation(); moveItemUp('%s')", iid),
                                                title = "Move up", bs_icon("chevron-up")),
                      if(!is_last) tags$button(class = "item-action-btn move-down",
                                               onclick = sprintf("event.stopPropagation(); moveItemDown('%s')", iid),
                                               title = "Move down", bs_icon("chevron-down")),
                      tags$button(class = "item-action-btn delete",
                                  onclick = sprintf("event.stopPropagation(); removeItemFromPage('%s')", iid),
                                  title = "Remove", bs_icon("x-lg"))
                  )
                },
                
                # Drag handle (visible in edit mode)
                if(is_edit) {
                  div(class = "drag-handle", style = "position: absolute; left: 4px; top: 50%; transform: translateY(-50%);",
                      bs_icon("grip-vertical"))
                },
                
                # Item content with inline editable question (edit mode)
                div(class = "d-flex justify-content-between align-items-start mb-2", style = if(is_edit) "margin-left: 20px;" else "",
                    if(is_edit) {
                      div(class = "editable-content preview-item-question",
                          `data-field` = if(lang == "de") "question_de" else "question_en",
                          `data-item-id` = iid,
                          contenteditable = "true",
                          onclick = "event.stopPropagation();",
                          question_text)
                    } else {
                      # Use .question-text matching real inrep question display
                      div(class = "question-text", question_text)
                    },
                    if(is_edit) span(class = "badge bg-light text-dark", style = "font-family: monospace;", iid)
                ),
                
                # Response scale — per-item layout overrides the global default.
                # item_layout: "vertical" (default), "horizontal_all", "horizontal_endpoints"
                {
                  # Detect free-text item type (live from properties panel or from data)
                  item_type_val <- if (is_selected && !is.null(input$edit_item_type)) {
                    input$edit_item_type
                  } else {
                    as.character(item_row$item_type %||% "irt")
                  }
                  is_free_text_item <- identical(item_type_val, "free_text")
                  
                  response_type <- input$response_ui_type %||% "radio"
                  
                  # Per-item layout: read from item data, fall back to global setting
                  item_layout <- {
                    if (is_selected && !is.null(input$edit_item_response_layout)) {
                      input$edit_item_response_layout
                    } else {
                      rl <- item_row$response_layout
                      if (!is.null(rl) && length(rl) > 0 && !is.na(rl) && nzchar(as.character(rl))) {
                        as.character(rl)
                      } else {
                        input$response_layout %||% "vertical"
                      }
                    }
                  }
                  
                  render_horizontal_scale <- function(endpoint_only) {
                    div(class = "preview-scale",
                        style = if(is_edit) "margin-left: 20px;" else "",
                        lapply(seq_along(resp_cats), function(i) {
                          show_label <- !endpoint_only || i == 1 || i == length(resp_cats)
                          div(class = "preview-scale-option",
                              div(class = "preview-scale-radio"),
                              div(class = if(show_label) "preview-scale-label" else "preview-scale-label preview-scale-label--hidden",
                                  if(show_label) resp_labels[i] else "\u00a0")
                          )
                        })
                    )
                  }
                  
                  render_vertical_scale <- function() {
                    # Vertical stacked preview using Studio-controlled markup.
                    # This avoids browser-specific native radio rendering issues on hosted deployments.
                    div(class = "preview-scale-vertical",
                        style = if(is_edit) "margin-left: 20px;" else "",
                        lapply(seq_along(resp_cats), function(i) {
                          div(class = "preview-scale-vertical-option",
                              div(class = "preview-scale-radio"),
                              div(class = "preview-scale-label", resp_labels[i])
                          )
                        })
                    )
                  }
                  
                  if (is_free_text_item) {
                    # Free-text item: render a textarea preview (non-interactive placeholder)
                    div(class = "preview-free-text",
                        style = paste0(
                          "margin:", if(is_edit) "4px 0 0 20px" else "8px 0 0", ";"),
                        tags$textarea(
                          class = "form-control",
                          style = "resize: vertical; min-height: 80px; font-size: 0.95rem; color: #888; border: 1.5px dashed #b0b8c1; background: #f8fafc; cursor: default;",
                          placeholder = if(lang == "de") "Freitext-Antwort …" else "Free text response …",
                          disabled = NA,
                          rows = "3"
                        ),
                        div(class = "small text-muted mt-1",
                            style = "font-size: 0.78rem;",
                            if(lang == "de") "Offen — kein IRT-Scoring" else "Open-ended — no IRT scoring")
                    )
                  } else if(response_type == "radio") {
                    if (item_layout == "horizontal_all") {
                      render_horizontal_scale(FALSE)
                    } else if (item_layout == "horizontal_endpoints") {
                      render_horizontal_scale(TRUE)
                    } else {
                      render_vertical_scale()
                    }
                  } else if(response_type == "slider") {
                    # Slider display
                    div(class = "preview-scale", style = if(is_edit) "margin-left: 20px;" else "margin: 16px 0;",
                        div(style = "display: flex; align-items: center; gap: 12px; padding: 8px 0;",
                            span(style = "font-size: 0.9rem; color: #666; min-width: 30px;", resp_cats[1]),
                            tags$input(type = "range", min = resp_cats[1], max = resp_cats[length(resp_cats)],
                                       style = "flex: 1; cursor: pointer;", value = resp_cats[ceiling(length(resp_cats)/2)]),
                            span(style = "font-size: 0.9rem; color: #666; min-width: 30px;", resp_cats[length(resp_cats)])
                        )
                    )
                  } else if(response_type == "dropdown") {
                    # Dropdown/select display
                    div(class = if(is_edit) "preview-scale" else "form-group",
                        style = if(is_edit) "margin-left: 20px;" else "margin: 8px 0;",
                        tags$select(
                          class = if (!is_edit) "form-control" else NULL,
                          style = if (is_edit) "width: 100%; padding: 8px 12px; border: 1px solid #ccc; border-radius: 4px; font-size: 0.95rem; cursor: pointer;" else NULL,
                          tags$option(value = "", if(lang == "de") "Bitte auswählen..." else "Please select..."),
                          lapply(resp_cats, function(cat) tags$option(value = cat, cat))
                        )
                    )
                  } else {
                    # Fallback: reuse layout logic
                    if (item_layout %in% c("horizontal_all", "horizontal_endpoints")) {
                      render_horizontal_scale(item_layout == "horizontal_endpoints")
                    } else {
                      render_vertical_scale()
                    }
                  }
                }
            )
          })
        )
      }
      
    } else if(pg$type == "results") {
      results_text <- if(lang == "de") pg$results_text_de else pg$results_text_en
      if(is.null(results_text) || results_text == "") {
        results_text <- if(lang == "de") "Vielen Dank für Ihre Teilnahme!" else "Thank you for your participation!"
      }
      
      # Get scales/metrics for visualization
      metrics <- pg$report_metrics
      itb <- items()
      
      # Use effective colors (respects user overrides from color pickers)
      effective_colors <- get_effective_colors()
      theme_accent <- effective_colors$accent %||% effective_colors$primary %||% "#3498db"
      theme_primary <- effective_colors$primary %||% "#3498db"
      theme_text <- effective_colors$text %||% "#1f2937"
      theme_border <- effective_colors$border %||% "#e5e7eb"
      theme_gray <- "#6b7280"
      # Use the theme's actual card background so dark themes get dark table/chart
      # backgrounds and light text stays readable. Hardcoded #f9fafb would give
      # light bg for dark themes where theme_text is white → white-on-white.
      theme_light <- effective_colors$card_bg %||% effective_colors$bg %||% "#f9fafb"
      
      # Professional color palette for charts
      chart_colors <- c(theme_accent, "#e74c3c", "#2ecc71", "#f39c12", "#9b59b6", "#1abc9c", "#34495e", "#e91e63")
      
      # Generate sample data for preview visualization
      if(!is.null(metrics) && length(metrics) > 0) {
        n_scales <- length(metrics)
        
        # Generate realistic sample scores (3.2-4.5 range for 5-point scale)
        set.seed(42)  # Consistent preview
        sample_scores <- sapply(seq_along(metrics), function(i) round(3.0 + (i %% 3) * 0.5 + runif(1, 0, 0.8), 2))
        sample_pcts <- round((sample_scores / 5) * 100)
        
        # ===== RADAR CHART (SVG) =====
        radar_chart <- NULL
        if(isTRUE(pg$show_radar_chart) && n_scales >= 3) {
          angles <- seq(0, 2*pi, length.out = n_scales + 1)[1:n_scales] - pi/2
          sample_vals <- sample_scores / 5
          
          cx <- 120; cy <- 120; r <- 85
          
          # Polygon points
          points_str <- paste(sapply(seq_along(angles), function(i) {
            x <- cx + r * sample_vals[i] * cos(angles[i])
            y <- cy + r * sample_vals[i] * sin(angles[i])
            paste(x, y, sep = ",")
          }), collapse = " ")
          
          # Data points
          data_points <- lapply(seq_along(angles), function(i) {
            x <- cx + r * sample_vals[i] * cos(angles[i])
            y <- cy + r * sample_vals[i] * sin(angles[i])
            tags$circle(cx = x, cy = y, r = 5, fill = theme_accent, stroke = "white", `stroke-width` = "2")
          })
          
          # Axis lines and labels
          axis_elements <- lapply(seq_along(angles), function(i) {
            x2 <- cx + r * cos(angles[i])
            y2 <- cy + r * sin(angles[i])
            lx <- cx + (r + 22) * cos(angles[i])
            ly <- cy + (r + 22) * sin(angles[i])
            tagList(
              tags$line(x1 = cx, y1 = cy, x2 = x2, y2 = y2, stroke = theme_border, `stroke-width` = "1.5", `stroke-dasharray` = "4,4"),
              tags$text(x = lx, y = ly, `text-anchor` = "middle", `dominant-baseline` = "middle",
                        style = sprintf("font-size: 11px; fill: %s; font-weight: 600;", theme_text), 
                        substr(metrics[[i]]$name, 1, 12))  # Truncate long names
            )
          })
          
          radar_chart <- div(class = "results-radar-section",
                             style = sprintf("text-align: center; padding: 24px; background: %s; border-radius: 16px; margin-bottom: 24px; box-shadow: 0 4px 15px rgba(0,0,0,0.05);", theme_light),
                             h4(style = sprintf("margin: 0 0 20px 0; color: %s; font-size: 1.15rem; font-weight: 700;", theme_accent),
                                bs_icon("pie-chart-fill"), " ",
                                if(lang == "de") "Ihr Persönlichkeitsprofil" else "Your Profile Overview"
                             ),
                             tags$svg(width = "280", height = "280", viewBox = "0 0 240 240",
                                      style = "max-width: 100%; filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1));",
                                      # Background circles with gradient effect
                                      tags$circle(cx = cx, cy = cy, r = r, fill = "none", stroke = theme_border, `stroke-width` = "1.5"),
                                      tags$circle(cx = cx, cy = cy, r = r*0.66, fill = "none", stroke = theme_border, `stroke-width` = "1"),
                                      tags$circle(cx = cx, cy = cy, r = r*0.33, fill = "none", stroke = theme_light, `stroke-width` = "1"),
                                      # Axis elements
                                      tagList(axis_elements),
                                      # Data polygon with gradient
                                      tags$polygon(points = points_str, 
                                                   fill = sprintf("rgba(%s, 0.25)", paste(col2rgb(theme_accent), collapse = ",")),
                                                   stroke = theme_accent, `stroke-width` = "2.5", `stroke-linejoin` = "round"),
                                      # Data points
                                      tagList(data_points)
                             ),
                             div(style = sprintf("font-size: 0.8rem; color: %s; margin-top: 12px; font-style: italic;", theme_gray),
                                 if(lang == "de") "Profilübersicht (Beispieldaten)" else "Profile overview (sample data)"
                             )
          )
        }
        
        # ===== PROFESSIONAL ACADEMIC-STYLE RESULTS =====
        # Generate sample SDs for demonstration
        sample_sds <- round(runif(n_scales, 0.4, 1.2), 2)
        
        # Clean academic table design with click-to-color support
        results_header_color <- theme_primary
        
        results_table <- div(class = "results-academic-section",
                             style = sprintf("background: %s; border-radius: 8px; border: 1px solid %s; overflow: hidden;", theme_light, theme_border),
                             tags$table(style = "width: 100%; border-collapse: collapse; font-family: 'Segoe UI', system-ui, sans-serif;",
                                        tags$thead(
                                          tags$tr(class = "results-header-row",
                                                  style = sprintf("background: %s; border-bottom: 2px solid %s;", theme_light, theme_accent),
                                                  tags$th(class = "results-header-cell",
                                                          style = sprintf("padding: 14px 16px; text-align: left; font-weight: 600; color: %s; font-size: 0.9rem; cursor: %s;", 
                                                                          results_header_color, if(is_edit) "pointer" else "default"),
                                                          `data-editable` = if(is_edit) "true" else "false",
                                                          if(lang == "de") "Skala" else "Scale"),
                                                  tags$th(class = "results-header-cell",
                                                          style = sprintf("padding: 14px 16px; text-align: center; font-weight: 600; color: %s; font-size: 0.9rem; cursor: %s;", 
                                                                          results_header_color, if(is_edit) "pointer" else "default"),
                                                          `data-editable` = if(is_edit) "true" else "false",
                                                          "M"),
                                                  tags$th(class = "results-header-cell",
                                                          style = sprintf("padding: 14px 16px; text-align: center; font-weight: 600; color: %s; font-size: 0.9rem; cursor: %s;", 
                                                                          results_header_color, if(is_edit) "pointer" else "default"),
                                                          `data-editable` = if(is_edit) "true" else "false",
                                                          "SD"),
                                                  tags$th(class = "results-header-cell",
                                                          style = sprintf("padding: 14px 16px; text-align: left; font-weight: 600; color: %s; font-size: 0.9rem; width: 40%%; cursor: %s;", 
                                                                          results_header_color, if(is_edit) "pointer" else "default"),
                                                          `data-editable` = if(is_edit) "true" else "false",
                                                          "")
                                          )
                                        ),
                                        tags$tbody(
                                          lapply(seq_along(metrics), function(i) {
                                            m <- metrics[[i]]
                                            score <- sample_scores[i]
                                            sd_val <- sample_sds[i]
                                            pct <- sample_pcts[i]
                                            bar_color <- chart_colors[(i-1) %% length(chart_colors) + 1]
                                            scale_name <- m$label %||% m$name
                                            scale_id <- paste0("scale_", sanitize_id(scale_name))
                                            
                                            # Get element-specific color override if exists
                                            ov <- color_overrides()
                                            element_color <- ov$element_colors[[curr]][[scale_id]]
                                            final_bar_color <- element_color %||% bar_color
                                            
                                            tags$tr(class = "results-table-row",
                                                    `data-scale-index` = i,
                                                    `data-scale-id` = scale_id,
                                                    style = sprintf("border-bottom: 1px solid %s;%s cursor: %s;", 
                                                                    theme_border,
                                                                    if(i %% 2 == 0) sprintf(" background: %s;", theme_light) else "",
                                                                    if(is_edit) "pointer;" else "default;"),
                                                    tags$td(class = "results-scale-name",
                                                            style = sprintf("padding: 12px 16px; font-weight: 500; color: %s; font-size: 0.9rem; cursor: %s;", 
                                                                            theme_text, if(is_edit) "pointer" else "default"),
                                                            `data-editable` = if(is_edit) "true" else "false",
                                                            `data-scale-id` = scale_id,
                                                            scale_name),
                                                    tags$td(style = sprintf("padding: 12px 16px; text-align: center; font-weight: 600; color: %s; font-size: 0.95rem;", final_bar_color), 
                                                            sprintf("%.2f", score)),
                                                    tags$td(style = sprintf("padding: 12px 16px; text-align: center; color: %s; font-size: 0.9rem;", theme_gray), 
                                                            sprintf("%.2f", sd_val)),
                                                    tags$td(class = "results-scale-bar",
                                                            style = "padding: 12px 16px; cursor: pointer;",
                                                            `data-scale-id` = scale_id,
                                                            `data-scale-index` = i,
                                                            `data-editable` = if(is_edit) "true" else "false",
                                                            div(class = "progress-bar-fill",
                                                                style = sprintf("background: %s; border-radius: 4px; height: 8px; overflow: hidden;", theme_border),
                                                                div(class = "progress-bar-inner",
                                                                    style = sprintf("background: %s; height: 100%%; width: %d%%; border-radius: 4px; transition: width 0.5s ease; cursor: pointer;", 
                                                                                    final_bar_color, pct),
                                                                    `data-color-override` = if(!is.null(element_color)) "true" else "false")
                                                            )
                                                    )
                                            )
                                          })
                                        )
                             )
        )
        
        # Academic footer - detect scale range dynamically (computed outside tagList)
        scale_note <- "Scale: 1-5."
        
        results_footer <- div(style = sprintf("padding: 12px 16px; background: %s; border-top: 1px solid %s; font-size: 0.75rem; color: %s;", theme_light, theme_border, theme_gray),
                              tags$em(paste0("M = Mean, SD = Standard Deviation. ", scale_note))
        )
        
        # Use the styled radar_chart built above (avoids duplicate SVG code)
        radar_section <- radar_chart
        
        # Simple note with dynamic scale info
        results_note <- div(
          results_footer,
          div(style = "margin-top: 8px; text-align: center;",
              tags$small(style = sprintf("color: %s; font-style: italic;", theme_gray),
                         if(lang == "de") "* Vorschau mit simulierten Daten" else "* Preview with simulated data")
          )
        )
        
      } else {
        # No scales defined - show helpful onboarding message
        radar_chart <- NULL
        results_chart <- div(style = "padding: 40px 30px; background: linear-gradient(135deg, #fff3cd 0%, #ffeeba 100%); border-radius: 16px; text-align: center; border: 2px dashed #ffc107;",
                             div(style = "font-size: 3rem; margin-bottom: 16px;", bs_icon("graph-up-arrow")),
                             h4(style = "margin: 0 0 12px 0; color: #856404; font-weight: 700;",
                                if(lang == "de") "Noch keine Skalen definiert" else "No Scales Defined Yet"
                             ),
                             p(style = "margin: 0 0 20px 0; color: #856404; font-size: 0.95rem; max-width: 400px; margin-left: auto; margin-right: auto;",
                               if(lang == "de") "Definieren Sie Skalen, um personalisierte Ergebnisvisualisierungen für Ihre Teilnehmer zu erstellen." 
                               else "Define scales to create personalized result visualizations for your participants."
                             ),
                             div(style = "display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;",
                                 tags$button(class = "btn btn-warning btn-sm", style = "font-weight: 600;",
                                             bs_icon("plus-circle"), " ",
                                             if(lang == "de") "Skala hinzufügen" else "Add Scale"),
                                 tags$button(class = "btn btn-outline-warning btn-sm",
                                             bs_icon("magic"), " ",
                                             if(lang == "de") "Auto-Erstellung" else "Auto-create")
                             ),
                             p(style = "margin: 20px 0 0 0; color: #a67c00; font-size: 0.8rem;",
                               if(lang == "de") "Tipp: Klicken Sie auf 'Auto' um Skalen automatisch aus Item-Präfixen zu erstellen" 
                               else "Tip: Click 'Auto-create' to automatically create scales from item prefixes"
                             )
        )
        results_table <- results_chart
        radar_section <- NULL
        results_note <- NULL
      }
      
      # ===== ASSEMBLE RESULTS PAGE — real inrep class names =====
      tagList(
        # .card-header matches real inrep h3(class = "card-header") on results page
        h3(class = "card-header",
           if(lang == "de") "Ihre Ergebnisse" else "Your Results"
        ),
        # .results-section matches real inrep div(class = "results-section")
        div(class = "results-section",
            # Thank-you / completion text — .welcome-text matches real inrep
            if (nzchar(results_text)) p(class = "welcome-text", results_text),
            # Radar chart (optional)
            radar_section,
            # Main results table with M, SD, and bar chart
            results_table,
            # Footer note
            results_note
        )
      )
    }
    
    # Wrap in study preview frame
    div(class = "study-preview", style = theme_style,
        # Studio chrome: study name + progress indicator (not in real inrep output)
        div(class = "study-preview-header",
            div(class = "study-preview-title", study_name),
            div(class = "study-preview-progress",
                # Language button lives here — same flex container as progress, same style
                {
                  p_langs  <- preview_langs()
                  cur_lang <- input$primary_lang %||% "en"
                  globe_icon <- HTML('<svg width="12" height="12" viewBox="0 0 16 16" fill="none" style="flex-shrink:0;"><circle cx="8" cy="8" r="6.5" stroke="currentColor" stroke-width="1.3"/><path d="M1.5 8h13M8 1.5c2 2.2 2 10.8 0 13M8 1.5C6 3.7 6 12.3 8 14.5" stroke="currentColor" stroke-width="1.3"/></svg>')
                  if (length(p_langs) >= 2) {
                    tags$button(
                      class = "preview-progress-add-btn",
                      type  = "button",
                      style = "border-style: solid; border-color: var(--preview-primary, #2c3e50); color: var(--preview-primary, #2c3e50);",
                      title = paste0("Switch language (", paste(toupper(p_langs), collapse = "/"), ")"),
                      onclick = "Shiny.setInputValue('lang_switch_click', Math.random(), {priority:'event'})",
                      globe_icon, " ", toupper(cur_lang)
                    )
                  } else {
                    tags$button(
                      class = "preview-progress-add-btn",
                      type  = "button",
                      title = "Click to add a 2nd language — enables in-preview language switching",
                      onclick = "Shiny.setInputValue('lang_add_click', Math.random(), {priority:'event'})",
                      globe_icon, " ", toupper(cur_lang)
                    )
                  }
                },
                {
                  progress_type <- input$progress_style %||% "none"
                  
                  if (progress_type == "none") {
                    # Show a subtle "+Add" affordance so the user knows this area is configurable
                    tags$button(
                      class = "preview-progress-add-btn",
                      type = "button",
                      title = "Click to add a progress indicator",
                      onclick = "Shiny.setInputValue('progress_style_add_click', Date.now(), {priority: 'event'})",
                      bs_icon("sliders"), " Progress"
                    )
                  } else if (progress_type == "bar") {
                    div(style = "display: flex; align-items: center; gap: 8px;",
                        div(class = "progress-bar-container",
                            div(class = "progress-bar-fill", style = sprintf("width: %s%%;", progress_pct))
                        ),
                        tags$button(
                          class = "preview-progress-edit-btn",
                          type = "button",
                          title = "Change progress indicator style",
                          onclick = "Shiny.setInputValue('progress_style_add_click', Date.now(), {priority: 'event'})",
                          bs_icon("pencil")
                        )
                    )
                  } else if (progress_type == "circle") {
                    div(style = "display: flex; align-items: center; gap: 8px;",
                        make_svg_progress_ring(
                          pct = progress_pct,
                          size_px = 48,
                          stroke_width = 6,
                          color = theme_colors$primary,
                          track = theme_colors$border %||% "#e5e7eb",
                          center_fill = theme_colors$bg,
                          text_color = theme_colors$text
                        ),
                        tags$button(
                          class = "preview-progress-edit-btn",
                          type = "button",
                          title = "Change progress indicator style",
                          onclick = "Shiny.setInputValue('progress_style_add_click', Date.now(), {priority: 'event'})",
                          bs_icon("pencil")
                        )
                    )
                  } else {
                    div(class = "progress-bar-container",
                        div(class = "progress-bar-fill", style = sprintf("width: %s%%;", progress_pct))
                    )
                  }
                }
            )
        ),
        
        # Studio-owned content area — does NOT use .assessment-card so inrep
        # scoped theme CSS never targets this wrapper (prevents double-card effect).
        div(class = "studio-preview-body",
            preview_content,
            
            # Navigation buttons — Studio-namespaced, not targeted by inrep theme CSS
            div(class = "studio-preview-nav",
                if (page_idx > 1) {
                  nav_labels <- switch(lang,
                                       de = list(back = "\u2190 Zur\u00FCck", cont = "Weiter \u2192", fin = "Abschlie\u00DFen"),
                                       es = list(back = "\u2190 Atr\u00E1s", cont = "Continuar \u2192", fin = "Finalizar"),
                                       fr = list(back = "\u2190 Retour", cont = "Continuer \u2192", fin = "Terminer"),
                                       fa = list(back = "\u0628\u0627\u0632\u06af\u0634\u062a", cont = "\u0627\u062f\u0627\u0645\u0647", fin = "\u067e\u0627\u06cc\u0627\u0646"),
                                       list(back = "\u2190 Back", cont = "Continue \u2192", fin = "Finish")
                  )
                  tags$button(class = "studio-nav-btn", nav_labels$back)
                } else {
                  div()
                },
                {
                  nav_labels2 <- switch(lang,
                                        de = list(back = "\u2190 Zur\u00FCck", cont = "Weiter \u2192", fin = "Abschlie\u00DFen"),
                                        es = list(back = "\u2190 Atr\u00E1s", cont = "Continuar \u2192", fin = "Finalizar"),
                                        fr = list(back = "\u2190 Retour", cont = "Continuer \u2192", fin = "Terminer"),
                                        fa = list(back = "\u0628\u0627\u0632\u06af\u0634\u062a", cont = "\u0627\u062f\u0627\u0645\u0647", fin = "\u067e\u0627\u06cc\u0627\u0646"),
                                        list(back = "\u2190 Back", cont = "Continue \u2192", fin = "Finish")
                  )
                  tags$button(class = "studio-nav-btn studio-nav-btn-primary",
                              if (page_idx == total_pages) nav_labels2$fin else nav_labels2$cont)
                }
            )
        )
    )
  })
  
  # ===== INLINE EDITING HANDLER =====
  # This handles all contenteditable field updates from the preview
  observeEvent(input$inline_edit, {
    req(input$inline_edit)
    data <- input$inline_edit
    page_id <- data$pageId
    item_id <- data$itemId
    field <- data$field
    new_value <- data$value
    
    # Handle item text changes
    if(!is.null(item_id) && !is.null(field)) {
      itb <- items()
      idx <- which(itb$id == item_id)
      if(length(idx) > 0) {
        if(field == "question_de") {
          itb$Question_DE[idx] <- new_value
        } else if(field == "question_en") {
          itb$Question_EN[idx] <- new_value
        } else if(field == "response_categories") {
          itb$ResponseCategories[idx] <- new_value
        }
        items(itb)
        showNotification(
          paste("Item", item_id, "updated"),
          type = "message",
          duration = 1,
          closeButton = FALSE
        )
      }
      return()
    }
    
    # Handle page field changes  
    if(!is.null(page_id) && !is.null(field)) {
      pgs <- pages()
      if(page_id %in% names(pgs)) {
        pgs[[page_id]][[field]] <- new_value
        pages(pgs)
        
        # Show a subtle notification
        showNotification(
          paste("Updated:", field),
          type = "message",
          duration = 1,
          closeButton = FALSE
        )
      }
    }
  })
  
  # Handle demographic field label edits with real-time preview update
  observeEvent(input$edit_demo_field, {
    req(input$edit_demo_field)
    data <- input$edit_demo_field
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") return()
    
    field_idx <- data$fieldIdx
    field_name <- data$field
    new_value <- data$value
    lang <- data$lang
    
    if(is.null(pgs[[curr]]$demo_fields) || field_idx > length(pgs[[curr]]$demo_fields)) return()
    
    # Update the demographic field
    if(field_name == "label_text") {
      if(lang == "de") {
        pgs[[curr]]$demo_fields[[field_idx]]$label_de <- new_value
      } else {
        pgs[[curr]]$demo_fields[[field_idx]]$label_en <- new_value
      }
    }
    
    pages(pgs)
  })
  
  # Handle delete demographic field
  observeEvent(input$delete_demo_field, {
    req(input$delete_demo_field)
    data <- input$delete_demo_field
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") return()
    
    field_idx <- data$fieldIdx
    if(is.null(pgs[[curr]]$demo_fields) || field_idx > length(pgs[[curr]]$demo_fields)) return()
    
    # Remove the field
    pgs[[curr]]$demo_fields[[field_idx]] <- NULL
    pages(pgs)
  })
  
  # Delete demographic field from right-side properties panel
  observeEvent(input$delete_demo_field_from_props, {
    req(input$delete_demo_field_from_props)
    data <- input$delete_demo_field_from_props
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") return()
    
    field_idx <- as.integer(data$fieldIdx %||% NA)
    if(is.na(field_idx) || field_idx < 1) return()
    if(is.null(pgs[[curr]]$demo_fields) || field_idx > length(pgs[[curr]]$demo_fields)) return()
    
    pgs[[curr]]$demo_fields[[field_idx]] <- NULL
    pages(pgs)
    showNotification("Demographic field removed", type = "message", duration = 2)
  })
  
  # Open edit modal for existing demographic fields
  observeEvent(input$edit_demo_field_settings, {
    req(input$edit_demo_field_settings)
    data <- input$edit_demo_field_settings
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") return()
    
    field_idx <- as.integer(data$fieldIdx %||% NA)
    if(is.na(field_idx) || field_idx < 1) return()
    if(is.null(pgs[[curr]]$demo_fields) || field_idx > length(pgs[[curr]]$demo_fields)) return()
    
    field <- pgs[[curr]]$demo_fields[[field_idx]]
    session$userData$editing_demo_field_idx <- field_idx
    
    showModal(modalDialog(
      title = "Edit Demographic Field",
      textInput("edit_demo_name", "Field Name (internal)", value = field$name %||% ""),
      textInput("edit_demo_label_de", "Label (German)", value = field$label_de %||% ""),
      textInput("edit_demo_label_en", "Label (English)", value = field$label_en %||% ""),
      selectInput("edit_demo_type", "Field Type", c("Text" = "text", "Number" = "number", "Select" = "select", "Slider" = "slider", "Checkbox" = "checkbox", "Radio" = "radio"), selected = field$type %||% "text"),
      checkboxInput("edit_demo_required", "Required Field", value = isTRUE(field$required)),
      textInput("edit_demo_options_de", "Options (German, comma-separated)", value = paste(field$options_de %||% character(0), collapse = ", ")),
      textInput("edit_demo_options_en", "Options (English, comma-separated)", value = paste(field$options_en %||% character(0), collapse = ", ")),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_edit_demo_field", "Save", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$confirm_edit_demo_field, {
    removeModal()
    curr <- current_page()
    pgs <- pages()
    
    field_idx <- as.integer(session$userData$editing_demo_field_idx %||% NA)
    if(is.na(field_idx) || is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") return()
    if(is.null(pgs[[curr]]$demo_fields) || field_idx > length(pgs[[curr]]$demo_fields)) return()
    
    f <- pgs[[curr]]$demo_fields[[field_idx]]
    f$name <- input$edit_demo_name %||% f$name
    f$label_de <- input$edit_demo_label_de %||% f$label_de
    f$label_en <- input$edit_demo_label_en %||% f$label_en
    f$type <- input$edit_demo_type %||% f$type
    f$required <- isTRUE(input$edit_demo_required)
    
    if(f$type %in% c("select", "radio", "checkbox")) {
      opts_de <- trimws(unlist(strsplit(input$edit_demo_options_de %||% "", ",")))
      opts_en <- trimws(unlist(strsplit(input$edit_demo_options_en %||% "", ",")))
      f$options_de <- opts_de[nzchar(opts_de)]
      f$options_en <- opts_en[nzchar(opts_en)]
    }
    
    pgs[[curr]]$demo_fields[[field_idx]] <- f
    pages(pgs)
    showNotification("Demographic field updated", type = "message", duration = 2)
  })
  
  # Handle element color click - store for properties panel (NO MODAL)
  observeEvent(input$element_color_click, {
    req(input$element_color_click)
    data <- input$element_color_click
    
    # Store the element that was clicked for properties panel display
    session$userData$selected_element_for_color <- data
    
    # Update the color picker in properties panel
    colourpicker::updateColourInput(session, "element_custom_color", value = data$currentColor)
    
    # Show notification to guide user to properties panel
    element_label <- switch(data$elementType,
                            "progress-bar" = "Progress Bar",
                            "item" = "Item",
                            "heading" = "Heading",
                            "results-bar" = "Results Scale Bar",
                            "Generic Element"
    )
    showNotification(paste("Selected:", element_label, "- Adjust color in Properties panel →"), 
                     type = "message", duration = 3)
  })
  
  # Apply color to single element
  observeEvent(input$apply_element_color, {
    req(session$userData$selected_element_for_color)
    new_color <- input$element_custom_color
    element_data <- session$userData$selected_element_for_color
    
    # Store in color overrides for element-specific coloring
    ov <- color_overrides()
    curr <- current_page()
    
    if (!curr %in% names(ov$element_colors)) {
      ov$element_colors[[curr]] <- list()
    }
    
    # Use scaleId for results table colors, otherwise use elementId
    element_key <- element_data$scaleId %||% element_data$elementId
    
    # Store color by element type for proper targeting
    ov$element_colors[[curr]][[element_key]] <- new_color
    color_overrides(ov)
    
    # Better notification based on element type
    element_label <- switch(element_data$elementType,
                            "results-bar" = "Results scale bar",
                            "progress-bar" = "Progress bar",
                            "item" = "Item",
                            "heading" = "Heading",
                            "results-row" = "Results row",
                            "results-text" = "Results text",
                            "Generic element"
    )
    
    showNotification(paste("Color applied to:", element_label), type = "message", duration = 2)
  })
  
  # Render progress style card picker
  output$progress_style_picker <- renderUI({
    sel <- input$progress_style %||% "circle"
    
    card_style <- function(val) {
      is_sel <- identical(sel, val)
      base_style <- paste0(
        "cursor: pointer; border-radius: 8px; padding: 10px 8px; text-align: center; ",
        "border: 2px solid ", if(is_sel) "#2c3e50" else "#dee2e6", "; ",
        "background: ", if(is_sel) "#f0f4f8" else "#ffffff", "; ",
        "transition: border-color 0.15s, background 0.15s; user-select: none; ",
        "flex: 1; min-width: 0;"
      )
      base_style
    }
    
    div(style = "display: flex; gap: 8px; margin-bottom: 4px;",
        # None / Disabled
        div(style = card_style("none"),
            onclick = "Shiny.setInputValue('progress_style', 'none', {priority: 'event'})",
            div(style = "width: 32px; height: 32px; border: 2px dashed #adb5bd; border-radius: 50%; margin: 0 auto 4px; display: flex; align-items: center; justify-content: center;",
                tags$span(style = "color: #adb5bd; font-size: 1rem; line-height: 1;", "\u2715")),
            tags$small(style = "color: #6c757d; font-size: 0.75rem; display: block;", "Disabled")
        ),
        # Bar
        div(style = card_style("bar"),
            onclick = "Shiny.setInputValue('progress_style', 'bar', {priority: 'event'})",
            div(style = "margin: 6px auto 6px; width: 100%; height: 8px; background: #dee2e6; border-radius: 4px; overflow: hidden;",
                div(style = "width: 40%; height: 100%; background: #2c3e50; border-radius: 4px;")),
            tags$small(style = "color: #495057; font-size: 0.75rem; display: block;", "Bar")
        ),
        # Circle
        div(style = card_style("circle"),
            onclick = "Shiny.setInputValue('progress_style', 'circle', {priority: 'event'})",
            tags$svg(
              style = "display: block; margin: 0 auto 2px;",
              width = "32", height = "32", viewBox = "0 0 32 32",
              tags$circle(cx="16", cy="16", r="12", fill="none", stroke="#dee2e6", `stroke-width`="3"),
              tags$circle(cx="16", cy="16", r="12", fill="none", stroke="#2c3e50", `stroke-width`="3",
                          `stroke-dasharray`="30 45", `stroke-dashoffset`="0",
                          style="transform-origin: center; transform: rotate(-90deg);")
            ),
            tags$small(style = "color: #495057; font-size: 0.75rem; display: block;", "Circle")
        )
    )
  })
  
  # Render element color picker UI dynamically
  output$element_color_ui <- renderUI({
    if (is.null(session$userData$selected_element_for_color)) {
      return(p(class = "text-muted small fst-italic", "No element selected"))
    }
    
    element_data <- session$userData$selected_element_for_color
    element_label <- switch(element_data$elementType,
                            "progress-bar" = "Progress Bar",
                            "item" = "Item Border",
                            "heading" = "Heading Text",
                            "results-bar" = "Results Scale Bar",
                            "results-row" = "Results Row",
                            "results-text" = "Results Text",
                            "Generic Element"
    )
    
    tagList(
      div(class = "mb-2",
          tags$label(class = "form-label small", paste("\u2022", element_label)),
          colourpicker::colourInput(
            "element_custom_color",
            NULL,
            value = element_data$currentColor,
            showColour = "background",
            allowTransparent = FALSE
          )
      ),
      div(class = "d-flex gap-2",
          actionButton("apply_element_color", "Apply to This Page", class = "btn-primary btn-sm flex-fill"),
          actionButton("apply_color_globally", "Apply to All Pages", class = "btn-secondary btn-sm flex-fill")
      )
    )
  })
  
  # Apply color globally to all pages with the same element type
  observeEvent(input$apply_color_globally, {
    req(session$userData$selected_element_for_color)
    new_color <- input$element_custom_color
    element_data <- session$userData$selected_element_for_color
    
    pgs <- pages()
    ov <- color_overrides()
    
    # Determine what to apply globally based on element type
    is_results_element <- grepl("results", element_data$elementType, ignore.case = TRUE)
    
    # Replace color in all pages for this element type
    for (page_id in names(pgs)) {
      if (!page_id %in% names(ov$element_colors)) {
        ov$element_colors[[page_id]] <- list()
      }
      
      if (is_results_element && !is.null(element_data$scaleId)) {
        # For results table elements, apply to matching scale IDs across all pages
        # Find all scales with similar names and apply color
        pg <- pgs[[page_id]]
        if (!is.null(pg$type) && pg$type == "results" && !is.null(pg$report_metrics)) {
          for (i in seq_along(pg$report_metrics)) {
            m <- pg$report_metrics[[i]]
            scale_id <- paste0("scale_", sanitize_id(m$label %||% m$name))
            # Apply color to matching scales across pages
            if (scale_id == element_data$scaleId || m$name == element_data$scaleId) {
              ov$element_colors[[page_id]][[scale_id]] <- new_color
            }
          }
        }
      } else {
        # For non-results elements, apply based on change type
        ov$element_colors[[page_id]][[element_data$changeType]] <- new_color
      }
    }
    
    color_overrides(ov)
    
    showNotification("Color applied globally to all pages!", type = "message", duration = 3)
  })
  
  
  observeEvent(input$edit_item, {
    selected_item(input$edit_item)
    # Update the property editor fields when selecting an item
    itb <- items()
    idx <- which(itb$id == input$edit_item)
    if (length(idx) > 0) {
      updateTextInput(session, "edit_item_id", value = itb$id[idx])
      updateTextAreaInput(session, "edit_item_q_de", value = itb$Question_DE[idx])
      updateTextAreaInput(session, "edit_item_q_en", value = itb$Question_EN[idx])
      updateTextInput(session, "edit_item_resp", value = itb$ResponseCategories[idx])
      cur_type <- if ("item_type" %in% names(itb)) as.character(itb$item_type[idx]) else "irt"
      if (is.na(cur_type) || !nzchar(cur_type)) cur_type <- "irt"
      updateSelectInput(session, "edit_item_type", selected = cur_type)
    }
  })
  
  output$repository_ui <- renderUI({
    itb <- items()
    pgs <- pages()
    
    assigned <- character(0)
    for(pg in pgs) {
      if(!is.null(pg$items) && length(pg$items) > 0) {
        assigned <- c(assigned, pg$items)
      }
    }
    assigned <- unique(assigned)
    
    unassigned <- itb[!itb$id %in% assigned, ]
    
    if(nrow(unassigned) == 0) {
      return(div(class="text-center text-muted p-4", 
                 icon("check-circle", style="font-size:2rem; opacity:0.3;"), 
                 p("Alle Items zugewiesen", class="small mt-2")))
    }
    
    lapply(seq_len(nrow(unassigned)), function(i) {
      item <- unassigned[i, ]
      q_text <- item$Question_DE
      if(is.null(q_text) || is.na(q_text) || q_text == "") q_text <- item$Question_EN
      if(is.null(q_text) || is.na(q_text) || q_text == "") q_text <- item$id
      if(nchar(q_text) > 50) q_text <- paste0(substr(q_text, 1, 50), "...")
      
      div(class = "repo-item draggable-item",
          `data-item-id` = item$id,
          draggable = "true",
          onclick = sprintf("Shiny.setInputValue('add_item_to_page', '%s', {priority: 'event'})", item$id),
          div(class = "drag-handle", bs_icon("grip-vertical")),
          div(style = "margin-left: 24px;",
              div(class = "repo-item-id", item$id),
              div(class = "repo-item-text", q_text)
          )
      )
    })
  })
  
  observeEvent(input$add_item_to_page, {
    req(input$add_item_to_page)
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]])) {
      showNotification("No page selected", type = "error")
      return()
    }
    
    if(pgs[[curr]]$type != "items") {
      showNotification("Items can only be added to 'Items' pages", type = "warning")
      return()
    }
    
    current_items <- pgs[[curr]]$items
    if(is.null(current_items)) current_items <- character(0)
    
    if(input$add_item_to_page %in% current_items) {
      showNotification("Item already on this page", type = "warning")
      return()
    }
    
    pgs[[curr]]$items <- c(current_items, input$add_item_to_page)
    
    # Auto-link item to results page's default scale
    pgs <- auto_link_item_to_results(pgs, input$add_item_to_page)
    
    pages(pgs)
    showNotification("Item added", type = "message")
  })
  
  # ===== DRAG AND DROP HANDLERS =====
  
  # Drop item from repository to page (at end)
  observeEvent(input$drop_item_to_page, {
    req(input$drop_item_to_page)
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") {
      showNotification("Please select an Items page first", type = "warning")
      return()
    }
    
    item_id <- input$drop_item_to_page
    current_items <- pgs[[curr]]$items %||% character(0)
    
    if(item_id %in% current_items) {
      showNotification("Item is already on this page", type = "message")
      return()
    }
    
    pgs[[curr]]$items <- c(current_items, item_id)
    
    # Auto-link item to results page's default scale (respects exclude_from_report)
    pgs <- auto_link_item_to_results(pgs, item_id, items_df = items())
    
    pages(pgs)
    showNotification(paste("Item", item_id, "added"), type = "message")
  })
  
  # Drop item from repository onto specific position (before/after another item)
  observeEvent(input$drop_item_on_item, {
    req(input$drop_item_on_item)
    data <- input$drop_item_on_item
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") return()
    
    item_id <- data$itemId
    target_id <- data$targetId
    position <- data$position
    
    current_items <- pgs[[curr]]$items %||% character(0)
    
    if(item_id %in% current_items) {
      showNotification("Item bereits vorhanden", type = "message")
      return()
    }
    
    target_idx <- which(current_items == target_id)
    if(length(target_idx) == 0) {
      # Target not found, add at end
      pgs[[curr]]$items <- c(current_items, item_id)
    } else {
      insert_idx <- if(position == "before") target_idx else target_idx + 1
      if(insert_idx > length(current_items)) {
        pgs[[curr]]$items <- c(current_items, item_id)
      } else {
        pgs[[curr]]$items <- append(current_items, item_id, after = insert_idx - 1)
      }
    }
    
    pages(pgs)
    showNotification(paste("Item", item_id, "inserted"), type = "message")
  })
  
  # Reorder items within page
  observeEvent(input$reorder_items, {
    req(input$reorder_items)
    data <- input$reorder_items
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") return()
    
    item_id <- data$itemId
    target_id <- data$targetId
    position <- data$position
    
    current_items <- pgs[[curr]]$items %||% character(0)
    
    # Remove item from current position
    item_idx <- which(current_items == item_id)
    if(length(item_idx) == 0) return()
    
    current_items <- current_items[-item_idx]
    
    # Find new position
    target_idx <- which(current_items == target_id)
    if(length(target_idx) == 0) {
      current_items <- c(current_items, item_id)
    } else {
      insert_idx <- if(position == "before") target_idx else target_idx + 1
      if(insert_idx > length(current_items)) {
        current_items <- c(current_items, item_id)
      } else {
        current_items <- append(current_items, item_id, after = insert_idx - 1)
      }
    }
    
    pgs[[curr]]$items <- current_items
    pages(pgs)
  })
  
  # Move item up
  observeEvent(input$move_item_up, {
    req(input$move_item_up)
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") return()
    
    item_id <- input$move_item_up
    current_items <- pgs[[curr]]$items %||% character(0)
    idx <- which(current_items == item_id)
    
    if(length(idx) == 0 || idx == 1) return()
    
    # Swap with previous item
    current_items[c(idx-1, idx)] <- current_items[c(idx, idx-1)]
    pgs[[curr]]$items <- current_items
    pages(pgs)
  })
  
  # Move item down
  observeEvent(input$move_item_down, {
    req(input$move_item_down)
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") return()
    
    item_id <- input$move_item_down
    current_items <- pgs[[curr]]$items %||% character(0)
    idx <- which(current_items == item_id)
    
    if(length(idx) == 0 || idx == length(current_items)) return()
    
    # Swap with next item
    current_items[c(idx, idx+1)] <- current_items[c(idx+1, idx)]
    pgs[[curr]]$items <- current_items
    pages(pgs)
  })
  
  # Remove item from page
  observeEvent(input$remove_item_from_page, {
    req(input$remove_item_from_page)
    curr <- current_page()
    pgs <- pages()
    
    if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "items") return()
    
    item_id <- input$remove_item_from_page
    current_items <- pgs[[curr]]$items %||% character(0)
    
    pgs[[curr]]$items <- current_items[current_items != item_id]
    pages(pgs)
    selected_item(NULL)
    showNotification(paste("Item", item_id, "entfernt"), type = "message")
  })
  
  # Reorder pages with validation warnings
  observeEvent(input$reorder_pages, {
    req(input$reorder_pages)
    data <- input$reorder_pages
    pgs <- pages()
    
    source_id <- data$sourceId
    target_id <- data$targetId
    position <- data$position
    
    page_names <- names(pgs)
    source_idx <- which(page_names == source_id)
    target_idx <- which(page_names == target_id)
    
    if(length(source_idx) == 0 || length(target_idx) == 0 || source_idx == target_idx) return()
    
    # Check source page type
    source_type <- pgs[[source_id]]$type
    
    # Remove source from list
    source_page <- pgs[[source_id]]
    pgs <- pgs[-source_idx]
    page_names <- names(pgs)
    
    # Recalculate target position
    target_idx <- which(page_names == target_id)
    insert_idx <- if(position == "before") target_idx else target_idx + 1
    
    if(insert_idx > length(pgs)) {
      pgs[[source_id]] <- source_page
    } else {
      # Insert at position
      new_pgs <- list()
      for(i in seq_along(pgs)) {
        if(i == insert_idx) {
          new_pgs[[source_id]] <- source_page
        }
        new_pgs[[names(pgs)[i]]] <- pgs[[i]]
      }
      if(insert_idx > length(pgs)) {
        new_pgs[[source_id]] <- source_page
      }
      pgs <- new_pgs
    }
    
    pages(pgs)
    
    # === PAGE ORDER VALIDATION WARNINGS ===
    new_names <- names(pgs)
    new_types <- sapply(pgs, function(p) p$type)
    
    # Find positions of key page types
    items_pos <- which(new_types == "items")
    results_pos <- which(new_types == "results")
    
    # Warning: Results page before items page
    if(length(results_pos) > 0 && length(items_pos) > 0) {
      if(min(results_pos) < max(items_pos)) {
        showNotification(
          HTML("<strong>Warning:</strong> Results page is before Items page. <br/>
                Results will show before all responses are collected. <br/>
                Consider moving Results to the end of your study."),
          type = "warning",
          duration = 8
        )
      }
    }
    
    # Warning: Results not at the end
    if(length(results_pos) > 0 && max(results_pos) < length(pgs)) {
      showNotification(
        HTML("<strong>Note:</strong> Results page is not the last page. <br/>
              inrep assumes data is submitted when results are shown. <br/>
              Pages after results may not have data saved to cloud."),
        type = "warning",
        duration = 8
      )
    }
    
    showNotification("Page order updated", type = "message", duration = 2)
  })
  
  # ===== END DRAG AND DROP HANDLERS =====
  
  # Clear selected_item if it references a deleted item (avoids side effects in renderUI)
  observeEvent(selected_item(), {
    sel <- selected_item()
    if (!is.null(sel)) {
      itb <- items()
      if (!sel %in% itb$id) selected_item(NULL)
    }
  })
  
  output$properties_ui <- renderUI({
    curr <- current_page()
    pgs <- pages()
    pg <- pgs[[curr]]
    sel_item <- selected_item()
    
    if(!is.null(sel_item)) {
      # ITEM EDITING MODE
      itb <- items()
      item <- itb[itb$id == sel_item, ]
      if(nrow(item) == 0) {
        return(div(class="text-muted", "Item not found"))
      }
      
      tagList(
        div(class="d-flex justify-content-between align-items-center mb-3",
            h6("Edit Item", class="m-0"),
            actionButton("close_item_edit", "×", class="btn btn-sm btn-light", style="font-size: 1.2rem; line-height: 1;")
        ),
        textInput("edit_item_id", "Item ID", value = item$id),
        textAreaInput("edit_item_q_de", "Question (German)", value = item$Question_DE, height = "100px"),
        textAreaInput("edit_item_q_en", "Question (English)", value = item$Question_EN, height = "100px"),
        selectInput("edit_item_type", "Item Type",
                    c("Standard (IRT / scale)" = "irt",
                      "Free Text (open response)" = "free_text"),
                    selected = as.character(item$item_type %||% "irt")),
        conditionalPanel(
          condition = "input.edit_item_type !== 'free_text'",
          textInput("edit_item_resp", "Response Scale (comma-separated)", value = item$ResponseCategories, placeholder = "1,2,3,4,5"),
          selectInput("edit_item_response_layout", "Response Display Style",
                      c("Vertical (like inrep)" = "vertical",
                        "Horizontal (all labels)" = "horizontal_all",
                        "Horizontal (endpoint labels only)" = "horizontal_endpoints"),
                      selected = item$response_layout %||% "vertical"),
          actionButton("apply_layout_to_all", "Apply to all items",
                       class = "btn btn-sm btn-outline-secondary w-100 mt-1 mb-2")
        ),
        hr(),
        h6(bs_icon("bar-chart-fill"), " Reporting", class="text-muted small mb-2"),
        div(class = "d-flex align-items-center gap-2",
            checkboxInput("edit_item_include_report",
                          "Include in report / results",
                          value = !(isTRUE(item$exclude_from_report)), width = "auto"),
            tags$span(
              bs_icon("info-circle", class = "text-muted", style = "font-size: 0.82em;"),
              style = "cursor: help;",
              title = paste0("When checked, this item's response is used in scale scores shown on the results page. ",
                             "Uncheck to collect the response silently without showing it (e.g., catch items, screeners, demographic sliders).")
            )
        ),
        div(id = "item_scale_hint", class = "small text-muted",
            "Scale: ", tags$strong({
              pgs_now <- pages()
              scale_for_item <- NA_character_
              for(pg2 in pgs_now) {
                if(!isTRUE(pg2$type == "results") || is.null(pg2$report_metrics)) next
                for(m in pg2$report_metrics) {
                  if(item$id %in% (m$items %||% character(0))) { scale_for_item <- m$name; break }
                }
                if(!is.na(scale_for_item)) break
              }
              if(is.na(scale_for_item)) "(not assigned — click Auto on results page)" else scale_for_item
            })
        ),
        hr(),
        actionButton("save_item", "Save Item", class="btn-primary w-100"),
        actionButton("delete_item", "Delete Item", class="btn-outline-danger w-100 mt-2 btn-sm")
      )
      
    } else if(!is.null(pg)) {
      # PAGE EDITING MODE
      page_title <- pg$title
      if(is.null(page_title)) page_title <- ""
      
      tagList(
        h6(paste("Page:", if(page_title != "") page_title else pg$id), class="mb-3"),
        textInput("prop_pg_title", "Page Title (German)", value = page_title),
        textInput("prop_pg_title_en", "Page Title (English)", value = pg$title_en %||% page_title),
        selectInput("prop_pg_type", "Page Type", 
                    c("Custom Content" = "custom", "Demographics" = "demographics", 
                      "Item Page" = "items", "Results Page" = "results"), 
                    selected = pg$type),
        
        # TYPE-SPECIFIC PROPERTIES
        if(pg$type == "custom" || (!is.null(input$prop_pg_type) && input$prop_pg_type == "custom")) {
          tagList(
            hr(),
            h6("Edit Content", class="text-muted mb-2"),
            textAreaInput("prop_pg_content_de", "Content (German)", 
                          value = pg$content_de, height = "200px", 
                          placeholder = "<h1>Heading</h1><p>Text here...</p>"),
            textAreaInput("prop_pg_content_en", "Content (English)", 
                          value = pg$content_en, height = "200px", 
                          placeholder = "<h1>Heading</h1><p>Text here...</p>")
            ,
            div(class = "alert alert-secondary py-2 px-3 mt-3 mb-0", style = "font-size: 0.8rem; line-height: 1.5;",
                bs_icon("code-slash"), tags$strong(" Custom CSS & JS"),
                " can be applied in the generated R script. Export your study and edit the script — this keeps the Studio focused and avoids overwhelming users with low-level code."
            )
          )
        } else if(pg$type == "items" || (!is.null(input$prop_pg_type) && input$prop_pg_type == "items")) {
          tagList(
            hr(),
            selectInput("prop_pg_scale", "Scale Type", 
                        c("Likert Scale" = "likert", "Difficulty Scale" = "difficulty"), 
                        selected = if(is.null(pg$scale_type)) "likert" else pg$scale_type),
            textAreaInput("prop_pg_instructions_de", "Item Instructions (German)", value = pg$instructions %||% "", height = "80px"),
            textAreaInput("prop_pg_instructions_en", "Item Instructions (English)", value = pg$instructions_en %||% "", height = "80px"),
            p(class="small text-muted mt-3", "Items on this page:"),
            if(!is.null(pg$items) && length(pg$items) > 0) {
              div(style="background: #f8fafc; padding: 10px; border-radius: 6px; font-family: monospace; font-size: 0.85rem;",
                  paste(pg$items, collapse = ", "))
            } else {
              p(class="small text-muted fst-italic", "No items")
            },
            actionButton("remove_all_items_from_page", "Remove All Items", 
                         class="btn-outline-warning w-100 btn-sm mt-2")
          )
        } else if(pg$type == "demographics" || (!is.null(input$prop_pg_type) && input$prop_pg_type == "demographics")) {
          tagList(
            hr(),
            h6("Demographic Fields", class="text-muted mb-2"),
            actionButton("add_demo_field", "Add Field", class="btn-sm btn-outline-primary w-100 mb-3"),
            div(class = "alert alert-secondary py-2 px-3 mt-3 mb-2", style = "font-size: 0.8rem; line-height: 1.5;",
                bs_icon("code-slash"), tags$strong(" Custom CSS & JS"),
                " can be applied in the generated R script. Export your study and edit the script — this keeps the Studio focused and avoids overwhelming users with low-level code."
            ),
            if(!is.null(pg$demo_fields) && length(pg$demo_fields) > 0) {
              lapply(seq_along(pg$demo_fields), function(i) {
                field <- pg$demo_fields[[i]]
                div(style="background: #f8fafc; padding: 12px; border-radius: 6px; margin-bottom: 8px;",
                    div(class="d-flex justify-content-between align-items-start mb-2",
                        strong(field$label_en %||% field$label_de %||% field$name %||% paste0("field_", i), style="font-size: 0.9rem;"),
                        div(class = "d-flex gap-1",
                            tags$button(
                              class = "btn btn-sm btn-outline-primary",
                              style = "padding: 0 6px; line-height: 1;",
                              onclick = sprintf("Shiny.setInputValue('edit_demo_field_settings', {fieldIdx: %d, from: 'properties'}, {priority: 'event'})", i),
                              bs_icon("pencil")
                            ),
                            tags$button(
                              class = "btn btn-sm btn-outline-danger",
                              style = "padding: 0 6px; line-height: 1;",
                              onclick = sprintf("Shiny.setInputValue('delete_demo_field_from_props', {fieldIdx: %d}, {priority: 'event'})", i),
                              "×"
                            )
                        )
                    ),
                    div(class="small text-muted", 
                        paste("Type:", field$type %||% "text", "| Name:", field$name %||% paste0("field_", i)))
                )
              })
            } else {
              p(class="small text-muted fst-italic", "No fields defined")
            }
          )
        } else if(pg$type == "results" || (!is.null(input$prop_pg_type) && input$prop_pg_type == "results")) {
          # Get all items from the item bank for scale assignment
          itb <- items()
          all_item_ids <- itb$id
          
          # Get items already assigned to scales
          assigned_items <- character(0)
          if(!is.null(pg$report_metrics) && length(pg$report_metrics) > 0) {
            assigned_items <- unique(unlist(lapply(pg$report_metrics, function(m) m$items)))
          }
          
          # Unassigned items
          unassigned_items <- setdiff(all_item_ids, assigned_items)
          
          tagList(
            hr(),
            # Display Settings
            h6(bs_icon("graph-up"), " Display Settings", class="text-muted mb-2"),
            checkboxInput("prop_results_radar", "Radar-Chart anzeigen", 
                          value = if(is.null(pg$show_radar_chart)) TRUE else pg$show_radar_chart),
            checkboxInput("prop_results_scores", "Skalenwerte anzeigen", 
                          value = if(is.null(pg$show_scale_scores)) TRUE else pg$show_scale_scores),
            
            hr(),
            # Scales Configuration (the KEY feature)
            h6(bs_icon("collection"), " Scales / Metrics", class="text-muted mb-2"),
            p(class="small text-muted mb-2", "Group items into scales to show in results. All items are automatically included."),
            
            # Button to add new scale
            div(class="d-flex gap-2 mb-3",
                actionButton("add_scale", tagList(bs_icon("plus-circle"), " Add Scale"), 
                             class = "btn-sm btn-primary flex-fill"),
                actionButton("auto_create_scales", tagList(bs_icon("magic"), " Auto"), 
                             class = "btn-sm btn-outline-secondary", title = "Auto-create scales from item prefixes")
            ),
            
            # Show existing scales
            if(!is.null(pg$report_metrics) && length(pg$report_metrics) > 0) {
              div(id = "scales-list",
                  lapply(seq_along(pg$report_metrics), function(i) {
                    m <- pg$report_metrics[[i]]
                    scale_items <- m$items %||% character(0)
                    div(class = "scale-card", style = "background: linear-gradient(135deg, #f8fafc 0%, #eef2f7 100%); padding: 12px; border-radius: 8px; margin-bottom: 10px; border-left: 4px solid var(--studio-primary);",
                        div(class = "d-flex justify-content-between align-items-center mb-2",
                            div(
                              strong(m$name, style = "font-size: 1rem;"),
                              tags$span(class = "badge bg-secondary ms-2", paste(length(scale_items), "items"))
                            ),
                            div(class = "btn-group btn-group-sm",
                                actionButton(paste0("edit_scale_", i), bs_icon("pencil"), class = "btn btn-outline-primary btn-sm"),
                                actionButton(paste0("del_scale_", i), bs_icon("trash"), class = "btn btn-outline-danger btn-sm")
                            )
                        ),
                        # Show items in this scale with scale range detection
                        if(length(scale_items) > 0) {
                          # Detect different response scales
                          itb_local <- itb
                          item_scales <- sapply(scale_items, function(item_id) {
                            idx <- which(itb_local$id == item_id)
                            if(length(idx) > 0 && !is.null(itb_local$ResponseCategories[idx[1]])) {
                              itb_local$ResponseCategories[idx[1]]
                            } else {
                              "1,2,3,4,5"  # default
                            }
                          })
                          unique_scales <- unique(item_scales)
                          has_mixed_scales <- length(unique_scales) > 1
                          
                          tagList(
                            if(has_mixed_scales) {
                              div(class = "alert alert-warning py-1 px-2 mb-2", style = "font-size: 0.8rem;",
                                  bs_icon("exclamation-triangle"), " ",
                                  tags$strong("Mixed scales detected: "),
                                  paste(unique_scales, collapse = " vs "),
                                  tags$br(),
                                  tags$em("Items with different response ranges may not be directly comparable.")
                              )
                            },
                            div(class = "scale-items", style = "display: flex; flex-wrap: wrap; gap: 4px; margin-top: 8px;",
                                lapply(scale_items, function(item_id) {
                                  idx <- which(itb_local$id == item_id)
                                  item_scale <- if(length(idx) > 0 && !is.null(itb_local$ResponseCategories[idx[1]])) {
                                    itb_local$ResponseCategories[idx[1]]
                                  } else "1,2,3,4,5"
                                  badge_class <- if(has_mixed_scales && item_scale != unique_scales[1]) {
                                    "badge bg-warning text-dark"
                                  } else {
                                    "badge bg-light text-dark"
                                  }
                                  tags$span(class = badge_class, style = "font-weight: 500;", 
                                            title = paste0("Scale: ", item_scale), item_id)
                                })
                            )
                          )
                        } else {
                          div(class = "text-muted small fst-italic", "No items assigned")
                        },
                        # Show expression
                        if(!is.null(m$expr) && nzchar(m$expr)) {
                          div(class = "small text-muted mt-2", style = "font-family: monospace; font-size: 0.75rem;",
                              bs_icon("code"), " ", substr(m$expr, 1, 50), if(nchar(m$expr) > 50) "..." else "")
                        }
                    )
                  })
              )
            } else {
              div(class = "text-center p-3", style = "background: #f8fafc; border-radius: 8px; border: 2px dashed #dee2e6;",
                  bs_icon("graph-up", class = "text-muted", style = "font-size: 2rem;"),
                  p(class = "text-muted mt-2 mb-0", "No scales defined yet"),
                  p(class = "small text-muted", "Click 'Add Scale' to create one")
              )
            },
            
            # Unassigned items section
            if(length(unassigned_items) > 0) {
              div(style = "margin-top: 16px;",
                  h6(class = "text-warning small", bs_icon("exclamation-triangle"), " Unassigned Items"),
                  div(style = "display: flex; flex-wrap: wrap; gap: 4px;",
                      lapply(unassigned_items, function(item_id) {
                        tags$span(class = "badge bg-warning text-dark", style = "cursor: pointer;", 
                                  title = "Click to assign to a scale", item_id)
                      })
                  ),
                  p(class = "small text-muted mt-1", "These items will still be collected but won't show in results scales.")
              )
            },
            
            hr(),
            # Closing text
            h6(bs_icon("chat-text"), " Closing Message", class="text-muted mb-2"),
            textAreaInput("prop_results_text_de", "Closing Text (German)", 
                          value = pg$results_text_de, height = "80px"),
            textAreaInput("prop_results_text_en", "Closing Text (English)", 
                          value = pg$results_text_en, height = "80px"),
            
            hr(),
            # Advanced options (collapsed by default)
            tags$details(style = "margin-top: 8px;",
                         tags$summary(class = "small text-muted", style = "cursor: pointer;", "Advanced Options"),
                         div(style = "padding: 12px 0;",
                             textAreaInput("prop_results_processing", "Results Processing (R function source)", 
                                           value = pg$processing_code %||% "", height = "150px",
                                           placeholder = "function(rv, config) { ... }"),
                             div(class = "alert alert-secondary py-2 px-3 mt-3 mb-0", style = "font-size: 0.8rem; line-height: 1.5;",
                                 bs_icon("code-slash"), tags$strong(" Custom CSS & JS"),
                                 " can be applied in the generated R script. Export your study and edit the script — this keeps the Studio focused and avoids overwhelming users with low-level code."
                             )
                         )
            )
          )
        },
        
      )
    } else {
      div(class="text-center text-muted p-4", "Select a page")
    }
  })
  
  # ===== SCALE MANAGEMENT OBSERVERS =====
  
  # Add new scale
  observeEvent(input$add_scale, {
    showModal(modalDialog(
      title = tagList(bs_icon("plus-circle"), " Create New Scale"),
      size = "m",
      easyClose = TRUE,
      textInput("new_scale_name", "Scale Name", placeholder = "e.g., Extraversion"),
      selectizeInput("new_scale_items", "Select Items", 
                     choices = items()$id, 
                     multiple = TRUE,
                     options = list(placeholder = "Select items to include...")),
      selectInput("new_scale_aggregation", "Aggregation Method",
                  choices = c("Mean" = "mean", "Sum" = "sum", "Min" = "min", "Max" = "max"),
                  selected = "mean"),
      footer = tagList(
        tags$button(type = "button", class = "btn btn-outline-secondary", `data-bs-dismiss` = "modal", "Cancel"),
        actionButton("confirm_add_scale", "Create Scale", class = "btn-primary")
      )
    ))
  })
  
  observeEvent(input$confirm_add_scale, {
    req(input$new_scale_name)
    
    scale_name <- trimws(input$new_scale_name)
    if(nchar(scale_name) == 0) {
      showNotification("Please enter a scale name", type = "error")
      return()
    }
    
    scale_items <- input$new_scale_items %||% character(0)
    agg_method <- input$new_scale_aggregation %||% "mean"
    
    # Create expression based on aggregation method
    expr <- switch(agg_method,
                   "mean" = "mean(items_vec, na.rm = TRUE)",
                   "sum" = "sum(items_vec, na.rm = TRUE)",
                   "min" = "min(items_vec, na.rm = TRUE)",
                   "max" = "max(items_vec, na.rm = TRUE)",
                   "mean(items_vec, na.rm = TRUE)"
    )
    
    # Find results page and add metric
    pgs <- pages()
    results_page_id <- NULL
    for(pid in names(pgs)) {
      if(pgs[[pid]]$type == "results") {
        results_page_id <- pid
        break
      }
    }
    
    if(is.null(results_page_id)) {
      showNotification("No results page found", type = "error")
      removeModal()
      return()
    }
    
    # Add the new metric
    if(is.null(pgs[[results_page_id]]$report_metrics)) {
      pgs[[results_page_id]]$report_metrics <- list()
    }
    
    new_metric <- list(
      name = scale_name,
      items = scale_items,
      expr = expr
    )
    
    pgs[[results_page_id]]$report_metrics <- c(pgs[[results_page_id]]$report_metrics, list(new_metric))
    pages(pgs)
    
    removeModal()
    showNotification(paste("Scale", scale_name, "created"), type = "message")
  })
  
  # Auto-create scales from item prefixes
  observeEvent(input$auto_create_scales, {
    itb <- items()
    if(nrow(itb) == 0) {
      showNotification("No items in repository", type = "warning")
      return()
    }
    
    # Extract prefixes (e.g., BFE from BFE_01)
    prefixes <- unique(gsub("_.*$", "", itb$id))
    prefixes <- prefixes[nchar(prefixes) > 0]
    
    if(length(prefixes) == 0) {
      showNotification("No item prefixes found (items should be named like PREFIX_01)", type = "warning")
      return()
    }
    
    # Find results page
    pgs <- pages()
    results_page_id <- NULL
    for(pid in names(pgs)) {
      if(pgs[[pid]]$type == "results") {
        results_page_id <- pid
        break
      }
    }
    
    if(is.null(results_page_id)) {
      showNotification("No results page found", type = "error")
      return()
    }
    
    # Create scales for each prefix
    if(is.null(pgs[[results_page_id]]$report_metrics)) {
      pgs[[results_page_id]]$report_metrics <- list()
    }
    
    existing_names <- sapply(pgs[[results_page_id]]$report_metrics, function(m) m$name)
    scales_created <- 0
    
    for(prefix in prefixes) {
      if(prefix %in% existing_names) next  # Skip if scale already exists
      
      prefix_items <- itb$id[grepl(paste0("^", prefix, "_"), itb$id)]
      if(length(prefix_items) > 0) {
        new_metric <- list(
          name = prefix,
          items = prefix_items,
          expr = "mean(items_vec, na.rm = TRUE)"
        )
        pgs[[results_page_id]]$report_metrics <- c(pgs[[results_page_id]]$report_metrics, list(new_metric))
        scales_created <- scales_created + 1
      }
    }
    
    pages(pgs)
    showNotification(paste(scales_created, "scale(s) created from item prefixes"), type = "message")
  })
  
  # Delete scale observers (dynamic)
  observe({
    pgs <- pages()
    curr <- current_page()
    if(is.null(curr) || is.null(pgs[[curr]])) return()
    pg <- pgs[[curr]]
    
    if(pg$type != "results" || is.null(pg$report_metrics)) return()
    
    lapply(seq_along(pg$report_metrics), function(i) {
      observeEvent(input[[paste0("del_scale_", i)]], {
        pgs <- pages()
        curr <- current_page()
        if(!is.null(pgs[[curr]]$report_metrics) && i <= length(pgs[[curr]]$report_metrics)) {
          scale_name <- pgs[[curr]]$report_metrics[[i]]$name
          pgs[[curr]]$report_metrics <- pgs[[curr]]$report_metrics[-i]
          pages(pgs)
          showNotification(paste("Scale", scale_name, "deleted"), type = "message")
        }
      }, ignoreInit = TRUE, once = TRUE)
      
      observeEvent(input[[paste0("edit_scale_", i)]], {
        pgs <- pages()
        curr <- current_page()
        if(!is.null(pgs[[curr]]$report_metrics) && i <= length(pgs[[curr]]$report_metrics)) {
          m <- pgs[[curr]]$report_metrics[[i]]
          showModal(modalDialog(
            title = tagList(bs_icon("pencil"), " Edit Scale: ", m$name),
            size = "m",
            easyClose = TRUE,
            textInput("edit_scale_name", "Scale Name", value = m$name),
            selectizeInput("edit_scale_items", "Select Items", 
                           choices = items()$id, 
                           selected = m$items,
                           multiple = TRUE),
            textAreaInput("edit_scale_expr", "Custom Expression", 
                          value = m$expr %||% "mean(items_vec, na.rm = TRUE)",
                          height = "80px",
                          placeholder = "mean(items_vec, na.rm = TRUE)"),
            tags$small(class = "text-muted", "Use 'items_vec' to reference the item values"),
            footer = tagList(
              tags$button(type = "button", class = "btn btn-outline-secondary", `data-bs-dismiss` = "modal", "Cancel"),
              actionButton("confirm_edit_scale", "Save Changes", class = "btn-primary", 
                           onclick = sprintf("Shiny.setInputValue('editing_scale_idx', %d)", i))
            )
          ))
        }
      }, ignoreInit = TRUE, once = TRUE)
    })
  })
  
  observeEvent(input$confirm_edit_scale, {
    idx <- input$editing_scale_idx
    req(idx)
    
    pgs <- pages()
    curr <- current_page()
    
    if(!is.null(pgs[[curr]]$report_metrics) && idx <= length(pgs[[curr]]$report_metrics)) {
      pgs[[curr]]$report_metrics[[idx]]$name <- input$edit_scale_name
      pgs[[curr]]$report_metrics[[idx]]$items <- input$edit_scale_items
      pgs[[curr]]$report_metrics[[idx]]$expr <- input$edit_scale_expr
      pages(pgs)
      removeModal()
      showNotification("Scale updated", type = "message")
    }
  })
  
  observeEvent(input$close_item_edit, { 
    selected_item(NULL) 
  })
  
  # Auto-save response_layout immediately on change so generate_script() stays in sync
  observeEvent(input$edit_item_response_layout, {
    sel <- selected_item()
    if(is.null(sel)) return()
    itb <- items()
    idx <- which(itb$id == sel)
    if(length(idx) == 0) return()
    itb[idx, "response_layout"] <- input$edit_item_response_layout %||% "vertical"
    items(itb)
  }, ignoreInit = TRUE)
  
  # Apply current layout to every item at once
  observeEvent(input$apply_layout_to_all, {
    layout_val <- input$edit_item_response_layout %||% "vertical"
    itb <- items()
    itb$response_layout <- layout_val
    items(itb)
    showNotification(paste0("Layout '", layout_val, "' applied to all ", nrow(itb), " items"), type = "message")
  })
  
  observeEvent(input$save_item, {
    sel <- selected_item()
    if(is.null(sel)) return()
    
    itb <- items()
    idx <- which(itb$id == sel)
    
    if(length(idx) == 0) {
      showNotification("Item nicht gefunden", type = "error")
      return()
    }
    
    # Check if ID changed and if new ID already exists
    new_id <- input$edit_item_id
    if(new_id != sel && new_id %in% itb$id) {
      showNotification("Item ID existiert bereits", type = "error")
      return()
    }
    
    # Update item
    itb[idx, "id"] <- new_id
    itb[idx, "Question_DE"] <- input$edit_item_q_de
    itb[idx, "Question_EN"] <- input$edit_item_q_en
    new_type <- input$edit_item_type %||% "irt"
    if (!"item_type" %in% names(itb)) itb$item_type <- "irt"
    itb[idx, "item_type"] <- new_type
    if (new_type != "free_text") {
      itb[idx, "ResponseCategories"] <- input$edit_item_resp
      itb[idx, "response_layout"] <- input$edit_item_response_layout %||% "vertical"
    }
    itb[idx, "exclude_from_report"] <- !isTRUE(input$edit_item_include_report)
    
    # If ID changed, update all page references
    if(new_id != sel) {
      pgs <- pages()
      for(pid in names(pgs)) {
        if(!is.null(pgs[[pid]]$items) && sel %in% pgs[[pid]]$items) {
          pgs[[pid]]$items[pgs[[pid]]$items == sel] <- new_id
        }
      }
      pages(pgs)
      selected_item(new_id)
    }
    
    items(itb)
    showNotification("Item saved", type = "message")
  })
  
  observeEvent(input$delete_item, {
    sel <- selected_item()
    if(is.null(sel)) return()
    
    showModal(modalDialog(
      title = "Delete Item",
      paste("Are you sure you want to delete the item", sel, "?"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_delete_item", "Delete", class = "btn-danger")
      )
    ))
  })
  
  # Inline editing observers registration to sync inline textareas to property inputs
  registered_inline_observers <- reactiveVal(character(0))
  observeEvent(items(), {
    itb <- items()
    reg <- registered_inline_observers()
    new_ids <- setdiff(itb$id, reg)
    if (length(new_ids) == 0) return()
    for (iid in new_ids) {
      sid <- sanitize_id(iid)
      local({
        my_iid <- iid
        my_sid <- sid
        observeEvent(input[[paste0('inline_item_q_de_', my_sid)]], {
          val <- input[[paste0('inline_item_q_de_', my_sid)]]
          if (!is.null(val)) updateTextAreaInput(session, 'edit_item_q_de', value = val)
        }, ignoreInit = TRUE)
        observeEvent(input[[paste0('inline_item_q_en_', my_sid)]], {
          val <- input[[paste0('inline_item_q_en_', my_sid)]]
          if (!is.null(val)) updateTextAreaInput(session, 'edit_item_q_en', value = val)
        }, ignoreInit = TRUE)
      })
      reg <- c(reg, iid)
    }
    registered_inline_observers(reg)
  })
  
  observeEvent(input$confirm_delete_item, {
    removeModal()
    sel <- selected_item()
    
    # Remove from item bank
    itb <- items()
    itb <- itb[itb$id != sel, ]
    items(itb)
    
    # Remove from all pages
    pgs <- pages()
    for(pid in names(pgs)) {
      if(!is.null(pgs[[pid]]$items)) {
        pgs[[pid]]$items <- pgs[[pid]]$items[pgs[[pid]]$items != sel]
      }
    }
    pages(pgs)
    
    selected_item(NULL)
    showNotification("Item deleted", type = "message")
  })
  
  observeEvent(
    list(input$prop_pg_title, input$prop_pg_title_en, input$prop_pg_type,
         input$prop_pg_content_de, input$prop_pg_content_en,
         input$prop_pg_scale, input$prop_pg_instructions_de, input$prop_pg_instructions_en,
         input$prop_results_radar, input$prop_results_scores,
         input$prop_results_text_de, input$prop_results_text_en,
         input$prop_results_processing),
    ignoreInit = TRUE, ignoreNULL = FALSE, {
      curr <- current_page()
      if(is.null(curr)) return()
      
      pgs <- pages()
      if(is.null(pgs[[curr]])) return()
      
      pgs[[curr]]$title <- input$prop_pg_title
      pgs[[curr]]$title_en <- input$prop_pg_title_en
      pgs[[curr]]$type <- input$prop_pg_type
      
      if(input$prop_pg_type == "custom") {
        pgs[[curr]]$content_de <- input$prop_pg_content_de
        pgs[[curr]]$content_en <- input$prop_pg_content_en
        # custom_css / custom_js / validate / completion_handler_src are not editable
        # in the Studio UI (removed to reduce complexity). Preserve existing stored values.
      } else if(input$prop_pg_type == "items") {
        pgs[[curr]]$scale_type <- input$prop_pg_scale
        pgs[[curr]]$instructions <- input$prop_pg_instructions_de
        pgs[[curr]]$instructions_en <- input$prop_pg_instructions_en
        # custom_css / custom_js / completion_handler_src preserved as stored
      } else if(input$prop_pg_type == "demographics") {
        # custom_css / custom_js / completion_handler_src preserved as stored
      } else if(input$prop_pg_type == "results") {
        pgs[[curr]]$show_radar_chart <- input$prop_results_radar
        pgs[[curr]]$show_scale_scores <- input$prop_results_scores
        pgs[[curr]]$results_text_de <- input$prop_results_text_de
        pgs[[curr]]$results_text_en <- input$prop_results_text_en
        # custom_css / custom_js / completion_handler_src preserved as stored
        pgs[[curr]]$processing_code <- input$prop_results_processing
        if(!is.null(input$prop_results_processing) && input$prop_results_processing != "") {
          valid_proc <- TRUE
          tryCatch({ parse(text = input$prop_results_processing) }, error = function(e) { valid_proc <<- FALSE })
          if(!valid_proc) {
            showNotification("Results processing code contains syntax errors and will be saved as plain text. Consider fixing it.", type = "warning")
          }
        }
        # Ensure report_metrics exists
        if(is.null(pgs[[curr]]$report_metrics)) pgs[[curr]]$report_metrics <- list()
      }
      
      pages(pgs)
    })
  
  observeEvent(input$remove_all_items_from_page, {
    curr <- current_page()
    pgs <- pages()
    if(!is.null(pgs[[curr]])) {
      pgs[[curr]]$items <- character(0)
      pages(pgs)
      showNotification("All items removed", type = "message")
    }
  })
  
  observeEvent(input$add_page_btn, {
    showModal(modalDialog(
      title = "Add New Page",
      selectInput("new_page_type", "Page Type", 
                  c("Custom Content" = "custom", "Demographics" = "demographics", 
                    "Questionnaire Items" = "items", "Results Page" = "results"), 
                  selected = "items"),
      textInput("new_page_title", "Title", value = "New Page"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_add_page", "Add", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  })
  
  observeEvent(input$confirm_add_page, {
    removeModal()
    pgs <- pages()
    
    next_num <- length(pgs) + 1
    pid <- paste0("page", next_num)
    
    new_pg <- list(
      id = pid, 
      type = input$new_page_type, 
      title = input$new_page_title, 
      title_en = input$new_page_title,
      items = character(0),
      custom_css = "",
      custom_js = "",
      validate = "",
      completion_handler_src = "",
      instructions = "",
      instructions_en = ""
    )
    
    if(input$new_page_type == "custom") {
      new_pg$content_de <- "<h2>New Page</h2><p>Edit content here...</p>"
      new_pg$content_en <- "<h2>New Page</h2><p>Edit content here...</p>"
    } else if(input$new_page_type == "items") {
      new_pg$scale_type <- "likert"
    } else if(input$new_page_type == "results") {
      new_pg$show_radar_chart <- TRUE
      new_pg$show_scale_scores <- TRUE
      new_pg$results_text_de <- "Thank you!"
      new_pg$results_text_en <- "Thank you!"
    } else if(input$new_page_type == "demographics") {
      new_pg$demo_fields <- list()
    }
    
    pgs[[pid]] <- new_pg
    pages(pgs)
    current_page(pid)
    showNotification("Page added", type = "message")
  })
  
  observeEvent(input$delete_page_btn, {
    curr <- current_page()
    pgs <- pages()
    
    if(length(pgs) <= 1) {
      showNotification("Cannot delete the last page", type = "warning")
      return()
    }
    
    showModal(modalDialog(
      title = "Delete Page",
      paste("Are you sure you want to delete this page?"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_delete_page", "Delete", class = "btn-danger")
      )
    ))
  })
  
  observeEvent(input$confirm_delete_page, {
    removeModal()
    curr <- current_page()
    pgs <- pages()
    pgs[[curr]] <- NULL
    pages(pgs)
    current_page(names(pgs)[1])
    showNotification("Page deleted", type = "message")
  })
  
  observeEvent(input$add_item_btn, {
    showModal(modalDialog(
      title = "Create New Item",
      textInput("new_item_id", "Item ID", value = paste0("ITEM_", sample(1000:9999, 1))),
      textAreaInput("new_item_q_de", "Question (German)", value = "", height = "80px"),
      textAreaInput("new_item_q_en", "Question (English)", value = "", height = "80px"),
      textInput("new_item_resp", "Response Scale", value = "1,2,3,4,5"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_add_item", "Create", class = "btn-primary")
      )
    ))
  })
  
  observeEvent(input$confirm_add_item, {
    removeModal()
    itb <- items()
    
    new_id <- input$new_item_id
    if(new_id %in% itb$id) {
      showNotification("Item ID existiert bereits", type = "error")
      return()
    }
    
    new_row <- data.frame(
      id = new_id,
      Question_DE = input$new_item_q_de,
      Question_EN = input$new_item_q_en,
      ResponseCategories = input$new_item_resp,
      a = NA_real_,
      b = NA_real_,
      response_layout = "vertical",
      stringsAsFactors = FALSE
    )
    
    items(rbind(itb, new_row))
    showNotification("Item created", type = "message")
  })
  
  # Handle CSV upload from custom file input
  observeEvent(input$upload_csv_data, {
    req(input$upload_csv_data)
    
    tryCatch({
      # Parse CSV from text content
      csv_content <- input$upload_csv_data$content
      df <- read.csv(text = csv_content, stringsAsFactors = FALSE)
      
      if(!"id" %in% names(df)) {
        df$id <- paste0("IMPORT_", seq_len(nrow(df)))
      }
      if(!"Question_DE" %in% names(df) && "Question" %in% names(df)) {
        df$Question_DE <- df$Question
      }
      if(!"Question_EN" %in% names(df)) {
        df$Question_EN <- df$Question_DE
      }
      if(!"ResponseCategories" %in% names(df)) {
        df$ResponseCategories <- "1,2,3,4,5"
      }
      if(!"a" %in% names(df)) {
        df$a <- 1.0
      }
      if(!"b" %in% names(df)) {
        df$b <- 0.0
      }
      if(!"response_layout" %in% names(df)) {
        df$response_layout <- "vertical"
      }
      
      items(df)
      # Auto-link imported items (respects exclude_from_report) to the results page scales by prefix
      pgs <- pages()
      for(item_id in df$id) {
        pgs <- auto_link_item_to_results(pgs, item_id, items_df = df)
      }
      pages(pgs)
      showNotification(paste(nrow(df), "Items imported", if(any(sapply(pgs, function(p) isTRUE(p$type=="results") && length(p$report_metrics) > 0))) "\u2014 scales auto-created" else ""), type = "message")
    }, error = function(e) {
      showNotification(paste("Import error:", e$message), type = "error")
    })
  })
  
  # Legacy upload_csv handler (kept for compatibility)
  observeEvent(input$upload_csv, {
    req(input$upload_csv)
    
    tryCatch({
      df <- read.csv(input$upload_csv$datapath, stringsAsFactors = FALSE)
      
      if(!"id" %in% names(df)) {
        df$id <- paste0("IMPORT_", seq_len(nrow(df)))
      }
      if(!"Question_DE" %in% names(df) && "Question" %in% names(df)) {
        df$Question_DE <- df$Question
      }
      if(!"Question_EN" %in% names(df)) {
        df$Question_EN <- df$Question_DE
      }
      if(!"ResponseCategories" %in% names(df)) {
        df$ResponseCategories <- "1,2,3,4,5"
      }
      if(!"a" %in% names(df)) {
        df$a <- 1.0
      }
      if(!"b" %in% names(df)) {
        df$b <- 0.0
      }
      if(!"response_layout" %in% names(df)) {
        df$response_layout <- "vertical"
      }
      
      items(df)
      # Auto-link imported items (respects exclude_from_report) to the results page scales by prefix
      pgs <- pages()
      for(item_id in df$id) {
        pgs <- auto_link_item_to_results(pgs, item_id, items_df = df)
      }
      pages(pgs)
      showNotification(paste(nrow(df), "Items importiert", if(any(sapply(pgs, function(p) isTRUE(p$type=="results") && length(p$report_metrics) > 0))) "\u2014 Skalen auto-erstellt" else ""), type = "message")
    }, error = function(e) {
      showNotification(paste("Fehler beim Import:", e$message), type = "error")
    })
  })
  
  # Handle config JSON upload from custom file input
  observeEvent(input$upload_config_data, {
    req(input$upload_config_data)
    
    tryCatch({
      data <- input$upload_config_data
      
      # Handle JSON files directly
      if(!isTRUE(data$isZip) && !is.null(data$content)) {
        config_data <- jsonlite::fromJSON(data$content, simplifyVector = FALSE)
        
        # Restore all settings (same logic as below)
        restore_config_from_data(session, config_data, pages, items, current_page)
        showNotification("Configuration loaded successfully!", type = "message", duration = 5)
      }
    }, error = function(e) {
      showNotification(paste("Error loading config:", e$message), type = "error", duration = 10)
    })
  })
  
  # Handle ZIP bundle upload (base64 data from JS)
  observeEvent(input$upload_config_zip_data, {
    req(input$upload_config_zip_data)
    
    tryCatch({
      # Decode base64 ZIP data
      zip_raw <- base64enc::base64decode(input$upload_config_zip_data)
      
      # Write to temp file
      temp_zip <- tempfile(fileext = ".zip")
      writeBin(zip_raw, temp_zip)
      
      # Extract to temp directory
      temp_dir <- tempfile()
      dir.create(temp_dir)
      zip::unzip(temp_zip, exdir = temp_dir)
      
      # Smart config file discovery - check multiple locations
      config_file <- NULL
      possible_paths <- c(
        file.path(temp_dir, "study_config.json"),
        file.path(temp_dir, "config.json"),
        list.files(temp_dir, pattern = "config\\.json$", recursive = TRUE, full.names = TRUE),
        list.files(temp_dir, pattern = "\\.json$", recursive = TRUE, full.names = TRUE)
      )
      
      for(path in possible_paths) {
        if(length(path) > 0 && file.exists(path[1])) {
          config_file <- path[1]
          break
        }
      }
      
      if(is.null(config_file)) {
        # Show what files were found for debugging
        all_files <- list.files(temp_dir, recursive = TRUE)
        showNotification(
          paste("No config JSON found in ZIP. Found files:", paste(head(all_files, 5), collapse = ", ")),
          type = "error", duration = 10
        )
        return()
      }
      
      # Load and restore config
      config_data <- jsonlite::fromJSON(config_file, simplifyVector = FALSE)
      restore_config_from_data(session, config_data, pages, items, current_page)
      
      # Clean up
      unlink(temp_zip)
      unlink(temp_dir, recursive = TRUE)
      
      showNotification(
        paste0("Bundle loaded successfully! (", basename(config_file), ")"),
        type = "message", duration = 5
      )
      
    }, error = function(e) {
      showNotification(paste("Error loading ZIP bundle:", e$message), type = "error", duration = 10)
    })
  })
  
  # Helper function to restore config from data
  restore_config_from_data <- function(session, config_data, pages, items, current_page) {
    if(!is.null(config_data$study_name)) updateTextInput(session, "study_name", value = config_data$study_name)
    if(!is.null(config_data$study_id)) updateTextInput(session, "study_id", value = config_data$study_id)
    if(!is.null(config_data$primary_lang)) updateSelectInput(session, "primary_lang", selected = config_data$primary_lang)
    # bilingual removed — not a create_study_config() parameter
    if(!is.null(config_data$theme)) updateSelectInput(session, "theme", selected = config_data$theme)
    if(!is.null(config_data$expert_mode)) { } # expert_mode removed, ignored for backward compat
    if(!is.null(config_data$adaptive)) updateCheckboxInput(session, "adaptive", value = config_data$adaptive)
    if(!is.null(config_data$irt_model)) updateSelectInput(session, "irt_model", selected = config_data$irt_model)
    if(!is.null(config_data$estimation_method)) updateSelectInput(session, "estimation_method", selected = config_data$estimation_method)
    if(!is.null(config_data$item_selection_criteria)) updateSelectInput(session, "item_selection_criteria", selected = config_data$item_selection_criteria)
    if(!is.null(config_data$cat_se_threshold)) updateNumericInput(session, "cat_se_threshold", value = config_data$cat_se_threshold)
    if(!is.null(config_data$min_items)) {
      updateNumericInput(session, "min_items", value = config_data$min_items)
      updateNumericInput(session, "min_items_nonadaptive", value = config_data$min_items)
    }
    if(!is.null(config_data$max_items)) updateNumericInput(session, "max_items", value = config_data$max_items)
    if(!is.null(config_data$progress_style)) updateSelectInput(session, "progress_style", selected = config_data$progress_style)
    if(!is.null(config_data$response_ui_type)) updateSelectInput(session, "response_ui_type", selected = config_data$response_ui_type)
    if(!is.null(config_data$response_layout))  updateSelectInput(session, "response_layout",  selected = config_data$response_layout)
    if(!is.null(config_data$session_save)) updateCheckboxInput(session, "session_save", value = config_data$session_save)
    if(!is.null(config_data$show_session_time)) updateCheckboxInput(session, "show_session_time", value = config_data$show_session_time)
    if(!is.null(config_data$max_session_duration)) updateNumericInput(session, "max_session_duration", value = config_data$max_session_duration)
    if(!is.null(config_data$max_response_time)) updateNumericInput(session, "max_response_time", value = config_data$max_response_time)
    if(!is.null(config_data$storage_backend)) updateSelectInput(session, "storage_backend", selected = config_data$storage_backend)
    if(!is.null(config_data$required_packages)) updateTextInput(session, "required_packages", value = config_data$required_packages)
    if(!is.null(config_data$show_introduction)) updateCheckboxInput(session, "show_introduction", value = config_data$show_introduction)
    if(!is.null(config_data$show_briefing)) updateCheckboxInput(session, "show_briefing", value = config_data$show_briefing)
    if(!is.null(config_data$show_consent)) updateCheckboxInput(session, "show_consent", value = config_data$show_consent)
    if(!is.null(config_data$show_gdpr_compliance)) updateCheckboxInput(session, "show_gdpr_compliance", value = config_data$show_gdpr_compliance)
    if(!is.null(config_data$show_debriefing)) updateCheckboxInput(session, "show_debriefing", value = config_data$show_debriefing)
    if(!is.null(config_data$enable_back_navigation)) updateCheckboxInput(session, "enable_back_navigation", value = config_data$enable_back_navigation)
    if(!is.null(config_data$report_formats)) updateCheckboxGroupInput(session, "report_formats", selected = config_data$report_formats)
    if(!is.null(config_data$cache_enabled)) updateCheckboxInput(session, "cache_enabled", value = config_data$cache_enabled)
    if(!is.null(config_data$parallel_computation)) updateCheckboxInput(session, "parallel_computation", value = config_data$parallel_computation)
    if(!is.null(config_data$fast_item_selection)) updateCheckboxInput(session, "fast_item_selection", value = config_data$fast_item_selection)
    if(!is.null(config_data$feedback_enabled)) updateCheckboxInput(session, "feedback_enabled", value = config_data$feedback_enabled)
    if(!is.null(config_data$primary_color_override)) {
      colourpicker::updateColourInput(session, "primary_color_override", value = config_data$primary_color_override)
      ov <- color_overrides()
      ov$primary <- config_data$primary_color_override
      color_overrides(ov)
    }
    if(!is.null(config_data$accent_color_override)) {
      colourpicker::updateColourInput(session, "accent_color_override", value = config_data$accent_color_override)
      ov <- color_overrides()
      ov$accent <- config_data$accent_color_override
      color_overrides(ov)
    }
    if(!is.null(config_data$text_color_override)) {
      colourpicker::updateColourInput(session, "text_color_override", value = config_data$text_color_override)
      ov <- color_overrides()
      ov$text <- config_data$text_color_override
      color_overrides(ov)
    }
    
    # Restore pages
    if(!is.null(config_data$pages)) {
      pages(config_data$pages)
      current_page(names(config_data$pages)[1])
    }
    
    # Restore items
    if(!is.null(config_data$items)) {
      items_df <- as.data.frame(config_data$items)
      items(items_df)
    }
  }
  
  # Upload config JSON or bundle ZIP handler (legacy fileInput)
  observeEvent(input$upload_config, {
    req(input$upload_config)
    
    tryCatch({
      file_path <- input$upload_config$datapath
      file_ext <- tools::file_ext(input$upload_config$name)
      
      if(tolower(file_ext) == "zip") {
        # Extract zip to temp directory
        temp_dir <- tempdir()
        zip::unzip(file_path, exdir = temp_dir)
        
        # Look for study_config.json
        config_file <- file.path(temp_dir, "study_config.json")
        if(!file.exists(config_file)) {
          showNotification("No study_config.json found in ZIP", type = "error")
          return()
        }
        file_path <- config_file
      }
      
      config_data <- jsonlite::fromJSON(file_path, simplifyVector = FALSE)
      
      # Restore all settings using the shared restore function
      restore_config_from_data(session, config_data, pages, items, current_page)
      
      showNotification("Configuration successfully loaded!", type = "message", duration = 5)
    }, error = function(e) {
      showNotification(paste("Error loading config:", e$message), type = "error", duration = 10)
    })
  })
  
  # Download handler for sample CSV template
  output$download_sample_csv <- downloadHandler(
    filename = function() {
      "inrep_item_template.csv"
    },
    content = function(file) {
      # Create a sample item bank with proper format and comments
      sample_data <- data.frame(
        id = c("ITEM_01", "ITEM_02", "ITEM_03", "ITEM_04", "ITEM_05"),
        Question_DE = c(
          "Ich fuehle mich wohl in sozialen Situationen.",
          "Ich plane meine Aufgaben im Voraus.",
          "Ich bleibe auch unter Druck ruhig.",
          "Ich bin neugierig auf neue Ideen.",
          "Ich helfe anderen gerne."
        ),
        Question_EN = c(
          "I feel comfortable in social situations.",
          "I plan my tasks ahead of time.",
          "I stay calm even under pressure.",
          "I am curious about new ideas.",
          "I enjoy helping others."
        ),
        ResponseCategories = c(
          "1,2,3,4,5",
          "1,2,3,4,5",
          "1,2,3,4,5",
          "1,2,3,4,5",
          "1,2,3,4,5"
        ),
        a = c(1.2, 1.0, 0.9, 1.1, 1.3),
        b = c(-0.5, 0.0, 0.3, -0.2, 0.1),
        stringsAsFactors = FALSE
      )
      write.csv(sample_data, file, row.names = FALSE, fileEncoding = "UTF-8")
    }
  )
  
  # GENERATE COMPLETE R SCRIPT
  generate_script <- function() {
    pgs <- pages()
    itb <- items()
    
    # ===========================================================================
    # STEP 1: Determine ALL configuration options from UI inputs
    # ===========================================================================
    
    # Basic study info
    study_name <- input$study_name %||% "My Assessment Study"
    study_id <- input$study_id %||% paste0("study_", format(Sys.Date(), "%Y%m%d"))
    primary_lang <- input$primary_lang %||% "en"
    theme_name <- input$theme %||% "hildesheim"
    # Adaptive testing settings (only if adaptive enabled)
    adaptive_flag <- isTRUE(input$adaptive)
    irt_model <- if(adaptive_flag) (input$irt_model %||% "GRM") else ""
    estimation_method <- if(adaptive_flag) (input$estimation_method %||% "EAP") else ""
    item_selection <- if(adaptive_flag) (input$item_selection_criteria %||% "MI") else ""
    min_sem <- if(adaptive_flag) (input$cat_se_threshold %||% 0.3) else 0.3
    
    # Study flow options
    show_introduction <- isTRUE(input$show_introduction %||% TRUE)
    show_briefing <- isTRUE(input$show_briefing %||% TRUE)
    show_consent <- isTRUE(input$show_consent %||% TRUE)
    show_gdpr <- isTRUE(input$show_gdpr_compliance %||% TRUE)
    show_debriefing <- isTRUE(input$show_debriefing %||% TRUE)
    enable_back_nav <- isTRUE(input$enable_back_navigation %||% TRUE)
    
    # Response & Progress settings
    response_ui_type <- input$response_ui_type %||% "radio"
    response_layout  <- input$response_layout  %||% "vertical"
    progress_style <- input$progress_style %||% "circle"
    
    # Session management
    session_save <- isTRUE(input$session_save %||% TRUE)
    show_session_time <- isTRUE(input$show_session_time)
    max_session_duration <- as.integer(input$max_session_duration %||% 60)
    max_response_time <- as.integer(input$max_response_time %||% 300)
    
    # Item configuration
    min_items <- if(adaptive_flag) {
      as.integer(input$min_items %||% 5)
    } else {
      as.integer(input$min_items_nonadaptive %||% input$min_items %||% 5)
    } 
    max_items_val <- as.integer(input$max_items %||% 0)
    if(max_items_val == 0) max_items_val <- nrow(itb)  # 0 means all items
    
    # Export formats
    report_formats <- input$report_formats
    if(is.null(report_formats) || length(report_formats) == 0) {
      report_formats <- c("rds", "csv", "json")
    }
    
    # Performance settings
    cache_enabled <- isTRUE(input$cache_enabled %||% TRUE)
    parallel_computation <- isTRUE(input$parallel_computation %||% TRUE)
    fast_item_selection <- isTRUE(input$fast_item_selection %||% TRUE)
    feedback_enabled <- isTRUE(input$feedback_enabled)
    
    # Storage backend
    storage_backend <- input$storage_backend %||% "local"
    
    # ===========================================================================
    # STEP 2: Build item bank data frame code
    # ===========================================================================
    
    # Ensure item bank has required columns with safe defaults
    if(nrow(itb) == 0) {
      itb <- data.frame(
        id = "ITEM_01",
        Question_DE = "Example question (please add items)",
        Question_EN = "Example question (please add items)",
        ResponseCategories = "1,2,3,4,5",
        a = 1.0,
        b = 0.0,
        stringsAsFactors = FALSE
      )
    }
    
    # Fill any NA values with defaults
    itb$id <- ifelse(is.na(itb$id), paste0("ITEM_", seq_len(nrow(itb))), itb$id)
    itb$Question_DE <- ifelse(is.na(itb$Question_DE), itb$Question_EN %||% "Question", itb$Question_DE)
    itb$Question_EN <- ifelse(is.na(itb$Question_EN), itb$Question_DE %||% "Question", itb$Question_EN)
    itb$ResponseCategories <- ifelse(is.na(itb$ResponseCategories), "1,2,3,4,5", itb$ResponseCategories)
    itb$a <- ifelse(is.na(itb$a), 1.0, itb$a)
    itb$b <- ifelse(is.na(itb$b), 0.0, itb$b)
    if(!"response_layout" %in% names(itb)) itb$response_layout <- "vertical"
    itb$response_layout <- ifelse(is.na(itb$response_layout) | !nzchar(itb$response_layout), "vertical", itb$response_layout)
    
    # Include response_layout column only when any item uses a non-default layout
    has_custom_layout <- "response_layout" %in% names(itb) && any(!is.na(itb$response_layout) & itb$response_layout != "vertical")
    
    # Include item_type column only when any item is free_text
    has_free_text <- "item_type" %in% names(itb) && any(!is.na(itb$item_type) & itb$item_type == "free_text")
    item_types_vec <- if (has_free_text) {
      ifelse(is.na(itb$item_type), "irt", as.character(itb$item_type))
    } else character(0)
    
    # Generate item bank code - use Question column for bilingual support
    layout_col_line <- if(has_custom_layout) {
      paste0("  response_layout = c(", paste(sapply(itb$response_layout, safe_quote), collapse = ", "), "),\n")
    } else ""
    
    item_type_col_line <- if(has_free_text) {
      paste0("  item_type = c(", paste(sapply(item_types_vec, safe_quote), collapse = ", "), "),\n")
    } else ""
    
    items_code <- paste0(
      '# =============================================================================\n',
      '# Item Bank Definition\n',
      '# =============================================================================\n',
      'all_items <- data.frame(\n',
      '  id = c(', paste(sapply(itb$id, safe_quote), collapse = ", "), '),\n',
      '  Question = c(', paste(sapply(itb$Question_DE, safe_quote), collapse = ", "), '),\n',
      '  Question_DE = c(', paste(sapply(itb$Question_DE, safe_quote), collapse = ", "), '),\n',
      '  Question_EN = c(', paste(sapply(itb$Question_EN, safe_quote), collapse = ", "), '),\n',
      '  ResponseCategories = c(', paste(sapply(itb$ResponseCategories, safe_quote), collapse = ", "), '),\n',
      '  a = c(', paste(safe_numeric(itb$a, 1.0), collapse = ", "), '),\n',
      '  b = c(', paste(safe_numeric(itb$b, 0.0), collapse = ", "), '),\n',
      layout_col_line,
      item_type_col_line,
      '  stringsAsFactors = FALSE\n',
      ')\n\n',
      '# For GRM (Graded Response Model) with 5-category items, inrep expects\n',
      '# Samejima boundary thresholds b1..b4 (one fewer than the number of categories).\n',
      '# If only a single b is provided, spread thresholds symmetrically around b.\n',
      'if (all(c("a", "b") %in% names(all_items)) && !all(c("b1", "b2", "b3", "b4") %in% names(all_items))) {\n',
      '  all_items$b1 <- all_items$b - 1.5\n',
      '  all_items$b2 <- all_items$b - 0.5\n',
      '  all_items$b3 <- all_items$b + 0.5\n',
      '  all_items$b4 <- all_items$b + 1.5\n',
      '}\n\n',
      '# Helper function to get items for language\n',
      'get_items_for_language <- function(lang = "de") {\n',
      '  items <- all_items\n',
      '  if (lang == "en" && "Question_EN" %in% names(items)) {\n',
      '    items$Question <- items$Question_EN\n',
      '  } else if ("Question_DE" %in% names(items)) {\n',
      '    items$Question <- items$Question_DE\n',
      '  }\n',
      '  return(items)\n',
      '}\n'
    )
    
    # ===========================================================================
    # STEP 3: Collect all demographic fields from all pages
    # ===========================================================================
    all_demo_fields <- list()
    all_input_types <- list()
    
    for(pid in names(pgs)) {
      pg <- pgs[[pid]]
      if(pg$type == "demographics" && !is.null(pg$demo_fields) && length(pg$demo_fields) > 0) {
        for(field in pg$demo_fields) {
          field_name <- field$name
          if(!is.null(field_name) && nzchar(field_name)) {
            all_demo_fields[[field_name]] <- field
            # Map type to input_type
            if(field$type == "text") {
              all_input_types[[field_name]] <- "text"
            } else if(field$type == "number") {
              all_input_types[[field_name]] <- "numeric"
            } else if(field$type == "select") {
              all_input_types[[field_name]] <- "select"
            } else if(field$type == "radio") {
              all_input_types[[field_name]] <- "radio"
            } else if(field$type == "checkbox") {
              all_input_types[[field_name]] <- "checkbox"
            } else if(field$type == "slider") {
              all_input_types[[field_name]] <- "slider"
            } else {
              all_input_types[[field_name]] <- "text"
            }
          }
        }
      }
    }
    
    # ===========================================================================
    # STEP 4: Generate demographic_configs code (HilFo.R style)
    # ===========================================================================
    demographic_configs_code <- '# Demographic Field Configurations (empty - add demographics pages)\ndemographic_configs <- list()\n'
    if(length(all_demo_fields) > 0) {
      field_codes <- sapply(names(all_demo_fields), function(fname) {
        f <- all_demo_fields[[fname]]
        parts <- c()
        
        # question and question_en
        if(!is.null(f$label_de) && nzchar(f$label_de)) {
          parts <- c(parts, sprintf('    question = %s', safe_quote(f$label_de)))
        }
        if(!is.null(f$label_en) && nzchar(f$label_en)) {
          parts <- c(parts, sprintf('    question_en = %s', safe_quote(f$label_en)))
        }
        
        # For select/radio/checkbox: options
        if(f$type %in% c("select", "radio", "checkbox")) {
          if(!is.null(f$options_de) && length(f$options_de) > 0) {
            opts_de <- paste(sapply(seq_along(f$options_de), function(i) {
              sprintf('%s=%s', safe_quote(f$options_de[i]), safe_quote(as.character(i)))
            }), collapse = ", ")
            parts <- c(parts, sprintf('    options = c(%s)', opts_de))
          }
          if(!is.null(f$options_en) && length(f$options_en) > 0) {
            opts_en <- paste(sapply(seq_along(f$options_en), function(i) {
              sprintf('%s=%s', safe_quote(f$options_en[i]), safe_quote(as.character(i)))
            }), collapse = ", ")
            parts <- c(parts, sprintf('    options_en = c(%s)', opts_en))
          }
          if(isTRUE(f$allow_other_text)) {
            parts <- c(parts, '    allow_other_text = TRUE')
          }
        }
        
        # For slider: min, max, step, default, labels
        if(f$type == "slider") {
          parts <- c(parts, '    type = "slider"')
          if(!is.null(f$min)) parts <- c(parts, sprintf('    min = %s', safe_numeric(f$min, 0)))
          if(!is.null(f$max)) parts <- c(parts, sprintf('    max = %s', safe_numeric(f$max, 100)))
          if(!is.null(f$step)) parts <- c(parts, sprintf('    step = %s', safe_numeric(f$step, 1)))
          if(!is.null(f$default)) parts <- c(parts, sprintf('    default = %s', if(is.null(f$default)) "NULL" else safe_numeric(f$default, NULL)))
          if(!is.null(f$label_min) && nzchar(f$label_min)) {
            parts <- c(parts, sprintf('    label_min = %s', safe_quote(f$label_min)))
          }
          if(!is.null(f$label_max) && nzchar(f$label_max)) {
            parts <- c(parts, sprintf('    label_max = %s', safe_quote(f$label_max)))
          }
          if(!is.null(f$label_min_en) && nzchar(f$label_min_en)) {
            parts <- c(parts, sprintf('    label_min_en = %s', safe_quote(f$label_min_en)))
          }
          if(!is.null(f$label_max_en) && nzchar(f$label_max_en)) {
            parts <- c(parts, sprintf('    label_max_en = %s', safe_quote(f$label_max_en)))
          }
        }
        
        # For text fields: html_content
        if(f$type == "text") {
          if(!is.null(f$html_content) && nzchar(f$html_content)) {
            parts <- c(parts, sprintf('    html_content = %s', safe_quote(f$html_content)))
          }
          if(!is.null(f$html_content_en) && nzchar(f$html_content_en)) {
            parts <- c(parts, sprintf('    html_content_en = %s', safe_quote(f$html_content_en)))
          }
        }
        
        # required
        parts <- c(parts, sprintf('    required = %s', if(isTRUE(f$required)) "TRUE" else "FALSE"))
        
        sprintf('  %s = list(\n%s\n  )', fname, paste(parts, collapse = ",\n"))
      })
      
      demographic_configs_code <- sprintf(
        '# =============================================================================
# Demographic Field Configurations (HilFo.R style)
# =============================================================================
demographic_configs <- list(
%s
)
',
      paste(field_codes, collapse = ",\n")
      )
    }
    
    # ===========================================================================
    # STEP 5: Generate input_types code
    # ===========================================================================
    input_types_code <- '# Input Type Mappings (empty - add demographics)\ninput_types <- list()\n'
    if(length(all_input_types) > 0) {
      type_assignments <- sapply(names(all_input_types), function(fname) {
        sprintf('  %s = %s', fname, safe_quote(all_input_types[[fname]]))
      })
      input_types_code <- sprintf(
        '# =============================================================================
# Input Type Mappings
# =============================================================================
input_types <- list(
%s
)
',
      paste(type_assignments, collapse = ",\n")
      )
    }
    
    # ===========================================================================
    # STEP 6: Generate custom_page_flow code (HilFo.R style)
    # ===========================================================================
    page_code_list <- lapply(names(pgs), function(pid) {
      pg <- pgs[[pid]]
      
      # Ensure pg$type is valid - default to "custom" if missing
      pg_type <- pg$type %||% "custom"
      
      if(pg_type == "custom") {
        css_code <- if(!is.null(pg$custom_css) && nzchar(pg$custom_css)) sprintf(",\n    custom_css = %s", safe_quote(pg$custom_css)) else ""
        js_code <- if(!is.null(pg$custom_js) && nzchar(pg$custom_js)) sprintf(",\n    custom_js = %s", safe_quote(pg$custom_js)) else ""
        validate_js <- if(!is.null(pg$validate) && nzchar(pg$validate)) sprintf(",\n    validate = %s", safe_quote(pg$validate)) else ""
        completion_handler_code <- if(!is.null(pg$completion_handler_src) && nzchar(pg$completion_handler_src)) sprintf(",\n    completion_handler = %s", pg$completion_handler_src) else ""
        
        sprintf(
          '  list(
    id = %s,
    type = "custom",
    title = %s,
    title_en = %s,
    content = %s,
    content_en = %s,
    required = FALSE%s%s%s%s
  )',
          safe_quote(pg$id %||% pid),
          safe_quote(pg$title %||% "Page"),
          safe_quote(pg$title_en %||% pg$title %||% "Page"),
          safe_quote(pg$content_de %||% pg$content %||% ""),
          safe_quote(pg$content_en %||% pg$content %||% ""),
          css_code, js_code, validate_js, completion_handler_code
        )
      } else if(pg_type == "demographics") {
        # Reference demographic field names (HilFo.R style)
        demo_names <- if(!is.null(pg$demo_fields) && length(pg$demo_fields) > 0) {
          field_names <- sapply(pg$demo_fields, function(f) f$name)
          field_names <- field_names[!is.na(field_names) & nzchar(field_names)]
          if(length(field_names) > 0) {
            sprintf('c(%s)', paste(sapply(field_names, safe_quote), collapse = ", "))
          } else {
            'c()'
          }
        } else {
          'c()'
        }
        
        css_code <- if(!is.null(pg$custom_css) && nzchar(pg$custom_css)) sprintf(",\n    custom_css = %s", safe_quote(pg$custom_css)) else ""
        js_code  <- if(!is.null(pg$custom_js)  && nzchar(pg$custom_js))  sprintf(",\n    custom_js = %s",  safe_quote(pg$custom_js))  else ""
        completion_handler_code <- if(!is.null(pg$completion_handler_src) && nzchar(pg$completion_handler_src)) sprintf(",\n    completion_handler = %s", pg$completion_handler_src) else ""
        
        sprintf(
          '  list(
    id = %s,
    type = "demographics",
    title = %s,
    title_en = %s,
    demographics = %s,
    required = FALSE%s%s%s
  )',
          safe_quote(pg$id %||% pid),
          safe_quote(pg$title %||% "Demographics"),
          safe_quote(pg$title_en %||% pg$title %||% "Demographics"),
          demo_names,
          css_code, js_code, completion_handler_code
        )
      } else if(pg_type == "items") {
        item_indices <- match(pg$items, itb$id)
        item_indices <- item_indices[!is.na(item_indices)]
        if(length(item_indices) == 0) item_indices <- seq_len(min(3, nrow(itb)))  # Default to first 3 items
        
        css_code <- if(!is.null(pg$custom_css) && nzchar(pg$custom_css)) sprintf(",\n    custom_css = %s", safe_quote(pg$custom_css)) else ""
        js_code  <- if(!is.null(pg$custom_js)  && nzchar(pg$custom_js))  sprintf(",\n    custom_js = %s",  safe_quote(pg$custom_js))  else ""
        instructions_code <- if(!is.null(pg$instructions) && nzchar(pg$instructions)) sprintf(",\n    instructions = %s", safe_quote(pg$instructions)) else ""
        instructions_en_code <- if(!is.null(pg$instructions_en) && nzchar(pg$instructions_en)) sprintf(",\n    instructions_en = %s", safe_quote(pg$instructions_en)) else ""
        completion_handler_code <- if(!is.null(pg$completion_handler_src) && nzchar(pg$completion_handler_src)) sprintf(",\n    completion_handler = %s", pg$completion_handler_src) else ""
        
        sprintf(
          '  list(
    id = %s,
    type = "items",
    title = %s,
    title_en = %s,
    item_indices = c(%s),
    scale_type = %s,
    randomize = FALSE,
    required = FALSE%s%s%s%s%s
  )',
          safe_quote(pg$id %||% pid),
          safe_quote(pg$title %||% "Items"),
          safe_quote(pg$title_en %||% pg$title %||% "Items"),
          paste(item_indices, collapse = ", "),
          safe_quote(pg$scale_type %||% "likert"),
          instructions_code, instructions_en_code, css_code, js_code, completion_handler_code
        )
      } else if(pg_type == "results") {
        # Generate report_metrics list code
        metrics_code <- ""
        if(!is.null(pg$report_metrics) && length(pg$report_metrics) > 0) {
          metric_entries <- sapply(pg$report_metrics, function(m) {
            items_vec <- if(length(m$items) > 0) {
              paste0("c(", paste(sapply(m$items, safe_quote), collapse = ", "), ")")
            } else {
              "character(0)"
            }
            sprintf('      list(name = %s, label = %s, icon = %s, items = %s, formula = %s)',
                    safe_quote(m$name %||% "Scale"),
                    safe_quote(m$label %||% m$name %||% "Scale"),
                    safe_quote(m$icon %||% "bar-chart"),
                    items_vec,
                    safe_quote(m$formula %||% "mean")
            )
          })
          metrics_code <- sprintf(",\n    report_metrics = list(\n%s\n    )", paste(metric_entries, collapse = ",\n"))
        }
        
        css_code <- if(!is.null(pg$custom_css) && nzchar(pg$custom_css)) sprintf(",\n    custom_css = %s", safe_quote(pg$custom_css)) else ""
        js_code  <- if(!is.null(pg$custom_js)  && nzchar(pg$custom_js))  sprintf(",\n    custom_js = %s",  safe_quote(pg$custom_js))  else ""
        completion_handler_code <- if(!is.null(pg$completion_handler_src) && nzchar(pg$completion_handler_src)) sprintf(",\n    completion_handler = %s", pg$completion_handler_src) else ""
        processing_code_str <- if(!is.null(pg$processing_code) && nzchar(pg$processing_code)) sprintf(",\n    processing_code = %s", pg$processing_code) else ""
        
        sprintf(
          '  list(
    id = %s,
    type = "results",
    title = %s,
    title_en = %s,
    show_radar_chart = %s,
    show_scale_scores = %s,
    results_text_de = %s,
    results_text_en = %s,
    required = FALSE%s%s%s%s%s
  )',
          safe_quote(pg$id %||% pid),
          safe_quote(pg$title %||% "Results"),
          safe_quote(pg$title_en %||% pg$title %||% "Results"),
          if(isTRUE(pg$show_radar_chart)) "TRUE" else "FALSE",
          if(isTRUE(pg$show_scale_scores)) "TRUE" else "FALSE",
          safe_quote(pg$results_text_de %||% "Thank you!"),
          safe_quote(pg$results_text_en %||% "Thank you!"),
          metrics_code, css_code, js_code, completion_handler_code, processing_code_str
        )
      } else {
        # Unknown page type - treat as custom
        sprintf(
          '  list(
    id = %s,
    type = "custom",
    title = %s,
    title_en = %s,
    content = "",
    content_en = "",
    required = FALSE
  )',
          safe_quote(pg$id %||% pid),
          safe_quote(pg$title %||% "Page"),
          safe_quote(pg$title_en %||% pg$title %||% "Page")
        )
      }
    })
    
    # Remove any NULL entries from page_code_list
    page_code_list <- page_code_list[!sapply(page_code_list, is.null)]
    
    # Ensure we have at least one page
    if(length(page_code_list) == 0) {
      page_code_list <- list('  list(id = "page1", type = "custom", title = "Welcome", title_en = "Welcome", content = "", content_en = "")')
    }
    
    page_flow_code <- sprintf(
      '# =============================================================================
# Page Flow Definition (HilFo.R style)
# =============================================================================
custom_page_flow <- list(
%s
)
',
    paste(page_code_list, collapse = ",\n")
    )

# ===========================================================================
# STEP 7: Generate color customization configuration code
# ===========================================================================
# Serialize custom color overrides so they persist in generated script
ov <- color_overrides()
# Use effective colors: if user set overrides, use them; otherwise use theme defaults.
# This ensures the generated code matches exactly what the user saw in preview.
theme_base <- get_preview_theme_css(theme_name)
effective_primary <- ov$primary %||% theme_base$primary
effective_accent <- ov$accent %||% theme_base$accent
effective_text <- ov$text %||% theme_base$text

serialize_list <- function(x) {
  if (is.null(x) || length(x) == 0) return("list()")
  paste(capture.output(dput(x)), collapse = "\n")
}
element_colors_code <- serialize_list(ov$element_colors)

color_config_code <- sprintf('# =============================================================================
# Color Customization Configuration (Optional)
# =============================================================================
# Customize colors by modifying theme_config below
theme_config <- list(
  primary_color = %s,    # Primary color (from theme or custom override)
  accent_color  = %s,    # Accent color
  text_color    = %s,    # Text color
  element_colors = %s    # Element-specific colors by page/element
)
# Example element_colors structure:
# element_colors = list(
#   page1 = list(scale_Math = "#ff0000", scale_Verbal = "#00ff00"),
#   page2 = list(scale_Stress = "#ffaa00")
# )
',
safe_quote(effective_primary),
safe_quote(effective_accent),
safe_quote(effective_text),
element_colors_code
)

# ===========================================================================
# STEP 7b: Generate storage configuration code
# ===========================================================================
storage_code <- if(storage_backend == "webdav") {
  sprintf(
    '# =============================================================================
# WebDAV Storage Configuration
# =============================================================================
# SECURITY: Store your WebDAV password in an environment variable.
# To set it, add this line to your .Renviron file (run usethis::edit_r_environ()):
#   INREP_WEBDAV_PASSWORD=your_password_here
# Then restart R. Never commit passwords to version control.
#
# HOW TO SET UP WEBDAV (e.g., Nextcloud/Academic Cloud):
# 1. Create a share link for a folder in your cloud storage
# 2. Copy the share URL (e.g., https://sync.academiccloud.de/index.php/s/ABC123/)
# 3. Set WEBDAV_URL to the share URL
# 4. Set the share token (the ABC123 part) as WEBDAV_SHARE_TOKEN
# 5. Set the password used to protect the share link
# =============================================================================
WEBDAV_URL <- %s
WEBDAV_PASSWORD <- Sys.getenv("INREP_WEBDAV_PASSWORD", "")
WEBDAV_SHARE_TOKEN <- %s

if (nchar(WEBDAV_PASSWORD) == 0) {
  message("WARNING: INREP_WEBDAV_PASSWORD environment variable not set.")
  message("Data will be saved locally only. Set it via usethis::edit_r_environ()")
}

storage_config <- list(
  type = "webdav",
  url = WEBDAV_URL,
  username = WEBDAV_SHARE_TOKEN,
  password = WEBDAV_PASSWORD
)
',
  safe_quote(input$webdav_url %||% ""),
  safe_quote(input$webdav_username %||% "")
  )
} else {
  sprintf(
    '# =============================================================================
# Local File Storage Configuration
# =============================================================================
storage_config <- list(
  type = "local",
  path = %s,
  format = %s
)
',
  safe_quote(input$local_save_path %||% "./data/"),
  safe_quote(input$local_format %||% "csv")
  )
}
  
  # ===========================================================================
  # STEP 8: Generate complete study configuration code
  # ===========================================================================
  # Build the create_study_config call with ALL parameters
  config_params <- c()
  
  # Basic info
  config_params <- c(config_params, sprintf('  name = %s', safe_quote(study_name)))
  config_params <- c(config_params, sprintf('  study_key = %s', safe_quote(study_id)))
  config_params <- c(config_params, sprintf('  theme = %s', safe_quote(theme_name)))
  
  # Page flow
  config_params <- c(config_params, '  custom_page_flow = custom_page_flow')
  
  # Demographics
  if(length(all_demo_fields) > 0) {
    config_params <- c(config_params, sprintf('  demographics = c(%s)', paste(sapply(names(all_demo_fields), safe_quote), collapse = ", ")))
    config_params <- c(config_params, '  demographic_configs = demographic_configs')
    config_params <- c(config_params, '  input_types = input_types')
  } else {
    config_params <- c(config_params, '  demographics = NULL')
    config_params <- c(config_params, '  demographic_configs = list()')
    config_params <- c(config_params, '  input_types = list()')
  }
  
  # Language settings
  config_params <- c(config_params, sprintf('  language = %s', safe_quote(primary_lang)))
  # participant_languages: include when study has 2+ languages (enables floating language toggle)
  plv <- preview_langs()
  if (length(plv) >= 2) {
    config_params <- c(config_params, sprintf('  participant_languages = c(%s)',
                                              paste(sapply(plv, safe_quote), collapse = ", ")))
  }
  
  # Adaptive testing settings
  if(adaptive_flag) {
    config_params <- c(config_params, sprintf('  model = %s', safe_quote(irt_model)))
    config_params <- c(config_params, '  adaptive = TRUE')
    config_params <- c(config_params, sprintf('  estimation_method = %s', safe_quote(estimation_method)))
    config_params <- c(config_params, sprintf('  criteria = %s', safe_quote(item_selection)))
    config_params <- c(config_params, sprintf('  min_SEM = %s', min_sem))
  } else {
    config_params <- c(config_params, '  adaptive = FALSE')
  }
  
  # Response & progress
  config_params <- c(config_params, sprintf('  response_ui_type = %s', safe_quote(response_ui_type)))
  config_params <- c(config_params, sprintf('  response_layout = %s', safe_quote(response_layout)))
  config_params <- c(config_params, sprintf('  progress_style = %s', safe_quote(progress_style)))
  
  # Session management
  config_params <- c(config_params, sprintf('  session_save = %s', if(session_save) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  show_session_time = %s', if(show_session_time) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  max_session_duration = %d', max_session_duration))
  config_params <- c(config_params, sprintf('  max_response_time = %d', max_response_time))
  
  # Item configuration
  config_params <- c(config_params, sprintf('  min_items = %d', min_items))
  config_params <- c(config_params, sprintf('  max_items = %d', max_items_val))
  
  # Export formats
  config_params <- c(config_params, sprintf('  report_formats = c(%s)', paste(sapply(report_formats, safe_quote), collapse = ", ")))
  
  # Performance settings
  config_params <- c(config_params, sprintf('  cache_enabled = %s', if(cache_enabled) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  parallel_computation = %s', if(parallel_computation) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  fast_item_selection = %s', if(fast_item_selection) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  feedback_enabled = %s', if(feedback_enabled) "TRUE" else "FALSE"))
  
  # Study flow options
  config_params <- c(config_params, sprintf('  show_introduction = %s', if(show_introduction) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  show_briefing = %s', if(show_briefing) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  show_consent = %s', if(show_consent) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  show_gdpr_compliance = %s', if(show_gdpr) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  show_debriefing = %s', if(show_debriefing) "TRUE" else "FALSE"))
  config_params <- c(config_params, sprintf('  enable_back_navigation = %s', if(enable_back_nav) "TRUE" else "FALSE"))
  
  study_config_code <- sprintf(
    '# =============================================================================
# Study Configuration (create_study_config)
# =============================================================================
study_config <- inrep::create_study_config(
%s
)

# Attach theme_config to study_config so results_processor can access it
study_config$theme_config <- theme_config
',
  paste(config_params, collapse = ",\n")
  )

# ===========================================================================
# STEP 10: Generate launch_study code
# ===========================================================================
launch_params <- c()
launch_params <- c(launch_params, '  config = study_config')
launch_params <- c(launch_params, '  item_bank = all_items')
launch_params <- c(launch_params, '  theme_config = theme_config')

# Add WebDAV params if configured
if(storage_backend == "webdav" && nzchar(input$webdav_url %||% "")) {
  launch_params <- c(launch_params, '  webdav_url = WEBDAV_URL')
  launch_params <- c(launch_params, '  password = WEBDAV_PASSWORD')
}

# Save format
launch_params <- c(launch_params, sprintf('  save_format = %s', safe_quote(input$local_format %||% "csv")))

# Session save must also be passed to launch_study (it has its own parameter)
launch_params <- c(launch_params, sprintf('  session_save = %s', if(session_save) "TRUE" else "FALSE"))

# Debug mode (default FALSE) and browser launch
launch_params <- c(launch_params, '  debug_mode = FALSE')
launch_params <- c(launch_params, '  launch_browser = TRUE')

launch_code <- sprintf(
  '# =============================================================================
# Launch the Study
# =============================================================================
inrep::launch_study(
%s
)
',
paste(launch_params, collapse = ",\n")
)

# ===========================================================================
# STEP 9b: Generate results_processor function for visualizations
# ===========================================================================
# Find results page with report_metrics
pgs <- pages()
has_metrics <- FALSE
for(pg in pgs) {
  if(isTRUE(pg$type == "results") && !is.null(pg$report_metrics) && length(pg$report_metrics) > 0) {
    has_metrics <- TRUE
    break
  }
}

results_processor_code <- if(has_metrics) {
  paste0(
    '# =============================================================================\n',
    '# Results Processor Function (Adaptive-aware: theta/SE for CAT, M/SD for fixed)\n',
    '# Accepts: responses, item_bank, config, rv (inrep passes these automatically)\n',
    '# =============================================================================\n',
    '\n',
    'results_processor <- function(responses, item_bank, config = NULL, rv = NULL) {\n',
    '  # Determine language (default to German)\n',
    '  is_english <- FALSE\n',
    '  if(!is.null(config) && !is.null(config$language)) {\n',
    '    is_english <- (config$language == "en")\n',
    '  }\n',
    '  \n',
    '  # Detect adaptive mode\n',
    '  is_adaptive <- isTRUE(config$adaptive)\n',
    '  \n',
    '  # Find results page with metrics\n',
    '  results_page <- NULL\n',
    '  if(!is.null(config) && !is.null(config$custom_page_flow)) {\n',
    '    for(pg in config$custom_page_flow) {\n',
    '      if(isTRUE(pg$type == "results") && !is.null(pg$report_metrics)) {\n',
    '        results_page <- pg\n',
    '        break\n',
    '      }\n',
    '    }\n',
    '  }\n',
    '  \n',
    '  # If no metrics defined, show simple completion message\n',
    '  if(is.null(results_page) || is.null(results_page$report_metrics)) {\n',
    '    return(shiny::HTML(\'<div style="text-align: center; padding: 40px;"></div>\'))\n',
    '  }\n',
    '  \n',
    '  # Calculate scale scores from responses (M +/- SD)\n',
    '  scale_scores <- list()\n',
    '  for(metric in results_page$report_metrics) {\n',
    '    if(is.null(metric$name) || is.null(metric$items)) next\n',
    '    \n',
    '    metric_name <- metric$name\n',
    '    item_ids <- metric$items\n',
    '    \n',
    '    # Get responses for items in this metric\n',
    '    item_responses <- c()\n',
    '    if(!is.null(item_bank) && is.data.frame(item_bank) && "id" %in% names(item_bank)) {\n',
    '      for(item_id in item_ids) {\n',
    '        idx <- which(item_bank$id == item_id)\n',
    '        if(length(idx) > 0 && idx[1] <= length(responses)) {\n',
    '          val <- responses[idx[1]]\n',
    '          if(!is.na(val)) item_responses <- c(item_responses, val)\n',
    '        }\n',
    '      }\n',
    '    }\n',
    '    \n',
    '    if(length(item_responses) > 0) {\n',
    '      score <- mean(item_responses, na.rm = TRUE)\n',
    '      sd_val <- if(length(item_responses) > 1) sd(item_responses, na.rm = TRUE) else 0\n',
    '      max_val <- 5\n',
    '      if(!is.null(item_bank) && "ResponseCategories" %in% names(item_bank)) {\n',
    '        rc <- item_bank$ResponseCategories[1]\n',
    '        if(!is.na(rc) && nzchar(rc)) {\n',
    '          vals <- suppressWarnings(as.numeric(unlist(strsplit(as.character(rc), ","))))\n',
    '          vals <- vals[!is.na(vals)]\n',
    '          if(length(vals) > 0) max_val <- max(vals)\n',
    '        }\n',
    '      }\n',
    '      scale_scores[[metric_name]] <- list(\n',
    '        score = round(score, 2),\n',
    '        sd = round(sd_val, 2),\n',
    '        pct = min(100, round((score / max_val) * 100)),\n',
    '        label = if(!is.null(metric$label)) metric$label else metric_name\n',
    '      )\n',
    '    }\n',
    '  }\n',
    '  \n',
    '  # Helpers\n',
    '  sanitize_id <- function(x) gsub("[^A-Za-z0-9]", "_", x)\n',
    '  \n',
    '  # Resolve theme primary color\n',
    '  primary_color <- "#2563eb"\n',
    '  if(!is.null(config) && !is.null(config$theme_config) && !is.null(config$theme_config$primary_color)) {\n',
    '    primary_color <- config$theme_config$primary_color\n',
    '  }\n',
    '  element_colors <- NULL\n',
    '  if(!is.null(config) && !is.null(config$theme_config) && !is.null(config$theme_config$element_colors)) {\n',
    '    element_colors <- config$theme_config$element_colors\n',
    '  }\n',
    '  \n',
    '  results_title <- "Your Results"\n',
    '  parts <- list()\n',
    '  \n',
    '  # -------------------------------------------------------------------------\n',
    '  # ADAPTIVE SECTION: IRT ability estimate (theta +/- SE)\n',
    '  # -------------------------------------------------------------------------\n',
    '  if(is_adaptive) {\n',
    '    theta <- NULL; se <- NULL\n',
    '    # Prefer final theta from rv (most up-to-date)\n',
    '    if(!is.null(rv)) {\n',
    '      theta <- rv$current_ability\n',
    '      se    <- rv$ability_se %||% rv$current_se\n',
    '    }\n',
    '    # Fallback: cat_result stored by inrep after assessment\n',
    '    if(is.null(theta) && !is.null(rv) && !is.null(rv$cat_result)) {\n',
    '      theta <- rv$cat_result$theta\n',
    '      se    <- rv$cat_result$se\n',
    '    }\n',
    '    \n',
    '    if(!is.null(theta) && !is.na(theta)) {\n',
    '      n_items_administered <- if(!is.null(rv) && !is.null(rv$administered)) length(rv$administered) else sum(!is.na(responses))\n',
    '      se_str <- if(!is.null(se) && !is.na(se)) sprintf("%.3f", se) else "N/A"\n',
    '      \n',
    '      parts$adaptive <- sprintf(\n',
    '        paste0(\n',
    '          \'<div style="background: linear-gradient(135deg, %s15, %s08); border: 1px solid %s40; \',\n',
    '          \'border-radius: 10px; padding: 20px 24px; margin-bottom: 20px; text-align: center;">\',\n',
    '          \'<div style="font-size: 0.8rem; color: #6b7280; font-weight: 500; text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 4px;">IRT Ability Estimate (\\u03b8)</div>\',\n',
    '          \'<div style="font-size: 2.8rem; font-weight: 700; color: %s; line-height: 1;">%.3f</div>\',\n',
    '          \'<div style="font-size: 0.85rem; color: #6b7280; margin-top: 6px;">SE = %s &nbsp;&bull;&nbsp; %d items administered</div>\',\n',
    '          \'</div>\'\n',
    '        ),\n',
    '        primary_color, primary_color, primary_color, primary_color,\n',
    '        theta, se_str, n_items_administered\n',
    '      )\n',
    '    }\n',
    '  }\n',
    '  \n',
    '  # -------------------------------------------------------------------------\n',
    '  # SCALE SCORES TABLE (M +/- SD for all modes)\n',
    '  # -------------------------------------------------------------------------\n',
    '  if(length(scale_scores) > 0) {\n',
    '    table_header <- sprintf(\n',
    '      paste0(\n',
    '        "<thead><tr style=\'background: #f9fafb; border-bottom: 2px solid #e5e7eb;\'>\\n",\n',
    '        "  <th style=\'padding: 12px 16px; text-align: left; font-weight: 600; color: #374151; font-size: 0.9rem;\'>%s</th>\\n",\n',
    '        "  <th style=\'padding: 12px 16px; text-align: center; font-weight: 600; color: #374151; font-size: 0.9rem;\'>M</th>\\n",\n',
    '        "  <th style=\'padding: 12px 16px; text-align: center; font-weight: 600; color: #374151; font-size: 0.9rem;\'>SD</th>\\n",\n',
    '        "  <th style=\'padding: 12px 16px; text-align: left; font-weight: 600; color: #374151; font-size: 0.9rem; width: 35%%;\'></th>\\n",\n',
    '        "</tr></thead>"\n',
    '      ),\n',
    '      "Scale"\n',
    '    )\n',
    '    \n',
    '    row_html <- ""\n',
    '    i <- 0\n',
    '    for (name in names(scale_scores)) {\n',
    '      i <- i + 1\n',
    '      s <- scale_scores[[name]]\n',
    '      bg <- if(i %% 2 == 0) " background: #fafafa;" else ""\n',
    '      scale_id <- paste0("scale_", sanitize_id(name))\n',
    '      scale_color <- primary_color\n',
    '      if(!is.null(element_colors) && length(element_colors) > 0) {\n',
    '        for (ec in element_colors) {\n',
    '          if(!is.null(ec[[scale_id]])) { scale_color <- ec[[scale_id]]; break }\n',
    '        }\n',
    '      }\n',
    '      row_html <- paste0(row_html, sprintf(\n',
    '        paste0(\n',
    '          "<tr style=\'border-bottom: 1px solid #f3f4f6;%s\'>\\n",\n',
    '          "  <td style=\'padding: 12px 16px; font-weight: 500; color: #1f2937; font-size: 0.9rem;\'>%s</td>\\n",\n',
    '          "  <td style=\'padding: 12px 16px; text-align: center; font-weight: 600; color: %s; font-size: 0.95rem;\'>%.2f</td>\\n",\n',
    '          "  <td style=\'padding: 12px 16px; text-align: center; color: #6b7280; font-size: 0.9rem;\'>%.2f</td>\\n",\n',
    '          "  <td style=\'padding: 12px 16px;\'>\\n",\n',
    '          "    <div style=\'background: #e5e7eb; border-radius: 4px; height: 8px; overflow: hidden;\'>\\n",\n',
    '          "      <div style=\'background: %s; height: 100%%; width: %d%%; border-radius: 4px;\'></div>\\n",\n',
    '          "    </div>\\n",\n',
    '          "  </td>\\n",\n',
    '          "</tr>"\n',
    '        ),\n',
    '        bg, s$label, scale_color, s$score, s$sd, scale_color, s$pct\n',
    '      ))\n',
    '    }\n',
    '    \n',
    '    # Footer: detect scale range from item_bank\n',
    '    scale_note <- "Scale: 1-5."\n',
    '    if(!is.null(item_bank) && "ResponseCategories" %in% names(item_bank)) {\n',
    '      all_scales <- unique(item_bank$ResponseCategories)\n',
    '      all_scales <- all_scales[!is.na(all_scales) & nzchar(all_scales)]\n',
    '      if(length(all_scales) == 1) {\n',
    '        vals <- suppressWarnings(as.numeric(unlist(strsplit(all_scales[1], ","))))\n',
    '        vals <- vals[!is.na(vals)]\n',
    '        if(length(vals) > 0) scale_note <- sprintf("Scale: %d-%d.", min(vals), max(vals))\n',
    '      } else if(length(all_scales) > 1) {\n',
    '        scale_note <- "Various response scales."\n',
    '      }\n',
    '    }\n',
    '    footer_note <- sprintf(\n',
    '      paste0(\n',
    '        "<div style=\'padding: 10px 16px; background: #f9fafb; border-top: 1px solid #e5e7eb; font-size: 0.75rem; color: #9ca3af;\'>\\n",\n',
    '        "  <em>M = Mean, SD = Standard Deviation. %s</em>\\n",\n',
    '        "</div>"\n',
    '      ),\n',
    '      scale_note\n',
    '    )\n',
    '    \n',
    '    parts$table <- sprintf(\n',
    '      paste0(\n',
    '        "  <div style=\'background: #ffffff; border-radius: 8px; border: 1px solid #e5e7eb; overflow: hidden;\'>\\n",\n',
    '        "    <table style=\'width: 100%%; border-collapse: collapse; font-family: system-ui, -apple-system, sans-serif;\'>\\n",\n',
    '        "      %s\\n",\n',
    '        "      <tbody>%s</tbody>\\n",\n',
    '        "    </table>\\n",\n',
    '        "    %s\\n",\n',
    '        "  </div>"\n',
    '      ),\n',
    '      table_header, row_html, footer_note\n',
    '    )\n',
    '  }\n',
    '  \n',
    '  # Assemble final output\n',
    '  shiny::HTML(sprintf(\n',
    '    paste0(\n',
    '      "<div style=\'max-width: 540px; margin: 0 auto; padding: 24px 16px;\'>\\n",\n',
    '      "  <h2 style=\'color: %s; text-align: center; margin-bottom: 20px; font-size: 1.25rem; font-weight: 600; letter-spacing: -0.02em;\'>%s</h2>\\n",\n',
    '      "%s",\n',
    '      "%s",\n',
    '      "</div>"\n',
    '    ),\n',
    '    primary_color, results_title,\n',
    '    parts$adaptive %||% "",\n',
    '    parts$table %||% ""\n',
    '  ))\n',
    '}\n',
    '\n',
    '# Attach results processor to config\n',
    'study_config$results_processor <- results_processor\n'
  )
} else {
  "# No results processor needed (no metrics defined)\\n"
}

# Header: required packages & user header code
packages_text <- input$required_packages %||% ""
pkgs <- if(nzchar(packages_text)) trimws(unlist(strsplit(packages_text, ","))) else character(0)
pkgs <- pkgs[nzchar(pkgs)]
pkg_lines <- c()
if(length(pkgs) > 0) {
  pkg_lines <- unlist(lapply(pkgs, function(p) {
    p <- trimws(p)
    if(isTRUE(input$include_install_instructions)) {
      sprintf('if(!requireNamespace("%s", quietly = TRUE)) { install.packages("%s") }; library(%s)', 
              p, p, p)
    } else {
      sprintf('library(%s)', p)
    }
  }))
}
header_code <- input$script_header_code %||% ""

# ===========================================================================
# STEP 10: Assemble complete script
# ===========================================================================
script_header <- sprintf(
  '################################################################################
# inrep Studio Generated Study Script
# Generated: %s
# Study: %s
################################################################################

# =============================================================================
# Encoding / locale defaults (best-effort)
# =============================================================================
options(encoding = "UTF-8")
Sys.setenv(LANGUAGE = "en")
try(suppressWarnings(Sys.setlocale("LC_CTYPE", "C.UTF-8")), silent = TRUE)
try(suppressWarnings(Sys.setlocale("LC_CTYPE", "English_United States.utf8")), silent = TRUE)
try(suppressWarnings(Sys.setlocale("LC_MESSAGES", "English")), silent = TRUE)

# =============================================================================
# Install Required Packages (if not already installed)
# =============================================================================

# Helper function to install packages if missing
install_if_missing <- function(pkg, github_repo = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (!is.null(github_repo)) {
      if (!requireNamespace("devtools", quietly = TRUE)) {
        install.packages("devtools")
      }
      message(paste("Installing", pkg, "from GitHub..."))
      devtools::install_github(github_repo, force = TRUE)
    } else {
      message(paste("Installing", pkg, "from CRAN..."))
      install.packages(pkg)
    }
  }
}

# Install CRAN packages
install_if_missing("shiny")
install_if_missing("httr")
install_if_missing("zip")
%s

# Install inrep from GitHub (always check for latest version)
install_if_missing("inrep", "selvastics/inrep")

# =============================================================================
# Load Required Packages
# =============================================================================
library(shiny)
library(inrep)
library(httr)
library(zip)
%s
%s

%s
',
Sys.time(),
study_name,
if(adaptive_flag) 'install_if_missing("TAM")  # Required for adaptive testing' else "# TAM not required for non-adaptive studies",
if(adaptive_flag) "library(TAM)  # Required for adaptive testing" else "# TAM not required for non-adaptive studies",
if(length(pkg_lines) > 0) paste(pkg_lines, collapse = "\n") else "",
if(nzchar(header_code)) paste0("# Custom Header Code\n", header_code) else ""
)

# Assemble complete script
complete_script <- paste(
  script_header,
  items_code,
  demographic_configs_code,
  input_types_code,
  page_flow_code,
  color_config_code,
  storage_code,
  study_config_code,
  results_processor_code,
  launch_code,
  sep = "\n"
)

return(complete_script)
  }

get_validated_script <- function() {
  script <- generate_script()
  if (is.null(script) || !nzchar(script)) {
    stop("Generated script is empty.", call. = FALSE)
  }
  
  format_script_parse_error <- function(script_text, parse_message) {
    lines <- strsplit(script_text, "\n", fixed = TRUE)[[1]]
    
    # Typical parse() error message format: "<text>:123:5: ..."
    m <- regexec("^<text>:(\\d+):(\\d+):", parse_message)
    parts <- regmatches(parse_message, m)[[1]]
    if (length(parts) >= 3) {
      err_line <- suppressWarnings(as.integer(parts[2]))
      err_col <- suppressWarnings(as.integer(parts[3]))
    } else {
      err_line <- NA_integer_
      err_col <- NA_integer_
    }
    
    if (!is.na(err_line) && err_line >= 1 && err_line <= length(lines)) {
      from <- max(1, err_line - 2)
      to <- min(length(lines), err_line + 2)
      snippet <- paste(
        sprintf("%4d | %s", from:to, lines[from:to]),
        collapse = "\n"
      )
      return(paste0(
        parse_message,
        "\n\nNear line ", err_line,
        if (!is.na(err_col)) paste0(", col ", err_col) else "",
        ":\n",
        snippet
      ))
    }
    
    parse_message
  }
  
  tryCatch(
    {
      parse(text = script)
      script
    },
    error = function(e) {
      details <- format_script_parse_error(script, e$message)
      stop(paste0("Generated script is not valid R:\n", details), call. = FALSE)
    }
  )
}

observeEvent(input$preview_script, {
  script <- tryCatch(
    get_validated_script(),
    error = function(e) {
      showNotification(conditionMessage(e), type = "error", duration = 10)
      NULL
    }
  )
  if (is.null(script)) return(NULL)
  # Properly escape HTML entities for display
  escaped_script <- gsub("&", "&amp;", script)
  escaped_script <- gsub("<", "&lt;", escaped_script)
  escaped_script <- gsub(">", "&gt;", escaped_script)
  showModal(modalDialog(
    title = tagList(bs_icon("file-code"), " Generated R Script"),
    size = "xl",
    easyClose = TRUE,
    tags$div(
      style = "max-height: 70vh; overflow-y: auto; background: #1e293b; border-radius: 8px; padding: 20px;",
      tags$pre(
        style = "margin: 0; color: #e2e8f0; font-family: 'Consolas', 'Monaco', 'Courier New', monospace; font-size: 0.85rem; line-height: 1.6; white-space: pre-wrap; word-wrap: break-word;",
        HTML(escaped_script)
      )
    ),
    footer = tagList(
      # Hidden textarea stores the script — plain text, zero escaping issues.
      # The copy button reads ta.value rather than parsing an inlined JSON literal.
      tags$textarea(
        id = "script-copy-src",
        style = "position:absolute;left:-9999px;top:-9999px;width:1px;height:1px;opacity:0;",
        script
      ),
      div(class = "d-flex gap-2 justify-content-end w-100",
          tags$button(type = "button", class = "btn btn-outline-secondary",
                      `data-bs-dismiss` = "modal", "Close"),
          # Plain <button> (no Shiny binding) reads text from the hidden textarea.
          tags$button(
            type = "button",
            id = "copy_script_btn",
            class = "btn btn-primary",
            onclick = paste0(
              "(function(btn){",
              "  var ta=document.getElementById('script-copy-src');",
              "  if(!ta) return;",
              "  var text=ta.value;",
              "  function ok(){",
              "    btn.innerHTML='<i class=\"bi bi-check2\"></i> Copied!';",
              "    btn.classList.replace('btn-primary','btn-success');",
              "    setTimeout(function(){",
              "      btn.innerHTML='<i class=\"bi bi-clipboard\"></i> Copy';",
              "      btn.classList.replace('btn-success','btn-primary');",
              "    },2000);",
              "  }",
              "  if(navigator.clipboard&&navigator.clipboard.writeText){",
              "    navigator.clipboard.writeText(text).then(ok).catch(function(){",
              "      ta.select();ta.setSelectionRange(0,99999);document.execCommand('copy');ok();",
              "    });",
              "  } else {",
              "    ta.select();ta.setSelectionRange(0,99999);document.execCommand('copy');ok();",
              "  }",
              "})(this)"
            ),
            tagList(bs_icon("clipboard"), " Copy")
          )
      )
    )
  ))
})

output$download_bundle <- downloadHandler(
  filename = function() {
    study_name_safe <- input$study_name %||% "study"
    paste0("inrep_study_", format(Sys.Date(), "%Y%m%d"), "_", gsub("[^A-Za-z0-9]", "_", study_name_safe), ".zip")
  },
  content = function(file) {
    # Validate we have data to export
    if(is.null(items()) || nrow(items()) == 0) {
      showNotification("Please add items to your study before downloading.", type = "error", duration = 5)
      return(NULL)
    }
    
    # Parse required packages for bundle
    packages_text <- input$required_packages %||% ""
    pkgs <- if(nzchar(packages_text)) trimws(unlist(strsplit(packages_text, ","))) else character(0)
    pkgs <- pkgs[nzchar(pkgs)]
    
    # Get adaptive flag for inclusion in READMEs
    adaptive_flag <- isTRUE(input$adaptive)
    
    tmp <- tempfile("inrep_bundle_")
    dir.create(tmp, showWarnings = FALSE, recursive = TRUE)
    on.exit(unlink(tmp, recursive = TRUE, force = TRUE), add = TRUE)
    
    # Create folder structure
    config_dir <- file.path(tmp, "config")
    rscript_dir <- file.path(tmp, "rscript")
    app_dir <- file.path(tmp, "app")
    
    dir.create(config_dir, showWarnings = FALSE)
    dir.create(rscript_dir, showWarnings = FALSE)
    dir.create(app_dir, showWarnings = FALSE)
    
    # === CONFIG FOLDER ===
    config_json_file <- file.path(config_dir, "study_config.json")
    config_items_file <- file.path(config_dir, "item_bank.csv")
    config_readme_file <- file.path(config_dir, "README.txt")
    
    # Write config JSON
    config_data <- list(
      study_name = input$study_name,
      study_id = input$study_id,
      primary_lang = input$primary_lang,
      theme = input$theme,
      expert_mode = NULL,  # removed: adaptive is now directly a toggle without expert_mode gate
      adaptive = input$adaptive,
      irt_model = input$irt_model,
      estimation_method = input$estimation_method,
      item_selection_criteria = input$item_selection_criteria,
      cat_se_threshold = input$cat_se_threshold,
      min_items = if(isTRUE(input$adaptive)) input$min_items else (input$min_items_nonadaptive %||% input$min_items),
      max_items = input$max_items,
      progress_style = input$progress_style,
      response_ui_type = input$response_ui_type,
      response_layout = input$response_layout,
      session_save = input$session_save,
      show_session_time = input$show_session_time,
      max_session_duration = input$max_session_duration,
      max_response_time = input$max_response_time,
      report_formats = input$report_formats,
      storage_backend = input$storage_backend,
      required_packages = input$required_packages,
      show_introduction = input$show_introduction,
      show_briefing = input$show_briefing,
      show_consent = input$show_consent,
      show_gdpr_compliance = input$show_gdpr_compliance,
      show_debriefing = input$show_debriefing,
      enable_back_navigation = input$enable_back_navigation,
      cache_enabled = input$cache_enabled,
      parallel_computation = input$parallel_computation,
      fast_item_selection = input$fast_item_selection,
      feedback_enabled = input$feedback_enabled,
      primary_color_override = color_overrides()$primary,
      accent_color_override = color_overrides()$accent,
      text_color_override = color_overrides()$text,
      pages = pages(),
      items = items()
    )
    write_text_utf8(jsonlite::toJSON(config_data, auto_unbox = TRUE, pretty = TRUE), config_json_file)
    write.csv(items(), config_items_file, row.names = FALSE, fileEncoding = "UTF-8")
    
    # Config README
    write_text_utf8(c(
      "CONFIG FOLDER",
      "=============",
      "",
      "This folder contains configuration files for re-importing into inrep Studio.",
      "",
      "Files:",
      "- study_config.json: Complete study configuration",
      "- item_bank.csv: All questionnaire items",
      "",
      "To restore your study in inrep Studio:",
      "1. Open inrep Studio configurator",
      "2. Click 'Upload Config/Bundle' button",
      "3. Select study_config.json or upload the entire ZIP",
      "4. All pages, items, and settings will be restored",
      "",
      "This allows you to:",
      "- Continue editing your study",
      "- Make modifications and re-export",
      "- Share configurations with collaborators",
      ""
    ), config_readme_file)
    
    script <- tryCatch(
      get_validated_script(),
      error = function(e) {
        showNotification(conditionMessage(e), type = "error", duration = 12)
        NULL
      }
    )
    if (is.null(script)) return(NULL)
    
    # === RSCRIPT FOLDER ===
    rscript_file <- file.path(rscript_dir, "launch_study.R")
    rscript_items_file <- file.path(rscript_dir, "item_bank.csv")
    rscript_readme_file <- file.path(rscript_dir, "README.txt")
    
    # Write R script
    write_text_utf8(script, rscript_file)
    write.csv(items(), rscript_items_file, row.names = FALSE, fileEncoding = "UTF-8")
    
    # determine adaptive flag for README
    adaptive_flag <- isTRUE(input$adaptive)
    packages_text <- input$required_packages %||% ""
    pkgs <- if(packages_text == "") character(0) else trimws(unlist(strsplit(packages_text, ",")))
    pkgs <- pkgs[pkgs != ""]
    
    # RScript README
    write_text_utf8(c(
      "RSCRIPT FOLDER",
      "==============",
      "",
      "This folder contains R scripts for running the study locally or on RStudio Server.",
      "",
      "Files:",
      "- launch_study.R: Complete executable R script",
      "- item_bank.csv: All questionnaire items",
      "",
      "To run the study:",
      "1. Install required packages:",
      sprintf("   install.packages(c(%s))", paste(paste0("'", c("inrep", "shiny", pkgs), "'"), collapse = ", ")),
      "",
      "2. Run in R/RStudio:",
      "   source('launch_study.R')",
      "",
      "3. Or from command line:",
      "   Rscript launch_study.R",
      "",
      "The study will launch in your default web browser.",
      "",
      if(adaptive_flag) "NOTE: This study uses adaptive testing and requires the TAM package." else "",
      "",
      if ((input$storage_backend %||% "local") == "webdav") c(
        "WEBDAV SETUP:",
        "  Before running, set your WebDAV password:",
        "  1. Run: usethis::edit_r_environ()",
        "  2. Add: INREP_WEBDAV_PASSWORD=your_password_here",
        "  3. Restart R",
        ""
      ) else "",
      ""
    ), rscript_readme_file)
    
    # === APP FOLDER ===
    app_file <- file.path(app_dir, "app.R")
    app_items_file <- file.path(app_dir, "item_bank.csv")
    app_readme_file <- file.path(app_dir, "README.txt")
    
    # Generate Shiny app.R for deployment
    # The generated script is self-contained (defines item bank inline, installs packages, etc.)
    # so the app.R is simply the script itself with a deployment header.
    app_content <- c(
      "# Shiny App for Deployment",
      "# Generated by inrep Studio",
      "# Upload this folder to shinyapps.io, Shiny Server, or RStudio Connect",
      "",
      script
    )
    
    # Validate app.R content in bundle is syntactically correct
    app_parse_error <- tryCatch(
      {
        parse(text = paste(app_content, collapse = "\n"))
        NULL
      },
      error = function(e) e
    )
    if (!is.null(app_parse_error)) {
      showNotification(
        paste0("Generated app/app.R is not valid R: ", app_parse_error$message),
        type = "error",
        duration = 12
      )
      return(NULL)
    }
    write_text_utf8(app_content, app_file)
    write.csv(items(), app_items_file, row.names = FALSE, fileEncoding = "UTF-8")
    
    # App README
    write_text_utf8(c(
      "APP FOLDER",
      "==========",
      "",
      "This folder is ready for deployment to Shiny hosting services.",
      "",
      "Files:",
      "- app.R: Shiny application file (deployment-ready)",
      "- item_bank.csv: All questionnaire items",
      "",
      "DEPLOYMENT OPTIONS:",
      "",
      "1. SHINYAPPS.IO (Cloud Hosting):",
      "   - Install rsconnect: install.packages('rsconnect')",
      "   - Set up account: rsconnect::setAccountInfo(name, token, secret)",
      "   - Deploy: rsconnect::deployApp(appDir = 'path/to/app')",
      "",
      "2. POSIT CLOUD (Free Tier Available):",
      "   - Upload this folder to Posit Cloud project",
      "   - Click 'Run App' in RStudio",
      "   - Share link with participants",
      "",
      "3. SHINY SERVER (Self-Hosted):",
      "   - Copy this folder to /srv/shiny-server/",
      "   - Access at: http://your-server/foldername/",
      "",
      "4. RSTUDIO CONNECT (Enterprise):",
      "   - Use RStudio 'Publish' button",
      "   - Select RStudio Connect as destination",
      "",
      "MINIMAL SETUP:",
      "- No code changes needed",
      "- All dependencies included in app.R",
      "- Item bank loads automatically",
      "",
      if ((input$storage_backend %||% "local") == "webdav") c(
        "IMPORTANT - WEBDAV STORAGE:",
        "This study uploads results to a WebDAV server.",
        "You must set the password as an environment variable:",
        "  - Local: Add INREP_WEBDAV_PASSWORD=your_password to .Renviron",
        "  - shinyapps.io: Set in rsconnect deployment settings",
        "  - Shiny Server: Set in /etc/environment or systemd service file",
        ""
      ) else "",
      sprintf("Study: %s", input$study_name %||% "Study"),
      sprintf("Language: %s", input$primary_lang %||% "en"),
      sprintf("Theme: %s", input$theme %||% "hildesheim"),
      ""
    ), app_readme_file)
    
    # === ROOT README ===
    root_readme_file <- file.path(tmp, "README.txt")
    pgs <- pages()
    pages_with_code <- names(pgs)[sapply(pgs, function(p) {
      (!is.null(p$custom_js) && nzchar(p$custom_js)) || 
        (!is.null(p$custom_css) && nzchar(p$custom_css)) || 
        (!is.null(p$completion_handler_src) && nzchar(p$completion_handler_src))
    })]
    if(is.null(pages_with_code) || length(pages_with_code) == 0) pages_with_code <- "(none)"
    
    write_text_utf8(c(
      "═══════════════════════════════════════════════",
      "  INREP STUDIO - COMPLETE STUDY BUNDLE",
      "═══════════════════════════════════════════════",
      "",
      sprintf("Study Name: %s", input$study_name %||% "Study"),
      sprintf("Generated: %s", Sys.time()),
      "",
      "FOLDER STRUCTURE:",
      "================",
      "",
      "📁 config/",
      "   └─ For re-importing into inrep Studio configurator",
      "   └─ Upload study_config.json to restore all settings",
      "   └─ Continue editing and making changes",
      "",
      "📁 rscript/",
      "   └─ For running study locally in R/RStudio",
      "   └─ Execute launch_study.R to start immediately",
      "   └─ Ideal for testing before deployment",
      "",
      "📁 app/",
      "   └─ For deploying to Shiny hosting services",
      "   └─ Upload entire folder to shinyapps.io, Posit Cloud, etc.",
      "   └─ No code changes needed - ready to publish",
      "",
      "QUICK START GUIDE:",
      "==================",
      "",
      "→ Want to edit the study?",
      "  Go to config/ folder → Upload study_config.json to inrep Studio",
      "",
      "→ Want to test locally?",
      "  Go to rscript/ folder → Run launch_study.R in RStudio",
      "",
      "→ Want to deploy online?",
      "  Go to app/ folder → Upload to shinyapps.io or Posit Cloud",
      "",
      "STUDY CONFIGURATION:",
      "====================",
      sprintf("- Language: %s", input$primary_lang %||% "en"),
      sprintf("- Theme: %s", input$theme %||% "Professional"),
      sprintf("- Adaptive Testing: %s", if(isTRUE(adaptive_flag)) "Yes" else "No"),
      sprintf("- Storage Backend: %s", input$storage_backend %||% "local"),
      sprintf("- Number of Pages: %d", length(pgs)),
      sprintf("- Number of Items: %d", nrow(items())),
      sprintf("- Progress Style: %s", input$progress_style %||% "bar"),
      sprintf("- Session Save: %s", if(isTRUE(input$session_save)) "Yes" else "No"),
      sprintf("- Pages with Custom Code: %s", paste(pages_with_code, collapse = ", ")),
      sprintf("- Required Packages: %s", if(length(pkgs) == 0) "inrep, shiny" else paste(c("inrep", "shiny", pkgs), collapse = ", ")),
      "",
      # Storage-specific setup instructions
      if ((input$storage_backend %||% "local") == "webdav") c(
        "DATA STORAGE SETUP (WebDAV):",
        "============================",
        "Your study is configured to upload results to a WebDAV cloud folder.",
        "",
        "Before running, you MUST set your WebDAV password as an environment variable:",
        "  1. In R, run: usethis::edit_r_environ()",
        "  2. Add this line: INREP_WEBDAV_PASSWORD=your_password_here",
        "  3. Save and restart R",
        "",
        "To test your WebDAV connection:",
        paste0("  URL: ", input$webdav_url %||% "(not set)"),
        paste0("  Share Token: ", input$webdav_username %||% "(not set)"),
        "",
        "For shinyapps.io deployment, set the environment variable in the",
        "rsconnect deployment settings or the app's .Rprofile.",
        ""
      ) else c(
        "DATA STORAGE:",
        "=============",
        "Results are saved locally in the working directory (CSV/JSON).",
        ""
      ),
      "SUPPORT:",
      "========",
      "- Documentation: https://github.com/selvastics/inrep",
      "- Issues: https://github.com/selvastics/inrep/issues",
      "",
      "Each folder contains its own detailed README.txt with specific instructions.",
      ""
    ), root_readme_file)
    
    # Create ZIP with folder structure
    old_wd <- getwd()
    on.exit(setwd(old_wd), add = TRUE)
    tryCatch({
      setwd(tmp)
      zip::zip(zipfile = file, files = c("config", "rscript", "app", "README.txt"), mode = "cherry-pick")
    }, error = function(e) {
      stop("Failed to create ZIP file: ", e$message)
    })
  }
)

# Automatic inline validation - no explicit validate button needed
validation_errors <- reactive({
  errors <- character(0)
  pgs <- pages()
  itb <- items()
  
  # Check pages exist
  if(length(pgs) == 0) {
    errors <- c(errors, "At least one page must be defined")
  }
  
  # Validate report metrics items
  for(pid in names(pgs)) {
    pg <- pgs[[pid]]
    if(!is.null(pg$report_metrics) && length(pg$report_metrics) > 0) {
      for(m in pg$report_metrics) {
        missing <- setdiff(m$items, itb$id)
        if(length(missing) > 0) {
          errors <- c(errors, sprintf("Metric '%s' references missing items: %s", m$name, paste(missing, collapse = ", ")))
        }
      }
    }
  }
  
  errors
})

observeEvent(input$add_demo_field, {
  showModal(modalDialog(
    title = "Add Demographic Field",
    textInput("demo_field_name", "Field Name (internal)", value = "", placeholder = "e.g. age, gender"),
    textInput("demo_field_label_de", "Label (German)", value = ""),
    textInput("demo_field_label_en", "Label (English)", value = ""),
    selectInput("demo_field_type", "Field Type", c("Text" = "text", "Number" = "number", "Select" = "select", "Slider" = "slider", "Checkbox" = "checkbox", "Radio" = "radio")),
    conditionalPanel("input.demo_field_type == 'select' || input.demo_field_type == 'radio' || input.demo_field_type == 'checkbox'",
                     textInput("demo_field_options_de", "Options (German, comma-separated)", value = ""),
                     textInput("demo_field_options_en", "Options (English, comma-separated)", value = ""),
                     checkboxInput("demo_field_allow_other", "Allow 'Other' option with text input", value = FALSE),
                     conditionalPanel("input.demo_field_allow_other == true",
                                      textInput("demo_field_other_placeholder_de", "Other placeholder (German)", value = ""),
                                      textInput("demo_field_other_placeholder_en", "Other placeholder (English)", value = "")
                     )
    ),
    conditionalPanel("input.demo_field_type == 'slider'",
                     numericInput("demo_field_min", "Min", value = 0, step = 1),
                     numericInput("demo_field_max", "Max", value = 100, step = 1),
                     numericInput("demo_field_step", "Step", value = 1, step = 1),
                     numericInput("demo_field_default", "Default (NULL = no default)", value = NULL),
                     textInput("demo_field_label_min", "Min Label (German)", value = "", placeholder = "e.g. 'strongly disagree'"),
                     textInput("demo_field_label_max", "Max Label (German)", value = "", placeholder = "e.g. 'strongly agree'"),
                     textInput("demo_field_label_min_en", "Min Label (English)", value = "", placeholder = "e.g. 'strongly disagree'"),
                     textInput("demo_field_label_max_en", "Max Label (English)", value = "", placeholder = "e.g. 'strongly agree'")
    ),
    conditionalPanel("input.demo_field_type == 'text'",
                     textAreaInput("demo_field_html_content_de", "Custom HTML / explanatory content (German)", value = "", height = "120px"),
                     textAreaInput("demo_field_html_content_en", "Custom HTML / explanatory content (English)", value = "", height = "120px")
    ),
    checkboxInput("demo_field_required", "Required Field", value = TRUE),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_add_demo_field", "Add", class = "btn-primary")
    )
  ))
})

# Edit page inline from preview: open modal depending on page type
observeEvent(input$edit_preview_page, {
  curr <- current_page()
  pgs <- pages()
  pg <- pgs[[curr]]
  if(is.null(pg)) return()
  
  if(pg$type == "custom") {
    showModal(modalDialog(
      title = sprintf("Edit Page: %s", pg$title %||% pg$id),
      textAreaInput("inline_edit_content_de", "Content (German)", value = pg$content_de %||% "", height = "260px"),
      textAreaInput("inline_edit_content_en", "Content (English)", value = pg$content_en %||% "", height = "260px"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_inline_edit", "Apply", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  } else if(pg$type == "items") {
    showModal(modalDialog(
      title = sprintf("Edit Instructions: %s", pg$title %||% pg$id),
      textAreaInput("inline_edit_instructions_de", "Instructions (German)", value = pg$instructions %||% "", height = "160px"),
      textAreaInput("inline_edit_instructions_en", "Instructions (English)", value = pg$instructions_en %||% "", height = "160px"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_inline_edit", "Apply", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  } else if(pg$type == "results") {
    showModal(modalDialog(
      title = sprintf("Edit Results Page: %s", pg$title %||% pg$id),
      textAreaInput("inline_edit_results_text_de", "Results Text (German)", value = pg$results_text_de %||% "", height = "120px"),
      textAreaInput("inline_edit_results_text_en", "Results Text (English)", value = pg$results_text_en %||% "", height = "120px"),
      textAreaInput("inline_edit_processing_code", "Results Processing (R code)", value = pg$processing_code %||% "", height = "220px"),
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_inline_edit", "Apply", class = "btn-primary")
      ),
      easyClose = TRUE
    ))
  }
})

observeEvent(input$confirm_inline_edit, {
  removeModal()
  curr <- current_page()
  pgs <- pages()
  pg <- pgs[[curr]]
  if(pg$type == "custom") {
    pgs[[curr]]$content_de <- input$inline_edit_content_de
    pgs[[curr]]$content_en <- input$inline_edit_content_en
  } else if(pg$type == "items") {
    pgs[[curr]]$instructions <- input$inline_edit_instructions_de
    pgs[[curr]]$instructions_en <- input$inline_edit_instructions_en
  } else if(pg$type == "results") {
    pgs[[curr]]$results_text_de <- input$inline_edit_results_text_de
    pgs[[curr]]$results_text_en <- input$inline_edit_results_text_en
    pgs[[curr]]$processing_code <- input$inline_edit_processing_code
  }
  pages(pgs)
  showNotification("Changes applied", type = "message")
})

observeEvent(input$add_report_metric, {
  showModal(modalDialog(
    title = "Add Report Metric",
    textInput("new_metric_name", "Metric Name", value = ""),
    textInput("new_metric_items", "Item IDs (comma-separated)", value = ""),
    textAreaInput("new_metric_expr", "R Expression (use `items_vec` for vector of item responses)", value = "", height = "160px"),
    footer = tagList(
      modalButton("Cancel"),
      actionButton("confirm_add_report_metric", "Add", class = "btn-primary")
    ),
    easyClose = TRUE
  ))
})

observeEvent(input$confirm_add_report_metric, {
  removeModal()
  curr <- current_page()
  pgs <- pages()
  if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "results") {
    showNotification("Report metrics can be added only to results pages", type = "error")
    return()
  }
  new_metric <- list(
    name = input$new_metric_name,
    items = trimws(unlist(strsplit(input$new_metric_items, ","))),
    expr = input$new_metric_expr
  )
  if(is.null(pgs[[curr]]$report_metrics)) pgs[[curr]]$report_metrics <- list()
  pgs[[curr]]$report_metrics <- c(pgs[[curr]]$report_metrics, list(new_metric))
  pages(pgs)
  showNotification("Report metric added", type = "message")
})

observeEvent(input$confirm_add_demo_field, {
  removeModal()
  curr <- current_page()
  pgs <- pages()
  
  if(is.null(pgs[[curr]]) || pgs[[curr]]$type != "demographics") {
    showNotification("Only available for Demographics pages", type = "error")
    return()
  }
  
  new_field <- list(
    name = input$demo_field_name,
    label_de = input$demo_field_label_de,
    label_en = input$demo_field_label_en,
    type = input$demo_field_type,
    required = input$demo_field_required
  )
  
  if(input$demo_field_type %in% c("select", "radio", "checkbox")) {
    new_field$options_de <- if(!is.null(input$demo_field_options_de) && input$demo_field_options_de != "") trimws(strsplit(input$demo_field_options_de, ",")[[1]]) else NULL
    new_field$options_en <- if(!is.null(input$demo_field_options_en) && input$demo_field_options_en != "") trimws(strsplit(input$demo_field_options_en, ",")[[1]]) else NULL
    if(isTRUE(input$demo_field_allow_other)) {
      new_field$allow_other_text <- TRUE
      new_field$other_placeholder_de <- input$demo_field_other_placeholder_de
      new_field$other_placeholder_en <- input$demo_field_other_placeholder_en
    }
  }
  if(input$demo_field_type == "slider") {
    new_field$min <- input$demo_field_min
    new_field$max <- input$demo_field_max
    new_field$step <- input$demo_field_step
    new_field$default <- input$demo_field_default
    # Add slider labels (HilFo.R style)
    if(!is.null(input$demo_field_label_min) && input$demo_field_label_min != "") {
      new_field$label_min <- input$demo_field_label_min
    }
    if(!is.null(input$demo_field_label_max) && input$demo_field_label_max != "") {
      new_field$label_max <- input$demo_field_label_max
    }
    if(!is.null(input$demo_field_label_min_en) && input$demo_field_label_min_en != "") {
      new_field$label_min_en <- input$demo_field_label_min_en
    }
    if(!is.null(input$demo_field_label_max_en) && input$demo_field_label_max_en != "") {
      new_field$label_max_en <- input$demo_field_label_max_en
    }
  }
  
  if(!is.null(input$demo_field_html_content_de) && input$demo_field_html_content_de != "") {
    new_field$html_content <- input$demo_field_html_content_de
  }
  if(!is.null(input$demo_field_html_content_en) && input$demo_field_html_content_en != "") {
    new_field$html_content_en <- input$demo_field_html_content_en
  }
  if(is.null(pgs[[curr]]$demo_fields)) {
    pgs[[curr]]$demo_fields <- list()
  }
  
  pgs[[curr]]$demo_fields <- c(pgs[[curr]]$demo_fields, list(new_field))
  pages(pgs)
  showNotification("Field added", type = "message")
})

}

shinyApp(ui, server)
