import 'package:postra/src/features/posts/domain/entities/post_entity.dart';

class Post extends PostEntity {
  Post({
    required super.id,
    required super.title,
    required super.subTitle,
    required super.postBanner,
    required super.content,
    required super.createdAt,
    required super.username,
    super.profilePic,
    required super.slug,
    required super.authorFullName,
    required super.likeCount,
    required super.commentCount,
    super.isLiked = false,
  });

  @override
  Post copyWith({
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
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      postBanner: postBanner ?? this.postBanner,
      content: content ?? this.content,
      subTitle: subTitle ?? this.subTitle,
      createdAt: createdAt ?? this.createdAt,
      username: username ?? this.username,
      profilePic: profilePic ?? this.profilePic,
      authorFullName: authorFullName ?? this.authorFullName,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      subTitle: json['subTitle'] ?? '',
      postBanner: json['postBanner'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      username: json['username'] ?? '',
      profilePic: json['profilePic'],
      slug: json['slug'] ?? '',
      authorFullName: json['authorFullName'] ?? '',
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] ?? false,
    );
  }
}
