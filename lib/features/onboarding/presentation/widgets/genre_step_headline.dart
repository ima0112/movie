import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// `GenreStep`'s headline — split out so step 3's "the word 'never' in
/// amber" (`docs/SCREENS.md` A2) doesn't inflate that file past rule 11.
class GenreStepHeadline extends StatelessWidget {
  const GenreStepHeadline({super.key, required this.text, this.highlightWord});

  final String text;
  final String? highlightWord;

  @override
  Widget build(BuildContext context) {
    final word = highlightWord;
    final index = word == null ? -1 : text.indexOf(word);
    if (index == -1) {
      return Text(text, style: AppTextStyles.h1);
    }
    return Text.rich(
      TextSpan(
        style: AppTextStyles.h1,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: word,
            style: const TextStyle(color: AppColors.accent),
          ),
          TextSpan(text: text.substring(index + word!.length)),
        ],
      ),
    );
  }
}
