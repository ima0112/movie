import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/launch/youtube_urls.dart';

void main() {
  test('candidate order: the app scheme first, the web URL second', () {
    final uris = youtubeTrailerUris('abc123');

    expect(uris, [
      Uri.parse('youtube://www.youtube.com/watch?v=abc123'),
      Uri.parse('https://www.youtube.com/watch?v=abc123'),
    ]);
  });
}
