import 'package:flutter/material.dart';

import '../../../core/domain/entities/person.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';
import '../profile_image.dart';

/// H3 (Full cast) — `docs/SCREENS.md` H3: "Cast and crew list with an
/// internal search box." Opened from D1/D2's own "See full cast" link
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

  bool _matches(String name) =>
      _query.isEmpty || name.toLowerCase().contains(_query.toLowerCase());

  @override
  Widget build(BuildContext context) {
    final cast = widget.cast.where((c) => _matches(c.person.name)).toList();
    final crew = widget.crew.where((c) => _matches(c.person.name)).toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.fullCastSheetTitle, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              _SearchField(
                query: _query,
                onChanged: (query) => setState(() => _query = query),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: cast.isEmpty && crew.isEmpty
                    ? Center(
                        child: Text(
                          context.l10n.commonNoMatches,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      )
                    : ListView(
                        children: [
                          if (cast.isNotEmpty) ...[
                            _SectionLabel(context.l10n.fullCastSheetCastLabel),
                            for (final member in cast)
                              _PersonRow(
                                person: member.person,
                                role: member.character,
                                onTap: () =>
                                    widget.onPersonTap?.call(member.person),
                              ),
                          ],
                          if (crew.isNotEmpty) ...[
                            _SectionLabel(context.l10n.fullCastSheetCrewLabel),
                            for (final member in crew)
                              _PersonRow(
                                person: member.person,
                                role: member.job,
                                onTap: () =>
                                    widget.onPersonTap?.call(member.person),
                              ),
                          ],
                        ],
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
        hintText: context.l10n.fullCastSheetSearchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        filled: true,
        fillColor: AppColors.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          borderSide: BorderSide.none,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        label,
        style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({required this.person, this.role, required this.onTap});

  final Person person;
  final String? role;
  final VoidCallback onTap;

  static const double _avatarSize = 48;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: _avatarSize,
                height: _avatarSize,
                child: ProfileImage(
                  profilePath: person.profilePath,
                  name: person.name,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    person.name,
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (role != null && role!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      role!,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
