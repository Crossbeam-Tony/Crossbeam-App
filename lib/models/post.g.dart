// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Post _$PostFromJson(Map<String, dynamic> json) => Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] as String,
      authorAvatar: json['authorAvatar'] as String,
      crew: json['crew'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String?,
      type: $enumDecode(_$PostTypeEnumMap, json['type']),
      date: DateTime.parse(json['date'] as String),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostToJson(Post instance) => <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'author': instance.author,
      'authorAvatar': instance.authorAvatar,
      'crew': instance.crew,
      'title': instance.title,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'type': _$PostTypeEnumMap[instance.type]!,
      'date': instance.date.toIso8601String(),
      'likes': instance.likes,
      'comments': instance.comments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$PostTypeEnumMap = {
  PostType.text: 'text',
  PostType.photo: 'photo',
  PostType.video: 'video',
  PostType.event: 'event',
  PostType.link: 'link',
};

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      author: json['author'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      reaction: json['reaction'] as String?,
      replies: (json['replies'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'authorId': instance.authorId,
      'author': instance.author,
      'authorAvatar': instance.authorAvatar,
      'content': instance.content,
      'date': instance.date.toIso8601String(),
      'reaction': instance.reaction,
      'replies': instance.replies,
    };
