import { promises as fs } from 'fs';
import path from 'path';
import { loadConfig } from '../utils/config.js';
import { trending, fastestGrowing, newlyPublished } from '../core/radar.js';
import { analyzeRepo } from '../core/analyzer.js';
import { saveAnalysisToSupabase } from '../services/supabase.js';
import { extractTitleAndContent } from '../utils/title-extractor.js';
import { GitHubRepo, CollectionConfig } from '../types/index.js';

async function getTop1FromCollection(
  collection: CollectionConfig,
  perPage: number = 10,
  maxPages: number = 1
): Promise<GitHubRepo | null> {
  try {
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
        repositories = await newlyPublished(
          collection.language,
          collection.days,
          perPage,
          maxPages
        );
        break;
        
      default:
        throw new Error(`Unknown collection type: ${collection.type}`);
    }
    
    if (repositories.length === 0) {
      return null;
    }
    
    // Convert SlimRepo back to GitHubRepo format for analysis
    const topRepo = repositories[0];
    const repoData: GitHubRepo = {
      full_name: topRepo.full_name,
      html_url: topRepo.html_url,
      description: topRepo.description,
      language: topRepo.language,
      stargazers_count: topRepo.stars,
      forks_count: topRepo.forks,
      open_issues_count: topRepo.open_issues,
      created_at: topRepo.created_at,
      pushed_at: topRepo.pushed_at
    };
    
    return repoData;
    
  } catch (error) {
    console.error(`Error getting top1 for ${collection.name}:`, error instanceof Error ? error.message : String(error));
    return null;
  }
}

export async function analyzeTopCommand(options: {
  config?: string;
  output?: string;
  delay?: string;
  saveToDb?: boolean;
}): Promise<void> {
  try {
    if (!process.env.DEEPSEEK_API_KEY) {
      console.error('❌ DEEPSEEK_API_KEY environment variable is required');
      process.exit(1);
    }

    if (!process.env.GITHUB_TOKEN) {
      console.warn('⚠️  GITHUB_TOKEN not set. You may hit rate limits.');
    }

    console.log('🔍 Loading configuration...');
    const config = await loadConfig(options.config);
    
    console.log(`📊 Analyzing top repositories from ${config.collections.length} collections...`);
    
    const outputDir = options.output || './reports';
    await fs.mkdir(outputDir, { recursive: true });
    
    const delay = parseInt(options.delay || '5000', 10);
    
    for (const collection of config.collections) {
      console.log(`\n🎯 Processing ${collection.name} (${collection.type})...`);
      
      // Get top 1 repository
      const topRepo = await getTop1FromCollection(collection);
      
      if (!topRepo) {
        console.log(`  ❌ No repositories found for ${collection.name}`);
        continue;
      }
      
      console.log(`  🏆 Top repository: ${topRepo.full_name} (${topRepo.stargazers_count} stars)`);
      
      try {
        // Analyze the repository
        const analysis = await analyzeRepo(topRepo);
        
        // Extract title and clean content
        const { title, content: cleanedAnalysis } = extractTitleAndContent(analysis.analysis);
        console.log(`  📝 Extracted title: ${title}`);
        
        // Save to database if enabled
        if (options.saveToDb !== false) {
          try {
            await saveAnalysisToSupabase({
              repo: topRepo,
              title: title,
              analysis: cleanedAnalysis, // Use cleaned analysis without title line
              markdown: analysis.markdown,
              collectionName: collection.name,
              collectionType: collection.type,
            });
            console.log(`  💾 Analysis saved to database`);
          } catch (dbError) {
            console.error(`  ⚠️  Database save failed:`, dbError instanceof Error ? dbError.message : String(dbError));
          }
        }
        
        // Save markdown report to file
        const timestamp = new Date().toISOString().split('T')[0];
        const sanitizedName = `${collection.name}_${topRepo.full_name.replace('/', '_')}`;
        const mdPath = path.join(outputDir, `${sanitizedName}_${timestamp}.md`);
        
        await fs.writeFile(mdPath, analysis.markdown, 'utf8');
        console.log(`  ✅ Report saved: ${mdPath}`);
        
      } catch (error) {
        console.error(`  ❌ Analysis failed for ${topRepo.full_name}:`, error instanceof Error ? error.message : String(error));
      }
      
      // Rate limiting between analyses
      if (delay > 0) {
        console.log(`  ⏳ Waiting ${delay}ms before next analysis...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
    
    console.log('\n🎉 Top repositories analysis completed!');
    
  } catch (error) {
    console.error('❌ Analysis failed:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}