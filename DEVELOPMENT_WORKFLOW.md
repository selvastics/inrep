# HilFo Study Development Workflow

## Memory Knowledge Graph Workflow (REQUIRED)

### MANDATORY RETRIEVAL WORKFLOW:
1. **At the START of every task**: SEARCH memory for related concepts
   - Use specific terms related to your task (e.g., "search_nodes({'query': 'language switching'})")
   - Include in your thinking: "Memory shows: [key findings]"
2. **Before EACH implementation step**: VERIFY current understanding
   - Check if memory contains relevant information for your current subtask
3. **Before answering questions**: CHECK memory FIRST
   - Always prioritize memory over other research methods

### MANDATORY UPDATE WORKFLOW:
1. **After LEARNING** about codebase structure
2. **After IMPLEMENTING** new features or modifications
3. **After DISCOVERING** inconsistencies between memory and code
4. **After USER** shares new information about project patterns

### UPDATE ACTIONS:
- **CREATE/UPDATE** entities for components/concepts
- **ADD** atomic, factual observations (15 words max)
- **DELETE** outdated observations when information changes
- **CONNECT** related entities with descriptive relation types
- **CONFIRM** in your thinking: "Memory updated: [summary]"

### MEMORY QUALITY RULES:
- **Entities** = Components, Features, Patterns, Practices (with specific types)
- **Observations** = Single, specific facts about implementation details
- **Relations** = Use descriptive types (contains, uses, implements)
- **AVOID** duplicates by searching before creating new entries
- **MAINTAIN** high-quality, factual knowledge

## HilFo Study Technical Architecture

### Core Components

#### 1. Language Switching System
- **Type**: Client-side JavaScript system
- **Location**: Page 1 (main), Page 20 (personal code), Page 21 (results)
- **State Management**: `window.hilfoLanguage` (de/en)
- **Event System**: `languageChanged` custom event
- **Functions**: `toggleLanguage()`, `updateLanguageUI()`, `applyLanguageToPage20()`

#### 2. Study Configuration
- **Framework**: R/Shiny with `inrep` package
- **File**: `/workspace/case_studies/hildesheim_study/HilFo.R`
- **Pages**: 22 pages total (1 intro, 2-19 demographics/items, 20 personal code, 21 results, 22 dummy)
- **Type**: Adaptive assessment with 51 items

#### 3. Results Processing
- **Function**: `create_hilfo_report()`
- **Language Detection**: Multiple sources (global env, session input, demographics)
- **Output**: HTML report with plots and tables
- **Language Support**: Bilingual (German/English)

#### 4. Data Storage
- **Format**: CSV via WebDAV
- **Credentials**: inreptest account
- **Variables**: 48 demographic variables + 51 item responses

### Key Patterns

#### Language Switching Pattern
```javascript
// Global state
window.hilfoLanguage = "de"; // Default German

// Toggle function
function toggleLanguage() {
  window.hilfoLanguage = (window.hilfoLanguage === "de") ? "en" : "de";
  updateLanguageUI();
  document.dispatchEvent(new CustomEvent("languageChanged"));
}

// UI update
function updateLanguageUI() {
  // Update content divs, buttons, data-lang elements, placeholders
}
```

#### Page Structure Pattern
```r
list(
  id = "pageX",
  type = "custom|demographics|results",
  title = "German Title",
  title_en = "English Title",
  content = paste0('HTML with data-lang attributes'),
  validate = "JavaScript validation function"
)
```

#### Data Attributes Pattern
```html
<!-- Text content -->
<span data-lang-de="German text" data-lang-en="English text">German text</span>

<!-- Input placeholders -->
<input data-placeholder-de="German placeholder" data-placeholder-en="English placeholder">
```

### Critical Issues Resolved

#### 1. Language Switching Feedback Loops
- **Problem**: Multiple conflicting language systems caused rapid switching
- **Solution**: Single "PURE AND SIMPLE" client-side system with no Shiny communication
- **Result**: Stable, reliable language switching across all pages

#### 2. Page 21 Index Out of Bounds Error
- **Problem**: Results page caused navigation error
- **Solution**: Changed type from "custom" to "results" and added dummy page 22
- **Result**: Smooth navigation to results page

#### 3. Inconsistent Language Display
- **Problem**: Some pages didn't update when language was switched
- **Solution**: Global event system with `languageChanged` event
- **Result**: All pages stay synchronized with language selection

### Development Guidelines

#### Before Making Changes
1. **Search memory** for related concepts and previous solutions
2. **Check existing patterns** in the codebase
3. **Verify language switching** won't be affected
4. **Test on all page types** (custom, demographics, results)

#### During Implementation
1. **Use consistent patterns** (data-lang attributes, event system)
2. **Avoid Shiny communication** for language switching
3. **Test language switching** after each change
4. **Update memory** with new learnings

#### After Implementation
1. **Update memory** with new entities and observations
2. **Test complete workflow** (all pages, language switching)
3. **Verify no conflicts** with existing systems
4. **Document changes** in memory

### Memory Update Triggers

#### When to Update Memory
- New component added
- Language switching modified
- Page structure changed
- Bug fixes implemented
- User requirements updated
- Architecture decisions made

#### What to Store in Memory
- Component relationships
- Implementation patterns
- Bug fix solutions
- User requirements
- Technical decisions
- Code structure insights

### Quality Assurance

#### Language Switching Tests
1. Switch language on Page 1 → verify all pages update
2. Switch language on Page 20 → verify all pages update  
3. Switch language on Page 21 → verify all pages update
4. Navigate between pages → verify language persists
5. Refresh page → verify language resets to German

#### Functional Tests
1. Complete assessment flow
2. Personal code validation
3. Results page display
4. Data saving to WebDAV
5. Error handling

### Current Status
- **Language Switching**: ✅ Fully functional across all pages
- **Page Navigation**: ✅ No errors, smooth flow
- **Results Display**: ✅ Clean, no download buttons
- **Data Storage**: ✅ CSV format via WebDAV
- **Code Quality**: ✅ Clean, no conflicts, well-documented

### Next Steps
1. **Monitor** for any language switching issues
2. **Test** with real users
3. **Update memory** with user feedback
4. **Refine** based on usage patterns
5. **Maintain** code quality and documentation