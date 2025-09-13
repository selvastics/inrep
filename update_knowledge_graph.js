#!/usr/bin/env node

/**
 * Simple Knowledge Graph Update Script
 * Maintains a local knowledge graph for the HilFo study project
 */

const fs = require('fs');
const path = require('path');

class KnowledgeGraph {
  constructor(memoryPath = '.aim') {
    this.memoryPath = memoryPath;
    this.configPath = path.join(memoryPath, 'config.json');
    this.entitiesPath = path.join(memoryPath, 'entities.json');
    this.relationsPath = path.join(memoryPath, 'relations.json');
    this.observationsPath = path.join(memoryPath, 'observations.json');
    
    this.ensureDirectory();
    this.loadData();
  }

  ensureDirectory() {
    if (!fs.existsSync(this.memoryPath)) {
      fs.mkdirSync(this.memoryPath, { recursive: true });
    }
  }

  loadData() {
    this.entities = this.loadFile(this.entitiesPath, {});
    this.relations = this.loadFile(this.relationsPath, {});
    this.observations = this.loadFile(this.observationsPath, {});
  }

  loadFile(filePath, defaultValue) {
    try {
      if (fs.existsSync(filePath)) {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
      }
    } catch (error) {
      console.warn(`Warning: Could not load ${filePath}:`, error.message);
    }
    return defaultValue;
  }

  saveFile(filePath, data) {
    try {
      fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
      return true;
    } catch (error) {
      console.error(`Error saving ${filePath}:`, error.message);
      return false;
    }
  }

  saveData() {
    this.saveFile(this.entitiesPath, this.entities);
    this.saveFile(this.relationsPath, this.relations);
    this.saveFile(this.observationsPath, this.observations);
  }

  createEntity(id, type, name, description = '') {
    this.entities[id] = {
      id,
      type,
      name,
      description,
      created: new Date().toISOString(),
      updated: new Date().toISOString()
    };
    this.saveData();
    return this.entities[id];
  }

  updateEntity(id, updates) {
    if (this.entities[id]) {
      this.entities[id] = {
        ...this.entities[id],
        ...updates,
        updated: new Date().toISOString()
      };
      this.saveData();
      return this.entities[id];
    }
    return null;
  }

  createRelation(fromId, toId, relationType, description = '') {
    const relationId = `${fromId}_${relationType}_${toId}`;
    this.relations[relationId] = {
      id: relationId,
      from: fromId,
      to: toId,
      type: relationType,
      description,
      created: new Date().toISOString()
    };
    this.saveData();
    return this.relations[relationId];
  }

  addObservation(entityId, observation) {
    const obsId = `${entityId}_${Date.now()}`;
    this.observations[obsId] = {
      id: obsId,
      entityId,
      observation,
      created: new Date().toISOString()
    };
    this.saveData();
    return this.observations[obsId];
  }

  searchEntities(query) {
    const results = [];
    const searchTerm = query.toLowerCase();
    
    for (const [id, entity] of Object.entries(this.entities)) {
      if (
        entity.name.toLowerCase().includes(searchTerm) ||
        entity.description.toLowerCase().includes(searchTerm) ||
        entity.type.toLowerCase().includes(searchTerm)
      ) {
        results.push(entity);
      }
    }
    
    return results;
  }

  getEntityObservations(entityId) {
    return Object.values(this.observations).filter(obs => obs.entityId === entityId);
  }

  getEntityRelations(entityId) {
    const relations = [];
    for (const [id, relation] of Object.entries(this.relations)) {
      if (relation.from === entityId || relation.to === entityId) {
        relations.push(relation);
      }
    }
    return relations;
  }

  printGraph() {
    console.log('\n=== KNOWLEDGE GRAPH ===');
    console.log(`Entities: ${Object.keys(this.entities).length}`);
    console.log(`Relations: ${Object.keys(this.relations).length}`);
    console.log(`Observations: ${Object.keys(this.observations).length}`);
    
    console.log('\n--- ENTITIES ---');
    for (const [id, entity] of Object.entries(this.entities)) {
      console.log(`${id}: ${entity.name} (${entity.type})`);
      console.log(`  Description: ${entity.description}`);
      console.log(`  Updated: ${entity.updated}`);
    }
    
    console.log('\n--- RELATIONS ---');
    for (const [id, relation] of Object.entries(this.relations)) {
      console.log(`${relation.from} --[${relation.type}]--> ${relation.to}`);
    }
  }
}

// CLI Interface
if (require.main === module) {
  const kg = new KnowledgeGraph();
  
  const command = process.argv[2];
  const args = process.argv.slice(3);
  
  switch (command) {
    case 'create-entity':
      if (args.length >= 3) {
        const [id, type, name, ...descParts] = args;
        const description = descParts.join(' ');
        kg.createEntity(id, type, name, description);
        console.log(`Created entity: ${id}`);
      } else {
        console.log('Usage: create-entity <id> <type> <name> [description]');
      }
      break;
      
    case 'add-observation':
      if (args.length >= 2) {
        const [entityId, ...obsParts] = args;
        const observation = obsParts.join(' ');
        kg.addObservation(entityId, observation);
        console.log(`Added observation to ${entityId}`);
      } else {
        console.log('Usage: add-observation <entityId> <observation>');
      }
      break;
      
    case 'create-relation':
      if (args.length >= 3) {
        const [fromId, relationType, toId, ...descParts] = args;
        const description = descParts.join(' ');
        kg.createRelation(fromId, toId, relationType, description);
        console.log(`Created relation: ${fromId} --[${relationType}]--> ${toId}`);
      } else {
        console.log('Usage: create-relation <fromId> <relationType> <toId> [description]');
      }
      break;
      
    case 'search':
      if (args.length >= 1) {
        const query = args.join(' ');
        const results = kg.searchEntities(query);
        console.log(`Search results for "${query}":`);
        results.forEach(entity => {
          console.log(`  ${entity.id}: ${entity.name} (${entity.type})`);
        });
      } else {
        console.log('Usage: search <query>');
      }
      break;
      
    case 'show':
      kg.printGraph();
      break;
      
    default:
      console.log('Knowledge Graph CLI');
      console.log('Commands:');
      console.log('  create-entity <id> <type> <name> [description]');
      console.log('  add-observation <entityId> <observation>');
      console.log('  create-relation <fromId> <relationType> <toId> [description]');
      console.log('  search <query>');
      console.log('  show');
  }
}

module.exports = KnowledgeGraph;