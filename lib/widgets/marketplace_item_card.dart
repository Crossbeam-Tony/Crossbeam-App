import 'package:flutter/material.dart';
import '../models/marketplace_item.dart';

class MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item;

  const MarketplaceItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: Image.network(
          item.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(item.title),
        subtitle: Text(item.description),
        trailing: Text('\$${item.price.toStringAsFixed(2)}'),
      ),
    );
  }
}
