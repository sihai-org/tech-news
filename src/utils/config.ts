import { promises as fs } from 'fs';
import { RadarConfig } from '../types/index.js';

export async function loadConfig(configPath: string = './radar-config.json'): Promise<RadarConfig> {
  try {
    const content = await fs.readFile(configPath, 'utf8');
    const config = JSON.parse(content) as RadarConfig;
    
    // Validate required fields
    if (!config.collections || !Array.isArray(config.collections)) {
      throw new Error('Config must contain collections array');
    }
    
    if (!config.output) {
      throw new Error('Config must contain output settings');
    }
    
    if (!config.api) {
      throw new Error('Config must contain api settings');
    }
    
    return config;
  } catch (error) {
    if (error instanceof Error && error.message.includes('ENOENT')) {
      throw new Error(`Config file not found: ${configPath}`);
    }
    throw error;
  }
}