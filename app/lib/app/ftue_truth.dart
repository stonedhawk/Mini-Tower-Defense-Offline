import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// The screens a player can see, as the ids the FTUE truth log uses.
///
/// The ids match the steps in ftue-friction-agent's
/// `examples/steps.mini-td.yaml`. [unknown] is for a screen no step describes.
enum FtueStep {
  levelSelect('level_select'),
  emptyBattlefield('empty_battlefield'),
  buildMenu('build_menu'),
  defending('defending'),
  runEnd('run_end'),
  gameOver('game_over'),
  unknown('unknown');

  const FtueStep(this.id);

  final String id;
}

/// Tells screens when they become visible again, so the level select can
/// report itself when the player comes back to it.
final RouteObserver<ModalRoute<void>> ftueRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// Debug-only screen report for the ftue-friction-agent golden recordings.
///
/// Each time the player's screen changes, debug builds print one line such
/// as `FTUE_TRUTH step=build_menu` to the device log. The same step is never
/// printed twice in a row. Release and profile builds print nothing.
///
/// This is not analytics: nothing is stored or sent anywhere.
class FtueTruth {
  const FtueTruth._();

  static const linePrefix = 'FTUE_TRUTH step=';

  static FtueStep? _lastReportedStep;

  static void report(FtueStep step, {bool isDebugMode = kDebugMode}) {
    if (!isDebugMode) {
      return;
    }

    if (step == _lastReportedStep) {
      return;
    }

    _lastReportedStep = step;
    debugPrint('$linePrefix${step.id}');
  }

  @visibleForTesting
  static void resetForTest() {
    _lastReportedStep = null;
  }
}

/// Which step the game screen is showing.
///
/// The "You Win!" overlay covers everything, then the tower build menu.
/// Without either, the map counts as defending once a tower has been built.
FtueStep battlefieldStep({
  required bool winOverlay,
  required bool buildMenuOpen,
  required bool hasBuiltTower,
}) {
  if (winOverlay) return FtueStep.runEnd;
  if (buildMenuOpen) return FtueStep.buildMenu;
  if (hasBuiltTower) return FtueStep.defending;
  return FtueStep.emptyBattlefield;
}
