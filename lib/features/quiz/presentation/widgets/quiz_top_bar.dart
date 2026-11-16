import 'package:flutter/material.dart';

import '../../../../core/domain/entities/media_type.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';

/// The quiz's top row (E2): the back button on the left and, centred, the
/// icon of the kind of title being searched (a film strip or a TV). There is
/// no "skip" — every step already has a sensible default.
class QuizTopBar extends StatelessWidget {
  const QuizTopBar({super.key, required this.mediaType, required this.onBack});

  final MediaType mediaType;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              icon: const Icon(AppIcons.back, color: AppColors.ink),
              onPressed: onBack,
            ),
          ),
          ExcludeSemantics(
            child: Icon(
              mediaType == MediaType.movie ? AppIcons.movie : AppIcons.tvShow,
              color: AppColors.inkMuted,
              size: AppSpacing.xl,
            ),
          ),
        ],
      ),
    );
  }
}
