import 'package:flutter/material.dart';

import '../../../../../core/domain/entities/streaming_service.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/streaming_service_logo.dart';

/// Where a Surprise-me card's title can be watched: up to three logos and, next
/// to them, "3 platforms" — or "+2" when it is on more than three. Nothing at
/// all when it is on none the search counts.
class SurpriseCardPlatforms extends StatelessWidget {
  const SurpriseCardPlatforms({super.key, required this.platforms});

  final List<StreamingService> platforms;

  static const int maxLogos = 3;
  static const double _logoSize = 28;

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final shown = platforms.take(maxLogos).toList();
    final extra = platforms.length - shown.length;
    return Row(
      children: [
        for (final service in shown) ...[
          StreamingServiceLogo(service: service, size: _logoSize),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            extra > 0
                ? l10n.surpriseCardPlatformsMore(extra)
                : l10n.surpriseCardPlatforms(platforms.length),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.inkMuted),
          ),
        ),
      ],
    );
  }
}
