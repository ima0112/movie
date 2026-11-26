import 'package:flutter/widgets.dart';

import 'app_network_image.dart';
import 'image_use.dart';

/// Warms the posters a horizontal list is about to scroll to.
///
/// A carousel builds only the cards on screen (and a little beyond): the next
/// ones start loading when they scroll in, and show as a flat tile until then.
/// This loads a few of them ahead — [take] posters after the first [skip] — into
/// the image cache, with the same URL and width the cards will use
/// (`AppNetworkImage.precache`), so the first flick of the finger shows posters.
/// It lays nothing out of its own: it just returns [child].
class PosterPrecache extends StatefulWidget {
  const PosterPrecache({
    super.key,
    required this.urls,
    required this.logicalWidth,
    required this.child,
    this.use = ImageUse.poster,
    this.skip = 5,
    this.take = 4,
  });

  /// The posters of the whole list, in order (`null` for an item with none).
  final List<String?> urls;

  /// The width each card is drawn at.
  final double logicalWidth;
  final ImageUse use;

  /// How many cards are already on screen, so not worth warming.
  final int skip;

  /// How many to warm after them.
  final int take;
  final Widget child;

  @override
  State<PosterPrecache> createState() => _PosterPrecacheState();
}

class _PosterPrecacheState extends State<PosterPrecache> {
  Iterable<String> _ahead(List<String?> urls) =>
      urls.skip(widget.skip).take(widget.take).whereType<String>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _warm(_ahead(widget.urls));
  }

  @override
  void didUpdateWidget(PosterPrecache oldWidget) {
    super.didUpdateWidget(oldWidget);
    final before = _ahead(oldWidget.urls).toSet();
    // Only what is new: a rebuild with the same list does nothing.
    _warm(_ahead(widget.urls).where((url) => !before.contains(url)));
  }

  void _warm(Iterable<String> urls) {
    for (final url in urls) {
      AppNetworkImage.precache(
        context,
        url,
        use: widget.use,
        logicalWidth: widget.logicalWidth,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
