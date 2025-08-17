export interface GitHubRepo {
  full_name: string;
  html_url: string;
  description: string | null;
  language: string | null;
  stargazers_count: number;
  forks_count: number;
  open_issues_count: number;
  created_at: string;
  pushed_at: string;
}

export interface SlimRepo {
  full_name: string;
  html_url: string;
  description: string;
  language: string | null;
  stars: number;
  forks: number;
  open_issues: number;
  created_at: string;
  pushed_at: string;
}

export interface FastGrowingRepo extends SlimRepo {
  stars_per_day: number;
}

export interface SearchResponse {
  total_count: number;
  incomplete_results: boolean;
  items: GitHubRepo[];
}

export interface SearchOptions {
  language?: string;
  trendingDays: number;
  growthDays: number;
  newDays: number;
  minStars: number;
  perPage: number;
  maxPages: number;
}