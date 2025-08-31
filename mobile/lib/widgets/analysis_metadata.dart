import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/app_theme.dart';
import '../models/analysis.dart';

class AnalysisMetadata extends StatelessWidget {
  final Analysis analysis;

  const AnalysisMetadata({
    super.key,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Analysis date
        const Icon(
          Icons.schedule,
          size: 16,
          color: AppTheme.textHint,
        ),
        const SizedBox(width: 4),
        Text(
          'Analyzed ${_formatDate(analysis.analyzedAt)}',
          style: AppTheme.bodySmall,
        ),
        
        const SizedBox(width: 16),
        
        // Collection name if available
        if (analysis.collectionName != null) ...[
          const Icon(
            Icons.label_outline,
            size: 16,
            color: AppTheme.textHint,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              analysis.collectionName!,
              style: AppTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 7) {
      return DateFormat('MMM d, y').format(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}