import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/core/network/api_endpoints.dart';
import 'package:postra/src/core/network/http_client.dart';
import 'package:postra/src/features/posts/data/models/comment.dart';
import 'package:postra/src/features/posts/data/models/post.dart';

class PostRemoteDataSource {
  final HttpClient client;

  PostRemoteDataSource(this.client);

  Future<List<Post>> getPosts({int? page, int? size}) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getPosts(page: page, size: size)),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final list = data['content'] as List?;
      if (list == null) {
        return [];
      }
      final posts = list.map<Post>((json) => Post.fromJson(json)).toList();
      return posts;
    } else {
      throw Exception('Failed to get posts');
    }
  }

  Future<Post> createPost({
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.createPost),
      body: jsonEncode({
        'title': title,
        'subTitle': subTitle,
        'content': content,
        'postBanner': postBanner,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error.toString());
    }
  }

  Future<Post> updatePost({
    required String slug,
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    final response = await client.put(
      Uri.parse(ApiEndpoints.updatePost(slug)),
      body: jsonEncode({
        'title': title,
        'subTitle': subTitle,
        'content': content,
        'postBanner': postBanner,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error.toString());
    }
  }

  Future<void> deletePost(String slug) async {
    final response = await client.delete(
      Uri.parse(ApiEndpoints.deletePost(slug)),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error.toString());
    }
  }

  Future<Map<String, dynamic>> toggleLike(String slug) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.toggleLike(slug)),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Backend returns: {totalLikes: X, message: 'Liked' or 'Unliked'}
      return {
        'totalLikes': data['totalLikes'] as int,
        'isLiked': data['message'] == 'Liked',
      };
    } else {
      throw Exception('Failed to toggle like');
    }
  }

  Future<int> getLikeCount(String slug) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getLikeCount(slug)),
    );
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to get like count');
    }
  }

  Future<bool> isLiked(String slug) async {
    final response = await client.get(Uri.parse(ApiEndpoints.isLiked(slug)));
    if (response.statusCode == 200) {
      return response.body == 'true';
    } else {
      throw Exception('Failed to check if liked');
    }
  }

  Future<List<Comment>> getComments(String slug) async {
    final response = await client.get(
      Uri.parse(ApiEndpoints.getComments(slug)),
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get comments');
    }
  }

  Future<Comment> addComment(String slug, String content) async {
    final response = await client.post(
      Uri.parse(ApiEndpoints.addComment(slug)),
      body: jsonEncode({'content': content}),
    );
    if (response.statusCode == 200) {
      return Comment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }
}

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final client = ref.read(httpClientProvider);
  return PostRemoteDataSource(client);
});
