#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

class KnowledgeGraph {
  constructor(memoryPath = '.aim/memory.jsonl') {
    this.memoryPath = memoryPath;
    this.ensureMemoryFile();
  }

  ensureMemoryFile() {
    const dir = path.dirname(this.memoryPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    if (!fs.existsSync(this.memoryPath)) {
      fs.writeFileSync(this.memoryPath, '');
    }
  }

  readMemory() {
    try {
      const content = fs.readFileSync(this.memoryPath, 'utf8');
      return content.trim().split('\n')
        .filter(line => line.trim())
        .map(line => JSON.parse(line));
    } catch (error) {
      console.error('Error reading memory:', error);
      return [];
    }
  }

  writeMemory(entries) {
    try {
      const content = entries.map(entry => JSON.stringify(entry)).join('\n');
      fs.writeFileSync(this.memoryPath, content);
    } catch (error) {
      console.error('Error writing memory:', error);
    }
  }

  addEntity(name, type, description, properties = {}) {
    const entries = this.readMemory();
    const id = name.toLowerCase().replace(/\s+/g, '_');
    const entity = {
      type: 'entity',
      id,
      name,
      type,
      description,
      properties,
      timestamp: new Date().toISOString()
    };
    entries.push(entity);
    this.writeMemory(entries);
    return entity;
  }

  addObservation(entityId, observation) {
    const entries = this.readMemory();
    const obs = {
      type: 'observation',
      entity: entityId,
      observation,
      timestamp: new Date().toISOString()
    };
    entries.push(obs);
    this.writeMemory(entries);
    return obs;
  }

  addRelation(sourceId, targetId, relationType, description = '') {
    const entries = this.readMemory();
    const relation = {
      type: 'relation',
      source: sourceId,
      target: targetId,
      type: relationType,
      description,
      timestamp: new Date().toISOString()
    };
    entries.push(relation);
    this.writeMemory(entries);
    return relation;
  }

  search(query) {
    const entries = this.readMemory();
    const searchTerm = query.toLowerCase();
    return entries.filter(entry => 
      JSON.stringify(entry).toLowerCase().includes(searchTerm)
    );
  }

  getEntity(id) {
    const entries = this.readMemory();
    return entries.find(entry => entry.type === 'entity' && entry.id === id);
  }

  getRelatedEntities(entityId) {
    const entries = this.readMemory();
    const relations = entries.filter(entry => 
      entry.type === 'relation' && 
      (entry.source === entityId || entry.target === entityId)
    );
    
    const relatedIds = new Set();
    relations.forEach(rel => {
      if (rel.source === entityId) relatedIds.add(rel.target);
      if (rel.target === entityId) relatedIds.add(rel.source);
    });
    
    return Array.from(relatedIds).map(id => this.getEntity(id)).filter(Boolean);
  }
}

// CLI interface
if (require.main === module) {
  const kg = new KnowledgeGraph();
  const command = process.argv[2];
  
  switch (command) {
    case 'search':
      const query = process.argv[3];
      console.log(JSON.stringify(kg.search(query), null, 2));
      break;
    case 'add-entity':
      const name = process.argv[3];
      const type = process.argv[4];
      const description = process.argv[5];
      console.log(JSON.stringify(kg.addEntity(name, type, description), null, 2));
      break;
    case 'add-observation':
      const entityId = process.argv[3];
      const observation = process.argv[4];
      console.log(JSON.stringify(kg.addObservation(entityId, observation), null, 2));
      break;
    case 'list':
      console.log(JSON.stringify(kg.readMemory(), null, 2));
      break;
    default:
      console.log('Usage: node kg_utils.js [search|add-entity|add-observation|list] [args...]');
  }
}

module.exports = KnowledgeGraph;