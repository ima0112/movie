import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/release_range_picker.dart';
import '../../../../shared/year_buckets.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';

/// C5's "Eras" (`docs/SCREENS.md` C5): the [ReleaseRangePicker] — FROM / TO
/// cards, a histogram, a two-handle slider and the All · 2020s · 2010s ·
/// Earlier presets — 1950 to today. The histogram counts the titles in the
/// user's own library by release year. A range that ends today is stored as
/// "no upper bound". Selects only the years from [MyTastesCubit] (rule 9).
class TasteErasSection extends StatefulWidget {
  const TasteErasSection({super.key, this.library});

  /// Where the histogram's years come from; the app's library by default.
  final UserLibraryRepository? library;

  static const int minYear = 1950;

  @override
  State<TasteErasSection> createState() => _TasteErasSectionState();
}

class _TasteErasSectionState extends State<TasteErasSection> {
  final int _latest = DateTime.now().year;
  late final Stream<List<int>> _buckets =
      (widget.library ?? getIt<UserLibraryRepository>()).watch().map(
        (entries) => yearBuckets(
          entries.map((e) => e.year),
          minYear: TasteErasSection.minYear,
          maxYear: _latest,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSection(
      title: l10n.myTastesErasTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.myTastesErasHint,
            style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocSelector<MyTastesCubit, MyTastesState, (int, int?)>(
            selector: (state) => (state.yearFrom, state.yearTo),
            builder: (context, years) => StreamBuilder<List<int>>(
              stream: _buckets,
              initialData: yearBuckets(
                const [],
                minYear: TasteErasSection.minYear,
                maxYear: _latest,
              ),
              builder: (context, snapshot) => ReleaseRangePicker(
                from: years.$1,
                to: years.$2 ?? _latest,
                minYear: TasteErasSection.minYear,
                maxYear: _latest,
                counts: snapshot.data!,
                onChanged: (from, to) => context
                    .read<MyTastesCubit>()
                    .setYearRange(from, to, latestYear: _latest),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
