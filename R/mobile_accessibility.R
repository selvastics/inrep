# Mobile and Accessibility Enhancement System for inrep Package
# Provides mobile responsiveness, PWA capabilities, and accessibility features

#' Mobile and Accessibility Enhancement System
#' 
#' This module provides comprehensive mobile responsiveness, Progressive Web App (PWA)
#' capabilities, and accessibility features for inrep assessments.
#' 
#' @name mobile_accessibility
#' @keywords internal
NULL

#' Mobile Responsiveness
#' 
#' Enhance mobile user experience and responsiveness.

#' Generate responsive CSS
#' 
#' @param breakpoints List of breakpoints for different screen sizes
#' @return Responsive CSS content
#' @export
generate_responsive_css <- function(breakpoints = list(
  mobile = "768px",
  tablet = "1024px",
  desktop = "1200px"
)) {
  css_content <- paste0(
    "/* Responsive CSS for inrep */
    
    /* Mobile First Approach */
    .inrep-container {
      width: 100%;
      max-width: 100%;
      margin: 0 auto;
      padding: 10px;
      box-sizing: border-box;
    }
    
    .inrep-question {
      margin-bottom: 20px;
      padding: 15px;
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    .inrep-options {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }
    
    .inrep-option {
      padding: 12px 16px;
      border: 2px solid #e0e0e0;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.3s ease;
      font-size: 16px;
      line-height: 1.4;
    }
    
    .inrep-option:hover {
      border-color: #007bff;
      background-color: #f8f9fa;
    }
    
    .inrep-option.selected {
      border-color: #007bff;
      background-color: #e3f2fd;
    }
    
    .inrep-button {
      padding: 12px 24px;
      font-size: 16px;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      transition: all 0.3s ease;
      min-height: 44px; /* Touch target size */
    }
    
    .inrep-button-primary {
      background-color: #007bff;
      color: white;
    }
    
    .inrep-button-primary:hover {
      background-color: #0056b3;
    }
    
    .inrep-button-secondary {
      background-color: #6c757d;
      color: white;
    }
    
    .inrep-button-secondary:hover {
      background-color: #545b62;
    }
    
    /* Tablet Styles */
    @media (min-width: ", breakpoints$tablet, ") {
      .inrep-container {
        max-width: 800px;
        padding: 20px;
      }
      
      .inrep-options {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 15px;
      }
      
      .inrep-question {
        padding: 20px;
        font-size: 18px;
      }
    }
    
    /* Desktop Styles */
    @media (min-width: ", breakpoints$desktop, ") {
      .inrep-container {
        max-width: 1000px;
        padding: 30px;
      }
      
      .inrep-options {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 20px;
      }
      
      .inrep-question {
        padding: 25px;
        font-size: 20px;
      }
    }
    
    /* Mobile Specific */
    @media (max-width: ", breakpoints$mobile, ") {
      .inrep-container {
        padding: 5px;
      }
      
      .inrep-question {
        padding: 10px;
        font-size: 16px;
      }
      
      .inrep-option {
        padding: 15px 12px;
        font-size: 16px;
        min-height: 44px;
        display: flex;
        align-items: center;
      }
      
      .inrep-button {
        width: 100%;
        margin-bottom: 10px;
      }
    }
    
    /* Touch-friendly improvements */
    .inrep-option:active {
      transform: scale(0.98);
    }
    
    .inrep-button:active {
      transform: scale(0.98);
    }
    
    /* Prevent zoom on input focus (iOS) */
    input[type=\"text\"], input[type=\"email\"], input[type=\"number\"], 
    textarea, select {
      font-size: 16px;
    }
    
    /* Smooth scrolling */
    html {
      scroll-behavior: smooth;
    }
    
    /* Focus indicators */
    .inrep-option:focus,
    .inrep-button:focus {
      outline: 3px solid #007bff;
      outline-offset: 2px;
    }
    "
  )
  
  return(css_content)
}

#' Create mobile-optimized UI component
#' 
#' @param content UI content
#' @param mobile_optimized Whether to apply mobile optimizations
#' @return Mobile-optimized UI component
#' @export
create_mobile_ui <- function(content, mobile_optimized = TRUE) {
  if (!mobile_optimized) {
    return(content)
  }
  
  # Add mobile-specific classes and attributes
  mobile_content <- gsub("class=\"", "class=\"mobile-optimized ", content)
  mobile_content <- gsub("<div", "<div data-mobile=\"true\"", mobile_content)
  
  return(mobile_content)
}

#' Progressive Web App (PWA) Features
#' 
#' Enable PWA capabilities for inrep assessments.

#' Generate PWA manifest
#' 
#' @param app_name Application name
#' @param short_name Short application name
#' @param description Application description
#' @param theme_color Theme color
#' @param background_color Background color
#' @return PWA manifest content
#' @export
generate_pwa_manifest <- function(app_name = "inrep Assessment", 
                                 short_name = "inrep", 
                                 description = "Adaptive Assessment Platform",
                                 theme_color = "#007bff",
                                 background_color = "#ffffff") {
  manifest <- list(
    name = app_name,
    short_name = short_name,
    description = description,
    start_url = "/",
    display = "standalone",
    theme_color = theme_color,
    background_color = background_color,
    orientation = "portrait",
    icons = list(
      list(
        src = "icon-192x192.png",
        sizes = "192x192",
        type = "image/png"
      ),
      list(
        src = "icon-512x512.png",
        sizes = "512x512",
        type = "image/png"
      )
    ),
    categories = c("education", "productivity", "utilities"),
    lang = "en",
    dir = "ltr"
  )
  
  return(manifest)
}

#' Generate service worker for offline functionality
#' 
#' @param cache_name Cache name
#' @param urls_to_cache URLs to cache
#' @return Service worker content
#' @export
generate_service_worker <- function(cache_name = "inrep-cache-v1", 
                                   urls_to_cache = c("/", "/css/style.css", "/js/app.js")) {
  service_worker_content <- paste0(
    "// inrep Service Worker
const CACHE_NAME = '", cache_name, "';
const urlsToCache = [", paste0("'", urls_to_cache, "'", collapse = ", "), "];

// Install event
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );
});

// Fetch event
self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        // Return cached version or fetch from network
        return response || fetch(event.request);
      })
  );
});

