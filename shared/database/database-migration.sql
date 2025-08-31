-- Migration script for GitHub Radar database updates
-- Run this in your Supabase SQL Editor if the tables already exist

-- Migration 1: Add title column to existing github_radar_analyses table
ALTER TABLE github_radar_analyses 
ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT 'GitHub项目分析报告';

-- Remove the default after adding the column (to make it required for new inserts)
ALTER TABLE github_radar_analyses 
ALTER COLUMN title DROP DEFAULT;

-- Migration 2: Add unique constraint to html_url for upsert functionality
-- First, remove any duplicate html_url entries (keep the most recent one)
DELETE FROM github_radar_repositories 
WHERE id NOT IN (
  SELECT DISTINCT ON (html_url) id 
  FROM github_radar_repositories 
  ORDER BY html_url, discovered_at DESC
);

-- Add unique constraint to html_url column
ALTER TABLE github_radar_repositories 
ADD CONSTRAINT IF NOT EXISTS unique_html_url UNIQUE (html_url);

-- Create index on html_url for better upsert performance (if not exists)
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_html_url ON github_radar_repositories(html_url);