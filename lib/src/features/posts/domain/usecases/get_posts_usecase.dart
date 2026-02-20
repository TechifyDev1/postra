import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/posts/repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository repository;

  GetPostsUseCase(this.repository);

  Future<List<Post>> execute({int? page, int? size}) async {
    try {
      return await repository.getPosts(page: page, size: size);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return GetPostsUseCase(repo);
});
