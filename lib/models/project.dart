enum ProjectStatus { planning, inProgress, review, completed }

class Project {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String? status;
  final List<String>? tags;
  final List<String>? images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.status,
    this.tags,
    this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String?,
      tags:
          json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status,
      'tags': tags,
      'images': images,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper method to convert status string to enum
  ProjectStatus get statusEnum {
    if (status == null) return ProjectStatus.planning;

    switch (status!.toLowerCase()) {
      case 'in-progress':
        return ProjectStatus.inProgress;
      case 'review':
        return ProjectStatus.review;
      case 'completed':
        return ProjectStatus.completed;
      default:
        return ProjectStatus.planning;
    }
  }

  // Helper method to convert enum to string
  String get statusString {
    switch (statusEnum) {
      case ProjectStatus.inProgress:
        return 'in-progress';
      case ProjectStatus.review:
        return 'review';
      case ProjectStatus.completed:
        return 'completed';
      default:
        return 'planning';
    }
  }

  // Copy with method for updates
  Project copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? status,
    List<String>? tags,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      tags: tags ?? this.tags,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
