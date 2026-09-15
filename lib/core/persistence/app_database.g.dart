// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserMediaEntriesTable extends UserMediaEntries
    with TableInfo<$UserMediaEntriesTable, UserMediaEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserMediaEntriesTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, String> mediaType =
      GeneratedColumn<String>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaType>($UserMediaEntriesTable.$convertermediaType);
  static const VerificationMeta _tmdbIdMeta = const VerificationMeta('tmdbId');
  @override
  late final GeneratedColumn<int> tmdbId = GeneratedColumn<int>(
    'tmdb_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _posterPathMeta = const VerificationMeta(
    'posterPath',
  );
  @override
  late final GeneratedColumn<String> posterPath = GeneratedColumn<String>(
    'poster_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backdropPathMeta = const VerificationMeta(
    'backdropPath',
  );
  @override
  late final GeneratedColumn<String> backdropPath = GeneratedColumn<String>(
    'backdrop_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteAverageMeta = const VerificationMeta(
    'voteAverage',
  );
  @override
  late final GeneratedColumn<double> voteAverage = GeneratedColumn<double>(
    'vote_average',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voteCountMeta = const VerificationMeta(
    'voteCount',
  );
  @override
  late final GeneratedColumn<int> voteCount = GeneratedColumn<int>(
    'vote_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _popularityMeta = const VerificationMeta(
    'popularity',
  );
  @override
  late final GeneratedColumn<double> popularity = GeneratedColumn<double>(
    'popularity',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWatchLaterMeta = const VerificationMeta(
    'isWatchLater',
  );
  @override
  late final GeneratedColumn<bool> isWatchLater = GeneratedColumn<bool>(
    'is_watch_later',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_watch_later" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runtimeMinutesMeta = const VerificationMeta(
    'runtimeMinutes',
  );
  @override
  late final GeneratedColumn<int> runtimeMinutes = GeneratedColumn<int>(
    'runtime_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeCountMeta = const VerificationMeta(
    'episodeCount',
  );
  @override
  late final GeneratedColumn<int> episodeCount = GeneratedColumn<int>(
    'episode_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _episodeRuntimeMinutesMeta =
      const VerificationMeta('episodeRuntimeMinutes');
  @override
  late final GeneratedColumn<int> episodeRuntimeMinutes = GeneratedColumn<int>(
    'episode_runtime_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    mediaType,
    tmdbId,
    title,
    posterPath,
    backdropPath,
    genres,
    voteAverage,
    voteCount,
    popularity,
    year,
    isFavorite,
    isWatchLater,
    watchedAt,
    rating,
    runtimeMinutes,
    episodeCount,
    episodeRuntimeMinutes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_media_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserMediaEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tmdb_id')) {
      context.handle(
        _tmdbIdMeta,
        tmdbId.isAcceptableOrUnknown(data['tmdb_id']!, _tmdbIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tmdbIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('poster_path')) {
      context.handle(
        _posterPathMeta,
        posterPath.isAcceptableOrUnknown(data['poster_path']!, _posterPathMeta),
      );
    }
    if (data.containsKey('backdrop_path')) {
      context.handle(
        _backdropPathMeta,
        backdropPath.isAcceptableOrUnknown(
          data['backdrop_path']!,
          _backdropPathMeta,
        ),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('vote_average')) {
      context.handle(
        _voteAverageMeta,
        voteAverage.isAcceptableOrUnknown(
          data['vote_average']!,
          _voteAverageMeta,
        ),
      );
    }
    if (data.containsKey('vote_count')) {
      context.handle(
        _voteCountMeta,
        voteCount.isAcceptableOrUnknown(data['vote_count']!, _voteCountMeta),
      );
    }
    if (data.containsKey('popularity')) {
      context.handle(
        _popularityMeta,
        popularity.isAcceptableOrUnknown(data['popularity']!, _popularityMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_watch_later')) {
      context.handle(
        _isWatchLaterMeta,
        isWatchLater.isAcceptableOrUnknown(
          data['is_watch_later']!,
          _isWatchLaterMeta,
        ),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('runtime_minutes')) {
      context.handle(
        _runtimeMinutesMeta,
        runtimeMinutes.isAcceptableOrUnknown(
          data['runtime_minutes']!,
          _runtimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('episode_count')) {
      context.handle(
        _episodeCountMeta,
        episodeCount.isAcceptableOrUnknown(
          data['episode_count']!,
          _episodeCountMeta,
        ),
      );
    }
    if (data.containsKey('episode_runtime_minutes')) {
      context.handle(
        _episodeRuntimeMinutesMeta,
        episodeRuntimeMinutes.isAcceptableOrUnknown(
          data['episode_runtime_minutes']!,
          _episodeRuntimeMinutesMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mediaType, tmdbId};
  @override
  UserMediaEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserMediaEntryRow(
      mediaType: $UserMediaEntriesTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      tmdbId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tmdb_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      posterPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_path'],
      ),
      backdropPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backdrop_path'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      ),
      voteAverage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vote_average'],
      ),
      voteCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vote_count'],
      ),
      popularity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}popularity'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isWatchLater: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_watch_later'],
      )!,
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      runtimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runtime_minutes'],
      ),
      episodeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_count'],
      ),
      episodeRuntimeMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_runtime_minutes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserMediaEntriesTable createAlias(String alias) {
    return $UserMediaEntriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, String, String> $convertermediaType =
      const EnumNameConverter<MediaType>(MediaType.values);
}

class UserMediaEntryRow extends DataClass
    implements Insertable<UserMediaEntryRow> {
  /// `MediaKey.type` — stored as text (the enum's name) rather than an
  /// int index, so the raw database stays human-readable and isn't
  /// silently invalidated by reordering `MediaType`'s values.
  final MediaType mediaType;

  /// `MediaKey.tmdbId`.
  final int tmdbId;
  final String? title;
  final String? posterPath;
  final String? backdropPath;

  /// Genre names, serialized (e.g. comma-joined) by whoever writes this
  /// row — drift/SQLite has no native array column, and this is a
  /// read-mostly snapshot, not something ever queried by individual
  /// genre.
  final String? genres;
  final double? voteAverage;
  final int? voteCount;
  final double? popularity;

  /// Release/first-air year — kept separate from a full release date
  /// since a year is all the offline snapshot ever needs to show
  /// (`docs/SCREENS.md` D1).
  final int? year;
  final bool isFavorite;
  final bool isWatchLater;
  final DateTime? watchedAt;

  /// 1–5, only meaningful once [watchedAt] is set — see
  /// `UserMediaEntry.markWatched`.
  final int? rating;
  final int? runtimeMinutes;
  final int? episodeCount;
  final int? episodeRuntimeMinutes;

  /// When this row last changed. Lets a future sync step know what to
  /// push without re-sending every row.
  final DateTime updatedAt;
  const UserMediaEntryRow({
    required this.mediaType,
    required this.tmdbId,
    this.title,
    this.posterPath,
    this.backdropPath,
    this.genres,
    this.voteAverage,
    this.voteCount,
    this.popularity,
    this.year,
    required this.isFavorite,
    required this.isWatchLater,
    this.watchedAt,
    this.rating,
    this.runtimeMinutes,
    this.episodeCount,
    this.episodeRuntimeMinutes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['media_type'] = Variable<String>(
        $UserMediaEntriesTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['tmdb_id'] = Variable<int>(tmdbId);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || posterPath != null) {
      map['poster_path'] = Variable<String>(posterPath);
    }
    if (!nullToAbsent || backdropPath != null) {
      map['backdrop_path'] = Variable<String>(backdropPath);
    }
    if (!nullToAbsent || genres != null) {
      map['genres'] = Variable<String>(genres);
    }
    if (!nullToAbsent || voteAverage != null) {
      map['vote_average'] = Variable<double>(voteAverage);
    }
    if (!nullToAbsent || voteCount != null) {
      map['vote_count'] = Variable<int>(voteCount);
    }
    if (!nullToAbsent || popularity != null) {
      map['popularity'] = Variable<double>(popularity);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_watch_later'] = Variable<bool>(isWatchLater);
    if (!nullToAbsent || watchedAt != null) {
      map['watched_at'] = Variable<DateTime>(watchedAt);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || runtimeMinutes != null) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes);
    }
    if (!nullToAbsent || episodeCount != null) {
      map['episode_count'] = Variable<int>(episodeCount);
    }
    if (!nullToAbsent || episodeRuntimeMinutes != null) {
      map['episode_runtime_minutes'] = Variable<int>(episodeRuntimeMinutes);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserMediaEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserMediaEntriesCompanion(
      mediaType: Value(mediaType),
      tmdbId: Value(tmdbId),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      posterPath: posterPath == null && nullToAbsent
          ? const Value.absent()
          : Value(posterPath),
      backdropPath: backdropPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backdropPath),
      genres: genres == null && nullToAbsent
          ? const Value.absent()
          : Value(genres),
      voteAverage: voteAverage == null && nullToAbsent
          ? const Value.absent()
          : Value(voteAverage),
      voteCount: voteCount == null && nullToAbsent
          ? const Value.absent()
          : Value(voteCount),
      popularity: popularity == null && nullToAbsent
          ? const Value.absent()
          : Value(popularity),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      isFavorite: Value(isFavorite),
      isWatchLater: Value(isWatchLater),
      watchedAt: watchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedAt),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      runtimeMinutes: runtimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(runtimeMinutes),
      episodeCount: episodeCount == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeCount),
      episodeRuntimeMinutes: episodeRuntimeMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeRuntimeMinutes),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserMediaEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserMediaEntryRow(
      mediaType: $UserMediaEntriesTable.$convertermediaType.fromJson(
        serializer.fromJson<String>(json['mediaType']),
      ),
      tmdbId: serializer.fromJson<int>(json['tmdbId']),
      title: serializer.fromJson<String?>(json['title']),
      posterPath: serializer.fromJson<String?>(json['posterPath']),
      backdropPath: serializer.fromJson<String?>(json['backdropPath']),
      genres: serializer.fromJson<String?>(json['genres']),
      voteAverage: serializer.fromJson<double?>(json['voteAverage']),
      voteCount: serializer.fromJson<int?>(json['voteCount']),
      popularity: serializer.fromJson<double?>(json['popularity']),
      year: serializer.fromJson<int?>(json['year']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isWatchLater: serializer.fromJson<bool>(json['isWatchLater']),
      watchedAt: serializer.fromJson<DateTime?>(json['watchedAt']),
      rating: serializer.fromJson<int?>(json['rating']),
      runtimeMinutes: serializer.fromJson<int?>(json['runtimeMinutes']),
      episodeCount: serializer.fromJson<int?>(json['episodeCount']),
      episodeRuntimeMinutes: serializer.fromJson<int?>(
        json['episodeRuntimeMinutes'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mediaType': serializer.toJson<String>(
        $UserMediaEntriesTable.$convertermediaType.toJson(mediaType),
      ),
      'tmdbId': serializer.toJson<int>(tmdbId),
      'title': serializer.toJson<String?>(title),
      'posterPath': serializer.toJson<String?>(posterPath),
      'backdropPath': serializer.toJson<String?>(backdropPath),
      'genres': serializer.toJson<String?>(genres),
      'voteAverage': serializer.toJson<double?>(voteAverage),
      'voteCount': serializer.toJson<int?>(voteCount),
      'popularity': serializer.toJson<double?>(popularity),
      'year': serializer.toJson<int?>(year),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isWatchLater': serializer.toJson<bool>(isWatchLater),
      'watchedAt': serializer.toJson<DateTime?>(watchedAt),
      'rating': serializer.toJson<int?>(rating),
      'runtimeMinutes': serializer.toJson<int?>(runtimeMinutes),
      'episodeCount': serializer.toJson<int?>(episodeCount),
      'episodeRuntimeMinutes': serializer.toJson<int?>(episodeRuntimeMinutes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserMediaEntryRow copyWith({
    MediaType? mediaType,
    int? tmdbId,
    Value<String?> title = const Value.absent(),
    Value<String?> posterPath = const Value.absent(),
    Value<String?> backdropPath = const Value.absent(),
    Value<String?> genres = const Value.absent(),
    Value<double?> voteAverage = const Value.absent(),
    Value<int?> voteCount = const Value.absent(),
    Value<double?> popularity = const Value.absent(),
    Value<int?> year = const Value.absent(),
    bool? isFavorite,
    bool? isWatchLater,
    Value<DateTime?> watchedAt = const Value.absent(),
    Value<int?> rating = const Value.absent(),
    Value<int?> runtimeMinutes = const Value.absent(),
    Value<int?> episodeCount = const Value.absent(),
    Value<int?> episodeRuntimeMinutes = const Value.absent(),
    DateTime? updatedAt,
  }) => UserMediaEntryRow(
    mediaType: mediaType ?? this.mediaType,
    tmdbId: tmdbId ?? this.tmdbId,
    title: title.present ? title.value : this.title,
    posterPath: posterPath.present ? posterPath.value : this.posterPath,
    backdropPath: backdropPath.present ? backdropPath.value : this.backdropPath,
    genres: genres.present ? genres.value : this.genres,
    voteAverage: voteAverage.present ? voteAverage.value : this.voteAverage,
    voteCount: voteCount.present ? voteCount.value : this.voteCount,
    popularity: popularity.present ? popularity.value : this.popularity,
    year: year.present ? year.value : this.year,
    isFavorite: isFavorite ?? this.isFavorite,
    isWatchLater: isWatchLater ?? this.isWatchLater,
    watchedAt: watchedAt.present ? watchedAt.value : this.watchedAt,
    rating: rating.present ? rating.value : this.rating,
    runtimeMinutes: runtimeMinutes.present
        ? runtimeMinutes.value
        : this.runtimeMinutes,
    episodeCount: episodeCount.present ? episodeCount.value : this.episodeCount,
    episodeRuntimeMinutes: episodeRuntimeMinutes.present
        ? episodeRuntimeMinutes.value
        : this.episodeRuntimeMinutes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserMediaEntryRow copyWithCompanion(UserMediaEntriesCompanion data) {
    return UserMediaEntryRow(
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      tmdbId: data.tmdbId.present ? data.tmdbId.value : this.tmdbId,
      title: data.title.present ? data.title.value : this.title,
      posterPath: data.posterPath.present
          ? data.posterPath.value
          : this.posterPath,
      backdropPath: data.backdropPath.present
          ? data.backdropPath.value
          : this.backdropPath,
      genres: data.genres.present ? data.genres.value : this.genres,
      voteAverage: data.voteAverage.present
          ? data.voteAverage.value
          : this.voteAverage,
      voteCount: data.voteCount.present ? data.voteCount.value : this.voteCount,
      popularity: data.popularity.present
          ? data.popularity.value
          : this.popularity,
      year: data.year.present ? data.year.value : this.year,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isWatchLater: data.isWatchLater.present
          ? data.isWatchLater.value
          : this.isWatchLater,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
      rating: data.rating.present ? data.rating.value : this.rating,
      runtimeMinutes: data.runtimeMinutes.present
          ? data.runtimeMinutes.value
          : this.runtimeMinutes,
      episodeCount: data.episodeCount.present
          ? data.episodeCount.value
          : this.episodeCount,
      episodeRuntimeMinutes: data.episodeRuntimeMinutes.present
          ? data.episodeRuntimeMinutes.value
          : this.episodeRuntimeMinutes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserMediaEntryRow(')
          ..write('mediaType: $mediaType, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('genres: $genres, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('voteCount: $voteCount, ')
          ..write('popularity: $popularity, ')
          ..write('year: $year, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isWatchLater: $isWatchLater, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('rating: $rating, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('episodeCount: $episodeCount, ')
          ..write('episodeRuntimeMinutes: $episodeRuntimeMinutes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    mediaType,
    tmdbId,
    title,
    posterPath,
    backdropPath,
    genres,
    voteAverage,
    voteCount,
    popularity,
    year,
    isFavorite,
    isWatchLater,
    watchedAt,
    rating,
    runtimeMinutes,
    episodeCount,
    episodeRuntimeMinutes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserMediaEntryRow &&
          other.mediaType == this.mediaType &&
          other.tmdbId == this.tmdbId &&
          other.title == this.title &&
          other.posterPath == this.posterPath &&
          other.backdropPath == this.backdropPath &&
          other.genres == this.genres &&
          other.voteAverage == this.voteAverage &&
          other.voteCount == this.voteCount &&
          other.popularity == this.popularity &&
          other.year == this.year &&
          other.isFavorite == this.isFavorite &&
          other.isWatchLater == this.isWatchLater &&
          other.watchedAt == this.watchedAt &&
          other.rating == this.rating &&
          other.runtimeMinutes == this.runtimeMinutes &&
          other.episodeCount == this.episodeCount &&
          other.episodeRuntimeMinutes == this.episodeRuntimeMinutes &&
          other.updatedAt == this.updatedAt);
}

class UserMediaEntriesCompanion extends UpdateCompanion<UserMediaEntryRow> {
  final Value<MediaType> mediaType;
  final Value<int> tmdbId;
  final Value<String?> title;
  final Value<String?> posterPath;
  final Value<String?> backdropPath;
  final Value<String?> genres;
  final Value<double?> voteAverage;
  final Value<int?> voteCount;
  final Value<double?> popularity;
  final Value<int?> year;
  final Value<bool> isFavorite;
  final Value<bool> isWatchLater;
  final Value<DateTime?> watchedAt;
  final Value<int?> rating;
  final Value<int?> runtimeMinutes;
  final Value<int?> episodeCount;
  final Value<int?> episodeRuntimeMinutes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserMediaEntriesCompanion({
    this.mediaType = const Value.absent(),
    this.tmdbId = const Value.absent(),
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.genres = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.voteCount = const Value.absent(),
    this.popularity = const Value.absent(),
    this.year = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isWatchLater = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.episodeRuntimeMinutes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserMediaEntriesCompanion.insert({
    required MediaType mediaType,
    required int tmdbId,
    this.title = const Value.absent(),
    this.posterPath = const Value.absent(),
    this.backdropPath = const Value.absent(),
    this.genres = const Value.absent(),
    this.voteAverage = const Value.absent(),
    this.voteCount = const Value.absent(),
    this.popularity = const Value.absent(),
    this.year = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isWatchLater = const Value.absent(),
    this.watchedAt = const Value.absent(),
    this.rating = const Value.absent(),
    this.runtimeMinutes = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.episodeRuntimeMinutes = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : mediaType = Value(mediaType),
       tmdbId = Value(tmdbId),
       updatedAt = Value(updatedAt);
  static Insertable<UserMediaEntryRow> custom({
    Expression<String>? mediaType,
    Expression<int>? tmdbId,
    Expression<String>? title,
    Expression<String>? posterPath,
    Expression<String>? backdropPath,
    Expression<String>? genres,
    Expression<double>? voteAverage,
    Expression<int>? voteCount,
    Expression<double>? popularity,
    Expression<int>? year,
    Expression<bool>? isFavorite,
    Expression<bool>? isWatchLater,
    Expression<DateTime>? watchedAt,
    Expression<int>? rating,
    Expression<int>? runtimeMinutes,
    Expression<int>? episodeCount,
    Expression<int>? episodeRuntimeMinutes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mediaType != null) 'media_type': mediaType,
      if (tmdbId != null) 'tmdb_id': tmdbId,
      if (title != null) 'title': title,
      if (posterPath != null) 'poster_path': posterPath,
      if (backdropPath != null) 'backdrop_path': backdropPath,
      if (genres != null) 'genres': genres,
      if (voteAverage != null) 'vote_average': voteAverage,
      if (voteCount != null) 'vote_count': voteCount,
      if (popularity != null) 'popularity': popularity,
      if (year != null) 'year': year,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isWatchLater != null) 'is_watch_later': isWatchLater,
      if (watchedAt != null) 'watched_at': watchedAt,
      if (rating != null) 'rating': rating,
      if (runtimeMinutes != null) 'runtime_minutes': runtimeMinutes,
      if (episodeCount != null) 'episode_count': episodeCount,
      if (episodeRuntimeMinutes != null)
        'episode_runtime_minutes': episodeRuntimeMinutes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserMediaEntriesCompanion copyWith({
    Value<MediaType>? mediaType,
    Value<int>? tmdbId,
    Value<String?>? title,
    Value<String?>? posterPath,
    Value<String?>? backdropPath,
    Value<String?>? genres,
    Value<double?>? voteAverage,
    Value<int?>? voteCount,
    Value<double?>? popularity,
    Value<int?>? year,
    Value<bool>? isFavorite,
    Value<bool>? isWatchLater,
    Value<DateTime?>? watchedAt,
    Value<int?>? rating,
    Value<int?>? runtimeMinutes,
    Value<int?>? episodeCount,
    Value<int?>? episodeRuntimeMinutes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserMediaEntriesCompanion(
      mediaType: mediaType ?? this.mediaType,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      posterPath: posterPath ?? this.posterPath,
      backdropPath: backdropPath ?? this.backdropPath,
      genres: genres ?? this.genres,
      voteAverage: voteAverage ?? this.voteAverage,
      voteCount: voteCount ?? this.voteCount,
      popularity: popularity ?? this.popularity,
      year: year ?? this.year,
      isFavorite: isFavorite ?? this.isFavorite,
      isWatchLater: isWatchLater ?? this.isWatchLater,
      watchedAt: watchedAt ?? this.watchedAt,
      rating: rating ?? this.rating,
      runtimeMinutes: runtimeMinutes ?? this.runtimeMinutes,
      episodeCount: episodeCount ?? this.episodeCount,
      episodeRuntimeMinutes:
          episodeRuntimeMinutes ?? this.episodeRuntimeMinutes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mediaType.present) {
      map['media_type'] = Variable<String>(
        $UserMediaEntriesTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (tmdbId.present) {
      map['tmdb_id'] = Variable<int>(tmdbId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (posterPath.present) {
      map['poster_path'] = Variable<String>(posterPath.value);
    }
    if (backdropPath.present) {
      map['backdrop_path'] = Variable<String>(backdropPath.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (voteAverage.present) {
      map['vote_average'] = Variable<double>(voteAverage.value);
    }
    if (voteCount.present) {
      map['vote_count'] = Variable<int>(voteCount.value);
    }
    if (popularity.present) {
      map['popularity'] = Variable<double>(popularity.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isWatchLater.present) {
      map['is_watch_later'] = Variable<bool>(isWatchLater.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (runtimeMinutes.present) {
      map['runtime_minutes'] = Variable<int>(runtimeMinutes.value);
    }
    if (episodeCount.present) {
      map['episode_count'] = Variable<int>(episodeCount.value);
    }
    if (episodeRuntimeMinutes.present) {
      map['episode_runtime_minutes'] = Variable<int>(
        episodeRuntimeMinutes.value,
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserMediaEntriesCompanion(')
          ..write('mediaType: $mediaType, ')
          ..write('tmdbId: $tmdbId, ')
          ..write('title: $title, ')
          ..write('posterPath: $posterPath, ')
          ..write('backdropPath: $backdropPath, ')
          ..write('genres: $genres, ')
          ..write('voteAverage: $voteAverage, ')
          ..write('voteCount: $voteCount, ')
          ..write('popularity: $popularity, ')
          ..write('year: $year, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isWatchLater: $isWatchLater, ')
          ..write('watchedAt: $watchedAt, ')
          ..write('rating: $rating, ')
          ..write('runtimeMinutes: $runtimeMinutes, ')
          ..write('episodeCount: $episodeCount, ')
          ..write('episodeRuntimeMinutes: $episodeRuntimeMinutes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTableTable extends UserProfileTable
    with TableInfo<$UserProfileTableTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _initialColorMeta = const VerificationMeta(
    'initialColor',
  );
  @override
  late final GeneratedColumn<int> initialColor = GeneratedColumn<int>(
    'initial_color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    initialColor,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('initial_color')) {
      context.handle(
        _initialColorMeta,
        initialColor.isAcceptableOrUnknown(
          data['initial_color']!,
          _initialColorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_initialColorMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      initialColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_color'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserProfileTableTable createAlias(String alias) {
    return $UserProfileTableTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final int id;
  final String displayName;

  /// See `UserProfile.initialColor` — a 32-bit ARGB int, not a color
  /// name or hex string.
  final int initialColor;
  final DateTime updatedAt;
  const UserProfileRow({
    required this.id,
    required this.displayName,
    required this.initialColor,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['initial_color'] = Variable<int>(initialColor);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserProfileTableCompanion toCompanion(bool nullToAbsent) {
    return UserProfileTableCompanion(
      id: Value(id),
      displayName: Value(displayName),
      initialColor: Value(initialColor),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      initialColor: serializer.fromJson<int>(json['initialColor']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'initialColor': serializer.toJson<int>(initialColor),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserProfileRow copyWith({
    int? id,
    String? displayName,
    int? initialColor,
    DateTime? updatedAt,
  }) => UserProfileRow(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    initialColor: initialColor ?? this.initialColor,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserProfileRow copyWithCompanion(UserProfileTableCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      initialColor: data.initialColor.present
          ? data.initialColor.value
          : this.initialColor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('initialColor: $initialColor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, initialColor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.initialColor == this.initialColor &&
          other.updatedAt == this.updatedAt);
}

class UserProfileTableCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<int> initialColor;
  final Value<DateTime> updatedAt;
  const UserProfileTableCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.initialColor = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserProfileTableCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required int initialColor,
    required DateTime updatedAt,
  }) : displayName = Value(displayName),
       initialColor = Value(initialColor),
       updatedAt = Value(updatedAt);
  static Insertable<UserProfileRow> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<int>? initialColor,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (initialColor != null) 'initial_color': initialColor,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserProfileTableCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<int>? initialColor,
    Value<DateTime>? updatedAt,
  }) {
    return UserProfileTableCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      initialColor: initialColor ?? this.initialColor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (initialColor.present) {
      map['initial_color'] = Variable<int>(initialColor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('initialColor: $initialColor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $TasteProfileTableTable extends TasteProfileTable
    with TableInfo<$TasteProfileTableTable, TasteProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasteProfileTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _likedGenresMeta = const VerificationMeta(
    'likedGenres',
  );
  @override
  late final GeneratedColumn<String> likedGenres = GeneratedColumn<String>(
    'liked_genres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vetoedGenresMeta = const VerificationMeta(
    'vetoedGenres',
  );
  @override
  late final GeneratedColumn<String> vetoedGenres = GeneratedColumn<String>(
    'vetoed_genres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _likedVibesMeta = const VerificationMeta(
    'likedVibes',
  );
  @override
  late final GeneratedColumn<String> likedVibes = GeneratedColumn<String>(
    'liked_vibes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearFromMeta = const VerificationMeta(
    'yearFrom',
  );
  @override
  late final GeneratedColumn<int> yearFrom = GeneratedColumn<int>(
    'year_from',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    likedGenres,
    vetoedGenres,
    likedVibes,
    yearFrom,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'taste_profile_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<TasteProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('liked_genres')) {
      context.handle(
        _likedGenresMeta,
        likedGenres.isAcceptableOrUnknown(
          data['liked_genres']!,
          _likedGenresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_likedGenresMeta);
    }
    if (data.containsKey('vetoed_genres')) {
      context.handle(
        _vetoedGenresMeta,
        vetoedGenres.isAcceptableOrUnknown(
          data['vetoed_genres']!,
          _vetoedGenresMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vetoedGenresMeta);
    }
    if (data.containsKey('liked_vibes')) {
      context.handle(
        _likedVibesMeta,
        likedVibes.isAcceptableOrUnknown(data['liked_vibes']!, _likedVibesMeta),
      );
    } else if (isInserting) {
      context.missing(_likedVibesMeta);
    }
    if (data.containsKey('year_from')) {
      context.handle(
        _yearFromMeta,
        yearFrom.isAcceptableOrUnknown(data['year_from']!, _yearFromMeta),
      );
    } else if (isInserting) {
      context.missing(_yearFromMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TasteProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TasteProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      likedGenres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liked_genres'],
      )!,
      vetoedGenres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vetoed_genres'],
      )!,
      likedVibes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}liked_vibes'],
      )!,
      yearFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_from'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TasteProfileTableTable createAlias(String alias) {
    return $TasteProfileTableTable(attachedDatabase, alias);
  }
}

class TasteProfileRow extends DataClass implements Insertable<TasteProfileRow> {
  final int id;

  /// `TasteProfile.likedGenres`, serialized as `id:name` pairs joined by
  /// commas (e.g. `"action:Action,drama:Drama"`) — a genre's `id` alone
  /// isn't enough to rebuild a `Genre` without a lookup table, and there
  /// isn't a normalized genre catalog in `core/domain` yet to look it up
  /// against, so both fields are stored directly.
  final String likedGenres;

  /// Same `id:name` serialization as [likedGenres].
  final String vetoedGenres;

  /// `TasteProfile.likedVibes`, comma-joined — vibe names come from
  /// `assets/vibes.json` and never contain a comma.
  final String likedVibes;
  final int yearFrom;
  final DateTime updatedAt;
  const TasteProfileRow({
    required this.id,
    required this.likedGenres,
    required this.vetoedGenres,
    required this.likedVibes,
    required this.yearFrom,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['liked_genres'] = Variable<String>(likedGenres);
    map['vetoed_genres'] = Variable<String>(vetoedGenres);
    map['liked_vibes'] = Variable<String>(likedVibes);
    map['year_from'] = Variable<int>(yearFrom);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TasteProfileTableCompanion toCompanion(bool nullToAbsent) {
    return TasteProfileTableCompanion(
      id: Value(id),
      likedGenres: Value(likedGenres),
      vetoedGenres: Value(vetoedGenres),
      likedVibes: Value(likedVibes),
      yearFrom: Value(yearFrom),
      updatedAt: Value(updatedAt),
    );
  }

  factory TasteProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TasteProfileRow(
      id: serializer.fromJson<int>(json['id']),
      likedGenres: serializer.fromJson<String>(json['likedGenres']),
      vetoedGenres: serializer.fromJson<String>(json['vetoedGenres']),
      likedVibes: serializer.fromJson<String>(json['likedVibes']),
      yearFrom: serializer.fromJson<int>(json['yearFrom']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'likedGenres': serializer.toJson<String>(likedGenres),
      'vetoedGenres': serializer.toJson<String>(vetoedGenres),
      'likedVibes': serializer.toJson<String>(likedVibes),
      'yearFrom': serializer.toJson<int>(yearFrom),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TasteProfileRow copyWith({
    int? id,
    String? likedGenres,
    String? vetoedGenres,
    String? likedVibes,
    int? yearFrom,
    DateTime? updatedAt,
  }) => TasteProfileRow(
    id: id ?? this.id,
    likedGenres: likedGenres ?? this.likedGenres,
    vetoedGenres: vetoedGenres ?? this.vetoedGenres,
    likedVibes: likedVibes ?? this.likedVibes,
    yearFrom: yearFrom ?? this.yearFrom,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TasteProfileRow copyWithCompanion(TasteProfileTableCompanion data) {
    return TasteProfileRow(
      id: data.id.present ? data.id.value : this.id,
      likedGenres: data.likedGenres.present
          ? data.likedGenres.value
          : this.likedGenres,
      vetoedGenres: data.vetoedGenres.present
          ? data.vetoedGenres.value
          : this.vetoedGenres,
      likedVibes: data.likedVibes.present
          ? data.likedVibes.value
          : this.likedVibes,
      yearFrom: data.yearFrom.present ? data.yearFrom.value : this.yearFrom,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TasteProfileRow(')
          ..write('id: $id, ')
          ..write('likedGenres: $likedGenres, ')
          ..write('vetoedGenres: $vetoedGenres, ')
          ..write('likedVibes: $likedVibes, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    likedGenres,
    vetoedGenres,
    likedVibes,
    yearFrom,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TasteProfileRow &&
          other.id == this.id &&
          other.likedGenres == this.likedGenres &&
          other.vetoedGenres == this.vetoedGenres &&
          other.likedVibes == this.likedVibes &&
          other.yearFrom == this.yearFrom &&
          other.updatedAt == this.updatedAt);
}

class TasteProfileTableCompanion extends UpdateCompanion<TasteProfileRow> {
  final Value<int> id;
  final Value<String> likedGenres;
  final Value<String> vetoedGenres;
  final Value<String> likedVibes;
  final Value<int> yearFrom;
  final Value<DateTime> updatedAt;
  const TasteProfileTableCompanion({
    this.id = const Value.absent(),
    this.likedGenres = const Value.absent(),
    this.vetoedGenres = const Value.absent(),
    this.likedVibes = const Value.absent(),
    this.yearFrom = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TasteProfileTableCompanion.insert({
    this.id = const Value.absent(),
    required String likedGenres,
    required String vetoedGenres,
    required String likedVibes,
    required int yearFrom,
    required DateTime updatedAt,
  }) : likedGenres = Value(likedGenres),
       vetoedGenres = Value(vetoedGenres),
       likedVibes = Value(likedVibes),
       yearFrom = Value(yearFrom),
       updatedAt = Value(updatedAt);
  static Insertable<TasteProfileRow> custom({
    Expression<int>? id,
    Expression<String>? likedGenres,
    Expression<String>? vetoedGenres,
    Expression<String>? likedVibes,
    Expression<int>? yearFrom,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (likedGenres != null) 'liked_genres': likedGenres,
      if (vetoedGenres != null) 'vetoed_genres': vetoedGenres,
      if (likedVibes != null) 'liked_vibes': likedVibes,
      if (yearFrom != null) 'year_from': yearFrom,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TasteProfileTableCompanion copyWith({
    Value<int>? id,
    Value<String>? likedGenres,
    Value<String>? vetoedGenres,
    Value<String>? likedVibes,
    Value<int>? yearFrom,
    Value<DateTime>? updatedAt,
  }) {
    return TasteProfileTableCompanion(
      id: id ?? this.id,
      likedGenres: likedGenres ?? this.likedGenres,
      vetoedGenres: vetoedGenres ?? this.vetoedGenres,
      likedVibes: likedVibes ?? this.likedVibes,
      yearFrom: yearFrom ?? this.yearFrom,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (likedGenres.present) {
      map['liked_genres'] = Variable<String>(likedGenres.value);
    }
    if (vetoedGenres.present) {
      map['vetoed_genres'] = Variable<String>(vetoedGenres.value);
    }
    if (likedVibes.present) {
      map['liked_vibes'] = Variable<String>(likedVibes.value);
    }
    if (yearFrom.present) {
      map['year_from'] = Variable<int>(yearFrom.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasteProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('likedGenres: $likedGenres, ')
          ..write('vetoedGenres: $vetoedGenres, ')
          ..write('likedVibes: $likedVibes, ')
          ..write('yearFrom: $yearFrom, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UserMediaEntriesTable userMediaEntries = $UserMediaEntriesTable(
    this,
  );
  late final $UserProfileTableTable userProfileTable = $UserProfileTableTable(
    this,
  );
  late final $TasteProfileTableTable tasteProfileTable =
      $TasteProfileTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userMediaEntries,
    userProfileTable,
    tasteProfileTable,
  ];
}

typedef $$UserMediaEntriesTableCreateCompanionBuilder =
    UserMediaEntriesCompanion Function({
      required MediaType mediaType,
      required int tmdbId,
      Value<String?> title,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> genres,
      Value<double?> voteAverage,
      Value<int?> voteCount,
      Value<double?> popularity,
      Value<int?> year,
      Value<bool> isFavorite,
      Value<bool> isWatchLater,
      Value<DateTime?> watchedAt,
      Value<int?> rating,
      Value<int?> runtimeMinutes,
      Value<int?> episodeCount,
      Value<int?> episodeRuntimeMinutes,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserMediaEntriesTableUpdateCompanionBuilder =
    UserMediaEntriesCompanion Function({
      Value<MediaType> mediaType,
      Value<int> tmdbId,
      Value<String?> title,
      Value<String?> posterPath,
      Value<String?> backdropPath,
      Value<String?> genres,
      Value<double?> voteAverage,
      Value<int?> voteCount,
      Value<double?> popularity,
      Value<int?> year,
      Value<bool> isFavorite,
      Value<bool> isWatchLater,
      Value<DateTime?> watchedAt,
      Value<int?> rating,
      Value<int?> runtimeMinutes,
      Value<int?> episodeCount,
      Value<int?> episodeRuntimeMinutes,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UserMediaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserMediaEntriesTable> {
  $$UserMediaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<MediaType, MediaType, String> get mediaType =>
      $composableBuilder(
        column: $table.mediaType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get voteCount => $composableBuilder(
    column: $table.voteCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWatchLater => $composableBuilder(
    column: $table.isWatchLater,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeRuntimeMinutes => $composableBuilder(
    column: $table.episodeRuntimeMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserMediaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserMediaEntriesTable> {
  $$UserMediaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tmdbId => $composableBuilder(
    column: $table.tmdbId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get voteCount => $composableBuilder(
    column: $table.voteCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWatchLater => $composableBuilder(
    column: $table.isWatchLater,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeRuntimeMinutes => $composableBuilder(
    column: $table.episodeRuntimeMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserMediaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserMediaEntriesTable> {
  $$UserMediaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<MediaType, String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get tmdbId =>
      $composableBuilder(column: $table.tmdbId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get posterPath => $composableBuilder(
    column: $table.posterPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backdropPath => $composableBuilder(
    column: $table.backdropPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumn<double> get voteAverage => $composableBuilder(
    column: $table.voteAverage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get voteCount =>
      $composableBuilder(column: $table.voteCount, builder: (column) => column);

  GeneratedColumn<double> get popularity => $composableBuilder(
    column: $table.popularity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isWatchLater => $composableBuilder(
    column: $table.isWatchLater,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get runtimeMinutes => $composableBuilder(
    column: $table.runtimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodeRuntimeMinutes => $composableBuilder(
    column: $table.episodeRuntimeMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserMediaEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserMediaEntriesTable,
          UserMediaEntryRow,
          $$UserMediaEntriesTableFilterComposer,
          $$UserMediaEntriesTableOrderingComposer,
          $$UserMediaEntriesTableAnnotationComposer,
          $$UserMediaEntriesTableCreateCompanionBuilder,
          $$UserMediaEntriesTableUpdateCompanionBuilder,
          (
            UserMediaEntryRow,
            BaseReferences<
              _$AppDatabase,
              $UserMediaEntriesTable,
              UserMediaEntryRow
            >,
          ),
          UserMediaEntryRow,
          PrefetchHooks Function()
        > {
  $$UserMediaEntriesTableTableManager(
    _$AppDatabase db,
    $UserMediaEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserMediaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserMediaEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserMediaEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<MediaType> mediaType = const Value.absent(),
                Value<int> tmdbId = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<int?> voteCount = const Value.absent(),
                Value<double?> popularity = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isWatchLater = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int?> runtimeMinutes = const Value.absent(),
                Value<int?> episodeCount = const Value.absent(),
                Value<int?> episodeRuntimeMinutes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserMediaEntriesCompanion(
                mediaType: mediaType,
                tmdbId: tmdbId,
                title: title,
                posterPath: posterPath,
                backdropPath: backdropPath,
                genres: genres,
                voteAverage: voteAverage,
                voteCount: voteCount,
                popularity: popularity,
                year: year,
                isFavorite: isFavorite,
                isWatchLater: isWatchLater,
                watchedAt: watchedAt,
                rating: rating,
                runtimeMinutes: runtimeMinutes,
                episodeCount: episodeCount,
                episodeRuntimeMinutes: episodeRuntimeMinutes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required MediaType mediaType,
                required int tmdbId,
                Value<String?> title = const Value.absent(),
                Value<String?> posterPath = const Value.absent(),
                Value<String?> backdropPath = const Value.absent(),
                Value<String?> genres = const Value.absent(),
                Value<double?> voteAverage = const Value.absent(),
                Value<int?> voteCount = const Value.absent(),
                Value<double?> popularity = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isWatchLater = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<int?> runtimeMinutes = const Value.absent(),
                Value<int?> episodeCount = const Value.absent(),
                Value<int?> episodeRuntimeMinutes = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserMediaEntriesCompanion.insert(
                mediaType: mediaType,
                tmdbId: tmdbId,
                title: title,
                posterPath: posterPath,
                backdropPath: backdropPath,
                genres: genres,
                voteAverage: voteAverage,
                voteCount: voteCount,
                popularity: popularity,
                year: year,
                isFavorite: isFavorite,
                isWatchLater: isWatchLater,
                watchedAt: watchedAt,
                rating: rating,
                runtimeMinutes: runtimeMinutes,
                episodeCount: episodeCount,
                episodeRuntimeMinutes: episodeRuntimeMinutes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserMediaEntriesTable, UserMediaEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserMediaEntriesTable,
                    UserMediaEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserMediaEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserMediaEntriesTable,
      UserMediaEntryRow,
      $$UserMediaEntriesTableFilterComposer,
      $$UserMediaEntriesTableOrderingComposer,
      $$UserMediaEntriesTableAnnotationComposer,
      $$UserMediaEntriesTableCreateCompanionBuilder,
      $$UserMediaEntriesTableUpdateCompanionBuilder,
      (
        UserMediaEntryRow,
        BaseReferences<
          _$AppDatabase,
          $UserMediaEntriesTable,
          UserMediaEntryRow
        >,
      ),
      UserMediaEntryRow,
      PrefetchHooks Function()
    >;
typedef $$UserProfileTableTableCreateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<int> id,
      required String displayName,
      required int initialColor,
      required DateTime updatedAt,
    });
typedef $$UserProfileTableTableUpdateCompanionBuilder =
    UserProfileTableCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<int> initialColor,
      Value<DateTime> updatedAt,
    });

class $$UserProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get initialColor => $composableBuilder(
    column: $table.initialColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialColor => $composableBuilder(
    column: $table.initialColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTableTable> {
  $$UserProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get initialColor => $composableBuilder(
    column: $table.initialColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTableTable,
          UserProfileRow,
          $$UserProfileTableTableFilterComposer,
          $$UserProfileTableTableOrderingComposer,
          $$UserProfileTableTableAnnotationComposer,
          $$UserProfileTableTableCreateCompanionBuilder,
          $$UserProfileTableTableUpdateCompanionBuilder,
          (
            UserProfileRow,
            BaseReferences<
              _$AppDatabase,
              $UserProfileTableTable,
              UserProfileRow
            >,
          ),
          UserProfileRow,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableTableManager(
    _$AppDatabase db,
    $UserProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<int> initialColor = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => UserProfileTableCompanion(
                id: id,
                displayName: displayName,
                initialColor: initialColor,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required int initialColor,
                required DateTime updatedAt,
              }) => UserProfileTableCompanion.insert(
                id: id,
                displayName: displayName,
                initialColor: initialColor,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserProfileTableTable, UserProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $UserProfileTableTable,
                    UserProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTableTable,
      UserProfileRow,
      $$UserProfileTableTableFilterComposer,
      $$UserProfileTableTableOrderingComposer,
      $$UserProfileTableTableAnnotationComposer,
      $$UserProfileTableTableCreateCompanionBuilder,
      $$UserProfileTableTableUpdateCompanionBuilder,
      (
        UserProfileRow,
        BaseReferences<_$AppDatabase, $UserProfileTableTable, UserProfileRow>,
      ),
      UserProfileRow,
      PrefetchHooks Function()
    >;
typedef $$TasteProfileTableTableCreateCompanionBuilder =
    TasteProfileTableCompanion Function({
      Value<int> id,
      required String likedGenres,
      required String vetoedGenres,
      required String likedVibes,
      required int yearFrom,
      required DateTime updatedAt,
    });
typedef $$TasteProfileTableTableUpdateCompanionBuilder =
    TasteProfileTableCompanion Function({
      Value<int> id,
      Value<String> likedGenres,
      Value<String> vetoedGenres,
      Value<String> likedVibes,
      Value<int> yearFrom,
      Value<DateTime> updatedAt,
    });

class $$TasteProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $TasteProfileTableTable> {
  $$TasteProfileTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get likedGenres => $composableBuilder(
    column: $table.likedGenres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vetoedGenres => $composableBuilder(
    column: $table.vetoedGenres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get likedVibes => $composableBuilder(
    column: $table.likedVibes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasteProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TasteProfileTableTable> {
  $$TasteProfileTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get likedGenres => $composableBuilder(
    column: $table.likedGenres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vetoedGenres => $composableBuilder(
    column: $table.vetoedGenres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get likedVibes => $composableBuilder(
    column: $table.likedVibes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearFrom => $composableBuilder(
    column: $table.yearFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasteProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasteProfileTableTable> {
  $$TasteProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get likedGenres => $composableBuilder(
    column: $table.likedGenres,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vetoedGenres => $composableBuilder(
    column: $table.vetoedGenres,
    builder: (column) => column,
  );

  GeneratedColumn<String> get likedVibes => $composableBuilder(
    column: $table.likedVibes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get yearFrom =>
      $composableBuilder(column: $table.yearFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TasteProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasteProfileTableTable,
          TasteProfileRow,
          $$TasteProfileTableTableFilterComposer,
          $$TasteProfileTableTableOrderingComposer,
          $$TasteProfileTableTableAnnotationComposer,
          $$TasteProfileTableTableCreateCompanionBuilder,
          $$TasteProfileTableTableUpdateCompanionBuilder,
          (
            TasteProfileRow,
            BaseReferences<
              _$AppDatabase,
              $TasteProfileTableTable,
              TasteProfileRow
            >,
          ),
          TasteProfileRow,
          PrefetchHooks Function()
        > {
  $$TasteProfileTableTableTableManager(
    _$AppDatabase db,
    $TasteProfileTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasteProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasteProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasteProfileTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> likedGenres = const Value.absent(),
                Value<String> vetoedGenres = const Value.absent(),
                Value<String> likedVibes = const Value.absent(),
                Value<int> yearFrom = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TasteProfileTableCompanion(
                id: id,
                likedGenres: likedGenres,
                vetoedGenres: vetoedGenres,
                likedVibes: likedVibes,
                yearFrom: yearFrom,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String likedGenres,
                required String vetoedGenres,
                required String likedVibes,
                required int yearFrom,
                required DateTime updatedAt,
              }) => TasteProfileTableCompanion.insert(
                id: id,
                likedGenres: likedGenres,
                vetoedGenres: vetoedGenres,
                likedVibes: likedVibes,
                yearFrom: yearFrom,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasteProfileTableTable, TasteProfileRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TasteProfileTableTable,
                    TasteProfileRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasteProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasteProfileTableTable,
      TasteProfileRow,
      $$TasteProfileTableTableFilterComposer,
      $$TasteProfileTableTableOrderingComposer,
      $$TasteProfileTableTableAnnotationComposer,
      $$TasteProfileTableTableCreateCompanionBuilder,
      $$TasteProfileTableTableUpdateCompanionBuilder,
      (
        TasteProfileRow,
        BaseReferences<_$AppDatabase, $TasteProfileTableTable, TasteProfileRow>,
      ),
      TasteProfileRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserMediaEntriesTableTableManager get userMediaEntries =>
      $$UserMediaEntriesTableTableManager(_db, _db.userMediaEntries);
  $$UserProfileTableTableTableManager get userProfileTable =>
      $$UserProfileTableTableTableManager(_db, _db.userProfileTable);
  $$TasteProfileTableTableTableManager get tasteProfileTable =>
      $$TasteProfileTableTableTableManager(_db, _db.tasteProfileTable);
}
