import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:postra/src/core/network/http_client.dart';
import 'package:postra/src/core/services/cloudinary_service.dart';
import 'package:postra/src/features/posts/data/models/comment.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import 'package:postra/src/features/posts/domain/usecases/add_comment_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/create_post_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/delete_post_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/get_comments_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/get_posts_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/toggle_like_usecase.dart';
import 'package:postra/src/features/posts/domain/usecases/update_post_usecase.dart';

final postsProvider = ChangeNotifierProvider<PostsProvider>((ref) {
  final getPostsUseCase = ref.read(getPostsUseCaseProvider);
  final createPostUseCase = ref.read(createPostUseCaseProvider);
  final updatePostUseCase = ref.read(updatePostUseCaseProvider);
  final deletePostUseCase = ref.read(deletePostUseCaseProvider);
  final toggleLikeUseCase = ref.read(toggleLikeUseCaseProvider);
  final getCommentsUseCase = ref.read(getCommentsUseCaseProvider);
  final addCommentUseCase = ref.read(addCommentUseCaseProvider);
  final httpClient = ref.read(httpClientProvider);
  final cloudinaryService = CloudinaryService(httpClient);

  return PostsProvider(
    getPostsUseCase,
    createPostUseCase,
    updatePostUseCase,
    deletePostUseCase,
    toggleLikeUseCase,
    getCommentsUseCase,
    addCommentUseCase,
    cloudinaryService: cloudinaryService,
  );
});

class PostsProvider extends ChangeNotifier {
  final GetPostsUseCase _getPostsUseCase;
  final CreatePostUseCase _createPostUseCase;
  final UpdatePostUseCase _updatePostUseCase;
  final DeletePostUseCase _deletePostUseCase;
  final ToggleLikeUseCase _toggleLikeUseCase;
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final CloudinaryService? _cloudinaryService;

  PostsProvider(
    this._getPostsUseCase,
    this._createPostUseCase,
    this._updatePostUseCase,
    this._deletePostUseCase,
    this._toggleLikeUseCase,
    this._getCommentsUseCase,
    this._addCommentUseCase, {
    CloudinaryService? cloudinaryService,
  }) : _cloudinaryService = cloudinaryService;

  List<Post> _posts = [];
  bool _isGettingPosts = false;
  String? _gettingPostsError;
  bool _isCreatingPost = false;
  String? _creatingPostError;
  bool _isDeletingPost = false;

  // Comments state
  List<Comment> _comments = [];
  bool _isGettingComments = false;
  String? _gettingCommentsError;
  bool _isAddingComment = false;
  String? _addingCommentError;

  // Banner upload state
  bool _isUploadingBanner = false;
  String? _uploadingBannerError;
  String? _uploadedBannerUrl;

  List<Post> get posts => _posts;
  bool get isGettingPosts => _isGettingPosts;
  String? get gettingPostsError => _gettingPostsError;
  bool get isCreatingPost => _isCreatingPost;
  String? get creatingPostError => _creatingPostError;
  bool get isDeletingPost => _isDeletingPost;

  List<Comment> get comments => _comments;
  bool get isGettingComments => _isGettingComments;
  String? get gettingCommentsError => _gettingCommentsError;
  bool get isAddingComment => _isAddingComment;
  String? get addingCommentError => _addingCommentError;

  bool get isUploadingBanner => _isUploadingBanner;
  String? get uploadingBannerError => _uploadingBannerError;
  String? get uploadedBannerUrl => _uploadedBannerUrl;

  // Get a specific post by slug
  Post? getPostBySlug(String slug) {
    try {
      return _posts.firstWhere((post) => post.slug == slug);
    } catch (e) {
      return null;
    }
  }

  Future<void> getPosts() async {
    _isGettingPosts = true;
    notifyListeners();

    try {
      final fetchedPosts = await _getPostsUseCase.execute();

      // Parallel fetch isLiked for each post
      final postsWithLikedStatus = await Future.wait(
        fetchedPosts.map((post) async {
          try {
            final liked = await _toggleLikeUseCase.isLiked(post.slug);
            return post.copyWith(isLiked: liked);
          } catch (e) {
            return post;
          }
        }),
      );

      _posts = postsWithLikedStatus;
    } catch (e) {
      _gettingPostsError = e.toString();
    } finally {
      _isGettingPosts = false;
      notifyListeners();
    }
  }

