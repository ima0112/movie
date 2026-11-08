import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:movies/app/environments.dart';
import 'core/config/env.dart';

import 'app/di.dart';
import 'app/splash_gate.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  // Keeps the native splash (flutter_native_splash.yaml) on screen past
  // Flutter's own first frame — SplashGate calls .remove() once its own
  // first frame (A1's in-app splash) is ready to take over, so there's
  // no blank gap between the two.
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  Env.validate();
  configureDependencies(Env.useFake ? fake.name : real.name);
  runApp(const SplashGate());
}
