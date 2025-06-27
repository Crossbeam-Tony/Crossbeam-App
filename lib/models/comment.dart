class Comment {
  final String id;
  final String userId;
  final String entityType;
  final String entityId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.entityType,
    required this.entityId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'entity_type': entityType,
      'entity_id': entityId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Helper method to check if comment is for a project
  bool get isProjectComment => entityType == 'project';

  // Copy with method for updates
  Comment copyWith({
    String? id,
    String? userId,
    String? entityType,
    String? entityId,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
