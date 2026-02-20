import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class SearchResultItem extends StatelessWidget {
  final String topic;
  final String title;
  final String snippet;
  final String time;
  final String views;
  final String? imageUrl;
  final VoidCallback? onTap;

  const SearchResultItem({
    super.key,
    required this.topic,
    required this.title,
    required this.snippet,
    required this.time,
    required this.views,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final theme = CupertinoTheme.of(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9), // slate-800 / slate-100
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                          letterSpacing: -0.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                          height: 1.2,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          height: 1.5,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                if (imageUrl != null) ...[
                  const SizedBox(width: 16),
                  PostraImage(
                    imageUrl: imageUrl!,
                    width: 80,
                    height: 80,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MetaItem(icon: Icons.schedule_rounded, text: time),
                const SizedBox(width: 16),
                _MetaItem(icon: Icons.visibility_rounded, text: views),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF94A3B8),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
