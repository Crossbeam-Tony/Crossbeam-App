class DummyFriend {
  final String id;
  final String username;
  final String realname;
  final String avatarUrl;
  final List<String> mutualCrews;
  final String location;
  final String bio;
  final List<String> interests;
  final List<String> skills;
  final Map<String, int> stats;
  final DateTime joinDate;

  DummyFriend({
    required this.id,
    required this.username,
    required this.realname,
    required this.avatarUrl,
    required this.mutualCrews,
    required this.location,
    required this.bio,
    required this.interests,
    required this.skills,
    required this.stats,
    required this.joinDate,
  });
}

final List<Map<String, dynamic>> userTemplates = [
  {
    'username': 'carEnthusiast',
    'realname': 'Mike Johnson',
    'bio':
        'Car enthusiast and mechanic. Love working on Miatas and Japanese imports.',
    'interests': ['Cars', 'Mechanics', 'Racing', 'Photography'],
    'skills': ['Engine Building', 'Welding', 'Fabrication', 'Photography'],
    'stats': {'posts': 45, 'projects': 12, 'followers': 234, 'following': 156},
    'location': 'Valrico, FL',
  },
  {
    'username': 'photoPro',
    'realname': 'Sarah Chen',
    'bio':
        'Professional photographer specializing in landscape and portrait photography.',
    'interests': ['Photography', 'Travel', 'Nature', 'Art'],
    'skills': [
      'Portrait Photography',
      'Landscape Photography',
      'Photo Editing',
      'Lighting'
    ],
    'stats': {'posts': 89, 'projects': 24, 'followers': 456, 'following': 321},
    'location': 'Brandon, FL',
  },
  {
    'username': 'woodworker',
    'realname': 'David Miller',
    'bio': 'Custom furniture maker and woodworking enthusiast.',
    'interests': ['Woodworking', 'DIY', 'Furniture', 'Design'],
    'skills': ['Furniture Making', 'Carpentry', 'Wood Finishing', 'Design'],
    'stats': {'posts': 67, 'projects': 18, 'followers': 345, 'following': 278},
    'location': 'Riverview, FL',
  },
  {
    'username': 'fitnessGuru',
    'realname': 'Lisa Thompson',
    'bio':
        'Personal trainer and fitness instructor. Helping people achieve their fitness goals.',
    'interests': ['Fitness', 'Health', 'Yoga', 'Nutrition'],
    'skills': [
      'Personal Training',
      'Yoga Instruction',
      'Nutrition Planning',
      'Group Fitness'
    ],
    'stats': {'posts': 54, 'projects': 15, 'followers': 289, 'following': 198},
    'location': 'Lithia, FL',
  },
  {
    'username': 'techGeek',
    'realname': 'Alex Rodriguez',
    'bio':
        'Software developer and tech enthusiast. Always exploring new technologies.',
    'interests': ['Technology', 'Programming', 'Gaming', 'AI'],
    'skills': [
      'Software Development',
      'Web Development',
      'Game Development',
      'AI/ML'
    ],
    'stats': {'posts': 78, 'projects': 21, 'followers': 412, 'following': 298},
    'location': 'FishHawk, FL',
  },
];

final List<DummyFriend> dummyFriends = List.generate(10, (index) {
  final template = userTemplates[index % userTemplates.length];
  return DummyFriend(
    id: (index + 1).toString(),
    username: template['username'],
    realname: template['realname'],
    avatarUrl: 'https://picsum.photos/seed/avatar${index + 1}/200/200',
    mutualCrews: [
      'Cars',
      'Photography',
      'Woodworking',
      'Fitness',
      'Technology'
    ],
    location: template['location'],
    bio: template['bio'],
    interests: template['interests'],
    skills: template['skills'],
    stats: template['stats'],
    joinDate: DateTime(2024, 1, 1 + index * 15),
  );
});
