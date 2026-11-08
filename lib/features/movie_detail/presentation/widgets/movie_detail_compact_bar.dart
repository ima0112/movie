import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/movie_detail_cubit.dart';

/// D1's compact bar: "When the title scrolls past the top, a compact
/// black bar appears with back and the title at 16 px" (SCREENS.md D1).
///
/// Pure presentation — whether it's shown at all is the assembled
/// screen's scroll-position concern (see `movie_detail_screen.dart`'s
/// `ValueListenableBuilder`); this widget only renders its own content
/// once mounted, with its own narrow `BlocSelector` on just the title
/// (rule 9) so a scroll-driven rebuild never touches the rest of D1.
class MovieDetailCompactBar extends StatelessWidget {
  const MovieDetailCompactBar({super.key});

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
              child: BlocSelector<MovieDetailCubit, MovieDetailState, String?>(
                selector: (state) => switch (state) {
                  MovieDetailLoaded(:final detail) => detail.item.title,
                  _ => null,
                },
                builder: (context, title) {
                  // SCREENS.md says 16 px; `h3` (15 px) is the closest
                  // existing token — no dedicated 16 px style yet
                  // (CLAUDE.md rule 4).
                  return Text(
                    title ?? '',
                    style: AppTextStyles.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
