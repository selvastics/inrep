# CRITICAL FIXES FOR HILFO STUDY
# Date: September 12, 2025
# This file contains the critical fixes that need to be applied to HilFo.R

# ============================================================================
# FIX 1: PAGE 20 LANGUAGE SWITCHING
# ============================================================================
# The page must show content in the correct language and update dynamically

page20_fixed_content <- '
<div style="padding: 20px; font-size: 16px; line-height: 1.8;">
  <h2 style="color: #e8041c; text-align: center; margin-bottom: 25px;">
    <span class="lang-switchable" data-de="Persönlicher Code" data-en="Personal Code">Persönlicher Code</span>
  </h2>
  <p style="text-align: center; margin-bottom: 30px; font-size: 18px;">
    <span class="lang-switchable" data-de="Bitte erstellen Sie einen persönlichen Code:" data-en="Please create a personal code:">Bitte erstellen Sie einen persönlichen Code:</span>
  </p>
  <div style="background: #fff3f4; padding: 20px; border-left: 4px solid #e8041c; margin: 20px 0;">
    <p style="margin: 0; font-weight: 500;">
      <span class="lang-switchable" data-de="Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags" data-en="First 2 letters of your mother\'s first name + first 2 letters of your birthplace + day of your birthday">Erste 2 Buchstaben des Vornamens Ihrer Mutter + erste 2 Buchstaben Ihres Geburtsortes + Tag Ihres Geburtstags</span>
    </p>
  </div>
  <div style="text-align: center; margin: 30px 0;">
    <input type="text" id="personal_code" placeholder="z.B. MAHA15" style="
      padding: 15px 20px; font-size: 18px; border: 2px solid #e0e0e0; border-radius: 8px; 
      text-align: center; width: 200px; text-transform: uppercase;" required>
  </div>
  <div style="text-align: center; color: #666; font-size: 14px;">
    <span class="lang-switchable" data-de="Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15" data-en="Example: Maria (MA) + Hamburg (HA) + 15th day = MAHA15">Beispiel: Maria (MA) + Hamburg (HA) + 15. Tag = MAHA15</span>
  </div>
</div>
<script>
(function() {
  // Immediate language update on page load
  var updatePageLanguage = function() {
    var currentLang = sessionStorage.getItem("hilfo_language") || "de";
    console.log("Page 20 - Updating language to:", currentLang);
    
    // Update all switchable elements
    var elements = document.querySelectorAll(".lang-switchable");
    elements.forEach(function(el) {
      if (currentLang === "en") {
        el.textContent = el.getAttribute("data-en");
      } else {
        el.textContent = el.getAttribute("data-de");
      }
    });
    
    // Update placeholder
    var input = document.getElementById("personal_code");
    if (input) {
      input.placeholder = currentLang === "en" ? "e.g. MAHA15" : "z.B. MAHA15";
    }
  };
  
  // Run immediately
  updatePageLanguage();
  
  // Also run on DOM ready
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", updatePageLanguage);
  }
  
  // Set up input handlers
  var input = document.getElementById("personal_code");
  if (input) {
    input.addEventListener("input", function() {
      this.value = this.value.toUpperCase();
    });
    input.addEventListener("blur", function() {
      if (this.value.trim() !== "") {
        Shiny.setInputValue("Persönlicher_Code", this.value.trim(), {priority: "event"});
      }
    });
  }
})();
</script>
'

# ============================================================================
# FIX 2: RADAR PLOT ERROR
# ============================================================================
# The radar plot should not crash with ggproto error

radar_plot_fix <- function(radar_plot, is_english) {
  # Safer way to add title to ggradar plot
  tryCatch({
    # Check if radar_plot is a ggplot object
    if (inherits(radar_plot, "gg") || inherits(radar_plot, "ggplot")) {
      # Add title using labs (not ggtitle which can cause issues)
      radar_plot <- radar_plot + 
        ggplot2::labs(
          title = if (is_english) "Your Personality Profile (Big Five)" else "Ihr Persönlichkeitsprofil (Big Five)"
        ) + 
        ggplot2::theme(
          plot.title = ggplot2::element_text(
            size = 20, 
            face = "bold", 
            hjust = 0.5, 
            color = "#e8041c", 
            margin = ggplot2::margin(b = 20)
          ),
          plot.background = ggplot2::element_rect(fill = "white", color = NA),
          plot.margin = ggplot2::margin(20, 20, 20, 20)
        )
    }
    return(radar_plot)
  }, error = function(e) {
    cat("Warning: Could not add theme to radar plot:", e$message, "\n")
    # Return the plot as-is
    return(radar_plot)
  })
}

