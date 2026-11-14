import 'package:flutter/material.dart';

import '../../core/theme/app_icons.dart';
import '../../l10n/l10n_extension.dart';
import 'app_buttons.dart';
import 'state_layout.dart';

/// Error state: the same layout as the empty state with a cloud-off icon and
/// an amber "Retry" (`docs/SCREENS.md` G). Most screens want [FailureStateView]
/// instead, which also tells an offline failure apart.
///
/// Pure presentation — everything comes in by parameter.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    required this.body,
    this.onRetry,
  });

  final String title;
  final String body;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return StateLayout(
      icon: AppIcons.cloudOff,
      title: title,
      body: body,
      actions: [
        AccentButton(
          label: context.l10n.commonRetry,
          onTap: onRetry,
          fullWidth: false,
        ),
      ],
    );
  }
}
