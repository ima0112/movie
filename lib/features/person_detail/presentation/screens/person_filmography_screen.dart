import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/domain/entities/person.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/person_filmography_section.dart';

/// Filmography (D3b) — pushed from D3's "View full filmography" card
/// (`docs/SCREENS.md` D3b).
///
/// Static: it renders the [PersonDetail] D3 already loaded, so there is no
/// Cubit and no network call here (CLAUDE.md rule 9 — nothing server-side
/// changes). The filter chips keep their own local selection state inside
/// [PersonFilmographySection], so picking one rebuilds only the list.
class PersonFilmographyScreen extends StatelessWidget {
  const PersonFilmographyScreen({super.key, required this.detail});

  final PersonDetail detail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(AppIcons.back, color: AppColors.ink),
          onPressed: () => context.pop(),
        ),
        title: Text(
          detail.person.name,
          style: AppTextStyles.h3,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: ListView(
          children: [
            PersonFilmographySection(
              credits: detail.credits,
              showTitle: false,
              onCreditTap: (credit) => context.pushMediaDetail(credit.item.key),
            ),
          ],
        ),
      ),
    );
  }
}
