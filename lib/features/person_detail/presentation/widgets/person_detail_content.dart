import 'package:flutter/material.dart';
import '../../../../shared/widgets/tmdb_footer.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../l10n/l10n_extension.dart';
import 'known_for.dart';
import 'person_age_label.dart';
import 'person_biography_section.dart';
import 'person_detail_header.dart';
import 'person_filmography_link_card.dart';
import 'person_known_for_section.dart';

/// D3 once `PersonDetailCubit` has loaded — assembles the header,
/// biography, "Known for", and filmography sections.
///
/// [detail] arrives already loaded — same "only the screen's own
/// top-level `BlocBuilder` reads Cubit state at all" discipline D1/D2's
/// own content widgets follow (CLAUDE.md rule 9).
class PersonDetailContent extends StatelessWidget {
  const PersonDetailContent({
    super.key,
    required this.detail,
    required this.scrollController,
    required this.headerKey,
  });

  final PersonDetail detail;
  final ScrollController scrollController;

  /// Lets the assembling screen measure the header's real height (it
  /// isn't a fixed fraction of the screen the way D1/D2's full-bleed
  /// poster header is) to decide when the compact bar should appear.
  final GlobalKey headerKey;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: EdgeInsets.zero,
      children: [
        KeyedSubtree(
          key: headerKey,
          child: PersonDetailHeader(
            person: detail.person,
            ageLabel: personAgeLabel(detail, context.l10n),
            placeOfBirth: detail.placeOfBirth,
          ),
        ),
        PersonBiographySection(
          biography: detail.biography,
          isEnglishFallback: detail.biographyIsEnglishFallback,
        ),
        PersonKnownForSection(
          items: detail.credits.knownForItems(),
          onItemTap: (item) => context.pushMediaDetail(item.key),
        ),
        PersonFilmographyLinkCard(
          titleCount: detail.credits.length,
          onTap: () => context.push(
            AppRoutes.personFilmography,
            extra: PersonFilmographyRouteArgs(detail: detail),
          ),
        ),
        const TmdbFooter(),
      ],
    );
  }
}
