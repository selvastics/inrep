#!/bin/bash

# Pre-Task Knowledge Graph Setup Script
# Run this before starting any development task

echo "🧠 Setting up Knowledge Graph for HilFo Study Development"
echo "=================================================="

# Check if knowledge graph exists
if [ ! -f ".aim/entities.json" ]; then
    echo "📝 Initializing knowledge graph..."
    node update_knowledge_graph.js show
else
    echo "📊 Current knowledge graph status:"
    node update_knowledge_graph.js show
fi

echo ""
echo "🔍 Searching for relevant concepts..."
echo "Language switching:"
node update_knowledge_graph.js search "language"

echo ""
echo "HilFo study components:"
node update_knowledge_graph.js search "hilfo"

echo ""
echo "Framework and tools:"
node update_knowledge_graph.js search "inrep"

echo ""
echo "✅ Knowledge graph ready for development task"
echo "💡 Remember to update memory after learning new information!"
echo ""