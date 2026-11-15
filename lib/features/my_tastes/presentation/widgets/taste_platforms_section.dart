import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_chip.dart';
import '../../../../shared/widgets/app_section.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import '../cubit/taste_platforms_cubit.dart';
import 'taste_platform_tile.dart';
import 'taste_platforms_sheet.dart';

/// C5's "My platforms": the services the user picked, as logos on neutral
/// cards, and an "+ Add" chip that opens a searchable multi-select of every
/// service of their region (`docs/SCREENS.md` C5). Tapping a logo takes it
/// off. It owns its [TastePlatformsCubit] (the region's list is only its
/// business) and selects only the picked ids from [MyTastesCubit] (rule 9).
/// Hidden when the region lists no service at all.
class TastePlatformsSection extends StatelessWidget {
  const TastePlatformsSection({super.key});

  static const int _columns = 3;
  static const double _tileAspect = 2;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => TastePlatformsCubit(getIt<MediaRepository>()),
      child: BlocBuilder<TastePlatformsCubit, TastePlatformsState>(
        builder: (context, state) {
          if (state is TastePlatformsLoaded && state.services.isEmpty) {
            return const SizedBox.shrink();
          }
          return AppSection(
            title: l10n.myTastesPlatformsTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myTastesPlatformsHint,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state is TastePlatformsLoaded) _Picked(state.services),
                AppChip(
                  label: l10n.myTastesPlatformsAdd,
                  icon: AppIcons.add,
                  onTap: () => showTastePlatformsSheet(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The picked services of the region as a grid of logos, with the gap below
/// it only when there is one.
class _Picked extends StatelessWidget {
  const _Picked(this.services);

  final List<StreamingService> services;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTastesCubit>();
    return BlocSelector<MyTastesCubit, MyTastesState, Set<int>>(
      selector: (state) => state.platformIds,
      builder: (context, selected) {
        final mine = [
          for (final s in services)
            if (selected.contains(s.id)) s,
        ];
        if (mine.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: GridView.count(
            crossAxisCount: TastePlatformsSection._columns,
            childAspectRatio: TastePlatformsSection._tileAspect,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final service in mine)
                TastePlatformTile(
                  key: ValueKey(service.id),
                  service: service,
                  onRemove: () => cubit.togglePlatform(service.id),
                ),
            ],
          ),
        );
      },
    );
  }
}
