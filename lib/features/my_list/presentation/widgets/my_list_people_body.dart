import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/domain/repositories/saved_people_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_tab_bar.dart';
import '../../../../shared/widgets/clear_of_tab_bar.dart';
import '../../../../shared/widgets/person_result_row.dart';
import '../../../../shared/widgets/state_views.dart';

/// My List's People tab (`docs/SCREENS.md` B4): the people saved from D3, by
/// name A–Z. Subscribes to [SavedPeopleRepository.watchAll] directly (CLAUDE.md
/// rule 10). Tap → D3; swipe left → remove, with an "Undo" snackbar like the
/// other tabs.
class MyListPeopleBody extends StatelessWidget {
  const MyListPeopleBody({super.key, required this.savedPeopleRepository});

  final SavedPeopleRepository savedPeopleRepository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Person>>(
      stream: savedPeopleRepository.watchAll(),
      builder: (context, snapshot) {
        final people = snapshot.data;
        if (people == null) return const SizedBox.shrink();
        if (people.isEmpty) {
          final l10n = context.l10n;
          return ClearOfTabBar(
            child: EmptyStateView(
              icon: AppIcons.user,
              title: l10n.myListEmptyPeopleHeadline,
              body: l10n.myListEmptyPeopleBody,
              ctaLabel: l10n.navTabExplore,
              onCtaTap: () => context.go('/explore'),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screenMargin,
            0,
            AppSpacing.screenMargin,
            AppTabBar.scrollInset(context),
          ),
          itemCount: people.length,
          itemBuilder: (context, index) => _SwipeablePerson(
            key: ValueKey(people[index].id),
            person: people[index],
            repository: savedPeopleRepository,
          ),
        );
      },
    );
  }
}

class _SwipeablePerson extends StatelessWidget {
  const _SwipeablePerson({
    super.key,
    required this.person,
    required this.repository,
  });

  final Person person;
  final SavedPeopleRepository repository;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('dismiss-${person.id}'),
      direction: DismissDirection.endToStart,
      background: const ColoredBox(color: AppColors.danger),
      confirmDismiss: (_) async {
        _remove(context);
        // The list rebuilds from the repository; the row never removes itself.
        return false;
      },
      child: PersonResultRow(
        person: person,
        onTap: () => context.pushPersonDetail(person.id),
      ),
    );
  }

  void _remove(BuildContext context) {
    final l10n = context.l10n;
    unawaited(repository.remove(person.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.myListRemovedFromTab(l10n.myListTabPeople)),
        action: SnackBarAction(
          label: l10n.myListUndoAction,
          onPressed: () => unawaited(repository.save(person)),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
