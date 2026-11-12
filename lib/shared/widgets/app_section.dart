import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'overline_label.dart';

/// The one building block for a titled block of a scrolling screen
/// ("Cast", "Similar movies", a Discover carousel…): [AppSpacing.sectionGap]
/// above, an optional heading row (`h2` title and an amber [actionLabel]),
/// [AppSpacing.headingGap], then [child].
///
/// Screens compose sections instead of placing gaps and heading styles by
/// hand, so the vertical rhythm and the heading look are defined here once
/// for the whole app. The section owns only its *top* spacing; one that
/// hides itself (renders nothing) leaves no hole.
///
/// [inset] — `true` (default) pads [child] with the screen margin; `false`
/// for content that scrolls edge to edge and pads its own rows.
class AppSection extends StatelessWidget {
  const AppSection({
    super.key,
    required this.child,
    this.title,
    this.actionLabel,
    this.onAction,
    this.inset = true,
  }) : _overline = false;

  /// A section headed by a small capitalised [OverlineLabel] instead of an
  /// `h2` ("NEXT EPISODE", "SEASONS" on D2b).
  const AppSection.overline({
    super.key,
    required this.child,
    required String this.title,
    this.inset = true,
  }) : actionLabel = null,
       onAction = null,
       _overline = true;

  final bool _overline;

  final Widget child;
  final String? title;

  /// The amber text action at the end of the heading ("See all"). Shown only
  /// with a [title]; [onAction] may be null (then it is only a label).
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    return Padding(
      padding: AppSpacing.sectionTopPadding,
      child: Column(
        // Full width, so a card in a section is as wide as every other one.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenMargin,
              ),
              child: _overline
                  ? OverlineLabel(title)
                  : _Heading(
                      title: title,
                      actionLabel: actionLabel,
                      onAction: onAction,
                    ),
            ),
            const SizedBox(height: AppSpacing.headingGap),
          ],
          inset
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenMargin,
                  ),
                  child: child,
                )
              : child,
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final actionLabel = this.actionLabel;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.h2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null) ...[
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: onAction,
            behavior: HitTestBehavior.opaque,
            child: Text(actionLabel, style: AppTextStyles.action),
          ),
        ],
      ],
    );
  }
}
