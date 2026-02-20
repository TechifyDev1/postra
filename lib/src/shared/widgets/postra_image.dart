import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostraImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const PostraImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    Widget imageWidget = Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: frame != null ? child : _buildPlaceholder(isDark),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(isDark);
      },
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6,
      ),
      child: const Center(child: CupertinoActivityIndicator()),
    );
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? CupertinoColors.systemGrey6.darkColor
            : CupertinoColors.systemGrey6,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey,
            size: 24,
          ),
          if (height != null && height! > 60) ...[
            const SizedBox(height: 8),
            Text(
              'Image Load Failed',
              style: TextStyle(
                fontSize: 10,
                color: isDark
                    ? CupertinoColors.systemGrey
                    : CupertinoColors.systemGrey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
