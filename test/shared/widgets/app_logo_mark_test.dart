import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/shared/widgets/app_logo_mark.dart';
import 'package:movies/shared/widgets/logo_mark_painter.dart';

final _svg = File('assets/icon/sources/pickme-glyph.svg').readAsStringSync();

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// The mark drawn at [size] and read back as pixels: (x, y) in the 160 box.
Future<Color Function(double, double)> _render(
  WidgetTester tester, {
  double size = 160,
}) async {
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: AppLogoMark(size: size),
        ),
      ),
    ),
  );
  late ByteData data;
  await tester.runAsync(() async {
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    data = (await image.toByteData())!;
  });
  final px = (size).round();
  return (x, y) {
    final i = (((y / 160 * px).round()) * px + (x / 160 * px).round()) * 4;
    return Color.fromARGB(
      data.getUint8(i + 3),
      data.getUint8(i),
      data.getUint8(i + 1),
      data.getUint8(i + 2),
    );
  };
}

void main() {
  group('it is the SVG\'s geometry and the app\'s colours', () {
    test('the sparkles are the SVG\'s path data', () {
      final fromSvg = RegExp(
        r'<path d="(M69 56[^"]*)" fill="#1A1204"',
      ).firstMatch(_svg)!.group(1)!;
      expect(LogoMarkPainter.sparklesPathData.replaceAll('\n', ' '), fromSvg);
    });

    test('the three cards: rectangle, radius, tilt and pivot', () {
      final rects = RegExp(
        r'<rect x="(\d+)" y="(\d+)" width="(\d+)" height="(\d+)" rx="(\d+)"',
      ).allMatches(_svg).toList();
      // The inner outline is the fourth rect.
      expect(rects, hasLength(4));
      for (var i = 0; i < 3; i++) {
        final m = rects[i];
        final card = LogoMarkPainter.cards[i];
        expect(card.rect.left, double.parse(m.group(1)!));
        expect(card.rect.top, double.parse(m.group(2)!));
        expect(card.rect.width, double.parse(m.group(3)!));
        expect(card.rect.height, double.parse(m.group(4)!));
        expect(card.radius, double.parse(m.group(5)!));
      }
      final inner = rects[3];
      expect(LogoMarkPainter.innerRect.left, double.parse(inner.group(1)!));
      expect(LogoMarkPainter.innerRect.top, double.parse(inner.group(2)!));
      expect(LogoMarkPainter.innerRect.width, double.parse(inner.group(3)!));
      expect(LogoMarkPainter.innerRect.height, double.parse(inner.group(4)!));
      expect(LogoMarkPainter.innerRadius, double.parse(inner.group(5)!));

      final rotations = RegExp(
        r'rotate\((-?\d+) (\d+) (\d+)\)',
      ).allMatches(_svg).toList();
      expect(rotations, hasLength(2));
      for (var i = 0; i < 2; i++) {
        expect(
          LogoMarkPainter.cards[i].degrees,
          double.parse(rotations[i].group(1)!),
        );
        expect(
          LogoMarkPainter.cards[i].pivot,
          Offset(
            double.parse(rotations[i].group(2)!),
            double.parse(rotations[i].group(3)!),
          ),
        );
      }
    });

    test('every gradient stop and the sparkles are AppColors tokens', () {
      final stops = RegExp(
        r'stop-color="(#[0-9A-Fa-f]{6})"',
      ).allMatches(_svg).map((m) => m.group(1)!.toUpperCase()).toSet();
      final tokens = {
        _hex(AppColors.logoAmberLight),
        _hex(AppColors.accent),
        _hex(AppColors.logoAmberDark),
        _hex(AppColors.logoVioletLight),
        _hex(AppColors.logoVioletDark),
        _hex(AppColors.logoTealLight),
        _hex(AppColors.logoTealDark),
        '#FFFFFF', // the gloss: AppColors.ink at its alpha
      };
      expect(stops, tokens);
      expect(_svg.toUpperCase(), contains(_hex(AppColors.onAccent)));
    });

    test('the data parser reads M, Q and Z', () {
      final path = LogoMarkPainter.pathFromData(
        LogoMarkPainter.sparklesPathData,
      );
      final bounds = path.getBounds();
      expect(bounds.left, closeTo(42, 0.01));
      expect(bounds.right, closeTo(115, 0.01));
      expect(bounds.top, closeTo(46, 0.01));
      expect(bounds.bottom, closeTo(113, 0.01));
    });
  });

  group('AppLogoMark', () {
    testWidgets('it is a square of the size it is given, hidden from screen '
        'readers', (tester) async {
      await tester.pumpWidget(
        const Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: AppLogoMark(size: 96)),
        ),
      );
      expect(tester.getSize(find.byType(AppLogoMark)), const Size(96, 96));
      expect(find.byType(ExcludeSemantics), findsWidgets);
      expect(AppLogoMark.defaultSize, 110);
    });

    testWidgets('drawn: amber card in front, violet and teal behind, dark '
        'sparkles, nothing in the corners', (tester) async {
      final at = await _render(tester, size: 320);

      expect(at(2, 2).a, 0, reason: 'transparent corner');
      expect(at(158, 158).a, 0);
      // The front card is amber, the sparkle over it is the dark on-accent.
      final card = at(60, 100);
      expect(card.r, greaterThan(0.85));
      expect(card.g, greaterThan(0.55));
      expect(card.b, lessThan(0.45));
      final sparkle = at(69, 83); // the big sparkle's heart
      expect(sparkle.r, lessThan(0.2));
      expect(sparkle.g, lessThan(0.15));
      // Left behind: violet (red and blue above green); right: teal.
      final violet = at(34, 100);
      expect(violet.a, greaterThan(0.5));
      expect(violet.b, greaterThan(violet.g));
      final teal = at(126, 90);
      expect(teal.a, greaterThan(0.5));
      expect(teal.g, greaterThan(teal.r));
    });

    testWidgets('it scales: the same drawing at half the size', (tester) async {
      final small = await _render(tester, size: 80);
      expect(small(60, 100).g, greaterThan(0.55)); // still amber
      expect(small(2, 2).a, 0);
    });
  });
}
