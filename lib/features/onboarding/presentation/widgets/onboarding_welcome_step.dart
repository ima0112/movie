import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/domain/entities/result.dart';
import 'poster_wall.dart';
import 'welcome_view.dart';

/// Binds [WelcomeView]'s [PosterWall] background to a real
/// `/trending/all/week` fetch — `docs/SCREENS.md` A2 step 0. Not a Bloc
/// concern (rule 9 is about `Cubit` rebuild scope), just a one-shot
/// network read, so a plain `FutureBuilder` is enough; [postersFuture]
/// is a *stable* field on `OnboardingFlow`'s own `State` (fetched once
/// in `initState`), not rebuilt per frame.
///
/// A [Failure] (offline, timeout...) or still-loading resolves to an
/// empty list — [PosterWall]'s own contract already renders that as
/// placeholder tiles, which is exactly "Offline: same wall with
/// placeholders" from `docs/SCREENS.md`.
class OnboardingWelcomeStep extends StatelessWidget {
  const OnboardingWelcomeStep({
    super.key,
    required this.postersFuture,
    required this.onGetStarted,
  });

  final Future<Result<List<MediaItem>>> postersFuture;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<MediaItem>>>(
      future: postersFuture,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final posterUrls = result is Success<List<MediaItem>>
            ? result.value.map((item) => item.posterUrl).toList()
            : const <String?>[];
        return WelcomeView(posterUrls: posterUrls, onGetStarted: onGetStarted);
      },
    );
  }
}
