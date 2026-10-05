import 'package:flutter/material.dart';
import 'package:movies/app/environments.dart';
import 'core/config/env.dart';

import 'app/app.dart';
import 'app/di.dart';

void main() {
  Env.validate();
  configureDependencies(Env.useFake ? fake.name : real.name);
  runApp(const PakoTvApp());
}
