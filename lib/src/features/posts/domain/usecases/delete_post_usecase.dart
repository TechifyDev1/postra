import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/posts/repositories/post_repository.dart';

class DeletePostUseCase {
  final PostRepository repository;

  DeletePostUseCase(this.repository);

  Future<void> execute(String slug) async {
    try {
      await repository.deletePost(slug);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return DeletePostUseCase(repo);
});
