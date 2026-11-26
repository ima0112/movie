import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every network image goes through `AppNetworkImage` (`docs/DECISIONS.md`,
/// "Caching"), so every one shares the disk cache, the decode-at-drawn-size
/// policy and the placeholder. This replaces the brief's "a grep of
/// `Image.network` in `lib/` finds nothing".
void main() {
  // The three files that are the cache: the service, its real implementation and
  // the widget.
  const allowed = {
    'lib/core/network/image_cache/app_image_cache.dart',
    'lib/core/network/image_cache/cached_image_cache.dart',
    'lib/shared/widgets/app_network_image.dart',
  };
  final pattern = RegExp(
    r'(?<![A-Za-z])(Image\.network|NetworkImage|CachedNetworkImage|'
    r'CachedNetworkImageProvider|precacheImage)\b\s*\(',
  );

  test('no widget builds Image.network, NetworkImage, CachedNetworkImage or '
      'precacheImage outside the image cache', () {
    final hits = <String>[];
    for (final file in Directory('lib').listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      if (allowed.contains(file.path)) continue;
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (pattern.hasMatch(line)) {
          hits.add('${file.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(
      hits,
      isEmpty,
      reason: 'use AppNetworkImage / AppNetworkImage.precache',
    );
  });

  test('the guard sees what it should', () {
    expect(pattern.hasMatch('return Image.network(url);'), isTrue);
    expect(
      pattern.hasMatch('await precacheImage(NetworkImage(u), c);'),
      isTrue,
    );
    expect(pattern.hasMatch('child: AppNetworkImage(url: u),'), isFalse);
    expect(pattern.hasMatch('NetworkImageCache()'), isFalse);
  });
}
