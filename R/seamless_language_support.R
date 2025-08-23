#' Seamless Language Support for inrep Package
#'
#' Advanced language switching system with preloading, caching, and smooth transitions
#' Designed specifically for the Hildesheim study but extensible to all inrep studies
#'
#' @export

#' Initialize Language System with Preloading
#' 
#' @param languages Vector of language codes to support (e.g., c("de", "en"))
#' @param default_language Default language code
#' @param preload_all Whether to preload all translations at startup
#' @return Language manager object
#' @export
initialize_language_system <- function(languages = c("de", "en"), 
                                      default_language = "de",
                                      preload_all = TRUE) {
  
  # Create language manager environment
  lang_env <- new.env(parent = emptyenv())
  
  # Store configuration
  lang_env$languages <- languages
  lang_env$default <- default_language
  lang_env$current <- default_language
  lang_env$cache <- list()
  lang_env$transition_duration <- 200  # milliseconds
  lang_env$preloaded <- FALSE
  
  # Preload translations if requested
  if (preload_all) {
    preload_translations(lang_env)
  }
  
  # Return manager object
  structure(
    list(
      env = lang_env,
      get_current = function() lang_env$current,
      set_language = function(lang) set_language_internal(lang_env, lang),
      get_text = function(key, lang = NULL) get_text_internal(lang_env, key, lang),
      preload = function() preload_translations(lang_env),
      clear_cache = function() lang_env$cache <- list()
    ),
    class = "language_manager"
  )
}

#' Preload All Translations
#' 
#' @param lang_env Language environment
#' @noRd
preload_translations <- function(lang_env) {
  if (lang_env$preloaded) return(invisible(NULL))
  
  # Load all language dictionaries into cache
  for (lang in lang_env$languages) {
    if (lang %in% names(LANGUAGE_DICTIONARY)) {
      lang_env$cache[[lang]] <- LANGUAGE_DICTIONARY[[lang]]
    }
  }
  
  lang_env$preloaded <- TRUE
  invisible(NULL)
}

#' Set Language Internally
#' 
#' @param lang_env Language environment
#' @param lang New language code
#' @noRd
set_language_internal <- function(lang_env, lang) {
  if (!lang %in% lang_env$languages) {
    warning(sprintf("Language '%s' not supported. Using default '%s'.", 
                   lang, lang_env$default))
    lang <- lang_env$default
  }
  
  old_lang <- lang_env$current
  lang_env$current <- lang
  
  # Trigger reactive updates if in Shiny context
  if (exists("session") && !is.null(session)) {
    session$sendCustomMessage("language_changed", list(
      old = old_lang,
      new = lang,
      transition_duration = lang_env$transition_duration
    ))
  }
  
  invisible(lang)
}

#' Get Text Internally
#' 
#' @param lang_env Language environment
#' @param key Text key
#' @param lang Language code (NULL for current)
#' @noRd
get_text_internal <- function(lang_env, key, lang = NULL) {
  if (is.null(lang)) lang <- lang_env$current
  
  # Check cache first
  if (!is.null(lang_env$cache[[lang]])) {
    text <- lang_env$cache[[lang]][[key]]
    if (!is.null(text)) return(text)
  }
  
  # Fallback to global dictionary
  if (lang %in% names(LANGUAGE_DICTIONARY)) {
    text <- LANGUAGE_DICTIONARY[[lang]][[key]]
    if (!is.null(text)) return(text)
  }
  
  # Final fallback to English or key itself
  if (lang != "en" && "en" %in% names(LANGUAGE_DICTIONARY)) {
    text <- LANGUAGE_DICTIONARY[["en"]][[key]]
    if (!is.null(text)) return(text)
  }
  
  return(key)  # Return key as last resort
}

