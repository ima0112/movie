import 'package:flutter_test/flutter_test.dart';
import 'package:movies/core/domain/entities/genre.dart';
import 'package:movies/core/domain/entities/media_key.dart';
import 'package:movies/core/domain/entities/media_type.dart';
import 'package:movies/core/domain/entities/taste_profile.dart';
import 'package:movies/core/domain/entities/user_media_entry.dart';
import 'package:movies/features/match_engine/domain/vibe.dart';
import 'package:movies/features/match_engine/domain/vibe_catalog.dart';
import 'package:movies/features/taste_profile/domain/taste_profile_builder.dart';

const _action = Genre(id: 'action');
const _comedy = Genre(id: 'comedy');
const _documentary = Genre(id: 'documentary');
const _drama = Genre(id: 'drama');
const _horror = Genre(id: 'horror');

Vibe _vibe(String id, String genreId) {
  return Vibe(
    id: id,
    icon: 'icon',
    movie: VibeRule(genreIds: [genreId], keywordIds: const []),
    tv: VibeRule(genreIds: [genreId], keywordIds: const []),
  );
}

final _vibeCatalog = VibeCatalog([
  _vibe('cozy', 'drama'),
  _vibe('laughs', 'comedy'),
  _vibe('scary', 'horror'),
  _vibe('adrenaline', 'action'),
  _vibe('real-life', 'documentary'),
  // Mirrors the real "indie" vibe: known to the catalog, but an empty
  // rule for tv (same shape `isMeaningfulFor` gates on) — not simply
  // absent, which "cult" below covers instead.
  const Vibe(
    id: 'indie',
    icon: 'icon',
    movie: VibeRule(genreIds: ['drama'], keywordIds: []),
    tv: VibeRule(genreIds: [], keywordIds: []),
  ),
]);

UserMediaEntry _entry(
  int id, {
  bool isFavorite = false,
  int? rating,
  List<Genre> genres = const [],
  bool watched = false,
}) {
  return UserMediaEntry(
    title: 'Test Title',
    key: MediaKey(type: MediaType.movie, tmdbId: id),
    isFavorite: isFavorite,
    watchedAt: (watched || rating != null) ? DateTime(2024) : null,
    rating: rating,
    genres: genres,
  );
}

TasteProfile _profile({
  Set<Genre> likedGenres = const {},
  Set<Genre> vetoedGenres = const {},
  Set<String> likedVibes = const {},
  int yearFrom = 2000,
}) {
  return TasteProfile(
    likedGenres: likedGenres,
    vetoedGenres: vetoedGenres,
    likedVibes: likedVibes,
    yearFrom: yearFrom,
    updatedAt: DateTime(2024),
  );
}

