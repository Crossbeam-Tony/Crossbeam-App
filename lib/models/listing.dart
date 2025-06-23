enum ListingCategory { project, event, marketplace }

class Listing {
  final String title;
  final String subtitle;
  final String description;
  final double price;
  final String? imageUrl;
  final ListingCategory category;
  final double? latitude;
  final double? longitude;

  Listing({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    this.latitude,
    this.longitude,
  });
}
