import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movies/app/cubits/connectivity_cubit.dart';
import 'package:movies/app/widgets/offline_banner_slot.dart';
import 'package:movies/core/network/network_status.dart';
import 'package:movies/core/theme/app_colors.dart';
import 'package:movies/core/theme/app_icons.dart';
import 'package:movies/l10n/app_localizations.dart';
import 'package:movies/shared/widgets/offline_banner.dart';

Widget _host(NetworkStatus status, {Locale? locale}) => MaterialApp(
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BlocProvider(
    create: (_) => ConnectivityCubit(status),
    child: const Scaffold(body: Column(children: [OfflineBannerSlot()])),
  ),
);

void main() {
  testWidgets('nothing while online; the amber banner while offline; gone '
      'again when a request gets through', (tester) async {
    final status = NetworkStatus();
    await tester.pumpWidget(_host(status));
    expect(find.byType(OfflineBanner), findsNothing);
    expect(tester.getSize(find.byType(OfflineBannerSlot)).height, 0);

    status.reportUnreachable();
    await tester.pumpAndSettle();
    expect(find.text('No internet connection'), findsOneWidget);
    expect(find.byIcon(AppIcons.wifiOff), findsOneWidget);
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(OfflineBanner),
        matching: find.byType(Container),
      ),
    );
    expect((box.decoration! as BoxDecoration).color, AppColors.accentSoft);

    status.reportReachable();
    await tester.pumpAndSettle();
    expect(find.byType(OfflineBanner), findsNothing);
  });

  testWidgets('the Spanish message', (tester) async {
    await tester.pumpWidget(
      _host(NetworkStatus()..reportUnreachable(), locale: const Locale('es')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin conexión a internet'), findsOneWidget);
  });
}
