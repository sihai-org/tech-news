import 'package:flutter/material.dart';

import '../config/app_theme.dart';

class FilterBar extends StatelessWidget {
  final String? selectedLanguage;
  final String? selectedCollectionType;
  final List<String> availableLanguages;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<String?> onCollectionTypeChanged;

  const FilterBar({
    super.key,
    required this.selectedLanguage,
    required this.selectedCollectionType,
    required this.availableLanguages,
    required this.onLanguageChanged,
    required this.onCollectionTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Language Filter
          Expanded(
            child: _buildFilterChip(
              context,
              label: selectedLanguage ?? 'All Languages',
              isSelected: selectedLanguage != null,
              onTap: () => _showLanguagePicker(context),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Collection Type Filter
          Expanded(
            child: _buildFilterChip(
              context,
              label: selectedCollectionType != null 
                  ? _getCollectionTypeDisplay(selectedCollectionType!)
                  : 'All Types',
              isSelected: selectedCollectionType != null,
              onTap: () => _showCollectionTypePicker(context),
            ),
          ),
          
          // Clear Filters Button
          if (selectedLanguage != null || selectedCollectionType != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilters,
              tooltip: 'Clear filters',
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryColor
                : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: isSelected 
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _LanguagePicker(
        availableLanguages: availableLanguages,
        selectedLanguage: selectedLanguage,
        onLanguageSelected: onLanguageChanged,
      ),
    );
  }

  void _showCollectionTypePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CollectionTypePicker(
        selectedCollectionType: selectedCollectionType,
        onCollectionTypeSelected: onCollectionTypeChanged,
      ),
    );
  }

  void _clearFilters() {
    onLanguageChanged(null);
    onCollectionTypeChanged(null);
  }

  String _getCollectionTypeDisplay(String type) {
    switch (type) {
      case 'trending':
        return 'Trending';
      case 'fastest_growing':
        return 'Fast Growing';
      case 'newly_published':
        return 'New Projects';
      default:
        return type;
    }
  }
}

class _LanguagePicker extends StatelessWidget {
  final List<String> availableLanguages;
  final String? selectedLanguage;
  final ValueChanged<String?> onLanguageSelected;

  const _LanguagePicker({
    required this.availableLanguages,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Language',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // All Languages option
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('All Languages'),
            trailing: selectedLanguage == null 
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
            onTap: () {
              onLanguageSelected(null);
              Navigator.pop(context);
            },
          ),
          
          const Divider(),
          
          // Available languages
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableLanguages.length,
              itemBuilder: (context, index) {
                final language = availableLanguages[index];
                final isSelected = selectedLanguage == language;
                
                return ListTile(
                  title: Text(language),
                  trailing: isSelected 
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    onLanguageSelected(language);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CollectionTypePicker extends StatelessWidget {
  final String? selectedCollectionType;
  final ValueChanged<String?> onCollectionTypeSelected;

  const _CollectionTypePicker({
    required this.selectedCollectionType,
    required this.onCollectionTypeSelected,
  });

  static const List<CollectionTypeOption> _collectionTypes = [
    CollectionTypeOption('trending', 'Trending', 'Currently popular repositories'),
    CollectionTypeOption('fastest_growing', 'Fast Growing', 'Rapidly gaining stars'),
    CollectionTypeOption('newly_published', 'New Projects', 'Recently created repositories'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Collection Type',
            style: AppTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // All Types option
          ListTile(
            leading: const Icon(Icons.all_inclusive),
            title: const Text('All Types'),
            trailing: selectedCollectionType == null 
                ? const Icon(Icons.check, color: AppTheme.primaryColor)
                : null,
            onTap: () {
              onCollectionTypeSelected(null);
              Navigator.pop(context);
            },
          ),
          
          const Divider(),
          
          // Collection types
          ..._collectionTypes.map((type) {
            final isSelected = selectedCollectionType == type.value;
            
            return ListTile(
              leading: Icon(_getCollectionTypeIcon(type.value)),
              title: Text(type.label),
              subtitle: Text(type.description),
              trailing: isSelected 
                  ? const Icon(Icons.check, color: AppTheme.primaryColor)
                  : null,
              onTap: () {
                onCollectionTypeSelected(type.value);
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }

  IconData _getCollectionTypeIcon(String type) {
    switch (type) {
      case 'trending':
        return Icons.trending_up;
      case 'fastest_growing':
        return Icons.speed;
      case 'newly_published':
        return Icons.fiber_new;
      default:
        return Icons.category;
    }
  }
}

class CollectionTypeOption {
  final String value;
  final String label;
  final String description;

  const CollectionTypeOption(this.value, this.label, this.description);
}