// Activate event
self.addEventListener('activate', function(event) {
  event.waitUntil(
    caches.keys().then(function(cacheNames) {
      return Promise.all(
        cacheNames.map(function(cacheName) {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});
"
  )
  
  return(service_worker_content)
}

#' Register service worker
#' 
#' @param sw_path Service worker path
#' @return Registration script
#' @export
register_service_worker <- function(sw_path = "/sw.js") {
  registration_script <- paste0(
    "// Register Service Worker
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function() {
    navigator.serviceWorker.register('", sw_path, "')
      .then(function(registration) {
        console.log('Service Worker registered successfully');
      })
      .catch(function(error) {
        console.log('Service Worker registration failed:', error);
      });
  });
}
"
  )
  
  return(registration_script)
}

#' Accessibility Features
#' 
#' Enhance accessibility for users with disabilities.

#' Generate accessibility CSS
#' 
#' @param high_contrast Whether to enable high contrast mode
#' @param large_text Whether to enable large text mode
#' @param dyslexia_friendly Whether to enable dyslexia-friendly fonts
#' @return Accessibility CSS content
#' @export
generate_accessibility_css <- function(high_contrast = FALSE, large_text = FALSE, 
                                      dyslexia_friendly = FALSE) {
  css_content <- paste0(
    "/* Accessibility CSS for inrep */
    
    /* Base accessibility styles */
    .inrep-container {
      font-family: ", ifelse(dyslexia_friendly, "'OpenDyslexic', 'Comic Sans MS', sans-serif", "Arial, sans-serif"), ";
      line-height: 1.6;
      color: ", ifelse(high_contrast, "#000000", "#333333"), ";
      background-color: ", ifelse(high_contrast, "#ffffff", "#ffffff"), ";
    }
    
    .inrep-question {
      font-size: ", ifelse(large_text, "20px", "16px"), ";
      font-weight: 600;
      margin-bottom: 20px;
    }
    
    .inrep-option {
      font-size: ", ifelse(large_text, "18px", "16px"), ";
      padding: ", ifelse(large_text, "16px 20px", "12px 16px"), ";
      border: 2px solid ", ifelse(high_contrast, "#000000", "#e0e0e0"), ";
      background-color: ", ifelse(high_contrast, "#ffffff", "#ffffff"), ";
      color: ", ifelse(high_contrast, "#000000", "#333333"), ";
    }
    
    .inrep-option:hover {
      border-color: ", ifelse(high_contrast, "#000000", "#007bff"), ";
      background-color: ", ifelse(high_contrast, "#f0f0f0", "#f8f9fa"), ";
    }
    
    .inrep-option:focus {
      outline: 3px solid ", ifelse(high_contrast, "#000000", "#007bff"), ";
      outline-offset: 2px;
    }
    
    .inrep-option.selected {
      border-color: ", ifelse(high_contrast, "#000000", "#007bff"), ";
      background-color: ", ifelse(high_contrast, "#e0e0e0", "#e3f2fd"), ";
    }
    
    .inrep-button {
      font-size: ", ifelse(large_text, "18px", "16px"), ";
      padding: ", ifelse(large_text, "16px 32px", "12px 24px"), ";
      min-height: ", ifelse(large_text, "48px", "44px"), ";
      border: 2px solid ", ifelse(high_contrast, "#000000", "#007bff"), ";
    }
    
    .inrep-button:focus {
      outline: 3px solid ", ifelse(high_contrast, "#000000", "#007bff"), ";
      outline-offset: 2px;
    }
    
    /* Screen reader only text */
    .sr-only {
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    }
    
    /* Skip links */
    .skip-link {
      position: absolute;
      top: -40px;
      left: 6px;
      background: ", ifelse(high_contrast, "#000000", "#007bff"), ";
      color: ", ifelse(high_contrast, "#ffffff", "#ffffff"), ";
      padding: 8px;
      text-decoration: none;
      z-index: 1000;
    }
    
    .skip-link:focus {
      top: 6px;
    }
    
    /* Focus indicators */
    *:focus {
      outline: 3px solid ", ifelse(high_contrast, "#000000", "#007bff"), ";
      outline-offset: 2px;
    }
    
    /* High contrast mode */
    ", ifelse(high_contrast, "
    .inrep-container {
      background-color: #ffffff;
      color: #000000;
    }
    
    .inrep-option {
      border-color: #000000;
      background-color: #ffffff;
      color: #000000;
    }
    
    .inrep-option:hover {
      background-color: #f0f0f0;
    }
    
    .inrep-button {
      border-color: #000000;
      background-color: #ffffff;
      color: #000000;
    }
    
    .inrep-button:hover {
      background-color: #f0f0f0;
    }
    ", ""), "
    
    /* Large text mode */
    ", ifelse(large_text, "
    .inrep-container {
      font-size: 18px;
    }
    
    .inrep-question {
      font-size: 22px;
    }
    
    .inrep-option {
      font-size: 20px;
      padding: 18px 22px;
    }
    
    .inrep-button {
      font-size: 20px;
      padding: 18px 36px;
    }
    ", ""), "
    
    /* Dyslexia-friendly mode */
    ", ifelse(dyslexia_friendly, "
    .inrep-container {
      font-family: 'OpenDyslexic', 'Comic Sans MS', sans-serif;
      letter-spacing: 0.1em;
    }
    
    .inrep-question {
      font-weight: 600;
    }
    
    .inrep-option {
      font-weight: 500;
    }
    ", ""), "
    "
  )
  
  return(css_content)
}

#' Generate ARIA labels for accessibility
#' 
#' @param question_text Question text
#' @param options List of options
#' @param question_number Question number
#' @return ARIA labels
#' @export
generate_aria_labels <- function(question_text, options, question_number) {
  aria_labels <- list(
    question = paste0("Question ", question_number, ": ", question_text),
    options = paste0("Options for question ", question_number),
    instructions = paste0("Select one option for question ", question_number),
    progress = paste0("Question ", question_number, " of total questions")
  )
  
  return(aria_labels)
}

#' Create accessible form element
#' 
#' @param input_type Type of input element
#' @param input_id Input element ID
#' @param label_text Label text
#' @param options List of options (for select/radio)
#' @param required Whether input is required
#' @return Accessible form element
#' @export
create_accessible_form_element <- function(input_type, input_id, label_text, 
                                          options = NULL, required = FALSE) {
  # Generate ARIA attributes
  aria_required <- ifelse(required, "aria-required=\"true\"", "")
  aria_describedby <- paste0("aria-describedby=\"", input_id, "-help\"")
  
  if (input_type == "text" || input_type == "email" || input_type == "number") {
    element <- paste0(
      "<div class=\"form-group\">
        <label for=\"", input_id, "\">", label_text, 
        ifelse(required, " <span class=\"required\">*</span>", ""), "
        </label>
        <input type=\"", input_type, "\" 
               id=\"", input_id, "\" 
               name=\"", input_id, "\" 
               ", aria_required, " 
               ", aria_describedby, "
               class=\"form-control\">
        <div id=\"", input_id, "-help\" class=\"help-text\">
          ", ifelse(required, "This field is required.", ""), "
        </div>
      </div>"
    )
  } else if (input_type == "select") {
    options_html <- paste0(
      "<option value=\"\">Select an option</option>",
      paste0("<option value=\"", options, "\">", options, "</option>", collapse = "")
    )
    
    element <- paste0(
      "<div class=\"form-group\">
        <label for=\"", input_id, "\">", label_text, 
        ifelse(required, " <span class=\"required\">*</span>", ""), "
        </label>
        <select id=\"", input_id, "\" 
                name=\"", input_id, "\" 
                ", aria_required, " 
                ", aria_describedby, "
                class=\"form-control\">
          ", options_html, "
        </select>
        <div id=\"", input_id, "-help\" class=\"help-text\">
          ", ifelse(required, "This field is required.", ""), "
        </div>
      </div>"
    )
  } else if (input_type == "radio") {
    options_html <- paste0(
      "<fieldset>
        <legend>", label_text, 
        ifelse(required, " <span class=\"required\">*</span>", ""), "
        </legend>
        <div class=\"radio-group\" role=\"radiogroup\" ", aria_describedby, ">",
        paste0(
          "<div class=\"radio-option\">
            <input type=\"radio\" 
                   id=\"", input_id, "_", gsub(" ", "_", tolower(options)), "\" 
                   name=\"", input_id, "\" 
                   value=\"", options, "\" 
                   ", aria_required, ">
            <label for=\"", input_id, "_", gsub(" ", "_", tolower(options)), "\">", options, "</label>
          </div>", 
          collapse = ""
        ),
        "</div>
        <div id=\"", input_id, "-help\" class=\"help-text\">
          ", ifelse(required, "This field is required.", ""), "
        </div>
      </fieldset>"
    )
  }
  
  return(element)
}

#' Voice input support
#' 
#' Enable voice input for accessibility.

#' Generate voice input component
#' 
#' @param input_id Input element ID
#' @param supported Whether voice input is supported
#' @return Voice input component
#' @export
create_voice_input <- function(input_id, supported = TRUE) {
  if (!supported) {
    return("")
  }
  
  voice_input_html <- paste0(
    "<div class=\"voice-input-container\">
      <button type=\"button\" 
              id=\"", input_id, "-voice\" 
              class=\"voice-input-button\" 
              aria-label=\"Start voice input\"
              title=\"Click to start voice input\">
        <span class=\"voice-icon\">🎤</span>
        <span class=\"voice-text\">Voice Input</span>
      </button>
      <div id=\"", input_id, "-voice-status\" class=\"voice-status\" aria-live=\"polite\"></div>
    </div>
    
    <script>
    document.getElementById('", input_id, "-voice').addEventListener('click', function() {
      if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
        const recognition = new (window.SpeechRecognition || window.webkitSpeechRecognition)();
        const status = document.getElementById('", input_id, "-voice-status');
        const input = document.getElementById('", input_id, "');
        
        recognition.start();
        status.textContent = 'Listening...';
        
        recognition.onresult = function(event) {
          const transcript = event.results[0][0].transcript;
          input.value = transcript;
          status.textContent = 'Voice input received';
        };
        
        recognition.onerror = function(event) {
          status.textContent = 'Voice input error: ' + event.error;
        };
        
        recognition.onend = function() {
          status.textContent = 'Voice input ended';
        };
      } else {
        document.getElementById('", input_id, "-voice-status').textContent = 'Voice input not supported';
      }
    });
    </script>"
  )
  
  return(voice_input_html)
}

#' Offline functionality
#' 
#' Enable offline functionality for inrep assessments.

#' Generate offline storage functions
#' 
#' @return Offline storage functions
#' @export
generate_offline_functions <- function() {
  offline_js <- paste0(
    "// Offline functionality for inrep
    const OFFLINE_STORAGE_KEY = 'inrep_offline_data';
    
    // Save data offline
    function saveOfflineData(key, data) {
      try {
        const offlineData = JSON.parse(localStorage.getItem(OFFLINE_STORAGE_KEY) || '{}');
        offlineData[key] = {
          data: data,
          timestamp: Date.now()
        };
        localStorage.setItem(OFFLINE_STORAGE_KEY, JSON.stringify(offlineData));
        return true;
      } catch (error) {
        console.error('Error saving offline data:', error);
        return false;
      }
    }
    
    // Load data from offline storage
    function loadOfflineData(key) {
      try {
        const offlineData = JSON.parse(localStorage.getItem(OFFLINE_STORAGE_KEY) || '{}');
        return offlineData[key] ? offlineData[key].data : null;
      } catch (error) {
        console.error('Error loading offline data:', error);
        return null;
      }
    }
    
    // Clear offline data
    function clearOfflineData() {
      try {
        localStorage.removeItem(OFFLINE_STORAGE_KEY);
        return true;
      } catch (error) {
        console.error('Error clearing offline data:', error);
        return false;
      }
    }
    
    // Check if online
    function isOnline() {
      return navigator.onLine;
    }
    
    // Handle online/offline events
    window.addEventListener('online', function() {
      console.log('Connection restored');
      // Sync offline data when back online
      syncOfflineData();
    });
    
    window.addEventListener('offline', function() {
      console.log('Connection lost - working offline');
    });
    
    // Sync offline data when back online
    function syncOfflineData() {
      const offlineData = JSON.parse(localStorage.getItem(OFFLINE_STORAGE_KEY) || '{}');
      for (const key in offlineData) {
        // Send data to server
        fetch('/api/sync', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            key: key,
            data: offlineData[key].data
          })
        })
        .then(response => {
          if (response.ok) {
            // Remove synced data from offline storage
            delete offlineData[key];
            localStorage.setItem(OFFLINE_STORAGE_KEY, JSON.stringify(offlineData));
          }
        })
        .catch(error => {
          console.error('Error syncing offline data:', error);
        });
      }
    }
    "
  )
  
  return(offline_js)
}