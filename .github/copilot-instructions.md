# inrep: AI Coding Agent Instructions

## Project Overview

**inrep** (Instant Reports for Adaptive Assessments) is an R package providing a Shiny-based framework for adaptive psychological assessments using Item Response Theory (IRT). This is a "vibe coding project" where LLM-assisted development has expanded core functionality—code is functional but actively being refined.

**Critical Distinction**: inrep is a **workflow orchestration layer**, not a psychometric engine. All IRT computations (ability estimation, item selection, model fitting) are performed by the **TAM package**. inrep provides Shiny UI, session management, and integration capabilities.

## Architecture: The Three-Layer System

### 1. Configuration Layer (`create_study_config()`)
- **R/create_study_config.R** (931 lines): Creates config objects controlling assessment behavior
- Sets adaptive vs. non-adaptive mode (`adaptive = TRUE/FALSE`)
- Defines IRT model, stopping rules, demographics, themes, language
- Config objects are immutable blueprints passed to `launch_study()`

### 2. Execution Layer (`launch_study()`)
- **R/launch_study.R** (6157 lines): Monolithic Shiny app function—intentionally kept large for LLM convenience
- **Why one giant function?** "You can more easily pass this entire function to an LLM to customize a specific study"
- Creates reactive values object (`rv`) for session state management
- Orchestrates UI stages: introduction → consent → demographics → assessment → results
- Handles TAM integration, session recovery, WebDAV cloud storage

### 3. Psychometric Layer (TAM Integration)
- **R/estimate_ability.R**: Interfaces with `TAM::tam.mml()`, `TAM::tam.wle()`, `TAM::tam.eap()`
- **R/item_selection.R**: Uses TAM's `IRT.informationCurves()` for adaptive item selection
- Selection criteria: MI (Maximum Information), WEIGHTED, RANDOM, MFI
- **Never implement IRT math directly—always delegate to TAM**

## Critical State Management Pattern

The `rv` (reactive values) object is the **central nervous system**:

```r
rv$responses         # Item responses vector
rv$administered      # Vector of administered item indices
rv$current_ability   # Ability estimate from TAM
rv$ability_se        # Standard error
rv$stage             # Current stage (e.g., "assessment", "results")
rv$current_page      # Page counter
rv$demo_data         # Demographics list
rv$page_selected_items  # Cache for adaptive item selection
```

**Key Pattern**: Adaptive item selection stores selections in `rv$page_selected_items[[page_id]]` to ensure response collection maps to correct items even after page navigation.

## Adaptive vs. Non-Adaptive Mode

**Adaptive (`adaptive = TRUE`)**:
- Items selected dynamically via `select_next_item(rv, item_bank, config)`
- Uses TAM ability estimates to maximize information
- Requires TAM package loaded
- Stopping rules: `min_SEM`, `max_items`, `min_items`

**Non-Adaptive (`adaptive = FALSE`)**:
- Sequential item presentation: items 1 through `max_items`
- Traditional fixed questionnaire format
- No TAM dependency (but can still use TAM for post-hoc analysis)
- Example: `config <- create_study_config(adaptive = FALSE, max_items = 5)`

## Development Workflows

### Testing Studies
```r
# Load and run a study
library(inrep)
source('case_studies/hildesheim_study/HilFo.R')
```

**Debug Mode** (`debug_mode = TRUE`):
- Keyboard shortcuts: `Ctrl+A` (fill current page), `Ctrl+Q` (auto-fill normal), `Ctrl+Y` (auto-fill fast)
- Red debug indicator appears bottom-right
- **R/debugmode.R** generates client-side JavaScript for auto-filling
- **Only for development—never enable in production**

### Package Development
```r
# Standard R package workflow
devtools::load_all()
devtools::test()         # No tests currently—package lacks test suite
devtools::check()
devtools::document()     # Roxygen2 for documentation
```

### Building and Installation
```r
# Clean install from GitHub
devtools::install_github("selvastics/inrep", ref = "main", force = TRUE)
```

## Theme System

**Built-in themes**: Professional, Midnight, Sunset, Forest, Ocean, Berry, Light
**Location**: `inst/themes/` contains CSS files

**Three customization approaches**:
1. Use built-in: `theme = "Professional"`
2. Theme config: `theme_config = list(primary_color = "#2a5db0", ...)`
3. Custom CSS: `custom_css = "body { ... }"`

