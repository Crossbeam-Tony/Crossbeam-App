import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import 'marketplace_detail_screen.dart';
import '../shared/avatar.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataService = Provider.of<DataService>(context, listen: false);
    final listings = dataService.marketplaceListings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement new listing creation
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: listings.length,
        itemBuilder: (context, index) {
          final listing = listings[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: Avatar(
                imageUrl: listing.imageUrl ??
                    'https://picsum.photos/200/200?random=${listing.id}',
                size: 40,
              ),
              title: Text(listing.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.description),
                  const SizedBox(height: 4),
                  Text(
                    '\$${listing.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MarketplaceDetailScreen(listingId: listing.id),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
