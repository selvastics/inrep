# Knowledge Graph System for HilFo Study

## Overview

This knowledge graph system maintains persistent memory about the HilFo study project, enabling better context awareness and decision-making during development tasks.

## Setup

### 1. Knowledge Graph Script
The main knowledge graph is managed by `update_knowledge_graph.js`:

```bash
# Show current knowledge graph
node update_knowledge_graph.js show

# Search for entities
node update_knowledge_graph.js search "language switching"

# Create new entity
node update_knowledge_graph.js create-entity <id> <type> <name> [description]

# Add observation to entity
node update_knowledge_graph.js add-observation <entityId> <observation>

# Create relation between entities
node update_knowledge_graph.js create-relation <fromId> <relationType> <toId> [description]
```

### 2. Memory Directory
All knowledge graph data is stored in `.aim/` directory:
- `entities.json` - Entity definitions
- `relations.json` - Relationships between entities
- `observations.json` - Factual observations about entities
- `config.json` - Configuration metadata

### 3. Claude Desktop Integration
To integrate with Claude Desktop, use the configuration in `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "knowledge-graph": {
      "command": "node",
      "args": ["/workspace/update_knowledge_graph.js"],
      "autoapprove": ["create-entity", "add-observation", "create-relation", "search", "show"]
    }
  }
}
```

## Usage Workflow

### Before Every Task
1. **Search memory** for related concepts:
   ```bash
   node update_knowledge_graph.js search "language switching"
   node update_knowledge_graph.js search "inrep"
   node update_knowledge_graph.js search "results"
   ```

2. **Review current knowledge**:
   ```bash
   node update_knowledge_graph.js show
   ```

### During Development
1. **Update entities** when learning about new components
2. **Add observations** when discovering implementation details
3. **Create relations** when understanding how components connect
4. **Search before creating** to avoid duplicates

### After Completing Tasks
1. **Add new learnings** as observations
2. **Update entity descriptions** if understanding changes
3. **Create new relations** if discovering new connections
4. **Remove outdated information** if patterns change

## Current Knowledge Graph

### Entities
- **hilfo-study**: Main project entity
- **language-switching**: Client-side language system
- **inrep-framework**: R package framework
- **results-processor**: Custom report generation

### Relations
- hilfo-study --[uses]--> inrep-framework
- hilfo-study --[implements]--> language-switching
- hilfo-study --[contains]--> results-processor

### Key Observations
- HilFo uses 22 pages total with specific structure
- Language switching uses window.hilfoLanguage state and custom events
- System is built on R/Shiny with inrep package
- Custom results processor generates HTML reports

## Development Guidelines

### Memory Quality Rules
1. **Entities** should represent concrete components, features, or concepts
2. **Observations** should be atomic, factual statements (15 words max)
3. **Relations** should use descriptive types (uses, implements, contains, etc.)
4. **Search before creating** to avoid duplicates
5. **Update regularly** to maintain accuracy

### When to Update Memory
- Learning about new codebase structure
- Implementing new features or modifications
- Discovering inconsistencies between memory and code
- User shares new information about project patterns
- Bug fixes reveal new understanding

### Memory Update Actions
- **CREATE/UPDATE** entities for new components
- **ADD** observations for implementation details
- **DELETE** outdated observations when information changes
- **CONNECT** related entities with descriptive relations
- **SEARCH** before creating to avoid duplicates

## Integration with Development Workflow

The knowledge graph is designed to integrate seamlessly with the development workflow described in `DEVELOPMENT_WORKFLOW.md`. Before every task, developers should:

1. **Search memory** for related concepts
2. **Review current understanding** of the system
3. **Update memory** as new information is learned
4. **Maintain accuracy** by removing outdated information

This ensures that each development session builds upon previous knowledge and maintains a comprehensive understanding of the HilFo study system.