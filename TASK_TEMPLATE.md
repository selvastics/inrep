# Task Template with Knowledge Graph Integration

## 🧠 Pre-Task Knowledge Graph Query

**BEFORE STARTING ANY TASK:**

```bash
# Query relevant context
node .aim/kg_utils.js search "task_keywords"

# Check related entities
node .aim/kg_utils.js search "hilfo_study"

# Review recent observations
node .aim/kg_utils.js list
```

---

## 📋 Task: [TASK_NAME]

### Context from Knowledge Graph:
- [Previous relevant findings]
- [Related entities and relationships]
- [Known patterns and solutions]

### Task Description:
[Detailed task description]

### Approach:
[Based on knowledge graph insights]

### Implementation:
[Step-by-step implementation]

### Testing:
[How to verify the solution works]

---

## 🧠 Post-Task Knowledge Graph Update

**AFTER COMPLETING THE TASK:**

```bash
# Add new observations
node .aim/kg_utils.js add-observation "hilfo_study" "Task completed: [description]"

# Add new entities if created
node .aim/kg_utils.js add-entity "new_entity" "Type" "Description"

# Create relationships
node .aim/kg_utils.js add-relation "source_entity" "target_entity" "relation_type" "description"
```

### Knowledge Graph Updates:
- [ ] Added observations about what was learned
- [ ] Created new entities if applicable
- [ ] Established relationships between concepts
- [ ] Documented patterns and solutions

---

## 📝 Task Completion Summary

### What was accomplished:
[Summary of completed work]

### Knowledge gained:
[New insights and patterns discovered]

### Next steps:
[Follow-up tasks or recommendations]

### Knowledge graph status:
[Current state of relevant entities and relationships]