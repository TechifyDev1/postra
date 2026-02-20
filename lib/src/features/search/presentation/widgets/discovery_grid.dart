import 'package:flutter/material.dart';
import 'package:postra/src/shared/widgets/postra_image.dart';

class DiscoveryGrid extends StatelessWidget {
  const DiscoveryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> images = [
      'https://picsum.photos/seed/arch/400/600',
      'https://picsum.photos/seed/minimal/400/400',
      'https://picsum.photos/seed/photo/400/500',
      'https://picsum.photos/seed/ui/400/700',
      'https://picsum.photos/seed/brand/400/400',
      'https://picsum.photos/seed/art/400/600',
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: PostraImage(
                imageUrl: images[index % images.length],
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }, childCount: 12),
      ),
    );
  }
}
