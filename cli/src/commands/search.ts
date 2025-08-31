import { trending, fastestGrowing, newlyPublished } from '../core/radar.js';
import { SlimRepo, FastGrowingRepo } from '../types/index.js';

function printRepo(repo: SlimRepo, index: number): void {
  const num = (index + 1).toString().padStart(2, '0');
  console.log(`${num}. ${repo.full_name}  ⭐ ${repo.stars}  [${repo.language || 'Unknown'}]`);
  console.log(`    ${repo.html_url}`);
  if (repo.description) {
    console.log(`    ${repo.description}`);
  }
  console.log(`    created: ${repo.created_at}  pushed: ${repo.pushed_at}`);
}

function printFastGrowingRepo(repo: FastGrowingRepo, index: number): void {
  const num = (index + 1).toString().padStart(2, '0');
  console.log(`${num}. ${repo.full_name}  ⭐ ${repo.stars}  ~ ${repo.stars_per_day}★/day  [${repo.language || 'Unknown'}]`);
  console.log(`    ${repo.html_url}`);
  if (repo.description) {
    console.log(`    ${repo.description}`);
  }
  console.log(`    created: ${repo.created_at}  pushed: ${repo.pushed_at}`);
}

export async function searchCommand(options: {
  language?: string;
  trendingDays: string;
  growthDays: string;
  newDays: string;
  minStars: string;
  perPage: string;
  maxPages: string;
}): Promise<void> {
  if (!process.env.GITHUB_TOKEN) {
    console.error('WARNING: GITHUB_TOKEN not set. You may hit low rate limits.');
  }

  const trendingDays = parseInt(options.trendingDays, 10);
  const growthDays = parseInt(options.growthDays, 10);
  const newDays = parseInt(options.newDays, 10);
  const minStars = parseInt(options.minStars, 10);
  const perPage = parseInt(options.perPage, 10);
  const maxPages = parseInt(options.maxPages, 10);

  try {
    console.log('\n=== Trending (approx) ===');
    const trendingRepos = await trending(options.language, trendingDays, perPage, maxPages);
    trendingRepos.slice(0, 50).forEach(printRepo);

    console.log('\n=== Fastest-growing (stars/day) ===');
    const growingRepos = await fastestGrowing(options.language, growthDays, minStars, perPage, maxPages);
    growingRepos.slice(0, 50).forEach(printFastGrowingRepo);

    console.log('\n=== Newly published ===');
    const newRepos = await newlyPublished(options.language, newDays, perPage, maxPages);
    newRepos.slice(0, 50).forEach(printRepo);
    
  } catch (error) {
    console.error('Error:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}