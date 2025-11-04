#' Debug Mode Functions for inrep Package
#' @keywords internal
#' @export
generate_debug_mode_js <- function(debug_mode = FALSE) {
  cat("DEBUG R: generate_debug_mode_js called with debug_mode =", debug_mode, "\n")
  if (!debug_mode) return(NULL)
  cat("DEBUG R: Creating debug mode script\n")

  return(shiny::tags$script(shiny::HTML("
    console.log('*** DEBUG MODE STARTED ***');
    console.log('Hotkeys: Ctrl+A=Fill Current Page | Ctrl+Q=Auto Normal | Ctrl+Y=Auto Fast');

    (function() {
      'use strict';
      
      // Prevent multiple initializations
      if (window.inrepDebugInitialized) {
        console.log('DEBUG: Already initialized, skipping');
        return;
      }
      window.inrepDebugInitialized = true;

      // Utility functions
      const utils = {
        randomNumber: (min, max) => Math.floor(Math.random() * (max - min + 1)) + min,
        
        randomText: (length = 10) => {
          const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
          return Array.from({length}, () => chars[Math.floor(Math.random() * chars.length)]).join('');
        },
        
        getInputLabel: (input) => {
          const labelId = input.getAttribute('aria-labelledby');
        if (labelId) {
            const label = document.getElementById(labelId);
            if (label) return label.textContent.trim();
          }
          if (input.id) {
            const label = document.querySelector(`label[for=\"${input.id}\"]`);
            if (label) return label.textContent.trim();
        }
        return '';
        },
        
        isVisible: (el) => {
          return el && el.offsetParent !== null && el.offsetHeight > 0 && el.offsetWidth > 0;
        },
        
        triggerShinyUpdate: (id, value) => {
          if (typeof Shiny !== 'undefined' && Shiny.setInputValue) {
            Shiny.setInputValue(id, value);
            // Double-trigger for reliability
            setTimeout(() => Shiny.setInputValue(id, value), 50);
          }
        },
        
        triggerEvents: (element, value) => {
          if (!element) return;
          
          if (value !== undefined) {
            element.value = value;
          }
          
          ['input', 'change', 'blur'].forEach(eventType => {
            element.dispatchEvent(new Event(eventType, { bubbles: true, cancelable: true }));
          });
          
          // jQuery fallback if available
          if (typeof jQuery !== 'undefined') {
            jQuery(element).trigger('change').trigger('input');
          }
        }
      };

      // Field filling strategies
      const fillers = {
        // Fill selectize (Shiny selectInput)
        fillSelectize: () => {
          console.log('DEBUG: Processing selectize inputs...');
          let count = 0;
          
          document.querySelectorAll('select:not(.selectized)').forEach(select => {
            if (select.disabled || !utils.isVisible(select)) return;
            
            // Check if this select has been selectized
            const selectizeInput = select.nextElementSibling;
            const isSelectized = selectizeInput && selectizeInput.classList.contains('selectize-control');
            
            if (isSelectized && select.selectize) {
              // Use selectize API directly
              const options = select.selectize.options;
              const validOptions = Object.keys(options).filter(key => key && key !== '' && key !== ' ');
              
              if (validOptions.length > 0) {
                const chosen = validOptions[0];
                select.selectize.setValue(chosen, false);
                select.selectize.blur();
                utils.triggerShinyUpdate(select.id, chosen);
                console.log('DEBUG: SELECTIZE', select.id, '->', chosen);
                count++;
              }
            } else if (!isSelectized) {
              // Regular select (non-selectized)
              fillers.fillNativeSelect(select) && count++;
            }
          });
          
          return count;
        },
        
        // Fill native select dropdowns
        fillNativeSelect: (select) => {
          if (!select || select.disabled || !utils.isVisible(select)) return false;
          
          const validOptions = Array.from(select.options).filter(opt => 
            opt.value && opt.value.trim() !== '' && opt.value !== ' '
          );
          
          if (validOptions.length === 0) return false;
          
          const chosen = validOptions[0];
          select.value = chosen.value;
          utils.triggerEvents(select);
          utils.triggerShinyUpdate(select.id, chosen.value);
          console.log('DEBUG: SELECT', select.id, '->', chosen.value);
          return true;
        },
        
        // Fill demographic fields (age, text inputs)
        fillDemographics: () => {
          console.log('DEBUG: Processing demographic fields...');
          let count = 0;
          
          // First pass: fill visible fields
          document.querySelectorAll('[id^=\"demo_\"]').forEach(input => {
            if (input.tagName !== 'INPUT' || input.disabled || input.readOnly) return;
            if (!utils.isVisible(input)) return;
            
            // Skip selectize inputs
            if (input.classList.contains('selectize-control') || 
                input.id.endsWith('-selectized') ||
                document.getElementById(input.id.replace('-selectized', ''))?.tagName === 'SELECT') {
              return;
            }
            
            const inputType = input.type || 'text';
            const label = utils.getInputLabel(input).toLowerCase();
            const isAgeField = input.id === 'demo_1' || 
                              label.includes('age') || 
                              label.includes('alter') || 
                              label.includes('jahr');
            
            let value = null;
            
            if (isAgeField || inputType === 'number') {
              value = utils.randomNumber(18, 75);
            } else if (inputType === 'text') {
              value = `Test ${utils.randomNumber(100, 999)}`;
            }
            
            if (value !== null) {
              utils.triggerEvents(input, value);
              utils.triggerShinyUpdate(input.id, value);
              console.log('DEBUG: DEMO', input.id, '->', value);
              count++;
            }
          });
          
          // Second pass: wait for conditional fields to appear and fill them
          // This handles cases where selecting Other option shows a text field
          setTimeout(() => {
            document.querySelectorAll('[id^=\"demo_\"]').forEach(input => {
              if (input.tagName !== 'INPUT' || input.disabled || input.readOnly) return;
              if (!utils.isVisible(input)) return;
              if (input.value && input.value.trim() !== '') return; // Already filled
              
              // Skip selectize inputs
              if (input.classList.contains('selectize-control') || 
                  input.id.endsWith('-selectized') ||
                  document.getElementById(input.id.replace('-selectized', ''))?.tagName === 'SELECT') {
                return;
              }
              
              const inputType = input.type || 'text';
              if (inputType === 'text') {
                const value = `Test ${utils.randomNumber(100, 999)}`;
                utils.triggerEvents(input, value);
                utils.triggerShinyUpdate(input.id, value);
                console.log('DEBUG: DEMO (conditional)', input.id, '->', value);
                count++;
              }
            });
          }, 500); // Wait 500ms for conditional fields to appear
          
          return count;
        },
        
        // Fill checkboxes (smart: check consent/agree, random for others)
        fillCheckboxes: () => {
          console.log('DEBUG: Processing checkboxes...');
          let count = 0;
          
          document.querySelectorAll('input[type=\"checkbox\"]').forEach(checkbox => {
            if (checkbox.disabled || !utils.isVisible(checkbox)) return;
            if (checkbox.checked) return; // Already checked
            
            const label = utils.getInputLabel(checkbox).toLowerCase();
            const isConsent = /agree|consent|akzept|zustimm|confirm|bestät/i.test(label);
            const shouldCheck = isConsent || Math.random() > 0.5;
            
            if (shouldCheck) {
              checkbox.checked = true;
              utils.triggerEvents(checkbox);
              utils.triggerShinyUpdate(checkbox.id, true);
              count++;
            }
          });
          
          console.log('DEBUG: Checked', count, 'checkboxes');
          return count;
        },
        
        // Fill radio buttons (smart handling for Likert scales)
        fillRadioButtons: () => {
          console.log('DEBUG: Processing radio buttons...');
          const processedGroups = new Set();
          let count = 0;
          
          document.querySelectorAll('input[type=\"radio\"]').forEach(radio => {
            if (radio.disabled || !utils.isVisible(radio)) return;
            
            const groupName = radio.name;
            if (!groupName || processedGroups.has(groupName)) return;
            
            const group = Array.from(document.querySelectorAll(`input[type=\"radio\"][name=\"${groupName}\"]`))
              .filter(r => !r.disabled && utils.isVisible(r));
            
            if (group.length === 0) return;
            processedGroups.add(groupName);
            
            // Check if already selected
            if (group.some(r => r.checked)) {
              console.log('DEBUG: Radio group', groupName, 'already has selection');
              return;
            }
            
            // Detect Likert scale (3-7 options with numeric values)
            const isLikert = group.length >= 3 && group.length <= 7 && 
                            group.every(r => /^\\d+$/.test(r.value));
            
            // For Likert, prefer middle options; for others, random but avoid Other option
            let chosenIndex;
            if (isLikert) {
              const middleIndex = Math.floor(group.length / 2);
              // Pick middle ± 1 randomly
              const variance = Math.random() < 0.5 ? 0 : (Math.random() < 0.5 ? -1 : 1);
              chosenIndex = Math.max(0, Math.min(group.length - 1, middleIndex + variance));
            } else {
              // For non-Likert, detect and avoid Other option (generic detection)
              // Filter out options that look like Other/Anders/etc (generic)
              const validOptions = group.filter((r, idx) => {
                const value = r.value || '';
                const label = utils.getInputLabel(r) || '';
                const labelLower = label.toLowerCase();
                // Generic detection: avoid options with Other/Anders/etc in label or value
                return !(value.toLowerCase() === 'other' || 
                        labelLower.includes('other') || 
                        labelLower.includes('anders') ||
                        labelLower.includes('sonstiges') ||
                        labelLower.includes('sonstige'));
              });
              
              if (validOptions.length > 0) {
                // Choose randomly from valid options (excluding Other-like options)
                chosenIndex = group.indexOf(validOptions[Math.floor(Math.random() * validOptions.length)]);
              } else {
                // Fallback: if all options are Other-like, just pick first
                chosenIndex = 0;
              }
            }
            
            const chosen = group[chosenIndex];
            chosen.checked = true;
            
            // Trigger events
            ['change', 'input', 'click'].forEach(eventType => {
              chosen.dispatchEvent(new Event(eventType, { bubbles: true, cancelable: true }));
            });
            
            utils.triggerShinyUpdate(groupName, chosen.value);
            
            console.log('DEBUG: RADIO', groupName, '->', chosen.value, '(' + group.length + ' options' + (isLikert ? ', Likert' : '') + ')');
            count++;
          });
          
          console.log('DEBUG: Filled', count, 'radio groups');
          
          // CRITICAL: After ALL radio buttons are selected, check for conditional fields
          // This works for ANY language - uses multiple detection methods
          setTimeout(() => {
            console.log('DEBUG: Post-radio conditional field check (language-agnostic)...');
            
            // Method 1: Check all demo_ prefixed text inputs
            document.querySelectorAll('[id^=\"demo_\"]').forEach(input => {
              if (input.tagName === 'INPUT' && input.type === 'text' && 
                  utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                const value = `Test ${utils.randomNumber(100, 999)}`;
                utils.triggerEvents(input, value);
                utils.triggerShinyUpdate(input.id, value);
                console.log('DEBUG: Filled conditional (demo_ pattern)', input.id);
              }
            });
            
            // Method 2: Check by ID patterns (language-agnostic)
            document.querySelectorAll('input[type=\"text\"]').forEach(input => {
              if (utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                const inputId = (input.id || input.name || '').toLowerCase();
                // Universal patterns that work in any language
                const conditionalPatterns = ['zusatz', 'other', 'specify', 'anders', 'sonstig', 
                                           'specify', 'detail', 'please', 'bitte', 'weitere'];
                if (conditionalPatterns.some(pattern => inputId.includes(pattern))) {
                  const value = `Test ${utils.randomNumber(100, 999)}`;
                  utils.triggerEvents(input, value);
                  utils.triggerShinyUpdate(input.id || input.name, value);
                  console.log('DEBUG: Filled conditional (pattern match)', input.id || input.name);
                }
              }
            });
            
            // Method 3: Check for text inputs that appear after radio selection (heuristic)
            document.querySelectorAll('input[type=\"radio\"]:checked').forEach(radio => {
              const container = radio.closest('div, form, fieldset, .form-group') || document.body;
              container.querySelectorAll('input[type=\"text\"]').forEach(input => {
                if (utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                  // Check if it's near the checked radio (likely conditional)
                  const rect1 = radio.getBoundingClientRect();
                  const rect2 = input.getBoundingClientRect();
                  const distance = Math.abs(rect2.top - rect1.bottom);
                  
                  if (distance < 200) { // Within 200px - likely conditional
                    const value = `Test ${utils.randomNumber(100, 999)}`;
                    utils.triggerEvents(input, value);
                    utils.triggerShinyUpdate(input.id || input.name, value);
                    console.log('DEBUG: Filled conditional (proximity)', input.id || input.name);
                  }
                }
              });
            });
          }, 600); // Wait 600ms for conditional fields to appear
          
          return count;
        },
        
        // Fill text areas and free-text inputs
        fillFreeText: () => {
          console.log('DEBUG: Processing free-text fields...');
          let count = 0;
          
          document.querySelectorAll('textarea, input[type=\"text\"]').forEach(el => {
            if (el.disabled || el.readOnly || !utils.isVisible(el)) return;
            
            const id = el.id || '';
            // Skip demographics (handled separately) and selectize
            if (id.startsWith('demo_') || 
                el.classList.contains('selectize-control') ||
                id.endsWith('-selectized')) {
              return;
            }
            
            const text = `AutoText ${utils.randomNumber(100, 999)} ${utils.randomText(8)}`;
            utils.triggerEvents(el, text);
            utils.triggerShinyUpdate(id, text);
            count++;
          });
          
          console.log('DEBUG: Filled', count, 'free-text fields');
          return count;
        }
      };

      // Main page filling function
      function fillCurrentPage(callback, fastMode) {
        console.log('DEBUG: ========== FILLING CURRENT PAGE ==========');
        
        // Safety check: Don't fill fields on report page
        if (isReportPage()) {
          console.log('DEBUG: Report page detected, skipping field filling');
          if (callback && typeof callback === 'function') {
            callback();
          }
          return;
        }
        
        const stats = {
          selectize: 0,
          demographics: 0,
          checkboxes: 0,
          radioGroups: 0,
          freeText: 0
        };
        
        // Fill in order (selectize first to avoid conflicts)
        stats.selectize = fillers.fillSelectize();
        stats.demographics = fillers.fillDemographics();
        stats.checkboxes = fillers.fillCheckboxes();
        stats.radioGroups = fillers.fillRadioButtons();
        stats.freeText = fillers.fillFreeText();
        
        // Wait for all updates to propagate - shorter timeout for fast mode
        const fillTimeout = fastMode ? 500 : 1000;
        setTimeout(() => {
          console.log('DEBUG: ========== FILL SUMMARY ==========');
          console.log('Selectize fields:', stats.selectize);
          console.log('Demographics:', stats.demographics);
          console.log('Checkboxes:', stats.checkboxes);
          console.log('Radio groups:', stats.radioGroups);
          console.log('Free-text fields:', stats.freeText);
          console.log('DEBUG: ====================================');
          
          if (callback && typeof callback === 'function') {
            callback();
          }
        }, fillTimeout);
      }

      // Navigation helpers
      function getNextButton() {
        const buttons = Array.from(document.querySelectorAll('button'));
        console.log('DEBUG: Searching', buttons.length, 'buttons for next button');
        
        // Priority 1: Exact text matches
        const nextKeywords = ['next', 'weiter', 'submit', 'senden', 'continue', 'fortfahren', 'start', 'beginnen'];
        for (const btn of buttons) {
          if (!utils.isVisible(btn) || btn.disabled) continue;
          
          const text = btn.textContent.toLowerCase().trim();
          if (nextKeywords.some(keyword => text === keyword || text.includes(keyword))) {
            console.log('DEBUG: Found next button by text:', text);
            return btn;
          }
        }
        
        // Priority 2: ID or class matches
        for (const btn of buttons) {
          if (!utils.isVisible(btn) || btn.disabled) continue;
          
          const id = (btn.id || '').toLowerCase();
          const className = (btn.className || '').toLowerCase();
          if (id.includes('next') || id.includes('submit') || className.includes('next')) {
            console.log('DEBUG: Found next button by ID/class:', id);
            return btn;
          }
        }
        
        // Priority 3: Visible primary/action button (excluding back/cancel/download)
        const excludeKeywords = ['back', 'zurück', 'cancel', 'abbrechen', 'download', 'pdf', 'save', 'print', 
                                'csv', 'export', 'herunterladen', 'speichern', 'exportieren', 'json', 'rds'];
        for (const btn of buttons) {
          if (!utils.isVisible(btn) || btn.disabled) continue;
          
          const text = btn.textContent.toLowerCase();
          if (excludeKeywords.some(keyword => text.includes(keyword))) continue;
          
          console.log('DEBUG: Found fallback button:', text);
              return btn;
        }
        
        console.log('DEBUG: No suitable next button found');
        return null;
      }

      function isReportPage() {
        const content = (document.getElementById('page_content') || document.body).textContent.toLowerCase();
        
        // Check for download buttons or CSV export functionality (indicates report page)
        const hasDownloadButtons = document.querySelectorAll('button, a, input').length > 0 && 
          Array.from(document.querySelectorAll('button, a, input')).some(el => {
            const text = el.textContent?.toLowerCase() || '';
            const id = el.id?.toLowerCase() || '';
            const value = el.value?.toLowerCase() || '';
            return text.includes('download') || text.includes('csv') || text.includes('export') ||
                   text.includes('herunterladen') || text.includes('speichern') || text.includes('save') ||
                   id.includes('download') || id.includes('csv') || id.includes('export') ||
                   value.includes('download') || value.includes('csv');
          });
        
        // Check for results/report content indicators
        const hasResultsContent = (content.includes('result') && (content.includes('score') || content.includes('theta'))) ||
               content.includes('abgeschlossen') ||
               (content.includes('thank') && content.includes('complete')) ||
               content.includes('danke für ihre teilnahme') ||
               content.includes('vielen dank') ||
               content.includes('results') ||
               content.includes('ergebnis') ||
               content.includes('auswertung') ||
               content.includes('completed') ||
               content.includes('fertig') ||
               content.includes('beendet');
        
        // Check for specific report page indicators
        const hasReportIndicators = content.includes('hilfo') || // Your study name
               content.includes('hildesheimer') ||
               (content.includes('study') && content.includes('complete')) ||
               (content.includes('studie') && content.includes('abgeschlossen'));
        
        const isReport = hasDownloadButtons || hasResultsContent || hasReportIndicators;
        
        if (isReport) {
          console.log('DEBUG: Report page detected - Download buttons:', hasDownloadButtons, 
                      'Results content:', hasResultsContent, 'Report indicators:', hasReportIndicators);
        }
        
        return isReport;
      }

      // Auto-progression function
      function autoProgressAll(waitTime, transitionTime) {
        console.log('DEBUG: Starting auto-progression wait=' + waitTime + 'ms transition=' + transitionTime + 'ms');
        
        // Detect fast mode (waitTime <= 150ms indicates fast mode)
        const fastMode = waitTime <= 150;
        
        let stepCount = 0;
        const maxSteps = 100; // Safety limit
        
        function progressStep() {
          stepCount++;
          console.log('DEBUG: === STEP', stepCount, '===');
          
          if (stepCount > maxSteps) {
            console.log('DEBUG: Max steps reached, stopping');
            return;
          }
          
          if (isReportPage()) {
            console.log('DEBUG: Report page detected, stopping auto-progression');
                  return;
                }

          fillCurrentPage(() => {
            // Wait for conditional fields to appear and be filled (LANGUAGE-AGNOSTIC)
            setTimeout(() => {
              // Multiple passes to catch conditional fields that appear at different times
              // Reduce attempts and interval for fast mode
              let attempts = 0;
              const maxAttempts = fastMode ? 2 : 5;
              const checkInterval = fastMode ? 200 : 400;
              
              const checkAndFillConditional = () => {
                attempts++;
                console.log('DEBUG: Checking for conditional fields, attempt', attempts);
                
                // Method 1: Check all demo_ prefixed fields
                document.querySelectorAll('[id^=\"demo_\"]').forEach(input => {
                  if (input.tagName === 'INPUT' && input.type === 'text' && 
                      utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                    const value = `Test ${utils.randomNumber(100, 999)}`;
                    utils.triggerEvents(input, value);
                    utils.triggerShinyUpdate(input.id, value);
                    console.log('DEBUG: Filled conditional field (demo_)', input.id);
                  }
                });
                
                // Method 2: Check all text inputs (language-agnostic)
                document.querySelectorAll('input[type=\"text\"]').forEach(input => {
                  if (utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                    const inputId = input.id || input.name || '';
                    // Detect conditional fields by common patterns (works in any language)
                    const isConditional = inputId.toLowerCase().includes('zusatz') ||
                                         inputId.toLowerCase().includes('other') ||
                                         inputId.toLowerCase().includes('specify') ||
                                         inputId.toLowerCase().includes('anders') ||
                                         inputId.includes('_Zusatz') ||
                                         inputId.includes('_other') ||
                                         inputId.includes('_Other');
                    
                    if (isConditional) {
                      const value = `Test ${utils.randomNumber(100, 999)}`;
                      utils.triggerEvents(input, value);
                      utils.triggerShinyUpdate(input.id || input.name, value);
                      console.log('DEBUG: Filled conditional field (pattern match)', inputId);
                    }
                  }
                });
                
                // Method 3: Check for visible empty text inputs near radio buttons (heuristic)
                document.querySelectorAll('input[type=\"radio\"]:checked').forEach(radio => {
                  // Find nearby text inputs that might be conditional
                  const parent = radio.closest('div, form, fieldset') || document.body;
                  parent.querySelectorAll('input[type=\"text\"]').forEach(input => {
                    if (utils.isVisible(input) && (!input.value || input.value.trim() === '')) {
                      const value = `Test ${utils.randomNumber(100, 999)}`;
                      utils.triggerEvents(input, value);
                      utils.triggerShinyUpdate(input.id || input.name, value);
                      console.log('DEBUG: Filled conditional field (proximity)', input.id || input.name);
                    }
                  });
                });
                
                // If we haven't found the next button yet and haven't exceeded attempts, try again
                if (attempts < maxAttempts) {
                  setTimeout(checkAndFillConditional, checkInterval);
                } else {
                  // Final attempt to find and click next button
                  const nextBtn = getNextButton();
                  if (nextBtn) {
                    console.log('DEBUG: Clicking next button after', attempts, 'attempts');
                    nextBtn.click();
                    setTimeout(progressStep, transitionTime);
                  } else {
                    console.log('DEBUG: No next button found after', attempts, 'attempts, stopping');
                  }
                }
              };
              
              // Start checking immediately, then continue checking
              checkAndFillConditional();
              
            }, waitTime);
          }, fastMode);
              }

        progressStep();
      }

      // Hotkey handlers
      document.addEventListener('keydown', (e) => {
        if (!e.ctrlKey) return;
        
        switch(e.key.toLowerCase()) {
          case 'a':
            e.preventDefault();
            console.log('DEBUG: Ctrl+A - Fill current page only');
            fillCurrentPage();
            break;
          case 'q':
            e.preventDefault();
            console.log('DEBUG: Ctrl+Q - Auto-fill (normal speed)');
            autoProgressAll(800, 600);
            break;
          case 'y':
            e.preventDefault();
            console.log('DEBUG: Ctrl+Y - Auto-fill (fast speed)');
            autoProgressAll(100, 100);
            break;
        }
      });

      console.log('DEBUG: Hotkey listeners registered');
      console.log('DEBUG: Ready! Press Ctrl+A, Ctrl+Q, or Ctrl+Y');
    })();
  ")))
}