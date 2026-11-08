import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/entities/video.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../cubit/movie_detail_cubit.dart';
import 'movie_action_button.dart';

/// D1's Trailer button + the Favorite / Watch later / Watched row.
///
/// Source of truth: `docs/SCREENS.md` D1. Per CLAUDE.md rule 10, this
/// subscribes directly to `UserLibraryRepository.watchEntry(mediaKey)`
/// instead of a My-List-wide Cubit — it only ever needs this one entry.
/// The Trailer button is the exception: whether a trailer exists comes
/// from [MovieDetailCubit] via its own narrow `BlocSelector` (rule 9).
class MovieActionRow extends StatelessWidget {
  const MovieActionRow({
    super.key,
    required this.mediaKey,
    required this.userLibraryRepository,
    this.onPlayTrailer,
    this.onSeeSimilar,
  });

  final MediaKey mediaKey;
  final UserLibraryRepository userLibraryRepository;

  /// No trailer → the button becomes "See similar" and scrolls there
  /// instead (SCREENS.md D1) — the assembled screen owns that scroll.
  final void Function(Video trailer)? onPlayTrailer;
  final VoidCallback? onSeeSimilar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BlocSelector<MovieDetailCubit, MovieDetailState, Video?>(
          selector: (state) => switch (state) {
            MovieDetailLoaded(detail: MovieDetail(:final trailer)) => trailer,
            _ => null,
          },
          builder: (context, trailer) {
            return PrimaryButton(
              label: trailer != null ? 'Trailer' : 'See similar',
              onTap: trailer != null
                  ? () => onPlayTrailer?.call(trailer)
                  : onSeeSimilar,
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        StreamBuilder<UserMediaEntry?>(
          stream: userLibraryRepository.watchEntry(mediaKey),
          builder: (context, snapshot) {
            final entry = snapshot.data;
            return Row(
              children: [
                Expanded(
                  child: MovieActionButton(
                    iconOutline: AppIcons.favorite,
                    iconFill: AppIcons.favoriteFill,
                    label: 'Favorite',
                    isActive: entry?.isFavorite ?? false,
                    onTap: () => _toggle(
                      entry,
                      (e) => e.copyWith(isFavorite: !e.isFavorite),
                    ),
                  ),
                ),
                Expanded(
                  child: MovieActionButton(
                    iconOutline: AppIcons.watchLater,
                    iconFill: AppIcons.watchLaterFill,
                    label: 'Watch later',
                    isActive: entry?.isWatchLater ?? false,
                    onTap: () => _toggle(
                      entry,
                      (e) => e.copyWith(isWatchLater: !e.isWatchLater),
                    ),
                  ),
                ),
                Expanded(
                  child: MovieActionButton(
                    iconOutline: AppIcons.watched,
                    iconFill: AppIcons.watchedFill,
                    label: 'Watched',
                    isActive: entry?.isWatched ?? false,
                    // TODO: should open H2 (rating sheet) once it exists —
                    // this toggles the flag directly in the meantime.
                    onTap: () => _toggle(
                      entry,
                      (e) => e.isWatched ? e.unmarkWatched() : e.markWatched(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _toggle(
    UserMediaEntry? entry,
    UserMediaEntry Function(UserMediaEntry) transform,
  ) {
    unawaited(
      userLibraryRepository.upsert(
        transform(entry ?? UserMediaEntry(key: mediaKey)),
      ),
    );
  }
}
