import 'package:flutter/material.dart';

import '../../core/domain/entities/streaming_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A streaming service's rounded logo, or the name's first letter on a flat
/// tile when TMDB has no logo (or it fails to load). Shared by B2's Platform
/// pills and the "See all" listing's context pill.
class StreamingServiceLogo extends StatelessWidget {
  const StreamingServiceLogo({
    super.key,
    required this.service,
    this.size = 24,
  });

  final StreamingService service;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = service.logoUrl;
    final letter = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        service.name.isEmpty ? '' : service.name.characters.first.toUpperCase(),
        style: AppTextStyles.captionStrong,
      ),
    );
    if (url == null) return letter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => letter,
      ),
    );
  }
}
