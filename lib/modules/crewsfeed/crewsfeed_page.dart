import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/feed_item.dart';
import '../../components/sliding_card.dart';
import 'package:provider/provider.dart';
import '../../services/data_service.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/feed_card_builders.dart';

class CrewsfeedPage extends StatefulWidget {
  const CrewsfeedPage({super.key});

  @override
  State<CrewsfeedPage> createState() => _CrewsfeedPageState();
}

class _CrewsfeedPageState extends State<CrewsfeedPage>
    with TickerProviderStateMixin {
  final List<dynamic> _displayedItems = [];
  List<dynamic> _allItems = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _loadFeedItems();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize displayed items
    _loadMoreItems();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreItems();
    }
  }

  void _loadMoreItems() {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          // Filter items based on search query and selected filter
          List<dynamic> filteredItems = _allItems.where((item) {
            bool matchesSearch = _searchQuery.isEmpty ||
                _getItemTitle(item)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                _getItemDescription(item)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());

            bool matchesFilter = _selectedFilter == 'All' ||
                (_selectedFilter == 'Projects' && item is ProjectFeedItem) ||
                (_selectedFilter == 'Events' && item is EventFeedItem) ||
                (_selectedFilter == 'Marketplace' && item is ListingFeedItem);

            return matchesSearch && matchesFilter;
          }).toList();

          // Calculate pagination
          final startIndex = _currentPage * _itemsPerPage;
          final endIndex =
              (startIndex + _itemsPerPage).clamp(0, filteredItems.length);

          if (startIndex < filteredItems.length) {
            final newItems = filteredItems.sublist(startIndex, endIndex);
            _displayedItems.addAll(newItems);
            _currentPage++;
          }

          _isLoadingMore = false;
        });
      }
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterItems();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterItems();
    });
  }

  void _filterItems() {
    setState(() {
      // Reset to first page when filtering
      _currentPage = 0;
      _displayedItems.clear();

      // Load filtered items
      _loadMoreItems();
    });
  }

  void _loadFeedItems() {
    final dataService = Provider.of<DataService>(context, listen: false);

    // Create FeedItems from the data sources
    List<FeedItem> projectItems = dataService.projects
        .map((project) => ProjectFeedItem(project))
        .toList();
    List<FeedItem> eventItems =
        dataService.events.map((event) => EventFeedItem(event)).toList();
    List<FeedItem> listingItems = dataService.marketplaceListings
        .map((listing) => ListingFeedItem(listing))
        .toList();

    // Combine all FeedItems
    _allItems = [
      ...projectItems,
      ...eventItems,
      ...listingItems,
    ];

    // Shuffle to create a random feed
    _allItems.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.20),
                    ),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.50),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', _selectedFilter == 'All'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Projects', _selectedFilter == 'Projects'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Events', _selectedFilter == 'Events'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          'Marketplace', _selectedFilter == 'Marketplace'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Feed list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Simulate refreshing items from different sources
                await Future.delayed(const Duration(seconds: 1));
                setState(() {
                  // In a real app, this would fetch new items
                  // For now, just trigger a rebuild
                });
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: _displayedItems.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _displayedItems.length) {
                    // Loading indicator
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = _displayedItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6.0),
                    height: 320,
                    child: SlidingCard(
                      topLayer: (slideProgress) =>
                          _buildTopLayer(context, item, index, slideProgress),
                      leftBottomLayer: (slideProgress) =>
                          _buildLeftBottomLayer(item, index),
                      rightBottomLayer: (slideProgress) =>
                          _buildRightBottomLayer(item, index),
                      maxSwipeOffset: 160,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        _onFilterChanged(label);
      },
      selectedColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.20),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withValues(alpha: 0.30),
      side: BorderSide(
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline.withValues(alpha: 0.20),
      ),
    );
  }

  String _getItemTitle(dynamic item) {
    if (item is ProjectFeedItem) return item.project.title;
    if (item is EventFeedItem) return item.event.title;
    if (item is ListingFeedItem) return item.listing.title;
    return '';
  }

  String _getItemDescription(dynamic item) {
    if (item is ProjectFeedItem) return item.project.description;
    if (item is EventFeedItem) return item.event.description;
    if (item is ListingFeedItem) return item.listing.description;
    return '';
  }

  Widget _buildTopLayer(
      BuildContext context, dynamic item, int index, double slideProgress) {
    // Use the feed router to build the appropriate card
    if (item is FeedItem) {
      return buildFeedItem(item);
    } else {
      // Fallback for any non-FeedItem items
      return const SizedBox();
    }
  }

  Widget _buildLeftBottomLayer(dynamic item, int index) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context)
                .colorScheme
                .primaryContainer
                .withValues(alpha: 0.10),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(Icons.favorite_border, 'Like', () {}),
            const SizedBox(height: 4),
            _buildActionButton(Icons.share, 'Share', () {}),
            const SizedBox(height: 4),
            _buildActionButton(Icons.bookmark_border, 'Save', () {}),
            const SizedBox(height: 4),
            _buildActionButton(Icons.flag_outlined, 'Report', () {}),
            const SizedBox(height: 4),
            _buildActionButton(Icons.person_add_outlined, 'Follow', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildRightBottomLayer(dynamic item, int index) {
    return GestureDetector(
      onTap: () {
        // Navigate to the appropriate detail page based on item type
        if (item is ProjectFeedItem) {
          context.push('/project/${item.project.id}');
        } else if (item is EventFeedItem) {
          context.push('/event/${item.event.id}');
        } else if (item is ListingFeedItem) {
          context.push('/listing/${item.listing.id}');
        }
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: 0.10),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.20),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 18, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Center(
                child: Text(
                  'Tap to view details',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return InkWell(
      onTap: () {
        onPressed();
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFeedItem(FeedItem item) {
    if (item is ProjectFeedItem) {
      return buildProjectCard(item.project);
    } else if (item is EventFeedItem) {
      return buildEventCard(item.event);
    } else if (item is ListingFeedItem) {
      return buildListingCard(item.listing);
    } else {
      return const SizedBox.shrink();
    }
  }
}
