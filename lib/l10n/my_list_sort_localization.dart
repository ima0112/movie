import '../features/my_list/presentation/cubit/my_list_cubit.dart';
import 'app_localizations.dart';

/// The single mapper from [MyListSort] to its chip label — CLAUDE.md
/// rule 15. [MyListSort.year] reuses `filterSheetSectionYear` rather
/// than its own key — same word in both places.
extension MyListSortLocalization on MyListSort {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MyListSort.recent => l10n.myListSortRecent,
    MyListSort.titleAZ => l10n.myListSortTitleAz,
    MyListSort.year => l10n.filterSheetSectionYear,
    MyListSort.tmdbRating => l10n.myListSortTmdbRating,
    MyListSort.myRating => l10n.myListSortMyRating,
    MyListSort.dateWatched => l10n.myListSortDateWatched,
  };
}
