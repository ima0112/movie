import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/failure_localization.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_buttons.dart';
import '../../../../shared/widgets/sheet_search_field.dart';
import '../../../../shared/widgets/skeleton_block.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';
import '../cubit/my_tastes_cubit.dart';
import '../cubit/my_tastes_state.dart';
import '../cubit/taste_platforms_cubit.dart';
import '../../../../core/domain/text/search_text.dart';

/// Opens the platform picker over C5: every streaming service of the user's
/// region in a searchable list, multi-select. Each tap saves at once (C5 is
/// auto-saved), so "Done" only closes. It opens on the root navigator, so the
/// two cubits are handed in explicitly.
Future<void> showTastePlatformsSheet(BuildContext context) {
  final tastes = context.read<MyTastesCubit>();
  final platforms = context.read<TastePlatformsCubit>();
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: tastes),
        BlocProvider.value(value: platforms),
      ],
      child: const TastePlatformsSheet(),
    ),
  );
}

/// The picker's content: a title, a search field, the list and "Done".
class TastePlatformsSheet extends StatefulWidget {
  const TastePlatformsSheet({super.key});

  @override
  State<TastePlatformsSheet> createState() => _TastePlatformsSheetState();
}

class _TastePlatformsSheetState extends State<TastePlatformsSheet> {
  String _query = '';

  static const double _height = 0.85;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: _height,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.myTastesPlatformsSheetTitle, style: AppTextStyles.h1),
              const SizedBox(height: AppSpacing.lg),
              SheetSearchField(
                hint: l10n.myTastesPlatformsSearchHint,
                query: _query,
                onChanged: (query) => setState(() => _query = query),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _List(query: _query)),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.commonDone,
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _List extends StatelessWidget {
  const _List({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted);
    return BlocBuilder<TastePlatformsCubit, TastePlatformsState>(
      builder: (context, state) => switch (state) {
        TastePlatformsLoading() => ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (var i = 0; i < 6; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: SkeletonBlock(
                  width: double.infinity,
                  height: _Row.height,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
          ],
        ),
        TastePlatformsError(:final reason) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(reason.localizedMessage(l10n), style: muted),
              TextLinkButton(
                label: l10n.commonRetry,
                onTap: context.read<TastePlatformsCubit>().load,
                fullWidth: false,
              ),
            ],
          ),
        ),
        TastePlatformsLoaded(:final services) => _Matches(
          services: [
            for (final s in services)
              if (matchesSearch(s.name, query)) s,
          ],
        ),
      },
    );
  }
}

class _Matches extends StatelessWidget {
  const _Matches({required this.services});

  final List<StreamingService> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Text(
          context.l10n.commonNoMatches,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
      );
    }
    final cubit = context.read<MyTastesCubit>();
    return BlocSelector<MyTastesCubit, MyTastesState, Set<int>>(
      selector: (state) => state.platformIds,
      builder: (context, selected) => ListView(
        children: [
          for (final (i, service) in services.indexed) ...[
            if (i > 0) const Divider(height: 1),
            _Row(
              service: service,
              selected: selected.contains(service.id),
              onTap: () => cubit.togglePlatform(service.id),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final StreamingService service;
  final bool selected;
  final VoidCallback onTap;

  static const double height = 60;
  static const double _logo = 36;
  static const double _check = 22;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: service.name,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: height),
          child: Row(
            children: [
              StreamingServiceLogo(service: service, size: _logo),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  service.name,
                  style: AppTextStyles.h3Toggle(selected),
                ),
              ),
              if (selected)
                const Icon(
                  AppIcons.check,
                  color: AppColors.accent,
                  size: _check,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
