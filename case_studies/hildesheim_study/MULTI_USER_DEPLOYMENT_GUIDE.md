# Multi-User Deployment Guide for HilFo Study on shinyapps.io

## 🚨 CRITICAL ISSUES FOR MULTI-USER DEPLOYMENT

### Problem 1: Global Variable Conflicts
**Current Issue:** The code uses `assign(..., envir = .GlobalEnv)` which causes user interference:
- User A switches to English → changes global variables
- User B (on German) suddenly sees English content!

**Location in code:**
```r
# Lines causing issues:
assign("all_items", updated_items, envir = .GlobalEnv)
assign("demographic_configs", updated_demographics, envir = .GlobalEnv)  
assign("custom_page_flow", updated_page_flow, envir = .GlobalEnv)
```

### Problem 2: Session Isolation
**Current Issue:** Multiple users share the same global state

**Solution Required:**
```r
# INSTEAD OF:
assign("all_items", updated_items, envir = .GlobalEnv)

# USE:
session$userData$all_items <- updated_items
```

### Problem 3: File Naming Conflicts
**Current Issue:** Files named with timestamp only - collision risk!

**Solution Required:**
```r
# Add unique session ID to filename:
session_id <- paste0(
  format(Sys.time(), "%Y%m%d_%H%M%S"),
  "_",
  paste0(sample(c(letters, 0:9), 8, replace = TRUE), collapse = "")
)
filename <- paste0("hilfo_results_", session_id, ".csv")
```

## ✅ REQUIRED CHANGES FOR MULTI-USER SUPPORT

### 1. Replace ALL Global Variables with Session Storage

```r
server_extensions <- function(input, output, session) {
  # Initialize session-specific data
  session$userData$item_bank <- all_items_de
  session$userData$demographic_configs <- demographic_configs
  session$userData$custom_page_flow <- custom_page_flow
  session$userData$current_language <- "de"
  session$userData$session_id <- paste0(
    "SESS_",
    format(Sys.time(), "%Y%m%d_%H%M%S"),
    "_",
    paste0(sample(letters, 6), collapse = "")
  )
  
  # Language switching - NO global assignments!
  observeEvent(input$study_language, {
    new_lang <- input$study_language
    session$userData$current_language <- new_lang
    
    if (new_lang == "en") {
      # Update session-specific data
      session$userData$item_bank$Question <- all_items_de$Question_EN
      # Update demographics...
      # Update page flow...
    }
    
    # Force UI refresh
    session$reload()
  })
}
```

### 2. Pass Session to Results Processor

```r
create_hilfo_report <- function(responses, item_bank, demographics = NULL, session = NULL) {
  # Get session-specific data
  current_lang <- if (!is.null(session)) {
    session$userData$current_language %||% "de"
  } else {
    "de"
  }
  
  session_id <- if (!is.null(session)) {
    session$userData$session_id
  } else {
    paste0("NOSESS_", format(Sys.time(), "%Y%m%d_%H%M%S"))
  }
  
  # Use session_id in file naming
  filename <- paste0("hilfo_results_", session_id, ".csv")
}
```

### 3. Configure inrep for Multi-User

```r
study_config <- create_study_config(
  # ... existing config ...
  
  # Add session management
  session_management = TRUE,
  session_timeout = 7200,
  
  # Ensure proper isolation
  use_global_env = FALSE,  # CRITICAL!
  
  # Pass session to processors
  results_processor = function(responses, item_bank, demographics = NULL) {
    # Get current session from parent frame
    session <- get("session", envir = parent.frame())
    create_hilfo_report(responses, item_bank, demographics, session)
  }
)
```

## 📊 SHINYAPPS.IO DEPLOYMENT CONSIDERATIONS

### Resource Requirements for 10 Concurrent Users:
- **Memory:** ~1GB RAM (100MB per user)
- **Plan:** At least Basic tier (1GB RAM, 25 active hours)
- **Recommended:** Standard tier for production

### Instance Configuration:
```r
# In app.R or global.R
options(
  shiny.maxRequestSize = 30*1024^2,  # 30MB max upload
  shiny.sanitize.errors = TRUE,      # Hide internal errors
  shiny.reactlog = FALSE             # Disable for performance
)
```

### Monitoring Setup:
1. Enable application logs in shinyapps.io dashboard
2. Monitor concurrent connections
3. Track memory usage
4. Set up alerts for errors

## 🧪 TESTING MULTI-USER SCENARIOS

### Test Script:
```bash
# 1. Deploy to shinyapps.io
rsconnect::deployApp()

# 2. Open multiple browser sessions (different browsers/incognito)
# 3. Test simultaneously:
#    - User 1: Complete in German
#    - User 2: Switch to English, complete
#    - User 3: Start German, switch to English mid-way
#    - User 4-10: Random combinations

# 4. Verify:
#    - Each user's data file is unique
#    - Language settings don't interfere
#    - No data mixing in cloud storage
```

### Expected Behavior:
- ✅ Each user has independent session
- ✅ Language changes affect only that user
- ✅ Data files have unique names
- ✅ Cloud uploads don't conflict
- ✅ No performance degradation up to 10 users

## 🔒 SECURITY CONSIDERATIONS

1. **Session Hijacking Prevention:**
   - Use HTTPS only (shinyapps.io provides this)
   - Implement session tokens if needed

2. **Data Privacy:**
   - Each session's data is isolated
   - No cross-user data access
   - Secure WebDAV credentials

3. **Rate Limiting:**
   - Consider implementing submission limits
   - Prevent spam/abuse

## 📝 IMPLEMENTATION CHECKLIST

- [ ] Remove ALL `assign(..., envir = .GlobalEnv)` calls
- [ ] Replace with `session$userData$...` storage
- [ ] Add unique session IDs to all filenames
- [ ] Test with 10 concurrent users
- [ ] Monitor resource usage
- [ ] Configure appropriate shinyapps.io tier
- [ ] Set up error logging
- [ ] Document deployment process

## 🚀 DEPLOYMENT COMMAND

```r
# Clean deployment
rsconnect::deployApp(
  appDir = ".",
  appFiles = c("use_this.R"),
  appName = "hilfo-study",
  account = "your-account",
  server = "shinyapps.io",
  forceUpdate = TRUE
)
```

## ⚠️ CRITICAL: DO NOT DEPLOY UNTIL:
1. All global variables are removed
2. Session isolation is implemented
3. Multi-user testing is complete
4. Resource requirements are verified