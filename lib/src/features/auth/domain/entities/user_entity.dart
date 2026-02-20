class UserEntity {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final String? profilePictureUrl;
  final String? bio;
  final String? bgImage;
  final int numOfFollowers;
  final int numOfFollowing;
  final int postCount;
  final String? token;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.profilePictureUrl,
    required this.bio,
    required this.bgImage,
    required this.numOfFollowers,
    required this.numOfFollowing,
    required this.postCount,
    this.token,
  });
}
