-- Migration script to add title column to existing github_radar_analyses table
-- Run this in your Supabase SQL Editor if the table already exists

-- Add title column if it doesn't exist
ALTER TABLE github_radar_analyses 
ADD COLUMN IF NOT EXISTS title TEXT NOT NULL DEFAULT 'GitHub项目分析报告';

-- Remove the default after adding the column (to make it required for new inserts)
ALTER TABLE github_radar_analyses 
ALTER COLUMN title DROP DEFAULT;