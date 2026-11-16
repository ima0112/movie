import 'package:flutter/widgets.dart';

import 'app_tab_bar.dart';

/// Centers a state view (empty, error) in the room the floating [AppTabBar]
/// leaves free, not in the whole body, which runs under the bar. Wrap the
/// state view of any root tab's page with it; pushed screens have no bar and
/// don't need it.
class ClearOfTabBar extends StatelessWidget {
  const ClearOfTabBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTabBar.scrollInset(context)),
      child: child,
    );
  }
}
