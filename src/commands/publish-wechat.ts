import { getLatestAnalyses, getAnalysisById } from '../services/supabase.js';
import { initWechatPublisher } from '../services/wechat.js';
import { generateTitleImage } from '../services/image-generator.js';
import path from 'path';
import { promises as fs } from 'fs';

export async function publishToWechatCommand(options: {
  id?: string;
  latest?: boolean;
  list?: boolean;
}): Promise<void> {
  try {
    // List available analyses
    if (options.list) {
      console.log('📋 Available analyses:');
      const analyses = await getLatestAnalyses(20);
      
      if (analyses.length === 0) {
        console.log('No analyses found in database.');
        return;
      }
      
      analyses.forEach((analysis, index) => {
        console.log(`${index + 1}. [${analysis.id.substring(0, 8)}] ${analysis.title}`);
        console.log(`   📁 ${analysis.repository_full_name} | ⭐ ${analysis.repository_stars} stars`);
        console.log(`   📅 ${new Date(analysis.analyzed_at).toLocaleString()}`);
        console.log('');
      });
      
      console.log('💡 Use --id <id> to publish a specific analysis');
      console.log('💡 Use --latest to publish the most recent analysis');
      return;
    }

    // Get analysis to publish
    let analysisToPublish;
    
    if (options.id) {
      analysisToPublish = await getAnalysisById(options.id);
      if (!analysisToPublish) {
        console.error(`❌ Analysis with ID ${options.id} not found`);
        process.exit(1);
      }
    } else if (options.latest) {
      const latest = await getLatestAnalyses(1);
      if (latest.length === 0) {
        console.error('❌ No analyses found in database');
        process.exit(1);
      }
      analysisToPublish = latest[0];
    } else {
      console.error('❌ Please specify --id <id>, --latest, or --list');
      console.log('💡 Use --list to see available analyses');
      process.exit(1);
    }

    console.log(`📝 Publishing analysis: ${analysisToPublish.title}`);
    console.log(`📁 Repository: ${analysisToPublish.repository_full_name}`);

    // Initialize WeChat publisher
    const wechatPublisher = initWechatPublisher();

    // Generate title image
    console.log(`🎨 Generating title image...`);
    const tempDir = './temp';
    await fs.mkdir(tempDir, { recursive: true });
    
    const imagePath = path.join(tempDir, `${analysisToPublish.id}.png`);
    await generateTitleImage(analysisToPublish.title, imagePath);
    
    console.log(`📤 Uploading image to WeChat...`);
    const thumbMediaId = await wechatPublisher.uploadImage(imagePath);
    
    // Clean up temp image
    await fs.unlink(imagePath);

    // Create draft
    const mediaId = await wechatPublisher.createDraft({
      title: analysisToPublish.title,
      content: analysisToPublish.analysis_content,
      digest: `${analysisToPublish.repository_full_name} - GitHub项目深度分析`,
      thumb_media_id: thumbMediaId,
    });

    console.log('✅ WeChat draft created successfully!');
    console.log(`📋 Media ID: ${mediaId}`);
    console.log('🔗 Please check your WeChat Official Account dashboard to review and publish the draft.');

  } catch (error) {
    console.error('❌ Failed to publish to WeChat:', error instanceof Error ? error.message : String(error));
    process.exit(1);
  }
}