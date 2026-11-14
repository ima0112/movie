import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/entities/result.dart';
import '../../../../core/domain/repositories/saved_people_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/scrim_icon_button.dart';

/// D3's heart: saves the person to My List's People tab, or forgets them.
///
/// It subscribes to just "is this person saved?"
/// ([SavedPeopleRepository.watchIsSaved]) and rebuilds only itself when that
/// flips (CLAUDE.md rules 9 and 10); the stream is created once. [compact]
/// draws it for the compact bar (an [IconButton]) instead of the circle over
/// the header.
class SavePersonButton extends StatefulWidget {
  const SavePersonButton({
    super.key,
    required this.person,
    required this.repository,
    required this.compact,
  });

  final Person person;
  final SavedPeopleRepository repository;
  final bool compact;

  @override
  State<SavePersonButton> createState() => _SavePersonButtonState();
}

class _SavePersonButtonState extends State<SavePersonButton> {
  late final Stream<bool> _saved = widget.repository.watchIsSaved(
    widget.person.id,
  );

  Future<void> _toggle(bool saved) async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = context.l10n.failureStorage;
    final result = saved
        ? await widget.repository.remove(widget.person.id)
        : await widget.repository.save(widget.person);
    // No confirmation snackbar for the heart (its icon is the feedback), but a
    // write that failed must not be silent.
    if (result is Failure<void>) AppSnackBar.showOn(messenger, failure);
  }

  @override
  Widget build(BuildContext context) {
    final label = context.l10n.personDetailSave;
    return StreamBuilder<bool>(
      stream: _saved,
      initialData: false,
      builder: (context, snapshot) {
        final saved = snapshot.data ?? false;
        final icon = saved ? AppIcons.favoriteFill : AppIcons.favorite;
        if (widget.compact) {
          return IconButton(
            onPressed: () => unawaited(_toggle(saved)),
            tooltip: label,
            isSelected: saved,
            icon: Icon(icon, color: saved ? AppColors.accent : AppColors.ink),
          );
        }
        return ScrimIconButton(
          icon: icon,
          label: label,
          selected: saved,
          onTap: () => unawaited(_toggle(saved)),
        );
      },
    );
  }
}
