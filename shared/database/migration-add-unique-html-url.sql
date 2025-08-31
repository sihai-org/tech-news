-- Migration: Add unique constraint to html_url for upsert functionality
-- Run this in your Supabase SQL Editor

-- First, remove any duplicate html_url entries (keep the most recent one)
DELETE FROM github_radar_repositories 
WHERE id NOT IN (
  SELECT DISTINCT ON (html_url) id 
  FROM github_radar_repositories 
  ORDER BY html_url, discovered_at DESC
);

-- Add unique constraint to html_url column
ALTER TABLE github_radar_repositories 
ADD CONSTRAINT unique_html_url UNIQUE (html_url);

-- Create index on html_url for better upsert performance (if not exists)
CREATE INDEX IF NOT EXISTS idx_github_radar_repositories_html_url ON github_radar_repositories(html_url);