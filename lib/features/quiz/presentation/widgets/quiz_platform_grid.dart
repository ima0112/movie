import 'package:flutter/material.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/skeleton_block.dart';
import 'quiz_platform_tile.dart';

/// The platforms step's 3-column grid: a [QuizPlatformTile] per service, or
/// twelve skeleton tiles while the list loads.
class QuizPlatformGrid extends StatelessWidget {
  const QuizPlatformGrid({
    super.key,
    required List<StreamingService> this.services,
    required Set<int> this.selected,
    required ValueChanged<int> this.onToggle,
  });

  const QuizPlatformGrid.loading({super.key})
    : services = null,
      selected = null,
      onToggle = null;

  final List<StreamingService>? services;
  final Set<int>? selected;
  final ValueChanged<int>? onToggle;

  static const int _columns = 3;
  static const int _skeletons = 12;

  @override
  Widget build(BuildContext context) {
    final list = services;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _columns,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: QuizPlatformTile.heightFor(context),
      ),
      itemCount: list?.length ?? _skeletons,
      itemBuilder: (context, index) {
        if (list == null) {
          return SkeletonBlock(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          );
        }
        final service = list[index];
        return QuizPlatformTile(
          service: service,
          selected: selected!.contains(service.id),
          onTap: () => onToggle!(service.id),
        );
      },
    );
  }
}
