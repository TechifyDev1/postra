import 'package:flutter/cupertino.dart';

class AuthInputBox extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffix;

  const AuthInputBox({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: theme.textTheme.textStyle.merge(
              TextStyle(
                fontSize: 10,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDark
                ? CupertinoColors.systemGrey6.darkColor.withValues(alpha: 0.5)
                : CupertinoColors.systemGrey6.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                  : CupertinoColors.systemGrey.withValues(alpha: 0.1),
            ),
          ),
          child: CupertinoTextField(
            controller: controller,
            placeholder: placeholder,
            obscureText: obscureText,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            placeholderStyle: TextStyle(
              color: isDark
                  ? CupertinoColors.systemGrey
                  : CupertinoColors.systemGrey2,
              fontSize: 14,
            ),
            style: theme.textTheme.textStyle.copyWith(
              fontSize: 14,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
            decoration: null,
            suffix: suffix,
            cursorColor: theme.primaryColor,
          ),
        ),
      ],
    );
  }
}
