class Crew {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final String ownerId;
  final String owner;
  final String ownerAvatar;
  final List<String> members;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Crew({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ownerId,
    required this.owner,
    required this.ownerAvatar,
    required this.members,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Crew.fromJson(Map<String, dynamic> json) {
    return Crew(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      ownerId: json['ownerId'] as String,
      owner: json['owner'] as String,
      ownerAvatar: json['ownerAvatar'] as String,
      members: List<String>.from(json['members'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'owner': owner,
      'ownerAvatar': ownerAvatar,
      'members': members,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
