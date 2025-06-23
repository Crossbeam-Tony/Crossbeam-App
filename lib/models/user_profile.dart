import 'event.dart';
import 'project.dart';
import 'marketplace_item.dart';

class UserProfile {
  final String id;
  final String name;
  final String realname;
  final String username;
  final String email;
  final String avatarUrl;
  final String bio;
  final String location;
  final Map<String, dynamic> stats;
  final List<String> mutualCrews;
  final List<String> skills;
  final List<Event> events;
  final List<Project> projects;
  final List<MarketplaceItem> marketplaceItems;
  final bool isCurrentUser;

  UserProfile({
    required this.id,
    required this.name,
    required this.realname,
    required this.username,
    required this.email,
    required this.avatarUrl,
    required this.bio,
    required this.location,
    required this.stats,
    required this.mutualCrews,
    required this.skills,
    this.events = const [],
    this.projects = const [],
    this.marketplaceItems = const [],
    this.isCurrentUser = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      realname: json['realname'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      stats: json['stats'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['stats'])
          : {},
      mutualCrews: json['mutual_crews'] is List
          ? List<String>.from(json['mutual_crews'])
          : [],
      skills: json['skills'] is List ? List<String>.from(json['skills']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'realname': realname,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
      'location': location,
      'stats': stats,
      'mutual_crews': mutualCrews,
      'skills': skills,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      realname: map['realname'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      avatarUrl: map['avatarUrl'] as String,
      bio: map['bio'] as String,
      location: map['location'] as String,
      stats: Map<String, dynamic>.from(map['stats'] as Map),
      mutualCrews: List<String>.from(map['mutualCrews'] as List),
      skills: List<String>.from(map['skills'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'realname': realname,
      'username': username,
      'email': email,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'location': location,
      'stats': stats,
      'mutualCrews': mutualCrews,
      'skills': skills,
    };
  }
}
