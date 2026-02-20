import 'package:flutter/cupertino.dart';
import 'package:postra/src/core/constants/app_colors.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:postra/src/features/main_tabs.dart';

class LandingActions extends StatelessWidget {
  const LandingActions({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 18),
            color: isDark ? CupertinoColors.white : AppColors.textLight,
            borderRadius: BorderRadius.circular(100),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(builder: (context) => const SignUpPage()),
              );
            },
            child: Text(
              'Get Started',
              style: TextStyle(
                color: isDark ? AppColors.textLight : CupertinoColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 2,
              ),
            ),
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(vertical: 18),
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(builder: (context) => const SignInPage()),
                );
              },
              child: Text(
                'Log In',
                style: TextStyle(
                  color: isDark ? CupertinoColors.white : AppColors.textLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (context) => const MainTabs()),
            );
          },
          child: Text(
            'Start Reading',
            style: TextStyle(
              color: isDark ? CupertinoColors.white : CupertinoColors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w500,
              color: CupertinoColors.systemGrey,
            ),
            children: [
              const TextSpan(text: 'BY CONTINUING, YOU AGREE TO OUR '),
              TextSpan(
                text: 'TERMS',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: CupertinoColors.systemGrey.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
              const TextSpan(text: ' & '),
              TextSpan(
                text: 'PRIVACY',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  decorationColor: CupertinoColors.systemGrey.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
