/// The local user's own profile — display name and avatar color, nothing
/// else (no age or gender: `docs/DECISIONS.md` section 4/F9 — minor
/// protection is handled by the stores' own 12+/Teen rating instead; see
/// `docs/decisions/family-mode-not-in-v1.md` for why an in-app content
/// filter was dropped rather than built partially).
///
/// Shape fixed by `docs/DECISIONS.md` section 7: `UserProfile
/// { displayName, initialColor }`. Set once during onboarding (F9,
/// "What's your name?"), editable later from B5 ("You") via H10.
///
/// [UserProfileRepository.watch] returning `null` (no row saved yet) is
/// what B5 reads as "no name: Pako's silhouette... 'Tap to set your
/// name'" — this class itself always has both fields set, since H10's
/// "Name and initial color" sheet asks for both together.
class UserProfile {
  const UserProfile({required this.displayName, required this.initialColor});

  final String displayName;

  /// One of H10's 4 preset avatar colors ("Name and initial color (4)"),
  /// as a 32-bit ARGB value — the same shape `Color.value` uses, so the
  /// presentation layer can wrap it straight into a `Color` without a
  /// lookup table. Stored as an int (not a `Color`) because `domain`
  /// never imports Flutter (CLAUDE.md rule 1); which 4 values are valid
  /// is a presentation-layer (H10) concern, not this entity's.
  final int initialColor;

  @override
  bool operator ==(Object other) =>
      other is UserProfile &&
      other.displayName == displayName &&
      other.initialColor == initialColor;

  @override
  int get hashCode => Object.hash(displayName, initialColor);

  @override
  String toString() => 'UserProfile($displayName, color: $initialColor)';
}