#' Create Smooth Language Switcher UI
#' 
#' @param id Shiny input ID
#' @param languages Named vector of languages (names = labels, values = codes)
#' @param current Current language code
#' @param style CSS style for the switcher
#' @return Shiny UI element
#' @export
smooth_language_switcher <- function(id = "language_switcher",
                                    languages = c("🇩🇪 Deutsch" = "de", 
                                                 "🇬🇧 English" = "en"),
                                    current = "de",
                                    style = NULL) {
  
  default_style <- paste(
    "position: absolute;",
    "top: 10px;",
    "right: 10px;",
    "background: white;",
    "border: 2px solid #e8041c;",
    "color: #e8041c;",
    "padding: 8px 16px;",
    "border-radius: 4px;",
    "cursor: pointer;",
    "font-size: 14px;",
    "transition: all 0.3s ease;",
    "z-index: 1000;"
  )
  
  if (!is.null(style)) {
    style <- paste(default_style, style)
  } else {
    style <- default_style
  }
  
  # Get current language label
  current_label <- names(languages)[languages == current]
  if (length(current_label) == 0) current_label <- current
  
  # Create button with smooth transition support
  shiny::tags$button(
    id = id,
    type = "button",
    class = "language-switcher",
    style = style,
    onclick = sprintf("smoothLanguageSwitch('%s')", id),
    shiny::tags$span(
      id = paste0(id, "_text"),
      current_label
    )
  )
}

