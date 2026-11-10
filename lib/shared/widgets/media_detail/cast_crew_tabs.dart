import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../media_segmented_control.dart';

/// Which list [FullCastScreen] is showing.
enum CastCrewTab { cast, crew }

/// The sheet's "Cast | Crew" contained pill — same shape and size as
/// `MediaSegmentedControl`'s pill (shared constants), two fixed options.
class CastCrewTabs extends StatelessWidget {
  const CastCrewTabs({
    super.key,
    required this.selected,
    required this.castLabel,
    required this.crewLabel,
    required this.onSelected,
  });

  final CastCrewTab selected;
  final String castLabel;
  final String crewLabel;
  final ValueChanged<CastCrewTab> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaSegmentedControl.pillHeight,
      padding: const EdgeInsets.all(MediaSegmentedControl.pillInset),
      decoration: BoxDecoration(
        color: AppColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: castLabel,
              isSelected: selected == CastCrewTab.cast,
              onTap: () => onSelected(CastCrewTab.cast),
            ),
          ),
          Expanded(
            child: _Tab(
              label: crewLabel,
              isSelected: selected == CastCrewTab.crew,
              onTap: () => onSelected(CastCrewTab.crew),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodySmToggle(isSelected).copyWith(
              color: isSelected ? AppColors.surface : AppColors.inkMuted,
            ),
          ),
        ),
      ),
    );
  }
}
