import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/posts/repositories/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<Post> execute({
    required String slug,
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    try {
      return await repository.updatePost(
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
}

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return UpdatePostUseCase(repo);
});
