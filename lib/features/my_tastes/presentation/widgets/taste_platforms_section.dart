import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/skeleton_block.dart';
import '../../../discover/presentation/widgets/discover_content_error.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import '../cubit/taste_platforms_cubit.dart';
import 'taste_platform_tile.dart';

/// C5's "My platforms": the streaming services of the user's region as a grid
/// of logos to pick (`docs/SCREENS.md` C5). Skeleton while they load, a retry
/// row on error, nothing when the region lists none. It owns its
/// [TastePlatformsCubit] (the list is only its business) and selects only the
/// picked ids from [MyTastesCubit] (rule 9).
class TastePlatformsSection extends StatelessWidget {
  const TastePlatformsSection({super.key});

  static const int _columns = 3;
  static const double _tileAspect = 2;
  static const int _skeletons = 6;

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
                switch (state) {
                  TastePlatformsLoading() => _grid([
                    for (var i = 0; i < _skeletons; i++)
                      SkeletonBlock(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                      ),
                  ]),
                  TastePlatformsError() => DiscoverContentError(
                    onRetry: context.read<TastePlatformsCubit>().load,
                  ),
                  TastePlatformsLoaded(:final services) => _Picker(
                    services: services,
                  ),
                },
              ],
            ),
          );
        },
      ),
    );
  }

  static Widget _grid(List<Widget> children) => GridView.count(
    crossAxisCount: _columns,
    childAspectRatio: _tileAspect,
    mainAxisSpacing: AppSpacing.sm,
    crossAxisSpacing: AppSpacing.sm,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    children: children,
  );
}

class _Picker extends StatelessWidget {
  const _Picker({required this.services});

  final List<StreamingService> services;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MyTastesCubit>();
    return BlocSelector<MyTastesCubit, MyTastesState, Set<int>>(
      selector: (state) => state.platformIds,
      builder: (context, selected) => TastePlatformsSection._grid([
        for (final service in services)
          TastePlatformTile(
            key: ValueKey(service.id),
            service: service,
            selected: selected.contains(service.id),
            onTap: () => cubit.togglePlatform(service.id),
          ),
      ]),
    );
  }
}
