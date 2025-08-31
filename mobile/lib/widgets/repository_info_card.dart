import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/analysis.dart';

class RepositoryInfoCard extends StatelessWidget {
  final Analysis analysis;

  const RepositoryInfoCard({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository name and URL
            Row(
              children: [
                const Icon(
                  Icons.account_tree,
                  size: 20,
                  color: AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    analysis.repositoryFullName,
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Repository description
            if (analysis.repositoryDescription != null)
              Text(
                analysis.repositoryDescription!,
                style: AppTheme.bodyLarge,
              ),
            
            const SizedBox(height: 16),
            
            // Repository stats
            Row(
              children: [
                // Language
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
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(width: 20),
                ],
                
                // Stars
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber[700],
                ),
                const SizedBox(width: 4),
                Text(
                  analysis.starsDisplay,
                  style: AppTheme.bodyMedium,
                ),
                
                const Spacer(),
                
                // Collection type badge
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
          ],
        ),
      ),
    );
  }

  Color _getLanguageColor(String language) {
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
}