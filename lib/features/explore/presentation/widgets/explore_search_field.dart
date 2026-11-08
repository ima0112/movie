import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';

/// B2's search field — `docs/SCREENS.md` B2: "real search field
/// ('Movies, TV shows, people') with a filter icon on the right (amber
/// when filters are active → H8)... State 2 — Typing: the field gains
/// '×' and 'Cancel'".
///
/// [query] drives the field's text from the outside (`ExploreState`'s
/// own live query — a "Recent" chip tap, or [onClear], changes it
/// externally, not just typing); this widget owns the actual
/// `TextEditingController` and keeps it in sync via [didUpdateWidget]
/// rather than rebuilding a fresh controller (and losing the cursor
/// position) on every keystroke.
class ExploreSearchField extends StatefulWidget {
  const ExploreSearchField({
    super.key,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.hasActiveFilters,
    required this.onFilterTap,
  });

  final String query;
  final ValueChanged<String> onChanged;

  /// The "×" inside the field, or "Cancel" beside it.
  final VoidCallback onClear;

  /// H8: the filter icon turns amber when filters are active.
  final bool hasActiveFilters;

  /// → H8. Not shown while typing — B2's own "Filters don't apply to
  /// text search" note means there's nothing useful to tap into here
  /// once a search is running; "Cancel" takes that slot instead.
  final VoidCallback onFilterTap;

  @override
  State<ExploreSearchField> createState() => _ExploreSearchFieldState();
}

class _ExploreSearchFieldState extends State<ExploreSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(covariant ExploreSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTyping = widget.query.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: context.l10n.exploreSearchHint,
              hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
              filled: true,
              fillColor: AppColors.surfaceRaised,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                borderSide: BorderSide.none,
              ),
              suffixIcon: isTyping
                  ? IconButton(
                      icon: const Icon(
                        AppIcons.close,
                        color: AppColors.inkMuted,
                      ),
                      onPressed: widget.onClear,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        if (isTyping)
          TextLinkButton(
            label: context.l10n.commonCancel,
            onTap: widget.onClear,
            fullWidth: false,
          )
        else
          IconButton(
            icon: Icon(
              AppIcons.filter,
              color: widget.hasActiveFilters ? AppColors.accent : AppColors.ink,
            ),
            onPressed: widget.onFilterTap,
          ),
      ],
    );
  }
}
