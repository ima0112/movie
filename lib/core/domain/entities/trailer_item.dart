import 'media_item.dart';
import 'video.dart';

/// A title paired with its trailer — one card of B1's "Latest trailers".
final class TrailerItem {
  const TrailerItem({required this.item, required this.video});

  final MediaItem item;

  /// A YouTube video (see `Video.pickTrailer`).
  final Video video;
}
