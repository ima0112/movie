import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import 'discover_taste_card_body.dart';

/// B1's taste-completion card (All tab): a full-width invitation in the feed to
/// tell the app what you like (→ C5) — see [DiscoverTasteCardBody] for its look. It is only there while the app
/// has nothing to personalise with — no usable taste profile *and* an empty
/// My List — and disappears the moment either exists.
///
/// Screen-local subscriptions to the two repositories (CLAUDE.md rule 10):
/// nothing global holds a copy of the library. No Pako here — it is a
/// card, not a mascot moment.
class DiscoverTasteCard extends StatefulWidget {
  const DiscoverTasteCard({super.key});

  @override
  State<DiscoverTasteCard> createState() => _DiscoverTasteCardState();
}

class _DiscoverTasteCardState extends State<DiscoverTasteCard> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool? _hasProfile;
  bool? _hasLibrary;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      getIt<TasteProfileRepository>().watch().listen((TasteProfile? p) {
        _update(() => _hasProfile = p?.isUsableForSuggestions ?? false);
      }),
      getIt<UserLibraryRepository>().watch().listen((
        List<UserMediaEntry> entries,
      ) {
        _update(() => _hasLibrary = entries.isNotEmpty);
      }),
    ]);
  }

  void _update(VoidCallback change) {
    if (!mounted) return;
    setState(change);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait for both signals: no flash of the card for someone who has data.
    if (_hasProfile != false || _hasLibrary != false) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: AppSpacing.sectionTopPadding,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
        ),
        child: DiscoverTasteCardBody(
          onPickTastes: () => context.push(AppRoutes.myTastes),
        ),
      ),
    );
  }
}
