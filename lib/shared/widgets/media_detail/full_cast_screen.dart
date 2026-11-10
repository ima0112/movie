import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import 'cast_crew_tabs.dart';
import 'full_cast_person_tile.dart';

/// D1b (Full cast & crew) — `docs/SCREENS.md` D1b: a pushed page (it used to
/// be the H3 bottom sheet) with the title as its own heading, a "Cast | Crew"
/// pill, an internal search box and a 3-column grid of portraits with name
/// and character/job (the "Reparto completo" design). Opened from D1/D2's
/// Cast "See all" — shared between both the same way `MediaCastRow` is.
///
/// Static: it renders the cast/crew D1/D2 already loaded, so there is no
/// Cubit and no network call. The tab and the query are local widget state
/// (CLAUDE.md rule 10) — they mean nothing outside this page.
///
/// The search box filters by person name only, case-insensitive substring,
/// same convention `ExploreSearchField`'s own query uses.
class FullCastScreen extends StatefulWidget {
  const FullCastScreen({
    super.key,
    required this.title,
    required this.cast,
    required this.crew,
    this.onPersonTap,
  });

  /// The movie's / show's title, shown centered in the app bar.
  final String title;
  final List<CastMember> cast;
  final List<CrewMember> crew;
  final void Function(Person person)? onPersonTap;

  @override
  State<FullCastScreen> createState() => _FullCastScreenState();
}

class _FullCastScreenState extends State<FullCastScreen> {
  String _query = '';
  CastCrewTab _tab = CastCrewTab.cast;

  static const int _columns = 3;

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

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: AppTextStyles.h3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CastCrewTabs(
                selected: _tab,
                castLabel: l10n.fullCastCastLabel,
                crewLabel: l10n.fullCastCrewLabel,
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
                              (constraints.maxWidth - gap * (_columns - 1)) /
                              _columns;
                          return SingleChildScrollView(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.sectionGap,
                            ),
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
        hintText: context.l10n.fullCastSearchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        filled: true,
        // On the page background the field is one level up, like the tabs'
        // track, with a hairline border.
        fillColor: AppColors.surfaceRaised,
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
