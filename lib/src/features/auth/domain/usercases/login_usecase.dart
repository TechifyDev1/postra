import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';
import 'package:postra/src/features/auth/repositories/auth_repository.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<UserEntity> call(LoginRequest request) async {
    return repository.login(request);
  }
}

final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginUsecase(repo);
});
