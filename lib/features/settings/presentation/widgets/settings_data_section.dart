import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/entities/user_media_entry.dart';
import '../../../../core/domain/repositories/taste_profile_repository.dart';
import '../../../../core/domain/repositories/user_library_repository.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Column(
      children: [
        const SettingsGroupHeader(title: 'Data'),
        SettingsRow(
          label: 'Export My List',
          showChevron: false,
          onTap: () => _exportLibrary(context),
        ),
        SettingsRow(
          label: 'Delete My List',
          labelColor: AppColors.danger,
          showChevron: false,
          onTap: () => _deleteLibrary(context),
        ),
        SettingsRow(
          label: 'Delete My Tastes',
          labelColor: AppColors.danger,
          showChevron: false,
          onTap: () => _deleteTastes(context),
        ),
      ],
    );
  }

  Future<void> _exportLibrary(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await userLibraryRepository.all();
    if (result is! Success<List<UserMediaEntry>>) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't export My List")),
      );
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
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't export My List")),
      );
    }
  }

  Future<void> _deleteLibrary(BuildContext context) async {
    final result = await userLibraryRepository.all();
    final itemCount = result is Success<List<UserMediaEntry>>
        ? result.value.length
        : 0;

    if (!context.mounted) return;
    final confirmed = await showConfirmDeletionDialog(
      context,
      subject: 'list',
      itemCount: itemCount,
      itemNoun: 'item',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final deleteResult = await userLibraryRepository.clearAll();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleteResult is Success<void>
              ? 'My List deleted'
              : "Couldn't delete My List",
        ),
      ),
    );
  }

  Future<void> _deleteTastes(BuildContext context) async {
    final profile = await tasteProfileRepository.watch().first;
    final itemCount = profile == null
        ? 0
        : profile.likedGenres.length +
              profile.vetoedGenres.length +
              profile.likedVibes.length;

    if (!context.mounted) return;
    final confirmed = await showConfirmDeletionDialog(
      context,
      subject: 'tastes',
      itemCount: itemCount,
      itemNoun: 'selection',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final deleteResult = await tasteProfileRepository.delete();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          deleteResult is Success<void>
              ? 'My Tastes deleted'
              : "Couldn't delete My Tastes",
        ),
      ),
    );
  }
}
