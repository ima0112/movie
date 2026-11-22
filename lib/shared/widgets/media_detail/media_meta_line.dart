import 'package:flutter/material.dart';

import '../../../core/domain/entities/genre.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/genre_localization.dart';
import '../../../l10n/l10n_extension.dart';

/// D1/D2's meta line, under the title and tagline: "2008 – 2013 · United
/// States · Drama · Crime · English" in muted text. [prefix] is the year(s) and
/// country, each genre in [genres] is tappable (→ C1 with that genre), and
/// [language] — the original language's name — closes the line.
class MediaMetaLine extends StatelessWidget {
  const MediaMetaLine({
    super.key,
    required this.prefix,
    required this.genres,
    this.language,
    this.onGenreTap,
  });

  final String prefix;
  final List<Genre> genres;
  final String? language;
  final void Function(Genre genre)? onGenreTap;

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    final language = this.language?.trim();
    final parts = <Widget>[
      if (prefix.isNotEmpty) Text(prefix, style: style),
      for (final genre in genres)
        GestureDetector(
          onTap: () => onGenreTap?.call(genre),
          behavior: HitTestBehavior.opaque,
          child: Text(genre.localizedName(context.l10n), style: style),
        ),
      if (language != null && language.isNotEmpty) Text(language, style: style),
    ];
    return Wrap(
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0) Text(' · ', style: style),
          parts[i],
        ],
      ],
    );
  }
}
