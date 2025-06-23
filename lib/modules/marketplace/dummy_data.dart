import '../circle/dummy_data.dart';

class DummyListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String sellerId;
  final String sellerName;
  final String sellerAvatar;
  final String category;
  final String condition;
  final String location;
  final DateTime date;

  DummyListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerAvatar,
    required this.category,
    required this.condition,
    required this.location,
    required this.date,
  });
}

final List<Map<String, dynamic>> listingTemplates = [
  {
    'title': 'Vintage Camera Collection',
    'description':
        'Beautiful collection of vintage cameras in excellent condition. Includes Canon AE-1, Nikon F3, and Pentax K1000.',
    'price': 599.99,
    'category': 'Photography',
    'condition': 'Used - Like New',
    'location': 'Brandon, FL',
  },
  {
    'title': 'Custom Gaming PC',
    'description':
        'High-end gaming PC with RTX 3080, Ryzen 9 5900X, 32GB RAM, 2TB NVMe SSD. Built for streaming and gaming.',
    'price': 1999.99,
    'category': 'Electronics',
    'condition': 'Used - Excellent',
    'location': 'Riverview, FL',
  },
  {
    'title': 'Professional DJ Equipment',
    'description':
        'Complete DJ setup including Pioneer DDJ-1000 controller, KRK Rokit 5 monitors, and flight case.',
    'price': 1299.99,
    'category': 'Music',
    'condition': 'Used - Good',
    'location': 'Valrico, FL',
  },
  {
    'title': 'Woodworking Tools Set',
    'description':
        'Complete set of professional woodworking tools. Includes table saw, router, planer, and various hand tools.',
    'price': 899.99,
    'category': 'Tools',
    'condition': 'Used - Good',
    'location': 'Lithia, FL',
  },
  {
    'title': 'Mountain Bike - Specialized Stumpjumper',
    'description':
        '2022 Specialized Stumpjumper Expert Carbon. Size L, barely used, perfect condition.',
    'price': 3499.99,
    'category': 'Sports',
    'condition': 'Used - Like New',
    'location': 'FishHawk, FL',
  },
];

final users = dummyFriends;
final List<DummyListing> dummyListings = List.generate(10, (index) {
  final user = users[index % users.length];
  final template = listingTemplates[index % listingTemplates.length];
  return DummyListing(
    id: (index + 1).toString(),
    title: template['title'],
    description: template['description'],
    price: template['price'],
    imageUrl: 'https://picsum.photos/seed/listing${index + 1}/800/600',
    sellerId: user.id,
    sellerName: user.realname,
    sellerAvatar: user.avatarUrl,
    category: template['category'],
    condition: template['condition'],
    location: template['location'],
    date: DateTime(2024, 3, 15 + index),
  );
});
