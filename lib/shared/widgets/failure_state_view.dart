import 'package:flutter/material.dart';

import '../../core/domain/entities/result.dart';
import '../../l10n/failure_localization.dart';
import '../../l10n/l10n_extension.dart';
import 'error_state_view.dart';
import 'offline_state_view.dart';

/// The state of a screen whose load failed with [reason]: the **offline** state
/// when it was the network ([FailureReason.network]), otherwise the **error**
/// state with the message for that cause (`FailureReason.localizedMessage`).
/// The one place that decision lives — screens don't build either by hand.
///
/// [onGoToMyList] adds the "Go to My List" link to the offline state; only the
/// root tabs (Home, Explore) pass it.
class FailureStateView extends StatelessWidget {
  const FailureStateView({
    super.key,
    required this.reason,
    required this.onRetry,
    this.onGoToMyList,
  });

  final FailureReason reason;
  final VoidCallback onRetry;
  final VoidCallback? onGoToMyList;

  @override
  Widget build(BuildContext context) {
    if (reason == FailureReason.network) {
      return OfflineStateView(onRetry: onRetry, onGoToMyList: onGoToMyList);
    }
    final l10n = context.l10n;
    return ErrorStateView(
      title: l10n.commonCouldntLoad,
      body: reason.localizedMessage(l10n),
      onRetry: onRetry,
    );
  }
}
