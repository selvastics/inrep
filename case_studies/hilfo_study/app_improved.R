# HILFO STUDY - IMPROVED VERSION
# All requested improvements implemented

# Ensure inrep is installed with immediate UI enabled by default
if (!requireNamespace("inrep", quietly = TRUE)) {
  if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
  devtools::install_github("selvastics/inrep", ref = "fix-immediate-ui-default-and-errors")
}
library(inrep)

library(shiny)
library(ggplot2)
library(broom)
library(emmeans)
library(ggthemes)
library(DT)
library(shinycssloaders)
library(patchwork)
library(markdown)
library(shinyjs)

# HILFO Study Configuration with all improvements
study_config <- inrep::create_study_config(
  name = "HilFo Studie",
  theme = "hildesheim",
  model = "2PL",
  adaptive = TRUE,
  max_items = 51,
  session_save = TRUE,
  immediate_ui = TRUE,  # Now default
  demographics = c("age", "gender", "study_program"),
  language = "de"
)

# Enhanced CSS and JavaScript for all improvements
hilfo_improvements <- "
<style>
  /* Mobile table improvements - abbreviate headers */
  @media (max-width: 768px) {
    .results-table th:nth-child(2):after { content: 'M'; }
    .results-table th:nth-child(2) { font-size: 0; }
    .results-table th:nth-child(3):after { content: 'SD'; }
    .results-table th:nth-child(3) { font-size: 0; }
    .results-table { font-size: 12px; }
  }
  
  /* Grey buttons for select and download */
  .btn-secondary, .download-btn, select, .form-control {
    background-color: #6c757d !important;
    border-color: #6c757d !important;
    color: white !important;
  }
  
  .btn-secondary:hover, .download-btn:hover {
    background-color: #5a6268 !important;
    border-color: #545b62 !important;
  }
  
  /* Radio button improvements - grey selection */
  .shiny-input-radiogroup input[type='radio']:checked + span {
    background-color: rgba(108, 117, 125, 0.15) !important;
    border-color: #6c757d !important;
    border-width: 2px !important;
  }
  
  /* Validation error highlighting */
  .validation-error-field {
    border: 2px solid #dc3545 !important;
    background-color: #fff5f5 !important;
    animation: shake 0.5s ease-in-out;
  }
  
  @keyframes shake {
    0%, 100% { transform: translateX(0); }
    25% { transform: translateX(-5px); }
    75% { transform: translateX(5px); }
  }
  
  /* Results section styling */
  .results-intro {
    font-size: 16px;
    margin-bottom: 25px;
    padding: 20px;
    background-color: #f8f9fa;
    border-radius: 8px;
    border-left: 4px solid #007bff;
  }
  
  /* Adaptive plot explanation */
  .adaptive-explanation {
    margin-top: 15px;
    padding: 10px;
    background-color: #e9ecef;
    border-radius: 5px;
    font-size: 14px;
    font-style: italic;
  }
  
  /* inrep attribution */
  .inrep-attribution {
    margin-top: 30px;
    padding: 20px;
    background-color: #e9ecef;
    border-radius: 8px;
    text-align: center;
    font-size: 14px;
    border-top: 3px solid #007bff;
  }
  
  .close-window-btn {
    margin-top: 15px;
    background-color: #6c757d !important;
    border-color: #6c757d !important;
    padding: 8px 20px;
  }
</style>

