import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment.dart';
import '../../repositories/post_repository.dart';

class GetCommentsUseCase {
  final PostRepository repository;

  GetCommentsUseCase(this.repository);

  Future<List<Comment>> execute(String slug) {
    return repository.getComments(slug);
  }
}

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return GetCommentsUseCase(repository);
});
