import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class LandingHero extends StatelessWidget {
  const LandingHero({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          children: [
            const PostraImage(
              imageUrl: 'https://picsum.photos/seed/postra_hero/800/800',
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, theme.scaffoldBackgroundColor],
                  stops: const [0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
