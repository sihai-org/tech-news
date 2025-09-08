# 📋 Analyze Missing Repositories Guide

## 🚀 Quick Start with NPM Scripts

These convenient npm scripts help you analyze repositories that haven't been analyzed yet.

### 📊 **Check Statistics**
```bash
npm run analyze-missing:stats
```
**Shows**: Repository analysis statistics (total/analyzed/unanalyzed)

### 👀 **Preview Mode**  
```bash
npm run analyze-missing:preview
```
**Shows**: Top 10 repositories that would be analyzed (dry run)

### 🧪 **Small Batch (Beginner Friendly)**
```bash
npm run analyze-missing:small
```
**Analyzes**: 5 repositories with 5-second delays

### 📈 **Medium Batch (Recommended)**
```bash
npm run analyze-missing:medium
```
**Analyzes**: 20 repositories with 3-second delays

### 🔥 **All Repositories (Advanced)**
```bash
npm run analyze-missing
```
**Analyzes**: All unanalyzed repositories (1108 repos, ~8-15 hours)

## 📋 NPM Scripts Reference

| Script | Command | Description |
|--------|---------|-------------|
| `analyze-missing:stats` | `--dry-run --limit 1` | Show analysis statistics |
| `analyze-missing:preview` | `--dry-run --limit 10` | Preview next 10 repositories |
| `analyze-missing:small` | `--limit 5 --delay 5000` | Analyze 5 repos (safe for testing) |
| `analyze-missing:medium` | `--limit 20 --delay 3000` | Analyze 20 repos (recommended batch) |
| `analyze-missing` | *(no limits)* | Analyze all unanalyzed repositories |

## 🎯 Recommended Workflow

### 1. **First Time Setup**
```bash
# Check what needs to be analyzed
npm run analyze-missing:stats

# Preview the repositories
npm run analyze-missing:preview
```

### 2. **Test Run**
```bash
# Analyze a small batch first
npm run analyze-missing:small
```

### 3. **Production Use**
```bash
# Regular batch processing
npm run analyze-missing:medium

# Or customize with direct command
github-radar analyze-missing --limit 50 --delay 2000
```

## ⚙️ Environment Requirements

Make sure these environment variables are set:
```bash
DEEPSEEK_API_KEY=your_deepseek_api_key    # Required
SUPABASE_URL=your_supabase_url           # Required  
SUPABASE_ANON_KEY=your_supabase_key      # Required
GITHUB_TOKEN=your_github_token           # Recommended
```

## 📊 Current Status

- **Total Repositories**: 1,112
- **Already Analyzed**: 4
- **Need Analysis**: 1,108
- **Estimated Time**: 8-15 hours for all

## 💡 Tips

- Start with `analyze-missing:small` to test your setup
- Use `analyze-missing:preview` to see what's coming next
- Monitor API usage and costs with DeepSeek
- Run in batches during off-peak hours
- Check logs for any failed analyses

## 🚨 Important Notes

- Each analysis consumes DeepSeek API credits
- Rate limiting prevents API abuse
- Failed analyses are logged but don't stop the process
- Results are automatically saved to Supabase database