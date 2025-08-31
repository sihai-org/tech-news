import { GitHubRepo, RepoAnalysis } from '../types/index.js';
import { getRepositoryContent } from './github-content.js';
import { analyzeRepository } from '../services/deepseek.js';
import { generateMarkdownReport } from '../utils/markdown.js';

export async function analyzeRepo(repo: GitHubRepo): Promise<RepoAnalysis> {
  console.log(`🔍 Analyzing ${repo.full_name}...`);
  
  // Get repository content
  console.log('  • Fetching repository content...');
  const content = await getRepositoryContent(repo);
  
  // Prepare data for AI analysis
  const analysisData = {
    name: repo.full_name,
    description: repo.description || 'No description provided',
    language: repo.language || 'Unknown',
    readme: content.readme || 'No README found',
    files: content.files,
    packageJson: content.packageJson
  };
  
  // Get AI analysis
  console.log('  • Running AI analysis...');
  const aiAnalysis = await analyzeRepository(analysisData);
  
  // Create analysis result
  const analysis: RepoAnalysis = {
    repo,
    content,
    analysis: aiAnalysis,
    markdown: '',
    timestamp: new Date().toISOString()
  };
  
  // Generate markdown report
  console.log('  • Generating markdown report...');
  analysis.markdown = generateMarkdownReport(analysis);
  
  return analysis;
}