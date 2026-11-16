import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';

/// The foot of C5: where everything is kept ("only on your device") and, on
/// the right, a discreet "Saved" that shows for a moment after each change —
/// every edit saves by itself. Selects only that flag (rule 9).
class TasteFooter extends StatelessWidget {
  const TasteFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppTextStyles.caption.copyWith(color: AppColors.inkMuted);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenMargin,
        AppSpacing.sectionGap,
        AppSpacing.screenMargin,
        0,
      ),
      child: Row(
        children: [
          Expanded(child: Text(l10n.myTastesFooter, style: muted)),
          const SizedBox(width: AppSpacing.md),
          BlocSelector<MyTastesCubit, MyTastesState, bool>(
            selector: (state) => state.justSaved,
            builder: (context, saved) => AnimatedOpacity(
              opacity: saved ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(l10n.myTastesSavedIndicator, style: muted),
            ),
          ),
        ],
      ),
    );
  }
}
