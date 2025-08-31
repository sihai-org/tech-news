import { loadConfig } from '../utils/config.js';
import { trending, fastestGrowing, newlyPublished } from '../core/radar.js';
import { saveResults } from '../services/storage.js';
import { saveResultsToSupabase } from '../services/supabase.js';
import { RadarResult, CollectionConfig } from '../types/index.js';

async function runCollection(
  collection: CollectionConfig,
  perPage: number,
  maxPages: number
): Promise<RadarResult> {
  const timestamp = new Date().toISOString();
  
  let repositories;
  
  switch (collection.type) {
    case 'trending':
      repositories = await trending(
        collection.language,
        collection.days,
        perPage,
        maxPages
      );
      break;
      
    case 'fastest_growing':
      repositories = await fastestGrowing(
        collection.language,
        collection.days,
        collection.minStars || 50,
        perPage,
        maxPages
      );
      break;
      
    case 'newly_published':
      // For newly_published, limit to only 10 repositories
      repositories = await newlyPublished(
        collection.language,
        collection.days,
        10, // Fixed to 10 per page
        1   // Only 1 page, so total = 10 repositories
      );
      break;
      
    default:
      throw new Error(`Unknown collection type: ${collection.type}`);
  }
  
  return {
    timestamp,
    collection: collection.name,
    type: collection.type,
    language: collection.language,
    repositories
  };
}

export async function runDailyRadar(configPath?: string): Promise<void> {
  try {
    console.log('🔍 Loading configuration...');
    const config = await loadConfig(configPath);
    
    console.log(`📊 Running ${config.collections.length} collections...`);
    
    const results: RadarResult[] = [];
    
    for (const collection of config.collections) {
      console.log(`  • ${collection.name} (${collection.type})`);
      
      try {
        const result = await runCollection(
          collection,
          config.api.perPage,
          config.api.maxPages
        );
        results.push(result);
        
        console.log(`    Found ${result.repositories.length} repositories`);
        
        // Rate limiting
        await new Promise(resolve => setTimeout(resolve, config.api.rateLimitDelay));
        
      } catch (error) {
        console.error(`    Error in ${collection.name}:`, error instanceof Error ? error.message : String(error));
      }
    }
    
    console.log('💾 Saving results...');
    
    let savedToDatabase = false;
    let filePath: string | null = null;
    
    // Try to save to Supabase first
    if (config.output.type === 'supabase' || config.output.type === 'both') {
      try {
        await saveResultsToSupabase(results);
        console.log('✅ Results saved to Supabase database');
        savedToDatabase = true;
      } catch (error) {
        console.error('❌ Failed to save to Supabase:', error instanceof Error ? error.message : String(error));
        
        if (config.output.fallbackToFile) {
          console.log('📁 Falling back to file storage...');
        } else {
          throw error;
        }
      }
    }
    
    // Save to file if configured or as fallback
    if (config.output.type === 'file' || 
        config.output.type === 'both' || 
        (!savedToDatabase && config.output.fallbackToFile)) {
      filePath = await saveResults(
        results,
        config.output.directory,
        config.output.format,
        config.output.includeTimestamp
      );
      console.log(`✅ Results saved to file: ${filePath}`);
    }
    
    const totalRepos = results.reduce((sum, r) => sum + r.repositories.length, 0);
    console.log(`📈 Total repositories discovered: ${totalRepos}`);
    
  } catch (error) {
    console.error('❌ Error running daily radar:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}