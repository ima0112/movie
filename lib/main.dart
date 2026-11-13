import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:movies/app/environments.dart';
import 'core/config/env.dart';

import 'app/app_preload.dart';
import 'app/di.dart';
import 'app/splash_gate.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keeps the native splash (flutter_native_splash.yaml: just the page's dark
  // color, no logo) on screen past Flutter's own first frame — SplashGate calls
  // .remove() once its own first frame (A1's in-app splash, the only one the
  // user sees) is ready to take over, so there's no blank gap between the two.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  Env.validate();
  configureDependencies(Env.useFake ? fake.name : real.name);
  // Starts A1's preload now, while the system still shows the native splash,
  // instead of waiting for the in-app splash to mount.
  final preload = preloadApp();
  runApp(SplashGate(preload: preload));
}
