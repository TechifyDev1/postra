import 'package:postra/src/features/posts/domain/entities/comment_entity.dart';

class Comment extends CommentEntity {
  Comment({
    required super.content,
    required super.authorUsername,
    required super.createdAt,
    super.profilePictureUrl,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      content: json['content'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? json['profilePic'],
      createdAt: json['createdAt'] ?? '',
    );
  }
}
