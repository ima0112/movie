import 'package:flutter/widgets.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Icon tokens for PakoTV.
///
/// Source of truth: `docs/DESIGN_SYSTEM.md`, section 4 ("Iconografía").
/// Every icon comes from `phosphor_flutter`, `regular` weight by default
/// and `fill` for active states — never mix with Material's `Icons.*` or
/// `CupertinoIcons.*`. Pako's icon (the Match FAB) is a custom SVG, not
/// Phosphor, so it is not part of this class (see `docs/DECISIONS.md`
/// section 9).
class AppIcons {
  const AppIcons._();

  static const IconData search = PhosphorIconsRegular.magnifyingGlass;
  static const IconData filter = PhosphorIconsRegular.slidersHorizontal;

  static const IconData favorite = PhosphorIconsRegular.heart;
  static const IconData favoriteFill = PhosphorIconsFill.heart;

  static const IconData watchLater = PhosphorIconsRegular.bookmarkSimple;
  static const IconData watchLaterFill = PhosphorIconsFill.bookmarkSimple;

  static const IconData watched = PhosphorIconsRegular.eye;
  static const IconData watchedFill = PhosphorIconsFill.eye;

  static const IconData play = PhosphorIconsRegular.play;
  static const IconData share = PhosphorIconsRegular.shareNetwork;
  static const IconData back = PhosphorIconsRegular.arrowLeft;
  static const IconData close = PhosphorIconsRegular.x;
  static const IconData home = PhosphorIconsRegular.house;
  static const IconData homeFill = PhosphorIconsFill.house;

  static const IconData compass = PhosphorIconsRegular.compass;
  static const IconData compassFill = PhosphorIconsFill.compass;

  static const IconData list = PhosphorIconsRegular.listBullets;
  static const IconData listFill = PhosphorIconsFill.listBullets;

  static const IconData user = PhosphorIconsRegular.user;
  static const IconData userFill = PhosphorIconsFill.user;
  static const IconData settings = PhosphorIconsRegular.gear;
  static const IconData stats = PhosphorIconsRegular.chartBar;
  static const IconData qrCode = PhosphorIconsRegular.qrCode;
  static const IconData copy = PhosphorIconsRegular.copy;
  static const IconData retry = PhosphorIconsRegular.arrowClockwise;
  static const IconData check = PhosphorIconsRegular.check;
  static const IconData chevronRight = PhosphorIconsRegular.caretRight;
  static const IconData chevronDown = PhosphorIconsRegular.caretDown;
  static const IconData info = PhosphorIconsRegular.info;
  static const IconData hourglass = PhosphorIconsRegular.hourglassMedium;
  static const IconData group = PhosphorIconsRegular.usersThree;
  static const IconData dice = PhosphorIconsRegular.diceFive;
  static const IconData useMyTastes = PhosphorIconsRegular.userCirclePlus;

  static const IconData star = PhosphorIconsRegular.star;
  static const IconData starFill = PhosphorIconsFill.star;
}