void main() {
  group('TasteProfileBuilder.build — an explicit profile', () {
    test('with exactly 3 vibes already, those are used as-is — library '
        'signals never touch an explicit pick', () {
      final profile = _profile(
        likedGenres: {_drama, _comedy},
        vetoedGenres: {_horror},
        likedVibes: {'cozy', 'laughs', 'scary'},
        yearFrom: 2010,
      );

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, {'cozy', 'laughs', 'scary'});
      expect(result.excludedGenres, {_horror});
      expect(result.yearFrom, 2010);
      expect(result.excludeWatched, isTrue);
    });

    test('with fewer than 3 vibes, the gap is filled from liked genres, '
        'the most-reinforced genre first', () {
      final profile = _profile(
        likedGenres: {_drama, _comedy, _action},
        likedVibes: {'cozy'}, // drama already covered
      );
      final libraryEntries = [
        _entry(1, isFavorite: true, genres: [_action]),
        _entry(2, isFavorite: true, genres: [_action]), // action affinity: 2
        _entry(3, rating: 5, genres: [_comedy]), // comedy affinity: 1
      ];

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result!.vibeIds, {'cozy', 'adrenaline', 'laughs'});
    });

    test('a vetoed genre is never used to fill a vibe, even with the '
        'strongest affinity — the explicit veto always wins', () {
      final profile = _profile(
        likedGenres: {_horror, _drama},
        vetoedGenres: {_horror},
      );
      final libraryEntries = [
        _entry(
          1,
          isFavorite: true,
          genres: [_horror],
        ), // strong signal, but vetoed
      ];

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result!.vibeIds, contains('cozy')); // drama's vibe
      expect(result.vibeIds, isNot(contains('scary'))); // horror's vibe
    });

    test('more than 3 vetoed genres are capped to 3, deterministically '
        'by genre id', () {
      final profile = _profile(
        // A liked vibe (not a genre, to avoid tangling with the
        // vetoed set below) just to make the profile usable — this
        // test is about the veto cap, not about what makes it usable.
        likedVibes: {'cozy'},
        vetoedGenres: {_action, _comedy, _documentary, _drama, _horror},
      );

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result!.excludedGenres, hasLength(3));
      expect(result.excludedGenres, {_action, _comedy, _documentary});
    });

    test('a usable profile (liked genres) with nothing else to work '
        'with still returns a (thinner) ParticipantAnswers, not null '
        'and not a crash', () {
      final profile = _profile(likedGenres: {_drama});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, {'cozy'}); // drama's own vibe
      expect(result.excludedGenres, isEmpty);
    });

    test('watchedKeys collects every watched entry regardless of rating '
        'or favorite status', () {
      final profile = _profile(likedVibes: {'cozy'});
      final libraryEntries = [
        _entry(1, watched: true), // watched, no rating, no favorite
        _entry(2, isFavorite: true), // favorite but never watched
        _entry(3, rating: 5),
      ];

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result!.watchedKeys, {
        const MediaKey(type: MediaType.movie, tmdbId: 1),
        const MediaKey(type: MediaType.movie, tmdbId: 3),
      });
    });
  });

  group('TasteProfileBuilder.build — no explicit profile', () {
    test('with at least 5 library entries, a provisional profile is '
        'inferred from favorites/ratings', () {
      final libraryEntries = [
        _entry(1, isFavorite: true, genres: [_drama]),
        _entry(2, rating: 5, genres: [_drama]),
        _entry(3, isFavorite: true, genres: [_comedy]),
        _entry(4, rating: 1, genres: [_horror]), // penalized, not liked
        _entry(5, watched: true, genres: [_action]), // no signal either way
      ];

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: null,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, {'cozy', 'laughs'}); // drama + comedy only
      expect(result.excludeWatched, isTrue);
      // Only entries that were actually *watched* count — being a
      // favorite or merely rated doesn't imply watchedAt is set; entries
      // 2 (rated), 4 (rated), and 5 (explicitly watched) qualify, not 1
      // or 3 (favorites that were never marked watched).
      expect(result.watchedKeys, hasLength(3));
    });

    test('fewer than 5 entries: no inferred profile, result is null', () {
      final libraryEntries = List.generate(
        4,
        (i) => _entry(i, isFavorite: true, genres: [_drama]),
      );

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: null,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNull);
    });

    test('no profile and an empty library: null, the signal to open the '
        'quiz', () {
      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: null,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNull);
    });
  });

  group('TasteProfileBuilder.build — TasteProfile.isUsableForSuggestions '
      'gate', () {
    final libraryOf5 = List.generate(
      5,
      (i) => _entry(i, isFavorite: true, genres: [_comedy]),
    );

    test('a profile with only yearFrom set falls through to the '
        'inferred-from-library case when there are 5+ entries', () {
      final profile = _profile(yearFrom: 1950);

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryOf5,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      // The inferred case's own fixed year default, not the unusable
      // profile's yearFrom (1950) — confirms the profile was ignored
      // entirely, not partially reused.
      expect(result!.yearFrom, TasteProfileBuilder.inferredDefaultYearFrom);
      expect(result.vibeIds, {'laughs'}); // comedy's own vibe
    });

    test('a profile with only yearFrom set falls all the way to null '
        '(the quiz) when the library has fewer than 5 entries too', () {
      final profile = _profile(yearFrom: 1950);

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNull);
    });

    test('a profile with only vetoedGenres set — no liked genres or '
        'vibes — falls through to the library case the same way', () {
      final profile = _profile(vetoedGenres: {_horror});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryOf5,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      // The inferred case's own vetoedGenres (always empty — nothing
      // in UserMediaEntry carries a veto signal), not the unusable
      // profile's {_horror}.
      expect(result!.excludedGenres, isEmpty);
    });

    test('a profile with only vetoedGenres set falls to null with an '
        'empty library too', () {
      final profile = _profile(vetoedGenres: {_horror});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNull);
    });

    test('a completely empty profile falls through exactly like no '
        'profile at all', () {
      final profile = _profile();

      final withLibrary = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryOf5,
        mediaType: MediaType.movie,
        participantId: 'me',
      );
      final withoutLibrary = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(withLibrary, isNotNull);
      expect(withLibrary!.vibeIds, {'laughs'});
      expect(withoutLibrary, isNull);
    });

    test('liked genres alone make a profile usable — it wins over the '
        'library even when there are 5+ entries available', () {
      final profile = _profile(likedGenres: {_drama});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryOf5, // all comedy — would infer differently
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, {'cozy'}); // drama's vibe, not comedy's
    });

    test('liked vibes alone make a profile usable — same, wins over '
        'the library', () {
      final profile = _profile(likedVibes: {'scary'});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryOf5,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, contains('scary'));
    });
  });

  group('TasteProfileBuilder.build — tied affinity', () {
    test('when more genres are tied for the remaining slots than there '
        'is room for, the cutoff breaks deterministically by genre id', () {
      final profile = _profile(
        likedGenres: {_action, _comedy, _documentary, _horror},
        // documentary already covered — only 2 slots remain, but 3
        // candidates (action/comedy/horror) all end up tied at the same
        // affinity below, so only 2 of them can fit.
        likedVibes: {'real-life'},
      );
      final libraryEntries = [
        _entry(1, isFavorite: true, genres: [_action]),
        _entry(2, isFavorite: true, genres: [_comedy]),
        _entry(3, isFavorite: true, genres: [_horror]),
      ];

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: libraryEntries,
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      // All three tie at affinity 1; alphabetically 'action' < 'comedy'
      // < 'horror', so the first two (action, comedy) win the 2
      // remaining slots and horror's vibe is left out.
      expect(result!.vibeIds, {'real-life', 'adrenaline', 'laughs'});
      expect(result.vibeIds, isNot(contains('scary')));
    });
  });

  group('TasteProfileBuilder.build — discards vibes that don\'t apply '
      'to the requested type', () {
    test('likedVibes with indie (empty tv rule) and cult (not in the '
        'catalog at all) for a tv session: both are dropped, then the '
        'gap is filled from liked genres as usual', () {
      final profile = _profile(
        likedGenres: {_drama, _comedy},
        likedVibes: {'indie', 'cult'},
      );

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.tvShow,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, isNot(contains('indie')));
      expect(result.vibeIds, isNot(contains('cult')));
      // Filled from likedGenres instead — drama's and comedy's own
      // vibes, exactly as if indie/cult had never been in the profile.
      expect(result.vibeIds, {'cozy', 'laughs'});
    });

    test('the same profile for a movie session keeps indie — its movie '
        'rule is meaningful — but still drops cult', () {
      final profile = _profile(likedVibes: {'indie', 'cult'});

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.movie,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, contains('indie'));
      expect(result.vibeIds, isNot(contains('cult')));
    });

    test('exactly 3 liked vibes, one of them inapplicable to tv: still '
        'drops it rather than keeping it via the "already full" fast '
        'path', () {
      final profile = _profile(
        likedGenres: {_drama},
        likedVibes: {'indie', 'cozy', 'laughs'},
      );

      final result = TasteProfileBuilder(_vibeCatalog).build(
        profile: profile,
        libraryEntries: const [],
        mediaType: MediaType.tvShow,
        participantId: 'me',
      );

      expect(result, isNotNull);
      expect(result!.vibeIds, isNot(contains('indie')));
      expect(result.vibeIds, {'cozy', 'laughs'});
    });
  });
}
