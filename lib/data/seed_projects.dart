import '../models/project.dart';

final List<Project> seededProjects = [
  Project(
    id: 'proj1',
    title: 'Tampa Bay Documentary',
    description: 'A documentary about the Tampa Bay area',
    category: 'Documentary',
    location: 'Tampa, FL',
    image: 'https://picsum.photos/800/600',
    imageUrl: 'https://picsum.photos/800/600',
    ownerId: 'u1',
    owner: 'Peter Fisher',
    ownerAvatar: 'https://i.pravatar.cc/150?img=1',
    userEmail: 'peter.fisher@example.com',
    members: ['u2', 'u3', 'u4'],
    status: ProjectStatus.inProgress,
    progress: 0.65,
    dueDate: DateTime.now().add(const Duration(days: 30)),
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    updatedAt: DateTime.now(),
    buildTags: ['documentary', 'tampa', 'bay'],
    imagesByTag: {
      'documentary': ['https://picsum.photos/800/600'],
      'tampa': ['https://picsum.photos/800/600'],
      'bay': ['https://picsum.photos/800/600'],
    },
  ),
];
