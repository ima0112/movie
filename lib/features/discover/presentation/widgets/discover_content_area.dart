import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_segment.dart';
import '../bloc/discover_cubit.dart';
import 'discover_content_error.dart';
import 'discover_content_loaded.dart';
import 'discover_content_skeleton.dart';

/// The only `BlocBuilder` on this screen scoped to "is Discover loading,
/// errored, or loaded" — everything above it (halo, top bar, segmented
/// control) and below it (bottom bar) is untouched by this (CLAUDE.md
/// rule 9).
class DiscoverContentArea extends StatelessWidget {
  const DiscoverContentArea({super.key, required this.segment});

  final MediaSegment segment;

  /// A state is only relevant to this widget if it's [DiscoverInitial]
  /// (nothing has loaded for *any* segment yet) or it's about the
  /// currently-selected [segment] specifically. This is what lets
  /// `buildWhen` ignore a stale in-flight request for a segment the user
  /// has since switched away from.
  bool _isRelevant(DiscoverState state) => switch (state) {
    DiscoverInitial() => true,
    DiscoverLoading(:final segment) => segment == this.segment,
    DiscoverLoaded(:final segment) => segment == this.segment,
    DiscoverError(:final segment) => segment == this.segment,
  };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverCubit, DiscoverState>(
      buildWhen: (previous, current) => _isRelevant(current),
      builder: (context, state) {
        if (!_isRelevant(state)) {
          return DiscoverContentSkeleton(segment: segment);
        }
        return switch (state) {
          DiscoverInitial() => DiscoverContentSkeleton(segment: segment),
          DiscoverLoading() => DiscoverContentSkeleton(segment: segment),
          DiscoverError() => DiscoverContentError(
            onRetry: () => context.read<DiscoverCubit>().loadDiscover(segment),
          ),
          DiscoverLoaded() => DiscoverContentLoaded(segment: segment),
        };
      },
    );
  }
}
