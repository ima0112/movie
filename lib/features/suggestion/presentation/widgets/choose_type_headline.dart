import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// E1's headline: "What are you in the mood for **today**?", the one word in
/// the accent color and the question mark in white.
class ChooseTypeHeadline extends StatelessWidget {
  const ChooseTypeHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '${l10n.chooseTypeHeadlineLead} '),
          TextSpan(
            text: l10n.chooseTypeHeadlineAccent,
            style: const TextStyle(color: AppColors.accent),
          ),
          const TextSpan(text: '?'),
        ],
      ),
      style: AppTextStyles.h1Strong,
    );
  }
}
