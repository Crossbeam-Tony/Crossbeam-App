enum ProjectStatus { planning, inProgress, review, completed }

class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String image;
  final String imageUrl;
  final String ownerId;
  final String owner;
  final String ownerAvatar;
  final String userEmail;
  final List<String> members;
  final ProjectStatus status;
  final double progress;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> buildTags;
  final Map<String, List<String>> imagesByTag;
  final List<Map<String, dynamic>> comments;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.image,
    required this.imageUrl,
    required this.ownerId,
    required this.owner,
    required this.ownerAvatar,
    this.userEmail = '',
    required this.members,
    required this.status,
    required this.progress,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.buildTags,
    required this.imagesByTag,
    this.comments = const [],
  });

  factory Project.fromDummy(dynamic dummy) {
    return Project(
      id: dummy.id,
      title: dummy.title,
      description: dummy.description,
      category: dummy.category,
      location: dummy.location,
      image: dummy.image,
      imageUrl: dummy.imageUrl,
      ownerId: dummy.ownerId,
      owner: dummy.owner,
      ownerAvatar: dummy.ownerAvatar,
      userEmail: dummy.userEmail ?? dummy.owner,
      members: dummy.members,
      status: dummy.status,
      progress: dummy.progress,
      dueDate: dummy.dueDate,
      createdAt: dummy.createdAt,
      updatedAt: dummy.updatedAt,
      buildTags: dummy.buildTags,
      imagesByTag: dummy.imagesByTag,
      comments: dummy.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'image': image,
      'image_url': imageUrl,
      'user_id': ownerId,
      'owner': owner,
      'owner_avatar': ownerAvatar,
      'user_email': userEmail,
      'members': members,
      'status': status.name,
      'progress': progress,
      'due_date': dueDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'build_tags': buildTags,
      'images_by_tag': imagesByTag,
      'comments': comments,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String? ?? 'General',
      location: json['location'] as String? ?? '',
      image: json['image'] as String? ?? '',
      imageUrl:
          json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      ownerId: json['user_id'] as String? ?? json['ownerId'] as String? ?? '',
      owner: json['owner'] as String? ?? '',
      ownerAvatar: json['owner_avatar'] as String? ??
          json['ownerAvatar'] as String? ??
          '',
      userEmail:
          json['user_email'] as String? ?? json['userEmail'] as String? ?? '',
      members: json['members'] != null
          ? List<String>.from(json['members'] as List)
          : [],
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => ProjectStatus.planning,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
      buildTags: json['build_tags'] != null
          ? List<String>.from(json['build_tags'] as List)
          : [],
      imagesByTag: json['images_by_tag'] != null
          ? Map<String, List<String>>.from(
              (json['images_by_tag'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  List<String>.from(value as List),
                ),
              ),
            )
          : {},
      comments: json['comments'] != null
          ? List<Map<String, dynamic>>.from(
              (json['comments'] as List).map((c) => c as Map<String, dynamic>))
          : [],
    );
  }
}
