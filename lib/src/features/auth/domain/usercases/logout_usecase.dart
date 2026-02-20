import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<void> call() async {
    return repository.logout();
  }
}

final logoutUsecaseProvider = Provider<LogoutUsecase>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LogoutUsecase(repo);
});
