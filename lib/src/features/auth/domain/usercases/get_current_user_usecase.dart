import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/repositories/auth_repository.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';

class GetCurrentUserUsecase {
  final AuthRepository repository;

  GetCurrentUserUsecase(this.repository);

  Future<UserEntity> call() async {
    return repository.getCurrentUser();
  }
}

final getCurrentUserUsecaseProvider = Provider<GetCurrentUserUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return GetCurrentUserUsecase(repo);
});
