import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';

/// Swipe a row **left** to delete it — the only direction, the one of the
/// action. A coral panel follows the finger with a trash icon and "Delete";
/// past the threshold it reads "Release to delete", and letting go collapses
/// the row and calls [onDelete] (which is also what the caller undoes).
///
/// The row hides itself the moment it is dismissed (a `Dismissible` must leave
/// the tree at once); the caller's list then drops it for real.
class SwipeToDelete extends StatefulWidget {
  const SwipeToDelete({super.key, required this.onDelete, required this.child});

  final VoidCallback onDelete;
  final Widget child;

  @override
  State<SwipeToDelete> createState() => _SwipeToDeleteState();
}

class _SwipeToDeleteState extends State<SwipeToDelete> {
  final ValueNotifier<bool> _reached = ValueNotifier(false);
  bool _gone = false;

  @override
  void dispose() {
    _reached.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_gone) return const SizedBox.shrink();
    final panel = _Panel(reached: _reached);
    return Dismissible(
      key: const ValueKey('swipe-to-delete'),
      direction: DismissDirection.endToStart,
      background: panel,
      secondaryBackground: panel,
      onUpdate: (details) => _reached.value = details.reached,
      onDismissed: (_) {
        setState(() => _gone = true);
        widget.onDelete();
      },
      child: widget.child,
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.reached});

  final ValueListenable<bool> reached;

  static const double _iconSize = 24;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ColoredBox(
      color: AppColors.danger,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: ValueListenableBuilder<bool>(
            valueListenable: reached,
            builder: (context, reached, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  AppIcons.delete,
                  size: _iconSize,
                  color: AppColors.onDanger,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reached ? l10n.swipeReleaseToDelete : l10n.swipeDelete,
                  style: AppTextStyles.captionStrong.copyWith(
                    color: AppColors.onDanger,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