#' Add Language Switching JavaScript
#' 
#' @param transition_duration Transition duration in milliseconds
#' @return JavaScript code as HTML
#' @export
add_language_switching_js <- function(transition_duration = 200) {
  js_code <- sprintf('
<script>
// Smooth language switching system
var SmoothLanguageSystem = (function() {
  var isTransitioning = false;
  var transitionDuration = %d;
  
  function smoothSwitch(buttonId) {
    if (isTransitioning) return;
    isTransitioning = true;
    
    // Get button and current language
    var btn = document.getElementById(buttonId);
    if (!btn) return;
    
    // Fade out content
    fadeOutContent();
    
    // Disable button
    btn.style.pointerEvents = "none";
    btn.style.opacity = "0.7";
    
    // Notify Shiny after fade
    setTimeout(function() {
      if (typeof Shiny !== "undefined") {
        Shiny.setInputValue(buttonId + "_clicked", Date.now(), {priority: "event"});
      }
    }, transitionDuration / 2);
    
    // Re-enable after transition
    setTimeout(function() {
      btn.style.pointerEvents = "auto";
      btn.style.opacity = "1";
      isTransitioning = false;
      fadeInContent();
    }, transitionDuration);
  }
  
  function fadeOutContent() {
    var containers = document.querySelectorAll(".content-container, .assessment-card");
    containers.forEach(function(el) {
      el.style.transition = "opacity " + (transitionDuration/2) + "ms ease";
      el.style.opacity = "0.3";
    });
  }
  
  function fadeInContent() {
    var containers = document.querySelectorAll(".content-container, .assessment-card");
    containers.forEach(function(el) {
      el.style.opacity = "1";
    });
  }
  
  // Handle Shiny messages for language changes
  if (typeof Shiny !== "undefined") {
    Shiny.addCustomMessageHandler("language_changed", function(message) {
      // Update UI elements smoothly
      setTimeout(function() {
        fadeInContent();
      }, 50);
    });
  }
  
  return {
    switch: smoothSwitch
  };
})();

// Global function for onclick handlers
function smoothLanguageSwitch(buttonId) {
  SmoothLanguageSystem.switch(buttonId);
}
</script>
', transition_duration)
  
  shiny::HTML(js_code)
}

#' Create Reactive Language Manager for Shiny
#' 
#' @param input Shiny input object
#' @param output Shiny output object
#' @param session Shiny session object
#' @param languages Supported languages
#' @param default_language Default language
#' @return Reactive language manager
#' @export
create_reactive_language_manager <- function(input, output, session,
                                            languages = c("de", "en"),
                                            default_language = "de") {
  
  # Initialize language system
  lang_manager <- initialize_language_system(languages, default_language, TRUE)
  
  # Create reactive value for current language
  current_lang <- shiny::reactiveVal(default_language)
  
  # Observe language switcher clicks
  shiny::observeEvent(input$language_switcher_clicked, {
    # Toggle between languages
    current <- current_lang()
    lang_idx <- which(languages == current)
    next_idx <- ifelse(lang_idx == length(languages), 1, lang_idx + 1)
    new_lang <- languages[next_idx]
    
    # Update language
    lang_manager$set_language(new_lang)
    current_lang(new_lang)
    
    # Update button text
    session$sendCustomMessage("update_language_button", list(
      id = "language_switcher",
      languages = languages,
      current = new_lang
    ))
  })
  
  # Return reactive language manager
  list(
    current = current_lang,
    get_text = function(key) lang_manager$get_text(key, current_lang()),
    manager = lang_manager
  )
}

#' Wrap Content with Language-Aware Container
#' 
#' @param content Shiny UI content
#' @param lang_manager Language manager object
#' @param fade_duration Fade duration in milliseconds
#' @return Wrapped content with language support
#' @export
language_aware_container <- function(content, 
                                    lang_manager = NULL,
                                    fade_duration = 200) {
  
  container_style <- sprintf(
    "transition: opacity %dms ease; width: 100%%; max-width: 1200px; margin: 0 auto;",
    fade_duration
  )
  
  shiny::div(
    class = "language-aware-container content-container",
    style = container_style,
    `data-language` = if (!is.null(lang_manager)) lang_manager$get_current() else "de",
    content
  )
}

#' Generate Bilingual Content Block
#' 
#' @param content_de German content
#' @param content_en English content
#' @param current_lang Current language
#' @param container_id Container ID for JavaScript targeting
#' @return HTML content block
#' @export
bilingual_content <- function(content_de, content_en, 
                             current_lang = "de",
                             container_id = NULL) {
  
  id_attr <- if (!is.null(container_id)) paste0('id="', container_id, '"') else ""
  
  shiny::HTML(sprintf('
    <div %s class="bilingual-content" data-current-lang="%s">
      <div class="content-de" style="%s">
        %s
      </div>
      <div class="content-en" style="%s">
        %s
      </div>
    </div>
  ',
    id_attr,
    current_lang,
    ifelse(current_lang == "de", "", "display: none;"),
    content_de,
    ifelse(current_lang == "en", "", "display: none;"),
    content_en
  ))
}

#' Update All UI Elements for Language Change
#' 
#' @param session Shiny session
#' @param lang New language code
#' @param ui_elements List of UI element IDs to update
#' @export
update_ui_for_language <- function(session, lang, ui_elements = NULL) {
  
  # Default UI elements to update
  if (is.null(ui_elements)) {
    ui_elements <- c(
      "next_page", "prev_page", "submit_study",
      "start_test", "begin_test", "restart_test"
    )
  }
  
  # Get translations for the new language
  labels <- get_language_labels(lang)
  
  # Update each UI element
  for (element_id in ui_elements) {
    # Map element ID to label key
    label_key <- switch(element_id,
      "next_page" = "continue_button",
      "prev_page" = "back_button",
      "submit_study" = "submit_button",
      "start_test" = "start_button",
      "begin_test" = "begin_button",
      "restart_test" = "restart_button",
      element_id
    )
    
    # Update button text if label exists
    if (!is.null(labels[[label_key]])) {
      session$sendCustomMessage("update_button_text", list(
        id = element_id,
        text = labels[[label_key]]
      ))
    }
  }
}

#' Export Language System for Global Use
#' @export
.language_system <- NULL

#' Initialize Global Language System
#' @export
init_global_language_system <- function() {
  .language_system <<- initialize_language_system(
    languages = c("de", "en", "es", "fr"),
    default_language = "de",
    preload_all = TRUE
  )
}