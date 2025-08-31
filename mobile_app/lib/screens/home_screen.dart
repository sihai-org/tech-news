import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../config/app_config.dart';
import '../config/app_theme.dart';
import '../providers/analysis_provider.dart';
import '../widgets/analysis_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_widget.dart';
import 'analysis_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    // Initialize data loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearch ? _buildSearchField() : Text(AppConfig.appName),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AnalysisProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              FilterBar(
                selectedLanguage: provider.selectedLanguage,
                selectedCollectionType: provider.selectedCollectionType,
                availableLanguages: provider.availableLanguages,
                onLanguageChanged: provider.setLanguageFilter,
                onCollectionTypeChanged: provider.setCollectionTypeFilter,
              ),
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: const InputDecoration(
        hintText: 'Search analyses...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppTheme.textHint),
      ),
      style: const TextStyle(color: AppTheme.textPrimary),
      onSubmitted: _performSearch,
    );
  }

  Widget _buildContent(AnalysisProvider provider) {
    if (provider.isLoading && provider.analyses.isEmpty) {
      return const LoadingWidget();
    }

    if (provider.error != null && provider.analyses.isEmpty) {
      return ErrorWidgetCustom(
        error: provider.error!,
        onRetry: () => provider.loadAnalyses(refresh: true),
      );
    }

    if (provider.analyses.isEmpty) {
      return _buildEmptyState();
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      enablePullUp: provider.hasNextPage,
      onRefresh: () => _onRefresh(provider),
      onLoading: () => _onLoading(provider),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: provider.analyses.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.analyses.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final analysis = provider.analyses[index];
          return AnalysisCard(
            analysis: analysis,
            onTap: () => _navigateToDetail(analysis),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: AppTheme.textHint,
          ),
          SizedBox(height: 16),
          Text(
            'No analyses found',
            style: AppTheme.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later',
            style: AppTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        // Clear search results if any
        context.read<AnalysisProvider>().loadAnalyses(refresh: true);
      }
    });
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<AnalysisProvider>().searchAnalyses(query.trim());
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        context.read<AnalysisProvider>().loadAnalyses(refresh: true);
        break;
      case 'settings':
        // TODO: Navigate to settings screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings coming soon!')),
        );
        break;
    }
  }

  void _onRefresh(AnalysisProvider provider) async {
    await provider.loadAnalyses(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoading(AnalysisProvider provider) async {
    await provider.loadMoreAnalyses();
    if (provider.hasNextPage) {
      _refreshController.loadComplete();
    } else {
      _refreshController.loadNoData();
    }
  }

  void _navigateToDetail(analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisDetailScreen(analysis: analysis),
      ),
    );
  }
}