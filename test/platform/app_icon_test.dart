import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';

/// The launcher icon is the "P" monogram: `AppColors.onAccent` on
/// `AppColors.accent`. These tests keep the platform files and the app's own
/// colours from drifting apart, and catch a missing or wrong-sized file that a
/// build would only report on a device. Sources and how to regenerate:
/// `assets/icon/` and `docs/DESIGN_SYSTEM.md` ("App icon").
const _res = 'android/app/src/main/res';

String _read(String path) => File(path).readAsStringSync();

/// `#RRGGBB` of [color], upper-case.
String _hex(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// (width, height, colour type) from a PNG's header.
(int, int, int) _png(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  return (data.getUint32(16), data.getUint32(20), bytes[25]);
}

String _attr(String xml, String name) =>
    RegExp('$name="([^"]*)"').firstMatch(xml)!.group(1)!;

void main() {
  group('Android', () {
    test('the adaptive icon is a background colour, the vector "P" and its '
        'monochrome twin', () {
      final xml = _read('$_res/mipmap-anydpi-v26/ic_launcher.xml');
      expect(xml, contains('@color/ic_launcher_background'));
      expect(xml, contains('@drawable/ic_launcher_foreground'));
      expect(xml, contains('@drawable/ic_launcher_monochrome'));
      expect(
        File('$_res/drawable/ic_launcher_foreground.xml').existsSync(),
        isTrue,
      );
      expect(
        File('$_res/drawable/ic_launcher_monochrome.xml').existsSync(),
        isTrue,
      );
    });

    test('the background is the app accent and the "P" its on-accent', () {
      final background = _read('$_res/values/ic_launcher_background.xml');
      expect(
        background.toUpperCase(),
        contains(_hex(AppColors.accent.toARGB32())),
      );
      final foreground = _read('$_res/drawable/ic_launcher_foreground.xml');
      expect(
        _attr(foreground, 'android:fillColor').toUpperCase(),
        _hex(AppColors.onAccent.toARGB32()),
      );
    });

    test('the monochrome icon draws the same "P" as the coloured one', () {
      final foreground = _read('$_res/drawable/ic_launcher_foreground.xml');
      final mono = _read('$_res/drawable/ic_launcher_monochrome.xml');
      expect(
        _attr(mono, 'android:pathData'),
        _attr(foreground, 'android:pathData'),
      );
    });

    test('the "P" is the same glyph as the source SVG', () {
      final svg = _read('assets/icon/sources/icon_foreground.svg');
      final foreground = _read('$_res/drawable/ic_launcher_foreground.xml');
      expect(_attr(svg, ' d'), _attr(foreground, 'android:pathData'));
    });

    test('the legacy launcher icons exist in every density at its size', () {
      const sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      sizes.forEach((density, size) {
        final (w, h, _) = _png('$_res/mipmap-$density/ic_launcher.png');
        expect((w, h), (size, size), reason: density);
      });
    });

    test('the manifest names the app PickMe and uses the launcher icon', () {
      final manifest = _read('android/app/src/main/AndroidManifest.xml');
      expect(manifest, contains('android:label="PickMe"'));
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    });
  });

  group('iOS', () {
    const set = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';

    test('one 1024 px icon with no alpha channel (what the App Store asks '
        'for); iOS draws the mask', () {
      final (w, h, colorType) = _png('$set/Icon-App-1024x1024@1x.png');
      expect((w, h), (1024, 1024));
      expect(colorType, 2, reason: 'PNG colour type 2 = RGB, no alpha');
    });

    test('the icon set is the single-size kind: only that image', () {
      final contents = _read('$set/Contents.json');
      expect(contents, contains('"size" : "1024x1024"'));
      expect(contents, contains('"idiom" : "universal"'));
      expect(contents, contains('"platform" : "ios"'));
      final pngs = Directory(set)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList();
      expect(pngs, hasLength(1));
    });

    test('the home screen name is PickMe', () {
      final plist = _read('ios/Runner/Info.plist');
      expect(
        RegExp(
          r'CFBundleDisplayName</key>\s*<string>PickMe</string>',
        ).hasMatch(plist),
        isTrue,
      );
    });

    test('it is the same artwork as the master kept in assets/icon', () {
      expect(
        File('$set/Icon-App-1024x1024@1x.png').readAsBytesSync(),
        File('assets/icon/ios_app_icon_1024.png').readAsBytesSync(),
      );
    });
  });

  group('sources', () {
    test('the masters are kept, at the sizes the stores ask for', () {
      expect(_png('assets/icon/ios_app_icon_1024.png').$1, 1024);
      expect(_png('assets/icon/play_store_512.png').$1, 512);
      for (final svg in ['icon_full', 'icon_foreground', 'icon_monochrome']) {
        expect(File('assets/icon/sources/$svg.svg').existsSync(), isTrue);
      }
    });

    test('they stay out of the app bundle', () {
      expect(_read('pubspec.yaml'), isNot(contains('assets/icon')));
    });
  });
}
