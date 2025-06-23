import '../models/user.dart';
import '../data/dummy_data.dart';

class UserService {
  Future<User> getUserById(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Find user in dummy data and convert to User model
    final userProfile = dummyUsers.firstWhere(
      (user) => user.id == userId,
      orElse: () => throw Exception('User not found'),
    );

    return User(
      id: userProfile.id,
      name: userProfile.name,
      email: userProfile.email,
      avatarUrl: userProfile.avatarUrl,
      bio: userProfile.bio,
      location: userProfile.location,
      followers: [], // TODO: Implement actual followers list
      following: [], // TODO: Implement actual following list
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
    );
  }
}
