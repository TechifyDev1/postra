class PostEntity {
  final String id;
  final String title;
  final String subTitle;
  final String postBanner;
  final String content;
  final String createdAt;
  final String username;
  final String? profilePic;
  final String slug;
  final String authorFullName;
  final int likeCount;
  final int commentCount;
  final bool isLiked;

  PostEntity({
    required this.id,
    required this.title,
    required this.subTitle,
    required this.postBanner,
    required this.content,
    required this.createdAt,
    required this.username,
    this.profilePic,
    required this.slug,
    required this.authorFullName,
    required this.likeCount,
    required this.commentCount,
    this.isLiked = false,
  });

  PostEntity copyWith({
    String? id,
    String? title,
    String? subTitle,
    String? postBanner,
    String? content,
    String? createdAt,
    String? username,
    String? profilePic,
    String? slug,
    String? authorFullName,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
  }) {
    return PostEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      subTitle: subTitle ?? this.subTitle,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      postBanner: postBanner ?? this.postBanner,
      username: username ?? this.username,
      authorFullName: authorFullName ?? this.authorFullName,
      profilePic: profilePic ?? this.profilePic,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
