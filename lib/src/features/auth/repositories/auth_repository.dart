import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:postra/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';
import 'package:postra/src/features/auth/data/models/register_request.dart';

abstract class AuthRepository {
  Future<UserEntity> login(LoginRequest request);
  Future<void> logout();
  Future<UserEntity> register(RegisterRequest request);
  Future<UserEntity> getCurrentUser();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDatasourceProvider);
  return AuthRepositoryImpl(remote);
});
