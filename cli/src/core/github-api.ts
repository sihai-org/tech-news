import fetch from 'node-fetch';
import { GitHubRepo, SearchResponse } from '../types/index.js';

const GITHUB_API = 'https://api.github.com';
const TOKEN = process.env.API_TOKEN;

function getHeaders(): Record<string, string> {
  const headers: Record<string, string> = {
    'Accept': 'application/vnd.github+json',
  };
  
  if (TOKEN) {
    headers['Authorization'] = `Bearer ${TOKEN}`;
  }
  
  return headers;
}

export async function githubGet(url: string, params: Record<string, string | number>): Promise<any> {
  const searchParams = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    searchParams.append(key, value.toString());
  }
  
  const fullUrl = `${url}?${searchParams.toString()}`;
  
  for (let attempt = 0; attempt < 5; attempt++) {
    try {
      const response = await fetch(fullUrl, {
        headers: getHeaders(),
      });
      
      if (response.status === 403 && response.statusText.toLowerCase().includes('rate limit')) {
        const resetHeader = response.headers.get('X-RateLimit-Reset');
        const reset = resetHeader ? parseInt(resetHeader, 10) : 0;
        const wait = Math.max(0, reset - Math.floor(Date.now() / 1000) + 1);
        await sleep(Math.min(wait * 1000, 60000));
        continue;
      }
      
      if ([502, 503, 504].includes(response.status)) {
        await sleep(Math.pow(2, attempt) * 1000);
        continue;
      }
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
    } catch (error) {
      if (attempt === 4) throw error;
      await sleep(Math.pow(2, attempt) * 1000);
    }
  }
}

export async function searchRepos(
  query: string,
  sort: string = 'stars',
  order: string = 'desc',
  perPage: number = 50,
  maxPages: number = 2
): Promise<GitHubRepo[]> {
  const items: GitHubRepo[] = [];
  
  for (let page = 1; page <= maxPages; page++) {
    const data: SearchResponse = await githubGet(`${GITHUB_API}/search/repositories`, {
      q: query,
      sort,
      order,
      per_page: perPage,
      page,
    });
    
    items.push(...data.items);
    
    if (data.items.length < perPage) {
      break;
    }
    
    await sleep(200);
  }
  
  return dedupeByFullName(items);
}

function dedupeByFullName(items: GitHubRepo[]): GitHubRepo[] {
  const seen = new Set<string>();
  const result: GitHubRepo[] = [];
  
  for (const item of items) {
    if (item.full_name && !seen.has(item.full_name)) {
      result.push(item);
      seen.add(item.full_name);
    }
  }
  
  return result;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}