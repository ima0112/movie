import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../l10n/app_localizations.dart';
import '../overline_label.dart';
import '../app_segmented_control.dart';
import 'full_cast_person_tile.dart';

/// Which list [FullCastScreen] is showing.
enum CastCrewTab { cast, crew }

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
/// across cast *and* crew whichever tab is selected (results grouped under a
/// Cast and a Crew heading, the selected tab's group first; the tabs stay
/// visible and show the match counts); same convention `ExploreSearchField`'s own query uses.
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

typedef _Entry = (Person person, String role);

class _FullCastScreenState extends State<FullCastScreen> {
  String _query = '';
  CastCrewTab _tab = CastCrewTab.cast;

  static const int _columns = 3;

  bool _matches(String name) =>
      _query.isEmpty || name.toLowerCase().contains(_query.toLowerCase());

  List<_Entry> get _cast => [
    for (final m in widget.cast) (m.person, m.character),
  ];
  List<_Entry> get _crew => [for (final m in widget.crew) (m.person, m.job)];

  List<_Entry> _filtered(List<_Entry> entries) => [
    for (final e in entries)
      if (_matches(e.$1.name)) e,
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searching = _query.isNotEmpty;

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
              AppSegmentedControl<CastCrewTab>(
                padding: EdgeInsets.zero,
                segments: [
                  AppSegment(
                    value: CastCrewTab.cast,
                    // While searching, the labels carry each list's match
                    // count.
                    label: searching
                        ? '${l10n.fullCastCastLabel} · ${_filtered(_cast).length}'
                        : l10n.fullCastCastLabel,
                  ),
                  AppSegment(
                    value: CastCrewTab.crew,
                    label: searching
                        ? '${l10n.fullCastCrewLabel} · ${_filtered(_crew).length}'
                        : l10n.fullCastCrewLabel,
                  ),
                ],
                selected: _tab,
                onSelected: (tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: AppSpacing.md),
              _SearchField(
                query: _query,
                onChanged: (query) => setState(() => _query = query),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: searching ? _results(l10n) : _tabList()),
            ],
          ),
        ),
      ),
    );
  }

  /// The selected tab's own list. Each tab has its own `PageStorageKey`, so
  /// it keeps its own scroll position: scrolling Cast never moves Crew.
  Widget _tabList() {
    final entries = _tab == CastCrewTab.cast ? _cast : _crew;
    return _PeopleList(
      key: PageStorageKey<CastCrewTab>(_tab),
      rows: _rows(entries),
      onPersonTap: widget.onPersonTap,
    );
  }

  /// Search results from both lists, each under its own heading.
  Widget _results(AppLocalizations l10n) {
    final cast = _filtered(_cast);
    final crew = _filtered(_crew);
    if (cast.isEmpty && crew.isEmpty) {
      return Center(
        child: Text(
          l10n.commonNoMatches,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
      );
    }
    final castGroup = [
      if (cast.isNotEmpty) ...[
        _Heading(l10n.fullCastCastLabel),
        ..._rows(cast),
      ],
    ];
    final crewGroup = [
      if (crew.isNotEmpty) ...[
        _Heading(l10n.fullCastCrewLabel),
        ..._rows(crew),
      ],
    ];
    return _PeopleList(
      key: const PageStorageKey<String>('search'),
      // The selected tab's matches come first.
      rows: _tab == CastCrewTab.cast
          ? [...castGroup, ...crewGroup]
          : [...crewGroup, ...castGroup],
      onPersonTap: widget.onPersonTap,
    );
  }

  List<_ListItem> _rows(List<_Entry> entries) => [
    for (var i = 0; i < entries.length; i += _columns)
      _PeopleRow(entries.skip(i).take(_columns).toList(), _columns),
  ];
}

sealed class _ListItem {
  const _ListItem();
}

final class _Heading extends _ListItem {
  const _Heading(this.label);

  final String label;
}

final class _PeopleRow extends _ListItem {
  const _PeopleRow(this.entries, this.columns);

  final List<_Entry> entries;
  final int columns;
}

/// A lazily built list of rows of portraits (a 735-person crew isn't built
/// all at once). Rows size to their content, so large text never overflows.
class _PeopleList extends StatelessWidget {
  const _PeopleList({super.key, required this.rows, required this.onPersonTap});

  final List<_ListItem> rows;
  final void Function(Person person)? onPersonTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
      itemCount: rows.length,
      itemBuilder: (context, index) => switch (rows[index]) {
        _Heading(:final label) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: OverlineLabel(label),
        ),
        _PeopleRow(:final entries, :final columns) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < columns; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: i < entries.length
                      ? FullCastPersonTile(
                          person: entries[i].$1,
                          role: entries[i].$2,
                          onTap: () => onPersonTap?.call(entries[i].$1),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      },
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
