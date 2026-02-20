import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment.dart';
import '../../repositories/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<Comment> execute(String slug, String content) {
    return repository.addComment(slug, content);
  }
}

final addCommentUseCaseProvider = Provider<AddCommentUseCase>((ref) {
  final repository = ref.read(postRepositoryProvider);
  return AddCommentUseCase(repository);
});
