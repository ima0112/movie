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
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [userMediaEntries];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UserMediaEntriesTableTableManager get userMediaEntries =>
      $$UserMediaEntriesTableTableManager(_db, _db.userMediaEntries);
}
