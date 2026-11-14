import 'package:flutter/material.dart';

import 'app_buttons.dart';
import 'state_layout.dart';

/// Empty state: an icon badge, a headline, a body line, and an optional CTA —
/// an outlined button, because "nothing here yet" isn't a problem to fix
/// (the error and offline states carry the amber "Retry").
///
/// Pure presentation — everything comes in by parameter.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.ctaLabel,
    this.onCtaTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCtaTap;

  @override
  Widget build(BuildContext context) {
    final cta = ctaLabel;
    return StateLayout(
      icon: icon,
      title: title,
      body: body,
      actions: [
        if (cta != null)
          SecondaryButton(label: cta, onTap: onCtaTap, fullWidth: false),
      ],
    );
  }
}
