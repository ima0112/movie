import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/entities/media_key.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_icons.dart';
import '../../../../../l10n/l10n_extension.dart';
import '../../cubit/surprise_cubit.dart';
import '../../cubit/surprise_state.dart';

/// The Watch later button in a card's top-right corner: an outline bookmark
/// when the title isn't saved, a solid amber one when it is; tapping toggles.
/// It listens only to whether *its own* title is in Watch later, so saving one
/// card rebuilds this button and nothing else.
class SurpriseSaveButton extends StatelessWidget {
  const SurpriseSaveButton({super.key, required this.mediaKey});

  final MediaKey mediaKey;

  static const double size = 44;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocSelector<SurpriseCubit, SurpriseState, bool>(
      selector: (s) => switch (s) {
        SurpriseResult() => s.savedKeys.contains(mediaKey),
        SurpriseChosen() => s.savedKeys.contains(mediaKey),
        _ => false,
      },
      builder: (context, saved) => Semantics(
        button: true,
        toggled: saved,
        excludeSemantics: true,
        label: saved
            ? l10n.myListActionRemoveWatchLater
            : l10n.surpriseAddToWatchLater,
        onTap: () => _toggle(context),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _toggle(context),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.lineStrong),
                ),
                child: SizedBox(
                  width: size - 8,
                  height: size - 8,
                  child: Icon(
                    saved ? AppIcons.watchLaterFill : AppIcons.watchLater,
                    size: _iconSize,
                    color: saved ? AppColors.accent : AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle(BuildContext context) {
    HapticFeedback.lightImpact();
    context.read<SurpriseCubit>().toggleSaved(mediaKey);
  }
}
