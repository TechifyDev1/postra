import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/data/models/register_request.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';
import 'package:postra/src/features/auth/repositories/auth_repository.dart';

class RegisterUsecase {
  final AuthRepository repository;

  RegisterUsecase(this.repository);

  Future<UserEntity> call(RegisterRequest request) async {
    return repository.register(request);
  }
}

final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return RegisterUsecase(repo);
});
