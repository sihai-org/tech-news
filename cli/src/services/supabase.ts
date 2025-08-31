import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { RadarResult, SlimRepo, FastGrowingRepo } from '../types/index.js';

interface Database {
  public: {
    Tables: {
      github_radar_collections: {
        Row: {
          id: string;
          name: string;
          type: string;
          language: string | null;
          timestamp: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          name: string;
          type: string;
          language?: string | null;
          timestamp?: string;
          created_at?: string;
        };
      };
      github_radar_repositories: {
        Row: {
          id: string;
          collection_id: string;
          full_name: string;
          html_url: string;
          description: string | null;
          language: string | null;
          stars: number;
          forks: number;
          open_issues: number;
          stars_per_day: number | null;
          created_at: string;
          pushed_at: string;
          discovered_at: string;
        };
        Insert: {
          id?: string;
          collection_id: string;
          full_name: string;
          html_url: string;
          description?: string | null;
          language?: string | null;
          stars: number;
          forks: number;
          open_issues: number;
          stars_per_day?: number | null;
          created_at: string;
          pushed_at: string;
          discovered_at?: string;
        };
      };
      github_radar_analyses: {
        Row: {
          id: string;
          repository_full_name: string;
          repository_url: string;
          repository_language: string | null;
          repository_stars: number;
          repository_description: string | null;
          title: string;
          analysis_content: string;
          markdown_content: string;
          collection_name: string | null;
          collection_type: string | null;
          analyzed_at: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          repository_full_name: string;
          repository_url: string;
          repository_language?: string | null;
          repository_stars: number;
          repository_description?: string | null;
          title: string;
          analysis_content: string;
          markdown_content: string;
          collection_name?: string | null;
          collection_type?: string | null;
          analyzed_at?: string;
          created_at?: string;
        };
      };
    };
  };
}

let supabase: SupabaseClient<Database> | null = null;

export function initSupabase(): SupabaseClient<Database> {
  if (supabase) return supabase;
  
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;
  
  if (!supabaseUrl || !supabaseKey) {
    throw new Error('SUPABASE_URL and SUPABASE_ANON_KEY environment variables are required');
  }
  
  supabase = createClient<Database>(supabaseUrl, supabaseKey);
  return supabase;
}

export async function saveResultsToSupabase(results: RadarResult[]): Promise<void> {
  const client = initSupabase();
  
  for (const result of results) {
    // Insert collection record
    const { data: collection, error: collectionError } = await client
      .from('github_radar_collections')
      .insert({
        name: result.collection,
        type: result.type,
        language: result.language || null,
        timestamp: result.timestamp,
      })
      .select()
      .single();
    
    if (collectionError) {
      throw new Error(`Failed to insert collection: ${collectionError.message}`);
    }
    
    // Upsert repository records (insert or update if html_url exists)
    const repoUpserts = result.repositories.map((repo) => ({
      collection_id: collection.id,
      full_name: repo.full_name,
      html_url: repo.html_url,
      description: repo.description || null,
      language: repo.language,
      stars: repo.stars,
      forks: repo.forks,
      open_issues: repo.open_issues,
      stars_per_day: 'stars_per_day' in repo ? repo.stars_per_day : null,
      created_at: repo.created_at,
      pushed_at: repo.pushed_at,
      discovered_at: new Date().toISOString(), // Always update discovery time
    }));
    
    // Process repositories in batches to avoid large payload issues
    const BATCH_SIZE = 50;
    for (let i = 0; i < repoUpserts.length; i += BATCH_SIZE) {
      const batch = repoUpserts.slice(i, i + BATCH_SIZE);
      
      const { error: repoError } = await client
        .from('github_radar_repositories')
        .upsert(batch, {
          onConflict: 'html_url',
          ignoreDuplicates: false
        });
      
      if (repoError) {
        throw new Error(`Failed to upsert repositories: ${repoError.message}`);
      }
      
      // Small delay between batches to avoid overwhelming the database
      if (i + BATCH_SIZE < repoUpserts.length) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }
  }
}

export async function saveAnalysisToSupabase(analysis: {
  repo: any;
  title: string;
  analysis: string;
  markdown: string;
  collectionName?: string;
  collectionType?: string;
}): Promise<void> {
  const client = initSupabase();
  
  const { error } = await client
    .from('github_radar_analyses')
    .insert({
      repository_full_name: analysis.repo.full_name,
      repository_url: analysis.repo.html_url,
      repository_language: analysis.repo.language,
      repository_stars: analysis.repo.stargazers_count,
      repository_description: analysis.repo.description,
      title: analysis.title,
      analysis_content: analysis.analysis,
      markdown_content: analysis.markdown,
      collection_name: analysis.collectionName,
      collection_type: analysis.collectionType,
    });
  
  if (error) {
    throw new Error(`Failed to save analysis: ${error.message}`);
  }
}

export async function getLatestAnalyses(limit: number = 10): Promise<Database['public']['Tables']['github_radar_analyses']['Row'][]> {
  const client = initSupabase();
  
  const { data, error } = await client
    .from('github_radar_analyses')
    .select('*')
    .order('analyzed_at', { ascending: false })
    .limit(limit);
  
  if (error) {
    throw new Error(`Failed to fetch analyses: ${error.message}`);
  }
  
  return data || [];
}

export async function getAnalysisById(id: string): Promise<Database['public']['Tables']['github_radar_analyses']['Row'] | null> {
  const client = initSupabase();
  
  const { data, error } = await client
    .from('github_radar_analyses')
    .select('*')
    .eq('id', id)
    .single();
  
  if (error) {
    throw new Error(`Failed to fetch analysis: ${error.message}`);
  }
  
  return data;
}