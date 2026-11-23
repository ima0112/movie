import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/outlined_text.dart';

/// One of E1's two cards (`docs/SCREENS.md` E1): a big outlined [number]
/// ("01", "02") on the left, the [label] with a muted [subtitle] beside it and
/// the [icon] at the top right. While it is pressed (or hovered, or focused) it
/// lights up — an amber border and tint, the number and the icon in amber;
/// at rest it is a neutral card.
///
/// Pure presentation — everything comes in by parameter.
class ChooseTypeCard extends StatefulWidget {
  const ChooseTypeCard({
    super.key,
    required this.number,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  /// 1-based: the card's place in the list.
  final int number;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  State<ChooseTypeCard> createState() => _ChooseTypeCardState();
}

class _ChooseTypeCardState extends State<ChooseTypeCard> {
  bool _lit = false;

  static const double _numberStroke = 1.5;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusXxl);
    final accent = _lit;
    final numberColor = accent ? AppColors.accent : AppColors.inkMuted;
    return Semantics(
      button: true,
      label: '${widget.label}. ${widget.subtitle}',
      excludeSemantics: true,
      child: Material(
        color: accent ? AppColors.accentSoft : AppColors.surfaceRaised,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: accent ? AppColors.accent : AppColors.lineStrong,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _lit = value),
          onHover: (value) => setState(() => _lit = value),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // A decoration, not text to read: it keeps its size however
                // large the user's text is, so the words get the room.
                MediaQuery.withNoTextScaling(
                  child: ExcludeSemantics(
                    child: OutlinedText(
                      NumberFormat('00').format(widget.number),
                      style: AppTextStyles.deckNumber,
                      strokeColor: numberColor,
                      strokeWidth: _numberStroke,
                      fillOpacity: 0,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label, style: AppTextStyles.h2),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        widget.subtitle,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Icon(
                  widget.icon,
                  color: accent ? AppColors.accent : AppColors.inkMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
