import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/settings_row.dart';
import '../../domain/library_export.dart';
import 'confirm_deletion_dialog.dart';

/// C6's Data group — `docs/SCREENS.md` C6: "Export My List" (JSON → the
/// system share sheet); "Delete My List", "Delete My Tastes" in red →
/// I1 (the dialog states how many items it deletes). Talks to
/// [UserLibraryRepository]/[TasteProfileRepository] directly (CLAUDE.md
/// rule 10) — none of these three actions have state that outlives a
/// single tap, so there's no Cubit here at all.
class SettingsDataSection extends StatelessWidget {
  const SettingsDataSection({
    super.key,
    required this.userLibraryRepository,
    required this.tasteProfileRepository,
  });

  final UserLibraryRepository userLibraryRepository;
  final TasteProfileRepository tasteProfileRepository;

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: context.l10n.settingsDataHeader,
      children: [
        SettingsRow(
          label: context.l10n.settingsExportMyList,
          showChevron: false,
          onTap: () => _exportLibrary(context),
        ),
        SettingsRow(
          label: context.l10n.settingsDeleteMyListLabel,
          labelColor: AppColors.danger,
          showChevron: false,
          onTap: () => _deleteLibrary(context),
        ),
        SettingsRow(
          label: context.l10n.settingsDeleteMyTastesLabel,
          labelColor: AppColors.danger,
          showChevron: false,
          onTap: () => _deleteTastes(context),
        ),
      ],
    );
  }

  Future<void> _exportLibrary(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final result = await userLibraryRepository.all();
    if (result is! Success<List<UserMediaEntry>>) {
      AppSnackBar.showOn(messenger, l10n.settingsExportFailedSnackbar);
      return;
    }

    try {
      final json = libraryExportJson(result.value);
      final file = File('${Directory.systemTemp.path}/my_list_export.json')
        ..writeAsStringSync(json);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          fileNameOverrides: const ['my_list.json'],
        ),
      );
    } catch (_) {
      AppSnackBar.showOn(messenger, l10n.settingsExportFailedSnackbar);
    }
  }

  Future<void> _deleteLibrary(BuildContext context) async {
    final l10n = context.l10n;
    final result = await userLibraryRepository.all();
    final itemCount = result is Success<List<UserMediaEntry>>
        ? result.value.length
        : 0;

    if (!context.mounted) return;
    final confirmed = await showConfirmDeletionDialog(
      context,
      title: l10n.settingsDeleteListDialogTitle,
      body: l10n.settingsDeleteDialogBody(
        l10n.settingsDataDeleteItemCount(itemCount),
      ),
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final deleteResult = await userLibraryRepository.clearAll();
    AppSnackBar.showOn(
      messenger,
      deleteResult is Success<void>
          ? l10n.settingsMyListDeletedSnackbar
          : l10n.settingsDeleteMyListFailedSnackbar,
    );
  }

  Future<void> _deleteTastes(BuildContext context) async {
    final l10n = context.l10n;
    final profile = await tasteProfileRepository.watch().first;
    final itemCount = profile == null
        ? 0
        : profile.likedGenres.length +
              profile.vetoedGenres.length +
              profile.likedVibes.length;

    if (!context.mounted) return;
    final confirmed = await showConfirmDeletionDialog(
      context,
      title: l10n.settingsDeleteTastesDialogTitle,
      body: l10n.settingsDeleteDialogBody(
        l10n.settingsDataDeleteSelectionCount(itemCount),
      ),
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final deleteResult = await tasteProfileRepository.delete();
    AppSnackBar.showOn(
      messenger,
      deleteResult is Success<void>
          ? l10n.settingsMyTastesDeletedSnackbar
          : l10n.settingsDeleteMyTastesFailedSnackbar,
    );
  }
}
