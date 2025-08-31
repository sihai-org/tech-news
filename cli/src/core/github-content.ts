import { githubGet } from './github-api.js';
import { GitHubRepo } from '../types/index.js';

const GITHUB_API = 'https://api.github.com';

export async function getRepositoryContent(repo: GitHubRepo): Promise<{
  readme?: string;
  packageJson?: any;
  files: string[];
  mainFiles: string[];
  languages: Record<string, number>;
}> {
  const [readme, files, languages] = await Promise.all([
    getReadme(repo.full_name),
    getFileTree(repo.full_name),
    getLanguages(repo.full_name)
  ]);

  let packageJson;
  if (files.includes('package.json')) {
    packageJson = await getFileContent(repo.full_name, 'package.json');
  }

  const mainFiles = files.filter(file => 
    file.includes('README') ||
    file.includes('package.json') ||
    file.includes('Cargo.toml') ||
    file.includes('setup.py') ||
    file.includes('pom.xml') ||
    file.includes('build.gradle') ||
    file.includes('Dockerfile') ||
    file.includes('docker-compose') ||
    file.includes('.github/workflows')
  );

  return {
    readme,
    packageJson,
    files: files.slice(0, 100), // Limit to avoid too much data
    mainFiles,
    languages
  };
}

async function getReadme(fullName: string): Promise<string | undefined> {
  try {
    const data = await githubGet(`${GITHUB_API}/repos/${fullName}/readme`, {});
    if (data.content) {
      return Buffer.from(data.content, 'base64').toString('utf8');
    }
  } catch (error) {
    // README not found or other error
  }
  return undefined;
}

async function getFileTree(fullName: string): Promise<string[]> {
  try {
    const data = await githubGet(`${GITHUB_API}/repos/${fullName}/git/trees/HEAD`, {
      recursive: '1'
    });
    
    return data.tree
      ?.filter((item: any) => item.type === 'blob')
      ?.map((item: any) => item.path)
      ?.slice(0, 200) || []; // Limit files
  } catch (error) {
    return [];
  }
}

async function getLanguages(fullName: string): Promise<Record<string, number>> {
  try {
    return await githubGet(`${GITHUB_API}/repos/${fullName}/languages`, {});
  } catch (error) {
    return {};
  }
}

async function getFileContent(fullName: string, path: string): Promise<any> {
  try {
    const data = await githubGet(`${GITHUB_API}/repos/${fullName}/contents/${path}`, {});
    if (data.content) {
      const content = Buffer.from(data.content, 'base64').toString('utf8');
      return path.endsWith('.json') ? JSON.parse(content) : content;
    }
  } catch (error) {
    // File not found or other error
  }
  return undefined;
}