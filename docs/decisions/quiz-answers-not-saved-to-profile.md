# ADR: Quiz answers are never saved to the taste profile

**Status**: Accepted
**Date**: 2026-10-11

## Context

E2's guided quiz (and the Matcher's own per-person questionnaire, same
steps) produces a `ParticipantAnswers`: genres the person does **not**
want (up to 3 vetoes), vibes they **do** want (up to 3), how far back,
and a runtime/status limit. `TasteProfile` stores the opposite shape —
`likedGenres` (favorites), `vetoedGenres`, `likedVibes`, `yearFrom`.

Only two of the quiz's fields line up with the profile at all
(vetoed genres, liked vibes); the quiz never asks for favorite genres,
and `TasteProfile.likedGenres` has no quiz equivalent to fill it from.
An earlier version of this document described a "Save these answers as
your tastes?" prompt at the end of the quiz — that was never built.

## Decision

`QuizCubit` has no method that writes to `TasteProfileRepository` and
never will, on its own. Its own doc comment states this explicitly:
wiring in a profile save would couple a Cubit whose entire contract is
"produce a `ParticipantAnswers` for whoever invoked it" to one specific
downstream consumer. A future screen that wants "answer the quiz, then
offer to save it as your tastes" can read the `ParticipantAnswers` this
Cubit already produces and call `TasteProfileCubit`'s own setters
itself — composition at the call site, not a feature inside the quiz.

Saving tastes happens in exactly one place today: Settings → My Tastes
(`my_tastes_cubit.dart`), which is also where `ChooseSource`/H11's
"Use my tastes" vs "Answer the quiz instead" choice (E1) reads the
profile from.
