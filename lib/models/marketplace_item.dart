class MarketplaceItem {
  final String id;
  final String title;
  final String description;
  final double price;
  final String sellerId;
  final String imageUrl;

  MarketplaceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.sellerId,
    required this.imageUrl,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      sellerId: json['seller_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'seller_id': sellerId,
      'image_url': imageUrl,
    };
  }
}
