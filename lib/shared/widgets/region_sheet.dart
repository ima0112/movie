import 'package:flutter/material.dart';

import '../../core/domain/entities/country.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'checkable_option_row.dart';

/// H6 (Region) — `docs/SCREENS.md` H6: "Searchable list of countries."
/// [selectedRegionCode] is `AppSettings.regionCode`; [onSelected] is
/// called with the new code and this sheet pops itself.
class RegionSheet extends StatefulWidget {
  const RegionSheet({
    super.key,
    required this.selectedRegionCode,
    required this.onSelected,
  });

  final String selectedRegionCode;
  final ValueChanged<String> onSelected;

  @override
  State<RegionSheet> createState() => _RegionSheetState();
}

class _RegionSheetState extends State<RegionSheet> {
  String _query = '';

  // Below this much height (small device, keyboard open, large text) the
  // subtitle steps aside so the matches stay visible.
  static const double _compactHeight = 480;

  @override
  Widget build(BuildContext context) {
    final results = countryCatalog
        .where(
          (country) =>
              _query.isEmpty ||
              country.name.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < _compactHeight;
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.l10n.regionSheetTitle, style: AppTextStyles.h1),
                  if (!compact) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      context.l10n.regionSheetSubtitle,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  _SearchField(
                    query: _query,
                    onChanged: (query) => setState(() => _query = query),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: results.isEmpty
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
                              for (final (i, country) in results.indexed) ...[
                                if (i > 0) const Divider(height: 1),
                                CheckableOptionRow(
                                  label: country.name,
                                  isSelected:
                                      country.code == widget.selectedRegionCode,
                                  onTap: () {
                                    widget.onSelected(country.code);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ],
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
        hintText: context.l10n.regionSheetSearchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        filled: true,
        // The sheet itself is surfaceRaised, so the field sits one level
        // down on `surface` with a hairline border (the "Región" design).
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
