import '../../models/user_profile.dart';

// Dummy users for testing
final List<UserProfile> dummyUsers = [
  UserProfile(
    id: '1',
    name: 'John Doe',
    realname: 'John Doe',
    username: 'johndoe',
    email: 'john@example.com',
    avatar: 'https://picsum.photos/200/200?random=1',
    avatarUrl: 'https://picsum.photos/200/200?random=1',
    bio: 'Software developer and tech enthusiast',
    location: 'New York, NY',
    stats: {
      'posts': 42,
      'followers': 156,
      'following': 89,
      'events': 5,
    },
    mutualCrews: ['Tech Enthusiasts', 'Web Developers'],
    skills: ['Flutter', 'Dart', 'Web Development', 'UI/UX'],
  ),
  UserProfile(
    id: '2',
    name: 'Jane Smith',
    realname: 'Jane Smith',
    username: 'janesmith',
    email: 'jane@example.com',
    avatar: 'https://picsum.photos/200/200?random=2',
    avatarUrl: 'https://picsum.photos/200/200?random=2',
    bio: 'Digital marketer and content creator',
    location: 'San Francisco, CA',
    stats: {
      'posts': 78,
      'followers': 234,
      'following': 145,
      'events': 8,
    },
    mutualCrews: ['Digital Marketers', 'Content Creators'],
    skills: ['Marketing', 'Content Creation', 'Social Media', 'SEO'],
  ),
];

// Project templates for generating dummy data
final List<Map<String, dynamic>> projectTemplates = [
  {
    'title': 'Website Redesign',
    'description': 'Complete overhaul of the company website',
    'category': 'Web Development',
  },
  {
    'title': 'Mobile App Development',
    'description': 'New mobile app for iOS and Android',
    'category': 'Mobile Development',
  },
  {
    'title': 'Marketing Campaign',
    'description': 'Q2 marketing campaign launch',
    'category': 'Marketing',
  },
];

// Helper function to get a random user
UserProfile getRandomUser(int index) {
  return dummyUsers[index % dummyUsers.length];
}

class DummyProject {
  final String id;
  final String title;
  final String description;
  final String category;
  final String image;
  final String ownerId;
  final String owner;
  final String ownerAvatar;
  final List<String> members;
  final String status;
  final double progress;
  final DateTime dueDate;

  DummyProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.image,
    required this.ownerId,
    required this.owner,
    required this.ownerAvatar,
    required this.members,
    required this.status,
    required this.progress,
    required this.dueDate,
  });
}

// Generate dummy projects
final List<DummyProject> dummyProjectList = List.generate(10, (index) {
  final user = getRandomUser(index);
  final template = projectTemplates[index % projectTemplates.length];
  final uniqueSeed = 'project${index + 100}';

  // Generate random members
  final members = List.generate(
    (index % 3) + 1,
    (i) => getRandomUser(i + 1).name,
  );

  return DummyProject(
    id: 'project_$index',
    title: template['title'] as String,
    description: template['description'] as String,
    category: template['category'] as String,
    image: 'https://picsum.photos/seed/$uniqueSeed/800/600',
    ownerId: user.id,
    owner: user.name,
    ownerAvatar: user.avatar,
    members: members,
    status: index % 2 == 0 ? 'In Progress' : 'Completed',
    progress: (index % 10) / 10,
    dueDate: DateTime.now().add(Duration(days: (index + 1) * 7)),
  );
});
