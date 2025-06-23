class MarketplaceListing {
  final String id;
  final String title;
  final String description;
  final String seller;
  final String sellerId;
  final String sellerAvatar;
  final double price;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl;
  final String? category;
  final String? condition;
  final bool isSold;
  final String crew;

  const MarketplaceListing({
    required this.id,
    required this.title,
    required this.description,
    required this.seller,
    required this.sellerId,
    required this.sellerAvatar,
    required this.price,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    required this.crew,
    this.imageUrl,
    this.category,
    this.condition,
    this.isSold = false,
  });

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    return MarketplaceListing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      seller: json['seller'] as String,
      sellerId: json['sellerId'] as String,
      sellerAvatar: json['sellerAvatar'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      crew: json['crew'] as String,
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String?,
      condition: json['condition'] as String?,
      isSold: json['isSold'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'seller': seller,
      'sellerId': sellerId,
      'sellerAvatar': sellerAvatar,
      'price': price,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'crew': crew,
      'imageUrl': imageUrl,
      'category': category,
      'condition': condition,
      'isSold': isSold,
    };
  }
}
