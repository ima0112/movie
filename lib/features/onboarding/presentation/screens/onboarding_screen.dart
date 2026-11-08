import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubits/taste_profile_cubit.dart';
import '../../../../app/cubits/user_profile_cubit.dart';
import '../../../../app/di.dart';
import '../../../../core/domain/repositories/onboarding_repository.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_flow.dart';

/// A2 (Onboarding) — implements `docs/SCREENS.md` A2.
///
/// Thin per CLAUDE.md rule 11: provides the screen-local
/// `OnboardingCubit` (rule 10 — its draft never outlives this screen)
/// and delegates everything else to [OnboardingFlow]. Reads the two
/// *global* Cubits via `context.read` the same way `EditProfileSheet`
/// already does, and [OnboardingRepository] via `getIt` like every
/// other repository/service this app resolves.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnboardingCubit(
        context.read<UserProfileCubit>(),
        context.read<TasteProfileCubit>(),
        getIt<OnboardingRepository>(),
      ),
      child: const OnboardingFlow(),
    );
  }
}
