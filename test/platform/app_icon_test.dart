import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';

/// The launcher icon is PickMe's mark — an amber card with sparkles over a fan
/// of two cards — on `AppColors.surface`. These tests keep the platform files
/// and the app's own colour from drifting apart, and catch a missing or
/// wrong-sized file that a build would only report on a device. Sources and
/// how to change it: `assets/icon/` and `docs/DESIGN_SYSTEM.md` ("App icon").
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

void main() {
  group('Android', () {
    test('the adaptive icon is a background colour, the artwork and its '
        'monochrome twin', () {
      final xml = _read('$_res/mipmap-anydpi-v26/ic_launcher.xml');
      expect(xml, contains('@color/ic_launcher_background'));
      expect(xml, contains('@mipmap/ic_launcher_foreground'));
      expect(xml, contains('@mipmap/ic_launcher_monochrome'));
    });

    test('the background is the app surface colour', () {
      final background = _read('$_res/values/ic_launcher_background.xml');
      expect(
        background.toUpperCase(),
        contains(_hex(AppColors.surface.toARGB32())),
      );
    });

    test('every density has the legacy icon (48-192 px) and the adaptive '
        'layers (108 dp), with an alpha channel on the layers', () {
      const legacy = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192,
      };
      const layer = {
        'mdpi': 108,
        'hdpi': 162,
        'xhdpi': 216,
        'xxhdpi': 324,
        'xxxhdpi': 432,
      };
      for (final density in legacy.keys) {
        final (w, h, _) = _png('$_res/mipmap-$density/ic_launcher.png');
        expect((w, h), (legacy[density], legacy[density]), reason: density);
        for (final name in [
          'ic_launcher_foreground',
          'ic_launcher_monochrome',
        ]) {
          final (lw, lh, colorType) = _png('$_res/mipmap-$density/$name.png');
          expect(
            (lw, lh),
            (layer[density], layer[density]),
            reason: '$density $name',
          );
          expect(
            colorType,
            6,
            reason: '$density $name: PNG colour type 6 = RGBA',
          );
        }
      }
    });

    test('the old P-monogram vectors are gone', () {
      expect(
        File('$_res/drawable/ic_launcher_foreground.xml').existsSync(),
        isFalse,
      );
      expect(
        File('$_res/drawable/ic_launcher_monochrome.xml').existsSync(),
        isFalse,
      );
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
      expect(_png('assets/icon/splash_glyph.png').$3, 6);
      for (final svg in [
        'pickme-icon',
        'pickme-glyph',
        'pickme-glyph-mono',
        'pickme-logotipo',
      ]) {
        expect(File('assets/icon/sources/$svg.svg').existsSync(), isTrue);
      }
    });

    test('they stay out of the app bundle', () {
      expect(_read('pubspec.yaml'), isNot(contains('assets/icon')));
    });
  });

  group('native splash', () {
    const res = 'android/app/src/main/res';
    const launch = 'ios/Runner/Assets.xcassets/LaunchImage.imageset';

    test('it shows the mark, in step with flutter_native_splash.yaml', () {
      final config = _read('flutter_native_splash.yaml');
      expect(config, contains('assets/icon/splash_glyph.png'));
      expect(config, contains('assets/icon/splash_android12.png'));
      expect(
        config.toUpperCase(),
        contains(_hex(AppColors.surface.toARGB32()).substring(1)),
      );
    });

    test('Android 11 and older: the mark at every density', () {
      const sizes = {
        'mdpi': 128,
        'hdpi': 192,
        'xhdpi': 256,
        'xxhdpi': 384,
        'xxxhdpi': 512,
      };
      sizes.forEach((density, size) {
        final (w, h, _) = _png('$res/drawable-$density/splash.png');
        expect((w, h), (size, size), reason: density);
      });
      expect(
        _read('$res/drawable/launch_background.xml'),
        contains('@drawable/splash'),
      );
    });

    test(
      'Android 12+: the mark kept inside the circle the system masks to',
      () async {
        // The artwork must sit in the central circle of 2/3 of the 1152 px
        // canvas (radius 384): nothing opaque beyond it.
        final (w, h, _) = _png('assets/icon/splash_android12.png');
        expect((w, h), (1152, 1152));
        final codec = await ui.instantiateImageCodec(
          File('assets/icon/splash_android12.png').readAsBytesSync(),
        );
        final image = (await codec.getNextFrame()).image;
        final data = (await image.toByteData())!;
        var farthest = 0.0;
        for (var y = 0; y < 1152; y++) {
          for (var x = 0; x < 1152; x++) {
            if (data.getUint8((y * 1152 + x) * 4 + 3) > 10) {
              final d = math.sqrt(
                (x - 576) * (x - 576) + (y - 576) * (y - 576),
              );
              if (d > farthest) farthest = d;
            }
          }
        }
        expect(farthest, lessThanOrEqualTo(384));
        expect(farthest, greaterThan(200), reason: 'the mark is there');
        final (mw, mh, _) = _png('$res/drawable-mdpi/android12splash.png');
        expect((mw, mh), (288, 288));
      },
    );

    test('iOS: the launch image at 1x, 2x and 3x', () {
      expect(_png('$launch/LaunchImage.png').$1, 128);
      expect(_png('$launch/LaunchImage@2x.png').$1, 256);
      expect(_png('$launch/LaunchImage@3x.png').$1, 384);
    });
  });
}
