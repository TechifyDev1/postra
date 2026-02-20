import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:postra/main.dart';
import 'package:postra/src/core/constants/app_colors.dart';
import 'package:postra/src/features/landing/presentation/widgets/landing_actions.dart';
import 'package:postra/src/features/landing/presentation/widgets/landing_header.dart';
import 'package:postra/src/features/landing/presentation/widgets/landing_hero.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: DefaultTextStyle(
                      style: theme.textTheme.textStyle,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 40),
                            // Upper Content
                            const LandingHeader(),

                            const SizedBox(height: 40),

                            // Center Content (Hero)
                            const LandingHero(),

                            const SizedBox(height: 40),

                            // Bottom Content
                            const LandingActions(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Theme Toggle
          Positioned(
            top: 48,
            right: 24,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => MyApp.of(context).toggleTheme(),
                child: CircleAvatar(
                  backgroundColor: isDark
                      ? AppColors.surfaceDark
                      : Colors.white,
                  child: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
