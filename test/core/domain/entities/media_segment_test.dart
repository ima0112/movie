import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/media_segment.dart';
import 'package:movies/core/domain/entities/media_type.dart';

void main() {
  group('MediaSegment.mediaType', () {
    test('all has no MediaType filter', () {
      expect(MediaSegment.all.mediaType, isNull);
    });

    test('movie maps to MediaType.movie', () {
      expect(MediaSegment.movie.mediaType, MediaType.movie);
    });

    test('tvShow maps to MediaType.tvShow', () {
      expect(MediaSegment.tvShow.mediaType, MediaType.tvShow);
    });
  });
}
