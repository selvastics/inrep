# HilFo Study - Hildesheimer Forschungsmethoden

## 🧠 Knowledge Graph Integration

**IMPORTANT:** Before proceeding with any task, ensure the Knowledge Graph system is active and accessible.

### Knowledge Graph Commands:
```bash
# Search the knowledge graph
node .aim/kg_utils.js search "language switching"

# Add new entities
node .aim/kg_utils.js add-entity "Task Name" "Task" "Description"

# Add observations
node .aim/kg_utils.js add-observation "entity_id" "Observation text"

# List all knowledge
node .aim/kg_utils.js list
```

---

## 📋 Project Overview

Bilingual (German/English) adaptive assessment study built with the `inrep` framework.

## 🎯 Key Features

### ✅ Language Switching System
- **Pure Client-Side**: No server communication to prevent feedback loops
- **Event-Driven**: Uses `languageChanged` events to synchronize all pages
- **Global State**: Single `window.hilfoLanguage` variable for consistency
- **Multi-Page Support**: Works across all pages

### ✅ Assessment Structure
- **51 Items Total**: Comprehensive item bank for research methodology assessment
- **Adaptive Testing**: Uses 2PL IRT model with Maximum Fisher Information criteria
- **Bilingual Support**: All content available in German and English
- **Progress Tracking**: Visual progress bar and page navigation

## 🚀 Usage

### Running the Study:
```r
source("HilFo.R")
```

### Knowledge Graph Integration:
```bash
# Before starting any development task:
node .aim/kg_utils.js search "current_task_context"

# After completing tasks, update the knowledge graph:
node .aim/kg_utils.js add-observation "hilfo_study" "Task completed successfully"
```

## 📁 File Structure

```
case_studies/hildesheim_study/
├── HilFo.R                    # Main study configuration
├── .aim/                      # Knowledge graph storage
│   ├── memory.jsonl          # Knowledge graph data
│   └── kg_utils.js           # Knowledge graph utilities
└── README.md                 # This documentation
```

## 🔧 Development Guidelines

### Before Each Task:
1. **Query Knowledge Graph**: Search for relevant context and previous work
2. **Review Current State**: Check existing entities and relationships
3. **Plan Approach**: Use knowledge graph insights to inform decisions

### After Each Task:
1. **Update Entities**: Add or modify relevant entities
2. **Record Observations**: Document what was learned or implemented
3. **Create Relations**: Connect related concepts and tasks

## 📝 Knowledge Graph Status

**Current Entities:**
- `hilfo_study`: Main study configuration and status
- `language_switching`: Client-side language switching system

**Recent Observations:**
- Successfully implemented pure client-side language switching
- Removed download functionality from results page
- Fixed page 21 index out of bounds error
- Cleaned up conflicting language switching implementations