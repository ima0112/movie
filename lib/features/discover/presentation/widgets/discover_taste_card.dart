import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di.dart';
import '../../../../app/router.dart';
import '../../../../core/domain/entities/taste_profile.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/l10n_extension.dart';

/// B1's taste-completion card (All tab): a full-width, quiet invitation in the
/// feed to tell the app what you like (→ C5). It is only there while the app
/// has nothing to personalise with — no usable taste profile *and* an empty
/// My List — and disappears the moment either exists.
///
/// Screen-local subscriptions to the two repositories (CLAUDE.md rule 10):
/// nothing global holds a copy of the library. No Pako here — it is a
/// card, not a mascot moment.
class DiscoverTasteCard extends StatefulWidget {
  const DiscoverTasteCard({super.key});

  @override
  State<DiscoverTasteCard> createState() => _DiscoverTasteCardState();
}

class _DiscoverTasteCardState extends State<DiscoverTasteCard> {
  final _subscriptions = <StreamSubscription<Object?>>[];
  bool? _hasProfile;
  bool? _hasLibrary;

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      getIt<TasteProfileRepository>().watch().listen((TasteProfile? p) {
        _update(() => _hasProfile = p?.isUsableForSuggestions ?? false);
      }),
      getIt<UserLibraryRepository>().watch().listen((
        List<UserMediaEntry> entries,
      ) {
        _update(() => _hasLibrary = entries.isNotEmpty);
      }),
    ]);
  }

  void _update(VoidCallback change) {
    if (!mounted) return;
    setState(change);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wait for both signals: no flash of the card for someone who has data.
    if (_hasProfile != false || _hasLibrary != false) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: AppSpacing.sectionTopPadding,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
        ),
        child: _TasteCardBody(onTap: () => context.push(AppRoutes.myTastes)),
      ),
    );
  }
}

class _TasteCardBody extends StatelessWidget {
  const _TasteCardBody({required this.onTap});

  final VoidCallback onTap;

  static const double _iconSize = 44;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: '${l10n.discoverTasteCardTitle}. ${l10n.discoverTasteCardBody}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.lineStrong),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentDeep.withValues(alpha: 0.55),
                AppColors.surfaceRaised,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: _iconSize,
                height: _iconSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                ),
                child: const Icon(AppIcons.match, color: AppColors.onAccent),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.discoverTasteCardTitle, style: AppTextStyles.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.discoverTasteCardBody,
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(AppIcons.chevronRight, color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
