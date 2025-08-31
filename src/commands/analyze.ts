import { promises as fs } from 'fs';
import path from 'path';
import { githubGet } from '../core/github-api.js';
import { analyzeRepo } from '../core/analyzer.js';
import { GitHubRepo } from '../types/index.js';

const GITHUB_API = 'https://api.github.com';

export async function analyzeCommand(repoName: string, options: {
  output?: string;
  format?: 'markdown' | 'json';
}): Promise<void> {
  try {
    if (!process.env.DEEPSEEK_API_KEY) {
      console.error('❌ DEEPSEEK_API_KEY environment variable is required');
      process.exit(1);
    }

    if (!process.env.GITHUB_TOKEN) {
      console.warn('⚠️  GITHUB_TOKEN not set. You may hit rate limits.');
    }

    // Get repository info
    console.log(`📊 Fetching repository info for ${repoName}...`);
    const repo: GitHubRepo = await githubGet(`${GITHUB_API}/repos/${repoName}`, {});
    
    // Analyze repository
    const analysis = await analyzeRepo(repo);
    
    // Save results
    const outputDir = options.output || './reports';
    await fs.mkdir(outputDir, { recursive: true });
    
    const timestamp = new Date().toISOString().split('T')[0];
    const sanitizedName = repoName.replace('/', '_');
    
    if (options.format === 'json') {
      const jsonPath = path.join(outputDir, `${sanitizedName}_${timestamp}.json`);
      await fs.writeFile(jsonPath, JSON.stringify(analysis, null, 2), 'utf8');
      console.log(`✅ Analysis saved to: ${jsonPath}`);
    } else {
      const mdPath = path.join(outputDir, `${sanitizedName}_${timestamp}.md`);
      await fs.writeFile(mdPath, analysis.markdown, 'utf8');
      console.log(`✅ Report saved to: ${mdPath}`);
    }
    
    console.log(`📝 Analysis completed for ${repoName}`);
    
  } catch (error) {
    console.error('❌ Analysis failed:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}