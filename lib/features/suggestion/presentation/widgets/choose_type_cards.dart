import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/surprise_cubit.dart';
import '../cubit/surprise_state.dart';

/// E1's own "two large cards 'A movie' / 'A TV show', each with an
/// icon". Its own narrow `BlocSelector`: only cares whether a search is
/// already running (to block a double-tap while `chooseType` resolves
/// which of the 3 cases applies), nothing else about `SurpriseState`.
class ChooseTypeCards extends StatelessWidget {
  const ChooseTypeCards({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SurpriseCubit, SurpriseState, bool>(
      selector: (state) => state is Searching,
      builder: (context, isSearching) {
        final cubit = context.read<SurpriseCubit>();
        return AbsorbPointer(
          absorbing: isSearching,
          child: Opacity(
            opacity: isSearching ? 0.5 : 1,
            child: Column(
              children: [
                _TypeCard(
                  icon: AppIcons.movie,
                  label: 'A movie',
                  onTap: () => cubit.chooseType(MediaType.movie),
                ),
                const SizedBox(height: AppSpacing.md),
                _TypeCard(
                  icon: AppIcons.tvShow,
                  label: 'A TV show',
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

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  // Same "closest existing token, not a one-off literal" call
  // `MatchHubCard`'s own icon already makes — DESIGN_SYSTEM.md section
  // 4's scale tops out at 24.
  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          children: [
            Icon(icon, size: _iconSize, color: AppColors.ink),
            const SizedBox(height: AppSpacing.md),
            Text(label, style: AppTextStyles.h3),
          ],
        ),
      ),
    );
  }
}
