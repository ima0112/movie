import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';
import 'choose_type_card.dart';

/// E1's two type cards. Its own narrow `BlocSelector`: only cares whether a
/// search is already running (to block a double-tap while `chooseType`
/// resolves which of the 3 cases applies), nothing else about
/// `SurpriseState`.
class ChooseTypeCards extends StatelessWidget {
  const ChooseTypeCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<SurpriseCubit, SurpriseState, bool>(
      selector: (state) => state is Searching,
      builder: (context, isSearching) {
        final cubit = context.read<SurpriseCubit>();
        return AbsorbPointer(
          absorbing: isSearching,
          child: Opacity(
            opacity: isSearching ? 0.5 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ChooseTypeCard(
                  icon: AppIcons.movie,
                  label: l10n.chooseTypeMovieLabel,
                  subtitle: l10n.chooseTypeMovieSubtitle,
                  onTap: () => cubit.chooseType(MediaType.movie),
                ),
                const SizedBox(height: AppSpacing.md),
                ChooseTypeCard(
                  icon: AppIcons.tvShow,
                  label: l10n.chooseTypeTvShowLabel,
                  subtitle: l10n.chooseTypeTvShowSubtitle,
                  onTap: () => cubit.chooseType(MediaType.tvShow),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
