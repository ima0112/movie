import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A flow headline with one word in colour — "What **NOT** to watch today?",
/// "Which **platforms** shall we look at?". Three parts because the coloured
/// word sits in the middle of the sentence and its place changes per
/// language ([before] and [after] already carry their own spaces).
///
/// Pure presentation — everything comes in by parameter.
class AccentHeadline extends StatelessWidget {
  const AccentHeadline({
    super.key,
    required this.before,
    required this.accent,
    required this.after,
    this.accentColor = AppColors.accent,
  });

  final String before;
  final String accent;
  final String after;

  /// The colour of [accent]: amber by default; red for a "NOT".
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: before),
          TextSpan(
            text: accent,
            style: TextStyle(color: accentColor),
          ),
          TextSpan(text: after),
        ],
      ),
      style: AppTextStyles.h1Strong,
    );
  }
}
