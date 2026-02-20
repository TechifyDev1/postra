import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:postra/src/core/storage/secure_storage_service.dart';
import 'package:postra/src/core/network/auth_event_provider.dart';

class HttpClient extends http.BaseClient {
  final http.Client _client;
  final VoidCallback? onUnauthorized;

  final service = SecureStorageService();

  HttpClient(this._client, {this.onUnauthorized});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = await service.read(key: 'token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['X-Client-Type'] = 'app';
    request.headers['Content-Type'] = 'application/json';

    final response = await _client.send(request);

    // Check for 401 Unauthorized
    if (response.statusCode == 401 && onUnauthorized != null) {
      onUnauthorized!();
    }

    return response;
  }

  @override
  void close() {
    _client.close();
  }
}

final httpClientProvider = Provider<HttpClient>((ref) {
  return HttpClient(
    http.Client(),
    onUnauthorized: () {
      // Increment the event state to notify listeners (like AuthProvider)
      ref.read(unauthorizedEventProvider.notifier).state++;
    },
  );
});