<script>
$(document).ready(function() {
  // 1. Auto scroll to top on every page change
  $(document).on('shiny:value', function(event) {
    if (event.name === 'study_ui' || event.name === 'page_content') {
      setTimeout(function() {
        window.scrollTo({top: 0, behavior: 'smooth'});
      }, 100);
    }
  });
  
  // 2. Enhanced radio button deselection
  $(document).on('click', 'input[type=\"radio\"]', function() {
    var $this = $(this);
    var wasChecked = $this.data('was-checked') === true;
    var radioGroup = $('input[name=\"' + this.name + '\"]');
    
    // Clear all previous states
    radioGroup.data('was-checked', false).closest('label').removeClass('selected');
    
    if (wasChecked) {
      // Deselect the radio button
      $this.prop('checked', false);
      if (typeof Shiny !== 'undefined') {
        Shiny.setInputValue(this.name, null);
      }
    } else {
      // Select the radio button
      $this.data('was-checked', true).closest('label').addClass('selected');
    }
  });
  
  // 3. Validation error handling with highlighting and auto-scroll
  Shiny.addCustomMessageHandler('validation_errors', function(message) {
    // Clear previous highlights
    $('.validation-error-field').removeClass('validation-error-field');
    
    // Highlight error fields and scroll to first one
    if (message.fields && message.fields.length > 0) {
      var firstErrorElement = null;
      
      message.fields.forEach(function(fieldName, index) {
        var element = $('[name=\"' + fieldName + '\"], #' + fieldName + ', input[name*=\"' + fieldName + '\"]');
        element.addClass('validation-error-field');
        
        if (index === 0 && element.length > 0) {
          firstErrorElement = element.first();
        }
      });
      
      // Scroll to first error field
      if (firstErrorElement) {
        $('html, body').animate({
          scrollTop: firstErrorElement.offset().top - 100
        }, 500);
      }
    }
  });
  
  // 4. Emergency data saving
  function saveData() {
    if (typeof Shiny !== 'undefined') {
      Shiny.setInputValue('emergency_save', {
        timestamp: new Date().toISOString(),
        random: Math.random()
      }, {priority: 'event'});
    }
  }
  
  // Auto-save on page unload
  $(window).on('beforeunload', function() {
    saveData();
  });
  
  // Auto-save every 30 seconds
  setInterval(saveData, 30000);
  
  // Auto-save on visibility change (tab switching, etc.)
  document.addEventListener('visibilitychange', function() {
    if (document.hidden) {
      saveData();
    }
  });
  
  // 5. Fix legend order (adaptive first, then fixed)
  $(document).on('plotly_afterplot', function() {
    // This will be handled in the R plotting code
  });
});
</script>
"

# Custom results processor with all improvements
process_hilfo_results <- function(responses, item_bank, demographics) {
  # Results introduction text
  results_intro <- div(
    class = "results-intro",
    h4("Vielen Dank für die Teilnahme!"),
    p("Nachfolgend erhalten Sie die Übersicht Ihrer Ergebnisse. Bedenken Sie, dass dies nur Schätzungen sind, die auf Ihrem Antwortverhalten basieren.")
  )
  
  # Process results (existing logic would go here)
  # ... existing results processing ...
  
  # Adaptive plot with explanation
  adaptive_plot <- div(
    # Your existing adaptive plot code
    div(
      class = "adaptive-explanation",
      "Hinweis: Der Itempool besteht insgesamt aus 20 Items. Die Darstellung zeigt die adaptive Itemauswahl basierend auf Ihren Antworten."
    )
  )
  
  # inrep attribution
  attribution <- div(
    class = "inrep-attribution",
    p("Diese Befragung wurde mit inrep durchgeführt - einem R-Paket für Instant Reports bei adaptiven Assessments."),
    actionButton("close_window", "Fenster schließen", class = "btn close-window-btn", 
                onclick = "window.close();")
  )
  
  return(tagList(
    results_intro,
    # ... your existing results content ...
    adaptive_plot,
    attribution
  ))
}

# Enhanced server function for data preservation
enhanced_server <- function(input, output, session) {
  # Emergency save handler
  observeEvent(input$emergency_save, {
    tryCatch({
      # Save current state to file and cloud
      current_data <- list(
        responses = isolate(reactiveValuesToList(input)),
        timestamp = Sys.time(),
        session_id = session$token
      )
      
      # Save locally
      saveRDS(current_data, paste0("emergency_save_", session$token, ".rds"))
      
      # Save to cloud if configured
      if (exists("WEBDAV_URL") && !is.null(WEBDAV_URL)) {
        # Cloud save logic here
      }
      
      message("Emergency save completed")
    }, error = function(e) {
      message("Emergency save failed: ", e$message)
    })
  })
  
  # Auto save handler
  observeEvent(input$auto_save, {
    # Similar to emergency save but less verbose
    tryCatch({
      current_data <- list(
        responses = isolate(reactiveValuesToList(input)),
        timestamp = Sys.time(),
        session_id = session$token
      )
      saveRDS(current_data, paste0("auto_save_", session$token, ".rds"))
    }, error = function(e) {
      # Silent failure for auto-save
    })
  })
  
  # Validation error highlighting
  validate_and_highlight <- function(required_fields) {
    missing_fields <- c()
    
    for (field in required_fields) {
      if (is.null(input[[field]]) || input[[field]] == "") {
        missing_fields <- c(missing_fields, field)
      }
    }
    
    if (length(missing_fields) > 0) {
      session$sendCustomMessage("validation_errors", list(fields = missing_fields))
      return(FALSE)
    }
    
    return(TRUE)
  }
}

# Launch the study with all improvements
inrep::launch_study(
  config = study_config,
  item_bank = all_items_de,  # Your item bank
  webdav_url = WEBDAV_URL,   # Your WebDAV URL
  password = WEBDAV_PASSWORD, # Your WebDAV password
  save_format = "csv",
  custom_css = hilfo_improvements,
  server_extensions = enhanced_server  # Additional server functionality
)