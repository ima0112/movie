import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../scrim_back_button.dart';
import '../scrim_share_button.dart';
import 'media_detail_compact_bar.dart';

/// The top controls of D1/D2/D3, pinned over the scrolling page (they are
/// siblings of the scroll view in the screen's `Stack`, not part of the
/// header that scrolls away — otherwise a half-scrolled header carries them
/// up under the status bar, where they can't be tapped).
///
/// At rest, and while the header is still on screen, they are the same
/// translucent back (and share) circles over the image; once [showCompact]
/// flips (the title has scrolled past the top) the circles give way to the
/// compact bar with back, the title and share. Nothing is drawn until [title]
/// is known (skeleton / error states bring their own back button).
class DetailTopControls extends StatelessWidget {
  const DetailTopControls({
    super.key,
    required this.showCompact,
    required this.title,
    this.onShare,
  });

  final ValueListenable<bool> showCompact;

  /// `null` while nothing is loaded.
  final String? title;

  /// `null` for screens with nothing to share (D3).
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    if (title == null) return const SizedBox.shrink();
    return ValueListenableBuilder<bool>(
      valueListenable: showCompact,
      builder: (context, compact, _) {
        if (compact) {
          return MediaDetailCompactBar(title: title, onShare: onShare);
        }
        return Stack(
          children: [
            const ScrimBackButton(),
            if (onShare != null) ScrimShareButton(onTap: onShare!),
          ],
        );
      },
    );
  }
}
