import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/api_response.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final ApiError error;
  final VoidCallback? onRetry;

  const ErrorWidgetCustom({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              _getErrorTitle(),
              style: AppTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    if (error.code != null) {
      switch (error.code) {
        case 404:
          return Icons.search_off;
        case 503:
        case 500:
          return Icons.cloud_off;
        case 408:
          return Icons.access_time;
        default:
          return Icons.error_outline;
      }
    }
    return Icons.error_outline;
  }

  String _getErrorTitle() {
    if (error.code != null) {
      switch (error.code) {
        case 404:
          return 'Not Found';
        case 503:
          return 'Service Unavailable';
        case 500:
          return 'Server Error';
        case 408:
          return 'Request Timeout';
        default:
          return 'Something went wrong';
      }
    }
    return 'Something went wrong';
  }
}