import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/theme/app_spacing.dart';
import 'discover_taste_card_body.dart';

/// B1's taste-completion card (All tab): a full-width invitation in the feed to
/// tell the app what you like (→ C5) — see [DiscoverTasteCardBody] for its look.
/// It is there until the user has **chosen their tastes** (a usable taste
/// profile) and goes away the moment they do. Saving titles (Favorites, Watch
/// later, Watched) does **not** hide it: that isn't choosing tastes — the
/// recommendation sections may use the library as a signal, but this card asks
/// for the tastes themselves.
///
/// Screen-local subscription to the taste profile (CLAUDE.md rule 10): nothing
/// global holds a copy of it. No Pako here — it is a card, not a mascot moment.
class DiscoverTasteCard extends StatefulWidget {
  const DiscoverTasteCard({super.key});

  @override
  State<DiscoverTasteCard> createState() => _DiscoverTasteCardState();
}

class _DiscoverTasteCardState extends State<DiscoverTasteCard> {
  late final StreamSubscription<TasteProfile?> _subscription;

  /// `null` until the first answer: no flash of the card for someone who has
  /// already chosen.
  bool? _hasProfile;

  @override
  void initState() {
    super.initState();
    _subscription = getIt<TasteProfileRepository>().watch().listen((
      TasteProfile? profile,
    ) {
      if (!mounted) return;
      setState(() => _hasProfile = profile?.isUsableForSuggestions ?? false);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasProfile != false) return const SizedBox.shrink();
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
