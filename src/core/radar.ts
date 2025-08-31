import { GitHubRepo, SlimRepo, FastGrowingRepo } from '../types/index.js';
import { searchRepos } from './github-api.js';

function parseISO8601(dateString: string): Date {
  return new Date(dateString.replace('Z', '+00:00'));
}

function repoAgeDays(repo: GitHubRepo, now: Date = new Date()): number {
  const created = parseISO8601(repo.created_at);
  const ageMs = now.getTime() - created.getTime();
  const ageDays = ageMs / (1000 * 60 * 60 * 24);
  return Math.max(1, Math.floor(ageDays));
}

function starsPerDay(repo: GitHubRepo, now: Date = new Date()): number {
  const age = repoAgeDays(repo, now);
  const stars = repo.stargazers_count || 0;
  return stars / Math.max(1, age);
}

function slim(repo: GitHubRepo): SlimRepo {
  return {
    full_name: repo.full_name,
    html_url: repo.html_url,
    description: (repo.description || '').substring(0, 200),
    language: repo.language,
    stars: repo.stargazers_count || 0,
    forks: repo.forks_count || 0,
    open_issues: repo.open_issues_count || 0,
    created_at: repo.created_at,
    pushed_at: repo.pushed_at,
  };
}

export async function trending(
  language?: string,
  days: number = 7,
  perPage: number = 50,
  maxPages: number = 2
): Promise<SlimRepo[]> {
  const since = new Date();
  since.setDate(since.getDate() - days);
  const sinceStr = since.toISOString().split('T')[0];
  
  const langQuery = language ? ` language:${language}` : '';
  const query = `created:>=${sinceStr}${langQuery} stars:>5`;
  
  const items = await searchRepos(query, 'stars', 'desc', perPage, maxPages);
  return items.map(slim);
}

export async function fastestGrowing(
  language?: string,
  sinceDays: number = 30,
  minStars: number = 50,
  perPage: number = 50,
  maxPages: number = 2
): Promise<FastGrowingRepo[]> {
  const since = new Date();
  since.setDate(since.getDate() - sinceDays);
  const sinceStr = since.toISOString().split('T')[0];
  
  const langQuery = language ? ` language:${language}` : '';
  const query = `created:>=${sinceStr} stars:>=${minStars}${langQuery}`;
  
  const items = await searchRepos(query, 'stars', 'desc', perPage, maxPages);
  const now = new Date();
  
  const scored: FastGrowingRepo[] = items.map(item => {
    const spd = starsPerDay(item, now);
    const slimmed = slim(item);
    return {
      ...slimmed,
      stars_per_day: Math.round(spd * 100) / 100,
    };
  });
  
  scored.sort((a, b) => b.stars_per_day - a.stars_per_day);
  return scored;
}

export async function newlyPublished(
  language?: string,
  days: number = 3,
  perPage: number = 50,
  maxPages: number = 2
): Promise<SlimRepo[]> {
  const since = new Date();
  since.setDate(since.getDate() - days);
  const sinceStr = since.toISOString().split('T')[0];
  
  const langQuery = language ? ` language:${language}` : '';
  const query = `created:>=${sinceStr}${langQuery}`;
  
  const items = await searchRepos(query, 'updated', 'desc', perPage, maxPages);
  return items.map(slim);
}