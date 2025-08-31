import { GitHubRepo } from './radar.js';

export interface RepoContent {
  readme?: string;
  packageJson?: any;
  files: string[];
  mainFiles: string[];
  languages: Record<string, number>;
}

export interface RepoAnalysis {
  repo: GitHubRepo;
  content: RepoContent;
  analysis: string;
  markdown: string;
  timestamp: string;
}

export interface DeepSeekMessage {
  role: 'system' | 'user' | 'assistant';
  content: string;
}

export interface DeepSeekRequest {
  model: string;
  messages: DeepSeekMessage[];
  max_tokens?: number;
  temperature?: number;
  stream?: boolean;
}

export interface DeepSeekResponse {
  id: string;
  object: string;
  created: number;
  model: string;
  choices: Array<{
    index: number;
    message: {
      role: string;
      content: string;
    };
    finish_reason: string;
  }>;
  usage: {
    prompt_tokens: number;
    completion_tokens: number;
    total_tokens: number;
  };
}