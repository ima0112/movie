import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/genre_localization.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/media_detail/info_chip.dart';
import '../../../../../shared/widgets/overline_label.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import 'surprise_card_credits.dart';
import 'surprise_card_meta.dart';
import 'surprise_card_number.dart';

/// The back of a Surprise-me card (`docs/SCREENS.md` E3), same size and shape
/// as the front: the outlined number, the title, the year/duration (or
/// years/seasons) with the rating, the genres as chips, the synopsis, the credit
/// line (created or directed by) and the three leading actors — in the order of
/// the detail screens. What the title lacks (no synopsis, no cast…) is left out.
/// The content scrolls inside the card when it doesn't fit (large text).
///
/// [topAction] is the same corner control as on the front (Watch later).
/// Pure presentation — everything comes in by parameter.
class SurpriseCardBack extends StatelessWidget {
  const SurpriseCardBack({
    super.key,
    required this.suggestion,
    required this.number,
    this.topAction,
  });

  final SurpriseSuggestion suggestion;

  /// 1-based, as on the front.
  final int number;
  final Widget? topAction;

  /// The title never grows up into the number's corner.
  static const double _numberClearance = 128;

  /// How much of the top clearance is fully hidden before the content starts
  /// to show (the number's and the Watch later button's corner).
  static const double _fadeHidden = 64;
  static const double _starSize = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = suggestion.detail;
    final item = suggestion.item;
    final meta = surpriseMetaLine(detail, l10n);
    final locale = Localizations.localeOf(context).toString();
    final rating = item.voteAverage > 0
        ? NumberFormat('0.0', locale).format(item.voteAverage)
        : null;
    final overview = detail.overview.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          border: Border.all(color: AppColors.lineStrong),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: -SurpriseCardNumber.overhang,
              top: -SurpriseCardNumber.overhang,
              child: SurpriseCardNumber(number: number),
            ),
            Positioned.fill(
              child: _FadedEdges(
                top: _numberClearance,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    _numberClearance,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.h1),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (meta != null)
                            Flexible(
                              child: Text(
                                meta,
                                style: AppTextStyles.bodySm.copyWith(
                                  color: AppColors.inkMuted,
                                ),
                              ),
                            ),
                          if (rating != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            const Icon(
                              AppIcons.starFill,
                              size: _starSize,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(rating, style: AppTextStyles.bodySmStrong),
                          ],
                        ],
                      ),
                      if (item.genres.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.md),
                        LayoutBuilder(
                          builder: (context, box) => Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.xs,
                            children: [
                              for (final genre in item.genres)
                                // A long name at a large text size shrinks to
                                // fit the line rather than overflowing it.
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: box.maxWidth,
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: InfoChip(
                                      label: genre.localizedName(l10n),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                      if (overview.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        OverlineLabel(l10n.mediaDetailSynopsis),
                        const SizedBox(height: AppSpacing.sm),
                        Text(overview, style: AppTextStyles.bodySm),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      SurpriseCardCredits(detail: detail),
                    ],
                  ),
                ),
              ),
            ),
            if (topAction != null)
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: topAction!,
              ),
          ],
        ),
      ),
    );
  }
}

/// Fades [child]'s top and bottom edges into the card, like a transparent veil:
/// the scrolling content is gone over the top [top] dp's first part and shows
/// fully by [top] — which is where it rests, so nothing is veiled at rest —
/// and eases out over the last [bottom] dp. So what scrolls up never mixes with
/// the number and the corner button, and never ends in a hard line.
class _FadedEdges extends StatelessWidget {
  const _FadedEdges({required this.top, required this.child});

  final double top;
  final Widget child;

  static const double _bottom = AppSpacing.xl;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        if (!h.isFinite || h <= top + _bottom) return child;
        final hidden = SurpriseCardBack._fadeHidden / h;
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, hidden, top / h, 1 - _bottom / h, 1],
            colors: [
              AppColors.ink.withValues(alpha: 0),
              AppColors.ink.withValues(alpha: 0),
              AppColors.ink,
              AppColors.ink,
              AppColors.ink.withValues(alpha: 0),
            ],
          ).createShader(rect),
          child: child,
        );
      },
    );
  }
}
