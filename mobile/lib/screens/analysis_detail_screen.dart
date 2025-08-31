import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_theme.dart';
import '../models/analysis.dart';
import '../widgets/repository_info_card.dart';
import '../widgets/analysis_metadata.dart';

class AnalysisDetailScreen extends StatelessWidget {
  final Analysis analysis;

  const AnalysisDetailScreen({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          analysis.repoName,
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _launchUrl(analysis.repositoryUrl),
            tooltip: 'Open in GitHub',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAnalysis(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository Info Card
            RepositoryInfoCard(analysis: analysis),
            
            const SizedBox(height: 24),
            
            // Analysis Title
            Text(
              analysis.title,
              style: AppTheme.headlineLarge,
            ),
            
            const SizedBox(height: 16),
            
            // Analysis Metadata
            AnalysisMetadata(analysis: analysis),
            
            const SizedBox(height: 24),
            
            // Analysis Content
            _buildAnalysisContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.article_outlined,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Analysis',
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Use Markdown for rich text display
            MarkdownBody(
              data: analysis.markdownContent.isNotEmpty 
                  ? analysis.markdownContent 
                  : analysis.analysisContent,
              onTapLink: (text, href, title) {
                if (href != null) {
                  _launchUrl(href);
                }
              },
              styleSheet: MarkdownStyleSheet(
                h1: AppTheme.headlineLarge,
                h2: AppTheme.headlineMedium,
                h3: AppTheme.titleLarge,
                p: AppTheme.bodyLarge,
                listBullet: AppTheme.bodyLarge,
                code: AppTheme.bodyMedium.copyWith(
                  fontFamily: 'monospace',
                  backgroundColor: Colors.grey[100],
                ),
                codeblockDecoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _shareAnalysis(BuildContext context) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing feature coming soon!')),
    );
  }
}