#!/usr/bin/env node

import 'dotenv/config';
import { Command } from 'commander';
import { runDailyRadar } from './commands/daily.js';
import { searchCommand } from './commands/search.js';
import { analyzeCommand } from './commands/analyze.js';
import { analyzeTopCommand } from './commands/analyze-top.js';
import { publishToWechatCommand } from './commands/publish-wechat.js';


async function main(): Promise<void> {
  const program = new Command();
  
  program
    .name('github-radar')
    .description('GitHub Open Source Radar')
    .version('1.0.0');

  program
    .command('search')
    .description('Interactive search mode')
    .option('--language <language>', 'Filter by main language, e.g. Python/TypeScript/Rust')
    .option('--trending-days <days>', 'Window for trending (days)', '7')
    .option('--growth-days <days>', 'Window for fastest-growing candidate pool (days)', '30')
    .option('--new-days <days>', 'Window for newly published (days)', '3')
    .option('--min-stars <stars>', 'Min stars for fastest-growing candidates', '50')
    .option('--per-page <count>', 'Results per page (max 100)', '50')
    .option('--max-pages <count>', 'Max pages to fetch', '2')
    .action(searchCommand);

  program
    .command('daily')
    .description('Run daily radar based on config file')
    .option('-c, --config <path>', 'Path to config file', './radar-config.json')
    .action(async (options) => {
      if (!process.env.GITHUB_TOKEN) {
        console.error('WARNING: GITHUB_TOKEN not set. You may hit low rate limits.');
      }
      
      await runDailyRadar(options.config);
    });

  program
    .command('analyze')
    .description('Analyze a repository with AI and generate report')
    .argument('<repo>', 'Repository name (owner/repo)')
    .option('-o, --output <dir>', 'Output directory for reports', './reports')
    .option('-f, --format <format>', 'Output format (markdown|json)', 'markdown')
    .action(analyzeCommand);

  program
    .command('analyze-top')
    .description('Analyze top #1 repository from each collection')
    .option('-c, --config <path>', 'Path to config file', './radar-config.json')
    .option('-o, --output <dir>', 'Output directory for reports', './reports')
    .option('-d, --delay <ms>', 'Delay between analyses (ms)', '5000')
    .option('--no-save-to-db', 'Skip saving to database')
    .action(analyzeTopCommand);

  program
    .command('publish-wechat')
    .description('Publish analysis to WeChat Official Account draft')
    .option('--id <id>', 'Analysis ID to publish')
    .option('--latest', 'Publish the latest analysis')
    .option('--list', 'List available analyses')
    .action(publishToWechatCommand);

  program.parse();
}

if (require.main === module) {
  main().catch(console.error);
}