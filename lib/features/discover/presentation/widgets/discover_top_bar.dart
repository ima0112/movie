import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_wordmark.dart';

/// "PakoTV" wordmark only — search lives in `DiscoverSearchField`, below
/// the hero. `const`, built once: static structure per `docs/SCREENS.md`
/// B1 — never depends on load state (CLAUDE.md rule 9).
class DiscoverTopBar extends StatelessWidget {
  const DiscoverTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Align(alignment: Alignment.centerLeft, child: AppWordmark()),
    );
  }
}
