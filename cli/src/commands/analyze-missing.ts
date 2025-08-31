import { analyzeRepo } from '../core/analyzer.js';
import { saveAnalysisToSupabase, getUnanalyzedRepositoriesWithCollection, getRepositoryStatistics } from '../services/supabase.js';
import { extractTitleAndContent } from '../utils/title-extractor.js';
import { GitHubRepo } from '../types/index.js';

// Convert database repository row to GitHubRepo format
function convertToGitHubRepo(dbRepo: any): GitHubRepo {
  return {
    full_name: dbRepo.full_name,
    html_url: dbRepo.html_url,
    description: dbRepo.description,
    language: dbRepo.language,
    stargazers_count: dbRepo.stars,
    forks_count: dbRepo.forks,
    open_issues_count: dbRepo.open_issues,
    created_at: dbRepo.created_at,
    pushed_at: dbRepo.pushed_at,
  };
}

export async function analyzeMissingCommand(options: {
  limit?: string;
  delay?: string;
  dryRun?: boolean;
}): Promise<void> {
  try {
    if (!process.env.DEEPSEEK_API_KEY) {
      console.error('❌ DEEPSEEK_API_KEY environment variable is required');
      process.exit(1);
    }

    if (!process.env.GITHUB_TOKEN) {
      console.error('WARNING: GITHUB_TOKEN not set. You may hit low rate limits.');
    }

    const limit = options.limit ? parseInt(options.limit, 10) : undefined;
    const delay = parseInt(options.delay || '3000', 10);

    console.log('🔍 Analyzing missing repository analyses...\n');

    // Get statistics
    console.log('📊 Checking repository statistics...');
    const stats = await getRepositoryStatistics();
    console.log(`  • Total repositories: ${stats.totalRepositories}`);
    console.log(`  • Already analyzed: ${stats.analyzedRepositories}`);
    console.log(`  • Need analysis: ${stats.unanalyzedRepositories}`);

    if (stats.unanalyzedRepositories === 0) {
      console.log('\n🎉 All repositories have been analyzed!');
      return;
    }

    // Get unanalyzed repositories with their collection info
    console.log(`\n🔎 Fetching unanalyzed repositories with collection info${limit ? ` (limit: ${limit})` : ''}...`);
    const unanalyzedRepoData = await getUnanalyzedRepositoriesWithCollection(limit);
    
    if (unanalyzedRepoData.length === 0) {
      console.log('🎉 No unanalyzed repositories found!');
      return;
    }

    console.log(`📋 Found ${unanalyzedRepoData.length} repositories to analyze\n`);

    if (options.dryRun) {
      console.log('🏃 DRY RUN - Would analyze the following repositories:');
      unanalyzedRepoData.forEach((repoData, index) => {
        const repo = repoData.repository;
        const collection = repoData.collection;
        console.log(`  ${index + 1}. ${repo.full_name} (⭐ ${repo.stars} stars) [${collection.type}/${collection.language}]`);
      });
      console.log(`\nRun without --dry-run to perform actual analysis.`);
      return;
    }

    let successCount = 0;
    let errorCount = 0;

    // Process each repository
    for (let i = 0; i < unanalyzedRepoData.length; i++) {
      const { repository: dbRepo, collection } = unanalyzedRepoData[i];
      const repo = convertToGitHubRepo(dbRepo);
      
      console.log(`[${i + 1}/${unanalyzedRepoData.length}] 🔍 Analyzing ${repo.full_name}...`);
      console.log(`  📊 ${repo.stargazers_count} stars | 🗂️ ${repo.language || 'Unknown'} | 📅 ${new Date(repo.created_at).toDateString()}`);
      console.log(`  📂 Collection: ${collection.name} (${collection.type})`);

      try {
        // Analyze the repository
        const analysis = await analyzeRepo(repo);
        
        // Extract title and clean content
        const { title, content: cleanedAnalysis } = extractTitleAndContent(analysis.analysis);
        console.log(`  📝 Extracted title: ${title}`);

        // Save analysis to database with collection information
        await saveAnalysisToSupabase({
          repo: repo,
          title: title,
          analysis: cleanedAnalysis,
          markdown: analysis.markdown,
          collectionName: collection.name,
          collectionType: collection.type,
        });

        console.log(`  ✅ Analysis completed and saved\n`);
        successCount++;

      } catch (error) {
        console.error(`  ❌ Analysis failed: ${error instanceof Error ? error.message : String(error)}\n`);
        errorCount++;
      }

      // Rate limiting between analyses
      if (i < unanalyzedRepoData.length - 1 && delay > 0) {
        console.log(`  ⏳ Waiting ${delay}ms before next analysis...\n`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    // Summary
    console.log('🎯 Analysis Summary:');
    console.log(`  ✅ Successfully analyzed: ${successCount}`);
    console.log(`  ❌ Failed: ${errorCount}`);
    console.log(`  📊 Total processed: ${unanalyzedRepoData.length}`);
    
    if (successCount > 0) {
      console.log('\n🎉 Missing repository analysis completed!');
    }

  } catch (error) {
    console.error('❌ Command failed:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}