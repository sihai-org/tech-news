import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../models/analysis.dart';

class AnalysisCard extends StatelessWidget {
  final Analysis analysis;
  final VoidCallback? onTap;

  const AnalysisCard({
    super.key,
    required this.analysis,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with repo info and collection type
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_tree,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            analysis.repositoryFullName,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCollectionTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      analysis.collectionTypeDisplay,
                      style: AppTheme.bodySmall.copyWith(
                        color: _getCollectionTypeColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Analysis title
              Text(
                analysis.title,
                style: AppTheme.titleLarge,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              // Analysis summary
              if (analysis.summary.isNotEmpty)
                Text(
                  analysis.summary,
                  style: AppTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Repository metadata
              Row(
                children: [
                  if (analysis.repositoryLanguage != null) ...[
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getLanguageColor(analysis.repositoryLanguage!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      analysis.languageDisplay,
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                  ],
                  Icon(
                    Icons.star_border,
                    size: 14,
                    color: Colors.amber[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    analysis.starsDisplay,
                    style: AppTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(analysis.analyzedAt),
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCollectionTypeColor() {
    switch (analysis.collectionType) {
      case 'trending':
        return AppTheme.gitHubBlue;
      case 'fastest_growing':
        return AppTheme.gitHubGreen;
      case 'newly_published':
        return AppTheme.gitHubYellow;
      default:
        return AppTheme.primaryColor;
    }
  }

  Color _getLanguageColor(String language) {
    // Simple color mapping for popular languages
    switch (language.toLowerCase()) {
      case 'typescript':
      case 'javascript':
        return const Color(0xFFF7DF1E);
      case 'python':
        return const Color(0xFF3776AB);
      case 'java':
        return const Color(0xFFED8B00);
      case 'rust':
        return const Color(0xFFDEA584);
      case 'go':
        return const Color(0xFF00ADD8);
      case 'swift':
        return const Color(0xFFFA7343);
      case 'kotlin':
        return const Color(0xFF7F52FF);
      case 'dart':
        return const Color(0xFF0175C2);
      default:
        return AppTheme.textHint;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}