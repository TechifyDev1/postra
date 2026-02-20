class CommentEntity {
  final String content;
  final String authorUsername;
  final String? profilePictureUrl;
  final String createdAt;

  CommentEntity({
    required this.content,
    required this.authorUsername,
    this.profilePictureUrl,
    required this.createdAt,
  });
}
