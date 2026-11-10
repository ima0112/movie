import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// `GenreStep`'s headline — split out so step 3's "the word 'never' in
/// amber" (`docs/SCREENS.md` A2) doesn't inflate that file past rule 11.
class GenreStepHeadline extends StatelessWidget {
  const GenreStepHeadline({
    super.key,
    required this.text,
    this.highlightWord,
    this.style,
    this.textAlign,
  });

  final String text;
  final String? highlightWord;

  /// Defaults to `h1`; the intro slides pass `display`.
  final TextStyle? style;

  /// Defaults to start-aligned; the intro slides center it.
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? AppTextStyles.h1;
    final word = highlightWord;
    final index = word == null ? -1 : text.indexOf(word);
    if (index == -1) {
      return Text(text, style: textStyle, textAlign: textAlign);
    }
    return Text.rich(
      textAlign: textAlign,
      TextSpan(
        style: textStyle,
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
