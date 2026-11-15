import 'package:flutter/widgets.dart';

import '../../core/theme/app_spacing.dart';

/// The page's side margin ([AppSpacing.screenMargin]) around one block of a
/// screen whose list has no side padding of its own — so a block that scrolls
/// edge to edge (a poster row) can sit beside cards that start on the margin.
class PageMargin extends StatelessWidget {
  const PageMargin({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
    child: child,
  );
}
