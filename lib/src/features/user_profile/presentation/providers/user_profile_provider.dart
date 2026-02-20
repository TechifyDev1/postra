import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:postra/src/core/network/api_endpoints.dart';
import 'package:postra/src/core/network/http_client.dart';
import 'package:postra/src/core/services/cloudinary_service.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';

class UserProfile {
  final String username;
  final String fullName;
  final String? profilePictureUrl;
  final String? bgImage;
  final String? bio;
  final int postCount;
  final int numOfFollowers;
  final int numOfFollowing;

  UserProfile({
    required this.username,
    required this.fullName,
    this.profilePictureUrl,
    this.bgImage,
    this.bio,
    required this.postCount,
    required this.numOfFollowers,
    required this.numOfFollowing,
  });

  UserProfile copyWith({
    String? username,
    String? fullName,
    String? profilePictureUrl,
    String? bgImage,
    String? bio,
    int? postCount,
    int? numOfFollowers,
    int? numOfFollowing,
  }) {
    return UserProfile(
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bgImage: bgImage ?? this.bgImage,
      bio: bio ?? this.bio,
      postCount: postCount ?? this.postCount,
      numOfFollowers: numOfFollowers ?? this.numOfFollowers,
      numOfFollowing: numOfFollowing ?? this.numOfFollowing,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePictureUrl: json['profilePictureUrl'],
      bgImage: json['bgImage'],
      bio: json['bio'],
      postCount: json['postCount'] ?? 0,
      numOfFollowers: json['numOfFollowers'] ?? 0,
      numOfFollowing: json['numOfFollowing'] ?? 0,
    );
  }
}

class UserProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isFollowing;
  final bool isTogglingFollow;
  final String? socialError; // For feedback on follow/unfollow
  final bool isUploadingPic;

  UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isFollowing = false,
    this.isTogglingFollow = false,
    this.socialError,
    this.isUploadingPic = false,
  });

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isFollowing,
    bool? isTogglingFollow,
    String? socialError,
    bool? isUploadingPic,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFollowing: isFollowing ?? this.isFollowing,
      isTogglingFollow: isTogglingFollow ?? this.isTogglingFollow,
      socialError: socialError ?? this.socialError,
      isUploadingPic: isUploadingPic ?? this.isUploadingPic,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileState> {
  final HttpClient client;
  final String? currentSessionUsername;
  final CloudinaryService? _cloudinaryService;

  UserProfileNotifier(
    this.client,
    this.currentSessionUsername, {
    CloudinaryService? cloudinaryService,
  }) : _cloudinaryService = cloudinaryService,
       super(UserProfileState());

  Future<void> fetchProfile(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await client.get(
        Uri.parse(ApiEndpoints.userProfile(username)),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final profile = UserProfile.fromJson(data['data']);
          state = state.copyWith(profile: profile, isLoading: false);

          if (currentSessionUsername != null &&
              currentSessionUsername != username) {
            await checkFollowingStatus(username);
          }
        } else {
          state = state.copyWith(isLoading: false, error: data['message']);
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch: ${response.statusCode}',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkFollowingStatus(String targetUsername) async {
    try {
      final response = await client.get(
        Uri.parse(ApiEndpoints.isFollowing(targetUsername)),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          state = state.copyWith(isFollowing: data['data'] as bool? ?? false);
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> toggleFollow() async {
    if (state.profile == null || state.isTogglingFollow) return;

    final targetUsername = state.profile!.username;
    final previousFollowingState = state.isFollowing;

    state = state.copyWith(
      isFollowing: !previousFollowingState,
      isTogglingFollow: true,
      socialError: null,
    );

    try {
      final response = await client.post(
        Uri.parse(ApiEndpoints.toggleFollow(targetUsername)),
        body: jsonEncode({}),
      );

      if (response.statusCode == 401) {
        state = state.copyWith(
          isFollowing: previousFollowingState,
          socialError: 'You must be logged in to follow users.',
        );
      } else if (response.statusCode != 200) {
        state = state.copyWith(
          isFollowing: previousFollowingState,
          socialError: 'Failed to update follow status: ${response.statusCode}',
        );
      } else {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Success: Refetch profile from backend to get accurate counts
          await fetchProfile(targetUsername);
          // Also check following status again just to be safe
          await checkFollowingStatus(targetUsername);
        } else {
          state = state.copyWith(
            isFollowing: previousFollowingState,
            socialError: data['message'] ?? 'An error occurred',
          );
        }
      }
    } catch (e) {
      state = state.copyWith(
        isFollowing: previousFollowingState,
        socialError: 'Network error. Please try again.',
      );
    } finally {
      state = state.copyWith(isTogglingFollow: false);
    }
  }

  Future<bool> updateProfile({
    String? fullName,
    String? bio,
    String? profilePic,
    String? bgImage,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await client.put(
        Uri.parse(ApiEndpoints.updateProfile),
        body: jsonEncode({
          if (fullName != null) 'fullName': fullName,
          if (bio != null) 'bio': bio,
          if (profilePic != null) 'profilePic': profilePic,
          if (bgImage != null) 'bgImage': bgImage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          // Update local profile state if it exists
          if (state.profile != null) {
            state = state.copyWith(
              profile: state.profile!.copyWith(
                fullName: fullName,
                bio: bio,
                profilePictureUrl: profilePic,
                bgImage: bgImage,
              ),
              isLoading: false,
            );
          } else {
            state = state.copyWith(isLoading: false);
          }
          return true;
        } else {
          state = state.copyWith(isLoading: false, error: data['message']);
          return false;
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<String?> uploadProfilePic(File file) async {
    if (_cloudinaryService == null) return null;

    state = state.copyWith(isUploadingPic: true, error: null);
    try {
      final url = await _cloudinaryService.uploadImage(file);
      state = state.copyWith(isUploadingPic: false);
      return url;
    } catch (e) {
      state = state.copyWith(isUploadingPic: false, error: e.toString());
      return null;
    }
  }
}

final userProfileProvider =
    StateNotifierProvider.family<UserProfileNotifier, UserProfileState, String>(
      (ref, username) {
        final client = ref.read(httpClientProvider);
        final currentUsername = ref.watch(authProvider).currentUser?.username;
        final cloudinaryService = CloudinaryService(client);
        return UserProfileNotifier(
          client,
          currentUsername,
          cloudinaryService: cloudinaryService,
        );
      },
    );
