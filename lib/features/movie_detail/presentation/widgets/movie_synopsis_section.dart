import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_detail.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/movie_detail_cubit.dart';

/// D1's synopsis: an italic tagline (if present) + the overview folded to
/// 4 lines with an amber "Read more".
///
/// Source of truth: `docs/SCREENS.md` D1. Carries its own `BlocSelector`
/// on just [MovieDetail]'s tagline/overview (rule 9); the "read more"
/// expand is local widget state, not Cubit state — it has no meaning
/// outside this one widget's lifecycle (rule 10 applies to shared data,
/// not this).
class MovieSynopsisSection extends StatefulWidget {
  const MovieSynopsisSection({super.key});

  @override
  State<MovieSynopsisSection> createState() => _MovieSynopsisSectionState();
}

class _MovieSynopsisSectionState extends State<MovieSynopsisSection> {
  static const int _foldedMaxLines = 4;

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MovieDetailCubit, MovieDetailState, MovieDetail?>(
      selector: (state) => switch (state) {
        MovieDetailLoaded(detail: MovieDetail movie) => movie,
        _ => null,
      },
      builder: (context, detail) {
        if (detail == null || detail.overview.isEmpty) {
          return const SizedBox.shrink();
        }
        final tagline = detail.tagline;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tagline != null && tagline.isNotEmpty) ...[
                Text(
                  tagline,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Text(
                detail.overview,
                style: AppTextStyles.body,
                maxLines: _expanded ? null : _foldedMaxLines,
                overflow: _expanded ? null : TextOverflow.ellipsis,
              ),
              // Always offered when folded — measuring real overflow needs
              // a LayoutBuilder/TextPainter pass this widget doesn't do
              // yet; tapping it when the text already fit is harmless.
              if (!_expanded) ...[
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () => setState(() => _expanded = true),
                  child: Text(
                    'Read more',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
