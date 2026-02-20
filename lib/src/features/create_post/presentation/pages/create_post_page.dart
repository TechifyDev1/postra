import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:postra/src/features/create_post/presentation/widgets/category_selector.dart';
import 'package:postra/src/features/create_post/presentation/widgets/post_toolbox.dart';
import 'package:postra/src/features/posts/data/models/post.dart';
import '../../../posts/presentation/providers/posts_provider.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  final Post? postToEdit;
  const CreatePostPage({super.key, this.postToEdit});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final QuillEditorController _editorController = QuillEditorController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedCategory = 'Article';
  File? _selectedImage;
  bool _isEditorReady = false;

  // Local state for formatting
  bool _isBold = false;
  bool _isItalic = false;
  bool _isList = false;

  @override
  void initState() {
    super.initState();
    if (widget.postToEdit != null) {
      _titleController.text = widget.postToEdit!.title;
      _subtitleController.text = widget.postToEdit!.subTitle;
    }
    // Clear any previous post creation state when entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).resetPostCreationState();
    });
    _editorController.onTextChanged((text) {
      setState(() {}); // Rebuild to update char count
    });
  }

  void _showCategoryPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CategorySelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() {
            _selectedCategory = category;
          });
        },
      ),
    );
  }

  Future<void> _pickBanner() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      // Upload immediately
      await ref.read(postsProvider.notifier).uploadBanner(_selectedImage!);
    }
  }

  Future<void> _insertImageContent() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      maxHeight: 720,
      imageQuality: 80,
    );

    if (image != null) {
      final url = await ref
          .read(postsProvider.notifier)
          .uploadImageDirectly(File(image.path));
      if (url != null) {
        // Ensure editor is focused before embedding
        _editorController.requestFocus();
        await Future.delayed(const Duration(milliseconds: 100));
        // Use insertText with HTML tag as suggested for better reliability in v2.2.8
        await _editorController.insertText(
          '<img src="$url" style="max-width: 100%; height: auto; border-radius: 8px;" /><br/>',
        );
        // Refresh state
        setState(() {});
      }
    }
  }

  void _toggleFormat(String format, dynamic value) {
    _editorController.setFormat(format: format, value: value);
    setState(() {
      if (format == 'bold') _isBold = !_isBold;
      if (format == 'italic') _isItalic = !_isItalic;
      if (format == 'list') _isList = !_isList;
    });
  }

  void _removeBanner() {
    setState(() {
      _selectedImage = null;
    });
    ref.read(postsProvider.notifier).clearBanner();
  }

  void _onPublish() async {
    final htmlContent = await _editorController.getText();

    if (_titleController.text.isEmpty || htmlContent.isEmpty) {
      _showErrorDialog('Error', 'Please fill in both title and content.');
      return;
    }

    if (_titleController.text.length < 5) {
      _showErrorDialog('Error', 'Title must be at least 5 characters long.');
      return;
    }

    if (htmlContent.length < 10) {
      _showErrorDialog('Error', 'Content must be at least 10 characters long.');
      return;
    }

    if (_subtitleController.text.isEmpty) {
      _showErrorDialog('Error', 'Please add a subtitle.');
      return;
    }

    final postsProv = ref.read(postsProvider);

    if (widget.postToEdit != null) {
      await ref
          .read(postsProvider.notifier)
          .updatePost(
            slug: widget.postToEdit!.slug,
            title: _titleController.text,
            subTitle: _subtitleController.text,
            content: htmlContent,
            postBanner:
                postsProv.uploadedBannerUrl ?? widget.postToEdit!.postBanner,
          );
    } else {
      await ref
          .read(postsProvider.notifier)
          .createPost(
            title: _titleController.text,
            subTitle: _subtitleController.text,
            content: htmlContent,
            postBanner: postsProv.uploadedBannerUrl,
          );
    }

    if (mounted) {
      final error = ref.read(postsProvider).creatingPostError;
      if (error != null) {
        _showErrorDialog('Failed to publish', error);
      } else {
        // Refresh posts and navigate back
        ref.read(postsProvider.notifier).getPosts();
        ref.read(postsProvider.notifier).resetPostCreationState();
        Navigator.pop(context);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _editorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final postsProv = ref.watch(postsProvider);
    final isLoading = postsProv.isCreatingPost;
    final isUploadingBanner = postsProv.isUploadingBanner;

    // Theme-aware colors
    final Color bgColor = isDark
        ? CupertinoColors.black
        : CupertinoColors.white;
    final Color textColor = isDark
        ? CupertinoColors.white
        : CupertinoColors.black;
    final Color mutedTextColor = isDark
        ? const Color(0x66FFFFFF)
        : const Color(0x66000000);
    final Color placeholderColor = isDark
        ? const Color(0x33FFFFFF)
        : const Color(0x33000000);

    return CupertinoPageScaffold(
      backgroundColor: bgColor,
      child: Stack(
        children: [
          // Main Content
          Column(
            children: [
              const SizedBox(height: 85), // Space for header
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Container
                      _buildBannerContainer(
                        placeholderColor,
                        isDark,
                        isUploadingBanner,
                      ),
                      const SizedBox(height: 32),

                      // Title Field
                      CupertinoTextField(
                        controller: _titleController,
                        placeholder: "Title",
                        placeholderStyle: TextStyle(
                          color: placeholderColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                        ),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontFamily: 'Inter',
                        ),
                        padding: EdgeInsets.zero,
                        decoration: null,
                        maxLines: null,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 12),

                      // Subtitle Field
                      CupertinoTextField(
                        controller: _subtitleController,
                        placeholder: "Subtitle",
                        placeholderStyle: TextStyle(
                          color: placeholderColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Inter',
                        ),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: mutedTextColor,
                          fontFamily: 'Inter',
                        ),
                        padding: EdgeInsets.zero,
                        decoration: null,
                        maxLines: null,
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 32),

                      // Content Body - HTML Editor
                      Container(
                        constraints: const BoxConstraints(minHeight: 400),
                        child: QuillHtmlEditor(
                          controller: _editorController,
                          isEnabled: !isLoading,
                          minHeight: 400,
                          hintText: 'Start writing your story...',
                          ensureVisible: true,
                          autoFocus: false,
                          hintTextStyle: TextStyle(
                            color: isDark
                                ? CupertinoColors.systemGrey
                                : CupertinoColors.systemGrey,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Inter',
                          ),
                          textStyle: TextStyle(
                            fontSize: 18,
                            height: 1.6,
                            color: textColor.withValues(alpha: 0.9),
                            fontFamily: 'Inter',
                          ),
                          backgroundColor: bgColor,
                          onFocusChanged: (hasFocus) {
                            if (hasFocus) setState(() {});
                          },
                          onTextChanged: (text) {
                            // Handled in initState
                          },
                          onSelectionChanged: (selection) {
                            // Listening for selection updates as suggested by the user
                            // This helps ensure selection handles are handled properly by the WebView
                            if (selection.length! > 0) {
                              // Selection active
                            }
                          },
                          onEditorCreated: () {
                            _isEditorReady = true;
                            if (widget.postToEdit != null) {
                              _editorController.setText(
                                widget.postToEdit!.content,
                              );
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      const SizedBox(height: 100), // Space for footer
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Custom Sticky Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.8),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? const Color(0x1AFFFFFF)
                            : const Color(0x1A000000),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          onPressed: isLoading
                              ? null
                              : () {
                                  ref
                                      .read(postsProvider.notifier)
                                      .resetPostCreationState();
                                  Navigator.pop(context);
                                },
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: mutedTextColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          widget.postToEdit != null ? 'EDIT POST' : 'NEW POST',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5,
                            color: mutedTextColor,
                            fontFamily: 'Inter',
                            decoration: TextDecoration.none,
                          ),
                        ),
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          borderRadius: BorderRadius.circular(100),
                          onPressed: isLoading ? null : _onPublish,
                          child: isLoading
                              ? CupertinoActivityIndicator(
                                  color: isDark
                                      ? CupertinoColors.black
                                      : CupertinoColors.white,
                                )
                              : Text(
                                  widget.postToEdit != null
                                      ? 'Update'
                                      : 'Publish',
                                  style: TextStyle(
                                    color: isDark
                                        ? CupertinoColors.black
                                        : CupertinoColors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Custom Footer
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: PostToolbox(
              onImagePick: isLoading ? () {} : _insertImageContent,
              onCategoryTap: isLoading ? () {} : _showCategoryPicker,
              isBoldActive: _isBold,
              isItalicActive: _isItalic,
              isListActive: _isList,
              onBoldTap: () => _toggleFormat('bold', !_isBold),
              onItalicTap: () => _toggleFormat('italic', !_isItalic),
              onLinkTap: () {
                // Future: implementation for links
              },
              onListTap: () => _toggleFormat('list', _isList ? '' : 'bullet'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerContainer(
    Color placeholderColor,
    bool isDark,
    bool isUploading,
  ) {
    final postsProv = ref.watch(postsProvider);
    final hasImage =
        _selectedImage != null ||
        postsProv.uploadedBannerUrl != null ||
        (widget.postToEdit?.postBanner != null &&
            widget.postToEdit!.postBanner.isNotEmpty);

    return GestureDetector(
      onTap: isUploading ? null : _pickBanner,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000),
              width: 2,
              style: BorderStyle.solid,
            ),
            image: hasImage && !isUploading
                ? DecorationImage(
                    image: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (postsProv.uploadedBannerUrl != null
                              ? NetworkImage(postsProv.uploadedBannerUrl!)
                                    as ImageProvider
                              : NetworkImage(widget.postToEdit!.postBanner)
                                    as ImageProvider),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? Stack(
                  children: [
                    if (isUploading)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                    if (!isUploading)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _removeBanner,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: CupertinoColors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 32,
                      color: placeholderColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ADD COVER IMAGE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: placeholderColor,
                        fontFamily: 'Inter',
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
