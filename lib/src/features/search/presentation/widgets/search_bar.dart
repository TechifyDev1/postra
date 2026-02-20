import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCancel;

  const AppSearchBar({super.key, required this.controller, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: CupertinoSearchTextField(
              controller: controller,
              placeholder: 'Search posts...',
              autofocus: true,
              prefixInsets: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
              placeholderStyle: TextStyle(
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B), // textDarkMuted / textLightMuted
                fontSize: 17,
                fontFamily: 'Inter',
              ),
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                fontSize: 17,
                fontFamily: 'Inter',
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(100),
              ),
              itemColor: const Color(0xFF94A3B8), // slate-400
              onChanged: (value) {
                // Handle search
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        CupertinoButton(
          padding: EdgeInsets.zero,
          minimumSize: Size(0, 0),
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: theme.primaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 17,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ],
    );
  }
}
