class ApiEndpoints {
  static const String baseUrl = 'https://postra-backend.onrender.com/api';

  static const String posts = '$baseUrl/posts';
  static const String createPost = '$baseUrl/posts/create';
  static String updatePost(String slug) => '$baseUrl/posts/update/$slug';
  static String deletePost(String slug) => '$baseUrl/posts/delete/$slug';
  static const String getSignature = '$baseUrl/sign';

  String getPost(String slug) => '$baseUrl/posts/$slug';

  static String getPosts({int? page, int? size}) {
    String url = '$baseUrl/posts/';
    List<String> queryParams = [];
    if (page != null) queryParams.add('page=$page');
    if (size != null) queryParams.add('size=$size');

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }
    return url;
  }

  static String login = '$baseUrl/users/login';
  static String register = '$baseUrl/users/register';
  static String getCurrentUser = '$baseUrl/users/profile/me';
  static String userProfile(String username) =>
      '$baseUrl/users/profile/$username';
  static String updateProfile = '$baseUrl/users/profile';

  // Likes
  static String toggleLike(String slug) => '$baseUrl/like/$slug';
  static String getLikeCount(String slug) => '$baseUrl/like/$slug/count';
  static String isLiked(String slug) => '$baseUrl/like/$slug/is-liked';

  // Comments
  static String getComments(String slug) => '$baseUrl/comments/$slug';
  static String addComment(String slug) => '$baseUrl/comments/add/$slug';

  // Follows
  static String toggleFollow(String username) => '$baseUrl/follow/$username';
  static String isFollowing(String username) =>
      '$baseUrl/follow/is-following/$username';
  static String getFollowers(String username) =>
      '$baseUrl/users/$username/followers';
  static String getFollowing(String username) =>
      '$baseUrl/users/$username/following';
}
