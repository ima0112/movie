/// Candidate URIs for opening a YouTube trailer, in try-order: the
/// YouTube app's own `youtube://` scheme first (opens directly in the
/// app if it's installed), the regular `https://www.youtube.com/watch`
/// page second (opens in the external browser otherwise).
///
/// Pure — no Flutter, no `url_launcher` — so the URL shape itself is
/// unit-tested with no device/platform channel involved.
/// `launch_external_link.dart` is what actually tries these in order.
List<Uri> youtubeTrailerUris(String videoKey) => [
  Uri.parse('youtube://www.youtube.com/watch?v=$videoKey'),
  Uri.parse('https://www.youtube.com/watch?v=$videoKey'),
];
