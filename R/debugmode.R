#' Debug Mode Functions for inrep Package
#' @keywords internal
#' @export
generate_debug_mode_js <- function(debug_mode = FALSE) {
  cat("DEBUG R: generate_debug_mode_js called with debug_mode =", debug_mode, "\n")
  if (!debug_mode) return(NULL)
  cat("DEBUG R: Creating debug mode script\n")

  return(shiny::tags$script(shiny::HTML("
    console.log('*** DEBUG MODE STARTED ***');
    console.log('Hotkeys: Ctrl+A=Fill All | Ctrl+Q=Auto Normal | Ctrl+W=Auto Fast');

    document.addEventListener('DOMContentLoaded', function() {
      function randomNumber(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
      }

      function randomText(length) {
        if (!length) length = 10;
        var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var result = '';
        for (var i = 0; i < length; i++) result += chars.charAt(Math.floor(Math.random() * chars.length));
        return result;
      }

      function isDemographicField(input) {
        var inputId = (input.id || '').toLowerCase();
        return inputId.indexOf('demo') !== -1;
      }

      function getInputLabel(input) {
        var labelId = input.getAttribute('aria-labelledby');
        if (labelId) {
          var label = document.getElementById(labelId);
          if (label) return label.textContent;
        }
        var inputId = input.id;
        if (inputId) {
          var label = document.querySelector('label[for=\"' + inputId + '\"]');
          if (label) return label.textContent;
        }
        return '';
      }

      function fillCurrentPageComprehensive() {
        console.log('DEBUG: Starting fillCurrentPageComprehensive');
        
        // STEP 0: First, log all demo inputs we find
        console.log('DEBUG: Searching for demographic inputs...');
        document.querySelectorAll('[id^=\"demo_\"]').forEach(function(el) {
          console.log('DEBUG: Found element with demo_ ID: id=' + el.id + ', tag=' + el.tagName + ', type=' + (el.type || 'N/A'));
        });
        
        // STEP 0.1: Inspect radio button groups and highlight programming anxiety pools
        var radioGroupSizes = {};
        document.querySelectorAll('input[type=\"radio\"]').forEach(function(radio) {
          var group = radio.name || '';
          if (!group) return;
          if (!radioGroupSizes[group]) {
            radioGroupSizes[group] = 0;
          }
          radioGroupSizes[group] += 1;
        });
        var groupNames = Object.keys(radioGroupSizes);
        console.log('DEBUG: Identified ' + groupNames.length + ' radio groups on this page');
        groupNames.forEach(function(group) {
          var size = radioGroupSizes[group];
          var descriptor = (size >= 3 && size <= 7) ? ' (Likert-style)' : '';
          console.log('DEBUG:   Group \"' + group + '\" has ' + size + ' options' + descriptor);
        });
        
        // STEP 1: Handle selectize inputs (Shiny selectInput) - including demographics
        console.log('DEBUG: Processing selectize inputs...');
        document.querySelectorAll('input.selectize-control').forEach(function(selectizeInput) {
          var baseId = selectizeInput.id.replace(/-selectized$/, '');
          var underlyingSelect = document.getElementById(baseId);
          
          console.log('DEBUG: Processing selectize - baseId=' + baseId + ', selectizeId=' + selectizeInput.id);
          
          if (underlyingSelect && underlyingSelect.tagName === 'SELECT') {
            var options = Array.from(underlyingSelect.options);
            console.log('DEBUG: Found underlying SELECT for ' + baseId + ' with ' + options.length + ' options');
            
            var validOptions = options.filter(function(opt) { 
              var isValid = opt.value !== '' && opt.value !== ' ' && opt.value !== null;
              console.log('DEBUG: Option value=\\\"' + opt.value + '\\\" text=\\\"' + opt.text + '\\\" valid=' + isValid);
              return isValid;
            });
            
            if (validOptions.length === 0) {
              console.log('DEBUG: No valid options found for ' + baseId);
              return;
            }
            
            var chosen = validOptions[0];
            console.log('DEBUG: SELECTIZE ' + baseId + ' -> choosing value=\\\"' + chosen.value + '\\\" text=\\\"' + chosen.text + '\\\"');
            
            // Method 1: Set value on underlying select
            underlyingSelect.value = chosen.value;
            underlyingSelect.dispatchEvent(new Event('change', { bubbles: true }));
            underlyingSelect.dispatchEvent(new Event('input', { bubbles: true }));
            
            // Method 2: Update Shiny
            if (typeof Shiny !== 'undefined') {
              Shiny.setInputValue(baseId, chosen.value);
              console.log('DEBUG: Set Shiny value for ' + baseId + ' = ' + chosen.value);
            }
            
            // Method 3: Click on visible selectize input and press Enter
            console.log('DEBUG: Clicking on selectize input ' + selectizeInput.id + ' and pressing Enter');
            selectizeInput.click();
            selectizeInput.focus();
            
            // Small delay to let the dropdown open
            setTimeout(function() {
              // Press Enter to select first option
              var enterEvent = new KeyboardEvent('keydown', {
                key: 'Enter',
                code: 'Enter',
                keyCode: 13,
                which: 13,
                bubbles: true,
                cancelable: true
              });
              selectizeInput.dispatchEvent(enterEvent);
              console.log('DEBUG: Pressed Enter on selectize ' + selectizeInput.id);
              
              // Also update visible input value
              selectizeInput.value = chosen.value;
              selectizeInput.dispatchEvent(new Event('change', { bubbles: true }));
              selectizeInput.dispatchEvent(new Event('input', { bubbles: true }));
              selectizeInput.dispatchEvent(new Event('blur', { bubbles: true }));
            }, 100);
            
            // Method 4: jQuery trigger if available
            if (typeof jQuery !== 'undefined') {
              jQuery(underlyingSelect).val(chosen.value).trigger('change').trigger('input');
              jQuery(selectizeInput).val(chosen.value).trigger('change').trigger('input');
              console.log('DEBUG: Triggered jQuery change for ' + baseId);
            }
          } else {
            console.log('DEBUG: No underlying SELECT found for ' + baseId);
          }
        });
        
        // STEP 2: Fill numeric and text inputs (demographics) - NEW SMARTER APPROACH
        console.log('DEBUG: Processing demographic inputs by ID...');
        document.querySelectorAll('[id^=\\\"demo_\\\"]').forEach(function(input) {
          if (input.tagName === 'INPUT' && !input.disabled && !input.readOnly) {
            var inputId = input.id || '';
            var inputType = input.type || 'text';
            
            // SKIP if this is a selectize input (check both class and ID pattern)
            var isSelectizeControl = input.className.indexOf('selectize-control') !== -1;
            var isSelectizeId = inputId.indexOf('-selectized') !== -1;
            if (isSelectizeControl || isSelectizeId) {
              console.log('DEBUG: Skipping selectize input ' + inputId + ' (class=selectize-control or ID ends with -selectized)');
              return;
            }
            
            // ALSO skip if there's a hidden SELECT for this ID
            var hiddenSelect = document.getElementById(inputId);
            if (hiddenSelect && hiddenSelect.tagName === 'SELECT') {
              console.log('DEBUG: Skipping ' + inputId + ' - found underlying SELECT element');
              return;
            }
            
            console.log('DEBUG: Found demo input - id=' + inputId + ', type=' + inputType);
            
            // Get the label/question for this field
            var label = getInputLabel(input);
            console.log('DEBUG: Label for ' + inputId + ' = \\\"' + label + '\\\"');
            
            var labelLower = label.toLowerCase();
            var value = null;
            
            // DEMO_1 is usually Age
            // DEMO_2+ are usually other demographics
            var demoNum = inputId.replace('demo_', '');
            var isFirstDemo = demoNum === '1';
            
            // Check if it's an age field (from label or position)
            var isAgeField = isFirstDemo || labelLower.indexOf('alter') !== -1 || labelLower.indexOf('age') !== -1 || labelLower.indexOf('jahr') !== -1 || labelLower.indexOf('years') !== -1;
            
            console.log('DEBUG: isFirstDemo=' + isFirstDemo + ', isAgeField=' + isAgeField + ', inputType=' + inputType);
            
            // AGE FIELDS: Always numeric
            if (isAgeField) {
              value = randomNumber(18, 75);
              console.log('DEBUG: Setting AGE ' + inputId + ' to ' + value);
            } else if (inputType === 'number') {
              // Numeric inputs
              value = randomNumber(18, 75);
              console.log('DEBUG: Setting NUMBER ' + inputId + ' to ' + value);
            } else if (inputType === 'text') {
              // Text inputs (non-age demographics)
              value = 'Test ' + randomNumber(100, 999);
              console.log('DEBUG: Setting TEXT ' + inputId + ' to ' + value);
            }
            
            if (value !== null) {
              input.value = value;
              input.dispatchEvent(new Event('input', { bubbles: true }));
              input.dispatchEvent(new Event('change', { bubbles: true }));
              input.dispatchEvent(new Event('blur', { bubbles: true }));
              
                    if (typeof Shiny !== 'undefined') {
                Shiny.setInputValue(inputId, value);
                console.log('DEBUG: Shiny.setInputValue(' + inputId + ', ' + value + ')');
              }
                    if (typeof jQuery !== 'undefined') {
                jQuery(input).val(value).trigger('change').trigger('input');
                    }
                  }
          }
        });

        // STEP 3: Fill native select dropdowns
        console.log('DEBUG: Processing native SELECT dropdowns...');
        document.querySelectorAll('select').forEach(function(select) {
          if (!select.disabled && select.id.indexOf('-selectized') === -1) {
            var options = Array.from(select.options);
            var validOptions = options.filter(function(opt) { return opt.value !== '' && opt.value !== ' '; });
              if (validOptions.length > 0) {
              var chosen = validOptions[0];
              select.value = chosen.value;
              select.dispatchEvent(new Event('change', { bubbles: true }));
              select.dispatchEvent(new Event('input', { bubbles: true }));
              select.dispatchEvent(new Event('blur', { bubbles: true }));

              if (typeof Shiny !== 'undefined' && select.id) {
                Shiny.setInputValue(select.id, chosen.value);
              }
              if (typeof jQuery !== 'undefined') {
                jQuery(select).val(chosen.value).trigger('change');
              }
              console.log('DEBUG: SELECT ' + select.id + ' -> ' + chosen.value);
            }
          }
        });
        
        // STEP 4: Fill checkboxes (smart - check consent/agree boxes, 50% for others)
        document.querySelectorAll('input[type=\"checkbox\"]').forEach(function(checkbox) {
          if (!checkbox.disabled) {
            var shouldCheck = false;
            var label = getInputLabel(checkbox).toLowerCase();
            
            if (label.indexOf('agree') !== -1 || label.indexOf('consent') !== -1 || label.indexOf('akzept') !== -1 || label.indexOf('zustimm') !== -1) {
              shouldCheck = true;
            } else {
              shouldCheck = Math.random() > 0.5;
            }
            
            if (shouldCheck && !checkbox.checked) {
              checkbox.checked = true;
              checkbox.dispatchEvent(new Event('change', { bubbles: true }));
              checkbox.dispatchEvent(new Event('input', { bubbles: true }));
              
              if (typeof Shiny !== 'undefined' && checkbox.id) {
                Shiny.setInputValue(checkbox.id, true);
              }
            }
          }
        });
        
        // STEP 5: Fill radio buttons (smart handling for Likert-style groups)
        var processedGroups = new Set();
        document.querySelectorAll('input[type=\"radio\"]').forEach(function(radio) {
          if (radio.disabled) return;
          var groupName = radio.name || '';
          if (!groupName || processedGroups.has(groupName)) return;
          var group = document.querySelectorAll('input[type=\"radio\"][name=\"' + groupName + '\"]');
          if (!group || group.length === 0) return;
          processedGroups.add(groupName);

          var options = Array.from(group);
          var isLikert = options.length >= 3 && options.length <= 7 && options.every(function(opt) {
            return /^\\d+$/.test(opt.value);
          });

          // Always choose a random option for debug filling (avoid always picking the middle)
          var randomIndex = Math.floor(Math.random() * options.length);
          var chosen = options[randomIndex];

          console.log('DEBUG: RADIO GROUP ' + groupName + ' -> selecting value \"' + chosen.value + '\" (options=' + options.length + ')' + (isLikert ? ' [Likert]' : ''));

          if (!chosen.checked) {
            chosen.checked = true;
            chosen.dispatchEvent(new Event('change', { bubbles: true }));
            chosen.dispatchEvent(new Event('input', { bubbles: true }));
            chosen.dispatchEvent(new Event('click', { bubbles: true }));
            if (typeof Shiny !== 'undefined') {
              Shiny.setInputValue(groupName, chosen.value);
              setTimeout(function() {
                if (typeof Shiny !== 'undefined') {
                  Shiny.setInputValue(groupName, chosen.value);
                }
              }, 50);
            }
          }
        });
        console.log('DEBUG: Total distinct radio groups filled on this page: ' + processedGroups.size);

        // Also fill any free-text fields on the page (e.g., open_O1)
        try { fillFreeTextFields(); } catch (e) { console.log('DEBUG: fillFreeTextFields error: ' + e); }

        console.log('DEBUG: fillCurrentPageComprehensive complete');
      }

      // NEW: STEP 6 - Fill free-text fields (textAreaInput and other text inputs not covered above)
      function fillFreeTextFields() {
        console.log('DEBUG: Filling free-text fields...');
        document.querySelectorAll('textarea, input[type=\"text\"]').forEach(function(el) {
          if (el.disabled || el.readOnly) return;
          var id = el.id || '';
          // Skip demographics handled earlier
          if (id.indexOf('demo_') === 0) return;
          // Skip selectize controls
          if (el.className && el.className.indexOf('selectize-control') !== -1) return;
          var text = 'AutoText ' + Math.floor(Math.random()*1000) + ' ' + randomText(8);
          el.value = text;
          el.dispatchEvent(new Event('input', { bubbles: true }));
          el.dispatchEvent(new Event('change', { bubbles: true }));
          if (typeof Shiny !== 'undefined' && id) {
            Shiny.setInputValue(id, text);
          }
        });
      }

      function getNextButton() {
        var buttons = document.querySelectorAll('button');
        for (var i = 0; i < buttons.length; i++) {
          var btn = buttons[i];
          var text = btn.textContent.toLowerCase().trim();
          var id = (btn.id || '').toLowerCase();
          var className = (btn.className || '').toLowerCase();
          
          // Check button text content
          if (text.indexOf('next') !== -1 || text.indexOf('weiter') !== -1 || text.indexOf('submit') !== -1 || text.indexOf('senden') !== -1 || text.indexOf('continue') !== -1 || text.indexOf('fortfahren') !== -1 || text.indexOf('start') !== -1 || text.indexOf('beginnen') !== -1) {
            console.log('DEBUG: Found button by text: ' + text);
            return btn;
          }
          
          // Check button ID or class
          if (id.indexOf('next') !== -1 || id.indexOf('submit') !== -1 || id.indexOf('continue') !== -1 || className.indexOf('next') !== -1 || className.indexOf('submit') !== -1) {
            console.log('DEBUG: Found button by ID/class: ' + id);
            return btn;
          }
        }
        
        // Fallback: Look for any button that's visible and not disabled
        for (var i = 0; i < buttons.length; i++) {
          var btn = buttons[i];
          if (!btn.disabled && btn.offsetHeight > 0) {
            var text = btn.textContent.toLowerCase();
            // Skip buttons that should NOT trigger navigation
            if (text.indexOf('back') === -1 && 
                text.indexOf('zurück') === -1 && 
                text.indexOf('cancel') === -1 && 
                text.indexOf('abbrechen') === -1 &&
                text.indexOf('download') === -1 &&
                text.indexOf('herunterladen') === -1 &&
                text.indexOf('pdf') === -1 &&
                text.indexOf('speichern') === -1 &&
                text.indexOf('save') === -1 &&
                text.indexOf('print') === -1 &&
                text.indexOf('drucken') === -1) {
              console.log('DEBUG: Found visible button (fallback): ' + text);
              return btn;
            }
          }
        }
        
        return null;
      }

      function isReportPage() {
        var pageContent = document.getElementById('page_content') || document.body;
        var text = pageContent.textContent.toLowerCase();
        // Only return true if we see clear report/results indicators
        return (text.indexOf('result') !== -1 && (text.indexOf('score') !== -1 || text.indexOf('ability') !== -1 || text.indexOf('theta') !== -1)) ||
               text.indexOf('abgeschlossen') !== -1 || 
               (text.indexOf('thank') !== -1 && text.indexOf('complete') !== -1) ||
               text.indexOf('danke') !== -1;
      }

      function autoProgressAll(waitTime, transitionTime) {
        console.log('DEBUG: autoProgressAll started with waitTime=' + waitTime + ', transitionTime=' + transitionTime);
        
        function progressStep() {
          if (isReportPage()) {
            console.log('DEBUG: Report page reached - stopping');
                  return;
                }

          fillCurrentPageComprehensive();

                setTimeout(function() {
            var nextBtn = getNextButton();
            if (nextBtn) {
              console.log('DEBUG: Clicking next button');
              nextBtn.click();
              setTimeout(progressStep, transitionTime);
                    } else {
              console.log('DEBUG: No next button found - may be on report page');
                  }
                }, waitTime);
              }

        progressStep();
      }

      // Hotkey handlers
      document.addEventListener('keydown', function(e) {
        if (e.ctrlKey) {
          if (e.key === 'a' || e.key === 'A') {
            e.preventDefault();
            console.log('DEBUG: Ctrl+A pressed - filling current page ONLY (no next)');
            fillCurrentPageComprehensive();
          } else if (e.key === 'q' || e.key === 'Q') {
            e.preventDefault();
            console.log('DEBUG: Ctrl+Q pressed - auto-fill normal speed');
            autoProgressAll(800, 600);
          } else if (e.key === 'w' || e.key === 'W') {
          e.preventDefault();
            console.log('DEBUG: Ctrl+W pressed - auto-fill fast speed');
            autoProgressAll(300, 300);
          }
        }
      });

      console.log('DEBUG: Hotkey listeners registered');
    });
  ")))
}
