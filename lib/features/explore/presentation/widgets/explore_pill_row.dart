import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import 'explore_pill.dart';

/// A horizontally scrolling row of [ExplorePill]s that starts on the page
/// margin and scrolls edge to edge, like the carousels around it.
class ExplorePillRow extends StatelessWidget {
  const ExplorePillRow({super.key, required this.pills});

  final List<ExplorePill> pills;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ExplorePill.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
        ),
        itemCount: pills.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => pills[index],
      ),
    );
  }
}
