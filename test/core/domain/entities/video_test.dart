import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/video.dart';

Video _v(
  String key, {
  String site = 'YouTube',
  String type = 'Clip',
  bool official = false,
  String lang = 'en',
}) => Video(
  key: key,
  site: site,
  type: type,
  name: key,
  official: official,
  iso6391: lang,
);

void main() {
  test('official trailer in the language beats everything', () {
    final pick = Video.pickTrailer([
      _v('teaser', type: 'Teaser'),
      _v('other', official: true, type: 'Trailer', lang: 'fr'),
      _v('best', official: true, type: 'Trailer', lang: 'es'),
    ], language: 'es');
    expect(pick?.key, 'best');
  });

  test('then official, then a teaser, then the first YouTube video', () {
    expect(Video.pickTrailer([_v('a'), _v('b', official: true)])?.key, 'b');
    expect(Video.pickTrailer([_v('a'), _v('t', type: 'Teaser')])?.key, 't');
    expect(Video.pickTrailer([_v('a'), _v('b')])?.key, 'a');
  });

  test('non-YouTube videos never count; none means null', () {
    expect(Video.pickTrailer([_v('v', site: 'Vimeo')]), isNull);
    expect(Video.pickTrailer(const []), isNull);
  });
}
