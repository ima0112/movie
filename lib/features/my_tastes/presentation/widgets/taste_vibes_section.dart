import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../match_engine/domain/vibe.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import 'taste_vibe_grid.dart';

/// C5's "Vibes you like". Selects only the liked vibes (rule 9).
class TasteVibesSection extends StatelessWidget {
  const TasteVibesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final vibes = context.read<MyTastesCubit>().state.availableVibes;
    return BlocSelector<MyTastesCubit, MyTastesState, Set<String>>(
      selector: (state) => state.likedVibes,
      builder: (context, selected) => AppSection(
        child: TasteVibeGrid(
          vibes: List<Vibe>.of(vibes),
          selected: selected,
          onToggle: context.read<MyTastesCubit>().toggleVibe,
        ),
      ),
    );
  }
}
