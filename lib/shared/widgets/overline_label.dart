import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

/// The small capitalised label above a block ("SYNOPSIS", "GUEST STARS",
/// a settings group's name): [AppTextStyles.overline] with the text
/// upper-cased, so every such label looks the same.
class OverlineLabel extends StatelessWidget {
  const OverlineLabel(this.text, {super.key, this.textAlign});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: AppTextStyles.overline,
    textAlign: textAlign,
  );
}
