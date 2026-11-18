import 'package:flutter/material.dart';

import '../../../../../core/domain/entities/media_detail.dart';
import '../../../../../core/domain/entities/person.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/media_detail/media_cast_circle.dart';
import '../../../../../shared/widgets/media_detail/media_byline.dart';

/// The people on the back of a Surprise-me card, laid out like the detail
/// screens' Cast section: the "Cast" heading, a credit line under it — "Created
/// by" (a series' creators) or "Directed by" (a film's directors), muted label
/// and the names — and the three leading actors as 64 dp avatars with name and
/// character. Each part is left out when TMDB has nothing for it.
///
/// Pure presentation — everything comes from the [detail] it is given.
class SurpriseCardCredits extends StatelessWidget {
  const SurpriseCardCredits({super.key, required this.detail});

  final MediaDetail detail;

  /// The actors shown.
  static const int castCount = 3;
  static const double _avatar = 64;

  /// The people behind the title: a series' creators or a film's directors, each
  /// once, in TMDB's order.
  static List<Person> creditedPeople(MediaDetail detail) => switch (detail) {
    TvShowDetail(:final creators) => creators,
    MovieDetail() => _directors(detail),
  };

  static List<Person> _directors(MediaDetail detail) {
    final seen = <int>{};
    return [
      for (final m in detail.crew)
        if (m.job == 'Director' && seen.add(m.person.id)) m.person,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final people = creditedPeople(detail);
    final cast = detail.cast.take(castCount).toList();
    final byline = MediaByline(
      label: detail is TvShowDetail
          ? l10n.mediaCreatedByLabel
          : l10n.mediaDirectedByLabel,
      people: people,
    );

    // As on the detail screens: the "Cast" heading, the credit line under it,
    // then the avatars.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cast.isNotEmpty) ...[
          Text(l10n.fullCastCastLabel, style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.headingGap),
        ],
        if (people.isNotEmpty) ...[
          byline,
          const SizedBox(height: AppSpacing.md),
        ],
        if (cast.isNotEmpty)
          Row(
            children: [
              for (final member in cast)
                Expanded(
                  child: Center(
                    child: MediaCastCircle(
                      member: member,
                      size: _avatar,
                      // The card's own tap turns it back; people aren't links
                      // here.
                      onTap: () {},
                    ),
                  ),
                ),
              // Keeps one or two actors in the same columns as three.
              for (var i = cast.length; i < castCount; i++)
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
      ],
    );
  }
}
