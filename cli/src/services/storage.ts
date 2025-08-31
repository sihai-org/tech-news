import { promises as fs } from 'fs';
import { RadarResult, SlimRepo, FastGrowingRepo } from '../types/index.js';
import path from 'path';

export async function ensureDirectory(dir: string): Promise<void> {
  try {
    await fs.access(dir);
  } catch {
    await fs.mkdir(dir, { recursive: true });
  }
}

export async function saveResults(
  results: RadarResult[],
  outputDir: string,
  format: 'json' | 'csv' = 'json',
  includeTimestamp: boolean = true
): Promise<string> {
  await ensureDirectory(outputDir);
  
  const timestamp = new Date().toISOString().split('T')[0];
  const filename = includeTimestamp 
    ? `radar-${timestamp}.${format}`
    : `radar.${format}`;
  
  const filePath = path.join(outputDir, filename);
  
  if (format === 'json') {
    await fs.writeFile(filePath, JSON.stringify(results, null, 2), 'utf8');
  } else {
    const csv = convertToCSV(results);
    await fs.writeFile(filePath, csv, 'utf8');
  }
  
  return filePath;
}

function convertToCSV(results: RadarResult[]): string {
  const headers = [
    'timestamp',
    'collection',
    'type',
    'language',
    'full_name',
    'html_url',
    'description',
    'stars',
    'forks',
    'open_issues',
    'created_at',
    'pushed_at',
    'stars_per_day'
  ];
  
  const rows: string[] = [headers.join(',')];
  
  for (const result of results) {
    for (const repo of result.repositories) {
      const row = [
        result.timestamp,
        result.collection,
        result.type,
        result.language || '',
        `"${repo.full_name}"`,
        `"${repo.html_url}"`,
        `"${repo.description.replace(/"/g, '""')}"`,
        repo.stars.toString(),
        repo.forks.toString(),
        repo.open_issues.toString(),
        repo.created_at,
        repo.pushed_at,
        'stars_per_day' in repo ? repo.stars_per_day.toString() : ''
      ];
      rows.push(row.join(','));
    }
  }
  
  return rows.join('\n');
}