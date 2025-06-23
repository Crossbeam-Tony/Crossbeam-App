class User {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? bio;
  final String? location;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.bio,
    this.location,
    required this.followers,
    required this.following,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      followers: List<String>.from(json['followers'] as List),
      following: List<String>.from(json['following'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'followers': followers,
      'following': following,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
