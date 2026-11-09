import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'cast_crew_tabs.dart';
import 'full_cast_person_tile.dart';

/// H3 (Full cast) — `docs/SCREENS.md` H3: a "Cast | Crew" pill, an internal
/// search box, and a 3-column grid of portraits with name and
/// character/job (the "Reparto completo" design). Opened from D1/D2's own "See full cast" link
/// (`MediaCastRow.onSeeFullCastTap`) — shared between both the same way
/// `MediaCastRow` itself is.
///
/// The search box filters by person name only (TMDB's own cast/crew
/// entries don't carry anything else worth matching here) — case-
/// insensitive substring, same convention `ExploreSearchField`'s own
/// query already uses.
class FullCastSheet extends StatefulWidget {
  const FullCastSheet({
    super.key,
    required this.cast,
    required this.crew,
    this.onPersonTap,
  });

  final List<CastMember> cast;
  final List<CrewMember> crew;
  final void Function(Person person)? onPersonTap;

  @override
  State<FullCastSheet> createState() => _FullCastSheetState();
}

class _FullCastSheetState extends State<FullCastSheet> {
  String _query = '';
  CastCrewTab _tab = CastCrewTab.cast;

  static const int _columns = 3;
  static const double _compactHeight = 480;

  bool _matches(String name) =>
      _query.isEmpty || name.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final people = switch (_tab) {
      CastCrewTab.cast => [
        for (final m in widget.cast)
          if (_matches(m.person.name)) (m.person, m.character),
      ],
      CastCrewTab.crew => [
        for (final m in widget.crew)
          if (_matches(m.person.name)) (m.person, m.job),
      ],
    };

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Small device / keyboard open / large text: a smaller title and
            // tighter padding keep the grid visible.
            final compact = constraints.maxHeight < _compactHeight;
            return Padding(
              padding: EdgeInsets.all(compact ? AppSpacing.xl : AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.fullCastSheetTitle,
                    style: compact ? AppTextStyles.h2 : AppTextStyles.h1,
                  ),
                  SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
                  CastCrewTabs(
                    selected: _tab,
                    castLabel: l10n.fullCastSheetCastLabel,
                    crewLabel: l10n.fullCastSheetCrewLabel,
                    onSelected: (tab) => setState(() => _tab = tab),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SearchField(
                    query: _query,
                    onChanged: (query) => setState(() => _query = query),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: people.isEmpty
                        ? Center(
                            child: Text(
                              l10n.commonNoMatches,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              const gap = AppSpacing.md;
                              final tileWidth =
                                  (constraints.maxWidth -
                                      gap * (_columns - 1)) /
                                  _columns;
                              return SingleChildScrollView(
                                child: Wrap(
                                  spacing: gap,
                                  runSpacing: AppSpacing.lg,
                                  children: [
                                    for (final (person, role) in people)
                                      SizedBox(
                                        width: tileWidth,
                                        child: FullCastPersonTile(
                                          person: person,
                                          role: role,
                                          onTap: () =>
                                              widget.onPersonTap?.call(person),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: context.l10n.fullCastSheetSearchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        filled: true,
        // The sheet itself is surfaceRaised: the field sits one level down
        // on `surface` with a hairline border.
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: const BorderSide(color: AppColors.lineStrong),
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
                icon: const Icon(AppIcons.close, color: AppColors.inkMuted),
                onPressed: () => onChanged(''),
              ),
      ),
    );
  }
}
