import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// A sheet opened from a root tab (Home, Explore, My List, You) must go on the
/// **root navigator**, so it covers the floating tab bar instead of sitting
/// under it. This guards the files those tabs open sheets from; a sheet on a
/// pushed screen (no bar there) doesn't need it.
void main() {
  const tabSheetFiles = [
    'lib/features/you/presentation/screens/you_screen.dart',
    'lib/features/my_list/presentation/entry_actions.dart',
    'lib/shared/widgets/actions_sheet.dart',
    'lib/shared/widgets/explore_filter_sheet.dart',
    'lib/features/my_tastes/presentation/widgets/taste_platforms_sheet.dart',
  ];

  for (final path in tabSheetFiles) {
    test('every showModalBottomSheet in $path uses the root navigator', () {
      final source = File(path).readAsStringSync();
      final calls = RegExp(r'showModalBottomSheet').allMatches(source);
      expect(calls, isNotEmpty, reason: 'the guard went stale: no sheet');
      for (final call in calls) {
        final end = source.indexOf('builder:', call.start);
        final head = source.substring(call.start, end);
        expect(
          head.contains('useRootNavigator: true'),
          isTrue,
          reason: 'a sheet in $path opens under the tab bar',
        );
      }
    });
  }
}
