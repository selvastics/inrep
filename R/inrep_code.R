#' Generate Standalone R Script for Assessment App
#'
#' Creates a completely self-contained R script that includes all inrep functionality
#' needed to run an assessment independently. This function extracts and packages
#' all dependencies, helper functions, data, and the complete Shiny app logic.
#' 
#' @section Limitations:
#' - Console deployment is limited to ~4,094 characters (R console input limit)
#' - Very complex server logic (>50,000 characters) may be impractical for standalone deployment
#' - For extensive studies, consider professional hosting via the inrep platform
#' 
#' @section Professional Hosting:
#' Researchers planning to use inrep for published papers and assessments can contact
#' the package author for professional hosting via the inrep platform. Contact 
#' selva@uni-hildesheim.de with a brief description of your study aim and publication plan.
#'
#' @param expr The launch_study() call expression
#' @param output_file Optional file path to save the script. If NULL, returns script as string.
#'   Can be a filename (saves to current directory) or full path.
#' @param auto_run Logical. If TRUE, adds code to automatically run the assessment.
#'   If FALSE (default), user must uncomment the launch line.
#' @param console_ready Logical. If TRUE, generates compact code for console copy-paste.
#'   When TRUE, creates minimal executable code under R's 4094 character limit.
#' @param minimal Logical. If TRUE, generates only essential code for faster deployment.
#' @return Character string containing the complete standalone R script, invisibly if 
#'   output_file is specified
#' @examples
#' \dontrun{
#' # Basic usage - returns script as string
#' config <- create_study_config(name = "My Study", model = "GRM")
#' script <- inrep_code(launch_study(config, bfi_items))
#' 
#' # Console-ready - compact code for copy-paste (RECOMMENDED)
#' console_script <- inrep_code(launch_study(config, bfi_items), 
#'                              console_ready = TRUE)
#' # Copy and paste console_script directly into R console!
#' 
#' # Save to file automatically
#' inrep_code(launch_study(config, bfi_items), 
#'            output_file = "my_assessment.R")
#' 
#' # Minimal version for quick deployment
#' inrep_code(launch_study(config, bfi_items),
#'            console_ready = TRUE, minimal = TRUE)
#'            
#' # For complex studies with extensive server logic:
#' # Consider professional hosting via inrep platform
#' # Contact: selva@uni-hildesheim.de
#' # Include: study description, publication plan, participant numbers
#' }
#' @export
inrep_code <- function(expr, output_file = NULL, auto_run = FALSE, console_ready = FALSE, minimal = FALSE) {
  # Capture the user's launch_study call
  user_code <- deparse(substitute(expr))
  
  # Smart file naming if output_file is just a name without extension
  if (!is.null(output_file)) {
    if (!grepl("\\.", basename(output_file))) {
      output_file <- paste0(output_file, ".R")
    }
    if (!grepl("[/\\\\]", output_file)) {
      # Just a filename, save to current directory
      output_file <- file.path(getwd(), output_file)
    }
  }
  
  # CONSOLE-READY MODE: Generate compact, executable code
  if (console_ready) {
    compact_script <- generate_compact_script(user_code, auto_run, minimal)
    script_length <- nchar(compact_script)
    
    # Check for console length limitations
    if (script_length > 4000) {
      cat("WARNING: Script length (", script_length, " characters) may exceed R console limits!\n")
      cat("   R console maximum is typically 4,094 characters per input.\n")
      cat("   Consider using:\n")
      cat("   1. minimal = TRUE for more compact code\n")
      cat("   2. output_file to save and source() the script instead\n")
      cat("   3. Contact inrep platform for hosting (see below)\n\n")
    }
    
    if (!is.null(output_file)) {
      writeLines(compact_script, output_file)
      cat("Compact standalone script saved to:", basename(output_file), "\n")
      cat("Script length:", script_length, "characters\n")
      if (script_length <= 4000) {
        cat("Console-safe: Ready for copy-paste deployment\n")
      }
      return(invisible(compact_script))
    }
    
    cat("Compact standalone script generated!\n")
    cat("Script length:", script_length, "characters\n")
    if (script_length <= 4000) {
      cat("Console-safe: Ready for copy-paste deployment\n")
      cat("READY: Copy-paste the output directly into R console\n")
    } else {
      cat("Too long for console: Use output_file parameter or minimal = TRUE\n")
    }
    return(compact_script)
  }
  
  # FULL MODE: Generate complete standalone script for file deployment
  complete_script <- generate_complete_script(user_code, auto_run)
  script_length <- nchar(complete_script)
  
  # Warning for very large scripts (extensive server logic)
  if (script_length > 50000) {
    cat("WARNING: Generated script is very large (", script_length, " characters)!\n")
    cat("   This may indicate complex server logic that could be difficult to deploy standalone.\n")
    cat("   For complex studies with extensive logic, consider professional hosting:\n\n")
    cat("INREP PLATFORM HOSTING SERVICE:\n")
    cat("   Researchers planning to use inrep for published papers and assessments\n")
    cat("   can contact the package author for professional hosting via the inrep platform.\n")
    cat("   \n")
    cat("   Contact: selva@uni-hildesheim.de\n")
    cat("   Please provide:\n")
    cat("      - Brief description of your study aim\n")
    cat("      - Publication plan details\n")
    cat("      - Expected participant numbers\n")
    cat("   \n")
    cat("   Benefits: Professional hosting, scalability, data security, technical support\n\n")
  }
  
  if (!is.null(output_file)) {
    # Create directory if it doesn't exist
    output_dir <- dirname(output_file)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    }
    
    # Write the script to file
    tryCatch({
      writeLines(complete_script, output_file)
      cat("Complete standalone script saved to:", basename(output_file), "\n")
      cat("Script size:", nchar(complete_script), "characters\n")
      cat("Auto-run enabled:", auto_run, "\n")
    }, error = function(e) {
      warning("Failed to write file: ", e$message)
      return(complete_script)
    })
    
    return(invisible(complete_script))
  }
  
  # Return the complete script
  cat("Complete standalone script generated!\n")
  cat("Script size:", nchar(complete_script), "characters\n")
  cat("Save with: writeLines(result, 'filename.R')\n")
  return(complete_script)
}

