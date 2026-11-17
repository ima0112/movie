import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/di.dart';
import '../../../../../core/domain/repositories/local_flags_repository.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../cubit/surprise_cubit.dart';
import '../../../../match_engine/domain/surprise_batch.dart';
import '../../cubit/surprise_state.dart';
import 'surprise_accessible_controls.dart';
import 'surprise_deck_stack.dart';
import 'surprise_deck_top_bar.dart';
import 'surprise_notice_listener.dart';
import 'surprise_reroll_button.dart';
import 'surprise_save_button.dart';
import 'surprise_thumbnail_strip.dart';

/// Surprise me's deck page (`docs/SCREENS.md` E3): top bar, the thumbnail
/// strip, the deck, the double-tap line and "Ask for another 5". The first
/// time ever, the deck carries the "2×" overlay; a flag remembers it was seen.
///
/// Only the strip and the deck listen to the Cubit, each to what it needs;
/// the bar, the help line and the button are built once.
class SurpriseDeckView extends StatefulWidget {
  const SurpriseDeckView({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  State<SurpriseDeckView> createState() => _SurpriseDeckViewState();
}

class _SurpriseDeckViewState extends State<SurpriseDeckView> {
  final LocalFlagsRepository _flags = getIt<LocalFlagsRepository>();
  bool _showHint = false;
  final SurpriseDeckController _deck = SurpriseDeckController();

  @override
  void initState() {
    super.initState();
    _flags.isSet(LocalFlag.surpriseDoubleTapHintSeen).then((seen) {
      if (mounted && !seen) setState(() => _showHint = true);
    });
  }

  void _hintDismissed() {
    _flags.set(LocalFlag.surpriseDoubleTapHintSeen);
    if (mounted) setState(() => _showHint = false);
  }

  /// The screen-reader actions on the deck: the gestures, by name.
  Widget _withActions(BuildContext context, SurpriseCubit cubit, Widget deck) {
    final l10n = context.l10n;
    return Semantics(
      customSemanticsActions: {
        CustomSemanticsAction(label: l10n.surpriseControlNext): cubit.next,
        CustomSemanticsAction(label: l10n.surpriseControlSave): cubit.save,
        CustomSemanticsAction(label: l10n.surpriseChooseThis): cubit.choose,
        CustomSemanticsAction(label: l10n.surpriseActionFlip): _deck.flipTop,
      },
      child: deck,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SurpriseCubit>();
    return SurpriseNoticeListener(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Column(
            children: [
              SurpriseDeckTopBar(
                title: context.l10n.matchHubSurpriseMeTitle,
                onClose: widget.onClose,
              ),
              BlocSelector<SurpriseCubit, SurpriseState, _StripData?>(
                selector: (s) => s is SurpriseResult ? _StripData(s) : null,
                builder: (context, data) => data == null
                    ? const SizedBox.shrink()
                    : SurpriseThumbnailStrip(
                        posterUrls: data.posters,
                        currentIndex: data.index,
                        savedIndexes: data.saved,
                        onTap: cubit.jumpTo,
                      ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: BlocSelector<SurpriseCubit, SurpriseState, _DeckData?>(
                  selector: (s) => s is SurpriseResult ? _DeckData(s) : null,
                  builder: (context, data) => data == null
                      ? const SizedBox.shrink()
                      : _withActions(
                          context,
                          cubit,
                          SurpriseDeckStack(
                            suggestions: data.suggestions,
                            index: data.index,
                            onNext: cubit.next,
                            onChoose: cubit.choose,
                            onFlipped: cubit.cardFlipped,
                            controller: _deck,
                            cardAction: (i) => SurpriseSaveButton(
                              mediaKey: data.suggestions[i].item.key,
                            ),
                            showHint: _showHint,
                            onHintDismissed: _hintDismissed,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (MediaQuery.accessibleNavigationOf(context))
                BlocSelector<SurpriseCubit, SurpriseState, int>(
                  selector: (s) =>
                      s is SurpriseResult ? s.suggestions.length : 0,
                  builder: (context, count) => SurpriseAccessibleControls(
                    onSave: cubit.save,
                    onChoose: cubit.choose,
                    onNext: cubit.next,
                    canNext: count > 1,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenMargin),
                child: SurpriseRerollButton(onTap: cubit.reroll),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the strip shows; equality keeps it from rebuilding on a notice.
class _StripData {
  _StripData(SurpriseResult s)
    : index = s.index,
      posters = [for (final x in s.suggestions) x.item.posterUrl],
      saved = {
        for (var i = 0; i < s.suggestions.length; i++)
          if (s.isSaved(i)) i,
      };

  final int index;
  final List<String?> posters;
  final Set<int> saved;

  @override
  bool operator ==(Object other) =>
      other is _StripData &&
      other.index == index &&
      _sameList(other.posters, posters) &&
      other.saved.length == saved.length &&
      other.saved.containsAll(saved);

  @override
  int get hashCode => Object.hash(index, posters.length, saved.length);
}

/// What the deck shows: the batch and the card on top.
class _DeckData {
  _DeckData(SurpriseResult s) : suggestions = s.suggestions, index = s.index;

  final List<SurpriseSuggestion> suggestions;
  final int index;

  @override
  bool operator ==(Object other) =>
      other is _DeckData &&
      other.index == index &&
      identical(other.suggestions, suggestions);

  @override
  int get hashCode => Object.hash(index, suggestions.length);
}

bool _sameList(List<String?> a, List<String?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
