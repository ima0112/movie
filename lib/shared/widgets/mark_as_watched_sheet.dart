import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/domain/entities/media_key.dart';
import '../../core/domain/entities/user_media_entry.dart';
import '../../core/domain/repositories/user_library_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_buttons.dart';
import 'rating_stars_selector.dart';

/// H2 (Mark as watched) — `docs/SCREENS.md` H2: "Title, 5-star selector
/// (optional), date (today by default, editable), 'Save' button, 'Remove
/// from Watched' link if it already was".
///
/// Opens from D1/D2's "Watched" button and (not yet wired — a separate
/// follow-up) B4's swipe-right/tapping the stars in Watched. Always
/// opened *before* any write happens — nothing reaches
/// [UserLibraryRepository] until "Save" (or "Remove from Watched") is
/// tapped. Both fields are genuinely optional in practice: the date
/// defaults to today and the rating defaults to unset, so tapping
/// "Save" with zero interaction is always valid.
class MarkAsWatchedSheet extends StatefulWidget {
  const MarkAsWatchedSheet({
    super.key,
    required this.mediaKey,
    required this.userLibraryRepository,
    this.existingEntry,
  });

  final MediaKey mediaKey;
  final UserLibraryRepository userLibraryRepository;

  /// Non-null when re-opening H2 for an entry that's already watched —
  /// pre-fills the rating/date and shows "Remove from Watched"
  /// (`docs/SCREENS.md` D1: "Tapping 'Watched' again opens H2 with
  /// current values... a red 'Remove from Watched' link").
  final UserMediaEntry? existingEntry;

  @override
  State<MarkAsWatchedSheet> createState() => _MarkAsWatchedSheetState();
}

class _MarkAsWatchedSheetState extends State<MarkAsWatchedSheet> {
  late int? _rating;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingEntry?.rating;
    // Always preselected at "today" — never blank.
    _date = widget.existingEntry?.watchedAt ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      // No such thing as watching something tomorrow.
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    final current =
        widget.existingEntry ?? UserMediaEntry(key: widget.mediaKey);
    unawaited(
      widget.userLibraryRepository.upsert(
        current.markWatched(watchedAt: _date, rating: _rating),
      ),
    );
    Navigator.of(context).pop();
  }

  void _remove() {
    unawaited(
      widget.userLibraryRepository.upsert(
        widget.existingEntry!.unmarkWatched(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditingWatched = widget.existingEntry?.isWatched ?? false;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mark as watched', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Your rating',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.sm),
            RatingStarsSelector(
              rating: _rating,
              onChanged: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: AppSpacing.lg),
            GestureDetector(
              onTap: _pickDate,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(_date), style: AppTextStyles.body),
                  const Icon(
                    AppIcons.chevronDown,
                    size: 20,
                    color: AppColors.inkMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(label: 'Save', onTap: _save),
            if (isEditingWatched) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: _remove,
                  child: Text(
                    'Remove from Watched',
                    style: AppTextStyles.body.copyWith(color: AppColors.danger),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static const _month = 'Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec';

  static String _formatDate(DateTime date) =>
      '${_month.split(',')[date.month - 1]} ${date.day}, ${date.year}';
}
