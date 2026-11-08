import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CLAUDE.md rule 15's own rule ("All text visible or accessible to
/// the user comes from `AppLocalizations`"), automated: walks
/// `lib/features/*/presentation` and `lib/shared` and fails if any
/// still holds a literal, real-word string in one of the parameter
/// shapes below — `Text('...')`, `label: '...'`, `title: '...'`, etc.
///
/// This is a guardrail against regressions after the app-wide .arb
/// migration, not a full linter: it reads line by line (a literal
/// wrapped onto its own line is invisible to it), can't resolve what a
/// named constant actually holds, and only recognizes a short, fixed
/// list of parameter names. That is a deliberate trade-off — a narrow
/// check with close to zero false positives beats a broad one the next
/// branch has to keep silencing.
///
/// A literal that genuinely isn't user-facing text opts out with a
/// trailing `// l10n-exempt: <reason>` comment on the same line. Three
/// categories are expected to ever need it:
/// - TMDB's own required attribution text (rule 15's documented
///   exception) — not written anywhere yet (C6's About section has no
///   TMDB row — see `settings_about_section.dart`'s own doc comment),
///   so there's no live example to point at, only the convention
///   that'll apply once it's added.
/// - A brand name ("PakoTV"/"Pako"/"TMDB" — CLAUDE.md: never translate
///   these). `app_wordmark.dart`'s two `TextSpan.text` literals are the
///   one real example today.
/// - Debug-only output never shown to a real user. In practice this
///   never needs the comment: `lib/features/debug/` (the design-system
///   preview screen) is excluded wholesale below, and genuine
///   debug/export strings — `debugPrint`, a `toString()` override, an
///   `assert` message, a share sheet's `mimeType`/`fileNameOverrides`,
///   an exported JSON's own field keys — are never passed through any
///   of the parameter names this check looks for, so they're exempt by
///   construction, not by listing them here.
void main() {
  test('lib/features/*/presentation and lib/shared have no hardcoded '
      'display-text literals outside an `// l10n-exempt:` comment', () {
    final violations = <String>[];

    for (final file in _filesToScan()) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (line.contains('// l10n-exempt:')) continue;

        for (final match in _displayParamPattern.allMatches(line)) {
          final literal = match.group(2)!;
          if (_looksLikeRealWords(literal)) {
            violations.add(
              "${file.path}:${i + 1}: '$literal' — route it through "
              'AppLocalizations (context.l10n.<key>), or add a trailing '
              "'// l10n-exempt: <reason>' comment if it genuinely isn't "
              'user-facing text.',
            );
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

/// `lib/features/debug/` (the design-system preview screen) is
/// developer-only tooling, never shown to a real user — rule 15's
/// "user-facing text" doesn't apply to it, so it's excluded wholesale
/// rather than littered with exemption comments.
Iterable<File> _filesToScan() {
  final files = <File>[];

  final featuresRoot = Directory('lib/features');
  if (featuresRoot.existsSync()) {
    for (final feature in featuresRoot.listSync()) {
      if (feature is! Directory) continue;
      if (feature.path.replaceAll('\\', '/').endsWith('/debug')) continue;

      final presentation = Directory('${feature.path}/presentation');
      if (!presentation.existsSync()) continue;
      files.addAll(
        presentation
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart')),
      );
    }
  }

  final shared = Directory('lib/shared');
  if (shared.existsSync()) {
    files.addAll(
      shared
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart')),
    );
  }

  return files;
}

/// The short list of display-text shapes this guardrail understands —
/// every one of them has, at some point in this app's real migration
/// history, held a literal that needed moving to .arb. Matches a
/// quoted literal immediately after `Text(` or one of these named
/// parameters; the second capture group is the literal's raw content.
final RegExp _displayParamPattern = RegExp(
  r"(?:\bText\(\s*|\b(?:label|title|body|subtitle|headline|text|hintText|"
  r"labelText|errorText|tooltip|message|semanticLabel|semanticsLabel|"
  r"value):\s*)(['\x22])((?:\\.|(?!\1).)*)\1",
);

final RegExp _interpolation = RegExp(r'\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*');

/// True once string interpolation is stripped out and at least one
/// letter remains — enough to tell `'Save'`/`"Couldn't load"` apart
/// from pure data formatting like `'$clamped'` or `'+$overflow'`.
bool _looksLikeRealWords(String literal) {
  final withoutInterpolation = literal.replaceAll(_interpolation, '');
  return RegExp('[A-Za-z]').hasMatch(withoutInterpolation);
}
