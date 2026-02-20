import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // App Logo Container
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: isDark ? CupertinoColors.white : CupertinoColors.black,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: CupertinoColors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            Icons.auto_stories,
            size: 40,
            color: isDark ? CupertinoColors.black : CupertinoColors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Postra',
          style: theme.textTheme.navLargeTitleTextStyle.merge(
            const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'The minimalist space for elegant thoughts and storytelling.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
