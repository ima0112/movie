import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_item.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/media_carousel.dart';
import '../cubit/movie_detail_cubit.dart';

/// D1's "Similar" carousel — no "See all" (SCREENS.md D1).
///
/// Carries its own `BlocSelector` on just `MediaDetail.similar` (rule 9).
class MovieSimilarSection extends StatelessWidget {
  const MovieSimilarSection({super.key, this.onItemTap});

  final void Function(MediaItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MovieDetailCubit, MovieDetailState, List<MediaItem>?>(
      selector: (state) => switch (state) {
        MovieDetailLoaded(:final detail) => detail.similar,
        _ => null,
      },
      builder: (context, similar) {
        if (similar == null || similar.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Similar', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.md),
              MediaCarousel.standard(
                items: similar,
                showTypeTag: true,
                onItemTap: onItemTap,
              ),
            ],
          ),
        );
      },
    );
  }
}
