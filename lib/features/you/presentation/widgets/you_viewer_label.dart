import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/stats/library_stats.dart';
import '../../../../core/domain/stats/viewer_label.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../l10n/viewer_label_localization.dart';
import '../cubit/you_stats_cubit.dart';

/// The line under the user's name: what their watch history says they are
/// ("Fan of Science Fiction", "Series binger"…). Draws nothing until
/// something has been watched. Selects only the label from [YouStatsCubit], so
/// it rebuilds when the label changes and for nothing else (rule 9).
class YouViewerLabel extends StatelessWidget {
  const YouViewerLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<YouStatsCubit, LibraryStats?, ViewerLabel?>(
      selector: (stats) => stats?.viewerLabel,
      builder: (context, label) {
        if (label == null) return const SizedBox.shrink();
        return Text(
          label.localized(context.l10n),
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
