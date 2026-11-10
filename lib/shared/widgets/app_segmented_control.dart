import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// One option of an [AppSegmentedControl].
class AppSegment<T> {
  const AppSegment({
    required this.value,
    required this.label,
    this.labelStream,
  });

  final T value;
  final String label;

  /// Optional live label (a count that changes: "Favorites · 3"). Shown in
  /// place of [label] once it emits; [label] is what shows until then and
  /// what screen readers use as the base.
  ///
  /// The stream instance must stay the same across rebuilds (create it once,
  /// e.g. in `initState`), or the segment re-subscribes every time.
  final Stream<String>? labelStream;
}

/// The app's only tabs / segmented control: a contained pill (a
/// `surfaceRaised` track, the selected option a white `ink` pill with dark
/// text, the rest muted) — `docs/DESIGN_SYSTEM.md` §5. Discover, Explore,
/// My List, Stats, Filmography and Cast/Crew all use it, so a new place that
/// needs tabs uses this and nothing else.
///
/// Purely presentational and generic: it knows only [segments], the
/// [selected] value and [onSelected]. Its height is [pillHeight] at normal
/// text and grows with the text scale; each label stays on one line.
class AppSegmentedControl<T> extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenMargin,
    ),
  });

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onSelected;

  /// Outside the track; pass [EdgeInsets.zero] when the parent already sits
  /// on the screen margin.
  final EdgeInsets padding;

  static const Duration _crossFade = Duration(milliseconds: 200);
  static const double pillHeight = 40;
  static const double pillInset = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        constraints: const BoxConstraints(minHeight: pillHeight),
        padding: const EdgeInsets.all(pillInset),
        decoration: BoxDecoration(
          color: AppColors.surfaceRaised,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final segment in segments)
                Expanded(
                  child: _Option<T>(
                    segment: segment,
                    isSelected: segment.value == selected,
                    onTap: () => onSelected(segment.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Option<T> extends StatelessWidget {
  const _Option({
    required this.segment,
    required this.isSelected,
    required this.onTap,
  });

  final AppSegment<T> segment;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      excludeSemantics: true,
      label: segment.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppSegmentedControl._crossFade,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.ink : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: AnimatedDefaultTextStyle(
            duration: AppSegmentedControl._crossFade,
            style: AppTextStyles.bodySmToggle(isSelected).copyWith(
              color: isSelected ? AppColors.surface : AppColors.inkMuted,
            ),
            child: segment.labelStream == null
                ? _label(segment.label)
                : StreamBuilder<String>(
                    stream: segment.labelStream,
                    initialData: segment.label,
                    builder: (context, snapshot) =>
                        _label(snapshot.data ?? segment.label),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    textAlign: TextAlign.center,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