# ============================================================================
# FIX 3: ENHANCED LANGUAGE SWITCHING JAVASCRIPT
# ============================================================================

enhanced_language_js <- '
<script>
// Global language management
window.HilfoLanguage = {
  current: sessionStorage.getItem("hilfo_language") || "de",
  
  update: function() {
    console.log("Updating all elements to language:", this.current);
    
    // Update all elements with data-de and data-en
    document.querySelectorAll("[data-de][data-en]").forEach(function(el) {
      el.textContent = el.getAttribute(HilfoLanguage.current === "en" ? "data-en" : "data-de");
    });
    
    // Update all elements with data-lang-de and data-lang-en
    document.querySelectorAll("[data-lang-de][data-lang-en]").forEach(function(el) {
      el.textContent = el.getAttribute(HilfoLanguage.current === "en" ? "data-lang-en" : "data-lang-de");
    });
    
    // Update all lang-switchable elements
    document.querySelectorAll(".lang-switchable").forEach(function(el) {
      el.textContent = el.getAttribute(HilfoLanguage.current === "en" ? "data-en" : "data-de");
    });
    
    // Update placeholders
    var personalCode = document.getElementById("personal_code");
    if (personalCode) {
      personalCode.placeholder = HilfoLanguage.current === "en" ? "e.g. MAHA15" : "z.B. MAHA15";
    }
  },
  
  switch: function() {
    this.current = this.current === "de" ? "en" : "de";
    sessionStorage.setItem("hilfo_language", this.current);
    this.update();
    
    // Notify Shiny
    if (typeof Shiny !== "undefined") {
      Shiny.setInputValue("study_language", this.current, {priority: "event"});
      Shiny.setInputValue("language", this.current, {priority: "event"});
    }
  },
  
  init: function() {
    // Set initial language from various sources
    if (typeof Shiny !== "undefined" && Shiny.inputBindings) {
      // Check Shiny inputs
      var shinyLang = Shiny.inputBindings.find("study_language");
      if (shinyLang) this.current = shinyLang;
    }
    
    // Update all elements
    this.update();
    
    // Set up mutation observer to catch new elements
    var observer = new MutationObserver(function() {
      HilfoLanguage.update();
    });
    observer.observe(document.body, {childList: true, subtree: true});
  }
};

// Initialize on page load
document.addEventListener("DOMContentLoaded", function() {
  HilfoLanguage.init();
});

// Also initialize immediately if DOM is already loaded
if (document.readyState !== "loading") {
  HilfoLanguage.init();
}
</script>
'

# ============================================================================
# FIX 4: DATA EXPORT FIXES
# ============================================================================

# Ensure complete_data is properly structured and accessible
ensure_data_export <- function(responses, demographics, scores) {
  # Create properly structured data frame
  complete_data <- data.frame(
    timestamp = Sys.time(),
    session_id = paste0("hilfo_", format(Sys.time(), "%Y%m%d_%H%M%S")),
    stringsAsFactors = FALSE
  )
  
  # Add demographics
  if (!is.null(demographics)) {
    for (name in names(demographics)) {
      complete_data[[name]] <- demographics[[name]]
    }
  }
  
  # Add all responses
  if (!is.null(responses)) {
    for (i in seq_along(responses)) {
      complete_data[[paste0("response_", i)]] <- responses[i]
    }
  }
  
  # Add calculated scores
  if (!is.null(scores)) {
    for (name in names(scores)) {
      complete_data[[paste0("score_", name)]] <- scores[[name]]
    }
  }
  
  # Store globally for download access
  assign("complete_data", complete_data, envir = .GlobalEnv)
  
  return(complete_data)
}

cat("CRITICAL FIXES LOADED\n")
cat("Apply these fixes to HilFo.R:\n")
cat("1. Replace page 20 content with page20_fixed_content\n")
cat("2. Use radar_plot_fix() for radar plot\n")
cat("3. Add enhanced_language_js to custom_js\n")
cat("4. Use ensure_data_export() for data storage\n")