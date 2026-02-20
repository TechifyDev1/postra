import '../../domain/entities/user_entity.dart';

class User extends UserEntity {
  User({
    required super.id,
    required super.username,
    required super.email,
    required super.fullName,
    required super.profilePictureUrl,
    required super.bio,
    required super.bgImage,
    required super.numOfFollowers,
    required super.numOfFollowing,
    required super.postCount,
    required super.token,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id']?.toString() ?? '',
    username: json['username']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    profilePictureUrl: json['profilePictureUrl']?.toString(),
    bio: json['bio']?.toString(),
    bgImage: json['bgImage']?.toString(),
    numOfFollowers: json['numOfFollowers'] is int ? json['numOfFollowers'] : 0,
    numOfFollowing: json['numOfFollowing'] is int ? json['numOfFollowing'] : 0,
    postCount: json['postCount'] is int ? json['postCount'] : 0,
    token: json['token']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'fullName': fullName,
    'profilePictureUrl': profilePictureUrl,
    'bio': bio,
    'bgImage': bgImage,
    'numOfFollowers': numOfFollowers,
    'numOfFollowing': numOfFollowing,
    'postCount': postCount,
    'token': token,
  };
}
