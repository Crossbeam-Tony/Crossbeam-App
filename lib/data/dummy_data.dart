import '../models/user_profile.dart';

// Nearby cities within 25 miles of Valrico
final nearbyLocations = [
  'Brandon, FL',
  'Riverview, FL',
  'Plant City, FL',
  'Lakeland, FL',
  'Tampa, FL',
  'Lutz, FL',
  'Wesley Chapel, FL',
  'Dover, FL',
  'Seffner, FL',
  'Lithia, FL',
];

final List<UserProfile> dummyUsers = [
  UserProfile(
    id: 'u1',
    name: 'John Doe',
    realname: 'John Doe',
    username: 'johndoe',
    email: 'john@example.com',
    avatar: 'https://randomuser.me/api/portraits/men/1.jpg',
    avatarUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    bio: 'Filmmaker and photographer based in Tampa Bay',
    location: nearbyLocations[0], // Brandon, FL
    stats: {
      'followers': 1200,
      'following': 800,
      'posts': 45,
    },
    mutualCrews: ['crew1', 'crew2'],
    skills: ['photography', 'filmmaking', 'editing'],
  ),
  UserProfile(
    id: 'u2',
    name: 'Jane Doe',
    realname: 'Jane Doe',
    username: 'janedoe',
    email: 'jane@example.com',
    avatar: 'https://randomuser.me/api/portraits/women/1.jpg',
    avatarUrl: 'https://randomuser.me/api/portraits/women/1.jpg',
    bio: 'Documentary filmmaker and writer',
    location: nearbyLocations[1], // Riverview, FL
    stats: {
      'followers': 850,
      'following': 600,
      'posts': 32,
    },
    mutualCrews: ['crew1'],
    skills: ['documentary', 'writing', 'cinematography'],
  ),
];
