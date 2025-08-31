-- GitHub Radar Database Schema
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS github_radar_collections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('trending', 'fastest_growing', 'newly_published')),
  language TEXT,
  timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS github_radar_repositories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id UUID NOT NULL REFERENCES github_radar_collections(id) ON DELETE CASCADE,
  full_name TEXT NOT NULL,
  html_url TEXT NOT NULL,
  description TEXT,
  language TEXT,
  stars INTEGER NOT NULL DEFAULT 0,
  forks INTEGER NOT NULL DEFAULT 0,
  open_issues INTEGER NOT NULL DEFAULT 0,
  stars_per_day DECIMAL(10,2), -- Only for fastest_growing type
  created_at TIMESTAMPTZ NOT NULL,
  pushed_at TIMESTAMPTZ NOT NULL,
  discovered_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_github_radar_collections_timestamp ON github_radar_collections(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_github_radar_collections_type ON github_radar_collections(type);
CREATE INDEX IF NOT EXISTS idx_github_radar_collections_language ON github_radar_collections(language);
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_collection_id ON github_radar_repositories(collection_id);
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_stars ON github_radar_repositories(stars DESC);
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_language ON github_radar_repositories(language);
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_discovered_at ON github_radar_repositories(discovered_at DESC);

CREATE TABLE IF NOT EXISTS github_radar_analyses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  repository_full_name TEXT NOT NULL,
  repository_url TEXT NOT NULL,
  repository_language TEXT,
  repository_stars INTEGER NOT NULL DEFAULT 0,
  repository_description TEXT,
  title TEXT NOT NULL,
  analysis_content TEXT NOT NULL,
  markdown_content TEXT NOT NULL,
  collection_name TEXT,
  collection_type TEXT,
  analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for analyses table
CREATE INDEX IF NOT EXISTS idx_github_radar_analyses_repository ON github_radar_analyses(repository_full_name);
CREATE INDEX IF NOT EXISTS idx_github_radar_analyses_language ON github_radar_analyses(repository_language);
CREATE INDEX IF NOT EXISTS idx_github_radar_analyses_analyzed_at ON github_radar_analyses(analyzed_at DESC);
CREATE INDEX IF NOT EXISTS idx_github_radar_analyses_collection ON github_radar_analyses(collection_name);

-- Enable Row Level Security (optional)
-- ALTER TABLE github_radar_collections ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE github_radar_repositories ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE github_radar_analyses ENABLE ROW LEVEL SECURITY;