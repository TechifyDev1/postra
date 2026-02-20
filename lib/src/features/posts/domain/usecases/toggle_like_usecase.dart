import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<Map<String, dynamic>> execute(String slug) {
    return repository.toggleLike(slug);
  }

  Future<bool> isLiked(String slug) {
    return repository.isLiked(slug);
  }
}

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return ToggleLikeUseCase(repository);
});
