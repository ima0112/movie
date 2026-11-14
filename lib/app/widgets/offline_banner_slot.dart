import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/offline_banner.dart';
import '../cubits/connectivity_cubit.dart';

/// Where a network-backed root tab (Home, Explore) shows the [OfflineBanner]:
/// on the page margin, only while [ConnectivityCubit] says the app is offline,
/// and nothing (no height) otherwise. Its own `BlocSelector` is the only thing
/// that rebuilds when the connection changes (CLAUDE.md rule 9).
class OfflineBannerSlot extends StatelessWidget {
  const OfflineBannerSlot({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ConnectivityCubit, bool, bool>(
      selector: (online) => !online,
      builder: (context, offline) => AnimatedSize(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: offline
            ? const Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  0,
                  AppSpacing.screenMargin,
                  AppSpacing.md,
                ),
                child: OfflineBanner(),
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}