**University branding example**: `theme = "hildesheim"` loads custom university theme

## Case Studies as Implementation Guides

**case_studies/** contains complete working examples:
- `hildesheim_study/HilFo.R`: Complex custom study with branching logic, custom item selection, results processing
- `programming_anxiety_assessment/`: Domain-specific assessment example
- `rcq/`: Research Confidence Questionnaire implementation

**Pattern**: Case studies often define custom functions like `custom_item_selection()` that override default behavior—see `study_management.R` lines 1687-1702 for detection pattern.

## Session Recovery and Cloud Storage

**Session save/resume**:
- Enabled via `session_save = TRUE` in config
- Auto-saves every `data_preservation_interval` seconds (default: 30)
- Resume via `resume_session()` function

**WebDAV cloud storage**:
```r
launch_study(config, item_bank,
  webdav_url = "https://sync.academiccloud.de/index.php/s/YourFolder/",
  password = Sys.getenv("WEBDAV_PASSWORD")
)
```
- Exports CSV/JSON/PDF/RDS formats
- **Security**: Store credentials in environment variables

## Important Conventions

### Response Collection Pattern
```r
# For adaptive items, ALWAYS cache selected item
page_id <- paste0("page_", rv$current_page)
rv$page_selected_items[[page_id]] <- selected_item

# Later, retrieve for response collection
item_index <- rv$page_selected_items[[page_id]]
rv$responses[item_index] <- user_response
```

**CRITICAL**: When rendering adaptive items, preserve actual item bank row indices:
- UI creation uses `item$id` from item_bank
- Adaptive selection creates single-row dataframes via `item_bank[selected_item, , drop=FALSE]`
- Rownames must be preserved to map loop index → actual item bank index
- Without this, input IDs become `item_1` instead of `item_PA_15`, breaking response collection

### Item Bank Structure
Must contain columns matching IRT model:
- **1PL/Rasch**: `Question`, `b`
- **2PL**: `Question`, `a`, `b`
- **3PL**: `Question`, `a`, `b`, `c`
- **GRM**: `Question`, `a`, `b1`, `b2`, ..., `ResponseCategories`

### Multilingual Support
- **R/language_labels.R**: Translation dictionaries for UI text
- Supported: English (en), German (de), Spanish (es), French (fr)
- Use `rv$language` to track current language

## File Structure Reference

```
R/
  launch_study.R           # 6157 lines - main Shiny app
  create_study_config.R    # Configuration builder
  item_selection.R         # Adaptive selection via TAM
  estimate_ability.R       # TAM ability estimation interface
  study_management.R       # Page rendering, navigation
  debugmode.R             # Dev keyboard shortcuts
  theme_system.R          # Theme management
  robust_session.R        # Session recovery logic

case_studies/            # Complete working examples
inst/themes/            # Built-in CSS themes
data/                   # Example item banks (.rda files)
```

## Common Pitfalls

1. **Don't implement IRT math**—always use TAM functions
2. **Monolithic `launch_study()`**—edit in place, don't refactor yet (intentional design)
3. **Adaptive item caching**—must store `rv$page_selected_items` or responses map incorrectly
4. **TAM dependency**—only required when `adaptive = TRUE` or doing post-hoc IRT analysis
5. **Debug mode in production**—never enable `debug_mode` in real studies
6. **Non-adaptive is sequential**—`adaptive = FALSE` just shows items 1 to `max_items` in order
7. **Debug mode timing**—Ctrl+Q can fill items before Shiny binds handlers; use Ctrl+A per page for adaptive items
8. **Reactive updates in renderUI**—NEVER update `rv` inside `renderUI()`, use `session$userData` for non-reactive state

## Getting Help

- **Documentation**: All functions have Roxygen2 docs with extensive examples
- **Case studies**: Reference `case_studies/` for real-world patterns
- **README disclaimer**: "vibe coding project"—code is functional but being refined
- **Issues**: Report bugs at https://github.com/selvastics/inrep/issues

## Quick Reference Commands

```r
# Create and launch basic study
library(inrep)
data(bfi_items)
config <- create_study_config(name = "Test Study", adaptive = TRUE, max_items = 10)
launch_study(config, bfi_items, debug_mode = TRUE)

# Non-adaptive questionnaire
config <- create_study_config(adaptive = FALSE, max_items = 5)
launch_study(config, bfi_items)

# Install from source
devtools::install_github("selvastics/inrep")
```
