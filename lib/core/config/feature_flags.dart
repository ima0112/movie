/// What the first version ships without, kept as flags so it can come back
/// without rewriting anything.
///
/// **Match hub (B3).** The sheet the bottom bar's Match button opens, with
/// "Surprise me" and "Match with friends" (the Matcher, v1.1). While it is
/// `false` the button goes **straight to Surprise me's first screen (E1)**, and
/// the sheet (`MatchHubSheet`) stays in the code, untouched and unreachable,
/// for when the Matcher arrives: turn this on and the button opens it again.
const bool matchHubEnabled = false;
