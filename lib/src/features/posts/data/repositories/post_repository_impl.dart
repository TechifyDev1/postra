import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:postra/src/features/posts/data/models/comment.dart';
import 'package:postra/src/features/posts/data/models/post.dart';

import '../../repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;

  PostRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Post>> getPosts({int? page, int? size}) {
    try {
      return remoteDataSource.getPosts(page: page, size: size);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Post> createPost({
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) {
    try {
      return remoteDataSource.createPost(
        title: title,
        subTitle: subTitle,
        content: content,
        postBanner: postBanner,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Post> updatePost({
    required String slug,
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) {
    try {
      return remoteDataSource.updatePost(
        slug: slug,
        title: title,
        subTitle: subTitle,
        content: content,
        postBanner: postBanner,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> deletePost(String slug) {
    try {
      return remoteDataSource.deletePost(slug);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> toggleLike(String slug) {
    return remoteDataSource.toggleLike(slug);
  }

  @override
  Future<int> getLikeCount(String slug) {
    return remoteDataSource.getLikeCount(slug);
  }

  @override
  Future<bool> isLiked(String slug) {
    return remoteDataSource.isLiked(slug);
  }

  @override
  Future<List<Comment>> getComments(String slug) {
    return remoteDataSource.getComments(slug);
  }

  @override
  Future<Comment> addComment(String slug, String content) {
    return remoteDataSource.addComment(slug, content);
  }
}

final postRepositoryImplProvider = Provider<PostRepositoryImpl>((ref) {
  final remoteDataSource = ref.read(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource);
});
