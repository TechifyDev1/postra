import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../network/api_endpoints.dart';
import '../network/http_client.dart';

class CloudinaryService {
  final HttpClient httpClient;
  static const String cloudName = 'dvpkp0u9u';
  static const String apiKey = '544934933231257';
  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  CloudinaryService(this.httpClient);

  /// Get signed upload parameters from backend
  Future<Map<String, dynamic>> getSignedParams() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final params = {'timestamp': timestamp, 'folder': 'posts'};

    final response = await httpClient.post(
      Uri.parse(ApiEndpoints.getSignature),
      body: jsonEncode(params),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return {'signature': data['data']['signature'], 'timestamp': timestamp};
      } else {
        throw Exception(data['message'] ?? 'Failed to get signature');
      }
    } else {
      throw Exception('Failed to get signed parameters');
    }
  }

  /// Upload image to Cloudinary using signed params
  Future<String> uploadImage(File imageFile) async {
    try {
      // Get signed params from backend
      final signedParams = await getSignedParams();

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add required fields
      request.fields['timestamp'] = signedParams['timestamp'].toString();
      request.fields['signature'] = signedParams['signature'];
      request.fields['api_key'] = apiKey;
      request.fields['folder'] = 'posts';

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'] as String;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Image upload failed: $e');
    }
  }
}
