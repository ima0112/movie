/// The two catalog kinds PakoTV works with.
///
/// Source of truth: `docs/STRUCTURE.md` (`core/domain/entities/`) and
/// `docs/DECISIONS.md` section 7 (domain model). Every list or detail
/// entity is a movie or a TV show — see `media_item.dart`.
enum MediaType { movie, tvShow }