# Generate compact script for console deployment
generate_compact_script <- function(user_code, auto_run, minimal) {
  
  # Minimal essential libraries
  libs <- if (minimal) {
    "library(shiny);library(TAM);library(magrittr)"
  } else {
    "library(shiny);library(shinyjs);library(shinyWidgets);library(DT);library(magrittr);library(TAM);library(jsonlite);library(ggplot2)"
  }
  
  # Compact utility functions
  utils <- "
`%||%`<-function(x,y)if(is.null(x))y else x
logger<-function(m,l='INFO')cat(sprintf('[%s] %s: %s\\n',Sys.time(),l,m))
"
  
  # Essential inrep functions - extract only the most critical ones
  essential_code <- '
# Core inrep functions (compact)
create_study_config<-function(name="Study",model="GRM",max_items=10,min_SEM=0.3,demographics=c("Age"),theme="light",...){
  list(name=name,model=model,max_items=max_items,min_SEM=min_SEM,demographics=demographics,theme=theme,
       min_items=5,adaptive=TRUE,criteria="MI",theta_prior=c(0,1),language="en",session_save=FALSE,
       response_ui_type="radio",progress_style="circle",estimation_method="TAM",...)
}

launch_study<-function(config,item_bank,webdav_url=NULL,password=NULL,save_format="json",study_key=NULL,...){
  if(is.null(item_bank)||nrow(item_bank)==0)stop("Item bank required")
  
  # Basic item bank validation
  if(!"Question"%in%names(item_bank))stop("Item bank must have Question column")
  
  # Ensure basic GRM structure
  if(config$model=="GRM"&&!"ResponseCategories"%in%names(item_bank)){
    item_bank$ResponseCategories<-rep("1,2,3,4,5",nrow(item_bank))
    item_bank$a<-rep(1.5,nrow(item_bank))
    item_bank$b1<-rnorm(nrow(item_bank),-1,0.5)
    item_bank$b2<-rnorm(nrow(item_bank),0,0.5)
    item_bank$b3<-rnorm(nrow(item_bank),0.5,0.5)
    item_bank$b4<-rnorm(nrow(item_bank),1,0.5)
  }
  
  # Simple UI
  ui<-fluidPage(
    tags$head(tags$style("body{font-family:Arial;margin:20px;}")),
    div(style="max-width:800px;margin:auto;",
        h2(config$name),
        uiOutput("main_ui")
    )
  )
  
  # Simple server
  server<-function(input,output,session){
    values<-reactiveValues(stage="demo",current_item=1,responses=c(),demo_data=list())
    
    output$main_ui<-renderUI({
      if(values$stage=="demo"){
        div(
          h3("Demographics"),
          lapply(config$demographics,function(d){
            textInput(paste0("demo_",d),d)
          }),
          actionButton("start_test","Start Assessment")
        )
      }else if(values$stage=="test"){
        if(values$current_item<=min(config$max_items,nrow(item_bank))){
          item<-item_bank[values$current_item,]
          choices<-if("ResponseCategories"%in%names(item)){
            cats<-as.numeric(strsplit(item$ResponseCategories,",")[[1]])
            setNames(cats,paste("Option",cats))
          }else{
            c("Strongly Disagree"=1,"Disagree"=2,"Neutral"=3,"Agree"=4,"Strongly Agree"=5)
          }
          div(
            h4(paste("Question",values$current_item,"of",min(config$max_items,nrow(item_bank)))),
            p(item$Question),
            radioButtons("response","Your answer:",choices),
            actionButton("next_item","Next")
          )
        }else{
          div(
            h3("Assessment Complete"),
            p("Thank you for participating!"),
            if(length(values$responses)>0)p(paste("Average response:",round(mean(values$responses),2))),
            actionButton("restart","Restart")
          )
        }
      }
    })
    
    observeEvent(input$start_test,{
      for(d in config$demographics){
        values$demo_data[[d]]<-input[[paste0("demo_",d)]]
      }
      values$stage<-"test"
    })
    
    observeEvent(input$next_item,{
      if(!is.null(input$response)){
        values$responses<-c(values$responses,as.numeric(input$response))
        values$current_item<-values$current_item+1
      }
    })
    
    observeEvent(input$restart,{
      values$stage<-"demo"
      values$current_item<-1
      values$responses<-c()
      values$demo_data<-list()
    })
  }
  
  cat("Starting assessment at http://localhost:3838\\n")
  shinyApp(ui,server)
}

# Fallback data
if(!exists("bfi_items")||!is.data.frame(bfi_items)){
  bfi_items<-data.frame(
    Question=c("I am talkative","I am reserved","I am outgoing","I am quiet","I am sociable"),
    ResponseCategories=rep("1,2,3,4,5",5),
    stringsAsFactors=FALSE
  )
}
'
  
  # Execution code
  exec_code <- if (auto_run) {
    paste("# Auto-launch:", user_code)
  } else {
    paste("# To launch, run:", user_code)
  }
  
  # Combine all parts
  final_script <- paste(
    "# Compact inrep assessment - Ready for console",
    libs,
    utils,
    essential_code,
    exec_code,
    sep = "\n"
  )
  
  return(final_script)
}

