import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/user_profile/presentation/providers/user_profile_provider.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  final ImagePicker _imagePicker = ImagePicker();
  String? _uploadedProfilePicUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).currentUser;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Navigation Bar
          _buildNavBar(context, isDark, theme),

          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    24,
                    32,
                    24,
                    120 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    children: [
                      // Avatar Section
                      _buildAvatarSection(isDark, theme),
                      const SizedBox(height: 48),

                      // Form Fields
                      _buildField(
                        label: 'Full Name',
                        controller: _nameController,
                        isDark: isDark,
                        theme: theme,
                      ),
                      const SizedBox(height: 32),
                      _buildField(
                        label: 'Bio',
                        controller: _bioController,
                        isDark: isDark,
                        theme: theme,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 64),

                      // Dangerous Area
                      _buildDeleteButton(),
                    ],
                  ),
                ),

                // Sticky Bottom Action
                _buildStickyFooter(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onSave() async {
    final user = ref.read(authProvider).currentUser;
    if (user == null) return;

    final success = await ref
        .read(userProfileProvider(user.username).notifier)
        .updateProfile(
          fullName: _nameController.text,
          bio: _bioController.text,
          profilePic: _uploadedProfilePicUrl ?? user.profilePictureUrl,
        );

    if (mounted) {
      if (success) {
        // Refresh Current User in AuthProvider to update local state everywhere
        await ref.read(authProvider.notifier).getCurrentUser();
        if (mounted) {
          Navigator.pop(context);
          _showSuccess('Profile updated successfully');
        }
      } else {
        _showError(
          ref.read(userProfileProvider(user.username)).error ?? 'Save failed',
        );
      }
    }
  }

  void _showSuccess(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Success'),
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

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
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

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      final user = ref.read(authProvider).currentUser;
      if (user == null) return;

      final url = await ref
          .read(userProfileProvider(user.username).notifier)
          .uploadProfilePic(File(image.path));

      if (url != null) {
        setState(() {
          _uploadedProfilePicUrl = url;
        });
      }
    }
  }

  Widget _buildNavBar(
    BuildContext context,
    bool isDark,
    CupertinoThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                : CupertinoColors.systemGrey6,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 17,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  'Edit Profile',
                  style: theme.textTheme.textStyle.merge(
                    const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(width: 60), // Spacer for centering
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(bool isDark, CupertinoThemeData theme) {
    final user = ref.watch(authProvider).currentUser;
    final profileState = ref.watch(userProfileProvider(user?.username ?? ''));
    final isUploading = profileState.isUploadingPic;

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? CupertinoColors.systemGrey6.darkColor
                      : CupertinoColors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  _uploadedProfilePicUrl ??
                      user?.profilePictureUrl ??
                      'https://picsum.photos/seed/user/200/200',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CupertinoActivityIndicator(
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            if (!isUploading)
              Positioned.fill(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.camera_fill,
                        color: CupertinoColors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: isUploading ? null : _pickImage,
          child: Text(
            'Change Photo',
            style: TextStyle(
              fontSize: 14,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
    required CupertinoThemeData theme,
    int maxLines = 1,
    Color? textColor,
    IconData? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                : CupertinoColors.systemGrey6,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.textStyle.merge(
                TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? CupertinoColors.systemGrey
                      : CupertinoColors.systemGrey3,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CupertinoTextField(
                  controller: controller,
                  maxLines: maxLines,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  style: theme.textTheme.textStyle.merge(
                    TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          textColor ??
                          (isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black),
                    ),
                  ),
                  decoration: null,
                  cursorColor: theme.primaryColor,
                ),
              ),
              if (suffixIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    suffixIcon,
                    size: 16,
                    color: isDark
                        ? CupertinoColors.systemGrey
                        : CupertinoColors.systemGrey3,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.trash,
              size: 20,
              color: CupertinoColors.systemRed,
            ),
            const SizedBox(width: 8),
            const Text(
              'Delete Account',
              style: TextStyle(
                fontSize: 14,
                color: CupertinoColors.systemRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyFooter(bool isDark) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final user = ref.watch(authProvider).currentUser;
    final profileState = ref.watch(userProfileProvider(user?.username ?? ''));
    final isLoading = profileState.isLoading;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (isDark ? CupertinoColors.black : CupertinoColors.white)
                  .withValues(alpha: 0),
              isDark ? CupertinoColors.black : CupertinoColors.white,
            ],
            stops: const [0, 0.4],
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 20),
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            borderRadius: BorderRadius.circular(100),
            onPressed: isLoading ? null : _onSave,
            child: isLoading
                ? CupertinoActivityIndicator(
                    color: isDark
                        ? CupertinoColors.black
                        : CupertinoColors.white,
                  )
                : Text(
                    'Save Changes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: isDark
                          ? CupertinoColors.black
                          : CupertinoColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
