import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/cubits/taste_profile_cubit.dart';

/// The TMDB provider ids of the streaming services the user keeps in My Tastes
/// (an empty set with no taste profile, or where the global cubit isn't
/// provided) — what the platform lists put first.
Set<int> preferredPlatformIds(BuildContext context) {
  try {
    return context.read<TasteProfileCubit>().state?.platformIds ?? const {};
  } catch (_) {
    return const {};
  }
}
