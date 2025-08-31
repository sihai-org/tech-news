import { analyzeRepo } from '../core/analyzer.js';
import { saveAnalysisToSupabase, getUnanalyzedRepositories, getRepositoryStatistics } from '../services/supabase.js';
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

    // Get unanalyzed repositories
    console.log(`\n🔎 Fetching unanalyzed repositories${limit ? ` (limit: ${limit})` : ''}...`);
    const unanalyzedRepos = await getUnanalyzedRepositories(limit);
    
    if (unanalyzedRepos.length === 0) {
      console.log('🎉 No unanalyzed repositories found!');
      return;
    }

    console.log(`📋 Found ${unanalyzedRepos.length} repositories to analyze\n`);

    if (options.dryRun) {
      console.log('🏃 DRY RUN - Would analyze the following repositories:');
      unanalyzedRepos.forEach((repo, index) => {
        console.log(`  ${index + 1}. ${repo.full_name} (⭐ ${repo.stars} stars)`);
      });
      console.log(`\nRun without --dry-run to perform actual analysis.`);
      return;
    }

    let successCount = 0;
    let errorCount = 0;

    // Process each repository
    for (let i = 0; i < unanalyzedRepos.length; i++) {
      const dbRepo = unanalyzedRepos[i];
      const repo = convertToGitHubRepo(dbRepo);
      
      console.log(`[${i + 1}/${unanalyzedRepos.length}] 🔍 Analyzing ${repo.full_name}...`);
      console.log(`  📊 ${repo.stargazers_count} stars | 🗂️ ${repo.language || 'Unknown'} | 📅 ${new Date(repo.created_at).toDateString()}`);

      try {
        // Analyze the repository
        const analysis = await analyzeRepo(repo);
        
        // Extract title and clean content
        const { title, content: cleanedAnalysis } = extractTitleAndContent(analysis.analysis);
        console.log(`  📝 Extracted title: ${title}`);

        // Save analysis to database
        await saveAnalysisToSupabase({
          repo: repo,
          title: title,
          analysis: cleanedAnalysis,
          markdown: analysis.markdown,
        });

        console.log(`  ✅ Analysis completed and saved\n`);
        successCount++;

      } catch (error) {
        console.error(`  ❌ Analysis failed: ${error instanceof Error ? error.message : String(error)}\n`);
        errorCount++;
      }

      // Rate limiting between analyses
      if (i < unanalyzedRepos.length - 1 && delay > 0) {
        console.log(`  ⏳ Waiting ${delay}ms before next analysis...\n`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }

    // Summary
    console.log('🎯 Analysis Summary:');
    console.log(`  ✅ Successfully analyzed: ${successCount}`);
    console.log(`  ❌ Failed: ${errorCount}`);
    console.log(`  📊 Total processed: ${unanalyzedRepos.length}`);
    
    if (successCount > 0) {
      console.log('\n🎉 Missing repository analysis completed!');
    }

  } catch (error) {
    console.error('❌ Command failed:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}