import 'package:postra/src/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:postra/src/features/auth/domain/entities/user_entity.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';
import 'package:postra/src/features/auth/data/models/register_request.dart';
import 'package:postra/src/features/auth/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<UserEntity> login(LoginRequest request) async {
    return remoteDatasource.login(request);
  }

  @override
  Future<void> logout() {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> register(RegisterRequest request) async {
    await remoteDatasource.register(request);
    final user = await remoteDatasource.login(
      LoginRequest(
        usernameOrEmail: request.username,
        password: request.password,
      ),
    );
    return user;
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    return remoteDatasource.getCurrentUser();
  }
}
