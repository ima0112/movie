import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// One streaming service as a rounded logo square. [size] is its edge;
/// [showName] adds the service name under it (the Streaming group does,
/// Rent/Buy don't). With no [logoUrl] — or if it fails to load — it shows
/// the name's first letter on a flat tile, so a missing logo never leaves a
/// hole. Tapping calls [onTap] (opens JustWatch's own link).
class ProviderLogoTile extends StatelessWidget {
  const ProviderLogoTile({
    super.key,
    required this.name,
    required this.size,
    this.logoUrl,
    this.showName = false,
    this.onTap,
  });

  final String name;
  final String? logoUrl;
  final double size;
  final bool showName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(
      size >= 56 ? AppSpacing.radiusMd + 2 : AppSpacing.radiusMd - 2,
    );
    final initial = name.isEmpty ? '' : name.characters.first.toUpperCase();
    final fallback = ColoredBox(
      color: AppColors.surfaceRaised2,
      child: Center(
        child: Text(
          initial,
          style: AppTextStyles.h3.copyWith(color: AppColors.inkMuted),
        ),
      ),
    );
    final url = logoUrl;

    return Semantics(
      button: onTap != null,
      label: name,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: showName ? size + AppSpacing.xs : size,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: radius,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: url == null
                      ? fallback
                      : Image.network(
                          url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              fallback,
                        ),
                ),
              ),
              if (showName) ...[
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
