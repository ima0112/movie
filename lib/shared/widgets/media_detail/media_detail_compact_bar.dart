import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/l10n_extension.dart';

/// D1/D2's compact bar: "When the title scrolls past the top, a compact
/// black bar appears with back and the title at 16 px" (`docs/SCREENS.md`
/// D1, reused unchanged by D2).
///
/// Pure presentation — whether it's shown at all is the assembled
/// screen's scroll-position concern (see `movie_detail_screen.dart`'s
/// `ValueListenableBuilder`), and [title] arrives as a plain value: the
/// screen's own narrow `BlocSelector` on just the title (rule 9) feeds
/// it in, so a scroll-driven rebuild never touches the rest of D1/D2 and
/// this widget itself needs no Cubit awareness at all.
class MediaDetailCompactBar extends StatelessWidget {
  const MediaDetailCompactBar({super.key, required this.title, this.onShare});

  final String title;

  /// Shows a Share action at the end of the bar (D1/D2: their Share circle
  /// has scrolled away by now). `null` for screens with no share.
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: kToolbarHeight,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(AppIcons.back, color: AppColors.ink),
            ),
            Expanded(
              // SCREENS.md says 16 px; `h3` (15 px) is the closest
              // existing token — no dedicated 16 px style yet (CLAUDE.md
              // rule 4).
              child: Text(
                title,
                style: AppTextStyles.h3,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onShare != null)
              IconButton(
                onPressed: onShare,
                tooltip: context.l10n.mediaDetailShare,
                icon: const Icon(AppIcons.share, color: AppColors.ink),
              )
            else
              // As wide as the back button, so the title stays centered.
              const SizedBox(width: kMinInteractiveDimension),
          ],
        ),
      ),
    );
  }
}
