import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/core/network/api_endpoints.dart';
import 'package:postra/src/core/network/http_client.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';
import 'package:postra/src/features/auth/data/models/user.dart';

import '../models/register_request.dart';

class AuthRemoteDatasource {
  final HttpClient client;

  AuthRemoteDatasource(this.client);

  Future<User> login(LoginRequest request) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.login),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['data']);
      await client.service.write(key: 'token', value: user.token!);
      return user;
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<User> getCurrentUser() async {
    final response = await client.get(Uri.parse(ApiEndpoints.getCurrentUser));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      throw Exception('Failed to get current user');
    }
  }

  Future<String> register(RegisterRequest request) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.register),
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['data'] != null) {
        final user = User.fromJson(data['data']);
        if (user.token != null) {
          await client.service.write(key: 'token', value: user.token!);
        }
      }
      return data['message'];
    } else {
      throw Exception('Failed to register');
    }
  }
}

final authRemoteDatasourceProvider = Provider<AuthRemoteDatasource>((ref) {
  final client = ref.read(httpClientProvider);
  return AuthRemoteDatasource(client);
});
