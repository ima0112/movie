import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/season_summary.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import 'episode_nav_button.dart';
import 'episode_sheet_body.dart';

/// H4b (Episode) — `docs/SCREENS.md` H4b: opened from an episode row in D2c.
/// The episode's [EpisodeSheetBody] with, pinned at the foot, "‹ Previous" and
/// "Next · E2 ›" to move through the season's [episodes] without closing the
/// sheet: the content cross-fades to the other episode and starts at the top
/// again.
///
/// The current episode is local UI state (CLAUDE.md rule 10); everything it
/// shows is already loaded by D2c, so there is no Cubit. With a single episode
/// (or none in [episodes]) there is no foot at all.
class EpisodeSheet extends StatefulWidget {
  const EpisodeSheet({
    super.key,
    required this.seasonNumber,
    required this.episode,
    this.episodes = const [],
    this.onPersonTap,
  });

  final int seasonNumber;

  /// The episode to open on.
  final Episode episode;

  /// The season's episodes, in order, [episode] among them; the sheet moves
  /// through them.
  final List<Episode> episodes;

  /// A guest star was tapped → D3.
  final void Function(Person person)? onPersonTap;

  static const double _heightFactor = 0.85;
  static const Duration _fade = Duration(milliseconds: 200);

  /// From this text scale up, the two buttons stack instead of sharing a row.
  static const double _stackScale = 1.5;

  @override
  State<EpisodeSheet> createState() => _EpisodeSheetState();
}

class _EpisodeSheetState extends State<EpisodeSheet> {
  late int _index;

  List<Episode> get _episodes =>
      widget.episodes.length > 1 ? widget.episodes : const [];

  Episode get _current =>
      _episodes.isEmpty ? widget.episode : _episodes[_index];

  @override
  void initState() {
    super.initState();
    final found = widget.episodes.indexOf(widget.episode);
    _index = found < 0 ? 0 : found;
  }

  void _go(int delta) => setState(() => _index += delta);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final episode = _current;
    final still = MediaQuery.disableAnimationsOf(context);
    final hasPrevious = _episodes.isNotEmpty && _index > 0;
    final hasNext = _episodes.isNotEmpty && _index < _episodes.length - 1;

    final previous = EpisodeNavButton(
      forward: false,
      label: hasPrevious
          ? l10n.tvEpisodePreviousWithCode(_episodes[_index - 1].episodeNumber)
          : l10n.tvEpisodePrevious,
      onTap: hasPrevious ? () => _go(-1) : null,
    );
    final next = EpisodeNavButton(
      forward: true,
      label: hasNext
          ? l10n.tvEpisodeNextWithCode(_episodes[_index + 1].episodeNumber)
          : l10n.tvEpisodeNext,
      onTap: hasNext ? () => _go(1) : null,
    );
    final stacked =
        MediaQuery.textScalerOf(context).scale(1) >= EpisodeSheet._stackScale;

    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: EpisodeSheet._heightFactor,
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: still ? Duration.zero : EpisodeSheet._fade,
                child: EpisodeSheetBody(
                  // A new key per episode: it fades and its scroll resets.
                  key: ValueKey(_index),
                  seasonNumber: widget.seasonNumber,
                  episode: episode,
                  onPersonTap: widget.onPersonTap,
                ),
              ),
            ),
            if (_episodes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.md,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          next,
                          const SizedBox(height: AppSpacing.md),
                          previous,
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(child: previous),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(child: next),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
