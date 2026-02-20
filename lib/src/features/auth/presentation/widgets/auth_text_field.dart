import 'package:flutter/cupertino.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String placeholder;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.label,
    required this.placeholder,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.textStyle.merge(
            TextStyle(
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey.withValues(alpha: 0.6),
              decoration: TextDecoration.none,
            ),
          ),
        ),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          obscureText: obscureText,
          keyboardType: keyboardType,
          placeholderStyle: TextStyle(
            color: isDark
                ? CupertinoColors.systemGrey
                : CupertinoColors.systemGrey3,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          style: theme.textTheme.textStyle.merge(
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? CupertinoColors.systemGrey.withValues(alpha: 0.1)
                    : CupertinoColors.systemGrey.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
          ),
          cursorColor: theme.primaryColor,
        ),
      ],
    );
  }
}
