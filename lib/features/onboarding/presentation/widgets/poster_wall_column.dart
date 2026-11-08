import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// One of `PosterWall`'s 4 columns — split out so that file stays under
/// rule 11's 150-line limit.
class PosterWallColumn extends StatelessWidget {
  const PosterWallColumn({super.key, required this.urls});

  final List<String?> urls;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final url in urls)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: url == null
                    ? const ColoredBox(color: AppColors.surfaceRaised)
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(color: AppColors.surfaceRaised),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
