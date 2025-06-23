import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../shared/avatar.dart';

class MarketplaceDetailScreen extends StatelessWidget {
  final String listingId;

  const MarketplaceDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final listing = dataService.getMarketplaceListingById(listingId);

    if (listing == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Listing Not Found'),
        ),
        body: const Center(
          child: Text('The requested listing could not be found.'),
        ),
      );
    }

    final relatedListings = dataService.marketplaceListings
        .where((l) =>
            l.id != listing.id &&
            (l.crew == listing.crew || l.category == listing.category))
        .take(6)
        .toList();
    final sellerListings = dataService.marketplaceListings
        .where((l) => l.sellerId == listing.sellerId)
        .toList();
    final joinDate =
        DateTime.now().subtract(const Duration(days: 120)); // Fake join date

    return Scaffold(
      appBar: AppBar(
        title: Text(listing.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Implement save listing functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo gallery (single image fallback)
            if (listing.imageUrl != null)
              GestureDetector(
                onTap: () {
                  // TODO: Implement full screen image view
                },
                child: Hero(
                  tag: 'marketplace_image_${listing.id}',
                  child: Image.network(
                    listing.imageUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and price
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$24${listing.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  // Listing details
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Posted ${DateTime.now().difference(listing.createdAt).inDays} days ago',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        listing.isSold
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: listing.isSold ? Colors.green : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        listing.isSold ? 'Sold' : 'Available',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: listing.isSold
                                  ? Colors.green
                                  : Colors.grey[700],
                            ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'ID: ${listing.id}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Seller profile section
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Avatar(
                            imageUrl: listing.sellerAvatar,
                            size: 56,
                            username: listing.seller,
                            userId: listing.sellerId,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  listing.seller,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Joined ${joinDate.year}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  '${sellerListings.length} other listings',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                // TODO: Navigate to seller profile
                              },
                              child: const Text('View Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Item details table
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Table(
                        columnWidths: const {
                          0: IntrinsicColumnWidth(),
                          1: FlexColumnWidth(),
                        },
                        children: [
                          TableRow(children: [
                            const Text('Category:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(listing.category ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                          TableRow(children: [
                            const Text('Condition:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(listing.condition ?? '-',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                          TableRow(children: [
                            const Text('Location:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(listing.location,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                          TableRow(children: [
                            const Text('Crew:',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(listing.crew,
                                style: Theme.of(context).textTheme.bodyMedium),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(listing.description,
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 20),
                  // Safety & payment tips
                  Card(
                    margin: EdgeInsets.zero,
                    color: Colors.yellow[50],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Safety Tips',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('• Meet in a public place for exchanges.'),
                                Text('• Never send money in advance.'),
                                Text('• Inspect items before buying.'),
                                Text('• Use secure payment methods.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Related listings
                  if (relatedListings.isNotEmpty) ...[
                    Text('Related Listings',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 170,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: relatedListings.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final rel = relatedListings[idx];
                          return SizedBox(
                            width: 140,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MarketplaceDetailScreen(
                                            listingId: rel.id),
                                  ),
                                );
                              },
                              child: Card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (rel.imageUrl != null)
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(4)),
                                        child: Image.network(
                                          rel.imageUrl!,
                                          height: 80,
                                          width: 140,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(rel.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                          const SizedBox(height: 4),
                                          Text(
                                              '\$24${rel.price.toStringAsFixed(0)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement contact seller functionality
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Contact Seller'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement save listing functionality
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
