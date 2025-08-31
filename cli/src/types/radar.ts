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

export interface CollectionConfig {
  name: string;
  type: 'trending' | 'fastest_growing' | 'newly_published';
  language?: string;
  days: number;
  minStars?: number;
}

export interface RadarConfig {
  collections: CollectionConfig[];
  output: {
    type: 'file' | 'supabase' | 'both';
    directory: string;
    format: 'json' | 'csv';
    includeTimestamp: boolean;
    fallbackToFile?: boolean;
  };
  api: {
    perPage: number;
    maxPages: number;
    rateLimitDelay: number;
    typeSettings?: {
      [key: string]: {
        perPage: number;
        maxPages: number;
      };
    };
  };
}

export interface RadarResult {
  timestamp: string;
  collection: string;
  type: string;
  language?: string;
  repositories: (SlimRepo | FastGrowingRepo)[];
}