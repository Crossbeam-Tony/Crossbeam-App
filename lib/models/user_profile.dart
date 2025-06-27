import 'event.dart';
import 'project.dart';
import 'marketplace_item.dart';

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String fullName;
  final String bio;
  final String avatarUrl;
  final String hometown;
  final String currentLocation;
  final DateTime? birthday;
  final DateTime createdAt;
  final List<Event> events;
  final List<Project> projects;
  final List<MarketplaceItem> marketplaceItems;
  final bool isCurrentUser;
  final bool emailVerified;
  final DateTime? emailVerifiedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.bio,
    required this.avatarUrl,
    required this.hometown,
    required this.currentLocation,
    this.birthday,
    required this.createdAt,
    this.events = const [],
    this.projects = const [],
    this.marketplaceItems = const [],
    this.isCurrentUser = false,
    this.emailVerified = false,
    this.emailVerifiedAt,
  });

  // Method to check if email is verified (from profiles table)
  bool get isEmailVerified => emailVerified;

  // Method to check if email is verified (should be called from auth.users table)
  static bool isEmailVerifiedFromAuth(String? emailConfirmedAt) {
    return emailConfirmedAt != null;
  }

  // Getters for compatibility with existing code
  String get realname => fullName;
  String get name => fullName;

  // Stats getter - returns a map with user statistics
  Map<String, dynamic> get stats => {
        'projects': projects.length,
        'events': events.length,
        'marketplaceItems': marketplaceItems.length,
        'friends': 0, // Placeholder - implement when friends system is added
      };

  // Mutual crews getter - returns empty list for now
  List<String> get mutualCrews => [];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      hometown: json['hometown'] ?? '',
      currentLocation: json['current_location'] ?? '',
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      emailVerified: json['email_verified'] ?? false,
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'bio': bio,
      'avatar_url': avatarUrl,
      'hometown': hometown,
      'current_location': currentLocation,
      'birthday':
          birthday?.toIso8601String().split('T')[0], // Format as YYYY-MM-DD
      'created_at': createdAt.toIso8601String(),
      'email_verified': emailVerified,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      username: map['username'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      fullName: map['fullName'] as String,
      bio: map['bio'] as String,
      avatarUrl: map['avatarUrl'] as String,
      hometown: map['hometown'] as String,
      currentLocation: map['currentLocation'] as String,
      birthday:
          map['birthday'] != null ? DateTime.parse(map['birthday']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      emailVerified: map['emailVerified'] ?? false,
      emailVerifiedAt: map['emailVerifiedAt'] != null
          ? DateTime.parse(map['emailVerifiedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'hometown': hometown,
      'currentLocation': currentLocation,
      'birthday': birthday?.toIso8601String().split('T')[0],
      'createdAt': createdAt.toIso8601String(),
      'emailVerified': emailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
    };
  }
}
