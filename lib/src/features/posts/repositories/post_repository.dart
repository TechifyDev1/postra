import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/data/datasources/post_remote_datasource.dart';
import 'package:postra/src/features/posts/data/models/comment.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/posts/data/repositories/post_repository_impl.dart';

abstract class PostRepository {
  Future<List<Post>> getPosts({int? page, int? size});
  Future<Post> createPost({
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  });
  Future<Post> updatePost({
    required String slug,
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  });
  Future<void> deletePost(String slug);

  Future<Map<String, dynamic>> toggleLike(String slug);
  Future<int> getLikeCount(String slug);
  Future<bool> isLiked(String slug);
  Future<List<Comment>> getComments(String slug);
  Future<Comment> addComment(String slug, String content);
}

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final remoteDataSource = ref.read(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource);
});
