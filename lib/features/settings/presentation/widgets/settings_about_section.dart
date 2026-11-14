import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../core/launch/launch_external_link.dart';
import '../../../../l10n/l10n_extension.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/settings_row.dart';

/// C6's About group — `docs/SCREENS.md` C6: "Version (long-press copies
/// the build number), Source code (GitHub, external link), Licenses
/// (`showLicensePage`)". The TMDB attribution block (same row) isn't
/// built here — there's no logo asset for it yet.
class SettingsAboutSection extends StatefulWidget {
  const SettingsAboutSection({super.key});

  @override
  State<SettingsAboutSection> createState() => _SettingsAboutSectionState();
}

class _SettingsAboutSectionState extends State<SettingsAboutSection> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  static const _sourceCodeUrl = 'https://github.com/ima0112/movie';

  void _copyBuildNumber(String buildNumber) {
    unawaited(Clipboard.setData(ClipboardData(text: buildNumber)));
    AppSnackBar.show(context, context.l10n.settingsBuildNumberCopiedSnackbar);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsGroup(
      title: l10n.settingsAboutHeader,
      children: [
        SettingsRow(
          label: l10n.settingsAttributionLabel,
          onTap: () => context.push(AppRoutes.attribution),
        ),
        FutureBuilder<PackageInfo>(
          future: _packageInfo,
          builder: (context, snapshot) {
            final info = snapshot.data;
            return SettingsRow(
              label: l10n.settingsVersionLabel,
              value: info == null
                  ? null
                  : l10n.settingsAboutVersion(info.version, info.buildNumber),
              showChevron: false,
              onLongPress: info == null
                  ? null
                  : () => _copyBuildNumber(info.buildNumber),
            );
          },
        ),
        SettingsRow(
          label: l10n.settingsSourceCodeLabel,
          onTap: () => unawaited(launchExternalLink(context, _sourceCodeUrl)),
        ),
        SettingsRow(
          label: l10n.settingsLicensesLabel,
          onTap: () =>
              showLicensePage(context: context, applicationName: 'PakoTV'),
        ),
      ],
    );
  }
}
