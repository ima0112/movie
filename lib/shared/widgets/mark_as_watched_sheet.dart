import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/domain/entities/media_detail.dart';
import '../../core/domain/entities/media_key.dart';
import '../../core/domain/entities/user_media_entry.dart';
import '../../core/domain/repositories/user_library_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';
import 'mark_as_watched_date_field.dart';
import 'media_detail_duration.dart';
import 'rating_stars_selector.dart';

/// H2 (Mark as watched) — `docs/SCREENS.md` H2: "Title, 5-star selector
/// (optional), date (today by default, editable), 'Save' button, 'Remove
/// from Watched' link if it already was".
///
/// Opens from D1/D2's "Watched" button and (not yet wired — a separate
/// follow-up) B4's swipe-right/tapping the stars in Watched. Nothing
/// reaches [UserLibraryRepository] until "Save"/"Remove from Watched" is
/// tapped. Both fields are genuinely optional: the date defaults to
/// today and the rating to unset, so a zero-interaction Save is valid.
class MarkAsWatchedSheet extends StatefulWidget {
  const MarkAsWatchedSheet({
    super.key,
    required this.mediaKey,
    required this.userLibraryRepository,
    this.existingEntry,
    this.mediaDetail,
  });

  final MediaKey mediaKey;
  final UserLibraryRepository userLibraryRepository;

  /// Non-null when re-opening H2 for an entry that's already watched —
  /// pre-fills the rating/date and shows "Remove from Watched"
  /// (`docs/SCREENS.md` D1: "Tapping 'Watched' again opens H2 with
  /// current values... a red 'Remove from Watched' link").
  final UserMediaEntry? existingEntry;

  /// The detail screen's already-loaded [MediaDetail] (D1/D2 always have
  /// one) — see [durationFieldsFrom] for how "Save" uses it.
  final MediaDetail? mediaDetail;

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
        widget.existingEntry ??
        UserMediaEntry(
          key: widget.mediaKey,
          title: widget.mediaDetail?.item.title ?? '',
        );
    // Fresh values fall back to `current`'s own — see
    // [durationFieldsFrom]'s doc comment.
    final fresh = durationFieldsFrom(widget.mediaDetail);
    final detail = widget.mediaDetail;
    final snapshot = detail == null ? null : catalogSnapshotFrom(detail.item);
    unawaited(
      widget.userLibraryRepository.upsert(
        current.markWatched(
          watchedAt: _date,
          rating: _rating,
          runtimeMinutes: fresh.runtimeMinutes ?? current.runtimeMinutes,
          episodeCount: fresh.episodeCount ?? current.episodeCount,
          episodeRuntimeMinutes:
              fresh.episodeRuntimeMinutes ?? current.episodeRuntimeMinutes,
          // markWatched() already falls back to current's own value for
          // genres/posterUrl/voteAverage/year when these are null, same
          // as it does for the duration fields above.
          genres: detail?.item.genres,
          posterUrl: snapshot?.posterUrl,
          voteAverage: snapshot?.voteAverage,
          year: snapshot?.year,
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  /// D1's generic "Mark as watched" doesn't fit a TV show the same way
  /// a movie — a show can span dozens of episodes, so "watched" reads
  /// as a claim about having finished it, not just pressed a button.
  /// Not in `docs/SCREENS.md` yet (H2's own row only says "Title",
  /// generically) — a direct product decision for D2 from this task,
  /// kept here rather than invented per-screen copy since this sheet is
  /// D1/D2's only shared entry point into it.
  String _heading() {
    final detail = widget.mediaDetail;
    if (detail is TvShowDetail) {
      return context.l10n.mediaDetailHaveYouFinished(detail.item.title);
    }
    return context.l10n.mediaDetailMarkAsWatched;
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_heading(), style: AppTextStyles.h1),
            const SizedBox(height: AppSpacing.xl),
            _FieldLabel(context.l10n.mediaDetailYourRating),
            const SizedBox(height: AppSpacing.xs),
            RatingStarsSelector(
              rating: _rating,
              onChanged: (rating) => setState(() => _rating = rating),
            ),
            const SizedBox(height: AppSpacing.lg),
            _FieldLabel(context.l10n.mediaDetailDateLabel),
            const SizedBox(height: AppSpacing.sm),
            MarkAsWatchedDateField(date: _date, onTap: _pickDate),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(label: context.l10n.commonSave, onTap: _save),
            if (isEditingWatched) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: GestureDetector(
                  onTap: _remove,
                  child: Text(
                    context.l10n.mediaDetailRemoveFromWatched,
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
}

/// A small spaced-out uppercase caption over a field ("YOUR RATING",
/// "DATE") — the "Marcar como vista" design.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  static const double _letterSpacing = 0.6;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.caption.copyWith(
        color: AppColors.inkMuted,
        letterSpacing: _letterSpacing,
      ),
    );
  }
}
