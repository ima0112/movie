import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../l10n/l10n_extension.dart';
import '../../../../../shared/widgets/app_snack_bar.dart';
import '../../cubit/surprise_cubit.dart';
import '../../cubit/surprise_state.dart';

/// Shows the deck's one-time notices (search widened, no more surprises,
/// offline) as the app's snackbar and tells the Cubit they were shown. Renders
/// [child] untouched — a listener, not a builder.
class SurpriseNoticeListener extends StatelessWidget {
  const SurpriseNoticeListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<SurpriseCubit, SurpriseState>(
      listenWhen: (previous, current) =>
          current is SurpriseResult && current.notice != SurpriseNotice.none,
      listener: (context, state) {
        final notice = (state as SurpriseResult).notice;
        final l10n = context.l10n;
        final message = switch (notice) {
          SurpriseNotice.widenedSearch => l10n.surpriseNoticeWidened,
          SurpriseNotice.noMoreSurprises => l10n.surpriseNoticeNoMore,
          SurpriseNotice.offline => l10n.surpriseNoticeOffline,
          SurpriseNotice.none => null,
        };
        if (message != null) AppSnackBar.show(context, message);
        context.read<SurpriseCubit>().noticeShown();
      },
      child: child,
    );
  }
}
