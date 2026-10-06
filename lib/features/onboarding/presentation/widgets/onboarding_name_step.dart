import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/onboarding_cubit.dart';
import '../cubit/onboarding_state.dart';
import 'name_step.dart';

/// Binds [NameStep] (pure presentation) to `OnboardingCubit` — scoped to
/// exactly the 3 fields it reads (CLAUDE.md rule 9), so typing a color
/// pick doesn't also rebuild the welcome/genre steps sitting in the same
/// `switch` one level up.
class OnboardingNameStep extends StatelessWidget {
  const OnboardingNameStep({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OnboardingCubit>();
    return BlocSelector<OnboardingCubit, OnboardingState, (String, int?, bool)>(
      selector: (state) =>
          (state.displayName, state.initialColor, state.isNameValid),
      builder: (context, data) {
        final (name, initialColor, isValid) = data;
        return NameStep(
          name: name,
          initialColor: initialColor,
          isValid: isValid,
          onNameChanged: cubit.setDisplayName,
          onColorChanged: cubit.setInitialColor,
          onNext: cubit.next,
        );
      },
    );
  }
}
