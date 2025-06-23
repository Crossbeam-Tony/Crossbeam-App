import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

enum PostType {
  text,
  photo,
  video,
  event,
  link,
}

@JsonSerializable()
class Post {
  final String id;
  final String authorId;
  final String author;
  final String authorAvatar;
  final String crew;
  final String title;
  final String description;
  final String? imageUrl;
  final PostType type;
  final DateTime date;
  final int likes;
  final List<Comment> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.authorId,
    required this.author,
    required this.authorAvatar,
    required this.crew,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.type,
    required this.date,
    this.likes = 0,
    this.comments = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);
  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class Comment {
  final String id;
  final String authorId;
  final String author;
  final String? authorAvatar;
  final String content;
  final DateTime date;
  String? reaction;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.authorId,
    required this.author,
    this.authorAvatar,
    required this.content,
    required this.date,
    this.reaction,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) =>
      _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}
