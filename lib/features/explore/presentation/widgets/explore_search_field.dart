import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// B2's search field — `docs/SCREENS.md` B2 (with a primary-color ring while
/// focused): a real search field ('Movies,
/// TV shows, people') across the **full content width**; once there is text
/// (or while it is focused) it gains a "×" inside it that clears the search
/// (or, empty, dismisses it); at rest — empty and not focused — it shows the
/// filter icon instead (→ H8) (there is no separate
/// filter icon or Cancel any more — genre and platform are pills below).
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
    required this.focusNode,
    required this.onFilterTap,
    this.focusToken,
  });

  final String query;
  final ValueChanged<String> onChanged;

  /// The "×" inside the field.
  final VoidCallback onClear;

  /// The filter icon at the end of the field while it is empty and not
  /// focused (→ H8).
  final VoidCallback onFilterTap;

  /// Owned by the screen, which also reads it to know whether the field is
  /// focused (B2 shows the recent searches then).
  final FocusNode focusNode;

  /// Focuses the field (cursor in, keyboard up) whenever it changes to a new
  /// non-null value, including on first build — B1's search bar uses this to
  /// be a shortcut to this field.
  final String? focusToken;

  @override
  State<ExploreSearchField> createState() => _ExploreSearchFieldState();
}

class _ExploreSearchFieldState extends State<ExploreSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
    if (widget.focusToken != null) _focusAfterFrame();
  }

  /// The "×" also shows while the field is focused, to close the recent
  /// searches panel and the keyboard.
  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  /// After the frame, so the field is on stage when the request is made (the
  /// Explore tab may only be switching in right now).
  void _focusAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant ExploreSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusToken != null &&
        widget.focusToken != oldWidget.focusToken) {
      _focusAfterFrame();
    }
    if (widget.query != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.query,
        selection: TextSelection.collapsed(offset: widget.query.length),
      );
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    super.dispose();
  }

  static const double _focusRingWidth = 1.5;

  static OutlineInputBorder _border(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
    borderSide: side,
  );

  @override
  Widget build(BuildContext context) {
    final isTyping = widget.query.isNotEmpty;

    return TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      style: AppTextStyles.body,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: context.l10n.exploreSearchHint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.inkMuted),
        filled: true,
        fillColor: AppColors.surfaceRaised,
        prefixIcon: const Icon(AppIcons.search, color: AppColors.inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        border: _border(BorderSide.none),
        // The primary color ring while focused — it adds no height or width
        // (an input's border is drawn, not laid out), so focusing never moves
        // anything.
        focusedBorder: _border(
          const BorderSide(color: AppColors.accent, width: _focusRingWidth),
        ),
        // Typing: × clears. Focused and empty: × dismisses. At rest (empty,
        // not focused): the filter icon.
        suffixIcon: isTyping || widget.focusNode.hasFocus
            ? IconButton(
                icon: const Icon(AppIcons.close, color: AppColors.inkMuted),
                onPressed: isTyping ? widget.onClear : widget.focusNode.unfocus,
              )
            : IconButton(
                tooltip: context.l10n.exploreFilterTooltip,
                icon: const Icon(AppIcons.filter, color: AppColors.ink),
                onPressed: widget.onFilterTap,
              ),
      ),
    );
  }
}
