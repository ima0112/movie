import 'package:flutter/material.dart';
import 'package:movies/app/environments.dart';
import 'core/config/env.dart';
import 'core/domain/repositories/onboarding_repository.dart';

import 'app/app.dart';
import 'app/di.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Env.validate();
  configureDependencies(Env.useFake ? fake.name : real.name);
  // Loaded before `runApp` so `OnboardingRepository.isCompleted` — a
  // synchronous value by design (see its own doc comment) — is already
  // accurate by the time the router's first redirect reads it.
  await getIt<OnboardingRepository>().load();
  runApp(const PakoTvApp());
}
