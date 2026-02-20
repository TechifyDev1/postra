import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/posts/repositories/post_repository.dart';

class CreatePostUseCase {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  Future<Post> execute({
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    try {
      return await repository.createPost(
        title: title,
        subTitle: subTitle,
        content: content,
        postBanner: postBanner,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return CreatePostUseCase(repo);
});
