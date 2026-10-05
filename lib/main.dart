import 'package:flutter/material.dart';
import 'core/config/env.dart';

import 'app/app.dart';
import 'app/di.dart';

void main() {
  Env.validate();
  configureDependencies();
  runApp(const PakoTvApp());
}
