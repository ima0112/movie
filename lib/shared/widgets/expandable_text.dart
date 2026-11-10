import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// Text folded to [maxLines] with an amber "Read more" that flips to
/// "Read less" once expanded — shared by every synopsis/biography so they
/// behave alike. The toggle only exists when the folded text is really cut;
/// text that fits shows no toggle at all.
///
/// The expanded flag is local state (CLAUDE.md rule 10): it means nothing
/// outside this widget.
class ExpandableText extends StatefulWidget {
  const ExpandableText(
    this.text, {
    super.key,
    required this.maxLines,
    this.style,
  });

  final String text;
  final int maxLines;

  /// Defaults to [AppTextStyles.body].
  final TextStyle? style;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  TextStyle get _style => widget.style ?? AppTextStyles.body;

  bool _overflows(double width) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: _style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: widget.maxLines,
    )..layout(maxWidth: width);
    final result = painter.didExceedMaxLines;
    painter.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final overflows = _overflows(constraints.maxWidth);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: _style,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows) ...[
              const SizedBox(height: AppSpacing.xs),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                behavior: HitTestBehavior.opaque,
                child: Text(
                  _expanded
                      ? context.l10n.commonReadLess
                      : context.l10n.commonReadMore,
                  style: AppTextStyles.action,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
