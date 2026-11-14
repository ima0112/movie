import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/app_section.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_year_slider.dart';

/// C5's "How far back" / eras. Selects only the years (rule 9).
class TasteErasSection extends StatelessWidget {
  const TasteErasSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MyTastesCubit, MyTastesState, (int, int?)>(
      selector: (state) => (state.yearFrom, state.yearTo),
      builder: (context, years) {
        final latest = DateTime.now().year;
        return AppSection(
          child: TasteYearSlider(
            yearFrom: years.$1,
            onChanged: (year) => context.read<MyTastesCubit>().setYearRange(
              year,
              years.$2 ?? latest,
              latestYear: latest,
            ),
          ),
        );
      },
    );
  }
}