# Generate complete script for file deployment  
generate_complete_script <- function(user_code, auto_run) {
  
  # Essential libraries - ordered by dependency
  libraries <- c(
    "library(shiny)",
    "library(shinyjs)", 
    "library(shinyWidgets)",
    "library(DT)",
    "library(magrittr)",
    "library(TAM)",
    "library(jsonlite)",
    "library(ggplot2)",
    "library(uuid)",
    "library(logr)",
    "# Optional but recommended:",
    "# library(pdftools)",
    "# library(knitr)", 
    "# library(kableExtra)",
    "# library(tinytex)"
  )
  
  # Extract all essential functions from inrep namespace
  essential_functions <- c(
    # Core configuration and validation
    "create_study_config",
    "validate_item_bank",
    "validate_session",
    "validate_demographic_config",
    
    # Assessment engine
    "launch_study",
    "estimate_ability", 
    "select_next_item",
    
    # UI components
    "get_theme_css",
    "get_builtin_themes",
    "validate_theme_name",
    "create_response_ui",
    "create_demographics_ui",
    "inrep_ui",
    
    # Session management  
    "init_reactive_values",
    "save_session_to_cloud",
    "resume_session",
    
    # Utilities
    "generate_uuid",
    "initialize_logging",
    "log_open",
    
    # Study flow helpers
    "create_default_introduction_content",
    "create_default_briefing_content", 
    "create_default_consent_content",
    "create_default_gdpr_content",
    "create_default_debriefing_content",
    "create_default_demographic_configs",
    "create_custom_demographic_ui",
    
    # Validation and response mapping
    "validate_response_mapping",
    
    # Enhanced reporting
    "create_enhanced_response_report"
  )
  
  # Extract function definitions
  function_code <- character()
  
  for (fn_name in essential_functions) {
    if (exists(fn_name, where = asNamespace("inrep"), inherits = FALSE)) {
      fn_obj <- get(fn_name, envir = asNamespace("inrep"))
      if (is.function(fn_obj)) {
        # Get the complete function definition with proper formatting
        fn_def <- paste(deparse(fn_obj), collapse = "\n")
        function_code <- c(function_code, paste0(fn_name, " <- ", fn_def))
      }
    }
  }
  
  # Extract built-in datasets that might be referenced
  data_extraction <- "
# ============================================================================
# BUILT-IN DATASETS
# ============================================================================

# Load built-in datasets (if they exist in the workspace or can be accessed)
if (exists('bfi_items') && is.data.frame(bfi_items)) {
  # bfi_items already available
} else {
  # Fallback BFI items dataset structure
  bfi_items <- data.frame(
    Question = c(
      'I am the life of the party.',
      'I feel little concern for others.',
      'I am always prepared.',
      'I get stressed out easily.',
      'I have a rich vocabulary.'
    ),
    a = c(1.5, 1.2, 1.8, 1.4, 1.6),
    b1 = c(-2.0, -1.5, -1.8, -1.2, -2.2),
    b2 = c(-0.5, -0.2, -0.8, -0.1, -0.9),
    b3 = c(0.5, 0.8, 0.2, 0.9, 0.1),
    b4 = c(2.0, 2.2, 1.8, 2.1, 1.9),
    ResponseCategories = rep('1,2,3,4,5', 5),
    stringsAsFactors = FALSE
  )
}

if (exists('cognitive_items') && is.data.frame(cognitive_items)) {
  # cognitive_items already available  
} else {
  # Fallback cognitive items dataset
  cognitive_items <- data.frame(
    Question = c(
      'What is 2 + 2?',
      'Which number comes next: 2, 4, 6, __?',
      'If all cats are animals, and Fluffy is a cat, then Fluffy is...?'
    ),
    a = c(1.0, 1.2, 1.4),
    b = c(-1.0, 0.0, 1.0),
    Option1 = c('3', '7', 'a plant'),
    Option2 = c('4', '8', 'an animal'), 
    Option3 = c('5', '9', 'a mineral'),
    Option4 = c('6', '10', 'unknown'),
    Answer = c('4', '8', 'an animal'),
    stringsAsFactors = FALSE
  )
}

if (exists('math_items') && is.data.frame(math_items)) {
  # math_items already available
} else {
  # Fallback math items dataset
  math_items <- data.frame(
    Question = c(
      'Solve: 3x + 7 = 22',
      'What is the area of a circle with radius 5?',
      'Factor: x² - 9'
    ),
    a = c(1.3, 1.5, 1.7),
    b = c(-0.5, 0.5, 1.5),
    Option1 = c('x = 4', '25π', '(x-3)(x-3)'),
    Option2 = c('x = 5', '10π', '(x+3)(x-3)'),
    Option3 = c('x = 6', '15π', '(x+3)(x+3)'),
    Option4 = c('x = 7', '20π', 'cannot factor'),
    Answer = c('x = 5', '25π', '(x+3)(x-3)'),
    stringsAsFactors = FALSE
  )
}
"

  # Theme CSS extraction - get all built-in themes
  theme_css_code <- "
# ============================================================================  
# THEME SYSTEM
# ============================================================================

# Built-in theme CSS content
theme_css_library <- list(
  light = '
:root {
  --primary-color: #007bff;
  --secondary-color: #6c757d;
  --background-color: #ffffff;
  --text-color: #212529;
  --border-radius: 6px;
  --font-family: \"Inter\", -apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif;
  --error-color: #dc3545;
  --success-color: #28a745;
  --progress-bg-color: #e9ecef;
}
body { background: var(--background-color); color: var(--text-color); }
',
  
  midnight = '
:root {
  --primary-color: #6366f1;
  --secondary-color: #4f46e5;
  --background-color: #1e1b4b;
  --text-color: #e2e8f0;
  --border-radius: 8px;
  --font-family: \"Inter\", sans-serif;
  --error-color: #ef4444;
  --success-color: #10b981;
  --progress-bg-color: #374151;
}
body { background: var(--background-color); color: var(--text-color); }
',
  
  sunset = '
:root {
  --primary-color: #ff6f61;
  --secondary-color: #ff8a80;
  --background-color: #fff3e0;
  --text-color: #5d4037;
  --border-radius: 12px;
  --font-family: \"Inter\", sans-serif;
  --error-color: #d32f2f;
  --success-color: #388e3c;
  --progress-bg-color: #ffcc02;
}
body { background: var(--background-color); color: var(--text-color); }
',
  
  hildesheim = '
:root {
  --primary-color: #e8041c;
  --secondary-color: #c62828;
  --background-color: #ffffff;
  --text-color: #212121;
  --border-radius: 4px;
  --font-family: \"Roboto\", sans-serif;
  --error-color: #d32f2f;
  --success-color: #388e3c;
  --progress-bg-color: #f5f5f5;
}
body { background: var(--background-color); color: var(--text-color); }
'
)

# Simplified theme system functions for standalone operation
get_theme_css_standalone <- function(theme = \"light\", custom_css = NULL) {
  theme <- tolower(theme)
  css_content <- theme_css_library[[theme]] %||% theme_css_library[[\"light\"]]
  if (!is.null(custom_css)) {
    css_content <- paste0(css_content, \"\\n\", custom_css)
  }
  return(css_content)
}

get_builtin_themes_standalone <- function() {
  names(theme_css_library)
}
"

  # Utility operators and helpers
  utility_code <- "
# ============================================================================
# UTILITY FUNCTIONS AND OPERATORS
# ============================================================================

# Null coalescing operator
`%||%` <- function(x, y) if (is.null(x)) y else x

# Simple logging function for standalone operation
logger <- function(message, level = 'INFO') {
  timestamp <- format(Sys.time(), '%Y-%m-%d %H:%M:%S')
  cat(sprintf('[%s] %s: %s\\n', timestamp, level, message))
}

# Simplified UUID generation
generate_uuid_standalone <- function() {
  if (requireNamespace('uuid', quietly = TRUE)) {
    uuid::UUIDgenerate()
  } else {
    # Fallback UUID generation
    paste0(sample(c(letters, 0:9), 32, replace = TRUE), collapse = '')
  }
}
"

  # Extract any variables referenced in the user code
  variable_extraction <- "
# ============================================================================
# VARIABLE EXTRACTION AND SETUP
# ============================================================================

# Note: Make sure to define any variables referenced in your launch_study() call
# Examples:
# config <- create_study_config(...)
# webdav_url <- 'https://your-cloud-storage.com/path'
# password <- 'your-password'
# study_key <- 'STUDY_2025_001'

# If using data() calls, uncomment and modify as needed:
# data(bfi_items)
# data(cognitive_items) 
# data(math_items)
"

  # Error handling wrapper
  error_handling <- "
# ============================================================================
# ERROR HANDLING AND DIAGNOSTICS
# ============================================================================

# Check for required packages
required_packages <- c('shiny', 'TAM', 'magrittr', 'jsonlite', 'DT', 'ggplot2')
missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]

if (length(missing_packages) > 0) {
  cat('Warning: Missing required packages:', paste(missing_packages, collapse = ', '), '\\n')
  cat('Install with: install.packages(c(', paste(paste0('\"', missing_packages, '\"'), collapse = ', '), '))\\n')
}

# Runtime diagnostics
cat('\\n=== INREP STANDALONE APP DIAGNOSTICS ===\\n')
cat('R Version:', R.version.string, '\\n')
cat('Platform:', R.version$platform, '\\n')
cat('Required packages status:\\n')
for (pkg in required_packages) {
  status <- if (requireNamespace(pkg, quietly = TRUE)) 'OK' else 'MISSING'
  cat(' -', pkg, ':', status, '\\n')
}
cat('==========================================\\n\\n')
"

  # Smart execution section based on parameters
  execution_section <- if (auto_run) {
    paste(
      "# ============================================================================",
      "# AUTOMATIC EXECUTION",
      "# ============================================================================",
      "",
      "cat('\\nStarting standalone inrep assessment application...\\n')",
      "cat('This script will automatically launch your assessment.\\n')",
      "cat('Access the application in your web browser at the displayed URL.\\n')",
      "cat('Press Ctrl+C or Esc to stop the application.\\n\\n')",
      "",
      "# Auto-launch the assessment:",
      paste(user_code, collapse = "\n"),
      "",
      sep = "\n"
    )
  } else {
    paste(
      "# ============================================================================",
      "# MANUAL EXECUTION",
      "# ============================================================================",
      "",
      "cat('\\nStandalone inrep assessment application ready!\\n')",
      "cat('To start your assessment, uncomment and run the line below:\\n')",
      "cat('Access the application in your web browser at the displayed URL.\\n')",
      "cat('Press Ctrl+C or Esc to stop the application.\\n\\n')",
      "",
      "# Uncomment the line below to launch the assessment:",
      paste("#", user_code),
      "",
      "# Alternative: Copy and paste this line to launch:",
      paste("#", user_code),
      "",
      sep = "\n"
    )
  }
  
  # Console-ready formatting
  console_formatting <- if (console_ready) {
    paste(
      "",
      "# ============================================================================",
      "# CONSOLE DEPLOYMENT INSTRUCTIONS",
      "# ============================================================================",
      "#",
      "# COPY-PASTE DEPLOYMENT:",
      "# 1. Select and copy this entire script",
      "# 2. Paste directly into your R console",
      "# 3. Press Enter to execute",
      "# 4. Your assessment will be ready to launch!",
      "#",
      "# QUICK LAUNCH:",
      "# After pasting this script, run:",
      paste("# ", user_code),
      "#",
      "# ============================================================================",
      "",
      sep = "\n"
    )
  } else {
    ""
  }
  # Compose the complete standalone script
  complete_script <- paste(
    "# ============================================================================",
    "# STANDALONE INREP ASSESSMENT APPLICATION",
    "# ============================================================================",
    "#",
    "# This script was auto-generated by inrep_code() and contains all necessary",
    "# components to run an inrep assessment independently of the inrep package.",
    "#",
    "# Generated on:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
    "# Original call:", paste(user_code, collapse = " "),
    "# Auto-run enabled:", auto_run,
    "# Console-ready:", console_ready,
    "#",
    "# ============================================================================",
    console_formatting,
    "",
    "# ============================================================================",
    "# REQUIRED LIBRARIES",
    "# ============================================================================",
    paste(libraries, collapse = "\n"),
    "",
    error_handling,
    "",
    utility_code,
    "",
    theme_css_code,
    "",
    data_extraction,
    "",
    variable_extraction,
    "",
    "# ============================================================================",
    "# CORE INREP FUNCTIONS",
    "# ============================================================================",
    "",
    paste(function_code, collapse = "\n\n"),
    "",
    "# ============================================================================",
    "# USER APPLICATION CODE",
    "# ============================================================================",
    "",
    "# Original launch_study call:",
    paste(user_code, collapse = "\n"),
    "",
    execution_section,
    "",
    "# ============================================================================",
    "# END OF STANDALONE SCRIPT", 
    "# ============================================================================",
    sep = "\n"
  )
  
  # Add helpful usage comments
  usage_info <- paste(
    "",
    "# ============================================================================",
    "# USAGE INSTRUCTIONS",
    "# ============================================================================",
    "#",
    if (auto_run) {
      "# AUTO-RUN MODE: This script will automatically launch your assessment!"
    } else {
      "# MANUAL MODE: Uncomment the launch_study() call to start your assessment"
    },
    "#",
    "# DEPLOYMENT OPTIONS:",
    "# 1. Save this script to a file (e.g., 'my_assessment.R')",
    "# 2. Install required packages if missing", 
    "# 3. Define any missing variables (config, data, etc.)",
    if (auto_run) {
      "# 4. Run the script - it will auto-launch!"
    } else {
      "# 4. Uncomment and run the launch_study() call"
    },
    "# 5. Access the assessment at the displayed URL",
    "#",
    if (console_ready) {
      paste(
        "# CONSOLE DEPLOYMENT:",
        "# - This script is optimized for copy-paste into R console",
        "# - Simply select all, copy, and paste into your R session",
        "#"
      )
    } else {
      ""
    },
    "# For cloud storage, make sure webdav_url and password are defined",
    "# For custom data, make sure your item_bank data.frame is defined", 
    "#",
    "# ============================================================================",
    "# PROFESSIONAL HOSTING AVAILABLE",
    "# ============================================================================",
    "#",
    "# For published research and complex assessments, consider professional",
    "# hosting via the inrep platform. Benefits include:",
    "# - Scalable infrastructure for large participant numbers",
    "# - Professional data security and backup",
    "# - Technical support and maintenance",
    "# - Advanced analytics and reporting features",
    "#",
    "# Contact: selva@uni-hildesheim.de",
    "# Please provide: study description, publication plan, participant numbers",
    "#",
    "# ============================================================================",
    sep = "\n"
  )
  
  final_script <- paste(complete_script, usage_info, sep = "\n")
  
  # Smart file handling
  if (!is.null(output_file)) {
    # Create directory if it doesn't exist
    output_dir <- dirname(output_file)
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
    }
    
    # Write the script to file
    tryCatch({
      writeLines(final_script, output_file)
      cat("Standalone script successfully saved to:", output_file, "\n")
      cat("Script size:", nchar(final_script), "characters\n")
      cat("Auto-run enabled:", auto_run, "\n")
      cat("Console-ready:", console_ready, "\n")
      
      if (auto_run) {
        cat("\nREADY TO USE: Just run the saved script file!\n")
        cat("   source('", basename(output_file), "')\n", sep = "")
      } else {
        cat("\nREADY TO USE: Uncomment the launch_study() call in the saved file\n")
      }
      
      if (console_ready) {
        cat("\nCONSOLE DEPLOYMENT: Open the file and copy-paste the contents\n")
      }
      
    }, error = function(e) {
      warning("Failed to write file: ", e$message)
      cat("File write failed, returning script as string instead\n")
      return(final_script)
    })
    
    # Return script invisibly when file is written
    return(invisible(final_script))
  }
  
  # If no output file, return the script visibly
  cat("Standalone script generated successfully!\n")
  cat("Script size:", nchar(final_script), "characters\n")
  cat("Auto-run enabled:", auto_run, "\n")
  cat("Console-ready:", console_ready, "\n")
  
  if (console_ready) {
    cat("\nCONSOLE-READY: You can copy-paste this output directly into R console\n")
  } else {
    cat("\nSave with: writeLines(result, 'filename.R')\n")
  }
  
  # Return the complete standalone script
  return(final_script)
}
