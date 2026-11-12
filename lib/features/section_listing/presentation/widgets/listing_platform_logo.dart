import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/media_key.dart';
import '../../../../core/domain/entities/streaming_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/streaming_service_logo.dart';
import '../cubit/listing_providers_cubit.dart';

/// The platform a title streams on, as a small logo in a poster's **top-right**
/// corner — the one corner no other dressing of the grid ever uses (the "TV"
/// tag and the rating badge take the top-left; the rank, the date and the year
/// the bottom-left; the title the foot). Shown only when the listing isn't
/// narrowed to a platform; the most relevant subscription service wins when a
/// title is on several. Nothing at all when it has none, or until it is known.
///
/// Asks for its title's providers once, when first built; watches only its own
/// entry (CLAUDE.md rule 9).
class ListingPlatformLogo extends StatefulWidget {
  const ListingPlatformLogo({super.key, required this.titleKey});

  final MediaKey titleKey;

  static const double size = 22;

  @override
  State<ListingPlatformLogo> createState() => _ListingPlatformLogoState();
}

class _ListingPlatformLogoState extends State<ListingPlatformLogo> {
  @override
  void initState() {
    super.initState();
    // Not during build: the cubit emits when the answer arrives.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ListingProvidersCubit>().request(widget.titleKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      ListingProvidersCubit,
      Map<MediaKey, List<StreamingService>>,
      StreamingService?
    >(
      selector: (state) => state[widget.titleKey]?.firstOrNull,
      builder: (context, service) {
        if (service == null) return const SizedBox.shrink();
        return Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xs),
            child: Semantics(
              label: service.name,
              image: true,
              excludeSemantics: true,
              child: DecoratedBox(
                // A hairline ring so the logo reads on any artwork.
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.surface),
                ),
                child: StreamingServiceLogo(
                  service: service,
                  size: ListingPlatformLogo.size,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
