import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/discover_cubit.dart';
import 'discover_hero.dart';
import 'discover_section_carousel.dart';

/// The hero + every section, once `DiscoverCubit` has something loaded
/// for [segment]. Only lays things out — [DiscoverHero] and
/// [DiscoverSectionCarousel] each independently select their own slice of
/// state, so this widget itself carries no Bloc subscription.
class DiscoverContentLoaded extends StatelessWidget {
  const DiscoverContentLoaded({super.key, required this.segment});

  final MediaSegment segment;

  @override
  Widget build(BuildContext context) {
    final sections = DiscoverCubit.sectionsBySegment[segment]!;
    return RefreshIndicator(
      onRefresh: () => context.read<DiscoverCubit>().loadDiscover(segment),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        children: [
          DiscoverHero(segment: segment),
          const SizedBox(height: AppSpacing.xxxl),
          for (final section in sections) ...[
            DiscoverSectionCarousel(segment: segment, section: section),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ],
      ),
    );
  }
}
