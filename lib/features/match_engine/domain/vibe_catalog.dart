import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../../core/domain/entities/media_type.dart';
import 'vibe.dart';

/// The 16-vibe catalog — `docs/DECISIONS.md` section 5 ("Vibe
/// catalog"): "JSON file in assets/. 16 initial vibes, each with an
/// icon, name, and rule."
///
/// Loads and parses `assets/vibes.json` directly, per
/// `docs/STRUCTURE.md`'s own file tree ("`vibe_catalog.dart` loads
/// `assets/vibes.json`" — placed in `match_engine/domain/`, not
/// `data/`). That's a narrow, deliberate exception to CLAUDE.md rule
/// 1's usual "domain: no Flutter" for this one file: [rootBundle] here
/// reads a bundled config file, not anything UI/widget-related. The
/// actual parsing ([fromJson]/[fromJsonString]) stays plain
/// `dart:convert`, so it's independently testable without touching an
/// asset bundle at all.
class VibeCatalog {
  const VibeCatalog(this._vibes);

  final List<Vibe> _vibes;

  /// Reads and parses `assets/vibes.json` from the real asset bundle.
  static Future<VibeCatalog> loadFromAssets() async {
    final source = await rootBundle.loadString('assets/vibes.json');
    return VibeCatalog.fromJsonString(source);
  }

  factory VibeCatalog.fromJsonString(String source) =>
      VibeCatalog.fromJson(jsonDecode(source) as Map<String, dynamic>);

  factory VibeCatalog.fromJson(Map<String, dynamic> json) {
    final vibesJson = json['vibes'] as List;
    return VibeCatalog(
      vibesJson
          .map((v) => Vibe.fromJson(v as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  List<Vibe> all() => List.unmodifiable(_vibes);

  /// `null` if no vibe has this id.
  Vibe? byId(String id) {
    for (final vibe in _vibes) {
      if (vibe.id == id) return vibe;
    }
    return null;
  }

  /// Vibes with an actual rule for [type] — see
  /// `Vibe.isMeaningfulFor`'s own doc comment for why this isn't just
  /// "all 16, always".
  List<Vibe> availableFor(MediaType type) =>
      _vibes.where((v) => v.isMeaningfulFor(type)).toList(growable: false);
}
