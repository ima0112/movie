import 'package:flutter/material.dart';

import '../../core/domain/entities/media_type.dart';
import '../../core/domain/entities/result.dart';
import '../../core/domain/entities/streaming_service.dart';
import '../../core/domain/repositories/media_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../l10n/l10n_extension.dart';
import 'app_chip.dart';
import 'filter_section_header.dart';
import 'state_views.dart';
import 'streaming_service_logo.dart';

/// H8's "Streaming on" row: the streaming services of the user's region (most
/// relevant first), each a chip with its logo, **single select** — tapping the
/// picked one again clears it. The region's name sits at the right of the
/// label. A skeleton while the services load, and the whole block is left out
/// when they fail or the region has none (a filter that can't be used isn't
/// worth a row of its own).
///
/// Loads once, for [type] (the sheet's segment, which it doesn't change).
class FilterPlatformChips extends StatefulWidget {
  const FilterPlatformChips({
    super.key,
    required this.mediaRepository,
    required this.type,
    required this.regionName,
    required this.selectedId,
    required this.onChanged,
  });

  final MediaRepository mediaRepository;
  final MediaType? type;
  final String regionName;

  /// The picked service's TMDB provider id, or `null`.
  final int? selectedId;
  final ValueChanged<int?> onChanged;

  @override
  State<FilterPlatformChips> createState() => _FilterPlatformChipsState();
}

class _FilterPlatformChipsState extends State<FilterPlatformChips> {
  late final Future<Result<List<StreamingService>>> _services = widget
      .mediaRepository
      .streamingServices(type: widget.type);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<StreamingService>>>(
      future: _services,
      builder: (context, snapshot) {
        final result = snapshot.data;
        final services = switch (result) {
          Success<List<StreamingService>>(:final value) => value,
          _ => null,
        };
        final loading = result == null;
        if (!loading && (services == null || services.isEmpty)) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sectionGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilterSectionHeader(
                context.l10n.filterSheetSectionStreaming,
                trailing: Text(
                  widget.regionName,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
              if (loading)
                const SkeletonBlock(width: double.infinity, height: _rowHeight)
              else
                SizedBox(
                  height: _rowHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: services!.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final service = services[index];
                      final selected = service.id == widget.selectedId;
                      return Center(
                        child: AppChip(
                          label: service.name,
                          state: selected
                              ? ChipState.selected
                              : ChipState.normal,
                          leading: StreamingServiceLogo(
                            service: service,
                            size: AppSpacing.xl,
                          ),
                          onTap: () =>
                              widget.onChanged(selected ? null : service.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static const double _rowHeight = 40;
}
