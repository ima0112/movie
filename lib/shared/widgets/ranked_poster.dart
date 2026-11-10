import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'outlined_text.dart';

/// Puts a big rank number (1, 2, 3…) over the bottom-left corner of [child]
/// (a poster card), on a soft fade to the page color so it stays legible on
/// any artwork — B2's "Top today". With a `null` [rank] it is just [child].
///
/// The number doesn't take touches: the card underneath keeps its own tap.
class RankedPoster extends StatelessWidget {
  const RankedPoster({super.key, required this.rank, required this.child});

  final int? rank;
  final Widget child;

  /// How much of the poster, from the bottom, the fade covers.
  static const double _fadeShare = 0.6;

  @override
  Widget build(BuildContext context) {
    final rank = this.rank;
    if (rank == null) return child;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: FractionallySizedBox(
                  heightFactor: _fadeShare,
                  widthFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surface.withValues(alpha: 0),
                          AppColors.surface.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.sm,
                          bottom: 0,
                        ),
                        // A narrow grid cell (or a 3-digit rank) shrinks the
                        // number instead of overflowing.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.bottomLeft,
                          child: OutlinedText(
                            '$rank',
                            style: AppTextStyles.rank,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
