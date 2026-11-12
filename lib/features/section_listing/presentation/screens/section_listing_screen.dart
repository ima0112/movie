import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/media_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/listing_source.dart';
import '../../domain/listing_style.dart';
import '../cubit/section_listing_cubit.dart';
import '../widgets/listing_content.dart';
import '../widgets/listing_summary.dart';
import '../widgets/listing_toolbar.dart';

/// C1b — the "See all" listing of a section (Explore's six, Home's carousels):
/// the section's title in the bar; under it the context pill (left) and the
/// sort icon (right); the full list in a 3-column grid that loads page by page
/// as it scrolls. `docs/SCREENS.md` C1b.
///
/// A pushed screen on the root navigator (back button, bottom bar hidden).
/// Thin per CLAUDE.md rule 11: provides [SectionListingCubit] and assembles
/// the sub-widgets, each with its own rebuild scope (rule 9).
class SectionListingScreen extends StatelessWidget {
  const SectionListingScreen({
    super.key,
    required this.title,
    required this.source,
    required this.style,
    required this.listingContext,
  });

  final String title;
  final ListingSource source;
  final ListingStyle style;
  final ListingContext listingContext;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SectionListingCubit(getIt<MediaRepository>(), source)..load(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(AppIcons.back, color: AppColors.ink),
            onPressed: () => context.pop(),
          ),
          title: Text(title, style: AppTextStyles.h2),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListingToolbar(listingContext: listingContext),
              const ListingSummary(),
              Expanded(child: ListingContent(style: style)),
            ],
          ),
        ),
      ),
    );
  }
}
