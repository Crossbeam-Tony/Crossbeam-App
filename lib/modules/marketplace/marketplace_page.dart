import 'package:flutter/material.dart';
import '../../models/marketplace_listing.dart';
import '../../shared/avatar.dart';
import '../../config/design_system.dart';
import '../../components/sliding_card.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedCondition = 'All';
  String _selectedCrew = 'All';
  bool _showFavoritesOnly = false;
  bool _showMyListingsOnly = false;
  List<MarketplaceListing> _filteredListings = [];
  final Set<String> _favorites = {};

  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Books',
    'Sports',
    'Home & Garden',
    'Other'
  ];

  final List<String> _conditions = [
    'All',
    'New',
    'Used - Like New',
    'Used - Excellent',
    'Used - Good',
    'Used - Fair',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with empty list for now - will be replaced with live data
    _filteredListings = <MarketplaceListing>[];
    _filterListings();
  }

  void _filterListings() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredListings = <MarketplaceListing>[]; // Empty for now
      } else {
        _filteredListings = <MarketplaceListing>[].where((listing) {
          return listing.category == _selectedCategory;
        }).toList();
      }
    });
  }

  void _searchListings(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterListings();
      } else {
        _filteredListings = <MarketplaceListing>[].where((listing) {
          return listing.title.toLowerCase().contains(query.toLowerCase()) ||
              listing.description.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredListings = <MarketplaceListing>[].where((listing) {
        // Category filter
        if (_selectedCategory != 'All' &&
            listing.category != _selectedCategory) {
          return false;
        }

        // Condition filter
        if (_selectedCondition != 'All' &&
            listing.condition != _selectedCondition) {
          return false;
        }

        // Crew filter
        if (_selectedCrew != 'All' && listing.crew != _selectedCrew) {
          return false;
        }

        // Search filter
        if (_searchController.text.isNotEmpty) {
          final searchTerm = _searchController.text.toLowerCase();
          if (!listing.title.toLowerCase().contains(searchTerm) &&
              !listing.description.toLowerCase().contains(searchTerm) &&
              !listing.seller.toLowerCase().contains(searchTerm)) {
            return false;
          }
        }

        // Favorites filter
        if (_showFavoritesOnly && !_favorites.contains(listing.id)) {
          return false;
        }

        // My listings filter
        if (_showMyListingsOnly && listing.sellerId != 'u1') {
          // Assuming current user is u1
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _toggleFavorite(String listingId) {
    setState(() {
      if (_favorites.contains(listingId)) {
        _favorites.remove(listingId);
      } else {
        _favorites.add(listingId);
      }
    });
    _applyFilters();
  }

  void _onCardOpen(int index) {
    // _openCardIndex is removed as per the instructions
  }

  void _onCardClose() {
    // _openCardIndex is removed as per the instructions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: Icon(
                _showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
                if (_showFavoritesOnly) _showMyListingsOnly = false;
              });
              _applyFilters();
            },
          ),
          IconButton(
            icon:
                Icon(_showMyListingsOnly ? Icons.person : Icons.person_outline),
            onPressed: () {
              setState(() {
                _showMyListingsOnly = !_showMyListingsOnly;
                if (_showMyListingsOnly) _showFavoritesOnly = false;
              });
              _applyFilters();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search marketplace...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilters();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              onChanged: _searchListings,
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Category', _selectedCategory, _categories,
                    (value) {
                  setState(() => _selectedCategory = value);
                  _applyFilters();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Condition', _selectedCondition, _conditions,
                    (value) {
                  setState(() => _selectedCondition = value);
                  _applyFilters();
                }),
                const SizedBox(width: 8),
                _buildFilterChip('Crew', _selectedCrew, [
                  'All',
                  'Photography',
                  'Fishing',
                  'Hunting',
                  'Cars',
                  'Art',
                  'Camping',
                  'Gaming',
                  'Coding',
                  'Carpentry',
                  'Guns',
                  'Fitness',
                  'DIY',
                  'Parenting',
                  'Cooking',
                  'Music',
                  'Travel',
                  'Outdoors',
                  'Film',
                  'Sports',
                  'Books',
                  'Tech',
                  'Science',
                  'Makers',
                  'Pets',
                  'Crafts'
                ], (value) {
                  setState(() => _selectedCrew = value);
                  _applyFilters();
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredListings.length} items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'All';
                      _selectedCondition = 'All';
                      _selectedCrew = 'All';
                      _showFavoritesOnly = false;
                      _showMyListingsOnly = false;
                      _searchController.clear();
                    });
                    _applyFilters();
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Marketplace Items Grid
          Expanded(
            child: _filteredListings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters or search terms',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                        ),
                      ],
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _filteredListings.length,
                      itemBuilder: (context, index) {
                        final listing = _filteredListings[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          height: 250,
                          child: SlidingCard(
                            topLayer: (slideProgress) =>
                                _buildTopLayer(listing, index, slideProgress),
                            leftBottomLayer: (slideProgress) =>
                                _buildLeftBottomLayer(listing, index),
                            rightBottomLayer: (slideProgress) =>
                                _buildRightBottomLayer(listing, index),
                            onSlideLeft: () => _onCardOpen(index),
                            onSlideRight: () => _onCardClose(),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create listing page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Create listing feature coming soon!')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedValue,
      List<String> options, Function(String) onChanged) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => options
          .map((option) => PopupMenuItem(
                value: option,
                child: Text(option),
              ))
          .toList(),
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selectedValue == 'All'
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : DesignSystem.mutedTangerine,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedValue == 'All'
                ? Colors.grey[300]!
                : DesignSystem.mutedTangerine,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedValue',
              style: TextStyle(
                color: selectedValue == 'All' ? Colors.grey[700] : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: selectedValue == 'All' ? Colors.grey[700] : Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildTopLayer(
      MarketplaceListing listing, int index, double slideProgress) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Avatar(
                  imageUrl: listing.imageUrl ?? '',
                  size: 36,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        listing.title,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '\$${listing.price.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontSize: 12,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              listing.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftBottomLayer(MarketplaceListing listing, int index) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(Icons.message, 'Contact', () {}),
            const SizedBox(height: 8),
            _buildActionButton(Icons.favorite_border, 'Favorite',
                () => _toggleFavorite(listing.id)),
            const SizedBox(height: 8),
            _buildActionButton(Icons.share, 'Share', () {}),
            const SizedBox(height: 8),
            _buildActionButton(Icons.bookmark_border, 'Save', () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildRightBottomLayer(MarketplaceListing listing, int index) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          // Listing details header
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Listing Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
          // Listing details content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                      'Price', '\$${listing.price.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Condition', listing.condition ?? 'Not specified'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                      'Category', listing.category ?? 'Uncategorized'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Seller', listing.seller),
                  const SizedBox(height: 8),
                  _buildDetailRow('Posted', _formatTimeAgo(listing.createdAt)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
