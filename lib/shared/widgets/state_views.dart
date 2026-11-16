/// The state widgets in one import — skeletons, the empty / error / offline
/// states and the offline banner (`docs/SCREENS.md` G). Each lives in its own
/// file; this barrel keeps the many importers short.
library;

export 'empty_state_view.dart';
export 'error_state_view.dart';
export 'failure_state_view.dart';
export 'offline_banner.dart';
export 'offline_state_view.dart';
export 'skeleton_block.dart';
export 'state_layout.dart';
