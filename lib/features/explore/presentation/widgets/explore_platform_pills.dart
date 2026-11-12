import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_section.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../discover/presentation/widgets/discover_content_error.dart';
import '../cubit/explore_browse_cubit.dart';
import '../cubit/explore_browse_state.dart';
import 'explore_pill.dart';
import 'explore_pill_row.dart';

/// B2's "PLATFORM" row: an "All" pill and the streaming services of the
/// user's region, each with its logo, single select. Skeleton while loading,
/// a retry row on error, and nothing at all when the region has no services.
class ExplorePlatformPills extends StatelessWidget {
  const ExplorePlatformPills({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreBrowseCubit, ExploreBrowseState>(
      buildWhen: (a, b) => a.services != b.services || a.service != b.service,
      builder: (context, state) {
        final l10n = context.l10n;
        final cubit = context.read<ExploreBrowseCubit>();
        return switch (state.services) {
          ExploreServicesLoading() => AppSection.overline(
            title: l10n.explorePlatformLabel,
            inset: false,
            child: const _PillsSkeleton(),
          ),
          ExploreServicesError() => AppSection.overline(
            title: l10n.explorePlatformLabel,
            child: DiscoverContentError(onRetry: cubit.retryServices),
          ),
          ExploreServicesLoaded(:final services) when services.isEmpty =>
            const SizedBox.shrink(),
          ExploreServicesLoaded(:final services) => AppSection.overline(
            title: l10n.explorePlatformLabel,
            inset: false,
            child: ExplorePillRow(
              pills: [
                ExplorePill(
                  label: l10n.explorePlatformAll,
                  selected: state.service == null,
                  onTap: () => cubit.selectService(null),
                ),
                for (final service in services)
                  ExplorePill(
                    label: service.name,
                    selected: state.service == service,
                    onTap: () => cubit.selectService(service),
                    leading: _Logo(service: service),
                  ),
              ],
            ),
          ),
        };
      },
    );
  }
}

class _PillsSkeleton extends StatelessWidget {
  const _PillsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ExplorePill.height,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
        ),
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            const SkeletonBlock(width: 96, height: ExplorePill.height),
          ],
        ],
      ),
    );
  }
}

/// A 24 px rounded logo, or the name's first letter on a flat tile when TMDB
/// has no logo (or it fails to load).
class _Logo extends StatelessWidget {
  const _Logo({required this.service});

  final StreamingService service;

  static const double _size = 24;

  @override
  Widget build(BuildContext context) {
    final url = service.logoUrl;
    final letter = Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised2,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        service.name.isEmpty ? '' : service.name.characters.first.toUpperCase(),
        style: AppTextStyles.captionStrong,
      ),
    );
    if (url == null) return letter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Image.network(
        url,
        width: _size,
        height: _size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => letter,
      ),
    );
  }
}