  Future<void> createPost({
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    _isCreatingPost = true;
    notifyListeners();

    try {
      await _createPostUseCase.execute(
        title: title,
        subTitle: subTitle,
        content: content,
        postBanner: postBanner,
      );
      clearBanner();
    } catch (e) {
      _creatingPostError = e.toString();
    } finally {
      _isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<void> updatePost({
    required String slug,
    required String title,
    required String subTitle,
    required String content,
    String? postBanner,
  }) async {
    _isCreatingPost = true; // Reusing this for simplicity
    notifyListeners();

    try {
      final updatedPost = await _updatePostUseCase.execute(
        slug: slug,
        title: title,
        subTitle: subTitle,
        content: content,
        postBanner: postBanner,
      );

      // Update local state
      final index = _posts.indexWhere((p) => p.slug == slug);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
      clearBanner();
    } catch (e) {
      _creatingPostError = e.toString();
    } finally {
      _isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> deletePost(String slug) async {
    _gettingPostsError = null;
    _isDeletingPost = true;
    notifyListeners();

    try {
      await _deletePostUseCase.execute(slug);
      _posts.removeWhere((p) => p.slug == slug);
      _isDeletingPost = false;
      notifyListeners();
      return true;
    } catch (e) {
      _gettingPostsError = e.toString();
      _isDeletingPost = false;
      notifyListeners();
      return false;
    }
  }

  void resetPostCreationState() {
    _uploadedBannerUrl = null;
    _uploadingBannerError = null;
    _creatingPostError = null;
    _isCreatingPost = false;
    _isUploadingBanner = false;
    notifyListeners();
  }

  Future<void> uploadBanner(File imageFile) async {
    if (_cloudinaryService == null) {
      _uploadingBannerError = 'Cloudinary service not initialized';
      notifyListeners();
      return;
    }

    _isUploadingBanner = true;
    _uploadingBannerError = null;
    _uploadedBannerUrl = null;
    notifyListeners();

    try {
      final url = await _cloudinaryService.uploadImage(imageFile);
      _uploadedBannerUrl = url;
    } catch (e) {
      _uploadingBannerError = e.toString();
    } finally {
      _isUploadingBanner = false;
      notifyListeners();
    }
  }

  Future<String?> uploadImageDirectly(File imageFile) async {
    if (_cloudinaryService == null) return null;
    try {
      return await _cloudinaryService.uploadImage(imageFile);
    } catch (e) {
      return null;
    }
  }

  void clearBanner() {
    _uploadedBannerUrl = null;
    _uploadingBannerError = null;
    notifyListeners();
  }

  Future<void> toggleLike(Post post) async {
    final index = _posts.indexWhere((p) => p.slug == post.slug);
    if (index == -1) return;

    final originalPost = _posts[index];
    final wasLiked = originalPost.isLiked;

    // Optimistic Update
    _posts[index] = originalPost.copyWith(
      isLiked: !wasLiked,
      likeCount: wasLiked
          ? originalPost.likeCount - 1
          : originalPost.likeCount + 1,
    );
    notifyListeners();

    try {
      final result = await _toggleLikeUseCase.execute(post.slug);
      // Use backend's actual count and status
      _posts[index] = _posts[index].copyWith(
        isLiked: result['isLiked'] as bool,
        likeCount: result['totalLikes'] as int,
      );
      notifyListeners();
    } catch (e) {
      // Rollback on error
      _posts[index] = originalPost;
      notifyListeners();
    }
  }

  Future<void> getComments(String slug) async {
    _isGettingComments = true;
    _comments = []; // Clear previous comments
    notifyListeners();

    try {
      _comments = await _getCommentsUseCase.execute(slug);
    } catch (e) {
      _gettingCommentsError = e.toString();
    } finally {
      _isGettingComments = false;
      notifyListeners();
    }
  }

  Future<void> addComment(
    String slug,
    String content,
    String username,
    String? profilePic,
  ) async {
    _isAddingComment = true;
    _addingCommentError = null;

    // Optimistic Update
    final tempComment = Comment(
      content: content,
      authorUsername: username,
      profilePictureUrl: profilePic,
      createdAt: DateTime.now().toIso8601String(),
    );

    final originalComments = List<Comment>.from(_comments);
    _comments = [..._comments, tempComment];

    // Update comment count in the post list
    final postIndex = _posts.indexWhere((p) => p.slug == slug);
    final originalPost = postIndex != -1 ? _posts[postIndex] : null;
    if (originalPost != null) {
      _posts[postIndex] = originalPost.copyWith(
        commentCount: originalPost.commentCount + 1,
      );
    }

    notifyListeners();

    try {
      final newComment = await _addCommentUseCase.execute(slug, content);
      // Replace temp comment with actual comment from backend
      _comments = [...originalComments, newComment];
      notifyListeners();
    } catch (e) {
      _addingCommentError = e.toString();
      // Rollback
      _comments = originalComments;
      if (originalPost != null) {
        _posts[postIndex] = originalPost;
      }
      notifyListeners();
    } finally {
      _isAddingComment = false;
      notifyListeners();
    }
  }
}
