import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postra/src/features/search/presentation/widgets/search_bar.dart';
import 'package:postra/src/features/search/presentation/widgets/search_result_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<Map<String, String>>? _searchResults;

  // Mock data for Recent Searches and Popular Topics
  final List<String> _recentSearches = [
    'Minimalist design',
    'iOS tips',
    'Blogging',
  ];
  final List<String> _popularTopics = [
    'Design',
    'Tech',
    'Lifestyle',
    'Writing',
    'Productivity',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final text = _searchController.text.trim();
    setState(() {
      _isSearching = text.isNotEmpty;
      if (_isSearching) {
        // Mock search logic
        if (text.toLowerCase() == 'minimalist') {
          _searchResults = []; // Mock "no results"
        } else if (text.length > 2) {
          _searchResults = [
            {
              'topic': 'Design Theory',
              'title': 'The Art of Simplicity',
              'snippet':
                  'Exploring how reduction leads to better clarity in user interfaces...',
              'time': '1h ago',
              'views': '1.2k views',
            },
          ];
        } else {
          _searchResults = null;
        }
      } else {
        _searchResults = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          _buildContent(context, isDark, theme),

          // Sticky Header (Simplified: no "Search" title as per latest mockup)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 52, 16, 12),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
              ),
              child: AppSearchBar(
                controller: _searchController,
                onCancel: () {
                  _searchController.clear();
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    bool isDark,
    CupertinoThemeData theme,
  ) {
    if (!_isSearching) {
      // New Initial State UI
      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recent Searches
            _buildSectionHeader(
              title: 'RECENT SEARCHES',
              actionLabel: 'Clear All',
              onAction: () {
                setState(() => _recentSearches.clear());
              },
              isDark: isDark,
            ),
            ..._recentSearches.map(
              (search) => _buildRecentSearchItem(search, isDark),
            ),

            const SizedBox(height: 40),

            // Popular Topics
            _buildSectionHeader(title: 'POPULAR TOPICS', isDark: isDark),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _popularTopics
                  .map((topic) => _buildTopicChip(topic, isDark, theme))
                  .toList(),
            ),

            const SizedBox(height: 60),

            // Decorative Footer
            Center(
              child: Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.manage_search,
                        size: 48,
                        color: theme.primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Search for creators, topics, or specific posts to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Inter',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      );
    }

    if (_searchResults == null || _searchResults!.isEmpty) {
      // Show "No Results" view
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
              const Icon(Icons.search, size: 80, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 24),
              Text(
                'No results found for "${_searchController.text}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Inter',
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check your spelling or try searching for something else.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontFamily: 'Inter',
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _searchController.clear();
                },
                child: Text(
                  'Try a new search',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                    decoration: TextDecoration.underline,
                    decorationThickness: 1,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show Results
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                // Results Header
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RESULTS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          letterSpacing: 1.2,
                          fontFamily: 'Inter',
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Text(
                        'Sort by relevance',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.primaryColor,
                          fontFamily: 'Inter',
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
                ..._searchResults!.map(
                  (result) => SearchResultItem(
                    topic: result['topic']!,
                    title: result['title']!,
                    snippet: result['snippet']!,
                    time: result['time']!,
                    views: result['views']!,
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onAction,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              letterSpacing: 1.2,
              fontFamily: 'Inter',
              decoration: TextDecoration.none,
            ),
          ),
          if (actionLabel != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: Size(0, 0),
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF2F2F7),
            width: 1,
          ),
        ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(vertical: 12),
        onPressed: () {
          _searchController.text = search;
        },
        child: Row(
          children: [
            const Icon(Icons.history, size: 20, color: Color(0xFFCBD5E1)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                search,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            Icon(
              Icons.close,
              size: 18,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicChip(String topic, bool isDark, CupertinoThemeData theme) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        _searchController.text = topic;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          topic,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
