import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostToolbox extends StatelessWidget {
  final VoidCallback onImagePick;
  final VoidCallback onCategoryTap;
  final VoidCallback onBoldTap;
  final VoidCallback onItalicTap;
  final VoidCallback onLinkTap;
  final VoidCallback onListTap;

  final bool isBoldActive;
  final bool isItalicActive;
  final bool isLinkActive;
  final bool isListActive;

  const PostToolbox({
    super.key,
    required this.onImagePick,
    required this.onCategoryTap,
    required this.onBoldTap,
    required this.onItalicTap,
    required this.onLinkTap,
    required this.onListTap,
    this.isBoldActive = false,
    this.isItalicActive = false,
    this.isLinkActive = false,
    this.isListActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color bgColor = isDark
        ? CupertinoColors.black
        : CupertinoColors.white;
    final Color borderColor = isDark
        ? const Color(0x1AFFFFFF) // white/10
        : const Color(0x1A000000); // black/10
    final Color iconColor = isDark
        ? const Color(0x66FFFFFF) // white/40
        : const Color(0x66000000); // black/40
    final Color statusTextColor = isDark
        ? const Color(0x4DFFFFFF) // white/30
        : const Color(0x4D000000); // black/30
    final Color dotColor = isDark
        ? const Color(0x33FFFFFF) // white/20
        : const Color(0x33000000); // black/20

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(top: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Formatting Icons
            _buildIconButton(
              Icons.format_bold_outlined,
              onBoldTap,
              iconColor,
              isActive: isBoldActive,
            ),
            _buildIconButton(
              Icons.format_italic_outlined,
              onItalicTap,
              iconColor,
              isActive: isItalicActive,
            ),
            _buildIconButton(
              Icons.link,
              onLinkTap,
              iconColor,
              isActive: isLinkActive,
            ),
            _buildIconButton(Icons.image_outlined, onImagePick, iconColor),
            _buildIconButton(
              Icons.format_list_bulleted,
              onListTap,
              iconColor,
              isActive: isListActive,
            ),

            const Spacer(),

            // Saved Status
            Row(
              children: [
                Text(
                  'SAVED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: statusTextColor,
                    fontFamily: 'Inter',
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(
    IconData icon,
    VoidCallback onTap,
    Color baseColor, {
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive
            ? baseColor.withValues(alpha: 0.25)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive
            ? Border.all(color: baseColor.withValues(alpha: 0.3), width: 1)
            : null,
      ),
      child: Focus(
        canRequestFocus: false,
        child: IconButton(
          icon: Icon(
            icon,
            color: isActive ? baseColor : baseColor.withOpacity(0.7),
            size: 22,
          ),
          onPressed: onTap,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}
