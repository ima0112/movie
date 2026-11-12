import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// `docs/DESIGN_SYSTEM.md` §2/§3 enforced for the whole app: sizes, weights
/// and gaps come from `AppTextStyles` / `AppSpacing`, never from a number
/// typed in a widget. Same spirit as `no_hardcoded_display_text_test.dart`:
/// narrow, line-based, close to no false positives.
///
/// A line that genuinely must scale on its own opts out with a
/// `// type-exempt: <reason>` (text) or `// layout-exempt: <reason>` (gaps)
/// comment on that line or the one above.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('app_text_styles.dart'))
      .where((f) => !f.path.contains('/features/debug/'))
      .toList();

  List<String> scan(RegExp pattern, String exempt) {
    final hits = <String>[];
    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (!pattern.hasMatch(line)) continue;
        if (line.contains(exempt)) continue;
        if (i > 0 && lines[i - 1].contains(exempt)) continue;
        hits.add('${file.path}:${i + 1}: ${line.trim()}');
      }
    }
    return hits;
  }

  test(
    'no widget sets its own fontSize/fontWeight/letterSpacing — use an AppTextStyles '
    'token (add one if it is missing)',
    () {
      expect(
        scan(RegExp(r'\b(fontSize|fontWeight|letterSpacing):'), 'type-exempt:'),
        isEmpty,
      );
    },
  );

  test('no widget types a raw number as a gap or padding — use an '
      'AppSpacing token', () {
    final pattern = RegExp(
      r'(EdgeInsets\.[a-zA-Z]+\(|SizedBox\((height|width): )'
      r'(?![^;]*AppSpacing)[^;]*\b\d+(\.\d+)?\b',
    );
    expect(scan(pattern, 'layout-exempt:'), isEmpty);
  });
}
