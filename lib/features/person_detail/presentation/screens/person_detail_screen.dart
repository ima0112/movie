import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/domain/repositories/person_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/media_detail/media_detail_compact_bar.dart';
import '../../../../shared/widgets/scrim_back_button.dart';
import '../../../../shared/widgets/state_views.dart';
import '../cubit/person_detail_cubit.dart';
import '../widgets/person_detail_content.dart';
import '../widgets/person_detail_header.dart';

/// D3 (Person detail).
///
/// Implements `docs/SCREENS.md` D3.
///
/// Thin per CLAUDE.md rule 11 — same shape as `MovieDetailScreen`/
/// `TvDetailScreen`: provides `PersonDetailCubit`, owns the shared
/// `ScrollController` the compact bar needs, and picks skeleton/error/
/// content. The compact-bar threshold differs from D1/D2's: their
/// header is a fixed fraction of the screen (the full-bleed poster);
/// D3's circular-photo header isn't, so this measures its real height
/// via `PersonDetailContent`'s own `headerKey` instead of a fraction.
class PersonDetailScreen extends StatelessWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final int personId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PersonDetailCubit(getIt<PersonRepository>())..loadDetail(personId),
      child: _PersonDetailView(personId: personId),
    );
  }
}

class _PersonDetailView extends StatefulWidget {
  const _PersonDetailView({required this.personId});

  final int personId;

  @override
  State<_PersonDetailView> createState() => _PersonDetailViewState();
}

class _PersonDetailViewState extends State<_PersonDetailView> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();
  final ValueNotifier<bool> _showCompactBar = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final headerHeight =
        _headerKey.currentContext?.size?.height ?? double.infinity;
    _showCompactBar.value =
        _scrollController.offset > headerHeight - kToolbarHeight;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _showCompactBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // The only `BlocBuilder` on this screen (CLAUDE.md rule 9) —
          // everything below it selects its own slice of
          // `PersonDetailState`.
          BlocBuilder<PersonDetailCubit, PersonDetailState>(
            builder: (context, state) {
              return switch (state) {
                PersonDetailInitial() || PersonDetailLoading() => const Stack(
                  children: [_PersonDetailSkeleton(), ScrimBackButton()],
                ),
                PersonDetailError(:final reason) => Stack(
                  children: [
                    Center(
                      child: ErrorStateView(
                        title: "Couldn't load",
                        body: reason.localizedMessage(context.l10n),
                        onRetry: () => context
                            .read<PersonDetailCubit>()
                            .loadDetail(widget.personId),
                      ),
                    ),
                    const ScrimBackButton(),
                  ],
                ),
                PersonDetailLoaded(:final detail) => PersonDetailContent(
                  detail: detail,
                  scrollController: _scrollController,
                  headerKey: _headerKey,
                ),
              };
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _showCompactBar,
            builder: (context, visible, child) =>
                visible ? child! : const SizedBox.shrink(),
            child: BlocSelector<PersonDetailCubit, PersonDetailState, String?>(
              selector: (state) => switch (state) {
                PersonDetailLoaded(:final detail) => detail.person.name,
                _ => null,
              },
              builder: (context, name) =>
                  MediaDetailCompactBar(title: name ?? ''),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonDetailSkeleton extends StatelessWidget {
  const _PersonDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: AppSpacing.xxxl * 2),
        Center(
          child: ClipOval(
            child: SkeletonBlock(
              width: PersonDetailHeader.photoSize,
              height: PersonDetailHeader.photoSize,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(child: SkeletonBlock(width: width * 0.5, height: 28)),
        const SizedBox(height: AppSpacing.sm),
        Center(child: SkeletonBlock(width: width * 0.3, height: 16)),
      ],
    );
  }
}
